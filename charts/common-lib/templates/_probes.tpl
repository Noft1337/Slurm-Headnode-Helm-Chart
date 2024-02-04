{{/* vim: set filetype=mustache: */}}

{{/*
Create a base livenessProbe function
*/}}
{{- define "common-lib.probes.liveness.create" -}}
{{- with .Values.livenessProbe -}}
livenessProbe:
  {{- toYaml . | nindent 2 }}
{{- end -}}
{{- end }}

{{/*
Create a base readinessProbe function
*/}}
{{- define "common-lib.probes.readiness.create" -}}
{{- with .Values.readinessProbe -}}
readinessProbe:
  {{- toYaml . | nindent 2 }}
{{- end -}}
{{- end }}
