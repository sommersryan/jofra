defmodule Jofra.PlayerCreation do
    def player() do
      %{}
      |> Map.put(:id, Ecto.UUID.generate())
      |> Map.put(:bat_handedness, [ :left, :right ] |> Enum.random())
      |> Map.put(:bowling_handedness, [ :left, :right ] |> Enum.random())
    end

    def as_batsman(player, :opening) do
      player
      |> with_rating(:shot_quality, Enum.random([:good, :ok]))
      |> with_rating(:shot_selection, Enum.random([:great, :good]))
      |> with_rating(:shot_precision, Enum.random([:ok]))
      |> Map.put(:tendency, Enum.random([:moderate, :conservative]))
    end

    def as_batsman(player, :middle) do
      player
      |> with_rating(:shot_quality, Enum.random([:great, :good]))
      |> with_rating(:shot_selection, Enum.random([:ok, :good, :great]))
      |> with_rating(:shot_precision, Enum.random([:good, :great]))
      |> Map.put(:tendency, Enum.random([:moderate]))
    end

    def as_batsman(player, :lower) do
      player
      |> with_rating(:shot_quality, Enum.random([:great, :good]))
      |> with_rating(:shot_selection, Enum.random([:ok, :good, :great]))
      |> with_rating(:shot_precision, Enum.random([:good, :great]))
      |> Map.put(:tendency, Enum.random([:conservative, :moderate, :aggressive]))
    end

    def as_batsman(player, :bowler) do
      player
      |> with_rating(:shot_quality, Enum.random([:poor, :ok]))
      |> with_rating(:shot_selection, Enum.random([:poor]))
      |> with_rating(:shot_precision, Enum.random([:poor]))
      |> Map.put(:tendency, Enum.random([:conservative]))
    end

    def with_bowling_tendency(player, tendency) do
      player
      |> Map.put(:can_bowl, true)
      |> Map.put(:bowler_type, tendency)
      |> with_rating(tendency, Enum.random([:ok, :good, :great]))
    end

    def as_bowler(player, :great) do
      player
      |> with_rating(:line, Enum.random([:great, :good]))
      |> with_rating(:length, Enum.random([:great, :good]))
    end

    def as_bowler(player, :moderate) do
      player
      |> with_rating(:line, Enum.random([:good, :ok]))
      |> with_rating(:length, Enum.random([:good, :ok]))
    end

    def as_bowler(player, :poor) do
      player
      |> with_rating(:line, Enum.random([:ok, :poor]))
      |> with_rating(:length, Enum.random([:ok, :poor]))
    end

    def with_rating(player, rating, quality) do
      Map.put(player, rating, get_grade(quality))
    end

    def get_grade(quality) do
      opts = case quality do
        :great -> [:a, :b]
        :good -> [:b, :c]
        :ok -> [:c]
        :poor -> [:d, :f]
      end

      Enum.random(opts)
    end
end