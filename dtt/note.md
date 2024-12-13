---
robots: noindex, nofollow
tags:  104dtt, web, 2024, application-review
---

# $app 應用程式十一月運行評估報告

> 撰文時間：Nov 18, 2024

> 作者：K8s 團隊

## GitOps 部署組態設定

設定檔在此：https://github.com/104corp/104dtt-apps/blob/master/$app/overlays/prod/prod.values.yaml

## Ingress／Egress 現況

若沒有需要調整之處，就是個 review。

https://github.com/104corp/k8s-gitops-infra-rancher/blob/main/apps/config/overlays/prod-env/prod-cluster/networking.k8s.io/networkpolicies/p-104dtt-$app/networkpolicy.yaml

## 系統資源狀況
以下是 30 天的數字。
> [監控數據](https://grafana.apps.k8s.104dc.com/k8s/clusters/c-m-vpjqbm2z/api/v1/namespaces/cattle-monitoring-system/services/http:rancher-monitoring-grafana:80/proxy/d/a164a7f0339f99e89cea5cb47e9be617/kubernetes-compute-resources-workload?orgId=1&from=now-7d&to=now&var-datasource=Prometheus&var-cluster=&var-namespace=p-104dtt-$app&var-type=deployment&var-workload=prod-prod-$app-web)

$cpu_output

$memory_output

### ingress 流量


| 名稱 | 一天流量 |
| --- | --- |
| prod-prod-$app    |  $count   |


[流量](http://k8s-kibana.104dc.com/app/discover#/?notFound=search&notFoundMessage=Could%20not%20locate%20that%20search%20(id:%203346b2ae-c01e-4180-9d21-9e397fce8fb3)&_g=(filters:!(),refreshInterval:(pause:!t,value:0),time:(from:now-7d,to:now))&_a=(columns:!(kubernetes.namespace_name,structured.apache.status,structured.nginx.vhost),filters:!(('$state':(store:appState),meta:(alias:!n,disabled:!f,index:bdd7ca00-09c0-11ed-aff1-ed02e57ef4e4,key:kubernetes.namespace_name,negate:!f,params:(query:ingress-nginx),type:phrase),query:(match_phrase:(kubernetes.namespace_name:ingress-nginx))),('$state':(store:appState),meta:(alias:!n,disabled:!f,index:bdd7ca00-09c0-11ed-aff1-ed02e57ef4e4,key:structured.nginx.vhost,negate:!f,params:(query:$app.104.com.tw),type:phrase),query:(match_phrase:(structured.nginx.vhost:$app.104.com.tw)))),index:bdd7ca00-09c0-11ed-aff1-ed02e57ef4e4,interval:auto,query:(language:kuery,query:''),sort:!(!(time,desc))))


[5xx 回覆](http://k8s-kibana.104dc.com/app/discover#/?notFound=search&notFoundMessage=Could%20not%20locate%20that%20search%20(id:%203346b2ae-c01e-4180-9d21-9e397fce8fb3)&_g=(filters:!(),refreshInterval:(pause:!t,value:0),time:(from:now-7d,to:now))&_a=(columns:!(kubernetes.namespace_name,structured.apache.status,structured.nginx.vhost),filters:!(('$state':(store:appState),meta:(alias:!n,disabled:!f,index:bdd7ca00-09c0-11ed-aff1-ed02e57ef4e4,key:kubernetes.namespace_name,negate:!f,params:(query:ingress-nginx),type:phrase),query:(match_phrase:(kubernetes.namespace_name:ingress-nginx))),('$state':(store:appState),meta:(alias:!n,disabled:!f,index:bdd7ca00-09c0-11ed-aff1-ed02e57ef4e4,key:structured.nginx.vhost,negate:!f,params:(query:$app.104.com.tw),type:phrase),query:(match_phrase:(structured.nginx.vhost:$app.104.com.tw))),('$state':(store:appState),meta:(alias:!n,disabled:!f,index:bdd7ca00-09c0-11ed-aff1-ed02e57ef4e4,key:structured.nginx.status,negate:!f,params:!('500','502','503','504'),type:phrases),query:(bool:(minimum_should_match:1,should:!((match_phrase:(structured.nginx.status:'500')),(match_phrase:(structured.nginx.status:'502')),(match_phrase:(structured.nginx.status:'503')),(match_phrase:(structured.nginx.status:'504'))))))),index:bdd7ca00-09c0-11ed-aff1-ed02e57ef4e4,interval:auto,query:(language:kuery,query:''),sort:!(!(time,desc))))

## 異常 Events

K8s 叢集並沒有發現特別需要關注的事件。

## 應用程式 Logs

目前未發現異常。

## 問題反應紀錄

:::warning
實際開會時，有提出問題再填寫即可。
:::