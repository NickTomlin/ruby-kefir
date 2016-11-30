require 'YAML'
require 'tmpdir'
require 'fileutils'

RSpec.describe Kefir do
  describe Kefir::Config do
    let(:store_double) { double(Kefir::FileStore, read: {}, write: nil) }
    let(:config) { Kefir::Config.new(store_double, {}) }

    describe 'initialize' do
      it 'accepts a default option that shallowly merges with config' do
        store = double(Kefir::FileStore, read: { should_change: 'change_me', should_stay: 'immortal' }, write: nil)
        options = {
          defaults: {
            should_change: 'changed!'
          }
        }
        config = Kefir::Config.new(store, options)

        expect(config.get(:should_change)).to eq('changed!')
        expect(config.get(:should_stay)).to eq('immortal')
      end
    end

    it 'includes enumerable methods' do
      config.set(foo: 'hay', biz: 'needle')

      expect(config.any? { |_, v| v == 'needle' }).to eq(true)
      expect(config.count).to eq(2)
    end

    describe 'set' do
      it 'sets config' do
        config.set(:foo, 'bar')

        expect(config.get(:foo)).to eq('bar')
      end

      it 'accepts a hash' do
        config.set(foo: 'bar', biz: 'baz', hsh: { nested: 'value' })

        expect(config.get(:hsh)).to eq(nested: 'value')
      end

      it 'raises an error if less than two arguments are supplied' do
        expect do
          config.set(:foo)
        end.to raise_exception(ArgumentError, 'Kefir::Config.set accepts a hash or key(s) and value')
      end

      it 'handles nested config values' do
        config.set(:my, :nested, :value, 'hello')

        expect(config.get(:my, :nested, :value)).to eq('hello')
      end

      it 'handles array indexes' do
        config.set(:nested, :array, [])
        config.set(:nested, :array, 0, 'hello')

        expect(config.get(:nested, :array, 0)).to eq('hello')
      end

      it 'handles a mixture of symbols and strings' do
        config.set(:one, 'two', 'boo')

        expect(config.get(:one, 'two')).to eq('boo')
      end
    end

    describe 'to_s' do
      it 'stringifies as the value of it\'s config hash' do
        config.set(:one, :two, 'bar')

        expect(config.to_s).to eq('{:one=>{:two=>"bar"}}')
      end
    end

    describe 'to_h' do
      it 'provides access to the underlying hash' do
        config.set(:one, 'bar')

        expect(config.to_h).to eq(one: 'bar')
      end
    end

    describe 'persist' do
      it 'persists data to a store' do
        expect(store_double).to receive(:write).with(one: { two: 'bar' })

        config.set(:one, :two, 'bar')
        config.persist
      end
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

    it 'returns a fully functioning config object that can read config' do
      allow(File).to receive(:read).and_yield("user: bob\napi_key: secret-value")

      config = Kefir.config('test')

      expect(config.get('user')).to eq('bob')
    end

    it 'returns a fully functioning config object that can write config' do
      allow(File).to receive(:read).and_yield("user: bob\napi_key: secret-value")
      expect(File).to receive(:write)

      config = Kefir.config('test')
      config.persist
    end
  end
end
