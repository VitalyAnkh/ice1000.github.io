---
layout: page
title: Open Source Contributions
description: Open Source Contributions
keywords: ice1000
comments: true
permalink: /opensource-contributions/
---

## Overview

<table>
  <thead>
    <tr>
      <th style="text-align: left">Repo#No.</th>
      <th style="text-align: left">Status</th>
      <th style="text-align: left">Checks</th>
      <th style="text-align: left">Details</th>
    </tr>
  </thead>
  <tbody>
    {% for con in site.data.contribs %}
    <tr>
      <td style="text-align: left">{{ con.repo }}#{{ con.num }}</td>
      <td style="text-align: left">
	    <a href="https://github.com/{{ con.repo }}/pull/{{ con.num }}/">
		  <img src="https://img.shields.io/github/issues/detail/s/{{ con.repo }}/{{ con.num }}.svg" alt="GitHub issue state" />
	    </a>
	  </td>
      <td style="text-align: left">
	    <a href="https://github.com/{{ con.repo }}/pull/{{ con.num }}/">
		  <img src="https://img.shields.io/github/status/contexts/pulls/{{ con.repo }}/{{ con.num }}.svg" alt="GitHub pull request check state" />
	    </a>
	  </td>
	  <td style="text-align: left">
	    <a href="#{{ con.repo_s }}{{ con.num }}">
		See below
	   </a>
	  </td>
    </tr>
    {% endfor %}
  </tbody>
</table>

{% for con in site.data.contribs %}
## {{ con.repo }}\#{{ con.num }}

[pull request](https://github.com/{{ con.repo }}/pull/{{ con.num }}/)

{% if con.ref == nil %}
{% else %}
+ Reference  
{{ con.ref }}
{% endif %}

+ Content  
{{ con.content }}
{% endfor %}
