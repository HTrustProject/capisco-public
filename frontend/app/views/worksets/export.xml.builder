# for HTML, erb suffices. For XML, use builder.
# See Builder section of http://api.rubyonrails.org/classes/ActionView/Base.html
# for how to output xml the way you want it to look

xml.workset do 
	xml.title(@workset.title)
	xml.description(@workset.description)
  
  	@storedresults.each do |searchresult|
		xml.searchresult do
			xml.date(searchresult.date)
			xml.title(searchresult.title)
			xml.source(searchresult.sourceid)
			xml.page(searchresult.pagenum)
			xml.searchterms(searchresult.searchterminfo)
		end
	end
end
