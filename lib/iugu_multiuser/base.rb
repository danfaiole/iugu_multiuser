# frozen_string_literal: true

require "rest-client"
require "json"

module IuguMultiuser
  class Base

    BASE_URL = "https://api.iugu.com/v1"

    def initialize(api_key:)
      @api_key = api_key.empty? ? ENV["IUGU_API_KEY"] : api_key

      raise IuguMultiuser::MissingApiKeyError("Chave de API não configurada para subconta do cliente.") if @api_key.empty?
    end

    def send_request(method, url, params = {})
      request = {
        verify_ssl: true,
        headers: headers,
        method: method.upcase,
        payload: params.to_json,
        url: "#{BASE_URL}/#{url}",
        timeout: 30
      }

      response = RestClient::Request.execute(request)
      handle_response(response)

    rescue RestClient::ResourceNotFound
      raise IuguMultiuser::NotFound
    rescue RestClient::UnprocessableEntity => ex
      raise IuguMultiuser::ValidationError.new JSON.parse(ex.response)['errors']
    rescue RestClient::BadRequest => ex
      raise IuguMultiuser::ParamError.new JSON.parse(ex.response)['errors']
    end

    def validate_buyer_hash(hash)
      validate_hash(hash, [
        :name, :document, :email
      ])
    end

    def validate_credit_card_hash(hash)
      validate_hash(hash, [
        :card_number, :card_holder_name,
        :card_expiration_month, :card_expiration_year,
        :card_cvv
      ])
    end

    private

    def validate_hash(hash, array_of_keys)
      array_of_keys.each { |key| raise IuguMultiuser::ParamError.new("Required key: #{key}") if hash.transform_keys(&:to_sym)[key].empty? }
      hash
    end

    def headers
      {
        authorization: 'Basic ' + Base64.encode64(@api_key + ':'),
        accept: "application/json",
        accept_charset: "utf-8",
        content_type: "application/json; charset=utf-8"
      }
    end

     def handle_response(response)
        response_json = JSON.parse(response.body)

        raise IuguMultiuser::NotFound if response_json.is_a?(Hash) && response_json['errors'] == 'Not Found'
        raise IuguMultiuser::RequestError, response_json['errors'] if response_json.is_a?(Hash) && response_json['errors'] && response_json['errors'].length > 0

        response_json
      rescue JSON::ParserError
        raise IuguMultiuser::RequestError
      end
  end
end