defmodule SeedsApp.Types do
  @moduledoc """
  Application types
  """

  @typedoc """
  Account record
  """
  @type account() :: %{
          required(:balance) => float(),
          required(:login) => boolean(),
          required(:user_id) => pos_integer()
        }

  @typedoc """
  User record
  """
  @type user() :: %{
          required(:name) => String.t(),
          required(:age) => pos_integer(),
          required(:email) => String.t()
        }

  @typedoc """
  Room record
  """
  @type room() :: %{required(:title) => String.t()}

  @typedoc """
  Meeting record
  """
  @type metting() :: %{
          optional(:theme) => String.t(),
          required(:user_id) => pos_integer(),
          required(:room_id) => pos_integer()
        }
end
