
obj/user/softint:     formato del fichero elf32-i386


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
  80002c:	e8 05 00 00 00       	call   800036 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
	asm volatile("int $14");  // page fault
  800033:	cd 0e                	int    $0xe
}
  800035:	c3                   	ret    

00800036 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800036:	55                   	push   %ebp
  800037:	89 e5                	mov    %esp,%ebp
  800039:	56                   	push   %esi
  80003a:	53                   	push   %ebx
  80003b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80003e:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	envid_t id = sys_getenvid();
  800041:	e8 04 01 00 00       	call   80014a <sys_getenvid>
	if (id >= 0)
  800046:	85 c0                	test   %eax,%eax
  800048:	78 15                	js     80005f <libmain+0x29>
		thisenv = &envs[ENVX(id)];
  80004a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004f:	69 c0 88 00 00 00    	imul   $0x88,%eax,%eax
  800055:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005a:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005f:	85 db                	test   %ebx,%ebx
  800061:	7e 07                	jle    80006a <libmain+0x34>
		binaryname = argv[0];
  800063:	8b 06                	mov    (%esi),%eax
  800065:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80006a:	83 ec 08             	sub    $0x8,%esp
  80006d:	56                   	push   %esi
  80006e:	53                   	push   %ebx
  80006f:	e8 bf ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800074:	e8 0a 00 00 00       	call   800083 <exit>
}
  800079:	83 c4 10             	add    $0x10,%esp
  80007c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007f:	5b                   	pop    %ebx
  800080:	5e                   	pop    %esi
  800081:	5d                   	pop    %ebp
  800082:	c3                   	ret    

00800083 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800083:	55                   	push   %ebp
  800084:	89 e5                	mov    %esp,%ebp
  800086:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800089:	6a 00                	push   $0x0
  80008b:	e8 98 00 00 00       	call   800128 <sys_env_destroy>
}
  800090:	83 c4 10             	add    $0x10,%esp
  800093:	c9                   	leave  
  800094:	c3                   	ret    

00800095 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800095:	55                   	push   %ebp
  800096:	89 e5                	mov    %esp,%ebp
  800098:	57                   	push   %edi
  800099:	56                   	push   %esi
  80009a:	53                   	push   %ebx
  80009b:	83 ec 1c             	sub    $0x1c,%esp
  80009e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8000a1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8000a4:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile(
  8000a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000ac:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000af:	8b 75 14             	mov    0x14(%ebp),%esi
  8000b2:	cd 30                	int    $0x30
	        "int %1\n"
	        : "=a"(ret)
	        : "i"(T_SYSCALL), "a"(num), "d"(a1), "c"(a2), "b"(a3), "D"(a4), "S"(a5)
	        : "cc", "memory");

	if (check && ret > 0)
  8000b4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000b8:	74 04                	je     8000be <syscall+0x29>
  8000ba:	85 c0                	test   %eax,%eax
  8000bc:	7f 08                	jg     8000c6 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  8000be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000c1:	5b                   	pop    %ebx
  8000c2:	5e                   	pop    %esi
  8000c3:	5f                   	pop    %edi
  8000c4:	5d                   	pop    %ebp
  8000c5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8000c6:	83 ec 0c             	sub    $0xc,%esp
  8000c9:	50                   	push   %eax
  8000ca:	ff 75 e0             	push   -0x20(%ebp)
  8000cd:	68 8a 0e 80 00       	push   $0x800e8a
  8000d2:	6a 1e                	push   $0x1e
  8000d4:	68 a7 0e 80 00       	push   $0x800ea7
  8000d9:	e8 f7 01 00 00       	call   8002d5 <_panic>

008000de <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  8000de:	55                   	push   %ebp
  8000df:	89 e5                	mov    %esp,%ebp
  8000e1:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t) s, len, 0, 0, 0);
  8000e4:	6a 00                	push   $0x0
  8000e6:	6a 00                	push   $0x0
  8000e8:	6a 00                	push   $0x0
  8000ea:	ff 75 0c             	push   0xc(%ebp)
  8000ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8000f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8000fa:	e8 96 ff ff ff       	call   800095 <syscall>
}
  8000ff:	83 c4 10             	add    $0x10,%esp
  800102:	c9                   	leave  
  800103:	c3                   	ret    

00800104 <sys_cgetc>:

int
sys_cgetc(void)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  80010a:	6a 00                	push   $0x0
  80010c:	6a 00                	push   $0x0
  80010e:	6a 00                	push   $0x0
  800110:	6a 00                	push   $0x0
  800112:	b9 00 00 00 00       	mov    $0x0,%ecx
  800117:	ba 00 00 00 00       	mov    $0x0,%edx
  80011c:	b8 01 00 00 00       	mov    $0x1,%eax
  800121:	e8 6f ff ff ff       	call   800095 <syscall>
}
  800126:	c9                   	leave  
  800127:	c3                   	ret    

00800128 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80012e:	6a 00                	push   $0x0
  800130:	6a 00                	push   $0x0
  800132:	6a 00                	push   $0x0
  800134:	6a 00                	push   $0x0
  800136:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800139:	ba 01 00 00 00       	mov    $0x1,%edx
  80013e:	b8 03 00 00 00       	mov    $0x3,%eax
  800143:	e8 4d ff ff ff       	call   800095 <syscall>
}
  800148:	c9                   	leave  
  800149:	c3                   	ret    

0080014a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80014a:	55                   	push   %ebp
  80014b:	89 e5                	mov    %esp,%ebp
  80014d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800150:	6a 00                	push   $0x0
  800152:	6a 00                	push   $0x0
  800154:	6a 00                	push   $0x0
  800156:	6a 00                	push   $0x0
  800158:	b9 00 00 00 00       	mov    $0x0,%ecx
  80015d:	ba 00 00 00 00       	mov    $0x0,%edx
  800162:	b8 02 00 00 00       	mov    $0x2,%eax
  800167:	e8 29 ff ff ff       	call   800095 <syscall>
}
  80016c:	c9                   	leave  
  80016d:	c3                   	ret    

0080016e <sys_yield>:

void
sys_yield(void)
{
  80016e:	55                   	push   %ebp
  80016f:	89 e5                	mov    %esp,%ebp
  800171:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800174:	6a 00                	push   $0x0
  800176:	6a 00                	push   $0x0
  800178:	6a 00                	push   $0x0
  80017a:	6a 00                	push   $0x0
  80017c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800181:	ba 00 00 00 00       	mov    $0x0,%edx
  800186:	b8 0a 00 00 00       	mov    $0xa,%eax
  80018b:	e8 05 ff ff ff       	call   800095 <syscall>
}
  800190:	83 c4 10             	add    $0x10,%esp
  800193:	c9                   	leave  
  800194:	c3                   	ret    

00800195 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800195:	55                   	push   %ebp
  800196:	89 e5                	mov    %esp,%ebp
  800198:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  80019b:	6a 00                	push   $0x0
  80019d:	6a 00                	push   $0x0
  80019f:	ff 75 10             	push   0x10(%ebp)
  8001a2:	ff 75 0c             	push   0xc(%ebp)
  8001a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a8:	ba 01 00 00 00       	mov    $0x1,%edx
  8001ad:	b8 04 00 00 00       	mov    $0x4,%eax
  8001b2:	e8 de fe ff ff       	call   800095 <syscall>
}
  8001b7:	c9                   	leave  
  8001b8:	c3                   	ret    

008001b9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001b9:	55                   	push   %ebp
  8001ba:	89 e5                	mov    %esp,%ebp
  8001bc:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map,
  8001bf:	ff 75 18             	push   0x18(%ebp)
  8001c2:	ff 75 14             	push   0x14(%ebp)
  8001c5:	ff 75 10             	push   0x10(%ebp)
  8001c8:	ff 75 0c             	push   0xc(%ebp)
  8001cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ce:	ba 01 00 00 00       	mov    $0x1,%edx
  8001d3:	b8 05 00 00 00       	mov    $0x5,%eax
  8001d8:	e8 b8 fe ff ff       	call   800095 <syscall>
	               srcenv,
	               (uint32_t) srcva,
	               dstenv,
	               (uint32_t) dstva,
	               perm);
}
  8001dd:	c9                   	leave  
  8001de:	c3                   	ret    

008001df <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001df:	55                   	push   %ebp
  8001e0:	89 e5                	mov    %esp,%ebp
  8001e2:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8001e5:	6a 00                	push   $0x0
  8001e7:	6a 00                	push   $0x0
  8001e9:	6a 00                	push   $0x0
  8001eb:	ff 75 0c             	push   0xc(%ebp)
  8001ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001f1:	ba 01 00 00 00       	mov    $0x1,%edx
  8001f6:	b8 06 00 00 00       	mov    $0x6,%eax
  8001fb:	e8 95 fe ff ff       	call   800095 <syscall>
}
  800200:	c9                   	leave  
  800201:	c3                   	ret    

00800202 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800202:	55                   	push   %ebp
  800203:	89 e5                	mov    %esp,%ebp
  800205:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800208:	6a 00                	push   $0x0
  80020a:	6a 00                	push   $0x0
  80020c:	6a 00                	push   $0x0
  80020e:	ff 75 0c             	push   0xc(%ebp)
  800211:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800214:	ba 01 00 00 00       	mov    $0x1,%edx
  800219:	b8 08 00 00 00       	mov    $0x8,%eax
  80021e:	e8 72 fe ff ff       	call   800095 <syscall>
}
  800223:	c9                   	leave  
  800224:	c3                   	ret    

00800225 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800225:	55                   	push   %ebp
  800226:	89 e5                	mov    %esp,%ebp
  800228:	83 ec 08             	sub    $0x8,%esp
	return syscall(
  80022b:	6a 00                	push   $0x0
  80022d:	6a 00                	push   $0x0
  80022f:	6a 00                	push   $0x0
  800231:	ff 75 0c             	push   0xc(%ebp)
  800234:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800237:	ba 01 00 00 00       	mov    $0x1,%edx
  80023c:	b8 09 00 00 00       	mov    $0x9,%eax
  800241:	e8 4f fe ff ff       	call   800095 <syscall>
	        SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800246:	c9                   	leave  
  800247:	c3                   	ret    

00800248 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  80024e:	6a 00                	push   $0x0
  800250:	ff 75 14             	push   0x14(%ebp)
  800253:	ff 75 10             	push   0x10(%ebp)
  800256:	ff 75 0c             	push   0xc(%ebp)
  800259:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80025c:	ba 00 00 00 00       	mov    $0x0,%edx
  800261:	b8 0b 00 00 00       	mov    $0xb,%eax
  800266:	e8 2a fe ff ff       	call   800095 <syscall>
}
  80026b:	c9                   	leave  
  80026c:	c3                   	ret    

0080026d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80026d:	55                   	push   %ebp
  80026e:	89 e5                	mov    %esp,%ebp
  800270:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t) dstva, 0, 0, 0, 0);
  800273:	6a 00                	push   $0x0
  800275:	6a 00                	push   $0x0
  800277:	6a 00                	push   $0x0
  800279:	6a 00                	push   $0x0
  80027b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80027e:	ba 01 00 00 00       	mov    $0x1,%edx
  800283:	b8 0c 00 00 00       	mov    $0xc,%eax
  800288:	e8 08 fe ff ff       	call   800095 <syscall>
}
  80028d:	c9                   	leave  
  80028e:	c3                   	ret    

0080028f <sys_get_priority>:

// Get priority of the current process
int
sys_get_priority(void)
{
  80028f:	55                   	push   %ebp
  800290:	89 e5                	mov    %esp,%ebp
  800292:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_get_priority, 0, 0, 0, 0, 0, 0);
  800295:	6a 00                	push   $0x0
  800297:	6a 00                	push   $0x0
  800299:	6a 00                	push   $0x0
  80029b:	6a 00                	push   $0x0
  80029d:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8002a7:	b8 0d 00 00 00       	mov    $0xd,%eax
  8002ac:	e8 e4 fd ff ff       	call   800095 <syscall>
}
  8002b1:	c9                   	leave  
  8002b2:	c3                   	ret    

008002b3 <sys_set_priority>:

// Get priority of the current process
int
sys_set_priority(unsigned int priority)
{
  8002b3:	55                   	push   %ebp
  8002b4:	89 e5                	mov    %esp,%ebp
  8002b6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, (uint32_t) priority, 0, 0, 0, 0);
  8002b9:	6a 00                	push   $0x0
  8002bb:	6a 00                	push   $0x0
  8002bd:	6a 00                	push   $0x0
  8002bf:	6a 00                	push   $0x0
  8002c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c9:	b8 0e 00 00 00       	mov    $0xe,%eax
  8002ce:	e8 c2 fd ff ff       	call   800095 <syscall>
}
  8002d3:	c9                   	leave  
  8002d4:	c3                   	ret    

008002d5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002d5:	55                   	push   %ebp
  8002d6:	89 e5                	mov    %esp,%ebp
  8002d8:	56                   	push   %esi
  8002d9:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002da:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002dd:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8002e3:	e8 62 fe ff ff       	call   80014a <sys_getenvid>
  8002e8:	83 ec 0c             	sub    $0xc,%esp
  8002eb:	ff 75 0c             	push   0xc(%ebp)
  8002ee:	ff 75 08             	push   0x8(%ebp)
  8002f1:	56                   	push   %esi
  8002f2:	50                   	push   %eax
  8002f3:	68 b8 0e 80 00       	push   $0x800eb8
  8002f8:	e8 b3 00 00 00       	call   8003b0 <cprintf>
	        sys_getenvid(),
	        binaryname,
	        file,
	        line);
	vcprintf(fmt, ap);
  8002fd:	83 c4 18             	add    $0x18,%esp
  800300:	53                   	push   %ebx
  800301:	ff 75 10             	push   0x10(%ebp)
  800304:	e8 56 00 00 00       	call   80035f <vcprintf>
	cprintf("\n");
  800309:	c7 04 24 db 0e 80 00 	movl   $0x800edb,(%esp)
  800310:	e8 9b 00 00 00       	call   8003b0 <cprintf>
  800315:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800318:	cc                   	int3   
  800319:	eb fd                	jmp    800318 <_panic+0x43>

0080031b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80031b:	55                   	push   %ebp
  80031c:	89 e5                	mov    %esp,%ebp
  80031e:	53                   	push   %ebx
  80031f:	83 ec 04             	sub    $0x4,%esp
  800322:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800325:	8b 13                	mov    (%ebx),%edx
  800327:	8d 42 01             	lea    0x1(%edx),%eax
  80032a:	89 03                	mov    %eax,(%ebx)
  80032c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80032f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256 - 1) {
  800333:	3d ff 00 00 00       	cmp    $0xff,%eax
  800338:	74 09                	je     800343 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80033a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80033e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800341:	c9                   	leave  
  800342:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800343:	83 ec 08             	sub    $0x8,%esp
  800346:	68 ff 00 00 00       	push   $0xff
  80034b:	8d 43 08             	lea    0x8(%ebx),%eax
  80034e:	50                   	push   %eax
  80034f:	e8 8a fd ff ff       	call   8000de <sys_cputs>
		b->idx = 0;
  800354:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80035a:	83 c4 10             	add    $0x10,%esp
  80035d:	eb db                	jmp    80033a <putch+0x1f>

0080035f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80035f:	55                   	push   %ebp
  800360:	89 e5                	mov    %esp,%ebp
  800362:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800368:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80036f:	00 00 00 
	b.cnt = 0;
  800372:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800379:	00 00 00 
	vprintfmt((void *) putch, &b, fmt, ap);
  80037c:	ff 75 0c             	push   0xc(%ebp)
  80037f:	ff 75 08             	push   0x8(%ebp)
  800382:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800388:	50                   	push   %eax
  800389:	68 1b 03 80 00       	push   $0x80031b
  80038e:	e8 74 01 00 00       	call   800507 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800393:	83 c4 08             	add    $0x8,%esp
  800396:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  80039c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003a2:	50                   	push   %eax
  8003a3:	e8 36 fd ff ff       	call   8000de <sys_cputs>

	return b.cnt;
}
  8003a8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003ae:	c9                   	leave  
  8003af:	c3                   	ret    

008003b0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003b0:	55                   	push   %ebp
  8003b1:	89 e5                	mov    %esp,%ebp
  8003b3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003b6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003b9:	50                   	push   %eax
  8003ba:	ff 75 08             	push   0x8(%ebp)
  8003bd:	e8 9d ff ff ff       	call   80035f <vcprintf>
	va_end(ap);

	return cnt;
}
  8003c2:	c9                   	leave  
  8003c3:	c3                   	ret    

008003c4 <printnum>:
         void *putdat,
         unsigned long long num,
         unsigned base,
         int width,
         int padc)
{
  8003c4:	55                   	push   %ebp
  8003c5:	89 e5                	mov    %esp,%ebp
  8003c7:	57                   	push   %edi
  8003c8:	56                   	push   %esi
  8003c9:	53                   	push   %ebx
  8003ca:	83 ec 1c             	sub    $0x1c,%esp
  8003cd:	89 c7                	mov    %eax,%edi
  8003cf:	89 d6                	mov    %edx,%esi
  8003d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003d7:	89 d1                	mov    %edx,%ecx
  8003d9:	89 c2                	mov    %eax,%edx
  8003db:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003de:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8003e1:	8b 45 10             	mov    0x10(%ebp),%eax
  8003e4:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003e7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ea:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003f1:	39 c2                	cmp    %eax,%edx
  8003f3:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8003f6:	72 3e                	jb     800436 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003f8:	83 ec 0c             	sub    $0xc,%esp
  8003fb:	ff 75 18             	push   0x18(%ebp)
  8003fe:	83 eb 01             	sub    $0x1,%ebx
  800401:	53                   	push   %ebx
  800402:	50                   	push   %eax
  800403:	83 ec 08             	sub    $0x8,%esp
  800406:	ff 75 e4             	push   -0x1c(%ebp)
  800409:	ff 75 e0             	push   -0x20(%ebp)
  80040c:	ff 75 dc             	push   -0x24(%ebp)
  80040f:	ff 75 d8             	push   -0x28(%ebp)
  800412:	e8 19 08 00 00       	call   800c30 <__udivdi3>
  800417:	83 c4 18             	add    $0x18,%esp
  80041a:	52                   	push   %edx
  80041b:	50                   	push   %eax
  80041c:	89 f2                	mov    %esi,%edx
  80041e:	89 f8                	mov    %edi,%eax
  800420:	e8 9f ff ff ff       	call   8003c4 <printnum>
  800425:	83 c4 20             	add    $0x20,%esp
  800428:	eb 13                	jmp    80043d <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80042a:	83 ec 08             	sub    $0x8,%esp
  80042d:	56                   	push   %esi
  80042e:	ff 75 18             	push   0x18(%ebp)
  800431:	ff d7                	call   *%edi
  800433:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800436:	83 eb 01             	sub    $0x1,%ebx
  800439:	85 db                	test   %ebx,%ebx
  80043b:	7f ed                	jg     80042a <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80043d:	83 ec 08             	sub    $0x8,%esp
  800440:	56                   	push   %esi
  800441:	83 ec 04             	sub    $0x4,%esp
  800444:	ff 75 e4             	push   -0x1c(%ebp)
  800447:	ff 75 e0             	push   -0x20(%ebp)
  80044a:	ff 75 dc             	push   -0x24(%ebp)
  80044d:	ff 75 d8             	push   -0x28(%ebp)
  800450:	e8 fb 08 00 00       	call   800d50 <__umoddi3>
  800455:	83 c4 14             	add    $0x14,%esp
  800458:	0f be 80 dd 0e 80 00 	movsbl 0x800edd(%eax),%eax
  80045f:	50                   	push   %eax
  800460:	ff d7                	call   *%edi
}
  800462:	83 c4 10             	add    $0x10,%esp
  800465:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800468:	5b                   	pop    %ebx
  800469:	5e                   	pop    %esi
  80046a:	5f                   	pop    %edi
  80046b:	5d                   	pop    %ebp
  80046c:	c3                   	ret    

0080046d <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80046d:	83 fa 01             	cmp    $0x1,%edx
  800470:	7f 13                	jg     800485 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800472:	85 d2                	test   %edx,%edx
  800474:	74 1c                	je     800492 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  800476:	8b 10                	mov    (%eax),%edx
  800478:	8d 4a 04             	lea    0x4(%edx),%ecx
  80047b:	89 08                	mov    %ecx,(%eax)
  80047d:	8b 02                	mov    (%edx),%eax
  80047f:	ba 00 00 00 00       	mov    $0x0,%edx
  800484:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  800485:	8b 10                	mov    (%eax),%edx
  800487:	8d 4a 08             	lea    0x8(%edx),%ecx
  80048a:	89 08                	mov    %ecx,(%eax)
  80048c:	8b 02                	mov    (%edx),%eax
  80048e:	8b 52 04             	mov    0x4(%edx),%edx
  800491:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  800492:	8b 10                	mov    (%eax),%edx
  800494:	8d 4a 04             	lea    0x4(%edx),%ecx
  800497:	89 08                	mov    %ecx,(%eax)
  800499:	8b 02                	mov    (%edx),%eax
  80049b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004a0:	c3                   	ret    

008004a1 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004a1:	83 fa 01             	cmp    $0x1,%edx
  8004a4:	7f 0f                	jg     8004b5 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  8004a6:	85 d2                	test   %edx,%edx
  8004a8:	74 18                	je     8004c2 <getint+0x21>
		return va_arg(*ap, long);
  8004aa:	8b 10                	mov    (%eax),%edx
  8004ac:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004af:	89 08                	mov    %ecx,(%eax)
  8004b1:	8b 02                	mov    (%edx),%eax
  8004b3:	99                   	cltd   
  8004b4:	c3                   	ret    
		return va_arg(*ap, long long);
  8004b5:	8b 10                	mov    (%eax),%edx
  8004b7:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004ba:	89 08                	mov    %ecx,(%eax)
  8004bc:	8b 02                	mov    (%edx),%eax
  8004be:	8b 52 04             	mov    0x4(%edx),%edx
  8004c1:	c3                   	ret    
	else
		return va_arg(*ap, int);
  8004c2:	8b 10                	mov    (%eax),%edx
  8004c4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004c7:	89 08                	mov    %ecx,(%eax)
  8004c9:	8b 02                	mov    (%edx),%eax
  8004cb:	99                   	cltd   
}
  8004cc:	c3                   	ret    

008004cd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004cd:	55                   	push   %ebp
  8004ce:	89 e5                	mov    %esp,%ebp
  8004d0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004d3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004d7:	8b 10                	mov    (%eax),%edx
  8004d9:	3b 50 04             	cmp    0x4(%eax),%edx
  8004dc:	73 0a                	jae    8004e8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004de:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004e1:	89 08                	mov    %ecx,(%eax)
  8004e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e6:	88 02                	mov    %al,(%edx)
}
  8004e8:	5d                   	pop    %ebp
  8004e9:	c3                   	ret    

008004ea <printfmt>:
{
  8004ea:	55                   	push   %ebp
  8004eb:	89 e5                	mov    %esp,%ebp
  8004ed:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8004f0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004f3:	50                   	push   %eax
  8004f4:	ff 75 10             	push   0x10(%ebp)
  8004f7:	ff 75 0c             	push   0xc(%ebp)
  8004fa:	ff 75 08             	push   0x8(%ebp)
  8004fd:	e8 05 00 00 00       	call   800507 <vprintfmt>
}
  800502:	83 c4 10             	add    $0x10,%esp
  800505:	c9                   	leave  
  800506:	c3                   	ret    

00800507 <vprintfmt>:
{
  800507:	55                   	push   %ebp
  800508:	89 e5                	mov    %esp,%ebp
  80050a:	57                   	push   %edi
  80050b:	56                   	push   %esi
  80050c:	53                   	push   %ebx
  80050d:	83 ec 2c             	sub    $0x2c,%esp
  800510:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800513:	8b 75 0c             	mov    0xc(%ebp),%esi
  800516:	8b 7d 10             	mov    0x10(%ebp),%edi
  800519:	eb 0a                	jmp    800525 <vprintfmt+0x1e>
			putch(ch, putdat);
  80051b:	83 ec 08             	sub    $0x8,%esp
  80051e:	56                   	push   %esi
  80051f:	50                   	push   %eax
  800520:	ff d3                	call   *%ebx
  800522:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800525:	83 c7 01             	add    $0x1,%edi
  800528:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80052c:	83 f8 25             	cmp    $0x25,%eax
  80052f:	74 0c                	je     80053d <vprintfmt+0x36>
			if (ch == '\0')
  800531:	85 c0                	test   %eax,%eax
  800533:	75 e6                	jne    80051b <vprintfmt+0x14>
}
  800535:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800538:	5b                   	pop    %ebx
  800539:	5e                   	pop    %esi
  80053a:	5f                   	pop    %edi
  80053b:	5d                   	pop    %ebp
  80053c:	c3                   	ret    
		padc = ' ';
  80053d:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
		altflag = 0;
  800541:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800548:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80054f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800556:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80055b:	8d 47 01             	lea    0x1(%edi),%eax
  80055e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800561:	0f b6 17             	movzbl (%edi),%edx
  800564:	8d 42 dd             	lea    -0x23(%edx),%eax
  800567:	3c 55                	cmp    $0x55,%al
  800569:	0f 87 b7 02 00 00    	ja     800826 <vprintfmt+0x31f>
  80056f:	0f b6 c0             	movzbl %al,%eax
  800572:	ff 24 85 a0 0f 80 00 	jmp    *0x800fa0(,%eax,4)
  800579:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80057c:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800580:	eb d9                	jmp    80055b <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800582:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800585:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800589:	eb d0                	jmp    80055b <vprintfmt+0x54>
  80058b:	0f b6 d2             	movzbl %dl,%edx
  80058e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0;; ++fmt) {
  800591:	b8 00 00 00 00       	mov    $0x0,%eax
  800596:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800599:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80059c:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8005a0:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8005a3:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8005a6:	83 f9 09             	cmp    $0x9,%ecx
  8005a9:	77 52                	ja     8005fd <vprintfmt+0xf6>
			for (precision = 0;; ++fmt) {
  8005ab:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8005ae:	eb e9                	jmp    800599 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  8005b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b3:	8d 50 04             	lea    0x4(%eax),%edx
  8005b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b9:	8b 00                	mov    (%eax),%eax
  8005bb:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8005c1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005c5:	79 94                	jns    80055b <vprintfmt+0x54>
				width = precision, precision = -1;
  8005c7:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005ca:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005cd:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8005d4:	eb 85                	jmp    80055b <vprintfmt+0x54>
  8005d6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005d9:	85 d2                	test   %edx,%edx
  8005db:	b8 00 00 00 00       	mov    $0x0,%eax
  8005e0:	0f 49 c2             	cmovns %edx,%eax
  8005e3:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005e9:	e9 6d ff ff ff       	jmp    80055b <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8005ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8005f1:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8005f8:	e9 5e ff ff ff       	jmp    80055b <vprintfmt+0x54>
  8005fd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800600:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800603:	eb bc                	jmp    8005c1 <vprintfmt+0xba>
			lflag++;
  800605:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800608:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80060b:	e9 4b ff ff ff       	jmp    80055b <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800610:	8b 45 14             	mov    0x14(%ebp),%eax
  800613:	8d 50 04             	lea    0x4(%eax),%edx
  800616:	89 55 14             	mov    %edx,0x14(%ebp)
  800619:	83 ec 08             	sub    $0x8,%esp
  80061c:	56                   	push   %esi
  80061d:	ff 30                	push   (%eax)
  80061f:	ff d3                	call   *%ebx
			break;
  800621:	83 c4 10             	add    $0x10,%esp
  800624:	e9 94 01 00 00       	jmp    8007bd <vprintfmt+0x2b6>
			err = va_arg(ap, int);
  800629:	8b 45 14             	mov    0x14(%ebp),%eax
  80062c:	8d 50 04             	lea    0x4(%eax),%edx
  80062f:	89 55 14             	mov    %edx,0x14(%ebp)
  800632:	8b 10                	mov    (%eax),%edx
  800634:	89 d0                	mov    %edx,%eax
  800636:	f7 d8                	neg    %eax
  800638:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80063b:	83 f8 08             	cmp    $0x8,%eax
  80063e:	7f 20                	jg     800660 <vprintfmt+0x159>
  800640:	8b 14 85 00 11 80 00 	mov    0x801100(,%eax,4),%edx
  800647:	85 d2                	test   %edx,%edx
  800649:	74 15                	je     800660 <vprintfmt+0x159>
				printfmt(putch, putdat, "%s", p);
  80064b:	52                   	push   %edx
  80064c:	68 fe 0e 80 00       	push   $0x800efe
  800651:	56                   	push   %esi
  800652:	53                   	push   %ebx
  800653:	e8 92 fe ff ff       	call   8004ea <printfmt>
  800658:	83 c4 10             	add    $0x10,%esp
  80065b:	e9 5d 01 00 00       	jmp    8007bd <vprintfmt+0x2b6>
				printfmt(putch, putdat, "error %d", err);
  800660:	50                   	push   %eax
  800661:	68 f5 0e 80 00       	push   $0x800ef5
  800666:	56                   	push   %esi
  800667:	53                   	push   %ebx
  800668:	e8 7d fe ff ff       	call   8004ea <printfmt>
  80066d:	83 c4 10             	add    $0x10,%esp
  800670:	e9 48 01 00 00       	jmp    8007bd <vprintfmt+0x2b6>
			if ((p = va_arg(ap, char *)) == NULL)
  800675:	8b 45 14             	mov    0x14(%ebp),%eax
  800678:	8d 50 04             	lea    0x4(%eax),%edx
  80067b:	89 55 14             	mov    %edx,0x14(%ebp)
  80067e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800680:	85 ff                	test   %edi,%edi
  800682:	b8 ee 0e 80 00       	mov    $0x800eee,%eax
  800687:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80068a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80068e:	7e 06                	jle    800696 <vprintfmt+0x18f>
  800690:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  800694:	75 0a                	jne    8006a0 <vprintfmt+0x199>
  800696:	89 f8                	mov    %edi,%eax
  800698:	03 45 e0             	add    -0x20(%ebp),%eax
  80069b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80069e:	eb 59                	jmp    8006f9 <vprintfmt+0x1f2>
				for (width -= strnlen(p, precision); width > 0;
  8006a0:	83 ec 08             	sub    $0x8,%esp
  8006a3:	ff 75 d8             	push   -0x28(%ebp)
  8006a6:	57                   	push   %edi
  8006a7:	e8 1a 02 00 00       	call   8008c6 <strnlen>
  8006ac:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006af:	29 c1                	sub    %eax,%ecx
  8006b1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006b4:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006b7:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  8006bb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006be:	89 7d d0             	mov    %edi,-0x30(%ebp)
  8006c1:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0;
  8006c3:	eb 0f                	jmp    8006d4 <vprintfmt+0x1cd>
					putch(padc, putdat);
  8006c5:	83 ec 08             	sub    $0x8,%esp
  8006c8:	56                   	push   %esi
  8006c9:	ff 75 e0             	push   -0x20(%ebp)
  8006cc:	ff d3                	call   *%ebx
				     width--)
  8006ce:	83 ef 01             	sub    $0x1,%edi
  8006d1:	83 c4 10             	add    $0x10,%esp
				for (width -= strnlen(p, precision); width > 0;
  8006d4:	85 ff                	test   %edi,%edi
  8006d6:	7f ed                	jg     8006c5 <vprintfmt+0x1be>
  8006d8:	8b 7d d0             	mov    -0x30(%ebp),%edi
  8006db:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006de:	85 c9                	test   %ecx,%ecx
  8006e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e5:	0f 49 c1             	cmovns %ecx,%eax
  8006e8:	29 c1                	sub    %eax,%ecx
  8006ea:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8006ed:	eb a7                	jmp    800696 <vprintfmt+0x18f>
					putch(ch, putdat);
  8006ef:	83 ec 08             	sub    $0x8,%esp
  8006f2:	56                   	push   %esi
  8006f3:	52                   	push   %edx
  8006f4:	ff d3                	call   *%ebx
  8006f6:	83 c4 10             	add    $0x10,%esp
  8006f9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006fc:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' &&
  8006fe:	83 c7 01             	add    $0x1,%edi
  800701:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800705:	0f be d0             	movsbl %al,%edx
  800708:	85 d2                	test   %edx,%edx
  80070a:	74 42                	je     80074e <vprintfmt+0x247>
  80070c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800710:	78 06                	js     800718 <vprintfmt+0x211>
			       (precision < 0 || --precision >= 0);
  800712:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800716:	78 1e                	js     800736 <vprintfmt+0x22f>
				if (altflag && (ch < ' ' || ch > '~'))
  800718:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80071c:	74 d1                	je     8006ef <vprintfmt+0x1e8>
  80071e:	0f be c0             	movsbl %al,%eax
  800721:	83 e8 20             	sub    $0x20,%eax
  800724:	83 f8 5e             	cmp    $0x5e,%eax
  800727:	76 c6                	jbe    8006ef <vprintfmt+0x1e8>
					putch('?', putdat);
  800729:	83 ec 08             	sub    $0x8,%esp
  80072c:	56                   	push   %esi
  80072d:	6a 3f                	push   $0x3f
  80072f:	ff d3                	call   *%ebx
  800731:	83 c4 10             	add    $0x10,%esp
  800734:	eb c3                	jmp    8006f9 <vprintfmt+0x1f2>
  800736:	89 cf                	mov    %ecx,%edi
  800738:	eb 0e                	jmp    800748 <vprintfmt+0x241>
				putch(' ', putdat);
  80073a:	83 ec 08             	sub    $0x8,%esp
  80073d:	56                   	push   %esi
  80073e:	6a 20                	push   $0x20
  800740:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  800742:	83 ef 01             	sub    $0x1,%edi
  800745:	83 c4 10             	add    $0x10,%esp
  800748:	85 ff                	test   %edi,%edi
  80074a:	7f ee                	jg     80073a <vprintfmt+0x233>
  80074c:	eb 6f                	jmp    8007bd <vprintfmt+0x2b6>
  80074e:	89 cf                	mov    %ecx,%edi
  800750:	eb f6                	jmp    800748 <vprintfmt+0x241>
			num = getint(&ap, lflag);
  800752:	89 ca                	mov    %ecx,%edx
  800754:	8d 45 14             	lea    0x14(%ebp),%eax
  800757:	e8 45 fd ff ff       	call   8004a1 <getint>
  80075c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80075f:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800762:	85 d2                	test   %edx,%edx
  800764:	78 0b                	js     800771 <vprintfmt+0x26a>
			num = getint(&ap, lflag);
  800766:	89 d1                	mov    %edx,%ecx
  800768:	89 c2                	mov    %eax,%edx
			base = 10;
  80076a:	bf 0a 00 00 00       	mov    $0xa,%edi
  80076f:	eb 32                	jmp    8007a3 <vprintfmt+0x29c>
				putch('-', putdat);
  800771:	83 ec 08             	sub    $0x8,%esp
  800774:	56                   	push   %esi
  800775:	6a 2d                	push   $0x2d
  800777:	ff d3                	call   *%ebx
				num = -(long long) num;
  800779:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80077c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80077f:	f7 da                	neg    %edx
  800781:	83 d1 00             	adc    $0x0,%ecx
  800784:	f7 d9                	neg    %ecx
  800786:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800789:	bf 0a 00 00 00       	mov    $0xa,%edi
  80078e:	eb 13                	jmp    8007a3 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  800790:	89 ca                	mov    %ecx,%edx
  800792:	8d 45 14             	lea    0x14(%ebp),%eax
  800795:	e8 d3 fc ff ff       	call   80046d <getuint>
  80079a:	89 d1                	mov    %edx,%ecx
  80079c:	89 c2                	mov    %eax,%edx
			base = 10;
  80079e:	bf 0a 00 00 00       	mov    $0xa,%edi
			printnum(putch, putdat, num, base, width, padc);
  8007a3:	83 ec 0c             	sub    $0xc,%esp
  8007a6:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  8007aa:	50                   	push   %eax
  8007ab:	ff 75 e0             	push   -0x20(%ebp)
  8007ae:	57                   	push   %edi
  8007af:	51                   	push   %ecx
  8007b0:	52                   	push   %edx
  8007b1:	89 f2                	mov    %esi,%edx
  8007b3:	89 d8                	mov    %ebx,%eax
  8007b5:	e8 0a fc ff ff       	call   8003c4 <printnum>
			break;
  8007ba:	83 c4 20             	add    $0x20,%esp
{
  8007bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007c0:	e9 60 fd ff ff       	jmp    800525 <vprintfmt+0x1e>
			num = getuint(&ap, lflag);
  8007c5:	89 ca                	mov    %ecx,%edx
  8007c7:	8d 45 14             	lea    0x14(%ebp),%eax
  8007ca:	e8 9e fc ff ff       	call   80046d <getuint>
  8007cf:	89 d1                	mov    %edx,%ecx
  8007d1:	89 c2                	mov    %eax,%edx
			base = 8;
  8007d3:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  8007d8:	eb c9                	jmp    8007a3 <vprintfmt+0x29c>
			putch('0', putdat);
  8007da:	83 ec 08             	sub    $0x8,%esp
  8007dd:	56                   	push   %esi
  8007de:	6a 30                	push   $0x30
  8007e0:	ff d3                	call   *%ebx
			putch('x', putdat);
  8007e2:	83 c4 08             	add    $0x8,%esp
  8007e5:	56                   	push   %esi
  8007e6:	6a 78                	push   $0x78
  8007e8:	ff d3                	call   *%ebx
			num = (unsigned long long) (uintptr_t) va_arg(ap, void *);
  8007ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ed:	8d 50 04             	lea    0x4(%eax),%edx
  8007f0:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f3:	8b 10                	mov    (%eax),%edx
  8007f5:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8007fa:	83 c4 10             	add    $0x10,%esp
			base = 16;
  8007fd:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  800802:	eb 9f                	jmp    8007a3 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  800804:	89 ca                	mov    %ecx,%edx
  800806:	8d 45 14             	lea    0x14(%ebp),%eax
  800809:	e8 5f fc ff ff       	call   80046d <getuint>
  80080e:	89 d1                	mov    %edx,%ecx
  800810:	89 c2                	mov    %eax,%edx
			base = 16;
  800812:	bf 10 00 00 00       	mov    $0x10,%edi
  800817:	eb 8a                	jmp    8007a3 <vprintfmt+0x29c>
			putch(ch, putdat);
  800819:	83 ec 08             	sub    $0x8,%esp
  80081c:	56                   	push   %esi
  80081d:	6a 25                	push   $0x25
  80081f:	ff d3                	call   *%ebx
			break;
  800821:	83 c4 10             	add    $0x10,%esp
  800824:	eb 97                	jmp    8007bd <vprintfmt+0x2b6>
			putch('%', putdat);
  800826:	83 ec 08             	sub    $0x8,%esp
  800829:	56                   	push   %esi
  80082a:	6a 25                	push   $0x25
  80082c:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  80082e:	83 c4 10             	add    $0x10,%esp
  800831:	89 f8                	mov    %edi,%eax
  800833:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800837:	74 05                	je     80083e <vprintfmt+0x337>
  800839:	83 e8 01             	sub    $0x1,%eax
  80083c:	eb f5                	jmp    800833 <vprintfmt+0x32c>
  80083e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800841:	e9 77 ff ff ff       	jmp    8007bd <vprintfmt+0x2b6>

00800846 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800846:	55                   	push   %ebp
  800847:	89 e5                	mov    %esp,%ebp
  800849:	83 ec 18             	sub    $0x18,%esp
  80084c:	8b 45 08             	mov    0x8(%ebp),%eax
  80084f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = { buf, buf + n - 1, 0 };
  800852:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800855:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800859:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80085c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800863:	85 c0                	test   %eax,%eax
  800865:	74 26                	je     80088d <vsnprintf+0x47>
  800867:	85 d2                	test   %edx,%edx
  800869:	7e 22                	jle    80088d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *) sprintputch, &b, fmt, ap);
  80086b:	ff 75 14             	push   0x14(%ebp)
  80086e:	ff 75 10             	push   0x10(%ebp)
  800871:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800874:	50                   	push   %eax
  800875:	68 cd 04 80 00       	push   $0x8004cd
  80087a:	e8 88 fc ff ff       	call   800507 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80087f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800882:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800885:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800888:	83 c4 10             	add    $0x10,%esp
}
  80088b:	c9                   	leave  
  80088c:	c3                   	ret    
		return -E_INVAL;
  80088d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800892:	eb f7                	jmp    80088b <vsnprintf+0x45>

00800894 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80089a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80089d:	50                   	push   %eax
  80089e:	ff 75 10             	push   0x10(%ebp)
  8008a1:	ff 75 0c             	push   0xc(%ebp)
  8008a4:	ff 75 08             	push   0x8(%ebp)
  8008a7:	e8 9a ff ff ff       	call   800846 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008ac:	c9                   	leave  
  8008ad:	c3                   	ret    

008008ae <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008ae:	55                   	push   %ebp
  8008af:	89 e5                	mov    %esp,%ebp
  8008b1:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b9:	eb 03                	jmp    8008be <strlen+0x10>
		n++;
  8008bb:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008be:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008c2:	75 f7                	jne    8008bb <strlen+0xd>
	return n;
}
  8008c4:	5d                   	pop    %ebp
  8008c5:	c3                   	ret    

008008c6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008c6:	55                   	push   %ebp
  8008c7:	89 e5                	mov    %esp,%ebp
  8008c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008cc:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d4:	eb 03                	jmp    8008d9 <strnlen+0x13>
		n++;
  8008d6:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008d9:	39 d0                	cmp    %edx,%eax
  8008db:	74 08                	je     8008e5 <strnlen+0x1f>
  8008dd:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008e1:	75 f3                	jne    8008d6 <strnlen+0x10>
  8008e3:	89 c2                	mov    %eax,%edx
	return n;
}
  8008e5:	89 d0                	mov    %edx,%eax
  8008e7:	5d                   	pop    %ebp
  8008e8:	c3                   	ret    

008008e9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008e9:	55                   	push   %ebp
  8008ea:	89 e5                	mov    %esp,%ebp
  8008ec:	53                   	push   %ebx
  8008ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008f0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f8:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8008fc:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8008ff:	83 c0 01             	add    $0x1,%eax
  800902:	84 d2                	test   %dl,%dl
  800904:	75 f2                	jne    8008f8 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800906:	89 c8                	mov    %ecx,%eax
  800908:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80090b:	c9                   	leave  
  80090c:	c3                   	ret    

0080090d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80090d:	55                   	push   %ebp
  80090e:	89 e5                	mov    %esp,%ebp
  800910:	53                   	push   %ebx
  800911:	83 ec 10             	sub    $0x10,%esp
  800914:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800917:	53                   	push   %ebx
  800918:	e8 91 ff ff ff       	call   8008ae <strlen>
  80091d:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800920:	ff 75 0c             	push   0xc(%ebp)
  800923:	01 d8                	add    %ebx,%eax
  800925:	50                   	push   %eax
  800926:	e8 be ff ff ff       	call   8008e9 <strcpy>
	return dst;
}
  80092b:	89 d8                	mov    %ebx,%eax
  80092d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800930:	c9                   	leave  
  800931:	c3                   	ret    

00800932 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size)
{
  800932:	55                   	push   %ebp
  800933:	89 e5                	mov    %esp,%ebp
  800935:	56                   	push   %esi
  800936:	53                   	push   %ebx
  800937:	8b 75 08             	mov    0x8(%ebp),%esi
  80093a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80093d:	89 f3                	mov    %esi,%ebx
  80093f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800942:	89 f0                	mov    %esi,%eax
  800944:	eb 0f                	jmp    800955 <strncpy+0x23>
		*dst++ = *src;
  800946:	83 c0 01             	add    $0x1,%eax
  800949:	0f b6 0a             	movzbl (%edx),%ecx
  80094c:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80094f:	80 f9 01             	cmp    $0x1,%cl
  800952:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800955:	39 d8                	cmp    %ebx,%eax
  800957:	75 ed                	jne    800946 <strncpy+0x14>
	}
	return ret;
}
  800959:	89 f0                	mov    %esi,%eax
  80095b:	5b                   	pop    %ebx
  80095c:	5e                   	pop    %esi
  80095d:	5d                   	pop    %ebp
  80095e:	c3                   	ret    

0080095f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	56                   	push   %esi
  800963:	53                   	push   %ebx
  800964:	8b 75 08             	mov    0x8(%ebp),%esi
  800967:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80096a:	8b 55 10             	mov    0x10(%ebp),%edx
  80096d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80096f:	85 d2                	test   %edx,%edx
  800971:	74 21                	je     800994 <strlcpy+0x35>
  800973:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800977:	89 f2                	mov    %esi,%edx
  800979:	eb 09                	jmp    800984 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80097b:	83 c1 01             	add    $0x1,%ecx
  80097e:	83 c2 01             	add    $0x1,%edx
  800981:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800984:	39 c2                	cmp    %eax,%edx
  800986:	74 09                	je     800991 <strlcpy+0x32>
  800988:	0f b6 19             	movzbl (%ecx),%ebx
  80098b:	84 db                	test   %bl,%bl
  80098d:	75 ec                	jne    80097b <strlcpy+0x1c>
  80098f:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800991:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800994:	29 f0                	sub    %esi,%eax
}
  800996:	5b                   	pop    %ebx
  800997:	5e                   	pop    %esi
  800998:	5d                   	pop    %ebp
  800999:	c3                   	ret    

0080099a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80099a:	55                   	push   %ebp
  80099b:	89 e5                	mov    %esp,%ebp
  80099d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009a3:	eb 06                	jmp    8009ab <strcmp+0x11>
		p++, q++;
  8009a5:	83 c1 01             	add    $0x1,%ecx
  8009a8:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8009ab:	0f b6 01             	movzbl (%ecx),%eax
  8009ae:	84 c0                	test   %al,%al
  8009b0:	74 04                	je     8009b6 <strcmp+0x1c>
  8009b2:	3a 02                	cmp    (%edx),%al
  8009b4:	74 ef                	je     8009a5 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009b6:	0f b6 c0             	movzbl %al,%eax
  8009b9:	0f b6 12             	movzbl (%edx),%edx
  8009bc:	29 d0                	sub    %edx,%eax
}
  8009be:	5d                   	pop    %ebp
  8009bf:	c3                   	ret    

008009c0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009c0:	55                   	push   %ebp
  8009c1:	89 e5                	mov    %esp,%ebp
  8009c3:	53                   	push   %ebx
  8009c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ca:	89 c3                	mov    %eax,%ebx
  8009cc:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009cf:	eb 06                	jmp    8009d7 <strncmp+0x17>
		n--, p++, q++;
  8009d1:	83 c0 01             	add    $0x1,%eax
  8009d4:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009d7:	39 d8                	cmp    %ebx,%eax
  8009d9:	74 18                	je     8009f3 <strncmp+0x33>
  8009db:	0f b6 08             	movzbl (%eax),%ecx
  8009de:	84 c9                	test   %cl,%cl
  8009e0:	74 04                	je     8009e6 <strncmp+0x26>
  8009e2:	3a 0a                	cmp    (%edx),%cl
  8009e4:	74 eb                	je     8009d1 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009e6:	0f b6 00             	movzbl (%eax),%eax
  8009e9:	0f b6 12             	movzbl (%edx),%edx
  8009ec:	29 d0                	sub    %edx,%eax
}
  8009ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009f1:	c9                   	leave  
  8009f2:	c3                   	ret    
		return 0;
  8009f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f8:	eb f4                	jmp    8009ee <strncmp+0x2e>

008009fa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009fa:	55                   	push   %ebp
  8009fb:	89 e5                	mov    %esp,%ebp
  8009fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800a00:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a04:	eb 03                	jmp    800a09 <strchr+0xf>
  800a06:	83 c0 01             	add    $0x1,%eax
  800a09:	0f b6 10             	movzbl (%eax),%edx
  800a0c:	84 d2                	test   %dl,%dl
  800a0e:	74 06                	je     800a16 <strchr+0x1c>
		if (*s == c)
  800a10:	38 ca                	cmp    %cl,%dl
  800a12:	75 f2                	jne    800a06 <strchr+0xc>
  800a14:	eb 05                	jmp    800a1b <strchr+0x21>
			return (char *) s;
	return 0;
  800a16:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a1b:	5d                   	pop    %ebp
  800a1c:	c3                   	ret    

00800a1d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a1d:	55                   	push   %ebp
  800a1e:	89 e5                	mov    %esp,%ebp
  800a20:	8b 45 08             	mov    0x8(%ebp),%eax
  800a23:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a27:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a2a:	38 ca                	cmp    %cl,%dl
  800a2c:	74 09                	je     800a37 <strfind+0x1a>
  800a2e:	84 d2                	test   %dl,%dl
  800a30:	74 05                	je     800a37 <strfind+0x1a>
	for (; *s; s++)
  800a32:	83 c0 01             	add    $0x1,%eax
  800a35:	eb f0                	jmp    800a27 <strfind+0xa>
			break;
	return (char *) s;
}
  800a37:	5d                   	pop    %ebp
  800a38:	c3                   	ret    

00800a39 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a39:	55                   	push   %ebp
  800a3a:	89 e5                	mov    %esp,%ebp
  800a3c:	57                   	push   %edi
  800a3d:	56                   	push   %esi
  800a3e:	53                   	push   %ebx
  800a3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800a42:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  800a45:	85 c9                	test   %ecx,%ecx
  800a47:	74 33                	je     800a7c <memset+0x43>
		return v;
	if ((int) v % 4 == 0 && n % 4 == 0) {
  800a49:	89 d0                	mov    %edx,%eax
  800a4b:	09 c8                	or     %ecx,%eax
  800a4d:	a8 03                	test   $0x3,%al
  800a4f:	75 23                	jne    800a74 <memset+0x3b>
		c &= 0xFF;
  800a51:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  800a55:	89 d8                	mov    %ebx,%eax
  800a57:	c1 e0 08             	shl    $0x8,%eax
  800a5a:	89 df                	mov    %ebx,%edi
  800a5c:	c1 e7 18             	shl    $0x18,%edi
  800a5f:	89 de                	mov    %ebx,%esi
  800a61:	c1 e6 10             	shl    $0x10,%esi
  800a64:	09 f7                	or     %esi,%edi
  800a66:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
		             : "=D"(p), "=c"(n)
		             : "D"(p), "a"(c), "c"(n / 4)
  800a68:	c1 e9 02             	shr    $0x2,%ecx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  800a6b:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800a6d:	89 d7                	mov    %edx,%edi
  800a6f:	fc                   	cld    
  800a70:	f3 ab                	rep stos %eax,%es:(%edi)
  800a72:	eb 08                	jmp    800a7c <memset+0x43>
		             : "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a74:	89 d7                	mov    %edx,%edi
  800a76:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a79:	fc                   	cld    
  800a7a:	f3 aa                	rep stos %al,%es:(%edi)
		             : "=D"(p), "=c"(n)
		             : "0"(p), "a"(c), "1"(n)
		             : "cc", "memory");
	return v;
}
  800a7c:	89 d0                	mov    %edx,%eax
  800a7e:	5b                   	pop    %ebx
  800a7f:	5e                   	pop    %esi
  800a80:	5f                   	pop    %edi
  800a81:	5d                   	pop    %ebp
  800a82:	c3                   	ret    

00800a83 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a83:	55                   	push   %ebp
  800a84:	89 e5                	mov    %esp,%ebp
  800a86:	57                   	push   %edi
  800a87:	56                   	push   %esi
  800a88:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a8e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a91:	39 c6                	cmp    %eax,%esi
  800a93:	73 32                	jae    800ac7 <memmove+0x44>
  800a95:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a98:	39 c2                	cmp    %eax,%edx
  800a9a:	76 2b                	jbe    800ac7 <memmove+0x44>
		s += n;
		d += n;
  800a9c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  800a9f:	89 d6                	mov    %edx,%esi
  800aa1:	09 fe                	or     %edi,%esi
  800aa3:	09 ce                	or     %ecx,%esi
  800aa5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aab:	75 0e                	jne    800abb <memmove+0x38>
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  800aad:	83 ef 04             	sub    $0x4,%edi
			             "S"(s - 4),
  800ab0:	8d 72 fc             	lea    -0x4(%edx),%esi
			             "c"(n / 4)
  800ab3:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  800ab6:	fd                   	std    
  800ab7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ab9:	eb 09                	jmp    800ac4 <memmove+0x41>
			             : "cc", "memory");
		else
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  800abb:	83 ef 01             	sub    $0x1,%edi
			             "S"(s - 1),
  800abe:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  800ac1:	fd                   	std    
  800ac2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             "c"(n)
			             : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ac4:	fc                   	cld    
  800ac5:	eb 1a                	jmp    800ae1 <memmove+0x5e>
	} else {
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  800ac7:	89 f2                	mov    %esi,%edx
  800ac9:	09 c2                	or     %eax,%edx
  800acb:	09 ca                	or     %ecx,%edx
  800acd:	f6 c2 03             	test   $0x3,%dl
  800ad0:	75 0a                	jne    800adc <memmove+0x59>
			asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800ad2:	c1 e9 02             	shr    $0x2,%ecx
  800ad5:	89 c7                	mov    %eax,%edi
  800ad7:	fc                   	cld    
  800ad8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ada:	eb 05                	jmp    800ae1 <memmove+0x5e>
			             : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800adc:	89 c7                	mov    %eax,%edi
  800ade:	fc                   	cld    
  800adf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             : "cc", "memory");
	}
	return dst;
}
  800ae1:	5e                   	pop    %esi
  800ae2:	5f                   	pop    %edi
  800ae3:	5d                   	pop    %ebp
  800ae4:	c3                   	ret    

00800ae5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ae5:	55                   	push   %ebp
  800ae6:	89 e5                	mov    %esp,%ebp
  800ae8:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800aeb:	ff 75 10             	push   0x10(%ebp)
  800aee:	ff 75 0c             	push   0xc(%ebp)
  800af1:	ff 75 08             	push   0x8(%ebp)
  800af4:	e8 8a ff ff ff       	call   800a83 <memmove>
}
  800af9:	c9                   	leave  
  800afa:	c3                   	ret    

00800afb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	56                   	push   %esi
  800aff:	53                   	push   %ebx
  800b00:	8b 45 08             	mov    0x8(%ebp),%eax
  800b03:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b06:	89 c6                	mov    %eax,%esi
  800b08:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b0b:	eb 06                	jmp    800b13 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b0d:	83 c0 01             	add    $0x1,%eax
  800b10:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800b13:	39 f0                	cmp    %esi,%eax
  800b15:	74 14                	je     800b2b <memcmp+0x30>
		if (*s1 != *s2)
  800b17:	0f b6 08             	movzbl (%eax),%ecx
  800b1a:	0f b6 1a             	movzbl (%edx),%ebx
  800b1d:	38 d9                	cmp    %bl,%cl
  800b1f:	74 ec                	je     800b0d <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800b21:	0f b6 c1             	movzbl %cl,%eax
  800b24:	0f b6 db             	movzbl %bl,%ebx
  800b27:	29 d8                	sub    %ebx,%eax
  800b29:	eb 05                	jmp    800b30 <memcmp+0x35>
	}

	return 0;
  800b2b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b30:	5b                   	pop    %ebx
  800b31:	5e                   	pop    %esi
  800b32:	5d                   	pop    %ebp
  800b33:	c3                   	ret    

00800b34 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
  800b37:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b3d:	89 c2                	mov    %eax,%edx
  800b3f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b42:	eb 03                	jmp    800b47 <memfind+0x13>
  800b44:	83 c0 01             	add    $0x1,%eax
  800b47:	39 d0                	cmp    %edx,%eax
  800b49:	73 04                	jae    800b4f <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b4b:	38 08                	cmp    %cl,(%eax)
  800b4d:	75 f5                	jne    800b44 <memfind+0x10>
			break;
	return (void *) s;
}
  800b4f:	5d                   	pop    %ebp
  800b50:	c3                   	ret    

00800b51 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b51:	55                   	push   %ebp
  800b52:	89 e5                	mov    %esp,%ebp
  800b54:	57                   	push   %edi
  800b55:	56                   	push   %esi
  800b56:	53                   	push   %ebx
  800b57:	8b 55 08             	mov    0x8(%ebp),%edx
  800b5a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b5d:	eb 03                	jmp    800b62 <strtol+0x11>
		s++;
  800b5f:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b62:	0f b6 02             	movzbl (%edx),%eax
  800b65:	3c 20                	cmp    $0x20,%al
  800b67:	74 f6                	je     800b5f <strtol+0xe>
  800b69:	3c 09                	cmp    $0x9,%al
  800b6b:	74 f2                	je     800b5f <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b6d:	3c 2b                	cmp    $0x2b,%al
  800b6f:	74 2a                	je     800b9b <strtol+0x4a>
	int neg = 0;
  800b71:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b76:	3c 2d                	cmp    $0x2d,%al
  800b78:	74 2b                	je     800ba5 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b7a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b80:	75 0f                	jne    800b91 <strtol+0x40>
  800b82:	80 3a 30             	cmpb   $0x30,(%edx)
  800b85:	74 28                	je     800baf <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b87:	85 db                	test   %ebx,%ebx
  800b89:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b8e:	0f 44 d8             	cmove  %eax,%ebx
  800b91:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b96:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b99:	eb 46                	jmp    800be1 <strtol+0x90>
		s++;
  800b9b:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800b9e:	bf 00 00 00 00       	mov    $0x0,%edi
  800ba3:	eb d5                	jmp    800b7a <strtol+0x29>
		s++, neg = 1;
  800ba5:	83 c2 01             	add    $0x1,%edx
  800ba8:	bf 01 00 00 00       	mov    $0x1,%edi
  800bad:	eb cb                	jmp    800b7a <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800baf:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bb3:	74 0e                	je     800bc3 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800bb5:	85 db                	test   %ebx,%ebx
  800bb7:	75 d8                	jne    800b91 <strtol+0x40>
		s++, base = 8;
  800bb9:	83 c2 01             	add    $0x1,%edx
  800bbc:	bb 08 00 00 00       	mov    $0x8,%ebx
  800bc1:	eb ce                	jmp    800b91 <strtol+0x40>
		s += 2, base = 16;
  800bc3:	83 c2 02             	add    $0x2,%edx
  800bc6:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bcb:	eb c4                	jmp    800b91 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800bcd:	0f be c0             	movsbl %al,%eax
  800bd0:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bd3:	3b 45 10             	cmp    0x10(%ebp),%eax
  800bd6:	7d 3a                	jge    800c12 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800bd8:	83 c2 01             	add    $0x1,%edx
  800bdb:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800bdf:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800be1:	0f b6 02             	movzbl (%edx),%eax
  800be4:	8d 70 d0             	lea    -0x30(%eax),%esi
  800be7:	89 f3                	mov    %esi,%ebx
  800be9:	80 fb 09             	cmp    $0x9,%bl
  800bec:	76 df                	jbe    800bcd <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800bee:	8d 70 9f             	lea    -0x61(%eax),%esi
  800bf1:	89 f3                	mov    %esi,%ebx
  800bf3:	80 fb 19             	cmp    $0x19,%bl
  800bf6:	77 08                	ja     800c00 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800bf8:	0f be c0             	movsbl %al,%eax
  800bfb:	83 e8 57             	sub    $0x57,%eax
  800bfe:	eb d3                	jmp    800bd3 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800c00:	8d 70 bf             	lea    -0x41(%eax),%esi
  800c03:	89 f3                	mov    %esi,%ebx
  800c05:	80 fb 19             	cmp    $0x19,%bl
  800c08:	77 08                	ja     800c12 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800c0a:	0f be c0             	movsbl %al,%eax
  800c0d:	83 e8 37             	sub    $0x37,%eax
  800c10:	eb c1                	jmp    800bd3 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c12:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c16:	74 05                	je     800c1d <strtol+0xcc>
		*endptr = (char *) s;
  800c18:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c1b:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800c1d:	89 c8                	mov    %ecx,%eax
  800c1f:	f7 d8                	neg    %eax
  800c21:	85 ff                	test   %edi,%edi
  800c23:	0f 45 c8             	cmovne %eax,%ecx
}
  800c26:	89 c8                	mov    %ecx,%eax
  800c28:	5b                   	pop    %ebx
  800c29:	5e                   	pop    %esi
  800c2a:	5f                   	pop    %edi
  800c2b:	5d                   	pop    %ebp
  800c2c:	c3                   	ret    
  800c2d:	66 90                	xchg   %ax,%ax
  800c2f:	90                   	nop

00800c30 <__udivdi3>:
  800c30:	f3 0f 1e fb          	endbr32 
  800c34:	55                   	push   %ebp
  800c35:	57                   	push   %edi
  800c36:	56                   	push   %esi
  800c37:	53                   	push   %ebx
  800c38:	83 ec 1c             	sub    $0x1c,%esp
  800c3b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800c3f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800c43:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c47:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800c4b:	85 c0                	test   %eax,%eax
  800c4d:	75 19                	jne    800c68 <__udivdi3+0x38>
  800c4f:	39 f3                	cmp    %esi,%ebx
  800c51:	76 4d                	jbe    800ca0 <__udivdi3+0x70>
  800c53:	31 ff                	xor    %edi,%edi
  800c55:	89 e8                	mov    %ebp,%eax
  800c57:	89 f2                	mov    %esi,%edx
  800c59:	f7 f3                	div    %ebx
  800c5b:	89 fa                	mov    %edi,%edx
  800c5d:	83 c4 1c             	add    $0x1c,%esp
  800c60:	5b                   	pop    %ebx
  800c61:	5e                   	pop    %esi
  800c62:	5f                   	pop    %edi
  800c63:	5d                   	pop    %ebp
  800c64:	c3                   	ret    
  800c65:	8d 76 00             	lea    0x0(%esi),%esi
  800c68:	39 f0                	cmp    %esi,%eax
  800c6a:	76 14                	jbe    800c80 <__udivdi3+0x50>
  800c6c:	31 ff                	xor    %edi,%edi
  800c6e:	31 c0                	xor    %eax,%eax
  800c70:	89 fa                	mov    %edi,%edx
  800c72:	83 c4 1c             	add    $0x1c,%esp
  800c75:	5b                   	pop    %ebx
  800c76:	5e                   	pop    %esi
  800c77:	5f                   	pop    %edi
  800c78:	5d                   	pop    %ebp
  800c79:	c3                   	ret    
  800c7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800c80:	0f bd f8             	bsr    %eax,%edi
  800c83:	83 f7 1f             	xor    $0x1f,%edi
  800c86:	75 48                	jne    800cd0 <__udivdi3+0xa0>
  800c88:	39 f0                	cmp    %esi,%eax
  800c8a:	72 06                	jb     800c92 <__udivdi3+0x62>
  800c8c:	31 c0                	xor    %eax,%eax
  800c8e:	39 eb                	cmp    %ebp,%ebx
  800c90:	77 de                	ja     800c70 <__udivdi3+0x40>
  800c92:	b8 01 00 00 00       	mov    $0x1,%eax
  800c97:	eb d7                	jmp    800c70 <__udivdi3+0x40>
  800c99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ca0:	89 d9                	mov    %ebx,%ecx
  800ca2:	85 db                	test   %ebx,%ebx
  800ca4:	75 0b                	jne    800cb1 <__udivdi3+0x81>
  800ca6:	b8 01 00 00 00       	mov    $0x1,%eax
  800cab:	31 d2                	xor    %edx,%edx
  800cad:	f7 f3                	div    %ebx
  800caf:	89 c1                	mov    %eax,%ecx
  800cb1:	31 d2                	xor    %edx,%edx
  800cb3:	89 f0                	mov    %esi,%eax
  800cb5:	f7 f1                	div    %ecx
  800cb7:	89 c6                	mov    %eax,%esi
  800cb9:	89 e8                	mov    %ebp,%eax
  800cbb:	89 f7                	mov    %esi,%edi
  800cbd:	f7 f1                	div    %ecx
  800cbf:	89 fa                	mov    %edi,%edx
  800cc1:	83 c4 1c             	add    $0x1c,%esp
  800cc4:	5b                   	pop    %ebx
  800cc5:	5e                   	pop    %esi
  800cc6:	5f                   	pop    %edi
  800cc7:	5d                   	pop    %ebp
  800cc8:	c3                   	ret    
  800cc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800cd0:	89 f9                	mov    %edi,%ecx
  800cd2:	ba 20 00 00 00       	mov    $0x20,%edx
  800cd7:	29 fa                	sub    %edi,%edx
  800cd9:	d3 e0                	shl    %cl,%eax
  800cdb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cdf:	89 d1                	mov    %edx,%ecx
  800ce1:	89 d8                	mov    %ebx,%eax
  800ce3:	d3 e8                	shr    %cl,%eax
  800ce5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800ce9:	09 c1                	or     %eax,%ecx
  800ceb:	89 f0                	mov    %esi,%eax
  800ced:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800cf1:	89 f9                	mov    %edi,%ecx
  800cf3:	d3 e3                	shl    %cl,%ebx
  800cf5:	89 d1                	mov    %edx,%ecx
  800cf7:	d3 e8                	shr    %cl,%eax
  800cf9:	89 f9                	mov    %edi,%ecx
  800cfb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800cff:	89 eb                	mov    %ebp,%ebx
  800d01:	d3 e6                	shl    %cl,%esi
  800d03:	89 d1                	mov    %edx,%ecx
  800d05:	d3 eb                	shr    %cl,%ebx
  800d07:	09 f3                	or     %esi,%ebx
  800d09:	89 c6                	mov    %eax,%esi
  800d0b:	89 f2                	mov    %esi,%edx
  800d0d:	89 d8                	mov    %ebx,%eax
  800d0f:	f7 74 24 08          	divl   0x8(%esp)
  800d13:	89 d6                	mov    %edx,%esi
  800d15:	89 c3                	mov    %eax,%ebx
  800d17:	f7 64 24 0c          	mull   0xc(%esp)
  800d1b:	39 d6                	cmp    %edx,%esi
  800d1d:	72 19                	jb     800d38 <__udivdi3+0x108>
  800d1f:	89 f9                	mov    %edi,%ecx
  800d21:	d3 e5                	shl    %cl,%ebp
  800d23:	39 c5                	cmp    %eax,%ebp
  800d25:	73 04                	jae    800d2b <__udivdi3+0xfb>
  800d27:	39 d6                	cmp    %edx,%esi
  800d29:	74 0d                	je     800d38 <__udivdi3+0x108>
  800d2b:	89 d8                	mov    %ebx,%eax
  800d2d:	31 ff                	xor    %edi,%edi
  800d2f:	e9 3c ff ff ff       	jmp    800c70 <__udivdi3+0x40>
  800d34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d38:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800d3b:	31 ff                	xor    %edi,%edi
  800d3d:	e9 2e ff ff ff       	jmp    800c70 <__udivdi3+0x40>
  800d42:	66 90                	xchg   %ax,%ax
  800d44:	66 90                	xchg   %ax,%ax
  800d46:	66 90                	xchg   %ax,%ax
  800d48:	66 90                	xchg   %ax,%ax
  800d4a:	66 90                	xchg   %ax,%ax
  800d4c:	66 90                	xchg   %ax,%ax
  800d4e:	66 90                	xchg   %ax,%ax

00800d50 <__umoddi3>:
  800d50:	f3 0f 1e fb          	endbr32 
  800d54:	55                   	push   %ebp
  800d55:	57                   	push   %edi
  800d56:	56                   	push   %esi
  800d57:	53                   	push   %ebx
  800d58:	83 ec 1c             	sub    $0x1c,%esp
  800d5b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800d5f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800d63:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  800d67:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  800d6b:	89 f0                	mov    %esi,%eax
  800d6d:	89 da                	mov    %ebx,%edx
  800d6f:	85 ff                	test   %edi,%edi
  800d71:	75 15                	jne    800d88 <__umoddi3+0x38>
  800d73:	39 dd                	cmp    %ebx,%ebp
  800d75:	76 39                	jbe    800db0 <__umoddi3+0x60>
  800d77:	f7 f5                	div    %ebp
  800d79:	89 d0                	mov    %edx,%eax
  800d7b:	31 d2                	xor    %edx,%edx
  800d7d:	83 c4 1c             	add    $0x1c,%esp
  800d80:	5b                   	pop    %ebx
  800d81:	5e                   	pop    %esi
  800d82:	5f                   	pop    %edi
  800d83:	5d                   	pop    %ebp
  800d84:	c3                   	ret    
  800d85:	8d 76 00             	lea    0x0(%esi),%esi
  800d88:	39 df                	cmp    %ebx,%edi
  800d8a:	77 f1                	ja     800d7d <__umoddi3+0x2d>
  800d8c:	0f bd cf             	bsr    %edi,%ecx
  800d8f:	83 f1 1f             	xor    $0x1f,%ecx
  800d92:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800d96:	75 40                	jne    800dd8 <__umoddi3+0x88>
  800d98:	39 df                	cmp    %ebx,%edi
  800d9a:	72 04                	jb     800da0 <__umoddi3+0x50>
  800d9c:	39 f5                	cmp    %esi,%ebp
  800d9e:	77 dd                	ja     800d7d <__umoddi3+0x2d>
  800da0:	89 da                	mov    %ebx,%edx
  800da2:	89 f0                	mov    %esi,%eax
  800da4:	29 e8                	sub    %ebp,%eax
  800da6:	19 fa                	sbb    %edi,%edx
  800da8:	eb d3                	jmp    800d7d <__umoddi3+0x2d>
  800daa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800db0:	89 e9                	mov    %ebp,%ecx
  800db2:	85 ed                	test   %ebp,%ebp
  800db4:	75 0b                	jne    800dc1 <__umoddi3+0x71>
  800db6:	b8 01 00 00 00       	mov    $0x1,%eax
  800dbb:	31 d2                	xor    %edx,%edx
  800dbd:	f7 f5                	div    %ebp
  800dbf:	89 c1                	mov    %eax,%ecx
  800dc1:	89 d8                	mov    %ebx,%eax
  800dc3:	31 d2                	xor    %edx,%edx
  800dc5:	f7 f1                	div    %ecx
  800dc7:	89 f0                	mov    %esi,%eax
  800dc9:	f7 f1                	div    %ecx
  800dcb:	89 d0                	mov    %edx,%eax
  800dcd:	31 d2                	xor    %edx,%edx
  800dcf:	eb ac                	jmp    800d7d <__umoddi3+0x2d>
  800dd1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800dd8:	8b 44 24 04          	mov    0x4(%esp),%eax
  800ddc:	ba 20 00 00 00       	mov    $0x20,%edx
  800de1:	29 c2                	sub    %eax,%edx
  800de3:	89 c1                	mov    %eax,%ecx
  800de5:	89 e8                	mov    %ebp,%eax
  800de7:	d3 e7                	shl    %cl,%edi
  800de9:	89 d1                	mov    %edx,%ecx
  800deb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800def:	d3 e8                	shr    %cl,%eax
  800df1:	89 c1                	mov    %eax,%ecx
  800df3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800df7:	09 f9                	or     %edi,%ecx
  800df9:	89 df                	mov    %ebx,%edi
  800dfb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800dff:	89 c1                	mov    %eax,%ecx
  800e01:	d3 e5                	shl    %cl,%ebp
  800e03:	89 d1                	mov    %edx,%ecx
  800e05:	d3 ef                	shr    %cl,%edi
  800e07:	89 c1                	mov    %eax,%ecx
  800e09:	89 f0                	mov    %esi,%eax
  800e0b:	d3 e3                	shl    %cl,%ebx
  800e0d:	89 d1                	mov    %edx,%ecx
  800e0f:	89 fa                	mov    %edi,%edx
  800e11:	d3 e8                	shr    %cl,%eax
  800e13:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e18:	09 d8                	or     %ebx,%eax
  800e1a:	f7 74 24 08          	divl   0x8(%esp)
  800e1e:	89 d3                	mov    %edx,%ebx
  800e20:	d3 e6                	shl    %cl,%esi
  800e22:	f7 e5                	mul    %ebp
  800e24:	89 c7                	mov    %eax,%edi
  800e26:	89 d1                	mov    %edx,%ecx
  800e28:	39 d3                	cmp    %edx,%ebx
  800e2a:	72 06                	jb     800e32 <__umoddi3+0xe2>
  800e2c:	75 0e                	jne    800e3c <__umoddi3+0xec>
  800e2e:	39 c6                	cmp    %eax,%esi
  800e30:	73 0a                	jae    800e3c <__umoddi3+0xec>
  800e32:	29 e8                	sub    %ebp,%eax
  800e34:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800e38:	89 d1                	mov    %edx,%ecx
  800e3a:	89 c7                	mov    %eax,%edi
  800e3c:	89 f5                	mov    %esi,%ebp
  800e3e:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e42:	29 fd                	sub    %edi,%ebp
  800e44:	19 cb                	sbb    %ecx,%ebx
  800e46:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800e4b:	89 d8                	mov    %ebx,%eax
  800e4d:	d3 e0                	shl    %cl,%eax
  800e4f:	89 f1                	mov    %esi,%ecx
  800e51:	d3 ed                	shr    %cl,%ebp
  800e53:	d3 eb                	shr    %cl,%ebx
  800e55:	09 e8                	or     %ebp,%eax
  800e57:	89 da                	mov    %ebx,%edx
  800e59:	83 c4 1c             	add    $0x1c,%esp
  800e5c:	5b                   	pop    %ebx
  800e5d:	5e                   	pop    %esi
  800e5e:	5f                   	pop    %edi
  800e5f:	5d                   	pop    %ebp
  800e60:	c3                   	ret    
