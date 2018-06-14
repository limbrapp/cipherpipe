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

  let!(:op_enabled_command) do
    ShellMock.stub_command("which op").and_return("/test/op")
  end
  let!(:primary_command) do
    ShellMock.stub_command("op create document \"mydir/cipherpipe.json\" --title=\"testing\" --vault=\"Development\"")
  end
  let!(:secondary_command) do
    ShellMock.stub_command("op create document \"mydir/cipherpipe.json\" --title=\"testing\" --vault=\"Backups\"")
  end
  let!(:list_primary_command) do
    ShellMock.stub_command("op list documents --vault \"Development\"").
      and_return JSON.dump([
        {"overview" => {"title" => "testing"}, "uuid" => "matchingUUID"}
      ])
  end
  let!(:list_secondary_command) do
    ShellMock.stub_command("op list documents --vault \"Backups\"").
      and_return JSON.dump([])
  end
  let!(:delete_command) do
    ShellMock.stub_command("op delete item \"matchingUUID\" --vault=\"Development\"")
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

    allow(Dir).to receive(:mktmpdir).and_yield "mydir"
    allow(File).to receive(:write).and_return nil
  end

  it "writes the file to the temporary location" do
    expect(File).to receive(:write).
      with("mydir/cipherpipe.json", JSON.dump(variables))

    Cipherpipe::CLI.call ["upload"], configuration
  end

  it "uploads to each source" do
    Cipherpipe::CLI.call ["upload"], configuration

    expect(primary_command).to have_been_called.once
    expect(secondary_command).to have_been_called.once
  end

  it "deletes existing documents when updating" do
    Cipherpipe::CLI.call ["upload"], configuration

    expect(delete_command).to have_been_called.once
  end
end
