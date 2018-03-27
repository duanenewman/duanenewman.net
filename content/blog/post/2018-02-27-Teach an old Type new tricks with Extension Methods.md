---

title: "Teach an old Type new tricks with Extension Methods"
slug: "Teach-an-old-Type-new-tricks-with-Extension-Methods"
type: "post"
date: 2018-02-27T00:00:00
draft: False
tags: [ "c#", "dotnet", "tips" ]
categories: [ "Coding" ]
comments: true

---

Extension methods are a great way to add functionality or integration for established types. Learn about some of the cool things that you can do without the need to subclass or modify a class directly. You can even use extension methods to supply specialized functionality that is only relevant in a particular situation or when also making use of another type or library. We'll take a look at a few quick tricks and explore how you can get started with Extension Methods today.

# What are Extension Methods? 

They are this cool concept introduced with .NET 3.0 and are central to making LINQ usable and convenient (more on that later). They basically allow you to write a method that acts as an extension to an existing class, even if you don't have access to the source code, or if the class is sealed. This can be a great way to make your code flow better and wrap up utilitarian functionality for easy reuse. There are some limitations to extension methods: the code inside an extension method has the same level of access to the class as you would writing any other code outside of the class, meaning you can't access non-public properties or methods. 

# Where can I find Extension Methods in .NET?

A great example of extension methods is the implementation of LINQ. If you take a close look at all the functionality that was provided as a part of the LINQ standard you see that all of it was created through extension methods. This was vital to allowing LINQ to be provided through a separate assembly from mscorelib while still being convenient to use and supporting the fluent coding style we are used to today. To provide the same level of functionality it would have required making all classes that inherit IEnumerable<T> instead inherit from some abstract base. That's right, did I forget to mention that Extension Methods can extend on Interfaces too, not just concrete classes? This is another key feature of extension methods, since there is no other convenient way to provide methods with implementations on an interface.

# How do you make an extension method?

To create an extension method you need to adhere to 3 things: the class has to be static, the method has to be static, and the first parameter the method takes has to be of the type you want to extend, and it has to use the [this] keyword.

```csharp
namespace MyExtensions
{
    public static class StringExtensions
    {
        public static bool IsNotEmptyOrAsterisk(this string input)
        {
            return !input.Equals(string.Empty) && !input.Equals("*");
        }
    }
}
```

Using an extension method is really easy, there is just one real requirement (aside from referencing the assembly with the extension methods), you have to either be in the same namespace as your extension method's class or include a using statement for that namespace so the compiler knows where to look for your extension methods. Then you just call it like a regular method.

```csharp
using MyExtensions;
...
var test = "*";
var pass = test.IsNotEmptyOrAsterisk();
```

This can be a great way to build a library of functionality that extends base CLR types that you can easily include an reference in all your projects. It also allows you to break code into separate assemblies that you can pick and choose when they are relevant and needed. I use this often when I am working with a third party library that might common code I have to perform on one of the libraries embedded types.

# What can you do with an Extension Method?

Anything you can write normally. Here are a couple ideas to get you thinking:

IsIn: I get tired of if statements that require checking a single variable for multiple conditions. For one, I can lose track of where I am, if the conditional check is complex, and then it is often very verbose. This is especially true if I'm checking a property of a property in a LINQ statement. Consider the following:

```csharp
var OrderLinesICareAbout = orders.Sum(o => o.Items.Count(l =>
    (l.ItemType == ItemType.KeyBoard ||
    l.ItemType == ItemType.Mouse ||
    l.ItemType == ItemType.GamePad) &&
    l.Price < 50));
```

Here is my Extension Method:

```csharp
public static bool IsIn<T>(this T input, params T[] values)
{
    foreach (var value in values)
    {
        if (value == null) continue;
        if (input.Equals(value)) return true;
    }
    return false;
}
```

Now I can rewrite my code like this:

```csharp
OrderLinesICareAbout = orders.Sum(o => o.Items.Count(l =>
    l.ItemType.IsIn(ItemType.KeyBoard, ItemType.Mouse, ItemType.GamePad) &&
    l.Price < 50));
```

Another common annoyance is checking if a date is between two dates can be verbose and take a moment to visually parse:

```csharp
var isInRange = DateValue >= startDate && DateValue <= endDate;
```

Add an extension method:

```csharp
public static bool IsBetween(this DateTime input, DateTime start, DateTime end)
{
    return input >= start && input <= end;
}
```

And it becomes much clearer:

```csharp
var isInRange = DateValue.IsBetween(startDate, endDate);
```

What have you done with extension methods? Drop a comment below with some of your favorites.
