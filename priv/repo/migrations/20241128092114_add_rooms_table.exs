defmodule SeedsApp.Repo.Migrations.AddRoomsTable do
  use Ecto.Migration

  def change do
    create table(:rooms) do
      add(:title, :string, null: false)

      timestamps()
    end

    create unique_index(:rooms, [:title])
  end
end
