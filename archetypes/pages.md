---
title : '{{ replace .File.ContentBaseName "-" " " | title }}'
author: {{ .Site.Params.author }}
type: page
date : {{ .Date }}
url: "/{{ .Name }}/"
draft : true
---