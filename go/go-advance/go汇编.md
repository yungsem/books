## 函数

### 定义函数

基本语法：

```sh
TEXT symbol(SB),[flags],$framesize[-argsize]
```

```
TEXT symbol(SB),[flags],$局部变量大小[-参数大小]
```

示例：

在 Go 语言中声明 Swap 函数：

```go
package main

func Swap(a, b int) (int, int)
```

汇编定义：

```assembly
TEXT ·Swap(SB), NOSPLIT, $0-32
```

注意：

1. Go 函数中的参数和返回值在 Go 汇编函数中都算作参数。所以参数的大小是参数和返回值总的大小。

2. 对于 Go 汇编函数，函数名和参数大小即是该函数的签名。所以对于上面定义的汇编函数，下面的 Go 函数声明都是有效的：

   ```go
   func Swap(a, b, c int) int
   func Swap(a, b, c, d int)
   func Swap() (a, b, c, d int)
   func Swap() (a []int, d int)
   ```

### 引用函数的参数和返回值

假设有如下函数：

```go
func Swap(a, b int) (ret0, ret1 int)
```

它对应的的汇编函数是：

```assembly
TEXT ·Swap(SB), $0-32
```

由上面我们知道，汇编函数在定义时只指定参数和返回值的总大小，并不分别指定具体某一个参数或某一个返回值。但是在汇编代码中，我们不可避免的要引用上述参数（a 和 b）和返回值（ret0 和 ret1）。那我们怎么引用呢？

Go 汇编引入了一个伪寄存器 FP ，FP 表示函数当前栈帧的地址，也就是第一个参数的地址。所以我们可以使用：

- +0(FP)  表示参数 a
- +8(FP)  表示参数 b
- +16(FP)  表示返回值 ret0
- +24(FP)  表示返回值 ret1

但是 Go 汇编还有一个规定，不能直接使用 +0(FP)  引用参数，需要加一个临时的标识符，一般使用变量名。所以正确的是：

- a+0(FP)  表示参数 a
- b+8(FP)  表示参数 b
- ret0+16(FP)  表示返回值 ret0
- ret1+24(FP)  表示返回值 ret1

下面示例演示如果在汇编代码中引用函数参数和返回值：

```assembly
TEXT ·Swap(SB), $0
    MOVQ a+0(FP), AX     // AX = a
    MOVQ b+8(FP), BX     // BX = b
    MOVQ BX, ret0+16(FP) // ret0 = BX
    MOVQ AX, ret1+24(FP) // ret1 = AX
    RET
```

### 复杂的参数和返回值

Go 函数：

```go
func Foo(a bool, b int16) (c []byte)
```

汇编函数：

```assembly
TEXT ·Foo(SB), $0
    MOVEQ a+0(FP),       AX // a
    MOVEQ b+2(FP),       BX // b
    MOVEQ c_dat+8*1(FP), CX // c.Data
    MOVEQ c_len+8*2(FP), DX // c.Len
    MOVEQ c_cap+8*3(FP), DI // c.Cap
    RET
```

内存对齐：

参数 a 和参数 b 之间出现了一个字节的空洞，b 和 c 之间出现了 4 个字节的空洞。出现空洞的原因是要保证每个参数变量地址都要对齐到相应的倍数。

### 函数的局部变量

在 Go 语言中，函数的局部变量包含：

- 参数
- 返回值
- 函数体内定义的局部变量

但是在 Go 汇编中，局部变量只包含：

- 函数体内定义的局部变量

为了方便引用局部变量，Go 汇编引入了一个伪 SP 寄存器。下面用示例说明伪 SP 的使用：

```go
func Foo() {
    var c []byte
    var b int16
    var a bool
}
```

```assembly
TEXT ·Foo(SB), $32-0
    MOVQ a-32(SP),      AX // a
    MOVQ b-30(SP),      BX // b
    MOVQ c_data-24(SP), CX // c.Data
    MOVQ c_len-16(SP),  DX // c.Len
    MOVQ c_cap-8(SP),   DI // c.Cap
    RET
```

指向当前函数栈帧的底部。栈是自顶向下生长的，所以栈帧的底部其实位于高地址位。

先定义的局部变量离伪 SP 越近。

Go 汇编用起始地址（低地址）引用变量，而栈是自顶向下生长的，所以引用局部变量的 offset 是负数。

还有一个真 SP ，真 SP 位于栈帧的顶部。

如图所示：

图缺

有调用其他和函数



函数栈帧：

- 本函数的参数
- 本函数的返回值
- 本函数的局部变量
- 被本函数调用的函数的参数
- 被本函数调用的函数的返回值