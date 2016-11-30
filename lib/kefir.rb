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
    include Enumerable

    def each(&block)
      @config.each(&block)
    end

    def initialize(store, options)
      @store = store
      @options = options
    end

    def config
      @config ||= @store.read.merge!(@options.fetch(:defaults, {}))
    end

    def persist
      @store.write(config)
    end

    def set(*paths)
      if paths.first.is_a?(Hash)
        config.merge!(paths.first)
      elsif paths.size >= 2
        deep_set(config, paths)
      else
        raise ArgumentError.new, 'Kefir::Config.set accepts a hash or key(s) and value'
      end

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

    private

    def deep_set(hash, paths)
      value = paths.pop
      *keys, last_key = paths

      nested = keys.inject(hash) do |h, key|
        h[key] = {} unless h[key]
        h[key]
      end

      nested[last_key] = value unless nested.nil?
    end
  end

  def self.config(namespace, options = {})
    raise MissingNamespaceError, 'You must supply a namespace for your configuration files' if namespace.nil? || namespace.empty?

    config_file_path = EnvPaths.get(namespace).config
    store = FileStore.new(config_file_path)

    Config.new(store, options)
  end
end
