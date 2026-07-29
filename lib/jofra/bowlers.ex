defmodule Jofra.Bowlers do
    defp select_bowler(%{ bowlers: bowlers, bowler_usage: usage } = match, last_bowler_id) do
      { on_spell, _ } = bowlers_by_spell(match)

      next_bowler = bowlers
        |> Enum.reject(fn b -> b.id == last_bowler_id end)
        |> Enum.map(fn b ->
            use_ = Enum.find(usage, fn u -> u.id == b.id end)
            Map.merge(b, use_)
          end)
        |> Enum.map(fn b ->
            case Enum.any?(on_spell, fn osb -> osb.id == b.id end) do
              true -> Map.put(b, :on_spell, true)
              false -> Map.put(b, :on_spell, false)
            end
         end)
        |> Enum.map(fn b -> Map.put(b, :points, 0) end)
        |> Enum.map(fn b -> score_bowler(b, match, [ :spell, :rest, :overall, :spin, :swing, :seam, :econ, :wickets ]) end)
        |> Enum.sort_by(&(&1.points), :desc)
        |> IO.inspect(label: "sorted bowlers by points")
        |> Enum.find(fn b -> b.overs_available > 0 end)

        match
        |> Map.put(:bowler, Enum.find(bowlers, fn b -> b.id == next_bowler.id end))
    end

    defp score_bowler(bowler, _, []) do
      bowler
    end

    defp score_bowler(%{ points: points } = bowler, match, categories) do
      [ category | remaining ] = categories
      added_points = score(bowler, match, category)

      score_bowler(bowler |> Map.put(:points, points + added_points), match, remaining)
    end

    defp score(bowler, _, :spell) do
      case bowler[:on_spell] do
        true -> 5
        false -> 0
      end
    end

    defp score(bowler, %{ bowler_usage: usage }, :rest) do
      { used, unused } = Enum.split_with(usage, fn u -> u[:last_timestamp] != nil end)

      most_rested_used = Enum.sort_by(used, &(&1[:last_timestamp]), DateTime)

      most_rested = (unused ++ most_rested_used)
        |> Enum.map(fn b -> b.id end)
        |> Enum.take(2)

      case bowler.id in most_rested do
        true -> 2
        false -> 0
      end
    end

    defp score(_, %{ bowler_usage: [] }, :rest) do
      0
    end

    defp score(bowler, _, :overall) do
      Jofra.Utils.gpa([bowler[:line], bowler[:length]])
    end

    defp score(%{ spin: spin }, %{ ball_age: ball_age }, :spin) when ball_age > 40 do
      Jofra.Utils.points_for_grade(spin)
    end

    defp score(%{ seam: seam }, %{ ball_age: ball_age }, :seam) when ball_age < 20 do
      Jofra.Utils.points_for_grade(seam)
    end

    defp score(%{ swing: swing }, %{ ball_age: ball_age }, :swing) when ball_age > 20 and ball_age <= 40 do
      Jofra.Utils.points_for_grade(swing)
    end

    defp score(%{ id: id }, %{ balls: balls }, :econ) do
      runs = balls
      |> Enum.filter(fn b -> b.bowler == id end)
      |> Enum.sum_by(fn b -> Jofra.Utils.runs_for_result(b[:result]) end)

      case runs / 6 do
        econ when econ < 2.5 -> 3
        econ when econ < 3.2 -> 2
        _ -> 0
      end
    end

    defp score(%{ id: id }, %{ balls: balls }, :wickets) do
      wickets = balls
      |> Enum.filter(fn b -> b.bowler == id && b.result == :wicket end)
      |> Enum.count()

      case wickets > 3 do
        true -> 2
        false -> 0
      end
    end

    defp score(_, _, _) do
      0
    end

    def new_bowler(%{ over: 0 } = match) do
      match
      |> select_bowler(nil)
    end

    def new_bowler(%{ over: over, balls: [ %{ bowler: last_bowler_id, over: last_ball_over } | _ ] } = match)
      when over > last_ball_over
    do
      match
      |> update_bowler_usage()
      |> select_bowler(last_bowler_id)
    end

    def new_bowler(match) do
      match
    end

    def new_bowler_usage(bowlers) do
      bowlers
      |> Enum.map(fn x -> %{
            id: x.id,
            overs_available: 12,
            last_over: nil,
            last_timestamp: nil,
            last_recovery: nil
         } end)
    end

    def bowlers_by_spell(%{ bowler_usage: usage, balls: [ %{ bowler: last_ball_bowler, over: last_ball_over } | _ ]}) do
      usage
      |> Enum.split_with(fn b -> b.id == last_ball_bowler || b.last_over == last_ball_over - 1 end)
    end

    def bowlers_by_spell(_) do
      {[], []}
    end

    def update_bowler_usage(%{ current_time: time, balls: [ last_ball | _ ] } = match) do
      { on_spell, off_spell } = bowlers_by_spell(match)

      off_spell = off_spell
      |> Enum.map(fn osb ->
        mins_since = DateTime.diff(time, osb.last_recovery || osb.last_timestamp || time, :minute)
        overs_recovered = floor(mins_since / 8)
        Map.merge(osb, %{
          overs_available: Enum.min([osb.overs_available + overs_recovered, 12]),
          last_recovery: time
        })
      end)

      on_spell = on_spell
      |> Enum.map(fn b ->
        case b.id == last_ball.bowler do
          true -> Map.merge(b, %{ overs_available: b.overs_available - 1, last_timestamp: time, last_over: last_ball.over })
          false -> b
         end
        end)

      Map.put(match, :bowler_usage, on_spell ++ off_spell)
    end
end