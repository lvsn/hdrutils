



Installation 
------------

1. Install libIlm and openEXR from http://openexr.com/downloads.html

2. Install pfstools (make sure EXR support is installed) from http://pfstools.sourceforge.net

3. Add path to `<pfstools>/src/matlab`

4. Install dcraw from http://www.cybercom.net/~dcoffin/dcraw/ and make sure it is in the path, so you can call it from within Matlab.

5. Profit!

Note to Mac users: install `gcc` and compile all of these with it. It's way easier than using `llvm` as pfstools hasn't been tested with it (apparently). 

