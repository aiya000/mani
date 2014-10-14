class Mani
  # This class contains methods to handle operations run within windows.
  class Window
    # Creates a new tab, or switches to the supplied tab.
    #
    # @param [Symbol, Integer] tab The tab. If :new is specified, a new tab
    #   will be created and the window will switch to it. If an integer is
    #   specified, the window will switch to that (previously existing) tab.
    # @param [Hash] options The options
    #   * :delay (Numeric) _Optional_ The amount of time, in seconds, to delay
    #     after handling the tab (defaults to 0.5)
    # @param [Proc] block The code to execute after handling the tab
    def browser_tab(tab, options = {}, &block)
      @windowing_system.focus_window @pid

      if tab == :new
        @windowing_system.type_keysequence 'ctrl+t'
        @windowing_system.type_keysequence 'alt+9'
      elsif tab >= 1 && tab <= 8
        @windowing_system.type_keysequence "alt+#{tab}"
      elsif tab > 8
        @windowing_system.type_keysequence 'alt+8'
        (tab - 8).times { @windowing_system.type_keysequence 'ctrl+Tab' }
      else
        return
      end

      sleep options[:delay] || 0.5

      instance_eval(&block) if block
    end

    # Initializes the window.
    #
    # @param [Object] windowing_system The windowing system
    def initialize(windowing_system)
      @windowing_system = windowing_system
    end

    # Launches the supplied program.
    #
    # @param [String] program The program
    # @param [Hash] options The options
    #   * :delay (Numeric) _Optional_ The amount of time, in seconds, to delay
    #     after launching the program (defaults to 0.5)
    # @param [Proc] block The code to execute after launching the program
    def launch(program, options = {}, &block)
      return if @pid

      @pid = Process.spawn program
      Process.detach @pid

      sleep options[:delay] || 0.5

      instance_eval(&block) if block
    end

    # Runs the supplied command within the current window.
    #
    # @param [String] command The command
    # @param [Hash] options The options
    #   * :delay (Numeric) _Optional_ The amount of time, in seconds, to delay
    #     after running the command (defaults to 0.5)
    def run(command, options = {})
      @windowing_system.focus_window @pid
      @windowing_system.type_combination command
      @windowing_system.type_keysequence 'Return'

      sleep options[:delay] || 0.5
    end

    # Types the supplied text into the current window.
    #
    # @param [String] text The text
    # @param [Hash] options The options
    #   * :delay (Numeric) _Optional_ The amount of time, in seconds, to delay
    #     after typing the text (defaults to 0.5)
    def type(text, options = {})
      @windowing_system.focus_window @pid
      @windowing_system.type_combination text

      sleep options[:delay] || 0.5
    end

    # Enters the supplied url into the current window.
    #
    # @param [String] url The url
    # @param [Hash] options The options
    #   * :delay (Numeric) _Optional_ The amount of time, in seconds, to delay
    #     after entering the url (defaults to 0.5)
    def visit(url, options = {})
      run url, options
    end
  end
end
