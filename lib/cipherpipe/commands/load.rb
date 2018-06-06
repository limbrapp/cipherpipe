class Cipherpipe::Commands::Load
  def self.call
    new.call
  end

  def call
    Cipherpipe::ENV.call external_source.download
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
