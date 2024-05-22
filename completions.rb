class Completions
  extend Forwardable

  def_delegators :pastel, :inverse

  NONE   = -1
  OFFSET = 1

  def initialize(input)
    @input = input
    @client = Completions::Client.new
    @selected = NONE
  end

  def render
    dupe = choices

    dupe[selected] = inverse(dupe[selected]) unless none_selected?

    print dupe[initial_drawn_choice, max].join("\r\n")
  end

  def tab
    return if choices.empty?

    self.selected = (selected + 1) % choices.size
  end

  def up
    return if choices.empty?

    self.selected = if selected.zero? then choices.size - 1
                    else
                      selected - 1
                    end
  end

  def down
    return if choices.empty?

    self.selected = (selected + 1) % choices.size
  end

  def none_selected?
    selected == NONE
  end

  def unselect!
    self.selected = NONE
  end

  def max
    [TTY::Screen.rows - 2, 5].min
  end

  attr_accessor :selected
  attr_reader :input

  private

  attr_reader :client

  def choices
    client.choices(input.user).dup
  end

  def initial_drawn_choice
    at_end = selected + OFFSET

    if none_selected? || at_end < max then 0
    elsif at_end >= choices.size then choices.size - max - 1
    else
      at_end - max
    end
  end

  def pastel
    @pastel ||= Pastel.new
  end
end
