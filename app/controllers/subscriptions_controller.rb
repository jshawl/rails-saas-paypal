class SubscriptionsController < ApplicationController
  skip_before_action :verify_authenticity_token
  def create
    fname = params[:txn_type] + '-' + Time.now.to_i.to_s + '.json'
    File.write(Rails.root.join('public', fname), params.to_json)
    if params[:txn_type] == 'subscr_payment'
      @user = User.find(params[:custom])
      @plan = Plan.find_by(price: params[:mc_gross].to_f)
      @subscription = Subscription.create!(plan: @plan, user: @user)
    end
    render nothing: true
  end
end
