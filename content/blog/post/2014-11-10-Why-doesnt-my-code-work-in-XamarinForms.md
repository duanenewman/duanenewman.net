---

title: "Why doesn’t my code work in Xamarin.Forms?"
slug: "Why-doesnt-my-code-work-in-XamarinForms"
type: "post"
date: 2014-11-10T13:00:00
draft: False
tags: [ "tips", "Xamarin", "Xamarin Forms" ]
categories: [ "Coding" ]
comments: true

---

<p>If you have tried something in Xamarin.Forms that should work but didn&rsquo;t, don&rsquo;t worry you might not be going crazy (I can&rsquo;t say for sure, I&rsquo;m a programmer, not a psychologist).</p>
<p>I&rsquo;ve been diving deeper into Xamarin.Forms over the last couple months while working on a small project we have as well as in preparation for my upcoming talk at St. Louis Days of .NET. <br />Sometimes in the course of creating a sample project I write some code that I know should work and then watch the exceptions pop-up (or worse, see nothing at all) when I run it. Then I go do a quick search and find that this is a known issue&hellip; and that it has been fixed. That is when I remember that I didn&rsquo;t update my Xamarin.Forms nuget packages.</p>
<p>The release version that is installed with the tools and referenced by default by the template when you create a new mobile app solution is out of date. Many small improvements and bug fixes have been introduced since release and updating your nuget packages is a vital first step for creating a successful project.</p>
