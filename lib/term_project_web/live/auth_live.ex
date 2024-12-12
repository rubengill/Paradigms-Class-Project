defmodule TermProjectWeb.AuthLive do
  use Phoenix.LiveView
  import Phoenix.LiveView.Socket

  def on_mount(:default, _params, session, socket) do
    case session["user_id"] && TermProject.Accounts.get_user(session["user_id"]) do
      nil ->
        {:halt, redirect(socket, to: "/signup")}

      user ->
        {:cont, assign(socket, :current_user, user)}
    end
  end
end
