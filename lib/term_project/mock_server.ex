defmodule TermProject.MockServer do
  @moduledoc """
  Mock server for testing game functionality
  """

  def send_actions(_match_id, _tick, actions) do
    IO.puts "Mock server received actions: #{inspect(actions)}"
    :ok
  end

  def get_opponent_actions(_match_id, _tick) do
    # Return empty actions and current tick
    {[], 0}
  end
end
