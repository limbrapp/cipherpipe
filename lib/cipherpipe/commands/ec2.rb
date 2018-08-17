class Cipherpipe::Commands::EC2
  TOKEN_FILE = ENV.fetch(
    "CIPHERPIPE_TOKEN_FILE",
    File.expand_path("~/.vault-token")
  )

  def self.call(configuration = nil)
    new(configuration).call
  end

  def initialize(configuration)
    @configuration = configuration
  end

  def call
    require_relative "../vault"
    require_relative "../vault/ec2_token"

    if external_source.ec2_role.nil?
      puts "No EC2 role is defined, so EC2 authentication is not possible."
    else
      File.write TOKEN_FILE, Cipherpipe::Vault::EC2Token.call(external_source)
    end
  rescue Cipherpipe::Vault::EC2Token::ConnectionError => error
    warn error.message
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
