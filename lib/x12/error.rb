module X12
  # Exceptions raised by X12 inherit from Error.
  # @abstract
  class Error < StandardError; end

  # Raised from {X12::Base#method_missing}.
  class MethodMissingError < Error
    # @param msg [String] ('')
    # @return [void]
    def initialize(msg = '')
      super(msg)
    end
  end
end
