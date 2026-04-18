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
  # Q' = P(Q) powerset
  def powerset([]), do: [MapSet.new()] #caso base
  def powerset([h | t]) do
    sub = powerset(t)
    sub ++ Enum.map(sub, fn s -> MapSet.put(s, h) end)
  end

  def determinize(nfa) do
    all_states = powerset( MapSet.to_list(nfa.states))

    # Si el subconjunto y los accepted states del NFA tienen algo en común
    dfa_accept_states = Enum.filter(all_states, fn subset -> !MapSet.disjoint?(subset, nfa.accept_states) end)

    # Para cada estado (subset), iteramos sobre cada letra del alfabeto (:a, :b)
    dfa_transitions = Enum.reduce(all_states, %{}, fn subset, acc ->
    Enum.reduce(nfa.alphabet, acc, fn symbol, acc2 ->
      dest = Enum.reduce(subset, MapSet.new(), fn state, union ->
        nfa_dest = Map.get(nfa.transitions, {state, symbol}, MapSet.new())
        MapSet.union(union, nfa_dest)
      end)
      # Guardamos la transición: {Subconjunto, Símbolo} -> Subconjunto Destino
        Map.put(acc2, {subset, symbol}, dest)
      end)
    end)

  #dfa
    %{
      states: MapSet.new(all_states),
      alphabet: nfa.alphabet,
      transitions: dfa_transitions,
      start_state: MapSet.new([nfa.start_state]),
      accept_states: MapSet.new(dfa_accept_states)
    }
  end

  def e_closure(nfa, states) do
    #dfs recursion right?
    e_closure_dfs(nfa, MapSet.to_list(states), MapSet.new())
  end
  #caso base, se acaban los estados, regreso todo lo que recorri
  def e_closure_dfs( _nfa, [], visited), do: visited
  def e_closure_dfs(nfa, [h|t], visited) do
    if MapSet.member?(visited, h) do
      # ya pase aqui, sigo con el tail
      e_closure_dfs(nfa, t, visited)
    else
      # busco epsilon transitions desde h, mapset.new es por defecto por si no hay
      eps_transitions = Map.get(nfa.transitions, {h, :epsilon}, MapSet.new())
      # marcar visitados
      new_visited = MapSet.put(visited, h)
      # agrego los nuevos para seguir
      e_closure_dfs(nfa, MapSet.to_list(eps_transitions) ++ t, new_visited)
    end
  end

  def e_nfa do
    %{
      states: MapSet.new([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]),
      alphabet: MapSet.new([:a, :b]),
      transitions: %{
        {0, :epsilon} => MapSet.new([1,7]),
        {1, :epsilon} => MapSet.new([2,3]),
        {2, :a} => MapSet.new([4]),
        {3, :b} => MapSet.new([5]),
        {4, :epsilon} => MapSet.new([6]),
        {5, :epsilon} => MapSet.new([6]),
        {6, :epsilon} => MapSet.new([1,7]),
        {7, :a} => MapSet.new([8]),
        {8, :b} => MapSet.new([9]),
        {9, :b} => MapSet.new([10])
      },
      start_state: 0,
      accept_states: MapSet.new([10])
    }
  end
  def e_determinize(e_nfa) do
    q0 = e_closure(e_nfa, MapSet.new([e_nfa.start_state]))

    {reachable_states, dfa_transitions} = open_dfs(e_nfa, [q0], MapSet.new(), %{})

    dfa_accept_states = Enum.filter(reachable_states, fn subset -> !MapSet.disjoint?(subset, e_nfa.accept_states) end)

    #dfa with epsilon transitions
    %{
      states: MapSet.new(reachable_states),
      alphabet: e_nfa.alphabet,
      transitions: dfa_transitions,
      start_state: q0,
      accept_states: MapSet.new(dfa_accept_states)
    }
  end

  def open_dfs( _e_nfa, [], visited, transitions), do: {visited, transitions} #visited are my states
  def open_dfs(e_nfa, [h|rest_open], visited, transitions) do
    if MapSet.member?(visited, h) do
      # ya pase aqui, sigo con el tail
      open_dfs(e_nfa, rest_open, visited, transitions)
    else
      new_visited = MapSet.put(visited, h)

      #for a in  alphabet
      {new_transitions, new_open} = for_loop(e_nfa, h, transitions, rest_open)

      open_dfs(e_nfa, new_open, new_visited, new_transitions)

    end
  end

  def for_loop(e_nfa, curr_state, transitions, open) do
    Enum.reduce(e_nfa.alphabet, {transitions, open}, fn symbol, {trans_acc, open_acc} ->
       # that thing with S transition function from my state
    direct_reach = e_nfa
          |> e_closure(curr_state)
          |> Enum.reduce(MapSet.new(), fn q, acc ->
               reached = Map.get(e_nfa.transitions, {q, symbol}, MapSet.new())
               MapSet.union(acc, reached)
             end)
    #now also with epsilon transitions
    s = e_closure(e_nfa, direct_reach)

    #ask if its not empty
    if MapSet.size(s) > 0 do
      new_trans = Map.put(trans_acc, {curr_state, symbol}, s)
      # if not visited (not in open)
      new_open  = if s in open_acc do
                    open_acc
                  else
                      open_acc ++ [s]
                  end
      {new_trans, new_open}
    else
      # nothing new to add
      {trans_acc, open_acc}
    end
    end
    )
  end

end
