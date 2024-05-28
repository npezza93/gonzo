class Completions
  extend Forwardable

  def_delegators :client, :call_function

  NONE   = -1
  OFFSET = 1

  def initialize(input)
    @input = input
    @selected = NONE
  end

  def render
    print(choices.map.with_index do |choice, index|
      choice.render(column: input.current_word_column, padding:,
                    selected: index == selected)
    end[initial_drawn_choice, max].join("\r\n"))
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

  def max = [TTY::Screen.rows - 2, 5].min

  def selection
    choices[selected]
  end

  attr_accessor :selected
  attr_reader :input

  private

  def choices
    return [] if input.user.empty?

    @choices ||= {}
    @choices[input.user] ||= call_function(
      "getcompletion", [input.user, "cmdline"]
    ).dup.map.with_index { |choice, i| Choice.new(choice, i) }
  end

  def initial_drawn_choice
    at_end = selected + OFFSET + 1

    if none_selected? || (at_end - 1 < max) then 0
    else
      [at_end, choices.size].min - max
    end
  end

  def client = App.client
  def padding = choices.map(&:size).max
end
