class SessionsController < ApplicationController
  layout :false

  def new
    authenticate if params[:shop]
  end

  def show
    if response = request.env['omniauth.auth']
      logger.debug "ominauth.auth found"
      sess = ShopifyAPI::Session.new(params[:shop], response['credentials']['token'])
      session[:shopify] = sess        
      flash[:notice] = "Logged in"
      redirect_to return_address
    else
      logger.debug "ominauth.auth NOT found :("
      flash[:error] = "Could not log in to Shopify store."
      redirect_to :action => 'new'
    end
  end
  
  protected
  
  def authenticate
    #
    # Instead of doing a backend redirect we need to do a javascript redirect
    # here. Open the app/views/commom/iframe_redirect.html.erb file to understand why.
    #
    if shop_name = sanitize_shop_param(params)
      logger.debug "Redirecting iframe"
      @redirect_url = "/auth/shopify?shop=#{shop_name}"
      render "/common/iframe_redirect", :format => [:html], layout: false
    else
      logger.debug "Redirecting to return_address (sanitization failed)"
      redirect_to return_address
    end
  end
  
  def return_address
    session[:return_to] || root_url
  end
  
  def sanitize_shop_param(params)
    return unless params[:shop].present?
    name = params[:shop].to_s.strip
    name += '.myshopify.com' if !name.include?("myshopify.com") && !name.include?(".")
    name.sub('https://', '').sub('http://', '')
  end
end
