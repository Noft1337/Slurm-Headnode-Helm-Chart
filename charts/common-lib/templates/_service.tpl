{{/* vim: set filetype=mustache: */}}

{{/*
Create a base service function
*/}}
{{- define "common-lib.service.create" -}}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "common-lib.names.fullname" . }}
  labels:
    {{- include "common-lib.labels.labels" . | nindent 4 }}
spec:
  type: {{ .Values.service.type }}
{{- with .Values.service.loadBalancerIP }}
  loadBalancerIP:
    {{- toYaml . | nindent 4 }}
{{- end }}
{{- with .Values.service.ports }}
  ports:
    {{- toYaml . | nindent 4 }}
{{- end }}
  selector:
    {{- include "common-lib.labels.selectorLabels" . | nindent 4 }}
{{- end }}

{{/*
Helper function to create a headless service.
*/}}
{{- define "common-lib.headless-service.create" -}}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "common-lib.names.fullname" . }}-headless
  labels:
    {{- include "common-lib.labels.labels" . | nindent 4 }}
spec:
  type: ClusterIP
  clusterIP: None
{{- with .Values.service.ports }}
  ports:
    {{- toYaml . | nindent 4 }}
{{- end }}
  selector:
    {{- include "common-lib.labels.selectorLabels" . | nindent 4 }}
{{- end }}
