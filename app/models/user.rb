class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  devise :omniauthable

  def self.find_for_facebook_oauth(auth, signed_in_resource=nil)
    user = User.where(:provider => auth.provider, :uid => auth.uid).first
    if user
      return user
    else
      registered_user = User.where(:email => auth.info.email).first
      if registered_user
        return registered_user
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
  end
end
