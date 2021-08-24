# 计算机结构

## CPU

### CPU逻辑结构

站在汇编的视角看 CPU 时，我们只需关注 CPU 的寄存器和指令集即可。下面是 CPU 的极简化的逻辑结构图：

![asml-1.1-1](img/asml-1.1-1.svg)

### 寄存器

既然关注的是寄存器，下面就来列举 x86_64 位 CPU 常用的寄存器。

#### 通用寄存器

| 寄存器 | 作用 |
| ------ | ---- |
| rax    |      |
| rbx    |      |
| rcx    |      |
| rdx    |      |
| rsp    |      |
| rbp    |      |
| rsi    |      |
| rdi    |      |
| r8~r15 |      |

#### 指令寄存器

| 寄存器 | 作用                              |
| ------ | --------------------------------- |
| rip    | 存放 CPU 要执行的下一条指令的地址 |

#### 段寄存器
| 寄存器 | 作用                              |
| ------ | --------------------------------- |
| cs | 代码段 |
| ds | 数据段 |
| ss | 栈段 |
| es | 扩展段 |
| fs | 数据段 |
| gs | 数据段 |

### 指令集

CPU 的本质能力在于执行指令，CPU 支持的指令就称为 CPU 指令集。目前主流的指令集有两种：

- Complex Instruction Set Computing (CISC) 复杂指令集，Intel 的 x86_64 CPU 使用
- Reduced Instruction Set Computing (RISC) 精简指令集，手机端的芯片使用

# 语法

## 程序结构

程序结构：

```assembly
.section .data # 数据段
.section .text # 代码段
.global _start # 全局标号
_start: # 标号
... # 代码
```

## 段

### 段是什么

段代表一段连续的地址空间。这段地址空间里的数据有着共同的用途。比如数据段里的数据作为程序的数据使用，代码段里的数据作为指令使用。

汇编指令和指令集的关系
一条汇编指令对应一条 CPU 指令
一条汇编指令也可能对应多条 CPU 指令
有的 CPU 指令没有汇编指令与其对应

## 汇编语言
在 `.s` 文件中，至少包含三个段：

- .text
- .data
- .bss

### `.section`指令

语法格式：

```assembly
.section name
```

示例：

```assembly
.section .data #定义代码段
```

### 段的地址

在编写源码时，我们使用 `.section` 指令定义段，此时段是没有地址的，此时的段仅仅是代码层面的段。

当我们使用 `as` 命令将 `.s` 文件编译成 `.o` 文件时，段就有了地址。不过这个地址并不是运行时的真实地址，而是 `静态地址` 。在 `.o` 文件中，`.text` 段的地址是 0 ，后面紧跟的是 `.data` 段，然后是 `.bss` 段。在复杂的程序中，我们可能会有多个 `.o` 文件，要注意每个 `.o` 文件对应的 `.text` 段的起始地址都是 0 。这也是为什么我们把此时段的地址称为 `静态地址` 。

当我们使用 `ld` 命令将一个或多个 `.o ` 文件链接成最终的可执行文件时，`ld` 的一个重要工作就是将 `静态地址` 转换为 `运行时的真实地址`。

## 标号

### 标号是什么

标号有点像高级语言里的变量。标号的本质作用是代表一个地址。

### 定义标号

语法格式：

```assembly
标号名:
```

示例：

```assembly
.section .text

.global _start
_start:
 movl $0, %edi
 movl data_items(,%edi,4), %eax
 movl %eax, %ebx

start_loop:
 cmpl $0, %eax
 je loop_exit
 incl %edi
 movl data_items(,%edi,4), %eax
 cmpl %ebx, %eax
 jle start_loop
 movl %eax, %ebx
 jmp start_loop
loop_exit:
 movl $1, %eax
 int $0x80
```

示例中的 _start ，start_loop ，loop_exit 都是标号。

其中 _start 比较特殊，它借助 .global 指令使自己对 ld 命令可见，也就是全局意义上的标号，其他的 .s 文件中可以直接使用，ld 命令会负责将这些符号引用解析为真正的地址引用。

### 使用标号

标号一旦定义，就可以直接使用，上例中定义的标号直接被作为指令的操作数使用，如下：

```assembly
jle start_loop

jmp start_loop
```

## 寻址模式

### immediate mode

指令中使用立即数，不需要寻址，直接当作值使用。

```assembly
# 指令中直接使用立即数 0
movl $0, %edi
```

### register addressing mode

指令中使用寄存器名，读取寄存器中的内容。

```assembly
# 指令中直接使用寄存器名
# 将 eax 中的内容复制到 ebx 中
movl %eax, %ebx
```

### direct addressing mode

指令中使用内存地址，读取内存地址对应的数据。

```assembly
# 指令中直接使用内存地址（ADDRESS） 
movl (ADDRESS), %eax
```

### indexed addressing mode

指令中使用一个内存地址，外加一个寄存器，寄存器中存放的是内存地址的偏移量，内存地址作为基址。偏移量还可以乘以一个倍数。所以：

```sh
最终地址 = 基址 + 偏移量 * 倍数
```

> 注意：偏移量从 0 开始。

```assembly
movl string_start(,%ecx,1), %eax
```

### indirect addressing mode

指令中使用寄存器，寄存器中存放着内存地址，指令先从寄存器中取出内存地址，然后根据内存地址读取对应的数据。

```assembly
movl (%eax), %ebx
```

### base pointer addressing mode

在 indirect addressing mode 基础上加一个 offset ，真正地址是：

```sh
寄存器中的地址 + offset
```

```assembly
movl 4(%eax), %ebx
```

### 总结

```assembly
ADDRESS_OR_OFFSET(%BASE_OR_OFFSET,%INDEX,MULTIPLIER)
```

```assembly
FINAL ADDRESS = ADDRESS_OR_OFFSET + %BASE_OR_OFFSET + MULTIPLIER * %INDE
```

## 指令

### 跳转指令

```assembly
# Jump if the values were equal
je

# Jump if the second value was greater than the first value
jg

# Jump if the second value was greater than or equal to the first value
jge

# Jump if the second value was less than the first value
jl

# Jump if the second value was less than or equal to the first value
jle

#Jump no matter what. This does not need to be preceeded by a comparison
jmp
```

### 比较指令

```assembly
# 比较两个操作数是否相等。比较结果会写入 eflags 寄存器中。
# 跳转指令（如：je）会从 eflags 寄存器中读取比较的结果，然后跳转。
cmpl op1, op2
```

### 递增指令

```assembly
# 将 edi 中的值增加 1
incl %edi
```

## 函数

### 概述

**函数的构成：**

- function name：函数名引用函数代码内存的首地址。
- function parameters
- local variables
- static variables：本次函数执行完，静态变量不丢弃，下次函数再执行时，继续使用该值。静态变量只为当前函数所拥有，其他函数不能共享。
- global variables
- return address： 返回地址是一个特殊的参数，在汇编语言中，call 指令负责将返回地址传递给被调用函数，ret 指令将程序跳转到返回地址指定的位置开始执行。
- return value

**调用协议(Calling Convention)：**

本汇编语言使用 C 语言的调用协议，该调用协议被广泛使用，并且是 Linux 平台的标准调用协议。

### C语言调用协议

假设有如下函数调用：

```c
void foo() {
    bar(3,2);
}

void bar(int a, int b) {
    int c = 5;
    int d = 4;
    return a + b + c + d;
}
```

则函数栈的结构如下：

压入局部变量之前：

![asml-2.6.2-1](img/asml-2.6.2-1.svg)

压入局部变量之后：

![asml-2.6.2-2](img/asml-2.6.2-2.svg)

# 案例

## 系统调用 sys_exit

### 说明

在本例中，我们将调用系 `sys_exit` 统调用。

**系统调用过程简述**：

- 要想触发系统调用，先需要发送 `int $0x80` 中断。
- 然后内核读取 `%eax` 里的功能码，找到对应的系统调用执行。其中参数从 `%ebx` , `%ecx` , `%edx` , `%esi` 中读取。
- 系统调用的返回值可以通过 `echo $?` 打印出来。

具体参考 [这里](https://introspelliam.github.io/2017/08/07/int-80h%E7%B3%BB%E7%BB%9F%E8%B0%83%E7%94%A8%E6%96%B9%E6%B3%95/) 。

`sys_exit` 系统调用的定义如下：

```
1. sys_exit

Syntax: int sys_exit(int status)
Source: kernel/exit.c
Action: terminate the current process
Details: status is return code
```

由定义可知，该系统调用的功能码是 1 ，需要一个 status 参数，并且该参数会作为返回值返回。

### 源码

```assembly
# exit.s

.section .data # 定义数据段，本例中没有数据，所以下方没有内容

.section .text # 定义代码段
.global _start # 定义一个 symbol ，名为 _start 。symbol 的值是下面 label 对应的地址，后续可以使用 symbol d
_start:        # label ，label 对应的地址就是 symbol 的值
 movl $1, %eax  # sys_exit 系统调用的功能码是 1 ,功能码必须存入 eax 中
 movl $0, %ebx  # 传递给 sys_exit 的参数，此处使用 0 。该参数的值作为 sys_exit 的返回值返回。 
                # 返回值可以使用 echo $? 打印出来
 int $0x80      # 触发中断，唤起系统调用
```

```sh
as exit.s -o exit.o
```

```sh
ld exit.o -o exit
```

```sh
./exit
```

打印系统调用的返回值：

```sh
echo $?
```

## 寻找最大值

### 说明

本例将实现需求：在一组数字中找出最大值。

约定：如果遇到 0 ，则表示结束。

![asml-3.2-1](img/asml-3.2-1-1625489917179.svg)

### 源码

```assembly
# max.s

.section .data # 数据段
data_items: # 标号，下面的代码使用 data_items 引用数据段的起始地址
  # 定义数据，都是 long 类型的数值，每个占 4 字节
 .long 3, 67, 34, 222, 45, 75, 54, 34, 44, 33, 22, 11, 66, 0

.section .text

.global _start
_start:
 movl $0, %edi
 movl data_items(,%edi,4), %eax
 movl %eax, %ebx

start_loop:
 cmpl $0, %eax
 je loop_exit
 incl %edi
 movl data_items(,%edi,4), %eax
 cmpl %ebx, %eax
 jle start_loop
 movl %eax, %ebx
 jmp start_loop
loop_exit:
 movl $1, %eax
 int $0x80
```

```assembly
as max.s -o max.o
ld max.o -o max
./max
echo $?

222
```

