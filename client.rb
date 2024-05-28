class Client
  extend Forwardable

  def_delegators :client, :call_function

  def initialize
    @client = Neovim.attach_unix(ARGV[0])
  rescue Errno::ENOENT
    instances = `ls ${XDG_RUNTIME_DIR:-${TMPDIR}nvim.${USER}}/*/nvim.*.0`
    puts "Can't find that instance. Try one of these instead:\n\n#{instances}\n"
    exit 1
  end

  def pmenu_background
    @pmenu_background ||= color_to_rgb(
      call_function("nvim_get_hl_by_name", ["Pmenu", true])["background"]
    )
  end

  def pmenu_foreground
    @pmenu_foreground ||= color_to_rgb(
      call_function("nvim_get_hl_by_name", ["Pmenu", true])["foreground"]
    )
  end

  def pmenu_selected_background
    @pmenu_selected_background ||= color_to_rgb(
      call_function("nvim_get_hl_by_name", ["PmenuSel", true])["background"]
    )
  end

  def pmenu_selected_foreground
    @pmenu_selected_foreground ||= color_to_rgb(
      call_function("nvim_get_hl_by_name", ["PmenuSel", true])["foreground"]
    )
  end

  private

  attr_reader :client

  def color_to_rgb(color)
    hex = format("%06x", color)
    r = hex[0..1].hex
    g = hex[2..3].hex
    b = hex[4..5].hex
    [r, g, b]
  end
end
