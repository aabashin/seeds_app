defmodule SeedsApp.Contexts.Models.Meeting do
  use Ecto.Schema

  import Ecto.Changeset

  alias SeedsApp.Contexts.Models.Room
  alias SeedsApp.Contexts.Models.User

  @type t :: __MODULE__

  @cast_fields ~w"theme user_id room_id"a
  @required_fields ~w"theme user_id room_id"a

  schema "meetings" do
    field(:theme, :string)

    belongs_to(:room, Room)
    belongs_to(:user, User)

    timestamps(type: :naive_datetime_usec)
  end

  def changeset(struct, params) do
    struct
    |> cast(params, @cast_fields)
    |> validate_required(@required_fields)
  end
end
