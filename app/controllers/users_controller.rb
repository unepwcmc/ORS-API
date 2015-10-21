class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(users_params)
    if @user.save
      flash[:success] = "Account registered!"
      redirect_to user_path(@user.id)
    else
      render :new
    end
  end

  def generate_new_token
    current_user.generate_authentication_token
    redirect_to user_path(current_user), notice: "Token generated successfully"
  end

  private

  def users_params
    params.require(:user).permit(:email, :password, :password_confirmation,
                                 :first_name, :last_name)
  end
end
