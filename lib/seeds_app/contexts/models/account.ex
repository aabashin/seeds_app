defmodule SeedsApp.Contexts.Models.Account do
  use Ecto.Schema

  import Ecto.Changeset

  alias SeedsApp.Contexts.Models.User

  @type t :: __MODULE__

  @cast_fields ~w"balance login user_id"a
  @required_fields ~w"balance login user_id"a

  schema "accounts" do
    field(:balance, :float)
    field(:login, :boolean)

    belongs_to(:user, User)

    timestamps(type: :naive_datetime_usec)
  end

  def changeset(struct, params) do
    struct
    |> cast(params, @cast_fields)
    |> validate_required(@required_fields)
  end
end
