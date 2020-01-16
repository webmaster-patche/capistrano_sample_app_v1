class Slack::EventsController < ModelBaseController

  def show
    render json: {id: @model.id}, status: :ok
  end

  def create
    @model.assign_attributes(test: @permit_params[:test])
    @model.save!
    render json: {id: @model.id, test: @model.test, challenge: @permit_params[:challenge]}, status: :ok
  end

  private
    # symbolize_key
    def strong_param_pattern
      %I[game description event_date join_limit latitude longitude]
    end
end
