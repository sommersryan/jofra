defmodule Jofra.Outcomes do
  import Jofra.MatchConfig
  import Jofra.Charts

  def build_outcome(batsmen, bowler, context) do
    [ batsman, non_striker ] = batsmen

    %{
      batsman: batsman.id,
      non_striker: non_striker.id,
      bowler: bowler.id
    }
    |> Map.put(:result, select_from_counts(:outcomes))
    |> add_extra()
    |> apply_outcome_charts(batsman, bowler, context)
    |> add_wicket_type()
    |> add_clock()
    |> mark_illegal_delivery()
    |> add_hit_location()
  end

  def apply_outcome_charts(outcome, batsman, bowler, context) do
    outcome
    |> Map.get(:result)
    |> apply_charts(batsman, bowler, context)
    |> then(fn new -> Map.put(outcome, :result, new) end)
  end

  def add_clock(outcome) do
    current_time = Jofra.Clock.current_time()
    { end_time } = Jofra.Clock.advance(:delivery)

    outcome 
    |> Map.put(:timestamp_start, current_time)
    |> Map.put(:timestamp_end, end_time)
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

  def add_wicket_type(%{ result: :wicket } = outcome) do
    outcome
    |> Map.put(:wicket_type, select_from_counts(:wickets))
  end

  def add_wicket_type(outcome) do
    outcome
  end

  def add_hit_location(%{ result: result } = outcome) when result in [:dot, :wicket], do: outcome

  def add_hit_location(outcome) do
    outcome
    |> Map.put(:hit_location, select_from_counts(:hit_locations))
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