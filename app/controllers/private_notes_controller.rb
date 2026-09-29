class PrivateNotesController < ApplicationController
  before_action :set_patient
  before_action :set_note, only: %i[edit update destroy]

  def new
    @private_note = @patient.private_notes.new
  end

  def create
    @private_note = @patient.private_notes.new(private_note_params)
    @private_note.user = Current.user

    if @private_note.save
      redirect_to @patient, notice: t(".success")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @private_note.update(private_note_params)
      redirect_to @patient, notice: t(".success")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @private_note.destroy
    redirect_to @patient, notice: t(".success")
  end

  private

  def set_patient
    @patient = Current.account.patients.find(params[:patient_id])
  end

  def set_note
    # authored_by garante que só o autor acessa — outro usuário recebe 404
    @private_note = @patient.private_notes.authored_by(Current.user).find(params[:id])
  end

  def private_note_params
    params.expect(private_note: [ :body ])
  end
end
