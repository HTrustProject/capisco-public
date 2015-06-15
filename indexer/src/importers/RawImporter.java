package importers;

import java.io.File;
import java.io.FileNotFoundException;

import org.apache.lucene.index.IndexWriter;

import indexer.ConceptParser;
import indexer.Importer;

public class RawImporter implements Importer
{
	private final IndexWriter writer;
	
	public RawImporter(IndexWriter writer)
	{
		this.writer = writer;
	}
	
	public Runnable process(File file) throws FileNotFoundException
	{
		return new ConceptParser(file, writer);
	}
}
