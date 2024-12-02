defmodule SeedsApp.Contexts.Models.Room do
  use Ecto.Schema

  import Ecto.Changeset

  alias SeedsApp.Contexts.Models.Meeting

  @type t :: __MODULE__

  @cast_fields ~w"title"a
  @required_fields ~w"title"a
  @constraint_fields ~w"title"a

  schema "rooms" do
    field(:title, :string)

    has_many(:meetings, Meeting)

    timestamps(type: :naive_datetime_usec)
  end

  def changeset(struct, params) do
    struct
    |> cast(params, @cast_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(@constraint_fields)
  end
end
