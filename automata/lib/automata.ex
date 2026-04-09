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
  defp powerset([]), do: [MapSet.new()] #caso base
  defp powerset([h | t]) do
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
end
