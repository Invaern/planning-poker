defmodule PlanningPoker do
  @moduledoc """
  PlanningPoker keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def count_rooms() do
    try do
      Registry.count(PlanningPoker.RoomRegistry)
    rescue
      _ ->
        :logger.warning("RoomRegistry not available for telemetry")
    else
      count ->
        :telemetry.execute([:planning_poker, :rooms_count], %{total: count}, %{})
    end

  end
end
