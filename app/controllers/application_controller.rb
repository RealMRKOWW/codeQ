class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def render_json(status, type, notice = "", data = "")
    render json: { type: type, data: data, notice: notice }, status: status
  end
end
