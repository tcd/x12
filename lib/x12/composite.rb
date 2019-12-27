module X12
  # Class implementing a composite field.
  class Composite < Base
    # Make a printable representation of the composite.
    # @return [String]
    def inspect
      return "Composite #{super.inspect}"
    end
  end
end
