defmodule TermProjectWeb.SessionControllerTest do
  use TermProjectWeb.ConnCase

  import TermProject.AccountsFixtures

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  describe "index" do
    test "lists all sessions", %{conn: conn} do
      conn = get(conn, ~p"/sessions")
      assert html_response(conn, 200) =~ "Listing Sessions"
    end
  end

  describe "new session" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/sessions/new")
      assert html_response(conn, 200) =~ "New Session"
    end
  end

  describe "create session" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/sessions", session: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/sessions/#{id}"

      conn = get(conn, ~p"/sessions/#{id}")
      assert html_response(conn, 200) =~ "Session #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/sessions", session: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Session"
    end
  end

  describe "edit session" do
    setup [:create_session]

    test "renders form for editing chosen session", %{conn: conn, session: session} do
      conn = get(conn, ~p"/sessions/#{session}/edit")
      assert html_response(conn, 200) =~ "Edit Session"
    end
  end

  describe "update session" do
    setup [:create_session]

    test "redirects when data is valid", %{conn: conn, session: session} do
      conn = put(conn, ~p"/sessions/#{session}", session: @update_attrs)
      assert redirected_to(conn) == ~p"/sessions/#{session}"

      conn = get(conn, ~p"/sessions/#{session}")
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, session: session} do
      conn = put(conn, ~p"/sessions/#{session}", session: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Session"
    end
  end

  describe "delete session" do
    setup [:create_session]

    test "deletes chosen session", %{conn: conn, session: session} do
      conn = delete(conn, ~p"/sessions/#{session}")
      assert redirected_to(conn) == ~p"/sessions"

      assert_error_sent 404, fn ->
        get(conn, ~p"/sessions/#{session}")
      end
    end
  end

  defp create_session(_) do
    session = session_fixture()
    %{session: session}
  end
end
