xSwipe - Ubuntu 14.04
======================
xSwipe is multitouch gesture recognizer.
This script make your Ubuntu 14.04 PC able to recognize swipes like a Macbook.

## Usage

Before running the script, you must first do some preparations.

  1. Install git
  2. Download xSwipe
  3. Install required packages
  4. Enable SHMConfig
  5. Install xserver-xorg-input-synaptic

### 1. Install git
Type below code to download git:

    $ sudo apt-get install git

### 2. Download xSwipe
Type below code, download xSwipe from github

    $ cd YourInstallationFolder
    $ git clone https://github.com/intersimone999/xSwipe.git

### 3. Install required packages

You have to install Ruby and X11::GUITest for Perl. Run the following command:

    $ sudo apt-get install ruby libx11-guitest-perl

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

    $ ruby ~/xSwipe-master/rubySwipe.rb -r -d

You can use "swipe" with 3 or 4 fingers, they can call an event.
Additionally, some gestures are avilable.

* *edge-swipe* : swipe with 2 fingers from outside edge.
* *long-press* : hold pressure for 0.5 seconds with 3 or 4 fingers.
* *movement* : tap with 5 fingers and release four of them. You can move the window you clicked on. Just release the last finger to stop. You can also use 3 fingers swiping to move the window to another workspace

### Option

*   `-d` :
      *DAEMON* run "syndaemon". Use only the first time you run the script in each session.
*   `-r` :
      *RUN* run the script. If you don't use this flag, the script won't start. It is useful if you import it in another application or you just want to test it using irb.

### Bindable gestures
* 1 finger edge-swipe
* 3/4/5 fingers swipe
* 2/3/4 fingers edge-swipe
    - *2fingers edge-swipe*: only swipe-left/right from right/left edge
    - *3/4/5fingers edge-swipe*: only swipe-down from top egde
* Move gesture
    - *Number of fingers*: number of fingers needed to start moving a window
    - *Move key*: the key to be used in order to move a window. See compiz configuration.
    - *Swipe actions*: how to deal with swipe gestures when moving a window

### Default gestures
* 1 Finger
  * Left (edge) -> disabled
  * Right (edge) -> disabled
* 2 Fingers
  * Left (edge) -> Lower volume (Special key)
  * Right (edge) -> Raise volume (Special key)
* 3 Fingers
  * Up -> To lower desktop (Ctrl+Alt+Down)
  * Down -> To upper desktop (Ctrl+Alt+Up)
  * Left -> History forward (Alt+Right)
  * Right -> History back (Alt+Left)
* 4 Fingers
  * Up -> Show all windows on desktop (modified compiz combination: Ctrl+Alt+w)
  * Down -> Show all windows in the system (modified compiz combination: Ctrl+Alt+Shift+w)
  * Left -> Previous song (Special key)
  * Right -> Next song (Special key)
* 5 Fingers
  * All disabled (used to move)
* Move gesture
  * Fingers -> 5
  * Key -> ALT

# Configuration file customization

In order to change the action of a gesture, find the gesture in "eventKey.cfgr" and set the corresponding double-quoted string. You can use the following modifiers:

    ^       CTRL
    %       ALT
    +       SHIFT
    #       META
    &       ALTGR
    ~       ENTER
    \n      ENTER
    \t      TAB
    ( and ) MODIFIER GROUPING (eg: "^(c)" is CTRL+C; "^(%(l))" is CTRL+ALT+L)
    { and } QUOTE / ESCAPE CHARACTERS (eg: "{LSK}" is Left "Super" key; {UP} is Up key.)


These are all the special keys:

      Name    Action
    -------------------
    BAC     BackSpace
    BS      BackSpace
    BKS     BackSpace
    BRE     Break
    CAN     Cancel
    CAP     Caps_Lock
    DEL     Delete
    DOWN    Down
    END     End
    ENT     Return
    ESC     Escape
    F1      F1
    ...     ...
    F12     F12
    HEL     Help
    HOM     Home
    INS     Insert
    LAL     Alt_L
    LMA     Meta_L
    LCT     Control_L
    LEF     Left
    LSH     Shift_L
    LSK     Super_L
    MNU     Menu
    NUM     Num_Lock
    PGD     Page_Down
    PGU     Page_Up
    PRT     Print
    RAL     Alt_R
    RMA     Meta_R
    RCT     Control_R
    RIG     Right
    RSH     Shift_R
    RSK     Super_R
    SCR     Scroll_Lock
    SPA     Space
    SPC     Space
    TAB     Tab
    UP      Up

To find special keys, use xev.

This is an example: 

    :swipe=>{
      [...]
      3=>{
        [...]
        :left    =>  "%({RIG})", #Triggered if there is a 3-fingers swipe towards left
        [...]
      }
      [...]
    :edgeSwipe
      2 =>{
        [...]
        :right	=>   "{LSK}", #Triggered if there is a 2-finger swipe from the left edge towards right
        [...]
      },
      [...]
    },
