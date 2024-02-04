{{/* vim: set filetype=mustache: */}}

{{/*
Create a serviceAccount based on .Values.serviceAccount.create setting
*/}}
{{- define "common-lib.sa.create" -}}
{{- if .Values.serviceAccount.create -}}
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ include "common-lib.names.serviceAccountName" . }}
  labels:
    {{- include "common-lib.labels.labels" . | nindent 4 }}
  {{- with .Values.serviceAccount.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}
