---

title: "All I want for Christmas is a C# Build System"
type: "post"
date: 2017-12-23T00:00:00
draft: False
tags: [ "devops", "c#", ".net", "cake", "build" ]
categories: [ "Coding" ]
comments: true

---

# Why So Jolly?

This post is part of the [The First C# Advent Calendar](https://crosscuttingconcerns.com/The-First-C-Advent-Calendar), celebrating all things C#. After you finish here check out the other great posts in the series.

# A C# Build System

I've used many tools over the years to manage builds of large .NET projects including custom BAT/CMD files, customer PowerShell scripts, NAnt, and of course MSBuild. While I've been happy with the solutions I provided with each of these I've always found them either awkward to extend or limiting in their extensibility and more recently I needed them to work on a Mac for building Xamarin projects. In the hunt to find something that would work outside of Windows I discovered [Cake](https://cakebuild.net/), and I coulnd't be happier.

Cake? You're making me hungry, what are you talking about? Cake (Stands for C# Make) is a tool for automating your builds that runs cross platform (Windows, OS X, and Linux) and uses a C# Domain Specific Language (DSL). You can use it to manipulate files, run msbuild (or other compilers), execute your unit tests, and prepare your build for publishing.

There are two major points that I want you to get:

1) It is built on Rosolyn with a C# DSL
2) It is cross-platform

# C# DSL (Domain Specific Language)

This means you can write regular C# anywhere inline with your build process, and in fact, the custom DSL that powers Cake is all C# syntax and .NET based. This provides a lot of flexibility for managing all aspects of the build. They are able to leverage C# through the use of Rosolyn, which also allows them to target .NET/mono on Windows, Mac OS, and Linux.

The Cake team has taken other cues from the C# development world, integrating support for extensibility through NuGet packages, making it easy to reference and use NuGet packages in your build process. They even use NuGet to get the core Cake components on your machine. That's right, setting up and using Cake in your project only requires downloading a bootstrapper file for your runtime platform and creating your build script. Running the bootstrapper downloads and expands the Cake (and supporting) NuGet packages, then runs Cake with your build script.

.NET Everywhere!

# Cross-Platform
The cross-platform capabilities really set Cake apart from the other build tools I've used. This didn't used to be something we even considered with C#/.NET development, but as .NET Core brings our favorite framework to more platforms we need our build system to go with it. This is especially true if you are building mobile apps and need to perform at least some of the compilation steps on a Mac, but is also relevant if you are creating .NET Core projects and primarily develop inside of OS X or Linux.

For me, being able to develop and test my build on my Windows daily dev box, commit it, and then have it run as part of CI on my Mac build server is awesome and saves a lot of headache. However, there are a few things to be aware of, like the fact that not all extensions and other NuGet packages will run in a non-Windows environment.

#Getting Started
It's easy, you just need to follow these easy steps (on Windows):

1) Download the needed bootstrapper (you can grab the others too)

```PowerShell
Invoke-WebRequest https://cakebuild.net/download/bootstrapper/windows -OutFile build.ps1
Invoke-WebRequest https://cakebuild.net/download/bootstrapper/osx -OutFile buildm.sh
Invoke-WebRequest https://cakebuild.net/download/bootstrapper/linux -OutFile buildl.sh
```

2) Create your Cake Build file (build.cake)

```csharp
var target = Argument("target", "Default");

Task("Default")
	.Does(() =>
	{
	var christmasDay = new DateTime(2017, 12, 25);
	var daysToChristmas = (christmasDay - DateTime.Now.Date).TotalDays;
	var message = daysToChristmas == 0
				? "Merry Christmas!"
				: string.Format("{0} days to Christmas!", daysToChristmas);
	Information(message);
	});

RunTarget(target);
```

3) Run your build

```PowerShell
./build.ps1
```

4) Commit it to version control, get latest on your Mac, and build

# VS Code
There is a nice extensions for [VS Code](https://marketplace.visualstudio.com/items?itemName=cake-build.cake-vscode) that give you syntax highlighting, quickstart templates, debugging, and more.

# Conclusion
As you can see, you can write C# anywhere in your build file, because (you guessed it) the entire file is C#! There are a few newer syntax sugar items that don't work at the moment (as far as I know) like string interpolation, but all the power of the .NET framework is there for you.

I've become a big fan of Cake and it is now my go-to build system when starting a new project. 

# TL;DR;
With [Cake](https://cakebuild.net/) you can manage your build processes with C# on any platform with .NET available.
 Get it, use it, you'll love it.

# Update
2017-12-29 Cake now supports C# 7.2 syntax with [v0.24.0 update](https://cakebuild.net/blog/2017/12/cake-v0.24.0-released). 