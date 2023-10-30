defmodule HostingWeb.PresignedUploadControllerTest do
  use HostingWeb.ConnCase, async: true

  import Hosting.SitesFixtures

  test "provides presigned upload JSON" do
    site = site_fixture()

    conn = build_conn()
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
