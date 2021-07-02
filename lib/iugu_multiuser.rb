# frozen_string_literal: true

require_relative "iugu_multiuser/version"

module IuguMultiuser
  class Error < StandardError; end

  class NotFound < StandardError; end

  class ParamError < StandardError; end

  class ValidationError < StandardError; end

  class MissingApiKeyError < StandardError; end

  class RequestError < StandardError; end


  # Your code goes here...
end
