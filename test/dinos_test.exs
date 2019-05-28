defmodule DinosTest do
  use ExUnit.Case
  doctest Dinos

  test "greets the world" do
    assert Dinos.hello() == :world
  end
end
