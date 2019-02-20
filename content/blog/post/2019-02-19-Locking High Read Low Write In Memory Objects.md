---

title: "Concurrent Reads and Locked Writes with In-Memory Objects"
slug: "concurrent-reads-and-locked-writes-with-in-memory-objects"
type: "post"
date: 2019-02-19T00:00:00
draft: False
tags: [ "csharp", "dotnet", "framework", "builtin", "tips", "lock" ]
categories: [ "Coding" ]
comments: true

---

## The Problem

On a recent project one of our clients had implemented an in-memory cache of some high read, low write data. The ultimate solution they had was a List&lt;T&gt; that they could search against while periodically updating when the database was updated. The reads worked great and were incredibly fast. The trouble came when they started to implement the updates. This was in their API layer and so incoming calls were on multiple threads. The multi-threading was perfect for reading, but as soon as they started updating the collection (or any sub-collections on the individual items involved in queries) they, unsurprisingly, started getting {{< target-blank "InvalidOperationExceptions" "https://docs.microsoft.com/en-us/dotnet/api/system.invalidoperationexception" >}} with the message "Collection was modified; enumeration operation may not execute."

## Quick Fix

They needed a quick solution to the exceptions so I put together a simple class to manage locking on updates, while allowing concurrent reads.  (I won't get into if there was a better overall solution to what they already had implemented)

```csharp
public class ReadUpdateLocker
{
	private readonly object UpdateLock = new object();
	private readonly object CounterLock = new object();

	private int ReadCount = 0;

	private void IncrementReadCounter()
	{		
		lock (UpdateLock)
		{
			Interlocked.Increment(ref ReadCount);
		}
	}

	private void DecrementReadCounter()
	{
		Interlocked.Decrement(ref ReadCount);
	}

	public void DoRead(Action readAction)
	{
		try
		{
			IncrementReadCounter();

			readAction.Invoke();
		}
		finally
		{
			DecrementReadCounter();
		}
	}

	public void DoUpdate(Action updateAction)
	{
		lock (UpdateLock)
		{
			//wait for counter to hit 0;		
			while (ReadCount > 0)
			{
				Thread.Sleep(0);
			}

			updateAction.Invoke();
		}
	}
}
```

Basically this allowed the reads to come in concurrently without being blocked, until an update was requested. When an update came in it would lock on the UpdateLock object and hold the lock until all the active read threads finished, which decremented the read counter back to 0. After the update finished and released the lock any incoming reads would resume with minimal impact.

## Making it Easier

So we had a solution that worked, but it required reading and updating code to keep track of both the in-memory list of data as well as the instance of the locking class. So I did a little refactoring so that the data was hidden behind the locking mechanism, which then guarded all access to the collection through the locks. This  simplified the calling code by removing the need to keep track of two objects, and preventing exceptions for accidental unlocked access to the data.

```csharp
public class InstanceReadUpdateLocker<T>
{
	private ReadUpdateLocker locker = new ReadUpdateLocker();
	private T Data { get; set; }

	public InstanceReadUpdateLocker(T data)
	{
		Data = data;
	}
	
	public T DoRead(Func<T, T> readAction)
	{
		var result = default(T);
		locker.DoRead (() => result = readAction(Data));
		return result;
	}

	public void DoUpdate(Action<T> updateAction)
	{
		locker.DoUpdate (() => updateAction(Data));
	}
}
```

Now all reads and updates to the data went through the class and this worked well.

## Reinventing the Wheel

After I finished the proof of concept and implemented it around their calls I got to thinking this has to be a common problem and there must be other implementations out there. What I found was the need to constantly investigate what the .NET framework has to offer and avoid reinventing the wheel. 

I present to you the {{< target-blank "ReaderWriterLock" "https://docs.microsoft.com/en-us/dotnet/api/system.threading.readerwriterlock" >}} class. Yes, a class designed to allow your code to track read and write locks. However, if you look at the sample implementation it is a bit more involved to use, because it is also more flexible. I wanted to be able to use it as simply as my above InstanceReadUpdateLocker class. So I wrote this little class to wrap the locking functionality, but still provide simple usage from calling code.

```csharp
public class InstanceReaderWriterLock<T>
{
	private ReaderWriterLock locker = new ReaderWriterLock();
	private T Data { get; set; }
	private int timeout = 500;

	public InstanceReaderWriterLock(T data)
	{
		Data = data;
	}

	public T DoRead(Func<T, T> readAction)
	{
		try
		{
			locker.AcquireReaderLock(timeout);

			return readAction.Invoke(Data);
		}
		finally
		{
			locker.ReleaseReaderLock();
		}
	}

	public void DoUpdate(Action<T> updateAction)
	{
		try
		{
			locker.AcquireWriterLock(timeout);

			updateAction.Invoke(Data);
		}
		finally
		{
			locker.ReleaseWriterLock();
		}
	}
}
```

After implementing this class and doing a little testing it turns out that using the ReaderWriterLock to handle the locking was faster (and more consistent). It ran about 30% faster than my ReadUpdateLockers best time and always came in with very similar results, while my results would sometimes be up to 30% longer than my best time (making it almost twice as long as the ReadUpdateLocker). I'm sure Microsoft has taken the time to implement optimizations at the IL or machine level.

## Wrapup

The moral of the story is if you think you are creating something that seems like a common need, take a quick look to make sure there isn't already one built for you.

Here is a {{< target-blank "gist" "https://gist.github.com/duanenewman/6bf027fae3aab5aa85342eb34c94d9d4" >}} that you can drop in LinqPad to see the initial problem and all the above solutions with some random multi-threaded calls. 

## Update, Even More Built-In Types

Thanks to a {{< target-blank "comment" "https://www.linkedin.com/feed/update/urn:li:activity:6503777687096553474/" >}} from {{< target-blank "Chase" "https://twitter.com/chaseaucoin" >}}, another class to checkout is {{< target-blank "ConcurrentBag<T>" "https://docs.microsoft.com/en-us/dotnet/api/system.collections.concurrent.concurrentbag-1" >}}, which gives you threadsafe access to the collection. The .NET framework has a wealth of types out there!