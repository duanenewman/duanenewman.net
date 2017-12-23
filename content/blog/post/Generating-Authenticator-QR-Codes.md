---

title: "Generating Authenticator QR Codes"
type: "post"
date: 2016-03-18T08:30:00
draft: False
tags: [ "QRCode", "Security", "tips", "Technology" ]
categories: [ "Technology" ]
comments: true

---

<p>I’ve taken to saving my Authenticator secrets so that I can recover from a lost, damaged or replaced phone with less pain. After actually replacing a phone and having to re-enter all my codes I decided there was a better way then pecking on the phone’s keyboard one letter at a time. I thought that they deliver them to me as a QR code I can scan in the first place, surely I can generate my own to speed up the process.</p>  <p>Well, turns out I can, but it took me a while to find the relevant information. It’s been a while since I did this, but I just helped a friend do the same and remembered some of these pain points and thought I’d share it with the hopes of saving you, dear reader, from some pain yourself.</p>  <p>To begin with, at the time, I had a hard time finding what the format of the string in these QR codes should be. I finally found some documentation somewhere in the bowels of Google that I now know, but have lost track of (sorry for no references). The format is rather simple and follows this pattern:</p>  <p>otpauth://totp/&lt;Display Name&gt;?secret=&lt;Secret&gt;&amp;issuer=&lt;Issue Name&gt;</p>  <p>A word of warning though, several authenticator apps seem to have issue with the issuer parameter, I had to omit it with mine and opted to include the issuer in the display name.</p>  <p>The next step is generating a QR code. There are several ways to do this from apps to websites. Obviously the website route is probably a less than idea route for security data. I went with a free windows store app that would generate a QR from any string. But if you are industrious you might check out a cool library <a href="https://github.com/codebude/QRCoder" target="_blank">QRCoder</a> from <a href="https://github.com/codebude" target="_blank">Raffael Herrmann</a> (I haven’t used it but it looks really cool, and I might just pick it up to play with).</p>
