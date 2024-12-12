defmodule TermProjectWeb.LogoutController do
  use TermProjectWeb, :controller

  def logout(conn, _params) do
    render(conn, "logout.html")
  end
end
