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

  test "start state e_nfa to dfa correct" do
    nfa = Automata.e_nfa()

    dfa = Automata.e_determinize(nfa)

    expected_start = MapSet.new([0, 1, 2, 3, 7])
    assert dfa.start_state == expected_start

  end

  test "same alphabet for dfa and e_nfa" do
    enfa = Automata.e_nfa()
    dfa = Automata.determinize(enfa)
    assert MapSet.equal?(dfa.alphabet, enfa.alphabet)
  end

  test "correct final states" do
    enfa = Automata.e_nfa()
    dfa = Automata.determinize(enfa)

    refute MapSet.equal?(dfa.accept_states, MapSet.new())

    assert Enum.any?(dfa.accept_states, fn state_set ->
      MapSet.member?(state_set, 10)
    end)
  end
end
