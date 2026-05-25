# Bot Army Schema Template

Define NATS message contracts for your Bot Army ecosystem.

This template helps you create JSON Schemas for NATS subjects, validate payloads, and document your bot's message types.

## Quick Start

```bash
# Clone this template
git clone https://github.com/ergon-automation-labs/ergon-schema-template my-schemas
cd my-schemas

# Setup
./setup_new_schema.sh

# Define your schemas in lib/schemas/*.schema.json
# Validate with Elixir module or standalone
```

## What's Included

- **JSON Schema validator** — Validate NATS payloads against schemas
- **Example schema** — Reference implementation (`example_event.schema.json`)
- **Validator module** — Elixir code to validate messages
- **Setup script** — Customize for your bot/service

## Creating Schemas

### 1. Design the Schema

Create a JSON Schema file in `lib/schemas/`:

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://ergon-automation-labs.github.io/schemas/mybot/action.schema.json",
  "title": "My Action Request",
  "description": "Request to perform an action",
  "type": "object",
  "properties": {
    "id": { "type": "string" },
    "action": { "type": "string" },
    "params": { "type": "object" }
  },
  "required": ["id", "action"]
}
```

### 2. Use in Your Bot

In your bot's handler:

```elixir
defmodule MyBot.Handlers.ActionHandler do
  def handle_request(msg) do
    case {{SCHEMA_APP_NAME_CAMEL}}.Validator.validate("my_action", msg.body) do
      {:ok, data} ->
        # Process valid request
        response = process_action(data)
        reply(msg, response)

      {:error, reason} ->
        # Return validation error
        reply(msg, BotArmyRuntime.NATS.Reply.error(reason, :invalid_schema))
    end
  end
end
```

### 3. Document the Subject

Create a `README.md` or `SUBJECTS.md`:

```markdown
## mybot.action

**Type:** Request/Reply

**Schema:** `lib/schemas/my_action.schema.json`

**Example Request:**
```json
{
  "id": "uuid-here",
  "action": "do_something",
  "params": { "key": "value" }
}
```

**Example Response:**
```json
{
  "status": "success",
  "result": { ... }
}
```

**Errors:**
- `invalid_schema` — Request doesn't match schema
- `action_failed` — Action failed to execute
```

## Schema Best Practices

1. **Use `$id`** — Fully-qualified schema URI for versioning
2. **Document properties** — Add `description` to every field
3. **Set `required`** — List all required properties
4. **Use enums** — Constrain string values: `"enum": ["created", "updated"]`
5. **Version your schemas** — Use schema URL: `.../mybot/v1/action.schema.json`
6. **Validate early** — Validate in handlers before processing

## Using Standalone

Validate messages without running a bot:

```bash
# Test a schema
mix test

# Validate JSON against schema
mix escript.build
./schema_validator lib/schemas/my_action.schema.json < payload.json
```

## Publishing Schemas

1. **Store in this repo** — Organize by service
2. **Document subjects** — Add to SUBJECTS.md or bot's README
3. **Make repo public** — So others can reference your schemas
4. **Host schemas** — Optional: serve from static host for `$id` URIs

Example hosted schema URL:
```
https://raw.githubusercontent.com/ergon-automation-labs/ergon-mybot-schemas/main/lib/schemas/action.schema.json
```

## Validation in NATS

### Before Publishing

```elixir
# Validate before sending
case MySchemas.Validator.validate_map("my_action", payload) do
  {:ok, _} -> 
    Gnat.pub(conn, "mybot.action", Jason.encode!(payload))
  {:error, reason} ->
    Logger.error("Invalid payload: #{reason}")
end
```

### On Receipt (Handler)

```elixir
def handle_info({:msg, msg}, state) do
  case MySchemas.Validator.validate("my_action", msg.body) do
    {:ok, data} ->
      # Safe to process
      process(data)
    {:error, reason} ->
      Logger.warning("Invalid message: #{reason}")
  end
  {:noreply, state}
end
```

## Examples

See `lib/schemas/example_event.schema.json` for a working example.

## JSON Schema Resources

- [JSON Schema Spec](https://json-schema.org/draft-07/json-schema-core.html)
- [Draft-07 Validator Keywords](https://json-schema.org/draft-07/json-schema-validation.html)
- [Common Patterns](https://json-schema.org/learn/getting-started-step-by-step.html)

## License

Apache 2.0 — Same as Bot Army

---

**Next Steps:**
1. Run `./setup_new_schema.sh` to customize
2. Define your message types in `lib/schemas/`
3. Add this repo as a dependency in your bot: `{:my_schemas, git: "https://github.com/yourorg/my-schemas"}`
4. Validate in handlers using `MySchemas.Validator.validate()`
