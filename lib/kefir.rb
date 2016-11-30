require 'dig_rb'
require 'env_paths'
require 'YAML'
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
    store = FileStore.new(parsed_options[:config_file_path])

    Config.new(store, options)
  end

  private_class_method

  def self.parse_options(namespace, options)
    parsed = DEFAULT_OPTIONS.merge(options)
    cwd = parsed.fetch(:cwd, EnvPaths.get(namespace).config)
    parsed[:config_file_path] = File.expand_path(parsed[:config_name], cwd)

    parsed
  end
end
