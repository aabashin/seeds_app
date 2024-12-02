defmodule SeedsApp.Repo.UserFactory do
  defmacro __using__(_opts) do
    quote do
      alias SeedsApp.Contexts.Models.User

      def user_factory do
        %User{
          name: Faker.Person.first_name(),
          age: :rand.uniform(100),
          email: Faker.Internet.email()
        }
      end
    end
  end
end