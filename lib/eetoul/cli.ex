defmodule Eetoul.CLI.ParseError do
	defexception message: "invalid arguments"
end

defmodule Eetoul.CLI do
	use Geef
	require Monad.Error, as: Error
	alias Eetoul.CLI.ParseError

	@doc false
	def test_cli_argument_parser repo, argv do
		cli_command repo, argv, dryrun: true
	end

	@external_resource commands_path = Path.join [__DIR__, "commands"]
	{:ok, command_file_names} = File.ls commands_path
	@commands (command_file_names
						 |> Enum.map(&(String.replace(&1, ".ex", "")))
						 |> Enum.map(&(Regex.replace(~r/(?:^|_)([a-z])/, &1, (fn _, x -> String.upcase x end), [global: true]))) # converting snake_case to PascalCase
						 |> Enum.map(&(:'Elixir.Eetoul.Commands.#{&1}')))

	defp cli_command(repo, command, options \\ [])
	for command <- @commands do
		defp cli_command(repo, [unquote(Macro.escape(command.name)) | args], _options) do
			spec = unquote(Macro.escape(command.arguments))
			parse_arguments repo, spec, args
		end
	end
	defp cli_command _repo, [command | _args], _options do
		raise ParseError, message: "unknown command #{command}"
	end
	defp cli_command _repo, [], _options do
		raise ParseError, message: "no command specified"
	end

	defp prettify_name name do
		name
		|> Atom.to_string
		|> String.replace("_", " ")
	end
	
	defp parse_arguments repo, [{:release, name, :existing} | specs], [value | args] do
		case read_spec repo, value do
			{:ok, _} ->
				parse_arguments(repo, specs, args)
				|> Dict.put(name, value)
			_ -> raise ParseError, message: "the #{prettify_name name} \"#{value}\" does not exist"
		end
	end
	defp parse_arguments repo, [{:release, name, :new} | specs], [value | args] do
		case read_spec repo, value do
			{:error, _} ->
				parse_arguments(repo, specs, args)
				|> Dict.put(name, value)
			_ -> raise ParseError, message: "the #{prettify_name name} \"#{value}\" already exists"
		end
	end
	defp parse_arguments repo, [{:release, name, :archived} | specs], [value | args] do
		case read_spec repo, ".archive/#{value}" do
			{:ok, _} ->
				parse_arguments(repo, specs, args)
				|> Dict.put(name, value)
			_ -> raise ParseError, message: "the #{prettify_name name} \"#{value}\" does not exist"
		end
	end
	defp parse_arguments _repo, [{:release, name, _} | _], [] do
		raise ParseError, message: "no #{prettify_name name} was specified"
	end

	defp parse_arguments repo, [{:reference, name} | specs], [value | args] do
		case Reference.dwim repo, value do
			{:ok, %Reference{name: real_name}} ->
				parse_arguments(repo, specs, args)
				|> Dict.put(name, real_name)
			_ -> raise ParseError, message: "the #{prettify_name name} \"#{value}\" does not exist"
		end
	end
	defp parse_arguments _repo, [{:reference, name} | _], [] do
		raise ParseError, message: "no #{prettify_name name} was specified"
	end

	defp parse_arguments repo, [{:options, spec} | []], args do
		case OptionParser.parse(args, strict: spec) do
			{options, [], []} -> Enum.into options, parse_arguments(repo, [], [])
			{_options, _argv, _errors} -> raise ParseError
		end
	end
	defp parse_arguments _repo, [{:options, _spec} | _], _args do
		raise ParseError, message: ":options must be the last arguments specification"
	end

	defp parse_arguments(_repo, [], []), do: %{}
	defp parse_arguments _repo, [], [arg | _args] do
		raise ParseError, message: "invalid arguments starting with #{arg}"
	end

	defp run_command repo, name, data do
		# TODO implement
		IO.inspect {repo, name, data}
	end

	def read_spec repo, spec do
		Error.m do
			%Reference{target: commit_id} <- Reference.lookup(repo, "refs/heads/eetoul-spec")
			commit <- Commit.lookup(repo, commit_id)
			tree <- Commit.tree(commit)
			%TreeEntry{id: file_id} <- Tree.get(tree, spec)
			blob <- Blob.lookup(repo, file_id)
			content <- Blob.content(blob)
			return content
		end
	end
end
