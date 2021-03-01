{{ if .Values.security }}
apiVersion: security.istio.io/v1beta1
kind: RequestAuthentication
metadata:
  name: {{ .Release.Name }}-request-authentication
spec:
  selector:
    matchLabels:
      app: {{.Values.appname}}
  jwtRules:
  -  issuer: {{ .Values.security.authenticationPolicy.issuer | quote }}
     jwksUri: {{ .Values.security.authenticationPolicy.jwksUri | quote }}
     forwardOriginalToken: true
{{ end }}