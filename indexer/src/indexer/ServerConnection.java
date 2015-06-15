package indexer;

import java.io.IOException;
import java.net.InetAddress;

public class ServerConnection extends ThreadLocal<BufferedSocket>
{
	public static InetAddress address;
	public static int port;
	
	private BufferedSocket server = null;
	
	@Override
	public BufferedSocket initialValue()
	{
		try
		{
			server = new BufferedSocket(address, port);
			System.out.println("Opened connection to server");
		}
		catch (IOException e)
		{
			System.err.println(e);
			server = null;
		}
		return server;
	}
	
	@Override
	public void remove()
	{
		try
		{
			if (server != null && !server.isClosed())
				server.close();
			System.out.println("Closed connection to server");
		}
		catch (IOException e)
		{
			System.err.format("Unable to close connection to server (%1$s)", e.getMessage());
		}
		finally
		{
			server = null;
		}
		super.remove();
	}
}
