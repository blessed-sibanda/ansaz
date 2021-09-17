class ApplicationController < ActionController::Base
  include Pundit
  before_action :configure_permitted_parameters, if: :devise_controller?
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(
      :sign_up,
      keys: [:name,
             :email, :password,
             :password_confirmation],
    )
    devise_parameter_sanitizer.permit(
      :account_update,
      keys: [:name, :about, :avatar,
             :email, :password,
             :password_confirmation,
             :current_password],
    )
  end

  private

  def user_not_authorized(exception)
    policy_name = exception.policy.class.to_s.underscore

    flash[:alert] = t "#{policy_name}.#{exception.query}",
                      scope: "pundit", default: :default
    redirect_to(request.referrer || root_path)
  end
end
