defmodule Collector.Example do
  alias Collector.{InstagramWeb}

  def parse(link) do
     link
      |> InstagramWeb.fetch_and_parse
      |> map_links
      |> from_links
  end

  def from_links(links) do
    links
      |> get_interactors
      |> get_public_accounts
  end

  defp get_interactors(links) do
    links
      |> Enum.map(fn link -> Task.async(fn -> get_screen_names(link) end) end)
      |> Enum.flat_map(fn task -> Task.await(task) end)
      |> Enum.uniq
  end

  def get_public_accounts(screen_names) do
    screen_names
      |> Enum.take(100)
      |> Enum.chunk_every(20)
      |> Enum.flat_map(fn screen_names ->
          Process.sleep(1000)
          get_accounts_by_chunk(screen_names)
      end)
  end

  def get_accounts_by_chunk(screen_names) do
    screen_names
      |> Enum.map(fn screen_name -> Task.async(fn -> get_profile_info(screen_name) end) end)
      |> Enum.map(fn task -> Task.await(task) end)
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
      |> profile_info()
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

  defp map_links(_), do: []

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

  defp map_screen_names(_), do: []

  defp profile_info({:ok, %{
    "entry_data" => %{
      "ProfilePage" => [
        %{
          "graphql" => %{
            "user" => %{
              "is_private" => private,
              "profile_pic_url" => profile_url,
              "full_name" => full_name,
              "username" => username
            }
          }
        }
      ]
    }
  }}) do
    %{screen_name: username, private: private, profile_url: profile_url, full_name: full_name, username: username}
  end
end
