require "spec_helper"
require "tempfile"

RSpec.describe "Downloading secrets from Vault" do
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

    stub_request(:get, "https://vault.test/v1/secret/data/testing").to_return(
      :body    => JSON.dump(:data => {:data => variables}),
      :headers => {"Content-Type" => "application/json"}
    )
  end

  it "downloads from the primary source" do
    Cipherpipe::CLI.call ["download"], configuration

    output = File.read(output_file.path)

    expect(JSON.load(output)).to eq(variables)
  end

  it "does not download from non-primary sources" do
    Cipherpipe::CLI.call ["download"], configuration

    expect(a_request(:get, "https://vault.test/v1/secret/data/testing")).
      to have_been_made.once
    expect(a_request(:get, "https://vault.test/v1/secret/data/testing-backup")).
      to_not have_been_made
  end

  context "with an ec2 role" do
    before :each do
      configuration_file.write <<~YAML
        file: #{output_file.path}
        format: json
        sources:
        - type: vault
          destination: testing
          primary: true
          ec2_role: servers
        - type: vault
          destination: testing-backup
      YAML
      configuration_file.flush

      allow(File).to receive(:exist?).and_return(false)
      allow(File).to receive(:write).and_return(nil)
    end

    after :each do
      Vault.client.token = "test"
    end

    it "fails gracefully when not on an EC2 server" do
      stub_request(
        :get, "http://169.254.169.254/latest/dynamic/instance-identity/pkcs7"
      ).to_timeout

      Cipherpipe::CLI.call ["download"], configuration

      expect(
        a_request(:get, "https://vault.test/v1/secret/data/testing").
          with { |request| request.headers["X-Vault-Token"] == "test" }
      ).to have_been_made.once
    end

    it "uses the EC2 token" do
      response = {
        :auth => {
          :client_token => "authenticated",
          :metadata     => {
            :nonce => "foo"
          }
        }
      }

      stub_request(
        :get, "http://169.254.169.254/latest/dynamic/instance-identity/pkcs7"
      ).to_return(:body => "my-signature")

      stub_request(:post, "https://vault.test/v1/auth/aws-ec2/login").
        to_return(
          :body    => JSON.dump(response),
          :headers => {"Content-Type" => "application/json"}
        )

      Cipherpipe::CLI.call ["download"], configuration

      expect(
        a_request(:post, "https://vault.test/v1/auth/aws-ec2/login").
          with { |request|
            JSON.load(request.body) == {"role" => "servers", "pkcs7" => "my-signature"}
          }
      ).to have_been_made.once

      expect(
        a_request(:get, "https://vault.test/v1/secret/data/testing").
          with { |request| request.headers["X-Vault-Token"] == "authenticated" }
      ).to have_been_made.once
    end
  end
end

RSpec.describe "Downloading secrets from 1Password" do
  let(:configuration_file) { Tempfile.new }
  let(:output_file)        { Tempfile.new }
  let(:variables)          { {"foo" => "bar", "baz" => "qux"} }
  let(:configuration) do
    Cipherpipe::Configuration.new configuration_file.path
  end

  let!(:primary_command) do
    ShellMock.stub_command("op get item \"testing\" --vault \"Development\"").
      and_return JSON.dump("details" => {"notesPlain" => JSON.dump(variables)})
  end
  let!(:secondary_command) do
    ShellMock.stub_command("op get item \"testing\" --vault \"Backups\"").
      and_return JSON.dump("details" => {"notesPlain" => nil})
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
  end

  it "downloads from the primary source" do
    Cipherpipe::CLI.call ["download"], configuration

    output = File.read(output_file.path)

    expect(JSON.load(output)).to eq(variables)
  end

  it "does not download from non-primary sources" do
    Cipherpipe::CLI.call ["download"], configuration

    expect(primary_command).to have_been_called.once
    expect(secondary_command).to_not have_been_called
  end
end
