defmodule TermProjectWeb.UserSocket do
  use Phoenix.Socket

  ## Channels
  channel "game:*", TermProjectWeb.GameChannel

  # TODO: Implement authentication if required
  def connect(_params, socket, _connect_info) do
    {:ok, socket}
  end

  def id(_socket), do: nil
end
