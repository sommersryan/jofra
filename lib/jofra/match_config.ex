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
      hit_locations: %{
        cover: 220,
        extra_cover: 20,
        mid_wicket: 120,
        mid_on: 85,
        point: 150,
        backward_point: 40,
        mid_off: 120,
        square_leg: 100,
        fine_leg: 20,
        slips: 80,
        gully: 10,
        keeper: 10,
        third_man: 25
      },
      overs_limit: nil,
      days: 5,
      day_start: ~T[09:00:00],
      sessions: [
        %{
          name: :morning,
          break: :lunch,
          hours: 2
        },
        %{
          name: :afternoon,
          break: :tea,
          hours: 2
        },
        %{
          name: :evening,
          break: :stumps,
          hours: 2
        }
      ]
    }
  end
end