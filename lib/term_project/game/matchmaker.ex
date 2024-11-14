defmodule GameApp.Matchmaker do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{queue: []}, name: __MODULE__)
  end

  @impl true
  def init(initial_state) do
    {:ok, initial_state}
  end

  def add_to_queue(player_pid) do
    GenServer.cast(__MODULE__, {:add_to_queue, player_pid})
  end

  @impl true
  def handle_cast({:add_to_queue, player_pid}, %{queue: queue} = state) do
    new_queue = [player_pid | queue]

    if length(new_queue) >= 2 do
      [p1, p2 | rest] = new_queue
      start_match(p1, p2)
      {:noreply, %{state | queue: rest}}
    else
      {:noreply, %{state | queue: new_queue}}
    end
  end

  defp start_match(p1, p2) do
    send(p1, {:match_found, p2})
    send(p2, {:match_found, p1})
  end
end
