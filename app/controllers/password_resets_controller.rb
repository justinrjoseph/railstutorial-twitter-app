class PasswordResetsController < ApplicationController
  before_action :set_user,         only: [:edit, :update]
  before_action :valid_user,       only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]
  
  def new
  end
  
  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "Email sent containing password reset instructions."
      redirect_to root_url
    else
      flash.now[:danger] = "That email address was not found in our records."
      render :new
    end
  end
  
  def edit
  end
  
  def update
    if password_blank?
       flash.now[:danger] = "Password can't be blank."
       render :edit
    elsif @user.update_attributes(user_params)
      log_in @user
      flash[:success] = "Your password has been reset."
      redirect_to @user
    else
      flash[:danger] = "Your password could not be reset."
      render :edit
    end
  end
  
  private
  
    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end
    
    # Returns true if password is blank.
    def password_blank?
      params[:user][:password].blank?
    end
    
    # Before filters
  
    # Finds the user.
    def set_user
      @user = User.find_by(email: params[:email])
    end
    
    # Confirms a valid user.
    def valid_user
      unless @user && @user.activated? &&
             @user.authenticated?(:reset, params[:id])
        redirect_to root_url
      end
    end
    
    # Checks expiration of reset token.
    def check_expiration
      if @user.password_reset_expired?
        flash[:danger] = "Your password reset link has expired."
        redirect_to new_password_reset_url
      end
    end
  
end