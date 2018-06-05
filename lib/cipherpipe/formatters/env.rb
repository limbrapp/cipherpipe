class Cipherpipe::Formatters::Env
  def self.read(input)
    require "dotenv"
    Dotenv::Parser.call input
  end

  def self.write(input)
    input.each { |key, value|
      "#{key}=\"#{value}\""
    }.join("\n")
  end
end
