# docker-duoauthproxy
 Duo's authentication proxy running in docker.

## Example Usage

```bash
docker run -d -p 1812:1812/udp \
  --name=duo \
  -e DUO_AD_HOST="domain.com" \
  -e DUO_AD_USER="DuoUser" \
  -e DUO_AD_PASSWORD="yourpassword" \
  -e DUO_AD_SEARCH_DN="CN=Users,DC=domain,DC=com" \
  -e DUO_INTEGRATION_KEY="yourintegrationkey" \
  -e DUO_SECRET_KEY="yoursecretkey" \
  -e DUO_API_HOSTNAME="api-yourhostname.duosecurity.com" \
  -e DUO_RADIUS_SECRET="yoursharedsecret" \
  -e DUO_FAILMODE="secure" \
  -e DUO_PORT="1812" \
  alphabet5/duoauthproxy
```

This generates a generic configuration based on the parameters you specified. 

```text
[ad_client]
host=domain.com
service_account_username=DuoUser
service_account_password=yourpassword
search_dn=CN=Users,DC=domain,DC=com

[radius_server_auto]
ikey=yourintegrationkey
skey=yoursecretkey
api_host=api-yourhostname.duosecurity.com
radius_ip_1=0.0.0.0/0
radius_secret_1=yoursharedsecret
failmode=secure
client=ad_client
port=1812
```

You will probably want to generate a custom configuration file instead.

```text
docker run -d -p 1812:1812/udp \
  --name=duoauthproxy \
  -v /your/path/authproxy.cfg:/opt/duoauthproxy/conf/authproxy.cfg \
  alphabet5/duoauthproxy
```


This is also usable in kubernetes. Here is an example configuration:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: duo-auth-proxy-service
  namespace: default
spec:
  type: LoadBalancer
  loadBalancerIP: 192.168.1.155
  ports:
    - name: radius
      protocol: UDP
      port: 1812
      targetPort: 1812
  selector:
    app: duo-auth-proxy
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: duo-auth-proxy-configmap
  namespace: default
data:
  authproxy.cfg: |
    [main]
    log_stdout=true

    [ad_client]
    host=domain.com
    service_account_username=DuoUser
    service_account_password=yourpassword
    search_dn=CN=Users,DC=domain,DC=com

    [radius_server_auto]
    ikey=yourintegrationkey
    skey=yoursecretkey
    api_host=api-yourhostname.duosecurity.com
    radius_ip_1=0.0.0.0/0
    radius_secret_1=yoursharedsecret
    failmode=secure
    client=ad_client
    port=1812
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: duo-auth-proxy-deployment
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: duo-auth-proxy
  template:
    metadata:
      labels:
        app: duo-auth-proxy
    spec:
      containers:
        - name: duo-auth-proxy-container-name
          image: alphabet5/duoauthproxy
          imagePullPolicy: Always
          ports:
            - containerPort: 1812
          volumeMounts:
            - name: duo-auth-proxy-volume
              mountPath: "/etc/duoauthproxy/authproxy.cfg"
              subPath: "authproxy.cfg"
      volumes:
        - name: duo-auth-proxy-volume
          configMap:
            name: duo-auth-proxy-configmap
```