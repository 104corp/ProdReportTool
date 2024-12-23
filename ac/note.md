---
robots: noindex, nofollow
tags:  ac, web, 2024, application-review
---

# $app $title

> 撰文時間：$create_time

> 作者：K8s 團隊

## GitOps 部署組態設定

設定檔在此：https://github.com/104corp/ac-k8s/blob/master/$app/overlays/prod/prod.values.yaml

## Ingress／Egress 現況

若沒有需要調整之處，就是個 review。

https://github.com/104corp/k8s-gitops-infra-rancher/blob/main/apps/config/overlays/prod-env/prod-cluster/networking.k8s.io/networkpolicies/p-ac-$app/networkpolicy.yaml

## 系統資源狀況
以下是 30 天的數字。
> [監控數據](https://grafana.apps.k8s.104dc.com/k8s/clusters/c-m-vpjqbm2z/api/v1/namespaces/cattle-monitoring-system/services/http:rancher-monitoring-grafana:80/proxy/d/a164a7f0339f99e89cea5cb47e9be617/kubernetes-compute-resources-workload?orgId=1&from=now-7d&to=now&var-datasource=Prometheus&var-cluster=&var-namespace=p-ac-$app&var-type=deployment&var-workload=prod-prod-$app-web)

> [監控數據](http://grafana.sys.104dc.com/d/ae79ll1qrwwlca/k8s-app-monthly-report?orgId=1&var-datasource=deOn58QVk&var-cluster=&var-namespace=$ns&var-type=deployment&var-ingress_vhost=$domain&from=now-7d&to=now)

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
