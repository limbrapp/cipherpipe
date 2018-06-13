class Cipherpipe::OnePassword::Upload
  def self.call(external_source, variables)
    new(external_source, variables).call
  end

  def initialize(external_source, variables)
    @external_source = external_source
    @variables       = variables
  end

  def call
    `op create item "Secure Note" "#{encoded_note}" --title="#{external_source.destination}" --vault="#{external_source.options["vault"]}"`
  end

  private

  attr_reader :external_source, :variables

  def encoded_note
    `echo "#{json}" | op encode`.strip
  end

  def json
    JSON.dump "notesPlain" => JSON.dump(variables), "sections" => []
  end
end
