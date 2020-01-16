require "rails_helper"

RSpec.describe V1::EventsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/v1/events").to route_to("v1/events#index")
    end

    it "routes to #show" do
      expect(:get => "/v1/events/1").to route_to("v1/events#show", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/v1/events").to route_to("v1/events#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/v1/events/1").to route_to("v1/events#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/v1/events/1").to route_to("v1/events#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/v1/events/1").to route_to("v1/events#destroy", :id => "1")
    end
  end
end
