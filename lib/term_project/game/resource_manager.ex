defmodule TermProject.ResourceManager do
  @moduledoc """
  Handles resource accumulation, spending, and validation.
  """

  @type resources :: %{wood: integer(), stone: integer(), iron: integer()}

  @doc """
  Initializes resources with default values.
  """
  def initialize() do
    %{wood: 100, stone: 50, iron: 10}
  end

  @doc """
  Adds resources.

  Parameters
    - resources (map): The current resource map
    - additions (map, optional): A map specifying the amounts to add for each resource

  Returns: new resource map with updated values for the specified resources.
  """
  def add(resources, additions \\ %{}) do
    Map.merge(resources, additions, fn _key, current, addition -> current + addition end)
  end

  @doc """
    Deducts resources. Validates whether or not a purchase is valid.

    Parameters
      - resources (map): The current resource map
      - costs (map, optional): A map specifying the amounts to deduct for each resource

    Returns:
      - {:ok, updated_resources} if the deduction is successful
      - {:error, :insufficient_resources} if there are not enough resources to deduct
    """
  def deduct(resources, costs \\ %{}) do
    if Enum.all?(costs, fn {key, value} -> Map.get(resources, key, 0) >= value end) do
      {:ok, Map.merge(resources, costs, fn _key, current, cost -> current - cost end)}
    else
      {:error, :insufficient_resources}
    end
  end


  @doc """
  Used for auto-updating resources based on specified update amounts and conditional flags.

  Parameters
    - resources (map): The current resource map
    - update_amounts (map, optional): A map specifying amounts to add for each resource
    - update_wood (boolean, optional): Whether to update :wood
    - update_stone (boolean, optional): Whether to update :stone
    - update_iron (boolean, optional): Whether to update :iron

  Returns: new resource map with updated values for :wood, :stone, and :iron.
  """
  def auto_update(
      resources,
      update_amounts \\ %{wood: 50, stone: 20, iron: 5},
      update_wood \\ false,
      update_stone \\ false,
      update_iron \\ false
    ) do
    filtered_updates = %{
      wood: if(update_wood, do: Map.get(update_amounts, :wood, 0), else: 0),
      stone: if(update_stone, do: Map.get(update_amounts, :stone, 0), else: 0),
      iron: if(update_iron, do: Map.get(update_amounts, :iron, 0), else: 0)
    }

    add(resources, filtered_updates)
  end

end
