# Build 'LightningDB' (Admin Only)

## 1. LightningDB Source Code(Private Repository)
```
$ git clone https://github.com/mnms/LightningDB
```

## 2. Build
### - v1
- Branch: release/flashbase_v1.4.3
- Commands:
  
```
$ ./build.sh compile
```
```
$ cd nvkvs
$ docker build . -t harbor.k8s.lightningdb/ltdb/nvkvs:v1.4.3
$ docker push harbor.k8s.lightningdb/ltdb/nvkvs:v1.4.3
```

### - v2
- Branch: release/flashbase_v2.0.0
- Commands:
```
$ ./build.sh compile debug
```
```
$ cd nvkvs
$ docker build . -t harbor.k8s.lightningdb/ltdb/nvkvs:v2.0.0
$ docker push harbor.k8s.lightningdb/ltdb/nvkvs:v2.0.0
```

### - v2 CXL-CMS
- Branch: cms-integration
- Prerequisite(install daxctl): 

```
$ yum install -y kmod-devel rubygem-asciidoctor.noarch iniparser-devel.x86_64 meson.noarch
```

```
// json-c (version: json-c-0.14-20200419)

$ git clone https://github.com/json-c/json-c.git
$ cd json-c
$ git checkout json-c-0.14-20200419 -b json-c-0.14-20200419
$ mkdir json-c-build
$ cd json-c-build/
$ cmake ../
$ make -j48
```

```
//Required Min Version: v75 (latest version: v78)

$ git clone https://github.com/pmem/ndctl
$ git checkout v75 -b v75
$ meson setup build;
$ meson compile -C build;
$ meson install -C build;
```

- Commands:

```
$ ./build.sh compile debug
```
```
// dax-ctl 을 이미지 base 경로에 설치 필요
// 컴파일 작업 디렉토리가 "/root/ldb/LightningDB_v2_cxl/nvkvs/debug/output"라 가정
// ndctl github 컴파일 디렉토리로 이동

$ cd ndctl
$ rm -rf build
$ meson -Drootprefix=/root/ldb/LightningDB_v2_cxl/nvkvs/debug/output -Dlibdir=/root/ldb/LightningDB_v2_cxl/nvkvs/debug/output/lib build -Dprefix=/root/ldb/LightningDB_v2_cxl/nvkvs/debug/output
$ meson compile -C build;
$ meson install -C build;
```
```
$ cd nvkvs
$ docker build . -t harbor.k8s.lightningdb/ltdb/nvkvs:v2-cms-integration
$ docker push harbor.k8s.lightningdb/ltdb/nvkvs:v2-cms-integration
```

!!! Tip
    How to use maximum cores to compile (e.g. max cpu core:56)
   
    In 'build.sh', use `cmake --build . --target install -- -j56` and `mvn clean install -DskipTests -P $RELEASE_MODE $MAVEN_OPTS -T 56`

    
# Build 'ltdb-http API Server' (Admin Only)

## 1. ltdb-http Source Code(Private Repository)
```
$ git clone https://github.com/mnms/ltdb-http
```

## 2. Build
### - v1
- Branch: develop
- Commands:
  
```
$ mvn clean package -DskipTests -P release-k8s,dist-k8s,tgz -Dsite-spec=k8s -Dk8s.namespace=metavision
$ cd target-k8s
$ tar xzvf ltdb-http-1.0-k8s-xxx_xxx.tar.gz
$ cd ltdb-http
$ docker build . -t harbor.k8s.lightningdb/ltdb/ltdb-http:develop
$ docker push harbor.k8s.lightningdb/ltdb/ltdb-http:develop
```

### - v2 / v2 CXL-CMS
- Branch: develop-v2
- Commands:
```
$ mvn clean package -DskipTests -P release-k8s,dist-k8s,tgz -Dsite-spec=k8s -Dk8s.namespace=metavision
$ cd target-k8s
$ tar xzvf ltdb-http-1.0-k8s-xxx_xxx.tar.gz
$ cd ltdb-http
$ docker build . -t harbor.k8s.lightningdb/ltdb/ltdb-http:develop-v2
$ docker push harbor.k8s.lightningdb/ltdb/ltdb-http:develop-v2
```


# Build 'Thunderquery API Server' (Admin Only)

## 1. Thunderquery Source Code(Private Repository)
```
$ git clone https://github.com/mnms/thunderquery_api
$ git clone https://github.com/mnms/thunderquery-cli
```

## 2. Build
- Branch: develop
- Prerequisite(install musl-gcc): 

```
$ yum install -y kmod-devel rubygem-asciidoctor.noarch iniparser-devel.x86_64 meson.noarch
```

```
$ vi /etc/yum.repos.d/cert-forensics-tools.repo
 
[cert-forensics-tools]
name=Cert Forensics Tools Repository
baseurl=https://forensics.cert.org/centos/cert/8/x86_64/
enabled=1
gpgcheck=1
gpgkey=https://forensics.cert.org/forensics.asc
 
$ yum clean all
$ yum makecache
$ yum install musl-gcc.x86_64
```

- Register public key to github
```
$ cat ~/.ssh/id_rsa.pub
```

- Command: 
```
$ vi ~/.cargo/config.toml
 
[net]
git-fetch-with-cli = true
 
$ cd thunderquery_api
$ cargo install --path . --target=x86_64-unknown-linux-musl
$ cd thunderquery-cli
$ cargo install --path . --target=x86_64-unknown-linux-musl

```
```
$ cd thunderquery_api
 
## thunderquery-cli binary 를 api 디렉토리로 복사 ##
$ cp ../thunderquery-cli/target/x86_64-unknown-linux-musl/release/thunderquery-cli target/x86_64-unknown-linux-musl/release

$ docker build . -t harbor.k8s.lightningdb/ltdb/thunderquery_api:develop
$ docker push harbor.k8s.lightningdb/ltdb/thunderquery_api:develop
```