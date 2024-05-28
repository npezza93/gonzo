class Input
  def initialize
    @user = ""
    @proposed = ""
    @position = 0
  end

  def print_final
    puts user unless user.nil?
  end

  def render
    print("❯ #{current_output} #{cursor_column}")
  end

  def backspace
    return if user.empty?

    self.user = user[0...-1]
    self.position -= 1
  end

  def ctrl_d
    return unless position != user.size

    user.slice!(position)
  end

  def ctrl_u
    self.user = ""
  end

  def left
    return if position.zero?

    self.position -= 1
    print cursor.backward(1)
  end

  def left_word
    self.position = words.reverse.find { |offset| offset < position }.to_i
  end

  def right
    return unless position < user.size

    self.position += 1
    print cursor.forward(1)
  end

  def right_word
    self.position = words.find { |offset| offset > position } || user.size
  end

  def backspace_word
    new_position = words.reverse.find { |offset| offset < position }.to_i
    user.slice!(new_position..position)
    self.position = new_position
  end

  def delete_word
    new_position = words.find { |offset| offset > position } || user.size
    user.slice!(position...new_position)
  end

  def backspace_line
    user.slice!(0...position)
    self.position = 0
  end

  def regular_char(character)
    user << character
    self.position += 1
  end

  def rollback
    self.proposed = ""
    self.position = user.size
  end

  def commit
    self.user = user_with_proposed
    self.proposed = ""
    self.position = user.size
  end

  def current_word_column
    if user.end_with?(" ") then position
    else
      user.split(/(?<=\s)/).tap(&:pop).join.size
    end + 3
  end

  attr_accessor :user, :proposed

  private

  attr_accessor :position

  def cursor
    @cursor ||= TTY::Cursor
  end

  def words
    user.to_enum(:scan, /(\b|_)\w/).map do
      Regexp.last_match.offset(0)[0]
    end
  end

  def current_output
    if proposed.to_s.empty?
      user
    else
      user_with_proposed
    end
  end

  def user_with_proposed
    split_words = user.split(/(?<=\s)/)

    if user.end_with?(" ") then split_words.push(proposed)
    else
      split_words[split_words.size - 1] = proposed
      split_words
    end.join(" ").gsub(/[[:space:]]+/, " ")
  end

  def cursor_column
    if proposed.to_s.empty?
      cursor.column(3 + position)
    else
      cursor.column(3 + current_output.size)
    end
  end
end
