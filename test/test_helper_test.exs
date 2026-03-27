defmodule TestHelperTest do
  use ExUnit.Case, async: false

  alias SeedsApp.TestHelper

  describe "await_until/3" do
    test "возвращает :ok когда условие выполняется сразу" do
      result = TestHelper.await_until(fn -> true end, 1000, 50)
      assert result == :ok
    end

    test "возвращает :ok когда условие выполняется после нескольких попыток" do
      counter = :counters.new(1, [:atomics])

      result =
        TestHelper.await_until(
          fn ->
            :counters.add(counter, 1, 1)
            :counters.get(counter, 1) >= 3
          end,
          1000,
          50
        )

      assert result == :ok
      assert :counters.get(counter, 1) >= 3
    end

    test "возвращает {:error, :timeout} когда условие не выполняется" do
      result = TestHelper.await_until(fn -> false end, 200, 50)
      assert result == {:error, :timeout}
    end

    test "использует значения по умолчанию" do
      # Проверяет, что функция работает без явных параметров
      result = TestHelper.await_until(fn -> true end)
      assert result == :ok
    end
  end
end
