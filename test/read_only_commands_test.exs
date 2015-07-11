defmodule EetoulReadOnlyCommandsTest do
  use ExUnit.Case
  import Eetoul.Test.Utils
  alias Eetoul.CLI
  alias Eetoul.Test.SampleSpecRepo

  setup_all do
    {a, b, c} = :erlang.timestamp
    :random.seed a, b, c
    path = "tmp-#{__MODULE__}-#{:random.uniform 1000000}"
    File.rm_rf path
    on_exit fn -> File.rm_rf path end
    case SampleSpecRepo.create path do
      {:ok, repo} ->
        {:ok, repo: repo}
      e -> e
    end
  end

  test "`help` prints full help", meta do
    call = fn ->
      CLI.run_command meta[:repo], ["help"]
    end
    assert capture_io(call) == %{value: {:ok, nil}, stdout: File.read!("HELP.txt"), stderr: ""}
  end

  test "`cat first-release` prints release spec", meta do
    call = fn ->
      CLI.run_command meta[:repo], ["cat", "first-release"]
    end
    assert capture_io(call) == %{value: {:ok, nil}, stdout: "checkout first-branch\ntake first-branch\n", stderr: ""}
  end

  test "`cat no-release` prints error message", meta do
    call = fn ->
      CLI.run_command meta[:repo], ["cat", "no-release"]
    end
    assert capture_io(call) == %{value: {:ok, nil}, stdout: "", stderr: "The release \"no-release\" does not exist.\n"}
  end

  test "`acat ancient-release` prints archived release spec", meta do
    call = fn ->
      CLI.run_command meta[:repo], ["acat", "ancient-release"]
    end
    assert capture_io(call) == %{value: {:ok, nil}, stdout: "checkout no-commit\n", stderr: ""}
  end

  test "`acat no-ancient-release` prints error message", meta do
    call = fn ->
      CLI.run_command meta[:repo], ["acat", "no-ancient-release"]
    end
    assert capture_io(call) == %{value: {:ok, nil}, stdout: "", stderr: "The archived release \"no-ancient-release\" does not exist.\n"}
  end
end
