{{/* vim: set filetype=mustache: */}}

{{/*
Create a base hpa function, this function accepts apiVersion, and kind as arguments.
*/}}
{{- define "common-lib.hpa.create" -}}
{{- $apiVersion := index . "apiVersion" -}}
{{- $kind := index . "kind" -}}
{{- $context := index . "context" -}}
{{- if $context.enabled }}
apiVersion: autoscaling/v2beta1
kind: HorizontalPodAutoscaler
metadata:
  name: {{ include "common-lib.names.fullname" . }}
  labels:
    {{- include "common-lib.labels.labels" . | nindent 4 }}
spec:
  scaleTargetRef:
    apiVersion: {{ $apiVersion }}
    kind: {{ $kind }}
    name: {{ include "common-lib.names.fullname" . }}
  minReplicas: {{ $context.minReplicas }}
  maxReplicas: {{ $context.maxReplicas }}
  metrics:
  {{- if $context.targetCPUUtilizationPercentage }}
    - type: Resource
      resource:
        name: cpu
        targetAverageUtilization: {{ $context.targetCPUUtilizationPercentage }}
  {{- end }}
  {{- if $context.targetMemoryUtilizationPercentage }}
    - type: Resource
      resource:
        name: memory
        targetAverageUtilization: {{ $context.targetMemoryUtilizationPercentage }}
  {{- end }}
{{- end }}
{{- end }}
