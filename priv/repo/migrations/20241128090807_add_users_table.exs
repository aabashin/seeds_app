defmodule Seeds.Repo.Migrations.AddUsersTable do
  use Ecto.Migration

  def change do
    create table(:users) do
      add(:name, :string, null: false)
      add(:age, :integer, default: 0, null: false)
      add(:email, :string, null: false)

      timestamps()
    end

    create unique_index(:users, [:email])
  end
end
