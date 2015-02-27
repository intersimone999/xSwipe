xSwipe - Ubuntu 14.04
======================
xSwipe is multitouch gesture recognizer.
This script make your Ubuntu 14.04 PC able to recognize swipes like a Macbook.

## Usage

Before running the script, you must first do some preparations.

  1. Install git
  2. Download xSwipe
  3. Install X11::GUITest
  4. Enable SHMConfig
  5. Install xserver-xorg-input-synaptic

### 1. Install git
Type below code to download git:

    $ sudo apt-get install git

### 2. Download xSwipe
Type below code, download xSwipe from github

    $ cd YourInstallationFolder
    $ git clone https://github.com/intersimone999/xSwipe.git

### 3. Install X11::GUITest

To install libx11-guitest-perl from synaptic package manager
Or run the script on the terminal run as

    $ sudo apt-get install libx11-guitest-perl

### 4. Enable SHMConfig

Open /etc/X11/xorg.conf.d/50-synaptics.conf with your favorite text editor and edit it to enable SHMConfig

    $ sudo gedit /etc/X11/xorg.conf.d/50-synaptics.conf

**NOTE**:You will need to create the /etc/X11/xorg.conf.d/ directory and create 50-synaptics.conf if it doesn't exist yet.
     `$ sudo mkdir /etc/X11/xorg.conf.d/`

##### /etc/X11/xorg.conf.d/50-synaptics.conf

    Section "InputClass"
    Identifier "evdev touchpad catchall"
    Driver "synaptics"
    MatchDevicePath "/dev/input/event*"
    MatchIsTouchpad "on"
    Option "Protocol" "event"
    Option "SHMConfig" "on"
    EndSection


### 5. Enable SHMConfig
First, uninstall the package xserver-xorg-input-synaptic:

    $ sudo apt-get remove xserver-xorg-input-synaptic
  
Download in a temporary folder this version of the package:

    $ git clone https://github.com/felipejfc/xserver-xorg-input-synaptics TempFolder
    $ cd TempFolder

Install the following packages in order to compile the previously downloaded package:

    $ sudo apt-get install xutils-dev xorg-dev mtdev-tools libevdev2 libevdev-dev libtool

Run the following commands in order to compile and install the package and to remove the temporary folder previously created.

    $ ./autogen.sh
    $ ./configure --exec_prefix=/usr
    $ make
    $ sudo make install
    $ cd ..
    $ rm -r TempFolder

Restart your session. That's it for the preparation.

**NOTE**: If something went wrong, your touchpad won't work! To let it work again, run:

    $ sudo apt-get install xserver-xorg-input-synaptic

and restart your session.
  
## Run xSwipe

To run xSwipe, type below code on terminal.

    $ perl ~/xSwipe-master/xSwipe.pl -n

**Note:You should run xSwipe.pl in same directory as "eventKey.cfg" .**
**Note:Always use the "-n" option, because this version of the project supports only natural scroll**

You can use "swipe" with 3 or 4 fingers, they can call an event.
Additionally, some gestures are avilable.

* *edge-swipe* : swipe with 2 fingers from outside edge.
* *long-press* : hold pressure for 0.5 seconds with 3 or 4 fingers.

### Option

*   `-d RATE` :
      *RATE* is sensitivity to swipe.Default value is 1.
      Shorten swipe-length by half (e.g.,`$ perl xSwipe.pl -d 0.5`)
*   `-m INTERVAL` :
      *INTERVAL* is how often synclient monitor changes to the touchpad state.
      Default value is 10(ms).
      Set 50ms as monitoring-span. (e.g.,`$ perl xSwipe.pl -m 50`)
*   `-n` :
      Natural scroll like Macbook, use "/nScroll/eventKey.cfg".

## Customize
You can customize the settings for gestues to edit eventKey.cfg.
Please check this article, ["How to customize gesture"](https://github.com/iberianpig/xSwipe/wiki/Customize-eventKey.cfg).

### Bindable gestures
* 3/4/5 fingers swipe
* 2/3/4/5 fingers long-press
* 2/3/4 fingers edge-swipe
    - *2fingers edge-swipe*: only swipe-left/right from right/left edge
    - *3fingers edge-swipe*: only swipe-down from top egde

### Example shortcut keys
* go back/forward on browser (Alt+Left, Alt+Right)
* open/close a tab on browser (Ctrl+t/Ctrl+w)
* move tabs (Ctrl+Tab, Ctrl+Shift+Tab)
* move workspaces (Alt+Ctrl+Lert, Alt+Ctrl+Right, Alt+Ctrl+Up, Alt+Ctrl+Down)
* move a window (Alt+F7)
* open launcher (Alt+F8)
* open a terminal (Ctrl+Alt+t)
* close a window (Alt+F4)
