defmodule Dinos do
  @first_dataset "dataset1.csv"
  @first_dataset_header ~w(NAME LEG_LENGTH DIET)

  @second_dataset "dataset2.csv"
  @second_dataset_header ~w(NAME STRIDE_LENGTH STANCE)

  @output_file "output.txt"

  #Main pipeline for classify the fastest dinosaur
  def classify() do
    read_biped()
    |> load_velocity()
    |> Enum.sort_by(fn x -> x |> Map.fetch("VELOCITY") end,  &>=/2)
    |> write_file()
  end

  # Iterate on dataset and write dinosaur name in output file
  def write_file(dataset) do
    file = open_output_file()

    dataset
    |> Enum.each(fn x ->
      IO.binwrite(file, "#{x["NAME"]}\n")
    end)
  end

  # open output file and return file stream
  defp open_output_file() do
    {:ok, file} =
      :code.priv_dir(:dinos)
      |> Path.join(@output_file)
      |> File.open([:write])
    file
  end

  #Extract all biped dinosaurs from dataset2
  defp read_biped() do
    build_priv_dir()
    |> Path.join(@second_dataset)
    |> read_csv(@second_dataset_header)
    |> Enum.filter(fn x -> x["STANCE"] == "bipedal" end)
  end

  def search_leg_length() do
    build_priv_dir()
    |> Path.join(@first_dataset)
    |> read_csv(@first_dataset_header)
    |> do_extract_biped_leg_length()
  end

  defp do_extract_biped_leg_length(dataset) do
    dataset
    |> Enum.reduce(%{}, fn x, acc ->
      with {ll_float, _} <- x["LEG_LENGTH"] |> Float.parse do
        acc |> Map.merge(%{x["NAME"] => ll_float})
      else
        _ -> acc
      end
    end)
  end

  #Get all dinos leg length and calc the
  #velocity for each biped dinosaur
  defp load_velocity(biped_dataset) do
    leg_length_dataset = search_leg_length()

    biped_dataset
    |> Enum.reduce([], fn bipede, acc ->
      dino_velocity =
        bipede["STRIDE_LENGTH"]
        |> get_dino_velocity(leg_length_dataset[bipede["NAME"]])

      bipede
      |> Map.put_new("VELOCITY", dino_velocity)
      |> remove_zero(acc, dino_velocity)
    end)
  end

  #Remove register when velocity is 0
  defp remove_zero(_, acc, 0), do: acc
  defp remove_zero(register, acc, _), do: acc ++ [register]

  #Fallback when not possible read leg length dino
  defp get_dino_velocity(_, nil), do: 0
  defp get_dino_velocity(stride_length, leg_length) do
    case stride_length |> Float.parse do
      {stride_length, _} ->
        calc_velocity(stride_length, leg_length)
      _ -> 0
    end
  end
  #Function responsible for calc dino velocity
  defp calc_velocity(stride_length, leg_length) do
    ((stride_length / leg_length) - 1) * :math.sqrt(leg_length * 9.8)
  end

  #Get private dir where csv's are located
  defp build_priv_dir() do
    :code.priv_dir(:dinos)
    |> Path.join("csv")
  end

  #Load CSV
  defp read_csv(csv_path, headers) do
    csv_path
    |> File.stream!()
    |> CSV.decode!(headers: headers)
  end
end
