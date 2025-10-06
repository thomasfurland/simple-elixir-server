defmodule SimpleElixirServer.Runs do
  @moduledoc """
  The Runs context.
  """

  import Ecto.Query, warn: false
  alias SimpleElixirServer.Repo
  alias SimpleElixirServer.Runs.Run

  @doc """
  Creates a run.

  ## Examples

      iex> create(%{user_id: 1, title: "Test Run"})
      {:ok, %Run{}}

      iex> create(%{})
      {:error, %Ecto.Changeset{}}

  """
  def create(attrs) do
    %Run{}
    |> Run.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Finds a run by id with preloaded user.

  ## Examples

      iex> find(123)
      {:ok, %Run{}}

      iex> find(456)
      {:error, :not_found}

  """
  def find(id) do
    case Repo.get(Run, id) do
      nil -> {:error, :not_found}
      run -> {:ok, Repo.preload(run, :user)}
    end
  end

  @doc """
  Finds all runs with optional filters and preloaded users.

  ## Examples

      iex> find_all()
      {:ok, [%Run{}, ...]}

      iex> find_all(%{user_id: 1})
      {:ok, [%Run{}, ...]}

  """
  def find_all(filters \\ %{}) do
    query = from r in Run

    query =
      Enum.reduce(filters, query, fn
        {:user_id, user_id}, query ->
          from r in query, where: r.user_id == ^user_id

        _, query ->
          query
      end)

    runs =
      query
      |> Repo.all()
      |> Repo.preload(:user)

    {:ok, runs}
  end

  @doc """
  Updates a run. The user_id field is immutable and cannot be changed.

  ## Examples

      iex> update(run, %{title: "New Title"})
      {:ok, %Run{}}

      iex> update(run, %{title: nil})
      {:ok, %Run{}}

  """
  def update(%Run{} = run, attrs) do
    attrs = Map.delete(attrs, :user_id)

    run
    |> Run.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a run.

  ## Examples

      iex> delete(run)
      {:ok, %Run{}}

      iex> delete(invalid_run)
      {:error, %Ecto.Changeset{}}

  """
  def delete(%Run{} = run) do
    Repo.delete(run)
  end
end
