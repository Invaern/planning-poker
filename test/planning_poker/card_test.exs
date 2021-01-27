
defmodule CardTest do
  use ExUnit.Case

  test "visible card can't be changed" do
    card = %Card{owner: "Bob", type: {:visible, :one}}
    new_card = Card.set_value(card, :two)
    assert card == new_card
  end

  test "empty card becomes hidden" do
    card = %Card{owner: "Bob", type: :empty}
    new_card = Card.set_value(card, :two)
    assert new_card.type == {:hidden, :two}
  end

  test "hidden card changes value" do
    card = %Card{owner: "Bob", type: {:hidden, :one}}
    new_card = Card.set_value(card, :two)
    assert new_card.type == {:hidden, :two}
  end

  test "hidden card can be revealed" do
    card = %Card{owner: "Bob", type: {:hidden, :one}}
    new_card = Card.reveal(card)
    assert new_card == %Card{owner: "Bob", type: {:visible, :one}}
  end

  test "empty card remains unchanged" do
    card = %Card{owner: "Bob", type: :empty}
    new_card = Card.reveal(card)
    assert new_card == card
  end

  test "sort cards" do
    c_hf = %Card{owner: "Bob", type: {:visible, :half}}
    c_1 = %Card{owner: "Bob", type: {:visible, :one}}
    c_2 = %Card{owner: "Bob", type: {:visible, :two}}
    c_3 = %Card{owner: "Bob", type: {:visible, :three}}
    c_5 = %Card{owner: "Bob", type: {:visible, :five}}
    c_8 = %Card{owner: "Bob", type: {:visible, :eight}}
    c_13 = %Card{owner: "Bob", type: {:visible, :thirteen}}
    c_20 = %Card{owner: "Bob", type: {:visible, :twenty}}
    c_q = %Card{owner: "Bob", type: {:visible, :question}}
    c_e = %Card{owner: "Bob", type: :empty}

    cards = [c_e, c_q, c_20, c_13, c_8, c_5, c_3, c_2, c_1, c_hf]
    assert [c_hf, c_1, c_2, c_3, c_5, c_8, c_13, c_20, c_q, c_e] == Card.sort_cards(cards)
  end

  test "value of empty card is nil" do
    card = %Card{owner: "Bob"}
    assert nil == Card.value(card)
  end

  test "get value of hidden card" do
    card = %Card{owner: "Bob", type: {:hidden, :one}}
    assert :one == Card.value(card)
  end

  test "get value of visible card" do
    card = %Card{owner: "Bob", type: {:visible, :two}}
    assert :two == Card.value(card)
  end

end
