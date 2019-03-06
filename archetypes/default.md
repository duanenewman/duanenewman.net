---
title: "{{ replace .TranslationBaseName "-" " " | title }}"
slug: "{{ replace .TranslationBaseName " " "-" | lower }}"
date: {{ .Date }}
type: "post"
draft: true
tags: [ "csharp", "dotnet" ]
categories: [ "Coding" ]
comments: true
---
