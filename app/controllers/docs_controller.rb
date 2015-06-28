class DocsController < ApplicationController

  before_action :validate_user!, :except => [:show]
  before_action :validate_access!, :except => [:show]

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
        else
          flash[:error] = 'Failed to locate requested documentation!'
          redirect_to root_url
        end
      end
    end
  end

end
