rem Author: Dylan Smith
rem Date: 10 August 2016
rem Script that compiles and runs the producer/consumer program using the JCSP library
cd "C:\Users\g13s0714\Desktop\CS Honours\GitHub\DPP_Prac2\PC"
"C:\Program Files (x86)\Java\jdk1.7.0_79\bin\javac" -cp ".;C:\Users\g13s0714\Desktop\CS Honours\GitHub\DPP_Prac2\PC\jcsp-1.1-rc4\jcsp.jar;" Consumer.java
"C:\Program Files (x86)\Java\jdk1.7.0_79\bin\javac" -cp ".;C:\Users\g13s0714\Desktop\CS Honours\GitHub\DPP_Prac2\PC\jcsp-1.1-rc4\jcsp.jar;" PCMain.java
"C:\Program Files (x86)\Java\jdk1.7.0_79\bin\javac" -cp ".;C:\Users\g13s0714\Desktop\CS Honours\GitHub\DPP_Prac2\PC\jcsp-1.1-rc4\jcsp.jar;" Producer.java
"C:\Program Files (x86)\Java\jdk1.7.0_79\bin\java" -cp ".;C:\Users\g13s0714\Desktop\CS Honours\GitHub\DPP_Prac2\PC\jcsp-1.1-rc4\jcsp.jar;" PCMain
pause
