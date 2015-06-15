module KnowledgeBaseHelper
require 'socket'

# This is the global static variable for the socket connector.
  @@port = 3434
#  @@port = 3435
#  @@address = 'wmi.cms.waikato.ac.nz' # 'matagouri.cms.waikato.ac.nz'
  @@address = 'localhost'
  
    # Remove weird chars from the description
  def cleanseDescription(description)
    return description.gsub(/'{2,5}/,"").gsub(/\[\[[^\]]*\|([^\]]*)\]\]/,"\\1").gsub(/\[\[([^\]]*)\]\]/,"\\1")
  end

  
    # Elapsed time:XXXXXXXXX
    # response
    # --message end--
  def executeQuery(query, socket)
    query.gsub!("\n", "")  
    puts("Executing query: " + query)
    socket.puts query
    response = ""
    elapsed = socket.gets
    if (elapsed == nil)
      puts "Connection terminated unexpectedly"
      return ""
    end
    puts elapsed[2, elapsed.length - 3]
    buffer = socket.gets
    if (buffer == nil)
      puts "Connection terminated unexpectedly"
      return ""
    end
    while !buffer.include?("--message end--")
      response += buffer
      buffer = socket.gets
      if (buffer == nil)
        puts "Connection terminated unexpectedly"
        break;
      end
    end
    if response == ""
      puts "Response from WMI is empty"
    end
    return response.force_encoding("UTF-8").chomp
  end
  
  def splitResponse(response)
    if response == ""
      return []
    else
      split = response.split('|')
      count = split[0].to_i
      puts("Received " + count.to_s + " entries")
      return split[1, count]
    end
  end
  
  def getArticleId(name, socket)
    puts("Getting article id for " + name)
    response = executeQuery("artid " + name, socket)
    
    if response == ""
      puts "No article exists with that name"
      return nil
    else
      id = response.to_i
      puts("Article id: " + id.to_s)
      return id
    end
  end
  
  def getArticleName(id, socket)
    puts("Getting name of article " + id.to_s)
    response = executeQuery("artname " + id.to_s, socket)
    if response == ""
      puts "No article exists with that id"
      return nil
    else
      puts("Article name: " + response)
      return response
    end
  end
  
  def getArticleNames(ids, socket)
    names = []
    ids.each do |id|
      name = getArticleName(id, socket)
      if name != nil
        names.push(name)
      end
    end
    return names
  end
  
  def getDescriptionById(id, socket)
    puts("Getting description for " + id.to_s)
    response = executeQuery("artdesc " + id.to_s, socket)
    puts("Description: " + response[0, [50, response.length].min])
    return cleanseDescription(response)
  end
  
  def getArticleById(id, socket)
    name = getArticleName(id, socket)
    if name == nil
      return nil
    end
    description = getDescriptionById(id, socket)
    return Concept.new(name: name, id: id, description: description)
  end
  
  def getArticlesByIds(ids, socket)
    articles = []
    ids.each do |id|
      articles.push(getArticleById(id, socket))
    end
    return articles
  end
  
  def getArticleByName(name, socket)
    id = getArticleId(name, socket)
    if id == nil
      return nil
    end
    description = getDescriptionById(id, socket)
    return Concept.new(name: name, id: id, description: description)
  end
  
  def getArticlesByNames(names, socket)
    articles = []
    names.each do |name|
      article = getArticleByName(name, socket)
      if article != nil
        articles.push(article)
      end
    end
    return articles
  end
  
  def getInlinksById(id, socket)
    puts("Getting inlinks for " + id.to_s)
    response = executeQuery("inlinks " + id.to_s, socket)
    # Count|Inlink1|Inlink2|Inlink3|...
    inlinks = []
    response.split('|').each do |inlink|
      inlinks.append inlink.to_i
    end
    puts("Received " + inlinks[0].to_s + " inlinks")
    inlinks.delete_at(0)
    return inlinks
  end
  
  def getOutlinksById(id, socket)
    puts("Getting outlinks for " + id.to_s)
    response = executeQuery("outlinks " + id.to_s, socket)
    # Count|Outlink1|Outlink2|Outlink3|...
    outlinks = []
    response.split('|').each do |outlink|
      outlinks.append outlink.to_i
    end
    puts("Received " + outlinks[0].to_s + " outlinks")
    outlinks.delete_at(0)
    return outlinks
  end
  
  def getContextsByName(name, socket)
    puts("Getting contexts for " + name.to_s)
    response = executeQuery("contexts " + id.to_s, socket)
    # Count|Context1|Context2|Context3|...
    contexts = []
    response.split('|').each do |context|
      contexts.append context.to_i
    end
    puts("Received " + contexts[0].to_s + " contexts")
    contexts.delete_at(0)
    return contexts
  end  
    
  def getSensesByName(name, socket)
    puts("Getting senses for " + name)
    response = executeQuery("senses " + name, socket)
    # Count|Sense1|Sense2|Sense3|...
    senses = []
    response.split('|').each do |sense|
      senses.append sense.to_i
      puts("Sense id: " + sense)
    end
    puts("Received " + senses[0].to_s + " senses")
    senses.delete_at(0)
    return senses
  end
  
  # DEPRECATED - Slowly moving these commands to their appropriate controllers.
  # Same command exists in links controller. TODO: remove references in contextsadder_controller
  # Returns phrases, not ids
  def getSynonymsById(id, socket)
    puts("Getting synonyms for " + id.to_s)
    response = executeQuery("synonyms " + id.to_s, socket)
    # Count|Synonym1|Synonym2|Synonym3|...
    if response == ""
      puts "No synonyms available for this id"
      return []
    end
    synonyms = response.split('|')
    puts("Received " + synonyms[0].to_s + " synonyms")
    synonyms.delete_at(0)
    return synonyms
  end
  
  # Returns phrases, not ids
  def getKeymapsById(id, socket)
    puts("Getting keymaps for " + id.to_s)
    response = executeQuery("keymaps " + id.to_s, socket)
    # Count|Keymap1|Keymap2|Keymap3|...
    if response == ""
      puts "No keymaps available for this id"
      return []
    end
    keymaps = response.split('|')
    puts("Received " + keymaps[0].to_s + " keymaps")
    keymaps.delete_at(0)
    return keymaps
  end
  
  # gets the hathi trust ids
  def getDocumentPathList(term, socket)
    if term == nil
      return []
    end    
    #sleep(1)
    response = executeQuery("set /lucene/docID false", socket)
    if response != ""
      puts "Failed to set WMI output mode to Document Path"
    end
    
    response = executeQuery("search " + term.downcase, socket)
    # Count|Keymap1|Keymap2|Keymap3|...
    results = response.split('|')
    puts("Received " + results[0].to_s + " results")
    results.delete_at(0)
    
    return results
  end
  
  # gets the lucene internal doc ids
  def getDocumentIdList(term, socket)
    if term == nil
      return []
    end
    response = executeQuery("set /lucene/docID true", socket)
    
    results = []
    response = executeQuery("search " + term.downcase, socket)
    # Count|Keymap1|Keymap2|Keymap3|...
    response.split('|').each do |result|
      results.append result.to_i
    end
    puts("Received " + results[0].to_s + " results")
    results.delete_at(0)
    return results
  end
  
  def getDocumentTextById(id, socket)
    response = executeQuery("doc " + id.to_s, socket)
    if response.start_with?("Exception getting Doc:")
      puts response
      return nil
    else
      return response
    end
  end
  
  def getDocumentCounts(terms, socket)
    query = 'count search '
    terms.each do |term|
      query += term.downcase + '|'
    end
    return executeQuery(query, socket)
  end

	# batch command to get articleIds (senseIds) for articleNames (senses)
	def batchGetArticleIds(names, delimiter, socket)
		#> batch artid ,
		#Kiwifruit
		#Cow-calf
		#,
		#Elapsed time:29399869108
		#17363
		#,
		#2121806
		#,
		#--message end--

		command = 'batch artid ' + delimiter + "\n"
	   names.each do |name|
	     command += name + "\n"
	   end
	   command += delimiter
    	socket.puts command # response = executeQuery(command, socket) # removes crucial newlines
    	
   	socket.gets # skip elapsed time line
   	
   	senseIds = []
	  	names.each do |name|
	     senseIds.append socket.gets.chomp  # remove newline
	     socket.gets # skip delimiter
	   end
	   clearBuffer(socket)

	   return senseIds
	end
	
	# batch requests for article name then article desc. 
	# Returns an array of Concept objects (id, artname, artdesc)
	def batchGetArticleNames(ids, delimiter, socket)
		#> batch artname ,
		#509080
		#17362
		#,
		#Elapsed time:11463915985
		#Kiwi (people)
		#,
		#Kiwi
		#,
		#--message end--

		command = 'batch artname ' + delimiter + "\n"
		ids.each do |id|
	     command += id.to_s + "\n"
	   end
	   command += delimiter
    	socket.puts command
    	
   	socket.gets # skip elapsed time line
   	
   	senseNames = []
	  	ids.each do |id|
	     senseNames.append socket.gets.chomp  # remove newline
	     socket.gets # skip delimiter
	   end
	   clearBuffer(socket)

	   return senseNames
	end
	
	def batchGetArticlesByIds(ids, delimiter, socket)
		#> batch artname ,
		#509080
		#17362
		#,
		#Elapsed time:11463915985
		#Kiwi (people)
		#,
		#Kiwi
		#,
		#--message end--

		# prepare the batch request for the article names
		command = 'batch artname ' + delimiter + "\n"
	   ids.each do |id|
	     command += id.to_s + "\n"
	   end
	   command += delimiter
    	socket.puts command
    	
   	socket.gets # skip elapsed time line
   	
   	senseNames = []
	  	ids.each do |id|
	     senseNames.append socket.gets.force_encoding("UTF-8").chomp  # remove newline
	     socket.gets # skip delimiter
	   end
	   clearBuffer(socket)
		
		# rerun the batch command, this time requesting article descriptions
		command.sub!('batch artname ', 'batch artdesc ') # substitute first occurrence of artname in command with artdesc
		socket.puts command
    	
   	socket.gets # skip elapsed time line
		senseDescriptions = []
	  	ids.each do |id|
	     senseDescriptions.append socket.gets.force_encoding("UTF-8").chomp  # remove newline
	     socket.gets # skip delimiter
	   end
	   clearBuffer(socket)
	   
	   # prepare the response
		articles = []	   
	   ids.each_with_index do |id, index| #ids.zip.senseNames.zip(senseDescriptions) do |id, sense, desc|
	   	concept = Concept.new(id: id, name: senseNames[index], description: senseDescriptions[index])
	   	articles.push(concept)
	   end
	   
	   puts "@@@ batch-get articles complete"
	   return articles
	end
	
	
  
# batch command to get total doc counts for all combinations
# e.g. for [cow-calf|kiwifruit, cow-calf, kiwifruit], 
# this method will return [0,58,1]
 def getDocCountsForAllCombinations(combinationsArray, delimiter, s)
   require 'socket'

   # Example wmi interaction where delimiter is ',' :
   #
   #> batch count ,
   #search kiwifruit|cow-calf
   #search kiwifruit
   #search cow-calf
   #,
   #Elapsed time:17246922314
   #0
   #,
   #1
   #,
   #58
   #,

   # delimiter in the above example is ',' since '|' is already in use
   command = 'batch count ' + delimiter + "\n"
   for combination in combinationsArray do
     command += "search " + combination.downcase + "\n"
   end
   command += delimiter
   s.puts command

   ##puts "@@@@ running batch command:\n" + command

   s.gets
   result = ""
   for combination in combinationsArray do
     result += s.gets.chomp # get the count, remove newline
     result += s.gets.chomp # get the delimiter, remove newline
   end
   clearBuffer(s)

  return result # string of counts for combinations, punctuated by delimiter
 end
 
 def getDocuments(terms, socket)
    
    documentIds = []
    documentPaths = []
    documentIds |= getDocumentIdList(terms.join('|'), socket)
    documentPaths |= getDocumentPathList(terms.join('|'), socket)
    
    results = []
    documentIds.zip(documentPaths) do |id, path|
      result = Document.new
      result.internalid = id.to_s # sourceid
      result.sourceid = path #result.filename = path # internalid
      document = getDocumentTextById(id, socket)
#      match = document.match(/.{0,5}(#{terms.join('|')}).{0,5}/)
#      if match != nil
#        result.resultlines = match.captures.join('\n')
#      else
#        result.resultlines = "..." #"No matches available"
#      end
      results.append(result)
    end
    return results
  end
  
  def getResultLines(term, id, s)
    # puts "in get1stLineOfDoc"
  
    s.puts "doc " + id.to_s
  
    s.gets
    toReturn = "..."
  
  
    line = s.gets
    while !line.include? "--message end--" do
      if line.include? term
        # toReturn.push line
        toReturn = toReturn + line + "..."
      end
  
      line = s.gets
    end
  
    return toReturn
  end
  
  def clearBuffer(s)
    require 'socket'
    result = " "
    while !result.include? "--message end--" do
      result = s.gets
    end
  end
  
  def getInlinksByName(name, socket)
    return getInlinksById(getArticleId(name, socket), socket)
  end
  
  def getInlinksHuman(name, socket)
    return getArticleNames(getInlinksByName(name, socket), socket)
  end
  
  def getOutlinksByName(name, socket)
    return getOutlinksById(getArticleId(name, socket), socket)
  end
  
  def getOutlinksHuman(name, socket)
    return getArticleNames(getOutlinksByName(name, socket), socket)
  end
  
  def getContextsById(id, socket)
    name = getArticleName(id, socket)
    if artid == ""
      return []
    end
    return getContextsByName(name, socket)
  end
  
  def getContextsHuman(name, socket)
    return getArticleNames(getContextsByName(name, socket))
  end
  
  # Returns phrases, not ids
  def getSynonymsByName(id, socket)
    return getSynonymsById(getArticleId(name, socket), socket)
  end
  
  def getSensesById(id, socket)
    return getSensesByName(getArticleName(id, socket), socket)
  end
  
  def getSensesHuman(name, socket)
    return getArticlesByIds(getSensesByName(name, socket), socket)
  end
  
  # Returns phrases, not ids
  def getKeymapsByName(name, socket)
    artid = getArticleId(name, socket)
    if artid == ""
      return []
    end
    return getKeymapsById(artid, socket)
  end

end #KnowledgeBaseHelper