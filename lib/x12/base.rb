module X12

  # Base class for {Segment}, {Composite}, and {Loop}.
  # Contains setable segment_separator, field_separator, and composite_separator fields.
  class Base

    # @return [String]
    attr_reader :name
    # @return [Array,nil]
    attr_reader :repeats

    # @return [String]
    attr_accessor :segment_separator
    # @return [String]
    attr_accessor :field_separator
    # @return [String]
    attr_accessor :composite_separator

    # @return [Array]
    attr_accessor :nodes
    # @return []
    attr_accessor :parsed_str
    # Next repeat of the same element, if any.
    attr_accessor :next_repeat

    # Creates a new base element with a given name, array of sub-elements, and array of repeats if any.
    #
    # @param name [String]
    # @param arr [Array]
    # @param repeats [,nil] (nil)
    # @return [void]
    def initialize(name, arr, repeats = nil)
      @name = name
      @repeats = repeats
      @next_repeat = nil
      @parsed_str = nil

      @segment_separator   = '~'
      @field_separator     = '*'
      @composite_separator = ':'

      X12.logger.debug("Created #{name} #{object_id} #{self.class}  ")
    end

    # Formats a printable string containing the base element's content.
    #
    # @return [String]
    def inspect
      "#{self.class.to_s.sub(/^.*::/, '')} (#{name}) #{repeats} #{super.inspect[1..-2]} =<#{parsed_str}, #{next_repeat.inspect}> ".gsub(/\\*\"/, '"')
    end

    # Prints a tree-like representation of the element.
    #
    # @param ind [String] ('')
    # @return [void]
    def show(ind = '')
      count = 0
      self.to_a.each do |i|
        # puts "#{ind}#{i.name} #{i.object_id} #{i.super.object_id} [#{count}]: #{i.parsed_str} #{i.super.class}"
        puts "#{ind}#{i.name} [#{count}]: #{i.to_s.sub(/^(.{30})(.*?)(.{30})$/, '\1...\3')}"
        # Force parsing a segment
        if i.is_a?(X12::Segment) && i.nodes[0]
          i.find_field(i.nodes[0].name)
        end
        i.nodes.each do |j|
        end
        count += 1
      end
    end

    # Try to parse the current element one more time if required.
    # Returns the rest of the string or the same string if no more repeats are found or required.
    #
    # @param str [String]
    # @return [String]
    def do_repeats(str)
      if self.repeats.end > 1
        possible_repeat = self.dup
        p_s = possible_repeat.parse(str)
        if p_s
          str = p_s
          self.next_repeat = possible_repeat
        end
      end
      str
    end

    # Empty out the current element.
    #
    # @return [self]
    def set_empty!
      @next_repeat = nil
      @parsed_str = nil
      self
    end

    # Make a deep copy of the element.
    #
    # @return [self]
    def dup
      n = clone
      n.set_empty!
      n.nodes = n.nodes.dup
      n.nodes.each_index do |i|
        n.nodes[i] = n.nodes[i].dup
        n.nodes[i].set_empty!
      end
      X12.logger.debug("Duped #{self.class} #{self.name} #{self.object_id} #{super.object_id} -> #{n.name} #{n.super.object_id} #{n.object_id} ")
      n
    end

    # Recursively find a sub-element, which also has to be of type Base.
    #
    # @return [X12::Base,X12::EMPTY]
    def find(e)
      X12.logger.debug("Finding [#{e}] in #{self.class} #{name}")
      case self
        when X12::Loop
        # Breadth first
        res = nodes.find { |i| e == i.name }
        return res if res
        # Depth now
        nodes.each do |i|
          res = i.find(e) if i.is_a?(X12::Loop)
        end
        return find_field(e).to_s
      end
      return EMPTY
    end

    # Present self and all repeats as an array with self being #0.
    #
    # @return [Array]
    def to_a
      res = [self]
      nr = self.next_repeat
      while nr
        res << nr
        nr = nr.next_repeat
      end
      res
    end

    # Returns a parsed string representation of the element.
    #
    # @return [String]
    def to_s
      @parsed_str || ''
    end

    # The main method implementing Ruby-like access methods for nested elements.
    #
    # @param meth []
    # @param args []
    # @param block []
    # @return [Any]
    def method_missing(meth, *args, &block)
      str = meth.id2name
      str = str[1..str.length] if str =~ /^_\d+$/ # to avoid pure number names like 270, 997, etc.
      X12.logger.debug("Missing #{str}")
      if str =~ /=$/
        # Assignment
        str.chop!
        X12.logger.debug(str)
        case self
        when X12::Segment
          res = find_field(str)
          throw X12::MethodMissingError.new("No field '#{str}' in segment '#{self.name}'") if res == X12::EMPTY
          res.content = args[0].to_s
          X12.logger.debug(res.inspect)
        else
          throw X12::MethodMissingError.new("Illegal assignment to #{meth} of #{self.class}")
        end
      else
        # Retrieval
        res = find(str)
        yield res if block_given?
        res
      end
    end

    # The main method implementing Ruby-like access methods for repeating elements.
    #
    # @param args [Any]
    # @return [self,X12::EMPTY]
    def [](*args)
      X12.logger.debug("squares #{args.inspect}")
      return self.to_a[args[0]] || X12::EMPTY
    end

    # Yields to accompanying block passing self as a parameter.
    #
    # @param block []
    def with(&block)
      if block_given?
        yield self
      else
        throw X12::Error.new("Method 'with' requires a block.")
      end
    end

    # Returns number of repeats.
    #
    # @return [Integer]
    def size
      return self.to_a.size
    end

    # Check if any of the fields has been set yet.
    #
    # @return [X12::Base,nil]
    def has_content?
      self.nodes.find{ |i| i.has_content? }
    end

    # Adds a repeat to a segment or loop.
    # Returns a new segment/loop or self if empty.
    def repeat
      res = if self.has_content? # Do not repeat an empty segment
              last_repeat = self.to_a[-1]
              last_repeat.next_repeat = last_repeat.dup
            else
              self
            end
      yield res if block_given?
      res
    end

  end

end
