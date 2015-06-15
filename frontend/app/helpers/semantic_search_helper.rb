module SemanticSearchHelper
  def htmlSenses(senses, no, s)
    toReturn = []
    htmlLine = []

    senses.each{ |sense|
      htmlLine.push('<div class="owl-item"> ' + sense + "<span class='grey doc-info'> |" + numDocAsString(sense, s) + "</span></div>")
    }

    puts "------htmlLine-----"
    puts htmlLine.to_s

    total = 0
    while total < senses.length do
      i = 0
      conString = ""
      while i < no do
        if htmlLine[total] != nil
        conString = conString + htmlLine[total]
        end
        i += 1
        total += 1
      end
      toReturn.push conString
    end
    return toReturn
  end

  # Remove weird chars from the description
  def cleanseDescription(description)
    return description.gsub(/'{2,5}/,"").gsub(/\[\[[^\]]*\|([^\]]*)\]\]/,"\\1").gsub(/\[\[([^\]]*)\]\]/,"\\1")
  end

  def htmlSensesWithDesc(query, sense_ids, senses, senses_desc, no, s)
    toReturn = []
    htmlLine = []

    i = 0
    while i < senses.length
      sense = senses[i]
      sense_id = sense_ids[i]
      ##			sense_desc = senses_desc[i]
      # TODO move this to a central location so that it can be reused by other controllers, e.g., concepts_controller (line 12)

      sense_desc = cleanseDescription(senses_desc[i])

      htmlLine.push('<div class="owl-item" id="' +sense_id.to_s+ '" title="'+sense_desc + '" data-sense="'+sense+'" data-term="' + query + '" data-sense-id="' +sense_id.to_s+ '"> ' + sense + "<span class='grey doc-info' data-sense-id='"+sense_id.to_s+"' data-sense='"+sense+"' data-term='"+query+"'> | " + numDocAsString(sense, s) + " </span></div>")

      i = i + 1
    end

    #		senses.each{ |sense|
    #			htmlLine.push('<div class="owl-item"> ' + sense + "<span class='grey doc-info'> |" + numDocAsString(sense, s) + "</span></div>")
    #		}

    puts "------htmlLine-----"
    puts htmlLine.to_s

    total = 0
    while total < senses.length do
      i = 0
      conString = ""
      while i < no do
        if htmlLine[total] != nil
        conString = conString + htmlLine[total]
        end
        i += 1
        total += 1
      end
      toReturn.push conString
    end
    return toReturn
  end

  def noOfDocs(name, s)
    require 'socket'
    s.puts "count search " + name.downcase
    s.gets
    count  = s.gets
    clearBuffer(s)
    return count.force_encoding('utf-8').chomp
  end

  def numDocAsString(name, s)
    countDocString = noOfDocs(name, s)
    countDocString += (countDocString != "1") ? " docs" : " doc"
    return countDocString
  end

  def clearBuffer(s)
    require 'socket'
    result = " "
    while !result.include? "--" do
      result = s.gets
    end
  end
end
