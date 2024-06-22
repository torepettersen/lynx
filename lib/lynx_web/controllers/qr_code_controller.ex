defmodule LynxWeb.QRCodeController do
  use LynxWeb, :controller

  alias Lynx.ShortLinks.ShortLink

  def qr_code(conn, %{"id" => id}) do
    short_link = Ash.get!(ShortLink, id)

    qr_code =
      "https://pnt.li/#{short_link.code}"
      |> QRCodeEx.encode()
      |> QRCodeEx.svg(width: 300)

    conn
    |> put_resp_content_type("image/svg+xml")
    |> send_download({:binary, qr_code}, filename: "pnt.li-#{short_link.code}.svg")
  end
end
