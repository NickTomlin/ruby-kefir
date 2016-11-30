require 'dig_rb'
require 'env_paths'
require 'YAML'
require 'kefir/version'
require 'kefir/config'
require 'kefir/file_store'

module Kefir
  class MissingNamespaceError < StandardError; end

  def self.config(namespace, options = {})
    raise MissingNamespaceError, 'You must supply a namespace for your configuration files' if namespace.nil? || namespace.empty?

    config_file_path = EnvPaths.get(namespace).config
    store = FileStore.new(config_file_path)

    Config.new(store, options)
  end
end
