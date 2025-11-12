defmodule SeedsAppWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: SeedsAppWeb

      import Plug.Conn
      import Phoenix.HTML
      alias SeedsAppWeb.Router.Helpers, as: Routes
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/seeds_app_web/templates/error",
        namespace: SeedsAppWeb,
        pattern: "**/*"

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_flash: 1, get_flash: 2, view_module: 1, view_template: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML
    end
  end

  def router do
    quote do
      use Phoenix.Router

      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
