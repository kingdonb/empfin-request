class LoginConfig
  include ActiveModel::Model
  attr_reader :username, :password

  def initialize(base64_string)
    s = Base64.decode64(base64_string)
    a = s.split(':')
    @username = a[0]
    @password = a[1]
  end
end
