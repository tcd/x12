require 'logger'

module X12
  class << self
    attr_writer :logger

    # @return [Logger]
    def logger
      @logger ||= Logger.new(STDOUT).tap do |log|
        log.progname = self.name
        log.level = Logger::WARN
      end
    end
  end
end
