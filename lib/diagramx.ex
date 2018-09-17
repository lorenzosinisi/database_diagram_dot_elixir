defmodule Diagramx do
  @moduledoc """
  Documentation for Diagramx.

  Diagramx.CLI.main(nil)
  """
  defmodule CLI do
    def main(args) do
      alias Graphvix.Graph
      database_name = Keyword.get(args, :database_name, "")

      link = DBSchema.Postgres.connect(database_name)
      tables = DBSchema.Postgres.get_tables(link)
      graph = Graph.new()

      references =
        Enum.map(tables, fn table ->
          table_to_camel_case(table, link)
          |> columns_to_string()
          |> merge_table_to_columns()
        end)
        |> Enum.map(fn %{name: name, columns: columns, ref: ref} ->
          {graph, id} = Graph.add_vertex(graph, columns, shape: "record")
          %{name: name, id: id, columns: columns, graph: graph, ref: ref}
        end)

      Enum.map(references, fn %{name: name, id: id, columns: columns, graph: graph, ref: ref} ->
        %{foreign_table: foreign_table} = ref
        foreign_table_name = foreign_table || ""

        foreign_table =
          Enum.find(references, fn %{name: name} ->
            Macro.camelize(name) == Macro.camelize(foreign_table_name)
          end)

        if foreign_table do
          Graph.add_edge(graph, id, Map.get(foreign_table, :id), color: "green")
        end
      end)

      Graph.write(graph, database_name)
    end

    def table_to_camel_case(table, link) do
      %{table: Macro.camelize(table.name), columns: DBSchema.Postgres.get_columns(link, table)}
    end

    def columns_to_string(table = %{columns: columns}) do
      concatenate = fn x, acc -> acc <> "#{Map.get(x, :name)}\\l" end
      new_columns = columns |> Enum.reduce("", concatenate)

      references = fn x, acc ->
        foreign_table = Map.get(x, :foreign_table)
        table_name = Map.get(x, :name)
        %{foreign_table: foreign_table, table_name: table_name}
      end

      new_references = Enum.reduce(columns, [], references)

      %{table | columns: new_columns <> "}"} |> Map.put(:ref, new_references)
    end

    def merge_table_to_columns(acc = %{table: table, columns: columns, ref: ref}) do
      %{name: table, columns: "{\\" <> table <> "|" <> columns, ref: ref}
    end

    # Diagramx.CLI.main(nil)
  end
end
