/*
  Author: Dylan Smith
  Date: 15 August 2016

  Buffer process for the Producer-Consumer Problem
*/
import org.jcsp.lang.*;
public class Buffer implements CSProcess {

  // prod / con 1
  private AltingChannelInputInt inputChannel1;
  private ChannelOutputInt outputChannel1;
  private AltingChannelInputInt requestChannel1;

  // prod / con 2
  private AltingChannelInputInt inputChannel2;
  private ChannelOutputInt outputChannel2;
  private AltingChannelInputInt requestChannel2;

  private int buffer [] = new int[10];
  private int x = 0; // HEAD
  private int y = 0; //  TAIL
  private int subscript = 0;

  private int terminate = 4;

  public Buffer (final AltingChannelInputInt inputChannel1,
                 final ChannelOutputInt outputChannel1,
                 final AltingChannelInputInt requestChannel1,

                 final AltingChannelInputInt inputChannel2,
                 final ChannelOutputInt outputChannel2,
                 final AltingChannelInputInt requestChannel2) {

     // intilise prod1 / con1 channels
     this.inputChannel1 = inputChannel1;
     this.outputChannel1 = outputChannel1;
     this.requestChannel1 = requestChannel1;
     // intilise prod2 / con2 channels
     this.inputChannel2 = inputChannel2;
     this.outputChannel2 = outputChannel2;
     this.requestChannel2 = requestChannel2;
   } // constructor

  public void run() {

    boolean guardBools [] = new boolean[4];

    final Alternative alt = new Alternative(new Guard[]{inputChannel1, requestChannel1, inputChannel2, requestChannel2}); // channel guards

    while (terminate > 0) {

      guardBools[0] = subscript < 10; // buffer is not full
      guardBools[1] =  subscript > 0; // buffer

      guardBools[2] = subscript < 10;
      guardBools[3] = subscript > 0;

      switch (alt.select(guardBools)) {
        case 0:
            if (x < y + 10) {
              int value = inputChannel1.read();
              if (value != -1) {
                buffer[x % buffer.length] = value;
                subscript++;
                x++;
              }
              else {
                buffer[x % buffer.length] = value;
                subscript++;
                x++;
                terminate--;
              }
              break;
            }
        case 1:
            if (requestChannel1.read() == 1) {
              int item = buffer[y % buffer.length];
              if (y < x) {
                if (item == -1) terminate--;
                outputChannel1.write(item);
                subscript--;
                y++;
              }
              break;
            }
        case 2:
            if (x < y + 10) {
              int value = inputChannel2.read();
              if (value != -1) {
                buffer[x % buffer.length] = value;
                subscript++;
                x++;
              }
              else {
                buffer[x % buffer.length] = value;
                subscript++;
                x++;
                terminate--;
              }
              break;
            }
        case 3:
            if (requestChannel2.read() == 1) {
              int item = buffer[y % buffer.length];
              if (y < x) {
                if (item == -1) terminate--;
                outputChannel2.write(item);
                subscript--;
                y++;
              }
              break;
            }
        default:
            System.out.println("An error occured");
      } // switch
    } // while true
    System.out.println("All processes terminated cleanly");
  }// run
}
