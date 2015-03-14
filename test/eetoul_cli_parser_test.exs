defmodule EetoulCLIParserTest do
  use ExUnit.Case
	use Geef
	alias Eetoul.CLI
	alias Eetoul.CLI.ParseError
	alias Eetoul.Test.SampleSpecRepo

	setup_all do
		{a, b, c} = :erlang.now
		:random.seed a, b, c
		path = "tmp-#{:random.uniform 1000000}"
		case SampleSpecRepo.create path do
			{:ok, repo} ->
				on_exit fn -> File.rm_rf path end
				{:ok, repo: repo}
			e -> e
		end
	end

	test "read_spec utility method", meta do
		assert CLI.read_spec(meta[:repo], "first-release") ==
			{:ok, ""}
		assert CLI.read_spec(meta[:repo], "first-branch") ==
			{:error, "The path 'first-branch' does not exist in the given tree"}
	end
	
  test "`edit <release>`", meta do
    assert CLI.test_cli_argument_parser(meta[:repo], ["edit", "first-release"]) ==
			%{release: "first-release"}
  end

  test "`edit <wrong-release>` fails", meta do
		assert_raise ParseError, "the release \"zeroth-release\" does not exist", fn ->
			CLI.test_cli_argument_parser meta[:repo], ["edit", "zeroth-release"]
		end
  end

  test "`edit <release> --amend`", meta do
    assert CLI.test_cli_argument_parser(meta[:repo], ["edit", "first-release", "--amend"]) ==
			%{release: "first-release", amend: true}
  end

  test "`edit` fails", meta do
    assert_raise ParseError, "no release was specified", fn ->
			CLI.test_cli_argument_parser meta[:repo], ["edit"]
		end
  end

  test "`edit <release> arg` fails", meta do
    assert_raise ParseError, "invalid arguments", fn ->
			CLI.test_cli_argument_parser meta[:repo], ["edit", "first-release", "arg"]
		end
  end

  test "`edit <release> --amend arg` fails", meta do
    assert_raise ParseError, "invalid arguments", fn ->
			CLI.test_cli_argument_parser meta[:repo], ["edit", "first-release", "--amend", "arg"]
		end
  end

  test "`noop` fails with ParseError", meta do
    assert_raise ParseError, "unknown command noop", fn ->
			CLI.test_cli_argument_parser meta[:repo], ["noop"]
		end
  end
end