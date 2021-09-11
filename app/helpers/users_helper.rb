module UsersHelper
  def user_avatar(user, height:, width:)
    render partial: "users/avatar_img",
           locals: { user: user,
                     height: height,
                     width: width }
  end

  def gravatar_url(user)
    hash = Digest::MD5.hexdigest(user.email)
    "https://www.gravatar.com/avatar/#{hash}?d=wavatar"
  end
end
