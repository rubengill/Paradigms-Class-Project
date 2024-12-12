defmodule TermProjectWeb.ErrorHelpers do
  use PhoenixHTMLHelpers
  # use Phoenix.HTML

  @doc """
  Generates tag for inlined form input errors.
  """
  def error_tag(form, field) do
    IO.puts("enter func call without opts")
    # IO.inspect(form.errors, label: "form.errors")
    IO.inspect(field, label: "field")
    IO.inspect(form, label: "opts")
    Enum.map(Keyword.get_values(form.errors, field), fn {msg, opts} ->
      translated_msg = if opts[:count],
      do: Gettext.dngettext(TermProjectWeb.Gettext, "errors" , msg, msg, opts[:count], opts), #don't misspell stuff
    else: Gettext.dgettext(TermProjectWeb.Gettext, msg, msg, opts)
      # content_tag(:span, "Somethign went wrong", class: "error")
    end)
  end


  def error_tag(form, field, opts) do
    IO.inspect(form.errors, label: "form.errors")
    IO.inspect(field, label: "field")
    IO.inspect(opts, label: "opts")
    IO.puts("enter function with opts")
    Enum.map(Keyword.get_values(form.errors, field), fn {msg, opts} ->
      translated_msg = if opts[:count], do: Gettext.dngettext(TermProjectWeb.Gettext, msg, msg, opts[:count], opts), else: Gettext.dgettext(TermProjectWeb.Gettext, "errors", msg, opts)
      content_tag(:span, translated_msg, class: "error")
    end)
  end

end
