# 2700_GROUP

##Team Member Breakdown

**Jay Zhang-**
Roles and Responsibilities-
Lead programmer for Exercise 1
Lead programmer for Exercise 2
Assisted with Exercise 3
Assisted with integration Exercise 4

**Marco Tupaz**
Roles and Responsibilities-
Assisted with  Exercise 1
Assisted with Exercise 3
Assisted with integration in Exercise 4
Pseudocode and Flowchart Editor

**Ethan Susanto**
Roles and Responsibilities-
Worked on Exercise 2
Lead programmer for  Exercise 3
Looked after the Dragon-12 board

##Program Overview

###Exercise 1

Each individual task is split into separate functions that can be called on by the programmer. The low2up module converts all characters in a string to lowercase. The up2low module converts all characters to uppercase. The CapWord module converts all characters to lowercase and then capitalises each word by checking if there is a space in front of it. CapSen converts all characters to lowercase and then capitalises words that are preceded by a space and fullstop. These modules were all combined into one program.

###Exercise 2

Each of the tasks were split into their own programs that run independently from each other. Each program is then broken down into its own modules to perform the set task. Task 1 ….
Task 3 stored in PRESS_CHANGE looks at the locations of the string to be displayed and maps them to the location of where the LED memory is stored. Each number is then called by polling button in port P and displayed onto the LED. Task 4 stored in 7_led_show_all will map ASCII values in their hex code to their corresponding numerical symbol and display it on the LED by loading data into port P to enable the LEDs and then port B to light them up. Task 5 will display a string that is longer than four characters by scrolling it through the LEDs from right to left. To do this we reserve four bytes for the characters that need to be displayed and this string is uploaded to the LEDs at each iteration. These characters in memory are updated to reflect the next string to display. 

###Exercise 3

Each of the tasks were once again split into their own programs and then combined into one program for task 4. For each task, the SCI1 port was set as the serial communication port between the computer and the Dragon-12 board. Task 1 loads a string into X, loads the first character into A and then writes it to the serial port when the TDRE bit has been set. It then increments through X until all characters have been displayed. Task 2 reserves a memory space of 100 bytes and when the RDRF bit has been set, will store the character transmitted by the serial to the pointer in the reserved memory. Task 3 builds on Task 2 by continually storing characters into memory while in a loop until the RETURN character is read by the serial port. If the RETURN character is read, return to the start of the program. Task 4 is a combination of Task 1 and Task 3, that will store an inputted string into reserved memory until the RETURN character is read. Once the RETURN is read, it will point back to the start of memory and output the characters into the string by incrementing through the memory everytime TDRE is set. 

###Exercise 4

Exercise 4 is the integration of Exercise 1, 3 and Exercise 2-Task 4. A string from serial is first read and stored into reserved memory. When the string has been inputted, the pointer for X is reset to the start of memory and checks if the mode of changing the string has been set by the button at PH0. Pressing the button PH0 will trigger an interrupt to update a variable that sets the mode to update the string. Once the mode has been determined, the string will either be changed to uppercase in the default state or all words are capitalised if the button is pressed. This new string is then sent back through serial to the transmitter. This program loops continuously. 

##Instructions for User:

For serial input and output, ensure a wire is connected to Serial Port 1 (right side of the HCS12)
For power and debugging, connect a wire to Serial Port 0 (left side of HCS12)
If Windows user, use the PUTTY software to have a Serial terminal to send and receive messages from the HCS12
Button that is used for all exercises is PH0 (rightmost button)
Setting up Putty
Choose ‘Serial’ as Connection type in Session tab
Set baud rate to 9600
Set Serial line to whatever port the HCS12 is connected to on your computer
In Terminal tab, tick box for Implicit LF in every CR
In Serial tab under Connection, set Flow Control to be None

##Test Plan:

###Exercise 1:

**Task1: Lower to Upper case**
Task1 Modular Test:
1.Load testing string
2.Open debug mode
3.Set a breakpoint in low2up subroutine at “cmpa #$61”
4.Spc to the $1000 where the testing string  is stored
5.Run the code till breakpoint
6.Step from the breakpoint to the line “staa 0,x” and check:
If the range we provided can check lower case letter
If we can change it into upper case
		7.Remove breakpoint and set new breakpoint at ‘pula’ of done subroutine
		8.Run the code till breakpoint and check if the code can find the end of string
	
**Task1 integration test:**
1.Load testing string
2.Open debug mode
3.Set breakpoint after “jsr up2low” in Start 
4.Spc to the $1000 where the testing string is stored
5.Run the code and check the result

**Task2: Upper to lower case**
Task2 Modular Test:
1.Load testing string
2.Open debug mode
3.Set a breakpoint in up2low subroutine at “cmpa #$5A”
4.Spc to the $1000 where the testing string is stored
5.Run the code till breakpoint
6.Step from the breakpoint to the line “staa 0,x” and check:
*If the range we provided can check upper case letter
*If we can change it into lower case
7.Remove breakpoint and set new breakpoint at ‘pula’ of done subroutine
8.Run the code till breakpoint and check if the code can find the end of string

Task2 integration test:
1.Load testing string 
2.Open debug mode
3.Set breakpoint after “jsr low2up” in Start 
4.Spc to the $1000 where the testing string is stored
5.Run the code and check the result

**Task3: Capitalise the first letter of each word, each other letter should be lower case**
Task3 Modular Test:
1.Load testing string
2.Open debug mode
3.Set a breakpoint in loop_word of CapWord subroutine at “cmpa #$20”
4.Spc to the $1000 where the testing string is stored
5.Run the code till breakpoint
6.Step from the breakpoint to the line “bne next_word” and check:
If the code can detect a space before a letter

Task3 integration test:
1.Load testing string 
2.Open debug mode
3.Set breakpoint after “jsr CapWord” in Start 
4.Spc to the $1000 where the testing string is stored
5.Run the code and check the result

**Task4: Capitalise the first letter of the string, and the first letter after a full stop**
Task3 Modular Test:
1.Load testing string 
2.Open debug mode
3.Set a breakpoint in loop_sen of CapSen subroutine at “cmpa #$20”
4.Spc to the $1000 where the testing string is stored
5.Run the code till breakpoint
6.Step from the breakpoint to the line “bne next_sen” and check:
If the code can detect a space and a full stop before a letter

Task4 integration test:
1.Load testing string 
2.Open debug mode
3.Set breakpoint after “jsr CapSen” in Start 
4.Spc to the $1000 where the testing string  is stored
5.Run the code and check the result

###Exercise 2:
The left up bit of the second 7_seg LED has a problem displaying, it requires more than 1 second to light up. The up left of the third and fourth 7_seg also have problems, they light up automatically by themself, we tested it using a project called 7_seg_tb. It can also be observed by the LEDs under 7 seg.

Task2 is included in the following tasks

Task3: Press button to change number displayed
Task3 modular test:
  1.Open the debug mode
  2.Set a breakpoint at “adda #$01” of Next sr
  3.Run the code till breakpoint and check:
  *if the register B is $FE
  *if the code detect input signal
  4.Click run again and check whether the displayed number changed
  5.Remove the breakpoint and set new at back sr
  6.Run the code and check if the end of the 4 numbers can be detected

Task3 integration test:
  1.Open debug mode
  2.2.Run the code
  3.Press the button PH0 and check if the number displayed change
	
Task4 Display 4 numbers in 7-seg LEDs:
Task4 modular test:
  1.Open the debug mode
  2. Set breakpoint at DISP_LETTER subroutine
  3.Run the code till breakpoint
  4.Step from breakpoint till “STAB PORTB” and check:
  *if the register Y point to the correct LED location ($1009-$100c)
  *if the register X point to the correct number($1000-$1003)      
  5.Click run again and keep checking    
  6.Remove breakpoint and set breakpoint at BRA inf_loop
  7.Check if the code can start the new loop                            

Task4 integration test:
  1.Open debug mode
  2.Run the code
  3.Check if all the numbers are shown

Task 5 Scroll a string longer than 4
Task5 modular test:
  1.Open the debug mode
  2.Spc the memory location of the Display String($100b)
		
Check load_less_than 4 :
  3.Set breakpoint at less_than_4 subroutine
  4.Run the code till breakpoint
  5.Step from breakpoint to “inc step_counter”
  6.Check if the Display string has been changed correctly
Run again and repeat step 5 and 6 until we need to display 4 numbers
		
Check load 4:
  7.Remove the breakpoint and add a new one at greater_equal_4 sr
  8.Run the code till breakpoint
  9.Step through the g4_loop subroutine
  10.Check if the display string has been changed correctly
Run again and repeat step 9 and 10 until we need to fill number from tail

		Check move X to the tail of the string
		11.Step through the use_back subroutine until branching back to g4_loop
		12.Check if the register X to the tail of the whole string ($1006)
		13.Keep running the code and check if the display is correct
		
		Task5 integration test:
		1.Open debug mode
		2.Run the code
		3.Check if all the numbers are scrolling


Exercise 3:
	Before running any serial program
	Check baud rate is set to 9600
	This is done by loading #156 into SCI1BDL and loading #$00 in SCI1BDH
	Set #$4C to SCI1CR1 to set 8 bit word length and wake up bit
	Set #$0C to SCI1CR2 to enable SCI transmission and receiving bits

1.Check if each function is working properly. Set breakpoints to the beginning of each function (Start, Input, Return, Read, Write, Delay)
2.If error in start, step through
Check that x stores the memory address of the string
Check if functions used work
If error in Input
Is there an issue with receiving bit (infinite loop)
Is data storing in the correct location (SCI1DRL)
Is x being incremented to parse through string
Is the program returning after detecting a carriage return
If error in return
Check the stack, there may have been something pushed on top of the memory address to return to
If error in Read
Is x pointing to the string
Is program returning after detecting a carriage return
Is program branching to Write after loading character
If error in Write
Check if TDRE is being set
Check baud rate
Check serial interface (terminal)
Check communication port
Is character writing to serial SCI1DRL
Is the correct character being written to the serial
Is function returning to the correct location
If not check stack 
If error in Delay
Ensure numbers loaded into x and y registers are within a 16 bit range (~65000)
Does function return to the correct location?
If not check stack

Exercise 4:
Modular Test for Exercise4:
Functions used in this exercise have been tested in the previous exercise, here we  only show the modular test for the interrupt used in this exercise, which is new.
1.Open debug mode
2.Set breakpoint at port_h_isr (at line ‘staa PTH_0’)
3.Run the code and type input and press button
4.Check if the interrupt can be triggered and PTH_0 has been loaded with PTH value($FE).

Exercise4 integration test:
1.Open PuTTY set to serial
	2.Open debug mode and run the code
	3.Type input string from PuTTY
	4.Press/Don’t press button when LED indicates reading completed
	5.Check the output in PuTTY
