defmodule Jofra.Utils do
  def summarize_session(session) do
    results = session
    |> Map.get(:overs)
    |> Enum.flat_map(&(&1))

    %{}
    |> Map.put(:runs, runs_in_overs(results))
    |> Map.put(:wickets, wickets_in_overs(results))
    |> Map.put(:extras, Enum.reject(results, &(&1.extra == nil))
        |> Enum.frequencies_by(&(&1.extra)))
  end

  def runs_in_overs(results) do
    results
    |> Enum.sum_by(fn res -> runs_for_result(res.result) end)
  end

  def wickets_in_overs(results) do
    results
    |> Enum.count(fn o -> o.result == :wicket end)
  end

  def runs_for_result(result) do
    case(result) do
      :single -> 1
      :double -> 2
      :triple -> 3
      :four -> 4
      :six -> 6
      _ -> 0
    end
  end

  def test_context do
    %{
      controller: :batsman,
      batsman: %{
        tendency: :moderate,
        shot_selection: :a,
        shot_quality: :a,
        shot_precision: :b,
        batting_endurance: :b
      },
      bowler: %{
        type: :spin,
        line: :c,
        length: :b,
        spin: :a,
        swing: :c,
        seam: :f
      },
      day: 4,
      outcome: :dot,
      ball_age: 52
    }
  end

  def test_sides do
    {
      [
        [
          %{
            id: :john,
            can_bowl: false
          },
          %{
            id: :paul,
            can_bowl: false
          },
          %{
            id: :george,
            can_bowl: false
          },
          %{
            id: :ringo,
            can_bowl: false
          },
          %{
            id: :jonny,
            can_bowl: false
          },
          %{
            id: :thom,
            can_bowl: false
          },
          %{
            id: :phil,
            can_bowl: true,
            bowling_priority: 5
          },
          %{
            id: :colin,
            can_bowl: true,
            bowling_priority: 3
          },
          %{
            id: :brian,
            can_bowl: true,
            bowling_priority: 4
          },
         %{
            id: :clover,
            can_bowl: true,
            bowling_priority: 2
          },
          %{
            id: :wren,
            can_bowl: true,
            bowling_priority: 1
          },
        ],
               [
                  %{
                    id: :michelangelo,
                    can_bowl: false
                  },
                  %{
                    id: :leonardo,
                    can_bowl: false
                  },
                  %{
                    id: :raphael,
                    can_bowl: false
                  },
                  %{
                    id: :donatello,
                    can_bowl: false
                  },
                  %{
                    id: :bart,
                    can_bowl: false
                  },
                  %{
                    id: :marge,
                    can_bowl: false
                  },
                  %{
                    id: :homer,
                    can_bowl: true,
                    bowling_priority: 2
                  },
                  %{
                    id: :lisa,
                    can_bowl: true,
                    bowling_priority: 5
                  },
                  %{
                    id: :maggie,
                    can_bowl: true,
                    bowling_priority: 1
                  },
                 %{
                    id: :burns,
                    can_bowl: true,
                    bowling_priority: 4
                  },
                  %{
                    id: :smithers,
                    can_bowl: true,
                    bowling_priority: 3
                  },
                ]
        ],
        :home,
        :visitors
    }
  end
end