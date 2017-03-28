describe SubscriptionsController, type: :controller do
  describe "IPN" do
    it "receives subscription payments" do
      @user = User.create! email: 'wow@wow.com', password: 'wowywow'
      @plan = Plan.create!(price:1.99)
      expect(@user.subscription).to be(nil)
      payload = File.read(Rails.root.join('public', 'payment.json'))
      post :create, params: JSON.parse(payload)
      @user.reload
      expect(@user.subscription.plan).to eq(@plan)
    end
  end
end
