class Cipherpipe::Formatters::Env
  def self.read(input)
    require "dotenv"
    Dotenv::Parser.call input
  end

  def self.write(input)
    input.collect { |key, value|
      "#{key}=\"#{value}\""
    }.join("\n")
  end
end
