module Kefir
  class FileStore
    attr_reader :path

    def initialize(config_file_path)
      @path = config_file_path
    end

    def read
      File.read(@path) do |contents|
        YAML.load(contents)
      end
    end

    def write(data)
      File.write(@path, YAML.dump(data))
    end
  end
end
