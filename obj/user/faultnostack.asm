
obj/user/faultnostack:     formato del fichero elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_env_set_pgfault_upcall(0, (void *) _pgfault_upcall);
  800039:	68 f3 02 80 00       	push   $0x8002f3
  80003e:	6a 00                	push   $0x0
  800040:	e8 fe 01 00 00       	call   800243 <sys_env_set_pgfault_upcall>
	*(int *) 0 = 0;
  800045:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80004c:	00 00 00 
}
  80004f:	83 c4 10             	add    $0x10,%esp
  800052:	c9                   	leave  
  800053:	c3                   	ret    

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	56                   	push   %esi
  800058:	53                   	push   %ebx
  800059:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	envid_t id = sys_getenvid();
  80005f:	e8 04 01 00 00       	call   800168 <sys_getenvid>
	if (id >= 0)
  800064:	85 c0                	test   %eax,%eax
  800066:	78 15                	js     80007d <libmain+0x29>
		thisenv = &envs[ENVX(id)];
  800068:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006d:	69 c0 88 00 00 00    	imul   $0x88,%eax,%eax
  800073:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800078:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007d:	85 db                	test   %ebx,%ebx
  80007f:	7e 07                	jle    800088 <libmain+0x34>
		binaryname = argv[0];
  800081:	8b 06                	mov    (%esi),%eax
  800083:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800088:	83 ec 08             	sub    $0x8,%esp
  80008b:	56                   	push   %esi
  80008c:	53                   	push   %ebx
  80008d:	e8 a1 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800092:	e8 0a 00 00 00       	call   8000a1 <exit>
}
  800097:	83 c4 10             	add    $0x10,%esp
  80009a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80009d:	5b                   	pop    %ebx
  80009e:	5e                   	pop    %esi
  80009f:	5d                   	pop    %ebp
  8000a0:	c3                   	ret    

008000a1 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000a7:	6a 00                	push   $0x0
  8000a9:	e8 98 00 00 00       	call   800146 <sys_env_destroy>
}
  8000ae:	83 c4 10             	add    $0x10,%esp
  8000b1:	c9                   	leave  
  8000b2:	c3                   	ret    

008000b3 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000b3:	55                   	push   %ebp
  8000b4:	89 e5                	mov    %esp,%ebp
  8000b6:	57                   	push   %edi
  8000b7:	56                   	push   %esi
  8000b8:	53                   	push   %ebx
  8000b9:	83 ec 1c             	sub    $0x1c,%esp
  8000bc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8000bf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8000c2:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile(
  8000c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000ca:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000cd:	8b 75 14             	mov    0x14(%ebp),%esi
  8000d0:	cd 30                	int    $0x30
	        "int %1\n"
	        : "=a"(ret)
	        : "i"(T_SYSCALL), "a"(num), "d"(a1), "c"(a2), "b"(a3), "D"(a4), "S"(a5)
	        : "cc", "memory");

	if (check && ret > 0)
  8000d2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000d6:	74 04                	je     8000dc <syscall+0x29>
  8000d8:	85 c0                	test   %eax,%eax
  8000da:	7f 08                	jg     8000e4 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  8000dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000df:	5b                   	pop    %ebx
  8000e0:	5e                   	pop    %esi
  8000e1:	5f                   	pop    %edi
  8000e2:	5d                   	pop    %ebp
  8000e3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8000e4:	83 ec 0c             	sub    $0xc,%esp
  8000e7:	50                   	push   %eax
  8000e8:	ff 75 e0             	push   -0x20(%ebp)
  8000eb:	68 0a 0f 80 00       	push   $0x800f0a
  8000f0:	6a 1e                	push   $0x1e
  8000f2:	68 27 0f 80 00       	push   $0x800f27
  8000f7:	e8 1c 02 00 00       	call   800318 <_panic>

008000fc <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  8000fc:	55                   	push   %ebp
  8000fd:	89 e5                	mov    %esp,%ebp
  8000ff:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t) s, len, 0, 0, 0);
  800102:	6a 00                	push   $0x0
  800104:	6a 00                	push   $0x0
  800106:	6a 00                	push   $0x0
  800108:	ff 75 0c             	push   0xc(%ebp)
  80010b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80010e:	ba 00 00 00 00       	mov    $0x0,%edx
  800113:	b8 00 00 00 00       	mov    $0x0,%eax
  800118:	e8 96 ff ff ff       	call   8000b3 <syscall>
}
  80011d:	83 c4 10             	add    $0x10,%esp
  800120:	c9                   	leave  
  800121:	c3                   	ret    

00800122 <sys_cgetc>:

int
sys_cgetc(void)
{
  800122:	55                   	push   %ebp
  800123:	89 e5                	mov    %esp,%ebp
  800125:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800128:	6a 00                	push   $0x0
  80012a:	6a 00                	push   $0x0
  80012c:	6a 00                	push   $0x0
  80012e:	6a 00                	push   $0x0
  800130:	b9 00 00 00 00       	mov    $0x0,%ecx
  800135:	ba 00 00 00 00       	mov    $0x0,%edx
  80013a:	b8 01 00 00 00       	mov    $0x1,%eax
  80013f:	e8 6f ff ff ff       	call   8000b3 <syscall>
}
  800144:	c9                   	leave  
  800145:	c3                   	ret    

00800146 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800146:	55                   	push   %ebp
  800147:	89 e5                	mov    %esp,%ebp
  800149:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80014c:	6a 00                	push   $0x0
  80014e:	6a 00                	push   $0x0
  800150:	6a 00                	push   $0x0
  800152:	6a 00                	push   $0x0
  800154:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800157:	ba 01 00 00 00       	mov    $0x1,%edx
  80015c:	b8 03 00 00 00       	mov    $0x3,%eax
  800161:	e8 4d ff ff ff       	call   8000b3 <syscall>
}
  800166:	c9                   	leave  
  800167:	c3                   	ret    

00800168 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  80016e:	6a 00                	push   $0x0
  800170:	6a 00                	push   $0x0
  800172:	6a 00                	push   $0x0
  800174:	6a 00                	push   $0x0
  800176:	b9 00 00 00 00       	mov    $0x0,%ecx
  80017b:	ba 00 00 00 00       	mov    $0x0,%edx
  800180:	b8 02 00 00 00       	mov    $0x2,%eax
  800185:	e8 29 ff ff ff       	call   8000b3 <syscall>
}
  80018a:	c9                   	leave  
  80018b:	c3                   	ret    

0080018c <sys_yield>:

void
sys_yield(void)
{
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800192:	6a 00                	push   $0x0
  800194:	6a 00                	push   $0x0
  800196:	6a 00                	push   $0x0
  800198:	6a 00                	push   $0x0
  80019a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80019f:	ba 00 00 00 00       	mov    $0x0,%edx
  8001a4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8001a9:	e8 05 ff ff ff       	call   8000b3 <syscall>
}
  8001ae:	83 c4 10             	add    $0x10,%esp
  8001b1:	c9                   	leave  
  8001b2:	c3                   	ret    

008001b3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001b3:	55                   	push   %ebp
  8001b4:	89 e5                	mov    %esp,%ebp
  8001b6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8001b9:	6a 00                	push   $0x0
  8001bb:	6a 00                	push   $0x0
  8001bd:	ff 75 10             	push   0x10(%ebp)
  8001c0:	ff 75 0c             	push   0xc(%ebp)
  8001c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001c6:	ba 01 00 00 00       	mov    $0x1,%edx
  8001cb:	b8 04 00 00 00       	mov    $0x4,%eax
  8001d0:	e8 de fe ff ff       	call   8000b3 <syscall>
}
  8001d5:	c9                   	leave  
  8001d6:	c3                   	ret    

008001d7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001d7:	55                   	push   %ebp
  8001d8:	89 e5                	mov    %esp,%ebp
  8001da:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map,
  8001dd:	ff 75 18             	push   0x18(%ebp)
  8001e0:	ff 75 14             	push   0x14(%ebp)
  8001e3:	ff 75 10             	push   0x10(%ebp)
  8001e6:	ff 75 0c             	push   0xc(%ebp)
  8001e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ec:	ba 01 00 00 00       	mov    $0x1,%edx
  8001f1:	b8 05 00 00 00       	mov    $0x5,%eax
  8001f6:	e8 b8 fe ff ff       	call   8000b3 <syscall>
	               srcenv,
	               (uint32_t) srcva,
	               dstenv,
	               (uint32_t) dstva,
	               perm);
}
  8001fb:	c9                   	leave  
  8001fc:	c3                   	ret    

008001fd <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001fd:	55                   	push   %ebp
  8001fe:	89 e5                	mov    %esp,%ebp
  800200:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800203:	6a 00                	push   $0x0
  800205:	6a 00                	push   $0x0
  800207:	6a 00                	push   $0x0
  800209:	ff 75 0c             	push   0xc(%ebp)
  80020c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80020f:	ba 01 00 00 00       	mov    $0x1,%edx
  800214:	b8 06 00 00 00       	mov    $0x6,%eax
  800219:	e8 95 fe ff ff       	call   8000b3 <syscall>
}
  80021e:	c9                   	leave  
  80021f:	c3                   	ret    

00800220 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800220:	55                   	push   %ebp
  800221:	89 e5                	mov    %esp,%ebp
  800223:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800226:	6a 00                	push   $0x0
  800228:	6a 00                	push   $0x0
  80022a:	6a 00                	push   $0x0
  80022c:	ff 75 0c             	push   0xc(%ebp)
  80022f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800232:	ba 01 00 00 00       	mov    $0x1,%edx
  800237:	b8 08 00 00 00       	mov    $0x8,%eax
  80023c:	e8 72 fe ff ff       	call   8000b3 <syscall>
}
  800241:	c9                   	leave  
  800242:	c3                   	ret    

00800243 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800243:	55                   	push   %ebp
  800244:	89 e5                	mov    %esp,%ebp
  800246:	83 ec 08             	sub    $0x8,%esp
	return syscall(
  800249:	6a 00                	push   $0x0
  80024b:	6a 00                	push   $0x0
  80024d:	6a 00                	push   $0x0
  80024f:	ff 75 0c             	push   0xc(%ebp)
  800252:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800255:	ba 01 00 00 00       	mov    $0x1,%edx
  80025a:	b8 09 00 00 00       	mov    $0x9,%eax
  80025f:	e8 4f fe ff ff       	call   8000b3 <syscall>
	        SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800264:	c9                   	leave  
  800265:	c3                   	ret    

00800266 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800266:	55                   	push   %ebp
  800267:	89 e5                	mov    %esp,%ebp
  800269:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  80026c:	6a 00                	push   $0x0
  80026e:	ff 75 14             	push   0x14(%ebp)
  800271:	ff 75 10             	push   0x10(%ebp)
  800274:	ff 75 0c             	push   0xc(%ebp)
  800277:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80027a:	ba 00 00 00 00       	mov    $0x0,%edx
  80027f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800284:	e8 2a fe ff ff       	call   8000b3 <syscall>
}
  800289:	c9                   	leave  
  80028a:	c3                   	ret    

0080028b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80028b:	55                   	push   %ebp
  80028c:	89 e5                	mov    %esp,%ebp
  80028e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t) dstva, 0, 0, 0, 0);
  800291:	6a 00                	push   $0x0
  800293:	6a 00                	push   $0x0
  800295:	6a 00                	push   $0x0
  800297:	6a 00                	push   $0x0
  800299:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80029c:	ba 01 00 00 00       	mov    $0x1,%edx
  8002a1:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002a6:	e8 08 fe ff ff       	call   8000b3 <syscall>
}
  8002ab:	c9                   	leave  
  8002ac:	c3                   	ret    

008002ad <sys_get_priority>:

// Get priority of the current process
int
sys_get_priority(void)
{
  8002ad:	55                   	push   %ebp
  8002ae:	89 e5                	mov    %esp,%ebp
  8002b0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_get_priority, 0, 0, 0, 0, 0, 0);
  8002b3:	6a 00                	push   $0x0
  8002b5:	6a 00                	push   $0x0
  8002b7:	6a 00                	push   $0x0
  8002b9:	6a 00                	push   $0x0
  8002bb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c5:	b8 0d 00 00 00       	mov    $0xd,%eax
  8002ca:	e8 e4 fd ff ff       	call   8000b3 <syscall>
}
  8002cf:	c9                   	leave  
  8002d0:	c3                   	ret    

008002d1 <sys_set_priority>:

// Get priority of the current process
int
sys_set_priority(unsigned int priority)
{
  8002d1:	55                   	push   %ebp
  8002d2:	89 e5                	mov    %esp,%ebp
  8002d4:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, (uint32_t) priority, 0, 0, 0, 0);
  8002d7:	6a 00                	push   $0x0
  8002d9:	6a 00                	push   $0x0
  8002db:	6a 00                	push   $0x0
  8002dd:	6a 00                	push   $0x0
  8002df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e7:	b8 0e 00 00 00       	mov    $0xe,%eax
  8002ec:	e8 c2 fd ff ff       	call   8000b3 <syscall>
}
  8002f1:	c9                   	leave  
  8002f2:	c3                   	ret    

008002f3 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8002f3:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8002f4:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  8002f9:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8002fb:	83 c4 04             	add    $0x4,%esp
	// Throughout the remaining code, think carefully about what
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	movl 40(%esp), %eax	// trap-time %epi -> %eax 
  8002fe:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %ebx	// trap-time %esp -> %ebx
  800302:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4, %ebx
  800306:	83 eb 04             	sub    $0x4,%ebx
	movl %eax, 0(%ebx)	// push %eip in trap-time stack
  800309:	89 03                	mov    %eax,(%ebx)

	movl %ebx, 48(%esp)
  80030b:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	popl %eax
  80030f:	58                   	pop    %eax
	popl %eax
  800310:	58                   	pop    %eax
	popal
  800311:	61                   	popa   
	

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	addl $4, %esp
  800312:	83 c4 04             	add    $0x4,%esp
	popfl
  800315:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	popl %esp
  800316:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	ret
  800317:	c3                   	ret    

00800318 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800318:	55                   	push   %ebp
  800319:	89 e5                	mov    %esp,%ebp
  80031b:	56                   	push   %esi
  80031c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80031d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800320:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800326:	e8 3d fe ff ff       	call   800168 <sys_getenvid>
  80032b:	83 ec 0c             	sub    $0xc,%esp
  80032e:	ff 75 0c             	push   0xc(%ebp)
  800331:	ff 75 08             	push   0x8(%ebp)
  800334:	56                   	push   %esi
  800335:	50                   	push   %eax
  800336:	68 38 0f 80 00       	push   $0x800f38
  80033b:	e8 b3 00 00 00       	call   8003f3 <cprintf>
	        sys_getenvid(),
	        binaryname,
	        file,
	        line);
	vcprintf(fmt, ap);
  800340:	83 c4 18             	add    $0x18,%esp
  800343:	53                   	push   %ebx
  800344:	ff 75 10             	push   0x10(%ebp)
  800347:	e8 56 00 00 00       	call   8003a2 <vcprintf>
	cprintf("\n");
  80034c:	c7 04 24 5b 0f 80 00 	movl   $0x800f5b,(%esp)
  800353:	e8 9b 00 00 00       	call   8003f3 <cprintf>
  800358:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80035b:	cc                   	int3   
  80035c:	eb fd                	jmp    80035b <_panic+0x43>

0080035e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80035e:	55                   	push   %ebp
  80035f:	89 e5                	mov    %esp,%ebp
  800361:	53                   	push   %ebx
  800362:	83 ec 04             	sub    $0x4,%esp
  800365:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800368:	8b 13                	mov    (%ebx),%edx
  80036a:	8d 42 01             	lea    0x1(%edx),%eax
  80036d:	89 03                	mov    %eax,(%ebx)
  80036f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800372:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256 - 1) {
  800376:	3d ff 00 00 00       	cmp    $0xff,%eax
  80037b:	74 09                	je     800386 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80037d:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800381:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800384:	c9                   	leave  
  800385:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800386:	83 ec 08             	sub    $0x8,%esp
  800389:	68 ff 00 00 00       	push   $0xff
  80038e:	8d 43 08             	lea    0x8(%ebx),%eax
  800391:	50                   	push   %eax
  800392:	e8 65 fd ff ff       	call   8000fc <sys_cputs>
		b->idx = 0;
  800397:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80039d:	83 c4 10             	add    $0x10,%esp
  8003a0:	eb db                	jmp    80037d <putch+0x1f>

008003a2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003a2:	55                   	push   %ebp
  8003a3:	89 e5                	mov    %esp,%ebp
  8003a5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003ab:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003b2:	00 00 00 
	b.cnt = 0;
  8003b5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003bc:	00 00 00 
	vprintfmt((void *) putch, &b, fmt, ap);
  8003bf:	ff 75 0c             	push   0xc(%ebp)
  8003c2:	ff 75 08             	push   0x8(%ebp)
  8003c5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003cb:	50                   	push   %eax
  8003cc:	68 5e 03 80 00       	push   $0x80035e
  8003d1:	e8 74 01 00 00       	call   80054a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003d6:	83 c4 08             	add    $0x8,%esp
  8003d9:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8003df:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003e5:	50                   	push   %eax
  8003e6:	e8 11 fd ff ff       	call   8000fc <sys_cputs>

	return b.cnt;
}
  8003eb:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003f1:	c9                   	leave  
  8003f2:	c3                   	ret    

008003f3 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003f3:	55                   	push   %ebp
  8003f4:	89 e5                	mov    %esp,%ebp
  8003f6:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003f9:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003fc:	50                   	push   %eax
  8003fd:	ff 75 08             	push   0x8(%ebp)
  800400:	e8 9d ff ff ff       	call   8003a2 <vcprintf>
	va_end(ap);

	return cnt;
}
  800405:	c9                   	leave  
  800406:	c3                   	ret    

00800407 <printnum>:
         void *putdat,
         unsigned long long num,
         unsigned base,
         int width,
         int padc)
{
  800407:	55                   	push   %ebp
  800408:	89 e5                	mov    %esp,%ebp
  80040a:	57                   	push   %edi
  80040b:	56                   	push   %esi
  80040c:	53                   	push   %ebx
  80040d:	83 ec 1c             	sub    $0x1c,%esp
  800410:	89 c7                	mov    %eax,%edi
  800412:	89 d6                	mov    %edx,%esi
  800414:	8b 45 08             	mov    0x8(%ebp),%eax
  800417:	8b 55 0c             	mov    0xc(%ebp),%edx
  80041a:	89 d1                	mov    %edx,%ecx
  80041c:	89 c2                	mov    %eax,%edx
  80041e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800421:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800424:	8b 45 10             	mov    0x10(%ebp),%eax
  800427:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80042a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80042d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800434:	39 c2                	cmp    %eax,%edx
  800436:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800439:	72 3e                	jb     800479 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80043b:	83 ec 0c             	sub    $0xc,%esp
  80043e:	ff 75 18             	push   0x18(%ebp)
  800441:	83 eb 01             	sub    $0x1,%ebx
  800444:	53                   	push   %ebx
  800445:	50                   	push   %eax
  800446:	83 ec 08             	sub    $0x8,%esp
  800449:	ff 75 e4             	push   -0x1c(%ebp)
  80044c:	ff 75 e0             	push   -0x20(%ebp)
  80044f:	ff 75 dc             	push   -0x24(%ebp)
  800452:	ff 75 d8             	push   -0x28(%ebp)
  800455:	e8 66 08 00 00       	call   800cc0 <__udivdi3>
  80045a:	83 c4 18             	add    $0x18,%esp
  80045d:	52                   	push   %edx
  80045e:	50                   	push   %eax
  80045f:	89 f2                	mov    %esi,%edx
  800461:	89 f8                	mov    %edi,%eax
  800463:	e8 9f ff ff ff       	call   800407 <printnum>
  800468:	83 c4 20             	add    $0x20,%esp
  80046b:	eb 13                	jmp    800480 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80046d:	83 ec 08             	sub    $0x8,%esp
  800470:	56                   	push   %esi
  800471:	ff 75 18             	push   0x18(%ebp)
  800474:	ff d7                	call   *%edi
  800476:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800479:	83 eb 01             	sub    $0x1,%ebx
  80047c:	85 db                	test   %ebx,%ebx
  80047e:	7f ed                	jg     80046d <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800480:	83 ec 08             	sub    $0x8,%esp
  800483:	56                   	push   %esi
  800484:	83 ec 04             	sub    $0x4,%esp
  800487:	ff 75 e4             	push   -0x1c(%ebp)
  80048a:	ff 75 e0             	push   -0x20(%ebp)
  80048d:	ff 75 dc             	push   -0x24(%ebp)
  800490:	ff 75 d8             	push   -0x28(%ebp)
  800493:	e8 48 09 00 00       	call   800de0 <__umoddi3>
  800498:	83 c4 14             	add    $0x14,%esp
  80049b:	0f be 80 5d 0f 80 00 	movsbl 0x800f5d(%eax),%eax
  8004a2:	50                   	push   %eax
  8004a3:	ff d7                	call   *%edi
}
  8004a5:	83 c4 10             	add    $0x10,%esp
  8004a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004ab:	5b                   	pop    %ebx
  8004ac:	5e                   	pop    %esi
  8004ad:	5f                   	pop    %edi
  8004ae:	5d                   	pop    %ebp
  8004af:	c3                   	ret    

008004b0 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004b0:	83 fa 01             	cmp    $0x1,%edx
  8004b3:	7f 13                	jg     8004c8 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8004b5:	85 d2                	test   %edx,%edx
  8004b7:	74 1c                	je     8004d5 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  8004b9:	8b 10                	mov    (%eax),%edx
  8004bb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004be:	89 08                	mov    %ecx,(%eax)
  8004c0:	8b 02                	mov    (%edx),%eax
  8004c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8004c7:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  8004c8:	8b 10                	mov    (%eax),%edx
  8004ca:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004cd:	89 08                	mov    %ecx,(%eax)
  8004cf:	8b 02                	mov    (%edx),%eax
  8004d1:	8b 52 04             	mov    0x4(%edx),%edx
  8004d4:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  8004d5:	8b 10                	mov    (%eax),%edx
  8004d7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004da:	89 08                	mov    %ecx,(%eax)
  8004dc:	8b 02                	mov    (%edx),%eax
  8004de:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004e3:	c3                   	ret    

008004e4 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004e4:	83 fa 01             	cmp    $0x1,%edx
  8004e7:	7f 0f                	jg     8004f8 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  8004e9:	85 d2                	test   %edx,%edx
  8004eb:	74 18                	je     800505 <getint+0x21>
		return va_arg(*ap, long);
  8004ed:	8b 10                	mov    (%eax),%edx
  8004ef:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004f2:	89 08                	mov    %ecx,(%eax)
  8004f4:	8b 02                	mov    (%edx),%eax
  8004f6:	99                   	cltd   
  8004f7:	c3                   	ret    
		return va_arg(*ap, long long);
  8004f8:	8b 10                	mov    (%eax),%edx
  8004fa:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004fd:	89 08                	mov    %ecx,(%eax)
  8004ff:	8b 02                	mov    (%edx),%eax
  800501:	8b 52 04             	mov    0x4(%edx),%edx
  800504:	c3                   	ret    
	else
		return va_arg(*ap, int);
  800505:	8b 10                	mov    (%eax),%edx
  800507:	8d 4a 04             	lea    0x4(%edx),%ecx
  80050a:	89 08                	mov    %ecx,(%eax)
  80050c:	8b 02                	mov    (%edx),%eax
  80050e:	99                   	cltd   
}
  80050f:	c3                   	ret    

00800510 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800510:	55                   	push   %ebp
  800511:	89 e5                	mov    %esp,%ebp
  800513:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800516:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80051a:	8b 10                	mov    (%eax),%edx
  80051c:	3b 50 04             	cmp    0x4(%eax),%edx
  80051f:	73 0a                	jae    80052b <sprintputch+0x1b>
		*b->buf++ = ch;
  800521:	8d 4a 01             	lea    0x1(%edx),%ecx
  800524:	89 08                	mov    %ecx,(%eax)
  800526:	8b 45 08             	mov    0x8(%ebp),%eax
  800529:	88 02                	mov    %al,(%edx)
}
  80052b:	5d                   	pop    %ebp
  80052c:	c3                   	ret    

0080052d <printfmt>:
{
  80052d:	55                   	push   %ebp
  80052e:	89 e5                	mov    %esp,%ebp
  800530:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800533:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800536:	50                   	push   %eax
  800537:	ff 75 10             	push   0x10(%ebp)
  80053a:	ff 75 0c             	push   0xc(%ebp)
  80053d:	ff 75 08             	push   0x8(%ebp)
  800540:	e8 05 00 00 00       	call   80054a <vprintfmt>
}
  800545:	83 c4 10             	add    $0x10,%esp
  800548:	c9                   	leave  
  800549:	c3                   	ret    

0080054a <vprintfmt>:
{
  80054a:	55                   	push   %ebp
  80054b:	89 e5                	mov    %esp,%ebp
  80054d:	57                   	push   %edi
  80054e:	56                   	push   %esi
  80054f:	53                   	push   %ebx
  800550:	83 ec 2c             	sub    $0x2c,%esp
  800553:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800556:	8b 75 0c             	mov    0xc(%ebp),%esi
  800559:	8b 7d 10             	mov    0x10(%ebp),%edi
  80055c:	eb 0a                	jmp    800568 <vprintfmt+0x1e>
			putch(ch, putdat);
  80055e:	83 ec 08             	sub    $0x8,%esp
  800561:	56                   	push   %esi
  800562:	50                   	push   %eax
  800563:	ff d3                	call   *%ebx
  800565:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800568:	83 c7 01             	add    $0x1,%edi
  80056b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80056f:	83 f8 25             	cmp    $0x25,%eax
  800572:	74 0c                	je     800580 <vprintfmt+0x36>
			if (ch == '\0')
  800574:	85 c0                	test   %eax,%eax
  800576:	75 e6                	jne    80055e <vprintfmt+0x14>
}
  800578:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80057b:	5b                   	pop    %ebx
  80057c:	5e                   	pop    %esi
  80057d:	5f                   	pop    %edi
  80057e:	5d                   	pop    %ebp
  80057f:	c3                   	ret    
		padc = ' ';
  800580:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
		altflag = 0;
  800584:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80058b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800592:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800599:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80059e:	8d 47 01             	lea    0x1(%edi),%eax
  8005a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005a4:	0f b6 17             	movzbl (%edi),%edx
  8005a7:	8d 42 dd             	lea    -0x23(%edx),%eax
  8005aa:	3c 55                	cmp    $0x55,%al
  8005ac:	0f 87 b7 02 00 00    	ja     800869 <vprintfmt+0x31f>
  8005b2:	0f b6 c0             	movzbl %al,%eax
  8005b5:	ff 24 85 20 10 80 00 	jmp    *0x801020(,%eax,4)
  8005bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8005bf:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  8005c3:	eb d9                	jmp    80059e <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8005c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005c8:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  8005cc:	eb d0                	jmp    80059e <vprintfmt+0x54>
  8005ce:	0f b6 d2             	movzbl %dl,%edx
  8005d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0;; ++fmt) {
  8005d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8005d9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8005dc:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005df:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8005e3:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8005e6:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8005e9:	83 f9 09             	cmp    $0x9,%ecx
  8005ec:	77 52                	ja     800640 <vprintfmt+0xf6>
			for (precision = 0;; ++fmt) {
  8005ee:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8005f1:	eb e9                	jmp    8005dc <vprintfmt+0x92>
			precision = va_arg(ap, int);
  8005f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f6:	8d 50 04             	lea    0x4(%eax),%edx
  8005f9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fc:	8b 00                	mov    (%eax),%eax
  8005fe:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800601:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800604:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800608:	79 94                	jns    80059e <vprintfmt+0x54>
				width = precision, precision = -1;
  80060a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80060d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800610:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800617:	eb 85                	jmp    80059e <vprintfmt+0x54>
  800619:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80061c:	85 d2                	test   %edx,%edx
  80061e:	b8 00 00 00 00       	mov    $0x0,%eax
  800623:	0f 49 c2             	cmovns %edx,%eax
  800626:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800629:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80062c:	e9 6d ff ff ff       	jmp    80059e <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800631:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800634:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80063b:	e9 5e ff ff ff       	jmp    80059e <vprintfmt+0x54>
  800640:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800643:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800646:	eb bc                	jmp    800604 <vprintfmt+0xba>
			lflag++;
  800648:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80064b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80064e:	e9 4b ff ff ff       	jmp    80059e <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800653:	8b 45 14             	mov    0x14(%ebp),%eax
  800656:	8d 50 04             	lea    0x4(%eax),%edx
  800659:	89 55 14             	mov    %edx,0x14(%ebp)
  80065c:	83 ec 08             	sub    $0x8,%esp
  80065f:	56                   	push   %esi
  800660:	ff 30                	push   (%eax)
  800662:	ff d3                	call   *%ebx
			break;
  800664:	83 c4 10             	add    $0x10,%esp
  800667:	e9 94 01 00 00       	jmp    800800 <vprintfmt+0x2b6>
			err = va_arg(ap, int);
  80066c:	8b 45 14             	mov    0x14(%ebp),%eax
  80066f:	8d 50 04             	lea    0x4(%eax),%edx
  800672:	89 55 14             	mov    %edx,0x14(%ebp)
  800675:	8b 10                	mov    (%eax),%edx
  800677:	89 d0                	mov    %edx,%eax
  800679:	f7 d8                	neg    %eax
  80067b:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80067e:	83 f8 08             	cmp    $0x8,%eax
  800681:	7f 20                	jg     8006a3 <vprintfmt+0x159>
  800683:	8b 14 85 80 11 80 00 	mov    0x801180(,%eax,4),%edx
  80068a:	85 d2                	test   %edx,%edx
  80068c:	74 15                	je     8006a3 <vprintfmt+0x159>
				printfmt(putch, putdat, "%s", p);
  80068e:	52                   	push   %edx
  80068f:	68 7e 0f 80 00       	push   $0x800f7e
  800694:	56                   	push   %esi
  800695:	53                   	push   %ebx
  800696:	e8 92 fe ff ff       	call   80052d <printfmt>
  80069b:	83 c4 10             	add    $0x10,%esp
  80069e:	e9 5d 01 00 00       	jmp    800800 <vprintfmt+0x2b6>
				printfmt(putch, putdat, "error %d", err);
  8006a3:	50                   	push   %eax
  8006a4:	68 75 0f 80 00       	push   $0x800f75
  8006a9:	56                   	push   %esi
  8006aa:	53                   	push   %ebx
  8006ab:	e8 7d fe ff ff       	call   80052d <printfmt>
  8006b0:	83 c4 10             	add    $0x10,%esp
  8006b3:	e9 48 01 00 00       	jmp    800800 <vprintfmt+0x2b6>
			if ((p = va_arg(ap, char *)) == NULL)
  8006b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bb:	8d 50 04             	lea    0x4(%eax),%edx
  8006be:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c1:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006c3:	85 ff                	test   %edi,%edi
  8006c5:	b8 6e 0f 80 00       	mov    $0x800f6e,%eax
  8006ca:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006cd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006d1:	7e 06                	jle    8006d9 <vprintfmt+0x18f>
  8006d3:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8006d7:	75 0a                	jne    8006e3 <vprintfmt+0x199>
  8006d9:	89 f8                	mov    %edi,%eax
  8006db:	03 45 e0             	add    -0x20(%ebp),%eax
  8006de:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006e1:	eb 59                	jmp    80073c <vprintfmt+0x1f2>
				for (width -= strnlen(p, precision); width > 0;
  8006e3:	83 ec 08             	sub    $0x8,%esp
  8006e6:	ff 75 d8             	push   -0x28(%ebp)
  8006e9:	57                   	push   %edi
  8006ea:	e8 1a 02 00 00       	call   800909 <strnlen>
  8006ef:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006f2:	29 c1                	sub    %eax,%ecx
  8006f4:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006f7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006fa:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  8006fe:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800701:	89 7d d0             	mov    %edi,-0x30(%ebp)
  800704:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0;
  800706:	eb 0f                	jmp    800717 <vprintfmt+0x1cd>
					putch(padc, putdat);
  800708:	83 ec 08             	sub    $0x8,%esp
  80070b:	56                   	push   %esi
  80070c:	ff 75 e0             	push   -0x20(%ebp)
  80070f:	ff d3                	call   *%ebx
				     width--)
  800711:	83 ef 01             	sub    $0x1,%edi
  800714:	83 c4 10             	add    $0x10,%esp
				for (width -= strnlen(p, precision); width > 0;
  800717:	85 ff                	test   %edi,%edi
  800719:	7f ed                	jg     800708 <vprintfmt+0x1be>
  80071b:	8b 7d d0             	mov    -0x30(%ebp),%edi
  80071e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800721:	85 c9                	test   %ecx,%ecx
  800723:	b8 00 00 00 00       	mov    $0x0,%eax
  800728:	0f 49 c1             	cmovns %ecx,%eax
  80072b:	29 c1                	sub    %eax,%ecx
  80072d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800730:	eb a7                	jmp    8006d9 <vprintfmt+0x18f>
					putch(ch, putdat);
  800732:	83 ec 08             	sub    $0x8,%esp
  800735:	56                   	push   %esi
  800736:	52                   	push   %edx
  800737:	ff d3                	call   *%ebx
  800739:	83 c4 10             	add    $0x10,%esp
  80073c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80073f:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' &&
  800741:	83 c7 01             	add    $0x1,%edi
  800744:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800748:	0f be d0             	movsbl %al,%edx
  80074b:	85 d2                	test   %edx,%edx
  80074d:	74 42                	je     800791 <vprintfmt+0x247>
  80074f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800753:	78 06                	js     80075b <vprintfmt+0x211>
			       (precision < 0 || --precision >= 0);
  800755:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800759:	78 1e                	js     800779 <vprintfmt+0x22f>
				if (altflag && (ch < ' ' || ch > '~'))
  80075b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80075f:	74 d1                	je     800732 <vprintfmt+0x1e8>
  800761:	0f be c0             	movsbl %al,%eax
  800764:	83 e8 20             	sub    $0x20,%eax
  800767:	83 f8 5e             	cmp    $0x5e,%eax
  80076a:	76 c6                	jbe    800732 <vprintfmt+0x1e8>
					putch('?', putdat);
  80076c:	83 ec 08             	sub    $0x8,%esp
  80076f:	56                   	push   %esi
  800770:	6a 3f                	push   $0x3f
  800772:	ff d3                	call   *%ebx
  800774:	83 c4 10             	add    $0x10,%esp
  800777:	eb c3                	jmp    80073c <vprintfmt+0x1f2>
  800779:	89 cf                	mov    %ecx,%edi
  80077b:	eb 0e                	jmp    80078b <vprintfmt+0x241>
				putch(' ', putdat);
  80077d:	83 ec 08             	sub    $0x8,%esp
  800780:	56                   	push   %esi
  800781:	6a 20                	push   $0x20
  800783:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  800785:	83 ef 01             	sub    $0x1,%edi
  800788:	83 c4 10             	add    $0x10,%esp
  80078b:	85 ff                	test   %edi,%edi
  80078d:	7f ee                	jg     80077d <vprintfmt+0x233>
  80078f:	eb 6f                	jmp    800800 <vprintfmt+0x2b6>
  800791:	89 cf                	mov    %ecx,%edi
  800793:	eb f6                	jmp    80078b <vprintfmt+0x241>
			num = getint(&ap, lflag);
  800795:	89 ca                	mov    %ecx,%edx
  800797:	8d 45 14             	lea    0x14(%ebp),%eax
  80079a:	e8 45 fd ff ff       	call   8004e4 <getint>
  80079f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007a2:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  8007a5:	85 d2                	test   %edx,%edx
  8007a7:	78 0b                	js     8007b4 <vprintfmt+0x26a>
			num = getint(&ap, lflag);
  8007a9:	89 d1                	mov    %edx,%ecx
  8007ab:	89 c2                	mov    %eax,%edx
			base = 10;
  8007ad:	bf 0a 00 00 00       	mov    $0xa,%edi
  8007b2:	eb 32                	jmp    8007e6 <vprintfmt+0x29c>
				putch('-', putdat);
  8007b4:	83 ec 08             	sub    $0x8,%esp
  8007b7:	56                   	push   %esi
  8007b8:	6a 2d                	push   $0x2d
  8007ba:	ff d3                	call   *%ebx
				num = -(long long) num;
  8007bc:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007bf:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007c2:	f7 da                	neg    %edx
  8007c4:	83 d1 00             	adc    $0x0,%ecx
  8007c7:	f7 d9                	neg    %ecx
  8007c9:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8007cc:	bf 0a 00 00 00       	mov    $0xa,%edi
  8007d1:	eb 13                	jmp    8007e6 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  8007d3:	89 ca                	mov    %ecx,%edx
  8007d5:	8d 45 14             	lea    0x14(%ebp),%eax
  8007d8:	e8 d3 fc ff ff       	call   8004b0 <getuint>
  8007dd:	89 d1                	mov    %edx,%ecx
  8007df:	89 c2                	mov    %eax,%edx
			base = 10;
  8007e1:	bf 0a 00 00 00       	mov    $0xa,%edi
			printnum(putch, putdat, num, base, width, padc);
  8007e6:	83 ec 0c             	sub    $0xc,%esp
  8007e9:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  8007ed:	50                   	push   %eax
  8007ee:	ff 75 e0             	push   -0x20(%ebp)
  8007f1:	57                   	push   %edi
  8007f2:	51                   	push   %ecx
  8007f3:	52                   	push   %edx
  8007f4:	89 f2                	mov    %esi,%edx
  8007f6:	89 d8                	mov    %ebx,%eax
  8007f8:	e8 0a fc ff ff       	call   800407 <printnum>
			break;
  8007fd:	83 c4 20             	add    $0x20,%esp
{
  800800:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800803:	e9 60 fd ff ff       	jmp    800568 <vprintfmt+0x1e>
			num = getuint(&ap, lflag);
  800808:	89 ca                	mov    %ecx,%edx
  80080a:	8d 45 14             	lea    0x14(%ebp),%eax
  80080d:	e8 9e fc ff ff       	call   8004b0 <getuint>
  800812:	89 d1                	mov    %edx,%ecx
  800814:	89 c2                	mov    %eax,%edx
			base = 8;
  800816:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  80081b:	eb c9                	jmp    8007e6 <vprintfmt+0x29c>
			putch('0', putdat);
  80081d:	83 ec 08             	sub    $0x8,%esp
  800820:	56                   	push   %esi
  800821:	6a 30                	push   $0x30
  800823:	ff d3                	call   *%ebx
			putch('x', putdat);
  800825:	83 c4 08             	add    $0x8,%esp
  800828:	56                   	push   %esi
  800829:	6a 78                	push   $0x78
  80082b:	ff d3                	call   *%ebx
			num = (unsigned long long) (uintptr_t) va_arg(ap, void *);
  80082d:	8b 45 14             	mov    0x14(%ebp),%eax
  800830:	8d 50 04             	lea    0x4(%eax),%edx
  800833:	89 55 14             	mov    %edx,0x14(%ebp)
  800836:	8b 10                	mov    (%eax),%edx
  800838:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80083d:	83 c4 10             	add    $0x10,%esp
			base = 16;
  800840:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  800845:	eb 9f                	jmp    8007e6 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  800847:	89 ca                	mov    %ecx,%edx
  800849:	8d 45 14             	lea    0x14(%ebp),%eax
  80084c:	e8 5f fc ff ff       	call   8004b0 <getuint>
  800851:	89 d1                	mov    %edx,%ecx
  800853:	89 c2                	mov    %eax,%edx
			base = 16;
  800855:	bf 10 00 00 00       	mov    $0x10,%edi
  80085a:	eb 8a                	jmp    8007e6 <vprintfmt+0x29c>
			putch(ch, putdat);
  80085c:	83 ec 08             	sub    $0x8,%esp
  80085f:	56                   	push   %esi
  800860:	6a 25                	push   $0x25
  800862:	ff d3                	call   *%ebx
			break;
  800864:	83 c4 10             	add    $0x10,%esp
  800867:	eb 97                	jmp    800800 <vprintfmt+0x2b6>
			putch('%', putdat);
  800869:	83 ec 08             	sub    $0x8,%esp
  80086c:	56                   	push   %esi
  80086d:	6a 25                	push   $0x25
  80086f:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  800871:	83 c4 10             	add    $0x10,%esp
  800874:	89 f8                	mov    %edi,%eax
  800876:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80087a:	74 05                	je     800881 <vprintfmt+0x337>
  80087c:	83 e8 01             	sub    $0x1,%eax
  80087f:	eb f5                	jmp    800876 <vprintfmt+0x32c>
  800881:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800884:	e9 77 ff ff ff       	jmp    800800 <vprintfmt+0x2b6>

00800889 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800889:	55                   	push   %ebp
  80088a:	89 e5                	mov    %esp,%ebp
  80088c:	83 ec 18             	sub    $0x18,%esp
  80088f:	8b 45 08             	mov    0x8(%ebp),%eax
  800892:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = { buf, buf + n - 1, 0 };
  800895:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800898:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80089c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80089f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008a6:	85 c0                	test   %eax,%eax
  8008a8:	74 26                	je     8008d0 <vsnprintf+0x47>
  8008aa:	85 d2                	test   %edx,%edx
  8008ac:	7e 22                	jle    8008d0 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *) sprintputch, &b, fmt, ap);
  8008ae:	ff 75 14             	push   0x14(%ebp)
  8008b1:	ff 75 10             	push   0x10(%ebp)
  8008b4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008b7:	50                   	push   %eax
  8008b8:	68 10 05 80 00       	push   $0x800510
  8008bd:	e8 88 fc ff ff       	call   80054a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008c5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008cb:	83 c4 10             	add    $0x10,%esp
}
  8008ce:	c9                   	leave  
  8008cf:	c3                   	ret    
		return -E_INVAL;
  8008d0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008d5:	eb f7                	jmp    8008ce <vsnprintf+0x45>

008008d7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008dd:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008e0:	50                   	push   %eax
  8008e1:	ff 75 10             	push   0x10(%ebp)
  8008e4:	ff 75 0c             	push   0xc(%ebp)
  8008e7:	ff 75 08             	push   0x8(%ebp)
  8008ea:	e8 9a ff ff ff       	call   800889 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008ef:	c9                   	leave  
  8008f0:	c3                   	ret    

008008f1 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008f1:	55                   	push   %ebp
  8008f2:	89 e5                	mov    %esp,%ebp
  8008f4:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8008fc:	eb 03                	jmp    800901 <strlen+0x10>
		n++;
  8008fe:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800901:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800905:	75 f7                	jne    8008fe <strlen+0xd>
	return n;
}
  800907:	5d                   	pop    %ebp
  800908:	c3                   	ret    

00800909 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800909:	55                   	push   %ebp
  80090a:	89 e5                	mov    %esp,%ebp
  80090c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80090f:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800912:	b8 00 00 00 00       	mov    $0x0,%eax
  800917:	eb 03                	jmp    80091c <strnlen+0x13>
		n++;
  800919:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80091c:	39 d0                	cmp    %edx,%eax
  80091e:	74 08                	je     800928 <strnlen+0x1f>
  800920:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800924:	75 f3                	jne    800919 <strnlen+0x10>
  800926:	89 c2                	mov    %eax,%edx
	return n;
}
  800928:	89 d0                	mov    %edx,%eax
  80092a:	5d                   	pop    %ebp
  80092b:	c3                   	ret    

0080092c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80092c:	55                   	push   %ebp
  80092d:	89 e5                	mov    %esp,%ebp
  80092f:	53                   	push   %ebx
  800930:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800933:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800936:	b8 00 00 00 00       	mov    $0x0,%eax
  80093b:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80093f:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800942:	83 c0 01             	add    $0x1,%eax
  800945:	84 d2                	test   %dl,%dl
  800947:	75 f2                	jne    80093b <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800949:	89 c8                	mov    %ecx,%eax
  80094b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80094e:	c9                   	leave  
  80094f:	c3                   	ret    

00800950 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800950:	55                   	push   %ebp
  800951:	89 e5                	mov    %esp,%ebp
  800953:	53                   	push   %ebx
  800954:	83 ec 10             	sub    $0x10,%esp
  800957:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80095a:	53                   	push   %ebx
  80095b:	e8 91 ff ff ff       	call   8008f1 <strlen>
  800960:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800963:	ff 75 0c             	push   0xc(%ebp)
  800966:	01 d8                	add    %ebx,%eax
  800968:	50                   	push   %eax
  800969:	e8 be ff ff ff       	call   80092c <strcpy>
	return dst;
}
  80096e:	89 d8                	mov    %ebx,%eax
  800970:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800973:	c9                   	leave  
  800974:	c3                   	ret    

00800975 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size)
{
  800975:	55                   	push   %ebp
  800976:	89 e5                	mov    %esp,%ebp
  800978:	56                   	push   %esi
  800979:	53                   	push   %ebx
  80097a:	8b 75 08             	mov    0x8(%ebp),%esi
  80097d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800980:	89 f3                	mov    %esi,%ebx
  800982:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800985:	89 f0                	mov    %esi,%eax
  800987:	eb 0f                	jmp    800998 <strncpy+0x23>
		*dst++ = *src;
  800989:	83 c0 01             	add    $0x1,%eax
  80098c:	0f b6 0a             	movzbl (%edx),%ecx
  80098f:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800992:	80 f9 01             	cmp    $0x1,%cl
  800995:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800998:	39 d8                	cmp    %ebx,%eax
  80099a:	75 ed                	jne    800989 <strncpy+0x14>
	}
	return ret;
}
  80099c:	89 f0                	mov    %esi,%eax
  80099e:	5b                   	pop    %ebx
  80099f:	5e                   	pop    %esi
  8009a0:	5d                   	pop    %ebp
  8009a1:	c3                   	ret    

008009a2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009a2:	55                   	push   %ebp
  8009a3:	89 e5                	mov    %esp,%ebp
  8009a5:	56                   	push   %esi
  8009a6:	53                   	push   %ebx
  8009a7:	8b 75 08             	mov    0x8(%ebp),%esi
  8009aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009ad:	8b 55 10             	mov    0x10(%ebp),%edx
  8009b0:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009b2:	85 d2                	test   %edx,%edx
  8009b4:	74 21                	je     8009d7 <strlcpy+0x35>
  8009b6:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009ba:	89 f2                	mov    %esi,%edx
  8009bc:	eb 09                	jmp    8009c7 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009be:	83 c1 01             	add    $0x1,%ecx
  8009c1:	83 c2 01             	add    $0x1,%edx
  8009c4:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  8009c7:	39 c2                	cmp    %eax,%edx
  8009c9:	74 09                	je     8009d4 <strlcpy+0x32>
  8009cb:	0f b6 19             	movzbl (%ecx),%ebx
  8009ce:	84 db                	test   %bl,%bl
  8009d0:	75 ec                	jne    8009be <strlcpy+0x1c>
  8009d2:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8009d4:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009d7:	29 f0                	sub    %esi,%eax
}
  8009d9:	5b                   	pop    %ebx
  8009da:	5e                   	pop    %esi
  8009db:	5d                   	pop    %ebp
  8009dc:	c3                   	ret    

008009dd <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009dd:	55                   	push   %ebp
  8009de:	89 e5                	mov    %esp,%ebp
  8009e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009e3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009e6:	eb 06                	jmp    8009ee <strcmp+0x11>
		p++, q++;
  8009e8:	83 c1 01             	add    $0x1,%ecx
  8009eb:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8009ee:	0f b6 01             	movzbl (%ecx),%eax
  8009f1:	84 c0                	test   %al,%al
  8009f3:	74 04                	je     8009f9 <strcmp+0x1c>
  8009f5:	3a 02                	cmp    (%edx),%al
  8009f7:	74 ef                	je     8009e8 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009f9:	0f b6 c0             	movzbl %al,%eax
  8009fc:	0f b6 12             	movzbl (%edx),%edx
  8009ff:	29 d0                	sub    %edx,%eax
}
  800a01:	5d                   	pop    %ebp
  800a02:	c3                   	ret    

00800a03 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a03:	55                   	push   %ebp
  800a04:	89 e5                	mov    %esp,%ebp
  800a06:	53                   	push   %ebx
  800a07:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a0d:	89 c3                	mov    %eax,%ebx
  800a0f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a12:	eb 06                	jmp    800a1a <strncmp+0x17>
		n--, p++, q++;
  800a14:	83 c0 01             	add    $0x1,%eax
  800a17:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a1a:	39 d8                	cmp    %ebx,%eax
  800a1c:	74 18                	je     800a36 <strncmp+0x33>
  800a1e:	0f b6 08             	movzbl (%eax),%ecx
  800a21:	84 c9                	test   %cl,%cl
  800a23:	74 04                	je     800a29 <strncmp+0x26>
  800a25:	3a 0a                	cmp    (%edx),%cl
  800a27:	74 eb                	je     800a14 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a29:	0f b6 00             	movzbl (%eax),%eax
  800a2c:	0f b6 12             	movzbl (%edx),%edx
  800a2f:	29 d0                	sub    %edx,%eax
}
  800a31:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a34:	c9                   	leave  
  800a35:	c3                   	ret    
		return 0;
  800a36:	b8 00 00 00 00       	mov    $0x0,%eax
  800a3b:	eb f4                	jmp    800a31 <strncmp+0x2e>

00800a3d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a3d:	55                   	push   %ebp
  800a3e:	89 e5                	mov    %esp,%ebp
  800a40:	8b 45 08             	mov    0x8(%ebp),%eax
  800a43:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a47:	eb 03                	jmp    800a4c <strchr+0xf>
  800a49:	83 c0 01             	add    $0x1,%eax
  800a4c:	0f b6 10             	movzbl (%eax),%edx
  800a4f:	84 d2                	test   %dl,%dl
  800a51:	74 06                	je     800a59 <strchr+0x1c>
		if (*s == c)
  800a53:	38 ca                	cmp    %cl,%dl
  800a55:	75 f2                	jne    800a49 <strchr+0xc>
  800a57:	eb 05                	jmp    800a5e <strchr+0x21>
			return (char *) s;
	return 0;
  800a59:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a5e:	5d                   	pop    %ebp
  800a5f:	c3                   	ret    

00800a60 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a60:	55                   	push   %ebp
  800a61:	89 e5                	mov    %esp,%ebp
  800a63:	8b 45 08             	mov    0x8(%ebp),%eax
  800a66:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a6a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a6d:	38 ca                	cmp    %cl,%dl
  800a6f:	74 09                	je     800a7a <strfind+0x1a>
  800a71:	84 d2                	test   %dl,%dl
  800a73:	74 05                	je     800a7a <strfind+0x1a>
	for (; *s; s++)
  800a75:	83 c0 01             	add    $0x1,%eax
  800a78:	eb f0                	jmp    800a6a <strfind+0xa>
			break;
	return (char *) s;
}
  800a7a:	5d                   	pop    %ebp
  800a7b:	c3                   	ret    

00800a7c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	57                   	push   %edi
  800a80:	56                   	push   %esi
  800a81:	53                   	push   %ebx
  800a82:	8b 55 08             	mov    0x8(%ebp),%edx
  800a85:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  800a88:	85 c9                	test   %ecx,%ecx
  800a8a:	74 33                	je     800abf <memset+0x43>
		return v;
	if ((int) v % 4 == 0 && n % 4 == 0) {
  800a8c:	89 d0                	mov    %edx,%eax
  800a8e:	09 c8                	or     %ecx,%eax
  800a90:	a8 03                	test   $0x3,%al
  800a92:	75 23                	jne    800ab7 <memset+0x3b>
		c &= 0xFF;
  800a94:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  800a98:	89 d8                	mov    %ebx,%eax
  800a9a:	c1 e0 08             	shl    $0x8,%eax
  800a9d:	89 df                	mov    %ebx,%edi
  800a9f:	c1 e7 18             	shl    $0x18,%edi
  800aa2:	89 de                	mov    %ebx,%esi
  800aa4:	c1 e6 10             	shl    $0x10,%esi
  800aa7:	09 f7                	or     %esi,%edi
  800aa9:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
		             : "=D"(p), "=c"(n)
		             : "D"(p), "a"(c), "c"(n / 4)
  800aab:	c1 e9 02             	shr    $0x2,%ecx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  800aae:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800ab0:	89 d7                	mov    %edx,%edi
  800ab2:	fc                   	cld    
  800ab3:	f3 ab                	rep stos %eax,%es:(%edi)
  800ab5:	eb 08                	jmp    800abf <memset+0x43>
		             : "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ab7:	89 d7                	mov    %edx,%edi
  800ab9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800abc:	fc                   	cld    
  800abd:	f3 aa                	rep stos %al,%es:(%edi)
		             : "=D"(p), "=c"(n)
		             : "0"(p), "a"(c), "1"(n)
		             : "cc", "memory");
	return v;
}
  800abf:	89 d0                	mov    %edx,%eax
  800ac1:	5b                   	pop    %ebx
  800ac2:	5e                   	pop    %esi
  800ac3:	5f                   	pop    %edi
  800ac4:	5d                   	pop    %ebp
  800ac5:	c3                   	ret    

00800ac6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ac6:	55                   	push   %ebp
  800ac7:	89 e5                	mov    %esp,%ebp
  800ac9:	57                   	push   %edi
  800aca:	56                   	push   %esi
  800acb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ace:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ad1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ad4:	39 c6                	cmp    %eax,%esi
  800ad6:	73 32                	jae    800b0a <memmove+0x44>
  800ad8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800adb:	39 c2                	cmp    %eax,%edx
  800add:	76 2b                	jbe    800b0a <memmove+0x44>
		s += n;
		d += n;
  800adf:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  800ae2:	89 d6                	mov    %edx,%esi
  800ae4:	09 fe                	or     %edi,%esi
  800ae6:	09 ce                	or     %ecx,%esi
  800ae8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aee:	75 0e                	jne    800afe <memmove+0x38>
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  800af0:	83 ef 04             	sub    $0x4,%edi
			             "S"(s - 4),
  800af3:	8d 72 fc             	lea    -0x4(%edx),%esi
			             "c"(n / 4)
  800af6:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  800af9:	fd                   	std    
  800afa:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800afc:	eb 09                	jmp    800b07 <memmove+0x41>
			             : "cc", "memory");
		else
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  800afe:	83 ef 01             	sub    $0x1,%edi
			             "S"(s - 1),
  800b01:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  800b04:	fd                   	std    
  800b05:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             "c"(n)
			             : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b07:	fc                   	cld    
  800b08:	eb 1a                	jmp    800b24 <memmove+0x5e>
	} else {
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  800b0a:	89 f2                	mov    %esi,%edx
  800b0c:	09 c2                	or     %eax,%edx
  800b0e:	09 ca                	or     %ecx,%edx
  800b10:	f6 c2 03             	test   $0x3,%dl
  800b13:	75 0a                	jne    800b1f <memmove+0x59>
			asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800b15:	c1 e9 02             	shr    $0x2,%ecx
  800b18:	89 c7                	mov    %eax,%edi
  800b1a:	fc                   	cld    
  800b1b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b1d:	eb 05                	jmp    800b24 <memmove+0x5e>
			             : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800b1f:	89 c7                	mov    %eax,%edi
  800b21:	fc                   	cld    
  800b22:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             : "cc", "memory");
	}
	return dst;
}
  800b24:	5e                   	pop    %esi
  800b25:	5f                   	pop    %edi
  800b26:	5d                   	pop    %ebp
  800b27:	c3                   	ret    

00800b28 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b28:	55                   	push   %ebp
  800b29:	89 e5                	mov    %esp,%ebp
  800b2b:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b2e:	ff 75 10             	push   0x10(%ebp)
  800b31:	ff 75 0c             	push   0xc(%ebp)
  800b34:	ff 75 08             	push   0x8(%ebp)
  800b37:	e8 8a ff ff ff       	call   800ac6 <memmove>
}
  800b3c:	c9                   	leave  
  800b3d:	c3                   	ret    

00800b3e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b3e:	55                   	push   %ebp
  800b3f:	89 e5                	mov    %esp,%ebp
  800b41:	56                   	push   %esi
  800b42:	53                   	push   %ebx
  800b43:	8b 45 08             	mov    0x8(%ebp),%eax
  800b46:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b49:	89 c6                	mov    %eax,%esi
  800b4b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b4e:	eb 06                	jmp    800b56 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b50:	83 c0 01             	add    $0x1,%eax
  800b53:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800b56:	39 f0                	cmp    %esi,%eax
  800b58:	74 14                	je     800b6e <memcmp+0x30>
		if (*s1 != *s2)
  800b5a:	0f b6 08             	movzbl (%eax),%ecx
  800b5d:	0f b6 1a             	movzbl (%edx),%ebx
  800b60:	38 d9                	cmp    %bl,%cl
  800b62:	74 ec                	je     800b50 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800b64:	0f b6 c1             	movzbl %cl,%eax
  800b67:	0f b6 db             	movzbl %bl,%ebx
  800b6a:	29 d8                	sub    %ebx,%eax
  800b6c:	eb 05                	jmp    800b73 <memcmp+0x35>
	}

	return 0;
  800b6e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b73:	5b                   	pop    %ebx
  800b74:	5e                   	pop    %esi
  800b75:	5d                   	pop    %ebp
  800b76:	c3                   	ret    

00800b77 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b77:	55                   	push   %ebp
  800b78:	89 e5                	mov    %esp,%ebp
  800b7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b80:	89 c2                	mov    %eax,%edx
  800b82:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b85:	eb 03                	jmp    800b8a <memfind+0x13>
  800b87:	83 c0 01             	add    $0x1,%eax
  800b8a:	39 d0                	cmp    %edx,%eax
  800b8c:	73 04                	jae    800b92 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b8e:	38 08                	cmp    %cl,(%eax)
  800b90:	75 f5                	jne    800b87 <memfind+0x10>
			break;
	return (void *) s;
}
  800b92:	5d                   	pop    %ebp
  800b93:	c3                   	ret    

00800b94 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b94:	55                   	push   %ebp
  800b95:	89 e5                	mov    %esp,%ebp
  800b97:	57                   	push   %edi
  800b98:	56                   	push   %esi
  800b99:	53                   	push   %ebx
  800b9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ba0:	eb 03                	jmp    800ba5 <strtol+0x11>
		s++;
  800ba2:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800ba5:	0f b6 02             	movzbl (%edx),%eax
  800ba8:	3c 20                	cmp    $0x20,%al
  800baa:	74 f6                	je     800ba2 <strtol+0xe>
  800bac:	3c 09                	cmp    $0x9,%al
  800bae:	74 f2                	je     800ba2 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800bb0:	3c 2b                	cmp    $0x2b,%al
  800bb2:	74 2a                	je     800bde <strtol+0x4a>
	int neg = 0;
  800bb4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800bb9:	3c 2d                	cmp    $0x2d,%al
  800bbb:	74 2b                	je     800be8 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bbd:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bc3:	75 0f                	jne    800bd4 <strtol+0x40>
  800bc5:	80 3a 30             	cmpb   $0x30,(%edx)
  800bc8:	74 28                	je     800bf2 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bca:	85 db                	test   %ebx,%ebx
  800bcc:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bd1:	0f 44 d8             	cmove  %eax,%ebx
  800bd4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bd9:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800bdc:	eb 46                	jmp    800c24 <strtol+0x90>
		s++;
  800bde:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800be1:	bf 00 00 00 00       	mov    $0x0,%edi
  800be6:	eb d5                	jmp    800bbd <strtol+0x29>
		s++, neg = 1;
  800be8:	83 c2 01             	add    $0x1,%edx
  800beb:	bf 01 00 00 00       	mov    $0x1,%edi
  800bf0:	eb cb                	jmp    800bbd <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bf2:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bf6:	74 0e                	je     800c06 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800bf8:	85 db                	test   %ebx,%ebx
  800bfa:	75 d8                	jne    800bd4 <strtol+0x40>
		s++, base = 8;
  800bfc:	83 c2 01             	add    $0x1,%edx
  800bff:	bb 08 00 00 00       	mov    $0x8,%ebx
  800c04:	eb ce                	jmp    800bd4 <strtol+0x40>
		s += 2, base = 16;
  800c06:	83 c2 02             	add    $0x2,%edx
  800c09:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c0e:	eb c4                	jmp    800bd4 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800c10:	0f be c0             	movsbl %al,%eax
  800c13:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c16:	3b 45 10             	cmp    0x10(%ebp),%eax
  800c19:	7d 3a                	jge    800c55 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800c1b:	83 c2 01             	add    $0x1,%edx
  800c1e:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800c22:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800c24:	0f b6 02             	movzbl (%edx),%eax
  800c27:	8d 70 d0             	lea    -0x30(%eax),%esi
  800c2a:	89 f3                	mov    %esi,%ebx
  800c2c:	80 fb 09             	cmp    $0x9,%bl
  800c2f:	76 df                	jbe    800c10 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800c31:	8d 70 9f             	lea    -0x61(%eax),%esi
  800c34:	89 f3                	mov    %esi,%ebx
  800c36:	80 fb 19             	cmp    $0x19,%bl
  800c39:	77 08                	ja     800c43 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800c3b:	0f be c0             	movsbl %al,%eax
  800c3e:	83 e8 57             	sub    $0x57,%eax
  800c41:	eb d3                	jmp    800c16 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800c43:	8d 70 bf             	lea    -0x41(%eax),%esi
  800c46:	89 f3                	mov    %esi,%ebx
  800c48:	80 fb 19             	cmp    $0x19,%bl
  800c4b:	77 08                	ja     800c55 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800c4d:	0f be c0             	movsbl %al,%eax
  800c50:	83 e8 37             	sub    $0x37,%eax
  800c53:	eb c1                	jmp    800c16 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c55:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c59:	74 05                	je     800c60 <strtol+0xcc>
		*endptr = (char *) s;
  800c5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c5e:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800c60:	89 c8                	mov    %ecx,%eax
  800c62:	f7 d8                	neg    %eax
  800c64:	85 ff                	test   %edi,%edi
  800c66:	0f 45 c8             	cmovne %eax,%ecx
}
  800c69:	89 c8                	mov    %ecx,%eax
  800c6b:	5b                   	pop    %ebx
  800c6c:	5e                   	pop    %esi
  800c6d:	5f                   	pop    %edi
  800c6e:	5d                   	pop    %ebp
  800c6f:	c3                   	ret    

00800c70 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800c70:	55                   	push   %ebp
  800c71:	89 e5                	mov    %esp,%ebp
  800c73:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800c76:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800c7d:	74 0a                	je     800c89 <set_pgfault_handler+0x19>
		if (r < 0)
			return;
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800c7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c82:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800c87:	c9                   	leave  
  800c88:	c3                   	ret    
		r = sys_page_alloc(0, (void *) exstk, perm);
  800c89:	83 ec 04             	sub    $0x4,%esp
  800c8c:	6a 07                	push   $0x7
  800c8e:	68 00 f0 bf ee       	push   $0xeebff000
  800c93:	6a 00                	push   $0x0
  800c95:	e8 19 f5 ff ff       	call   8001b3 <sys_page_alloc>
		if (r < 0)
  800c9a:	83 c4 10             	add    $0x10,%esp
  800c9d:	85 c0                	test   %eax,%eax
  800c9f:	78 e6                	js     800c87 <set_pgfault_handler+0x17>
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  800ca1:	83 ec 08             	sub    $0x8,%esp
  800ca4:	68 f3 02 80 00       	push   $0x8002f3
  800ca9:	6a 00                	push   $0x0
  800cab:	e8 93 f5 ff ff       	call   800243 <sys_env_set_pgfault_upcall>
		if (r < 0)
  800cb0:	83 c4 10             	add    $0x10,%esp
  800cb3:	85 c0                	test   %eax,%eax
  800cb5:	79 c8                	jns    800c7f <set_pgfault_handler+0xf>
  800cb7:	eb ce                	jmp    800c87 <set_pgfault_handler+0x17>
  800cb9:	66 90                	xchg   %ax,%ax
  800cbb:	66 90                	xchg   %ax,%ax
  800cbd:	66 90                	xchg   %ax,%ax
  800cbf:	90                   	nop

00800cc0 <__udivdi3>:
  800cc0:	f3 0f 1e fb          	endbr32 
  800cc4:	55                   	push   %ebp
  800cc5:	57                   	push   %edi
  800cc6:	56                   	push   %esi
  800cc7:	53                   	push   %ebx
  800cc8:	83 ec 1c             	sub    $0x1c,%esp
  800ccb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800ccf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800cd3:	8b 74 24 34          	mov    0x34(%esp),%esi
  800cd7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800cdb:	85 c0                	test   %eax,%eax
  800cdd:	75 19                	jne    800cf8 <__udivdi3+0x38>
  800cdf:	39 f3                	cmp    %esi,%ebx
  800ce1:	76 4d                	jbe    800d30 <__udivdi3+0x70>
  800ce3:	31 ff                	xor    %edi,%edi
  800ce5:	89 e8                	mov    %ebp,%eax
  800ce7:	89 f2                	mov    %esi,%edx
  800ce9:	f7 f3                	div    %ebx
  800ceb:	89 fa                	mov    %edi,%edx
  800ced:	83 c4 1c             	add    $0x1c,%esp
  800cf0:	5b                   	pop    %ebx
  800cf1:	5e                   	pop    %esi
  800cf2:	5f                   	pop    %edi
  800cf3:	5d                   	pop    %ebp
  800cf4:	c3                   	ret    
  800cf5:	8d 76 00             	lea    0x0(%esi),%esi
  800cf8:	39 f0                	cmp    %esi,%eax
  800cfa:	76 14                	jbe    800d10 <__udivdi3+0x50>
  800cfc:	31 ff                	xor    %edi,%edi
  800cfe:	31 c0                	xor    %eax,%eax
  800d00:	89 fa                	mov    %edi,%edx
  800d02:	83 c4 1c             	add    $0x1c,%esp
  800d05:	5b                   	pop    %ebx
  800d06:	5e                   	pop    %esi
  800d07:	5f                   	pop    %edi
  800d08:	5d                   	pop    %ebp
  800d09:	c3                   	ret    
  800d0a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d10:	0f bd f8             	bsr    %eax,%edi
  800d13:	83 f7 1f             	xor    $0x1f,%edi
  800d16:	75 48                	jne    800d60 <__udivdi3+0xa0>
  800d18:	39 f0                	cmp    %esi,%eax
  800d1a:	72 06                	jb     800d22 <__udivdi3+0x62>
  800d1c:	31 c0                	xor    %eax,%eax
  800d1e:	39 eb                	cmp    %ebp,%ebx
  800d20:	77 de                	ja     800d00 <__udivdi3+0x40>
  800d22:	b8 01 00 00 00       	mov    $0x1,%eax
  800d27:	eb d7                	jmp    800d00 <__udivdi3+0x40>
  800d29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d30:	89 d9                	mov    %ebx,%ecx
  800d32:	85 db                	test   %ebx,%ebx
  800d34:	75 0b                	jne    800d41 <__udivdi3+0x81>
  800d36:	b8 01 00 00 00       	mov    $0x1,%eax
  800d3b:	31 d2                	xor    %edx,%edx
  800d3d:	f7 f3                	div    %ebx
  800d3f:	89 c1                	mov    %eax,%ecx
  800d41:	31 d2                	xor    %edx,%edx
  800d43:	89 f0                	mov    %esi,%eax
  800d45:	f7 f1                	div    %ecx
  800d47:	89 c6                	mov    %eax,%esi
  800d49:	89 e8                	mov    %ebp,%eax
  800d4b:	89 f7                	mov    %esi,%edi
  800d4d:	f7 f1                	div    %ecx
  800d4f:	89 fa                	mov    %edi,%edx
  800d51:	83 c4 1c             	add    $0x1c,%esp
  800d54:	5b                   	pop    %ebx
  800d55:	5e                   	pop    %esi
  800d56:	5f                   	pop    %edi
  800d57:	5d                   	pop    %ebp
  800d58:	c3                   	ret    
  800d59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d60:	89 f9                	mov    %edi,%ecx
  800d62:	ba 20 00 00 00       	mov    $0x20,%edx
  800d67:	29 fa                	sub    %edi,%edx
  800d69:	d3 e0                	shl    %cl,%eax
  800d6b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d6f:	89 d1                	mov    %edx,%ecx
  800d71:	89 d8                	mov    %ebx,%eax
  800d73:	d3 e8                	shr    %cl,%eax
  800d75:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800d79:	09 c1                	or     %eax,%ecx
  800d7b:	89 f0                	mov    %esi,%eax
  800d7d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d81:	89 f9                	mov    %edi,%ecx
  800d83:	d3 e3                	shl    %cl,%ebx
  800d85:	89 d1                	mov    %edx,%ecx
  800d87:	d3 e8                	shr    %cl,%eax
  800d89:	89 f9                	mov    %edi,%ecx
  800d8b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800d8f:	89 eb                	mov    %ebp,%ebx
  800d91:	d3 e6                	shl    %cl,%esi
  800d93:	89 d1                	mov    %edx,%ecx
  800d95:	d3 eb                	shr    %cl,%ebx
  800d97:	09 f3                	or     %esi,%ebx
  800d99:	89 c6                	mov    %eax,%esi
  800d9b:	89 f2                	mov    %esi,%edx
  800d9d:	89 d8                	mov    %ebx,%eax
  800d9f:	f7 74 24 08          	divl   0x8(%esp)
  800da3:	89 d6                	mov    %edx,%esi
  800da5:	89 c3                	mov    %eax,%ebx
  800da7:	f7 64 24 0c          	mull   0xc(%esp)
  800dab:	39 d6                	cmp    %edx,%esi
  800dad:	72 19                	jb     800dc8 <__udivdi3+0x108>
  800daf:	89 f9                	mov    %edi,%ecx
  800db1:	d3 e5                	shl    %cl,%ebp
  800db3:	39 c5                	cmp    %eax,%ebp
  800db5:	73 04                	jae    800dbb <__udivdi3+0xfb>
  800db7:	39 d6                	cmp    %edx,%esi
  800db9:	74 0d                	je     800dc8 <__udivdi3+0x108>
  800dbb:	89 d8                	mov    %ebx,%eax
  800dbd:	31 ff                	xor    %edi,%edi
  800dbf:	e9 3c ff ff ff       	jmp    800d00 <__udivdi3+0x40>
  800dc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800dc8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800dcb:	31 ff                	xor    %edi,%edi
  800dcd:	e9 2e ff ff ff       	jmp    800d00 <__udivdi3+0x40>
  800dd2:	66 90                	xchg   %ax,%ax
  800dd4:	66 90                	xchg   %ax,%ax
  800dd6:	66 90                	xchg   %ax,%ax
  800dd8:	66 90                	xchg   %ax,%ax
  800dda:	66 90                	xchg   %ax,%ax
  800ddc:	66 90                	xchg   %ax,%ax
  800dde:	66 90                	xchg   %ax,%ax

00800de0 <__umoddi3>:
  800de0:	f3 0f 1e fb          	endbr32 
  800de4:	55                   	push   %ebp
  800de5:	57                   	push   %edi
  800de6:	56                   	push   %esi
  800de7:	53                   	push   %ebx
  800de8:	83 ec 1c             	sub    $0x1c,%esp
  800deb:	8b 74 24 30          	mov    0x30(%esp),%esi
  800def:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800df3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  800df7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  800dfb:	89 f0                	mov    %esi,%eax
  800dfd:	89 da                	mov    %ebx,%edx
  800dff:	85 ff                	test   %edi,%edi
  800e01:	75 15                	jne    800e18 <__umoddi3+0x38>
  800e03:	39 dd                	cmp    %ebx,%ebp
  800e05:	76 39                	jbe    800e40 <__umoddi3+0x60>
  800e07:	f7 f5                	div    %ebp
  800e09:	89 d0                	mov    %edx,%eax
  800e0b:	31 d2                	xor    %edx,%edx
  800e0d:	83 c4 1c             	add    $0x1c,%esp
  800e10:	5b                   	pop    %ebx
  800e11:	5e                   	pop    %esi
  800e12:	5f                   	pop    %edi
  800e13:	5d                   	pop    %ebp
  800e14:	c3                   	ret    
  800e15:	8d 76 00             	lea    0x0(%esi),%esi
  800e18:	39 df                	cmp    %ebx,%edi
  800e1a:	77 f1                	ja     800e0d <__umoddi3+0x2d>
  800e1c:	0f bd cf             	bsr    %edi,%ecx
  800e1f:	83 f1 1f             	xor    $0x1f,%ecx
  800e22:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800e26:	75 40                	jne    800e68 <__umoddi3+0x88>
  800e28:	39 df                	cmp    %ebx,%edi
  800e2a:	72 04                	jb     800e30 <__umoddi3+0x50>
  800e2c:	39 f5                	cmp    %esi,%ebp
  800e2e:	77 dd                	ja     800e0d <__umoddi3+0x2d>
  800e30:	89 da                	mov    %ebx,%edx
  800e32:	89 f0                	mov    %esi,%eax
  800e34:	29 e8                	sub    %ebp,%eax
  800e36:	19 fa                	sbb    %edi,%edx
  800e38:	eb d3                	jmp    800e0d <__umoddi3+0x2d>
  800e3a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e40:	89 e9                	mov    %ebp,%ecx
  800e42:	85 ed                	test   %ebp,%ebp
  800e44:	75 0b                	jne    800e51 <__umoddi3+0x71>
  800e46:	b8 01 00 00 00       	mov    $0x1,%eax
  800e4b:	31 d2                	xor    %edx,%edx
  800e4d:	f7 f5                	div    %ebp
  800e4f:	89 c1                	mov    %eax,%ecx
  800e51:	89 d8                	mov    %ebx,%eax
  800e53:	31 d2                	xor    %edx,%edx
  800e55:	f7 f1                	div    %ecx
  800e57:	89 f0                	mov    %esi,%eax
  800e59:	f7 f1                	div    %ecx
  800e5b:	89 d0                	mov    %edx,%eax
  800e5d:	31 d2                	xor    %edx,%edx
  800e5f:	eb ac                	jmp    800e0d <__umoddi3+0x2d>
  800e61:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e68:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e6c:	ba 20 00 00 00       	mov    $0x20,%edx
  800e71:	29 c2                	sub    %eax,%edx
  800e73:	89 c1                	mov    %eax,%ecx
  800e75:	89 e8                	mov    %ebp,%eax
  800e77:	d3 e7                	shl    %cl,%edi
  800e79:	89 d1                	mov    %edx,%ecx
  800e7b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e7f:	d3 e8                	shr    %cl,%eax
  800e81:	89 c1                	mov    %eax,%ecx
  800e83:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e87:	09 f9                	or     %edi,%ecx
  800e89:	89 df                	mov    %ebx,%edi
  800e8b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e8f:	89 c1                	mov    %eax,%ecx
  800e91:	d3 e5                	shl    %cl,%ebp
  800e93:	89 d1                	mov    %edx,%ecx
  800e95:	d3 ef                	shr    %cl,%edi
  800e97:	89 c1                	mov    %eax,%ecx
  800e99:	89 f0                	mov    %esi,%eax
  800e9b:	d3 e3                	shl    %cl,%ebx
  800e9d:	89 d1                	mov    %edx,%ecx
  800e9f:	89 fa                	mov    %edi,%edx
  800ea1:	d3 e8                	shr    %cl,%eax
  800ea3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800ea8:	09 d8                	or     %ebx,%eax
  800eaa:	f7 74 24 08          	divl   0x8(%esp)
  800eae:	89 d3                	mov    %edx,%ebx
  800eb0:	d3 e6                	shl    %cl,%esi
  800eb2:	f7 e5                	mul    %ebp
  800eb4:	89 c7                	mov    %eax,%edi
  800eb6:	89 d1                	mov    %edx,%ecx
  800eb8:	39 d3                	cmp    %edx,%ebx
  800eba:	72 06                	jb     800ec2 <__umoddi3+0xe2>
  800ebc:	75 0e                	jne    800ecc <__umoddi3+0xec>
  800ebe:	39 c6                	cmp    %eax,%esi
  800ec0:	73 0a                	jae    800ecc <__umoddi3+0xec>
  800ec2:	29 e8                	sub    %ebp,%eax
  800ec4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800ec8:	89 d1                	mov    %edx,%ecx
  800eca:	89 c7                	mov    %eax,%edi
  800ecc:	89 f5                	mov    %esi,%ebp
  800ece:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ed2:	29 fd                	sub    %edi,%ebp
  800ed4:	19 cb                	sbb    %ecx,%ebx
  800ed6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800edb:	89 d8                	mov    %ebx,%eax
  800edd:	d3 e0                	shl    %cl,%eax
  800edf:	89 f1                	mov    %esi,%ecx
  800ee1:	d3 ed                	shr    %cl,%ebp
  800ee3:	d3 eb                	shr    %cl,%ebx
  800ee5:	09 e8                	or     %ebp,%eax
  800ee7:	89 da                	mov    %ebx,%edx
  800ee9:	83 c4 1c             	add    $0x1c,%esp
  800eec:	5b                   	pop    %ebx
  800eed:	5e                   	pop    %esi
  800eee:	5f                   	pop    %edi
  800eef:	5d                   	pop    %ebp
  800ef0:	c3                   	ret    
