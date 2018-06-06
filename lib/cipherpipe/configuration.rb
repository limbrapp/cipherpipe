require "yaml"

class Cipherpipe::Configuration
  FILENAME = ".cipherpipe.yml"

  UnknownFormatterError = Class.new Cipherpipe::Error

  attr_reader :external_sources, :format, :file

  def initialize(filename = FILENAME)
    @filename = filename

    parse!
  end

  def variables
    formatter.read File.read(file)
  end

  def variables=(hash)
    File.write file, formatter.write(hash) if file
  end

  private

  attr_reader :filename

  def environment
    ENV["CIPHERPIPE_ENV"] || ENV["RAILS_ENV"] || "development"
  end

  def formatter
    case format
    when "json"
      Cipherpipe::Formatters::JSON
    when "hcl"
      Cipherpipe::Formatters::HCL
    when "env"
      Cipherpipe::Formatters::Env
    else
      raise UnknownFormatterError, "unknown format #{format}"
    end
  end

  def parse!
    @external_sources = yaml["sources"].collect { |source| parse_source source }
    @format           = yaml["format"]
    @file             = yaml["file"].gsub("ENVIRONMENT", environment)
  end

  def parse_source(hash)
    Cipherpipe::ExternalSource.new(
      source["type"],
      source["destination"].gsub("ENVIRONMENT", environment),
      source["primary"]
    )
  end

  def yaml
    @yaml ||= YAML.load File.read(filename)
  end
end
