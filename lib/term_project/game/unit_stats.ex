defmodule TermProject.UnitStats do
  def get_stats(:archer), do: %{health: 100, damage: 15, range: 200}
  def get_stats(:soldier), do: %{health: 150, damage: 25, range: 50}
  def get_stats(:cavalry), do: %{health: 200, damage: 35, range: 75}
end
