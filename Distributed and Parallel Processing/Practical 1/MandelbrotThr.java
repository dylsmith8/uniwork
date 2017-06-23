/*
  Modified byt Dylan Smith - 13s0714
  Mandelbrot modified to use Callable, Futures and Executors

  Code changes are in CAPS
*/

import java.applet.*;
import java.awt.*;
import java.awt.event.*;
import java.util.Date;
import java.util.concurrent.*;

public class MandelbrotThr extends Applet
    implements Runnable, MouseListener, MouseMotionListener
  { private int xsize;      // dimensions of window
    private int ysize;
    private int taskSize;
    private final int NUM_TASKS = 100;
    private Thread master;
    private long startTime;

    // initial region for which Mandelbrot is being computed
    private double x1 = -2.25;
    private double x2 =  3.0;
    private double y1 = -1.8;
    private double y2 =  3.3;

    private boolean done = false;   // computation finished?
    private int progress;           // number of scan lines
    private boolean drag = false;   // user dragging zoom box?

    // off-screen buffer and graphics
    private Image offscreen;
    private Graphics offg;

    public void init()
      { xsize = getSize().width;
        ysize = getSize().height;
        System.out.println("xsize = " + xsize + " ysize = " + ysize);
        taskSize = ysize / NUM_TASKS;

        // set up listeners
        this.addMouseListener(this);
        this.addMouseMotionListener(this);
      } // init

    public void start ()
      { // create offscreen buffer
        offscreen = createImage(xsize, ysize);
        if (offscreen == null)
          { System.err.println("ERROR: Cannot create offscreen image.");
            System.exit(1);
          }
        offg = offscreen.getGraphics();
        offg.setColor(Color.black);
        offg.fillRect(0, 0, xsize, ysize);

        // spawn thread to handle computations
        if (master == null)
          { master = new Thread(this);
            master.start();
          }
      } // start

    public void run()
      { while (true)
          { while (done)
              { try
                  { Thread.sleep(500);
                  }
                catch (InterruptedException e)
                  { // ignore
                  }
              }
            generateImage();
          }
      } // run

    /*
      THIS METHOD INITIALLY CREATED NEW THREADS CREATING A WorkerThread OBJECT AND INVOKING RUN.

      IT NOW USES A Callable AND Future OBJECT AND HAS SUITABLE
      ERROR CHECKING
    */
    private void generateImage()
      {
        final int N_THRS = 5;
        // SHOULD CALL THE WORKER THREADS HERE
        ExecutorService threadPool = Executors.newFixedThreadPool(N_THRS);
        startTime = System.currentTimeMillis();
        for (int i = 0; i < ysize; i += taskSize)
          {
            // REPRESENTS THE TASK THAT RETURNS A 2D BYTE ARRAY
              // TASK IN THIS CASE EXECUTES calculateMandelbrot
            Callable <byte[][]> tasks = new WorkerThread(i, i+taskSize);
            // Future OBJECT THAT'S USED TO GET THER RESULT
            Future <byte[][]> results = threadPool.submit(tasks);
            try {
                // CALL DISPLAY BASED ON WHAT WE GOT Future
                display(results.get(), i);
            } catch (ExecutionException ex) {
              ex.printStackTrace();
            } catch (InterruptedException e) {
              e.printStackTrace();
            }
          }
        waitForResults();
      } // generateImage

    private void waitForResults ()
      { while (progress != NUM_TASKS)
          { try
              { Thread.sleep(100);
              }
            catch (InterruptedException e)
              { // ignore
              }
          }

        done = true;
        long end = System.currentTimeMillis();
        System.out.println("Time taken: " + (end-startTime) + "ms.");
        repaint();
      } // waitForResults

    public void mouseDragged (MouseEvent e)
      { int x = e.getX();
        int y = e.getY();
        if (done)
          { drag=true;
            Graphics g=this.getGraphics();
            g.drawImage(offscreen,0,0,this);
            g.setColor(Color.white);
            g.drawRect(x-xsize/4,y-ysize/4,xsize/2,ysize/2);
          }
      } // mouseDragged

    public void mouseReleased(MouseEvent e)
      { int x = e.getX();
        int y = e.getY();
        if (done)
          { x1 += ((float)x / (float)xsize) * x2;
            y1 += ((float)y / (float)ysize) * y2;
            x2 /= 2.0;
            y2 /= 2.0;
            x1 -= x2 / 2.0;
            y1 -= y2 / 2.0;
            done = false;
            drag = false;
            offg.setColor(Color.black);
            offg.fillRect(0, 0, xsize, ysize);
            progress = 0;
            repaint();
            // generateImage();
          }
      } // mouseReleased

    public void update( Graphics g )
      { if (!drag)
          { paint(g);
          }
      } // update

    public void paint (Graphics g)
      { if (!drag)
          { if (done)
              { g.drawImage(offscreen,0,0,this);
              }
            else
              { if (offscreen != null)
                  g.drawImage(offscreen,0,0,this);
                g.setColor(Color.white);
                g.drawRect(xsize/4, 10, xsize/2, 5);
                g.fillRect(xsize/4, 11, (progress*(xsize/2))/NUM_TASKS, 4);
              }
          }
      } // paint

    private Color getPixelColour (int val)
      { Color colour;

        if (val == 100)     colour = new Color(0,0,0);
        else if (val > 90)  colour = new Color(val*2,0,(val-90)*25);
        else if (val > 80)  colour = new Color(val*2,0,0);
        else if (val > 60)  colour = new Color(val*3,0,val);
        else if (val > 20)  colour = new Color(val*4,0,val*2);
        else if (val > 10)  colour = new Color(val*5,0,val*10);
        else                colour = new Color(0,0,val*20);
        return colour;
      } // getPixelColour

    /*
      synchronized USED TO ENSURE CORRECT THREAD SYNC.
      ENSURES THAT GRAPHICS ARE DISPLAYED CORRECTLY
    */
    private synchronized void display (byte[][] points, int start)
      { int j = 0;
        for(int l=start;j < taskSize; j++, l++)
          { for(int k = 0; k < xsize; k++)
              { int n = points[k][j];
                Color pixelColour = getPixelColour(points[k][j]);
                offg.setColor(pixelColour);
                offg.fillRect(k, l, 1, 1);
              }
          }
        repaint();
      } // display

    public void mousePressed(MouseEvent e) {}
    public void mouseClicked(MouseEvent e) {}
    public void mouseEntered(MouseEvent e) {}
    public void mouseExited(MouseEvent e) {}
    public void mouseMoved(MouseEvent e) {}

    public static void main (String args[])
      { Frame f = new Frame("Mandelbrot applet");
        f.addWindowListener(new WindowCloser());
        Applet a = new MandelbrotThr();
        a.setSize(800, 800);
        f.setSize(800, 800);
        f.add(a, BorderLayout.CENTER);
        a.init();
        f.setVisible(true);
        a.start();
      } // main

    // Inner classes

    private static class WindowCloser extends WindowAdapter
      {
        public void windowClosing (WindowEvent e)
          { System.exit(0);
          }
      } // inner class WindowCloser

    /* MADE THE CLASS IMPLEMENT Callable INSTEAD OF Runnable
    */
    public class WorkerThread implements Callable
      { private int start;
        private int end;

        public WorkerThread (int start, int end)
          { this.start = start;
            this.end = end;
          } // constructor

        // RETURN BYTES INSTEAD OF LEAVING IT AS VOID
        public byte[][] calculateMandelbrot()
          { double x, y, xx, a, b = y1, da = x2/xsize, db = y2/ysize;
            byte[][] results = new byte[xsize][end-start];

            for (int i = 0; i < start; i++)
              { b = b + db;
              }

            int k = 0;

            for (int i = start; i < end; i++, k++)
              { a = x1;
                for (int j = 0; j < xsize; j++)
                  { byte n = 0;
                    x = 0.0;
                    y = 0.0;
                    while ( (n < 100) && ( (x*x)+(y*y) < 4.0) )
                      { xx = x * x - y * y + a;
                        y = 2 * x * y + b;
                        x = xx;
                        n++;
                      }
                    results[j][k] = n;
                    a = a + da;
                  }
                b = b + db;
              }
            progress += 1;
            /*
              INSTEAD OF CALLING display DIRECTLY, SIMPLY RETURN
              THE RESULTS OF THE CALCULATION FOR A Future OBJECT THAT IS
              USED IN generateImage
            */
            return results;
          } // calculateMandelbrot

        /* call MUST BE IMPLEMENTED SINCE Callable IS IMPLEMENTED IN
           THE CALL DEFINITION -- RETURNS THE RESULTS RETURNED BY
           calculateMandelbrot. run DOES NOT RETURN A RESULT
        */
        public byte[][] call()
          { return calculateMandelbrot();
          } // run
      } // inner class WorkerThread
  } // class MandelbrotThr
