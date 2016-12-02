RSpec.describe Kefir::FileStore do
  let(:data) do
    {
      secret: 'dont tell',
      users: [{ name: 'bob' }, { name: 'jane' }]
    }
  end

  let(:file_path) { File.join(@temp_dir, 'config.yml') }

  before(:each) do
    @temp_dir = Dir.mktmpdir
  end

  after(:each) do
    FileUtils.remove_dir(@temp_dir)
  end

  it 'gives its path' do
    store = Kefir::FileStore.new(cwd: @temp_dir, config_name: 'config.yml')
    expect(store.path).to eq(File.join(@temp_dir, 'config.yml'))
  end

  it 'reads a configuration file' do
    File.write(file_path, YAML.dump(data))
    Kefir::FileStore.new(cwd: @temp_dir, config_name: 'config.yml')
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
    store = Kefir::FileStore.new(cwd: @temp_dir, config_name: 'config.yml')
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

  it 'returns an empty hash when file is empty' do
    FileUtils.touch(file_path)
    store = Kefir::FileStore.new(cwd: @temp_dir, config_name: 'config.yml')
    expect(store.read).to eq({})
  end

  it 'creates nonexistant directories' do
    nonexistant_path = File.join(@temp_dir, 'cool/beans')
    Kefir::FileStore.new(
      cwd: nonexistant_path,
      config_name: 'config.yml'
    ).read
    expect(File.directory?(nonexistant_path)).to eq(true)
  end

  it 'returns an empty hash when reading nonexistant files' do
    store = Kefir::FileStore.new(
      cwd: @temp_dir,
      config_name: 'config.yml'
    )

    expect(store.read).to eq({})
  end

  it 'succesfully writes to nonexistant files' do
    store = Kefir::FileStore.new(
      cwd: @temp_dir,
      config_name: 'config.yml'
    )

    store.write(foo: 'bar')

    expect(YAML.load_file(File.join(@temp_dir, 'config.yml'))).to eq(foo: 'bar')
  end
end
