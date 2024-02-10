
obj/user/buggyhello2:     formato del fichero elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs(hello, 1024 * 1024);
  800039:	68 00 00 10 00       	push   $0x100000
  80003e:	ff 35 00 20 80 00    	push   0x802000
  800044:	e8 ad 00 00 00       	call   8000f6 <sys_cputs>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	envid_t id = sys_getenvid();
  800059:	e8 04 01 00 00       	call   800162 <sys_getenvid>
	if (id >= 0)
  80005e:	85 c0                	test   %eax,%eax
  800060:	78 15                	js     800077 <libmain+0x29>
		thisenv = &envs[ENVX(id)];
  800062:	25 ff 03 00 00       	and    $0x3ff,%eax
  800067:	69 c0 88 00 00 00    	imul   $0x88,%eax,%eax
  80006d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800072:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800077:	85 db                	test   %ebx,%ebx
  800079:	7e 07                	jle    800082 <libmain+0x34>
		binaryname = argv[0];
  80007b:	8b 06                	mov    (%esi),%eax
  80007d:	a3 04 20 80 00       	mov    %eax,0x802004

	// call user main routine
	umain(argc, argv);
  800082:	83 ec 08             	sub    $0x8,%esp
  800085:	56                   	push   %esi
  800086:	53                   	push   %ebx
  800087:	e8 a7 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008c:	e8 0a 00 00 00       	call   80009b <exit>
}
  800091:	83 c4 10             	add    $0x10,%esp
  800094:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800097:	5b                   	pop    %ebx
  800098:	5e                   	pop    %esi
  800099:	5d                   	pop    %ebp
  80009a:	c3                   	ret    

0080009b <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009b:	55                   	push   %ebp
  80009c:	89 e5                	mov    %esp,%ebp
  80009e:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000a1:	6a 00                	push   $0x0
  8000a3:	e8 98 00 00 00       	call   800140 <sys_env_destroy>
}
  8000a8:	83 c4 10             	add    $0x10,%esp
  8000ab:	c9                   	leave  
  8000ac:	c3                   	ret    

008000ad <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000ad:	55                   	push   %ebp
  8000ae:	89 e5                	mov    %esp,%ebp
  8000b0:	57                   	push   %edi
  8000b1:	56                   	push   %esi
  8000b2:	53                   	push   %ebx
  8000b3:	83 ec 1c             	sub    $0x1c,%esp
  8000b6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8000b9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8000bc:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile(
  8000be:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000c4:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000c7:	8b 75 14             	mov    0x14(%ebp),%esi
  8000ca:	cd 30                	int    $0x30
	        "int %1\n"
	        : "=a"(ret)
	        : "i"(T_SYSCALL), "a"(num), "d"(a1), "c"(a2), "b"(a3), "D"(a4), "S"(a5)
	        : "cc", "memory");

	if (check && ret > 0)
  8000cc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000d0:	74 04                	je     8000d6 <syscall+0x29>
  8000d2:	85 c0                	test   %eax,%eax
  8000d4:	7f 08                	jg     8000de <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  8000d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000d9:	5b                   	pop    %ebx
  8000da:	5e                   	pop    %esi
  8000db:	5f                   	pop    %edi
  8000dc:	5d                   	pop    %ebp
  8000dd:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8000de:	83 ec 0c             	sub    $0xc,%esp
  8000e1:	50                   	push   %eax
  8000e2:	ff 75 e0             	push   -0x20(%ebp)
  8000e5:	68 b8 0e 80 00       	push   $0x800eb8
  8000ea:	6a 1e                	push   $0x1e
  8000ec:	68 d5 0e 80 00       	push   $0x800ed5
  8000f1:	e8 f7 01 00 00       	call   8002ed <_panic>

008000f6 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  8000f6:	55                   	push   %ebp
  8000f7:	89 e5                	mov    %esp,%ebp
  8000f9:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t) s, len, 0, 0, 0);
  8000fc:	6a 00                	push   $0x0
  8000fe:	6a 00                	push   $0x0
  800100:	6a 00                	push   $0x0
  800102:	ff 75 0c             	push   0xc(%ebp)
  800105:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800108:	ba 00 00 00 00       	mov    $0x0,%edx
  80010d:	b8 00 00 00 00       	mov    $0x0,%eax
  800112:	e8 96 ff ff ff       	call   8000ad <syscall>
}
  800117:	83 c4 10             	add    $0x10,%esp
  80011a:	c9                   	leave  
  80011b:	c3                   	ret    

0080011c <sys_cgetc>:

int
sys_cgetc(void)
{
  80011c:	55                   	push   %ebp
  80011d:	89 e5                	mov    %esp,%ebp
  80011f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800122:	6a 00                	push   $0x0
  800124:	6a 00                	push   $0x0
  800126:	6a 00                	push   $0x0
  800128:	6a 00                	push   $0x0
  80012a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80012f:	ba 00 00 00 00       	mov    $0x0,%edx
  800134:	b8 01 00 00 00       	mov    $0x1,%eax
  800139:	e8 6f ff ff ff       	call   8000ad <syscall>
}
  80013e:	c9                   	leave  
  80013f:	c3                   	ret    

00800140 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800140:	55                   	push   %ebp
  800141:	89 e5                	mov    %esp,%ebp
  800143:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800146:	6a 00                	push   $0x0
  800148:	6a 00                	push   $0x0
  80014a:	6a 00                	push   $0x0
  80014c:	6a 00                	push   $0x0
  80014e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800151:	ba 01 00 00 00       	mov    $0x1,%edx
  800156:	b8 03 00 00 00       	mov    $0x3,%eax
  80015b:	e8 4d ff ff ff       	call   8000ad <syscall>
}
  800160:	c9                   	leave  
  800161:	c3                   	ret    

00800162 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800168:	6a 00                	push   $0x0
  80016a:	6a 00                	push   $0x0
  80016c:	6a 00                	push   $0x0
  80016e:	6a 00                	push   $0x0
  800170:	b9 00 00 00 00       	mov    $0x0,%ecx
  800175:	ba 00 00 00 00       	mov    $0x0,%edx
  80017a:	b8 02 00 00 00       	mov    $0x2,%eax
  80017f:	e8 29 ff ff ff       	call   8000ad <syscall>
}
  800184:	c9                   	leave  
  800185:	c3                   	ret    

00800186 <sys_yield>:

void
sys_yield(void)
{
  800186:	55                   	push   %ebp
  800187:	89 e5                	mov    %esp,%ebp
  800189:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  80018c:	6a 00                	push   $0x0
  80018e:	6a 00                	push   $0x0
  800190:	6a 00                	push   $0x0
  800192:	6a 00                	push   $0x0
  800194:	b9 00 00 00 00       	mov    $0x0,%ecx
  800199:	ba 00 00 00 00       	mov    $0x0,%edx
  80019e:	b8 0a 00 00 00       	mov    $0xa,%eax
  8001a3:	e8 05 ff ff ff       	call   8000ad <syscall>
}
  8001a8:	83 c4 10             	add    $0x10,%esp
  8001ab:	c9                   	leave  
  8001ac:	c3                   	ret    

008001ad <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001ad:	55                   	push   %ebp
  8001ae:	89 e5                	mov    %esp,%ebp
  8001b0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8001b3:	6a 00                	push   $0x0
  8001b5:	6a 00                	push   $0x0
  8001b7:	ff 75 10             	push   0x10(%ebp)
  8001ba:	ff 75 0c             	push   0xc(%ebp)
  8001bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001c0:	ba 01 00 00 00       	mov    $0x1,%edx
  8001c5:	b8 04 00 00 00       	mov    $0x4,%eax
  8001ca:	e8 de fe ff ff       	call   8000ad <syscall>
}
  8001cf:	c9                   	leave  
  8001d0:	c3                   	ret    

008001d1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001d1:	55                   	push   %ebp
  8001d2:	89 e5                	mov    %esp,%ebp
  8001d4:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map,
  8001d7:	ff 75 18             	push   0x18(%ebp)
  8001da:	ff 75 14             	push   0x14(%ebp)
  8001dd:	ff 75 10             	push   0x10(%ebp)
  8001e0:	ff 75 0c             	push   0xc(%ebp)
  8001e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001e6:	ba 01 00 00 00       	mov    $0x1,%edx
  8001eb:	b8 05 00 00 00       	mov    $0x5,%eax
  8001f0:	e8 b8 fe ff ff       	call   8000ad <syscall>
	               srcenv,
	               (uint32_t) srcva,
	               dstenv,
	               (uint32_t) dstva,
	               perm);
}
  8001f5:	c9                   	leave  
  8001f6:	c3                   	ret    

008001f7 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001f7:	55                   	push   %ebp
  8001f8:	89 e5                	mov    %esp,%ebp
  8001fa:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8001fd:	6a 00                	push   $0x0
  8001ff:	6a 00                	push   $0x0
  800201:	6a 00                	push   $0x0
  800203:	ff 75 0c             	push   0xc(%ebp)
  800206:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800209:	ba 01 00 00 00       	mov    $0x1,%edx
  80020e:	b8 06 00 00 00       	mov    $0x6,%eax
  800213:	e8 95 fe ff ff       	call   8000ad <syscall>
}
  800218:	c9                   	leave  
  800219:	c3                   	ret    

0080021a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80021a:	55                   	push   %ebp
  80021b:	89 e5                	mov    %esp,%ebp
  80021d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800220:	6a 00                	push   $0x0
  800222:	6a 00                	push   $0x0
  800224:	6a 00                	push   $0x0
  800226:	ff 75 0c             	push   0xc(%ebp)
  800229:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80022c:	ba 01 00 00 00       	mov    $0x1,%edx
  800231:	b8 08 00 00 00       	mov    $0x8,%eax
  800236:	e8 72 fe ff ff       	call   8000ad <syscall>
}
  80023b:	c9                   	leave  
  80023c:	c3                   	ret    

0080023d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80023d:	55                   	push   %ebp
  80023e:	89 e5                	mov    %esp,%ebp
  800240:	83 ec 08             	sub    $0x8,%esp
	return syscall(
  800243:	6a 00                	push   $0x0
  800245:	6a 00                	push   $0x0
  800247:	6a 00                	push   $0x0
  800249:	ff 75 0c             	push   0xc(%ebp)
  80024c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80024f:	ba 01 00 00 00       	mov    $0x1,%edx
  800254:	b8 09 00 00 00       	mov    $0x9,%eax
  800259:	e8 4f fe ff ff       	call   8000ad <syscall>
	        SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80025e:	c9                   	leave  
  80025f:	c3                   	ret    

00800260 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800266:	6a 00                	push   $0x0
  800268:	ff 75 14             	push   0x14(%ebp)
  80026b:	ff 75 10             	push   0x10(%ebp)
  80026e:	ff 75 0c             	push   0xc(%ebp)
  800271:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800274:	ba 00 00 00 00       	mov    $0x0,%edx
  800279:	b8 0b 00 00 00       	mov    $0xb,%eax
  80027e:	e8 2a fe ff ff       	call   8000ad <syscall>
}
  800283:	c9                   	leave  
  800284:	c3                   	ret    

00800285 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800285:	55                   	push   %ebp
  800286:	89 e5                	mov    %esp,%ebp
  800288:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t) dstva, 0, 0, 0, 0);
  80028b:	6a 00                	push   $0x0
  80028d:	6a 00                	push   $0x0
  80028f:	6a 00                	push   $0x0
  800291:	6a 00                	push   $0x0
  800293:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800296:	ba 01 00 00 00       	mov    $0x1,%edx
  80029b:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002a0:	e8 08 fe ff ff       	call   8000ad <syscall>
}
  8002a5:	c9                   	leave  
  8002a6:	c3                   	ret    

008002a7 <sys_get_priority>:

// Get priority of the current process
int
sys_get_priority(void)
{
  8002a7:	55                   	push   %ebp
  8002a8:	89 e5                	mov    %esp,%ebp
  8002aa:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_get_priority, 0, 0, 0, 0, 0, 0);
  8002ad:	6a 00                	push   $0x0
  8002af:	6a 00                	push   $0x0
  8002b1:	6a 00                	push   $0x0
  8002b3:	6a 00                	push   $0x0
  8002b5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8002bf:	b8 0d 00 00 00       	mov    $0xd,%eax
  8002c4:	e8 e4 fd ff ff       	call   8000ad <syscall>
}
  8002c9:	c9                   	leave  
  8002ca:	c3                   	ret    

008002cb <sys_set_priority>:

// Get priority of the current process
int
sys_set_priority(unsigned int priority)
{
  8002cb:	55                   	push   %ebp
  8002cc:	89 e5                	mov    %esp,%ebp
  8002ce:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, (uint32_t) priority, 0, 0, 0, 0);
  8002d1:	6a 00                	push   $0x0
  8002d3:	6a 00                	push   $0x0
  8002d5:	6a 00                	push   $0x0
  8002d7:	6a 00                	push   $0x0
  8002d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e1:	b8 0e 00 00 00       	mov    $0xe,%eax
  8002e6:	e8 c2 fd ff ff       	call   8000ad <syscall>
}
  8002eb:	c9                   	leave  
  8002ec:	c3                   	ret    

008002ed <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002ed:	55                   	push   %ebp
  8002ee:	89 e5                	mov    %esp,%ebp
  8002f0:	56                   	push   %esi
  8002f1:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002f2:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002f5:	8b 35 04 20 80 00    	mov    0x802004,%esi
  8002fb:	e8 62 fe ff ff       	call   800162 <sys_getenvid>
  800300:	83 ec 0c             	sub    $0xc,%esp
  800303:	ff 75 0c             	push   0xc(%ebp)
  800306:	ff 75 08             	push   0x8(%ebp)
  800309:	56                   	push   %esi
  80030a:	50                   	push   %eax
  80030b:	68 e4 0e 80 00       	push   $0x800ee4
  800310:	e8 b3 00 00 00       	call   8003c8 <cprintf>
	        sys_getenvid(),
	        binaryname,
	        file,
	        line);
	vcprintf(fmt, ap);
  800315:	83 c4 18             	add    $0x18,%esp
  800318:	53                   	push   %ebx
  800319:	ff 75 10             	push   0x10(%ebp)
  80031c:	e8 56 00 00 00       	call   800377 <vcprintf>
	cprintf("\n");
  800321:	c7 04 24 ac 0e 80 00 	movl   $0x800eac,(%esp)
  800328:	e8 9b 00 00 00       	call   8003c8 <cprintf>
  80032d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800330:	cc                   	int3   
  800331:	eb fd                	jmp    800330 <_panic+0x43>

00800333 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800333:	55                   	push   %ebp
  800334:	89 e5                	mov    %esp,%ebp
  800336:	53                   	push   %ebx
  800337:	83 ec 04             	sub    $0x4,%esp
  80033a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80033d:	8b 13                	mov    (%ebx),%edx
  80033f:	8d 42 01             	lea    0x1(%edx),%eax
  800342:	89 03                	mov    %eax,(%ebx)
  800344:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800347:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256 - 1) {
  80034b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800350:	74 09                	je     80035b <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800352:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800356:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800359:	c9                   	leave  
  80035a:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80035b:	83 ec 08             	sub    $0x8,%esp
  80035e:	68 ff 00 00 00       	push   $0xff
  800363:	8d 43 08             	lea    0x8(%ebx),%eax
  800366:	50                   	push   %eax
  800367:	e8 8a fd ff ff       	call   8000f6 <sys_cputs>
		b->idx = 0;
  80036c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800372:	83 c4 10             	add    $0x10,%esp
  800375:	eb db                	jmp    800352 <putch+0x1f>

00800377 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800377:	55                   	push   %ebp
  800378:	89 e5                	mov    %esp,%ebp
  80037a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800380:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800387:	00 00 00 
	b.cnt = 0;
  80038a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800391:	00 00 00 
	vprintfmt((void *) putch, &b, fmt, ap);
  800394:	ff 75 0c             	push   0xc(%ebp)
  800397:	ff 75 08             	push   0x8(%ebp)
  80039a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003a0:	50                   	push   %eax
  8003a1:	68 33 03 80 00       	push   $0x800333
  8003a6:	e8 74 01 00 00       	call   80051f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003ab:	83 c4 08             	add    $0x8,%esp
  8003ae:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8003b4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003ba:	50                   	push   %eax
  8003bb:	e8 36 fd ff ff       	call   8000f6 <sys_cputs>

	return b.cnt;
}
  8003c0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003c6:	c9                   	leave  
  8003c7:	c3                   	ret    

008003c8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003c8:	55                   	push   %ebp
  8003c9:	89 e5                	mov    %esp,%ebp
  8003cb:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003ce:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003d1:	50                   	push   %eax
  8003d2:	ff 75 08             	push   0x8(%ebp)
  8003d5:	e8 9d ff ff ff       	call   800377 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003da:	c9                   	leave  
  8003db:	c3                   	ret    

008003dc <printnum>:
         void *putdat,
         unsigned long long num,
         unsigned base,
         int width,
         int padc)
{
  8003dc:	55                   	push   %ebp
  8003dd:	89 e5                	mov    %esp,%ebp
  8003df:	57                   	push   %edi
  8003e0:	56                   	push   %esi
  8003e1:	53                   	push   %ebx
  8003e2:	83 ec 1c             	sub    $0x1c,%esp
  8003e5:	89 c7                	mov    %eax,%edi
  8003e7:	89 d6                	mov    %edx,%esi
  8003e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003ef:	89 d1                	mov    %edx,%ecx
  8003f1:	89 c2                	mov    %eax,%edx
  8003f3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003f6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8003f9:	8b 45 10             	mov    0x10(%ebp),%eax
  8003fc:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003ff:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800402:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800409:	39 c2                	cmp    %eax,%edx
  80040b:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80040e:	72 3e                	jb     80044e <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800410:	83 ec 0c             	sub    $0xc,%esp
  800413:	ff 75 18             	push   0x18(%ebp)
  800416:	83 eb 01             	sub    $0x1,%ebx
  800419:	53                   	push   %ebx
  80041a:	50                   	push   %eax
  80041b:	83 ec 08             	sub    $0x8,%esp
  80041e:	ff 75 e4             	push   -0x1c(%ebp)
  800421:	ff 75 e0             	push   -0x20(%ebp)
  800424:	ff 75 dc             	push   -0x24(%ebp)
  800427:	ff 75 d8             	push   -0x28(%ebp)
  80042a:	e8 21 08 00 00       	call   800c50 <__udivdi3>
  80042f:	83 c4 18             	add    $0x18,%esp
  800432:	52                   	push   %edx
  800433:	50                   	push   %eax
  800434:	89 f2                	mov    %esi,%edx
  800436:	89 f8                	mov    %edi,%eax
  800438:	e8 9f ff ff ff       	call   8003dc <printnum>
  80043d:	83 c4 20             	add    $0x20,%esp
  800440:	eb 13                	jmp    800455 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800442:	83 ec 08             	sub    $0x8,%esp
  800445:	56                   	push   %esi
  800446:	ff 75 18             	push   0x18(%ebp)
  800449:	ff d7                	call   *%edi
  80044b:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80044e:	83 eb 01             	sub    $0x1,%ebx
  800451:	85 db                	test   %ebx,%ebx
  800453:	7f ed                	jg     800442 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800455:	83 ec 08             	sub    $0x8,%esp
  800458:	56                   	push   %esi
  800459:	83 ec 04             	sub    $0x4,%esp
  80045c:	ff 75 e4             	push   -0x1c(%ebp)
  80045f:	ff 75 e0             	push   -0x20(%ebp)
  800462:	ff 75 dc             	push   -0x24(%ebp)
  800465:	ff 75 d8             	push   -0x28(%ebp)
  800468:	e8 03 09 00 00       	call   800d70 <__umoddi3>
  80046d:	83 c4 14             	add    $0x14,%esp
  800470:	0f be 80 07 0f 80 00 	movsbl 0x800f07(%eax),%eax
  800477:	50                   	push   %eax
  800478:	ff d7                	call   *%edi
}
  80047a:	83 c4 10             	add    $0x10,%esp
  80047d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800480:	5b                   	pop    %ebx
  800481:	5e                   	pop    %esi
  800482:	5f                   	pop    %edi
  800483:	5d                   	pop    %ebp
  800484:	c3                   	ret    

00800485 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800485:	83 fa 01             	cmp    $0x1,%edx
  800488:	7f 13                	jg     80049d <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80048a:	85 d2                	test   %edx,%edx
  80048c:	74 1c                	je     8004aa <getuint+0x25>
		return va_arg(*ap, unsigned long);
  80048e:	8b 10                	mov    (%eax),%edx
  800490:	8d 4a 04             	lea    0x4(%edx),%ecx
  800493:	89 08                	mov    %ecx,(%eax)
  800495:	8b 02                	mov    (%edx),%eax
  800497:	ba 00 00 00 00       	mov    $0x0,%edx
  80049c:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  80049d:	8b 10                	mov    (%eax),%edx
  80049f:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004a2:	89 08                	mov    %ecx,(%eax)
  8004a4:	8b 02                	mov    (%edx),%eax
  8004a6:	8b 52 04             	mov    0x4(%edx),%edx
  8004a9:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  8004aa:	8b 10                	mov    (%eax),%edx
  8004ac:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004af:	89 08                	mov    %ecx,(%eax)
  8004b1:	8b 02                	mov    (%edx),%eax
  8004b3:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004b8:	c3                   	ret    

008004b9 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004b9:	83 fa 01             	cmp    $0x1,%edx
  8004bc:	7f 0f                	jg     8004cd <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  8004be:	85 d2                	test   %edx,%edx
  8004c0:	74 18                	je     8004da <getint+0x21>
		return va_arg(*ap, long);
  8004c2:	8b 10                	mov    (%eax),%edx
  8004c4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004c7:	89 08                	mov    %ecx,(%eax)
  8004c9:	8b 02                	mov    (%edx),%eax
  8004cb:	99                   	cltd   
  8004cc:	c3                   	ret    
		return va_arg(*ap, long long);
  8004cd:	8b 10                	mov    (%eax),%edx
  8004cf:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004d2:	89 08                	mov    %ecx,(%eax)
  8004d4:	8b 02                	mov    (%edx),%eax
  8004d6:	8b 52 04             	mov    0x4(%edx),%edx
  8004d9:	c3                   	ret    
	else
		return va_arg(*ap, int);
  8004da:	8b 10                	mov    (%eax),%edx
  8004dc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004df:	89 08                	mov    %ecx,(%eax)
  8004e1:	8b 02                	mov    (%edx),%eax
  8004e3:	99                   	cltd   
}
  8004e4:	c3                   	ret    

008004e5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004e5:	55                   	push   %ebp
  8004e6:	89 e5                	mov    %esp,%ebp
  8004e8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004eb:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004ef:	8b 10                	mov    (%eax),%edx
  8004f1:	3b 50 04             	cmp    0x4(%eax),%edx
  8004f4:	73 0a                	jae    800500 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004f6:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004f9:	89 08                	mov    %ecx,(%eax)
  8004fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8004fe:	88 02                	mov    %al,(%edx)
}
  800500:	5d                   	pop    %ebp
  800501:	c3                   	ret    

00800502 <printfmt>:
{
  800502:	55                   	push   %ebp
  800503:	89 e5                	mov    %esp,%ebp
  800505:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800508:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80050b:	50                   	push   %eax
  80050c:	ff 75 10             	push   0x10(%ebp)
  80050f:	ff 75 0c             	push   0xc(%ebp)
  800512:	ff 75 08             	push   0x8(%ebp)
  800515:	e8 05 00 00 00       	call   80051f <vprintfmt>
}
  80051a:	83 c4 10             	add    $0x10,%esp
  80051d:	c9                   	leave  
  80051e:	c3                   	ret    

0080051f <vprintfmt>:
{
  80051f:	55                   	push   %ebp
  800520:	89 e5                	mov    %esp,%ebp
  800522:	57                   	push   %edi
  800523:	56                   	push   %esi
  800524:	53                   	push   %ebx
  800525:	83 ec 2c             	sub    $0x2c,%esp
  800528:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80052b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80052e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800531:	eb 0a                	jmp    80053d <vprintfmt+0x1e>
			putch(ch, putdat);
  800533:	83 ec 08             	sub    $0x8,%esp
  800536:	56                   	push   %esi
  800537:	50                   	push   %eax
  800538:	ff d3                	call   *%ebx
  80053a:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80053d:	83 c7 01             	add    $0x1,%edi
  800540:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800544:	83 f8 25             	cmp    $0x25,%eax
  800547:	74 0c                	je     800555 <vprintfmt+0x36>
			if (ch == '\0')
  800549:	85 c0                	test   %eax,%eax
  80054b:	75 e6                	jne    800533 <vprintfmt+0x14>
}
  80054d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800550:	5b                   	pop    %ebx
  800551:	5e                   	pop    %esi
  800552:	5f                   	pop    %edi
  800553:	5d                   	pop    %ebp
  800554:	c3                   	ret    
		padc = ' ';
  800555:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
		altflag = 0;
  800559:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800560:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800567:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80056e:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800573:	8d 47 01             	lea    0x1(%edi),%eax
  800576:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800579:	0f b6 17             	movzbl (%edi),%edx
  80057c:	8d 42 dd             	lea    -0x23(%edx),%eax
  80057f:	3c 55                	cmp    $0x55,%al
  800581:	0f 87 b7 02 00 00    	ja     80083e <vprintfmt+0x31f>
  800587:	0f b6 c0             	movzbl %al,%eax
  80058a:	ff 24 85 c0 0f 80 00 	jmp    *0x800fc0(,%eax,4)
  800591:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800594:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800598:	eb d9                	jmp    800573 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80059a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80059d:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  8005a1:	eb d0                	jmp    800573 <vprintfmt+0x54>
  8005a3:	0f b6 d2             	movzbl %dl,%edx
  8005a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0;; ++fmt) {
  8005a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8005ae:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8005b1:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005b4:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8005b8:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8005bb:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8005be:	83 f9 09             	cmp    $0x9,%ecx
  8005c1:	77 52                	ja     800615 <vprintfmt+0xf6>
			for (precision = 0;; ++fmt) {
  8005c3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8005c6:	eb e9                	jmp    8005b1 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  8005c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cb:	8d 50 04             	lea    0x4(%eax),%edx
  8005ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d1:	8b 00                	mov    (%eax),%eax
  8005d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8005d9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005dd:	79 94                	jns    800573 <vprintfmt+0x54>
				width = precision, precision = -1;
  8005df:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005e2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005e5:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8005ec:	eb 85                	jmp    800573 <vprintfmt+0x54>
  8005ee:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005f1:	85 d2                	test   %edx,%edx
  8005f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8005f8:	0f 49 c2             	cmovns %edx,%eax
  8005fb:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800601:	e9 6d ff ff ff       	jmp    800573 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800606:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800609:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800610:	e9 5e ff ff ff       	jmp    800573 <vprintfmt+0x54>
  800615:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800618:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80061b:	eb bc                	jmp    8005d9 <vprintfmt+0xba>
			lflag++;
  80061d:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800620:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800623:	e9 4b ff ff ff       	jmp    800573 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800628:	8b 45 14             	mov    0x14(%ebp),%eax
  80062b:	8d 50 04             	lea    0x4(%eax),%edx
  80062e:	89 55 14             	mov    %edx,0x14(%ebp)
  800631:	83 ec 08             	sub    $0x8,%esp
  800634:	56                   	push   %esi
  800635:	ff 30                	push   (%eax)
  800637:	ff d3                	call   *%ebx
			break;
  800639:	83 c4 10             	add    $0x10,%esp
  80063c:	e9 94 01 00 00       	jmp    8007d5 <vprintfmt+0x2b6>
			err = va_arg(ap, int);
  800641:	8b 45 14             	mov    0x14(%ebp),%eax
  800644:	8d 50 04             	lea    0x4(%eax),%edx
  800647:	89 55 14             	mov    %edx,0x14(%ebp)
  80064a:	8b 10                	mov    (%eax),%edx
  80064c:	89 d0                	mov    %edx,%eax
  80064e:	f7 d8                	neg    %eax
  800650:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800653:	83 f8 08             	cmp    $0x8,%eax
  800656:	7f 20                	jg     800678 <vprintfmt+0x159>
  800658:	8b 14 85 20 11 80 00 	mov    0x801120(,%eax,4),%edx
  80065f:	85 d2                	test   %edx,%edx
  800661:	74 15                	je     800678 <vprintfmt+0x159>
				printfmt(putch, putdat, "%s", p);
  800663:	52                   	push   %edx
  800664:	68 28 0f 80 00       	push   $0x800f28
  800669:	56                   	push   %esi
  80066a:	53                   	push   %ebx
  80066b:	e8 92 fe ff ff       	call   800502 <printfmt>
  800670:	83 c4 10             	add    $0x10,%esp
  800673:	e9 5d 01 00 00       	jmp    8007d5 <vprintfmt+0x2b6>
				printfmt(putch, putdat, "error %d", err);
  800678:	50                   	push   %eax
  800679:	68 1f 0f 80 00       	push   $0x800f1f
  80067e:	56                   	push   %esi
  80067f:	53                   	push   %ebx
  800680:	e8 7d fe ff ff       	call   800502 <printfmt>
  800685:	83 c4 10             	add    $0x10,%esp
  800688:	e9 48 01 00 00       	jmp    8007d5 <vprintfmt+0x2b6>
			if ((p = va_arg(ap, char *)) == NULL)
  80068d:	8b 45 14             	mov    0x14(%ebp),%eax
  800690:	8d 50 04             	lea    0x4(%eax),%edx
  800693:	89 55 14             	mov    %edx,0x14(%ebp)
  800696:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800698:	85 ff                	test   %edi,%edi
  80069a:	b8 18 0f 80 00       	mov    $0x800f18,%eax
  80069f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006a2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006a6:	7e 06                	jle    8006ae <vprintfmt+0x18f>
  8006a8:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8006ac:	75 0a                	jne    8006b8 <vprintfmt+0x199>
  8006ae:	89 f8                	mov    %edi,%eax
  8006b0:	03 45 e0             	add    -0x20(%ebp),%eax
  8006b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006b6:	eb 59                	jmp    800711 <vprintfmt+0x1f2>
				for (width -= strnlen(p, precision); width > 0;
  8006b8:	83 ec 08             	sub    $0x8,%esp
  8006bb:	ff 75 d8             	push   -0x28(%ebp)
  8006be:	57                   	push   %edi
  8006bf:	e8 1a 02 00 00       	call   8008de <strnlen>
  8006c4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006c7:	29 c1                	sub    %eax,%ecx
  8006c9:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006cc:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006cf:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  8006d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006d6:	89 7d d0             	mov    %edi,-0x30(%ebp)
  8006d9:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0;
  8006db:	eb 0f                	jmp    8006ec <vprintfmt+0x1cd>
					putch(padc, putdat);
  8006dd:	83 ec 08             	sub    $0x8,%esp
  8006e0:	56                   	push   %esi
  8006e1:	ff 75 e0             	push   -0x20(%ebp)
  8006e4:	ff d3                	call   *%ebx
				     width--)
  8006e6:	83 ef 01             	sub    $0x1,%edi
  8006e9:	83 c4 10             	add    $0x10,%esp
				for (width -= strnlen(p, precision); width > 0;
  8006ec:	85 ff                	test   %edi,%edi
  8006ee:	7f ed                	jg     8006dd <vprintfmt+0x1be>
  8006f0:	8b 7d d0             	mov    -0x30(%ebp),%edi
  8006f3:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006f6:	85 c9                	test   %ecx,%ecx
  8006f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8006fd:	0f 49 c1             	cmovns %ecx,%eax
  800700:	29 c1                	sub    %eax,%ecx
  800702:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800705:	eb a7                	jmp    8006ae <vprintfmt+0x18f>
					putch(ch, putdat);
  800707:	83 ec 08             	sub    $0x8,%esp
  80070a:	56                   	push   %esi
  80070b:	52                   	push   %edx
  80070c:	ff d3                	call   *%ebx
  80070e:	83 c4 10             	add    $0x10,%esp
  800711:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800714:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' &&
  800716:	83 c7 01             	add    $0x1,%edi
  800719:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80071d:	0f be d0             	movsbl %al,%edx
  800720:	85 d2                	test   %edx,%edx
  800722:	74 42                	je     800766 <vprintfmt+0x247>
  800724:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800728:	78 06                	js     800730 <vprintfmt+0x211>
			       (precision < 0 || --precision >= 0);
  80072a:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80072e:	78 1e                	js     80074e <vprintfmt+0x22f>
				if (altflag && (ch < ' ' || ch > '~'))
  800730:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800734:	74 d1                	je     800707 <vprintfmt+0x1e8>
  800736:	0f be c0             	movsbl %al,%eax
  800739:	83 e8 20             	sub    $0x20,%eax
  80073c:	83 f8 5e             	cmp    $0x5e,%eax
  80073f:	76 c6                	jbe    800707 <vprintfmt+0x1e8>
					putch('?', putdat);
  800741:	83 ec 08             	sub    $0x8,%esp
  800744:	56                   	push   %esi
  800745:	6a 3f                	push   $0x3f
  800747:	ff d3                	call   *%ebx
  800749:	83 c4 10             	add    $0x10,%esp
  80074c:	eb c3                	jmp    800711 <vprintfmt+0x1f2>
  80074e:	89 cf                	mov    %ecx,%edi
  800750:	eb 0e                	jmp    800760 <vprintfmt+0x241>
				putch(' ', putdat);
  800752:	83 ec 08             	sub    $0x8,%esp
  800755:	56                   	push   %esi
  800756:	6a 20                	push   $0x20
  800758:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  80075a:	83 ef 01             	sub    $0x1,%edi
  80075d:	83 c4 10             	add    $0x10,%esp
  800760:	85 ff                	test   %edi,%edi
  800762:	7f ee                	jg     800752 <vprintfmt+0x233>
  800764:	eb 6f                	jmp    8007d5 <vprintfmt+0x2b6>
  800766:	89 cf                	mov    %ecx,%edi
  800768:	eb f6                	jmp    800760 <vprintfmt+0x241>
			num = getint(&ap, lflag);
  80076a:	89 ca                	mov    %ecx,%edx
  80076c:	8d 45 14             	lea    0x14(%ebp),%eax
  80076f:	e8 45 fd ff ff       	call   8004b9 <getint>
  800774:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800777:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  80077a:	85 d2                	test   %edx,%edx
  80077c:	78 0b                	js     800789 <vprintfmt+0x26a>
			num = getint(&ap, lflag);
  80077e:	89 d1                	mov    %edx,%ecx
  800780:	89 c2                	mov    %eax,%edx
			base = 10;
  800782:	bf 0a 00 00 00       	mov    $0xa,%edi
  800787:	eb 32                	jmp    8007bb <vprintfmt+0x29c>
				putch('-', putdat);
  800789:	83 ec 08             	sub    $0x8,%esp
  80078c:	56                   	push   %esi
  80078d:	6a 2d                	push   $0x2d
  80078f:	ff d3                	call   *%ebx
				num = -(long long) num;
  800791:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800794:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800797:	f7 da                	neg    %edx
  800799:	83 d1 00             	adc    $0x0,%ecx
  80079c:	f7 d9                	neg    %ecx
  80079e:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8007a1:	bf 0a 00 00 00       	mov    $0xa,%edi
  8007a6:	eb 13                	jmp    8007bb <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  8007a8:	89 ca                	mov    %ecx,%edx
  8007aa:	8d 45 14             	lea    0x14(%ebp),%eax
  8007ad:	e8 d3 fc ff ff       	call   800485 <getuint>
  8007b2:	89 d1                	mov    %edx,%ecx
  8007b4:	89 c2                	mov    %eax,%edx
			base = 10;
  8007b6:	bf 0a 00 00 00       	mov    $0xa,%edi
			printnum(putch, putdat, num, base, width, padc);
  8007bb:	83 ec 0c             	sub    $0xc,%esp
  8007be:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  8007c2:	50                   	push   %eax
  8007c3:	ff 75 e0             	push   -0x20(%ebp)
  8007c6:	57                   	push   %edi
  8007c7:	51                   	push   %ecx
  8007c8:	52                   	push   %edx
  8007c9:	89 f2                	mov    %esi,%edx
  8007cb:	89 d8                	mov    %ebx,%eax
  8007cd:	e8 0a fc ff ff       	call   8003dc <printnum>
			break;
  8007d2:	83 c4 20             	add    $0x20,%esp
{
  8007d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007d8:	e9 60 fd ff ff       	jmp    80053d <vprintfmt+0x1e>
			num = getuint(&ap, lflag);
  8007dd:	89 ca                	mov    %ecx,%edx
  8007df:	8d 45 14             	lea    0x14(%ebp),%eax
  8007e2:	e8 9e fc ff ff       	call   800485 <getuint>
  8007e7:	89 d1                	mov    %edx,%ecx
  8007e9:	89 c2                	mov    %eax,%edx
			base = 8;
  8007eb:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  8007f0:	eb c9                	jmp    8007bb <vprintfmt+0x29c>
			putch('0', putdat);
  8007f2:	83 ec 08             	sub    $0x8,%esp
  8007f5:	56                   	push   %esi
  8007f6:	6a 30                	push   $0x30
  8007f8:	ff d3                	call   *%ebx
			putch('x', putdat);
  8007fa:	83 c4 08             	add    $0x8,%esp
  8007fd:	56                   	push   %esi
  8007fe:	6a 78                	push   $0x78
  800800:	ff d3                	call   *%ebx
			num = (unsigned long long) (uintptr_t) va_arg(ap, void *);
  800802:	8b 45 14             	mov    0x14(%ebp),%eax
  800805:	8d 50 04             	lea    0x4(%eax),%edx
  800808:	89 55 14             	mov    %edx,0x14(%ebp)
  80080b:	8b 10                	mov    (%eax),%edx
  80080d:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800812:	83 c4 10             	add    $0x10,%esp
			base = 16;
  800815:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  80081a:	eb 9f                	jmp    8007bb <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  80081c:	89 ca                	mov    %ecx,%edx
  80081e:	8d 45 14             	lea    0x14(%ebp),%eax
  800821:	e8 5f fc ff ff       	call   800485 <getuint>
  800826:	89 d1                	mov    %edx,%ecx
  800828:	89 c2                	mov    %eax,%edx
			base = 16;
  80082a:	bf 10 00 00 00       	mov    $0x10,%edi
  80082f:	eb 8a                	jmp    8007bb <vprintfmt+0x29c>
			putch(ch, putdat);
  800831:	83 ec 08             	sub    $0x8,%esp
  800834:	56                   	push   %esi
  800835:	6a 25                	push   $0x25
  800837:	ff d3                	call   *%ebx
			break;
  800839:	83 c4 10             	add    $0x10,%esp
  80083c:	eb 97                	jmp    8007d5 <vprintfmt+0x2b6>
			putch('%', putdat);
  80083e:	83 ec 08             	sub    $0x8,%esp
  800841:	56                   	push   %esi
  800842:	6a 25                	push   $0x25
  800844:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  800846:	83 c4 10             	add    $0x10,%esp
  800849:	89 f8                	mov    %edi,%eax
  80084b:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80084f:	74 05                	je     800856 <vprintfmt+0x337>
  800851:	83 e8 01             	sub    $0x1,%eax
  800854:	eb f5                	jmp    80084b <vprintfmt+0x32c>
  800856:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800859:	e9 77 ff ff ff       	jmp    8007d5 <vprintfmt+0x2b6>

0080085e <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80085e:	55                   	push   %ebp
  80085f:	89 e5                	mov    %esp,%ebp
  800861:	83 ec 18             	sub    $0x18,%esp
  800864:	8b 45 08             	mov    0x8(%ebp),%eax
  800867:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = { buf, buf + n - 1, 0 };
  80086a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80086d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800871:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800874:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80087b:	85 c0                	test   %eax,%eax
  80087d:	74 26                	je     8008a5 <vsnprintf+0x47>
  80087f:	85 d2                	test   %edx,%edx
  800881:	7e 22                	jle    8008a5 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *) sprintputch, &b, fmt, ap);
  800883:	ff 75 14             	push   0x14(%ebp)
  800886:	ff 75 10             	push   0x10(%ebp)
  800889:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80088c:	50                   	push   %eax
  80088d:	68 e5 04 80 00       	push   $0x8004e5
  800892:	e8 88 fc ff ff       	call   80051f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800897:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80089a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80089d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008a0:	83 c4 10             	add    $0x10,%esp
}
  8008a3:	c9                   	leave  
  8008a4:	c3                   	ret    
		return -E_INVAL;
  8008a5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008aa:	eb f7                	jmp    8008a3 <vsnprintf+0x45>

008008ac <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008ac:	55                   	push   %ebp
  8008ad:	89 e5                	mov    %esp,%ebp
  8008af:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008b2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008b5:	50                   	push   %eax
  8008b6:	ff 75 10             	push   0x10(%ebp)
  8008b9:	ff 75 0c             	push   0xc(%ebp)
  8008bc:	ff 75 08             	push   0x8(%ebp)
  8008bf:	e8 9a ff ff ff       	call   80085e <vsnprintf>
	va_end(ap);

	return rc;
}
  8008c4:	c9                   	leave  
  8008c5:	c3                   	ret    

008008c6 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008c6:	55                   	push   %ebp
  8008c7:	89 e5                	mov    %esp,%ebp
  8008c9:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d1:	eb 03                	jmp    8008d6 <strlen+0x10>
		n++;
  8008d3:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008d6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008da:	75 f7                	jne    8008d3 <strlen+0xd>
	return n;
}
  8008dc:	5d                   	pop    %ebp
  8008dd:	c3                   	ret    

008008de <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008de:	55                   	push   %ebp
  8008df:	89 e5                	mov    %esp,%ebp
  8008e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008e4:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ec:	eb 03                	jmp    8008f1 <strnlen+0x13>
		n++;
  8008ee:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008f1:	39 d0                	cmp    %edx,%eax
  8008f3:	74 08                	je     8008fd <strnlen+0x1f>
  8008f5:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008f9:	75 f3                	jne    8008ee <strnlen+0x10>
  8008fb:	89 c2                	mov    %eax,%edx
	return n;
}
  8008fd:	89 d0                	mov    %edx,%eax
  8008ff:	5d                   	pop    %ebp
  800900:	c3                   	ret    

00800901 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800901:	55                   	push   %ebp
  800902:	89 e5                	mov    %esp,%ebp
  800904:	53                   	push   %ebx
  800905:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800908:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80090b:	b8 00 00 00 00       	mov    $0x0,%eax
  800910:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800914:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800917:	83 c0 01             	add    $0x1,%eax
  80091a:	84 d2                	test   %dl,%dl
  80091c:	75 f2                	jne    800910 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80091e:	89 c8                	mov    %ecx,%eax
  800920:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800923:	c9                   	leave  
  800924:	c3                   	ret    

00800925 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800925:	55                   	push   %ebp
  800926:	89 e5                	mov    %esp,%ebp
  800928:	53                   	push   %ebx
  800929:	83 ec 10             	sub    $0x10,%esp
  80092c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80092f:	53                   	push   %ebx
  800930:	e8 91 ff ff ff       	call   8008c6 <strlen>
  800935:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800938:	ff 75 0c             	push   0xc(%ebp)
  80093b:	01 d8                	add    %ebx,%eax
  80093d:	50                   	push   %eax
  80093e:	e8 be ff ff ff       	call   800901 <strcpy>
	return dst;
}
  800943:	89 d8                	mov    %ebx,%eax
  800945:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800948:	c9                   	leave  
  800949:	c3                   	ret    

0080094a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size)
{
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
  80094d:	56                   	push   %esi
  80094e:	53                   	push   %ebx
  80094f:	8b 75 08             	mov    0x8(%ebp),%esi
  800952:	8b 55 0c             	mov    0xc(%ebp),%edx
  800955:	89 f3                	mov    %esi,%ebx
  800957:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80095a:	89 f0                	mov    %esi,%eax
  80095c:	eb 0f                	jmp    80096d <strncpy+0x23>
		*dst++ = *src;
  80095e:	83 c0 01             	add    $0x1,%eax
  800961:	0f b6 0a             	movzbl (%edx),%ecx
  800964:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800967:	80 f9 01             	cmp    $0x1,%cl
  80096a:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  80096d:	39 d8                	cmp    %ebx,%eax
  80096f:	75 ed                	jne    80095e <strncpy+0x14>
	}
	return ret;
}
  800971:	89 f0                	mov    %esi,%eax
  800973:	5b                   	pop    %ebx
  800974:	5e                   	pop    %esi
  800975:	5d                   	pop    %ebp
  800976:	c3                   	ret    

00800977 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800977:	55                   	push   %ebp
  800978:	89 e5                	mov    %esp,%ebp
  80097a:	56                   	push   %esi
  80097b:	53                   	push   %ebx
  80097c:	8b 75 08             	mov    0x8(%ebp),%esi
  80097f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800982:	8b 55 10             	mov    0x10(%ebp),%edx
  800985:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800987:	85 d2                	test   %edx,%edx
  800989:	74 21                	je     8009ac <strlcpy+0x35>
  80098b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80098f:	89 f2                	mov    %esi,%edx
  800991:	eb 09                	jmp    80099c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800993:	83 c1 01             	add    $0x1,%ecx
  800996:	83 c2 01             	add    $0x1,%edx
  800999:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  80099c:	39 c2                	cmp    %eax,%edx
  80099e:	74 09                	je     8009a9 <strlcpy+0x32>
  8009a0:	0f b6 19             	movzbl (%ecx),%ebx
  8009a3:	84 db                	test   %bl,%bl
  8009a5:	75 ec                	jne    800993 <strlcpy+0x1c>
  8009a7:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8009a9:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009ac:	29 f0                	sub    %esi,%eax
}
  8009ae:	5b                   	pop    %ebx
  8009af:	5e                   	pop    %esi
  8009b0:	5d                   	pop    %ebp
  8009b1:	c3                   	ret    

008009b2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009b2:	55                   	push   %ebp
  8009b3:	89 e5                	mov    %esp,%ebp
  8009b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009b8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009bb:	eb 06                	jmp    8009c3 <strcmp+0x11>
		p++, q++;
  8009bd:	83 c1 01             	add    $0x1,%ecx
  8009c0:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8009c3:	0f b6 01             	movzbl (%ecx),%eax
  8009c6:	84 c0                	test   %al,%al
  8009c8:	74 04                	je     8009ce <strcmp+0x1c>
  8009ca:	3a 02                	cmp    (%edx),%al
  8009cc:	74 ef                	je     8009bd <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009ce:	0f b6 c0             	movzbl %al,%eax
  8009d1:	0f b6 12             	movzbl (%edx),%edx
  8009d4:	29 d0                	sub    %edx,%eax
}
  8009d6:	5d                   	pop    %ebp
  8009d7:	c3                   	ret    

008009d8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009d8:	55                   	push   %ebp
  8009d9:	89 e5                	mov    %esp,%ebp
  8009db:	53                   	push   %ebx
  8009dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009df:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009e2:	89 c3                	mov    %eax,%ebx
  8009e4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009e7:	eb 06                	jmp    8009ef <strncmp+0x17>
		n--, p++, q++;
  8009e9:	83 c0 01             	add    $0x1,%eax
  8009ec:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009ef:	39 d8                	cmp    %ebx,%eax
  8009f1:	74 18                	je     800a0b <strncmp+0x33>
  8009f3:	0f b6 08             	movzbl (%eax),%ecx
  8009f6:	84 c9                	test   %cl,%cl
  8009f8:	74 04                	je     8009fe <strncmp+0x26>
  8009fa:	3a 0a                	cmp    (%edx),%cl
  8009fc:	74 eb                	je     8009e9 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009fe:	0f b6 00             	movzbl (%eax),%eax
  800a01:	0f b6 12             	movzbl (%edx),%edx
  800a04:	29 d0                	sub    %edx,%eax
}
  800a06:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a09:	c9                   	leave  
  800a0a:	c3                   	ret    
		return 0;
  800a0b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a10:	eb f4                	jmp    800a06 <strncmp+0x2e>

00800a12 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a12:	55                   	push   %ebp
  800a13:	89 e5                	mov    %esp,%ebp
  800a15:	8b 45 08             	mov    0x8(%ebp),%eax
  800a18:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a1c:	eb 03                	jmp    800a21 <strchr+0xf>
  800a1e:	83 c0 01             	add    $0x1,%eax
  800a21:	0f b6 10             	movzbl (%eax),%edx
  800a24:	84 d2                	test   %dl,%dl
  800a26:	74 06                	je     800a2e <strchr+0x1c>
		if (*s == c)
  800a28:	38 ca                	cmp    %cl,%dl
  800a2a:	75 f2                	jne    800a1e <strchr+0xc>
  800a2c:	eb 05                	jmp    800a33 <strchr+0x21>
			return (char *) s;
	return 0;
  800a2e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a33:	5d                   	pop    %ebp
  800a34:	c3                   	ret    

00800a35 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a35:	55                   	push   %ebp
  800a36:	89 e5                	mov    %esp,%ebp
  800a38:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a3f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a42:	38 ca                	cmp    %cl,%dl
  800a44:	74 09                	je     800a4f <strfind+0x1a>
  800a46:	84 d2                	test   %dl,%dl
  800a48:	74 05                	je     800a4f <strfind+0x1a>
	for (; *s; s++)
  800a4a:	83 c0 01             	add    $0x1,%eax
  800a4d:	eb f0                	jmp    800a3f <strfind+0xa>
			break;
	return (char *) s;
}
  800a4f:	5d                   	pop    %ebp
  800a50:	c3                   	ret    

00800a51 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a51:	55                   	push   %ebp
  800a52:	89 e5                	mov    %esp,%ebp
  800a54:	57                   	push   %edi
  800a55:	56                   	push   %esi
  800a56:	53                   	push   %ebx
  800a57:	8b 55 08             	mov    0x8(%ebp),%edx
  800a5a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  800a5d:	85 c9                	test   %ecx,%ecx
  800a5f:	74 33                	je     800a94 <memset+0x43>
		return v;
	if ((int) v % 4 == 0 && n % 4 == 0) {
  800a61:	89 d0                	mov    %edx,%eax
  800a63:	09 c8                	or     %ecx,%eax
  800a65:	a8 03                	test   $0x3,%al
  800a67:	75 23                	jne    800a8c <memset+0x3b>
		c &= 0xFF;
  800a69:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  800a6d:	89 d8                	mov    %ebx,%eax
  800a6f:	c1 e0 08             	shl    $0x8,%eax
  800a72:	89 df                	mov    %ebx,%edi
  800a74:	c1 e7 18             	shl    $0x18,%edi
  800a77:	89 de                	mov    %ebx,%esi
  800a79:	c1 e6 10             	shl    $0x10,%esi
  800a7c:	09 f7                	or     %esi,%edi
  800a7e:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
		             : "=D"(p), "=c"(n)
		             : "D"(p), "a"(c), "c"(n / 4)
  800a80:	c1 e9 02             	shr    $0x2,%ecx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  800a83:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800a85:	89 d7                	mov    %edx,%edi
  800a87:	fc                   	cld    
  800a88:	f3 ab                	rep stos %eax,%es:(%edi)
  800a8a:	eb 08                	jmp    800a94 <memset+0x43>
		             : "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a8c:	89 d7                	mov    %edx,%edi
  800a8e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a91:	fc                   	cld    
  800a92:	f3 aa                	rep stos %al,%es:(%edi)
		             : "=D"(p), "=c"(n)
		             : "0"(p), "a"(c), "1"(n)
		             : "cc", "memory");
	return v;
}
  800a94:	89 d0                	mov    %edx,%eax
  800a96:	5b                   	pop    %ebx
  800a97:	5e                   	pop    %esi
  800a98:	5f                   	pop    %edi
  800a99:	5d                   	pop    %ebp
  800a9a:	c3                   	ret    

00800a9b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
  800a9e:	57                   	push   %edi
  800a9f:	56                   	push   %esi
  800aa0:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800aa9:	39 c6                	cmp    %eax,%esi
  800aab:	73 32                	jae    800adf <memmove+0x44>
  800aad:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ab0:	39 c2                	cmp    %eax,%edx
  800ab2:	76 2b                	jbe    800adf <memmove+0x44>
		s += n;
		d += n;
  800ab4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  800ab7:	89 d6                	mov    %edx,%esi
  800ab9:	09 fe                	or     %edi,%esi
  800abb:	09 ce                	or     %ecx,%esi
  800abd:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ac3:	75 0e                	jne    800ad3 <memmove+0x38>
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  800ac5:	83 ef 04             	sub    $0x4,%edi
			             "S"(s - 4),
  800ac8:	8d 72 fc             	lea    -0x4(%edx),%esi
			             "c"(n / 4)
  800acb:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  800ace:	fd                   	std    
  800acf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ad1:	eb 09                	jmp    800adc <memmove+0x41>
			             : "cc", "memory");
		else
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  800ad3:	83 ef 01             	sub    $0x1,%edi
			             "S"(s - 1),
  800ad6:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  800ad9:	fd                   	std    
  800ada:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             "c"(n)
			             : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800adc:	fc                   	cld    
  800add:	eb 1a                	jmp    800af9 <memmove+0x5e>
	} else {
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  800adf:	89 f2                	mov    %esi,%edx
  800ae1:	09 c2                	or     %eax,%edx
  800ae3:	09 ca                	or     %ecx,%edx
  800ae5:	f6 c2 03             	test   $0x3,%dl
  800ae8:	75 0a                	jne    800af4 <memmove+0x59>
			asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800aea:	c1 e9 02             	shr    $0x2,%ecx
  800aed:	89 c7                	mov    %eax,%edi
  800aef:	fc                   	cld    
  800af0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800af2:	eb 05                	jmp    800af9 <memmove+0x5e>
			             : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800af4:	89 c7                	mov    %eax,%edi
  800af6:	fc                   	cld    
  800af7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             : "cc", "memory");
	}
	return dst;
}
  800af9:	5e                   	pop    %esi
  800afa:	5f                   	pop    %edi
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    

00800afd <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b03:	ff 75 10             	push   0x10(%ebp)
  800b06:	ff 75 0c             	push   0xc(%ebp)
  800b09:	ff 75 08             	push   0x8(%ebp)
  800b0c:	e8 8a ff ff ff       	call   800a9b <memmove>
}
  800b11:	c9                   	leave  
  800b12:	c3                   	ret    

00800b13 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b13:	55                   	push   %ebp
  800b14:	89 e5                	mov    %esp,%ebp
  800b16:	56                   	push   %esi
  800b17:	53                   	push   %ebx
  800b18:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b1e:	89 c6                	mov    %eax,%esi
  800b20:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b23:	eb 06                	jmp    800b2b <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b25:	83 c0 01             	add    $0x1,%eax
  800b28:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800b2b:	39 f0                	cmp    %esi,%eax
  800b2d:	74 14                	je     800b43 <memcmp+0x30>
		if (*s1 != *s2)
  800b2f:	0f b6 08             	movzbl (%eax),%ecx
  800b32:	0f b6 1a             	movzbl (%edx),%ebx
  800b35:	38 d9                	cmp    %bl,%cl
  800b37:	74 ec                	je     800b25 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800b39:	0f b6 c1             	movzbl %cl,%eax
  800b3c:	0f b6 db             	movzbl %bl,%ebx
  800b3f:	29 d8                	sub    %ebx,%eax
  800b41:	eb 05                	jmp    800b48 <memcmp+0x35>
	}

	return 0;
  800b43:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b48:	5b                   	pop    %ebx
  800b49:	5e                   	pop    %esi
  800b4a:	5d                   	pop    %ebp
  800b4b:	c3                   	ret    

00800b4c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b4c:	55                   	push   %ebp
  800b4d:	89 e5                	mov    %esp,%ebp
  800b4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b55:	89 c2                	mov    %eax,%edx
  800b57:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b5a:	eb 03                	jmp    800b5f <memfind+0x13>
  800b5c:	83 c0 01             	add    $0x1,%eax
  800b5f:	39 d0                	cmp    %edx,%eax
  800b61:	73 04                	jae    800b67 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b63:	38 08                	cmp    %cl,(%eax)
  800b65:	75 f5                	jne    800b5c <memfind+0x10>
			break;
	return (void *) s;
}
  800b67:	5d                   	pop    %ebp
  800b68:	c3                   	ret    

00800b69 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b69:	55                   	push   %ebp
  800b6a:	89 e5                	mov    %esp,%ebp
  800b6c:	57                   	push   %edi
  800b6d:	56                   	push   %esi
  800b6e:	53                   	push   %ebx
  800b6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b72:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b75:	eb 03                	jmp    800b7a <strtol+0x11>
		s++;
  800b77:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b7a:	0f b6 02             	movzbl (%edx),%eax
  800b7d:	3c 20                	cmp    $0x20,%al
  800b7f:	74 f6                	je     800b77 <strtol+0xe>
  800b81:	3c 09                	cmp    $0x9,%al
  800b83:	74 f2                	je     800b77 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b85:	3c 2b                	cmp    $0x2b,%al
  800b87:	74 2a                	je     800bb3 <strtol+0x4a>
	int neg = 0;
  800b89:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b8e:	3c 2d                	cmp    $0x2d,%al
  800b90:	74 2b                	je     800bbd <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b92:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b98:	75 0f                	jne    800ba9 <strtol+0x40>
  800b9a:	80 3a 30             	cmpb   $0x30,(%edx)
  800b9d:	74 28                	je     800bc7 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b9f:	85 db                	test   %ebx,%ebx
  800ba1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ba6:	0f 44 d8             	cmove  %eax,%ebx
  800ba9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bae:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800bb1:	eb 46                	jmp    800bf9 <strtol+0x90>
		s++;
  800bb3:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800bb6:	bf 00 00 00 00       	mov    $0x0,%edi
  800bbb:	eb d5                	jmp    800b92 <strtol+0x29>
		s++, neg = 1;
  800bbd:	83 c2 01             	add    $0x1,%edx
  800bc0:	bf 01 00 00 00       	mov    $0x1,%edi
  800bc5:	eb cb                	jmp    800b92 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bc7:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bcb:	74 0e                	je     800bdb <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800bcd:	85 db                	test   %ebx,%ebx
  800bcf:	75 d8                	jne    800ba9 <strtol+0x40>
		s++, base = 8;
  800bd1:	83 c2 01             	add    $0x1,%edx
  800bd4:	bb 08 00 00 00       	mov    $0x8,%ebx
  800bd9:	eb ce                	jmp    800ba9 <strtol+0x40>
		s += 2, base = 16;
  800bdb:	83 c2 02             	add    $0x2,%edx
  800bde:	bb 10 00 00 00       	mov    $0x10,%ebx
  800be3:	eb c4                	jmp    800ba9 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800be5:	0f be c0             	movsbl %al,%eax
  800be8:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800beb:	3b 45 10             	cmp    0x10(%ebp),%eax
  800bee:	7d 3a                	jge    800c2a <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800bf0:	83 c2 01             	add    $0x1,%edx
  800bf3:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800bf7:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800bf9:	0f b6 02             	movzbl (%edx),%eax
  800bfc:	8d 70 d0             	lea    -0x30(%eax),%esi
  800bff:	89 f3                	mov    %esi,%ebx
  800c01:	80 fb 09             	cmp    $0x9,%bl
  800c04:	76 df                	jbe    800be5 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800c06:	8d 70 9f             	lea    -0x61(%eax),%esi
  800c09:	89 f3                	mov    %esi,%ebx
  800c0b:	80 fb 19             	cmp    $0x19,%bl
  800c0e:	77 08                	ja     800c18 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800c10:	0f be c0             	movsbl %al,%eax
  800c13:	83 e8 57             	sub    $0x57,%eax
  800c16:	eb d3                	jmp    800beb <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800c18:	8d 70 bf             	lea    -0x41(%eax),%esi
  800c1b:	89 f3                	mov    %esi,%ebx
  800c1d:	80 fb 19             	cmp    $0x19,%bl
  800c20:	77 08                	ja     800c2a <strtol+0xc1>
			dig = *s - 'A' + 10;
  800c22:	0f be c0             	movsbl %al,%eax
  800c25:	83 e8 37             	sub    $0x37,%eax
  800c28:	eb c1                	jmp    800beb <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c2a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c2e:	74 05                	je     800c35 <strtol+0xcc>
		*endptr = (char *) s;
  800c30:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c33:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800c35:	89 c8                	mov    %ecx,%eax
  800c37:	f7 d8                	neg    %eax
  800c39:	85 ff                	test   %edi,%edi
  800c3b:	0f 45 c8             	cmovne %eax,%ecx
}
  800c3e:	89 c8                	mov    %ecx,%eax
  800c40:	5b                   	pop    %ebx
  800c41:	5e                   	pop    %esi
  800c42:	5f                   	pop    %edi
  800c43:	5d                   	pop    %ebp
  800c44:	c3                   	ret    
  800c45:	66 90                	xchg   %ax,%ax
  800c47:	66 90                	xchg   %ax,%ax
  800c49:	66 90                	xchg   %ax,%ax
  800c4b:	66 90                	xchg   %ax,%ax
  800c4d:	66 90                	xchg   %ax,%ax
  800c4f:	90                   	nop

00800c50 <__udivdi3>:
  800c50:	f3 0f 1e fb          	endbr32 
  800c54:	55                   	push   %ebp
  800c55:	57                   	push   %edi
  800c56:	56                   	push   %esi
  800c57:	53                   	push   %ebx
  800c58:	83 ec 1c             	sub    $0x1c,%esp
  800c5b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800c5f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800c63:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c67:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800c6b:	85 c0                	test   %eax,%eax
  800c6d:	75 19                	jne    800c88 <__udivdi3+0x38>
  800c6f:	39 f3                	cmp    %esi,%ebx
  800c71:	76 4d                	jbe    800cc0 <__udivdi3+0x70>
  800c73:	31 ff                	xor    %edi,%edi
  800c75:	89 e8                	mov    %ebp,%eax
  800c77:	89 f2                	mov    %esi,%edx
  800c79:	f7 f3                	div    %ebx
  800c7b:	89 fa                	mov    %edi,%edx
  800c7d:	83 c4 1c             	add    $0x1c,%esp
  800c80:	5b                   	pop    %ebx
  800c81:	5e                   	pop    %esi
  800c82:	5f                   	pop    %edi
  800c83:	5d                   	pop    %ebp
  800c84:	c3                   	ret    
  800c85:	8d 76 00             	lea    0x0(%esi),%esi
  800c88:	39 f0                	cmp    %esi,%eax
  800c8a:	76 14                	jbe    800ca0 <__udivdi3+0x50>
  800c8c:	31 ff                	xor    %edi,%edi
  800c8e:	31 c0                	xor    %eax,%eax
  800c90:	89 fa                	mov    %edi,%edx
  800c92:	83 c4 1c             	add    $0x1c,%esp
  800c95:	5b                   	pop    %ebx
  800c96:	5e                   	pop    %esi
  800c97:	5f                   	pop    %edi
  800c98:	5d                   	pop    %ebp
  800c99:	c3                   	ret    
  800c9a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ca0:	0f bd f8             	bsr    %eax,%edi
  800ca3:	83 f7 1f             	xor    $0x1f,%edi
  800ca6:	75 48                	jne    800cf0 <__udivdi3+0xa0>
  800ca8:	39 f0                	cmp    %esi,%eax
  800caa:	72 06                	jb     800cb2 <__udivdi3+0x62>
  800cac:	31 c0                	xor    %eax,%eax
  800cae:	39 eb                	cmp    %ebp,%ebx
  800cb0:	77 de                	ja     800c90 <__udivdi3+0x40>
  800cb2:	b8 01 00 00 00       	mov    $0x1,%eax
  800cb7:	eb d7                	jmp    800c90 <__udivdi3+0x40>
  800cb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800cc0:	89 d9                	mov    %ebx,%ecx
  800cc2:	85 db                	test   %ebx,%ebx
  800cc4:	75 0b                	jne    800cd1 <__udivdi3+0x81>
  800cc6:	b8 01 00 00 00       	mov    $0x1,%eax
  800ccb:	31 d2                	xor    %edx,%edx
  800ccd:	f7 f3                	div    %ebx
  800ccf:	89 c1                	mov    %eax,%ecx
  800cd1:	31 d2                	xor    %edx,%edx
  800cd3:	89 f0                	mov    %esi,%eax
  800cd5:	f7 f1                	div    %ecx
  800cd7:	89 c6                	mov    %eax,%esi
  800cd9:	89 e8                	mov    %ebp,%eax
  800cdb:	89 f7                	mov    %esi,%edi
  800cdd:	f7 f1                	div    %ecx
  800cdf:	89 fa                	mov    %edi,%edx
  800ce1:	83 c4 1c             	add    $0x1c,%esp
  800ce4:	5b                   	pop    %ebx
  800ce5:	5e                   	pop    %esi
  800ce6:	5f                   	pop    %edi
  800ce7:	5d                   	pop    %ebp
  800ce8:	c3                   	ret    
  800ce9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800cf0:	89 f9                	mov    %edi,%ecx
  800cf2:	ba 20 00 00 00       	mov    $0x20,%edx
  800cf7:	29 fa                	sub    %edi,%edx
  800cf9:	d3 e0                	shl    %cl,%eax
  800cfb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cff:	89 d1                	mov    %edx,%ecx
  800d01:	89 d8                	mov    %ebx,%eax
  800d03:	d3 e8                	shr    %cl,%eax
  800d05:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800d09:	09 c1                	or     %eax,%ecx
  800d0b:	89 f0                	mov    %esi,%eax
  800d0d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d11:	89 f9                	mov    %edi,%ecx
  800d13:	d3 e3                	shl    %cl,%ebx
  800d15:	89 d1                	mov    %edx,%ecx
  800d17:	d3 e8                	shr    %cl,%eax
  800d19:	89 f9                	mov    %edi,%ecx
  800d1b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800d1f:	89 eb                	mov    %ebp,%ebx
  800d21:	d3 e6                	shl    %cl,%esi
  800d23:	89 d1                	mov    %edx,%ecx
  800d25:	d3 eb                	shr    %cl,%ebx
  800d27:	09 f3                	or     %esi,%ebx
  800d29:	89 c6                	mov    %eax,%esi
  800d2b:	89 f2                	mov    %esi,%edx
  800d2d:	89 d8                	mov    %ebx,%eax
  800d2f:	f7 74 24 08          	divl   0x8(%esp)
  800d33:	89 d6                	mov    %edx,%esi
  800d35:	89 c3                	mov    %eax,%ebx
  800d37:	f7 64 24 0c          	mull   0xc(%esp)
  800d3b:	39 d6                	cmp    %edx,%esi
  800d3d:	72 19                	jb     800d58 <__udivdi3+0x108>
  800d3f:	89 f9                	mov    %edi,%ecx
  800d41:	d3 e5                	shl    %cl,%ebp
  800d43:	39 c5                	cmp    %eax,%ebp
  800d45:	73 04                	jae    800d4b <__udivdi3+0xfb>
  800d47:	39 d6                	cmp    %edx,%esi
  800d49:	74 0d                	je     800d58 <__udivdi3+0x108>
  800d4b:	89 d8                	mov    %ebx,%eax
  800d4d:	31 ff                	xor    %edi,%edi
  800d4f:	e9 3c ff ff ff       	jmp    800c90 <__udivdi3+0x40>
  800d54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d58:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800d5b:	31 ff                	xor    %edi,%edi
  800d5d:	e9 2e ff ff ff       	jmp    800c90 <__udivdi3+0x40>
  800d62:	66 90                	xchg   %ax,%ax
  800d64:	66 90                	xchg   %ax,%ax
  800d66:	66 90                	xchg   %ax,%ax
  800d68:	66 90                	xchg   %ax,%ax
  800d6a:	66 90                	xchg   %ax,%ax
  800d6c:	66 90                	xchg   %ax,%ax
  800d6e:	66 90                	xchg   %ax,%ax

00800d70 <__umoddi3>:
  800d70:	f3 0f 1e fb          	endbr32 
  800d74:	55                   	push   %ebp
  800d75:	57                   	push   %edi
  800d76:	56                   	push   %esi
  800d77:	53                   	push   %ebx
  800d78:	83 ec 1c             	sub    $0x1c,%esp
  800d7b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800d7f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800d83:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  800d87:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  800d8b:	89 f0                	mov    %esi,%eax
  800d8d:	89 da                	mov    %ebx,%edx
  800d8f:	85 ff                	test   %edi,%edi
  800d91:	75 15                	jne    800da8 <__umoddi3+0x38>
  800d93:	39 dd                	cmp    %ebx,%ebp
  800d95:	76 39                	jbe    800dd0 <__umoddi3+0x60>
  800d97:	f7 f5                	div    %ebp
  800d99:	89 d0                	mov    %edx,%eax
  800d9b:	31 d2                	xor    %edx,%edx
  800d9d:	83 c4 1c             	add    $0x1c,%esp
  800da0:	5b                   	pop    %ebx
  800da1:	5e                   	pop    %esi
  800da2:	5f                   	pop    %edi
  800da3:	5d                   	pop    %ebp
  800da4:	c3                   	ret    
  800da5:	8d 76 00             	lea    0x0(%esi),%esi
  800da8:	39 df                	cmp    %ebx,%edi
  800daa:	77 f1                	ja     800d9d <__umoddi3+0x2d>
  800dac:	0f bd cf             	bsr    %edi,%ecx
  800daf:	83 f1 1f             	xor    $0x1f,%ecx
  800db2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800db6:	75 40                	jne    800df8 <__umoddi3+0x88>
  800db8:	39 df                	cmp    %ebx,%edi
  800dba:	72 04                	jb     800dc0 <__umoddi3+0x50>
  800dbc:	39 f5                	cmp    %esi,%ebp
  800dbe:	77 dd                	ja     800d9d <__umoddi3+0x2d>
  800dc0:	89 da                	mov    %ebx,%edx
  800dc2:	89 f0                	mov    %esi,%eax
  800dc4:	29 e8                	sub    %ebp,%eax
  800dc6:	19 fa                	sbb    %edi,%edx
  800dc8:	eb d3                	jmp    800d9d <__umoddi3+0x2d>
  800dca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800dd0:	89 e9                	mov    %ebp,%ecx
  800dd2:	85 ed                	test   %ebp,%ebp
  800dd4:	75 0b                	jne    800de1 <__umoddi3+0x71>
  800dd6:	b8 01 00 00 00       	mov    $0x1,%eax
  800ddb:	31 d2                	xor    %edx,%edx
  800ddd:	f7 f5                	div    %ebp
  800ddf:	89 c1                	mov    %eax,%ecx
  800de1:	89 d8                	mov    %ebx,%eax
  800de3:	31 d2                	xor    %edx,%edx
  800de5:	f7 f1                	div    %ecx
  800de7:	89 f0                	mov    %esi,%eax
  800de9:	f7 f1                	div    %ecx
  800deb:	89 d0                	mov    %edx,%eax
  800ded:	31 d2                	xor    %edx,%edx
  800def:	eb ac                	jmp    800d9d <__umoddi3+0x2d>
  800df1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800df8:	8b 44 24 04          	mov    0x4(%esp),%eax
  800dfc:	ba 20 00 00 00       	mov    $0x20,%edx
  800e01:	29 c2                	sub    %eax,%edx
  800e03:	89 c1                	mov    %eax,%ecx
  800e05:	89 e8                	mov    %ebp,%eax
  800e07:	d3 e7                	shl    %cl,%edi
  800e09:	89 d1                	mov    %edx,%ecx
  800e0b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e0f:	d3 e8                	shr    %cl,%eax
  800e11:	89 c1                	mov    %eax,%ecx
  800e13:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e17:	09 f9                	or     %edi,%ecx
  800e19:	89 df                	mov    %ebx,%edi
  800e1b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e1f:	89 c1                	mov    %eax,%ecx
  800e21:	d3 e5                	shl    %cl,%ebp
  800e23:	89 d1                	mov    %edx,%ecx
  800e25:	d3 ef                	shr    %cl,%edi
  800e27:	89 c1                	mov    %eax,%ecx
  800e29:	89 f0                	mov    %esi,%eax
  800e2b:	d3 e3                	shl    %cl,%ebx
  800e2d:	89 d1                	mov    %edx,%ecx
  800e2f:	89 fa                	mov    %edi,%edx
  800e31:	d3 e8                	shr    %cl,%eax
  800e33:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e38:	09 d8                	or     %ebx,%eax
  800e3a:	f7 74 24 08          	divl   0x8(%esp)
  800e3e:	89 d3                	mov    %edx,%ebx
  800e40:	d3 e6                	shl    %cl,%esi
  800e42:	f7 e5                	mul    %ebp
  800e44:	89 c7                	mov    %eax,%edi
  800e46:	89 d1                	mov    %edx,%ecx
  800e48:	39 d3                	cmp    %edx,%ebx
  800e4a:	72 06                	jb     800e52 <__umoddi3+0xe2>
  800e4c:	75 0e                	jne    800e5c <__umoddi3+0xec>
  800e4e:	39 c6                	cmp    %eax,%esi
  800e50:	73 0a                	jae    800e5c <__umoddi3+0xec>
  800e52:	29 e8                	sub    %ebp,%eax
  800e54:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800e58:	89 d1                	mov    %edx,%ecx
  800e5a:	89 c7                	mov    %eax,%edi
  800e5c:	89 f5                	mov    %esi,%ebp
  800e5e:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e62:	29 fd                	sub    %edi,%ebp
  800e64:	19 cb                	sbb    %ecx,%ebx
  800e66:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800e6b:	89 d8                	mov    %ebx,%eax
  800e6d:	d3 e0                	shl    %cl,%eax
  800e6f:	89 f1                	mov    %esi,%ecx
  800e71:	d3 ed                	shr    %cl,%ebp
  800e73:	d3 eb                	shr    %cl,%ebx
  800e75:	09 e8                	or     %ebp,%eax
  800e77:	89 da                	mov    %ebx,%edx
  800e79:	83 c4 1c             	add    $0x1c,%esp
  800e7c:	5b                   	pop    %ebx
  800e7d:	5e                   	pop    %esi
  800e7e:	5f                   	pop    %edi
  800e7f:	5d                   	pop    %ebp
  800e80:	c3                   	ret    
