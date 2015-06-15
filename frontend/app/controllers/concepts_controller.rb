class ConceptsController < ApplicationController
  
  def index

  end

  
  def exploreSynonyms
    socket = TCPSocket.open(@@address, @@port)
    
    if params[:ids] != nil
      @concepts = getArticlesByIds(params[:ids], socket)
    elsif params[:names] != nil
      @concepts = getArticlesByNames(params[:names], socket)
    end
    
    respond_to do |format|
      format.html
      format.json { render :json => @concepts }
    end
    
    socket.close
  end
  

  def viewSynonyms
    socket = TCPSocket.open(@@address, @@port)
    
    if params[:id] != nil
      @concept = getArticleById(params[:id], socket)
    elsif params[:name] != nil
      @concept = getArticleByName(params[:name], socket)
    end
    
    respond_to do |format|
      format.html
      format.json { render :json => @concept }
    end
    
    socket.close
  end

  
  def exploreContexts
    socket = TCPSocket.open(@@address, @@port)
    
    if params[:ids] != nil
      @concepts = getArticlesByIds(params[:ids], socket)
    elsif params[:names] != nil
      @concepts = getArticlesByNames(params[:names], socket)
    end
    
    respond_to do |format|
      format.html
      format.json { render :json => @concepts }
    end
    
    socket.close
  end
  

  def viewContexts
    socket = TCPSocket.open(@@address, @@port)
    
    if params[:id] != nil
      @concept = getArticleById(params[:id], socket)
    elsif params[:name] != nil
      @concept = getArticleByName(params[:name], socket)
    end
    
    respond_to do |format|
      format.html
      format.json { render :json => @concept }
    end
    
    socket.close
  end

  

  def everything
    socket = TCPSocket.open(@@address, @@port)
    
    if params[:id] != nil
      @concept = getArticleById(params[:id], socket)
    elsif params[:name] != nil
      @concept = getArticleByName(params[:name], socket)
    end

    respond_to do |format|
      format.html
      format.json { render :json => @concept }
    end
    
    socket.close
  end
  
  
  def download
    if params[:name] != nil
      send_file Rails.root.join('data', params[:name]), :type=>"text/json", :x_sendfile=>true
    end
  end
end