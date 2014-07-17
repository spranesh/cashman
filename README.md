Cash Manager 0.2
================

Manage who owes who.

Author : Pranesh Srinivasan
License : GPL

Dependencies : A good haskell compiler. I have tested this with the Glasgow
Haskell Compiler (GHC) on a GNU/Linux Machine (Ubuntu). It should also
work on Windows, using ghc

Brief Installation Steps
========================
    * Make sure you have a haskell compiler (pref ghc) installed. On
      Debian/Ubuntu this can be done by 
        apt-get install ghc
      
    * In the directory of the program, change any Makefile variables that
      you may want to. The most oft changed will be the PREFIX, since it
      might differ from system to system. For Debian/Ubuntu, this is
      /usr/bin

    * Simply run make followed by a make install


Usage
=====
The program allows one to have buddies, that he declares using cashman add
friends. Then he can keep track individually of the money he gives or takes
from someone. Options will be added later to sum all debt / credit, and
allow transfer from a friend to another.

Right now, the program is first person centric.

    help                -> display this message
    take  friend amount -> take amount money from friend 
    give  friend amount -> give amount money to friend 
    reset friend        -> reset money owed to/by friend to 0 (keeps logs)
    show  friend        -> show money owed to/by friend
    add   friend        -> add a friend with the name friend
    history friend      -> display entire log history of friend
    list                -> list all friends
    report              -> make a report
    In all the above, amount is integral

    Comments can be added when using give or take, as an optional last option.

Examples : 
      cashman add smith    -> adds smith as a friend 
      cashman take smith 5 -> borrow 5 from Smith
      cashman give smith 100 "lunch" -> lend Smith a 100, with an annotation saying "lunch"
                                        to help memory
      cashman report

Tip
===
To keep track of daily expenditure, you may want to add a friend called
expenditure, and give him your daily expenditure everyday. Since there is a
time log, you can then use the history command to view your expenditure
across a time period.


Implementation Details
======================
The data is stored in ~/.cashman (on Linux Machines) with each friend having a
file, friend.frnd Money given to the friend is viewed as personal credit (+ve
sign), and money taken from the friend is viewed as personal debit (-ve sign)

