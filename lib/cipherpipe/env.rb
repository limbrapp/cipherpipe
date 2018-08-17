class Cipherpipe::ENV
  def self.call(variables)
    variables.each { |key, value| ENV[key.to_s] ||= value }
  end
end
