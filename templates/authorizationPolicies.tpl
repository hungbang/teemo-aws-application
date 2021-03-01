{{ if .Values.security }}
{{ if .Values.security.policies }}
{{ .Values.security.policies }}
{{ end }}
{{ end }}