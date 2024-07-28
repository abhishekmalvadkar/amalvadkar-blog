---
title : '{{ replace .File.ContentBaseName "-" " " | title }}'
author: {{ .Site.Params.author }}
date : {{ .Date }}
url: "/{{ .Name }}/"
draft : true
---