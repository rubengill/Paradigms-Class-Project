defmodule TermProject.ResourceManager do
  @moduledoc """
  Handles resource accumulation, spending, and validation.
  """

  @doc """
  Defines the structure of the `resources` map.

  The `resources` map represents the current state of resources and their generation rates:
    - `amounts`: A map of integers indicating the current quantity of each resource (`:wood`, `:stone`, `:iron`).
    - `rates`: A map of floats specifying the generation rate multiplier for each resource.
      These rates are relative to the default generation rates:
      - `@default_wood_rate`: 50
      - `@default_stone_rate`: 25
      - `@default_iron_rate`: 10

  Generation rate for a resource is calculated as `default_rate * rate`.
  """
  @type resources :: %{
    amounts: %{wood: integer(), stone: integer(), iron: integer()},
    rates: %{wood: float(), stone: float(), iron: float()}
  }

  @initial_wood_amt 200
  @initial_stone_amt 100
  @initial_iron_amt 20

  @default_wood_rate 50
  @default_stone_rate 25
  @default_iron_rate 10

  @doc """
  Initializes resources with default amounts and rates.
  """
  def initialize() do
    %{
      amounts: %{wood: @initial_wood_amt, stone: @initial_stone_amt, iron: @initial_iron_amt},
      rates: %{wood: 1.0, stone: 1.0, iron: 1.0}
    }
  end

  @doc """
  Adds resources to the `:amount` field of each resource.

  Parameters
    - resources (map): The current resource map, with each resource containing `:amount` and `:boost`.
    - additions (map, optional): A map specifying the amounts to add for each resource.

  Returns: updated resource map with modified `:amounts` for the specified resources.
  """
  def add(resources, additions \\ %{}) do
    updated_amounts =
      Enum.reduce(additions, resources.amounts, fn {key, addition}, acc ->
        Map.update!(acc, key, &(&1 + addition))
      end)

    %{resources | amounts: updated_amounts}
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
    if Enum.all?(costs, fn {key, value} -> Map.get(resources.amounts, key, 0) >= value end) do
      updated_amounts =
        Enum.reduce(costs, resources.amounts, fn {key, value}, acc ->
          Map.update!(acc, key, &(&1 - value))
        end)

      {:ok, %{resources | amounts: updated_amounts}}
    else
      {:error, :insufficient_resources}
    end
  end

  @doc """
  Used for auto-updating resources based on specified update amounts and conditional flags.

  Parameters
    - resources: The current resource state
    - update_amounts (map, optional): A map specifying amounts to add for each resource
    - update_wood (boolean, optional): Whether to update :wood
    - update_stone (boolean, optional): Whether to update :stone
    - update_iron (boolean, optional): Whether to update :iron

  Returns: updated resource map with adjusted amounts for :wood, :stone, and :iron.
  """
  def auto_update(
    resources,
    update_wood \\ false,
    update_stone \\ false,
    update_iron \\ false
  ) do
    # Scale the update amounts by the current rates
    scaled_updates = %{
    wood: if(update_wood, do: @default_wood_rate * Map.get(resources.rates, :wood, 1.0), else: 0),
    stone: if(update_stone, do: @default_stone_rate * Map.get(resources.rates, :stone, 1.0), else: 0),
    iron: if(update_iron, do: @default_iron_rate * Map.get(resources.rates, :iron, 1.0), else: 0)
    }

    # Use the add function to update resource amounts
    updated_resources = add(resources, Enum.into(scaled_updates, %{}, fn {key, value} -> {key, trunc(value)} end))

    # Return the updated resource map
    updated_resources
  end

  @doc """
  Increases the rate of a specified resource by 25%.

  Parameters:
    - resources (map): The current resource map, with `amounts` and `rates`.
    - rate_to_increase (atom): The resource key (`:wood`, `:stone`, or `:iron`) whose rate should be increased.

  Returns: updated resource map with the increased rate.
  """
  def increase_rate(resources, rate_to_increase) do
    updated_rates =
      Map.update!(resources.rates, rate_to_increase, fn current_rate ->
        current_rate + 0.25
      end)

    %{resources | rates: updated_rates}
  end

  @doc """
  Decreases the rate of a specified resource by 25%.

  Parameters:
    - resources (map): The current resource map, with `amounts` and `rates`.
    - rate_to_decrease (atom): The resource key (`:wood`, `:stone`, or `:iron`) whose rate should be decreased.

  Returns:
    - {:ok, updated_resources} if the rate decrease is successful.
    - {:error, :minimum_rate_reached} if the rate is already at the minimum and cannot be decreased further.
  """
  def decrease_rate(resources, rate_to_decrease) do
    current_rate = Map.get(resources.rates, rate_to_decrease, 0.0)

    if current_rate > 0.25 do
      updated_rates =
        Map.update!(resources.rates, rate_to_decrease, fn rate ->
          rate - 0.25
        end)

      {:ok, %{resources | rates: updated_rates}}
    else
      {:error, :minimum_rate_reached}
    end
  end

end
