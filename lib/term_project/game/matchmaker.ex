defmodule TermProject.Game.Matchmaker do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{queue: []}, name: __MODULE__)
  end

  def init(initial_state) do
    {:ok, initial_state}
  end

  def add_to_queue(player_id) do
    GenServer.call(__MODULE__, {:add_to_queue, player_id})
  end

  def handle_call({:add_to_queue, player_id}, _from, state) do
    new_queue = state.queue ++ [player_id]
    # Check if we have enough players to create a match
    if length(new_queue) >= 2 do
      [p1, p2 | rest] = new_queue
      # Pair players p1 and p2
      broadcast_match(p1, p2)
      {:reply, :ok, %{state | queue: rest}}
    else
      {:reply, :ok, %{state | queue: new_queue}}
    end
  end

  defp broadcast_match(p1, p2) do
    Phoenix.PubSub.broadcast(TermProject.PubSub, "matchmaking", {:match_found, p1, p2})
  end
end
