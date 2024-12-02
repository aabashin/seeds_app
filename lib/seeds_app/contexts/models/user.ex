defmodule SeedsApp.Contexts.Models.User do
  use Ecto.Schema

  import Ecto.Changeset

  alias SeedsApp.Contexts.Models.Account
  alias SeedsApp.Contexts.Models.Meeting

  @type t :: __MODULE__

  @cast_fields ~w"name age email"a
  @required_fields ~w"name age email"a
  @constraint_fields ~w"email"a

  schema "users" do
    field(:name, :string)
    field(:age, :integer)
    field(:email, :string)

    has_many(:meetings, Meeting)

    has_one(:account, Account)

    timestamps(type: :naive_datetime_usec)
  end

  def changeset(struct, params) do
    struct
    |> cast(params, @cast_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(@constraint_fields)
  end
end
