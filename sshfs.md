# SSHFS

This document explains howto setup sshfs on your computer
so you can mount the hbrc_fpga_class directory on the 
class robot into your file system.

This is useful for it allows you use your computers
GUI tools to edit or view files that are on the robot.
For example you can use your favorite GUI editor
to edit files on the robot instead of being limited
to editors that run in the terminal.

## Ubuntu/Debian

If your host computer is running Ubuntu sshfs is pretty
easy to setup via:

```
> sudo apt-get install sshfs
```

### Create a mount point

Create a directory where you would like to access your
robots files.  This directory can be anywhere, but
it is common to put it in the /mnt directory.  I named
the directory my robots name.

```
> cd /mnt
> sudo mkdir h01.local
```

### Mount the robots directory

Make sure the robot is turned on and booted, then type:

```
> sudo sshfs ubuntu@h01.local:hbrc_fpga_class h01.local -o allow_other
```

Now you should be able to browse the robot's files through that mount point.

![sshfs explorer](images/sshfs_explorer.png)

![sshfs gedit](images/sshfs_gedit.png)

### Unmount

Before shutting down the robot, unmount the sshfs via:


```
> sudo umount /mnt/h01.local
```

## Windows 10

todo...

