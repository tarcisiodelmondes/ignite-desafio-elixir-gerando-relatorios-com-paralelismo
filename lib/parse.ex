defmodule GenReport.Parser do
  @moths %{
    "1" => "janeiro",
    "2" => "fevereiro",
    "3" => "março",
    "4" => "abril",
    "5" => "maio",
    "6" => "junho",
    "7" => "julho",
    "8" => "agosto",
    "9" => "setembro",
    "10" => "outubro",
    "11" => "novembro",
    "12" => "dezembro"
  }

  def parse_file(filename) do
    filename
    |> File.stream!()
    |> Stream.map(&parse_line/1)
  end

  defp parse_line(line) do
    line
    |> String.trim()
    |> String.split(",")
    |> return_name_of_month()
    |> Enum.map(fn string ->
      case Integer.parse(string) do
        {number, _rest} -> number
        :error -> String.downcase(string)
      end
    end)
  end

  defp return_name_of_month(list) do
    List.update_at(list, 3, &@moths[&1])
  end
end
