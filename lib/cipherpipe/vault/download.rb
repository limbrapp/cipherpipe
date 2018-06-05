require "vault"
require_relative "api"

class Cipherpipe::Vault::Download
  def self.call(external_source)
    new(external_source).call
  end

  def initialize(external_source)
    @external_source = external_source
  end

  def call
    Cipherpipe::Vault::API.new(Vault.client).read(
      external_source.destination
    ).data
  end

  private

  attr_reader :external_source
end
