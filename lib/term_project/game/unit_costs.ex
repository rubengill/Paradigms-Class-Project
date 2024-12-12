defmodule TermProject.UnitCosts do
  def cost(:soldier), do: %{wood: 50, iron: 30}
  def cost(:archer), do: %{wood: 30, stone: 20}
  def cost(:cavalry), do: %{wood: 40, iron: 40}
end
