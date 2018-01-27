defmodule Bamboo.AliyunAdapterTest do
  use ExUnit.Case,async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias Bamboo.Email
  alias Bamboo.AliyunAdapter

  @config %{
    adapter: Bamboo.AliyunAdapter,
    uri: "https://dm.aliyuncs.com",
    version: "2015-11-23",
    region_id: "cn-hangzhou",
    access_key_id: "sample",
    access_key_secret: "secret",
    address_type: 1,
    reply_to_address: true,
    click_trace: 1
  }

  test "deliver/2 sends from, html and text body, subject" do
    email = new_email(
      subject: "My Subject",
      text_body: "TEXT BODY",
      html_body: "HTML BODY"
    )

    use_cassette "success_sample" do
      result =
        email
        |> AliyunAdapter.deliver(@config)

      assert result.status_code == 200
      assert result.body
    end
  end

  defp new_email(attrs) do
    attrs = Keyword.merge([
      from: {"Test From", "test@example.com"},
      to: [{"Jun", "jun@example.com"}]
    ], attrs)

    Email.new_email(attrs) |> Bamboo.Mailer.normalize_addresses
  end
end
