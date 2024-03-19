require 'spec_helper'

describe Steno::Logger do
  let(:logger) { Steno::Logger.new('test', []) }

  it 'provides #level, #levelf, and #level? methods for each log level' do
    Steno::Logger::LEVELS.each do |name, _|
      [name, name.to_s + 'f', name.to_s + '?'].each do |meth|
        expect(logger.respond_to?(meth)).to be_truthy
      end
    end
  end

  describe '#level_active?' do
    it 'returns a boolean indicating if the level is enabled' do
      expect(logger.level_active?(:error)).to be_truthy
      expect(logger.level_active?(:info)).to be_truthy
      expect(logger.level_active?(:debug)).to be_falsey
    end
  end

  describe '#<level>?' do
    it 'returns a boolean indiciating if <level> is enabled' do
      expect(logger.error?).to be_truthy
      expect(logger.info?).to be_truthy
      expect(logger.debug?).to be_falsey
    end
  end

  describe '#level' do
    it 'returns the name of the currently active level' do
      expect(logger.level).to eq(:info)
    end
  end

  describe '#level=' do
    it 'allows the level to be changed' do
      logger.level = :warn
      expect(logger.level).to eq(:warn)
      expect(logger.level_active?(:info)).to be_falsey
      expect(logger.level_active?(:warn)).to be_truthy
    end
  end

  describe '#log' do
    let(:sink) { instance_double(Steno::Sink::Base) }
    let(:logger) { Steno::Logger.new('test', [sink]) }

    before do
      allow(sink).to receive(:add_record)
    end

    it 'does not forward any messages for levels that are inactive' do
      logger.debug('test')

      expect(sink).not_to have_received(:add_record)
    end

    it 'forwards messages for levels that are active' do
      logger.warn('test')

      expect(sink).to have_received(:add_record).with(any_args)
    end

    it 'does not invoke a supplied block if the level is inactive' do
      invoked = false
      logger.debug { invoked = true }
      expect(invoked).to be_falsey
    end

    it 'invokes a supplied block if the level is active' do
      invoked = false
      logger.warn { invoked = true }
      expect(invoked).to be_truthy
    end

    it 'creates a record with the proper level' do
      expect(Steno::Record).to receive(:new).with('test', :warn, 'message', anything, anything).and_call_original

      logger.warn('message')
    end

    it 'includes the location where the record was generated' do
      location = [__FILE__, an_instance_of(Integer), 'log']
      expect(Steno::Record).to receive(:new).with('test', :warn, 'message', location, anything).and_call_original

      def log(logger)
        logger.warn('message')
      end

      log(logger)
    end

    describe 'option :ignored_locations' do
      let(:logger) { Steno::Logger.new('test', [sink], ignored_locations: ignored_locations) }
      let(:callstack) do
        [
          '/path/to/lib/steno/logger.rb:12:in `block in define_log_method`',
          '/path/to/another_file.rb:34:in `yet_another_method`',
          '/path/to/some_file.rb:56:in `another_method`',
          '/path/to/some_file.rb:78:in `some_method`',
          '/path/to/program.rb:90:in `<main>'
        ]
      end

      before do
        allow(Kernel).to receive(:caller).and_return(callstack)
      end

      context 'when ignoring a file' do
        let(:ignored_locations) { /another_file\.rb/ }

        it 'includes the next file as location' do
          location = ['/path/to/some_file.rb', 56, 'another_method']
          expect(Steno::Record).to receive(:new).with('test', :warn, 'message', location, anything).and_call_original

          logger.warn('message')
        end
      end

      context 'when ignoring multiple files and methods' do
        let(:ignored_locations) { /(another_file\.rb|some_file\.rb.*another_method)/ }

        it 'includes the next file/method as location' do
          location = ['/path/to/some_file.rb', 78, 'some_method']
          expect(Steno::Record).to receive(:new).with('test', :warn, 'message', location, anything).and_call_original

          logger.warn('message')
        end
      end

      context 'when regex is too broad' do
        let(:ignored_locations) { /.*/ }

        it 'still includes a location (the last one) and does not fail' do
          location = [an_instance_of(String), an_instance_of(Integer), an_instance_of(String)]
          expect(Steno::Record).to receive(:new).with('test', :warn, 'message', location, anything).and_call_original

          logger.warn('message')
        end
      end
    end
  end

  describe '#logf' do
    it 'formats messages according to the supplied format string' do
      expect(logger).to receive(:log).with(:debug, 'test 1 2.20')
      logger.debugf('test %d %0.2f', 1, 2.2)
    end
  end

  describe '#tag' do
    it 'returns a tagged logger' do
      tagged_logger = logger.tag('foo' => 'bar')
      expect(tagged_logger).not_to be_nil
      expect(tagged_logger.user_data).to eq({ 'foo' => 'bar' })
    end
  end
end
