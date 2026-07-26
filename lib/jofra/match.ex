defmodule Jofra.Match do
    import Jofra.Outcomes
    alias Jofra.{ Clock, Sides, Scores }

    def init_match(home, visitors, toss_winners, toss_choice) do
      %{
        day: 1,
        session: :morning,
        toss_winners: toss_winners,
        toss_choice: toss_choice,
        current_time: ~U[2026-07-25T09:00:00Z],
        session_start_time: ~U[2026-07-25T09:00:00Z],
        match_start_time: ~U[2026-07-25T09:00:00Z],
        session_duration: 2,
        partnership: 0,
        balls: [],
        over: 0,
        ball_age: 0,
        follow_on: false,
        innings: 1,
        home: home,
        visitors: visitors,
        complete: false,
        scores: [%{ side: :home, runs: 0, wickets: 0 }]
      }
      |> Sides.build_sides()
    end

    def play_match(%{ complete: true } = match) do
      IO.inspect(match[:scores], label: "MATCH COMPLETE")
      match
    end

    def play_match(match) do
      match
      |> add_ball()
      |> update_over()
      |> new_ball()
      |> Scores.update_scores()
      |> handle_wicket()
      |> rotate_strike()
      |> change_ends()
      |> change_innings()
      |> Sides.check_declaration()
      |> Clock.advance()
      #need to update bowler usage in here somewhere
      |> Clock.update_session()
      |> Sides.select_bowler()
      |> Scores.check_victory()
      |> play_match()
    end

    def add_ball(%{ balls: balls } = match) do
      match
      |> Map.put(:balls, [ build_outcome(match) | balls ])
    end

    def update_over(%{ balls: balls, innings: innings, over: over, ball_age: ball_age } = match) do
      balls_in_over = balls
      |> query_balls([ innings: innings, over: over, illegal_delivery: false ])
      |> Enum.count

      case balls_in_over do
        6 -> Map.put(match, :over, over + 1) |> Map.put(:ball_age, ball_age + 1)
        _ -> match
      end
    end

    def new_ball(%{ ball_age: ball_age } = match) when ball_age > 80 do
      match
      |> Map.put(:ball_age, 0) #TODO: new ball logic
    end

    def new_ball(match) do
      match
    end

    def rotate_strike(%{ balls: [ %{ result: last_result } | _ ], batsmen: batsmen } = match)
      when last_result in [:single, :triple] do
      match
      |> Map.put(:batsmen, Enum.reverse(batsmen))
    end

    def rotate_strike(match) do
      match
    end

    def change_ends(%{ over: over, balls: [ %{ over: last_ball_over } | _ ], batsmen: batsmen } = match)
      when over > last_ball_over do
      match
      |> Map.put(:batsmen, Enum.reverse(batsmen))
    end

    def change_ends(match) do
      match
    end

    def handle_wicket(%{ balls: [ %{ result: :wicket } | _ ], next_in: [] } = match) do
      IO.inspect(match[:scores], label: "wicket occurred. scores: ")
            IO.inspect(match[:difference], label: "difference: ")
            IO.puts("=====================\r\n")
      match
    end

    def handle_wicket(%{ balls: [ %{ result: :wicket } | _ ] } = match) do
      IO.inspect(match[:scores], label: "wicket occurred. scores: ")
      IO.inspect(match[:difference], label: "difference: ")
      IO.puts("=====================\r\n")
      Sides.new_batsman(match)
    end

    def handle_wicket(match), do: match

    def change_innings(%{ balls: [ %{ result: :wicket } | _ ], scores: [ %{ wickets: wickets } | _ ] } = match)
      when wickets == 10
    do
      Sides.new_innings(match)
    end

    def change_innings(match), do: match

    def query_balls(balls, query) do
      balls
      |> Enum.filter(fn ball ->
            Enum.all?(query, fn { key, value } ->
              Map.get(ball, key) == value end)
            end)
    end
end