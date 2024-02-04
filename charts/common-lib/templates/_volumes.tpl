{{/* vim: set filetype=mustache: */}}

{{/*
Return container volumeMounts block
*/}}
{{- define "common-lib.volumes.volumeMounts" -}}
  {{- with .Values.volumeMounts }}
volumeMounts:
  {{- toYaml . | nindent 2 }}
  {{- end }}
{{- end }}

{{/*
Return container volumes block
*/}}
{{- define "common-lib.volumes.volumes" -}}
  {{- with .Values.volumes }}
volumes:
  {{- toYaml . | nindent 2 }}
  {{- end }}
{{- end }}

{{/*
Return global container volumeMounts block
*/}}
{{- define "common-lib.volumes.global.volumeMounts" -}}
  {{- with .Values.global.volumeMounts }}
volumeMounts:
  {{- toYaml . | nindent 2 }}
  {{- end }}
{{- end }}

{{/*
Return global container volumes block
*/}}
{{- define "common-lib.volumes.global.volumes" -}}
  {{- with .Values.global.volumes }}
volumes:
  {{- toYaml . | nindent 2 }}
  {{- end }}
{{- end }}
