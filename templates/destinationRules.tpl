{{ if .Values.stickySession }}
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: {{ .Release.Name }}-destination-rule
spec:
  host: {{ .Values.appname }}
  trafficPolicy:
    loadBalancer:
      consistentHash:
        httpCookie:
          name: {{ .Release.Name | upper }}-IID
          path: {{ .Values.stickySession.path | default "/" }}
          ttl: {{ .Values.stickySession.ttl | default "300s" }}
{{ end }}