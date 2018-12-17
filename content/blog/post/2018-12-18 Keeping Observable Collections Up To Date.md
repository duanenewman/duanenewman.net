---

title: "Keeping Observable Collections Up To Date"
slug: "keeping-observable-collections-up-to-date"
type: "post"
date: 2018-12-17T00:00:00
draft: False
tags: [ "c#", "dotnet", "csadvent", "mvvm", "observable", "api" ]
categories: [ "Coding" ]
comments: true

---

This post is part of [The Second Annual C# Advent](https://crosscuttingconcerns.com/The-Second-Annual-C-Advent) organized by Matthew Groves. Check out the article for a bunch of other great posts about C# development.

One of the powerful capabilities we've learned to leverage when using the MVVM pattern for XAML based apps, whether for the desktop or mobile platforms, is data binding. Binding allows us to easily keep our View up to date with changes in the ViewModel. These bindings are typically pretty quick when not abused, but there are situations where they can become less than performant, causing visual anomalies such as flickering or even impacting general app performance.

## The Problem

One of these situations that can really affect performance is binding a frequently changing observable collection to you UI, especially with a complex DataTemplate. We can run into this problem when we are doing something like polling an API that returns a collection that updates frequently. This can be even worse if an item can be added or removed from the list over time.

A simple solution to this problem might be to just rebuild the list each time. While that might seem to work well enough with just a few items or a basic UI layout it will result in the creation and disposal of a lot of objects. That constant churn of object construction and destruction will ramp up both the CPU and memory usage of your application.

## A Solution

I solved this by writing code to compare my incoming list with my displayed list and to update the existing list to match. We want to achieve three steps with this code: 1) remove items that are no longer present, 2) update items that are in both lists, and 3) add new items from our incoming list. There is an optional 4th step that my code doesn't cover, ordering the list of current items to match the order from our incoming list.

## Removing Old Items

First we get all the items from our existing list that we cannot find in our update list as a new list (so we don't get an exception due to the collection changing as we enumerate it). Then we remove each item that didn't match from the existing list.

```csharp
var itemsToRemove = existingCollection
    .Where(e => !updateCollection.Any(u => e.Id == u.Id))
    .ToList();

foreach (var item in itemsToRemove)
{
    existingCollection.Remove(item);
}
```

## Updating Existing Items

After we have removed the old items from the list we need to update the remaining items with the new values.

```csharp
foreach (var item in existingCollection)
{
    var updatedItem = updateCollection.First(u => item.Id == u.Id));
    item.Property = updatedItem.Property
}
```

## Adding new Items

Finally, we need to add in any new items from our update list.

```csharp
var itemsToAdd = updateCollection
    .Where(u => !existingCollection.Any(e => e.Id == u.Id)).ToList();

foreach (var item in itemsToAdd)
{
    existingCollection.Add(item);
}
```

## Making it Better

You might have noticed that we are doing some repetitive iterations when we remove and update the collection, and this code is very specific to our app. Let's make the code a little more generic and put it in some extension methods so we can reuse it.