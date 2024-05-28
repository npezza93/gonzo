class Choice < SimpleDelegator
  extend Forwardable

  def_delegators :client, :pmenu_selected_background,
                 :pmenu_selected_foreground, :pmenu_background,
                 :pmenu_foreground

  def initialize(string, index)
    super(string)
    @index = index
  end

  def render(column:, padding:, selected:)
    text = ljust(padding, " ")

    if selected
      colorize(text, *pmenu_selected_background, *pmenu_selected_foreground)
    else
      colorize(text, *pmenu_background, *pmenu_foreground)
    end.prepend(TTY::Cursor.column(column))
  end

  private

  attr_reader :index

  def colorize(text, bg_r, bg_g, bg_b, fg_r, fg_g, fg_b)
    bg_color_code, reset_code = "\e[48;2;#{bg_r};#{bg_g};#{bg_b}m", "\e[0m"
    text_color_code = "\e[38;2;#{fg_r};#{fg_g};#{fg_b}m"
    "#{bg_color_code}#{text_color_code}#{text}#{reset_code}"
  end

  def client
    App.client
  end
end
