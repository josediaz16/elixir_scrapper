defmodule HoundExample do

  use Hound.Helpers

  def start do
    Hound.start_session
    navigate_to "http://www.instagram.com/elephantjournal"
    execute_script "window.document.body.scrollTop = document.body.scrollHeight;"

    page_source()
    |> Floki.find(".v1Nh3.kIKUG._bz0w a")
    |> Floki.attribute("href")
    |> Enum.map(fn code -> "https://www.instagram.com#{code}" end)
  end
end

links = HoundExample.start
IO.puts inspect(links)
results = Collector.Example.from_links(links)

IO.puts length(results)
Enum.each(results, fn result -> IO.puts(inspect(result)) end)
