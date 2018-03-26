---

title: "Better unit testing with IOC, DI, and Mocking"
slug: "better-unit-testing-with-ioc-di-and-mocking"
type: "post"
date: 2018-03-26T00:00:00
draft: False
tags: [ "c#", "unit testing", "di", "ioc", ".net", "tips" ]
categories: [ "Coding" ]
comments: true

---

When you write code designed for dependency injection it can make testing easier.. But it can also make it seem more complex and add a lot of ceremony to creating your testable instances. I thought I would share some tips I use when setting up a new cross-platform mobile project with unit testing. We can take advantage of the same IoC container strategy to make instanciating the class we want to test less painful.

We typically develop our cross-platform Xamarin mobile apps using Prism for a MVVM framework, Unity for our IOC container, and NUnit for our testing framework. This turns out to make a great combination for handling unit testing on the View Models. Rather than writing code in out unit tests that manually creates supporting types and directly passes them into the View Models via the constructor, I like to take advantage of using our IOC container to automatically handle the dependency injection.

## A Common Base

To begin with I create a base test class that provides the Unity container for any testing.

```csharp
public abstract class BaseTest
{
    protected UnityContainer Container;

    protected BaseTest()
    {
        Container = new UnityContainer();
    }
}
```

With all my tests inheriting from BaseTest I will always have a container ready for testing. I can now register implementations into this container and use it to resolve my view models. There is one problem though, this container is common across all my tests, and the objects it creates will be dirty from each previous test.

## Lifetime Manager

Using Unity we can handle this by adding a custom LifetimeManager that we can reset on demand. The LifetimeManager is responsible for holding the reference to an instance that the Unity IoC container creates. Since we can create a custom LifetimeManager we can control how it keeps track of the instance. We will also create a class that will let us initiate a reset to release the instance that our custom LifetimeManager is holding. We'll pass this into our custom LifetimeManager on instanciation of the manager.

```csharp
protected class LifetimeResetter
{
    public event EventHandler<EventArgs> OnReset;

    public void Reset()
    {
        OnReset?.Invoke(this, EventArgs.Empty);
    }
}

protected class ResettableLifetimeManager : LifetimeManager
{
    public ResettableLifetimeManager(LifetimeResetter lifetimeResetter)
    {
        lifetimeResetter.OnReset += (o, args) => instance = null;
    }

    private object instance;

    public override object GetValue()
    {
        return instance;
    }

    public override void SetValue(object newValue)
    {
        instance = newValue;
    }

    public override void RemoveValue()
    {
        instance = null;
    }
}
```

## Resetting For Each Test

Using our ResettableLifetimeManager for each type we register and a shared instance of the LifetimeResetter allows us to clear our all instances our Unity container has created by calling the LifetimeResetter's Reset method. After the reset is called and all the instances are cleared Unity will automatically create new instances the next time one is requested, giving each test a fresh instance. Let's wire it all together with some helper methods to register the type. The new BaseTest class now looks like this:

```csharp
public abstract class BaseTest
{
    protected UnityContainer Container;
    protected LifetimeResetter Resetter { get; set; }

    protected BaseTest()
    {
        Resetter = new LifetimeResetter();
        Container = new UnityContainer();
    }

    protected void RegisterResettableType<T>(params InjectionMember[] injectionMembers)
    {
        Container.RegisterType<T>(new ResettableLifetimeManager(Resetter), injectionMembers);
    }

}
```

## Automating the reset

NUnit allows us to add a method to our test class that will be called before each individual test is ran. This is done by adding the SetUp attribute to the method. This gives us a convenient way to call the Reset method on our LifetimeResetter before each test in any test class that inherits from our base. A nice feature of NUnit is that this SetUp attribute can be used in both a base class as well as on our actual test class, allowing someone using our BaseTest class to add their own test initializtion code without stomping on our lifetime management.

```csharp
[SetUp]
public void OnTestSetup()
{
    Resetter.Reset();
}
```

## Adding Support for Mocking

This gives us everything we need to be able to register all our dependency types and resolve instances. However, using mocking we can simplyfy things a little more. I like to use Moq for my mocking framework, and that usually requires doing some setup work beyond just creating a Mock of your type. To handle this setup, which could vary by each test, we'll pass in a Func that can either be set once during the class constructor, or can be swapped at the start of each test.

```csharp
protected void RegisterResettableType<T>(Func<Action<Mock<T>>> onCreatedCallbackFactory) where T : class
{
    RegisterResettableType<T>(new InjectionFactory(c => CreateMockInstance(onCreatedCallbackFactory)));
}

private T CreateMockInstance<T>(Func<Action<Mock<T>>> onCreatedCallbackFactory) where T : class
{
    var mock = new Mock<T>();
    var onCreatedCallback = onCreatedCallbackFactory();
    onCreatedCallback?.Invoke(mock);
    return mock.Object;
}
```

## Putting it All Together

Now in our test we can register a type and upon creation it will call our setup method passing in the newly mocked instance, allowing us to add Setup calls or get a reference for checking execution with a Verify call later in the test.

```csharp
public class OrderViewModelTest
{
    [SetUp]
    public void TestSetup()
    {
        //setup the IOrderService for all tests
        RegisterResettableType(() => Mock<IOrderService> mock => 
        {
            mock.Setup(s => s.GetOrders()
                .Returns(new List<Order>());
        }); 
    }

    [Test]
    public void CreatingOrderViewModelCallsOrderServiceGetOrdersOnce()
    {
        var viewModel = Container.Resolve<OrderViewModel>();
        
        var service = Mock.Get(Container.Resolve<IOrderService>());
        service.Verify(s => s.GetOrders(), Times.Once);
    }
}
```

