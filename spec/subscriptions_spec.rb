describe SubscriptionsController, type: :controller do
  describe "IPN" do
    before do
      @user = User.create! email: 'wow@wow.com', password: 'wowywow'
      @plan = Plan.create!(price:1.99)
    end
    it "receives subscription payments" do
      expect(@user.subscription).to be(nil)
      payload = File.read(Rails.root.join('public', 'payment.json'))
      post :create, params: JSON.parse(payload)
      @user.reload
      expect(@user.subscription.plan).to eq(@plan)
    end
    it "receives subscription cancellations" do
      Subscription.create!(user:@user, plan: @plan)
      payload = File.read(Rails.root.join('public', 'subscr_cancel.json'))
      post :create, params: JSON.parse(payload)
      @user.reload
      expect(@user.subscription).to be(nil)
    end
  end
end
