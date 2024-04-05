# A relation of workers.
#
# Relations are enumerable, so you can use +Enumerable+ methods on them.
# Notice however that using these methods will imply loading all the relation
# in memory, which could introduce performance concerns.
class MissionControl::Jobs::WorkersRelation
  include Enumerable

  PROPERTIES = %i[ offset_value limit_value hostname name ]
  attr_reader *PROPERTIES

  delegate :last, :[], :to_s, :reverse, to: :to_a

  ALL_WORKERS_LIMIT = 100_000_000 # When no limit value it defaults to "all workers"

  def initialize(queue_adapter:)
    @queue_adapter = queue_adapter

    set_defaults
  end

  def where(name: nil, hostname: nil)
    # Remove nil arguments to avoid overriding parameters when concatenating +where+ clauses
    arguments = {
      hostname: hostname,
      name: name
    }.compact.collect { |key, value| [ key, value.to_s ] }.to_h

    clone_with **arguments
  end

  def offset(offset)
    clone_with offset_value: offset
  end

  def limit(limit)
    clone_with limit_value: limit
  end

  def each(&block)
    workers.each(&block)
  end

  def reload
    @count = @workers = nil
    self
  end

  def count
    if loaded?
      to_a.length
    else
      query_count
    end
  end

  def empty?
    count == 0
  end

  alias length count
  alias size count

  private
    attr_writer *PROPERTIES

    def set_defaults
      self.offset_value = 0
      self.limit_value = ALL_WORKERS_LIMIT
    end

    def workers
      @workers ||= @queue_adapter.fetch_workers(self)
    end

    def query_count
      @count ||= @queue_adapter.count_workers(self)
    end

    def loaded?
      !@workers.nil?
    end

    def clone_with(**properties)
      dup.reload.tap do |relation|
        properties.each do |key, value|
          relation.send("#{key}=", value)
        end
      end
    end
end
