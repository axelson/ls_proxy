defmodule LsProxy.Requests.Initialize do
  defmodule SaveOptions do
    use Ecto.Schema
    import Ecto.Changeset

    embedded_schema do
      field(:includeText, :boolean)
    end

    def changeset(_, params) do
      %__MODULE__{}
      |> cast(params, [:includeText])
      |> validate_required([])
    end
  end

  defmodule TextDocumentSyncCapabilities do
    use Ecto.Schema
    import Ecto.Changeset

    embedded_schema do
      field(:openClose, :boolean)
      # Maybe not quite correct
      field(:change, :integer)
      field(:willSave, :boolean)
      field(:willSaveWaitUntil, :boolean)
      embeds_one(:save, LsProxy.Requests.Initialize.SaveOptions)
    end

    def changeset(_, params) do
      %__MODULE__{}
      |> cast(params, [:openClose, :change, :willSave, :willSaveWaitUntil])
      |> cast_embed(:save)
      |> validate_required([])
    end
  end

  def validate_capabilities(capabilities) when is_map(capabilities) do
    case capabilities["textDocumentSync"] do
      number when is_number(number) ->
        :ok

      text_document_sync_options when is_map(text_document_sync_options) ->
        case TextDocumentSyncCapabilities.changeset(nil, text_document_sync_options) do
          %{valid?: true} ->
            :ok

          changeset ->
            {:error, print_errors(changeset, "TextDocumentSyncCapabilities")}
        end
    end
  end

  defp print_errors(%Ecto.Changeset{} = changeset, prefix) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
    |> Enum.map(fn {key, messages} ->
      "#{prefix}.#{key} #{Enum.join(messages, " and ")}"
    end)
    |> Enum.join("\n")
  end
end
