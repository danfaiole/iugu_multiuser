# frozen_string_literal: true

module IuguMultiuser
  class Customers < IuguMultiuser::Base
    BASE_PATH = "customers"

    # Cria usuário na plataforma Iugu já com endereço adicionado
    #
    # ==== Attributes
    #
    # * +customer_params+ - Hash com dados do customer
    # * +address_params+ - Hash com dados de endereço
    #
    # ==== Examples
    #
    #    base = Base.new("Example String")
    #    base.method_name("Example", "more")
    def create(customer_params, address_params)
      customer_hash = customer_params.transform_keys(&:to_sym)
      address_hash = address_params.transform_keys(&:to_sym)

      validate_customer_hash(customer_hash)

      send_request(
        "POST",
        BASE_PATH,
        request_params(customer_hash, address_hash)
      )
    end

    def request_params(customer_hash, address_hash)
      {
        name: customer_hash[:name],
        cpf_cnpj: customer_hash[:document].gsub(/\D/, ""),
        email: customer_hash[:email],
        custom_variables: [{
          name: "external_id",
          value: customer_hash[:id]
        }]
      }.merge(address_hash)
    end

    private

    def validate_customer_hash(hash)
      validate_hash(
        hash,
        %i[name document email]
      )
    end
  end
end
