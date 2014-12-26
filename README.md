Here is an example to demonstrate how to integrate Facebook connect with devise authentication in a rails 4 app.

Step:1 - Add the gems in your gem file.
gem ‘devise’
gem 'omniauth'
gem 'omniauth-facebook' 
Run the “bundle install” command to install the gem.

Step:2 - Define your root url like below

root :to => “home#index”

Step:3 - Run command - rails generate devise:install

This generator will install all Devise configurations.Take a look at them.

Step:4 - Add Devise users models using the generator:

rails generate devise User

This generator creates a few interesting things: a model file, a migration and a devise_for route.

Step:5 - Go the user model “user.rb” and add the following line

devise : omniauthable

Step:6 - Run the migrate command to insert the User table in your database.

rake db:migrate

It’ll insert the Users table with some columns.

Step:7 - You need two more columns to store provider type and userid given from facebook

rails g migration AddProviderToUsers provider:string uid:string

Runt rake db:migrate to insert the columns in users table.

Step:8 - You need to create an application in facebook to get “App-ID” and “App Secret”

https://developers.facebook.com/

Create an app and get the App id and secret key.

Go to app basic setting and find Website with Facebook Login and enter your site URL -  http://localhost:3000/

Step:9 - Declare the provider name and app id and key.

Go to the file config/initializers/devise.rb and the following line

require "omniauth-facebook"

config.omniauth :facebook, "APP_ID", "APP_SECRET"

Step:10 - Change in devise.rb

devise_for :users, :controllers => { : omniauth_callbacks => "omniauth_callbacks" }

Step:11 - Go to your layout file and the following block
```
<% if user_signed_in? %>
    Signed in as <%= current_user.name %>. Not you?
    <%= link_to "Sign out", destroy_user_session_path,:method => :delete %>
<% else %>
    <%= link_to "Sign in with Facebook", user_omniauth_authorize_path(:facebook) %>
<% end %>
```
When the user clicks on Sign in with Facebook link, they will redirects to the Facebook login page, after entering their credentials it will again redirect the user back to the applications Callback method .

Step:12 - Create a new controller named as “omniauth_callbacks_controller.rb”.Add the following method in it.
```
class OmniauthCallbacksController < Devise::OmniauthCallbacksController   
  def facebook     
       @user = User.find_for_facebook_oauth(request.env["omniauth.auth"], current_user)      
       if @user.persisted?       
        sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
        set_flash_message(:notice, :success, :kind => "Facebook") if is_navigational_format?
      else
        session["devise.facebook_data"] = request.env["omniauth.auth"]
        redirect_to new_user_registration_url
      end
  end
end
```

Step:13 - Add the following block in your user model.
```
def self.find_for_facebook_oauth(auth, signed_in_resource=nil)
     user = User.where(:provider => auth.provider, :uid => auth.uid).first
     if user
         return user
     else
         params = ActionController::Parameters.new({
          user: {
            name:auth.extra.raw_info.name,
            provider:auth.provider,
            uid:auth.uid,
            email:auth.info.email,
            password:Devise.friendly_token[9,20]
          }
          })
        user = params.require(:user).permit(:name, :provider, :uid, :email, :password)
        User.create(user)
     end
end
```
