#!/bin/bash
cd /home/jsmith/Desktop/DPP_Prac2/PC
javac -cp ".:/home/jsmith/Desktop/DPP_Prac2/jcsp-1.1-rc4/jcsp.jar" Consumer.java
javac -cp ".:/home/jsmith/Desktop/DPP_Prac2/jcsp-1.1-rc4/jcsp.jar" PCMain.java
javac -cp ".:/home/jsmith/Desktop/DPP_Prac2/jcsp-1.1-rc4/jcsp.jar" Producer.java
java -cp ".:/home/jsmith/Desktop/DPP_Prac2/jcsp-1.1-rc4/jcsp.jar" PCMain
pause
