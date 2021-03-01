{{ if .Values.ingress}}
{{ if .Values.istio.ingress.customVirtualService}}
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: {{.Values.appname}}
spec:
{{.Values.istio.ingress.customVirtualService | indent 2}}
{{ else }}
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: {{.Values.appname}}
spec:
  gateways:
  - {{.Values.appname}}
  {{ include "host" . }}
  http:
  - route:
    - destination:
        host: {{.Values.appname}}
        port:
          number: {{ .Values.port | default "8080" }}
{{- if .Values.istio.virtualService.corsPolicy }}
    corsPolicy:
{{ .Values.istio.virtualService.corsPolicy | indent 6 }}
{{- end -}}
{{- if .Values.istio.virtualService.matchRule }}
    match:
{{ .Values.istio.virtualService.matchRule | indent 6 }}
{{- if .Values.istio.virtualService.rewrite }}
    rewrite: 
{{ .Values.istio.virtualService.rewrite | indent 6 }}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}