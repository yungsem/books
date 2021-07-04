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

# 起步

## 系统调用 sys_exit

### 说明

**系统调用过程简述**：

- 要想触发系统调用，先需要发送 `int $0x80` 中断。
- 然后内核读取 `%eax` 里的功能码，找到对应的系统调用执行。其中参数从 `%ebx` , `%ecx` , `%edx` , `%esi` 中读取。
- 系统调用的返回值可以通过 `echo $?` 打印出来。

具体参考 [这里](https://introspelliam.github.io/2017/08/07/int-80h%E7%B3%BB%E7%BB%9F%E8%B0%83%E7%94%A8%E6%96%B9%E6%B3%95/) 。

在本例中，我们将调用一个系统调用 `sys_exit` ，该系统调用的定义如下：

```
1. sys_exit

Syntax: int sys_exit(int status)
Source: kernel/exit.c
Action: terminate the current process
Details: status is return code
```

由定义可知，该系统调用的功能码是 1 ，需要一个 status 参数，并且该参数会作为返回值返回。

### 示例

源码：

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

编译：

```sh
as exit.s -o exit.o
```

链接：

```sh
ld exit.o -o exit
```

执行：

```sh
./exit
```

打印系统调用的返回值：

```sh
echo $?
```

## 寻找最大值

说明：

本例将实现需求：在一组数字中找出最大值。

# 语法

## 程序结构

程序结构：

```assembly
.section .data # 数据段
.section .text # 代码段
.global _start # 全局标号
_start: # 起始标号
... # 代码
```

## 段

### 段是什么

段代表一段连续的地址空间。这段地址空间里的数据有着共同的用途。比如数据段里的数据作为程序的数据使用，代码段里的数据作为指令使用。

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

如：基址 2002 ，倍数 4 ，读取从 2002 开始的第四个字（一个字占 4 个字节）：

2002,3

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

寄存器中的地址 + offset

```assembly
movl 4(%eax), %ebx
```

汇编代码层面

```assembly
ADDRESS_OR_OFFSET(%BASE_OR_OFFSET,%INDEX,MULTIPLIER)
```

```assembly
FINAL ADDRESS = ADDRESS_OR_OFFSET + %BASE_OR_OFFSET + MULTIPLIER * %INDE
```



