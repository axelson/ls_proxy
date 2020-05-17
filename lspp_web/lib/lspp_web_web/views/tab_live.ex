defmodule LsppWeb.TabLive do
  @moduledoc """
  A simple tab component

  Example usage:


      <%= live_component(@socket, LsppWeb.TabLive, id: :tab, assigns: assigns, initial_tab: :requests, tabs: tab_config()) %>

  With tab config:

      def tab_config do
        [
          requests: {"Requests", LsppWeb.ReqRespLive},
          messages: {"Message List", LsppWeb.MessageList}
        ]
      end

  Warning: Probably not change-tracking optimized
  """
  use Phoenix.LiveComponent

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    socket = assign(socket, assigns)
    socket = assign(socket, :active_tab, assigns.initial_tab)

    {:ok, socket}
  end

  @impl Phoenix.LiveComponent
  def render(assigns) do
    validate_tab_config!(assigns)

    ~L"""
    <div class="tab-bar">
      <%= render_nav(assigns) %>

      <%= live_component(@socket, component(assigns), @assigns) %>
    </div>
    """
  end

  def render_nav(assigns) do
    ~L"""
    <div class="tab-bar-nav">
      <%= for {key, {name, _}} <- @tabs do %>
        <div
          class="<%= active_class(key, @active_tab) %>"
          phx-target="<%= @myself %>"
          phx-click="focus:<%= key %>">
          <%= name %>
        </div>
      <% end %>
    </div>
    """
  end

  @impl Phoenix.LiveComponent
  def handle_event("focus:" <> focus_target, _params, socket) do
    if focus_target in valid_targets(socket) do
      socket = assign(socket, :active_tab, String.to_existing_atom(focus_target))
      {:noreply, socket}
    else
      raise "Unable to switch to non-existant tab: #{inspect(focus_target)}"
    end
  end

  defp valid_targets(socket) do
    Keyword.keys(socket.assigns.tabs)
    |> Enum.map(&to_string/1)
  end

  defp active_class(key, key), do: "active"
  defp active_class(_, _), do: ""

  def component(assigns) do
    {_name, component} = Keyword.fetch!(assigns.tabs, assigns.active_tab)
    component
  end

  # It's starting to seem worth it to pull in a validation library
  defp validate_tab_config!(assigns) do
    with {:config, {:ok, tab_config}} <- {:config, Map.fetch(assigns, :tabs)},
         {:list, true, _} <- {:list, is_list(tab_config), tab_config} do
      Enum.each(tab_config, fn
        {key, val} ->
          key_valid = match?(key when is_atom(key), key)
          if !key_valid, do: raise("Tab config key is invalid (#{inspect(key)})")
          value_valid = match?({name, component} when is_binary(name) and is_atom(component), val)
          if !value_valid, do: raise("Tab config value is invalid (#{inspect(val)})")
      end)
    else
      {:config, _} ->
        raise "Tab config must be passed with key `:tabs` assigns: #{inspect(assigns)}"

      {:list, false, tab_config} ->
        raise "Tab config must be a list. Got: #{inspect(tab_config)}"
    end
  end
end
