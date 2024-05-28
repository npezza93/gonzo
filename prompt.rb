class Prompt
  def initialize(app)
    @app = app
    @input = Input.new
    @completions = Completions.new(input)
    @completions_shown = false
  end

  def draw
    print cursor.clear_line
    input.render

    clear_and_restore { completions.render if completions_shown? }
  end

  def initial_draw
    print "\n" * completions.max
    print cursor.up(completions.max)

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
    if completions_shown?
      hide_completions
      input.commit
    end

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
  def keyreturn(*)           = keyenter
  def keyctrl_c(*)           = keyescape
  def completions_shown?     = completions_shown

  def keypress(event)
    kind = Key.new(event).kind

    respond_to?(kind) && send(kind, event) && draw
  end

  def keyenter(*)
    if completions.none_selected? then app.done!
    else
      hide_completions
      input.commit
      draw
    end
  end

  def keyescape(*)
    if completions.none_selected? then app.done! and app.quit!
    else
      hide_completions
      input.rollback
      draw
    end
  end

  def keytab(*)
    self.completions_shown = true
    completions.tab
    input.proposed = completions.selection
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
    if completions_shown?
      hide_completions
      input.commit
    end
    input.regular_char(event.value)

    draw
  end

  private

  attr_accessor :completions_shown

  def cursor
    @cursor ||= TTY::Cursor
  end

  attr_reader :app, :completions, :input

  def clear_and_restore
    print "#{cursor.save}\r\n#{cursor.clear_screen_down}"
    yield
    print cursor.restore
  end

  def hide_completions
    self.completions_shown = false
    completions.unselect!
  end
end
