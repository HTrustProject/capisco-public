class LinksController < ApplicationController
  def requestedReadable(params)
    if params[:readable] != nil
      return stringToBool(params[:readable])
    else
      return true;
    end
  end
  
  
  def synonyms
    socket = TCPSocket.open(@@address, @@port)
    
    if params[:name] != nil
      id = getArticleId(params[:name], socket)
    elsif params[:id] != nil
      id = params[:id]
    end
    
    if id != nil
      response = executeQuery("synonyms " + id.to_s, socket)
      # Count|Synonym1|Synonym2|Synonym3|...
      if response == ""
        puts "No synonyms available for this id"
        return []
      end
      synonyms = response.split('|')
      puts("Received " + synonyms[0].to_s + " synonyms")
      synonyms.delete_at(0)
      
      @synonyms = synonyms
    end
    
    respond_to do |format|
      format.html
      format.json { render :json => @synonyms }
    end
    
    socket.close
  end
  
  
  
  def senses
    readable = requestedReadable(params)
    socket = TCPSocket.open(@@address, @@port)
    
    if params[:name] != nil
      name = params[:name]
      response = executeQuery("senses " + name, socket)
      # Count|Sense1|Sense2|Sense3|...
      ids = []
      response.split('|').each do |sense|
        ids.append sense.to_i
      end
      puts("Received " + ids[0].to_s + " senses")
      ids.delete_at(0)
      
      if readable
        @senses = getArticlesByIds(ids, socket)
      else
        @senses = ids
      end
    end
    
    respond_to do |format|
      format.html
      format.json { render :json => @senses }
    end
    
    socket.close
  end
  
  def contexts
    socket = TCPSocket.open(@@address, @@port)
    
    if params[:name] != nil
      name = params[:name]
      response = executeQuery("contexts " + name, socket)
      # Count|Context1|Context2|Context3|...
      ids = splitResponse(response)
      @contexts = getArticlesByIds(ids, socket)
    end
    
    respond_to do |format|
      format.json { render :json => @contexts }
    end
    
    socket.close
  end
  
  
  
  def synmaps
    readable = requestedReadable(params)
    
    def label(synmap)
      elements = synmap.split(',')
      return { id: elements[0].to_i, symbol: elements[1] }
    end
    
    socket = TCPSocket.open(@@address, @@port)
    
    if params[:id] != nil
      id = params[:id]
    elsif params[:name] != nil
      id = getArticleId(params[:name], socket)
    else
      # Return 400 - bad request
    end
    
    response = executeQuery("synmaps " + id, socket)
    # Count|Context1,Symbol1|Context2,Symbol2|Context3,Symbol3|...
    synmaps = splitResponse(response)
    synmaps.map!{ |synmap| label(synmap)}
    
    if readable
      @synmaps = []
      synmaps.each do |synmap|
        puts synmap
        concept = getArticleById(synmap[:id], socket)
        @synmaps.push({:symbol => synmap[:symbol], :concept => concept})
      end
    else
      @synmaps = synmaps
    end
    
    respond_to do |format|
      # Todo: Create html page to visualize synmaps
      # format.html
      format.json { render :json => @synmaps }
    end
    
    socket.close
  end
  
  
  
  def keymaps
    def split(keymap)
      elements = keymap.split(',')
      return { :id => elements[0], :symbol => elements[1] }
    end
    
    socket = TCPSocket.open(@@address, @@port)
    
    if params[:id] != nil
      id = params[:id].to_i
    else
      # Return 400 - bad request
    end
    
    response = executeQuery("keymaps " + id.to_s, socket)
    # Count|Context1,Symbol1|Context2,Symbol2|Context3,Symbol3|...
    keymaps = splitResponse(response)
    keymaps.map!{ |keymap| split(keymap)}
    
    @keymaps = []
    keymaps.each do |keymap|
      concept = getArticleById(keymap.id, socket)
      @keymaps.push({:symbol => keymap.symbol, :concept => concept})
    end
    
    respond_to do |format|
      # Todo: Create html page to visualize keymaps
      # format.html
      format.json { render :json => @keymaps }
    end
    
    socket.close
  end
  
  
  
  # Given a symbol, returns all concepts and their contexts which the symbol is used in
  def mappings
    def split(mapping)
      elements = mapping.split(',')
      return { :context => elements[0].to_i, :concept => elements[1].to_i }
    end
    
    socket = TCPSocket.open(@@address, @@port)
    
    if params[:symbol] != nil
      symbol = params[:symbol]
    else
      # Return 400 - bad request
    end
    
    response = executeQuery("mappings " + symbol, socket)
    # Count|Context1,Concept1|Context2,Concept2|Context3,Concept3|...
    mappings = splitResponse(response).map!{ |mapping| split(mapping) }
    ids = mappings.flatten.uniq
    cache = Hash.new
    ids.each do |id|
      cache[id] = getArticleById(id, socket)
    end
    
    @mappings = []
    mappings.each do |mapping|
      concept = cache[mapping.concept]
      context = cache[mapping.context]
      @mappings.push({:context => context, :concept => concept})
    end
    
    respond_to do |format|
      # Todo: Create html page to visualize mappings
      # format.html
      format.json { render :json => @mappings }
    end
    
    socket.close
  end
end