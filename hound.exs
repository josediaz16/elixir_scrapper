defmodule HoundExample do

  use Hound.Helpers

  def start(screen_name) do
    navigate_to "http://www.instagram.com/#{screen_name}"
    (1 .. 16)
      |> Enum.flat_map(fn _ ->
        execute_script("window.scrollTo(0, document.body.scrollHeight)")
        Process.sleep(1000)
        page_source()
          |> Floki.find(".v1Nh3.kIKUG._bz0w a")
          |> Floki.attribute("href")
          |> Enum.map(fn code -> "https://www.instagram.com#{code}" end)
    end)
      |> Enum.uniq
  end
end

Hound.start_session
screen_names = File.stream!("new_names_3") |> Stream.map(&String.trim_trailing/1)  |> Enum.to_list |> Enum.slice(491, 8)

screen_names
  |> Enum.map(fn screen_name -> 
    IO.puts screen_name
    links = HoundExample.start(screen_name)
    [%{screen_name => links, "count" => length(links)}]
      |> Stream.map(&(inspect(&1, limit: :infinity) <> "\n"))
      |> Stream.into(File.stream!("los_screen_names_4", [:append, :utf8]))
      |> Stream.run

  end)

Hound.end_session

