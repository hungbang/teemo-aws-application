{{/* Return hostname */}}
{{- define "host" -}}
hosts: 
{{- if .Values.host }}
    - {{ .Values.host }}
{{- else }}
{{- if .Values.hosts }}
    {{- range $host := .Values.hosts }}
    - {{ $host }}
    {{- end }}
{{- else }}
{{- if eq .Values.environment "prd" }}
    - {{ printf "%s.apps.app.teemo.ai" .Values.appname }}
{{- else }}
    - {{ printf "%s.apps.app%s.teemo.ai" .Values.appname .Values.environment }}
{{- end }}
{{- end }}
{{- end }}
{{- end -}}

{{/* Generate config map if values file has a configs section */}}
{{ define "teemo-chart.configmap" }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{.Values.appname}}
data:
{{- if .Values.mountConfigmap }}
  application-{{.Values.environment}}.yaml: |-
{{- else }}
  application.yaml: |-
{{ end }}
    {{- .Values.configs | nindent 4}}
{{ end }}

{{/* Generate secrets if values file has a secrets section */}}
{{ define "teemo-chart.secrets" }}
apiVersion: v1
kind: Secret
metadata:
  name: {{.Values.appname}}
data:
  application.yaml: |- 
    {{.Values.secrets | b64enc}}
{{ end }}

{{/* Generate gateway if values file has a ingress flag */}}
{{ define "teemo-chart.gateway" }}
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: {{.Values.appname}}
spec:
  selector:
    {{ .Values.istio.ingress.selector }}
  servers:
  - {{ include "host" .}}
    port:
     name: http
     number: 80
     protocol: HTTP
{{ end }}
