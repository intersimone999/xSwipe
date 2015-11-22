xSwipe - Universal
======================
xSwipe is multitouch gesture recognizer.
This script make your Linux PC able to recognize swipes like a Macbook.

## Usage

Before running the script, you must first do some preparations.

  1. Install git
  2. Download xSwipe
  3. Install required packages

Note: this guide is designed for Debian derivates and Arch Linux.

### 1. Install git
Type below code to download git:

    $ sudo apt-get install git
    

### 2. Download xSwipe
Type below code, download xSwipe from github

    $ cd YourInstallationFolder
    $ git clone https://github.com/intersimone999/xSwipe.git

### 3. Install required packages

You have to install Ruby and X11::GUITest for Perl. Run the following command:

    $ sudo apt-get install ruby libx11-guitest-perl evemu


## Run xSwipe

To run xSwipe, type below code on terminal.

    $ ruby ~/xSwipe-master/rubySwipe.rb -r

You can use "swipe" with 3 or 4 fingers, they can call an event.
Additionally, some gestures are avilable.

* *edge-swipe* : swipe with 2 fingers from outside edge.
* *long-press* : hold pressure for 0.5 seconds with 3 or 4 fingers.
* *movement* : tap with 5 fingers and release four of them. You can move the window you clicked on. Just release the last finger to stop. You can also use 3 fingers swiping to move the window to another workspace

### Option

*   `-r` :
      *RUN* run the script. If you don't use this flag, the script won't start. It is useful if you import it in another application or you just want to test it using irb.

### Bindable gestures
* 1 finger edge-swipe
* 3/4/5 fingers swipe
* 2/3/4/5 fingers long-press
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
