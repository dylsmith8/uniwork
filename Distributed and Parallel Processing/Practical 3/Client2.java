/*
  Author: Dylan Smith
  Date: 10 August 2016

  Simple class that RETRIEVES messages using a remote method 
*/
import java.rmi.registry.LocateRegistry;
import java.rmi.registry.Registry;
import java.rmi.RemoteException;
import java.util.Scanner;

public class Client2 {
  public static void main (String [] args) {
    MessageService msg = null;
    String[] messages = new String[10000];
    try {
      Registry reg = LocateRegistry.getRegistry();
      msg = (MessageService) reg.lookup("RMI_MESSAGE_SERVICE");
    } catch (Exception e) {
      e.printStackTrace();
    }

    Scanner input = new Scanner(System.in);
    System.out.println("Please enter a username");
    String username = input.nextLine();

    try {
      String[] arr = msg.getMessages(username);
      System.out.println("The message: " + arr[0]);
    } catch (RemoteException e) {
      e.printStackTrace();
    }
  }
}
