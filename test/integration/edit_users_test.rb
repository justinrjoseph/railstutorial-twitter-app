require 'test_helper'

class EditUsersTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = users(:michael)
  end
  
  test "unsuccessful edit" do
    log_in_as @user

    get edit_user_path @user

    assert_template 'users/edit'
    
    patch user_path(@user), user: { name:  "",
                                    email: "user@invalid",
                                    password:              "foo",
                                    password_confirmation: "bar" }
                                    
    assert_template 'users/edit'
  end
  
  test "successful edit with friendly forwarding" do
    name = "Foo Bar"
    email = "foo@bar.com"

    request_url = edit_user_url @user
    
    get edit_user_path @user

    assert_not_nil session[:forwarding_url]

    assert_equal session[:forwarding_url], request_url
    
    log_in_as @user
    
    assert_redirected_to edit_user_path(@user)
    
    assert_nil session[:forwarding_url]
    
    patch user_path(@user), user: { name:  name,
                                    email: email,
                                    password:              "",
                                    password_confirmation: "" }

    assert_not flash.empty?
    assert_redirected_to @user
    
    @user.reload
    
    assert_equal @user.name, name
    assert_equal @user.email, email
  end
  
end