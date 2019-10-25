module X12
  
  # Class to represent a segment field. Please note, it's not a descendant of Base.
  class Field
    attr_reader :name, :type, :required, :min_length, :max_length, :validation
    attr_writer :content

    # Create a new field with given parameters
    def initialize(name, type, required, min_length, max_length, validation)
      @name       = name
      @type       = type
      @required   = required
      @min_length = min_length.to_i
      @max_length = max_length.to_i
      @validation = validation
      @content = nil
    end

    # Returns printable string with field's content
    # @return [String]
    def inspect
      "Field #{name}|#{type}|#{required}|#{min_length}-#{max_length}|#{validation} <#{@content}>"
    end

    # Synonym for 'render'
    def to_s
      render
    end

    def render
      unless @content
        @content = $1 if self.type =~ /"(.*)"/ # If it's a constant
      end
      rendered = @content || ''
      rendered = rendered.ljust(@min_length) if @required
      rendered
    end

    # Check if it's been set yet and it's not a constant
    def has_content?
      !@content.nil? && ('"'+@content+'"' != self.type)
    end

    # Erase the content
    def set_empty!
      @content = nil
    end

    # Returns simplified string regexp for this field, takes field separator and segment separator as arguments
    def simple_regexp(field_sep, segment_sep)
      case self.type
      when /"(.*)"/ then $1
      else "[^#{Regexp.escape(field_sep)}#{Regexp.escape(segment_sep)}]*"
      end # case
    end

    # Returns proper validating string regexp for this field, takes field separator and segment separator as arguments
    def proper_regexp(field_sep, segment_sep)
      case self.type
      when 'I'      then "\\d{#{@min_length},#{@max_length}}"
      when 'S'      then "[^#{Regexp.escape(field_sep)}#{Regexp.escape(segment_sep)}]{#{@min_length},#{@max_length}}"
      when /C.*/    then "[^#{Regexp.escape(field_sep)}#{Regexp.escape(segment_sep)}]{#{@min_length},#{@max_length}}"
      when /"(.*)"/ then $1
      else "[^#{Regexp.escape(field_sep)}#{Regexp.escape(segment_sep)}]*"
      end
    end

  end
  
end
