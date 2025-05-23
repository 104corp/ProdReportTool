#!/bin/bash

apps=(
  "app=ac-api ns=p-ac-ac-api domain=acapi.104dc.com region=idc,aws"
  "app=bsignin ns=p-ac-bsignin domain=api.bsignin.104.com.tw region=idc,aws"
  "app=b-hydra ns=p-ac-b-hydra domain=boidc.104.com.tw region=idc,aws"
#  "app=queue ns=p-ac-queue domain=unknown"
#  "app=schedule ns=p-ac-schedule domain=unknown"
)

title="應用程式 5月運行評估報告"
## For Linux
# create_time=$(date --iso-8601=seconds)
## For MacOS
create_time=$(date -u +'%Y-%m-%dT%H:%M:%S%z')
export title
export create_time

printed_cpu=false
printed_memory=false

for item in "${apps[@]}"; do
  for pair in $item; do
    key=${pair%=*}
    value=${pair#*=}

    case $key in
      "app") export app=$value ;;
      "domain") export domain=$value ;;
      "ns") export ns=$value ;;
      "region") export region=$value ;;
      *) export default=$value ;;
    esac
  done

  IFS=',' read -ra reg_list <<< "${region}"

  echo -e "\n## 應用名稱: $app"
  cpu_output=""
  memory_output=""
  ingress_output=""

  for reg in "${reg_list[@]}"; do
    case "$reg" in
      aws)
        prometheus_url="https://k8s-prom-eks21.104dc.com"
        cluster="eks21"
        ;;
      gcp)
        prometheus_url="https://k8s-prom-gke21.104dc.com"
        cluster="gke21"
        ;;
      *)
        #prometheus_url="https://k8s-prom-prod.104dc.com"
        prometheus_url="http://prom.apps.k8s.104dc.com"
        cluster="prod"
        ;;
    esac

    print_header=true
    cpu_result=$(curl -s "$prometheus_url/api/v1/query?query=sum(node_namespace_pod_container%3Acontainer_cpu_usage_seconds_total%3Asum_irate%7Bnamespace%3D%22p-ac-$app%22%7D%20*%20on(namespace%2Cpod)%20group_left(workload%2Cworkload_type)%20namespace_workload_pod%3Akube_pod_owner%3Arelabel%7Bnamespace%3D%22p-ac-$app%22%2Cworkload%3D%22prod-$cluster-$app-web%22%2Cworkload_type%3D%22deployment%22%7D)%20by%20(pod)%20%2F%20sum(kube_pod_container_resource_limits%7Bjob%3D%22kube-state-metrics%22%2Cnamespace%3D%22p-ac-$app%22%2Cresource%3D%22cpu%22%7D%20*%20on(namespace%2Cpod)%20group_left(workload%2Cworkload_type)%20namespace_workload_pod%3Akube_pod_owner%3Arelabel%7Bnamespace%3D%22p-ac-$app%22%2Cworkload%3D%22prod-$cluster-$app-web%22%2Cworkload_type%3D%22deployment%22%7D)%20by%20(pod)" -Lk | \
    jq -r '.data.result[] | "\(.metric.pod) | \(.value[1] | tonumber * 100 | . * 100| floor / 100)"' | \
    while IFS=" | " read -r pod cpu; do
      if [ "$print_header" = true ]; then
        echo "| Pod 名稱 | 一天 CPU 使用 (%) |"
        echo "| --- | --- |"
        print_header=false
      fi
      cpu=${cpu:-0}
      echo "| $pod | $cpu(%) |"
    done)

    echo ""
    if [ -n "$cpu_output" ]; then
      echo -e "$cpu_output"
    else
      echo "No valid data found for $app"
    fi

    print_header=true
    memory_result=$(curl -s "$prometheus_url/api/v1/query?query=sum(container_memory_working_set_bytes%7Bnamespace%3D%22p-ac-$app%22%7D%20*%20on(namespace%2Cpod)%20group_left(workload%2Cworkload_type)%20namespace_workload_pod%3Akube_pod_owner%3Arelabel%7Bnamespace%3D%22p-ac-$app%22%2Cworkload%3D%22prod-$cluster-$app-web%22%2Cworkload_type%3D%22deployment%22%7D)%20by%20(pod)%20%2F%20sum(kube_pod_container_resource_limits%7Bjob%3D%22kube-state-metrics%22%2Cnamespace%3D%22p-ac-$app%22%2Cresource%3D%22memory%22%7D%20*%20on(namespace%2Cpod)%20group_left(workload%2Cworkload_type)%20namespace_workload_pod%3Akube_pod_owner%3Arelabel%7Bnamespace%3D%22p-ac-$app%22%2Cworkload%3D%22prod-$cluster-$app-web%22%2Cworkload_type%3D%22deployment%22%7D)%20by%20(pod)" -Lk | \
    jq -r '.data.result[] | "\(.metric.pod) | \(.value[1] | tonumber * 100 | . * 100 | floor / 100)"' | \
    while IFS=" | " read -r pod memory; do
      if [ "$print_header" = true ]; then
        echo "| Pod 名稱 | 一天記憶體使用 (%) |"
        echo "| --- | --- |"
        print_header=false
      fi
      memory=${memory:-0}
      echo "| $pod | $memory(%) |"
    done)

    echo ""
    if [ -n "$memory_output" ]; then
      echo -e "$memory_output"
    else
      echo "No valid data found for $app"
    fi

    ingress_count=$(curl -s "$prometheus_url/api/v1/query?query=sum(increase(nginx_ingress_controller_requests%7Bcontroller_namespace%3D%22ingress-nginx%22%2Cexported_service%3D%22prod-$cluster-$app-web%22%7D%5B1d%5D))%20by%20(ingress)" -Lk | jq '.data.result[].value[1] | tonumber | floor')
    ingress_result=$(echo "| Ingress 名稱 | 一天流量 |"
      echo "| --- | --- |"
      echo "| prod-$cluster-$app | $ingress_count |"
    )

    cpu_output+=$cpu_result
    memory_output+=$memory_result
    ingress_output+=$ingress_result
  done

  export cpu_output
  export memory_output
  export ingress_output

  content=$(envsubst < note.md | jq -Rs .)
  curl -X POST "https://api.hackmd.io/v1/teams/104ContainerizationProject/notes" \
       -H "Authorization: Bearer 1EY2Y4U8SE637U1AFHCV3L9QHP6P7CDTHPKYNI6JRHJ1D7RA5B" \
       -H "Content-Type: application/json" \
       -d "{\"title\": \"$app $title\", \"content\": $content}"
done
