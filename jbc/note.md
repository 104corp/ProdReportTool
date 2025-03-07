---
robots: noindex, nofollow
tags:  104jbc, web, 2025, application-review
---

# $app $title

> 撰文時間：$create_time

> 作者：K8s 團隊

## GitOps 部署組態設定

設定檔在此：https://github.com/104corp/104jbc-apps/blob/master/$app/overlays/prod/prod.values.yaml

## Ingress／Egress 現況

若沒有需要調整之處，就是個 review。

https://github.com/104corp/k8s-gitops-infra-rancher/blob/main/apps/config/overlays/prod-env/prod-cluster/networking.k8s.io/networkpolicies/p-104jbc-$app/networkpolicy.yaml

## 系統資源狀況
以下是 30 天的數字。
> [監控數據](https://grafana.apps.k8s.104dc.com/k8s/clusters/c-m-vpjqbm2z/api/v1/namespaces/cattle-monitoring-system/services/http:rancher-monitoring-grafana:80/proxy/d/a164a7f0339f99e89cea5cb47e9be617/kubernetes-compute-resources-workload?orgId=1&from=now-7d&to=now&var-datasource=Prometheus&var-cluster=&var-namespace=p-104jbc-$app&var-type=deployment&var-workload=prod-prod-$app-web)

$cpu_output

$memory_output

### ingress 流量


| 名稱 | 一天流量 |
| --- | --- |
| prod-prod-$app    |  $count   |

## 異常 Events

K8s 叢集並沒有發現特別需要關注的事件。

## 應用程式 Logs

目前未發現異常。

## 問題反應紀錄

:::warning
實際開會時，有提出問題再填寫即可。
:::
