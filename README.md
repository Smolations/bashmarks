### Bashmarks is a shell script that allows you to save and jump to commonly used directories.

## Install

1. git clone git://github.com/Smolations/bashmarks.git
2. source **/path/to/bashmarks.sh** from within your **~.bash\_profile** or **~/.bashrc** file

## Shell Commands

    s <bookmark_name> - Saves the current directory as "bookmark_name"
    g <bookmark_name> - Goes (cd) to the directory associated with "bookmark_name"
    d <bookmark_name> - Deletes the bookmark
    l                 - Lists all available bookmarks

## Example Usage

    $ cd /var/www/

    $ s webfolder
    baskmark saved!

    $ cd /usr/local/lib/

    $ s locallib
    baskmark saved!

    $ l
     webfolder  /var/www
      locallib  /usr/local/lib

    $ g webfolder

## Where Bashmarks are stored

All of your directory bookmarks are saved in a file called ".sdirs" in your HOME directory.
