defmodule DinosTest do
  use ExUnit.Case

  @output_file "output.txt"

  setup do
    clear_output_file()
  end

  test "Do classify" do
    {:ok, output_file} = read_output_file()
    assert output_file |> String.length() == 0
    assert Dinos.classify() == :ok
    {:ok, new_output_file} = read_output_file()
    assert new_output_file |> String.length() > 0
  end

  test "Do classify without file" do
    remove_output_file()
    {:error, _} = read_output_file()

    assert Dinos.classify() == :ok
    {:ok, _} = read_output_file()
  end

  test "Do Test search_leg_length" do
    assert Dinos.search_leg_length() |> is_map()
  end

  defp get_output_file() do
    get_output_file_path()
    |> File.open([:write])
  end

  defp get_output_file_path() do
    :code.priv_dir(:dinos)
    |> Path.join(@output_file)
  end

  def read_output_file() do
    get_output_file_path()
    |> File.read()
  end

  defp clear_output_file() do
    case get_output_file() do
      {:ok, file} -> file |> IO.binwrite("")
      _ -> ""
    end
  end

  defp remove_output_file() do
    get_output_file_path()
    |> File.rm()
  end
end
