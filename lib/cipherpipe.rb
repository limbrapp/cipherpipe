module Cipherpipe
  Commands   = Module.new
  Error      = Class.new StandardError
  Formatters = Module.new
end

require_relative "cipherpipe/commands/download"
require_relative "cipherpipe/commands/help"
require_relative "cipherpipe/commands/load"
require_relative "cipherpipe/commands/upload"
require_relative "cipherpipe/cli"
require_relative "cipherpipe/configuration"
require_relative "cipherpipe/env"
require_relative "cipherpipe/external_source"
require_relative "cipherpipe/formatters/env"
require_relative "cipherpipe/formatters/hcl"
require_relative "cipherpipe/formatters/json"
