defmodule SeedsAppWeb.ErrorView do
  use SeedsAppWeb, :view

  def render("404.html", _assigns) do
    "Page Not Found"
  end

  # Можно добавить другие шаблоны для разных ошибок
  def render("500.html", _assigns) do
    "Internal Server Error"
  end

  # Fallback для любых других ошибок
  def template_not_found(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end
end
