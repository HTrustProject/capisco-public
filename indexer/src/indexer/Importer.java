package indexer;

import java.io.File;
import java.io.IOException;

public interface Importer
{
	public Runnable process(File file) throws IOException;
}
