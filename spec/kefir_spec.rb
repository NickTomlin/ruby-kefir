require 'YAML'
require 'tmpdir'
require 'fileutils'

RSpec.describe Kefir do
  describe Kefir::Config do
    let(:store_double) { double(Kefir::FileStore, :read => {}, :write => nil) }
    let(:config) { Kefir::Config.new(store_double) }

    it 'sets config' do
      config.set(:foo, 'bar')

      expect(config.get(:foo)).to eq('bar')
    end

    it 'raises an error if less than two arguments are supplied' do
      expect do
        config.set(:foo)
      end.to raise_exception(ArgumentError, 'Kefir::Config.set requires at least one path and value')
    end

    it 'handles nested config values' do
      config.set(:one, :two, 'bar')

      expect(config.get(:one, :two)).to eq('bar')
    end

    it 'handles array indexes' do
      config.set(:nested, :array, [])
      config.set(:nested, :array, 0, 'hello')

      expect(config.get(:nested, :array, 0)).to eq('hello')
    end

    it 'stringifies as the value of it\'s config hash' do
      config.set(:one, :two, 'bar')

      expect(config.to_s).to eq('{:one=>{:two=>"bar"}}')
    end

    it 'handles a mixture of symbols and strings' do
      config.set(:one, 'two', 'boo')

      expect(config.get(:one, 'two')).to eq('boo')
    end

    it 'persists data to a store' do
      expect(store_double).to receive(:write).with(one: { two: 'bar' })

      config.set(:one, :two, 'bar')
      config.store
    end
  end

  describe Kefir::FileStore do
    let(:data) { { secret: 'dont tell', users: [{ name: 'bob' }, { name: 'jane' }] } }
    let(:file_path) { File.join(@temp_dir, 'config') }

    before(:each) do
      @temp_dir = Dir.mktmpdir
    end

    after(:each) do
      FileUtils.remove_dir(@temp_dir)
    end

    it 'reads a configuration file' do
      File.write(file_path, YAML.dump(data))
      Kefir::FileStore.new(file_path)
      parsed = YAML.load_file(file_path)

      expect(parsed).to eq(
        secret: 'dont tell',
        users: [
          { name: 'bob' },
          { name: 'jane' }
        ]
      )
    end

    it 'writes to a configuration file' do
      File.write(file_path, YAML.dump(data))
      store = Kefir::FileStore.new(file_path)

      store.write(data.merge(secret: 'changed'))

      parsed = YAML.load_file(file_path)

      expect(parsed).to eq(
        secret: 'changed',
        users: [
          { name: 'bob' },
          { name: 'jane' }
        ]
      )
    end
  end

  describe '.config' do
    it 'throws an error if no namespace is provided' do
      expect do
        Kefir.config(nil)
      end.to raise_exception(Kefir::MissingNamespaceError)
    end

    it 'throws an error if an empty namespace is provided' do
      expect do
        Kefir.config('')
      end.to raise_exception(Kefir::MissingNamespaceError)
    end
  end
end
