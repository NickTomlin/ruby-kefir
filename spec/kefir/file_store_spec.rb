RSpec.describe Kefir::FileStore do
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
