/*
  Author: Dylan Smith
  Date: 10 August 2016

  Class implements the server part of the RMI message service
*/
import java.rmi.registry.Registry;
import java.rmi.registry.LocateRegistry;
import java.rmi.RemoteException;
import java.rmi.server.UnicastRemoteObject;
import java.util.Hashtable;

public class MessageServiceServer implements MessageService {

  Hashtable msgStorage;

  public MessageServiceServer() {
    this.msgStorage = new Hashtable(); // initilise hashtable
  } // Constructor

  public void storeMessages(String username, String[] messages) {
    msgStorage.put(username, messages);
  }

  public String[] getMessages(String username) {
    return (String[]) msgStorage.get(username);
  }

  public static void main (String[] args) {
    try {
      MessageServiceServer msgServer = new MessageServiceServer();
      MessageService stub = (MessageService) UnicastRemoteObject.exportObject(msgServer, 0);
      Registry reg = LocateRegistry.getRegistry();
      reg.bind("RMI_MESSAGE_SERVICE", stub);
      System.out.println("RMI Message Service Ready");
    } catch (Exception e) {
      System.err.println("Server exception: " + e.toString());
      e.printStackTrace();
    }
  } // main
} // MessageServiceServer
