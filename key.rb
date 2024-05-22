class Key
  def initialize(event)
    @event = event
  end

  def kind # rubocop:disable Metrics/MethodLength
    if left_word? then :left_word
    elsif right_word? then :right_word
    elsif backspace_word? then :backspace_word
    elsif delete_word? then :delete_word
    elsif backspace_line? then :backspace_line
    elsif regular_char? then :regular_char
    else
      :unkown
    end
  end

  def left_word?
    ignore? && !ctrl? && !meta? && !shift? && value == "\eb"
  end

  def right_word?
    ignore? && !ctrl? && !meta? && !shift? && value == "\ef"
  end

  def backspace_word?
    ignore? && !ctrl? && !meta? && !shift? && value == "\e\u007F"
  end

  def delete_word?
    ignore? && !ctrl? && !meta? && !shift? && value == "\ed"
  end

  def backspace_line?
    ignore? && !ctrl? && !meta? && !shift? && value == "\ew"
  end

  def regular_char?
    (%i(alpha num space).include?(name) || (!ctrl? && !meta? && ignore?)) &&
      value != "\e[1;3A" && value != "\e[1;3B"
  end

  private

  attr_reader :event

  def ctrl?   = event.key.ctrl
  def meta?   = event.key.meta
  def shift?  = event.key.shift
  def name    = event.key.name
  def ignore? = event.key.name == :ignore
  def value   = event.value
end
