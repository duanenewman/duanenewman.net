---
title: "Unit Testing Prism Apps With Ease"
slug: "unit-testing-prism-apps-with-ease"
date: 2019-05-03T11:24:25-05:00
draft: false
tags: [ ]
categories: [ ]
---

Prism makes it easy to use dependency injection and keep our apps modular. This modularity is great for testing, but all that dependency injection magic can make our test code seem more complex and filled with a lot of ceremony just to create a testable instance of a ViewModel and its dependencies. I've learned to embrace magic and I'll share tips on how to take advantage of the same IoC container strategy used at runtime to make instantiating the class we want to test less painful. We'll tap into the life-cycle or our unit testing framework and combine a mocking framework and a custom lifetime manager for our IoC container to make sure each test has clean dependencies and keep us from ever directly instantiating our ViewModels or dependencies again. A great side-effect is that our tests become more resilient against changing dependencies that do not concern the test. Skip all the setup ceremony and get straight to the actual test.

## Learning Objectives

* Attendees will learn how to harness IoC in their unit tests to simplify instance creation
* Attendees will learn how to use Action<T> delegate methods to manage setup of mocked types and override/append setup per test
* Attendees will be shown How to convert existing tests to use these methodologies

## Level: Intermediate