#!/bin/bash

function check_deployments() {
    deployments="$(kubectl get deployments -n $1 -o custom-columns=":metadata.name")"
    for deployment in $deployments; do
        kubectl rollout status deployment -n $1 $deployment
    done   
}

mount --make-shared /sys/fs/cgroup
mount --make-shared /proc
mount --make-shared /var/gitpod/workspaces

CERTS=$(pwd)/certs
kubectl create secret tls https-certificates \
    --cert="$CERTS/fullchain.pem" \
    --key="$CERTS/privkey.pem"

PROVIDER=$(sed "s+<clientId>+${CLIENT_ID}+g; s+<clientSecret>+${CLIENT_SECRET}+g; s+<domain>+${DOMAIN}+" "gitpod/gitlab-oauth.yaml")
kubectl create secret generic --from-literal=provider="$PROVIDER" gitlab-oauth

kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.7.1/cert-manager.yaml

curl -fsSLO https://github.com/gitpod-io/gitpod/releases/latest/download/gitpod-installer-linux-amd64
install -o root -g root gitpod-installer-linux-amd64 /usr/local/bin/gitpod-installer
sed "s+<domain>+${DOMAIN}+g" "gitpod/gitpod.config.yaml" > gitpod.config.yaml

check_deployments "cert-manager"
gitpod-installer render --config gitpod.config.yaml > gitpod.yaml

kubectl apply -f gitpod.yaml

check_deployments "default"

echo "Gitpod is ready to use on gitpod.${DOMAIN}"
