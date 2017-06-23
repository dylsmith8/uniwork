/*
  Author: Dylan Smith
  Date: 15 August 2016

  The Consumer process
*/
import org.jcsp.lang.*;

/** Consumer class: reads one int from input channel, displays it, then
  * terminates.
  */
public class Consumer implements CSProcess
  {  private ChannelInputInt inputChannel;
     private ChannelOutputInt requestChannel;

     public Consumer (final ChannelInputInt inputChannel, final ChannelOutputInt requestChannel){
      this.inputChannel = inputChannel;
      this.requestChannel = requestChannel;
    }
    public void run ()
      {
        while (true) {
          requestChannel.write(1);
          int item = inputChannel.read();
          if (item==-1) break;
          else System.out.println(item);
        }
      } // run

  } // class Consumer
