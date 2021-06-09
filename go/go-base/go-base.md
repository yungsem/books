# 基础知识

## 什么是 go module
首先，一个 go module 有一个根目录。在这个根目录下有一组 go packe 和一个 go.md 文件。直观来看，一个典型的 go module 的目录结构如下：
```
my-module
    └── package1
    └── package2
    └── package3
    └── go.mod
```

要想将一个目录初始化为一个 go module ，在该目录下执行如下命令即可：
```
go mod init github.com/yungsem/根目录名称
```

## module path

go.md 文件的内容如下：
```
module github.com/yungsem/my-module

go 1.15
```

module 关键字后面声明的 `github.com/yungsem/my-module` 就是 module path 。

module path 是一个很重要的路径：
- 如果 module A 依赖了 module B ，那么在 module A 中导入 module B 的 package 时，导入的根路径就是 module B 的 module path 。
- 在 module A 内部，package1 想要导入 package2 ，导入的根路径也是 module A 的 module paht 。


## 理解 import
import 语句的完整语法是：
```go
import package_name package_path
```
如果 package_name 和 package_path 的最后一级同名，那么 package_name 就可以省略。如下：
```go
import package_path
```

在引入 go module 之后，package_path 前面要加上 module path ，其他的理解不变。

例如，在 module A 内部，如果我们在 package1 中需要依赖 package2 ，会写如下的 import 语句：
```go
import module_path/package2_path
```

## 参考
[Using Go Modules](https://blog.golang.org/using-go-modules)