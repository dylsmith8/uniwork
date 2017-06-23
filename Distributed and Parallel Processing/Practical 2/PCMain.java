/*
  Author: George Wells
  Modified by: Dylan Smith
  Date: 15 August 2016

  The Driver program
*/
import org.jcsp.lang.*;

/** Main program class for Producer/Consumer example.
  * Sets up channel, creates one of each process then
  * executes them in parallel, using JCSP.
  */
public final class PCMain
  {
    public static void main (String[] args)
      { new PCMain();
      } // main

    public PCMain ()
      {
        // channel objects for Producer1 and Consumer 1
        final One2OneChannelInt producer1ToBuffer = Channel.one2oneInt();
        final One2OneChannelInt bufferToConsumer1 = Channel.one2oneInt();
        final One2OneChannelInt consumer1ToBufferRequest = Channel.one2oneInt();

        //channel objects for Producer 2 and Consumer 2
        final One2OneChannelInt producer2ToBuffer = Channel.one2oneInt();
        final One2OneChannelInt bufferToConsumer2 = Channel.one2oneInt();
        final One2OneChannelInt consumer2ToBufferRequest = Channel.one2oneInt();

        // Create and run parallel construct with a list of processes
        CSProcess[] procList = {

          new Producer(producer1ToBuffer.out(), 0),
          new Producer(producer2ToBuffer.out(), 100),
          new Buffer (
            producer1ToBuffer.in(),
            bufferToConsumer1.out(),
            consumer1ToBufferRequest.in(),

            producer2ToBuffer.in(),
            bufferToConsumer2.out(),
            consumer2ToBufferRequest.in()
            ),

          new Consumer(bufferToConsumer1.in(), consumer1ToBufferRequest.out()),
          new Consumer(bufferToConsumer2.in(), consumer2ToBufferRequest.out())
        }; // Processes
        Parallel par = new Parallel(procList); // PAR construct
        par.run(); // Execute processes in parallel

        System.out.println("Run sucessful");
      } // PCMain constructor

  } // class PCMain
