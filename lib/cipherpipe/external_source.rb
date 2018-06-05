class Cipherpipe::ExternalSource
  UnknownProviderError = Class.new Cipherpipe::Error

  attr_reader :type, :destination, :primary

  def initialize(type, destination, primary = false)
    @type        = type
    @destination = destination
    @primary     = primary
  end

  def download
    if provider.available?
      provider.download self
    else
      puts "#{type} is not available, download is being skipped."
    end
  end

  def primary?
    primary
  end

  def upload(variables)
    if provider.available?
      provider.upload self, variables
    else
      puts "#{type} is not available, upload is being skipped."
    end
  end

  private

  def provider
    @provider ||= case type
    when "vault"
      require_relative "vault"
      Cipherpipe::Vault
    else
      raise UnknownProviderError, "unknown provider #{type}"
    end
  end
end
