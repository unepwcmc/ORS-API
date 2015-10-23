class User < ActiveRecord::Base

  has_many :assignments, dependent: :destroy #=> many-to-many relation with roles
  has_many :roles, through: :assignments

  acts_as_authentic do |c|
    c.login_field = 'email'
  end

  def generate_authentication_token
    token = loop do
      t = SecureRandom.base64.tr('+/=', 'Qrt')
      break t unless User.exists?(single_access_token: t)
    end
    self.update_attribute(:single_access_token, token)
  end
end
