RSpec.describe Kefir do
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

    context 'options' do
      it 'provides defaults' do
        expect(File).to receive(:read).with(/config\.yml$/).and_yield("user: bob\napi_key: secret-value")
        config = Kefir.config('test')
        config.get(:foo)
      end

      it 'allows overriding current directory' do
        custom_cwd = File.expand_path('custom/path', '/')
        expect(File).to receive(:read).with(File.join(custom_cwd, 'config.yml')).and_yield("user: bob\napi_key: secret-value")

        config = Kefir.config('test', cwd: custom_cwd)
        config.get(:foo)
      end

      it 'allows overriding the :config_name' do
        custom_cwd = File.expand_path('custom/path', '/')
        expect(File).to receive(:read).with(File.join(custom_cwd, 'custom_config_name.yml')).and_yield("user: bob\napi_key: secret-value")

        config = Kefir.config('test', cwd: custom_cwd, config_name: 'custom_config_name.yml')
        config.get(:foo)
      end
    end
  end
end
