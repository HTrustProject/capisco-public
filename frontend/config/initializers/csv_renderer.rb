# http://stackoverflow.com/questions/5182344/rails-3-how-to-respond-with-csv-without-having-a-template-file
# http://api.rubyonrails.org/classes/ActionController/Renderers.html#method-c-add
# Remember to restart rails server after adding a Renderer
ActionController::Renderers.add :csv do |obj, options|
  filename = options[:filename] || 'data'
  str = obj.respond_to?(:to_csv) ? obj.to_csv : obj.to_s
  send_data str, :type => Mime::CSV,
    :disposition => "attachment; filename=#{filename}.csv"
end