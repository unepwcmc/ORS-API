class UsersController < ApplicationController
  include ApplicationHelper

  before_action :authenticate, except: [:new, :create]
  before_action :revoke_access_for_ramsar, only: [:new, :create]

  def new
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(users_params)
    api_role = Role.find_by_name('api')
    @user.roles << api_role if api_role
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

  def revoke_access_for_ramsar
    redirect_to root_path if is_ramsar_instance?
  end
end
