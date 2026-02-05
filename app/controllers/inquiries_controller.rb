class InquiriesController < ApplicationController
  def index
    @inquiries = Inquiry.includes(:user).order(:id)
  end
end
