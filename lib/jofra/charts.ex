defmodule Jofra.Charts do
  def apply_chart(event, chart, context) do

  end

  def batsman_charts do [
    :tendency,
    :shot_selection,
    :shot_quality,
    :shot_precision,
    :batting_endurance
  ] end

  def bowler_charts do [
    :line,
    :length,
    :spin,
    :swing,
    :seam
  ] end


  def get_chart(:shot_quality, context) do [
    # better quality - ones and twos become fours
    { :a, :single, :four, 1, 20 },
    { :a, :double, :four, 1, 15 },
    { :b, :single, :four, 1, 40 },
    { :b, :double, :four, 1, 25 },
    { :d, :four, :double, 1, 25 },
    { :d, :four, :single, 1, 40 },
    { :f, :four, :double, 1, 15 },
    { :f, :four, :single, 1, 20 }
   ]
  end

  def get_chart(:shot_selection, context) do [
    # better selection - wickets become dots
      { :a, :wicket, :dot, 1, 10 },
      { :b, :wicket, :dot, 1, 15 },
      { :d, :dot, :wicket, 1, 40 },
      { :f, :dot, :wicket, 1, 30 }
    ]
  end

  def get_chart(:shot_precision, context) do
    [
    # better precision - dots become singles, doubles, boundaries
      { :a, :dot, :single, 1, 10 },
      { :a, :dot, :double, 1, 20 },
      { :a, :dot, :four, 1, 50 },
      { :b, :dot, :single, 1, 20 },
      { :b, :dot, :double, 1, 30 },
      { :b, :dot, :four, 1, 70 },
      { :d, :four, :dot, 1, 20 },
      { :d, :double, :dot, 1, 30 },
      { :d, :single, :dot, 1, 70 },
      { :f, :four, :dot, 1, 10 },
      { :f, :double, :dot, 1, 20 },
      { :f, :single, :dot, 1, 50 }
    ]
  end

  def get_chart(:tendency, context) do [
    # conservative / moderate / aggressive
    # conservative - singles become dots, wickets become dots
    # moderate - no change
    # aggressive - singles become fours, dots become wickets
    { :conservative, :single, :dot, 1, 20 },
    { :conservative, :wicket, :dot, 1, 10 },
    { :aggressive, :single, :four, 1, 10 },
    { :aggressive, :dot, :wicket, 1, 30 }
  ]
  end

  def get_chart(:batting_endurance, _), do: []

  def get_chart(:batting_endurance, %{ day: day } = context) when day > 3 do
    [# with lower endurance, dots become wickets late in match
      { :d, :dot, :wicket, 1,  30 },
      { :f, :dot, :wicket, 1, 15}
    ]
  end

  # bowlers
  def get_chart(:line, context) do
    # better line - wides become dots, singles become dots
    [
      # wait how do I do this
    ]
  end

  def get_chart(:length, context) do
    # better length - dots become wickets
    [
      { :a, :dot, :wicket, 1, 30 },
      { :b, :dot, :wicket, 1, 15 },
      { :d, :wicket, :dot, 1, 30 },
      { :f, :wicket, :dot, 1, 15 }
    ]
  end

  def get_chart(:spin, %{ ball_age: ball_age } = context) when ball_age > 40 do
    # for spin bowlers, better spin makes dots become wickets
    # for older balls
    [
      { :a, :dot, :wicket, 1, 30 },
      { :b, :dot, :wicket, 1, 15 },
      { :d, :wicket, :dot, 1, 30 },
      { :f, :wicket, :dot, 1, 15 }
    ]
  end

  def get_chart(:swing, %{ ball_age: ball_age } = context) when ball_age > 20 do
    # for swing bowlers, better swing makes dots become wickets
    # for medium-old(?) balls
        [
          { :a, :dot, :wicket, 1, 30 },
          { :b, :dot, :wicket, 1, 15 },
          { :d, :wicket, :dot, 1, 30 },
          { :f, :wicket, :dot, 1, 15 }
        ]
  end

  def get_chart(:seam, %{ ball_age: ball_age } = context) when ball_age < 20 do
    # for seam bowlers, better seam makes dots become wickets
    # for newer balls
            [
              { :a, :dot, :wicket, 1, 30 },
              { :b, :dot, :wicket, 1, 15 },
              { :d, :wicket, :dot, 1, 30 },
              { :f, :wicket, :dot, 1, 15 }
            ]
  end

  def get_chart(:field_setting, context) do
    # for the captain, better field setting turns fours into singles
    # and doubles into wickets
  end
end