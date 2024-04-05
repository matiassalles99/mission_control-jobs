class MissionControl::Jobs::WorkersController < MissionControl::Jobs::ApplicationController
  include MissionControl::Jobs::WorkerFilters

  before_action :ensure_exposed_workers

  def index
    @workers_page = MissionControl::Jobs::Page.new(workers_relation, page: params[:page].to_i)
    @workers_count = @workers_page.total_count
  end

  def show
    @worker = MissionControl::Jobs::Current.server.find_worker(params[:id])
  end

  private
    def ensure_exposed_workers
      unless workers_exposed?
        redirect_to root_url, alert: "This server doesn't expose workers"
      end
    end

    def workers_relation
      MissionControl::Jobs::Current.server.workers_relation.where(**@worker_filters)
    end
end
