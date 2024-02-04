{{/* vim: set filetype=mustache: */}}

{{/*
Return environment variables block
*/}}
{{- define "common-lib.env.env" -}}
  {{- with .Values.env }}
env:
  {{- toYaml . | nindent 2 }}
  {{- end }}
{{- end }}

{{/*
Return global environment variables block
*/}}
{{- define "common-lib.env.global.env" -}}
  {{- with .Values.global.env }}
env:
  {{- toYaml . | nindent 2 }}
  {{- end }}
{{- end }}
