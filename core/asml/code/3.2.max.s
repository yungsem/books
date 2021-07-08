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