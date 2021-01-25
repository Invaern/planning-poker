defmodule PlanningPoker.Validation do

  def validate_string(input, opts \\ [])
  def validate_string(nil, _), do: {:error, :blank}
  def validate_string(input, opts) do
    max_len = Keyword.get(opts, :max_len, 15)
    trimmed = String.trim(input)
    with :ok <- not_blank(trimmed),
         :ok <- max_length(trimmed, max_len),
         do: {:ok, trimmed}
  end

  defp not_blank(""), do: {:error, :blank}
  defp not_blank(_input), do: :ok

  defp max_length(input, max_len) do
    if String.length(input) > max_len do
      {:error, :too_long}
    else
      :ok
    end
  end

end
