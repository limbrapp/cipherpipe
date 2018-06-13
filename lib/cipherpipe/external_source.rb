class Cipherpipe::ExternalSource
  UnknownProviderError = Class.new Cipherpipe::Error

  attr_reader :type, :destination, :primary, :ec2_role, :options

  def initialize(options = {})
    @type        = options.delete "type"
    @destination = options.delete "destination"
    @primary     = options.delete "primary"
    @ec2_role    = options.delete "ec2_role"
    @options     = options
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
    when "1password"
      require_relative "one_password"
      Cipherpipe::OnePassword
    else
      raise UnknownProviderError, "unknown provider #{type}"
    end
  end
end
