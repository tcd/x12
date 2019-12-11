module X12

  # Main class for creating X12 parsers and factories.
  class Parser

    # Creates a parser out of a definition.
    #
    # @param file_name [String]
    # @return [void]
    def initialize(file_name)
      save_definition = @x12_definition if defined? @x12_definition

      # get the current working directory
      file_location = File.join(File.dirname(__FILE__), '../../misc', file_name)
      # Read and parse the definition
      str = File.open(file_location, 'r').read
      # @dir_name = File.dirname(File.expand_path(file_name)) # to look up other files if needed
      @x12_definition = X12::XMLDefinitions.new(str)

      # Populate fields in all segments found in all the loops.
      if @x12_definition[X12::Loop]
        @x12_definition[X12::Loop].each_pair do |k, v|
          X12.logger.debug("Populating definitions for loop #{k}")
          process_loop(v)
        end
      end

      # Merge the newly parsed definition into a saved one, if any.
      if save_definition
        @x12_definition.keys.each do |t|
          save_definition[t] ||= {}
          @x12_definition[t].keys.each do |u|
            save_definition[t][u] = @x12_definition[t][u]
          end
          @x12_definition = save_definition
        end
      end

      X12.logger.debug(self)
    end
    # Parse a loop of a given name out of a string.
    # Throws an exception if the loop name is not defined.
    #
    def parse(loop_name, str)
      looop = @x12_definition[X12::Loop][loop_name]
      X12.logger.debug("Loops to parse #{@x12_definition[X12::Loop].keys}")
      throw X12::Error.new("Cannot find a definition for loop #{loop_name}") unless looop
      looop = looop.dup
      looop.parse(str)
      return looop
    end

    # Make an empty loop to be filled out with information.
    #
    def factory(loop_name)
      looop = @x12_definition[X12::Loop][loop_name]
      throw X12::Error.new("Cannot find a definition for loop #{loop_name}") unless looop
      looop = looop.dup
      return looop
    end

    private

    # Recursively scan the loop and instantiate fields' definitions for all its segments.
    def process_loop(looop)
      looop.nodes.each do |i|
        case i
          when X12::Loop then process_loop(i)
          when X12::Segment then process_segment(i) unless i.nodes.size > 0
          else return
        end
      end
    end

    # Instantiate segment's fields as previously defined.
    #
    def process_segment(segment)
      X12.logger.debug("Trying to process segment #{segment.inspect}")
      unless @x12_definition[X12::Segment] && @x12_definition[X12::Segment][segment.name]
        # Try to find it in a separate file if missing from the @x12_definition structure
        initialize(segment.name + '.xml')
        segment_definition = @x12_definition[X12::Segment][segment.name]
        throw X12::Error.new("Cannot find a definition for segment #{segment.name}") unless segment_definition
      else
        segment_definition = @x12_definition[X12::Segment][segment.name]
      end
      segment_definition.nodes.each_index do |i|
        segment.nodes[i] = segment_definition.nodes[i]
        # Make sure we have the validation table if any for this field. Try to read one in if missing.
        table = segment.nodes[i].validation
        if table
          unless @x12_definition[X12::Table] && @x12_definition[X12::Table][table]
            initialize(table + '.xml')
            unless @x12_definition[X12::Table] && @x12_definition[X12::Table][table]
              throw X12::Error.new("Cannot find a definition for table #{table}")
            end
          end
        end
      end
    end

  end

end
