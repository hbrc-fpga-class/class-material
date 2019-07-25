# Robot Internet

This document provides an overview of how to communicate with your robot via the internet.
There are three broad ways of doing this:

* No Internet: This is done with a keyboard, mouse, and HDMI monitor.
* Wired Internet: This is done with an Ethernet cable.
* WiFi: WiFi is the method of choice and provides a wire less connection.

These are techniques are discussed in separate sections below.

## No Internet

The internet option ***ALWAYS*** works.  For this you need the following:

* HDMI Display: An HDMI display with an [HDMI](https://en.wikipedia.org/wiki/HDMI) connector.
* Mouse: A mouse with a USB 2.0 connector is needed.  It can be either wired or wireless.
* Keyboard: A keyboard with a USB 2.0 connector is required.

The steps are:

1. Plug the HDMI Display, Mouse and Keyboard into the Raspberry Pi.
2. Provide power for the Raspberry Pi.
3. After a few seconds you should see some text appear on the display and start scrolling by.
4. Eventually you will see a `login:` prompt.  Type in `ubuntu`.
5. Next you will see a `passwd:` prompt.  Type in `ubuntu` again.
6. After a little more text, you will see a `>` prompt.
7. You are in.

To halt the machine:

1. Type `sudo halt`.
2. After the `passwd:` prompt type 'ubuntu`.
3. The green LED on the side of the Raspberry Pi will blink on and off for a bit.
4. Eventually, the green LED will go on for about a second and then go dark.
5. Remove power from the Raspberry Pi.

The advantage with the No Internet option is that it can be used to debug and
figure out why your internet connection is not working.

## Wired Internet

For wired internet you need the following:

1. An Ethernet cable.
2. An Ethernet port to plug into.  This port can be on your WiFi router (if you have one.)
3. A shell/terminal window running on your computer/laptop.

The steps are:

1. Plug one end of the Ethernet cable into the Raspberry Pi.
2. Plug the other end of the Ethernet cable into you local area network.
   If you are plugging into your WiFi router, plug into one of the connectors
   labeled `LAN` (i.e. Local Area Network.)
3. Look at the back of the Raspberry Pi for the host name.  It is a label of the form `'H##`,
   where `##` is a two digit decimal number.
4. Power up your Raspberry Pi and wait about a minute.
5. What happens next depends upon your operating system.
   * Linux/MacOS:
     1. Open a terminal window.
     2. Type `ping H##.local` in the terminal window, where the `##` has been replaced
        by the digits on the back of your Raspberry Pi.
     3. Wait for at least 30 seconds to see if you start getting responses of the form:

            64 bytes from H##.local (#.#.#.#): icmp_seq=1 ttl=64 time=0.057 ms

        when you see the ping messages getting through, you may proceed to the next step.
	If the ping messages are not showing up, you have an internet configuration problem
	that needs to be addressed.  The most common problems are discussed a bit further below.
     4. Type Control-C to terminate the `ping command`.
     5. Login to the robot by typing `ssh ubuntu@H##.local`.
        The first time you do this you may get a prompt that asks permission if it is
	acceptable to log into the the new robot.  Respond with `yes`.
     6. When the `passwd:` prompt shows up, type `ubuntu`.
  * Windows:
     There are many versions of Windows.  These directions give an overview.
     1. Download `putty`.
     2. Attempt to connect to `H##.local`.  If it finds the Raspberry Pi, it will
        prompt you for a password.  The password is `ubuntu`.
6.When you get a `>` prompt you are in.

If your Windows operating system does not work read further below about installing Bonjour.

## WiFi

If you boot up your robot away from any wifi networks that it knows about, it will come
up as it's own network. The name of the network will be your robots hostname followed
by 4 characters. For example my robot is h18, so the wifi it comes up as is h189A4E.

You can connect to your robots wifi with the password "robotseverywhere" no quotes.
Windows users: if it is asking for a "PIN" there should be an option for
"Use Security Key Instead", click that and use the password.

Then you can SSH into your robot with your (hostname).local. For me the full command is
ssh ubuntu@h18.local  
Windows users: .local addressing doesn't work on windows. The IP of the robot is 10.42.0.1
while in AP mode.

After you have ssh'ed into the robot (user: ubuntu, password: ubuntu), you can add your
wifi network.
Windows users: Once you have connected to your home wifi, you *MUST* either have access
to your router's admin console which *MUST* have a "Clients List" feature to get your
robot's IP. OR you must do the steps needed for zeroconf networking to work. Otherwise
please just use your robot as it's own network, and deal with not having internet while
you are connected to it.

To add your home wifi network run:

        sudo pifi add NETWORK PASSWORD

Then you will need to reboot:

        sudo reboot

Once the robot reboots you should be able to ssh into it with (HOSTNAME).local
or IP_ADDRESS.local. For me this would be h18.local or 192.168.1.138

## Bringing up `zeroconf`:

The rest of this email is how to get zeroconf working on Windows.

On Windows 10 you need to follow these
[instructions](https://superuser.com/questions/1330027/how-to-enable-mdns-on-windows-10-build-17134)

After that (or skip to here on earlier Windows): you will need to install
[Bonjour Print Services For Windows](https://support.apple.com/downloads/bonjour_for_windows).

The other option is to use an Ubuntu Virtual Machine, and ensure that the network
adapter settings are in "Bridge Mode". This allows .local addressing to work on the
virtual machine.
