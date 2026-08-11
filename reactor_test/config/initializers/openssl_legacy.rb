# frozen_string_literal: true

require "openssl"
OpenSSL::Provider.load("legacy") if OpenSSL::Provider.respond_to?(:load)
