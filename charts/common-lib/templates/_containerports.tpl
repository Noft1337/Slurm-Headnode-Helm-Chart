{{/* vim: set filetype=mustache: */}}

{{/*
Extract's the container Ports section when service is enabled, and service ports are provided.
*/}}
{{- define "common-lib.containerports.createfromService" -}}
{{- if .Values.service -}}
{{- if .Values.service.ports -}}
ports:
{{- range $containerPort := .Values.service.ports }}
  - name: {{ $containerPort.name }}
    containerPort: {{ $containerPort.port }}
    protocol: {{ $containerPort.protocol }}
{{- end }}
{{- end -}}
{{- end -}}
{{- end -}}
