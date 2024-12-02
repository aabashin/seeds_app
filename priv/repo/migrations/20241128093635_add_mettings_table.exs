defmodule SeedsApp.Repo.Migrations.AddMettingsTable do
  use Ecto.Migration

  def change do
    create table(:meetings) do
      add(:user_id, references(:users, on_delete: :restrict, on_update: :update_all))
      add(:room_id, references(:rooms, on_delete: :restrict, on_update: :update_all))
      add(:theme, :string)

      timestamps()
    end
  end
end
