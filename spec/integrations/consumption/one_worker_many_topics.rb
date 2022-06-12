# frozen_string_literal: true

# Karafka should be able to consume multiple topics with one worker

setup_karafka do |config|
  config.concurrency = 1
end

topic1 = DataCollector.topics[0]
topic2 = DataCollector.topics[1]

class Consumer1 < Karafka::BaseConsumer
  def consume
    messages.each do
      DataCollector[Thread.current.object_id] << true
    end
  end
end

class Consumer2 < Karafka::BaseConsumer
  def consume
    messages.each do
      DataCollector[Thread.current.object_id] << true
    end
  end
end

draw_routes do
  consumer_group DataCollector.consumer_group do
    topic topic1 do
      consumer Consumer1
    end

    topic topic2 do
      consumer Consumer2
    end
  end
end

10.times { produce(topic1, SecureRandom.uuid) }
10.times { produce(topic2, SecureRandom.uuid) }

start_karafka_and_wait_until do
  DataCollector.data.values.flatten.size >= 20
end

assert_equal 1, DataCollector.data.keys.uniq.size
assert_equal 20, DataCollector.data.values.flatten.size