{{/* vim: set filetype=mustache: */}}

{{/*
Create a base ingress function
*/}}
{{- define "common-lib.ingress.create" -}}
{{- if .Values.ingress.enabled -}}
{{- $fullName := include "common-lib.names.fullname" . -}}
apiVersion: {{ include "common-lib.capabilities.ingress.apiVersion" . }}
kind: Ingress
metadata:
  name: {{ $fullName }}
  labels:
    {{- include "common-lib.labels.labels" . | nindent 4 }}
  {{- with .Values.ingress.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  ingressClassName: nginx
  {{- if .Values.ingress.tls }}
  tls:
    {{- range .Values.ingress.tls }}
    - hosts:
        {{- range .hosts }}
        - {{ . | quote }}
        {{- end }}
      secretName: {{ .secretName }}
    {{- end }}
  {{- end }}
  rules:
    {{- range .Values.ingress.hosts }}
    - host: {{ .host | quote }}
      http:
        paths:
          {{- range .paths }}
          - pathType: Prefix
            path: {{ .path }}
            backend:
              service:
                name: {{ $fullName }}
                port:
                  number: {{ .svcPort }}
          {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
