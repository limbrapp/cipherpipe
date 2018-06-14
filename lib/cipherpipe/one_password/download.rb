require "json"

class Cipherpipe::OnePassword::Download
  UnknownDocument = Class.new Cipherpipe::Error

  def self.call(external_source)
    new(external_source).call
  end

  def initialize(external_source)
    @external_source = external_source
  end

  def call
    hash = documents.detect do |document|
      document["overview"]["title"] == external_source.destination
    end

    if hash.nil?
      raise UnknownDocument,
        "Cannot find #{external_source.destination} in 1Password vault #{vault}"
    end

    JSON.load `op get document \"#{hash["uuid"]}\" --vault \"#{vault}\"`
  end

  private

  attr_reader :external_source

  def documents
    JSON.load `op list documents --vault \"#{vault}\"`
  end

  def vault
    external_source.options["vault"]
  end
end
