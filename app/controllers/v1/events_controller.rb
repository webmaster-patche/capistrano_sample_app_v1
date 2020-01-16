class V1::EventsController < ModelBaseController
  def strong_param_pattern
    %I[game description event_date join_limit latitude longitude]
  end
end
