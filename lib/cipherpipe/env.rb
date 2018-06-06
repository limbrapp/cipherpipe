class Cipherpipe::ENV
  def self.call(variables)
    variables.each { |key, value| ENV[key] ||= value }
  end
end
