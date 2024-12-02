defmodule SeedsApp.Repo.AccountFactory do
  defmacro __using__(_opts) do
    quote do
      alias SeedsApp.Contexts.Models.Account

      def account_factory do
        %Account{
          balance: :rand.uniform(),
          login: false,
          user: build(:user)
        }
      end
    end
  end
end
