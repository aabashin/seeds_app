defmodule SeedsApp.Repo.MeetingFactory do
  defmacro __using__(_opts) do
    quote do
      alias SeedsApp.Contexts.Models.Meeting

      def meeting_factory do
        %Meeting{
          theme: Faker.Lorem.sentence(),
          room: build(:room),
          user: build(:user)
        }
      end
    end
  end
end
