# frozen_string_literal: true

RSpec.describe Karafka::Schemas::Config do
  let(:schema) { described_class }

  let(:config) do
    {
      name: 'name',
      topic_mapper: Karafka::Routing::Mapper,
      redis: { url: 'url' }
    }
  end

  context 'config is valid' do
    it { expect(schema.call(config).success?).to be_truthy }
  end

  context 'name validator' do
    it 'name is nil' do
      config[:name] = nil
      expect(schema.call(config).success?).to be_falsey
    end

    it 'name is not a string' do
      config[:name] = 2
      expect(schema.call(config).success?).to be_falsey
    end
  end

  context 'redis validator' do
    before do
      config[:redis] = { url: 'url' }
    end

    context 'inline_mode is true' do
      before do
        config[:inline_mode] = true
      end

      it 'redis is nil' do
        config[:redis] = nil
        expect(schema.call(config).success?).to be_truthy
      end
    end

    context 'inline_mode is false' do
      before do
        config[:inline_mode] = false
      end

      it 'redis is nil' do
        config[:redis] = nil
        expect(schema.call(config).success?).to be_falsey
      end

      context 'redis is a hash' do
        context 'url validator' do
          it 'url is nil' do
            config[:redis][:url] = nil
            expect(schema.call(config).success?).to be_falsey
          end

          it 'url is not a string' do
            config[:redis][:url] = 2
            expect(schema.call(config).success?).to be_falsey
          end
        end
      end
    end
  end

  context 'connection_pool validator' do
    it 'connection_pool is nil' do
      config[:connection_pool] = nil
      expect(schema.call(config).success?).to be_falsey
    end

    it 'connection_pool is not a hash' do
      config[:connection_pool] = 2
      expect(schema.call(config).success?).to be_falsey
    end

    context 'connection_pool is a hash' do
      before do
        config[:connection_pool] = { size: 1, timeout: 2 }
      end

      context 'size validator' do
        it 'size is nil' do
          config[:connection_pool][:size] = nil
          expect(schema.call(config).success?).to be_falsey
        end
      end

      context 'timeout validator' do
        it 'timeout is nil' do
          config[:connection_pool][:timeout] = nil
          expect(schema.call(config).success?).to be_falsey
        end

        it 'timeout is not a hash' do
          config[:connection_pool][:timeout] = 's'
          expect(schema.call(config).success?).to be_falsey
        end
      end
    end
  end
end
