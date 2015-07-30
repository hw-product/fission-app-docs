class DocsController < ApplicationController

  before_action :validate_user!, :except => [:show, :tos, :privacy]
  before_action :validate_access!, :except => [:show, :tos, :privacy]

  before_action do
    @doc_product = @product || Product.find_by_internal_name(
      params.fetch(:product_name, 'fission')
    )
  end

  def show
    respond_to do |format|
      format.js do
        flash[:error] = 'Unknown request!'
        javascript_redirect_to root_url
      end
      format.html do
        if(@doc_product)
          @docs_toc = "docs/#{@doc_product.internal_name}/toc"
          @docs_content = "docs/#{@doc_product.internal_name}/#{@doc_product.internal_name}"
          @site_style = 'fission-app-docs'
        else
          not_found!
        end
      end
    end
  end

  def tos
    respond_to do |format|
      format.js do
        flash[:error] = 'Unknown request!'
        javascript_redirect_to root_url
      end
      format.html do
        @title = 'Terms of Service'
        @domain = request.domain
        @website = request.host
        @support_email = "helpdesk@#{@domain}"
        @content = 'termsofservice'
        render :legal
      end
    end
  end

  def privacy
    respond_to do |format|
      format.js do
        flash[:error] = 'Unknown request!'
        javascript_redirect_to root_url
      end
      format.html do
        @title = 'Privacy Policy'
        @domain = request.domain
        @website = request.host
        @support_email = "helpdesk@#{@domain}"
        @content = 'privacy'
        render :legal
      end
    end
  end

end
