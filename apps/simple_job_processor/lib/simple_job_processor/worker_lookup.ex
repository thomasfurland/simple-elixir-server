defmodule SimpleJobProcessor.WorkerLookup do
  def list_queues do
    Application.get_env(:simple_job_processor, Oban, [])
    |> Keyword.get(:queues, [])
    |> Enum.map(fn {queue_name, _limit} -> Atom.to_string(queue_name) end)
  end

  def queue_to_module(queue_name) when is_binary(queue_name) do
    module_name =
      queue_name
      |> String.split("_")
      |> Enum.map(&String.capitalize/1)
      |> Enum.join()

    module = Module.concat([SimpleJobProcessor.Workers, module_name])

    if Code.ensure_loaded?(module) and oban_worker?(module) do
      {:ok, module}
    else
      {:error,
       "Module #{inspect(module)} not found or not an Oban worker. " <>
         "Ensure workers follow the pattern: SimpleJobProcessor.Workers.QueueName"}
    end
  end

  defp oban_worker?(module) do
    :erlang.function_exported(module, :perform, 1)
  end
end
