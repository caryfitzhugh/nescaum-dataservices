require 'app/models'

module Controllers
  class AuthenticationController < Controllers::Base

    get "/sign_in", no_swagger: true  do
      if current_user
        redirect params[:return_to] || '/'
      end
      erb :"authentication/sign_in"
    end

    post "/sign_in", no_swagger: true  do
      user =  User.first(:username => params[:username])

      if user && user.password == params[:password]
        session.clear
        session[:user_id] = user.id
        redirect params[:return_to] || '/'
      else
        erb :"authentication/sign_in", locals: { error: 'Username or password was incorrect' }
      end
    end

    get "/sign_out", no_swagger: true  do
      session.clear
      redirect '/sign_in'
    end
  end
end
