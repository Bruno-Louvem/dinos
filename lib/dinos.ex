defmodule Dinos do
  @first_dataset "dataset1.csv"
  @first_dataset_header ~w("NAME" "LEG_LENGTH" "DIET")

  @second_dataset "dataset2.csv"
  @second_dataset_header ~w("NAME", "STRIDE_LENGTH", "STANCE")

  def run() do
    %{}
    # |> read_first_dataset()
    |> read_second_dataset()
    # |> proccess_business_logic()
  end

  defp proccess_business_logic(unified_dataset) do

  end

  def read_first_dataset(unified_dataset) do
    build_priv_dir()
    |> Path.join(@first_dataset)
    |> read_csv(@first_dataset_header)
    |> normalize_dataset
    |> update_dataset(unified_dataset)
  end

  def read_second_dataset(unified_dataset) do
    build_priv_dir()
    |> Path.join(@second_dataset)
    |> read_csv(@second_dataset_header)
    |> normalize_dataset
    # |> update_dataset(unified_dataset)
  end

  def update_dataset(set, unified_dataset) do
    unified_dataset
    |> IO.inspect
    |> Map.merge(set |> IO.inspect)
    # |> Enum.filter(fn {k, v} -> k != nil end)
  end

  """
  This function normalize map keys removing the \"
  and remove header from dataset
  """
  defp normalize_dataset(unified_dataset) do
    unified_dataset
    |> Enum.map(fn x ->  x
      |> Enum.reduce(%{}, fn
        {k, v}, acc -> Map.merge(acc, %{k |> String.trim("\"") => v})
      end)
    end)
    |> List.delete_at(0)
    |> Enum.reduce(%{}, fn x, acc ->
      Map.merge(acc, %{x["NAME"] => x |> Map.drop(["NAME"])})
    end)
  end

  defp build_priv_dir() do
    :code.priv_dir(:dinos)
    |> Path.join("csv")
  end

  defp read_csv(csv_path, headers) do
    csv_path
    |> IO.inspect
    |> File.stream!()
    |> CSV.decode!(headers: headers, strip_fields: true)
  end
end
