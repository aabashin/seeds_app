defmodule SeedsApp.Repo.RoomFactory do
  defmacro __using__(_opts) do
    quote do
      alias SeedsApp.Contexts.Models.Room

      def room_factory do
        %Room{
          title: Faker.Lorem.sentence()
        }
      end
    end
  end
end
