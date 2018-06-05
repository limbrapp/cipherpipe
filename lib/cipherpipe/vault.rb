class Cipherpipe::Vault
  def self.available?
    true
  end

  def self.download(external_source)
    require_relative "vault/download"

    Cipherpipe::Vault::Download.call external_source
  end

  def self.upload(external_source, settings)
    require_relative "vault/upload"

    Cipherpipe::Vault::Upload.call external_source, settings
  end
end
