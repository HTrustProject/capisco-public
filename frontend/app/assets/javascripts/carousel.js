
function createCarousel(id, entries) {
	var carousel = $('<div id="' + id + '" class="carousel slide wide" data-ride="carousel" data-interval="false"></div>');
	var carouselInner = $("<div class=\"carousel-inner tall\" role=\"listbox\"></div>");
	var carouselIndicators = $("<ol class=\"carousel-indicators carousel-dark-indicators carousel-outer-indicators\"></ol>");
	var carouselPrev = $("<a class=\"left carousel-control carousel-left-control\" href=\"#" + id + "\" data-slide=\"prev\"><span class=\"icon-prev\"></span></a>");
	var carouselNext = $("<a class=\"right carousel-control carousel-right-control\" href=\"#" + id + "\" data-slide=\"next\"><span class=\"icon-next\"></span></a>");
	
	var index = 0;
	var pages = Math.ceil(entries.length / 21);
	
	for (var page = 0; page < pages; page++)
	{
		var remainingColumns = Math.ceil((entries.length - index) / 3);
		var columns = Math.min(remainingColumns, 3);
		
		var pageDiv = $("<div class=\"item\"><div class=\"row\"></div></div>");
		var pageIndicator = $("<li data-target=\"" + id + "\" data-slide-to=\"" + page + "\"></li>");
		
		if (page === 0)
		{
			pageDiv.addClass("active");
			pageIndicator.addClass("active");
		}
		
		for (var column = 0; column < columns; column++)
		{
			var remainingRows = entries.length - index;
			var rows = Math.min(remainingRows, 7);
			
			var columnDiv = $("<div class=\"col-md-4\"></div>");
			
			for (var row = 0; row < rows; row++)
			{
				entries[index].appendTo(columnDiv);
				index++;
			}
			
			//if (pages > 1)
			//{
			//	for (var row = rows; row < 7; row++)
			//	{
			//		$("<br></br>").appendTo(columnDiv);
			//	}
			//}
			
			columnDiv.appendTo(pageDiv);
		}
		
		pageDiv.appendTo(carouselInner);
		pageIndicator.appendTo(carouselIndicators);
	}
	
	carouselInner.appendTo(carousel);
	
	if(pages > 1)
	{
		carouselPrev.appendTo(carousel);
		carouselNext.appendTo(carousel);
		carouselIndicators.appendTo(carousel);
	}

	return carousel;
}