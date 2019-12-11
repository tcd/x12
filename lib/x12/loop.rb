module X12

  # Implements nested loops of segments.
  class Loop < Base

    # Parse a string and fill out internal structures with the pieces of it.
    # Returns an unparsed portion of the string or the original string if nothing was parsed out.
    #
    # @return [String]
    def parse(str)
      X12.logger.debug("Parsing loop #{name}: #{str}")
      s = str
      nodes.each do |i|
        m = i.parse(s)
        s = m if m
      end
      return nil if str == s
      self.parsed_str = str[0..-s.length-1]
      s = do_repeats(s)
      X12.logger.debug("Parsed loop + #{self.inspect}")
      return s
    end

    # Render all components of this loop as string suitable for EDI.
    #
    # @return [String]
    def render
      if self.has_content?
        self.to_a.reduce('') do |loop_str, i|
          loop_str += i.nodes.reduce('') do |nodes_str, j|
            nodes_str += j.render
          end
        end
      else
        ''
      end
    end

    # Formats a printable string containing the loops element's content.
    # Added to provide compatability with ruby > 2.0.0.
    #
    # @return [String]
    def inspect
      str = "#{self.class.to_s.sub(/^.*::/, '')} (#{name}) #{repeats} =<#{parsed_str}, #{next_repeat.inspect}> "
      return str.gsub(/\\*\"/, '"')
    end

    # Provides looping through repeats of a message.
    def each
      res = self.to_a
      0.upto(res.length - 1) do |x|
        yield res[x]
      end
    end

  end

end
