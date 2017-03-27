class SubscriptionsController < ApplicationController
  skip_before_action :verify_authenticity_token
  def create
    fname = Time.now.to_i.to_s + '.json'
    File.write(Rails.root.join('public', fname), params.to_json)
    render nothing: true
  end
end
