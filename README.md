# Terraria

## Update Terraria Server
The script updateTerrariaServer.sh is used to pull and rotate terraria servers as new versions are released.

The URL, version numbers, file names, and directory structure of the unzipped server are subject to change.  
To help this, two variables at the top of the script are available and expected to be updated by the user before use.

As of v1.4.0.4 these values at the top of the script are accurate
    
    # !! Keep this version number updated !!
    VERSION=1404
    
    # !! Keep this url updated !!
    #TERRARIA_URL=''
    TERRARIA_URL='https://www.terraria.org/system/dedicated_servers/archives/000/000/038/original/terraria-server-1404.zip'

## Assumptions
On my server I save all terraria related files here, referred to in the script as TERRARIA_HOME.   
    
    /wd/terraria/

This is a secondary hard drive mounted on /wd 
I assume the user has full permission (rwx) for this directory, or whatever directory they use.
If changing to a different TERRARIA_HOME simply change the part of the script that looks like this

        TERRARIA_HOME='/wd/terraria'

Built and tested on Ubuntu 20.04 server

Script will use 

    #!/bin/bash
        GNU bash, version 5.0.16(1)-release (x86_64-pc-linux-gnu)
        
    unzip
        UnZip 6.00 of 20 April 2009, by Debian. Original by Info-ZIP.
    
    awk
        GNU Awk 5.0.1, API: 2.0 (GNU MPFR 4.0.2, GNU MP 6.2.0)
        
## Script procedure
1. File and permission checking
1. Cleanup directories to help consistancy of each run
1. Pull server zip file provided by terraria.org
1. Unzip our new zip file, correct permissions
1. Create copy and archive a copy our now old server files
1. Perform archive file rotation (default 2)
1. Prompt user to check that the server is not currently running the game. We would not want to delete files that are currently executing. That might be a bummer.
    1. If user replys with not 'y' or 'Y', script terminates leaving it to the user to copy-paste the new files over.
 1. Remove all old server files in latest/ that are to be replaced
 1. Moves our new files that we staged into the latest/ directory
 1. Some cleanup
 
## Directory Tree
Result of tree command
        
        me@mine:/$ tree /wd/terraria
        
![directory tree](terraria_server_tree.GIF)

## Terraria official documentation
https://terraria.gamepedia.com/Server
