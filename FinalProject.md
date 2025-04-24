# Final Project Assessment and Feedback
Class: CS 373 - Digital Logic Design Assessment
Last Modified: 11/25/2024

### Final Project Details Grade Break Down
| Part                                          |  Earned | Points  |
|-----------------------------------------------|---------|---------|
| Documentation: ProjectReadme.md File          |         |         |  
| * Title                                       |         |  5 pts  |
| * Description and Goals                       |         |  5 pts  | 
| * Usage guide                                 |         |  5 pts  |
| * Hardware diagram                            |         | 10 pts  | 
|                                               |         |
| VHDL Files with Comments                      |         |         | 
| * Working project submitted to whitgit        |         | 25 pts  |
|                                               |         |         |
| Final Presentation & Analysis                 |         | 25 pts  | 
| Final Reflection Graded Individually (25pts)  |         | 25 pts  |
| Total                                         |         | 100 pts |

### General Requirements
Overall this project, presentation, and reflection will form 20% of your total grade for this class.  
* Pick a problem or application that seems interesting to the majority of your group and implements the concepts we have learned this semester. 
* Example ideas for projects are listed later in this document. 
* Once you have picked a project, list the features that you hope to implement from easy to hard. 
* Whatever project you choose, layout a first draft of the major hardware components and the hardware design before you attempt to write the VHDL. 
* Divide your project up into major components. Design an entity for each unique component. 
* In your top level file, include the components and use portmaps to connect your design together and to the FPGA board.

### Group Project Structure and Professionalism
You will be assigned a group for this final project. You will however have 

Professional conduct when interacting with others in your group will be important. If there are specific reasons you cannot participate in a group and wish to work alone, please state this in the group survey.

Desirable group behaviors are:
* Treating your group partner(s) the way you wish to be treated. 
* Following through on scheduled meetings (or texting/emailing if there is an emergency and a meeting can't be attended on time)
* Practicing good listening skills and diplomacy when discussing issues or problems with the hardware design. 
* Working to seek an understanding of your group partners and then focus on fixing issues.

In addition, since this project will be completed as a group, all VHDL hardware will be written utilizing pair/group programming, this means that:
* All group members will be present and actively engaged (e.g. using Live Share and Discord)  when working on the major hardware components together.
* Look for ways to include all group members in the design and learning process.  
* The rest of the work should be evenly divided among the group members and all group members should review all work before submitting it.
* The development of the documentation preferably should be done as a pair/group, but this is not required.
* Reliability in attending meetings, group project participation, will all form a part of your final grade for this project. 
  
All documents, with the exception of the confidential individual feedback sent via email, will be submitted via Whitgit. You and your partner will have access to a group project folder on whitgit. The submission closest to, but not past the start of the final presentations for your section will be graded.

### Project Description and Ideas

### READ THIS FIRST
* I can't emphasize this enough - start with small, (seemingly) ridiculously simple goals first, get that goal working, then incrementally make it more complex.
* I caution against believing you can write all the VHDL in one big session. That has made previous groups very sad, stressed, and resulted in lots of errors that are hard to track down. Incrementally grow your project with a series of small incremental steps.
* Make use of the simulation capability to understand and check your modules!
* Make use of the LEDs to help you understand and debug your hardware state! 
* TIP: Start with previous code allready presented in class as an example, make simple modifications to the code (i.e. morph it), into what you want. For example, make small changes to modify the colors or react to the switches or push-buttons.
* I highly encourage you to make smaller modules that you can test independantly of the overall project. Divide and conquer!
* If your hardware grows into one huge if - else if - else structure (i.e. a  multiplexer ), make it modular and structural but start small!
   
### Here are ideas that you can grow towards as you learn...
__I/O Components__
* Utilize the text generator example and modify it to be able to put messages anywhere on the screen.
* Utilize the keyboard example interface to make an application that uses the keyboard.
* Develop VHDL hardware that can talk to an external device via a pmod port on the BASYS board.

__A Game__
* Pong – use either a keyboard or buttons on the board as controllers. Show pong on the VGA monitor
* A Hardware Based Tic Tac Toe Game 
* Some other simple game
* Bonus points - program the SPI interface and use a joystick controller that's in the lab.

__PMOD Board Applications__
* Easy if no Input/Output
* Much harder if using audio input/output
* Digital Filter - Implement a digital filter for filtering audio or other signals 
  
__A Mathematical Application or Processor__
* VERY HARD
* A floating point ALU to do floating point addition / subtraction / multiplication
* A Mandelbrot fractal generator (very challenging without a microprocessor and a floating point unit and has been successfully accomplished only once before.)
* A hardware based encryption program that implements RSA (again, challenging because it relies on hardware for arbitrarily large integers) 
* Some other mathematical application approved by your instructor.
  
__Some Other Application Approved by Your Instructor__
* Talk to your instructor and get a project of your group's choosing approved.


### Deliverable #1: Optional Project Proposal 
I highly encourage each group to make a short project proposal to your instructor before you proceed. You don't want to be that group which at presentation time their project was not sufficient!  Take the time to talk to your instructor and determine if the level of difficulty is acceptable. Write up the project paragraph. Discuss this with your instructor soon. This can eventually become a part of your ProjectReadme.md file.

### Deliverable #2: ProjectReadme.md File along  with the Final Project Code Due on Final Presentation Day
Your group will submit a Readme.md file along with your with all the hardware VHDL files for your project to your shared Whitgit final project repository. 

The __ProjectReadme.md__ file will contain:
 * Title - The title of your final project VHDL device.                                      
 * Description and Goals - A short description of the purpose and goals of the hardware device.
 * Usage guide - How to use the hardware                              
 * Hardware diagram - A hardware diagram of your project. If you made your project modular, you may use Vivado's hardware diagram (use structural VHDL code to have this be readable and easily generated by vivado). I don't want to see masses of logic gates though! Look at the examples I shared in class powerpoints (e.g. the VGA driver example)
 * __Works Cited__ This should includes any third party libraries used, any online sources and any VHDL utilized that was not specifically written for this project. These citations should also be listed directly in your VHDL.

NOTE: Your hardware project must use the gen.sh script to build the project with vivado. 

### Deliverable #3: Final Presentation at the Final
During the final time for your section, your group will give a presentation on the work that you accomplished. 

* You must present your original (and possibly modified) goals.
* You must present your high level hardware diagram. You can draw this with a hardware drawing tool, OR if you designed your components using structural VHDL code, then the hardware diagram made for you by Vivado will be easier to comprehend and read and of better quality for presentation.
* You must demonstrate your project working or describe what components are working and what roadblocks you encountered.
  

### Deliverable #4: Individual Project Reflection Form
After the project is over, students will be provided a reflection form that each must fill out individually. The questions on the form will be reflective in nature and likely very similar to these shown here:

* Please rate how well you feel your group worked together (0-Poorly 3-Average 5-Excellent) 
* Please rate how well you worked at contributing to the group as a whole.
* Do you feel like your ideas were listened to by other group members?
* Did group members treat each other professionally and with respect?
* Were you able to contribute at the level you wanted to, and if not, what ideas do you have for FP3 to ensure that you will be able to contribute to the project?
* Did all the group members in the group hold up their end of the individual group contract?
* Did you and your team made good team decisions, or did your or other team members make major decisions without first talking to the team as a whole?
* Did you and your team members shown passion/interest/enthusiasm for what you are building?
* What should you and your team keep doing well in the future?
* If there were issues, what improvements can you and your team make in the future to avoid them?
* Anything else you want to communicate?
