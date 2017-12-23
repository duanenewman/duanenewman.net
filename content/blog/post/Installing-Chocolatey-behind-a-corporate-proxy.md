---

title: "Installing Chocolatey behind a corporate proxy"
type: "post"
date: 2016-01-22T12:00:00
draft: False
tags: [ "chocolatey", "proxy", "powershell", "admin", "utility" ]
categories: [ "Technology" ]
comments: true

---

<p>Recently I was working at a project at a new client and needed to add some tools to my development machine. So I turned to one of my favorite tools for getting the apps and tools I need, Chocolatey. The only problem was that I was getting an error installing Chocolatey using the command on their website.</p>  <pre>Exception calling &quot;DownloadString&quot; with &quot;1&quot; argument(s): &quot;The remote server returned an error: (407) Proxy Authentication Required.&quot;<br />At line:1 char:47<br />+ iex ((new-object net.webclient).DownloadString &lt;&lt;&lt;&lt; ('https://chocolatey.org/install.ps1'))<br />+ CategoryInfo : NotSpecified: (:) [], MethodInvocationException<br />+ FullyQualifiedErrorId : DotNetMethodException</pre>

<p>After some google-binging I found a useful article on Stack Overflow that got me the hints I needed. I had to modify the command to force the WebRequest to use (of all things) the Default Credentials for the proxy setting. I didn’t have to add username/password info or anything. This is what seemed odd to me, having to set the setting to the “default”. </p>

<p>Here is the command I finally used:</p>

<pre>@powershell -NoProfile -ExecutionPolicy Unrestricted -Command &quot;[Net.WebRequest]::DefaultWebProxy.Credentials = [Net.CredentialCache]::DefaultCredentials; iex ((New-Object Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))&quot; &amp;&amp; SET PATH=%PATH%;%systemdrive%\chocolatey\bin</pre>

<p>Hopefully this will be helpful to someone else out there running into a corporate proxy.</p>
