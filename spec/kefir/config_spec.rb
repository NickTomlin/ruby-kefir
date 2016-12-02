RSpec.describe Kefir::Config do
  let(:store_double) do
    double(Kefir::FileStore, read: {}, write: nil, path: 'custom_path')
  end
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

  describe 'empty!' do
    it 'empties config' do
      config.set(foo: 'hay', biz: 'needle')
      expect(config.count).to eq(2)
      config.empty!
      expect(config.count).to eq(0)
    end
  end

  describe 'path' do
    it 'returns the path of its store' do
      store = double(Kefir::FileStore, path: '/config/path')
      config = Kefir::Config.new(store, {})

      expect(config.path).to eq('/config/path')
    end
  end

  context 'methods delegated to config hash' do
    it 'allows inspection via key?' do
      config.set(:one, 'one')

      expect(config.key?(:one)).to eq(true)
    end

    it 'allows for the deletion of items via delete' do
      config.set(one: 'one', two: 'two')
      expect(config.key?(:one)).to eq(true)
      config.delete(:one)

      expect(config.to_h).to eq(two: 'two')
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
