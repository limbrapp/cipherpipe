require "uri"
require "net/http"
require "vault"

class Cipherpipe::Vault::EC2Token
  ConnectionError = Class.new Cipherpipe::Error
  URL             = URI.parse(
    "http://169.254.169.254/latest/dynamic/instance-identity/pkcs7"
  )

  NONCE_FILE = ENV.fetch(
    "CIPHERPIPE_NONCE_FILE",
    File.expand_path("~/.cipherpipe-nonce")
  )

  def self.call(external_source)
    new(external_source).call
  end

  def initialize(external_source)
    @external_source = external_source
  end

  def call
    response = ::Vault.auth.aws_ec2 external_source.ec2_role, signature, nonce

    if response.auth.metadata[:nonce]
      File.write NONCE_FILE, response.auth.metadata[:nonce]
    end

    response.auth.client_token
  end

  private

  attr_reader :external_source

  def nonce
    return nil unless File.exist?(NONCE_FILE)

    File.read(NONCE_FILE).strip
  end

  def signature
    http = Net::HTTP.new URL.host, URL.port
    http.open_timeout = 1 # second
    http.request_get(URL.path).body.gsub("\n", "")
  rescue Net::OpenTimeout => error
    raise ConnectionError, "Unable to read the local EC2 information endpoint"
  end
end
