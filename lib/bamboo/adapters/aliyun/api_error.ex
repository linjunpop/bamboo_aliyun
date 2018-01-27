defmodule Bamboo.AliyunAdapter.ApiError do
  defexception [:message]

  def raise_api_error(message), do: raise(__MODULE__, message: message)

  def raise_api_error(service_name, response, params, extra_message \\ "") do
    message = """
    There was a problem sending the email through the #{service_name} API.
    Here is the response:
    #{inspect(response, limit: :infinity)}
    Here are the params we sent:
    #{inspect(params, limit: :infinity)}
    """

    message =
      case extra_message do
        "" -> message
        em -> message <> "\n#{em}\n"
      end

    raise(__MODULE__, message: message)
  end
end
