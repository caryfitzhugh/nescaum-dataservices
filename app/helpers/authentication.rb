module Helpers
  module Authentication
    def login_user(user)
      session.clear
      session[:user_id] = user.id
    end
    def current_user
      if session[:user_id]
        Models::User.get(session[:user_id])
      else
        nil
      end
    end

  end
end
