class Cipherpipe::Formatters::HCL
  def self.read(input)
    require "rhcl"
    ::Rhcl.parse input
  end

  def self.write(input)
    require "rhcl"
    ::Rhcl.dump input
  end
end
