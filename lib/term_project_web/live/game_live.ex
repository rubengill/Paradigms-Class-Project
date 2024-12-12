defmodule TermProjectWeb.GameLive do
  use TermProjectWeb, :live_view
  alias TermProject.Game
  alias TermProject.GameState

  @countdown_start 10

  @impl true
  # In game_live.ex
  def mount(%{"lobby_id" => lobby_id, "username" => username}, _session, socket) do
    lobby_id = String.to_integer(lobby_id)

    IO.puts("Game server running: #{game_server_running?(lobby_id)}")

    if connected?(socket) do
      Phoenix.PubSub.subscribe(TermProject.PubSub, "game:#{lobby_id}")
      Phoenix.PubSub.subscribe(TermProject.PubSub, "lobby:#{lobby_id}")
    end

    # Get lobby info first to get player mapping
    {:ok, lobby} = TermProject.Game.LobbyServer.get_lobby(lobby_id)
    [host | others] = Map.keys(lobby.players)
    player_mapping = %{1 => host, 2 => Enum.at(others, 0)}

    game_state =
      case Game.get_state(lobby_id) do
        {:ok, state} ->
          IO.inspect(state.players, label: "Players in game state")
          state

        {:error, _} ->
          # Initialize with player mapping
          %{GameState.new() | players: player_mapping}
      end

    player_id =
      cond do
        game_state.players[1] == username -> 1
        game_state.players[2] == username -> 2
        true -> nil
      end

    IO.inspect(player_id, label: "Assigned player_id")

    {:ok,
     socket
     |> assign(:lobby_id, lobby_id)
     |> assign(:username, username)
     |> assign(:player_id, player_id)
     |> assign(:game_state, game_state)
     |> assign(:countdown, nil)}
  end

  @impl true
  def render(assigns) do
    ~H"""
<div class="game-container flex flex-col items-center justify-center min-h-screen bg-gray-800 text-white">
  <%= if @countdown do %>
    <div class="countdown text-2xl font-bold bg-yellow-500 text-black p-4 rounded-lg shadow-md">
      Game starts in <%= @countdown %> seconds...
    </div>
  <% else %>
    <div class="status-panel flex flex-col gap-4 w-full max-w-4xl bg-gray-700 p-6 rounded-lg shadow-lg">
      <div class="resources grid grid-cols-3 gap-4 text-center">
        <%= if @game_state.resources[@player_id] do %>
          <div class="bg-gray-900 p-4 rounded-lg shadow-md">
            Wood: <span class="font-semibold"><%= @game_state.resources[@player_id].amounts.wood %></span>
          </div>
          <div class="bg-gray-900 p-4 rounded-lg shadow-md">
            Stone: <span class="font-semibold"><%= @game_state.resources[@player_id].amounts.stone %></span>
          </div>
          <div class="bg-gray-900 p-4 rounded-lg shadow-md">
            Iron: <span class="font-semibold"><%= @game_state.resources[@player_id].amounts.iron %></span>
          </div>
        <% else %>
          <div class="col-span-3 text-yellow-500 font-medium">Loading resources...</div>
        <% end %>
      </div>

      <div class="bases flex justify-around">
        <div class="bg-gray-900 p-4 rounded-lg shadow-md">
          Base 1 Health: <span class="font-semibold text-green-500"><%= @game_state.bases[1].health %></span>
        </div>
        <div class="bg-gray-900 p-4 rounded-lg shadow-md">
          Base 2 Health: <span class="font-semibold text-green-500"><%= @game_state.bases[2].health %></span>
        </div>
      </div>
    </div>

    <div class="game-controls flex justify-center gap-4 mt-6">
      <button phx-click="spawn_unit" phx-value-type="archer"
        class="unit-button bg-blue-600 hover:bg-blue-500 text-white py-2 px-4 rounded-lg shadow-md transition">
        Spawn Archer
      </button>
      <button phx-click="spawn_unit" phx-value-type="soldier"
        class="unit-button bg-green-600 hover:bg-green-500 text-white py-2 px-4 rounded-lg shadow-md transition">
        Spawn Soldier
      </button>
      <button phx-click="spawn_unit" phx-value-type="cavalry"
        class="unit-button bg-red-600 hover:bg-red-500 text-white py-2 px-4 rounded-lg shadow-md transition">
        Spawn Cavalry
      </button>
    </div>

    <div class="game-field relative mt-6 w-full max-w-4xl bg-gray-600 p-4 rounded-lg shadow-lg">
      <div class="base left-base absolute top-4 left-4 bg-blue-800 text-white py-2 px-4 rounded-lg shadow-md">
        Player 1 Base
      </div>
      <div class="base right-base absolute top-4 right-4 bg-red-800 text-white py-2 px-4 rounded-lg shadow-md">
        Player 2 Base
      </div>
      <%= for unit <- @game_state.units do %>
        <div
          class={"unit #{unit.type} absolute text-center text-sm bg-white text-black py-1 px-2 rounded-lg shadow-md"}
          style={"left: #{unit.position.x}px; top: #{unit.position.y}px;"}
        >
          <%= unit.type %>
        </div>
      <% end %>
    </div>
  <% end %>
</div>

    """
  end

  @impl true
  def handle_event("spawn_unit", %{"type" => type}, socket) do
    Game.spawn_unit(
      socket.assigns.lobby_id,
      String.to_atom(type),
      socket.assigns.player_id
    )

    {:noreply, socket}
  end

  @impl true
  def handle_info({:game_state_update, updated_game_state}, socket) do
    {:noreply, assign(socket, :game_state, updated_game_state)}
  end

  @impl true
  def handle_info(:start_countdown, socket) do
    countdown = @countdown_start
    send_countdown(self(), countdown)
    {:noreply, assign(socket, :countdown, countdown)}
  end

  @impl true
  def handle_info({:countdown, remaining}, socket) when remaining > 0 do
    send_countdown(self(), remaining - 1)
    {:noreply, assign(socket, :countdown, remaining)}
  end

  @impl true
  def handle_info({:countdown, 0}, socket) do
    {:noreply, assign(socket, :countdown, nil)}
  end

  @impl true
  def handle_info({:combat_event, message}, socket) do
    {:noreply, socket |> put_flash(:info, message)}
  end

  defp send_countdown(pid, remaining) do
    Process.send_after(pid, {:countdown, remaining}, 1000)
  end

  defp validate_unit_type("archer"), do: {:ok, :archer}
  defp validate_unit_type("soldier"), do: {:ok, :soldier}
  defp validate_unit_type("cavalry"), do: {:ok, :cavalry}
  defp validate_unit_type(_), do: {:error, :invalid_unit_type}

  defp game_server_running?(lobby_id) do
    case :global.whereis_name({:game_server, lobby_id}) do
      :undefined -> false
      pid when is_pid(pid) -> Process.alive?(pid)
    end
  end
end
