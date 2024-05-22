class App
  extend Forwardable

  def_delegators :prompt, :draw, :clear_line, :print_final_input, :initial_draw

  def self.run
    new.run
  end

  def initialize
    @done = false
    @quit = false
    @reader = TTY::Reader.new(interrupt: :noop)
    @prompt = Prompt.new(self)
  end

  def run
    initial_draw

    reader.subscribe(prompt)
    reader.read_keypress until done?

    print cursor.clear_line
    print_final_input unless quit?

    exit 1 if quit?
  end

  def done?
    @done
  end

  def done!
    @done = true
  end

  def quit?
    @quit
  end

  def quit!
    @quit = true
  end

  private

  attr_reader :reader, :prompt

  def cursor
    @cursor ||= TTY::Cursor
  end
end
