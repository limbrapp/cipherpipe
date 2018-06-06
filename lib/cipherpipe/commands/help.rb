class Cipherpipe::Commands::Help
  def self.call(configuration = nil)
    puts <<~TXT
      cipherpipe

      Command-line tool for interacting with secret stores and transferring
      data between them and with local environments.

      Configuration for secret stores and any local copies are managed via a
      .cipherpipe.yml file in the project's directory. Once that is in place,
      the following commands can be used:

        cipherpipe download # loads the secrets from the primary source
        cipherpipe upload   # uploads secrets to all sources

      TXT
  end
end
