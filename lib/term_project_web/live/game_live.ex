defmodule TermProjectWeb.GameLive do
  use TermProjectWeb, :live_view
  alias TermProject.Game

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(TermProject.PubSub, "game")
    end

    {:ok, assign(socket,
      player_id: 1,
      resources: 100,
      base_health: 1000,
      units: []
    )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="game-container">
      <div class="status-panel">
        <div class="resource-counter">Resources: <%= @resources %></div>
        <div class="base-health">Base Health: <%= @base_health %></div>
      </div>

      <div class="game-controls">
        <button phx-click="spawn_unit" phx-value-type="soldier" class="unit-button">
          Spawn Soldier (50)
        </button>
        <button phx-click="spawn_unit" phx-value-type="archer" class="unit-button">
          Spawn Archer (75)
        </button>
        <button phx-click="spawn_unit" phx-value-type="cavalry" class="unit-button">
          Spawn Cavalry (100)
        </button>
      </div>

      <div class="game-field">
        <div class="base left-base">Player 1 Base</div>
        <div class="base right-base">Player 2 Base</div>
        <%= for unit <- @units do %>
          <div class={"unit #{unit.type}"} style={"left: #{unit.position.x}px; top: #{unit.position.y}px;"}>
            <%= unit.type %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("spawn_unit", %{"type" => type}, socket) do
    # TODO: Implement unit spawning through Game GenServer
    {:noreply, socket}
  end
end
