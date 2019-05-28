defmodule Dinos do
  @first_dataset "dataset1.csv"
  @first_dataset_header ~w(NAME LEG_LENGTH DIET)

  @second_dataset "dataset2.csv"
  @second_dataset_header ~w(NAME STRIDE_LENGTH STANCE)

  @output_file "output.txt"

  def start() do
    read_biped()
    |> load_velocity()
    |> Enum.sort_by(&Map.fetch(&1, "VELOCITY"),  &>=/2)
    |> write_file()
  end

  def write_file(dataset) do
    file = open_output_file()
    
    dataset
    |> Enum.each(fn x -> 
      IO.binwrite(file, "#{x["NAME"]}\n") 
    end)
  end

  def open_output_file() do
    {:ok, file} = 
      :code.priv_dir(:dinos)
      |> Path.join(@output_file)
      |> File.open([:write])
    file
  end

  defp read_biped() do
    build_priv_dir()
    |> Path.join(@second_dataset)
    |> read_csv(@second_dataset_header)
    |> Enum.filter(fn x -> x["STANCE"] == "bipedal" end)
  end

  defp get_biped_names(biped_dataset) do
    biped_dataset
    |> Enum.map(fn x -> x["NAME"] end)
  end

  def search_leg_length(dino_names) do
    build_priv_dir()
    |> Path.join(@first_dataset)
    |> read_csv(@first_dataset_header)
    |> Enum.reduce(%{}, fn x, acc ->
      with {ll_float, _} <- x["LEG_LENGTH"] |> Float.parse,
           true <- dino_names |> Enum.member?(x["NAME"])
      do
        x = x |> Map.merge(%{
          "LEG_LENGTH" => ll_float
        })
        
        acc
        |> Map.merge(%{x["NAME"] => x |> Map.drop(["NAME"])})
      else
        _ -> acc
      end
    end)
  end

  defp load_velocity(biped_dataset) do
    dino_names = get_biped_names(biped_dataset)
    leg_length_dataset = search_leg_length(dino_names)
    biped_dataset
    |> Enum.reduce([], fn x, acc -> 
      dino_leg_length = leg_length_dataset[x["NAME"]]["LEG_LENGTH"]
      with true <- dino_leg_length |> is_float() do
        x = x |> Map.put("LEG_LENGTH", dino_leg_length)
        dino_velocity = get_dino_velocity(x)
        x = x |> Map.put_new("VELOCITY", dino_velocity)
        acc ++ [x]
      else
        _ -> acc
      end      
    end)
  end

  defp get_dino_velocity(dino_map) do
    dino_map["STRIDE_LENGTH"] 
    |> Float.parse
    |> elem(0)
    |> calc_velocity(dino_map["LEG_LENGTH"])
  end

  defp calc_velocity(stride_length, leg_length) do
    ((stride_length / leg_length) - 1) * :math.sqrt(leg_length * 9.8)
  end

  defp build_priv_dir() do
    :code.priv_dir(:dinos)
    |> Path.join("csv")
  end

  defp read_csv(csv_path, headers) do
    csv_path
    |> File.stream!()
    |> CSV.decode!(headers: headers)
  end
end
