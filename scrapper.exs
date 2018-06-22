results = Collector.Example.parse("https://www.instagram.com/elephantjournal/")
IO.puts length(results)
Enum.each(results, fn result -> IO.puts(inspect(result)) end)
