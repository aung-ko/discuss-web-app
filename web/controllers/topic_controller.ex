defmodule Discuss.TopicController do
    use Discuss.Web, :controller

    alias Discuss.Topic

    def index(conn, _params) do
      topics = Repo.all(Topic)
      render conn, "index.html", topics: topics
    end
  
    def new(conn, _params) do
      # struct = %Topic{}
      # params = %{}
      changeset = Topic.changeset(%Topic{}, %{})

      render conn, "new.html", changeset: changeset
    end

    # params = %{"_csrf_token" => "blahblah", "utf-8" => "true", "topic" => %{"title" => "asdf"}}
    # %{"topic" => topic} = params
    def create(conn, %{"topic" => topic}) do
      changeset = Topic.changeset(%Topic{}, topic)

      case Repo.insert(changeset) do
        {:ok, post} -> 
          conn
          |> put_flash(:info, "Topic Created")
          |> redirect(to: topic_path(conn, :index))
        {:error, changeset} -> 
          render conn, "new.html", changeset: changeset
      end

    end
    
  end
  