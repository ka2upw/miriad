# miriad
M17 IP Reference Implementation and Demo

This program is a GUI front end that demonstrates sending and receiving
M17 encoded audio. You can use it to listen to what M17 audio sounds like.

The original source of the audio can be a local WAVE file or the 
default microphone on the computer. The audio is encoded using 
the m17-mod program.  

The encoded audio can then be written to a local WAVE file, played out
the speakers, or sent via TCPIP to another copy of the miriad software
(running either on the same computer or on a different computer).

WAVE files to be encoded need to have been recorded at 8k samples per 
second, 16-bit, 1 channel. There are several sample WAVE files included 
with this software package in the "recordings" directory.

## Build

## Prerequisites

Miriad uses WAVE files that are recorded at 8000 samples per 
second, 16-bit samples. There are several sample recordings in
the "recordings" directory that can be used for testing. WAVE
files in other formats will give unexpected results.

Miriad requires the m17-mod and m17-demod executables from the 
m17-cxx-demod package. These should be placed in the same directory
as the miriad executable. Miriad also requires that the sox package
be installed on your system in /usr/bin (sox, rec, and play). Lastly, 
miriad also needs netcat installed in /usr/bin.   

## Build Steps

Miriad can be built from source using the Lazarus IDE. It was built
and tested using v2.0.6+dfsg-3 under Ubuntu 20.06LTS.
   
## Running and testing

The easiest way to run miriad is to select the option to play a WAVE
file and select the audio destination as the speaker. You will be
prompted for the WAVE file that you want encoded and played. Click
on "PTT" to hear the M17 audio.

You can also run two copies of miriad on the same computer using one 
as the "receiver" and the second instance as the "transmitter." Start the
first instance of miriad and in "Audio Source" select "Listen on TCPIP
port 3000" and in "Audio Destination" select "Use speaker." Then click
on "Listen." This copy of miriad will be the receiver. The receiver 
version must be started and configured first. Then, start the second 
instance of miriad and select "Play WAV file" and "Send over IP to 
localhost port 3000". In the second instance click on "PTT".  You 
should then hear the M17 audio being played from the speaker.

## Common problems

If you run miriad from the command line you might see a message that
says "[DEBUG] Name com.canonical.AppMenu.Registrar does not exist 
on the session bus".  You can ignore this message.

If you run miriad and it immediately says "miriad is not responding.
wait or force close." on GUI then you need install appmenu-gtk2-module.  
You can install it by running the command
"sudo apt install appmenu-gtk2-module"

