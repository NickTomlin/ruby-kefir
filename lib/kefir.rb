require 'kefir/version'
require 'dig_rb'
require 'env_paths'
require 'YAML'

module Kefir
  class MissingNamespaceError < StandardError; end

  class FileStore
    def initialize(config_file_path)
      @config_path = config_file_path
    end

    def read
      File.read(@config_path) do |contents|
        YAML.load(contents)
      end
    end

    def write(data)
      File.write(@config_path, YAML.dump(data))
    end
  end

  class Config
    def initialize(store)
      @store = store
    end

    def config
      @config ||= @store.read
    end

    def persist
      @store.write(config)
    end

    def set(*paths)
      raise ArgumentError.new, 'Kefir::Config.set requires at least one path and value' if paths.size < 2
      value = paths.pop
      *keys, last_key = paths

      nested = keys.inject(config) do |config, key|
        config[key] = {} unless config[key]
        config[key]
      end

      nested[last_key] = value unless nested.nil?

      config
    end

    def get(*paths)
      config.dig(*paths)
    end

    def to_s
      config.to_s
    end

    def to_h
      config.dup
    end
  end

  def self.config(namespace)
    raise MissingNamespaceError, 'You must supply a namespace for your configuration files' if namespace.nil? || namespace.empty?

    config_file_path = EnvPaths.get(namespace).config
    store = FileStore.new(config_file_path)

    Config.new(store)
  end
end
