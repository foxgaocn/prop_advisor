defmodule AdvisorTest do
  use ExUnit.Case
  doctest Advisor

  test "greets the world" do
    assert Advisor.hello() == :world
  end
end
