class Cipherpipe::OnePassword::Download
  def self.call(external_source)
    new(external_source).call
  end

  def initialize(external_source)
    @external_source = external_source
  end

  def call
    JSON.load json.fetch("details", {})["notesPlain"]
  end

  private

  attr_reader :external_source

  def json
    JSON.load(
      `op get item \"#{external_source.destination}\" --vault \"#{external_source.options["vault"]}\"`
    )
  end
end
