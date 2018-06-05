class Cipherpipe::CLI
  def self.call(arguments = [])
    case arguments.first
    when "upload"
      Cipherpipe::Commands::Upload.call
    when "download"
      Cipherpipe::Commands::Download.call
    else
      Cipherpipe::Commands::Help.call
    end
  end
end
