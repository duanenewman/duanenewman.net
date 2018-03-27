---

title: "Processing collections with LINQ using the Aggregate extension method"
slug: "Processing-collections-with-LINQ-using-the-Aggregate-extension-method"
type: "post"
date: 2011-09-14T22:19:00
draft: False
tags: [ "dotnet", "linq" ]
categories: [ "Coding" ]
comments: true

---

<p>Everyone knows one of the easiest ways to process collections of objects is using foreach, it is much more elegant and less error prone (IMHO) than using a for (int x..) and looping by index. &nbsp;However, sometimes you get forced into using the indexer to process a collection. &nbsp;This usually happens when you need to look at the current object in context of the previous. &nbsp;</p>
<p>The need to use the indexer and have code like obj[i] == obj[i -1] bugged me. I spent a little time digging into the LINQ extensions to see if anything could help. &nbsp;Then i stumbled upon an explanation of the various aggregation methods that got me thinking. &nbsp;After a little play time in Linq Pad I had a working solution.</p>
<p>I discovered that the answer was in using the Aggregate method. &nbsp;The Aggregate method takes a seed value and a function that accepts two paramters and returns a value, all of the type of the collection. &nbsp;The first call in passes the seed value and the current item, each subsiquent call passes the previous calls output and the current item. &nbsp;Using this we are able to seed with a null and return the "current" item untouched, allowing continuous processing of the current value againts the previous (or seed) value.</p>
<p>Here is my sample code, it processes the list and counts the number of times each property toggles into the true state (and ignores contiguous true values):</p>
<p>&nbsp;</p>
<pre class="brush: c-sharp;">public class Item
{
	public bool Value1 { get; set; }
	public bool Value2 { get; set; }
}

void Main()
{
	var Items = new List&lt;Item&gt;()
	{
		new Item() { Value1 = true, Value2 = false },
		new Item() { Value1 = true, Value2 = false },
		new Item() { Value1 = true, Value2 = true },
		new Item() { Value1 = true, Value2 = true },
		new Item() { Value1 = false, Value2 = true },
		new Item() { Value1 = false, Value2 = true },
		new Item() { Value1 = true, Value2 = false },
		new Item() { Value1 = true, Value2 = false },
	};
        //Number of Times Value1 entered the on state.
	int count1 = 0; 
        //Number of Times Value2 entered the on state.
	int count2 = 0;

	Items.Aggregate (null, (Func&lt;Item, Item, Item&gt;)((a, b)=&gt;
	{
		count1 += ((a == null || a.Value1 != b.Value1) &amp;&amp; b.Value1 == true ? 1 : 0);
		count2 += ((a == null || a.Value2 != b.Value2) &amp;&amp; b.Value2 == true ? 1 : 0);
		return b;
	}));
}</pre>
<p>I hope you find this helpful. &nbsp;Obviously you could have an actual method defined to do this processing istead of an anonymous Func, but I like having this simple code inline with local variables.</p>
