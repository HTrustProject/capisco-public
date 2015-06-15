package importers;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

import indexer.ImportBuffer;
import indexer.Importer;

public class ZipImporter implements Importer
{
	private class Unzipper implements Runnable
	{
		private final File zip;
		
		public Unzipper(File zip)
		{
			this.zip = zip;
		}

		@Override
		public void run()
		{
			try
			{
				ZipInputStream zipIn = new ZipInputStream(new FileInputStream(zip.getPath()));
				ZipEntry entry = zipIn.getNextEntry();
				while (entry != null)
				{
					String filePath = zip.getParent() + File.separator + entry.getName();
					if (entry.isDirectory())
					{
						File directory = new File(filePath);
						directory.mkdir();
						directory.deleteOnExit();
					}
					else
					{
						File file = new File(filePath);
						BufferedOutputStream bos = new BufferedOutputStream(new FileOutputStream(file));
						byte[] bytesIn = new byte[BUFFER_SIZE];
						int read = 0;
						while ((read = zipIn.read(bytesIn)) != -1)
							bos.write(bytesIn, 0, read);
						bos.close();
						buffer.process(file);
						file.deleteOnExit();
					}
					zipIn.closeEntry();
					entry = zipIn.getNextEntry();
				}
				zipIn.close();
			}
			catch(IOException e)
			{
				System.err.format("Failed to unzip %1$s (%2%s)", zip, e.getMessage());
			}
		}
		
		public String toString()
		{
			return "Unzip " + zip;
		}
	}
	
	private static final int BUFFER_SIZE = 4096;
	
	private final ImportBuffer buffer;
	
	public ZipImporter(ImportBuffer buffer)
	{
		this.buffer = buffer;
	}

	@Override
	public Runnable process(File file) throws IOException
	{
		return new Unzipper(file);
	}
}
