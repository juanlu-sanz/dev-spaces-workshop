#!/bin/bash
echo "Waiting for CheCluster to become ready..."
until [ "$(oc get checluster devspaces -n openshift-devspaces -o jsonpath='{.status.chePhase}' 2>/dev/null)" = "Active" ]; do
  sleep 15
  echo "  Still waiting... ($(oc get checluster devspaces -n openshift-devspaces -o jsonpath='{.status.chePhase}' 2>/dev/null || echo 'Initializing'))"
done
echo "CheCluster is Active!"
