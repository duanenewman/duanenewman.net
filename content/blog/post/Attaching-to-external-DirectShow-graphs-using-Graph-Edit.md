---

title: "Attaching to external DirectShow graphs using Graph Edit"
type: "post"
date: 2011-09-14T18:00:00
draft: False
tags: [ "media", "directshow", ".net" ]
categories: [ "Coding" ]

---

<p>In my day job I work on a product that does a lot of video work and in fact has a custom DirectShow player that gets all our video into WPF. &nbsp;It plays multiple files all synchronized (a real challenge).</p>
<p>While looking into ways to improve performance I found myself needing to see how my filter graph was being built. &nbsp;I did a little looking and found that creating an instance of DsROTEntry with a reference to the graph makes it available for external viewing. The code is really quite simple:</p>
<pre class="brush: c-sharp;">RotEntry = new DsROTEntry(graph);</pre>
<p>This was all the samples said you needed to do. However, after adding this line the graph still would not be listed in Graph Edit when attempting to connect to a remote graph. I tried all sorts of things (double-checking the app was running 32-bit, etc) to no avail.</p>
<p>After a little digging and research I discovered that there is one additional step; you must register a dll supplied with the windows SDK. The file is proppage.dll and should be in the bin directory of the SDK. This command worked for me:</p>
<pre>regsvr32 "C:\Program Files (x86)\Microsoft SDKs\Windows\v7.0A\Bin\proppage.dll"</pre>
<p>Now any time I need to check my graph it is readily available.</p>
