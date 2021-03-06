# Cipherpipe

Cipherpipe transfers secrets from stores (such as Vault and 1Password) onto your local machine, or into the `ENV` of a Ruby app. You can then make changes and upload these back into the store - all of which is done only when you have valid access.

## Why?

App and infrastructure secrets - API keys and other sensitive information - should be managed very carefully. Reading and writing these secrets must happen, though: developers will add new values in, production servers will retrieve values, and potentially so will CI services.

Cipherpipe makes the transferring of this data predictable and reliable. It doesn't take care of managing authentication - you'll need to do that yourself (for example, with Vault via the appropriate tokens) - but it provides an executable to send and retrieve secrets as determined by a configuration file that can be checked in to the appropriate version control repositories.

## Installation

To use Cipherpipe on your machine, you'll need to install the gem:

    $ gem install cipherpipe

There are additional gems you may need, depending on what formats and which secret storage services you're dealing with.

    $ gem install vault # if you're interacting with Vault
    $ gem install rhcl  # if you're storing data as HCL variables (e.g. Terraform)
    $ gem install dotenv # if you're storing data as a bash env file.

If you want to access secrets within your Rails/Ruby app, then add it to your Gemfile:

```ruby
gem 'cipherpipe'
```

And add the following to an initializer to load the secrets:

```ruby
Cipherpipe::Commands::Load.call
```

If you're using Vault's EC2 authentication and have specified an `ec2_role` value for the primary source (as noted in the configuration example below), then loading the secrets will automatically authenticate against Vault using the EC2 instance's PKCS7-signed identity.

If you're using 1Password, you'll want to have [their command-line tool](https://support.1password.com/command-line-getting-started/) installed (testing has been conducted with v0.4.1). Any time you use cipherpipe commands that interact with 1Password, you'll have to be authenticated first (`op signin team-subdomain.1password.com me@myemail.com A3-XXXXXX-XXXXXX-XXXXX-XXXXX-XXXXX-XXXXX`).

## Configuration

Everything for Cipherpipe is managed in a YAML configuration file `.cipherpipe.yml` which you should place in the root of your project. You'll need to specify at least one source (and mark it as the primary). Having an output file/format is optional, but likely useful.

When setting a Vault source, the destination is a key-value store (v2) and the `secret/` prefix is added automatically. When setting up 1Password, the destination is the name of the document, and you'll want to specify a vault as well.

Here's an example for a Rails application using `dotenv` (and `ENVIRONMENT` is automatically translated to the appropriate Rails environment, as based on the CIPHERPIPE_ENV or RAILS_ENV variables):

```yml
file: .env.ENVIRONMENT
format: env
sources:
- type: vault
  destination: apps/myapp/ENVIRONMENT
  primary: true
- type: 1password
  destination: "Apps: myapp ENVIRONMENT"
  vault: Developers
```

If you're running this on EC2 servers that are set up to authenticate with Vault via a specific role, you can provide that with the `ec2_role` setting and it'll automatically be used:

```yml
file: .env.ENVIRONMENT
format: env
sources:
- type: vault
  destination: apps/myapp/ENVIRONMENT
  primary: true
  ec2_role: servers
```

Another example, for use with a Terraform project:

```yml
file: terraform.tfvars
format: hcl
sources:
- type: vault
  destination: infrastructure/myapp
  primary: true
```

Or, for use with Packer:

```yml
file: variables.json
format: json
sources:
- type: vault
  destination: images/myserver
  primary: true
```

Note that you must have one primary source - the primary source is where data is downloaded from. Other sources are only for uploading (i.e. as a backup).

## Usage

Once you've got things configured, you can use the `cipherpipe` executable to download or upload configuration.

Downloading takes data from the primary secret storage service, and copies it into the specified file, in the specified format:

    $ cipherpipe download

Uploading will take the data from the configured file and send it to all of the configured secret sources.

    $ cipherpipe upload

Make sure that the configured secrets file is _not_ stored in version control. The `.cipherpipe.yml` file, however, should definitely be stored.

If you're using Vault's EC2 authentication and have specified an `ec2_role` value for the primary source, you can automatically save a token for your system user (in `~/.vault-token`) with the `ec2` command:

    $ cipherpipe ec2

## Dependencies

If you're using Vault, you'll need to make sure it's using the V2 kv secrets engine.

If you're using 1Password, you'll need [their command-line tool](https://support.1password.com/command-line-getting-started/) installed (v0.4.1 or newer is recommended).

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/limbrapp/cipherpipe](https://github.com/limbrapp/cipherpipe). This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Cipherpipe project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/pat/cipherpipe/blob/master/CODE_OF_CONDUCT.md).
