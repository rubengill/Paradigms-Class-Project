# TermProject

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix

PARADIGMS-CLASS-PROJECT/
├── _build/
├── assets/
│   ├── css/
│   └── js/
├── config/
├── lib/
│   ├── game_app/
│   │   ├── lobby_manager.ex        # GenServer for lobby management
│   │   ├── matchmaker.ex           # GenServer for matchmaking
│   │   └── game_server.ex          # Additional game logic (if needed)
│   └── game_app_web/
│       ├── channels/
│       │   ├── game_channel.ex      # Phoenix Channel for game events
│       │   └── chat_channel.ex      # Phoenix Channel for in-game chat
│       ├── live/
│       │   └── lobby_live.ex       # LiveView for lobby and matchmaking UI
│       └── templates/
│           └── live/
│               └── lobby_live.html.heex # HTML template for lobby UI
├── priv/
├── test/
│   ├── game_app/
│   │   ├── lobby_manager_test.exs   # Tests for lobby management
│   │   ├── matchmaker_test.exs      # Tests for matchmaking
│   └── game_app_web/
│       └── live/
│           └── lobby_live_test.exs  # Tests for LobbyLive LiveView
