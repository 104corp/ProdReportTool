---
robots: noindex, nofollow
tags:  104se, web, 2024, application-review
---

# $app 應用程式十一月運行評估報告

> 撰文時間：Nov 29, 2024

> 作者：K8s 團隊

## GitOps 部署組態設定

設定檔在此：https://github.com/104corp/104se-apps/blob/master/$app/overlays/prod/prod.values.yaml

## Ingress／Egress 現況

若沒有需要調整之處，就是個 review。

https://github.com/104corp/k8s-gitops-infra-rancher/blob/main/apps/config/overlays/prod-env/prod-cluster/networking.k8s.io/networkpolicies/p-104se-$app/networkpolicy.yaml

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
