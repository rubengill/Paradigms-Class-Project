defmodule TermProject.GameClient do
  alias TermProject.GameState

  @tick_duration 100

  def start_link(server, match_id) do
    Task.start_link(fn -> run_game_loop(server, match_id) end)
  end

  def run_game_loop(server, match_id) do
    state = GameState.new()

    loop(state, server, match_id)
  end

  defp loop(state, server, match_id) do
    {opponent_actions, confirmed_tick} = sync_with_server(server, match_id, state.tick)

    if confirmed_tick != state.tick do
      IO.puts("Tick desync detected! Correcting...")
      state = %{state | tick: confirmed_tick}
    end

    state = GameState.apply_opponent_actions(state, opponent_actions)
    state = process_local_tick(state)

    local_actions = generate_local_actions(state)
    send_actions_to_server(server, match_id, state.tick, local_actions)

    state = %{state | tick: state.tick + 1}
    :timer.sleep(@tick_duration)
    loop(state, server, match_id)
  end

  defp process_local_tick(state), do: state
  defp generate_local_actions(_state), do: []
  defp send_actions_to_server(server, match_id, tick, actions), do: server.send_actions(match_id, tick, actions)
  defp sync_with_server(server, match_id, tick), do: server.get_opponent_actions(match_id, tick)
end
