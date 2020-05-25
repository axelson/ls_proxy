defmodule LsppWebWeb.DashboardLive do
  use Phoenix.LiveView

  defmodule State do
    defstruct message_records: [],
              expanded: %{},
              formatted: %{},
              query: nil,
              requests: %{},
              filtered_requests: [],
              filtered_message_records: [],
              test_data: nil,
              filter: ""
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    if connected?(socket) do
      LsProxy.ProxyState.register_listener()
    end

    socket =
      socket
      |> assign(:state, %State{})
      |> update_messages()
      |> apply_filter()
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

  def tab_config do
    [
      requests: {"Requests", LsppWeb.RequestsTabComponent},
      messages: {"Message List", LsppWeb.MessagesTabComponent},
      logs: {"Logs", LsppWebWeb.LogTabComponent}
    ]
  end

  @impl Phoenix.LiveView
  def handle_info({:update_messages}, socket) do
    socket =
      socket
      |> update_messages()
      |> apply_filter()
      |> add_bar_chart_data()

    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("reset", _, socket) do
    LsProxy.ProxyState.clear()
    {:noreply, socket}
  end

  def handle_event("filter_requests", %{"q" => query}, socket) do
    state = %State{socket.assigns.state | filter: query}
    state = apply_filter(state)

    socket =
      assign(socket, state: state)
      |> add_bar_chart_data()

    {:noreply, socket}
  end

  def handle_event("filter_requests", %{"q" => ""}, socket) do
    state = %State{socket.assigns.state | filtered_requests: :empty}
    {:noreply, assign(socket, state: state)}
  end

  def handle_event("filter_requests", %{"q" => query}, socket) when byte_size(query) <= 1000 do
    state = socket.assigns.state

    filtered =
      state.requests
      |> Enum.filter(fn req_resp ->
        case LsProxy.MessageRecord.method(req_resp.request) do
          nil -> false
          method -> String.contains?(String.downcase(method), String.downcase(query))
        end
      end)

    state = %State{state | filtered_requests: filtered}

    {:noreply, assign(socket, state: state)}
  end

  def handle_event("expand:" <> id, _, socket) do
    id = String.to_integer(id)
    %State{expanded: expanded} = state = socket.assigns.state
    expanded = Map.put(expanded, id, true)

    state = %State{state | expanded: expanded}

    {:noreply, assign(socket, state: state)}
  end

  def handle_event("collapse:" <> id, _, socket) do
    id = String.to_integer(id)
    %State{expanded: expanded} = state = socket.assigns.state
    expanded = Map.put(expanded, id, false)

    state = %State{state | expanded: expanded}

    {:noreply, assign(socket, state: state)}
  end

  def handle_event("expand-formatted:" <> id, _, socket) do
    id = String.to_integer(id)
    %State{formatted: formatted} = state = socket.assigns.state
    formatted = Map.put(formatted, id, true)

    state = %State{state | formatted: formatted}

    {:noreply, assign(socket, state: state)}
  end

  def handle_event("collapse-formatted:" <> id, _, socket) do
    id = String.to_integer(id)
    %State{formatted: formatted} = state = socket.assigns.state
    formatted = Map.put(formatted, id, false)

    state = %State{state | formatted: formatted}

    {:noreply, assign(socket, state: state)}
  end

  defp update_messages(socket) do
    socket
    |> update(:state, fn state ->
      message_records =
        LsProxy.ProxyState.messages()
        |> Enum.reverse()

      %State{state | message_records: message_records}
    end)
    |> update_requests()
  end

  # TODO: Change this to take state instead of socket?
  defp update_requests(socket) do
    %State{message_records: message_records} = state = socket.assigns.state

    requests =
      process(message_records)
      |> Enum.sort_by(fn {id, _} -> id end)
      |> Enum.reverse()
      |> Enum.map(fn {_id, req_resp} -> req_resp end)

    state = %State{state | requests: requests}
    assign(socket, state: state)
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
    state = socket.assigns.state
    requests = Enum.take(state.requests, 10)

    data =
      requests
      |> Enum.filter(&LsProxy.RequestResponse.complete?/1)
      |> Enum.map(&to_contex_data/1)

    dataset = Contex.Dataset.new(data, ["Category", "Series 1"])
    state = %State{state | test_data: dataset}

    assign(socket, state: state)
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

  defp apply_filter(%Phoenix.LiveView.Socket{} = socket) do
    state = apply_filter(socket.assigns.state)
    assign(socket, state: state)
  end

  defp apply_filter(%State{filter: ""} = state) do
    %State{
      state
      | filtered_requests: state.requests,
        filtered_message_records: state.message_records
    }
  end

  defp apply_filter(%State{} = state) do
    %State{message_records: message_records, requests: requests, filter: filter} = state

    filtered_requests =
      requests
      |> Enum.filter(fn req_resp ->
        case LsProxy.MessageRecord.method(req_resp.request) do
          nil -> false
          method -> String.contains?(String.downcase(method), String.downcase(filter))
        end
      end)

    filtered_message_records =
      message_records
      |> Enum.filter(fn message_record ->
        filter_text = LsProxy.MessageRecord.filter_text(message_record)
        String.contains?(String.downcase(filter_text), String.downcase(filter))
      end)

    %State{
      state
      | filtered_requests: filtered_requests,
        filtered_message_records: filtered_message_records
    }
  end
end
