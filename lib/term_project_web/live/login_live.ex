defmodule TermProjectWeb.LoginLive do
  use TermProjectWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, error_message: nil)}
  end

  def handle_event("guest_login", %{"guest_name" => guest_name}, socket) do
    # Redirect to the lobby, passing the guest_name as a parameter
    {:noreply, redirect(socket, to: ~p"/?username=#{URI.encode(guest_name)}")}
  end
end
