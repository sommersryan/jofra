defmodule Jofra.Match do
  import Jofra.Outcomes
  alias Jofra.{ Clock, Sides }

# REFACTOR:
# should everything be stored on individual balls? day, session, innings, over number, and the data for a match is just a list of
# balls? and maybe some general descriptive properties? a big giant reduce on one starting state? might be sick!!
# might make tallying session and innings results and player stats (just group bys!) and checking victory conditions much easier
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
    balls: [],
    over: 0,
    ball_age: 0,
    runs_to_win: nil,
    wickets_to_win: nil,
    innings: 1,
    home: home,
    visitors: visitors,
    complete: false,
    scores: [%{ side: :home, runs: 0, wickets: 0 }] # current innings goes at the head, update every iteration. may not need the *_to_win properties
                # sum could just be a group by
  }
  |> Sides.build_sides()
end

def play_match(%{ complete: true } = match) do
  match
end

def play_match(match) do
  match
  |> add_ball()
  |> update_over()
  |> handle_wicket()
  |> rotate_strike()
  |> change_ends()
  |> change_innings()
  |> Clock.advance()
  #add end timestamp to last ball here?
  #need to update ball age and bowler usage in here somewhere
  |> Clock.update_session()
  |> Sides.select_bowler()
  |> play_match()
end

def add_ball(%{ balls: balls } = match) do
  match
  |> Map.put(:balls, [ build_outcome(match) | balls ])
end

def update_over(%{ balls: balls, innings: innings, over: over } = match) do
  balls_in_over = balls
  |> query_balls([ innings: innings, over: over, illegal_delivery: false ])
  |> Enum.count

  case balls_in_over do
    6 -> Map.put(match, :over, over + 1)
    _ -> match
  end
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
  match
end

def handle_wicket(%{ balls: [ %{ result: :wicket } | _ ] } = match) do
  Sides.new_batsman(match)
end

def handle_wicket(match), do: match

def change_innings(%{ balls: [ %{ result: :wicket } | _ ], next_in: [] } = match) do
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