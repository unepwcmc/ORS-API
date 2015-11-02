require 'active_support/concern'

module Pagination
  extend ActiveSupport::Concern

  included do
    param :page, String,
      desc: 'Page number for paginated responses.',
      required: false
    param :per_page, String,
      desc: 'How many objects returned per page for paginated responses (#{MAX_PER_PAGE} by default)',
      required: false
  end

  def validate_page_format
    return true unless params[:page]
    /\A\d+\Z/.match(params[:page])
  end

  def validate_per_page_format
    return true unless params[:per_page]
    /\A\d+\Z/.match(params[:per_page])
  end

end
