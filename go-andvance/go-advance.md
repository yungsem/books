# 目录

# Go汇编

## 起步

### 如何使用

Go 汇编并不是一个独立的汇编语言，它不能独立使用，必须和 Go 语言一起使用。

Go 汇编源文件也是放在 Go 包里组织的，同时 Go 包里必须有一个 Go 源文件，用以指明包信息。

在 Go 汇编源文件中定义的变量和函数，如果要放到 Go 源文件中使用，必须先在 Go 源文件中再声明一次才能使用。

### 简单示例

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

同时，在 test 包下新建一个 Go 源文件，用于指明包信息。再次声明一下 Id 变量，以在 `main.go` 中使用：

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
## 字面量

### 字面量（literal）
Go 汇编中的字面量以 $ 开头，有整型，浮点型，字符型和字符串型。
```
$1           // 十进制
$0xf4f8fcff  // 十六进制
$1.5         // 浮点数
$'a'         // 字符
$"abcd"      // 字符串
```
整型默认是十进制。

### 字面量表达式（literal expression）
字面量表达式也是以 $ 开头，后面跟字面量表达式。
```
$2+2      // $4
$3&1<<2   // $4
$(3&1)<<2 // $4
```
表达式中运算符的优先级和 Go 语言保持一致。

### 运行时字面量
上面说的字面量都是编译时期定义的字面量，Go 汇编也有运行时期的字面量。

比如，变量和函数的地址在运行期间都是不变的，所以变量和函数的地址也是一种字面量，不过是运行时的字面量。

```
GLOBL ·NameData(SB),$8
DATA  ·NameData(SB)/8,$"gopher"

GLOBL ·Name(SB),$16
DATA  ·Name+0(SB)/8,$·NameData(SB)
DATA  ·Name+8(SB)/8,$6
```
`$·NameData(SB)` 表示变量 NameData 的地址，也可以看作一个字面量，它在运行期间是不变的。

## 全局变量

### 概述

变量根据作用域可分为全局变量和局部变量。

Go 中的全局变量是包级别的变量，在运行期间一般有着固定的内存地址。生命周期跨越整个程序运行期间。

局部变量是在函数内部定义的变量，函数被调用时在栈上创建，函数调用完成之后就被释放了。生命周期随函数调用的结束而结束。

Go 汇编中的全局变量和函数在本质上是同一个东西，都是通过一个符号引用一段内存空间。对于变量，内存空间中存放的是数据；对于函数，内存空间中存放的是指令。

### 定义全局变量

**定义**

```
GLOBL symbol(SB),width
```

Go 汇编使用一个伪寄存器 SB 来定位内存空间。symbol(SB) 就表示符号 symbol 引用的内存空间的起始地址。

width 指定该变量占用的字节数。

**初始化**

```
DATA symbol+offset(SB)/width,value
```

offset 表示变量所引用内存空间里字节的偏移量。如：

- offset + 0 ：变量内存空间的第一个字节
- offset + 1 ：变量内存空间的第二个字节 

**示例**

定义：

```
GLOBL ·count(SB),$4
```
`·count` 前面的 `·` 表示该符号位于当前包下，最终会被替换为 `path/to/pkg.count` 。

初始化：

```
DATA ·count+0(SB)/1,$1
DATA ·count+1(SB)/1,$2
DATA ·count+2(SB)/1,$3
DATA ·count+3(SB)/1,$4
```
该示例定义了一个名为 count 的全局变量，大小 4 个字节，初始化为：

二进制：00000100 00000011 00000010 00000001

十六进制：0x04030201

十进制：67305985

### 各类型示例

#### 数组类型
```go
var num [2]int
```

```
GLOBL ·num(SB),$16
DATA ·num+0(SB)/8,$0 // 第一个元素，8 个字节，初始化为 0
DATA ·num+8(SB)/8,$0 // 第二个元素，8 个字节，初始化为 0
```

#### 布尔类型
```go
var (
    boolValue  bool
    trueValue  bool
    falseValue bool
)
```

```
GLOBL ·boolValue(SB),$1

GLOBL ·trueValue(SB),$1
DATA ·trueValue(SB)/1,$1 // 初始化为 1 ，非 0 为 true

GLOBL ·falseValue(SB),$1
DATA ·falseValue(SB)/1,$0 // 初始化为 0 ，0 为 false
```

#### int 类型
```go
var int32Value int32

var uint32Value uint32
```

```
GLOBL ·int32Value(SB),$4
DATA ·int32Value+0(SB)/1,$0x01 // 第 1 字节
DATA ·int32Value+1(SB)/1,$0x02 // 第 2 字节
DATA ·int32Value+2(SB)/2,$0x03 // 第 3-4 字节

GLOBL ·uint32Value(SB),$4
DATA ·uint32Value(SB)/4,$0x01020304 // 第1-4字节
```

#### float 类型
```go
var float32Value float32

var float64Value float64
```

```
GLOBL ·float32Value(SB),$4
DATA ·float32Value+0(SB)/4,$1.5      // var float32Value = 1.5

GLOBL ·float64Value(SB),$8
DATA ·float64Value(SB)/8,$0x01020304 // bit 方式初始化
```

#### string 类型
```go
var helloworld string
```

string 类型的底层结构：
```go
type reflect.StringHeader struct {
    Data uintptr
    Len  int
}
```

```
GLOBL text<>(SB),NOPTR,$16
DATA text<>+0(SB)/8,$"Hello Wo"
DATA text<>+8(SB)/8,$"rld!"
```

```
GLOBL ·helloworld(SB),$16
DATA ·helloworld+0(SB)/8,$text<>(SB) // StringHeader.Data
DATA ·helloworld+8(SB)/8,$12         // StringHeader.Len
```

#### slice 类型
```go
var helloworld []byte
```

slice 类型底层结构：
```go
type reflect.SliceHeader struct {
    Data uintptr
    Len  int
    Cap  int
}
```

```
GLOBL ·helloworld(SB),$24            // var helloworld []byte("Hello World!")
DATA ·helloworld+0(SB)/8,$text<>(SB) // StringHeader.Data
DATA ·helloworld+8(SB)/8,$12         // StringHeader.Len
DATA ·helloworld+16(SB)/8,$16        // StringHeader.Cap

GLOBL text<>(SB),$16
DATA text<>+0(SB)/8,$"Hello Wo"      // ...string data...
DATA text<>+8(SB)/8,$"rld!"          // ...string data...
```


#### map/channel 类型
map/channel等类型并没有公开的内部结构，它们只是一种未知类型的指针，无法直接初始化。在汇编代码中我们只能为类似变量定义并进行0值初始化：
```go
var m map[string]int

var ch chan int
```

```
GLOBL ·m(SB),$8  // var m map[string]int
DATA  ·m+0(SB)/8,$0

GLOBL ·ch(SB),$8 // var ch chan int
DATA  ·ch+0(SB)/8,$0
```


# 调度

# 内存分配

# 垃圾回收

