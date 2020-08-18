defmodule AffableWeb.IconHelpers do
  use Phoenix.HTML

  def arrow_down do
    raw("""
    <svg viewBox="0 0 24 24" class="feather feather-arrow-down-circle">
      <circle cx="12" cy="12" r="10"></circle>
      <polyline points="8 12 12 16 16 12"></polyline>
      <line x1="12" y1="8" x2="12" y2="16"></line>
    </svg>
    """)
  end

  def arrow_up do
    raw("""
    <svg viewBox="0 0 24 24" class="feather feather-arrow-up-circle">
      <circle cx="12" cy="12" r="10"></circle>
      <polyline points="16 12 12 8 8 12"></polyline>
      <line x1="12" y1="16" x2="12" y2="8"></line>
    </svg>
    """)
  end
end
