module Kefir
  class FileStore
    attr_reader :path

    def initialize(options = {})
      @dir = options[:cwd]
      @path = File.expand_path(options[:config_name], @dir)
    end

    def read
      FileUtils.mkdir_p(@dir)
      YAML.load_file(@path) || {}
    rescue Errno::ENOENT
      {}
    end

    def write(data)
      FileUtils.mkdir_p(@dir)
      File.write(@path, YAML.dump(data))
    end
  end
end
