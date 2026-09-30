class IssuedDocumentsController < ApplicationController
  before_action :set_patient
  before_action :set_document, only: %i[show pdf]

  def index
    @issued_documents = @patient.issued_documents.order(created_at: :desc)
  end

  def show
  end

  def new
    @issued_document = @patient.issued_documents.new
  end

  def create
    @issued_document = @patient.issued_documents.new(issued_document_params)
    @issued_document.account = Current.account
    @issued_document.user = Current.user

    @issued_document.rendered_html = render_to_string(
      template: "issued_documents/document",
      layout: false,
      locals: { document: @issued_document, issued_at: Time.current }
    )

    if @issued_document.save
      redirect_to patient_issued_document_path(@patient, @issued_document), notice: t(".success")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def pdf
    wrapper = render_to_string(
      template: "issued_documents/pdf_wrapper",
      layout: false,
      locals: { body: @issued_document.rendered_html }
    )
    pdf_data = Grover.new(wrapper, format: "A4", margin: {
      top: "2cm", right: "2cm", bottom: "2cm", left: "2cm"
    }).to_pdf
    send_data pdf_data,
              filename: "#{@issued_document.kind}_#{@issued_document.id}.pdf",
              type: "application/pdf",
              disposition: "inline"
  end

  private

  def set_patient
    @patient = Current.account.patients.find(params[:patient_id])
  end

  def set_document
    @issued_document = @patient.issued_documents.find(params[:id])
  end

  def issued_document_params
    params.expect(issued_document: %i[kind content amount])
  end
end
