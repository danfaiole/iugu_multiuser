# frozen_string_literal: true

require_relative "iugu_multiuser/version"

module IuguMultiuser
  class NotFound < StandardError; end

  class ParamError < StandardError; end

  class ValidationError < StandardError; end

  class MissingApiKeyError < StandardError; end

  class RequestError < StandardError; end

  class ParserError < StandardError; end
end
