defmodule LsppWeb.LogMessageView do
  use LsppWebWeb, :view

  alias LsProxy.MessageRecord

  def render_message(message_record)

  def render_message(%MessageRecord{} = message_record) do
    render_message_contents(message_record.message.content)
  end

  def render_full(other) do
    ~E"""
    <pre><code>
    <%= inspect(other, pretty: true) %>
    </code></pre>
    """
  end

  def render_message_contents(%{"method" => "window/logMessage"} = message) do
    %{"params" => %{"message" => log_message}} = message

    ~E"""
    <pre class="word-wrap log-message"><%= log_message %></pre>
    """
  end
end
