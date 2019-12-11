module X12

  # Class to represent a segment field. Please note, it's not a descendant of Base.
  class Field
    # @return [String]
    attr_reader :name
    # @return [String]
    attr_reader :type
    # @return [Boolean]
    attr_reader :required
    # @return [Integer]
    attr_reader :min_length
    # @return [Integer]
    attr_reader :max_length
    # @return [String]
    attr_reader :validation

    attr_writer :content

    # Create a new field with given parameters.
    #
    # @param name [String]
    # @param type [String]
    # @param required [Boolean]
    # @param min_length [Integer]
    # @param max_length [Integer]
    # @param validation [String]
    # @return [void]
    def initialize(name, type, required, min_length, max_length, validation)
      @name       = name
      @type       = type
      @required   = required
      @min_length = min_length.to_i
      @max_length = max_length.to_i
      @validation = validation
      @content = nil
    end

    # Returns printable string with field's content.
    #
    # @return [String]
    def inspect
      return "Field #{name}|#{type}|#{required}|#{min_length}-#{max_length}|#{validation} <#{@content}>"
    end

    # Synonym for 'render'.
    #
    # @return [String]
    def to_s
      return render
    end

    # @return [String]
    def render
      unless @content
        @content = Regexp.last_match(1) if self.type =~ /"(.*)"/ # If it's a constant
      end
      rendered = @content || ''
      rendered = rendered.ljust(@min_length) if @required
      return rendered
    end

    # Check if it's been set yet and it's not a constant
    #
    # @return [Boolean]
    def has_content?
      !@content.nil? && (self.type != %("#{@content}"))
    end

    # Erase the content.
    #
    # @return [void]
    def set_empty!
      @content = nil
      return nil
    end

    # Returns simplified string regexp for this field, takes field separator and segment separator as arguments
    #
    # @return [String<Regexp>]
    def simple_regexp(field_sep, segment_sep)
      case self.type
      when /"(.*)"/
        Regexp.last_match(1)
      else
        "[^#{Regexp.escape(field_sep)}#{Regexp.escape(segment_sep)}]*"
      end
    end

    # Returns proper validating string regexp for this field, takes field separator and segment separator as arguments
    #
    # @return [String<Regexp>]
    def proper_regexp(field_sep, segment_sep)
      field_sep   = Regexp.escape(field_sep)
      segment_sep = Regexp.escape(segment_sep)
      case self.type
      when 'I'      then "\\d{#{@min_length},#{@max_length}}"
      when 'S'      then "[^#{field_sep}#{segment_sep}]{#{@min_length},#{@max_length}}"
      when /C.*/    then "[^#{field_sep}#{segment_sep}]{#{@min_length},#{@max_length}}"
      when /"(.*)"/ then Regexp.last_match(1)
      else               "[^#{field_sep}#{segment_sep}]*"
      end
    end

  end

end
