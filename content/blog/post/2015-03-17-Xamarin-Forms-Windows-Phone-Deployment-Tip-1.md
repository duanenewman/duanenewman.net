---

title: "Xamarin Forms Windows Phone Deployment Tip #1"
slug: "Xamarin-Forms-Windows-Phone-Deployment-Tip-1"
type: "post"
date: 2015-03-17T08:40:00
draft: False
tags: [ "mobile", "Xamarin", "Xamarin Forms", "WinPhone", "Silverlight", "Deployment" ]
categories: [ "Coding" ]
comments: true

---

<p>Here is a helpful tip if you are developing a mobile app using Xamarin Forms and targeting Windows Phone 8.0 (or if you are just writing a WP8.0 Silverlight based app). If you are ready to deploy and filling everything out online it is easier than it first seems. </p>  <p>On the Windows Phone Dev Center you will find a helpful link to <a href="https://msdn.microsoft.com/en-us/library/windows/apps/dn655122(v=vs.105).aspx" target="_blank">this article</a> telling you to add some info to the Package.appxmanifest.xml file. Only when you look at your project the file doesn’t exist. Searching will turn up little in the way of useful information. The problem is that these instructions are for Windows Phone Silverlight 8.1, which added the Package.appxmanifest.xml file.</p>  <p>The solution couldn’t be simpler, just upload the xap file that gets created when you compile your app in Visual Studio. Really, that’s it. Hopefully this saves someone a few minutes of frustration.</p>
