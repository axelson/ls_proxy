defmodule LsppWeb.MessagesView do
  use LsppWebWeb, :view

  def render_message(%LsProxy.MessageRecord{} = message_record, true) do
    ~E"""
    <div>
    <a phx-click="collapse:<%= message_record.id %>">collapse</a>
    </div>
    <%= render_full(message_record.message.content) %>
    """
  end

  def render_message(%LsProxy.MessageRecord{} = message_record, expanded) do
    ~E"""
    <div>
      <a phx-click="expand:<%= message_record.id %>">expand</a>
    </div>
    <%= render_message(message_record.message.content) %>
    """
  end

  def render_message(message) when is_binary(message) do
    ~E"""
    <pre><code>
    <%= Phoenix.HTML.Format.text_to_html(message) %>
    </code></pre>
    """
  end

  def render_message(%{"method" => "window/logMessage"} = message) do
    %{"params" => %{"message" => log_message}} = message
    # IO.puts "Log: #{log_message}"
    ~E"""
    <div>
    Log: <%= Utils.truncate(log_message, 100) %>
    </div>
    <br>
    """
  end

  def render_message(%{"method" => "textDocument/hover", "id" => id}) do
    ~E"""
    textDocument/hover id: <%= id %>
    """
  end

  def render_message(%{"method" => "$/cancelRequest", "params" => params}) do
    %{"id" => id} = params

    ~E"""
    $/cancelRequest id: <%= id %>
    """
  end

  # def render_message(%{"method" => method, "id" => id}) do
  #   ~E"""
  #   method: <%= method %>
  #   id: <%= id %>
  #   """
  # end

  def render_message(%{"id" => id, "result" => %{"contents" => []}}) do
    ~E"<b><%= id %></b> result is empty"
  end

  def render_message(%{"id" => id, "result" => %{"contents" => contents}}) when is_binary(contents) do
    ~E"""
    <b><%= id %></b> result: <%= Utils.truncate(contents, 100) %>
    """
  end

  # def render_message(%{"result" => %{"range" => %{"start" => start_range, "end" => end_range}}}) do
  #   ~E"""
  #   <%= inspect(start_range) %> to <%= inspect(end_range) %>
  #   """
  # end

  def render_message(other) do
    render_full(other)
  end

  def render_full(other) do
    ~E"""
    <pre><code>
    <%= inspect(other, pretty: true) %>
    </code></pre>
    """
  end

end
