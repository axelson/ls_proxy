defmodule LsppWebWeb.MessagesLive do
  use Phoenix.LiveView

  def render(assigns) do
    LsppWeb.MessagesView.render("messages.html", assigns)
  end

  def mount(_params, _session, socket) do
    if connected?(socket) do
      LsProxy.ProxyState.register_listener()
    end

    socket =
      socket
      |> assign(:message_records, [])
      |> assign(:expanded, %{})
      |> assign(:formatted, %{})
      |> assign(:query, nil)
      |> assign(:requests, %{})
      |> assign(:filtered_requests, nil)
      |> update_messages()
      |> add_bar_chart_data()

    {:ok, socket}
  end

  def plot_response_times(%Contex.Dataset{data: []}), do: nil

  def plot_response_times(test_data) do
    plot_content =
      Contex.BarChart.new(test_data)
      |> Contex.BarChart.set_val_col_names(["Series 1"])
      |> Contex.BarChart.type(:stacked)
      |> Contex.BarChart.data_labels(true)
      |> Contex.BarChart.orientation(:vertical)
      |> Contex.BarChart.colours(LsppWebWeb.BarchartHelpers.lookup_colours("themed"))

    plot =
      Contex.Plot.new(300, 200, plot_content)
      |> Contex.Plot.titles("Response Times", nil)
      |> Contex.Plot.plot_options(%{})

    Contex.Plot.to_svg(plot)
  end

  def handle_info({:update_messages}, socket) do
    socket =
      socket
      |> update_messages()
      |> add_bar_chart_data()

    {:noreply, socket}
  end

  def handle_event("reset", _, socket) do
    LsProxy.ProxyState.clear()
    {:noreply, socket}
  end

  def handle_event("filter_requests", %{"q" => ""}, socket) do
    socket = assign(socket, filtered_requests: nil)
    {:noreply, socket}
  end

  def handle_event("filter_requests", %{"q" => query}, socket) when byte_size(query) <= 1000 do
    filtered =
      socket.assigns.requests
      |> Enum.filter(fn req_resp ->
        case LsProxy.MessageRecord.method(req_resp.request) do
          nil -> false
          method -> String.contains?(String.downcase(method), String.downcase(query))
        end
      end)

    socket = assign(socket, filtered_requests: filtered)

    {:noreply, socket}
  end

  def handle_event("expand:" <> id, _, socket) do
    id = String.to_integer(id)
    %{expanded: expanded} = socket.assigns
    expanded = Map.put(expanded, id, true)

    socket =
      socket
      |> assign(:expanded, expanded)

    {:noreply, socket}
  end

  def handle_event("collapse:" <> id, _, socket) do
    id = String.to_integer(id)
    %{expanded: expanded} = socket.assigns
    expanded = Map.put(expanded, id, false)

    socket =
      socket
      |> assign(:expanded, expanded)

    {:noreply, socket}
  end

  def handle_event("expand-formatted:" <> id, _, socket) do
    id = String.to_integer(id)
    %{formatted: formatted} = socket.assigns
    formatted = Map.put(formatted, id, true)

    socket =
      socket
      |> assign(:formatted, formatted)

    {:noreply, socket}
  end

  def handle_event("collapse-formatted:" <> id, _, socket) do
    id = String.to_integer(id)
    %{formatted: formatted} = socket.assigns
    formatted = Map.put(formatted, id, false)

    socket =
      socket
      |> assign(:formatted, formatted)

    {:noreply, socket}
  end

  defp update_messages(socket) do
    socket
    |> update(:message_records, fn _ ->
      LsProxy.ProxyState.messages()
      |> Enum.reverse()
    end)
    |> update_requests()
  end

  defp update_requests(socket) do
    %{message_records: message_records} = socket.assigns

    requests =
      process(message_records)
      |> Enum.sort_by(fn {id, _} -> id end)
      |> Enum.reverse()
      |> Enum.map(fn {_id, req_resp} -> req_resp end)

    socket
    |> assign(:requests, requests)
  end

  defp process(message_records) do
    message_records
    |> Enum.reduce(%{}, fn
      %{lsp_id: nil}, requests ->
        requests

      %{lsp_id: lsp_id} = message_record, requests ->
        {:ok, initial} = LsProxy.RequestResponse.new(message_record)

        Map.update(requests, lsp_id, initial, fn existing ->
          {:ok, req_resp} = LsProxy.RequestResponse.add(existing, message_record)
          req_resp
        end)
    end)
  end

  defp add_bar_chart_data(socket) do
    requests =
      socket.assigns.requests
      |> Enum.take(10)

    data =
      requests
      |> Enum.filter(&LsProxy.RequestResponse.complete?/1)
      |> Enum.map(&to_contex_data/1)

    dataset = Contex.Dataset.new(data, ["Category", "Series 1"])

    assign(socket, test_data: dataset)
  end

  defp to_contex_data(%LsProxy.RequestResponse{} = request_response) do
    req = request_response.request
    resp = request_response.response

    name =
      case LsProxy.Protocol.Message.method(req.message) do
        nil -> "Request #{request_response.id}"
        method -> "#{method}:#{request_response.id}"
      end

    duration = NaiveDateTime.diff(resp.timestamp, req.timestamp, :millisecond)

    # Force duration to a float until https://github.com/mindok/contex/pull/4 is fixed
    duration = duration / 1

    [name, duration]
  end
end
