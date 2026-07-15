defmodule Jofra.Match do
  import Jofra.Outcomes

  def build_over(over) do
    case is_completed_over?(over) do
      true -> over |> Enum.reverse()
      false -> [ build_outcome() | over ] |> build_over()
    end
  end

  defp is_completed_over?(over) do
    over
    |> Enum.reject(fn o -> Map.get(o, :illegal_delivery) == true end)
    |> Enum.count()
    |> then(&(&1 == 6))
  end
end