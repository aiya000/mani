require 'strscan'

class Mani
  # This class contains methods to handle the tokenization of strings.
  class Tokenizer
    # The escape character
    ESCAPE_CHARACTER = '%'

    # The delimiter signifying the start of a sequence
    SEQUENCE_OPEN_DELIMITER = '{{'

    # The delimiter signifying the end of a sequence
    SEQUENCE_CLOSE_DELIMITER = '}}'

    # The delimiter signifying an "open sequence" escape sequence
    LITERAL_OPEN_DELIMITER = ESCAPE_CHARACTER + SEQUENCE_OPEN_DELIMITER

    # The delimiter signifying a "close sequence" escape sequence
    LITERAL_CLOSE_DELIMITER = ESCAPE_CHARACTER + SEQUENCE_CLOSE_DELIMITER

    # The pattern to match the start of a sequence
    SEQUENCE_OPEN = /
      # find opening delimiter at beginning of string...
      ^#{SEQUENCE_OPEN_DELIMITER}
      # ...or elsewhere in the string, provided it's not preceded by
      # ESCAPE_CHARACTER
      |[^#{ESCAPE_CHARACTER}]#{SEQUENCE_OPEN_DELIMITER}
    /x

    # The pattern to match the end of a sequence
    SEQUENCE_CLOSE = /
      # find closing delimiter at beginning of string...
      ^#{SEQUENCE_CLOSE_DELIMITER}
      # ...or elsewhere in the string, provided it's not preceded by
      # ESCAPE_CHARACTER
      |[^#{ESCAPE_CHARACTER}]#{SEQUENCE_CLOSE_DELIMITER}
    /x

    # Retrieves the tokens comprising the supplied text.
    #
    # @param [String] text The text
    # @return [Array]
    def self.get_tokens(text)
      tokenize StringScanner.new(text), []
    end

    # Strips the comment delimiters from the supplied text.
    #
    # @param [String] text The text
    # @return [String]
    def self.strip_comment_delimiters(text)
      text
        .gsub(LITERAL_OPEN_DELIMITER, SEQUENCE_OPEN_DELIMITER)
        .gsub(LITERAL_CLOSE_DELIMITER, SEQUENCE_CLOSE_DELIMITER)
    end

    # Recursively scans the string within the supplied scanner to produce a
    # list of tokens.
    #
    # @param [StringScanner] scanner The string scanner
    # @param [Array] tokens The tokens
    # @return [Array]
    def self.tokenize(scanner, tokens)
      match = scanner.scan_until SEQUENCE_OPEN
      unless match
        static = strip_comment_delimiters scanner.rest
        tokens.concat [[:static, static]] unless static.empty?
        return tokens
      end

      if !scanner.check_until SEQUENCE_CLOSE
        static = strip_comment_delimiters(match + scanner.rest)
        tokens.concat [[:static, static]]
      else
        static = strip_comment_delimiters match.chomp(SEQUENCE_OPEN_DELIMITER)
        tokens.concat [[:static, static]] unless static.empty?

        match = scanner.scan_until SEQUENCE_CLOSE
        match.chomp! SEQUENCE_CLOSE_DELIMITER

        sequence = strip_comment_delimiters match
        tokens.concat [[:sequence, sequence]] unless sequence.empty?

        tokenize scanner, tokens
      end
    end
  end
end
