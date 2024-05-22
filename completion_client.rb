class Completions::Client
  extend Forwardable

  def_delegators :client, :call_function

  def initialize
    @client = Neovim.attach_unix(ARGV[0])
  rescue Errno::ENOENT
    instances = `ls ${XDG_RUNTIME_DIR:-${TMPDIR}nvim.${USER}}/*/nvim.*.0`
    puts "Can't find that instance. Try one of these instead:\n\n#{instances}\n"
    exit 1
  end

  def choices(q)
    return [] if q.empty?

    @choices ||= {}
    @choices[q] ||= call_function("getcompletion", [q, "cmdline"])
  end

  private

  attr_reader :client
end
