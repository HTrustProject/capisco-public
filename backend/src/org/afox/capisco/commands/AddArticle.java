package org.afox.capisco.commands;

import java.text.MessageFormat;
import java.util.*;

import core.Command;
import core.CommandParser;

import org.afox.capisco.*;

import com.mongodb.DBCollection;
import com.mongodb.BasicDBObject;
import com.mongodb.DBCursor;

public class AddArticle extends CapiscoCommand
{
    public AddArticle()
    {
    }
	
    public String helpText()
    {
		return "{0} id|title|desc : Adds the specified context to the knowledge base.";
    }
	
    public String shortDescription()
    {
		return "Add an article to the knowledge base.";
    }
	
    protected void executeImpl()
    {
		DBCollection coll = getCollection("article");
		BasicDBObject addRecord = new BasicDBObject();

		String[] fields = data.split("\\|");

		addRecord.put("_id", Integer.parseInt(fields[0]));
		addRecord.put("title", fields[1]);
		addRecord.put("desc", fields[2].trim());

		try
		{
			coll.insert(addRecord);
		}
		catch(Exception x)
		{
			print("Exception:" + x);
		}

		print("Success\n");

    }
}
