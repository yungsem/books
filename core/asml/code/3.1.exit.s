# exit.s
.section .data # 定义数据段，本例中没有数据，所以下方没有内容

.section .text # 定义代码段
.global _start # 定义一个 symbol ，名为 _start 。symbol 的值是下面 label 对应的地址，后续可以使用 symbol 代表地址
_start:        # label ，label 对应的地址就是 symbol 的值
 movl $1, %eax  # sys_exit 系统调用的功能码是 1 ,功能码必须存入 eax 中
 movl $0, %ebx  # 传递给 sys_exit 的参数，此处使用 0 。该参数的值作为 sys_exit 的返回值返回。 
                # 返回值可以使用 echo $? 打印出来
 int $0x80      # 触发中断，唤起系统调用