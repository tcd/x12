module X12

  # Implements a segment containing fields or composites
  class Segment < Base
    # Parses this segment out of a string, puts the match into value,
    # returns the rest of the string - nil if cannot parse.
    def parse(str)
      s = str
      # puts "Parsing segment #{name} from #{s} with regexp [#{regexp.source}]"
      m = regexp.match(s)
      # puts "Matched #{m ? m[0] : 'nothing'}"

      return nil unless m

      s = m.post_match
      self.parsed_str = m[0]
      s = do_repeats(s)

      # puts "Parsed segment "+self.inspect
      return s
    end

    # Render all components of this segment as string suitable for EDI.
    def render
      self.to_a.inject('') { |repeat_str, i|
        if i.repeats.begin < 1 and !i.has_content?
          # Skip optional empty segments
          repeat_str
        else
          # Have to render no matter how empty
          repeat_str += i.name + i.nodes.reverse.inject('') { |nodes_str, j|
            field = j.render
            (j.required or nodes_str != '' or field != '') ? field_separator + field + nodes_str : nodes_str
          } + segment_separator
        end
      }
    end

    # Returns a regexp that matches this particular segment.
    def regexp
      unless defined? @regexp
        if self.nodes.find { |i| i.type =~ /^".+"$/ }
          # It's a very special regexp if there are constant fields
          re_str = self.nodes.inject("^#{name}#{Regexp.escape(field_separator)}") { |s, i|
            field_re = i.simple_regexp(field_separator, segment_separator) + Regexp.escape(field_separator) + '?'
            field_re = "(#{field_re})?" unless i.required
            s + field_re
          } + Regexp.escape(segment_separator)
          @regexp = Regexp.new(re_str)
        else
          # Simple match
          @regexp = Regexp.new("^#{name}#{Regexp.escape(field_separator)}[^#{Regexp.escape(segment_separator)}]*#{Regexp.escape(segment_separator)}")
        end
        # puts sprintf("%s %p", name, @regexp)
      end
      @regexp
    end

    # Finds a field in the segment. Returns EMPTY if not found.
    def find_field(str)
      # puts "Finding field [#{str}] in #{self.class} #{name}"
      # If there is such a field to begin with
      field_num = nil
      self.nodes.each_index{ |i|
        field_num = i if str == self.nodes[i].name
      }
      return EMPTY if field_num.nil?
      # puts field_num

      # Parse the segment if not parsed already
      unless defined? @fields
        @fields = self.to_s.chop.split(Regexp.new(Regexp.escape(field_separator)))
        self.nodes.each_index { |i| self.nodes[i].content = @fields[i + 1] }
      end
      # puts self.nodes[field_num].inspect
      return self.nodes[field_num]
    end

    # provides loopong through multiple segments within the loop
    def each
      res = self.to_a
      0.upto(res.length - 1) do |x|
        yield res[x]
      end
    end

  end

end
