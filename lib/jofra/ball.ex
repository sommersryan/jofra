defmodule Jofra.Ball do
  use GenServer

  @impl true
  def init(age) do
    { :ok, %{ age: age }}
  end

  @impl true
  def handle_call(:over_bowled, _from, %{ age: age }) do
    { :reply, :ok, %{ age: age + 1 } }
  end

  @impl true
  def handle_call(:current_age, _from, %{ age: age } = state) do
    { :reply, age, state }
  end

  @impl true
  def handle_call(:new_ball_check, _from, %{ age: age } = state) do
    { :reply, age > 79, state }
  end

  @impl true
  def handle_call(:new_ball_taken, _from, _) do
    { :reply, :ok, %{ age: 0 } }
  end

  def start_link(age \\ 0) do
    GenServer.start_link(__MODULE__, age, name: __MODULE__)
  end

  def over_bowled() do
    GenServer.call(__MODULE__, :over_bowled)
  end

  def age() do
    GenServer.call(__MODULE__, :current_age)
  end

  def new_ball_possible?() do
    GenServer.call(__MODULE__, :new_ball_check)
  end

  def new_ball() do
    GenServer.call(__MODULE__, :new_ball_taken)
  end
end