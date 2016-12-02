require 'dig_rb'
require 'fileutils'
require 'env_paths'
require 'yaml'
require 'kefir/version'
require 'kefir/config'
require 'kefir/file_store'

module Kefir
  class MissingNamespaceError < StandardError; end

  DEFAULT_OPTIONS = {
    config_name: 'config.yml'
  }.freeze

  def self.config(namespace, options = {})
    raise MissingNamespaceError, 'You must supply a namespace for your configuration files' if namespace.nil? || namespace.empty?

    parsed_options = parse_options(namespace, options)
    store = FileStore.new(parsed_options)

    Config.new(store, options)
  end

  private_class_method

  def self.parse_options(namespace, options)
    parsed = DEFAULT_OPTIONS.merge(options)
    parsed[:cwd] = parsed.fetch(:cwd, EnvPaths.get(namespace).config)
    parsed
  end
end
