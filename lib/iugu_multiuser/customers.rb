# frozen_string_literal: true

module IuguMultiuser
  class Customers < IuguMultiuser::Base
    BASE_PATH = "customers"

    # Cria usuário na plataforma Iugu já com endereço adicionado
    #
    # ==== Attributes
    #
    # * +buyer_params+ - Hash com dados do customer
    # * +address_params+ - Hash com dados de endereço
    #
    # ==== Examples
    #
    #    base = Base.new("Example String")
    #    base.method_name("Example", "more")
    def create(buyer_params, address_params)
      puts "**** Criando customer no Iugu ****"

      buyer_hash = buyer_params.transform_keys(&:to_sym)
      address_hash = address_params.transform_keys(&:to_sym)

      validate_buyer_hash(buyer_hash)

      params = {
        name: buyer_hash[:name],
        cpf_cnpj: buyer_hash[:document].gsub(/\D/, ''),
        email: buyer_hash[:email],
        # cc_emails: buyer_hash[:email],
        custom_variables: [{
          name: 'external_id',
          value: buyer_hash[:id]
        }],
        zip_code: address_hash[:zip_code],
        number: address_hash[:number],
        street: address_hash[:street],
        city: address_hash[:city],
        state: address_hash[:state],
        district: address_hash[:district]
      }

      object = send_request(
        'POST',
        BASE_PATH,
        params
      )

      pp object
      puts "**** Criado customer no iugu ****"

      object
    end
  end
end
