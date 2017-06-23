/*
  Author: Dylan Smith
  Date: 15 August 2016

  The Producer process
*/
import org.jcsp.lang.*;

/** Producer class: produces one random integer and sends on
  * output channel, then terminates.
  */
public class Producer implements CSProcess
  { private ChannelOutputInt channel;
    private int startingVal;
    public Producer (final ChannelOutputInt out, int startingVal)
      { channel = out;
        this.startingVal = startingVal;
      } // constructor

    public void run ()  {
      for (int i = 0; i < 100; i++) {
        int item = (int)(Math.random()*100)+1+startingVal;
        channel.write(item);
      }
      channel.write(-1);
    } // run
  } // class Producer
