#!/bin/bash

apps=(
  "alertmanager-adapter"
  "alertmanager-gateway"
  "alertmanager-sender"
  "apim-java-sdk-test"
  "apim2-auth"
  "apim2-auth-job"
  "apim2-gw"
  "apim2-jwks"
  "apim2-mesh-authz"
  "apim2-stress"
  "auto-test-platform"
  "crypto-client"
  "crypto-probe"
  "crypto-server"
  "devmaster-api"
  "k8s-tutorial-sample"
  "oidc-bapp-agent"
  "oidc-ehrweb-agent"
  "oidc-server"
  "oidc-validator"
  "oidc-vip-agent"
  "rm-104-web"
  "sms2-checker"
  "sms2-cms"
  "sms2-receiver"
  "sms2-sender"
  "sysblog"
)

gke21=(
  "mvs"
)

printed_cpu=false
printed_memory=false

generate_report_no_web(){
  local app=$1
  local cpu_output=""
  export app
  echo -e "\n## 應用名稱: $app"
  cpu_output=""
  export cpu_output=$(curl -s "http://prom.apps.k8s.104dc.com/api/v1/query?query=sum(node_namespace_pod_container%3Acontainer_cpu_usage_seconds_total%3Asum_irate%7Bnamespace%3D%22p-devops-$app%22%7D%20*%20on(namespace%2Cpod)%20group_left(workload%2Cworkload_type)%20namespace_workload_pod%3Akube_pod_owner%3Arelabel%7Bnamespace%3D%22p-devops-$app%22%2Cworkload%3D%22prod-prod-$app-web%22%2Cworkload_type%3D%22deployment%22%7D)%20by%20(pod)%20%2F%20sum(kube_pod_container_resource_limits%7Bjob%3D%22kube-state-metrics%22%2Cnamespace%3D%22p-devops-$app%22%2Cresource%3D%22cpu%22%7D%20*%20on(namespace%2Cpod)%20group_left(workload%2Cworkload_type)%20namespace_workload_pod%3Akube_pod_owner%3Arelabel%7Bnamespace%3D%22p-devops-$app%22%2Cworkload%3D%22prod-prod-$app-web%22%2Cworkload_type%3D%22deployment%22%7D)%20by%20(pod)" -Lk | \
  jq -r '.data.result[] | "\(.metric.pod) | \(.value[1] | tonumber * 100 | . * 100| floor / 100)"' | \
  while IFS=" | " read -r pod cpu; do
    cpu=${cpu:-0}
    if [ "$printed_cpu" = false ]; then
      echo "| Pod 名稱 | 一天 CPU 使用 (%) |"
      echo "| --- | --- |"
      printed_cpu=true
    fi
    echo "| $pod | $cpu(%) |"
  done
  )
  if [ -n "$cpu_output" ]; then
    echo -e "$cpu_output"
  else
    echo "No valid data found for $app"
  fi
  echo ""

  local memory_output=""
  memory_output=$(curl -s "http://prom.apps.k8s.104dc.com/api/v1/query?query=sum(container_memory_working_set_bytes%7Bnamespace%3D%22p-devops-$app%22%7D%20*%20on(namespace%2Cpod)%20group_left(workload%2Cworkload_type)%20namespace_workload_pod%3Akube_pod_owner%3Arelabel%7Bnamespace%3D%22p-devops-$app%22%2Cworkload%3D%22prod-prod-$app%22%2Cworkload_type%3D%22deployment%22%7D)%20by%20(pod)%20%2F%20sum(kube_pod_container_resource_limits%7Bjob%3D%22kube-state-metrics%22%2Cnamespace%3D%22p-devops-$app%22%2Cresource%3D%22memory%22%7D%20*%20on(namespace%2Cpod)%20group_left(workload%2Cworkload_type)%20namespace_workload_pod%3Akube_pod_owner%3Arelabel%7Bnamespace%3D%22p-devops-$app%22%2Cworkload%3D%22prod-prod-$app%22%2Cworkload_type%3D%22deployment%22%7D)%20by%20(pod)" -Lk | \
    jq -r '.data.result[] | "\(.metric.pod) | \(.value[1] | tonumber * 100 | . * 100 | floor / 100)"' | \
    while IFS=" | " read -r pod memory; do
      memory=${memory:-0}
      if [ "$printed_memory" = false ]; then
        echo "| Pod 名稱 | 一天記憶體使用 (%) |"
        echo "| --- | --- |"
        printed_memory=true
      fi
      echo "| $pod | $memory(%) |"
    done)
  if [ -n "$memory_output" ]; then
    echo -e "$memory_output"
  else
    echo "No valid data found for $app"
  fi
  echo ""
  local count=$(curl -s "http://prom.apps.k8s.104dc.com/api/v1/query?query=sum(increase(nginx_ingress_controller_requests%7Bcontroller_namespace%3D%22ingress-nginx%22%2Cexported_service%3D%22prod-prod-$app%22%7D%5B1d%5D))%20by%20(ingress)" -Lk | jq '.data.result[].value[1] | tonumber | floor')
  echo $count
  local content=$(envsubst < note.md | jq -Rs .)
  curl -X POST "https://api.hackmd.io/v1/teams/104ContainerizationProject/notes" \
       -H "Authorization: Bearer 1EY2Y4U8SE637U1AFHCV3L9QHP6P7CDTHPKYNI6JRHJ1D7RA5B" \
       -H "Content-Type: application/json" \
       -d "{\"title\": \"$app 應用程式十一月運行評估報告\", \"content\": $content}"
  }


generate_report() {
  cpu_output=""
  local app=$1
  local cpu_output=""
  export app
  echo -e "\n## 應用名稱: $app"

    export cpu_output=$(curl -s "http://prom.apps.k8s.104dc.com/api/v1/query?query=sum(node_namespace_pod_container%3Acontainer_cpu_usage_seconds_total%3Asum_irate%7Bnamespace%3D%22p-devops-$app%22%7D%20*%20on(namespace%2Cpod)%20group_left(workload%2Cworkload_type)%20namespace_workload_pod%3Akube_pod_owner%3Arelabel%7Bnamespace%3D%22p-devops-$app%22%2Cworkload%3D%22prod-prod-$app-web%22%2Cworkload_type%3D%22deployment%22%7D)%20by%20(pod)%20%2F%20sum(kube_pod_container_resource_limits%7Bjob%3D%22kube-state-metrics%22%2Cnamespace%3D%22p-devops-$app%22%2Cresource%3D%22cpu%22%7D%20*%20on(namespace%2Cpod)%20group_left(workload%2Cworkload_type)%20namespace_workload_pod%3Akube_pod_owner%3Arelabel%7Bnamespace%3D%22p-devops-$app%22%2Cworkload%3D%22prod-prod-$app-web%22%2Cworkload_type%3D%22deployment%22%7D)%20by%20(pod)" -Lk | \
    jq -r '.data.result[] | "\(.metric.pod) | \(.value[1] | tonumber * 100 | . * 100| floor / 100)"' | \
    while IFS=" | " read -r pod cpu; do

      cpu=${cpu:-0}
      if [ "$printed_cpu" = false ]; then
        echo "| Pod 名稱 | 一天 CPU 使用 (%) |"
        echo "| --- | --- |"
        printed_cpu=true
      fi
      echo "| $pod | $cpu(%) |"
    done)
    if [ -n "$cpu_output" ]; then
      echo -e "$cpu_output"
    else
      echo "No valid data found for $app"
    fi
    echo ""

    export memory_output=$(curl -s "http://prom.apps.k8s.104dc.com/api/v1/query?query=sum(container_memory_working_set_bytes%7Bnamespace%3D%22p-devops-$app%22%7D%20*%20on(namespace%2Cpod)%20group_left(workload%2Cworkload_type)%20namespace_workload_pod%3Akube_pod_owner%3Arelabel%7Bnamespace%3D%22p-devops-$app%22%2Cworkload%3D%22prod-prod-$app-web%22%2Cworkload_type%3D%22deployment%22%7D)%20by%20(pod)%20%2F%20sum(kube_pod_container_resource_limits%7Bjob%3D%22kube-state-metrics%22%2Cnamespace%3D%22p-devops-$app%22%2Cresource%3D%22memory%22%7D%20*%20on(namespace%2Cpod)%20group_left(workload%2Cworkload_type)%20namespace_workload_pod%3Akube_pod_owner%3Arelabel%7Bnamespace%3D%22p-devops-$app%22%2Cworkload%3D%22prod-prod-$app-web%22%2Cworkload_type%3D%22deployment%22%7D)%20by%20(pod)" -Lk | \
    jq -r '.data.result[] | "\(.metric.pod) | \(.value[1] | tonumber * 100 | . * 100 | floor / 100)"' | \
    while IFS=" | " read -r pod memory; do
      if [ "$printed_memory" = false ]; then
        echo "| Pod 名稱 | 一天記憶體使用 (%) |"
        echo "| --- | --- |"
        printed_memory=true
      fi

      memory=${memory:-0}
      echo "| $pod | $memory(%) |"
    done
    )
    if [ -n "$memory_output" ]; then
      echo -e "$memory_output"
    else
      echo "No valid data found for $app"
    fi
    echo ""
    printed_cpu=false
    printed_memory=false
    export count=$(curl -s "http://prom.apps.k8s.104dc.com/api/v1/query?query=sum(increase(nginx_ingress_controller_requests%7Bcontroller_namespace%3D%22ingress-nginx%22%2Cexported_service%3D%22prod-prod-$app-web%22%7D%5B1d%5D))%20by%20(ingress)" -Lk | jq '.data.result[].value[1] | tonumber | floor')
    echo $count
    content=$(envsubst < note.md | jq -Rs .)
    curl -X POST "https://api.hackmd.io/v1/teams/104ContainerizationProject/notes" \
         -H "Authorization: Bearer 1EY2Y4U8SE637U1AFHCV3L9QHP6P7CDTHPKYNI6JRHJ1D7RA5B" \
         -H "Content-Type: application/json" \
         -d "{\"title\": \"$app 應用程式十一月運行評估報告\", \"content\": $content}"
}

for app in "${apps[@]}"; do
  generate_report_no_web "$app"
done

for app in "${gke21[@]}"; do
  generate_report "$app"
done