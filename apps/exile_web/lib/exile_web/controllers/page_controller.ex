defmodule ExileWeb.PageController do
  use ExileWeb, :controller
  alias ExileWeb.ConnectionToken

  def index(conn, %{"token" => token}) do
    {:ok, %{prefix: prefix}} = ConnectionToken.verify(token)
    payload = %{prefix: prefix, token: token}
    render(conn, "index.html", prefix: prefix, payload: payload)
  end

  def index(conn, _) do
    prefix = UUID.uuid4()
    token = ConnectionToken.encode(prefix: prefix)
    conn |> redirect(to: Routes.page_path(conn, :index, %{token: token}))
  end
end
