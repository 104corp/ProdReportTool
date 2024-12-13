#!/bin/bash

# 生成的應用名稱
#apps=("ac-api" "bsignin" )  # 根據需要替換應用名稱
#apps=("b-hydra")
apps=("queue" "schedule")
# 標誌變量，用來控制標題的打印
printed_cpu=false
printed_memory=false

# 遍歷每個應用及對應的 CPU 和記憶體使用數據
for app in "${apps[@]}"; do
  export app
  # 打印應用名稱
  echo -e "\n## 應用名稱: $app"
  cpu_output=""
  # 使用 curl 查詢 Prometheus 並取得每個應用下每個 Pod 的 CPU 使用百分比
  export cpu_output=$(curl -s "http://prom.apps.k8s.104dc.com/api/v1/query?query=sum(node_namespace_pod_container%3Acontainer_cpu_usage_seconds_total%3Asum_irate%7Bnamespace%3D%22p-ac-$app%22%7D%20*%20on(namespace%2Cpod)%20group_left(workload%2Cworkload_type)%20namespace_workload_pod%3Akube_pod_owner%3Arelabel%7Bnamespace%3D%22p-ac-$app%22%2Cworkload%3D%22prod-prod-$app-web%22%2Cworkload_type%3D%22deployment%22%7D)%20by%20(pod)%20%2F%20sum(kube_pod_container_resource_limits%7Bjob%3D%22kube-state-metrics%22%2Cnamespace%3D%22p-ac-$app%22%2Cresource%3D%22cpu%22%7D%20*%20on(namespace%2Cpod)%20group_left(workload%2Cworkload_type)%20namespace_workload_pod%3Akube_pod_owner%3Arelabel%7Bnamespace%3D%22p-ac-$app%22%2Cworkload%3D%22prod-prod-$app-web%22%2Cworkload_type%3D%22deployment%22%7D)%20by%20(pod)" -Lk | \
  jq -r '.data.result[] | "\(.metric.pod) | \(.value[1] | tonumber * 100 | . * 100| floor / 100)"' | \
   while IFS=" | " read -r pod cpu; do
    # 如果 `cpu` 是空的，設置為 0
    cpu=${cpu:-0}
    if [ "$printed_cpu" = false ]; then
      # 打印 Markdown 表格的標題並加入變數
      echo "| Pod 名稱 | 一天 CPU 使用 (%) |"
      echo "| --- | --- |"
      printed_cpu=true
    fi
    # 將每行輸出加入變數
    echo "| $pod | $cpu(%) |"
  done)
  # 将结果输出到变量
  if [ -n "$cpu_output" ]; then
    echo -e "$cpu_output"
  else
    echo "No valid data found for $app"
  fi
  echo ""  # 插入空行分隔 CPU 和記憶體

  # 使用 curl 查詢 Prometheus 並取得每個應用下每個 Pod 的記憶體使用百分比
  export memory_output=$(curl -s "http://prom.apps.k8s.104dc.com/api/v1/query?query=sum(container_memory_working_set_bytes%7Bnamespace%3D%22p-ac-$app%22%7D%20*%20on(namespace%2Cpod)%20group_left(workload%2Cworkload_type)%20namespace_workload_pod%3Akube_pod_owner%3Arelabel%7Bnamespace%3D%22p-ac-$app%22%2Cworkload%3D%22prod-prod-$app-web%22%2Cworkload_type%3D%22deployment%22%7D)%20by%20(pod)%20%2F%20sum(kube_pod_container_resource_limits%7Bjob%3D%22kube-state-metrics%22%2Cnamespace%3D%22p-ac-$app%22%2Cresource%3D%22memory%22%7D%20*%20on(namespace%2Cpod)%20group_left(workload%2Cworkload_type)%20namespace_workload_pod%3Akube_pod_owner%3Arelabel%7Bnamespace%3D%22p-ac-$app%22%2Cworkload%3D%22prod-prod-$app-web%22%2Cworkload_type%3D%22deployment%22%7D)%20by%20(pod)" -Lk | \
  jq -r '.data.result[] | "\(.metric.pod) | \(.value[1] | tonumber * 100 | . * 100 | floor / 100)"' | \
  while IFS=" | " read -r pod memory; do
    # 第一次打印 Markdown 表格的標題
    if [ "$printed_memory" = false ]; then
      echo "| Pod 名稱 | 一天記憶體使用 (%) |"
      echo "| --- | --- |"
      printed_memory=true
    fi

    # 如果 `memory` 是空的，設置為 0
    memory=${memory:-0}
    # 打印表格行
    echo "| $pod | $memory(%) |"
  done
  )
  if [ -n "$memory_output" ]; then
    echo -e "$memory_output"
  else
    echo "No valid data found for $app"
  fi
  echo ""  # 插入空行分隔 CPU 和記憶體
  # 重置標誌變量，用於下一個應用的數據
  printed_cpu=false
  printed_memory=false
  export count=$(curl -s "http://prom.apps.k8s.104dc.com/api/v1/query?query=sum(increase(nginx_ingress_controller_requests%7Bcontroller_namespace%3D%22ingress-nginx%22%2Cexported_service%3D%22prod-prod-$app-web%22%7D%5B1d%5D))%20by%20(ingress)" -Lk | jq '.data.result[].value[1] | tonumber | floor')
  echo $count
  content=$(envsubst < note.md | jq -Rs .)
  curl -X POST "https://api.hackmd.io/v1/teams/104ContainerizationProject/notes" \
       -H "Authorization: Bearer 1EY2Y4U8SE637U1AFHCV3L9QHP6P7CDTHPKYNI6JRHJ1D7RA5B" \
       -H "Content-Type: application/json" \
       -d "{\"title\": \"$app 應用程式十月運行評估報告\", \"content\": $content}"
done