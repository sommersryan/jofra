defmodule Jofra.MatchConfig do
  def get_match_config(:test) do
    %{
      outcomes: %{
        dot: 730,
        single: 180,
        four: 46,
        double: 33,
        triple: 4,
        six: 3,
        wicket: 4
      },
      extras: %{
        leg_bye: 5,
        bye: 2,
        wide: 1,
        no_ball: 1
      },
      wickets: %{
        caught: 580,
        bowled: 200,
        lbw: 173,
        run_out: 30,
        stumped: 17
      },
      overs_limit: nil,
      days: 5,
      day_start: ~T[09:00:00],
      sessions: [
        %{
          name: "Morning",
          end_name: "Lunch",
          hours: 2
        },
        %{
          name: "Afternoon",
          end_name: "Tea",
          hours: 2
        },
        %{
          name: "Evening",
          end_name: "Stumps",
          hours: 2
        }
      ]
    }
  end
end