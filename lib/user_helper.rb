module UserHelper

  def user(name)
    User.where(user: name).first
  end

  def users
    User.all
  end
  
end