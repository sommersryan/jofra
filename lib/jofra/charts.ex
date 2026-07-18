defmodule Jofra.Charts do
  def charts_for(:batsman) do [
    :tendency,
    :shot_selection,
    :shot_quality,
    :shot_precision,
    :batting_endurance
  ] end

  def charts_for(:bowler) do [
    :line,
    :length,
    :spin,
    :swing,
    :seam
  ] end

  def apply_charts(value, %{ controller: controller } = context) do
    controller
    |> charts_for
    |> Enum.reduce([value], fn current_chart, acc ->
         [ curr | _ ] = acc
         chart_to_use = get_chart(current_chart, curr, context)
         [ roll_on_chart(curr, chart_to_use) | acc ]
       end)
    |> hd()
  end

  def get_chart(chart, value, %{
    controller: controller
  } = context) do
    player_rating = case controller do
      :bowler -> Map.get(context, :bowler) |> Map.get(chart)
      :batsman -> Map.get(context, :batsmen) |> hd() |> Map.get(chart)
    end

    chart(chart, context)
    |> Enum.filter(fn { rating, _, _, _ } -> rating == player_rating end)
    |> Enum.filter(fn { _, chart_value, _, _ } -> chart_value == value end)
  end

  def roll_on_chart(value, value_chart) do
    roll = :rand.uniform()

    result = Enum.reduce_while(value_chart, 0.0, fn { _, _, event, prob }, acc_prob ->
        next_boundary = acc_prob + prob

        cond do
          roll < next_boundary -> { :halt, { :selected, event } }
          true -> { :cont, next_boundary }
        end
      end
    )

    case result do
      { :selected, new_value } -> new_value
      _acc -> value
    end
  end

  def chart(:shot_quality, _) do [
    # better quality - ones and twos become fours
    { :a, :single, :four, 1/20 },
    { :a, :double, :four, 1/5 },
    { :b, :single, :four, 1/40 },
    { :b, :double, :four, 1/25 },
    { :d, :four, :double, 1/25 },
    { :d, :four, :single, 1/40 },
    { :f, :four, :double, 1/15 },
    { :f, :four, :single, 1/15 }
   ]
  end

  def chart(:shot_selection, _) do [
    # better selection - wickets become dots
      { :a, :wicket, :dot, 1/10 },
      { :b, :wicket, :dot, 1/15 },
      { :d, :dot, :wicket, 1/30 },
      { :f, :dot, :wicket, 1/20 }
    ]
  end

  def chart(:shot_precision, _) do
    [
    # better precision - dots become singles, doubles, boundaries
      { :a, :dot, :single, 1/10 },
      { :a, :dot, :double, 1/20 },
      { :a, :dot, :four, 1/50 },
      { :b, :dot, :single, 1/20 },
      { :b, :dot, :double, 1/30 },
      { :b, :dot, :four, 1/70 },
      { :d, :four, :dot, 1/20 },
      { :d, :double, :dot, 1/30 },
      { :d, :single, :dot, 1/70 },
      { :f, :four, :dot, 1/10 },
      { :f, :double, :dot, 1/20 },
      { :f, :single, :dot, 1/50 }
    ]
  end

  def chart(:tendency, _) do [
    # conservative / moderate / aggressive
    # conservative - singles become dots, wickets become dots
    # moderate - no change
    # aggressive - singles become fours, dots become wickets
    { :conservative, :single, :dot, 1/20 },
    { :conservative, :wicket, :dot, 1/10 },
    { :aggressive, :single, :four, 1/10 },
    { :aggressive, :dot, :wicket, 1/30 }
  ]
  end

  def chart(:batting_endurance, %{ day: day }) when day > 3 do
    [# with lower endurance, dots become wickets late in match
      { :d, :dot, :wicket, 1/30 },
      { :f, :dot, :wicket, 1/15 }
    ]
  end

  def chart(:batting_endurance, _), do: []

  # bowlers
  def chart(:line, _) do
    # better line - wides become dots, singles become dots
    [
      # wait how do I do this
    ]
  end

  def chart(:length, _) do
    # better length - dots become wickets
    [
      { :a, :dot, :wicket, 1/30 },
      { :b, :dot, :wicket, 1/15 },
      { :d, :wicket, :dot, 1/30 },
      { :f, :wicket, :dot, 1/15 }
    ]
  end

  def chart(:spin, %{ ball_age: ball_age, bowler: %{ bowler_type: :spin } }) when ball_age > 40 do
    # for spin bowlers, better spin makes dots become wickets
    # for older balls
    [
      { :a, :dot, :wicket, 1/30 },
      { :b, :dot, :wicket, 1/15 },
      { :d, :wicket, :dot, 1/30 },
      { :f, :wicket, :dot, 1/15 }
    ]
  end

  def chart(:swing, %{ ball_age: ball_age, bowler: %{ bowler_type: :swing } }) when ball_age > 20 do
    # for swing bowlers, better swing makes dots become wickets
    # for medium-old(?) balls
        [
          { :a, :dot, :wicket, 1/30 },
          { :b, :dot, :wicket, 1/15 },
          { :d, :wicket, :dot, 1/30 },
          { :f, :wicket, :dot, 1/15 }
        ]
  end

  def chart(:seam, %{ ball_age: ball_age, bowler: %{ bowler_type: :seam } }) when ball_age < 20 do
    # for seam bowlers, better seam makes dots become wickets
    # for newer balls
            [
              { :a, :dot, :wicket, 1/30 },
              { :b, :dot, :wicket, 1/15 },
              { :d, :wicket, :dot, 1/30 },
              { :f, :wicket, :dot, 1/15 }
            ]
  end

  def chart(:field_setting, _) do
    # for the captain, better field setting turns fours into singles
    # and doubles into wickets
  end

  def chart(_, _) do
    []
  end
end