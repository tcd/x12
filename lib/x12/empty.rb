module X12
  # Class indicating the absense of any X12 element, be it Loop, Segment, or anything else like that.
  class Empty < Base
    # Create a new Empty.
    #
    # @return [void]
    def initialize
      super(nil, [])
    end

    # Returns an empty string.
    #
    # @return [String]
    def to_s
      return ''
    end
  end
end
