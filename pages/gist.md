---
layout: page
title: Gists
description: ice1000's gists
keywords: ice1000
menu: Gist
permalink: /gists/
---

{% assign gists = site.static_files | where: "gist", true %}
{% for gist in gists %}
0. [{{ gist.basename }}](../gist/{{ gist.basename }}/)
{% endfor %}
