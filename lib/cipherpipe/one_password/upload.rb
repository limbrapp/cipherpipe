require "tempfile"
require "json"

class Cipherpipe::OnePassword::Upload
  def self.call(external_source, variables)
    new(external_source, variables).call
  end

  def initialize(external_source, variables)
    @external_source = external_source
    @variables       = variables
  end

  def call
    documents.each do |document|
      next unless document["overview"]["title"] == external_source.destination

      `op delete item "#{document["uuid"]}" --vault="#{vault}"`
    end

    file.write JSON.dump(variables)
    file.flush

    `op create document "#{file.path}" --title="#{external_source.destination}" --vault="#{vault}"`
  end

  private

  attr_reader :external_source, :variables

  def documents
    JSON.load `op list documents --vault "#{vault}"`
  end

  def file
    @file ||= Tempfile.new
  end

  def vault
    external_source.options["vault"]
  end
end
