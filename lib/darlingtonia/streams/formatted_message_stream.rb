# frozen_string_literal: true

module Darlingtonia
  ##
  # A message stream that formats a message before forwarding it to an
  # underlying {#stream} (STDOUT by default). Messages are formatted using
  # the `#%` method; the formatter can be a string format specification like
  # "Message received: %s".
  #
  # @example Using a simple formatter
  #   formatter = "Message received: %s\n"
  #   stream    = Darlingtonia::FormattedMessageStream.new(formatter: formatter)
  #
  #   stream << "a message"
  #   # Message received: a message
  #   # => #<IO:<STDOUT>>
  #
  # @example A more complex formatter use case
  #   class MyFormatter
  #     def %(arg)
  #       "#{Time.now}: %s\n" % arg
  #     end
  #   end
  #
  #   formatter = MyFormatter.new
  #   stream    = Darlingtonia::FormattedMessageStream.new(formatter: formatter)
  #
  #   stream << 'a message'
  #   # 2018-02-02 16:10:52 -0800: a message
  #   # => #<IO:<STDOUT>>
  #
  #   stream << 'another message'
  #   # 2018-02-02 16:10:55 -0800: another message
  #   # => #<IO:<STDOUT>>
  #
  class FormattedMessageStream
    ##
    # @!attribute [rw] formatter
    #   @return [#%] A format specification
    #   @see https://ruby-doc.org/core-2.4.0/String.html#method-i-25
    # @!attribute [rw] stream
    #   @return [#<<] an underlying stream to forward messages to after
    #     formatting
    attr_accessor :formatter, :stream

    ##
    # @param formatter [#%] A format specification
    # @param stream    [#<<] an underlying stream to forward messages to after
    #   formatting
    #
    # @see https://ruby-doc.org/core-2.4.0/String.html#method-i-25
    def initialize(stream: STDOUT, formatter: "%s\n")
      self.formatter = formatter
      self.stream    = stream
    end

    ##
    def <<(msg)
      stream << format_message(msg)
    end

    ##
    # @param msg [#to_s]
    #
    # @return [String] the input, cast to a string and formatted using
    def format_message(msg)
      formatter % msg
    end
  end
end
