defmodule Jofra.Outcomes do
  import Jofra.MatchConfig

  def build_outcome() do
    %{}
    |> Map.put(:result, select_from_counts(:outcomes))
    |> add_extra()
    |> mark_illegal_delivery()
  end

  def add_extra(%{ result: :dot } = outcome) do
    outcome
    |> Map.put(:extra, select_from_counts(:extras, [:wide, :no_ball]))
  end

  def add_extra(outcome) do
    outcome
    |> Map.put(:extra, select_from_counts(:extras))
  end

  def mark_illegal_delivery(%{ extra: extra } = outcome) do
    case extra do
      extra when extra in [:no_ball, :wide] -> Map.put(outcome, :illegal_delivery, true)
      _ -> outcome
    end
  end

  def select_from_counts(event_type, event_list \\ [], chances \\ 1000) do
     get_match_config(:test)
     |> Map.get(event_type)
     |> build_outcome_rolls(event_list)
     |> Enum.at(:rand.uniform(chances)-1)
   end

   def build_outcome_rolls(counts, []) do
     build_outcome_rolls(counts, counts |> Map.keys)
   end

   def build_outcome_rolls(counts, sorted_events) do
     Enum.reduce(sorted_events, [], fn outcome, acc ->
       Enum.concat(acc, List.duplicate(outcome, counts[outcome]))
     end)
   end
end