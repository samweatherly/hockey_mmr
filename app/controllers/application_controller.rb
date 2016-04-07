class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Adds below types to flash so they can be written the same as notice: "MESSAGE"
  add_flash_types :success, :error, :alert

  def date_format(holder)
    month = holder.month.to_s
    day = holder.day.to_s
    if month.length == 1
      month = "0" + month
    end
    if day.length == 1
      day = "0" + day
    end
    "#{day}/#{month}/#{holder.year}"
  end
  helper_method :date_format

  def date_display(date)
    month = Date::MONTHNAMES[date.month]
    "#{month} #{date.day}"
  end
  helper_method :date_display

end
