require "spec_helper"
require "tempfile"

RSpec.describe "Uploading secrets to Vault" do
  let(:configuration_file) { Tempfile.new }
  let(:output_file)        { Tempfile.new }
  let(:variables)          { {"foo" => "bar", "baz" => "qux"} }
  let(:configuration) do
    Cipherpipe::Configuration.new configuration_file.path
  end

  before :each do
    configuration_file.write <<~YAML
      file: #{output_file.path}
      format: json
      sources:
      - type: vault
        destination: testing
        primary: true
      - type: vault
        destination: testing-backup
    YAML
    configuration_file.flush

    output_file.write JSON.dump(variables)
    output_file.flush

    stub_request(:post, "https://vault.test/v1/secret/data/testing").to_return(
      :body    => JSON.dump(:data => {:data => variables}),
      :headers => {"Content-Type" => "application/json"}
    )

    stub_request(:post, "https://vault.test/v1/secret/data/testing-backup")
      .to_return(
        :body    => JSON.dump(:data => {:data => variables}),
        :headers => {"Content-Type" => "application/json"}
      )
  end

  it "uploads to each source" do
    Cipherpipe::CLI.call ["upload"], configuration

    expect(
      a_request(:post, "https://vault.test/v1/secret/data/testing").
        with { |request| request.body == JSON.dump(:data => variables) }
    ).to have_been_made.once

    expect(
      a_request(:post, "https://vault.test/v1/secret/data/testing-backup").
        with { |request| request.body == JSON.dump(:data => variables) }
    ).to have_been_made.once
  end
end

RSpec.describe "Uploading secrets to 1Password" do
  let(:configuration_file) { Tempfile.new }
  let(:output_file)        { Tempfile.new }
  let(:variables)          { {"foo" => "bar", "baz" => "qux"} }
  let(:configuration) do
    Cipherpipe::Configuration.new configuration_file.path
  end
  let(:document) { {"notesPlain" => JSON.dump(variables), "sections" => []} }

  let!(:primary_command) do
    ShellMock.stub_command("op create item \"Secure Note\" \"encodedNote\" --title=\"testing\" --vault=\"Development\"")
  end
  let!(:secondary_command) do
    ShellMock.stub_command("op create item \"Secure Note\" \"encodedNote\" --title=\"testing\" --vault=\"Backups\"")
  end
  let!(:encode_command) do
    ShellMock.stub_command("echo \"#{JSON.dump(document)}\" | op encode").
      and_return("encodedNote")
  end

  before :each do
    configuration_file.write <<~YAML
      file: #{output_file.path}
      format: json
      sources:
      - type: 1password
        destination: testing
        primary: true
        vault: Development
      - type: 1password
        destination: testing
        vault: Backups
    YAML
    configuration_file.flush

    output_file.write JSON.dump(variables)
    output_file.flush
  end

  it "uploads to each source" do
    Cipherpipe::CLI.call ["upload"], configuration

    expect(primary_command).to have_been_called.once
    expect(secondary_command).to have_been_called.once
  end
end
