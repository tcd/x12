module X12

  # Implements a segment containing fields or composites
  class Segment < Base
    # @return [Array<X12::Field>]
    attr_accessor :fields

    # Parses this segment out of a string, puts the match into value.
    # Returns the rest of the string - `nil` if cannot parse.
    #
    # @param str [String]
    # @return [String,nil]
    def parse(str)
      s = str
      X12.logger.debug("Parsing segment #{name} from #{s} with regexp [#{regexp.source}]")
      m = regexp.match(s)
      X12.logger.debug("Matched #{m ? m[0] : 'nothing'}")

      return nil unless m

      s = m.post_match
      self.parsed_str = m[0]
      s = do_repeats(s)

      X12.logger.debug("Parsed segment #{self.inspect}")
      return s
    end

    # Render all components of this segment as string suitable for EDI.
    #
    # @return [String]
    def render
      self.to_a.inject('') do |repeat_str, i|
        if i.repeats.begin < 1 && !i.has_content?
          # Skip optional empty segments
          repeat_str
        else
          # Have to render no matter how empty
          repeat_str += i.name + i.nodes.reverse.inject('') do |nodes_str, j|
            field = j.render
            (j.required || nodes_str != '' || field != '') ? field_separator + field + nodes_str : nodes_str
          end + segment_separator
        end
      end
    end

    # Returns a regexp that matches this particular segment.
    #
    # @return [Regexp]
    def regexp
      unless defined? @regexp
        if self.nodes.find { |i| i.type =~ /^".+"$/ }
          # It's a very special regexp if there are constant fields
          re_str = self.nodes.inject("^#{name}#{Regexp.escape(field_separator)}") do |s, i|
            field_re = i.simple_regexp(field_separator, segment_separator) + Regexp.escape(field_separator) + '?'
            field_re = "(#{field_re})?" unless i.required
            s + field_re
          end + Regexp.escape(segment_separator)
          @regexp = Regexp.new(re_str)
        else
          # Simple match
          @regexp = Regexp.new("^#{name}#{Regexp.escape(field_separator)}[^#{Regexp.escape(segment_separator)}]*#{Regexp.escape(segment_separator)}")
        end
        X12.logger.debug(sprintf("%s %p", name, @regexp))
      end
      @regexp
    end

    # Finds a field in the segment. Returns EMPTY if not found.
    #
    # @param str [String]
    # @return [X12::Base,X12::EMPTY]
    def find_field(str)
      X12.logger.debug("Finding field [#{str}] in #{self.class} #{name}")
      # If there is such a field to begin with
      field_num = nil
      self.nodes.each_index { |i| field_num = i if str == self.nodes[i].name }
      return EMPTY if field_num.nil?
      X12.logger.debug(field_num)

      # Parse the segment if not parsed already
      unless defined? @fields
        @fields = self.to_s.chop.split(Regexp.new(Regexp.escape(field_separator)))
        self.nodes.each_index { |i| self.nodes[i].content = @fields[i + 1] }
      end
      X12.logger.debug(self.nodes[field_num].inspect)
      return self.nodes[field_num]
    end

    # Provides looping through multiple segments within the loop.
    #
    # TODO: enumerator?
    #
    # @yield [X12::Segment]
    # @yieldparam [X12::Segment] segment
    # @yieldreturn [X12::Segment]
    def each
      res = self.to_a
      0.upto(res.length - 1) { |x| yield res[x] }
    end

  end

end
