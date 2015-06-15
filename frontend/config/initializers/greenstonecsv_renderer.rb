# http://stackoverflow.com/questions/5182344/rails-3-how-to-respond-with-csv-without-having-a-template-file
# http://api.rubyonrails.org/classes/ActionController/Renderers.html#method-c-add
# Remember to restart rails server after adding a Renderer
ActionController::Renderers.add :greenstonecsv do |obj, options|
  filename = options[:filename] || 'greenstone'
  str = obj.respond_to?(:to_greenstonecsv) ? obj.to_greenstonecsv : obj.to_s
  send_data str, :type => Mime::CSV,
    :disposition => "attachment; filename=#{filename}.csv"
end