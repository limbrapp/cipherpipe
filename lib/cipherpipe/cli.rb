class Cipherpipe::CLI
  def self.call(arguments = [], configuration = nil)
    case arguments.first
    when "upload"
      Cipherpipe::Commands::Upload.call configuration
    when "download"
      Cipherpipe::Commands::Download.call configuration
    else
      Cipherpipe::Commands::Help.call configuration
    end
  end
end
