
obj/user/badsegment:     formato del fichero elf32-i386


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
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void
umain(int argc, char **argv)
{
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800033:	66 b8 28 00          	mov    $0x28,%ax
  800037:	8e d8                	mov    %eax,%ds
}
  800039:	c3                   	ret    

0080003a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003a:	55                   	push   %ebp
  80003b:	89 e5                	mov    %esp,%ebp
  80003d:	56                   	push   %esi
  80003e:	53                   	push   %ebx
  80003f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800042:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	envid_t id = sys_getenvid();
  800045:	e8 04 01 00 00       	call   80014e <sys_getenvid>
	if (id >= 0)
  80004a:	85 c0                	test   %eax,%eax
  80004c:	78 15                	js     800063 <libmain+0x29>
		thisenv = &envs[ENVX(id)];
  80004e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800053:	69 c0 88 00 00 00    	imul   $0x88,%eax,%eax
  800059:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005e:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800063:	85 db                	test   %ebx,%ebx
  800065:	7e 07                	jle    80006e <libmain+0x34>
		binaryname = argv[0];
  800067:	8b 06                	mov    (%esi),%eax
  800069:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80006e:	83 ec 08             	sub    $0x8,%esp
  800071:	56                   	push   %esi
  800072:	53                   	push   %ebx
  800073:	e8 bb ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800078:	e8 0a 00 00 00       	call   800087 <exit>
}
  80007d:	83 c4 10             	add    $0x10,%esp
  800080:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800083:	5b                   	pop    %ebx
  800084:	5e                   	pop    %esi
  800085:	5d                   	pop    %ebp
  800086:	c3                   	ret    

00800087 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800087:	55                   	push   %ebp
  800088:	89 e5                	mov    %esp,%ebp
  80008a:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80008d:	6a 00                	push   $0x0
  80008f:	e8 98 00 00 00       	call   80012c <sys_env_destroy>
}
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	c9                   	leave  
  800098:	c3                   	ret    

00800099 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800099:	55                   	push   %ebp
  80009a:	89 e5                	mov    %esp,%ebp
  80009c:	57                   	push   %edi
  80009d:	56                   	push   %esi
  80009e:	53                   	push   %ebx
  80009f:	83 ec 1c             	sub    $0x1c,%esp
  8000a2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8000a5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8000a8:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile(
  8000aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000b0:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000b3:	8b 75 14             	mov    0x14(%ebp),%esi
  8000b6:	cd 30                	int    $0x30
	        "int %1\n"
	        : "=a"(ret)
	        : "i"(T_SYSCALL), "a"(num), "d"(a1), "c"(a2), "b"(a3), "D"(a4), "S"(a5)
	        : "cc", "memory");

	if (check && ret > 0)
  8000b8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000bc:	74 04                	je     8000c2 <syscall+0x29>
  8000be:	85 c0                	test   %eax,%eax
  8000c0:	7f 08                	jg     8000ca <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  8000c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000c5:	5b                   	pop    %ebx
  8000c6:	5e                   	pop    %esi
  8000c7:	5f                   	pop    %edi
  8000c8:	5d                   	pop    %ebp
  8000c9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8000ca:	83 ec 0c             	sub    $0xc,%esp
  8000cd:	50                   	push   %eax
  8000ce:	ff 75 e0             	push   -0x20(%ebp)
  8000d1:	68 8a 0e 80 00       	push   $0x800e8a
  8000d6:	6a 1e                	push   $0x1e
  8000d8:	68 a7 0e 80 00       	push   $0x800ea7
  8000dd:	e8 f7 01 00 00       	call   8002d9 <_panic>

008000e2 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  8000e2:	55                   	push   %ebp
  8000e3:	89 e5                	mov    %esp,%ebp
  8000e5:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t) s, len, 0, 0, 0);
  8000e8:	6a 00                	push   $0x0
  8000ea:	6a 00                	push   $0x0
  8000ec:	6a 00                	push   $0x0
  8000ee:	ff 75 0c             	push   0xc(%ebp)
  8000f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8000f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8000fe:	e8 96 ff ff ff       	call   800099 <syscall>
}
  800103:	83 c4 10             	add    $0x10,%esp
  800106:	c9                   	leave  
  800107:	c3                   	ret    

00800108 <sys_cgetc>:

int
sys_cgetc(void)
{
  800108:	55                   	push   %ebp
  800109:	89 e5                	mov    %esp,%ebp
  80010b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  80010e:	6a 00                	push   $0x0
  800110:	6a 00                	push   $0x0
  800112:	6a 00                	push   $0x0
  800114:	6a 00                	push   $0x0
  800116:	b9 00 00 00 00       	mov    $0x0,%ecx
  80011b:	ba 00 00 00 00       	mov    $0x0,%edx
  800120:	b8 01 00 00 00       	mov    $0x1,%eax
  800125:	e8 6f ff ff ff       	call   800099 <syscall>
}
  80012a:	c9                   	leave  
  80012b:	c3                   	ret    

0080012c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80012c:	55                   	push   %ebp
  80012d:	89 e5                	mov    %esp,%ebp
  80012f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800132:	6a 00                	push   $0x0
  800134:	6a 00                	push   $0x0
  800136:	6a 00                	push   $0x0
  800138:	6a 00                	push   $0x0
  80013a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80013d:	ba 01 00 00 00       	mov    $0x1,%edx
  800142:	b8 03 00 00 00       	mov    $0x3,%eax
  800147:	e8 4d ff ff ff       	call   800099 <syscall>
}
  80014c:	c9                   	leave  
  80014d:	c3                   	ret    

0080014e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80014e:	55                   	push   %ebp
  80014f:	89 e5                	mov    %esp,%ebp
  800151:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800154:	6a 00                	push   $0x0
  800156:	6a 00                	push   $0x0
  800158:	6a 00                	push   $0x0
  80015a:	6a 00                	push   $0x0
  80015c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800161:	ba 00 00 00 00       	mov    $0x0,%edx
  800166:	b8 02 00 00 00       	mov    $0x2,%eax
  80016b:	e8 29 ff ff ff       	call   800099 <syscall>
}
  800170:	c9                   	leave  
  800171:	c3                   	ret    

00800172 <sys_yield>:

void
sys_yield(void)
{
  800172:	55                   	push   %ebp
  800173:	89 e5                	mov    %esp,%ebp
  800175:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800178:	6a 00                	push   $0x0
  80017a:	6a 00                	push   $0x0
  80017c:	6a 00                	push   $0x0
  80017e:	6a 00                	push   $0x0
  800180:	b9 00 00 00 00       	mov    $0x0,%ecx
  800185:	ba 00 00 00 00       	mov    $0x0,%edx
  80018a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80018f:	e8 05 ff ff ff       	call   800099 <syscall>
}
  800194:	83 c4 10             	add    $0x10,%esp
  800197:	c9                   	leave  
  800198:	c3                   	ret    

00800199 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  80019f:	6a 00                	push   $0x0
  8001a1:	6a 00                	push   $0x0
  8001a3:	ff 75 10             	push   0x10(%ebp)
  8001a6:	ff 75 0c             	push   0xc(%ebp)
  8001a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ac:	ba 01 00 00 00       	mov    $0x1,%edx
  8001b1:	b8 04 00 00 00       	mov    $0x4,%eax
  8001b6:	e8 de fe ff ff       	call   800099 <syscall>
}
  8001bb:	c9                   	leave  
  8001bc:	c3                   	ret    

008001bd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001bd:	55                   	push   %ebp
  8001be:	89 e5                	mov    %esp,%ebp
  8001c0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map,
  8001c3:	ff 75 18             	push   0x18(%ebp)
  8001c6:	ff 75 14             	push   0x14(%ebp)
  8001c9:	ff 75 10             	push   0x10(%ebp)
  8001cc:	ff 75 0c             	push   0xc(%ebp)
  8001cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001d2:	ba 01 00 00 00       	mov    $0x1,%edx
  8001d7:	b8 05 00 00 00       	mov    $0x5,%eax
  8001dc:	e8 b8 fe ff ff       	call   800099 <syscall>
	               srcenv,
	               (uint32_t) srcva,
	               dstenv,
	               (uint32_t) dstva,
	               perm);
}
  8001e1:	c9                   	leave  
  8001e2:	c3                   	ret    

008001e3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e3:	55                   	push   %ebp
  8001e4:	89 e5                	mov    %esp,%ebp
  8001e6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8001e9:	6a 00                	push   $0x0
  8001eb:	6a 00                	push   $0x0
  8001ed:	6a 00                	push   $0x0
  8001ef:	ff 75 0c             	push   0xc(%ebp)
  8001f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001f5:	ba 01 00 00 00       	mov    $0x1,%edx
  8001fa:	b8 06 00 00 00       	mov    $0x6,%eax
  8001ff:	e8 95 fe ff ff       	call   800099 <syscall>
}
  800204:	c9                   	leave  
  800205:	c3                   	ret    

00800206 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800206:	55                   	push   %ebp
  800207:	89 e5                	mov    %esp,%ebp
  800209:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80020c:	6a 00                	push   $0x0
  80020e:	6a 00                	push   $0x0
  800210:	6a 00                	push   $0x0
  800212:	ff 75 0c             	push   0xc(%ebp)
  800215:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800218:	ba 01 00 00 00       	mov    $0x1,%edx
  80021d:	b8 08 00 00 00       	mov    $0x8,%eax
  800222:	e8 72 fe ff ff       	call   800099 <syscall>
}
  800227:	c9                   	leave  
  800228:	c3                   	ret    

00800229 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800229:	55                   	push   %ebp
  80022a:	89 e5                	mov    %esp,%ebp
  80022c:	83 ec 08             	sub    $0x8,%esp
	return syscall(
  80022f:	6a 00                	push   $0x0
  800231:	6a 00                	push   $0x0
  800233:	6a 00                	push   $0x0
  800235:	ff 75 0c             	push   0xc(%ebp)
  800238:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80023b:	ba 01 00 00 00       	mov    $0x1,%edx
  800240:	b8 09 00 00 00       	mov    $0x9,%eax
  800245:	e8 4f fe ff ff       	call   800099 <syscall>
	        SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80024a:	c9                   	leave  
  80024b:	c3                   	ret    

0080024c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80024c:	55                   	push   %ebp
  80024d:	89 e5                	mov    %esp,%ebp
  80024f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800252:	6a 00                	push   $0x0
  800254:	ff 75 14             	push   0x14(%ebp)
  800257:	ff 75 10             	push   0x10(%ebp)
  80025a:	ff 75 0c             	push   0xc(%ebp)
  80025d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800260:	ba 00 00 00 00       	mov    $0x0,%edx
  800265:	b8 0b 00 00 00       	mov    $0xb,%eax
  80026a:	e8 2a fe ff ff       	call   800099 <syscall>
}
  80026f:	c9                   	leave  
  800270:	c3                   	ret    

00800271 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800271:	55                   	push   %ebp
  800272:	89 e5                	mov    %esp,%ebp
  800274:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t) dstva, 0, 0, 0, 0);
  800277:	6a 00                	push   $0x0
  800279:	6a 00                	push   $0x0
  80027b:	6a 00                	push   $0x0
  80027d:	6a 00                	push   $0x0
  80027f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800282:	ba 01 00 00 00       	mov    $0x1,%edx
  800287:	b8 0c 00 00 00       	mov    $0xc,%eax
  80028c:	e8 08 fe ff ff       	call   800099 <syscall>
}
  800291:	c9                   	leave  
  800292:	c3                   	ret    

00800293 <sys_get_priority>:

// Get priority of the current process
int
sys_get_priority(void)
{
  800293:	55                   	push   %ebp
  800294:	89 e5                	mov    %esp,%ebp
  800296:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_get_priority, 0, 0, 0, 0, 0, 0);
  800299:	6a 00                	push   $0x0
  80029b:	6a 00                	push   $0x0
  80029d:	6a 00                	push   $0x0
  80029f:	6a 00                	push   $0x0
  8002a1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ab:	b8 0d 00 00 00       	mov    $0xd,%eax
  8002b0:	e8 e4 fd ff ff       	call   800099 <syscall>
}
  8002b5:	c9                   	leave  
  8002b6:	c3                   	ret    

008002b7 <sys_set_priority>:

// Get priority of the current process
int
sys_set_priority(unsigned int priority)
{
  8002b7:	55                   	push   %ebp
  8002b8:	89 e5                	mov    %esp,%ebp
  8002ba:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, (uint32_t) priority, 0, 0, 0, 0);
  8002bd:	6a 00                	push   $0x0
  8002bf:	6a 00                	push   $0x0
  8002c1:	6a 00                	push   $0x0
  8002c3:	6a 00                	push   $0x0
  8002c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8002cd:	b8 0e 00 00 00       	mov    $0xe,%eax
  8002d2:	e8 c2 fd ff ff       	call   800099 <syscall>
}
  8002d7:	c9                   	leave  
  8002d8:	c3                   	ret    

008002d9 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002d9:	55                   	push   %ebp
  8002da:	89 e5                	mov    %esp,%ebp
  8002dc:	56                   	push   %esi
  8002dd:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002de:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002e1:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8002e7:	e8 62 fe ff ff       	call   80014e <sys_getenvid>
  8002ec:	83 ec 0c             	sub    $0xc,%esp
  8002ef:	ff 75 0c             	push   0xc(%ebp)
  8002f2:	ff 75 08             	push   0x8(%ebp)
  8002f5:	56                   	push   %esi
  8002f6:	50                   	push   %eax
  8002f7:	68 b8 0e 80 00       	push   $0x800eb8
  8002fc:	e8 b3 00 00 00       	call   8003b4 <cprintf>
	        sys_getenvid(),
	        binaryname,
	        file,
	        line);
	vcprintf(fmt, ap);
  800301:	83 c4 18             	add    $0x18,%esp
  800304:	53                   	push   %ebx
  800305:	ff 75 10             	push   0x10(%ebp)
  800308:	e8 56 00 00 00       	call   800363 <vcprintf>
	cprintf("\n");
  80030d:	c7 04 24 db 0e 80 00 	movl   $0x800edb,(%esp)
  800314:	e8 9b 00 00 00       	call   8003b4 <cprintf>
  800319:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80031c:	cc                   	int3   
  80031d:	eb fd                	jmp    80031c <_panic+0x43>

0080031f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80031f:	55                   	push   %ebp
  800320:	89 e5                	mov    %esp,%ebp
  800322:	53                   	push   %ebx
  800323:	83 ec 04             	sub    $0x4,%esp
  800326:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800329:	8b 13                	mov    (%ebx),%edx
  80032b:	8d 42 01             	lea    0x1(%edx),%eax
  80032e:	89 03                	mov    %eax,(%ebx)
  800330:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800333:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256 - 1) {
  800337:	3d ff 00 00 00       	cmp    $0xff,%eax
  80033c:	74 09                	je     800347 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80033e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800342:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800345:	c9                   	leave  
  800346:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800347:	83 ec 08             	sub    $0x8,%esp
  80034a:	68 ff 00 00 00       	push   $0xff
  80034f:	8d 43 08             	lea    0x8(%ebx),%eax
  800352:	50                   	push   %eax
  800353:	e8 8a fd ff ff       	call   8000e2 <sys_cputs>
		b->idx = 0;
  800358:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80035e:	83 c4 10             	add    $0x10,%esp
  800361:	eb db                	jmp    80033e <putch+0x1f>

00800363 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800363:	55                   	push   %ebp
  800364:	89 e5                	mov    %esp,%ebp
  800366:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80036c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800373:	00 00 00 
	b.cnt = 0;
  800376:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80037d:	00 00 00 
	vprintfmt((void *) putch, &b, fmt, ap);
  800380:	ff 75 0c             	push   0xc(%ebp)
  800383:	ff 75 08             	push   0x8(%ebp)
  800386:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80038c:	50                   	push   %eax
  80038d:	68 1f 03 80 00       	push   $0x80031f
  800392:	e8 74 01 00 00       	call   80050b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800397:	83 c4 08             	add    $0x8,%esp
  80039a:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8003a0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003a6:	50                   	push   %eax
  8003a7:	e8 36 fd ff ff       	call   8000e2 <sys_cputs>

	return b.cnt;
}
  8003ac:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003b2:	c9                   	leave  
  8003b3:	c3                   	ret    

008003b4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003b4:	55                   	push   %ebp
  8003b5:	89 e5                	mov    %esp,%ebp
  8003b7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003ba:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003bd:	50                   	push   %eax
  8003be:	ff 75 08             	push   0x8(%ebp)
  8003c1:	e8 9d ff ff ff       	call   800363 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003c6:	c9                   	leave  
  8003c7:	c3                   	ret    

008003c8 <printnum>:
         void *putdat,
         unsigned long long num,
         unsigned base,
         int width,
         int padc)
{
  8003c8:	55                   	push   %ebp
  8003c9:	89 e5                	mov    %esp,%ebp
  8003cb:	57                   	push   %edi
  8003cc:	56                   	push   %esi
  8003cd:	53                   	push   %ebx
  8003ce:	83 ec 1c             	sub    $0x1c,%esp
  8003d1:	89 c7                	mov    %eax,%edi
  8003d3:	89 d6                	mov    %edx,%esi
  8003d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003db:	89 d1                	mov    %edx,%ecx
  8003dd:	89 c2                	mov    %eax,%edx
  8003df:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003e2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8003e5:	8b 45 10             	mov    0x10(%ebp),%eax
  8003e8:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003eb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ee:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003f5:	39 c2                	cmp    %eax,%edx
  8003f7:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8003fa:	72 3e                	jb     80043a <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003fc:	83 ec 0c             	sub    $0xc,%esp
  8003ff:	ff 75 18             	push   0x18(%ebp)
  800402:	83 eb 01             	sub    $0x1,%ebx
  800405:	53                   	push   %ebx
  800406:	50                   	push   %eax
  800407:	83 ec 08             	sub    $0x8,%esp
  80040a:	ff 75 e4             	push   -0x1c(%ebp)
  80040d:	ff 75 e0             	push   -0x20(%ebp)
  800410:	ff 75 dc             	push   -0x24(%ebp)
  800413:	ff 75 d8             	push   -0x28(%ebp)
  800416:	e8 25 08 00 00       	call   800c40 <__udivdi3>
  80041b:	83 c4 18             	add    $0x18,%esp
  80041e:	52                   	push   %edx
  80041f:	50                   	push   %eax
  800420:	89 f2                	mov    %esi,%edx
  800422:	89 f8                	mov    %edi,%eax
  800424:	e8 9f ff ff ff       	call   8003c8 <printnum>
  800429:	83 c4 20             	add    $0x20,%esp
  80042c:	eb 13                	jmp    800441 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80042e:	83 ec 08             	sub    $0x8,%esp
  800431:	56                   	push   %esi
  800432:	ff 75 18             	push   0x18(%ebp)
  800435:	ff d7                	call   *%edi
  800437:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80043a:	83 eb 01             	sub    $0x1,%ebx
  80043d:	85 db                	test   %ebx,%ebx
  80043f:	7f ed                	jg     80042e <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800441:	83 ec 08             	sub    $0x8,%esp
  800444:	56                   	push   %esi
  800445:	83 ec 04             	sub    $0x4,%esp
  800448:	ff 75 e4             	push   -0x1c(%ebp)
  80044b:	ff 75 e0             	push   -0x20(%ebp)
  80044e:	ff 75 dc             	push   -0x24(%ebp)
  800451:	ff 75 d8             	push   -0x28(%ebp)
  800454:	e8 07 09 00 00       	call   800d60 <__umoddi3>
  800459:	83 c4 14             	add    $0x14,%esp
  80045c:	0f be 80 dd 0e 80 00 	movsbl 0x800edd(%eax),%eax
  800463:	50                   	push   %eax
  800464:	ff d7                	call   *%edi
}
  800466:	83 c4 10             	add    $0x10,%esp
  800469:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80046c:	5b                   	pop    %ebx
  80046d:	5e                   	pop    %esi
  80046e:	5f                   	pop    %edi
  80046f:	5d                   	pop    %ebp
  800470:	c3                   	ret    

00800471 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800471:	83 fa 01             	cmp    $0x1,%edx
  800474:	7f 13                	jg     800489 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800476:	85 d2                	test   %edx,%edx
  800478:	74 1c                	je     800496 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  80047a:	8b 10                	mov    (%eax),%edx
  80047c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80047f:	89 08                	mov    %ecx,(%eax)
  800481:	8b 02                	mov    (%edx),%eax
  800483:	ba 00 00 00 00       	mov    $0x0,%edx
  800488:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  800489:	8b 10                	mov    (%eax),%edx
  80048b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80048e:	89 08                	mov    %ecx,(%eax)
  800490:	8b 02                	mov    (%edx),%eax
  800492:	8b 52 04             	mov    0x4(%edx),%edx
  800495:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  800496:	8b 10                	mov    (%eax),%edx
  800498:	8d 4a 04             	lea    0x4(%edx),%ecx
  80049b:	89 08                	mov    %ecx,(%eax)
  80049d:	8b 02                	mov    (%edx),%eax
  80049f:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004a4:	c3                   	ret    

008004a5 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004a5:	83 fa 01             	cmp    $0x1,%edx
  8004a8:	7f 0f                	jg     8004b9 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  8004aa:	85 d2                	test   %edx,%edx
  8004ac:	74 18                	je     8004c6 <getint+0x21>
		return va_arg(*ap, long);
  8004ae:	8b 10                	mov    (%eax),%edx
  8004b0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004b3:	89 08                	mov    %ecx,(%eax)
  8004b5:	8b 02                	mov    (%edx),%eax
  8004b7:	99                   	cltd   
  8004b8:	c3                   	ret    
		return va_arg(*ap, long long);
  8004b9:	8b 10                	mov    (%eax),%edx
  8004bb:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004be:	89 08                	mov    %ecx,(%eax)
  8004c0:	8b 02                	mov    (%edx),%eax
  8004c2:	8b 52 04             	mov    0x4(%edx),%edx
  8004c5:	c3                   	ret    
	else
		return va_arg(*ap, int);
  8004c6:	8b 10                	mov    (%eax),%edx
  8004c8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004cb:	89 08                	mov    %ecx,(%eax)
  8004cd:	8b 02                	mov    (%edx),%eax
  8004cf:	99                   	cltd   
}
  8004d0:	c3                   	ret    

008004d1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004d1:	55                   	push   %ebp
  8004d2:	89 e5                	mov    %esp,%ebp
  8004d4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004d7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004db:	8b 10                	mov    (%eax),%edx
  8004dd:	3b 50 04             	cmp    0x4(%eax),%edx
  8004e0:	73 0a                	jae    8004ec <sprintputch+0x1b>
		*b->buf++ = ch;
  8004e2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004e5:	89 08                	mov    %ecx,(%eax)
  8004e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ea:	88 02                	mov    %al,(%edx)
}
  8004ec:	5d                   	pop    %ebp
  8004ed:	c3                   	ret    

008004ee <printfmt>:
{
  8004ee:	55                   	push   %ebp
  8004ef:	89 e5                	mov    %esp,%ebp
  8004f1:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8004f4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004f7:	50                   	push   %eax
  8004f8:	ff 75 10             	push   0x10(%ebp)
  8004fb:	ff 75 0c             	push   0xc(%ebp)
  8004fe:	ff 75 08             	push   0x8(%ebp)
  800501:	e8 05 00 00 00       	call   80050b <vprintfmt>
}
  800506:	83 c4 10             	add    $0x10,%esp
  800509:	c9                   	leave  
  80050a:	c3                   	ret    

0080050b <vprintfmt>:
{
  80050b:	55                   	push   %ebp
  80050c:	89 e5                	mov    %esp,%ebp
  80050e:	57                   	push   %edi
  80050f:	56                   	push   %esi
  800510:	53                   	push   %ebx
  800511:	83 ec 2c             	sub    $0x2c,%esp
  800514:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800517:	8b 75 0c             	mov    0xc(%ebp),%esi
  80051a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80051d:	eb 0a                	jmp    800529 <vprintfmt+0x1e>
			putch(ch, putdat);
  80051f:	83 ec 08             	sub    $0x8,%esp
  800522:	56                   	push   %esi
  800523:	50                   	push   %eax
  800524:	ff d3                	call   *%ebx
  800526:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800529:	83 c7 01             	add    $0x1,%edi
  80052c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800530:	83 f8 25             	cmp    $0x25,%eax
  800533:	74 0c                	je     800541 <vprintfmt+0x36>
			if (ch == '\0')
  800535:	85 c0                	test   %eax,%eax
  800537:	75 e6                	jne    80051f <vprintfmt+0x14>
}
  800539:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80053c:	5b                   	pop    %ebx
  80053d:	5e                   	pop    %esi
  80053e:	5f                   	pop    %edi
  80053f:	5d                   	pop    %ebp
  800540:	c3                   	ret    
		padc = ' ';
  800541:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
		altflag = 0;
  800545:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80054c:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800553:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80055a:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80055f:	8d 47 01             	lea    0x1(%edi),%eax
  800562:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800565:	0f b6 17             	movzbl (%edi),%edx
  800568:	8d 42 dd             	lea    -0x23(%edx),%eax
  80056b:	3c 55                	cmp    $0x55,%al
  80056d:	0f 87 b7 02 00 00    	ja     80082a <vprintfmt+0x31f>
  800573:	0f b6 c0             	movzbl %al,%eax
  800576:	ff 24 85 a0 0f 80 00 	jmp    *0x800fa0(,%eax,4)
  80057d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800580:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800584:	eb d9                	jmp    80055f <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800586:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800589:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  80058d:	eb d0                	jmp    80055f <vprintfmt+0x54>
  80058f:	0f b6 d2             	movzbl %dl,%edx
  800592:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0;; ++fmt) {
  800595:	b8 00 00 00 00       	mov    $0x0,%eax
  80059a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80059d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005a0:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8005a4:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8005a7:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8005aa:	83 f9 09             	cmp    $0x9,%ecx
  8005ad:	77 52                	ja     800601 <vprintfmt+0xf6>
			for (precision = 0;; ++fmt) {
  8005af:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8005b2:	eb e9                	jmp    80059d <vprintfmt+0x92>
			precision = va_arg(ap, int);
  8005b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b7:	8d 50 04             	lea    0x4(%eax),%edx
  8005ba:	89 55 14             	mov    %edx,0x14(%ebp)
  8005bd:	8b 00                	mov    (%eax),%eax
  8005bf:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8005c5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005c9:	79 94                	jns    80055f <vprintfmt+0x54>
				width = precision, precision = -1;
  8005cb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005ce:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005d1:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8005d8:	eb 85                	jmp    80055f <vprintfmt+0x54>
  8005da:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005dd:	85 d2                	test   %edx,%edx
  8005df:	b8 00 00 00 00       	mov    $0x0,%eax
  8005e4:	0f 49 c2             	cmovns %edx,%eax
  8005e7:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005ed:	e9 6d ff ff ff       	jmp    80055f <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8005f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8005f5:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8005fc:	e9 5e ff ff ff       	jmp    80055f <vprintfmt+0x54>
  800601:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800604:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800607:	eb bc                	jmp    8005c5 <vprintfmt+0xba>
			lflag++;
  800609:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80060c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80060f:	e9 4b ff ff ff       	jmp    80055f <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800614:	8b 45 14             	mov    0x14(%ebp),%eax
  800617:	8d 50 04             	lea    0x4(%eax),%edx
  80061a:	89 55 14             	mov    %edx,0x14(%ebp)
  80061d:	83 ec 08             	sub    $0x8,%esp
  800620:	56                   	push   %esi
  800621:	ff 30                	push   (%eax)
  800623:	ff d3                	call   *%ebx
			break;
  800625:	83 c4 10             	add    $0x10,%esp
  800628:	e9 94 01 00 00       	jmp    8007c1 <vprintfmt+0x2b6>
			err = va_arg(ap, int);
  80062d:	8b 45 14             	mov    0x14(%ebp),%eax
  800630:	8d 50 04             	lea    0x4(%eax),%edx
  800633:	89 55 14             	mov    %edx,0x14(%ebp)
  800636:	8b 10                	mov    (%eax),%edx
  800638:	89 d0                	mov    %edx,%eax
  80063a:	f7 d8                	neg    %eax
  80063c:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80063f:	83 f8 08             	cmp    $0x8,%eax
  800642:	7f 20                	jg     800664 <vprintfmt+0x159>
  800644:	8b 14 85 00 11 80 00 	mov    0x801100(,%eax,4),%edx
  80064b:	85 d2                	test   %edx,%edx
  80064d:	74 15                	je     800664 <vprintfmt+0x159>
				printfmt(putch, putdat, "%s", p);
  80064f:	52                   	push   %edx
  800650:	68 fe 0e 80 00       	push   $0x800efe
  800655:	56                   	push   %esi
  800656:	53                   	push   %ebx
  800657:	e8 92 fe ff ff       	call   8004ee <printfmt>
  80065c:	83 c4 10             	add    $0x10,%esp
  80065f:	e9 5d 01 00 00       	jmp    8007c1 <vprintfmt+0x2b6>
				printfmt(putch, putdat, "error %d", err);
  800664:	50                   	push   %eax
  800665:	68 f5 0e 80 00       	push   $0x800ef5
  80066a:	56                   	push   %esi
  80066b:	53                   	push   %ebx
  80066c:	e8 7d fe ff ff       	call   8004ee <printfmt>
  800671:	83 c4 10             	add    $0x10,%esp
  800674:	e9 48 01 00 00       	jmp    8007c1 <vprintfmt+0x2b6>
			if ((p = va_arg(ap, char *)) == NULL)
  800679:	8b 45 14             	mov    0x14(%ebp),%eax
  80067c:	8d 50 04             	lea    0x4(%eax),%edx
  80067f:	89 55 14             	mov    %edx,0x14(%ebp)
  800682:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800684:	85 ff                	test   %edi,%edi
  800686:	b8 ee 0e 80 00       	mov    $0x800eee,%eax
  80068b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80068e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800692:	7e 06                	jle    80069a <vprintfmt+0x18f>
  800694:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  800698:	75 0a                	jne    8006a4 <vprintfmt+0x199>
  80069a:	89 f8                	mov    %edi,%eax
  80069c:	03 45 e0             	add    -0x20(%ebp),%eax
  80069f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006a2:	eb 59                	jmp    8006fd <vprintfmt+0x1f2>
				for (width -= strnlen(p, precision); width > 0;
  8006a4:	83 ec 08             	sub    $0x8,%esp
  8006a7:	ff 75 d8             	push   -0x28(%ebp)
  8006aa:	57                   	push   %edi
  8006ab:	e8 1a 02 00 00       	call   8008ca <strnlen>
  8006b0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006b3:	29 c1                	sub    %eax,%ecx
  8006b5:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006b8:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006bb:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  8006bf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006c2:	89 7d d0             	mov    %edi,-0x30(%ebp)
  8006c5:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0;
  8006c7:	eb 0f                	jmp    8006d8 <vprintfmt+0x1cd>
					putch(padc, putdat);
  8006c9:	83 ec 08             	sub    $0x8,%esp
  8006cc:	56                   	push   %esi
  8006cd:	ff 75 e0             	push   -0x20(%ebp)
  8006d0:	ff d3                	call   *%ebx
				     width--)
  8006d2:	83 ef 01             	sub    $0x1,%edi
  8006d5:	83 c4 10             	add    $0x10,%esp
				for (width -= strnlen(p, precision); width > 0;
  8006d8:	85 ff                	test   %edi,%edi
  8006da:	7f ed                	jg     8006c9 <vprintfmt+0x1be>
  8006dc:	8b 7d d0             	mov    -0x30(%ebp),%edi
  8006df:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006e2:	85 c9                	test   %ecx,%ecx
  8006e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e9:	0f 49 c1             	cmovns %ecx,%eax
  8006ec:	29 c1                	sub    %eax,%ecx
  8006ee:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8006f1:	eb a7                	jmp    80069a <vprintfmt+0x18f>
					putch(ch, putdat);
  8006f3:	83 ec 08             	sub    $0x8,%esp
  8006f6:	56                   	push   %esi
  8006f7:	52                   	push   %edx
  8006f8:	ff d3                	call   *%ebx
  8006fa:	83 c4 10             	add    $0x10,%esp
  8006fd:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800700:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' &&
  800702:	83 c7 01             	add    $0x1,%edi
  800705:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800709:	0f be d0             	movsbl %al,%edx
  80070c:	85 d2                	test   %edx,%edx
  80070e:	74 42                	je     800752 <vprintfmt+0x247>
  800710:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800714:	78 06                	js     80071c <vprintfmt+0x211>
			       (precision < 0 || --precision >= 0);
  800716:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80071a:	78 1e                	js     80073a <vprintfmt+0x22f>
				if (altflag && (ch < ' ' || ch > '~'))
  80071c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800720:	74 d1                	je     8006f3 <vprintfmt+0x1e8>
  800722:	0f be c0             	movsbl %al,%eax
  800725:	83 e8 20             	sub    $0x20,%eax
  800728:	83 f8 5e             	cmp    $0x5e,%eax
  80072b:	76 c6                	jbe    8006f3 <vprintfmt+0x1e8>
					putch('?', putdat);
  80072d:	83 ec 08             	sub    $0x8,%esp
  800730:	56                   	push   %esi
  800731:	6a 3f                	push   $0x3f
  800733:	ff d3                	call   *%ebx
  800735:	83 c4 10             	add    $0x10,%esp
  800738:	eb c3                	jmp    8006fd <vprintfmt+0x1f2>
  80073a:	89 cf                	mov    %ecx,%edi
  80073c:	eb 0e                	jmp    80074c <vprintfmt+0x241>
				putch(' ', putdat);
  80073e:	83 ec 08             	sub    $0x8,%esp
  800741:	56                   	push   %esi
  800742:	6a 20                	push   $0x20
  800744:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  800746:	83 ef 01             	sub    $0x1,%edi
  800749:	83 c4 10             	add    $0x10,%esp
  80074c:	85 ff                	test   %edi,%edi
  80074e:	7f ee                	jg     80073e <vprintfmt+0x233>
  800750:	eb 6f                	jmp    8007c1 <vprintfmt+0x2b6>
  800752:	89 cf                	mov    %ecx,%edi
  800754:	eb f6                	jmp    80074c <vprintfmt+0x241>
			num = getint(&ap, lflag);
  800756:	89 ca                	mov    %ecx,%edx
  800758:	8d 45 14             	lea    0x14(%ebp),%eax
  80075b:	e8 45 fd ff ff       	call   8004a5 <getint>
  800760:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800763:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800766:	85 d2                	test   %edx,%edx
  800768:	78 0b                	js     800775 <vprintfmt+0x26a>
			num = getint(&ap, lflag);
  80076a:	89 d1                	mov    %edx,%ecx
  80076c:	89 c2                	mov    %eax,%edx
			base = 10;
  80076e:	bf 0a 00 00 00       	mov    $0xa,%edi
  800773:	eb 32                	jmp    8007a7 <vprintfmt+0x29c>
				putch('-', putdat);
  800775:	83 ec 08             	sub    $0x8,%esp
  800778:	56                   	push   %esi
  800779:	6a 2d                	push   $0x2d
  80077b:	ff d3                	call   *%ebx
				num = -(long long) num;
  80077d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800780:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800783:	f7 da                	neg    %edx
  800785:	83 d1 00             	adc    $0x0,%ecx
  800788:	f7 d9                	neg    %ecx
  80078a:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80078d:	bf 0a 00 00 00       	mov    $0xa,%edi
  800792:	eb 13                	jmp    8007a7 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  800794:	89 ca                	mov    %ecx,%edx
  800796:	8d 45 14             	lea    0x14(%ebp),%eax
  800799:	e8 d3 fc ff ff       	call   800471 <getuint>
  80079e:	89 d1                	mov    %edx,%ecx
  8007a0:	89 c2                	mov    %eax,%edx
			base = 10;
  8007a2:	bf 0a 00 00 00       	mov    $0xa,%edi
			printnum(putch, putdat, num, base, width, padc);
  8007a7:	83 ec 0c             	sub    $0xc,%esp
  8007aa:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  8007ae:	50                   	push   %eax
  8007af:	ff 75 e0             	push   -0x20(%ebp)
  8007b2:	57                   	push   %edi
  8007b3:	51                   	push   %ecx
  8007b4:	52                   	push   %edx
  8007b5:	89 f2                	mov    %esi,%edx
  8007b7:	89 d8                	mov    %ebx,%eax
  8007b9:	e8 0a fc ff ff       	call   8003c8 <printnum>
			break;
  8007be:	83 c4 20             	add    $0x20,%esp
{
  8007c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007c4:	e9 60 fd ff ff       	jmp    800529 <vprintfmt+0x1e>
			num = getuint(&ap, lflag);
  8007c9:	89 ca                	mov    %ecx,%edx
  8007cb:	8d 45 14             	lea    0x14(%ebp),%eax
  8007ce:	e8 9e fc ff ff       	call   800471 <getuint>
  8007d3:	89 d1                	mov    %edx,%ecx
  8007d5:	89 c2                	mov    %eax,%edx
			base = 8;
  8007d7:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  8007dc:	eb c9                	jmp    8007a7 <vprintfmt+0x29c>
			putch('0', putdat);
  8007de:	83 ec 08             	sub    $0x8,%esp
  8007e1:	56                   	push   %esi
  8007e2:	6a 30                	push   $0x30
  8007e4:	ff d3                	call   *%ebx
			putch('x', putdat);
  8007e6:	83 c4 08             	add    $0x8,%esp
  8007e9:	56                   	push   %esi
  8007ea:	6a 78                	push   $0x78
  8007ec:	ff d3                	call   *%ebx
			num = (unsigned long long) (uintptr_t) va_arg(ap, void *);
  8007ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f1:	8d 50 04             	lea    0x4(%eax),%edx
  8007f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f7:	8b 10                	mov    (%eax),%edx
  8007f9:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8007fe:	83 c4 10             	add    $0x10,%esp
			base = 16;
  800801:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  800806:	eb 9f                	jmp    8007a7 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  800808:	89 ca                	mov    %ecx,%edx
  80080a:	8d 45 14             	lea    0x14(%ebp),%eax
  80080d:	e8 5f fc ff ff       	call   800471 <getuint>
  800812:	89 d1                	mov    %edx,%ecx
  800814:	89 c2                	mov    %eax,%edx
			base = 16;
  800816:	bf 10 00 00 00       	mov    $0x10,%edi
  80081b:	eb 8a                	jmp    8007a7 <vprintfmt+0x29c>
			putch(ch, putdat);
  80081d:	83 ec 08             	sub    $0x8,%esp
  800820:	56                   	push   %esi
  800821:	6a 25                	push   $0x25
  800823:	ff d3                	call   *%ebx
			break;
  800825:	83 c4 10             	add    $0x10,%esp
  800828:	eb 97                	jmp    8007c1 <vprintfmt+0x2b6>
			putch('%', putdat);
  80082a:	83 ec 08             	sub    $0x8,%esp
  80082d:	56                   	push   %esi
  80082e:	6a 25                	push   $0x25
  800830:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  800832:	83 c4 10             	add    $0x10,%esp
  800835:	89 f8                	mov    %edi,%eax
  800837:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80083b:	74 05                	je     800842 <vprintfmt+0x337>
  80083d:	83 e8 01             	sub    $0x1,%eax
  800840:	eb f5                	jmp    800837 <vprintfmt+0x32c>
  800842:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800845:	e9 77 ff ff ff       	jmp    8007c1 <vprintfmt+0x2b6>

0080084a <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80084a:	55                   	push   %ebp
  80084b:	89 e5                	mov    %esp,%ebp
  80084d:	83 ec 18             	sub    $0x18,%esp
  800850:	8b 45 08             	mov    0x8(%ebp),%eax
  800853:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = { buf, buf + n - 1, 0 };
  800856:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800859:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80085d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800860:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800867:	85 c0                	test   %eax,%eax
  800869:	74 26                	je     800891 <vsnprintf+0x47>
  80086b:	85 d2                	test   %edx,%edx
  80086d:	7e 22                	jle    800891 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *) sprintputch, &b, fmt, ap);
  80086f:	ff 75 14             	push   0x14(%ebp)
  800872:	ff 75 10             	push   0x10(%ebp)
  800875:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800878:	50                   	push   %eax
  800879:	68 d1 04 80 00       	push   $0x8004d1
  80087e:	e8 88 fc ff ff       	call   80050b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800883:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800886:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800889:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80088c:	83 c4 10             	add    $0x10,%esp
}
  80088f:	c9                   	leave  
  800890:	c3                   	ret    
		return -E_INVAL;
  800891:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800896:	eb f7                	jmp    80088f <vsnprintf+0x45>

00800898 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800898:	55                   	push   %ebp
  800899:	89 e5                	mov    %esp,%ebp
  80089b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80089e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008a1:	50                   	push   %eax
  8008a2:	ff 75 10             	push   0x10(%ebp)
  8008a5:	ff 75 0c             	push   0xc(%ebp)
  8008a8:	ff 75 08             	push   0x8(%ebp)
  8008ab:	e8 9a ff ff ff       	call   80084a <vsnprintf>
	va_end(ap);

	return rc;
}
  8008b0:	c9                   	leave  
  8008b1:	c3                   	ret    

008008b2 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008b2:	55                   	push   %ebp
  8008b3:	89 e5                	mov    %esp,%ebp
  8008b5:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8008bd:	eb 03                	jmp    8008c2 <strlen+0x10>
		n++;
  8008bf:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008c2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008c6:	75 f7                	jne    8008bf <strlen+0xd>
	return n;
}
  8008c8:	5d                   	pop    %ebp
  8008c9:	c3                   	ret    

008008ca <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008ca:	55                   	push   %ebp
  8008cb:	89 e5                	mov    %esp,%ebp
  8008cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008d0:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d8:	eb 03                	jmp    8008dd <strnlen+0x13>
		n++;
  8008da:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008dd:	39 d0                	cmp    %edx,%eax
  8008df:	74 08                	je     8008e9 <strnlen+0x1f>
  8008e1:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008e5:	75 f3                	jne    8008da <strnlen+0x10>
  8008e7:	89 c2                	mov    %eax,%edx
	return n;
}
  8008e9:	89 d0                	mov    %edx,%eax
  8008eb:	5d                   	pop    %ebp
  8008ec:	c3                   	ret    

008008ed <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008ed:	55                   	push   %ebp
  8008ee:	89 e5                	mov    %esp,%ebp
  8008f0:	53                   	push   %ebx
  8008f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8008fc:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800900:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800903:	83 c0 01             	add    $0x1,%eax
  800906:	84 d2                	test   %dl,%dl
  800908:	75 f2                	jne    8008fc <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80090a:	89 c8                	mov    %ecx,%eax
  80090c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80090f:	c9                   	leave  
  800910:	c3                   	ret    

00800911 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800911:	55                   	push   %ebp
  800912:	89 e5                	mov    %esp,%ebp
  800914:	53                   	push   %ebx
  800915:	83 ec 10             	sub    $0x10,%esp
  800918:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80091b:	53                   	push   %ebx
  80091c:	e8 91 ff ff ff       	call   8008b2 <strlen>
  800921:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800924:	ff 75 0c             	push   0xc(%ebp)
  800927:	01 d8                	add    %ebx,%eax
  800929:	50                   	push   %eax
  80092a:	e8 be ff ff ff       	call   8008ed <strcpy>
	return dst;
}
  80092f:	89 d8                	mov    %ebx,%eax
  800931:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800934:	c9                   	leave  
  800935:	c3                   	ret    

00800936 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size)
{
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	56                   	push   %esi
  80093a:	53                   	push   %ebx
  80093b:	8b 75 08             	mov    0x8(%ebp),%esi
  80093e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800941:	89 f3                	mov    %esi,%ebx
  800943:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800946:	89 f0                	mov    %esi,%eax
  800948:	eb 0f                	jmp    800959 <strncpy+0x23>
		*dst++ = *src;
  80094a:	83 c0 01             	add    $0x1,%eax
  80094d:	0f b6 0a             	movzbl (%edx),%ecx
  800950:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800953:	80 f9 01             	cmp    $0x1,%cl
  800956:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800959:	39 d8                	cmp    %ebx,%eax
  80095b:	75 ed                	jne    80094a <strncpy+0x14>
	}
	return ret;
}
  80095d:	89 f0                	mov    %esi,%eax
  80095f:	5b                   	pop    %ebx
  800960:	5e                   	pop    %esi
  800961:	5d                   	pop    %ebp
  800962:	c3                   	ret    

00800963 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800963:	55                   	push   %ebp
  800964:	89 e5                	mov    %esp,%ebp
  800966:	56                   	push   %esi
  800967:	53                   	push   %ebx
  800968:	8b 75 08             	mov    0x8(%ebp),%esi
  80096b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80096e:	8b 55 10             	mov    0x10(%ebp),%edx
  800971:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800973:	85 d2                	test   %edx,%edx
  800975:	74 21                	je     800998 <strlcpy+0x35>
  800977:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80097b:	89 f2                	mov    %esi,%edx
  80097d:	eb 09                	jmp    800988 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80097f:	83 c1 01             	add    $0x1,%ecx
  800982:	83 c2 01             	add    $0x1,%edx
  800985:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800988:	39 c2                	cmp    %eax,%edx
  80098a:	74 09                	je     800995 <strlcpy+0x32>
  80098c:	0f b6 19             	movzbl (%ecx),%ebx
  80098f:	84 db                	test   %bl,%bl
  800991:	75 ec                	jne    80097f <strlcpy+0x1c>
  800993:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800995:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800998:	29 f0                	sub    %esi,%eax
}
  80099a:	5b                   	pop    %ebx
  80099b:	5e                   	pop    %esi
  80099c:	5d                   	pop    %ebp
  80099d:	c3                   	ret    

0080099e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80099e:	55                   	push   %ebp
  80099f:	89 e5                	mov    %esp,%ebp
  8009a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009a7:	eb 06                	jmp    8009af <strcmp+0x11>
		p++, q++;
  8009a9:	83 c1 01             	add    $0x1,%ecx
  8009ac:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8009af:	0f b6 01             	movzbl (%ecx),%eax
  8009b2:	84 c0                	test   %al,%al
  8009b4:	74 04                	je     8009ba <strcmp+0x1c>
  8009b6:	3a 02                	cmp    (%edx),%al
  8009b8:	74 ef                	je     8009a9 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009ba:	0f b6 c0             	movzbl %al,%eax
  8009bd:	0f b6 12             	movzbl (%edx),%edx
  8009c0:	29 d0                	sub    %edx,%eax
}
  8009c2:	5d                   	pop    %ebp
  8009c3:	c3                   	ret    

008009c4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009c4:	55                   	push   %ebp
  8009c5:	89 e5                	mov    %esp,%ebp
  8009c7:	53                   	push   %ebx
  8009c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ce:	89 c3                	mov    %eax,%ebx
  8009d0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009d3:	eb 06                	jmp    8009db <strncmp+0x17>
		n--, p++, q++;
  8009d5:	83 c0 01             	add    $0x1,%eax
  8009d8:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009db:	39 d8                	cmp    %ebx,%eax
  8009dd:	74 18                	je     8009f7 <strncmp+0x33>
  8009df:	0f b6 08             	movzbl (%eax),%ecx
  8009e2:	84 c9                	test   %cl,%cl
  8009e4:	74 04                	je     8009ea <strncmp+0x26>
  8009e6:	3a 0a                	cmp    (%edx),%cl
  8009e8:	74 eb                	je     8009d5 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009ea:	0f b6 00             	movzbl (%eax),%eax
  8009ed:	0f b6 12             	movzbl (%edx),%edx
  8009f0:	29 d0                	sub    %edx,%eax
}
  8009f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009f5:	c9                   	leave  
  8009f6:	c3                   	ret    
		return 0;
  8009f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8009fc:	eb f4                	jmp    8009f2 <strncmp+0x2e>

008009fe <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009fe:	55                   	push   %ebp
  8009ff:	89 e5                	mov    %esp,%ebp
  800a01:	8b 45 08             	mov    0x8(%ebp),%eax
  800a04:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a08:	eb 03                	jmp    800a0d <strchr+0xf>
  800a0a:	83 c0 01             	add    $0x1,%eax
  800a0d:	0f b6 10             	movzbl (%eax),%edx
  800a10:	84 d2                	test   %dl,%dl
  800a12:	74 06                	je     800a1a <strchr+0x1c>
		if (*s == c)
  800a14:	38 ca                	cmp    %cl,%dl
  800a16:	75 f2                	jne    800a0a <strchr+0xc>
  800a18:	eb 05                	jmp    800a1f <strchr+0x21>
			return (char *) s;
	return 0;
  800a1a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a1f:	5d                   	pop    %ebp
  800a20:	c3                   	ret    

00800a21 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a21:	55                   	push   %ebp
  800a22:	89 e5                	mov    %esp,%ebp
  800a24:	8b 45 08             	mov    0x8(%ebp),%eax
  800a27:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a2b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a2e:	38 ca                	cmp    %cl,%dl
  800a30:	74 09                	je     800a3b <strfind+0x1a>
  800a32:	84 d2                	test   %dl,%dl
  800a34:	74 05                	je     800a3b <strfind+0x1a>
	for (; *s; s++)
  800a36:	83 c0 01             	add    $0x1,%eax
  800a39:	eb f0                	jmp    800a2b <strfind+0xa>
			break;
	return (char *) s;
}
  800a3b:	5d                   	pop    %ebp
  800a3c:	c3                   	ret    

00800a3d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a3d:	55                   	push   %ebp
  800a3e:	89 e5                	mov    %esp,%ebp
  800a40:	57                   	push   %edi
  800a41:	56                   	push   %esi
  800a42:	53                   	push   %ebx
  800a43:	8b 55 08             	mov    0x8(%ebp),%edx
  800a46:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  800a49:	85 c9                	test   %ecx,%ecx
  800a4b:	74 33                	je     800a80 <memset+0x43>
		return v;
	if ((int) v % 4 == 0 && n % 4 == 0) {
  800a4d:	89 d0                	mov    %edx,%eax
  800a4f:	09 c8                	or     %ecx,%eax
  800a51:	a8 03                	test   $0x3,%al
  800a53:	75 23                	jne    800a78 <memset+0x3b>
		c &= 0xFF;
  800a55:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  800a59:	89 d8                	mov    %ebx,%eax
  800a5b:	c1 e0 08             	shl    $0x8,%eax
  800a5e:	89 df                	mov    %ebx,%edi
  800a60:	c1 e7 18             	shl    $0x18,%edi
  800a63:	89 de                	mov    %ebx,%esi
  800a65:	c1 e6 10             	shl    $0x10,%esi
  800a68:	09 f7                	or     %esi,%edi
  800a6a:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
		             : "=D"(p), "=c"(n)
		             : "D"(p), "a"(c), "c"(n / 4)
  800a6c:	c1 e9 02             	shr    $0x2,%ecx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  800a6f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800a71:	89 d7                	mov    %edx,%edi
  800a73:	fc                   	cld    
  800a74:	f3 ab                	rep stos %eax,%es:(%edi)
  800a76:	eb 08                	jmp    800a80 <memset+0x43>
		             : "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a78:	89 d7                	mov    %edx,%edi
  800a7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a7d:	fc                   	cld    
  800a7e:	f3 aa                	rep stos %al,%es:(%edi)
		             : "=D"(p), "=c"(n)
		             : "0"(p), "a"(c), "1"(n)
		             : "cc", "memory");
	return v;
}
  800a80:	89 d0                	mov    %edx,%eax
  800a82:	5b                   	pop    %ebx
  800a83:	5e                   	pop    %esi
  800a84:	5f                   	pop    %edi
  800a85:	5d                   	pop    %ebp
  800a86:	c3                   	ret    

00800a87 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a87:	55                   	push   %ebp
  800a88:	89 e5                	mov    %esp,%ebp
  800a8a:	57                   	push   %edi
  800a8b:	56                   	push   %esi
  800a8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a92:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a95:	39 c6                	cmp    %eax,%esi
  800a97:	73 32                	jae    800acb <memmove+0x44>
  800a99:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a9c:	39 c2                	cmp    %eax,%edx
  800a9e:	76 2b                	jbe    800acb <memmove+0x44>
		s += n;
		d += n;
  800aa0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  800aa3:	89 d6                	mov    %edx,%esi
  800aa5:	09 fe                	or     %edi,%esi
  800aa7:	09 ce                	or     %ecx,%esi
  800aa9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aaf:	75 0e                	jne    800abf <memmove+0x38>
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  800ab1:	83 ef 04             	sub    $0x4,%edi
			             "S"(s - 4),
  800ab4:	8d 72 fc             	lea    -0x4(%edx),%esi
			             "c"(n / 4)
  800ab7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  800aba:	fd                   	std    
  800abb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800abd:	eb 09                	jmp    800ac8 <memmove+0x41>
			             : "cc", "memory");
		else
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  800abf:	83 ef 01             	sub    $0x1,%edi
			             "S"(s - 1),
  800ac2:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  800ac5:	fd                   	std    
  800ac6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             "c"(n)
			             : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ac8:	fc                   	cld    
  800ac9:	eb 1a                	jmp    800ae5 <memmove+0x5e>
	} else {
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  800acb:	89 f2                	mov    %esi,%edx
  800acd:	09 c2                	or     %eax,%edx
  800acf:	09 ca                	or     %ecx,%edx
  800ad1:	f6 c2 03             	test   $0x3,%dl
  800ad4:	75 0a                	jne    800ae0 <memmove+0x59>
			asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800ad6:	c1 e9 02             	shr    $0x2,%ecx
  800ad9:	89 c7                	mov    %eax,%edi
  800adb:	fc                   	cld    
  800adc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ade:	eb 05                	jmp    800ae5 <memmove+0x5e>
			             : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800ae0:	89 c7                	mov    %eax,%edi
  800ae2:	fc                   	cld    
  800ae3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             : "cc", "memory");
	}
	return dst;
}
  800ae5:	5e                   	pop    %esi
  800ae6:	5f                   	pop    %edi
  800ae7:	5d                   	pop    %ebp
  800ae8:	c3                   	ret    

00800ae9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ae9:	55                   	push   %ebp
  800aea:	89 e5                	mov    %esp,%ebp
  800aec:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800aef:	ff 75 10             	push   0x10(%ebp)
  800af2:	ff 75 0c             	push   0xc(%ebp)
  800af5:	ff 75 08             	push   0x8(%ebp)
  800af8:	e8 8a ff ff ff       	call   800a87 <memmove>
}
  800afd:	c9                   	leave  
  800afe:	c3                   	ret    

00800aff <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aff:	55                   	push   %ebp
  800b00:	89 e5                	mov    %esp,%ebp
  800b02:	56                   	push   %esi
  800b03:	53                   	push   %ebx
  800b04:	8b 45 08             	mov    0x8(%ebp),%eax
  800b07:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b0a:	89 c6                	mov    %eax,%esi
  800b0c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b0f:	eb 06                	jmp    800b17 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b11:	83 c0 01             	add    $0x1,%eax
  800b14:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800b17:	39 f0                	cmp    %esi,%eax
  800b19:	74 14                	je     800b2f <memcmp+0x30>
		if (*s1 != *s2)
  800b1b:	0f b6 08             	movzbl (%eax),%ecx
  800b1e:	0f b6 1a             	movzbl (%edx),%ebx
  800b21:	38 d9                	cmp    %bl,%cl
  800b23:	74 ec                	je     800b11 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800b25:	0f b6 c1             	movzbl %cl,%eax
  800b28:	0f b6 db             	movzbl %bl,%ebx
  800b2b:	29 d8                	sub    %ebx,%eax
  800b2d:	eb 05                	jmp    800b34 <memcmp+0x35>
	}

	return 0;
  800b2f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b34:	5b                   	pop    %ebx
  800b35:	5e                   	pop    %esi
  800b36:	5d                   	pop    %ebp
  800b37:	c3                   	ret    

00800b38 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
  800b3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b41:	89 c2                	mov    %eax,%edx
  800b43:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b46:	eb 03                	jmp    800b4b <memfind+0x13>
  800b48:	83 c0 01             	add    $0x1,%eax
  800b4b:	39 d0                	cmp    %edx,%eax
  800b4d:	73 04                	jae    800b53 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b4f:	38 08                	cmp    %cl,(%eax)
  800b51:	75 f5                	jne    800b48 <memfind+0x10>
			break;
	return (void *) s;
}
  800b53:	5d                   	pop    %ebp
  800b54:	c3                   	ret    

00800b55 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b55:	55                   	push   %ebp
  800b56:	89 e5                	mov    %esp,%ebp
  800b58:	57                   	push   %edi
  800b59:	56                   	push   %esi
  800b5a:	53                   	push   %ebx
  800b5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b5e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b61:	eb 03                	jmp    800b66 <strtol+0x11>
		s++;
  800b63:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b66:	0f b6 02             	movzbl (%edx),%eax
  800b69:	3c 20                	cmp    $0x20,%al
  800b6b:	74 f6                	je     800b63 <strtol+0xe>
  800b6d:	3c 09                	cmp    $0x9,%al
  800b6f:	74 f2                	je     800b63 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b71:	3c 2b                	cmp    $0x2b,%al
  800b73:	74 2a                	je     800b9f <strtol+0x4a>
	int neg = 0;
  800b75:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b7a:	3c 2d                	cmp    $0x2d,%al
  800b7c:	74 2b                	je     800ba9 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b7e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b84:	75 0f                	jne    800b95 <strtol+0x40>
  800b86:	80 3a 30             	cmpb   $0x30,(%edx)
  800b89:	74 28                	je     800bb3 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b8b:	85 db                	test   %ebx,%ebx
  800b8d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b92:	0f 44 d8             	cmove  %eax,%ebx
  800b95:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b9a:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b9d:	eb 46                	jmp    800be5 <strtol+0x90>
		s++;
  800b9f:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800ba2:	bf 00 00 00 00       	mov    $0x0,%edi
  800ba7:	eb d5                	jmp    800b7e <strtol+0x29>
		s++, neg = 1;
  800ba9:	83 c2 01             	add    $0x1,%edx
  800bac:	bf 01 00 00 00       	mov    $0x1,%edi
  800bb1:	eb cb                	jmp    800b7e <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bb3:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bb7:	74 0e                	je     800bc7 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800bb9:	85 db                	test   %ebx,%ebx
  800bbb:	75 d8                	jne    800b95 <strtol+0x40>
		s++, base = 8;
  800bbd:	83 c2 01             	add    $0x1,%edx
  800bc0:	bb 08 00 00 00       	mov    $0x8,%ebx
  800bc5:	eb ce                	jmp    800b95 <strtol+0x40>
		s += 2, base = 16;
  800bc7:	83 c2 02             	add    $0x2,%edx
  800bca:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bcf:	eb c4                	jmp    800b95 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800bd1:	0f be c0             	movsbl %al,%eax
  800bd4:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bd7:	3b 45 10             	cmp    0x10(%ebp),%eax
  800bda:	7d 3a                	jge    800c16 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800bdc:	83 c2 01             	add    $0x1,%edx
  800bdf:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800be3:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800be5:	0f b6 02             	movzbl (%edx),%eax
  800be8:	8d 70 d0             	lea    -0x30(%eax),%esi
  800beb:	89 f3                	mov    %esi,%ebx
  800bed:	80 fb 09             	cmp    $0x9,%bl
  800bf0:	76 df                	jbe    800bd1 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800bf2:	8d 70 9f             	lea    -0x61(%eax),%esi
  800bf5:	89 f3                	mov    %esi,%ebx
  800bf7:	80 fb 19             	cmp    $0x19,%bl
  800bfa:	77 08                	ja     800c04 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800bfc:	0f be c0             	movsbl %al,%eax
  800bff:	83 e8 57             	sub    $0x57,%eax
  800c02:	eb d3                	jmp    800bd7 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800c04:	8d 70 bf             	lea    -0x41(%eax),%esi
  800c07:	89 f3                	mov    %esi,%ebx
  800c09:	80 fb 19             	cmp    $0x19,%bl
  800c0c:	77 08                	ja     800c16 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800c0e:	0f be c0             	movsbl %al,%eax
  800c11:	83 e8 37             	sub    $0x37,%eax
  800c14:	eb c1                	jmp    800bd7 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c16:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c1a:	74 05                	je     800c21 <strtol+0xcc>
		*endptr = (char *) s;
  800c1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c1f:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800c21:	89 c8                	mov    %ecx,%eax
  800c23:	f7 d8                	neg    %eax
  800c25:	85 ff                	test   %edi,%edi
  800c27:	0f 45 c8             	cmovne %eax,%ecx
}
  800c2a:	89 c8                	mov    %ecx,%eax
  800c2c:	5b                   	pop    %ebx
  800c2d:	5e                   	pop    %esi
  800c2e:	5f                   	pop    %edi
  800c2f:	5d                   	pop    %ebp
  800c30:	c3                   	ret    
  800c31:	66 90                	xchg   %ax,%ax
  800c33:	66 90                	xchg   %ax,%ax
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
