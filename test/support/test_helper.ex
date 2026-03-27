defmodule SeedsApp.TestHelper do
  @moduledoc """
  Утилиты для тестирования.

  Предоставляет функции для ожидания выполнения условий вместо использования Process.sleep.
  """

  @doc """
  Ожидает, пока условие не станет истинным или не истечёт таймаут.

  ## Параметры
    - fun: функция-предикат, возвращающая boolean
    - timeout: максимальное время ожидания в мс (по умолчанию 5000)
    - interval: интервал между проверками в мс (по умолчанию 100)

  ## Примеры
      iex> await_until(fn -> UsersAccounts.count() > 0 end, 5_000)
      :ok

      iex> await_until(fn -> false end, 100)
      {:error, :timeout}
  """
  @spec await_until(fun(), non_neg_integer(), non_neg_integer()) :: :ok | {:error, :timeout}
  def await_until(fun, timeout \\ 5000, interval \\ 100) do
    do_await_until(fun, timeout, interval)
  end

  defp do_await_until(_fun, timeout, _interval) when timeout <= 0 do
    {:error, :timeout}
  end

  defp do_await_until(fun, timeout, interval) do
    case fun.() do
      true ->
        :ok

      false ->
        Process.sleep(interval)
        do_await_until(fun, timeout - interval, interval)
    end
  end
end
