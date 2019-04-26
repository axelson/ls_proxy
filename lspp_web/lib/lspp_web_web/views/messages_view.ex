defmodule LsppWeb.MessagesView do
  use LsppWebWeb, :view

  def render_message(%LsProxy.Protocol.Message{content: content}) do
    render_message(content)
  end

  def render_message(message) when is_binary(message) do
    Phoenix.HTML.Format.text_to_html(message)
  end

  def render_message(other) do
    ~E"""
    <pre><code>
      <%= inspect(other, pretty: true) %>
    </code></pre>
    """
  end
end
