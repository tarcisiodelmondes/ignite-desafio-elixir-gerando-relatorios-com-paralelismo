defmodule GenReport do
  alias GenReport.Parser

  @frelances [
    "cleiton",
    "daniele",
    "danilo",
    "diego",
    "giuliano",
    "jakeliny",
    "joseph",
    "mayk",
    "rafael",
    "vinicius"
  ]

  @moths [
    "janeiro",
    "fevereiro",
    "março",
    "abril",
    "maio",
    "junho",
    "julho",
    "agosto",
    "setembro",
    "outubro",
    "novembro",
    "dezembro"
  ]

  @years [2016, 2017, 2018, 2019, 2020]

  def build(filename) do
    filename
    |> Parser.parse_file()
    |> Enum.reduce(report_acc(), fn line, report -> sum_values(line, report) end)
  end

  def build() do
    {:error, "Insira o nome de um arquivo"}
  end

  def build_from_many(filenames) when not is_list(filenames) do
    {:error, "Please provide a list of strings"}
  end

  def build_from_many(filenames) do
    result =
      filenames
      |> Task.async_stream(&build/1)
      |> Enum.reduce(report_acc(), fn {_ok, result}, report -> sum_reports(report, result) end)

    {:ok, result}
  end

  defp sum_values([name, hour, _day, month, year], %{
         "all_hours" => all_hours,
         "hours_per_month" => hours_per_month,
         "hours_per_year" => hours_per_year
       }) do
    all_hours = Map.put(all_hours, name, all_hours[name] + hour)

    hours_per_month =
      Map.put(
        hours_per_month,
        name,
        Map.put(
          hours_per_month[name],
          month,
          hours_per_month[name][month] + hour
        )
      )

    hours_per_year =
      Map.put(
        hours_per_year,
        name,
        Map.put(hours_per_year[name], year, hours_per_year[name][year] + hour)
      )

    build_report(all_hours, hours_per_month, hours_per_year)
  end

  defp sum_reports(
         %{
           "all_hours" => all_hours1,
           "hours_per_month" => hours_per_month1,
           "hours_per_year" => hours_per_year1
         },
         %{
           "all_hours" => all_hours2,
           "hours_per_month" => hours_per_month2,
           "hours_per_year" => hours_per_year2
         }
       ) do
    all_hours =
      Map.merge(all_hours1, all_hours2, fn _key, value1, value2 ->
        value1 + value2
      end)

    hours_per_month = merge_maps(hours_per_month1, hours_per_month2)
    hours_per_year = merge_maps(hours_per_year1, hours_per_year2)

    build_report(all_hours, hours_per_month, hours_per_year)
  end

  defp report_acc() do
    all_hours = Enum.into(@frelances, %{}, &{&1, 0})
    hours_per_month = gen_report_map(@moths)
    hours_per_year = gen_report_map(@years)

    build_report(all_hours, hours_per_month, hours_per_year)
  end

  defp merge_maps(data1, data2) do
    Map.merge(data1, data2, fn _key, map1, map2 ->
      Map.merge(map1, map2, fn _key, value1, value2 -> value1 + value2 end)
    end)
  end

  defp gen_report_map(data) do
    Enum.into(@frelances, %{}, fn elem ->
      new_map = Enum.into(data, %{}, &{&1, 0})
      {elem, new_map}
    end)
  end

  defp build_report(all_hours, hours_per_month, hours_per_year),
    do: %{
      "all_hours" => all_hours,
      "hours_per_month" => hours_per_month,
      "hours_per_year" => hours_per_year
    }
end
