#!/bin/bash

function check_deployments() {
    deployments="$(kubectl get deployments -n $1 -o custom-columns=":metadata.name")"
    for deployment in $deployments; do
        kubectl rollout status deployment -n $1 $deployment
    done   
}

CERTS=$(pwd)/certs
kubectl create secret tls https-certificates \
    --cert="$CERTS/fullchain.pem" \
    --key="$CERTS/privkey.pem"

helm repo add gitlab https://charts.gitlab.io/
helm repo update
helm install gitlab gitlab/gitlab --kubeconfig /etc/rancher/k3s/k3s.yaml \
  --set global.hosts.domain=${DOMAIN} \
  --set certmanager.install=false \
  --set global.ingress.configureCertmanager=false \
  --set global.ingress.tls.secretName=https-certificates

check_deployments "default"

echo "Creating GitLab OAuth"
DBPASSWD=$(kubectl get secret gitlab-postgresql-password -o jsonpath='{.data.postgresql-postgres-password}' | base64 --decode)
SQL=$(sed "s+<clientId>+${CLIENT_ID}+g; s+<clientSecret>+${CLIENT_SECRET}+g; s+<domain>+${DOMAIN}+g" "gitlab/insertOauthApplication.sql")
kubectl exec -it gitlab-postgresql-0 -- bash -c "PGPASSWORD=$DBPASSWD psql -U postgres -d gitlabhq_production -c \"$SQL\""

kubectl get secret gitlab-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode > gitlab/initRootPasswd.txt

echo "GitLab initial root password stored in gitlab/initRootPasswd.txt"
echo "Gitlab is ready to use on gitlab.${DOMAIN}"
