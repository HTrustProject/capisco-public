package org.afox.capisco.commands;

import java.text.MessageFormat;
import java.util.*;

import core.Command;
import core.CommandParser;

import org.afox.capisco.*;

import com.mongodb.DBCollection;
import com.mongodb.BasicDBObject;
import com.mongodb.DBCursor;

import java.util.*;

public class RelationshipHelper
{
	public static BasicDBObject getRelationshipQuery(DBCollection coll, String term1, String term2)
	{
		BasicDBObject query1 = new BasicDBObject("label", term1);
		BasicDBObject query2 = new BasicDBObject("label", term2);

		// obtain the possible meanings of each term
		List<Integer> list1 = coll.distinct("meaning", query1);
		List<Integer> list2 = coll.distinct("meaning", query2);

		// And determine if there is a context-meaning relationship between
		// and of the concepts returned from term 1 (context) and 
		// the concepts returned from term 2 (meaning).
		BasicDBObject inClause1= new BasicDBObject("$in", list1);
		BasicDBObject context = new BasicDBObject("context", inClause1);
		BasicDBObject inClause2= new BasicDBObject("$in", list2);
		BasicDBObject meaning = new BasicDBObject("meaning", inClause2);
		ArrayList<BasicDBObject> clauseList = new ArrayList<BasicDBObject>();
		clauseList.add(context);
		clauseList.add(meaning);

		BasicDBObject query = new BasicDBObject("$and", clauseList);

		return query;
	}

	public static ArrayList<ArrayList<Integer>> resolveMutuality(DBCollection coll,
																 String term1, 
																 String term2)
	{
		ArrayList<Integer> contexts = new ArrayList<Integer>();
		ArrayList<Integer> meanings = new ArrayList<Integer>();
		ArrayList<ArrayList<Integer>> results = new ArrayList<ArrayList<Integer>> ();
		
		results.add(contexts);
		results.add(meanings);

		DBCursor cursor = coll.find(getRelationshipQuery(coll, term1, term2));
		try
		{
			while(cursor.hasNext()) 
			{
				Map aMap = cursor.next().toMap();
				contexts.add((Integer)aMap.get("context"));
				meanings.add((Integer)aMap.get("meaning"));
			}
		}
		catch(Exception x)
		{
			System.out.println("Exception" + x);
			return null;
		}
		return results;
	}
}