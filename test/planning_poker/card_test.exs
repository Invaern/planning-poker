
defmodule CardTest do
  use ExUnit.Case

  test "visible card can't be changed" do
    card = %Card{owner: "Bob", type: {:visible, 1}}
    new_card = Card.set_value(card, 2)
    assert card == new_card
  end

  test "empty card becomes hidden" do
    card = %Card{owner: "Bob", type: :empty}
    new_card = Card.set_value(card, 2)
    assert new_card.type == {:hidden, 2}
  end

  test "empty card changes value" do
    card = %Card{owner: "Bob", type: {:hidden, 1}}
    new_card = Card.set_value(card, 2)
    assert new_card.type == {:hidden, 2}
  end

  test "hidden card can be revealed" do
    card = %Card{owner: "Bob", type: {:hidden, 1}}
    new_card = Card.reveal(card)
    assert new_card == %Card{owner: "Bob", type: {:visible, 1}}
  end

  test "empty card remains unchanged" do
    card = %Card{owner: "Bob", type: :empty}
    new_card = Card.reveal(card)
    assert new_card == card
  end

end
