---
title: "A Better Way to Override References With PackageReference"
slug: "a-better-way-to-override-references-with-packagereference"
date: 2019-04-01T00:00:00-06:00
type: "post"
draft: true
tags: [ "csharp", "dotnet" ]
categories: [ "Coding" ]
comments: true
---

Recently, there was a {{< target-blank "new feature added" "https://github.com/NuGet/Home/issues/6949" >}} to msbuild (working in Visual Studio 2019 15.9.9) that generates a variable for each package that contains the full path to the package version being used. All you have to do is add an attribute to each `<PackageReference>` you want need to work with. 

There are just two changes to what we did before:

1. Add `GeneratePathProperty` attribute to `<PackageReference>`
2. Switch to `Pkg<Package_Name>` variable in `<HintPath>`

Step one is pretty simple, add the attribute `GeneratePathProperty` with a value of `true`:

```xml
<PackageReference Include="Prism.Core" GeneratePathProperty="true">
    <Version>7.1.0.431</Version>
</PackageReference>
```

This will cause msbuild to generate a property for that package that points to directory for the specific version of that package, future proofing against version changes and any changes in directory structure to how NuGet stores the package cache. The variable format prepends `Pkg` to the package name and replaced any period (.) with an underscore (_). That makes the variable for `Prism.Core` into `PkgPrism_Core`.

That makes the next step pretty easy. Let's update our `<Reference>` to this:

```xml
<Reference Include="Prism">
    <HintPath>$(PkgPrism_Core)lib\netstandard2.0\Prism.dll</HintPath>
</Reference>
```

Now when you update packages to a new version you no longer need to worry about updating the `<Reference>` node.