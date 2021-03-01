{{ if .Values.security }}
{{ if .Values.security.cookie }}
apiVersion: networking.istio.io/v1alpha3
kind: EnvoyFilter
metadata:
  name: {{ .Release.Name }}-envoy-filter

spec:
  workloadSelector:
    labels:
      app: {{.Values.appname}}
  configPatches:
    - applyTo: HTTP_FILTER
      match:
        listener:
          filterChain:
            filter:
              name: envoy.http_connection_manager
              subFilter:
                name: envoy.filters.http.jwt_authn
      patch:
        operation: INSERT_BEFORE
        value:
          name: envoy.lua
          config:
            inlineCode: |
              function stringSplit(inputstr, sep)
                if sep == nil then
                  sep = "%s"
                end
                local t={}
                for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                  print (str)
                  table.insert(t, str)
                end
                return t
              end

              function envoy_on_request(handle) 
                headers = handle:headers()
                streamInfo = handle:streamInfo()
                connection = handle:connection()
                dynamicMetadata = streamInfo:dynamicMetadata()
                dynamicMetadata:set("request_headers", "request_authority", headers:get(":authority"))
                dynamicMetadata:set("request_headers", "request_path", headers:get(":path"))

                proto = "http"
                if connection:ssl() ~= nil then
                  proto = "https"
                else
                  forwarded_proto = headers:get("x-forwarded-proto")
                  if forwarded_proto ~= nil then
                    proto = forwarded_proto
                  end
                end
                dynamicMetadata:set("request_headers", "proto", proto)

                cookieString = headers:get("cookie")
                if cookieString ~= nil then
                  splitCookieString = stringSplit(cookieString, ";")
                  
                  jwt = nil
                  for i, cookieItem in ipairs(splitCookieString) do
                    if string.find(cookieItem, "{{ .Values.security.filter.cookieName }}") ~= nil then
                      jwt = string.gsub(cookieItem, "{{ .Values.security.filter.cookieName }}=", "")
                    end
                  end

                  if jwt ~= nil then
                    auth = "Bearer " .. jwt
                    headers:replace("Authorization", auth)
                  end
                end
              end

              function envoy_on_response(handle) 
                headers = handle:headers()
                streamInfo = handle:streamInfo()
                dynamicMetadata = streamInfo:dynamicMetadata()
                requestData = dynamicMetadata:get("request_headers")
                headers:replace("x-auth-envoy-filter-passthrough", "yes")

                -- get auth config, if any
                authConfig = dynamicMetadata:get("auth_config")

                -- redirect if indicated in auth config and auth failed
                if headers:get(":status") == "401" or headers:get(":status") == "403" then
                  handle:logWarn("auth failed")
                  if authConfig ~= nil and authConfig["redirect"] and requestData ~= nil then
                    headers:replace(":status", "302")
                    redirect_url = "https".."://"..requestData["request_authority"]..requestData["request_path"]
                    headers:replace("location", "{{ .Values.security.filter.redirectURL }}"..redirect_url)
                    handle:logWarn("redirecting to: "..redirect_url)
                  end
                end
              end
{{ end }}
{{ end }}