package indexer;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.Reader;
import java.io.Writer;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;

import org.apache.lucene.document.Document;
import org.apache.lucene.document.Field;
import org.apache.lucene.document.StringField;
import org.apache.lucene.document.TextField;
import org.apache.lucene.index.IndexWriter;

public class ConceptParser implements Runnable
{
	private static ThreadLocal<BufferedSocket> server = new ServerConnection();
	
	private final File source;
	private final IndexWriter writer;
	
	public ConceptParser(File source, IndexWriter writer) throws FileNotFoundException
	{
		if (!source.exists() || !source.isFile())
			throw new FileNotFoundException();
		this.source = source;
		this.writer = writer;
	}

	@Override
	public void run()
	{
		BufferedSocket socket = server.get();
		BufferedReader svin = socket.getInput();
		BufferedWriter svout = socket.getOutput();
		
		try
		{
			byte[] encoded = Files.readAllBytes(source.toPath());
			String content = new String(encoded, StandardCharsets.UTF_8);
			svout.write("topics __||__\n ");
			svout.write(content + "\n");
			svout.write("__||__\n");
			svout.flush();
		}
		catch(IOException e)
		{
			System.err.format("Failed to analyze %1$s (%2$s)", source, e.getMessage());
			return;
		}

		try
		{
			File topics = File.createTempFile(source.getName(), ".types"); // Could replace with a memory stream
			Writer topout = new FileWriter(topics);
			svin.readLine();
			String line = svin.readLine();
			while (!line.toString().equals("--message end--") && !line.equals("0--message end--"))
			{
				String[] words = line.split("\\|");
				if (words.length > 1)
					topout.write(words[1] + "|");
				line = svin.readLine();
			}
			topout.close();
			
			Document doc = new Document();
			Reader topin = new FileReader(topics);
			doc.add(new TextField("contents", topin));
			doc.add(new StringField("path", source.getPath(), Field.Store.YES));
			doc.add(new StringField("filename", source.getName(), Field.Store.YES));
			writer.addDocument(doc);
			topics.delete();
		}
		catch (IOException e)
		{
			System.err.format("Failed to add %1$s to index (%2$s)", source, e.getMessage());
			return;
		}
	}

	public String toString()
	{
		return "Index " + source;
	}
}
