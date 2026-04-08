defmodule Automata do
  @moduledoc """
  Documentation for `Automata`.
  """

  def nfa do
    %{
      states: MapSet.new([0, 1, 2, 3]),
      alphabet: MapSet.new([:a, :b]),
      transitions: %{
        {0, :a} => MapSet.new([0, 1]),
        {0, :b} => MapSet.new([0]),
        {1, :b} => MapSet.new([2]),
        {2, :b} => MapSet.new([3])
      },
      start_state: 0,
      accept_states: MapSet.new([3])
    }
  end
"""
  def determinize do

  end
"""
end
