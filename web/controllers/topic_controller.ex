defmodule Discuss.TopicController do
    use Discuss.Web, :controller

    alias Discuss.Topic

    plug Discuss.Plugs.RequireAuth when action in [:new, :create, :edit, :update, :delete]
    plug :check_topic_owner when action in [:edit, :update, :delete]

    def index(conn, _params) do
      topics = Repo.all(Topic)
      render conn, "index.html", topics: topics
    end

    def show(conn, %{"id" => topic_id}) do
      topic = Repo.get(Topic, topic_id)
      render conn, "show.html", topic: topic
    end
  
    def new(conn, _params) do
      # struct = %Topic{}
      # params = %{}
      changeset = Topic.changeset(%Topic{}, %{})

      render conn, "new.html", changeset: changeset
    end

    # params = %{"_csrf_token" => "blahblah", "utf-8" => "true", "topic" => %{"title" => "asdf"}}
    # %{"topic" => topic} = params     //{"topic" => %{"title" => "asdf"}}
    def create(conn, %{"topic" => topic}) do
      # changeset = Topic.changeset(%Topic{}, topic)
      changeset = conn.assigns.user
      |> build_assoc(:topics)
      |> Topic.changeset(topic)

      case Repo.insert(changeset) do
        {:ok, _topic} ->
          conn
          |> put_flash(:info, "Topic Created")
          |> redirect(to: topic_path(conn, :index))
        {:error, changeset} ->
          render conn, "new.html", changeset: changeset
      end

    end

    def edit(conn, %{"id" => topic_id}) do
      topic = Repo.get(Topic, topic_id)
      changeset = Topic.changeset(topic)

      render conn, "edit.html", changeset: changeset, topic: topic
    end

    # params = %{"_csrf_token" => "HRARQgBsCGR7PD4FFhgkWDQcP3VdAAAApjT4n6MPTom7rLB/eOi87A==", "_method" => "put", "_utf8" => "✓", 
    # "id" => "5", "topic" => %{"title" => "JS Frameworks"}}
    def update(conn, %{"id" => topic_id, "topic" => topic}) do
      old_topic = Repo.get(Topic, topic_id)
      changeset = Topic.changeset(old_topic, topic)

      # changeset = Repo.get(Topic, topic_id) |> Topic.changeset(topic)

      case Repo.update(changeset) do
        {:ok, _post} -> 
          conn
          |> put_flash(:info, "Topic Updated")
          |> redirect(to: topic_path(conn, :index))
        {:error, changeset} -> 
          render conn, "edit.html", changeset: changeset, topic: old_topic
      end
    end

    def delete(conn, %{"id" => topic_id}) do
      #Repo.get!(Topic, topic_id) |> Repo.delete!

      {id, _str} = :string.to_integer topic_id
      Repo.delete!(%Topic{id: id})

      conn
      |> put_flash(:info, "Topic Deleted")
      |> redirect(to: topic_path(conn, :index))
    end

    def check_topic_owner(conn, _params) do
      %{params: %{"id" => topic_id}} = conn

      if Repo.get(Topic, topic_id).user_id == conn.assigns.user.id do
        conn
      else
        conn
          |> put_flash(:error, "Not Authorized to edit")
          |> redirect(to: topic_path(conn, :index))
          |> halt()
      end
    end

  end
  