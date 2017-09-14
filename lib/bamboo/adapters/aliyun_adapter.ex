defmodule Bamboo.AliyunAdapter do
  @moduledoc """
  Sends email using [Aliyun’s API](https://www.aliyun.com/product/directmail?spm=5176.8142029.388261.228.dKDNYN).

  Use this adapter to send emails through Aliyun’s API.

  ## Example config

      # In config/config.exs, or config.prod.exs, etc.
      config :my_app, MyApp.Mailer,
        uri: "https://dm.aliyuncs.com",
        version: "2015-11-23",
        region_id: "cn-hangzhou",
        adapter: Bamboo.AliyunAdapter,
        access_key_id: "sample",
        access_key_secret: "secret",
        address_type: 1,
        reply_to_address: true

      # Define a Mailer. Maybe in lib/my_app/mailer.ex
      defmodule MyApp.Mailer do
        use Bamboo.Mailer, otp_app: :my_app
      end
  """
  @behaviour Bamboo.Adapter

  @aliyun_dm_fields ~w(Action AccountName ReplyToAddress AddressType ToAddress FromAlias Subject HtmlBody TextBody ClickTrace)a
  @service_name "Aliyun"

  alias Bamboo.Email
  alias Bamboo.AliyunAdapter.ApiError

  @impl Bamboo.Adapter
  def deliver(email, config) do
    headers = [
      {"Content-Type", "application/x-www-form-urlencoded"},
    ]

    body =
      email
      |> to_aliyun_body(config)
      |> append_shared_info(config)
      |> sign(config)

    case :hackney.post(config.uri, headers, URI.encode_query(body), [:with_body]) do
      {:ok, status, _headers, response} when status > 299 ->
        ApiError.raise_api_error(@service_name, response, body)
      {:ok, status, headers, response} ->
        %{status_code: status, headers: headers, body: response}
      {:error, reason} ->
        ApiError.raise_api_error(inspect(reason))
    end
  end

  @impl Bamboo.Adapter
  def handle_config(config) do
    for setting <- [:uri, :version, :region_id, :access_key_id, :access_key_secret, :address_type, :reply_to_address] do
      if config[setting] in [nil, ""] do
        raise_missing_setting_error(config, setting)
      end
    end
    config
  end

  defp raise_missing_setting_error(config, setting) do
    raise ArgumentError, """
    There was no #{setting} set for the Aliyun adapter.

    Here are the config options that were passed in:

    #{inspect config}
    """
  end

  defp append_shared_info(body, config) do
    body
    |> Keyword.put(:Action, "SingleSendMail")
    |> Keyword.put(:Format, "JSON")
    |> Keyword.put(:Version, config.version)
    |> Keyword.put(:AccessKeyId, config.access_key_id)
    |> Keyword.put(:SignatureMethod, "HMAC-SHA1")
    |> Keyword.put(:SignatureVersion, "1.0")
    |> Keyword.put(:SignatureNonce, gen_nonce())
    |> Keyword.put(:Timestamp, DateTime.utc_now() |> DateTime.to_iso8601())
    |> Keyword.put(:RegionId, config.region_id)
  end

  # Sign logic from the official PHP SDK:
  # aliyun-php-sdk-core/RpcAcsRequest.php
  defp sign(req, config) do
    signature =
      req
      |> Enum.sort()
      |> Enum.map(fn ({key, item}) -> "#{percent_encode(key)}=#{percent_encode(item)}" end)
      |> Enum.join("&")

    signature = "POST" <> "&%2F&" <> percent_encode(signature)

    signature =
      :sha
      |> :crypto.hmac(config.access_key_secret <> "&", signature)
      |> Base.encode64()

    req
    |> Keyword.put_new(:Signature, signature)
  end

  defp percent_encode(str) when is_binary(str) do
    str
    |> URI.encode_www_form
    |> String.replace("+", "%20")
    |> String.replace("*", "%2A")
    |> String.replace("%7E", "~")
  end
  defp percent_encode(value) do
    value
    |> to_string()
    |> percent_encode()
  end

  defp gen_nonce do
    :crypto.strong_rand_bytes(24)
    |> :base64.encode()
  end

  defp to_aliyun_body(%Email{} = email, config) do
    email
    |> Map.from_struct
    |> put_subject(email)
    |> put_from(email)
    |> put_to(email)
    |> put_html_body(email)
    |> put_text_body(email)
    |> Map.put(:AddressType, config.address_type)
    |> Map.put(:ReplyToAddress, config.reply_to_address)
    |> filter_non_aliyun_dm_fields()
  end

  defp put_subject(body, %Email{subject: subject}) do
    body
    |> Map.put(:Subject, subject)
  end

  defp put_from(body, %Email{from: from}) do
    case from do
      {nil, email} ->
        body
        |> Map.put(:AccountName, email)
      {name, email} ->
        body
        |> Map.put(:FromAlias, name)
        |> Map.put(:AccountName, email)
    end
  end

  defp put_to(body, %Email{to: to}) do
    email = do_transform_email(to)

    body
    |> Map.put(:ToAddress, email)
  end

  defp do_transform_email(list) when is_list(list) do
    list
    |> Enum.map(&do_transform_email/1)
    |> Enum.join(",")
  end
  defp do_transform_email({_name, email}) do
    # name is not supported
    email
  end

  defp put_html_body(body, %Email{html_body: html_body}), do: Map.put(body, :HtmlBody, html_body)

  defp put_text_body(body, %Email{text_body: text_body}), do: Map.put(body, :TextBody, text_body)

  defp filter_non_aliyun_dm_fields(map) do
    Enum.filter(map, fn({key, value}) ->
      (key in @aliyun_dm_fields) && !(value in [nil, "", []])
    end)
  end
end
