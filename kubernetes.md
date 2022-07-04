# Kubernetes Quick Reference

This Kubernetes quick reference guide is a compilation of useful commands and lessons learnt from my experiences with Kubernetes at work. Note that some commands such as `gcloud` are specific to Google Kubernetes Engine (GKE). 

## Table of Contents
- [Common Commands](#common-commands)
- [Autoscaling](#autoscaling)

## Common Commands

1. You can create a Google Kubernetes Engine (GKE) cluster using CLI or using Google Cloud Console.
    
    To create a GKE cluster from CLI:
    ```
    gcloud container clusters create <CLUSTER NAME> --region <REGION>
    ```

    If you created the GKE cluster from Google Cloud Console, you'll need to get the cluster credentials as shown below in order to run subsequent `kubectl` commands:
    ```
    gcloud container clusters get-credentials <CLUSTER_NAME> --region=<REGION>
    ```

    Check that the cluster has been created and nodes are ready.
    ```
    kubectl get nodes
    ```

2. Next, to apply a deployment:
    ```
    kubectl apply -f deployment.yaml
    kubectl get deployments
    kubectl get pods
    ```
    It usually takes a few minutes to create a deployment, and the `kubectl get` commands will show the status.

3. Subsequently, to apply a service:
    ```
    kubectl apply -f service.yaml
    kubectl get services
    ```

4. To help with troubleshooting:
    ```
    kubectl get pods
    kubectl logs <POD NAME>
    kubectl exec -ti <POD NAME> -- bash
    kubectl describe services <SERVICE NAME>
    ```

5. To update the deployment:
    ```
    kubectl get deployments
    kubectl set image deployments/<DEPLOYMENT NAME> <CONTAINER NAME>=<IMAGE NAME>:<IMAGE VERSION>
    kubectl rollout status deployments/<DEPLOYMENT NAME>
    # To undo update:
    kubectl rollout undo deployments/<DEPLOYMENT NAME>
    ```

## Autoscaling

