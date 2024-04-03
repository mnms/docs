# Deploy LightningDB and API Server

## 1. Kubernetes manifest github
```
$ git clone https://github.com/mnms/metavision2_k8s_manifests
```

## 2. Install LightningDB v1
- Install ltdb-operator
```
$ cd ltdb-operator
$ kubectl create -f ltdb-operator-controller-manager.yaml
```

- deploy LightningDB with CRD
```
$ cd ltdb
$ kubectl create -f ltdb.yaml -n {namespace}
```

- 참조
    - size / storageClass / maxMemory 등 통해 클러스터 설정 조정
    - AOF/RDB 는 디폴트 옵션 on
    - fs 내 redis/rocksdb mount 위치
        - /tmp-redis_rocksdb_integration_0: redis's aof/rdb, conf
        - /tmp-redis_rocksdb_integration_1: rocksdb's sst/wal
    - rdb 명시적 명령: bash flashbase cli-all bgsave
    - on-premise 경우, 아래 URL 처럼 system 튜닝이 들어감. k8s 운영 상황에서도 튜닝 여부 확인 필요
        - https://docs.lightningdb.io/get-started-with-scratch/
    - 삭제
        - STS 는 PVC 가 자동으로 삭제되지 않으므로 완전히 삭제하려면 해당 PVC 수동 삭제 필요
```
$ kubectl delete -f ltdb.yaml
or
$ kubectl delete ltdb ltdb -n metavision
$ for i in {0..39}; do kubectl delete pvc "ltdb-data-logging-ltdb-$i" -n metavision; done
$ for i in {0..39}; do kubectl delete pvc "ltdb-data-ltdb-$i" -n metavision; done
```


## 3. Install LightningDB v2 / Thunderquery

```
$ cd ltdbv2
$ kubectl create -f ltdbv2-all-in-one.yaml
$ kubectl -n metavision exec -it ltdbv2-0 -- redis-cli --cluster-yes --cluster create `kubectl -n metavision get po -o wide -l app=ltdbv2 | grep ltdbv2 | awk '{print $6":6379"}' | tr '\n' ' '`
```

- 참조
    - Operator 없이 수동 설치
    - namespace 가 metavision 으로 명시적으로 되어 있음. namespace 를 바꾸고 싶으면 해당 부분 수정
    - 최신 버전은 ann 을 사용한다 하더라도 maxmemory-policy 를 noeviction 으로 바꿀 필요 없이 eviction rule 정상 작동하면서 사용하면 됨
    - AOF/RDB 는 디폴트 옵션 on
    - fs 내 redis/rocksdb mount 위치
        - /tmp/redis: redis's aof/rdb, conf, rocksdb's sst/wal
    - rdb 명시적 명령: flashbase cli-all bgrewriteaof
    - 삭제
        - STS 는 PVC 가 자동으로 삭제되지 않으므로 완전히 삭제하려면 해당 PVC 수동 삭제 필요
```
$ kubectl delete -f ltdbv2-all-in-one.yaml
$ for i in {0..99}; do kubectl delete pvc "ltdbv2-pvc-ltdbv2-$i" -n metavision; done
```


## 4. Install ltdb-http v1
```
$ cd ltdb-http
$ ls -alh
total 32
drwxr-xr-x   6 1111462  1437349805   192B  8 31 17:53 .
drwxr-xr-x  11 1111462  1437349805   352B  8 31 17:54 ..
-rw-r--r--   1 1111462  1437349805   1.3K  8 31 17:53 ltdb-http-configmap.yaml
-rw-r--r--   1 1111462  1437349805   1.5K  8 31 17:53 ltdb-http.yaml
-rw-r--r--   1 1111462  1437349805   259B  8 31 17:53 pvc.yaml
-rw-r--r--   1 1111462  1437349805   342B  8 31 17:53 spark-rbac.yaml
```

- ltdb-http.yaml만 가장 나중에 apply
```
kubectl -n metavision apply -f ltdb-http-configmap.yaml
kubectl -n metavision apply -f spark-rbac.yaml
kubectl -n metavision apply -f pvc.yaml

kubectl -n metavision apply -f ltdb-http.yaml  // 가장 나중에...
```

## 5. Install ltdb-http v2
- 참조: https://www.notion.so/ltdb/LTDB-HTTP-V2-0-K8S-b47ad5741e9a43668c7bee4d40e1616e?pvs=4
- 아이스버그 사용 안할 시, ltdb-postgresql.yaml 제외 가능
- namespace 가 metavision 으로 명시적으로 되어 있음. namespace 를 바꾸고 싶으면 해당 부분 수정
- s3 기능을 사용하고 싶으면, app/s3-secret.yaml 설치 필요 (분당 9층 TB에는 이미 설치 됨)
- s3 region 은 기본값으로 ap-northeast-2 설정 됨

```
$ cd ltdbv2-http
$ kubectl create -f ltdb-http-configmap.yaml
$ kubectl create -f ltdb-http.yaml
$ kubectl create -f ltdbv2-http-vs.yaml
```

- 삭제
```
$ kubectl delete -f ltdbv2-http-vs.yaml
$ kubectl delete -f ltdb-http.yaml
$ kubectl delete -f ltdb-http-configmap.yaml
```


## 6. Install ltdb-http v2 CXL-CMS
```
$ cd hynix
$ kubectl create -f ltdbv2.yaml
$ kubectl -n hynix exec -it ltdbv2-0 -- redis-cli --cluster-yes --cluster create `kubectl -n hynix get po -o wide -l app=ltdbv2 | grep ltdbv2 | awk '{print $6":6379"}' | tr '\n' ' '`
$ kubectl create -f thunderquery.yaml
$ kubectl create -f ltdbv2-http.yaml
$ kubectl create -f istio-ingress.yaml
```

- 참조
    - cxl-cms 에서 추가 된 config 값은 아래 같으며, cxl-cms dev 용 CSI 드라이버가 없기 때문에 STS 에서 수동으로 pod 개수 및 Node Affinity 설정 하면서 테스트 해야 함
    - dax-device-name /dev/xxx, cms-device-name /dev/yyy 형태로 잡아짐

```
$ vi ltdbv2.yaml
...
cms-enabled no
dax-device-name no
cms-device-name no
```

- 삭제
    - STS 는 PVC 가 자동으로 삭제되지 않으므로 완전히 삭제하려면 해당 PVC 수동 삭제 필요
```
$ cd hynix
$ kubectl delete -f ltdbv2-http.yaml
$ kubectl delete -f thunderquery.yaml
$ kubectl delete -f ltdbv2.yaml
for i in {0..9}; do kubectl delete pvc "ltdbv2-pvc-ltdbv2-$i" -n hynix; done
$ kubectl delete -f istio-ingress.yaml
```