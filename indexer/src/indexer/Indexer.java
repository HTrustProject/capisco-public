package indexer;

import importers.RawImporter;
import importers.ZipImporter;

import java.io.File;
import java.io.IOException;
import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

import org.apache.lucene.analysis.Analyzer;
import org.apache.lucene.index.IndexWriter;
import org.apache.lucene.index.IndexWriterConfig;
import org.apache.lucene.store.FSDirectory;
import org.apache.lucene.util.Version;

public class Indexer
{
	private ExecutorService executor;
	public final ImportBuffer buffer;
	public final int workers;
	
	public Indexer(int workers)
	{
		buffer = new ImportBuffer();
		this.workers = workers;
		this.executor = Executors.newFixedThreadPool(workers);
	}
	
	public void run()
	{
		int running = 0;
		while (buffer.hasNext() || running > 0)
		{
			while(running == workers)
			{
				try
				{
					buffer.lock.lock();
					buffer.progress.await();
					buffer.lock.unlock();
					double percent = buffer.percent();
					String time = String.format("Progress: %6.2f%%, Completed tasks: %d/%d", percent, buffer.completed.get(), buffer.total());
					System.out.println(time);
				}
				catch (InterruptedException e)
				{
					System.out.println("Interrupted while waiting for any task to complete");
				}
				running = buffer.running();
			}
			while(running < workers && buffer.hasNext())
			{
				Runnable task = buffer.next();
				if (task != null)
					executor.execute(task);
				running = buffer.running();
			}
			while(running < workers && running > 0 && !buffer.hasNext())
			{
				try
				{
					buffer.lock.lock();
					buffer.progress.await();
					buffer.lock.unlock();
					double percent = buffer.percent();
					String time = String.format("Progress: %6.2f%%, Completed tasks: %d/%d", percent, buffer.completed.get(), buffer.total());
					System.out.println(time);
				}
				catch (InterruptedException e)
				{
					System.out.println("Interrupted while waiting for any task to complete");
				}
				running = buffer.running();
			}
		}
		System.out.println("All tasks complete, shutting down...");
		executor.shutdown();
		int awaits = 0;
		while(!executor.isTerminated() && awaits < 5)
		{
			try
			{
				executor.awaitTermination(60, TimeUnit.SECONDS);
			}
			catch (InterruptedException e)
			{
				awaits++;
			}
		}
		if (!executor.isTerminated())
			System.err.println("Failed to release task executor");
	}
	
	static IndexWriter createIndex(File location) throws IOException
	{
		try
		{
			FSDirectory dir = FSDirectory.open(location);
			Analyzer analyzer = new CustomAnalyzer();
			IndexWriterConfig config = new IndexWriterConfig(Version.LUCENE_4_10_1, analyzer);
			config.setOpenMode(IndexWriterConfig.OpenMode.valueOf("CREATE_OR_APPEND"));
			return new IndexWriter(dir, config);
		}
		catch (IOException e)
		{
			System.err.format("Could not create index writer (%1$s)", e.getMessage());
			throw e;
		}
	}
	
	public static void main(String[] args)
	{
		// arg[0] = WMI server address - the thing that returns the topics
		// arg[1] = server port
		// arg[2] = input documents directory path
		// arg[3] = where to create/append to the index
		// arg[4] = number of worker threads to run
		
		if (args.length != 4 && args.length != 5)
		{
			System.out.println("Use: WMindexer <server URI> <server port> <input documents path> <index path> [number of workers]");
			return;
		}
		
		try
		{
			ServerConnection.address = InetAddress.getByName(args[0]);
			ServerConnection.port = Integer.parseInt(args[1]);
		}
		catch (UnknownHostException e)
		{
			System.out.format("Unknown host \"%1$s\" (%2$s)", args[0], e.getMessage());
			System.exit(-1);
		}
		catch(NumberFormatException e)
		{
			System.out.format("Unknown port \"%1$s\" (%2$s)", args[1], e.getMessage());
			System.exit(-1);
		}
		
		int workers = 8;
		if (args.length == 5)
		{
			try
			{
				workers = Integer.parseInt(args[4]);
			}
			catch(NumberFormatException e)
			{
				System.out.format("Unable to interpret number of workers \"%1$s\" (%2$s)", args[1], e.getMessage());
				System.exit(-1);
			}
		}
		
		File documents = new File(args[2]);
		File index = new File(args[3]);
		try
		{
			IndexWriter writer = createIndex(index);
			Indexer indexer = new Indexer(workers);
			Importer raw = new RawImporter(writer);
			Importer zip = new ZipImporter(indexer.buffer);
			indexer.buffer.addImporter("txt", raw);
			indexer.buffer.addImporter("htm", raw);
			indexer.buffer.addImporter("html", raw);
			indexer.buffer.addImporter("zip", zip);
			indexer.buffer.process(documents);
			indexer.run();
		}
		catch(Exception e)
		{
			System.err.println("A fatal exception has occurred - " + e.getMessage());
			e.printStackTrace();
			System.exit(-1);
		}
	}
}
