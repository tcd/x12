module X12

  # Implements nested loops of segments.
  class Loop < Base

#     def regexp
#       @regexp ||=
#         Regexp.new(inject(''){|s, i|
#                      puts i.class
#                      s += case i
#                           when X12::Segment: "(#{i.regexp.source}){#{i.repeats.begin},#{i.repeats.end}}"
#                           when X12::Loop:    "(.*?)"
#                           else
#                             ''
#                           end
#                    })
#     end

    # Parse a string and fill out internal structures with the pieces of it.
    # Returns  an unparsed portion of the string or the original string if nothing was parsed out.
    def parse(str)
      # puts "Parsing loop #{name}: "+str
      s = str
      nodes.each{|i|
        m = i.parse(s)
        s = m if m
      }
      if str == s
        return nil
      else
        self.parsed_str = str[0..-s.length-1]
        s = do_repeats(s)
      end
      # puts 'Parsed loop '+self.inspect
      return s
    end

    # Render all components of this loop as string suitable for EDI.
    def render
      if self.has_content?
        self.to_a.inject(''){|loop_str, i|
          loop_str += i.nodes.inject(''){|nodes_str, j|
            nodes_str += j.render
          }
        }
      else
        ''
      end
    end


    # Formats a printable string containing the loops element's content
    # added to provide compatability with ruby > 2.0.0.
    # @return [String]
    def inspect
      "#{self.class.to_s.sub(/^.*::/, '')} (#{name}) #{repeats} =<#{parsed_str}, #{next_repeat.inspect}> ".gsub(/\\*\"/, '"')
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
