require "vault"
require_relative "api"

class Cipherpipe::Vault::Upload
  def self.call(external_source, variables)
    new(external_source, variables).call
  end

  def initialize(external_source, variables)
    @external_source = external_source
    @variables       = variables
  end

  def call
    Cipherpipe::Vault::API.new(Vault.client).write(
      external_source.destination, variables
    )
  end

  private

  attr_reader :external_source, :variables
end
