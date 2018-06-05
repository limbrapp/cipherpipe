class Cipherpipe::Formatters::JSON
  def self.read(input)
    require "json"
    ::JSON.load input
  end

  def self.write(input)
    require "json"
    ::JSON.pretty_generate input
  end
end
