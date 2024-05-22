class Input
  def initialize
    @user = ""
    @position = 0
  end

  def print_final
    puts user unless user.nil?
  end

  def render
    print("❯ #{user} #{cursor.column(3 + position)}")
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

  attr_accessor :user

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
end
