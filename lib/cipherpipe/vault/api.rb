class Cipherpipe::Vault::API < ::Vault::Request
  def read(path, options = {})
    headers = extract_headers! options
    json    = client.get("/v1/secret/data/#{encode_path(path)}", {}, headers)

    ::Vault::Secret.decode json[:data]
  rescue ::Vault::HTTPError => error
    return nil if error.code == 404
    raise error
  end

  def write(path, data = {}, options = {})
    headers = extract_headers! options
    json    = Vault.logical.client.post(
      "/v1/secret/data/#{encode_path path}",
      JSON.fast_generate(:data => data),
      headers
    )

    json.nil? ? true : ::Vault::Secret.decode(json)
  end
end
