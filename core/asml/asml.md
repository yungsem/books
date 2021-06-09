# 计算机结构

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

