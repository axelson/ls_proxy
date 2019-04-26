defmodule LsppWeb.MessagesView do
  use LsppWebWeb, :view

  def render_message(%LsProxy.Protocol.Message{content: content}) do
    render_message(content)
  end

  def render_message(message) when is_binary(message) do
    ~E"""
    <pre><code>
    <%= Phoenix.HTML.Format.text_to_html(message) %>
    </code></pre>
    """
  end

  def render_message(%{"method" => method}) do
    ~E"""
    method: <%= method %>
    """
  end

  def render_message(%{"result" => %{"range" => %{"start" => start_range, "end" => end_range}}}) do
    ~E"""
    <%= inspect(start_range) %> to <%= inspect(end_range) %>
    """
  end

  def render_message(other) do
    ~E"""
    <pre><code>
      <%= inspect(other, pretty: true) %>
    </code></pre>
    """
  end
end
