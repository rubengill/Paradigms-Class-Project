defmodule TermProjectWeb.AuthHtml do
  use TermProjectWeb, :html

  import TermProjectWeb.ErrorHelpers

  use PhoenixHTMLHelpers

  embed_templates "page_html/*"
end
