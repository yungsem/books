# 目录

- [ ] 汇编语言
  - [x] 简单起步
- [ ] 调度
- [ ] 内存分配
- [ ] 垃圾回收

# 汇编语言

## 简单起步

### Go汇编代码的组织方式

Go 汇编并不是一个独立的汇编语言，它不能独立使用，必须依赖 Go 语言使用。

Go 汇编源文件也是放在 Go 包里组织的，同时 Go 包里必须有一个 Go 源文件，用以指明包信息。

在 Go 汇编源文件中定义的变量和函数，如果要放到 Go 源文件中使用，必须先在 Go 源文件中重新声明一次才能使用。

### 完整示例

创建一个 Go 汇编源文件，命名为 `test_amd64.s` ，放在 test 包下。

这段汇编代码在当前包下定义了一个变量 Id ，长度为 8 字节，并初始化为 0x2537 ，十进制是 9527 。

```go
// github.com/yungsem/learn-go/go-advance/asm/03/test/test_amd64.s

#include"textflag.h"
GLOBL ·Id(SB),NOPTR,$8
DATA ·Id+0(SB)/1,$0x37
DATA ·Id+1(SB)/1,$0x25
DATA ·Id+2(SB)/1,$0x00
DATA ·Id+3(SB)/1,$0x00
DATA ·Id+4(SB)/1,$0x00
DATA ·Id+5(SB)/1,$0x00
DATA ·Id+6(SB)/1,$0x00
DATA ·Id+7(SB)/1,$0x00
```

同时，在 test 包下新建一个 Go 源文件，用于指明包信息和重新声明 Id 变量，以在 `main.go` 中使用：

```go
// github.com/yungsem/learn-go/go-advance/asm/03/test/test.go
package test

var Id int
```

在 `main.go` 中使用变量 Id ：

```go
// github.com/yungsem/learn-go/go-advance/asm/03/main/main.go

package main

import (
	"fmt"
	"github.com/yungsem/learn-go/go-advance/asm/03/test"
)

func main() {
	i := test.Id
	fmt.Println(i)
}

// output
9527
```



# 调度

# 内存分配

# 垃圾回收

