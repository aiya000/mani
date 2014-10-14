require 'mani/window'
require 'mani/tokenizer'

# The base class.
class Mani
  # Initializes the windowing system, as well as the window manager options.
  #
  # @param [Hash] options The options
  #   * :window_manager (Symbol) The window manager (currently only handles
  #     :xmonad)
  #   * :switch_to_workspace (Proc) _Optional_ The proc which, when called,
  #     returns a string which, when interpreted, will switch to the specified
  #     workspace
  # @param [Proc] block The code to execute after initialization
  def initialize(options = {}, &block)
    window_manager = options.delete :window_manager
    case window_manager
    when :xmonad
      require 'mani/x'

      @windowing_system = Mani::X.new
      @window_manager_options = {
        switch_to_workspace: ->(space) { "super+#{space}" }
      }.merge options
    else
      fail 'Unrecognized :window_manager.'
    end

    @windows = {}

    instance_eval(&block)
  end

  # Creates a new window object, or defers execution of the supplied block to
  # an existing window object.
  #
  # @param [Symbol] name The window name
  # @param [Hash] options The options
  #   * :launch (String) _Optional_ The program to launch. If specified, any
  #     remaining options, as well as the supplied block, will be passed to
  #     Mani::Window#launch. If not specified, the supplied block will be
  #     executed (within the context of the window).
  # @param [Proc] block The code to execute
  def window(name, options = {}, &block)
    @windows[name] = Window.new @windowing_system unless @windows[name]

    program = options.delete :launch
    if program
      @windows[name].launch program, options, &block
    else
      @windows[name].instance_eval(&block)
    end
  end

  # Switches to the specified workspace.
  #
  # @param [Integer] space The space number
  # @param [Proc] block The code to execute after switching to the workspace
  def workspace(space, &block)
    sequence = @window_manager_options[:switch_to_workspace].call space
    @windowing_system.type_keysequence sequence

    instance_eval(&block) if block
  end
end
