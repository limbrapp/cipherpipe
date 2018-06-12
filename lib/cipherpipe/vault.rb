class Cipherpipe::Vault
  def self.available?
    true
  end

  def self.download(external_source)
    require_relative "vault/download"

    set_token external_source
    Cipherpipe::Vault::Download.call external_source
  end

  def self.upload(external_source, settings)
    require_relative "vault/upload"

    Cipherpipe::Vault::Upload.call external_source, settings
  end

  def self.set_token(external_source)
    return unless external_source.ec2_role

    require_relative "vault/ec2_token"
    ::Vault.client.token = Cipherpipe::Vault::EC2Token.call external_source
  rescue Cipherpipe::Vault::EC2Token::ConnectionError => error
    warn error.message
  end
end
