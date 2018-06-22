defmodule Collector.InstagramWeb do

  def fetch_and_parse(link) do
    link
      |> get_page
      |> Floki.find("script:fl-contains('window._sharedData =')")
      |> get_match_data
  end

  defp get_page(link) do
    case HTTPoison.get(link, [], hackney: [pool: :first_pool]) do
      {:ok, %HTTPoison.Response{body: body, status_code: status_code}} ->
        IO.puts "link: #{link}, status_code: #{status_code}"
        body
      {:error, %HTTPoison.Error{}} -> get_page(link)
    end
  end

  defp get_match_data([
      {"script", _, [
        "window._sharedData = " <> text
        ]
      }
    ]) do

    Regex.named_captures(~r/(?<data>.+);/, text)["data"]
      |> Poison.decode
  end
end
