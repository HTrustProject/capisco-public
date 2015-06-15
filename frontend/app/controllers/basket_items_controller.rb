class BasketItemsController < ApplicationController
	def index
		@basketItems = BasketItem.where(archived: false).order('term')
	end

	def add
		logger.info {params.to_yaml}
		@item = BasketItem.new(item_params)
		if @item.save
			render json: {success: true}
		else
			render json: {success: false, errors: 'Unable to save changes', status: 422}
		end
	end

	def archive
		@item = BasketItem.find params[:id]

		@item.archived = true
		if @item.save
			render json: {success: true}
		else
			render json: {success: false, errors: 'Unable to save changes', status: 422}
		end

	rescue ActiveRecord::RecordNotFound
		render json: {success: false, errors: 'Basket item (' + @item.id + ') was not found'}, status: 404
	end

	private
	def item_params
		params.require(:item).permit(:term, :comment)
	end


end
