# Simple SaaS App

Let's build a recurring revenue application with PayPal

## Assumed

A ruby on rails application with two disconnected models:

- Users
  - Email
  - Password
- Plans
  - Title
  - Description
  - Price

For this application, we'll be selling a monthly subscription for motivational
text messages. We'll have three plans:

1. Acquaintance
 - 1 motivational text message a month
 - $1.99
2. Friend
 - 1 motivational text message a week
 - $5.99
3. BFFL
 - 1 motivational text message a day
 - $10.99

Users can sign up and log in. The plans will be seeded in the database, and the list
of them will be what users see on the home page.

## Creating a Subscription Model

In order to track who has which plan, we'll create a `Subscription` model with
the following fields:

- `plan_id`
  - the corresponding `Plan` id
- `active`
  - boolean on whether or not the user's subscription is active
- `user_id`
  - the corresponding `User` id
-  `payer_id`
  - just in case we need to look up a transaction on paypal

## Preparing PayPal

Log in to https://developer.paypal.com/developer/accounts/create and create two test
accounts:

1. A Buyer account
  - give them enough money to subscribe
  - user: jesse+buyer@updog.co
  - pass: jessebuyer
2. A Seller account
  - user: jesse+seller@updog.co
  - pass: jesseseller

Log in to sandbox.paypal.com as the seller

click my business setup on the far right:

![](https://jesse.sh/ots/2017/03-27-c177.png)

click profile in the top right:

![](https://jesse.sh/ots/2017/03-27-5d13.png)

click on paypal buttons under tools in the top menu:

![](https://jesse.sh/ots/2017/03-27-09d2.png)

[Create a new button](https://www.sandbox.paypal.com/cgi-bin/webscr?cmd=_button-management) for each plan:

under advanced options add:

```txt
notify_url=urlforipnnotify
modify=1
```

```html
<form action="https://www.sandbox.paypal.com/cgi-bin/webscr" method="post" target="_top">
  <input type="hidden" name="cmd" value="_s-xclick">
  <input type="hidden" name="hosted_button_id" value="429L2XFYT7EFG">
  <input type="image" src="https://www.sandbox.paypal.com/en_US/i/btn/btn_subscribeCC_LG.gif" border="0" name="submit" alt="PayPal - The safer, easier way to pay online!">
  <img alt="" border="0" src="https://www.sandbox.paypal.com/en_US/i/scr/pixel.gif" width="1" height="1">
</form>
```

I used ngrok to make this happen

You'll be able to make a purchase now, but there's currently a couple of issues:

1. No way to say who made the purchase(user_id)
2. User needs to be logged in to purchase
3. Paypal needs to know where to send transaction notifications via webhooks

## Handling the current user

We can send custom info to paypal using `custom` as a hidden input.

```html
<input type='hidden' name='custom' value='<%= current_user.id %>'
```  

## Handling IPN Notifications

Create a resource for subscriptions

```rb
# config/routes.rb
resources :subscriptions
```

Create a controller for subscriptions and use `File.write` to view the IPN sent
from PayPal.

```rb
class SubscriptionsController < ApplicationController
  skip_before_action :verify_authenticity_token
  def create
    fname = Time.now.to_i.to_s + '.json'
    File.write(Rails.root.join('public', fname), params.to_json)
    render nothing: true
  end
end
```

Because a bunch of JSON comes back in the IPN notification, we’ll use a little
Ruby to parse this out within the create method:

```rb
if params[:txn_type] == 'subscr_payment'
  @user = User.find(params[:custom])
  @plan = Plan.find_by(price: params[:mc_gross].to_f)
  @subscription = Subscription.create!(plan: @plan, user: @user)
end
```

This feels a little smelly to me - if the price changes, we're going to have to
change it in multiple places. Oh well, onwards.

Now that we can create a subscription for a user, we need to modify the outputted
HTML to allow the user to unsubscribe:

```
<% if current_user.subscription && current_user.subscription.plan == plan %>
  <A HREF="https://www.sandbox.paypal.com/cgi-bin/webscr?cmd=_subscr-find&alias=YL54KKM5RH2VS">
    <IMG SRC="https://www.sandbox.paypal.com/en_US/i/btn/btn_unsubscribe_LG.gif" BORDER="0">
  </A>
<% else %>
```

Yes, PayPal did generate the above HTML with uppercase tag names.

Just need to handle the IPN notification when a user cancels a subscription.

![](https://jesse.sh/ots/2017/03-28-4b6d.png)
