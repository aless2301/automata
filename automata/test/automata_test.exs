defmodule AutomataTest do
  use ExUnit.Case
  doctest Automata

  test "correct number of states" do
    nfa = Automata.nfa()
    dfa = Automata.determinize(nfa)
    assert MapSet.size(dfa.states) == 16
  end

   test "initial state {0}" do
    nfa = Automata.nfa()
    dfa = Automata.determinize(nfa)
    assert dfa.start_state == MapSet.new([0])
  end

  test "abb accepted" do
    dfa = Automata.nfa() |> Automata.determinize()
    # Simulamos: {0} -a-> {0,1} -b-> {0,2} -b-> {0,3}
    s0 = Map.get(dfa.transitions, {MapSet.new([0]),       :a})
    s1 = Map.get(dfa.transitions, {s0,                    :b})
    s2 = Map.get(dfa.transitions, {s1,                    :b})
    assert MapSet.member?(dfa.accept_states, s2)
  end

end
