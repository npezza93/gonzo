class Prompt
  def initialize(app)
    @app = app
    @input = Input.new
    @completions = Completions.new(input)
  end

  def draw
    print cursor.clear_line
    input.render

    clear_and_restore { completions.render }
  end

  def initial_draw
    (completions.max + 1).tap do |count|
      print "\n" * count
      print cursor.up(count)
    end

    draw
  end

  def keyctrl_d(*)
    input.ctrl_d
    draw
  end

  def keyctrl_u(*)
    input.ctrl_u
    draw
  end

  def keybackspace(*)
    input.backspace
    draw
  end

  def print_final_input      = input.print_final
  def keyleft(*)             = input.left
  def left_word(_event)      = input.left_word
  def keyright(*)            = input.right
  def right_word(_event)     = input.right_word
  def backspace_word(_event) = input.backspace_word
  def delete_word(_event)    = input.delete_word
  def backspace_line(_event) = input.backspace_line
  def keyenter(*)            = app.done!
  def keyreturn(*)           = app.done!
  def keyctrl_c(*)           = keyescape

  def keypress(event)
    kind = Key.new(event).kind

    respond_to?(kind) && send(kind, event) && draw
  end

  def keyescape(*)
    if completions.none_selected?
      app.done! and app.quit!
    else
      completions.unselect!
      draw
    end
  end

  def keytab(*)
    completions.tab
    # self.input = choices[selected]
    draw
  end

  def keyup(*)
    completions.up
    draw
  end

  def keydown(*)
    completions.down
    draw
  end

  def regular_char(event)
    input.regular_char(event.value)
    completions.unselect!
  end

  private

  def cursor
    @cursor ||= TTY::Cursor
  end

  attr_reader :app, :completions, :input

  def clear_and_restore
    print "#{cursor.save}\r\n#{cursor.clear_screen_down}"
    yield
    print cursor.restore
  end
end
