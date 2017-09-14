# Bamboo.AliyunAdapter

An [Aliyun](https://www.aliyun.com/product/directmail?spm=5176.8142029.388261.228.dKDNYN) adapter for the [Bamboo](https://github.com/thoughtbot/bamboo).

## Installation

The package can be installed
by adding `bamboo_aliyun` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:bamboo_aliyun, "~> 0.1.0"}]
end
```

In `config/config.exs`, or `config.prod.exs`, etc.

```elixir
config :my_app, MyApp.Mailer,
  adapter: Bamboo.AliyunAdapter,
  api_user: "my_api_user",
  api_key: "my_api_key"
```

## Usage

### Send standard email

```elixir
import Bamboo.Email

email =
  new_email()
  |> from({"Bender", "notify@send1.example.com"})
  |> to(user)
  |> subject("Welcome!")
  |> text_body("Welcome to the app")
  |> html_body("<strong>Welcome to the app</strong>")
```

## Docs

[https://hexdocs.pm/bamboo_aliyun](https://hexdocs.pm/bamboo_aliyun).

