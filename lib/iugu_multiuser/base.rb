# frozen_string_literal: true

require "rest-client"
require "json"

module IuguMultiuser
  class Base
    BASE_URL = "https://api.iugu.com/v1"

    def initialize(api_key:)
      @api_key = api_key.empty? ? ENV["IUGU_API_KEY"] : api_key

      return unless @api_key.empty?

      raise IuguMultiuser::MissingApiKeyError("Chave de API não configurada para subconta do cliente.")
    end

    def send_request(http_verb, url, params = {})
      request = create_request(http_verb, url, params)
      response = RestClient::Request.execute(request)
      handle_response(response)

    rescue RestClient::ResourceNotFound
      raise IuguMultiuser::NotFound
    rescue RestClient::UnprocessableEntity => e
      raise IuguMultiuser::ValidationError(JSON.parse(e.response)["errors"])
    rescue RestClient::BadRequest => e
      raise IuguMultiuser::ParamError(JSON.parse(e.response)["errors"])
    end

    # def validate_buyer_hash(hash)
    #   validate_hash(hash, [
    #     :name, :document, :email
    #   ])
    # end

    # def validate_credit_card_hash(hash)
    #   validate_hash(hash, [
    #     :card_number, :card_holder_name,
    #     :card_expiration_month, :card_expiration_year,
    #     :card_cvv
    #   ])
    # end

    private

    # def validate_hash(hash, array_of_keys)
    #   array_of_keys.each { |key| raise IuguMultiuser::ParamError.new("Required key: #{key}") if hash.transform_keys(&:to_sym)[key].empty? }
    #   hash
    # end

    def headers
      api_key_to_encode = "#{@api_key}:"
      {
        authorization: "Basic #{Base64.encode64(api_key_to_encode)}",
        accept: "application/json",
        accept_charset: "utf-8",
        content_type: "application/json; charset=utf-8"
      }
    end

    def create_request(http_verb, url, params)
      {
        verify_ssl: true,
        headers: headers,
        method: http_verb.upcase,
        payload: params.to_json,
        url: "#{BASE_URL}/#{url}",
        timeout: 30
      }
    end

    def handle_response(response)
      response_json = JSON.parse(response.body)

      if response_json["errors"].length.positive?
        raise IuguMultiuser::NotFound if response_json["errors"] == "Not Found"

        raise IuguMultiuser::RequestError(response_json["errors"])
      end

      response_json
    rescue JSON::ParserError
      raise IuguMultiuser::RequestError
    end
  end
end
