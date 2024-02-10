
obj/user/faultwritekernel:     formato del fichero elf32-i386


Desensamblado de la sección .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 0d 00 00 00       	call   80003e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
	*(unsigned *) 0xf0100000 = 0;
  800033:	c7 05 00 00 10 f0 00 	movl   $0x0,0xf0100000
  80003a:	00 00 00 
}
  80003d:	c3                   	ret    

0080003e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003e:	55                   	push   %ebp
  80003f:	89 e5                	mov    %esp,%ebp
  800041:	56                   	push   %esi
  800042:	53                   	push   %ebx
  800043:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800046:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	envid_t id = sys_getenvid();
  800049:	e8 04 01 00 00       	call   800152 <sys_getenvid>
	if (id >= 0)
  80004e:	85 c0                	test   %eax,%eax
  800050:	78 15                	js     800067 <libmain+0x29>
		thisenv = &envs[ENVX(id)];
  800052:	25 ff 03 00 00       	and    $0x3ff,%eax
  800057:	69 c0 88 00 00 00    	imul   $0x88,%eax,%eax
  80005d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800062:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800067:	85 db                	test   %ebx,%ebx
  800069:	7e 07                	jle    800072 <libmain+0x34>
		binaryname = argv[0];
  80006b:	8b 06                	mov    (%esi),%eax
  80006d:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800072:	83 ec 08             	sub    $0x8,%esp
  800075:	56                   	push   %esi
  800076:	53                   	push   %ebx
  800077:	e8 b7 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007c:	e8 0a 00 00 00       	call   80008b <exit>
}
  800081:	83 c4 10             	add    $0x10,%esp
  800084:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800087:	5b                   	pop    %ebx
  800088:	5e                   	pop    %esi
  800089:	5d                   	pop    %ebp
  80008a:	c3                   	ret    

0080008b <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008b:	55                   	push   %ebp
  80008c:	89 e5                	mov    %esp,%ebp
  80008e:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800091:	6a 00                	push   $0x0
  800093:	e8 98 00 00 00       	call   800130 <sys_env_destroy>
}
  800098:	83 c4 10             	add    $0x10,%esp
  80009b:	c9                   	leave  
  80009c:	c3                   	ret    

0080009d <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  80009d:	55                   	push   %ebp
  80009e:	89 e5                	mov    %esp,%ebp
  8000a0:	57                   	push   %edi
  8000a1:	56                   	push   %esi
  8000a2:	53                   	push   %ebx
  8000a3:	83 ec 1c             	sub    $0x1c,%esp
  8000a6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8000a9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8000ac:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile(
  8000ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000b4:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000b7:	8b 75 14             	mov    0x14(%ebp),%esi
  8000ba:	cd 30                	int    $0x30
	        "int %1\n"
	        : "=a"(ret)
	        : "i"(T_SYSCALL), "a"(num), "d"(a1), "c"(a2), "b"(a3), "D"(a4), "S"(a5)
	        : "cc", "memory");

	if (check && ret > 0)
  8000bc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000c0:	74 04                	je     8000c6 <syscall+0x29>
  8000c2:	85 c0                	test   %eax,%eax
  8000c4:	7f 08                	jg     8000ce <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  8000c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000c9:	5b                   	pop    %ebx
  8000ca:	5e                   	pop    %esi
  8000cb:	5f                   	pop    %edi
  8000cc:	5d                   	pop    %ebp
  8000cd:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	50                   	push   %eax
  8000d2:	ff 75 e0             	push   -0x20(%ebp)
  8000d5:	68 8a 0e 80 00       	push   $0x800e8a
  8000da:	6a 1e                	push   $0x1e
  8000dc:	68 a7 0e 80 00       	push   $0x800ea7
  8000e1:	e8 f7 01 00 00       	call   8002dd <_panic>

008000e6 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  8000e6:	55                   	push   %ebp
  8000e7:	89 e5                	mov    %esp,%ebp
  8000e9:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t) s, len, 0, 0, 0);
  8000ec:	6a 00                	push   $0x0
  8000ee:	6a 00                	push   $0x0
  8000f0:	6a 00                	push   $0x0
  8000f2:	ff 75 0c             	push   0xc(%ebp)
  8000f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000fd:	b8 00 00 00 00       	mov    $0x0,%eax
  800102:	e8 96 ff ff ff       	call   80009d <syscall>
}
  800107:	83 c4 10             	add    $0x10,%esp
  80010a:	c9                   	leave  
  80010b:	c3                   	ret    

0080010c <sys_cgetc>:

int
sys_cgetc(void)
{
  80010c:	55                   	push   %ebp
  80010d:	89 e5                	mov    %esp,%ebp
  80010f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800112:	6a 00                	push   $0x0
  800114:	6a 00                	push   $0x0
  800116:	6a 00                	push   $0x0
  800118:	6a 00                	push   $0x0
  80011a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80011f:	ba 00 00 00 00       	mov    $0x0,%edx
  800124:	b8 01 00 00 00       	mov    $0x1,%eax
  800129:	e8 6f ff ff ff       	call   80009d <syscall>
}
  80012e:	c9                   	leave  
  80012f:	c3                   	ret    

00800130 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800130:	55                   	push   %ebp
  800131:	89 e5                	mov    %esp,%ebp
  800133:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800136:	6a 00                	push   $0x0
  800138:	6a 00                	push   $0x0
  80013a:	6a 00                	push   $0x0
  80013c:	6a 00                	push   $0x0
  80013e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800141:	ba 01 00 00 00       	mov    $0x1,%edx
  800146:	b8 03 00 00 00       	mov    $0x3,%eax
  80014b:	e8 4d ff ff ff       	call   80009d <syscall>
}
  800150:	c9                   	leave  
  800151:	c3                   	ret    

00800152 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800152:	55                   	push   %ebp
  800153:	89 e5                	mov    %esp,%ebp
  800155:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800158:	6a 00                	push   $0x0
  80015a:	6a 00                	push   $0x0
  80015c:	6a 00                	push   $0x0
  80015e:	6a 00                	push   $0x0
  800160:	b9 00 00 00 00       	mov    $0x0,%ecx
  800165:	ba 00 00 00 00       	mov    $0x0,%edx
  80016a:	b8 02 00 00 00       	mov    $0x2,%eax
  80016f:	e8 29 ff ff ff       	call   80009d <syscall>
}
  800174:	c9                   	leave  
  800175:	c3                   	ret    

00800176 <sys_yield>:

void
sys_yield(void)
{
  800176:	55                   	push   %ebp
  800177:	89 e5                	mov    %esp,%ebp
  800179:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  80017c:	6a 00                	push   $0x0
  80017e:	6a 00                	push   $0x0
  800180:	6a 00                	push   $0x0
  800182:	6a 00                	push   $0x0
  800184:	b9 00 00 00 00       	mov    $0x0,%ecx
  800189:	ba 00 00 00 00       	mov    $0x0,%edx
  80018e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800193:	e8 05 ff ff ff       	call   80009d <syscall>
}
  800198:	83 c4 10             	add    $0x10,%esp
  80019b:	c9                   	leave  
  80019c:	c3                   	ret    

0080019d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8001a3:	6a 00                	push   $0x0
  8001a5:	6a 00                	push   $0x0
  8001a7:	ff 75 10             	push   0x10(%ebp)
  8001aa:	ff 75 0c             	push   0xc(%ebp)
  8001ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b0:	ba 01 00 00 00       	mov    $0x1,%edx
  8001b5:	b8 04 00 00 00       	mov    $0x4,%eax
  8001ba:	e8 de fe ff ff       	call   80009d <syscall>
}
  8001bf:	c9                   	leave  
  8001c0:	c3                   	ret    

008001c1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001c1:	55                   	push   %ebp
  8001c2:	89 e5                	mov    %esp,%ebp
  8001c4:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map,
  8001c7:	ff 75 18             	push   0x18(%ebp)
  8001ca:	ff 75 14             	push   0x14(%ebp)
  8001cd:	ff 75 10             	push   0x10(%ebp)
  8001d0:	ff 75 0c             	push   0xc(%ebp)
  8001d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001d6:	ba 01 00 00 00       	mov    $0x1,%edx
  8001db:	b8 05 00 00 00       	mov    $0x5,%eax
  8001e0:	e8 b8 fe ff ff       	call   80009d <syscall>
	               srcenv,
	               (uint32_t) srcva,
	               dstenv,
	               (uint32_t) dstva,
	               perm);
}
  8001e5:	c9                   	leave  
  8001e6:	c3                   	ret    

008001e7 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e7:	55                   	push   %ebp
  8001e8:	89 e5                	mov    %esp,%ebp
  8001ea:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8001ed:	6a 00                	push   $0x0
  8001ef:	6a 00                	push   $0x0
  8001f1:	6a 00                	push   $0x0
  8001f3:	ff 75 0c             	push   0xc(%ebp)
  8001f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001f9:	ba 01 00 00 00       	mov    $0x1,%edx
  8001fe:	b8 06 00 00 00       	mov    $0x6,%eax
  800203:	e8 95 fe ff ff       	call   80009d <syscall>
}
  800208:	c9                   	leave  
  800209:	c3                   	ret    

0080020a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80020a:	55                   	push   %ebp
  80020b:	89 e5                	mov    %esp,%ebp
  80020d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800210:	6a 00                	push   $0x0
  800212:	6a 00                	push   $0x0
  800214:	6a 00                	push   $0x0
  800216:	ff 75 0c             	push   0xc(%ebp)
  800219:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80021c:	ba 01 00 00 00       	mov    $0x1,%edx
  800221:	b8 08 00 00 00       	mov    $0x8,%eax
  800226:	e8 72 fe ff ff       	call   80009d <syscall>
}
  80022b:	c9                   	leave  
  80022c:	c3                   	ret    

0080022d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80022d:	55                   	push   %ebp
  80022e:	89 e5                	mov    %esp,%ebp
  800230:	83 ec 08             	sub    $0x8,%esp
	return syscall(
  800233:	6a 00                	push   $0x0
  800235:	6a 00                	push   $0x0
  800237:	6a 00                	push   $0x0
  800239:	ff 75 0c             	push   0xc(%ebp)
  80023c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80023f:	ba 01 00 00 00       	mov    $0x1,%edx
  800244:	b8 09 00 00 00       	mov    $0x9,%eax
  800249:	e8 4f fe ff ff       	call   80009d <syscall>
	        SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80024e:	c9                   	leave  
  80024f:	c3                   	ret    

00800250 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
  800253:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800256:	6a 00                	push   $0x0
  800258:	ff 75 14             	push   0x14(%ebp)
  80025b:	ff 75 10             	push   0x10(%ebp)
  80025e:	ff 75 0c             	push   0xc(%ebp)
  800261:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800264:	ba 00 00 00 00       	mov    $0x0,%edx
  800269:	b8 0b 00 00 00       	mov    $0xb,%eax
  80026e:	e8 2a fe ff ff       	call   80009d <syscall>
}
  800273:	c9                   	leave  
  800274:	c3                   	ret    

00800275 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800275:	55                   	push   %ebp
  800276:	89 e5                	mov    %esp,%ebp
  800278:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t) dstva, 0, 0, 0, 0);
  80027b:	6a 00                	push   $0x0
  80027d:	6a 00                	push   $0x0
  80027f:	6a 00                	push   $0x0
  800281:	6a 00                	push   $0x0
  800283:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800286:	ba 01 00 00 00       	mov    $0x1,%edx
  80028b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800290:	e8 08 fe ff ff       	call   80009d <syscall>
}
  800295:	c9                   	leave  
  800296:	c3                   	ret    

00800297 <sys_get_priority>:

// Get priority of the current process
int
sys_get_priority(void)
{
  800297:	55                   	push   %ebp
  800298:	89 e5                	mov    %esp,%ebp
  80029a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_get_priority, 0, 0, 0, 0, 0, 0);
  80029d:	6a 00                	push   $0x0
  80029f:	6a 00                	push   $0x0
  8002a1:	6a 00                	push   $0x0
  8002a3:	6a 00                	push   $0x0
  8002a5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8002af:	b8 0d 00 00 00       	mov    $0xd,%eax
  8002b4:	e8 e4 fd ff ff       	call   80009d <syscall>
}
  8002b9:	c9                   	leave  
  8002ba:	c3                   	ret    

008002bb <sys_set_priority>:

// Get priority of the current process
int
sys_set_priority(unsigned int priority)
{
  8002bb:	55                   	push   %ebp
  8002bc:	89 e5                	mov    %esp,%ebp
  8002be:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, (uint32_t) priority, 0, 0, 0, 0);
  8002c1:	6a 00                	push   $0x0
  8002c3:	6a 00                	push   $0x0
  8002c5:	6a 00                	push   $0x0
  8002c7:	6a 00                	push   $0x0
  8002c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d1:	b8 0e 00 00 00       	mov    $0xe,%eax
  8002d6:	e8 c2 fd ff ff       	call   80009d <syscall>
}
  8002db:	c9                   	leave  
  8002dc:	c3                   	ret    

008002dd <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002dd:	55                   	push   %ebp
  8002de:	89 e5                	mov    %esp,%ebp
  8002e0:	56                   	push   %esi
  8002e1:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002e2:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002e5:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8002eb:	e8 62 fe ff ff       	call   800152 <sys_getenvid>
  8002f0:	83 ec 0c             	sub    $0xc,%esp
  8002f3:	ff 75 0c             	push   0xc(%ebp)
  8002f6:	ff 75 08             	push   0x8(%ebp)
  8002f9:	56                   	push   %esi
  8002fa:	50                   	push   %eax
  8002fb:	68 b8 0e 80 00       	push   $0x800eb8
  800300:	e8 b3 00 00 00       	call   8003b8 <cprintf>
	        sys_getenvid(),
	        binaryname,
	        file,
	        line);
	vcprintf(fmt, ap);
  800305:	83 c4 18             	add    $0x18,%esp
  800308:	53                   	push   %ebx
  800309:	ff 75 10             	push   0x10(%ebp)
  80030c:	e8 56 00 00 00       	call   800367 <vcprintf>
	cprintf("\n");
  800311:	c7 04 24 db 0e 80 00 	movl   $0x800edb,(%esp)
  800318:	e8 9b 00 00 00       	call   8003b8 <cprintf>
  80031d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800320:	cc                   	int3   
  800321:	eb fd                	jmp    800320 <_panic+0x43>

00800323 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800323:	55                   	push   %ebp
  800324:	89 e5                	mov    %esp,%ebp
  800326:	53                   	push   %ebx
  800327:	83 ec 04             	sub    $0x4,%esp
  80032a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80032d:	8b 13                	mov    (%ebx),%edx
  80032f:	8d 42 01             	lea    0x1(%edx),%eax
  800332:	89 03                	mov    %eax,(%ebx)
  800334:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800337:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256 - 1) {
  80033b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800340:	74 09                	je     80034b <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800342:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800346:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800349:	c9                   	leave  
  80034a:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80034b:	83 ec 08             	sub    $0x8,%esp
  80034e:	68 ff 00 00 00       	push   $0xff
  800353:	8d 43 08             	lea    0x8(%ebx),%eax
  800356:	50                   	push   %eax
  800357:	e8 8a fd ff ff       	call   8000e6 <sys_cputs>
		b->idx = 0;
  80035c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800362:	83 c4 10             	add    $0x10,%esp
  800365:	eb db                	jmp    800342 <putch+0x1f>

00800367 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800367:	55                   	push   %ebp
  800368:	89 e5                	mov    %esp,%ebp
  80036a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800370:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800377:	00 00 00 
	b.cnt = 0;
  80037a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800381:	00 00 00 
	vprintfmt((void *) putch, &b, fmt, ap);
  800384:	ff 75 0c             	push   0xc(%ebp)
  800387:	ff 75 08             	push   0x8(%ebp)
  80038a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800390:	50                   	push   %eax
  800391:	68 23 03 80 00       	push   $0x800323
  800396:	e8 74 01 00 00       	call   80050f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80039b:	83 c4 08             	add    $0x8,%esp
  80039e:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8003a4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003aa:	50                   	push   %eax
  8003ab:	e8 36 fd ff ff       	call   8000e6 <sys_cputs>

	return b.cnt;
}
  8003b0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003b6:	c9                   	leave  
  8003b7:	c3                   	ret    

008003b8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003b8:	55                   	push   %ebp
  8003b9:	89 e5                	mov    %esp,%ebp
  8003bb:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003be:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003c1:	50                   	push   %eax
  8003c2:	ff 75 08             	push   0x8(%ebp)
  8003c5:	e8 9d ff ff ff       	call   800367 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003ca:	c9                   	leave  
  8003cb:	c3                   	ret    

008003cc <printnum>:
         void *putdat,
         unsigned long long num,
         unsigned base,
         int width,
         int padc)
{
  8003cc:	55                   	push   %ebp
  8003cd:	89 e5                	mov    %esp,%ebp
  8003cf:	57                   	push   %edi
  8003d0:	56                   	push   %esi
  8003d1:	53                   	push   %ebx
  8003d2:	83 ec 1c             	sub    $0x1c,%esp
  8003d5:	89 c7                	mov    %eax,%edi
  8003d7:	89 d6                	mov    %edx,%esi
  8003d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8003dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003df:	89 d1                	mov    %edx,%ecx
  8003e1:	89 c2                	mov    %eax,%edx
  8003e3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003e6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8003e9:	8b 45 10             	mov    0x10(%ebp),%eax
  8003ec:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003ef:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003f2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003f9:	39 c2                	cmp    %eax,%edx
  8003fb:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8003fe:	72 3e                	jb     80043e <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800400:	83 ec 0c             	sub    $0xc,%esp
  800403:	ff 75 18             	push   0x18(%ebp)
  800406:	83 eb 01             	sub    $0x1,%ebx
  800409:	53                   	push   %ebx
  80040a:	50                   	push   %eax
  80040b:	83 ec 08             	sub    $0x8,%esp
  80040e:	ff 75 e4             	push   -0x1c(%ebp)
  800411:	ff 75 e0             	push   -0x20(%ebp)
  800414:	ff 75 dc             	push   -0x24(%ebp)
  800417:	ff 75 d8             	push   -0x28(%ebp)
  80041a:	e8 21 08 00 00       	call   800c40 <__udivdi3>
  80041f:	83 c4 18             	add    $0x18,%esp
  800422:	52                   	push   %edx
  800423:	50                   	push   %eax
  800424:	89 f2                	mov    %esi,%edx
  800426:	89 f8                	mov    %edi,%eax
  800428:	e8 9f ff ff ff       	call   8003cc <printnum>
  80042d:	83 c4 20             	add    $0x20,%esp
  800430:	eb 13                	jmp    800445 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800432:	83 ec 08             	sub    $0x8,%esp
  800435:	56                   	push   %esi
  800436:	ff 75 18             	push   0x18(%ebp)
  800439:	ff d7                	call   *%edi
  80043b:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80043e:	83 eb 01             	sub    $0x1,%ebx
  800441:	85 db                	test   %ebx,%ebx
  800443:	7f ed                	jg     800432 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800445:	83 ec 08             	sub    $0x8,%esp
  800448:	56                   	push   %esi
  800449:	83 ec 04             	sub    $0x4,%esp
  80044c:	ff 75 e4             	push   -0x1c(%ebp)
  80044f:	ff 75 e0             	push   -0x20(%ebp)
  800452:	ff 75 dc             	push   -0x24(%ebp)
  800455:	ff 75 d8             	push   -0x28(%ebp)
  800458:	e8 03 09 00 00       	call   800d60 <__umoddi3>
  80045d:	83 c4 14             	add    $0x14,%esp
  800460:	0f be 80 dd 0e 80 00 	movsbl 0x800edd(%eax),%eax
  800467:	50                   	push   %eax
  800468:	ff d7                	call   *%edi
}
  80046a:	83 c4 10             	add    $0x10,%esp
  80046d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800470:	5b                   	pop    %ebx
  800471:	5e                   	pop    %esi
  800472:	5f                   	pop    %edi
  800473:	5d                   	pop    %ebp
  800474:	c3                   	ret    

00800475 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800475:	83 fa 01             	cmp    $0x1,%edx
  800478:	7f 13                	jg     80048d <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80047a:	85 d2                	test   %edx,%edx
  80047c:	74 1c                	je     80049a <getuint+0x25>
		return va_arg(*ap, unsigned long);
  80047e:	8b 10                	mov    (%eax),%edx
  800480:	8d 4a 04             	lea    0x4(%edx),%ecx
  800483:	89 08                	mov    %ecx,(%eax)
  800485:	8b 02                	mov    (%edx),%eax
  800487:	ba 00 00 00 00       	mov    $0x0,%edx
  80048c:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  80048d:	8b 10                	mov    (%eax),%edx
  80048f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800492:	89 08                	mov    %ecx,(%eax)
  800494:	8b 02                	mov    (%edx),%eax
  800496:	8b 52 04             	mov    0x4(%edx),%edx
  800499:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  80049a:	8b 10                	mov    (%eax),%edx
  80049c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80049f:	89 08                	mov    %ecx,(%eax)
  8004a1:	8b 02                	mov    (%edx),%eax
  8004a3:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004a8:	c3                   	ret    

008004a9 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004a9:	83 fa 01             	cmp    $0x1,%edx
  8004ac:	7f 0f                	jg     8004bd <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  8004ae:	85 d2                	test   %edx,%edx
  8004b0:	74 18                	je     8004ca <getint+0x21>
		return va_arg(*ap, long);
  8004b2:	8b 10                	mov    (%eax),%edx
  8004b4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004b7:	89 08                	mov    %ecx,(%eax)
  8004b9:	8b 02                	mov    (%edx),%eax
  8004bb:	99                   	cltd   
  8004bc:	c3                   	ret    
		return va_arg(*ap, long long);
  8004bd:	8b 10                	mov    (%eax),%edx
  8004bf:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004c2:	89 08                	mov    %ecx,(%eax)
  8004c4:	8b 02                	mov    (%edx),%eax
  8004c6:	8b 52 04             	mov    0x4(%edx),%edx
  8004c9:	c3                   	ret    
	else
		return va_arg(*ap, int);
  8004ca:	8b 10                	mov    (%eax),%edx
  8004cc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004cf:	89 08                	mov    %ecx,(%eax)
  8004d1:	8b 02                	mov    (%edx),%eax
  8004d3:	99                   	cltd   
}
  8004d4:	c3                   	ret    

008004d5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004d5:	55                   	push   %ebp
  8004d6:	89 e5                	mov    %esp,%ebp
  8004d8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004db:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004df:	8b 10                	mov    (%eax),%edx
  8004e1:	3b 50 04             	cmp    0x4(%eax),%edx
  8004e4:	73 0a                	jae    8004f0 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004e6:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004e9:	89 08                	mov    %ecx,(%eax)
  8004eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ee:	88 02                	mov    %al,(%edx)
}
  8004f0:	5d                   	pop    %ebp
  8004f1:	c3                   	ret    

008004f2 <printfmt>:
{
  8004f2:	55                   	push   %ebp
  8004f3:	89 e5                	mov    %esp,%ebp
  8004f5:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8004f8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004fb:	50                   	push   %eax
  8004fc:	ff 75 10             	push   0x10(%ebp)
  8004ff:	ff 75 0c             	push   0xc(%ebp)
  800502:	ff 75 08             	push   0x8(%ebp)
  800505:	e8 05 00 00 00       	call   80050f <vprintfmt>
}
  80050a:	83 c4 10             	add    $0x10,%esp
  80050d:	c9                   	leave  
  80050e:	c3                   	ret    

0080050f <vprintfmt>:
{
  80050f:	55                   	push   %ebp
  800510:	89 e5                	mov    %esp,%ebp
  800512:	57                   	push   %edi
  800513:	56                   	push   %esi
  800514:	53                   	push   %ebx
  800515:	83 ec 2c             	sub    $0x2c,%esp
  800518:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80051b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80051e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800521:	eb 0a                	jmp    80052d <vprintfmt+0x1e>
			putch(ch, putdat);
  800523:	83 ec 08             	sub    $0x8,%esp
  800526:	56                   	push   %esi
  800527:	50                   	push   %eax
  800528:	ff d3                	call   *%ebx
  80052a:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80052d:	83 c7 01             	add    $0x1,%edi
  800530:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800534:	83 f8 25             	cmp    $0x25,%eax
  800537:	74 0c                	je     800545 <vprintfmt+0x36>
			if (ch == '\0')
  800539:	85 c0                	test   %eax,%eax
  80053b:	75 e6                	jne    800523 <vprintfmt+0x14>
}
  80053d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800540:	5b                   	pop    %ebx
  800541:	5e                   	pop    %esi
  800542:	5f                   	pop    %edi
  800543:	5d                   	pop    %ebp
  800544:	c3                   	ret    
		padc = ' ';
  800545:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
		altflag = 0;
  800549:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800550:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800557:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80055e:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800563:	8d 47 01             	lea    0x1(%edi),%eax
  800566:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800569:	0f b6 17             	movzbl (%edi),%edx
  80056c:	8d 42 dd             	lea    -0x23(%edx),%eax
  80056f:	3c 55                	cmp    $0x55,%al
  800571:	0f 87 b7 02 00 00    	ja     80082e <vprintfmt+0x31f>
  800577:	0f b6 c0             	movzbl %al,%eax
  80057a:	ff 24 85 a0 0f 80 00 	jmp    *0x800fa0(,%eax,4)
  800581:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800584:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800588:	eb d9                	jmp    800563 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80058a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80058d:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800591:	eb d0                	jmp    800563 <vprintfmt+0x54>
  800593:	0f b6 d2             	movzbl %dl,%edx
  800596:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0;; ++fmt) {
  800599:	b8 00 00 00 00       	mov    $0x0,%eax
  80059e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8005a1:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005a4:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8005a8:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8005ab:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8005ae:	83 f9 09             	cmp    $0x9,%ecx
  8005b1:	77 52                	ja     800605 <vprintfmt+0xf6>
			for (precision = 0;; ++fmt) {
  8005b3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8005b6:	eb e9                	jmp    8005a1 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  8005b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bb:	8d 50 04             	lea    0x4(%eax),%edx
  8005be:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c1:	8b 00                	mov    (%eax),%eax
  8005c3:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8005c9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005cd:	79 94                	jns    800563 <vprintfmt+0x54>
				width = precision, precision = -1;
  8005cf:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005d2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005d5:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8005dc:	eb 85                	jmp    800563 <vprintfmt+0x54>
  8005de:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005e1:	85 d2                	test   %edx,%edx
  8005e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8005e8:	0f 49 c2             	cmovns %edx,%eax
  8005eb:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005f1:	e9 6d ff ff ff       	jmp    800563 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8005f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8005f9:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800600:	e9 5e ff ff ff       	jmp    800563 <vprintfmt+0x54>
  800605:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800608:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80060b:	eb bc                	jmp    8005c9 <vprintfmt+0xba>
			lflag++;
  80060d:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800610:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800613:	e9 4b ff ff ff       	jmp    800563 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800618:	8b 45 14             	mov    0x14(%ebp),%eax
  80061b:	8d 50 04             	lea    0x4(%eax),%edx
  80061e:	89 55 14             	mov    %edx,0x14(%ebp)
  800621:	83 ec 08             	sub    $0x8,%esp
  800624:	56                   	push   %esi
  800625:	ff 30                	push   (%eax)
  800627:	ff d3                	call   *%ebx
			break;
  800629:	83 c4 10             	add    $0x10,%esp
  80062c:	e9 94 01 00 00       	jmp    8007c5 <vprintfmt+0x2b6>
			err = va_arg(ap, int);
  800631:	8b 45 14             	mov    0x14(%ebp),%eax
  800634:	8d 50 04             	lea    0x4(%eax),%edx
  800637:	89 55 14             	mov    %edx,0x14(%ebp)
  80063a:	8b 10                	mov    (%eax),%edx
  80063c:	89 d0                	mov    %edx,%eax
  80063e:	f7 d8                	neg    %eax
  800640:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800643:	83 f8 08             	cmp    $0x8,%eax
  800646:	7f 20                	jg     800668 <vprintfmt+0x159>
  800648:	8b 14 85 00 11 80 00 	mov    0x801100(,%eax,4),%edx
  80064f:	85 d2                	test   %edx,%edx
  800651:	74 15                	je     800668 <vprintfmt+0x159>
				printfmt(putch, putdat, "%s", p);
  800653:	52                   	push   %edx
  800654:	68 fe 0e 80 00       	push   $0x800efe
  800659:	56                   	push   %esi
  80065a:	53                   	push   %ebx
  80065b:	e8 92 fe ff ff       	call   8004f2 <printfmt>
  800660:	83 c4 10             	add    $0x10,%esp
  800663:	e9 5d 01 00 00       	jmp    8007c5 <vprintfmt+0x2b6>
				printfmt(putch, putdat, "error %d", err);
  800668:	50                   	push   %eax
  800669:	68 f5 0e 80 00       	push   $0x800ef5
  80066e:	56                   	push   %esi
  80066f:	53                   	push   %ebx
  800670:	e8 7d fe ff ff       	call   8004f2 <printfmt>
  800675:	83 c4 10             	add    $0x10,%esp
  800678:	e9 48 01 00 00       	jmp    8007c5 <vprintfmt+0x2b6>
			if ((p = va_arg(ap, char *)) == NULL)
  80067d:	8b 45 14             	mov    0x14(%ebp),%eax
  800680:	8d 50 04             	lea    0x4(%eax),%edx
  800683:	89 55 14             	mov    %edx,0x14(%ebp)
  800686:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800688:	85 ff                	test   %edi,%edi
  80068a:	b8 ee 0e 80 00       	mov    $0x800eee,%eax
  80068f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800692:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800696:	7e 06                	jle    80069e <vprintfmt+0x18f>
  800698:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  80069c:	75 0a                	jne    8006a8 <vprintfmt+0x199>
  80069e:	89 f8                	mov    %edi,%eax
  8006a0:	03 45 e0             	add    -0x20(%ebp),%eax
  8006a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006a6:	eb 59                	jmp    800701 <vprintfmt+0x1f2>
				for (width -= strnlen(p, precision); width > 0;
  8006a8:	83 ec 08             	sub    $0x8,%esp
  8006ab:	ff 75 d8             	push   -0x28(%ebp)
  8006ae:	57                   	push   %edi
  8006af:	e8 1a 02 00 00       	call   8008ce <strnlen>
  8006b4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006b7:	29 c1                	sub    %eax,%ecx
  8006b9:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006bc:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006bf:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  8006c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006c6:	89 7d d0             	mov    %edi,-0x30(%ebp)
  8006c9:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0;
  8006cb:	eb 0f                	jmp    8006dc <vprintfmt+0x1cd>
					putch(padc, putdat);
  8006cd:	83 ec 08             	sub    $0x8,%esp
  8006d0:	56                   	push   %esi
  8006d1:	ff 75 e0             	push   -0x20(%ebp)
  8006d4:	ff d3                	call   *%ebx
				     width--)
  8006d6:	83 ef 01             	sub    $0x1,%edi
  8006d9:	83 c4 10             	add    $0x10,%esp
				for (width -= strnlen(p, precision); width > 0;
  8006dc:	85 ff                	test   %edi,%edi
  8006de:	7f ed                	jg     8006cd <vprintfmt+0x1be>
  8006e0:	8b 7d d0             	mov    -0x30(%ebp),%edi
  8006e3:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006e6:	85 c9                	test   %ecx,%ecx
  8006e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ed:	0f 49 c1             	cmovns %ecx,%eax
  8006f0:	29 c1                	sub    %eax,%ecx
  8006f2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8006f5:	eb a7                	jmp    80069e <vprintfmt+0x18f>
					putch(ch, putdat);
  8006f7:	83 ec 08             	sub    $0x8,%esp
  8006fa:	56                   	push   %esi
  8006fb:	52                   	push   %edx
  8006fc:	ff d3                	call   *%ebx
  8006fe:	83 c4 10             	add    $0x10,%esp
  800701:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800704:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' &&
  800706:	83 c7 01             	add    $0x1,%edi
  800709:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80070d:	0f be d0             	movsbl %al,%edx
  800710:	85 d2                	test   %edx,%edx
  800712:	74 42                	je     800756 <vprintfmt+0x247>
  800714:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800718:	78 06                	js     800720 <vprintfmt+0x211>
			       (precision < 0 || --precision >= 0);
  80071a:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80071e:	78 1e                	js     80073e <vprintfmt+0x22f>
				if (altflag && (ch < ' ' || ch > '~'))
  800720:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800724:	74 d1                	je     8006f7 <vprintfmt+0x1e8>
  800726:	0f be c0             	movsbl %al,%eax
  800729:	83 e8 20             	sub    $0x20,%eax
  80072c:	83 f8 5e             	cmp    $0x5e,%eax
  80072f:	76 c6                	jbe    8006f7 <vprintfmt+0x1e8>
					putch('?', putdat);
  800731:	83 ec 08             	sub    $0x8,%esp
  800734:	56                   	push   %esi
  800735:	6a 3f                	push   $0x3f
  800737:	ff d3                	call   *%ebx
  800739:	83 c4 10             	add    $0x10,%esp
  80073c:	eb c3                	jmp    800701 <vprintfmt+0x1f2>
  80073e:	89 cf                	mov    %ecx,%edi
  800740:	eb 0e                	jmp    800750 <vprintfmt+0x241>
				putch(' ', putdat);
  800742:	83 ec 08             	sub    $0x8,%esp
  800745:	56                   	push   %esi
  800746:	6a 20                	push   $0x20
  800748:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  80074a:	83 ef 01             	sub    $0x1,%edi
  80074d:	83 c4 10             	add    $0x10,%esp
  800750:	85 ff                	test   %edi,%edi
  800752:	7f ee                	jg     800742 <vprintfmt+0x233>
  800754:	eb 6f                	jmp    8007c5 <vprintfmt+0x2b6>
  800756:	89 cf                	mov    %ecx,%edi
  800758:	eb f6                	jmp    800750 <vprintfmt+0x241>
			num = getint(&ap, lflag);
  80075a:	89 ca                	mov    %ecx,%edx
  80075c:	8d 45 14             	lea    0x14(%ebp),%eax
  80075f:	e8 45 fd ff ff       	call   8004a9 <getint>
  800764:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800767:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  80076a:	85 d2                	test   %edx,%edx
  80076c:	78 0b                	js     800779 <vprintfmt+0x26a>
			num = getint(&ap, lflag);
  80076e:	89 d1                	mov    %edx,%ecx
  800770:	89 c2                	mov    %eax,%edx
			base = 10;
  800772:	bf 0a 00 00 00       	mov    $0xa,%edi
  800777:	eb 32                	jmp    8007ab <vprintfmt+0x29c>
				putch('-', putdat);
  800779:	83 ec 08             	sub    $0x8,%esp
  80077c:	56                   	push   %esi
  80077d:	6a 2d                	push   $0x2d
  80077f:	ff d3                	call   *%ebx
				num = -(long long) num;
  800781:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800784:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800787:	f7 da                	neg    %edx
  800789:	83 d1 00             	adc    $0x0,%ecx
  80078c:	f7 d9                	neg    %ecx
  80078e:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800791:	bf 0a 00 00 00       	mov    $0xa,%edi
  800796:	eb 13                	jmp    8007ab <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  800798:	89 ca                	mov    %ecx,%edx
  80079a:	8d 45 14             	lea    0x14(%ebp),%eax
  80079d:	e8 d3 fc ff ff       	call   800475 <getuint>
  8007a2:	89 d1                	mov    %edx,%ecx
  8007a4:	89 c2                	mov    %eax,%edx
			base = 10;
  8007a6:	bf 0a 00 00 00       	mov    $0xa,%edi
			printnum(putch, putdat, num, base, width, padc);
  8007ab:	83 ec 0c             	sub    $0xc,%esp
  8007ae:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  8007b2:	50                   	push   %eax
  8007b3:	ff 75 e0             	push   -0x20(%ebp)
  8007b6:	57                   	push   %edi
  8007b7:	51                   	push   %ecx
  8007b8:	52                   	push   %edx
  8007b9:	89 f2                	mov    %esi,%edx
  8007bb:	89 d8                	mov    %ebx,%eax
  8007bd:	e8 0a fc ff ff       	call   8003cc <printnum>
			break;
  8007c2:	83 c4 20             	add    $0x20,%esp
{
  8007c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007c8:	e9 60 fd ff ff       	jmp    80052d <vprintfmt+0x1e>
			num = getuint(&ap, lflag);
  8007cd:	89 ca                	mov    %ecx,%edx
  8007cf:	8d 45 14             	lea    0x14(%ebp),%eax
  8007d2:	e8 9e fc ff ff       	call   800475 <getuint>
  8007d7:	89 d1                	mov    %edx,%ecx
  8007d9:	89 c2                	mov    %eax,%edx
			base = 8;
  8007db:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  8007e0:	eb c9                	jmp    8007ab <vprintfmt+0x29c>
			putch('0', putdat);
  8007e2:	83 ec 08             	sub    $0x8,%esp
  8007e5:	56                   	push   %esi
  8007e6:	6a 30                	push   $0x30
  8007e8:	ff d3                	call   *%ebx
			putch('x', putdat);
  8007ea:	83 c4 08             	add    $0x8,%esp
  8007ed:	56                   	push   %esi
  8007ee:	6a 78                	push   $0x78
  8007f0:	ff d3                	call   *%ebx
			num = (unsigned long long) (uintptr_t) va_arg(ap, void *);
  8007f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f5:	8d 50 04             	lea    0x4(%eax),%edx
  8007f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8007fb:	8b 10                	mov    (%eax),%edx
  8007fd:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800802:	83 c4 10             	add    $0x10,%esp
			base = 16;
  800805:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  80080a:	eb 9f                	jmp    8007ab <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  80080c:	89 ca                	mov    %ecx,%edx
  80080e:	8d 45 14             	lea    0x14(%ebp),%eax
  800811:	e8 5f fc ff ff       	call   800475 <getuint>
  800816:	89 d1                	mov    %edx,%ecx
  800818:	89 c2                	mov    %eax,%edx
			base = 16;
  80081a:	bf 10 00 00 00       	mov    $0x10,%edi
  80081f:	eb 8a                	jmp    8007ab <vprintfmt+0x29c>
			putch(ch, putdat);
  800821:	83 ec 08             	sub    $0x8,%esp
  800824:	56                   	push   %esi
  800825:	6a 25                	push   $0x25
  800827:	ff d3                	call   *%ebx
			break;
  800829:	83 c4 10             	add    $0x10,%esp
  80082c:	eb 97                	jmp    8007c5 <vprintfmt+0x2b6>
			putch('%', putdat);
  80082e:	83 ec 08             	sub    $0x8,%esp
  800831:	56                   	push   %esi
  800832:	6a 25                	push   $0x25
  800834:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  800836:	83 c4 10             	add    $0x10,%esp
  800839:	89 f8                	mov    %edi,%eax
  80083b:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80083f:	74 05                	je     800846 <vprintfmt+0x337>
  800841:	83 e8 01             	sub    $0x1,%eax
  800844:	eb f5                	jmp    80083b <vprintfmt+0x32c>
  800846:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800849:	e9 77 ff ff ff       	jmp    8007c5 <vprintfmt+0x2b6>

0080084e <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80084e:	55                   	push   %ebp
  80084f:	89 e5                	mov    %esp,%ebp
  800851:	83 ec 18             	sub    $0x18,%esp
  800854:	8b 45 08             	mov    0x8(%ebp),%eax
  800857:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = { buf, buf + n - 1, 0 };
  80085a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80085d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800861:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800864:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80086b:	85 c0                	test   %eax,%eax
  80086d:	74 26                	je     800895 <vsnprintf+0x47>
  80086f:	85 d2                	test   %edx,%edx
  800871:	7e 22                	jle    800895 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *) sprintputch, &b, fmt, ap);
  800873:	ff 75 14             	push   0x14(%ebp)
  800876:	ff 75 10             	push   0x10(%ebp)
  800879:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80087c:	50                   	push   %eax
  80087d:	68 d5 04 80 00       	push   $0x8004d5
  800882:	e8 88 fc ff ff       	call   80050f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800887:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80088a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80088d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800890:	83 c4 10             	add    $0x10,%esp
}
  800893:	c9                   	leave  
  800894:	c3                   	ret    
		return -E_INVAL;
  800895:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80089a:	eb f7                	jmp    800893 <vsnprintf+0x45>

0080089c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80089c:	55                   	push   %ebp
  80089d:	89 e5                	mov    %esp,%ebp
  80089f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008a2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008a5:	50                   	push   %eax
  8008a6:	ff 75 10             	push   0x10(%ebp)
  8008a9:	ff 75 0c             	push   0xc(%ebp)
  8008ac:	ff 75 08             	push   0x8(%ebp)
  8008af:	e8 9a ff ff ff       	call   80084e <vsnprintf>
	va_end(ap);

	return rc;
}
  8008b4:	c9                   	leave  
  8008b5:	c3                   	ret    

008008b6 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008b6:	55                   	push   %ebp
  8008b7:	89 e5                	mov    %esp,%ebp
  8008b9:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c1:	eb 03                	jmp    8008c6 <strlen+0x10>
		n++;
  8008c3:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008c6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008ca:	75 f7                	jne    8008c3 <strlen+0xd>
	return n;
}
  8008cc:	5d                   	pop    %ebp
  8008cd:	c3                   	ret    

008008ce <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008ce:	55                   	push   %ebp
  8008cf:	89 e5                	mov    %esp,%ebp
  8008d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008d4:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8008dc:	eb 03                	jmp    8008e1 <strnlen+0x13>
		n++;
  8008de:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008e1:	39 d0                	cmp    %edx,%eax
  8008e3:	74 08                	je     8008ed <strnlen+0x1f>
  8008e5:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008e9:	75 f3                	jne    8008de <strnlen+0x10>
  8008eb:	89 c2                	mov    %eax,%edx
	return n;
}
  8008ed:	89 d0                	mov    %edx,%eax
  8008ef:	5d                   	pop    %ebp
  8008f0:	c3                   	ret    

008008f1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008f1:	55                   	push   %ebp
  8008f2:	89 e5                	mov    %esp,%ebp
  8008f4:	53                   	push   %ebx
  8008f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800900:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800904:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800907:	83 c0 01             	add    $0x1,%eax
  80090a:	84 d2                	test   %dl,%dl
  80090c:	75 f2                	jne    800900 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80090e:	89 c8                	mov    %ecx,%eax
  800910:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800913:	c9                   	leave  
  800914:	c3                   	ret    

00800915 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800915:	55                   	push   %ebp
  800916:	89 e5                	mov    %esp,%ebp
  800918:	53                   	push   %ebx
  800919:	83 ec 10             	sub    $0x10,%esp
  80091c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80091f:	53                   	push   %ebx
  800920:	e8 91 ff ff ff       	call   8008b6 <strlen>
  800925:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800928:	ff 75 0c             	push   0xc(%ebp)
  80092b:	01 d8                	add    %ebx,%eax
  80092d:	50                   	push   %eax
  80092e:	e8 be ff ff ff       	call   8008f1 <strcpy>
	return dst;
}
  800933:	89 d8                	mov    %ebx,%eax
  800935:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800938:	c9                   	leave  
  800939:	c3                   	ret    

0080093a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	56                   	push   %esi
  80093e:	53                   	push   %ebx
  80093f:	8b 75 08             	mov    0x8(%ebp),%esi
  800942:	8b 55 0c             	mov    0xc(%ebp),%edx
  800945:	89 f3                	mov    %esi,%ebx
  800947:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80094a:	89 f0                	mov    %esi,%eax
  80094c:	eb 0f                	jmp    80095d <strncpy+0x23>
		*dst++ = *src;
  80094e:	83 c0 01             	add    $0x1,%eax
  800951:	0f b6 0a             	movzbl (%edx),%ecx
  800954:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800957:	80 f9 01             	cmp    $0x1,%cl
  80095a:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  80095d:	39 d8                	cmp    %ebx,%eax
  80095f:	75 ed                	jne    80094e <strncpy+0x14>
	}
	return ret;
}
  800961:	89 f0                	mov    %esi,%eax
  800963:	5b                   	pop    %ebx
  800964:	5e                   	pop    %esi
  800965:	5d                   	pop    %ebp
  800966:	c3                   	ret    

00800967 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800967:	55                   	push   %ebp
  800968:	89 e5                	mov    %esp,%ebp
  80096a:	56                   	push   %esi
  80096b:	53                   	push   %ebx
  80096c:	8b 75 08             	mov    0x8(%ebp),%esi
  80096f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800972:	8b 55 10             	mov    0x10(%ebp),%edx
  800975:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800977:	85 d2                	test   %edx,%edx
  800979:	74 21                	je     80099c <strlcpy+0x35>
  80097b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80097f:	89 f2                	mov    %esi,%edx
  800981:	eb 09                	jmp    80098c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800983:	83 c1 01             	add    $0x1,%ecx
  800986:	83 c2 01             	add    $0x1,%edx
  800989:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  80098c:	39 c2                	cmp    %eax,%edx
  80098e:	74 09                	je     800999 <strlcpy+0x32>
  800990:	0f b6 19             	movzbl (%ecx),%ebx
  800993:	84 db                	test   %bl,%bl
  800995:	75 ec                	jne    800983 <strlcpy+0x1c>
  800997:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800999:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80099c:	29 f0                	sub    %esi,%eax
}
  80099e:	5b                   	pop    %ebx
  80099f:	5e                   	pop    %esi
  8009a0:	5d                   	pop    %ebp
  8009a1:	c3                   	ret    

008009a2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009a2:	55                   	push   %ebp
  8009a3:	89 e5                	mov    %esp,%ebp
  8009a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009ab:	eb 06                	jmp    8009b3 <strcmp+0x11>
		p++, q++;
  8009ad:	83 c1 01             	add    $0x1,%ecx
  8009b0:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8009b3:	0f b6 01             	movzbl (%ecx),%eax
  8009b6:	84 c0                	test   %al,%al
  8009b8:	74 04                	je     8009be <strcmp+0x1c>
  8009ba:	3a 02                	cmp    (%edx),%al
  8009bc:	74 ef                	je     8009ad <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009be:	0f b6 c0             	movzbl %al,%eax
  8009c1:	0f b6 12             	movzbl (%edx),%edx
  8009c4:	29 d0                	sub    %edx,%eax
}
  8009c6:	5d                   	pop    %ebp
  8009c7:	c3                   	ret    

008009c8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009c8:	55                   	push   %ebp
  8009c9:	89 e5                	mov    %esp,%ebp
  8009cb:	53                   	push   %ebx
  8009cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d2:	89 c3                	mov    %eax,%ebx
  8009d4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009d7:	eb 06                	jmp    8009df <strncmp+0x17>
		n--, p++, q++;
  8009d9:	83 c0 01             	add    $0x1,%eax
  8009dc:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009df:	39 d8                	cmp    %ebx,%eax
  8009e1:	74 18                	je     8009fb <strncmp+0x33>
  8009e3:	0f b6 08             	movzbl (%eax),%ecx
  8009e6:	84 c9                	test   %cl,%cl
  8009e8:	74 04                	je     8009ee <strncmp+0x26>
  8009ea:	3a 0a                	cmp    (%edx),%cl
  8009ec:	74 eb                	je     8009d9 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009ee:	0f b6 00             	movzbl (%eax),%eax
  8009f1:	0f b6 12             	movzbl (%edx),%edx
  8009f4:	29 d0                	sub    %edx,%eax
}
  8009f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009f9:	c9                   	leave  
  8009fa:	c3                   	ret    
		return 0;
  8009fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800a00:	eb f4                	jmp    8009f6 <strncmp+0x2e>

00800a02 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a02:	55                   	push   %ebp
  800a03:	89 e5                	mov    %esp,%ebp
  800a05:	8b 45 08             	mov    0x8(%ebp),%eax
  800a08:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a0c:	eb 03                	jmp    800a11 <strchr+0xf>
  800a0e:	83 c0 01             	add    $0x1,%eax
  800a11:	0f b6 10             	movzbl (%eax),%edx
  800a14:	84 d2                	test   %dl,%dl
  800a16:	74 06                	je     800a1e <strchr+0x1c>
		if (*s == c)
  800a18:	38 ca                	cmp    %cl,%dl
  800a1a:	75 f2                	jne    800a0e <strchr+0xc>
  800a1c:	eb 05                	jmp    800a23 <strchr+0x21>
			return (char *) s;
	return 0;
  800a1e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a23:	5d                   	pop    %ebp
  800a24:	c3                   	ret    

00800a25 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a25:	55                   	push   %ebp
  800a26:	89 e5                	mov    %esp,%ebp
  800a28:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a2f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a32:	38 ca                	cmp    %cl,%dl
  800a34:	74 09                	je     800a3f <strfind+0x1a>
  800a36:	84 d2                	test   %dl,%dl
  800a38:	74 05                	je     800a3f <strfind+0x1a>
	for (; *s; s++)
  800a3a:	83 c0 01             	add    $0x1,%eax
  800a3d:	eb f0                	jmp    800a2f <strfind+0xa>
			break;
	return (char *) s;
}
  800a3f:	5d                   	pop    %ebp
  800a40:	c3                   	ret    

00800a41 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a41:	55                   	push   %ebp
  800a42:	89 e5                	mov    %esp,%ebp
  800a44:	57                   	push   %edi
  800a45:	56                   	push   %esi
  800a46:	53                   	push   %ebx
  800a47:	8b 55 08             	mov    0x8(%ebp),%edx
  800a4a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  800a4d:	85 c9                	test   %ecx,%ecx
  800a4f:	74 33                	je     800a84 <memset+0x43>
		return v;
	if ((int) v % 4 == 0 && n % 4 == 0) {
  800a51:	89 d0                	mov    %edx,%eax
  800a53:	09 c8                	or     %ecx,%eax
  800a55:	a8 03                	test   $0x3,%al
  800a57:	75 23                	jne    800a7c <memset+0x3b>
		c &= 0xFF;
  800a59:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  800a5d:	89 d8                	mov    %ebx,%eax
  800a5f:	c1 e0 08             	shl    $0x8,%eax
  800a62:	89 df                	mov    %ebx,%edi
  800a64:	c1 e7 18             	shl    $0x18,%edi
  800a67:	89 de                	mov    %ebx,%esi
  800a69:	c1 e6 10             	shl    $0x10,%esi
  800a6c:	09 f7                	or     %esi,%edi
  800a6e:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
		             : "=D"(p), "=c"(n)
		             : "D"(p), "a"(c), "c"(n / 4)
  800a70:	c1 e9 02             	shr    $0x2,%ecx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  800a73:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800a75:	89 d7                	mov    %edx,%edi
  800a77:	fc                   	cld    
  800a78:	f3 ab                	rep stos %eax,%es:(%edi)
  800a7a:	eb 08                	jmp    800a84 <memset+0x43>
		             : "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a7c:	89 d7                	mov    %edx,%edi
  800a7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a81:	fc                   	cld    
  800a82:	f3 aa                	rep stos %al,%es:(%edi)
		             : "=D"(p), "=c"(n)
		             : "0"(p), "a"(c), "1"(n)
		             : "cc", "memory");
	return v;
}
  800a84:	89 d0                	mov    %edx,%eax
  800a86:	5b                   	pop    %ebx
  800a87:	5e                   	pop    %esi
  800a88:	5f                   	pop    %edi
  800a89:	5d                   	pop    %ebp
  800a8a:	c3                   	ret    

00800a8b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
  800a8e:	57                   	push   %edi
  800a8f:	56                   	push   %esi
  800a90:	8b 45 08             	mov    0x8(%ebp),%eax
  800a93:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a96:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a99:	39 c6                	cmp    %eax,%esi
  800a9b:	73 32                	jae    800acf <memmove+0x44>
  800a9d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800aa0:	39 c2                	cmp    %eax,%edx
  800aa2:	76 2b                	jbe    800acf <memmove+0x44>
		s += n;
		d += n;
  800aa4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  800aa7:	89 d6                	mov    %edx,%esi
  800aa9:	09 fe                	or     %edi,%esi
  800aab:	09 ce                	or     %ecx,%esi
  800aad:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ab3:	75 0e                	jne    800ac3 <memmove+0x38>
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  800ab5:	83 ef 04             	sub    $0x4,%edi
			             "S"(s - 4),
  800ab8:	8d 72 fc             	lea    -0x4(%edx),%esi
			             "c"(n / 4)
  800abb:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  800abe:	fd                   	std    
  800abf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ac1:	eb 09                	jmp    800acc <memmove+0x41>
			             : "cc", "memory");
		else
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  800ac3:	83 ef 01             	sub    $0x1,%edi
			             "S"(s - 1),
  800ac6:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  800ac9:	fd                   	std    
  800aca:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             "c"(n)
			             : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800acc:	fc                   	cld    
  800acd:	eb 1a                	jmp    800ae9 <memmove+0x5e>
	} else {
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  800acf:	89 f2                	mov    %esi,%edx
  800ad1:	09 c2                	or     %eax,%edx
  800ad3:	09 ca                	or     %ecx,%edx
  800ad5:	f6 c2 03             	test   $0x3,%dl
  800ad8:	75 0a                	jne    800ae4 <memmove+0x59>
			asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800ada:	c1 e9 02             	shr    $0x2,%ecx
  800add:	89 c7                	mov    %eax,%edi
  800adf:	fc                   	cld    
  800ae0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ae2:	eb 05                	jmp    800ae9 <memmove+0x5e>
			             : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800ae4:	89 c7                	mov    %eax,%edi
  800ae6:	fc                   	cld    
  800ae7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             : "cc", "memory");
	}
	return dst;
}
  800ae9:	5e                   	pop    %esi
  800aea:	5f                   	pop    %edi
  800aeb:	5d                   	pop    %ebp
  800aec:	c3                   	ret    

00800aed <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aed:	55                   	push   %ebp
  800aee:	89 e5                	mov    %esp,%ebp
  800af0:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800af3:	ff 75 10             	push   0x10(%ebp)
  800af6:	ff 75 0c             	push   0xc(%ebp)
  800af9:	ff 75 08             	push   0x8(%ebp)
  800afc:	e8 8a ff ff ff       	call   800a8b <memmove>
}
  800b01:	c9                   	leave  
  800b02:	c3                   	ret    

00800b03 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b03:	55                   	push   %ebp
  800b04:	89 e5                	mov    %esp,%ebp
  800b06:	56                   	push   %esi
  800b07:	53                   	push   %ebx
  800b08:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b0e:	89 c6                	mov    %eax,%esi
  800b10:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b13:	eb 06                	jmp    800b1b <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b15:	83 c0 01             	add    $0x1,%eax
  800b18:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800b1b:	39 f0                	cmp    %esi,%eax
  800b1d:	74 14                	je     800b33 <memcmp+0x30>
		if (*s1 != *s2)
  800b1f:	0f b6 08             	movzbl (%eax),%ecx
  800b22:	0f b6 1a             	movzbl (%edx),%ebx
  800b25:	38 d9                	cmp    %bl,%cl
  800b27:	74 ec                	je     800b15 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800b29:	0f b6 c1             	movzbl %cl,%eax
  800b2c:	0f b6 db             	movzbl %bl,%ebx
  800b2f:	29 d8                	sub    %ebx,%eax
  800b31:	eb 05                	jmp    800b38 <memcmp+0x35>
	}

	return 0;
  800b33:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b38:	5b                   	pop    %ebx
  800b39:	5e                   	pop    %esi
  800b3a:	5d                   	pop    %ebp
  800b3b:	c3                   	ret    

00800b3c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b45:	89 c2                	mov    %eax,%edx
  800b47:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b4a:	eb 03                	jmp    800b4f <memfind+0x13>
  800b4c:	83 c0 01             	add    $0x1,%eax
  800b4f:	39 d0                	cmp    %edx,%eax
  800b51:	73 04                	jae    800b57 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b53:	38 08                	cmp    %cl,(%eax)
  800b55:	75 f5                	jne    800b4c <memfind+0x10>
			break;
	return (void *) s;
}
  800b57:	5d                   	pop    %ebp
  800b58:	c3                   	ret    

00800b59 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b59:	55                   	push   %ebp
  800b5a:	89 e5                	mov    %esp,%ebp
  800b5c:	57                   	push   %edi
  800b5d:	56                   	push   %esi
  800b5e:	53                   	push   %ebx
  800b5f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b62:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b65:	eb 03                	jmp    800b6a <strtol+0x11>
		s++;
  800b67:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b6a:	0f b6 02             	movzbl (%edx),%eax
  800b6d:	3c 20                	cmp    $0x20,%al
  800b6f:	74 f6                	je     800b67 <strtol+0xe>
  800b71:	3c 09                	cmp    $0x9,%al
  800b73:	74 f2                	je     800b67 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b75:	3c 2b                	cmp    $0x2b,%al
  800b77:	74 2a                	je     800ba3 <strtol+0x4a>
	int neg = 0;
  800b79:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b7e:	3c 2d                	cmp    $0x2d,%al
  800b80:	74 2b                	je     800bad <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b82:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b88:	75 0f                	jne    800b99 <strtol+0x40>
  800b8a:	80 3a 30             	cmpb   $0x30,(%edx)
  800b8d:	74 28                	je     800bb7 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b8f:	85 db                	test   %ebx,%ebx
  800b91:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b96:	0f 44 d8             	cmove  %eax,%ebx
  800b99:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b9e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800ba1:	eb 46                	jmp    800be9 <strtol+0x90>
		s++;
  800ba3:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800ba6:	bf 00 00 00 00       	mov    $0x0,%edi
  800bab:	eb d5                	jmp    800b82 <strtol+0x29>
		s++, neg = 1;
  800bad:	83 c2 01             	add    $0x1,%edx
  800bb0:	bf 01 00 00 00       	mov    $0x1,%edi
  800bb5:	eb cb                	jmp    800b82 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bb7:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bbb:	74 0e                	je     800bcb <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800bbd:	85 db                	test   %ebx,%ebx
  800bbf:	75 d8                	jne    800b99 <strtol+0x40>
		s++, base = 8;
  800bc1:	83 c2 01             	add    $0x1,%edx
  800bc4:	bb 08 00 00 00       	mov    $0x8,%ebx
  800bc9:	eb ce                	jmp    800b99 <strtol+0x40>
		s += 2, base = 16;
  800bcb:	83 c2 02             	add    $0x2,%edx
  800bce:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bd3:	eb c4                	jmp    800b99 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800bd5:	0f be c0             	movsbl %al,%eax
  800bd8:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bdb:	3b 45 10             	cmp    0x10(%ebp),%eax
  800bde:	7d 3a                	jge    800c1a <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800be0:	83 c2 01             	add    $0x1,%edx
  800be3:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800be7:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800be9:	0f b6 02             	movzbl (%edx),%eax
  800bec:	8d 70 d0             	lea    -0x30(%eax),%esi
  800bef:	89 f3                	mov    %esi,%ebx
  800bf1:	80 fb 09             	cmp    $0x9,%bl
  800bf4:	76 df                	jbe    800bd5 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800bf6:	8d 70 9f             	lea    -0x61(%eax),%esi
  800bf9:	89 f3                	mov    %esi,%ebx
  800bfb:	80 fb 19             	cmp    $0x19,%bl
  800bfe:	77 08                	ja     800c08 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800c00:	0f be c0             	movsbl %al,%eax
  800c03:	83 e8 57             	sub    $0x57,%eax
  800c06:	eb d3                	jmp    800bdb <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800c08:	8d 70 bf             	lea    -0x41(%eax),%esi
  800c0b:	89 f3                	mov    %esi,%ebx
  800c0d:	80 fb 19             	cmp    $0x19,%bl
  800c10:	77 08                	ja     800c1a <strtol+0xc1>
			dig = *s - 'A' + 10;
  800c12:	0f be c0             	movsbl %al,%eax
  800c15:	83 e8 37             	sub    $0x37,%eax
  800c18:	eb c1                	jmp    800bdb <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c1a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c1e:	74 05                	je     800c25 <strtol+0xcc>
		*endptr = (char *) s;
  800c20:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c23:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800c25:	89 c8                	mov    %ecx,%eax
  800c27:	f7 d8                	neg    %eax
  800c29:	85 ff                	test   %edi,%edi
  800c2b:	0f 45 c8             	cmovne %eax,%ecx
}
  800c2e:	89 c8                	mov    %ecx,%eax
  800c30:	5b                   	pop    %ebx
  800c31:	5e                   	pop    %esi
  800c32:	5f                   	pop    %edi
  800c33:	5d                   	pop    %ebp
  800c34:	c3                   	ret    
  800c35:	66 90                	xchg   %ax,%ax
  800c37:	66 90                	xchg   %ax,%ax
  800c39:	66 90                	xchg   %ax,%ax
  800c3b:	66 90                	xchg   %ax,%ax
  800c3d:	66 90                	xchg   %ax,%ax
  800c3f:	90                   	nop

00800c40 <__udivdi3>:
  800c40:	f3 0f 1e fb          	endbr32 
  800c44:	55                   	push   %ebp
  800c45:	57                   	push   %edi
  800c46:	56                   	push   %esi
  800c47:	53                   	push   %ebx
  800c48:	83 ec 1c             	sub    $0x1c,%esp
  800c4b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800c4f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800c53:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c57:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800c5b:	85 c0                	test   %eax,%eax
  800c5d:	75 19                	jne    800c78 <__udivdi3+0x38>
  800c5f:	39 f3                	cmp    %esi,%ebx
  800c61:	76 4d                	jbe    800cb0 <__udivdi3+0x70>
  800c63:	31 ff                	xor    %edi,%edi
  800c65:	89 e8                	mov    %ebp,%eax
  800c67:	89 f2                	mov    %esi,%edx
  800c69:	f7 f3                	div    %ebx
  800c6b:	89 fa                	mov    %edi,%edx
  800c6d:	83 c4 1c             	add    $0x1c,%esp
  800c70:	5b                   	pop    %ebx
  800c71:	5e                   	pop    %esi
  800c72:	5f                   	pop    %edi
  800c73:	5d                   	pop    %ebp
  800c74:	c3                   	ret    
  800c75:	8d 76 00             	lea    0x0(%esi),%esi
  800c78:	39 f0                	cmp    %esi,%eax
  800c7a:	76 14                	jbe    800c90 <__udivdi3+0x50>
  800c7c:	31 ff                	xor    %edi,%edi
  800c7e:	31 c0                	xor    %eax,%eax
  800c80:	89 fa                	mov    %edi,%edx
  800c82:	83 c4 1c             	add    $0x1c,%esp
  800c85:	5b                   	pop    %ebx
  800c86:	5e                   	pop    %esi
  800c87:	5f                   	pop    %edi
  800c88:	5d                   	pop    %ebp
  800c89:	c3                   	ret    
  800c8a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800c90:	0f bd f8             	bsr    %eax,%edi
  800c93:	83 f7 1f             	xor    $0x1f,%edi
  800c96:	75 48                	jne    800ce0 <__udivdi3+0xa0>
  800c98:	39 f0                	cmp    %esi,%eax
  800c9a:	72 06                	jb     800ca2 <__udivdi3+0x62>
  800c9c:	31 c0                	xor    %eax,%eax
  800c9e:	39 eb                	cmp    %ebp,%ebx
  800ca0:	77 de                	ja     800c80 <__udivdi3+0x40>
  800ca2:	b8 01 00 00 00       	mov    $0x1,%eax
  800ca7:	eb d7                	jmp    800c80 <__udivdi3+0x40>
  800ca9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800cb0:	89 d9                	mov    %ebx,%ecx
  800cb2:	85 db                	test   %ebx,%ebx
  800cb4:	75 0b                	jne    800cc1 <__udivdi3+0x81>
  800cb6:	b8 01 00 00 00       	mov    $0x1,%eax
  800cbb:	31 d2                	xor    %edx,%edx
  800cbd:	f7 f3                	div    %ebx
  800cbf:	89 c1                	mov    %eax,%ecx
  800cc1:	31 d2                	xor    %edx,%edx
  800cc3:	89 f0                	mov    %esi,%eax
  800cc5:	f7 f1                	div    %ecx
  800cc7:	89 c6                	mov    %eax,%esi
  800cc9:	89 e8                	mov    %ebp,%eax
  800ccb:	89 f7                	mov    %esi,%edi
  800ccd:	f7 f1                	div    %ecx
  800ccf:	89 fa                	mov    %edi,%edx
  800cd1:	83 c4 1c             	add    $0x1c,%esp
  800cd4:	5b                   	pop    %ebx
  800cd5:	5e                   	pop    %esi
  800cd6:	5f                   	pop    %edi
  800cd7:	5d                   	pop    %ebp
  800cd8:	c3                   	ret    
  800cd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ce0:	89 f9                	mov    %edi,%ecx
  800ce2:	ba 20 00 00 00       	mov    $0x20,%edx
  800ce7:	29 fa                	sub    %edi,%edx
  800ce9:	d3 e0                	shl    %cl,%eax
  800ceb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cef:	89 d1                	mov    %edx,%ecx
  800cf1:	89 d8                	mov    %ebx,%eax
  800cf3:	d3 e8                	shr    %cl,%eax
  800cf5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800cf9:	09 c1                	or     %eax,%ecx
  800cfb:	89 f0                	mov    %esi,%eax
  800cfd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d01:	89 f9                	mov    %edi,%ecx
  800d03:	d3 e3                	shl    %cl,%ebx
  800d05:	89 d1                	mov    %edx,%ecx
  800d07:	d3 e8                	shr    %cl,%eax
  800d09:	89 f9                	mov    %edi,%ecx
  800d0b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800d0f:	89 eb                	mov    %ebp,%ebx
  800d11:	d3 e6                	shl    %cl,%esi
  800d13:	89 d1                	mov    %edx,%ecx
  800d15:	d3 eb                	shr    %cl,%ebx
  800d17:	09 f3                	or     %esi,%ebx
  800d19:	89 c6                	mov    %eax,%esi
  800d1b:	89 f2                	mov    %esi,%edx
  800d1d:	89 d8                	mov    %ebx,%eax
  800d1f:	f7 74 24 08          	divl   0x8(%esp)
  800d23:	89 d6                	mov    %edx,%esi
  800d25:	89 c3                	mov    %eax,%ebx
  800d27:	f7 64 24 0c          	mull   0xc(%esp)
  800d2b:	39 d6                	cmp    %edx,%esi
  800d2d:	72 19                	jb     800d48 <__udivdi3+0x108>
  800d2f:	89 f9                	mov    %edi,%ecx
  800d31:	d3 e5                	shl    %cl,%ebp
  800d33:	39 c5                	cmp    %eax,%ebp
  800d35:	73 04                	jae    800d3b <__udivdi3+0xfb>
  800d37:	39 d6                	cmp    %edx,%esi
  800d39:	74 0d                	je     800d48 <__udivdi3+0x108>
  800d3b:	89 d8                	mov    %ebx,%eax
  800d3d:	31 ff                	xor    %edi,%edi
  800d3f:	e9 3c ff ff ff       	jmp    800c80 <__udivdi3+0x40>
  800d44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d48:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800d4b:	31 ff                	xor    %edi,%edi
  800d4d:	e9 2e ff ff ff       	jmp    800c80 <__udivdi3+0x40>
  800d52:	66 90                	xchg   %ax,%ax
  800d54:	66 90                	xchg   %ax,%ax
  800d56:	66 90                	xchg   %ax,%ax
  800d58:	66 90                	xchg   %ax,%ax
  800d5a:	66 90                	xchg   %ax,%ax
  800d5c:	66 90                	xchg   %ax,%ax
  800d5e:	66 90                	xchg   %ax,%ax

00800d60 <__umoddi3>:
  800d60:	f3 0f 1e fb          	endbr32 
  800d64:	55                   	push   %ebp
  800d65:	57                   	push   %edi
  800d66:	56                   	push   %esi
  800d67:	53                   	push   %ebx
  800d68:	83 ec 1c             	sub    $0x1c,%esp
  800d6b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800d6f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800d73:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  800d77:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  800d7b:	89 f0                	mov    %esi,%eax
  800d7d:	89 da                	mov    %ebx,%edx
  800d7f:	85 ff                	test   %edi,%edi
  800d81:	75 15                	jne    800d98 <__umoddi3+0x38>
  800d83:	39 dd                	cmp    %ebx,%ebp
  800d85:	76 39                	jbe    800dc0 <__umoddi3+0x60>
  800d87:	f7 f5                	div    %ebp
  800d89:	89 d0                	mov    %edx,%eax
  800d8b:	31 d2                	xor    %edx,%edx
  800d8d:	83 c4 1c             	add    $0x1c,%esp
  800d90:	5b                   	pop    %ebx
  800d91:	5e                   	pop    %esi
  800d92:	5f                   	pop    %edi
  800d93:	5d                   	pop    %ebp
  800d94:	c3                   	ret    
  800d95:	8d 76 00             	lea    0x0(%esi),%esi
  800d98:	39 df                	cmp    %ebx,%edi
  800d9a:	77 f1                	ja     800d8d <__umoddi3+0x2d>
  800d9c:	0f bd cf             	bsr    %edi,%ecx
  800d9f:	83 f1 1f             	xor    $0x1f,%ecx
  800da2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800da6:	75 40                	jne    800de8 <__umoddi3+0x88>
  800da8:	39 df                	cmp    %ebx,%edi
  800daa:	72 04                	jb     800db0 <__umoddi3+0x50>
  800dac:	39 f5                	cmp    %esi,%ebp
  800dae:	77 dd                	ja     800d8d <__umoddi3+0x2d>
  800db0:	89 da                	mov    %ebx,%edx
  800db2:	89 f0                	mov    %esi,%eax
  800db4:	29 e8                	sub    %ebp,%eax
  800db6:	19 fa                	sbb    %edi,%edx
  800db8:	eb d3                	jmp    800d8d <__umoddi3+0x2d>
  800dba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800dc0:	89 e9                	mov    %ebp,%ecx
  800dc2:	85 ed                	test   %ebp,%ebp
  800dc4:	75 0b                	jne    800dd1 <__umoddi3+0x71>
  800dc6:	b8 01 00 00 00       	mov    $0x1,%eax
  800dcb:	31 d2                	xor    %edx,%edx
  800dcd:	f7 f5                	div    %ebp
  800dcf:	89 c1                	mov    %eax,%ecx
  800dd1:	89 d8                	mov    %ebx,%eax
  800dd3:	31 d2                	xor    %edx,%edx
  800dd5:	f7 f1                	div    %ecx
  800dd7:	89 f0                	mov    %esi,%eax
  800dd9:	f7 f1                	div    %ecx
  800ddb:	89 d0                	mov    %edx,%eax
  800ddd:	31 d2                	xor    %edx,%edx
  800ddf:	eb ac                	jmp    800d8d <__umoddi3+0x2d>
  800de1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800de8:	8b 44 24 04          	mov    0x4(%esp),%eax
  800dec:	ba 20 00 00 00       	mov    $0x20,%edx
  800df1:	29 c2                	sub    %eax,%edx
  800df3:	89 c1                	mov    %eax,%ecx
  800df5:	89 e8                	mov    %ebp,%eax
  800df7:	d3 e7                	shl    %cl,%edi
  800df9:	89 d1                	mov    %edx,%ecx
  800dfb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800dff:	d3 e8                	shr    %cl,%eax
  800e01:	89 c1                	mov    %eax,%ecx
  800e03:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e07:	09 f9                	or     %edi,%ecx
  800e09:	89 df                	mov    %ebx,%edi
  800e0b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e0f:	89 c1                	mov    %eax,%ecx
  800e11:	d3 e5                	shl    %cl,%ebp
  800e13:	89 d1                	mov    %edx,%ecx
  800e15:	d3 ef                	shr    %cl,%edi
  800e17:	89 c1                	mov    %eax,%ecx
  800e19:	89 f0                	mov    %esi,%eax
  800e1b:	d3 e3                	shl    %cl,%ebx
  800e1d:	89 d1                	mov    %edx,%ecx
  800e1f:	89 fa                	mov    %edi,%edx
  800e21:	d3 e8                	shr    %cl,%eax
  800e23:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e28:	09 d8                	or     %ebx,%eax
  800e2a:	f7 74 24 08          	divl   0x8(%esp)
  800e2e:	89 d3                	mov    %edx,%ebx
  800e30:	d3 e6                	shl    %cl,%esi
  800e32:	f7 e5                	mul    %ebp
  800e34:	89 c7                	mov    %eax,%edi
  800e36:	89 d1                	mov    %edx,%ecx
  800e38:	39 d3                	cmp    %edx,%ebx
  800e3a:	72 06                	jb     800e42 <__umoddi3+0xe2>
  800e3c:	75 0e                	jne    800e4c <__umoddi3+0xec>
  800e3e:	39 c6                	cmp    %eax,%esi
  800e40:	73 0a                	jae    800e4c <__umoddi3+0xec>
  800e42:	29 e8                	sub    %ebp,%eax
  800e44:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800e48:	89 d1                	mov    %edx,%ecx
  800e4a:	89 c7                	mov    %eax,%edi
  800e4c:	89 f5                	mov    %esi,%ebp
  800e4e:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e52:	29 fd                	sub    %edi,%ebp
  800e54:	19 cb                	sbb    %ecx,%ebx
  800e56:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800e5b:	89 d8                	mov    %ebx,%eax
  800e5d:	d3 e0                	shl    %cl,%eax
  800e5f:	89 f1                	mov    %esi,%ecx
  800e61:	d3 ed                	shr    %cl,%ebp
  800e63:	d3 eb                	shr    %cl,%ebx
  800e65:	09 e8                	or     %ebp,%eax
  800e67:	89 da                	mov    %ebx,%edx
  800e69:	83 c4 1c             	add    $0x1c,%esp
  800e6c:	5b                   	pop    %ebx
  800e6d:	5e                   	pop    %esi
  800e6e:	5f                   	pop    %edi
  800e6f:	5d                   	pop    %ebp
  800e70:	c3                   	ret    
