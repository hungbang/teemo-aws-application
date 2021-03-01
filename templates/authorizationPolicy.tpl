{{ if .Values.security }}
{{ if .Values.security.rules }}
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: {{.Values.appname}}-authorization-policy
spec:
  selector:
    matchLabels:
      app: {{.Values.appname}}
  action: ALLOW
  rules:
    {{- range .Values.security.rules }}
    - to:
        - operation:
            paths:
              - {{ .path }}
      when:
        - key: request.auth.claims[railincPermissions]
          values: 
            {{- range .roles }}
            - {{ . | quote }}
            {{- end }}
    {{- end }}
{{ end }}
{{ end }}