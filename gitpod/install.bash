#!/bin/bash

function check_deployments() {
    deployments="$(k3s kubectl get deployments -n $1 -o custom-columns=":metadata.name")"
    for deployment in $deployments; do
        k3s kubectl rollout status deployment -n $1 $deployment
    done   
}

mount --make-shared /sys/fs/cgroup
mount --make-shared /proc
mount --make-shared /var/gitpod/workspaces

CERTS=$(pwd)/certs
k3s kubectl create secret tls https-certificates \
    --cert="$CERTS/fullchain.pem" \
    --key="$CERTS/privkey.pem"

k3s kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.7.1/cert-manager.yaml
sed "s+<domain>+${DOMAIN}+g" "gitpod/gitpod.config.yaml" > gitpod.config.yaml

if [ "$ENABLE_AUTH_PROVIDER" = "true" ]
then 
    cat gitpod/gitpod.authProvider.config.yaml >> gitpod.config.yaml
    PROVIDER=$(sed "s+<clientId>+${CLIENT_ID}+g; s+<clientSecret>+${CLIENT_SECRET}+g; s+<domain>+${DOMAIN}+" "gitpod/gitlab-oauth.yaml")
    k3s kubectl create secret generic --from-literal=provider="$PROVIDER" gitlab-oauth
fi

check_deployments "cert-manager"
gitpod-installer render --config gitpod.config.yaml > gitpod.yaml

k3s kubectl apply -f gitpod.yaml --validate=false

check_deployments "default"

echo "Gitpod is ready to use on gitpod.${DOMAIN}"
