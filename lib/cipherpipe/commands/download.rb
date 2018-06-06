class Cipherpipe::Commands::Download
  def self.call(configuration = nil)
    new(configuration).call
  end

  def initialize(configuration)
    @configuration = configuration
  end

  def call
    puts "Downloading from #{external_source.type}"
    configuration.variables = external_source.download
  end

  private

  def configuration
    @configuration ||= Cipherpipe::Configuration.new
  end

  def external_source
    @external_source ||= configuration.external_sources.detect { |source|
      source.primary?
    }
  end
end
