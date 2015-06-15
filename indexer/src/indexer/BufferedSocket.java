package indexer;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.net.InetAddress;
import java.net.Socket;

public class BufferedSocket
{
	private Socket socket;
	private final BufferedReader in;
	private final BufferedWriter out;

	public BufferedSocket(InetAddress address, int port) throws IOException
	{
		try
		{
			socket = new Socket(address, port);
			in = new BufferedReader(new InputStreamReader(socket.getInputStream()));
			out = new BufferedWriter(new OutputStreamWriter(socket.getOutputStream()));
		}
		catch (IOException e)
		{
			throw e;
		}
	}
	
	public BufferedReader getInput()
	{
		return in;
	}
	
	public BufferedWriter getOutput()
	{
		return out;
	}
	
	public boolean isClosed()
	{
		return socket.isClosed();
	}
	
	public void close() throws IOException
	{
		socket.close();
	}

	@Override
	protected void finalize()
	{
		try
		{
			socket.close();
		}
		catch (IOException e)
		{
			System.err.println("Connection to server terminated ungracefully");
		}
		System.out.println("Closed connection to server");
	}
}
