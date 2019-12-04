module X12

  # This just a named hash to store validation tables.
  class Table < Hash
    # @return [String]
    attr_reader :name

    # Create a new table with given name and hash content.
    # @return [void]
    def initialize(name, name_values)
      @name = name
      self.merge!(name_values)
    end

    # Return a printable string representing this table
    # @return [String]
    def inspect
      "Table #{name} -- #{super.inspect}"
    end

  end

end
