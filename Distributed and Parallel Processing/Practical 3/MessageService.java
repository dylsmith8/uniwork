/*
  Author: Dylan Smith
  Date: 10 August 2016
  Interface that defines the server's remote methods
*/
import java.rmi.Remote;
import java.rmi.RemoteException;

public interface MessageService extends Remote {
  public void storeMessages(String username, String[] messages) throws RemoteException;
  public String[] getMessages(String username) throws RemoteException;
}
