#!/bin/bash

function check_deployments() {
    deployments="$(kubectl get deployments -n $1 -o custom-columns=":metadata.name")"
    for deployment in $deployments; do
        kubectl rollout status deployment -n $1 $deployment
    done   
}

echo "Installing observability"

kubectl create namespace monitoring

kubectl create -f observability/kubernetes-prometheus/
kubectl apply -f observability/kube-state-metrics-configs/
kubectl create -f observability/kubernetes-alert-manager/
kubectl create -f observability/kubernetes-grafana/

check_deployments "monitoring"

echo "Premotheus endpoint: localhost:30000" 
echo "Alert manager: localhost:31000" 
echo "Grafana: localhost:32000" 