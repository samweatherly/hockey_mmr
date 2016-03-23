class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Adds below types to flash so they can be written the same as notice: "MESSAGE"
  add_flash_types :success, :error, :alert

end
