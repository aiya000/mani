require 'x_do'

class Mani
  # This class contains methods to interface with the X Window System.
  class X
    # Initializes XDo to handle the heavy lifting of interfacing with X.
    def initialize
      @xdo = XDo.new
    end

    # Finds the visible window with the supplied pid and focuses it.
    #
    # @param [Fixnum] pid The pid
    def focus_window(pid)
      @xdo.find_windows(pid: pid, visible: true).first.focus
    end

    # Types the supplied combination. Note that any text between '{{' and '}}'
    # delimiters is treated as a sequence. All other text is treated literally.
    #
    # @param [String] combination The combination
    def type_combination(combination)
      tokens = Mani::Tokenizer.get_tokens combination
      tokens.each do |token|
        case token.first
        when :static
          type_string token.last
        when :sequence
          type_keysequence token.last
        end
      end
    end

    # Types the supplied sequence (e.g., 'ctrl+v', 'F6', 'alt+2').
    #
    # @param [String] sequence The sequence
    def type_keysequence(sequence)
      @xdo.keyboard.type_keysequence sequence
    end

    # Types the supplied string. Note that the string is treated literally.
    #
    # @param [String] string The string
    def type_string(string)
      @xdo.keyboard.type_string string
    end
  end
end
