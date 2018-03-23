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

Better unit testing with IOC, DI, and Mocking

I thought I would share some tips I use when setting up a new project with unit testing. When writing mobile apps with Xamarin we typically use Prism for a MVVM framework and Unity for our IOC container. This turns out to make a great combination for handling unit testing on the View Models. However, I often see the unit tests instantiating View Models directly and passing in the mocked or test implementation of dependencies. I like to take advantage of using our IOC container to automatically handle dependency injection.

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

With all my tests inheriting from BaseTest I will always have a container ready for each test. There is one problem though, this container is common across all my tests, and the objects it creates will be dirty from each previous test. Using Unity we can handle this by adding a custom LifetimeManager that we can reset on demand. Along with the LifetimeManager we will also create a class that will let us initiate a reset for each type that is given our custom LifetimeManager.

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

Using a shared instance of the LifetimeResetter and calling Reset allows us to clear our all instances our Unity container has created, causing them to be recreated on the next request, all ready for a new test. Let's wire it all together with some helper methods to register the type. The new BaseTest class looks like this:

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

When using NUnit we can add a method with the SetUp attribute that will get called before each test run automatically resetting our instances.

```csharp
[SetUp]
public void OnTestSetup()
{
    Resetter.Reset();
}
```

This gives us everything we need to be able to register all our dependency types and resolve instances. However, using mocking we can simplyfy things a little more. I like to use Moq for my mocking framework, with a couple more helper methods we can handle the mock creation and provide a callback for mock setup on creation.

```csharp
protected void RegisterResettableType<T>(Func<Action<Mock<T>>> onCreatedCallbackFactory) where T : class
{
    RegisterResettableType<T>(new InjectionFactory(c => CreateMockInstance(onCreatedCallbackFactory)));
}

protected T CreateMockInstance<T>(Func<Action<Mock<T>>> onCreatedCallbackFactory) where T : class
{
    var mock = new Mock<T>();
    var onCreatedCallback = onCreatedCallbackFactory();
    onCreatedCallback?.Invoke(mock);
    return mock.Object;
}
```

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

