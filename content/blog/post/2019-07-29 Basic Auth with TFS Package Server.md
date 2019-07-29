---
title: "Basic Authentication with TFS Package Server"
slug: "2019-07-29-basic-auth-with-tfs-package-server"
date: 2019-07-29T13:43:31-05:00
type: "post"
draft: true
tags: [ "csharp", "dotnet", "nuget", "mac", "osx", "packaging", "tfs", "domain", "authentication" ]
categories: [ "Coding" ]
comments: true
---

I recently encountered some authentication issues connecting my Mac to the package service hosted on a client's on-prem TFS server. The server is on a Windows domain and normally I access TFS from a windows VM that is joined to the domain. However, I've recently found myself on my Mac more often while working on one of thier Xamarin mobile apps. This is when I began having problems.

## The Poblem

The client has a couple NuGet packages hosted on the TFS server using the Package Management extension, and whenever I tried to do a NuGet restore I would run into authentication errors. I tried my normal domain user & password as well as a Personal Access Token (the method I wanted to use) and consistently was told my credentials were no good.

```
Please provide credentials for: http://TfsServer/tfs/collection/_packaging/PackageCollection/nuget/v3/index.json

UserName: duane
Password: *****

Unable to load the service index for source http://TfsServer/tfs/collection/_packaging/PackageCollection/nuget/v3/index.json.

Response status code does not indicate success: 401 (Unauthorized).
```

I finally thought I was going mad, so I fired up Postman and supplied my index.json url and personal access token using Basic Authentication and it immediately connected! After some searching with a new search phrase that hinted at a problem with TFS Package Manager and Basic Authentication I hit the jackpot on [Stack Overflow](https://stackoverflow.com/a/55245837).

## The Solution

With NuGet 5.0 there was a new parameter added to the `nuget sources` command that allows you to specify the valid authentication types to use when connecting to a package feed. You can use it when adding a source:

```
nuget sources add -Name MyPackageSource -Server http:/Server/feed/path/index.json -ValidAuthenticationTypes basic -username user -password password
```

You can also specify it directly in your NuGet.config file using the `packageSourceCredentials` section:

```xml
<packageSourceCredentials>
    <MyPackageSourceName>
        <add key="Username" value="unsused" />
        <add key="Password" value="EncryptedPersonalAccessToken" />
        <add key="ValidAuthenticationTypes" value="basic" />
    </MyPackageSourceName>
</packageSourceCredentials>
```

Once I had this in place my `nuget restore` executed with no issues and I was back in business.

## Why?

I never ran into this issue on my Windows VM, and I think it is because the TFS server responds with a request to negotiate credentials and so Windows goes into action and authenticates me with my domain login and everything just works. I'm pretty sure this would be an issue if I attemted to connect with a Windows machine that was not joined to the domain.

I hope this saves you some time (and me, next time I run into this).