class SessionsController < ApplicationController
  def new
  end

  def create
    credential = params.expect(session: [ :email, :password ])

    email = credential[:email].to_s.strip.downcase
    user = User.find_by(email: email)

    if user&.authenticate(credential[:password])
      reset_session
      session[:user_id] = user.id
      redirect_to root_path, notice: "Signed in successfully."
    else
      flash.now[:alert] = "Invalid email or password."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to root_path, notice: "Signed out.", status: :see_other
  end
end
