Installation
============

Prerequisites
-------------

* rdiff-backup
* tmux
* sudo
* git
* Oracle JRE 7 64-bit, with `java` in $PATH

On Debian-based distributions, such as Ubuntu, most of these can be installed as follows:

    sudo apt-get install rdiff-backup tmux sudo

Oracle Java is the tricky one.  That is beyond the scope of this documentation.  I recommend using the `update-alternatives` utility to install `java` and related executables to your $PATH, if available.  `install-alternatives.sh` is a handy script included with MineScript for running `update-alternatives` on all executable files in a directory.

You can check to see that all of these programs are installed using `which`:

    which rdiff-backup tmux sudo java git

You should receive four paths to executables, one for each argument to `which`.  Any omitted programs are not fully installed.

Creating the User
-----------------

Minecraft will be running under its own user.  We're going to use `mc`, but you can use a different user.

Create the new user as appropriate for your distribution.  It will need a similarly named group and a secure password.  A typical command:

    sudo useradd mc
    sudo passwd mc

The user will need access to the `sudo` command.  The exact group to which the user needs to be added varies by distribution.  It tends to be either `sudo` or `wheel`.  Try `sudo`, and if that doesn't work, try `wheel`.  You can get the exact group name by reading the `/etc/sudoers` file.  To add the user to the `sudo` group:

    sudo usermod -aG sudo mc

Any users that will be connecting to the console need to be in the sudoer group as well.  They also need to be in the group named for the Minecraft server user.  If I wanted to give `bob` access:

    sudo usermod -aG sudo bob
    sudo usermod -aG mc bob

You can make additional users at this point for other administrators who will have access to the console.  Run the above for each user, substituting appropriately.  Your distribution might have an `adduser` wizard that wraps around `useradd`; you should use that command for these additional users, if available.  Be sure to set secure passwords with `passwd`.

Once you are done, be sure to log out: the changes to your groups don't take effect until you log in again.

Directory Structure
-------------------

Determine where your Minecraft server files are going to be located.  We're going to use `/srv/mc` in the documentation.  This won't necessarily determine the drive on which the files will be located; we'll adjust that later.

    sudo mkdir -p /srv/mc

You should now be able to move to the new directory:

    cd /srv/mc

If you are denied permission, log out and back in.  If you are still denied permission, you didn't add yourself to the `mc` group.

There are three important directories that we will need to make here.  The first in the directory containing MineScript.  The name of this directory is important, as it defines the name of the server instance.  You can have multiple MineScript directories to run multiple servers.  For a CraftBukkit server, you might name this folder `bukkit`.  For Feed the Beast: MindCrack, you might use `mindcrack`.  Once you have chosen a name for the directory, clone the MineScript repository into it.  Assuming your instance name is `bukkit`:

    git clone https://github.com/Zenexer/MineScript.git bukkit

The next two folders are similar.  The first is the `live` folder: this is from where your live Minecraft servers will run.  The second is the `backup` folder: everything, including the MineScript directory, will be backed up here periodically.  It is up to you to have two separate drives already present and mounted: that is beyond the scope of this documentation.  For this documentation, we're going to assume that the live and backup drives are mounted in `/mnt/live` and `/mnt/backup`, respectively.  To prepare folders on the drives:

    sudo mkdir /mnt/live/mc /mnt/backup/mc

Next, create symbolic links to the drives:

    ln -s /mnt/live/mc live
    ln -s /mnt/backup/mc backup

Type `ls`.  You should have three folders.  Two are symbolic links: `live` and `backup`.  If they are red, you typed something wrong; delete them and retry.  You should additionally have a normal folder containing MineScript, that is named for the server instance.

Create a directory inside your live directory also named for the instance.  Assuming your MineScript directory is named `bukkit`:

    mkdir live/bukkit
    
Now we need to set permissions on everything.  Return to the MineScript folder and run:

    sudo internal/reclaim.sh /srv/mc

Preparing Server
----------------

Move to the instance folder within the live directory.  We're going to use `bukkit` as our instance name, so we'll do:

    cd live/bukkit

Time to add the server files.  Create several directories to hold the files:

    mkdir jar plugins workdir log config worlds

Put the server `.jar` file in the `jar` folder, then switch to `workdir`:

    mv workdir

We're going to create symbolic links to everything so that improperly programmed or old plugins and mods don't look in the wrong places for files.  This shouldn't be necessary for the most part on recent versions of CraftBukkit and derivatives.  Be sure that you use the correct world names: you may have different worlds and/or additional worlds, particularly if you are using Feed the Beast or Multiverse.

Most users can copy and paste this directly into their terminals.  Some might need to edit it in a text editor first.  There is no way to correctly determine the proper configuration, which is why it is left up to the user to perform this step.  These defaults will be suitable for most users.

    ln -s ../config/banned-players.txt banned-players.txt
    ln -s ../config/banned-ips.txt banned-ips.txt
    ln -s ../config/white-list.txt white-list.txt
    ln -s ../config/ops.txt ops.txt
    ln -s ../config/help.yml help.yml
    ln -s ../config/permissions.yml permissions.yml
    ln -s ../config/wepif.yml wepif.yml
    ln -s ../config/server.properties server.properties
    ln -s ../config/bukkit.yml bukkit.yml
    ln -s ../worlds/world world
    ln -s ../worlds/world_nether world_nether
    ln -s ../worlds/world_the_end world_the_end
    ln -s ../plugins plugins
    ln -s ../log/server.log server.log

Configuration
-------------

`cd` to the `include` directory within your MineScript folder.  Copy `configuration-local.sh.example` to `configuration-local.sh`.  Leave the original file intact, or git will notice that you edited/deleted the file.  It is set to ignore files that match `*-local.sh`, though, so the new file won't be included in git's operations.

Edit `configuration-local.sh` as you see fit.  Not all of the options are listed in there; you can see more advanced settings in `configuration.sh`.  If you need to edit something from `configuration.sh`, copy it to `configuration-local.sh` and change it there.  `configuration-local.sh` always overrides `configuration.sh`.  If it doesn't, you have a syntax error somewhere.  Fix it: don't edit `configuration.sh`.

Initialization
--------------

At this point, you should see the instructions on starting the server manually.  Ensure that the server starts and edit configuration files as necessary.  Continue only once you are ready to run the server persistently.

cron
----

We need to schedule various tasks to run at set intervals on the server.  Linux has a system for this: cron.  Open the mc user's crontab file for editing:

    sudo su -c "crontab -e" mc

Unless you have already edited this file, it should have nothing but documentation comments.  We're going to add two entries.  The first runs the server when the machine powers on:

    @reboot /srv/mc/bukkit/start-task.sh

Reminder: `/srv/mc` is the root folder for all of the Minecraft server files, and `bukkit` is the folder in which the MineScript files reside.  You are likely using different names, so substitute appropriately.

The second entry runs incremental backups periodically.  Using the documentation comments in the crontab file, you should be able to change the frequency.  This example uses a 30-minute interval:

    */30 * * * * /srv/mc/bukkit/backup-task.sh

Here's every six hours, at quarter-past:

    15 */6 * * * /srv/mc/bukkit/backup-task.sh

Save and close the file.  It will be installed in place of the existing crontab.

Restart the machine to test the first cronjob:

    sudo reboot

Usage
=====

Prerequisites
-------------

* You should already be able to navigate around tmux.  Experience with GNU screen will do.
* Basic bash experience is a must.

Scripts
-------

* `start-instance.sh`: Starts the server and attaches to it immediately.
* `start-task.sh`: Starts the server in the background.
* `stop-instance.sh: Stops the server; it will need to be restarted manually.  To complete the process, exit the input editor after the Minecraft server terminates; tmux will then exit if no other windows are open.
* `attach.sh`: Attaches to a running server.  Each user gets their own session so that they can be on different windows simultaneously.
* `backup-task.sh`: Backs up everything; tells the server to save first, and waits one minute for the save to complete.
* `backup-all.sh`: Backs up everything immediately; doesn't tell the server to save.  Do not run while backup-task.sh is scheduled with cron, or problems will ensue.
* `backup-shell.sh`: Backs up the MineScript folder immediately.  Idem rules.
* `backup-instance.sh`: Backs up the live server folder immediately.  Idem rules.
* `install-alternatives.sh`: Examines all arguments: any that are executable are installed via `update-alternatives`.  Should only be run on files in the current directory.  Uses priority 10002.  Will intentionally and reversibly override OpenJDK.

Interface
---------

The tmux interface is split vertically into two panes: the console output on the top, and an input editor on the bottom.  Multiple lines can be inserted into the editor, but they do not get sent until the editor exits.  Once the editor exits, the lines are sent to the server en masse.  This is useful for pasting text and batch processing.  The input editor used is the bash implementation of readline. 

xample
-------

1. `./start-instance.sh`: Starts the server
2. `Ctrl + b, Down`: Switches focus to the input area
4. `say Hello, World!`: The command to send
6. `Enter`: Sends the command to the server
7. `[Console] Hello, World!`: The command gets executed
8. `Ctrl + b, c`: Creates a new tmux window with a bash prompt
9. `/srv/mc/bukkit/stop-instance.sh`: Stops the Minecraft server
10. `Ctrl + b, p`: Switches to the previous tmux window
11. `Enter`: Sends a blank command to the server so that it will exit
12. `exit`: Exits bash, and consequently, the tmux window; since it is the last window, tmux exits entirely
13. We're back at a bash prompt without tmux.

License
=======

Copyright (c) 2012 Paul Buonopane.  All rights reserved.  Earth2Me and MineScript are trademarks of Paul Buonopane.

You may reproduce this product in whole for any purpose.  This README.md must be included.  Paul Buonopane must be noticeably credited in any resulting products.

Modifications are permitted as long as they are published publicly on GitHub.

Paul Buonopane reserves the right to change this license at any time, with or without notice.

