defmodule Discuss.CommentsChannel do
    use Discuss.Web, :channel

    alias Discuss.{Topic, Comment}
    # alias Discuss.Comment

    def join("comments:" <> topic_id, _params, socket) do
        # name = comments:3
        id = String.to_integer(topic_id)
        # topic = Repo.get(Topic, id)
        topic = Topic
                |> Repo.get(id)
                |> Repo.preload(comments: [:user]) # load association users that comments belongs to

        {:ok, %{comments: topic.comments}, assign(socket, :topic, topic)}  #assign topic to :topic in socket
    end

                    # message = %{"content" => "blahblah"}
    def handle_in(name, %{"content" => content}, socket) do
        topic = socket.assigns.topic
        user_id = socket.assigns.user_id

        changeset = topic
                    |> build_assoc(:comments, user_id: user_id)
                    |> Comment.changeset(%{content: content})
        
        case Repo.insert(changeset) do
            {:ok, comment} ->
                broadcast!(socket, "comments:#{socket.assigns.topic.id}:new",
                    %{comment: comment}
                )
                {:reply, :ok, socket}
            {:error, _reason} ->
                {:reply, {:error, %{errors: changeset}}, socket}
        end

        {:reply, :ok, socket}
    end
end