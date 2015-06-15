class SemanticSearchController < ApplicationController
	include SemanticSearchHelper

 def getOwlJson
  # Method that returns the JSON object for the OWLCarosel JS libaray

  json = "{"

  query = " "
  if params[:query] != nil
    query = params[:query]
  end

  type = " "
  if params[:type] != nil
    type = params[:type]
  end

  require 'socket'
  s = TCPSocket.new @@address, @@port

  result = []
  desc_result = []
  sense_ids = []

  if (type.include? "outlinks")
    result = getOutlinksHuman(query,s)
  elsif (type.include? "senses")
  	 sense_ids = getSensesByName(query, s)
    batch_delimiter = ","    
    articles = batchGetArticlesByIds(sense_ids, batch_delimiter, s) # articles = getArticlesByIds(sense_ids, s)    
    result = articles.map { |article| article.name }
    desc_result = articles.map { |article| article.description }
  end

  i = 0
  while i < result.length
    result[i].force_encoding 'utf-8'
    i = i + 1
  end

  if result.length == 0
    conHTML = ['<div id="no-senses" data-term="' + query + '"></div>']
  else
    conHTML = htmlSensesWithDesc(query, sense_ids, result, desc_result, 7, s)
  end
  s.close;

  require 'json_builder'

  puts "#= just before JSONBuilder"
  json = JSONBuilder::Compiler.generate do
    owl do 
      array conHTML do |text|
        item "<span class='item'>" + text + '</span>'
      end
    end
  end

  puts json

# This allows the controller to respond to GET requests that are asking for .json files
  respond_to do |format|
    format.html
    format.json { render json: json }
  end
end
end
