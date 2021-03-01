{{- if .Values.security }}
{{- if .Values.security.clientid }}
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: {{.Values.appname}}-authorization-policy-deny
spec:
  selector:
    matchLabels:
      app: {{.Values.appname}}
  action: DENY
  rules:
    - when:
        - key: request.auth.claims[cid]
          notValues: {{ .Values.security.clientid }}
{{- end }}          
{{- end }}