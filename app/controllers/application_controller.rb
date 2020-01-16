class ApplicationController < ActionController::API
  # Action Filter
  before_action :permit_param, only: [:index, :create, :show, :update, :destroy]
  before_action :new_model, only: [:create]
  before_action :find_model, only: [:show, :update, :destroy]

  # Rescue Handler
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ArgumentError, with: :bad_request
  rescue_from NoMethodError, with: :no_method_error

  def render_json
    render json: @model, status: :ok
  end

  def bad_request
    render json: { "BadRequest" => + params.to_s }, status: :bad_request
  end

  def record_not_found
    render json: @model.errors, status: :not_found
  end
  
  # undefined method for...
  def no_method_error(e = nil)
    render json: e.message, status: :internal_server_error
  end

  private

    def permit_param
      @permit_params = params.permit(strong_param_pattern)
    end

    def strong_param_pattern
      %I[id]
    end

    def find_model
      @model = "#{controller_name.singularize.camelize}".safe_constantize.find(@permit_params[:id])
    end

    def new_model
      @model = "#{controller_name.singularize.camelize}".safe_constantize&.new(@permit_param)
    end

end
