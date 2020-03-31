---
title: "Unit Testing With Ease"
slug: "unit-testing-with-ease"
date: 2019-05-03T11:24:25-05:00
draft: false
tags: [ ]
categories: [ ]
---

Do you want to skip all the setup ceremony and get straight to the actual testing when writing unit tests? Leveraging dependency injection and IoC makes it a breeze to build solutions that are modular and testable, but building out those dependency chains in our unit tests can leave them cluttered and overly complex. It's time to learn to embrace the magic of IoC, DI, and mocking to lower the friction of writing and maintaining unit tests. Taking cues from the open-source library Ease, you can see how to tap into the life-cycle of unit testing frameworks and integrate it with an IoC container to give you a fresh start for each test. Throw in a little mocking and a flexible pattern for managing setup and now you are testing in high gear! A great side-effect of using Ease, or a similar methodology, is that tests become more resilient against changes in the dependencies that are not a direct concern of the test, so you end up breaking fewer tests and changing less test code. What are you waiting for? Stop the ceremony, and start testing!

## Learning Objectives

* Attendees will learn how to harness IoC in their unit tests to simplify instance creation
* Attendees will learn how to use Action<T> delegate methods to manage setup of mocked types and override/append setup per test
* Attendees will be shown How to convert existing tests to use these methodologies

## Level: Intermediate