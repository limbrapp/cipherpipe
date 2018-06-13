class Cipherpipe::OnePassword
  def self.available?
    !`which op`.empty?
  end

  def self.download(external_source)
    require_relative "one_password/download"

    Cipherpipe::OnePassword::Download.call external_source
  end

  def self.upload(external_source, settings)
    require_relative "one_password/upload"

    Cipherpipe::OnePassword::Upload.call external_source, settings
  end
end
