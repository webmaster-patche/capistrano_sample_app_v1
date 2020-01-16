class ModelBaseController < ApplicationController
  # Action Filter
  #after_action :render_json, only: [:index, :create, :show, :update, :destroy]

  def index
    render_json
  end

  def create
    @model.assign_attributes(@permit_params)
    @model.save!
    render_json
  end

  def show
    @model.find(@permit_params[:id])
    render_json
  end

  def update
    @model.assign_attributes(@permit_params)
    @model.update!
    render_json
  end

  def destroy
    @model.destroy
    render_json
  end
end
