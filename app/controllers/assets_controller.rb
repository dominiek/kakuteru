class AssetsController < ApplicationController

  def create
    @asset = Asset.upload(params[:asset], :post_id => params[:post_id])
    respond_to do |format|
      format.js do
        responds_to_parent do
          render(:update) do |page|
            page << "$('upload').className = 'upload';"
            page.insert_html(:bottom, 'assets', :partial => 'assets/asset', :asset => @asset)
          end
        end
      end
    end
  end

end
