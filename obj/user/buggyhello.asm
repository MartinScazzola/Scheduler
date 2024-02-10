
obj/user/buggyhello:     formato del fichero elf32-i386


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
  80002c:	e8 16 00 00 00       	call   800047 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs((char *) 1, 1);
  800039:	6a 01                	push   $0x1
  80003b:	6a 01                	push   $0x1
  80003d:	e8 ad 00 00 00       	call   8000ef <sys_cputs>
}
  800042:	83 c4 10             	add    $0x10,%esp
  800045:	c9                   	leave  
  800046:	c3                   	ret    

00800047 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800047:	55                   	push   %ebp
  800048:	89 e5                	mov    %esp,%ebp
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	envid_t id = sys_getenvid();
  800052:	e8 04 01 00 00       	call   80015b <sys_getenvid>
	if (id >= 0)
  800057:	85 c0                	test   %eax,%eax
  800059:	78 15                	js     800070 <libmain+0x29>
		thisenv = &envs[ENVX(id)];
  80005b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800060:	69 c0 88 00 00 00    	imul   $0x88,%eax,%eax
  800066:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006b:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800070:	85 db                	test   %ebx,%ebx
  800072:	7e 07                	jle    80007b <libmain+0x34>
		binaryname = argv[0];
  800074:	8b 06                	mov    (%esi),%eax
  800076:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	e8 ae ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800085:	e8 0a 00 00 00       	call   800094 <exit>
}
  80008a:	83 c4 10             	add    $0x10,%esp
  80008d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800090:	5b                   	pop    %ebx
  800091:	5e                   	pop    %esi
  800092:	5d                   	pop    %ebp
  800093:	c3                   	ret    

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80009a:	6a 00                	push   $0x0
  80009c:	e8 98 00 00 00       	call   800139 <sys_env_destroy>
}
  8000a1:	83 c4 10             	add    $0x10,%esp
  8000a4:	c9                   	leave  
  8000a5:	c3                   	ret    

008000a6 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000a6:	55                   	push   %ebp
  8000a7:	89 e5                	mov    %esp,%ebp
  8000a9:	57                   	push   %edi
  8000aa:	56                   	push   %esi
  8000ab:	53                   	push   %ebx
  8000ac:	83 ec 1c             	sub    $0x1c,%esp
  8000af:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8000b2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8000b5:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile(
  8000b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000bd:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000c0:	8b 75 14             	mov    0x14(%ebp),%esi
  8000c3:	cd 30                	int    $0x30
	        "int %1\n"
	        : "=a"(ret)
	        : "i"(T_SYSCALL), "a"(num), "d"(a1), "c"(a2), "b"(a3), "D"(a4), "S"(a5)
	        : "cc", "memory");

	if (check && ret > 0)
  8000c5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000c9:	74 04                	je     8000cf <syscall+0x29>
  8000cb:	85 c0                	test   %eax,%eax
  8000cd:	7f 08                	jg     8000d7 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  8000cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000d2:	5b                   	pop    %ebx
  8000d3:	5e                   	pop    %esi
  8000d4:	5f                   	pop    %edi
  8000d5:	5d                   	pop    %ebp
  8000d6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8000d7:	83 ec 0c             	sub    $0xc,%esp
  8000da:	50                   	push   %eax
  8000db:	ff 75 e0             	push   -0x20(%ebp)
  8000de:	68 8a 0e 80 00       	push   $0x800e8a
  8000e3:	6a 1e                	push   $0x1e
  8000e5:	68 a7 0e 80 00       	push   $0x800ea7
  8000ea:	e8 f7 01 00 00       	call   8002e6 <_panic>

008000ef <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  8000ef:	55                   	push   %ebp
  8000f0:	89 e5                	mov    %esp,%ebp
  8000f2:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t) s, len, 0, 0, 0);
  8000f5:	6a 00                	push   $0x0
  8000f7:	6a 00                	push   $0x0
  8000f9:	6a 00                	push   $0x0
  8000fb:	ff 75 0c             	push   0xc(%ebp)
  8000fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800101:	ba 00 00 00 00       	mov    $0x0,%edx
  800106:	b8 00 00 00 00       	mov    $0x0,%eax
  80010b:	e8 96 ff ff ff       	call   8000a6 <syscall>
}
  800110:	83 c4 10             	add    $0x10,%esp
  800113:	c9                   	leave  
  800114:	c3                   	ret    

00800115 <sys_cgetc>:

int
sys_cgetc(void)
{
  800115:	55                   	push   %ebp
  800116:	89 e5                	mov    %esp,%ebp
  800118:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  80011b:	6a 00                	push   $0x0
  80011d:	6a 00                	push   $0x0
  80011f:	6a 00                	push   $0x0
  800121:	6a 00                	push   $0x0
  800123:	b9 00 00 00 00       	mov    $0x0,%ecx
  800128:	ba 00 00 00 00       	mov    $0x0,%edx
  80012d:	b8 01 00 00 00       	mov    $0x1,%eax
  800132:	e8 6f ff ff ff       	call   8000a6 <syscall>
}
  800137:	c9                   	leave  
  800138:	c3                   	ret    

00800139 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800139:	55                   	push   %ebp
  80013a:	89 e5                	mov    %esp,%ebp
  80013c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80013f:	6a 00                	push   $0x0
  800141:	6a 00                	push   $0x0
  800143:	6a 00                	push   $0x0
  800145:	6a 00                	push   $0x0
  800147:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80014a:	ba 01 00 00 00       	mov    $0x1,%edx
  80014f:	b8 03 00 00 00       	mov    $0x3,%eax
  800154:	e8 4d ff ff ff       	call   8000a6 <syscall>
}
  800159:	c9                   	leave  
  80015a:	c3                   	ret    

0080015b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800161:	6a 00                	push   $0x0
  800163:	6a 00                	push   $0x0
  800165:	6a 00                	push   $0x0
  800167:	6a 00                	push   $0x0
  800169:	b9 00 00 00 00       	mov    $0x0,%ecx
  80016e:	ba 00 00 00 00       	mov    $0x0,%edx
  800173:	b8 02 00 00 00       	mov    $0x2,%eax
  800178:	e8 29 ff ff ff       	call   8000a6 <syscall>
}
  80017d:	c9                   	leave  
  80017e:	c3                   	ret    

0080017f <sys_yield>:

void
sys_yield(void)
{
  80017f:	55                   	push   %ebp
  800180:	89 e5                	mov    %esp,%ebp
  800182:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800185:	6a 00                	push   $0x0
  800187:	6a 00                	push   $0x0
  800189:	6a 00                	push   $0x0
  80018b:	6a 00                	push   $0x0
  80018d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800192:	ba 00 00 00 00       	mov    $0x0,%edx
  800197:	b8 0a 00 00 00       	mov    $0xa,%eax
  80019c:	e8 05 ff ff ff       	call   8000a6 <syscall>
}
  8001a1:	83 c4 10             	add    $0x10,%esp
  8001a4:	c9                   	leave  
  8001a5:	c3                   	ret    

008001a6 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8001ac:	6a 00                	push   $0x0
  8001ae:	6a 00                	push   $0x0
  8001b0:	ff 75 10             	push   0x10(%ebp)
  8001b3:	ff 75 0c             	push   0xc(%ebp)
  8001b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b9:	ba 01 00 00 00       	mov    $0x1,%edx
  8001be:	b8 04 00 00 00       	mov    $0x4,%eax
  8001c3:	e8 de fe ff ff       	call   8000a6 <syscall>
}
  8001c8:	c9                   	leave  
  8001c9:	c3                   	ret    

008001ca <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001ca:	55                   	push   %ebp
  8001cb:	89 e5                	mov    %esp,%ebp
  8001cd:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map,
  8001d0:	ff 75 18             	push   0x18(%ebp)
  8001d3:	ff 75 14             	push   0x14(%ebp)
  8001d6:	ff 75 10             	push   0x10(%ebp)
  8001d9:	ff 75 0c             	push   0xc(%ebp)
  8001dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001df:	ba 01 00 00 00       	mov    $0x1,%edx
  8001e4:	b8 05 00 00 00       	mov    $0x5,%eax
  8001e9:	e8 b8 fe ff ff       	call   8000a6 <syscall>
	               srcenv,
	               (uint32_t) srcva,
	               dstenv,
	               (uint32_t) dstva,
	               perm);
}
  8001ee:	c9                   	leave  
  8001ef:	c3                   	ret    

008001f0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001f0:	55                   	push   %ebp
  8001f1:	89 e5                	mov    %esp,%ebp
  8001f3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8001f6:	6a 00                	push   $0x0
  8001f8:	6a 00                	push   $0x0
  8001fa:	6a 00                	push   $0x0
  8001fc:	ff 75 0c             	push   0xc(%ebp)
  8001ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800202:	ba 01 00 00 00       	mov    $0x1,%edx
  800207:	b8 06 00 00 00       	mov    $0x6,%eax
  80020c:	e8 95 fe ff ff       	call   8000a6 <syscall>
}
  800211:	c9                   	leave  
  800212:	c3                   	ret    

00800213 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800213:	55                   	push   %ebp
  800214:	89 e5                	mov    %esp,%ebp
  800216:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800219:	6a 00                	push   $0x0
  80021b:	6a 00                	push   $0x0
  80021d:	6a 00                	push   $0x0
  80021f:	ff 75 0c             	push   0xc(%ebp)
  800222:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800225:	ba 01 00 00 00       	mov    $0x1,%edx
  80022a:	b8 08 00 00 00       	mov    $0x8,%eax
  80022f:	e8 72 fe ff ff       	call   8000a6 <syscall>
}
  800234:	c9                   	leave  
  800235:	c3                   	ret    

00800236 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
  800239:	83 ec 08             	sub    $0x8,%esp
	return syscall(
  80023c:	6a 00                	push   $0x0
  80023e:	6a 00                	push   $0x0
  800240:	6a 00                	push   $0x0
  800242:	ff 75 0c             	push   0xc(%ebp)
  800245:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800248:	ba 01 00 00 00       	mov    $0x1,%edx
  80024d:	b8 09 00 00 00       	mov    $0x9,%eax
  800252:	e8 4f fe ff ff       	call   8000a6 <syscall>
	        SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800257:	c9                   	leave  
  800258:	c3                   	ret    

00800259 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800259:	55                   	push   %ebp
  80025a:	89 e5                	mov    %esp,%ebp
  80025c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  80025f:	6a 00                	push   $0x0
  800261:	ff 75 14             	push   0x14(%ebp)
  800264:	ff 75 10             	push   0x10(%ebp)
  800267:	ff 75 0c             	push   0xc(%ebp)
  80026a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80026d:	ba 00 00 00 00       	mov    $0x0,%edx
  800272:	b8 0b 00 00 00       	mov    $0xb,%eax
  800277:	e8 2a fe ff ff       	call   8000a6 <syscall>
}
  80027c:	c9                   	leave  
  80027d:	c3                   	ret    

0080027e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80027e:	55                   	push   %ebp
  80027f:	89 e5                	mov    %esp,%ebp
  800281:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t) dstva, 0, 0, 0, 0);
  800284:	6a 00                	push   $0x0
  800286:	6a 00                	push   $0x0
  800288:	6a 00                	push   $0x0
  80028a:	6a 00                	push   $0x0
  80028c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80028f:	ba 01 00 00 00       	mov    $0x1,%edx
  800294:	b8 0c 00 00 00       	mov    $0xc,%eax
  800299:	e8 08 fe ff ff       	call   8000a6 <syscall>
}
  80029e:	c9                   	leave  
  80029f:	c3                   	ret    

008002a0 <sys_get_priority>:

// Get priority of the current process
int
sys_get_priority(void)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_get_priority, 0, 0, 0, 0, 0, 0);
  8002a6:	6a 00                	push   $0x0
  8002a8:	6a 00                	push   $0x0
  8002aa:	6a 00                	push   $0x0
  8002ac:	6a 00                	push   $0x0
  8002ae:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8002b8:	b8 0d 00 00 00       	mov    $0xd,%eax
  8002bd:	e8 e4 fd ff ff       	call   8000a6 <syscall>
}
  8002c2:	c9                   	leave  
  8002c3:	c3                   	ret    

008002c4 <sys_set_priority>:

// Get priority of the current process
int
sys_set_priority(unsigned int priority)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, (uint32_t) priority, 0, 0, 0, 0);
  8002ca:	6a 00                	push   $0x0
  8002cc:	6a 00                	push   $0x0
  8002ce:	6a 00                	push   $0x0
  8002d0:	6a 00                	push   $0x0
  8002d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8002da:	b8 0e 00 00 00       	mov    $0xe,%eax
  8002df:	e8 c2 fd ff ff       	call   8000a6 <syscall>
}
  8002e4:	c9                   	leave  
  8002e5:	c3                   	ret    

008002e6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002e6:	55                   	push   %ebp
  8002e7:	89 e5                	mov    %esp,%ebp
  8002e9:	56                   	push   %esi
  8002ea:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002eb:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002ee:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8002f4:	e8 62 fe ff ff       	call   80015b <sys_getenvid>
  8002f9:	83 ec 0c             	sub    $0xc,%esp
  8002fc:	ff 75 0c             	push   0xc(%ebp)
  8002ff:	ff 75 08             	push   0x8(%ebp)
  800302:	56                   	push   %esi
  800303:	50                   	push   %eax
  800304:	68 b8 0e 80 00       	push   $0x800eb8
  800309:	e8 b3 00 00 00       	call   8003c1 <cprintf>
	        sys_getenvid(),
	        binaryname,
	        file,
	        line);
	vcprintf(fmt, ap);
  80030e:	83 c4 18             	add    $0x18,%esp
  800311:	53                   	push   %ebx
  800312:	ff 75 10             	push   0x10(%ebp)
  800315:	e8 56 00 00 00       	call   800370 <vcprintf>
	cprintf("\n");
  80031a:	c7 04 24 db 0e 80 00 	movl   $0x800edb,(%esp)
  800321:	e8 9b 00 00 00       	call   8003c1 <cprintf>
  800326:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800329:	cc                   	int3   
  80032a:	eb fd                	jmp    800329 <_panic+0x43>

0080032c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80032c:	55                   	push   %ebp
  80032d:	89 e5                	mov    %esp,%ebp
  80032f:	53                   	push   %ebx
  800330:	83 ec 04             	sub    $0x4,%esp
  800333:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800336:	8b 13                	mov    (%ebx),%edx
  800338:	8d 42 01             	lea    0x1(%edx),%eax
  80033b:	89 03                	mov    %eax,(%ebx)
  80033d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800340:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256 - 1) {
  800344:	3d ff 00 00 00       	cmp    $0xff,%eax
  800349:	74 09                	je     800354 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80034b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80034f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800352:	c9                   	leave  
  800353:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800354:	83 ec 08             	sub    $0x8,%esp
  800357:	68 ff 00 00 00       	push   $0xff
  80035c:	8d 43 08             	lea    0x8(%ebx),%eax
  80035f:	50                   	push   %eax
  800360:	e8 8a fd ff ff       	call   8000ef <sys_cputs>
		b->idx = 0;
  800365:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80036b:	83 c4 10             	add    $0x10,%esp
  80036e:	eb db                	jmp    80034b <putch+0x1f>

00800370 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800370:	55                   	push   %ebp
  800371:	89 e5                	mov    %esp,%ebp
  800373:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800379:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800380:	00 00 00 
	b.cnt = 0;
  800383:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80038a:	00 00 00 
	vprintfmt((void *) putch, &b, fmt, ap);
  80038d:	ff 75 0c             	push   0xc(%ebp)
  800390:	ff 75 08             	push   0x8(%ebp)
  800393:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800399:	50                   	push   %eax
  80039a:	68 2c 03 80 00       	push   $0x80032c
  80039f:	e8 74 01 00 00       	call   800518 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003a4:	83 c4 08             	add    $0x8,%esp
  8003a7:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8003ad:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003b3:	50                   	push   %eax
  8003b4:	e8 36 fd ff ff       	call   8000ef <sys_cputs>

	return b.cnt;
}
  8003b9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003bf:	c9                   	leave  
  8003c0:	c3                   	ret    

008003c1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003c1:	55                   	push   %ebp
  8003c2:	89 e5                	mov    %esp,%ebp
  8003c4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003c7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003ca:	50                   	push   %eax
  8003cb:	ff 75 08             	push   0x8(%ebp)
  8003ce:	e8 9d ff ff ff       	call   800370 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003d3:	c9                   	leave  
  8003d4:	c3                   	ret    

008003d5 <printnum>:
         void *putdat,
         unsigned long long num,
         unsigned base,
         int width,
         int padc)
{
  8003d5:	55                   	push   %ebp
  8003d6:	89 e5                	mov    %esp,%ebp
  8003d8:	57                   	push   %edi
  8003d9:	56                   	push   %esi
  8003da:	53                   	push   %ebx
  8003db:	83 ec 1c             	sub    $0x1c,%esp
  8003de:	89 c7                	mov    %eax,%edi
  8003e0:	89 d6                	mov    %edx,%esi
  8003e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003e8:	89 d1                	mov    %edx,%ecx
  8003ea:	89 c2                	mov    %eax,%edx
  8003ec:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003ef:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8003f2:	8b 45 10             	mov    0x10(%ebp),%eax
  8003f5:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003f8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003fb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800402:	39 c2                	cmp    %eax,%edx
  800404:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800407:	72 3e                	jb     800447 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800409:	83 ec 0c             	sub    $0xc,%esp
  80040c:	ff 75 18             	push   0x18(%ebp)
  80040f:	83 eb 01             	sub    $0x1,%ebx
  800412:	53                   	push   %ebx
  800413:	50                   	push   %eax
  800414:	83 ec 08             	sub    $0x8,%esp
  800417:	ff 75 e4             	push   -0x1c(%ebp)
  80041a:	ff 75 e0             	push   -0x20(%ebp)
  80041d:	ff 75 dc             	push   -0x24(%ebp)
  800420:	ff 75 d8             	push   -0x28(%ebp)
  800423:	e8 18 08 00 00       	call   800c40 <__udivdi3>
  800428:	83 c4 18             	add    $0x18,%esp
  80042b:	52                   	push   %edx
  80042c:	50                   	push   %eax
  80042d:	89 f2                	mov    %esi,%edx
  80042f:	89 f8                	mov    %edi,%eax
  800431:	e8 9f ff ff ff       	call   8003d5 <printnum>
  800436:	83 c4 20             	add    $0x20,%esp
  800439:	eb 13                	jmp    80044e <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80043b:	83 ec 08             	sub    $0x8,%esp
  80043e:	56                   	push   %esi
  80043f:	ff 75 18             	push   0x18(%ebp)
  800442:	ff d7                	call   *%edi
  800444:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800447:	83 eb 01             	sub    $0x1,%ebx
  80044a:	85 db                	test   %ebx,%ebx
  80044c:	7f ed                	jg     80043b <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80044e:	83 ec 08             	sub    $0x8,%esp
  800451:	56                   	push   %esi
  800452:	83 ec 04             	sub    $0x4,%esp
  800455:	ff 75 e4             	push   -0x1c(%ebp)
  800458:	ff 75 e0             	push   -0x20(%ebp)
  80045b:	ff 75 dc             	push   -0x24(%ebp)
  80045e:	ff 75 d8             	push   -0x28(%ebp)
  800461:	e8 fa 08 00 00       	call   800d60 <__umoddi3>
  800466:	83 c4 14             	add    $0x14,%esp
  800469:	0f be 80 dd 0e 80 00 	movsbl 0x800edd(%eax),%eax
  800470:	50                   	push   %eax
  800471:	ff d7                	call   *%edi
}
  800473:	83 c4 10             	add    $0x10,%esp
  800476:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800479:	5b                   	pop    %ebx
  80047a:	5e                   	pop    %esi
  80047b:	5f                   	pop    %edi
  80047c:	5d                   	pop    %ebp
  80047d:	c3                   	ret    

0080047e <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80047e:	83 fa 01             	cmp    $0x1,%edx
  800481:	7f 13                	jg     800496 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800483:	85 d2                	test   %edx,%edx
  800485:	74 1c                	je     8004a3 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  800487:	8b 10                	mov    (%eax),%edx
  800489:	8d 4a 04             	lea    0x4(%edx),%ecx
  80048c:	89 08                	mov    %ecx,(%eax)
  80048e:	8b 02                	mov    (%edx),%eax
  800490:	ba 00 00 00 00       	mov    $0x0,%edx
  800495:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  800496:	8b 10                	mov    (%eax),%edx
  800498:	8d 4a 08             	lea    0x8(%edx),%ecx
  80049b:	89 08                	mov    %ecx,(%eax)
  80049d:	8b 02                	mov    (%edx),%eax
  80049f:	8b 52 04             	mov    0x4(%edx),%edx
  8004a2:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  8004a3:	8b 10                	mov    (%eax),%edx
  8004a5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004a8:	89 08                	mov    %ecx,(%eax)
  8004aa:	8b 02                	mov    (%edx),%eax
  8004ac:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004b1:	c3                   	ret    

008004b2 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004b2:	83 fa 01             	cmp    $0x1,%edx
  8004b5:	7f 0f                	jg     8004c6 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  8004b7:	85 d2                	test   %edx,%edx
  8004b9:	74 18                	je     8004d3 <getint+0x21>
		return va_arg(*ap, long);
  8004bb:	8b 10                	mov    (%eax),%edx
  8004bd:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004c0:	89 08                	mov    %ecx,(%eax)
  8004c2:	8b 02                	mov    (%edx),%eax
  8004c4:	99                   	cltd   
  8004c5:	c3                   	ret    
		return va_arg(*ap, long long);
  8004c6:	8b 10                	mov    (%eax),%edx
  8004c8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004cb:	89 08                	mov    %ecx,(%eax)
  8004cd:	8b 02                	mov    (%edx),%eax
  8004cf:	8b 52 04             	mov    0x4(%edx),%edx
  8004d2:	c3                   	ret    
	else
		return va_arg(*ap, int);
  8004d3:	8b 10                	mov    (%eax),%edx
  8004d5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004d8:	89 08                	mov    %ecx,(%eax)
  8004da:	8b 02                	mov    (%edx),%eax
  8004dc:	99                   	cltd   
}
  8004dd:	c3                   	ret    

008004de <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004de:	55                   	push   %ebp
  8004df:	89 e5                	mov    %esp,%ebp
  8004e1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004e4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004e8:	8b 10                	mov    (%eax),%edx
  8004ea:	3b 50 04             	cmp    0x4(%eax),%edx
  8004ed:	73 0a                	jae    8004f9 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004ef:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004f2:	89 08                	mov    %ecx,(%eax)
  8004f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f7:	88 02                	mov    %al,(%edx)
}
  8004f9:	5d                   	pop    %ebp
  8004fa:	c3                   	ret    

008004fb <printfmt>:
{
  8004fb:	55                   	push   %ebp
  8004fc:	89 e5                	mov    %esp,%ebp
  8004fe:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800501:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800504:	50                   	push   %eax
  800505:	ff 75 10             	push   0x10(%ebp)
  800508:	ff 75 0c             	push   0xc(%ebp)
  80050b:	ff 75 08             	push   0x8(%ebp)
  80050e:	e8 05 00 00 00       	call   800518 <vprintfmt>
}
  800513:	83 c4 10             	add    $0x10,%esp
  800516:	c9                   	leave  
  800517:	c3                   	ret    

00800518 <vprintfmt>:
{
  800518:	55                   	push   %ebp
  800519:	89 e5                	mov    %esp,%ebp
  80051b:	57                   	push   %edi
  80051c:	56                   	push   %esi
  80051d:	53                   	push   %ebx
  80051e:	83 ec 2c             	sub    $0x2c,%esp
  800521:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800524:	8b 75 0c             	mov    0xc(%ebp),%esi
  800527:	8b 7d 10             	mov    0x10(%ebp),%edi
  80052a:	eb 0a                	jmp    800536 <vprintfmt+0x1e>
			putch(ch, putdat);
  80052c:	83 ec 08             	sub    $0x8,%esp
  80052f:	56                   	push   %esi
  800530:	50                   	push   %eax
  800531:	ff d3                	call   *%ebx
  800533:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800536:	83 c7 01             	add    $0x1,%edi
  800539:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80053d:	83 f8 25             	cmp    $0x25,%eax
  800540:	74 0c                	je     80054e <vprintfmt+0x36>
			if (ch == '\0')
  800542:	85 c0                	test   %eax,%eax
  800544:	75 e6                	jne    80052c <vprintfmt+0x14>
}
  800546:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800549:	5b                   	pop    %ebx
  80054a:	5e                   	pop    %esi
  80054b:	5f                   	pop    %edi
  80054c:	5d                   	pop    %ebp
  80054d:	c3                   	ret    
		padc = ' ';
  80054e:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
		altflag = 0;
  800552:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800559:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800560:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800567:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80056c:	8d 47 01             	lea    0x1(%edi),%eax
  80056f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800572:	0f b6 17             	movzbl (%edi),%edx
  800575:	8d 42 dd             	lea    -0x23(%edx),%eax
  800578:	3c 55                	cmp    $0x55,%al
  80057a:	0f 87 b7 02 00 00    	ja     800837 <vprintfmt+0x31f>
  800580:	0f b6 c0             	movzbl %al,%eax
  800583:	ff 24 85 a0 0f 80 00 	jmp    *0x800fa0(,%eax,4)
  80058a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80058d:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800591:	eb d9                	jmp    80056c <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800593:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800596:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  80059a:	eb d0                	jmp    80056c <vprintfmt+0x54>
  80059c:	0f b6 d2             	movzbl %dl,%edx
  80059f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0;; ++fmt) {
  8005a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a7:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8005aa:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005ad:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8005b1:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8005b4:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8005b7:	83 f9 09             	cmp    $0x9,%ecx
  8005ba:	77 52                	ja     80060e <vprintfmt+0xf6>
			for (precision = 0;; ++fmt) {
  8005bc:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8005bf:	eb e9                	jmp    8005aa <vprintfmt+0x92>
			precision = va_arg(ap, int);
  8005c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c4:	8d 50 04             	lea    0x4(%eax),%edx
  8005c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ca:	8b 00                	mov    (%eax),%eax
  8005cc:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8005d2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005d6:	79 94                	jns    80056c <vprintfmt+0x54>
				width = precision, precision = -1;
  8005d8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005db:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005de:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8005e5:	eb 85                	jmp    80056c <vprintfmt+0x54>
  8005e7:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005ea:	85 d2                	test   %edx,%edx
  8005ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8005f1:	0f 49 c2             	cmovns %edx,%eax
  8005f4:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005fa:	e9 6d ff ff ff       	jmp    80056c <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8005ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800602:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800609:	e9 5e ff ff ff       	jmp    80056c <vprintfmt+0x54>
  80060e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800611:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800614:	eb bc                	jmp    8005d2 <vprintfmt+0xba>
			lflag++;
  800616:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800619:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80061c:	e9 4b ff ff ff       	jmp    80056c <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800621:	8b 45 14             	mov    0x14(%ebp),%eax
  800624:	8d 50 04             	lea    0x4(%eax),%edx
  800627:	89 55 14             	mov    %edx,0x14(%ebp)
  80062a:	83 ec 08             	sub    $0x8,%esp
  80062d:	56                   	push   %esi
  80062e:	ff 30                	push   (%eax)
  800630:	ff d3                	call   *%ebx
			break;
  800632:	83 c4 10             	add    $0x10,%esp
  800635:	e9 94 01 00 00       	jmp    8007ce <vprintfmt+0x2b6>
			err = va_arg(ap, int);
  80063a:	8b 45 14             	mov    0x14(%ebp),%eax
  80063d:	8d 50 04             	lea    0x4(%eax),%edx
  800640:	89 55 14             	mov    %edx,0x14(%ebp)
  800643:	8b 10                	mov    (%eax),%edx
  800645:	89 d0                	mov    %edx,%eax
  800647:	f7 d8                	neg    %eax
  800649:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80064c:	83 f8 08             	cmp    $0x8,%eax
  80064f:	7f 20                	jg     800671 <vprintfmt+0x159>
  800651:	8b 14 85 00 11 80 00 	mov    0x801100(,%eax,4),%edx
  800658:	85 d2                	test   %edx,%edx
  80065a:	74 15                	je     800671 <vprintfmt+0x159>
				printfmt(putch, putdat, "%s", p);
  80065c:	52                   	push   %edx
  80065d:	68 fe 0e 80 00       	push   $0x800efe
  800662:	56                   	push   %esi
  800663:	53                   	push   %ebx
  800664:	e8 92 fe ff ff       	call   8004fb <printfmt>
  800669:	83 c4 10             	add    $0x10,%esp
  80066c:	e9 5d 01 00 00       	jmp    8007ce <vprintfmt+0x2b6>
				printfmt(putch, putdat, "error %d", err);
  800671:	50                   	push   %eax
  800672:	68 f5 0e 80 00       	push   $0x800ef5
  800677:	56                   	push   %esi
  800678:	53                   	push   %ebx
  800679:	e8 7d fe ff ff       	call   8004fb <printfmt>
  80067e:	83 c4 10             	add    $0x10,%esp
  800681:	e9 48 01 00 00       	jmp    8007ce <vprintfmt+0x2b6>
			if ((p = va_arg(ap, char *)) == NULL)
  800686:	8b 45 14             	mov    0x14(%ebp),%eax
  800689:	8d 50 04             	lea    0x4(%eax),%edx
  80068c:	89 55 14             	mov    %edx,0x14(%ebp)
  80068f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800691:	85 ff                	test   %edi,%edi
  800693:	b8 ee 0e 80 00       	mov    $0x800eee,%eax
  800698:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80069b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80069f:	7e 06                	jle    8006a7 <vprintfmt+0x18f>
  8006a1:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8006a5:	75 0a                	jne    8006b1 <vprintfmt+0x199>
  8006a7:	89 f8                	mov    %edi,%eax
  8006a9:	03 45 e0             	add    -0x20(%ebp),%eax
  8006ac:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006af:	eb 59                	jmp    80070a <vprintfmt+0x1f2>
				for (width -= strnlen(p, precision); width > 0;
  8006b1:	83 ec 08             	sub    $0x8,%esp
  8006b4:	ff 75 d8             	push   -0x28(%ebp)
  8006b7:	57                   	push   %edi
  8006b8:	e8 1a 02 00 00       	call   8008d7 <strnlen>
  8006bd:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006c0:	29 c1                	sub    %eax,%ecx
  8006c2:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006c5:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006c8:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  8006cc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006cf:	89 7d d0             	mov    %edi,-0x30(%ebp)
  8006d2:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0;
  8006d4:	eb 0f                	jmp    8006e5 <vprintfmt+0x1cd>
					putch(padc, putdat);
  8006d6:	83 ec 08             	sub    $0x8,%esp
  8006d9:	56                   	push   %esi
  8006da:	ff 75 e0             	push   -0x20(%ebp)
  8006dd:	ff d3                	call   *%ebx
				     width--)
  8006df:	83 ef 01             	sub    $0x1,%edi
  8006e2:	83 c4 10             	add    $0x10,%esp
				for (width -= strnlen(p, precision); width > 0;
  8006e5:	85 ff                	test   %edi,%edi
  8006e7:	7f ed                	jg     8006d6 <vprintfmt+0x1be>
  8006e9:	8b 7d d0             	mov    -0x30(%ebp),%edi
  8006ec:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006ef:	85 c9                	test   %ecx,%ecx
  8006f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f6:	0f 49 c1             	cmovns %ecx,%eax
  8006f9:	29 c1                	sub    %eax,%ecx
  8006fb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8006fe:	eb a7                	jmp    8006a7 <vprintfmt+0x18f>
					putch(ch, putdat);
  800700:	83 ec 08             	sub    $0x8,%esp
  800703:	56                   	push   %esi
  800704:	52                   	push   %edx
  800705:	ff d3                	call   *%ebx
  800707:	83 c4 10             	add    $0x10,%esp
  80070a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80070d:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' &&
  80070f:	83 c7 01             	add    $0x1,%edi
  800712:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800716:	0f be d0             	movsbl %al,%edx
  800719:	85 d2                	test   %edx,%edx
  80071b:	74 42                	je     80075f <vprintfmt+0x247>
  80071d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800721:	78 06                	js     800729 <vprintfmt+0x211>
			       (precision < 0 || --precision >= 0);
  800723:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800727:	78 1e                	js     800747 <vprintfmt+0x22f>
				if (altflag && (ch < ' ' || ch > '~'))
  800729:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80072d:	74 d1                	je     800700 <vprintfmt+0x1e8>
  80072f:	0f be c0             	movsbl %al,%eax
  800732:	83 e8 20             	sub    $0x20,%eax
  800735:	83 f8 5e             	cmp    $0x5e,%eax
  800738:	76 c6                	jbe    800700 <vprintfmt+0x1e8>
					putch('?', putdat);
  80073a:	83 ec 08             	sub    $0x8,%esp
  80073d:	56                   	push   %esi
  80073e:	6a 3f                	push   $0x3f
  800740:	ff d3                	call   *%ebx
  800742:	83 c4 10             	add    $0x10,%esp
  800745:	eb c3                	jmp    80070a <vprintfmt+0x1f2>
  800747:	89 cf                	mov    %ecx,%edi
  800749:	eb 0e                	jmp    800759 <vprintfmt+0x241>
				putch(' ', putdat);
  80074b:	83 ec 08             	sub    $0x8,%esp
  80074e:	56                   	push   %esi
  80074f:	6a 20                	push   $0x20
  800751:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  800753:	83 ef 01             	sub    $0x1,%edi
  800756:	83 c4 10             	add    $0x10,%esp
  800759:	85 ff                	test   %edi,%edi
  80075b:	7f ee                	jg     80074b <vprintfmt+0x233>
  80075d:	eb 6f                	jmp    8007ce <vprintfmt+0x2b6>
  80075f:	89 cf                	mov    %ecx,%edi
  800761:	eb f6                	jmp    800759 <vprintfmt+0x241>
			num = getint(&ap, lflag);
  800763:	89 ca                	mov    %ecx,%edx
  800765:	8d 45 14             	lea    0x14(%ebp),%eax
  800768:	e8 45 fd ff ff       	call   8004b2 <getint>
  80076d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800770:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800773:	85 d2                	test   %edx,%edx
  800775:	78 0b                	js     800782 <vprintfmt+0x26a>
			num = getint(&ap, lflag);
  800777:	89 d1                	mov    %edx,%ecx
  800779:	89 c2                	mov    %eax,%edx
			base = 10;
  80077b:	bf 0a 00 00 00       	mov    $0xa,%edi
  800780:	eb 32                	jmp    8007b4 <vprintfmt+0x29c>
				putch('-', putdat);
  800782:	83 ec 08             	sub    $0x8,%esp
  800785:	56                   	push   %esi
  800786:	6a 2d                	push   $0x2d
  800788:	ff d3                	call   *%ebx
				num = -(long long) num;
  80078a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80078d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800790:	f7 da                	neg    %edx
  800792:	83 d1 00             	adc    $0x0,%ecx
  800795:	f7 d9                	neg    %ecx
  800797:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80079a:	bf 0a 00 00 00       	mov    $0xa,%edi
  80079f:	eb 13                	jmp    8007b4 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  8007a1:	89 ca                	mov    %ecx,%edx
  8007a3:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a6:	e8 d3 fc ff ff       	call   80047e <getuint>
  8007ab:	89 d1                	mov    %edx,%ecx
  8007ad:	89 c2                	mov    %eax,%edx
			base = 10;
  8007af:	bf 0a 00 00 00       	mov    $0xa,%edi
			printnum(putch, putdat, num, base, width, padc);
  8007b4:	83 ec 0c             	sub    $0xc,%esp
  8007b7:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  8007bb:	50                   	push   %eax
  8007bc:	ff 75 e0             	push   -0x20(%ebp)
  8007bf:	57                   	push   %edi
  8007c0:	51                   	push   %ecx
  8007c1:	52                   	push   %edx
  8007c2:	89 f2                	mov    %esi,%edx
  8007c4:	89 d8                	mov    %ebx,%eax
  8007c6:	e8 0a fc ff ff       	call   8003d5 <printnum>
			break;
  8007cb:	83 c4 20             	add    $0x20,%esp
{
  8007ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007d1:	e9 60 fd ff ff       	jmp    800536 <vprintfmt+0x1e>
			num = getuint(&ap, lflag);
  8007d6:	89 ca                	mov    %ecx,%edx
  8007d8:	8d 45 14             	lea    0x14(%ebp),%eax
  8007db:	e8 9e fc ff ff       	call   80047e <getuint>
  8007e0:	89 d1                	mov    %edx,%ecx
  8007e2:	89 c2                	mov    %eax,%edx
			base = 8;
  8007e4:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  8007e9:	eb c9                	jmp    8007b4 <vprintfmt+0x29c>
			putch('0', putdat);
  8007eb:	83 ec 08             	sub    $0x8,%esp
  8007ee:	56                   	push   %esi
  8007ef:	6a 30                	push   $0x30
  8007f1:	ff d3                	call   *%ebx
			putch('x', putdat);
  8007f3:	83 c4 08             	add    $0x8,%esp
  8007f6:	56                   	push   %esi
  8007f7:	6a 78                	push   $0x78
  8007f9:	ff d3                	call   *%ebx
			num = (unsigned long long) (uintptr_t) va_arg(ap, void *);
  8007fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fe:	8d 50 04             	lea    0x4(%eax),%edx
  800801:	89 55 14             	mov    %edx,0x14(%ebp)
  800804:	8b 10                	mov    (%eax),%edx
  800806:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80080b:	83 c4 10             	add    $0x10,%esp
			base = 16;
  80080e:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  800813:	eb 9f                	jmp    8007b4 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  800815:	89 ca                	mov    %ecx,%edx
  800817:	8d 45 14             	lea    0x14(%ebp),%eax
  80081a:	e8 5f fc ff ff       	call   80047e <getuint>
  80081f:	89 d1                	mov    %edx,%ecx
  800821:	89 c2                	mov    %eax,%edx
			base = 16;
  800823:	bf 10 00 00 00       	mov    $0x10,%edi
  800828:	eb 8a                	jmp    8007b4 <vprintfmt+0x29c>
			putch(ch, putdat);
  80082a:	83 ec 08             	sub    $0x8,%esp
  80082d:	56                   	push   %esi
  80082e:	6a 25                	push   $0x25
  800830:	ff d3                	call   *%ebx
			break;
  800832:	83 c4 10             	add    $0x10,%esp
  800835:	eb 97                	jmp    8007ce <vprintfmt+0x2b6>
			putch('%', putdat);
  800837:	83 ec 08             	sub    $0x8,%esp
  80083a:	56                   	push   %esi
  80083b:	6a 25                	push   $0x25
  80083d:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  80083f:	83 c4 10             	add    $0x10,%esp
  800842:	89 f8                	mov    %edi,%eax
  800844:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800848:	74 05                	je     80084f <vprintfmt+0x337>
  80084a:	83 e8 01             	sub    $0x1,%eax
  80084d:	eb f5                	jmp    800844 <vprintfmt+0x32c>
  80084f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800852:	e9 77 ff ff ff       	jmp    8007ce <vprintfmt+0x2b6>

00800857 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	83 ec 18             	sub    $0x18,%esp
  80085d:	8b 45 08             	mov    0x8(%ebp),%eax
  800860:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = { buf, buf + n - 1, 0 };
  800863:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800866:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80086a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80086d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800874:	85 c0                	test   %eax,%eax
  800876:	74 26                	je     80089e <vsnprintf+0x47>
  800878:	85 d2                	test   %edx,%edx
  80087a:	7e 22                	jle    80089e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *) sprintputch, &b, fmt, ap);
  80087c:	ff 75 14             	push   0x14(%ebp)
  80087f:	ff 75 10             	push   0x10(%ebp)
  800882:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800885:	50                   	push   %eax
  800886:	68 de 04 80 00       	push   $0x8004de
  80088b:	e8 88 fc ff ff       	call   800518 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800890:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800893:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800896:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800899:	83 c4 10             	add    $0x10,%esp
}
  80089c:	c9                   	leave  
  80089d:	c3                   	ret    
		return -E_INVAL;
  80089e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008a3:	eb f7                	jmp    80089c <vsnprintf+0x45>

008008a5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008a5:	55                   	push   %ebp
  8008a6:	89 e5                	mov    %esp,%ebp
  8008a8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008ab:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008ae:	50                   	push   %eax
  8008af:	ff 75 10             	push   0x10(%ebp)
  8008b2:	ff 75 0c             	push   0xc(%ebp)
  8008b5:	ff 75 08             	push   0x8(%ebp)
  8008b8:	e8 9a ff ff ff       	call   800857 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008bd:	c9                   	leave  
  8008be:	c3                   	ret    

008008bf <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008bf:	55                   	push   %ebp
  8008c0:	89 e5                	mov    %esp,%ebp
  8008c2:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ca:	eb 03                	jmp    8008cf <strlen+0x10>
		n++;
  8008cc:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008cf:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008d3:	75 f7                	jne    8008cc <strlen+0xd>
	return n;
}
  8008d5:	5d                   	pop    %ebp
  8008d6:	c3                   	ret    

008008d7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008dd:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e5:	eb 03                	jmp    8008ea <strnlen+0x13>
		n++;
  8008e7:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008ea:	39 d0                	cmp    %edx,%eax
  8008ec:	74 08                	je     8008f6 <strnlen+0x1f>
  8008ee:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008f2:	75 f3                	jne    8008e7 <strnlen+0x10>
  8008f4:	89 c2                	mov    %eax,%edx
	return n;
}
  8008f6:	89 d0                	mov    %edx,%eax
  8008f8:	5d                   	pop    %ebp
  8008f9:	c3                   	ret    

008008fa <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	53                   	push   %ebx
  8008fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800901:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800904:	b8 00 00 00 00       	mov    $0x0,%eax
  800909:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80090d:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800910:	83 c0 01             	add    $0x1,%eax
  800913:	84 d2                	test   %dl,%dl
  800915:	75 f2                	jne    800909 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800917:	89 c8                	mov    %ecx,%eax
  800919:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80091c:	c9                   	leave  
  80091d:	c3                   	ret    

0080091e <strcat>:

char *
strcat(char *dst, const char *src)
{
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
  800921:	53                   	push   %ebx
  800922:	83 ec 10             	sub    $0x10,%esp
  800925:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800928:	53                   	push   %ebx
  800929:	e8 91 ff ff ff       	call   8008bf <strlen>
  80092e:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800931:	ff 75 0c             	push   0xc(%ebp)
  800934:	01 d8                	add    %ebx,%eax
  800936:	50                   	push   %eax
  800937:	e8 be ff ff ff       	call   8008fa <strcpy>
	return dst;
}
  80093c:	89 d8                	mov    %ebx,%eax
  80093e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800941:	c9                   	leave  
  800942:	c3                   	ret    

00800943 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size)
{
  800943:	55                   	push   %ebp
  800944:	89 e5                	mov    %esp,%ebp
  800946:	56                   	push   %esi
  800947:	53                   	push   %ebx
  800948:	8b 75 08             	mov    0x8(%ebp),%esi
  80094b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80094e:	89 f3                	mov    %esi,%ebx
  800950:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800953:	89 f0                	mov    %esi,%eax
  800955:	eb 0f                	jmp    800966 <strncpy+0x23>
		*dst++ = *src;
  800957:	83 c0 01             	add    $0x1,%eax
  80095a:	0f b6 0a             	movzbl (%edx),%ecx
  80095d:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800960:	80 f9 01             	cmp    $0x1,%cl
  800963:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800966:	39 d8                	cmp    %ebx,%eax
  800968:	75 ed                	jne    800957 <strncpy+0x14>
	}
	return ret;
}
  80096a:	89 f0                	mov    %esi,%eax
  80096c:	5b                   	pop    %ebx
  80096d:	5e                   	pop    %esi
  80096e:	5d                   	pop    %ebp
  80096f:	c3                   	ret    

00800970 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	56                   	push   %esi
  800974:	53                   	push   %ebx
  800975:	8b 75 08             	mov    0x8(%ebp),%esi
  800978:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80097b:	8b 55 10             	mov    0x10(%ebp),%edx
  80097e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800980:	85 d2                	test   %edx,%edx
  800982:	74 21                	je     8009a5 <strlcpy+0x35>
  800984:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800988:	89 f2                	mov    %esi,%edx
  80098a:	eb 09                	jmp    800995 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80098c:	83 c1 01             	add    $0x1,%ecx
  80098f:	83 c2 01             	add    $0x1,%edx
  800992:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800995:	39 c2                	cmp    %eax,%edx
  800997:	74 09                	je     8009a2 <strlcpy+0x32>
  800999:	0f b6 19             	movzbl (%ecx),%ebx
  80099c:	84 db                	test   %bl,%bl
  80099e:	75 ec                	jne    80098c <strlcpy+0x1c>
  8009a0:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8009a2:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009a5:	29 f0                	sub    %esi,%eax
}
  8009a7:	5b                   	pop    %ebx
  8009a8:	5e                   	pop    %esi
  8009a9:	5d                   	pop    %ebp
  8009aa:	c3                   	ret    

008009ab <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009b1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009b4:	eb 06                	jmp    8009bc <strcmp+0x11>
		p++, q++;
  8009b6:	83 c1 01             	add    $0x1,%ecx
  8009b9:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8009bc:	0f b6 01             	movzbl (%ecx),%eax
  8009bf:	84 c0                	test   %al,%al
  8009c1:	74 04                	je     8009c7 <strcmp+0x1c>
  8009c3:	3a 02                	cmp    (%edx),%al
  8009c5:	74 ef                	je     8009b6 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009c7:	0f b6 c0             	movzbl %al,%eax
  8009ca:	0f b6 12             	movzbl (%edx),%edx
  8009cd:	29 d0                	sub    %edx,%eax
}
  8009cf:	5d                   	pop    %ebp
  8009d0:	c3                   	ret    

008009d1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009d1:	55                   	push   %ebp
  8009d2:	89 e5                	mov    %esp,%ebp
  8009d4:	53                   	push   %ebx
  8009d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009db:	89 c3                	mov    %eax,%ebx
  8009dd:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009e0:	eb 06                	jmp    8009e8 <strncmp+0x17>
		n--, p++, q++;
  8009e2:	83 c0 01             	add    $0x1,%eax
  8009e5:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009e8:	39 d8                	cmp    %ebx,%eax
  8009ea:	74 18                	je     800a04 <strncmp+0x33>
  8009ec:	0f b6 08             	movzbl (%eax),%ecx
  8009ef:	84 c9                	test   %cl,%cl
  8009f1:	74 04                	je     8009f7 <strncmp+0x26>
  8009f3:	3a 0a                	cmp    (%edx),%cl
  8009f5:	74 eb                	je     8009e2 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009f7:	0f b6 00             	movzbl (%eax),%eax
  8009fa:	0f b6 12             	movzbl (%edx),%edx
  8009fd:	29 d0                	sub    %edx,%eax
}
  8009ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a02:	c9                   	leave  
  800a03:	c3                   	ret    
		return 0;
  800a04:	b8 00 00 00 00       	mov    $0x0,%eax
  800a09:	eb f4                	jmp    8009ff <strncmp+0x2e>

00800a0b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
  800a0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a11:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a15:	eb 03                	jmp    800a1a <strchr+0xf>
  800a17:	83 c0 01             	add    $0x1,%eax
  800a1a:	0f b6 10             	movzbl (%eax),%edx
  800a1d:	84 d2                	test   %dl,%dl
  800a1f:	74 06                	je     800a27 <strchr+0x1c>
		if (*s == c)
  800a21:	38 ca                	cmp    %cl,%dl
  800a23:	75 f2                	jne    800a17 <strchr+0xc>
  800a25:	eb 05                	jmp    800a2c <strchr+0x21>
			return (char *) s;
	return 0;
  800a27:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a2c:	5d                   	pop    %ebp
  800a2d:	c3                   	ret    

00800a2e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a2e:	55                   	push   %ebp
  800a2f:	89 e5                	mov    %esp,%ebp
  800a31:	8b 45 08             	mov    0x8(%ebp),%eax
  800a34:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a38:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a3b:	38 ca                	cmp    %cl,%dl
  800a3d:	74 09                	je     800a48 <strfind+0x1a>
  800a3f:	84 d2                	test   %dl,%dl
  800a41:	74 05                	je     800a48 <strfind+0x1a>
	for (; *s; s++)
  800a43:	83 c0 01             	add    $0x1,%eax
  800a46:	eb f0                	jmp    800a38 <strfind+0xa>
			break;
	return (char *) s;
}
  800a48:	5d                   	pop    %ebp
  800a49:	c3                   	ret    

00800a4a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a4a:	55                   	push   %ebp
  800a4b:	89 e5                	mov    %esp,%ebp
  800a4d:	57                   	push   %edi
  800a4e:	56                   	push   %esi
  800a4f:	53                   	push   %ebx
  800a50:	8b 55 08             	mov    0x8(%ebp),%edx
  800a53:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  800a56:	85 c9                	test   %ecx,%ecx
  800a58:	74 33                	je     800a8d <memset+0x43>
		return v;
	if ((int) v % 4 == 0 && n % 4 == 0) {
  800a5a:	89 d0                	mov    %edx,%eax
  800a5c:	09 c8                	or     %ecx,%eax
  800a5e:	a8 03                	test   $0x3,%al
  800a60:	75 23                	jne    800a85 <memset+0x3b>
		c &= 0xFF;
  800a62:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  800a66:	89 d8                	mov    %ebx,%eax
  800a68:	c1 e0 08             	shl    $0x8,%eax
  800a6b:	89 df                	mov    %ebx,%edi
  800a6d:	c1 e7 18             	shl    $0x18,%edi
  800a70:	89 de                	mov    %ebx,%esi
  800a72:	c1 e6 10             	shl    $0x10,%esi
  800a75:	09 f7                	or     %esi,%edi
  800a77:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
		             : "=D"(p), "=c"(n)
		             : "D"(p), "a"(c), "c"(n / 4)
  800a79:	c1 e9 02             	shr    $0x2,%ecx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  800a7c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800a7e:	89 d7                	mov    %edx,%edi
  800a80:	fc                   	cld    
  800a81:	f3 ab                	rep stos %eax,%es:(%edi)
  800a83:	eb 08                	jmp    800a8d <memset+0x43>
		             : "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a85:	89 d7                	mov    %edx,%edi
  800a87:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a8a:	fc                   	cld    
  800a8b:	f3 aa                	rep stos %al,%es:(%edi)
		             : "=D"(p), "=c"(n)
		             : "0"(p), "a"(c), "1"(n)
		             : "cc", "memory");
	return v;
}
  800a8d:	89 d0                	mov    %edx,%eax
  800a8f:	5b                   	pop    %ebx
  800a90:	5e                   	pop    %esi
  800a91:	5f                   	pop    %edi
  800a92:	5d                   	pop    %ebp
  800a93:	c3                   	ret    

00800a94 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a94:	55                   	push   %ebp
  800a95:	89 e5                	mov    %esp,%ebp
  800a97:	57                   	push   %edi
  800a98:	56                   	push   %esi
  800a99:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a9f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800aa2:	39 c6                	cmp    %eax,%esi
  800aa4:	73 32                	jae    800ad8 <memmove+0x44>
  800aa6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800aa9:	39 c2                	cmp    %eax,%edx
  800aab:	76 2b                	jbe    800ad8 <memmove+0x44>
		s += n;
		d += n;
  800aad:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  800ab0:	89 d6                	mov    %edx,%esi
  800ab2:	09 fe                	or     %edi,%esi
  800ab4:	09 ce                	or     %ecx,%esi
  800ab6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800abc:	75 0e                	jne    800acc <memmove+0x38>
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  800abe:	83 ef 04             	sub    $0x4,%edi
			             "S"(s - 4),
  800ac1:	8d 72 fc             	lea    -0x4(%edx),%esi
			             "c"(n / 4)
  800ac4:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  800ac7:	fd                   	std    
  800ac8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aca:	eb 09                	jmp    800ad5 <memmove+0x41>
			             : "cc", "memory");
		else
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  800acc:	83 ef 01             	sub    $0x1,%edi
			             "S"(s - 1),
  800acf:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  800ad2:	fd                   	std    
  800ad3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             "c"(n)
			             : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ad5:	fc                   	cld    
  800ad6:	eb 1a                	jmp    800af2 <memmove+0x5e>
	} else {
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  800ad8:	89 f2                	mov    %esi,%edx
  800ada:	09 c2                	or     %eax,%edx
  800adc:	09 ca                	or     %ecx,%edx
  800ade:	f6 c2 03             	test   $0x3,%dl
  800ae1:	75 0a                	jne    800aed <memmove+0x59>
			asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800ae3:	c1 e9 02             	shr    $0x2,%ecx
  800ae6:	89 c7                	mov    %eax,%edi
  800ae8:	fc                   	cld    
  800ae9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aeb:	eb 05                	jmp    800af2 <memmove+0x5e>
			             : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800aed:	89 c7                	mov    %eax,%edi
  800aef:	fc                   	cld    
  800af0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             : "cc", "memory");
	}
	return dst;
}
  800af2:	5e                   	pop    %esi
  800af3:	5f                   	pop    %edi
  800af4:	5d                   	pop    %ebp
  800af5:	c3                   	ret    

00800af6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800af6:	55                   	push   %ebp
  800af7:	89 e5                	mov    %esp,%ebp
  800af9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800afc:	ff 75 10             	push   0x10(%ebp)
  800aff:	ff 75 0c             	push   0xc(%ebp)
  800b02:	ff 75 08             	push   0x8(%ebp)
  800b05:	e8 8a ff ff ff       	call   800a94 <memmove>
}
  800b0a:	c9                   	leave  
  800b0b:	c3                   	ret    

00800b0c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	56                   	push   %esi
  800b10:	53                   	push   %ebx
  800b11:	8b 45 08             	mov    0x8(%ebp),%eax
  800b14:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b17:	89 c6                	mov    %eax,%esi
  800b19:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b1c:	eb 06                	jmp    800b24 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b1e:	83 c0 01             	add    $0x1,%eax
  800b21:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800b24:	39 f0                	cmp    %esi,%eax
  800b26:	74 14                	je     800b3c <memcmp+0x30>
		if (*s1 != *s2)
  800b28:	0f b6 08             	movzbl (%eax),%ecx
  800b2b:	0f b6 1a             	movzbl (%edx),%ebx
  800b2e:	38 d9                	cmp    %bl,%cl
  800b30:	74 ec                	je     800b1e <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800b32:	0f b6 c1             	movzbl %cl,%eax
  800b35:	0f b6 db             	movzbl %bl,%ebx
  800b38:	29 d8                	sub    %ebx,%eax
  800b3a:	eb 05                	jmp    800b41 <memcmp+0x35>
	}

	return 0;
  800b3c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b41:	5b                   	pop    %ebx
  800b42:	5e                   	pop    %esi
  800b43:	5d                   	pop    %ebp
  800b44:	c3                   	ret    

00800b45 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b45:	55                   	push   %ebp
  800b46:	89 e5                	mov    %esp,%ebp
  800b48:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b4e:	89 c2                	mov    %eax,%edx
  800b50:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b53:	eb 03                	jmp    800b58 <memfind+0x13>
  800b55:	83 c0 01             	add    $0x1,%eax
  800b58:	39 d0                	cmp    %edx,%eax
  800b5a:	73 04                	jae    800b60 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b5c:	38 08                	cmp    %cl,(%eax)
  800b5e:	75 f5                	jne    800b55 <memfind+0x10>
			break;
	return (void *) s;
}
  800b60:	5d                   	pop    %ebp
  800b61:	c3                   	ret    

00800b62 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	57                   	push   %edi
  800b66:	56                   	push   %esi
  800b67:	53                   	push   %ebx
  800b68:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b6e:	eb 03                	jmp    800b73 <strtol+0x11>
		s++;
  800b70:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b73:	0f b6 02             	movzbl (%edx),%eax
  800b76:	3c 20                	cmp    $0x20,%al
  800b78:	74 f6                	je     800b70 <strtol+0xe>
  800b7a:	3c 09                	cmp    $0x9,%al
  800b7c:	74 f2                	je     800b70 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b7e:	3c 2b                	cmp    $0x2b,%al
  800b80:	74 2a                	je     800bac <strtol+0x4a>
	int neg = 0;
  800b82:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b87:	3c 2d                	cmp    $0x2d,%al
  800b89:	74 2b                	je     800bb6 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b8b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b91:	75 0f                	jne    800ba2 <strtol+0x40>
  800b93:	80 3a 30             	cmpb   $0x30,(%edx)
  800b96:	74 28                	je     800bc0 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b98:	85 db                	test   %ebx,%ebx
  800b9a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b9f:	0f 44 d8             	cmove  %eax,%ebx
  800ba2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ba7:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800baa:	eb 46                	jmp    800bf2 <strtol+0x90>
		s++;
  800bac:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800baf:	bf 00 00 00 00       	mov    $0x0,%edi
  800bb4:	eb d5                	jmp    800b8b <strtol+0x29>
		s++, neg = 1;
  800bb6:	83 c2 01             	add    $0x1,%edx
  800bb9:	bf 01 00 00 00       	mov    $0x1,%edi
  800bbe:	eb cb                	jmp    800b8b <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bc0:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bc4:	74 0e                	je     800bd4 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800bc6:	85 db                	test   %ebx,%ebx
  800bc8:	75 d8                	jne    800ba2 <strtol+0x40>
		s++, base = 8;
  800bca:	83 c2 01             	add    $0x1,%edx
  800bcd:	bb 08 00 00 00       	mov    $0x8,%ebx
  800bd2:	eb ce                	jmp    800ba2 <strtol+0x40>
		s += 2, base = 16;
  800bd4:	83 c2 02             	add    $0x2,%edx
  800bd7:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bdc:	eb c4                	jmp    800ba2 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800bde:	0f be c0             	movsbl %al,%eax
  800be1:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800be4:	3b 45 10             	cmp    0x10(%ebp),%eax
  800be7:	7d 3a                	jge    800c23 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800be9:	83 c2 01             	add    $0x1,%edx
  800bec:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800bf0:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800bf2:	0f b6 02             	movzbl (%edx),%eax
  800bf5:	8d 70 d0             	lea    -0x30(%eax),%esi
  800bf8:	89 f3                	mov    %esi,%ebx
  800bfa:	80 fb 09             	cmp    $0x9,%bl
  800bfd:	76 df                	jbe    800bde <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800bff:	8d 70 9f             	lea    -0x61(%eax),%esi
  800c02:	89 f3                	mov    %esi,%ebx
  800c04:	80 fb 19             	cmp    $0x19,%bl
  800c07:	77 08                	ja     800c11 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800c09:	0f be c0             	movsbl %al,%eax
  800c0c:	83 e8 57             	sub    $0x57,%eax
  800c0f:	eb d3                	jmp    800be4 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800c11:	8d 70 bf             	lea    -0x41(%eax),%esi
  800c14:	89 f3                	mov    %esi,%ebx
  800c16:	80 fb 19             	cmp    $0x19,%bl
  800c19:	77 08                	ja     800c23 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800c1b:	0f be c0             	movsbl %al,%eax
  800c1e:	83 e8 37             	sub    $0x37,%eax
  800c21:	eb c1                	jmp    800be4 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c23:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c27:	74 05                	je     800c2e <strtol+0xcc>
		*endptr = (char *) s;
  800c29:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c2c:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800c2e:	89 c8                	mov    %ecx,%eax
  800c30:	f7 d8                	neg    %eax
  800c32:	85 ff                	test   %edi,%edi
  800c34:	0f 45 c8             	cmovne %eax,%ecx
}
  800c37:	89 c8                	mov    %ecx,%eax
  800c39:	5b                   	pop    %ebx
  800c3a:	5e                   	pop    %esi
  800c3b:	5f                   	pop    %edi
  800c3c:	5d                   	pop    %ebp
  800c3d:	c3                   	ret    
  800c3e:	66 90                	xchg   %ax,%ax

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
