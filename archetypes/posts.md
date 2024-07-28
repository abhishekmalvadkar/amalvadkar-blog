---
title : '{{ replace .File.ContentBaseName "-" " " | title }}'
author: {{ .Site.Params.author }}
type: post
date : {{ .Date }}
url: "/{{ .Name }}/"
draft : true
---