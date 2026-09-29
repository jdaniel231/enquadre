class ApplicationController < ActionController::Base
  include Authentication
  allow_browser versions: :modern
  stale_when_importmap_changes

  private

  # Garante que recursos de domínio sejam sempre buscados dentro da conta atual.
  # Usar Current.account.patients.find(...) — nunca Patient.find(...)
  def current_account
    Current.account
  end
  helper_method :current_account
end
