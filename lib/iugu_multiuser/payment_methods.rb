# frozen_string_literal: true

module IuguMultiuser
  class PaymentMethods < IuguMultiuser::Base
    BASE_PATH = "customers"

    # Adiciona método de pagamento para customer Iugu
    #
    # ==== Attributes
    #
    # * +customer_id+ - Id do customer
    # * +credit_card_token+ - Token de cartão de crédito gerado usando a lib JS Iugu
    # * +document+ - Documento do customer apenas para identificação
    #
    def create(customer_id, credit_card_token, document = "não disponível")
      params = create_request_params(customer_id, document, credit_card_token)

      send_request(
        "POST",
        "#{BASE_PATH}/#{customer_id}/payment_methods",
        params
      )
    end

    # Busca um método de pagamento específico
    #
    # ==== Attributes
    #
    # * +customer_id+ - Id do customer
    # * +payment_method_id+ - Id do método de pagamento
    #
    def find(customer_id, payment_method_id)
      send_request(
        "GET",
        "#{BASE_PATH}/#{customer_id}/payment_methods/#{payment_method_id}"
      )
    end

    # Busca todos os métodos de pagamento de um customer
    #
    # ==== Attributes
    #
    # * +customer_id+ - Id do customer
    #
    def where(customer_id)
      send_request(
        "GET",
        "#{BASE_PATH}/#{customer_id}/payment_methods"
      )
    end

    # Apaga um método de pagamento
    #
    # ==== Attributes
    #
    # * +customer_id+ - Id do customer
    # * +payment_method_id+ - Id do método de pagamento
    #
    def delete(customer_id, payment_method_id)
      payment_method = find(customer_id, payment_method_id)

      send_request(
        "DELETE",
        "#{BASE_PATH}/#{customer_id}/payment_methods/#{payment_method["id"]}"
      )
    end

    private

    def create_request_params(customer_id, document, credit_card_token)
      {
        customer_id: customer_id,
        description: "Cartão de crédito doc: #{document}",
        token: credit_card_token,
        set_as_default: true
      }
    end
  end
end
