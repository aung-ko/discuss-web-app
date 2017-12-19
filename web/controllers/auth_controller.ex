defmodule Discuss.AuthController do
    use Discuss.Web, :controller

    plug Ueberauth

    alias Discuss.User

    def callback(%{assigns: %{ueberauth_auth: auth}} = conn, params) do
        # IO.inspect conn.assigns
        # IO.inspect params
        # IO.inspect auth
        user_params = %{token: auth.credentials.token, email: auth.info.email, provider: "github"}
        changeset = User.changeset(%User{}, user_params)

        singin(conn, changeset)
    end

    defp singin(conn, changeset) do
        case insert_or_update_user(changeset) do
            {:ok, user} ->
                conn
                |> put_flash(:info, "Welcome Back")
                |> put_session(:user_id, user.id)
                |> redirect(to: topic_path(conn, :index))
            {:error, _reason} -> 
                conn
                |> put_flash(:error, "Error Sigining in")
                |> redirect(to: topic_path(conn, :index))
        end
    end

    def signout(conn, _params) do
        conn
        |> configure_session(drop: true)
        |> redirect(to: topic_path(conn, :index))
    end

    defp insert_or_update_user(changeset) do
        case Repo.get_by(User, email: changeset.changes.email) do
            nil -> 
                Repo.insert(changeset)
            user ->
                {:ok, user}
        end
    end

end