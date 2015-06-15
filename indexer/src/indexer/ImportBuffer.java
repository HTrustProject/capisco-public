package indexer;

import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.Queue;
import java.util.Stack;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.atomic.AtomicLong;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

public class ImportBuffer
{
	private class Work
	{
		final File file;
		final int estimate;
		
		public Work(File file)
		{
			this.file = file;
			this.estimate = count(file);
		}
		
		public int count(File file) {
	        int total = 0;
            if (file.isDirectory())
            	for (File child : file.listFiles())
	                total += count(child);
            else
                total += 1;
	        return total;
	    }
	}
	
	private HashMap<String, Importer> importers = new HashMap<>();
	private Stack<Work> files = new Stack<>();
	private Queue<Runnable> tasks = new LinkedList<>();
	private int remaining;
	
	public final Lock lock = new ReentrantLock();
	public final Condition added = lock.newCondition();
	public final Condition progress = lock.newCondition();
	public final AtomicInteger running = new AtomicInteger();
	public final AtomicInteger completed = new AtomicInteger();
	public final AtomicLong totalTime = new AtomicLong();
	
	public int running()
	{
		return running.get();
	}
	
	public int remaining()
	{
		return remaining;
	}
	
	public int total()
	{
		return running.get() + remaining + completed.get();
	}
	
	public synchronized boolean hasNext()
	{
		return (tasks.size() + files.size() > 0);
	}
	
	public synchronized int available()
	{
		return tasks.size();
	}
	
	public synchronized void buffer(final Runnable task)
	{
		Runnable wrapper = new Runnable()
		{
			@Override
			public void run()
			{
				long start = System.currentTimeMillis();
				running.incrementAndGet();
				task.run();
				running.decrementAndGet();
				completed.incrementAndGet();
				long time = System.currentTimeMillis() - start;
				totalTime.addAndGet(time);
				lock.lock();
				progress.signal();
				lock.unlock();
			}
		};
		tasks.add(wrapper);
		lock.lock();
		added.signal();
		lock.unlock();
	}
	
	public synchronized Runnable next()
	{
		while (tasks.size() == 0 && files.size() > 0)
		{
			Work first = files.pop();
			remaining -= first.estimate;
			process(first.file);
		}
		return tasks.poll();
	}
	
	public void process(File file)
	{
		if (file.isDirectory())
		{
			for (File child : file.listFiles())
			{
				Work work = new Work(child);
				files.push(work);
				remaining += work.estimate;
			}
		}
		else
		{
			String name = file.getName();
			String[] components = name.split("\\.");
			if (components.length == 1)
				System.out.format("File %1$s has no extension\n", file);
			else
			{
				Importer importer = importers.get(components[components.length - 1]);
				if (importer == null)
					System.out.format("No importer for .%1$s files - skipping %2$s\n", components[1], file);
				else
				{
					try
					{
						Runnable task = importer.process(file);
						buffer(task);
					}
					catch(IOException e)
					{
						System.err.format("Could not queue %1$s for import (%2$s)\n", file, e.getMessage());
					}
				}
			}
		}
	}
	
	public double percent()
	{
		int remainder = running.get() + remaining;
		int total = completed.get() + remainder;
		double percent = ((total - remainder) * 100) / (double)total;
		return percent;
	}
	
	public void addImporter(String extension, Importer importer)
	{
		importers.put(extension, importer);
	}
}
