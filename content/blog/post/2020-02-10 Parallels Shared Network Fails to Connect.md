---
title: "Parallels Shared Network Fails to Connect"
slug: "parallels-shared-network-fails-to-connect"
date: 2020-02-10T12:30:00-06:00
type: "post"
draft: False
tags: [ "parallels", "network", "tips" ]
categories: [ "Technology" ]
comments: true
---

Today (Monday), out of the blue, one of my Windows 10 Parallels virtual machines decided that it had no connection to the internet. Friday I was on site at a client using thier WiFi network to work through some changes they needed. Today, back at the office, I fired up my VM to push the changes and make a couple more tweaks. I was immediated greated by git telling me that my git host didn't exist. I realized that Windows was reporting that I had no internet connection. 

## Attempts at self-help

* My first instinct was to reboot the VM, this didn't work. 
* Next, I tried to use Window's network troubleshooter to fix the problem, this didn't work. 
* I rebooted again, because why not? Still no internet (or local network) connectivity. 
* I turned to the internet: A realatively quick search for 'parallels shared network no internet' got me to {{< target-blank "this forum post" "https://forum.parallels.com/threads/shared-networking-not-working-no-internet.98918/" >}} on the Parallels forums. The post was from 2010, and the OP was having issues on Windows XP, but I figured I'd give the solution a try, and it worked!

## The Solution

The Parallels developer (Elric) stated that it may be the Windows TCP/IP Stack wigging out and to try to do a reset on the stack. Here are the steps so I can find this faster in the future, and in case that forum post dissapears. 

1) Open an elevated command prompt
2) Run this command `netsh winsock reset`
3) Reboot
4) Open an elevated command prompt, again
5) Run this command `netsh int ip reset reset.log`
6) Reboot, again
7) You should have a working internet connection!

This is another post that exists mostly to help me remember how I got this working, but I hope this helps someone else in the future. 