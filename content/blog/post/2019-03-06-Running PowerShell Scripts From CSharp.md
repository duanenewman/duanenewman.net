---
title: "Running PowerShell Scripts From C#"
slug: "running-powershell-scripts-from-csharp"
type: "post"
date: 2019-03-06T00:00:00-06:00
tags: [ "csharp", "dotnet", "powershell" ]
categories: [ "Coding" ]
comments: true
---

Sometimes the little things can trip up your code, even when you think you are doing all the right things. We recently ran into an issue with a utility that runs an included PowerShell script as part of it operation. When the app was first put into use it seemed to be fine. Recently, it was deployed into a folder with spaces in the name and it began to blow up. Here is a simplified example of what it was running:

```csharp
void GetAnError()
{
    var ps1File = @"C:\my script folder\script.ps1";
    var startInfo = new ProcessStartInfo()
    {
        FileName = "powershell.exe",
        Arguments = $"-NoProfile -ExecutionPolicy unrestricted \"{ps1File}\"",
        UseShellExecute = false
    };
    Process.Start(startInfo);
}
```

The error we were getting from PowerShell was along the lines of ```The term 'C:\my' is not recognized as the name of a cmdlet, function, script file, or operable program```, and before looking at the code I figured I had not quoted the file name. But as you can see from the above code, the filename was indeed quoted (I'm not a noob, after all). This puzzled me a bit and it took some digging to see the cause of the error. Here is the fixed code, can you spot the change?

```csharp
void NoError()
{
    var ps1File = @"C:\my script folder\script.ps1";
    var startInfo = new ProcessStartInfo()
    {
        FileName = "powershell.exe",
        Arguments = $"-NoProfile -ExecutionPolicy unrestricted -file \"{ps1File}\"",
        UseShellExecute = false
    };
    Process.Start(startInfo);
}
```

When you pass a string to the PowerShell executable it treats it as the ```Command``` switch, which is pure PowerShell script. If you want it to explicitly treat it as a script file can use the ```-File``` parameter. It just happened to work with paths without spaces, since you can call a script that way. If you do need to pass script text that needs complex quoting (or perhaps line breaks), you can use the ```EncodedCommand``` switch, which accepts Base64 encoded content.

```csharp
void Base64EncodedCommand()
{
    var psCommmand = @"echo ""quoted value"" 
    echo ""Second Line""
    pause";
    var psCommandBytes = System.Text.Encoding.Unicode.GetBytes(psCommmand);
    var psCommandBase64 = Convert.ToBase64String(psCommandBytes);

    var startInfo = new ProcessStartInfo()
    {
        FileName = "powershell.exe",
        Arguments = $"-NoProfile -ExecutionPolicy unrestricted -EncodedCommand {psCommandBase64}",
        UseShellExecute = false
    };
    Process.Start(startInfo);
}
```

Now you can enjoy launching PowerShell scripts from your C# code without limits.