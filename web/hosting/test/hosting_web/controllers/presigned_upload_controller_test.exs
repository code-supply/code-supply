defmodule HostingWeb.PresignedUploadControllerTest do
  use HostingWeb.ConnCase, async: true

  import Hosting.AccountsFixtures

  alias Hosting.Accounts

  test "rejects users with mismatching API keys" do
    user = user_fixture()
    [site] = user.sites

    conn =
      build_conn()
      |> put_req_header("authorization", "Bearer bad-api-key")

    conn = get(conn, url(~p"/sites/#{site.id}/presigned_upload"))

    assert json_response(conn, 401)
  end

  test "provides presigned upload JSON to users with matching API key" do
    user = user_fixture()
    [site] = user.sites

    {:ok, _user} = Accounts.apply_api_key(user, "my-api-key")

    conn =
      build_conn()
      |> put_req_header("authorization", "Bearer my-api-key")

    conn = get(conn, url(~p"/sites/#{site.id}/presigned_upload"))

    response = json_response(conn, 200)

    expected_url =
      "https://#{Application.fetch_env!(:hosting, :bucket_name)}.storage.googleapis.com/"

    assert %{
             "uploader" => "GCS",
             "url" => ^expected_url,
             "fields" => %{
               "key" => _key,
               "policy" => policy,
               "x-goog-algorithm" => "GOOG4-RSA-SHA256",
               "x-goog-credential" => creds,
               "x-goog-date" => _date,
               "x-goog-signature" => _signature
             }
           } = response

    assert creds =~ "/auto/storage/goog4_request"
    assert Base.decode64!(policy)
  end
end
