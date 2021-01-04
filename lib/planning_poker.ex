defmodule PlanningPoker do
  @moduledoc """
  PlanningPoker keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def count_rooms() do
    try do
      count = Registry.count(PlanningPoker.RoomRegistry)
      :telemetry.execute([:planning_poker, :rooms_count], %{total: count}, %{})
    rescue
      _ -> :logger.warning("RoomRegistry not available for telemetry")
    end

  end
end
