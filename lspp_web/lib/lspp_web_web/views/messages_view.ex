defmodule LsppWeb.MessagesView do
  use LsppWebWeb, :view

  alias LsProxy.MessageRecord

  @doc """
  Render a detailed view of the message
  """
  def render_message(message_record, expanded, formatted, req_by_id, word_wrap)

  def render_message(%MessageRecord{} = message_record, true, formatted, req_by_id, word_wrap) do
    assigns = %{}

    ~H"""
    <%= message_common(message_record, true, formatted, req_by_id, word_wrap) %>
    <div class="text-btn">
    <a phx-click={"collapse:#{message_record.id}"}>collapse</a>
    </div>
    <%= render_full(message_record.message.content) %>
    """
  end

  def render_message(%MessageRecord{} = message_record, expanded, formatted, req_by_id, word_wrap) do
    assigns = %{}

    ~H"""
    <%= message_common(message_record, expanded, formatted, req_by_id, word_wrap) %>
    <div class="text-btn">
      <a phx-click={"expand:#{message_record.id }"}>show full</a>
      <%= if(has_formatting?(message_record.message.content)) do %>
        <%= if formatted do %>
          <a phx-click={"collapse-formatted:#{message_record.id}"}>hide formatted message</a>
        <% else %>
          <a phx-click={"expand-formatted:#{message_record.id}"}>show formatted message</a>
        <% end %>
        <a phx-click="toggle-word-wrap">toggle word wrap</a>
      <% end %>
    </div>
    """
  end

  def message_common(%MessageRecord{} = message_record, expanded, formatted, req_by_id, word_wrap) do
    timestamp_format = if expanded, do: :full, else: :short
    method_name = MessageRecord.method(message_record)
    assigns = %{}

    ~H"""
    <%= render_direction(message_record) %>
    <%= render_timestamp(message_record, timestamp_format) %>
    <div>
      <%= render_message_details(message_record, method_name, formatted: formatted, req_by_id: req_by_id, word_wrap: word_wrap) %>
    </div>
    """
  end

  def render_message_details(%MessageRecord{} = message_record, "textDocument/hover", opts)
      when is_list(opts) do
    content = message_record.message.content
    %{"id" => id} = content
    assigns = %{}

    case content["params"] do
      %{
        "textDocument" => %{"uri" => uri_str},
        "position" => %{"line" => line, "character" => character}
      } ->
        ~H"""
        textDocument/hover <code><%= uri_str %>:<%= line %></code>(char <%= character %>)
        <div class="code"><%= message_record.extra_info %></div>
        <%= render_id(id) %>
        """

      _ ->
        ~H"""
        textDocument/hover
        """
    end
  end

  def render_message_details(%MessageRecord{} = message_record, "textDocument/completion", _opts) do
    content = message_record.message.content
    %{"id" => id} = content
    assigns = %{}

    case content["params"] do
      %{
        "textDocument" => %{"uri" => uri_str},
        "position" => %{"line" => line, "character" => character}
      } ->
        ~H"""
        textDocument/completion <code><%= uri_str %>:<%= line %></code>(char <%= character %>)
        <div class="code"><%= message_record.extra_info %></div>
        <%= render_id(id) %>
        """

      _ ->
        ~H"""
        textDocument/completion
        """
    end
  end

  def render_message_details(%MessageRecord{} = message_record, _method, opts)
      when is_list(opts) do
    assigns = %{}

    ~H"""
    <%= render_message_contents(message_record.message.content, opts) %>
    """
  end

  def render_message_contents(%{"method" => "initialize"}, _opts) do
    assigns = %{}

    ~H"""
    initialize
    """
  end

  def render_message_contents(message, _opts) when is_binary(message) do
    assigns = %{}

    ~H"""
    <pre><code>
    <%= Phoenix.HTML.Format.text_to_html(message) %>
    </code></pre>
    """
  end

  def render_message_contents(%{"method" => "window/logMessage"} = message, opts) do
    formatted = Keyword.get(opts, :formatted)
    word_wrap = Keyword.get(opts, :word_wrap)
    word_wrap_class = if word_wrap, do: "word-wrap", else: ""
    assigns = %{}

    %{"params" => %{"message" => log_message}} = message

    if formatted do
      ~H"""
      <div>Log: <%= Utils.truncate(log_message, 100) %></div>
      <pre class={"#{word_wrap_class}"}>
        <%= log_message %>
      </pre>
      """
    else
      ~H"""
      <div>Log: <%= Utils.truncate(log_message, 100) %></div>
      """
    end
  end

  def render_message_contents(
        %{"method" => "textDocument/hover", "id" => id} = message_record,
        _opts
      ) do
    assigns = %{}

    case message_record["params"] do
      %{
        "textDocument" => %{"uri" => uri_str},
        "position" => %{"line" => line, "character" => character}
      } ->
        ~H"""
        textDocument/hover <code><%= uri_str %>:<%= line %></code>(char <%= character %>)
        <%= render_id(id) %>
        """

      _ ->
        ~H"""
        textDocument/hover
        """
    end
  end

  def render_message_contents(%{"method" => "$/cancelRequest", "params" => params}, _opts) do
    %{"id" => id} = params
    assigns = %{}

    ~H"""
    $/cancelRequest id: <%= id %>
    """
  end

  def render_message_contents(
        %{"method" => "textDocument/codeLens", "id" => id} = message_record,
        _opts
      ) do
    uri_str = get_in(message_record, ["params", "textDocument", "uri"])
    assigns = %{}

    ~H"""
    textDocument/codeLens: <code><%= uri_str %></code>
    <div>
      id: <b><%= id %></b>
    </div>
    """
  end

  def render_message_contents(%{"method" => "textDocument/didOpen"} = message_record, _opts) do
    assigns = %{}

    case message_record["params"]["textDocument"] do
      %{"text" => text, "uri" => uri_str} ->
        ~H"""
        textDocument/didOpen: <code><%= uri_str %></code>
        <div>
          <%= Utils.truncate(text, 80) %>
        </div>
        """

      _ ->
        "textDocument/didOpen"
    end
  end

  def render_message_contents(
        %{"method" => "textDocument/publishDiagnostics"} = message_record,
        _opts
      ) do
    assigns = %{}

    case message_record["params"]["uri"] do
      uri_str when not is_nil(uri_str) ->
        ~H"""
        textDocument/publishDiagnostics: <code><%= uri_str %></code>
        """

      _ ->
        "textDocument/publishDiagnostics"
    end
  end

  def render_message_contents(%{"id" => id, "result" => %{"contents" => []}}, _opts) do
    assigns = %{}

    ~H"""
    Result: empty
    <%= render_id(id) %>
    """
  end

  def render_message_contents(%{"id" => id, "result" => _result} = message, opts) do
    req_by_id = Keyword.get(opts, :req_by_id)

    with request when not is_nil(request) <- Map.get(req_by_id, id),
         method <- LsProxy.MessageRecord.method(request.request) do
      render_result_message(method, message, request, opts)
    else
      _ ->
        render_result_message(nil, message, nil, opts)
    end
  end

  def render_message_contents(%{"error" => error} = message_contents, opts) do
    formatted = Keyword.get(opts, :formatted)
    %{"code" => error_code, "message" => error_message} = error
    assigns = %{}

    error_name =
      case LsProxy.ErrorCodes.error_name(error_code) do
        {:ok, error_name} -> error_name
        _ -> "An Unknown Error"
      end

    ~H"""
    <div><%= error_name %>: <%= Utils.truncate(error_message, 100) %></div>
    <%= if formatted do %>
      <pre><%= error_message %></pre>
    <% end %>
    <%= if message_contents["id"] do %>
      <%= render_id(message_contents["id"]) %>
    <% end %>
    """
  end

  def render_message_contents(other, _opts) do
    render_full(other)
  end

  def render_result_message(method, message, request, opts)

  def render_result_message("textDocument/completion", message, request, _opts)
      when not is_nil(request) do
    assigns = %{}
    %{"id" => id} = message
    items = request.response.message.content["result"]["items"]

    ~H"""
    items:
    <%= for item <- items do %>
      <div>
        - <%= item["label"] %>
      </div>
    <% end %>
    <%= render_id(id) %>
    """
  end

  def render_result_message(_method, message, _request, opts) do
    formatted = Keyword.get(opts, :formatted)

    case message do
      %{"id" => id, "result" => %{"contents" => contents}} ->
        render_result_message_contents(id, contents, formatted)

      _ ->
        render_result_message_default(message)
    end
  end

  def render_result_message_default(%{"id" => id}) do
    assigns = %{}

    ~H"""
    Result (no contents2)
    <%= render_id(id) %>
    """
  end

  # Messages like textDocument/hover typically have contents
  def render_result_message_contents(id, contents_list, formatted) when is_list(contents_list) do
    for contents <- contents_list do
      render_result_message_contents(id, contents, formatted)
    end
  end

  def render_result_message_contents(id, contents, true = _formatted) do
    assigns = %{}

    case Earmark.as_html(contents, %Earmark.Options{smartypants: false}) do
      {:ok, html, []} ->
        ~H"""
        Result: <%= Utils.truncate(contents, 100) %>
        <%= render_id(id) %>
        <%= Phoenix.HTML.raw html %>
        """

      {:error, html, error_messages} ->
        ~H"""
        Result: <%= Utils.truncate(contents, 100) %>
        <%= render_id(id) %>
        Unable to render full contents
        <%= html %>
        <div>
        <%= inspect(error_messages) %>
        </div>
        """
    end
  end

  def render_result_message_contents(id, %{"kind" => "markdown", "value" => value}, formatted) do
    render_result_message_contents(id, value, formatted)
  end

  def render_result_message_contents(id, %{"kind" => "plaintext", "value" => value}, formatted) do
    render_result_message_contents(id, value, formatted)
  end

  # NOTE: This appears to be non-standard
  def render_result_message_contents(id, %{"language" => "rust", "value" => value}, formatted) do
    render_result_message_contents(id, value, formatted)
  end

  def render_result_message_contents(id, contents, _formatted) when is_binary(contents) do
    assigns = %{}

    ~H"""
    Result: <%= Utils.truncate(contents, 100) %>
    <%= render_id(id) %>
    """
  end

  def render_full(other) do
    assigns = %{}

    ~H"""
    <pre><code>
    <%= inspect(other, pretty: true) %>
    </code></pre>
    """
  end

  def render_direction(%MessageRecord{} = message_record) do
    assigns = %{}

    ~H"""
    <span class="direction-arrow" title={direction_tooltip(message_record)}>
      <%= direction_arrow(message_record) %>
    </span>
    """
  end

  def direction_arrow(message_record) do
    case message_record.direction do
      :incoming -> "➡"
      :outgoing -> "⬅"
    end
  end

  def direction_tooltip(message_record) do
    case message_record.direction do
      :incoming -> "Message sent TO server"
      :outgoing -> "Message received FROM server"
    end
  end

  def render_timestamp(%MessageRecord{timestamp: timestamp}, :short) do
    {{_year, _month, _day}, {hour, minute, second}} = NaiveDateTime.to_erl(timestamp)

    [zero_pad(hour), zero_pad(minute), zero_pad(second)]
    |> Enum.join(":")
  end

  def render_timestamp(%MessageRecord{timestamp: timestamp}, :full) do
    NaiveDateTime.to_string(timestamp)
  end

  defp has_formatting?(%{"method" => "window/logMessage"}), do: true

  defp has_formatting?(%{"error" => %{"message" => _message}}), do: true

  defp has_formatting?(%{"result" => %{"contents" => contents}}) when is_binary(contents) do
    true
  end

  defp has_formatting?(_), do: false

  defp zero_pad(number), do: String.pad_leading(to_string(number), 2, "0")

  def render_id(id) do
    assigns = %{}
    ~H"<div>id: <b><%= id %></b></div>"
  end

  # TODO: This call seems to indicate bad call structuring
  defdelegate plot_response_times(data), to: LsppWebWeb.DashboardLive
end
