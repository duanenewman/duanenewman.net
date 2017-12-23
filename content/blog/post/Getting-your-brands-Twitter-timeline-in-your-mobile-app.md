---

title: "Getting your brand’s Twitter timeline in your mobile app"
type: "post"
date: 2015-03-03T08:55:00
draft: False
tags: [ "twitter", "Xamarin", "business", "Coding", "tips", "linq", "social", "mobile" ]
categories: [ "Coding" ]

---

<p>I’m working on a demo app to show some simple functionality that can be done with Xamarin Forms. I’m using the opportunity to also make a business card app for myself (and ultimately for <a href="http://www.alienarc.com" target="_blank">Alien Arc</a>). The app has my picture, name, short bio, and other relevant information. This also seemed like a good place to tie in some of my various social network feeds. I quickly added a page that pulls my blog RSS feed and lists my recent posts. That went really quick and next on my list was to load my twitter timeline and show recent tweets. The blog was so easy and quick to do that I thought it would take no time to get twitter integrated.</p>  <p>Then I realized I’ve never pulled twitter data.. I did a little research and figured out that I just needed to do <a href="https://dev.twitter.com/oauth/application-only" target="_blank">Application-Only Authorization</a> for my app. Setting up the application over at <a href="https://apps.twitter.com/" target="_blank">Twitter Apps</a> was pretty easy and I quickly had my API key and secret. Now I just needed to find a libraries for the Twitter API and pull my timeline.. </p>  <p>That is where things really slowed down. I found plenty of documentation for several libraries that showed full user token authentication to give your app access to a particular users account (like for a full twitter client). What I could not find was people doing Application-Only requests. It started to seem dismal as at first I only found one explicit reference to application-only authentication on a library forum that indicated the library did not yet have support. I was getting ready to give up and just roll my own simple wrapper for the required API calls when I finally found this StackOverflow question: <a href="http://stackoverflow.com/questions/16387037/twitter-api-application-only-authentication-with-linq2twitter" target="_blank">Twitter API application-only authentication (with linq2twitter)</a></p>  <p>Finally, I was close. Except it was obsolete code referencing an earlier version of <a href="https://linqtotwitter.codeplex.com/" target="_blank">linq2twitter</a>. It wasn’t too bad though, the authentication has only slightly changed. I quickly corrected that, did a little digging for code that pulled a timeline instead of a search result and I was in business. Here is my finished code:</p>  <pre class="brush: csharp;">var auth = new ApplicationOnlyAuthorizer
{
    CredentialStore = new InMemoryCredentialStore
    {
        ConsumerKey = consumerKey,
        ConsumerSecret = consumerSecret                        
    }
    
};

auth.AuthorizeAsync().Wait();

var twitter = new TwitterContext(auth);

var timeline =
    twitter.Status
        .Where(t =&gt; 
            t.Type == StatusType.User &amp;&amp; 
            t.ScreenName == &quot;duanenewman&quot; &amp;&amp; 
            t.IncludeRetweets == true)
        .OrderByDescending(t =&gt; t.CreatedAt)
        .ToList();

foreach (var tweet in timeline)
{
    Tweets.Add(new Tweet()
    {
        Date = tweet.CreatedAt,
        Content = tweet.Text
    });
}</pre>
