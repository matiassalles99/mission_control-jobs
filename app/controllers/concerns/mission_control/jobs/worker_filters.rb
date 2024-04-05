module MissionControl::Jobs::WorkerFilters
  extend ActiveSupport::Concern

  included do
    before_action :set_filters

    helper_method :active_filters?
  end

  private

  def set_filters
    @worker_filters ||= { hostname: params.dig(:filter, :hostname).presence, name: params.dig(:filter, :name).presence }.compact
  end
end
