defmodule ArgvParser.Help do
  alias ArgvParser.Format
  alias __MODULE__.Formatter

  def help(optimus, command_path, max_width) do
    title = ArgvParser.Title.title(optimus, command_path)
    usage = usage(optimus, command_path)

    {subcommand, _} = ArgvParser.fetch_subcommand(optimus, command_path)
    sections = format_sections(subcommand, max_width)

    title ++ usage ++ sections ++ [""]
  end

  defp usage(optimus, []) do
    List.flatten([
      "Usage:",
      "  #{ArgvParser.Usage.usage(optimus)}",
      "  #{ArgvParser.Usage.version_usage(optimus)}",
      "  #{ArgvParser.Usage.help_usage(optimus)}",
      case optimus.subcommands do
        [] -> []
        _ -> "  #{ArgvParser.Usage.subcomand_help_usage(optimus)}"
      end
    ])
    |> Enum.intersperse("\n")
  end

  defp usage(optimus, subcommand_path) do
    [
      "Usage:",
      "  #{ArgvParser.Usage.usage(optimus, subcommand_path)}"
    ]
    |> Enum.intersperse("\n")
  end

  defp format_sections(command, width) do
    [
      {"Commands:", command.subcommands},
      {"Arguments:", command.args},
      {"Flags:", command.flags},
      {"Options:", command.options}
    ]
    |> Enum.reject(fn {_, formatables} -> is_nil(formatables) || formatables == [] end)
    |> Enum.map(fn {title, formatables} -> format_section({title, formatables}, width) end)
    |> Enum.intersperse("\n")
  end

  defp format_section({title, formatables}, width) do
    title = Formatter.format(title, width)

    contents =
      Enum.map(formatables, fn f ->
        name = Format.format(f)
        help = Format.help(f)
        ["", name, "", help]
      end)

    names = Enum.map(contents, &Enum.at(&1, 1))
    left_padding_width = 2
    name_width = names |> Enum.map(&String.length/1) |> Enum.max()
    sep_padding_width = 2
    help_width = width - left_padding_width - name_width - sep_padding_width
    widths = [left_padding_width, name_width, sep_padding_width, help_width]

    contents =
      Enum.map(contents, fn strings ->
        strings
        |> Enum.zip(widths)
        |> Formatter.format_columns()
      end)

    [title, "\n", contents, "\n"]
  end
end
