defmodule SeedsApp.Repo.Migrations.AddAccountsTable do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add(:user_id, references(:users, on_delete: :delete_all, on_update: :update_all), null: false)
      add(:balance, :float, default: 0.0, null: false)
      add(:login, :boolean, default: false, null: false)

      timestamps()
    end

    create unique_index(:accounts, [:user_id])
  end
end
