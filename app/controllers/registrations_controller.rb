class RegistrationsController < ApplicationController
  skip_before_action :require_authentication

  def new
    @registration = Registration.new
  end

  def create
    @registration = Registration.new(registration_params)
    if @registration.save
      start_new_session_for @registration.user
      redirect_to root_path, notice: t("registrations.welcome")
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def registration_params
    params.expect(registration: [ :account_name, :email_address, :password, :kind, :crp ])
  end
end
