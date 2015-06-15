package org.afox.capisco.commands;

import java.text.MessageFormat;
import java.util.*;

import core.Command;
import core.CommandParser;

import org.afox.capisco.*;

import com.mongodb.DBCollection;
import com.mongodb.BasicDBObject;
import com.mongodb.DBCursor;

public class Mutuality extends CapiscoCommand
{
    public Mutuality()
    {
    }
	
    public String helpText()
    {
		return "{0} Symbol1|Symbol2 : Attempts to identify a mutual dependency between two symbols";
    }
	
    public String shortDescription()
    {
		return "Returns all context-meaning relationships between the defined symbols that are mutual.";
    }
	
    protected void executeImpl()
    {
	}
/*

		DBCollection coll = getCollection("labelMapping");
		String[] fields = data.split("\\|");

		ArrayList<ArrayList<Integer>> q1 = 
			RelationshipHelper.resolveMutuality(coll, fields[0], fields[1]);

		ArrayList<ArrayList<Integer>> q2 = 
			RelationshipHelper.resolveMutuality(coll, fields[1], fields[0]);

		print("|");

		ArrayList<Integer> contexts = new ArrayList<Integer>();
		ArrayList<Integer> meanings = new ArrayList<Integer>();

		int count = 0;
		for (Integer value : q1.get(0))
		{
			if(q2.get(1).contains(value))
			{
				if (count > 0)
					print (",");
				print("" + value);
				count++;
			}
		}
		print("|");
		count = 0;
		for (Integer value : q2.get(0))
		{
			if(q1.get(1).contains(value))
			{
				if 
				if (count > 0)
					print (",");
				print("" + value);
				count++;
			}
		}
		print("|\n");
		}*/
}
