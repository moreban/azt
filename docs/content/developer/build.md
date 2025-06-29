---
title: "构建，以及贡献"
draft: false
weight: 10
---

编译需要 Go 1.23+，请注意保重基本编译环境。

```shell
make
make install # 安装systemd服务等，可选
```

或者直接使用Go进行编译：

```shell
go build -tags "full" # 编译完整版本
```

可以通过指定GOOS和GOARCH环境变量，指定交叉编译的目标操作系统和架构，例如

```shell
GOOS=windows GOARCH=386 go build -tags "full" # windows x86
GOOS=linux GOARCH=arm64 go build -tags "full" # linux arm64
```
