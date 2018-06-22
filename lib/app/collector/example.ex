defmodule Collector.Example do
  alias Collector.{InstagramWeb, Async}

  def parse(link) do
     link
      |> InstagramWeb.fetch_and_parse
      |> map_links
      |> get_interactors
      |> get_public_accounts
  end

  defp get_interactors(links) do
    links
      |> Enum.map(fn link -> Async.async_send(link, &get_screen_names/1) end)
      |> Enum.flat_map(fn _ -> Async.collect() end)
      |> Enum.uniq
  end

  def get_public_accounts(screen_names) do
    screen_names
      |> Enum.take(80)
      |> Enum.chunk_every(40)
      |> Enum.flat_map(fn screen_names ->
          Process.sleep(5000)
          get_accounts_by_chunk(screen_names)
      end)
  end

  def get_accounts_by_chunk(screen_names) do
    screen_names
      |> Enum.map(fn screen_name -> Async.async_send(screen_name, &get_profile_info/1) end)
      |> Enum.map(fn _ -> Async.collect end)
  end

  defp get_screen_names(link) do
    link
      |> InstagramWeb.fetch_and_parse
      |> map_screen_names
  end

  defp get_profile_info(screen_name) do
    link = "https://www.instagram.com/#{screen_name}/"
      link
      |> InstagramWeb.fetch_and_parse
      |> profile_info(screen_name)
  end

  defp map_links({:ok, %{
    "entry_data" => %{
      "ProfilePage" => [
        %{
          "graphql" => %{
            "user" => %{
              "edge_owner_to_timeline_media" => %{
                "edges" => posts
              }
            }
          }
        }
      ]
    }
  }}) do

    Enum.map(posts, fn %{"node" => %{"shortcode" => code}} -> 
      "https://www.instagram.com/p/#{code}/"
    end)
  end

  defp map_screen_names({:ok, %{
    "entry_data" => %{
      "PostPage" => [
        %{
          "graphql" => %{
            "shortcode_media" => %{
              "edge_media_preview_like" => %{
                "edges" => likers
              },
              "edge_media_to_comment" => %{
                "edges" => commenters
              }
            }
          }
        }
      ]
    }
  }}) do

    liker_screen_names = Enum.map(likers, fn liker -> liker["node"]["username"] end)
    commenter_screen_names = Enum.map(commenters, fn commenter -> commenter["node"]["owner"]["username"] end)
    liker_screen_names ++ commenter_screen_names
  end

  defp profile_info({:ok, %{
    "entry_data" => %{
      "ProfilePage" => [
        %{
          "graphql" => %{
            "user" => %{
              "is_private" => private
            }
          }
        }
      ]
    }
  }}, screen_name) do
    %{screen_name => private}
  end
end
