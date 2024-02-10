
obj/user/breakpoint:     formato del fichero elf32-i386


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
  80002c:	e8 04 00 00 00       	call   800035 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
	asm volatile("int $3");
  800033:	cc                   	int3   
}
  800034:	c3                   	ret    

00800035 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800035:	55                   	push   %ebp
  800036:	89 e5                	mov    %esp,%ebp
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80003d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	envid_t id = sys_getenvid();
  800040:	e8 04 01 00 00       	call   800149 <sys_getenvid>
	if (id >= 0)
  800045:	85 c0                	test   %eax,%eax
  800047:	78 15                	js     80005e <libmain+0x29>
		thisenv = &envs[ENVX(id)];
  800049:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004e:	69 c0 88 00 00 00    	imul   $0x88,%eax,%eax
  800054:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800059:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005e:	85 db                	test   %ebx,%ebx
  800060:	7e 07                	jle    800069 <libmain+0x34>
		binaryname = argv[0];
  800062:	8b 06                	mov    (%esi),%eax
  800064:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800069:	83 ec 08             	sub    $0x8,%esp
  80006c:	56                   	push   %esi
  80006d:	53                   	push   %ebx
  80006e:	e8 c0 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800073:	e8 0a 00 00 00       	call   800082 <exit>
}
  800078:	83 c4 10             	add    $0x10,%esp
  80007b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007e:	5b                   	pop    %ebx
  80007f:	5e                   	pop    %esi
  800080:	5d                   	pop    %ebp
  800081:	c3                   	ret    

00800082 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800082:	55                   	push   %ebp
  800083:	89 e5                	mov    %esp,%ebp
  800085:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800088:	6a 00                	push   $0x0
  80008a:	e8 98 00 00 00       	call   800127 <sys_env_destroy>
}
  80008f:	83 c4 10             	add    $0x10,%esp
  800092:	c9                   	leave  
  800093:	c3                   	ret    

00800094 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	57                   	push   %edi
  800098:	56                   	push   %esi
  800099:	53                   	push   %ebx
  80009a:	83 ec 1c             	sub    $0x1c,%esp
  80009d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8000a0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8000a3:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile(
  8000a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000ab:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000ae:	8b 75 14             	mov    0x14(%ebp),%esi
  8000b1:	cd 30                	int    $0x30
	        "int %1\n"
	        : "=a"(ret)
	        : "i"(T_SYSCALL), "a"(num), "d"(a1), "c"(a2), "b"(a3), "D"(a4), "S"(a5)
	        : "cc", "memory");

	if (check && ret > 0)
  8000b3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000b7:	74 04                	je     8000bd <syscall+0x29>
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	7f 08                	jg     8000c5 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  8000bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000c0:	5b                   	pop    %ebx
  8000c1:	5e                   	pop    %esi
  8000c2:	5f                   	pop    %edi
  8000c3:	5d                   	pop    %ebp
  8000c4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8000c5:	83 ec 0c             	sub    $0xc,%esp
  8000c8:	50                   	push   %eax
  8000c9:	ff 75 e0             	push   -0x20(%ebp)
  8000cc:	68 8a 0e 80 00       	push   $0x800e8a
  8000d1:	6a 1e                	push   $0x1e
  8000d3:	68 a7 0e 80 00       	push   $0x800ea7
  8000d8:	e8 f7 01 00 00       	call   8002d4 <_panic>

008000dd <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  8000dd:	55                   	push   %ebp
  8000de:	89 e5                	mov    %esp,%ebp
  8000e0:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t) s, len, 0, 0, 0);
  8000e3:	6a 00                	push   $0x0
  8000e5:	6a 00                	push   $0x0
  8000e7:	6a 00                	push   $0x0
  8000e9:	ff 75 0c             	push   0xc(%ebp)
  8000ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8000f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000f9:	e8 96 ff ff ff       	call   800094 <syscall>
}
  8000fe:	83 c4 10             	add    $0x10,%esp
  800101:	c9                   	leave  
  800102:	c3                   	ret    

00800103 <sys_cgetc>:

int
sys_cgetc(void)
{
  800103:	55                   	push   %ebp
  800104:	89 e5                	mov    %esp,%ebp
  800106:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800109:	6a 00                	push   $0x0
  80010b:	6a 00                	push   $0x0
  80010d:	6a 00                	push   $0x0
  80010f:	6a 00                	push   $0x0
  800111:	b9 00 00 00 00       	mov    $0x0,%ecx
  800116:	ba 00 00 00 00       	mov    $0x0,%edx
  80011b:	b8 01 00 00 00       	mov    $0x1,%eax
  800120:	e8 6f ff ff ff       	call   800094 <syscall>
}
  800125:	c9                   	leave  
  800126:	c3                   	ret    

00800127 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800127:	55                   	push   %ebp
  800128:	89 e5                	mov    %esp,%ebp
  80012a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80012d:	6a 00                	push   $0x0
  80012f:	6a 00                	push   $0x0
  800131:	6a 00                	push   $0x0
  800133:	6a 00                	push   $0x0
  800135:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800138:	ba 01 00 00 00       	mov    $0x1,%edx
  80013d:	b8 03 00 00 00       	mov    $0x3,%eax
  800142:	e8 4d ff ff ff       	call   800094 <syscall>
}
  800147:	c9                   	leave  
  800148:	c3                   	ret    

00800149 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800149:	55                   	push   %ebp
  80014a:	89 e5                	mov    %esp,%ebp
  80014c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  80014f:	6a 00                	push   $0x0
  800151:	6a 00                	push   $0x0
  800153:	6a 00                	push   $0x0
  800155:	6a 00                	push   $0x0
  800157:	b9 00 00 00 00       	mov    $0x0,%ecx
  80015c:	ba 00 00 00 00       	mov    $0x0,%edx
  800161:	b8 02 00 00 00       	mov    $0x2,%eax
  800166:	e8 29 ff ff ff       	call   800094 <syscall>
}
  80016b:	c9                   	leave  
  80016c:	c3                   	ret    

0080016d <sys_yield>:

void
sys_yield(void)
{
  80016d:	55                   	push   %ebp
  80016e:	89 e5                	mov    %esp,%ebp
  800170:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800173:	6a 00                	push   $0x0
  800175:	6a 00                	push   $0x0
  800177:	6a 00                	push   $0x0
  800179:	6a 00                	push   $0x0
  80017b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800180:	ba 00 00 00 00       	mov    $0x0,%edx
  800185:	b8 0a 00 00 00       	mov    $0xa,%eax
  80018a:	e8 05 ff ff ff       	call   800094 <syscall>
}
  80018f:	83 c4 10             	add    $0x10,%esp
  800192:	c9                   	leave  
  800193:	c3                   	ret    

00800194 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  80019a:	6a 00                	push   $0x0
  80019c:	6a 00                	push   $0x0
  80019e:	ff 75 10             	push   0x10(%ebp)
  8001a1:	ff 75 0c             	push   0xc(%ebp)
  8001a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a7:	ba 01 00 00 00       	mov    $0x1,%edx
  8001ac:	b8 04 00 00 00       	mov    $0x4,%eax
  8001b1:	e8 de fe ff ff       	call   800094 <syscall>
}
  8001b6:	c9                   	leave  
  8001b7:	c3                   	ret    

008001b8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map,
  8001be:	ff 75 18             	push   0x18(%ebp)
  8001c1:	ff 75 14             	push   0x14(%ebp)
  8001c4:	ff 75 10             	push   0x10(%ebp)
  8001c7:	ff 75 0c             	push   0xc(%ebp)
  8001ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001cd:	ba 01 00 00 00       	mov    $0x1,%edx
  8001d2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001d7:	e8 b8 fe ff ff       	call   800094 <syscall>
	               srcenv,
	               (uint32_t) srcva,
	               dstenv,
	               (uint32_t) dstva,
	               perm);
}
  8001dc:	c9                   	leave  
  8001dd:	c3                   	ret    

008001de <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001de:	55                   	push   %ebp
  8001df:	89 e5                	mov    %esp,%ebp
  8001e1:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8001e4:	6a 00                	push   $0x0
  8001e6:	6a 00                	push   $0x0
  8001e8:	6a 00                	push   $0x0
  8001ea:	ff 75 0c             	push   0xc(%ebp)
  8001ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001f0:	ba 01 00 00 00       	mov    $0x1,%edx
  8001f5:	b8 06 00 00 00       	mov    $0x6,%eax
  8001fa:	e8 95 fe ff ff       	call   800094 <syscall>
}
  8001ff:	c9                   	leave  
  800200:	c3                   	ret    

00800201 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800201:	55                   	push   %ebp
  800202:	89 e5                	mov    %esp,%ebp
  800204:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800207:	6a 00                	push   $0x0
  800209:	6a 00                	push   $0x0
  80020b:	6a 00                	push   $0x0
  80020d:	ff 75 0c             	push   0xc(%ebp)
  800210:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800213:	ba 01 00 00 00       	mov    $0x1,%edx
  800218:	b8 08 00 00 00       	mov    $0x8,%eax
  80021d:	e8 72 fe ff ff       	call   800094 <syscall>
}
  800222:	c9                   	leave  
  800223:	c3                   	ret    

00800224 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800224:	55                   	push   %ebp
  800225:	89 e5                	mov    %esp,%ebp
  800227:	83 ec 08             	sub    $0x8,%esp
	return syscall(
  80022a:	6a 00                	push   $0x0
  80022c:	6a 00                	push   $0x0
  80022e:	6a 00                	push   $0x0
  800230:	ff 75 0c             	push   0xc(%ebp)
  800233:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800236:	ba 01 00 00 00       	mov    $0x1,%edx
  80023b:	b8 09 00 00 00       	mov    $0x9,%eax
  800240:	e8 4f fe ff ff       	call   800094 <syscall>
	        SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800245:	c9                   	leave  
  800246:	c3                   	ret    

00800247 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800247:	55                   	push   %ebp
  800248:	89 e5                	mov    %esp,%ebp
  80024a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  80024d:	6a 00                	push   $0x0
  80024f:	ff 75 14             	push   0x14(%ebp)
  800252:	ff 75 10             	push   0x10(%ebp)
  800255:	ff 75 0c             	push   0xc(%ebp)
  800258:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80025b:	ba 00 00 00 00       	mov    $0x0,%edx
  800260:	b8 0b 00 00 00       	mov    $0xb,%eax
  800265:	e8 2a fe ff ff       	call   800094 <syscall>
}
  80026a:	c9                   	leave  
  80026b:	c3                   	ret    

0080026c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t) dstva, 0, 0, 0, 0);
  800272:	6a 00                	push   $0x0
  800274:	6a 00                	push   $0x0
  800276:	6a 00                	push   $0x0
  800278:	6a 00                	push   $0x0
  80027a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80027d:	ba 01 00 00 00       	mov    $0x1,%edx
  800282:	b8 0c 00 00 00       	mov    $0xc,%eax
  800287:	e8 08 fe ff ff       	call   800094 <syscall>
}
  80028c:	c9                   	leave  
  80028d:	c3                   	ret    

0080028e <sys_get_priority>:

// Get priority of the current process
int
sys_get_priority(void)
{
  80028e:	55                   	push   %ebp
  80028f:	89 e5                	mov    %esp,%ebp
  800291:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_get_priority, 0, 0, 0, 0, 0, 0);
  800294:	6a 00                	push   $0x0
  800296:	6a 00                	push   $0x0
  800298:	6a 00                	push   $0x0
  80029a:	6a 00                	push   $0x0
  80029c:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8002a6:	b8 0d 00 00 00       	mov    $0xd,%eax
  8002ab:	e8 e4 fd ff ff       	call   800094 <syscall>
}
  8002b0:	c9                   	leave  
  8002b1:	c3                   	ret    

008002b2 <sys_set_priority>:

// Get priority of the current process
int
sys_set_priority(unsigned int priority)
{
  8002b2:	55                   	push   %ebp
  8002b3:	89 e5                	mov    %esp,%ebp
  8002b5:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, (uint32_t) priority, 0, 0, 0, 0);
  8002b8:	6a 00                	push   $0x0
  8002ba:	6a 00                	push   $0x0
  8002bc:	6a 00                	push   $0x0
  8002be:	6a 00                	push   $0x0
  8002c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c8:	b8 0e 00 00 00       	mov    $0xe,%eax
  8002cd:	e8 c2 fd ff ff       	call   800094 <syscall>
}
  8002d2:	c9                   	leave  
  8002d3:	c3                   	ret    

008002d4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002d4:	55                   	push   %ebp
  8002d5:	89 e5                	mov    %esp,%ebp
  8002d7:	56                   	push   %esi
  8002d8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002d9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002dc:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8002e2:	e8 62 fe ff ff       	call   800149 <sys_getenvid>
  8002e7:	83 ec 0c             	sub    $0xc,%esp
  8002ea:	ff 75 0c             	push   0xc(%ebp)
  8002ed:	ff 75 08             	push   0x8(%ebp)
  8002f0:	56                   	push   %esi
  8002f1:	50                   	push   %eax
  8002f2:	68 b8 0e 80 00       	push   $0x800eb8
  8002f7:	e8 b3 00 00 00       	call   8003af <cprintf>
	        sys_getenvid(),
	        binaryname,
	        file,
	        line);
	vcprintf(fmt, ap);
  8002fc:	83 c4 18             	add    $0x18,%esp
  8002ff:	53                   	push   %ebx
  800300:	ff 75 10             	push   0x10(%ebp)
  800303:	e8 56 00 00 00       	call   80035e <vcprintf>
	cprintf("\n");
  800308:	c7 04 24 db 0e 80 00 	movl   $0x800edb,(%esp)
  80030f:	e8 9b 00 00 00       	call   8003af <cprintf>
  800314:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800317:	cc                   	int3   
  800318:	eb fd                	jmp    800317 <_panic+0x43>

0080031a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80031a:	55                   	push   %ebp
  80031b:	89 e5                	mov    %esp,%ebp
  80031d:	53                   	push   %ebx
  80031e:	83 ec 04             	sub    $0x4,%esp
  800321:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800324:	8b 13                	mov    (%ebx),%edx
  800326:	8d 42 01             	lea    0x1(%edx),%eax
  800329:	89 03                	mov    %eax,(%ebx)
  80032b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80032e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256 - 1) {
  800332:	3d ff 00 00 00       	cmp    $0xff,%eax
  800337:	74 09                	je     800342 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800339:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80033d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800340:	c9                   	leave  
  800341:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800342:	83 ec 08             	sub    $0x8,%esp
  800345:	68 ff 00 00 00       	push   $0xff
  80034a:	8d 43 08             	lea    0x8(%ebx),%eax
  80034d:	50                   	push   %eax
  80034e:	e8 8a fd ff ff       	call   8000dd <sys_cputs>
		b->idx = 0;
  800353:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800359:	83 c4 10             	add    $0x10,%esp
  80035c:	eb db                	jmp    800339 <putch+0x1f>

0080035e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80035e:	55                   	push   %ebp
  80035f:	89 e5                	mov    %esp,%ebp
  800361:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800367:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80036e:	00 00 00 
	b.cnt = 0;
  800371:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800378:	00 00 00 
	vprintfmt((void *) putch, &b, fmt, ap);
  80037b:	ff 75 0c             	push   0xc(%ebp)
  80037e:	ff 75 08             	push   0x8(%ebp)
  800381:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800387:	50                   	push   %eax
  800388:	68 1a 03 80 00       	push   $0x80031a
  80038d:	e8 74 01 00 00       	call   800506 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800392:	83 c4 08             	add    $0x8,%esp
  800395:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  80039b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003a1:	50                   	push   %eax
  8003a2:	e8 36 fd ff ff       	call   8000dd <sys_cputs>

	return b.cnt;
}
  8003a7:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003ad:	c9                   	leave  
  8003ae:	c3                   	ret    

008003af <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003af:	55                   	push   %ebp
  8003b0:	89 e5                	mov    %esp,%ebp
  8003b2:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003b5:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003b8:	50                   	push   %eax
  8003b9:	ff 75 08             	push   0x8(%ebp)
  8003bc:	e8 9d ff ff ff       	call   80035e <vcprintf>
	va_end(ap);

	return cnt;
}
  8003c1:	c9                   	leave  
  8003c2:	c3                   	ret    

008003c3 <printnum>:
         void *putdat,
         unsigned long long num,
         unsigned base,
         int width,
         int padc)
{
  8003c3:	55                   	push   %ebp
  8003c4:	89 e5                	mov    %esp,%ebp
  8003c6:	57                   	push   %edi
  8003c7:	56                   	push   %esi
  8003c8:	53                   	push   %ebx
  8003c9:	83 ec 1c             	sub    $0x1c,%esp
  8003cc:	89 c7                	mov    %eax,%edi
  8003ce:	89 d6                	mov    %edx,%esi
  8003d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003d6:	89 d1                	mov    %edx,%ecx
  8003d8:	89 c2                	mov    %eax,%edx
  8003da:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003dd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8003e0:	8b 45 10             	mov    0x10(%ebp),%eax
  8003e3:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003e6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003e9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003f0:	39 c2                	cmp    %eax,%edx
  8003f2:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8003f5:	72 3e                	jb     800435 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003f7:	83 ec 0c             	sub    $0xc,%esp
  8003fa:	ff 75 18             	push   0x18(%ebp)
  8003fd:	83 eb 01             	sub    $0x1,%ebx
  800400:	53                   	push   %ebx
  800401:	50                   	push   %eax
  800402:	83 ec 08             	sub    $0x8,%esp
  800405:	ff 75 e4             	push   -0x1c(%ebp)
  800408:	ff 75 e0             	push   -0x20(%ebp)
  80040b:	ff 75 dc             	push   -0x24(%ebp)
  80040e:	ff 75 d8             	push   -0x28(%ebp)
  800411:	e8 1a 08 00 00       	call   800c30 <__udivdi3>
  800416:	83 c4 18             	add    $0x18,%esp
  800419:	52                   	push   %edx
  80041a:	50                   	push   %eax
  80041b:	89 f2                	mov    %esi,%edx
  80041d:	89 f8                	mov    %edi,%eax
  80041f:	e8 9f ff ff ff       	call   8003c3 <printnum>
  800424:	83 c4 20             	add    $0x20,%esp
  800427:	eb 13                	jmp    80043c <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800429:	83 ec 08             	sub    $0x8,%esp
  80042c:	56                   	push   %esi
  80042d:	ff 75 18             	push   0x18(%ebp)
  800430:	ff d7                	call   *%edi
  800432:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800435:	83 eb 01             	sub    $0x1,%ebx
  800438:	85 db                	test   %ebx,%ebx
  80043a:	7f ed                	jg     800429 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80043c:	83 ec 08             	sub    $0x8,%esp
  80043f:	56                   	push   %esi
  800440:	83 ec 04             	sub    $0x4,%esp
  800443:	ff 75 e4             	push   -0x1c(%ebp)
  800446:	ff 75 e0             	push   -0x20(%ebp)
  800449:	ff 75 dc             	push   -0x24(%ebp)
  80044c:	ff 75 d8             	push   -0x28(%ebp)
  80044f:	e8 fc 08 00 00       	call   800d50 <__umoddi3>
  800454:	83 c4 14             	add    $0x14,%esp
  800457:	0f be 80 dd 0e 80 00 	movsbl 0x800edd(%eax),%eax
  80045e:	50                   	push   %eax
  80045f:	ff d7                	call   *%edi
}
  800461:	83 c4 10             	add    $0x10,%esp
  800464:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800467:	5b                   	pop    %ebx
  800468:	5e                   	pop    %esi
  800469:	5f                   	pop    %edi
  80046a:	5d                   	pop    %ebp
  80046b:	c3                   	ret    

0080046c <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80046c:	83 fa 01             	cmp    $0x1,%edx
  80046f:	7f 13                	jg     800484 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800471:	85 d2                	test   %edx,%edx
  800473:	74 1c                	je     800491 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  800475:	8b 10                	mov    (%eax),%edx
  800477:	8d 4a 04             	lea    0x4(%edx),%ecx
  80047a:	89 08                	mov    %ecx,(%eax)
  80047c:	8b 02                	mov    (%edx),%eax
  80047e:	ba 00 00 00 00       	mov    $0x0,%edx
  800483:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  800484:	8b 10                	mov    (%eax),%edx
  800486:	8d 4a 08             	lea    0x8(%edx),%ecx
  800489:	89 08                	mov    %ecx,(%eax)
  80048b:	8b 02                	mov    (%edx),%eax
  80048d:	8b 52 04             	mov    0x4(%edx),%edx
  800490:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  800491:	8b 10                	mov    (%eax),%edx
  800493:	8d 4a 04             	lea    0x4(%edx),%ecx
  800496:	89 08                	mov    %ecx,(%eax)
  800498:	8b 02                	mov    (%edx),%eax
  80049a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80049f:	c3                   	ret    

008004a0 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004a0:	83 fa 01             	cmp    $0x1,%edx
  8004a3:	7f 0f                	jg     8004b4 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  8004a5:	85 d2                	test   %edx,%edx
  8004a7:	74 18                	je     8004c1 <getint+0x21>
		return va_arg(*ap, long);
  8004a9:	8b 10                	mov    (%eax),%edx
  8004ab:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004ae:	89 08                	mov    %ecx,(%eax)
  8004b0:	8b 02                	mov    (%edx),%eax
  8004b2:	99                   	cltd   
  8004b3:	c3                   	ret    
		return va_arg(*ap, long long);
  8004b4:	8b 10                	mov    (%eax),%edx
  8004b6:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004b9:	89 08                	mov    %ecx,(%eax)
  8004bb:	8b 02                	mov    (%edx),%eax
  8004bd:	8b 52 04             	mov    0x4(%edx),%edx
  8004c0:	c3                   	ret    
	else
		return va_arg(*ap, int);
  8004c1:	8b 10                	mov    (%eax),%edx
  8004c3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004c6:	89 08                	mov    %ecx,(%eax)
  8004c8:	8b 02                	mov    (%edx),%eax
  8004ca:	99                   	cltd   
}
  8004cb:	c3                   	ret    

008004cc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004cc:	55                   	push   %ebp
  8004cd:	89 e5                	mov    %esp,%ebp
  8004cf:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004d2:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004d6:	8b 10                	mov    (%eax),%edx
  8004d8:	3b 50 04             	cmp    0x4(%eax),%edx
  8004db:	73 0a                	jae    8004e7 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004dd:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004e0:	89 08                	mov    %ecx,(%eax)
  8004e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e5:	88 02                	mov    %al,(%edx)
}
  8004e7:	5d                   	pop    %ebp
  8004e8:	c3                   	ret    

008004e9 <printfmt>:
{
  8004e9:	55                   	push   %ebp
  8004ea:	89 e5                	mov    %esp,%ebp
  8004ec:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8004ef:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004f2:	50                   	push   %eax
  8004f3:	ff 75 10             	push   0x10(%ebp)
  8004f6:	ff 75 0c             	push   0xc(%ebp)
  8004f9:	ff 75 08             	push   0x8(%ebp)
  8004fc:	e8 05 00 00 00       	call   800506 <vprintfmt>
}
  800501:	83 c4 10             	add    $0x10,%esp
  800504:	c9                   	leave  
  800505:	c3                   	ret    

00800506 <vprintfmt>:
{
  800506:	55                   	push   %ebp
  800507:	89 e5                	mov    %esp,%ebp
  800509:	57                   	push   %edi
  80050a:	56                   	push   %esi
  80050b:	53                   	push   %ebx
  80050c:	83 ec 2c             	sub    $0x2c,%esp
  80050f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800512:	8b 75 0c             	mov    0xc(%ebp),%esi
  800515:	8b 7d 10             	mov    0x10(%ebp),%edi
  800518:	eb 0a                	jmp    800524 <vprintfmt+0x1e>
			putch(ch, putdat);
  80051a:	83 ec 08             	sub    $0x8,%esp
  80051d:	56                   	push   %esi
  80051e:	50                   	push   %eax
  80051f:	ff d3                	call   *%ebx
  800521:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800524:	83 c7 01             	add    $0x1,%edi
  800527:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80052b:	83 f8 25             	cmp    $0x25,%eax
  80052e:	74 0c                	je     80053c <vprintfmt+0x36>
			if (ch == '\0')
  800530:	85 c0                	test   %eax,%eax
  800532:	75 e6                	jne    80051a <vprintfmt+0x14>
}
  800534:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800537:	5b                   	pop    %ebx
  800538:	5e                   	pop    %esi
  800539:	5f                   	pop    %edi
  80053a:	5d                   	pop    %ebp
  80053b:	c3                   	ret    
		padc = ' ';
  80053c:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
		altflag = 0;
  800540:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800547:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80054e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800555:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80055a:	8d 47 01             	lea    0x1(%edi),%eax
  80055d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800560:	0f b6 17             	movzbl (%edi),%edx
  800563:	8d 42 dd             	lea    -0x23(%edx),%eax
  800566:	3c 55                	cmp    $0x55,%al
  800568:	0f 87 b7 02 00 00    	ja     800825 <vprintfmt+0x31f>
  80056e:	0f b6 c0             	movzbl %al,%eax
  800571:	ff 24 85 a0 0f 80 00 	jmp    *0x800fa0(,%eax,4)
  800578:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80057b:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  80057f:	eb d9                	jmp    80055a <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800581:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800584:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800588:	eb d0                	jmp    80055a <vprintfmt+0x54>
  80058a:	0f b6 d2             	movzbl %dl,%edx
  80058d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0;; ++fmt) {
  800590:	b8 00 00 00 00       	mov    $0x0,%eax
  800595:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800598:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80059b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80059f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8005a2:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8005a5:	83 f9 09             	cmp    $0x9,%ecx
  8005a8:	77 52                	ja     8005fc <vprintfmt+0xf6>
			for (precision = 0;; ++fmt) {
  8005aa:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8005ad:	eb e9                	jmp    800598 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  8005af:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b2:	8d 50 04             	lea    0x4(%eax),%edx
  8005b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b8:	8b 00                	mov    (%eax),%eax
  8005ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8005c0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005c4:	79 94                	jns    80055a <vprintfmt+0x54>
				width = precision, precision = -1;
  8005c6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005c9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005cc:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8005d3:	eb 85                	jmp    80055a <vprintfmt+0x54>
  8005d5:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005d8:	85 d2                	test   %edx,%edx
  8005da:	b8 00 00 00 00       	mov    $0x0,%eax
  8005df:	0f 49 c2             	cmovns %edx,%eax
  8005e2:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005e8:	e9 6d ff ff ff       	jmp    80055a <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8005ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8005f0:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8005f7:	e9 5e ff ff ff       	jmp    80055a <vprintfmt+0x54>
  8005fc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ff:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800602:	eb bc                	jmp    8005c0 <vprintfmt+0xba>
			lflag++;
  800604:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800607:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80060a:	e9 4b ff ff ff       	jmp    80055a <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  80060f:	8b 45 14             	mov    0x14(%ebp),%eax
  800612:	8d 50 04             	lea    0x4(%eax),%edx
  800615:	89 55 14             	mov    %edx,0x14(%ebp)
  800618:	83 ec 08             	sub    $0x8,%esp
  80061b:	56                   	push   %esi
  80061c:	ff 30                	push   (%eax)
  80061e:	ff d3                	call   *%ebx
			break;
  800620:	83 c4 10             	add    $0x10,%esp
  800623:	e9 94 01 00 00       	jmp    8007bc <vprintfmt+0x2b6>
			err = va_arg(ap, int);
  800628:	8b 45 14             	mov    0x14(%ebp),%eax
  80062b:	8d 50 04             	lea    0x4(%eax),%edx
  80062e:	89 55 14             	mov    %edx,0x14(%ebp)
  800631:	8b 10                	mov    (%eax),%edx
  800633:	89 d0                	mov    %edx,%eax
  800635:	f7 d8                	neg    %eax
  800637:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80063a:	83 f8 08             	cmp    $0x8,%eax
  80063d:	7f 20                	jg     80065f <vprintfmt+0x159>
  80063f:	8b 14 85 00 11 80 00 	mov    0x801100(,%eax,4),%edx
  800646:	85 d2                	test   %edx,%edx
  800648:	74 15                	je     80065f <vprintfmt+0x159>
				printfmt(putch, putdat, "%s", p);
  80064a:	52                   	push   %edx
  80064b:	68 fe 0e 80 00       	push   $0x800efe
  800650:	56                   	push   %esi
  800651:	53                   	push   %ebx
  800652:	e8 92 fe ff ff       	call   8004e9 <printfmt>
  800657:	83 c4 10             	add    $0x10,%esp
  80065a:	e9 5d 01 00 00       	jmp    8007bc <vprintfmt+0x2b6>
				printfmt(putch, putdat, "error %d", err);
  80065f:	50                   	push   %eax
  800660:	68 f5 0e 80 00       	push   $0x800ef5
  800665:	56                   	push   %esi
  800666:	53                   	push   %ebx
  800667:	e8 7d fe ff ff       	call   8004e9 <printfmt>
  80066c:	83 c4 10             	add    $0x10,%esp
  80066f:	e9 48 01 00 00       	jmp    8007bc <vprintfmt+0x2b6>
			if ((p = va_arg(ap, char *)) == NULL)
  800674:	8b 45 14             	mov    0x14(%ebp),%eax
  800677:	8d 50 04             	lea    0x4(%eax),%edx
  80067a:	89 55 14             	mov    %edx,0x14(%ebp)
  80067d:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80067f:	85 ff                	test   %edi,%edi
  800681:	b8 ee 0e 80 00       	mov    $0x800eee,%eax
  800686:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800689:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80068d:	7e 06                	jle    800695 <vprintfmt+0x18f>
  80068f:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  800693:	75 0a                	jne    80069f <vprintfmt+0x199>
  800695:	89 f8                	mov    %edi,%eax
  800697:	03 45 e0             	add    -0x20(%ebp),%eax
  80069a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80069d:	eb 59                	jmp    8006f8 <vprintfmt+0x1f2>
				for (width -= strnlen(p, precision); width > 0;
  80069f:	83 ec 08             	sub    $0x8,%esp
  8006a2:	ff 75 d8             	push   -0x28(%ebp)
  8006a5:	57                   	push   %edi
  8006a6:	e8 1a 02 00 00       	call   8008c5 <strnlen>
  8006ab:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006ae:	29 c1                	sub    %eax,%ecx
  8006b0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006b3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006b6:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  8006ba:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006bd:	89 7d d0             	mov    %edi,-0x30(%ebp)
  8006c0:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0;
  8006c2:	eb 0f                	jmp    8006d3 <vprintfmt+0x1cd>
					putch(padc, putdat);
  8006c4:	83 ec 08             	sub    $0x8,%esp
  8006c7:	56                   	push   %esi
  8006c8:	ff 75 e0             	push   -0x20(%ebp)
  8006cb:	ff d3                	call   *%ebx
				     width--)
  8006cd:	83 ef 01             	sub    $0x1,%edi
  8006d0:	83 c4 10             	add    $0x10,%esp
				for (width -= strnlen(p, precision); width > 0;
  8006d3:	85 ff                	test   %edi,%edi
  8006d5:	7f ed                	jg     8006c4 <vprintfmt+0x1be>
  8006d7:	8b 7d d0             	mov    -0x30(%ebp),%edi
  8006da:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006dd:	85 c9                	test   %ecx,%ecx
  8006df:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e4:	0f 49 c1             	cmovns %ecx,%eax
  8006e7:	29 c1                	sub    %eax,%ecx
  8006e9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8006ec:	eb a7                	jmp    800695 <vprintfmt+0x18f>
					putch(ch, putdat);
  8006ee:	83 ec 08             	sub    $0x8,%esp
  8006f1:	56                   	push   %esi
  8006f2:	52                   	push   %edx
  8006f3:	ff d3                	call   *%ebx
  8006f5:	83 c4 10             	add    $0x10,%esp
  8006f8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006fb:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' &&
  8006fd:	83 c7 01             	add    $0x1,%edi
  800700:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800704:	0f be d0             	movsbl %al,%edx
  800707:	85 d2                	test   %edx,%edx
  800709:	74 42                	je     80074d <vprintfmt+0x247>
  80070b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80070f:	78 06                	js     800717 <vprintfmt+0x211>
			       (precision < 0 || --precision >= 0);
  800711:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800715:	78 1e                	js     800735 <vprintfmt+0x22f>
				if (altflag && (ch < ' ' || ch > '~'))
  800717:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80071b:	74 d1                	je     8006ee <vprintfmt+0x1e8>
  80071d:	0f be c0             	movsbl %al,%eax
  800720:	83 e8 20             	sub    $0x20,%eax
  800723:	83 f8 5e             	cmp    $0x5e,%eax
  800726:	76 c6                	jbe    8006ee <vprintfmt+0x1e8>
					putch('?', putdat);
  800728:	83 ec 08             	sub    $0x8,%esp
  80072b:	56                   	push   %esi
  80072c:	6a 3f                	push   $0x3f
  80072e:	ff d3                	call   *%ebx
  800730:	83 c4 10             	add    $0x10,%esp
  800733:	eb c3                	jmp    8006f8 <vprintfmt+0x1f2>
  800735:	89 cf                	mov    %ecx,%edi
  800737:	eb 0e                	jmp    800747 <vprintfmt+0x241>
				putch(' ', putdat);
  800739:	83 ec 08             	sub    $0x8,%esp
  80073c:	56                   	push   %esi
  80073d:	6a 20                	push   $0x20
  80073f:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  800741:	83 ef 01             	sub    $0x1,%edi
  800744:	83 c4 10             	add    $0x10,%esp
  800747:	85 ff                	test   %edi,%edi
  800749:	7f ee                	jg     800739 <vprintfmt+0x233>
  80074b:	eb 6f                	jmp    8007bc <vprintfmt+0x2b6>
  80074d:	89 cf                	mov    %ecx,%edi
  80074f:	eb f6                	jmp    800747 <vprintfmt+0x241>
			num = getint(&ap, lflag);
  800751:	89 ca                	mov    %ecx,%edx
  800753:	8d 45 14             	lea    0x14(%ebp),%eax
  800756:	e8 45 fd ff ff       	call   8004a0 <getint>
  80075b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80075e:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800761:	85 d2                	test   %edx,%edx
  800763:	78 0b                	js     800770 <vprintfmt+0x26a>
			num = getint(&ap, lflag);
  800765:	89 d1                	mov    %edx,%ecx
  800767:	89 c2                	mov    %eax,%edx
			base = 10;
  800769:	bf 0a 00 00 00       	mov    $0xa,%edi
  80076e:	eb 32                	jmp    8007a2 <vprintfmt+0x29c>
				putch('-', putdat);
  800770:	83 ec 08             	sub    $0x8,%esp
  800773:	56                   	push   %esi
  800774:	6a 2d                	push   $0x2d
  800776:	ff d3                	call   *%ebx
				num = -(long long) num;
  800778:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80077b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80077e:	f7 da                	neg    %edx
  800780:	83 d1 00             	adc    $0x0,%ecx
  800783:	f7 d9                	neg    %ecx
  800785:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800788:	bf 0a 00 00 00       	mov    $0xa,%edi
  80078d:	eb 13                	jmp    8007a2 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  80078f:	89 ca                	mov    %ecx,%edx
  800791:	8d 45 14             	lea    0x14(%ebp),%eax
  800794:	e8 d3 fc ff ff       	call   80046c <getuint>
  800799:	89 d1                	mov    %edx,%ecx
  80079b:	89 c2                	mov    %eax,%edx
			base = 10;
  80079d:	bf 0a 00 00 00       	mov    $0xa,%edi
			printnum(putch, putdat, num, base, width, padc);
  8007a2:	83 ec 0c             	sub    $0xc,%esp
  8007a5:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  8007a9:	50                   	push   %eax
  8007aa:	ff 75 e0             	push   -0x20(%ebp)
  8007ad:	57                   	push   %edi
  8007ae:	51                   	push   %ecx
  8007af:	52                   	push   %edx
  8007b0:	89 f2                	mov    %esi,%edx
  8007b2:	89 d8                	mov    %ebx,%eax
  8007b4:	e8 0a fc ff ff       	call   8003c3 <printnum>
			break;
  8007b9:	83 c4 20             	add    $0x20,%esp
{
  8007bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007bf:	e9 60 fd ff ff       	jmp    800524 <vprintfmt+0x1e>
			num = getuint(&ap, lflag);
  8007c4:	89 ca                	mov    %ecx,%edx
  8007c6:	8d 45 14             	lea    0x14(%ebp),%eax
  8007c9:	e8 9e fc ff ff       	call   80046c <getuint>
  8007ce:	89 d1                	mov    %edx,%ecx
  8007d0:	89 c2                	mov    %eax,%edx
			base = 8;
  8007d2:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  8007d7:	eb c9                	jmp    8007a2 <vprintfmt+0x29c>
			putch('0', putdat);
  8007d9:	83 ec 08             	sub    $0x8,%esp
  8007dc:	56                   	push   %esi
  8007dd:	6a 30                	push   $0x30
  8007df:	ff d3                	call   *%ebx
			putch('x', putdat);
  8007e1:	83 c4 08             	add    $0x8,%esp
  8007e4:	56                   	push   %esi
  8007e5:	6a 78                	push   $0x78
  8007e7:	ff d3                	call   *%ebx
			num = (unsigned long long) (uintptr_t) va_arg(ap, void *);
  8007e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ec:	8d 50 04             	lea    0x4(%eax),%edx
  8007ef:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f2:	8b 10                	mov    (%eax),%edx
  8007f4:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8007f9:	83 c4 10             	add    $0x10,%esp
			base = 16;
  8007fc:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  800801:	eb 9f                	jmp    8007a2 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  800803:	89 ca                	mov    %ecx,%edx
  800805:	8d 45 14             	lea    0x14(%ebp),%eax
  800808:	e8 5f fc ff ff       	call   80046c <getuint>
  80080d:	89 d1                	mov    %edx,%ecx
  80080f:	89 c2                	mov    %eax,%edx
			base = 16;
  800811:	bf 10 00 00 00       	mov    $0x10,%edi
  800816:	eb 8a                	jmp    8007a2 <vprintfmt+0x29c>
			putch(ch, putdat);
  800818:	83 ec 08             	sub    $0x8,%esp
  80081b:	56                   	push   %esi
  80081c:	6a 25                	push   $0x25
  80081e:	ff d3                	call   *%ebx
			break;
  800820:	83 c4 10             	add    $0x10,%esp
  800823:	eb 97                	jmp    8007bc <vprintfmt+0x2b6>
			putch('%', putdat);
  800825:	83 ec 08             	sub    $0x8,%esp
  800828:	56                   	push   %esi
  800829:	6a 25                	push   $0x25
  80082b:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  80082d:	83 c4 10             	add    $0x10,%esp
  800830:	89 f8                	mov    %edi,%eax
  800832:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800836:	74 05                	je     80083d <vprintfmt+0x337>
  800838:	83 e8 01             	sub    $0x1,%eax
  80083b:	eb f5                	jmp    800832 <vprintfmt+0x32c>
  80083d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800840:	e9 77 ff ff ff       	jmp    8007bc <vprintfmt+0x2b6>

00800845 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800845:	55                   	push   %ebp
  800846:	89 e5                	mov    %esp,%ebp
  800848:	83 ec 18             	sub    $0x18,%esp
  80084b:	8b 45 08             	mov    0x8(%ebp),%eax
  80084e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = { buf, buf + n - 1, 0 };
  800851:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800854:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800858:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80085b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800862:	85 c0                	test   %eax,%eax
  800864:	74 26                	je     80088c <vsnprintf+0x47>
  800866:	85 d2                	test   %edx,%edx
  800868:	7e 22                	jle    80088c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *) sprintputch, &b, fmt, ap);
  80086a:	ff 75 14             	push   0x14(%ebp)
  80086d:	ff 75 10             	push   0x10(%ebp)
  800870:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800873:	50                   	push   %eax
  800874:	68 cc 04 80 00       	push   $0x8004cc
  800879:	e8 88 fc ff ff       	call   800506 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80087e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800881:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800884:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800887:	83 c4 10             	add    $0x10,%esp
}
  80088a:	c9                   	leave  
  80088b:	c3                   	ret    
		return -E_INVAL;
  80088c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800891:	eb f7                	jmp    80088a <vsnprintf+0x45>

00800893 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800893:	55                   	push   %ebp
  800894:	89 e5                	mov    %esp,%ebp
  800896:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800899:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80089c:	50                   	push   %eax
  80089d:	ff 75 10             	push   0x10(%ebp)
  8008a0:	ff 75 0c             	push   0xc(%ebp)
  8008a3:	ff 75 08             	push   0x8(%ebp)
  8008a6:	e8 9a ff ff ff       	call   800845 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008ab:	c9                   	leave  
  8008ac:	c3                   	ret    

008008ad <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008ad:	55                   	push   %ebp
  8008ae:	89 e5                	mov    %esp,%ebp
  8008b0:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b8:	eb 03                	jmp    8008bd <strlen+0x10>
		n++;
  8008ba:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008bd:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008c1:	75 f7                	jne    8008ba <strlen+0xd>
	return n;
}
  8008c3:	5d                   	pop    %ebp
  8008c4:	c3                   	ret    

008008c5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008c5:	55                   	push   %ebp
  8008c6:	89 e5                	mov    %esp,%ebp
  8008c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008cb:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d3:	eb 03                	jmp    8008d8 <strnlen+0x13>
		n++;
  8008d5:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008d8:	39 d0                	cmp    %edx,%eax
  8008da:	74 08                	je     8008e4 <strnlen+0x1f>
  8008dc:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008e0:	75 f3                	jne    8008d5 <strnlen+0x10>
  8008e2:	89 c2                	mov    %eax,%edx
	return n;
}
  8008e4:	89 d0                	mov    %edx,%eax
  8008e6:	5d                   	pop    %ebp
  8008e7:	c3                   	ret    

008008e8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	53                   	push   %ebx
  8008ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f7:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8008fb:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8008fe:	83 c0 01             	add    $0x1,%eax
  800901:	84 d2                	test   %dl,%dl
  800903:	75 f2                	jne    8008f7 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800905:	89 c8                	mov    %ecx,%eax
  800907:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80090a:	c9                   	leave  
  80090b:	c3                   	ret    

0080090c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80090c:	55                   	push   %ebp
  80090d:	89 e5                	mov    %esp,%ebp
  80090f:	53                   	push   %ebx
  800910:	83 ec 10             	sub    $0x10,%esp
  800913:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800916:	53                   	push   %ebx
  800917:	e8 91 ff ff ff       	call   8008ad <strlen>
  80091c:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80091f:	ff 75 0c             	push   0xc(%ebp)
  800922:	01 d8                	add    %ebx,%eax
  800924:	50                   	push   %eax
  800925:	e8 be ff ff ff       	call   8008e8 <strcpy>
	return dst;
}
  80092a:	89 d8                	mov    %ebx,%eax
  80092c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80092f:	c9                   	leave  
  800930:	c3                   	ret    

00800931 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size)
{
  800931:	55                   	push   %ebp
  800932:	89 e5                	mov    %esp,%ebp
  800934:	56                   	push   %esi
  800935:	53                   	push   %ebx
  800936:	8b 75 08             	mov    0x8(%ebp),%esi
  800939:	8b 55 0c             	mov    0xc(%ebp),%edx
  80093c:	89 f3                	mov    %esi,%ebx
  80093e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800941:	89 f0                	mov    %esi,%eax
  800943:	eb 0f                	jmp    800954 <strncpy+0x23>
		*dst++ = *src;
  800945:	83 c0 01             	add    $0x1,%eax
  800948:	0f b6 0a             	movzbl (%edx),%ecx
  80094b:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80094e:	80 f9 01             	cmp    $0x1,%cl
  800951:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800954:	39 d8                	cmp    %ebx,%eax
  800956:	75 ed                	jne    800945 <strncpy+0x14>
	}
	return ret;
}
  800958:	89 f0                	mov    %esi,%eax
  80095a:	5b                   	pop    %ebx
  80095b:	5e                   	pop    %esi
  80095c:	5d                   	pop    %ebp
  80095d:	c3                   	ret    

0080095e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80095e:	55                   	push   %ebp
  80095f:	89 e5                	mov    %esp,%ebp
  800961:	56                   	push   %esi
  800962:	53                   	push   %ebx
  800963:	8b 75 08             	mov    0x8(%ebp),%esi
  800966:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800969:	8b 55 10             	mov    0x10(%ebp),%edx
  80096c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80096e:	85 d2                	test   %edx,%edx
  800970:	74 21                	je     800993 <strlcpy+0x35>
  800972:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800976:	89 f2                	mov    %esi,%edx
  800978:	eb 09                	jmp    800983 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80097a:	83 c1 01             	add    $0x1,%ecx
  80097d:	83 c2 01             	add    $0x1,%edx
  800980:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800983:	39 c2                	cmp    %eax,%edx
  800985:	74 09                	je     800990 <strlcpy+0x32>
  800987:	0f b6 19             	movzbl (%ecx),%ebx
  80098a:	84 db                	test   %bl,%bl
  80098c:	75 ec                	jne    80097a <strlcpy+0x1c>
  80098e:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800990:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800993:	29 f0                	sub    %esi,%eax
}
  800995:	5b                   	pop    %ebx
  800996:	5e                   	pop    %esi
  800997:	5d                   	pop    %ebp
  800998:	c3                   	ret    

00800999 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800999:	55                   	push   %ebp
  80099a:	89 e5                	mov    %esp,%ebp
  80099c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80099f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009a2:	eb 06                	jmp    8009aa <strcmp+0x11>
		p++, q++;
  8009a4:	83 c1 01             	add    $0x1,%ecx
  8009a7:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8009aa:	0f b6 01             	movzbl (%ecx),%eax
  8009ad:	84 c0                	test   %al,%al
  8009af:	74 04                	je     8009b5 <strcmp+0x1c>
  8009b1:	3a 02                	cmp    (%edx),%al
  8009b3:	74 ef                	je     8009a4 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009b5:	0f b6 c0             	movzbl %al,%eax
  8009b8:	0f b6 12             	movzbl (%edx),%edx
  8009bb:	29 d0                	sub    %edx,%eax
}
  8009bd:	5d                   	pop    %ebp
  8009be:	c3                   	ret    

008009bf <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009bf:	55                   	push   %ebp
  8009c0:	89 e5                	mov    %esp,%ebp
  8009c2:	53                   	push   %ebx
  8009c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c9:	89 c3                	mov    %eax,%ebx
  8009cb:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009ce:	eb 06                	jmp    8009d6 <strncmp+0x17>
		n--, p++, q++;
  8009d0:	83 c0 01             	add    $0x1,%eax
  8009d3:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009d6:	39 d8                	cmp    %ebx,%eax
  8009d8:	74 18                	je     8009f2 <strncmp+0x33>
  8009da:	0f b6 08             	movzbl (%eax),%ecx
  8009dd:	84 c9                	test   %cl,%cl
  8009df:	74 04                	je     8009e5 <strncmp+0x26>
  8009e1:	3a 0a                	cmp    (%edx),%cl
  8009e3:	74 eb                	je     8009d0 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009e5:	0f b6 00             	movzbl (%eax),%eax
  8009e8:	0f b6 12             	movzbl (%edx),%edx
  8009eb:	29 d0                	sub    %edx,%eax
}
  8009ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009f0:	c9                   	leave  
  8009f1:	c3                   	ret    
		return 0;
  8009f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f7:	eb f4                	jmp    8009ed <strncmp+0x2e>

008009f9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009f9:	55                   	push   %ebp
  8009fa:	89 e5                	mov    %esp,%ebp
  8009fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ff:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a03:	eb 03                	jmp    800a08 <strchr+0xf>
  800a05:	83 c0 01             	add    $0x1,%eax
  800a08:	0f b6 10             	movzbl (%eax),%edx
  800a0b:	84 d2                	test   %dl,%dl
  800a0d:	74 06                	je     800a15 <strchr+0x1c>
		if (*s == c)
  800a0f:	38 ca                	cmp    %cl,%dl
  800a11:	75 f2                	jne    800a05 <strchr+0xc>
  800a13:	eb 05                	jmp    800a1a <strchr+0x21>
			return (char *) s;
	return 0;
  800a15:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a1a:	5d                   	pop    %ebp
  800a1b:	c3                   	ret    

00800a1c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a1c:	55                   	push   %ebp
  800a1d:	89 e5                	mov    %esp,%ebp
  800a1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a22:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a26:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a29:	38 ca                	cmp    %cl,%dl
  800a2b:	74 09                	je     800a36 <strfind+0x1a>
  800a2d:	84 d2                	test   %dl,%dl
  800a2f:	74 05                	je     800a36 <strfind+0x1a>
	for (; *s; s++)
  800a31:	83 c0 01             	add    $0x1,%eax
  800a34:	eb f0                	jmp    800a26 <strfind+0xa>
			break;
	return (char *) s;
}
  800a36:	5d                   	pop    %ebp
  800a37:	c3                   	ret    

00800a38 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a38:	55                   	push   %ebp
  800a39:	89 e5                	mov    %esp,%ebp
  800a3b:	57                   	push   %edi
  800a3c:	56                   	push   %esi
  800a3d:	53                   	push   %ebx
  800a3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a41:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  800a44:	85 c9                	test   %ecx,%ecx
  800a46:	74 33                	je     800a7b <memset+0x43>
		return v;
	if ((int) v % 4 == 0 && n % 4 == 0) {
  800a48:	89 d0                	mov    %edx,%eax
  800a4a:	09 c8                	or     %ecx,%eax
  800a4c:	a8 03                	test   $0x3,%al
  800a4e:	75 23                	jne    800a73 <memset+0x3b>
		c &= 0xFF;
  800a50:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  800a54:	89 d8                	mov    %ebx,%eax
  800a56:	c1 e0 08             	shl    $0x8,%eax
  800a59:	89 df                	mov    %ebx,%edi
  800a5b:	c1 e7 18             	shl    $0x18,%edi
  800a5e:	89 de                	mov    %ebx,%esi
  800a60:	c1 e6 10             	shl    $0x10,%esi
  800a63:	09 f7                	or     %esi,%edi
  800a65:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
		             : "=D"(p), "=c"(n)
		             : "D"(p), "a"(c), "c"(n / 4)
  800a67:	c1 e9 02             	shr    $0x2,%ecx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  800a6a:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800a6c:	89 d7                	mov    %edx,%edi
  800a6e:	fc                   	cld    
  800a6f:	f3 ab                	rep stos %eax,%es:(%edi)
  800a71:	eb 08                	jmp    800a7b <memset+0x43>
		             : "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a73:	89 d7                	mov    %edx,%edi
  800a75:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a78:	fc                   	cld    
  800a79:	f3 aa                	rep stos %al,%es:(%edi)
		             : "=D"(p), "=c"(n)
		             : "0"(p), "a"(c), "1"(n)
		             : "cc", "memory");
	return v;
}
  800a7b:	89 d0                	mov    %edx,%eax
  800a7d:	5b                   	pop    %ebx
  800a7e:	5e                   	pop    %esi
  800a7f:	5f                   	pop    %edi
  800a80:	5d                   	pop    %ebp
  800a81:	c3                   	ret    

00800a82 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a82:	55                   	push   %ebp
  800a83:	89 e5                	mov    %esp,%ebp
  800a85:	57                   	push   %edi
  800a86:	56                   	push   %esi
  800a87:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a8d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a90:	39 c6                	cmp    %eax,%esi
  800a92:	73 32                	jae    800ac6 <memmove+0x44>
  800a94:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a97:	39 c2                	cmp    %eax,%edx
  800a99:	76 2b                	jbe    800ac6 <memmove+0x44>
		s += n;
		d += n;
  800a9b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  800a9e:	89 d6                	mov    %edx,%esi
  800aa0:	09 fe                	or     %edi,%esi
  800aa2:	09 ce                	or     %ecx,%esi
  800aa4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aaa:	75 0e                	jne    800aba <memmove+0x38>
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  800aac:	83 ef 04             	sub    $0x4,%edi
			             "S"(s - 4),
  800aaf:	8d 72 fc             	lea    -0x4(%edx),%esi
			             "c"(n / 4)
  800ab2:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  800ab5:	fd                   	std    
  800ab6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ab8:	eb 09                	jmp    800ac3 <memmove+0x41>
			             : "cc", "memory");
		else
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  800aba:	83 ef 01             	sub    $0x1,%edi
			             "S"(s - 1),
  800abd:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  800ac0:	fd                   	std    
  800ac1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             "c"(n)
			             : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ac3:	fc                   	cld    
  800ac4:	eb 1a                	jmp    800ae0 <memmove+0x5e>
	} else {
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  800ac6:	89 f2                	mov    %esi,%edx
  800ac8:	09 c2                	or     %eax,%edx
  800aca:	09 ca                	or     %ecx,%edx
  800acc:	f6 c2 03             	test   $0x3,%dl
  800acf:	75 0a                	jne    800adb <memmove+0x59>
			asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800ad1:	c1 e9 02             	shr    $0x2,%ecx
  800ad4:	89 c7                	mov    %eax,%edi
  800ad6:	fc                   	cld    
  800ad7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ad9:	eb 05                	jmp    800ae0 <memmove+0x5e>
			             : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800adb:	89 c7                	mov    %eax,%edi
  800add:	fc                   	cld    
  800ade:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             : "cc", "memory");
	}
	return dst;
}
  800ae0:	5e                   	pop    %esi
  800ae1:	5f                   	pop    %edi
  800ae2:	5d                   	pop    %ebp
  800ae3:	c3                   	ret    

00800ae4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ae4:	55                   	push   %ebp
  800ae5:	89 e5                	mov    %esp,%ebp
  800ae7:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800aea:	ff 75 10             	push   0x10(%ebp)
  800aed:	ff 75 0c             	push   0xc(%ebp)
  800af0:	ff 75 08             	push   0x8(%ebp)
  800af3:	e8 8a ff ff ff       	call   800a82 <memmove>
}
  800af8:	c9                   	leave  
  800af9:	c3                   	ret    

00800afa <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800afa:	55                   	push   %ebp
  800afb:	89 e5                	mov    %esp,%ebp
  800afd:	56                   	push   %esi
  800afe:	53                   	push   %ebx
  800aff:	8b 45 08             	mov    0x8(%ebp),%eax
  800b02:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b05:	89 c6                	mov    %eax,%esi
  800b07:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b0a:	eb 06                	jmp    800b12 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b0c:	83 c0 01             	add    $0x1,%eax
  800b0f:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800b12:	39 f0                	cmp    %esi,%eax
  800b14:	74 14                	je     800b2a <memcmp+0x30>
		if (*s1 != *s2)
  800b16:	0f b6 08             	movzbl (%eax),%ecx
  800b19:	0f b6 1a             	movzbl (%edx),%ebx
  800b1c:	38 d9                	cmp    %bl,%cl
  800b1e:	74 ec                	je     800b0c <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800b20:	0f b6 c1             	movzbl %cl,%eax
  800b23:	0f b6 db             	movzbl %bl,%ebx
  800b26:	29 d8                	sub    %ebx,%eax
  800b28:	eb 05                	jmp    800b2f <memcmp+0x35>
	}

	return 0;
  800b2a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b2f:	5b                   	pop    %ebx
  800b30:	5e                   	pop    %esi
  800b31:	5d                   	pop    %ebp
  800b32:	c3                   	ret    

00800b33 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b33:	55                   	push   %ebp
  800b34:	89 e5                	mov    %esp,%ebp
  800b36:	8b 45 08             	mov    0x8(%ebp),%eax
  800b39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b3c:	89 c2                	mov    %eax,%edx
  800b3e:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b41:	eb 03                	jmp    800b46 <memfind+0x13>
  800b43:	83 c0 01             	add    $0x1,%eax
  800b46:	39 d0                	cmp    %edx,%eax
  800b48:	73 04                	jae    800b4e <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b4a:	38 08                	cmp    %cl,(%eax)
  800b4c:	75 f5                	jne    800b43 <memfind+0x10>
			break;
	return (void *) s;
}
  800b4e:	5d                   	pop    %ebp
  800b4f:	c3                   	ret    

00800b50 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b50:	55                   	push   %ebp
  800b51:	89 e5                	mov    %esp,%ebp
  800b53:	57                   	push   %edi
  800b54:	56                   	push   %esi
  800b55:	53                   	push   %ebx
  800b56:	8b 55 08             	mov    0x8(%ebp),%edx
  800b59:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b5c:	eb 03                	jmp    800b61 <strtol+0x11>
		s++;
  800b5e:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b61:	0f b6 02             	movzbl (%edx),%eax
  800b64:	3c 20                	cmp    $0x20,%al
  800b66:	74 f6                	je     800b5e <strtol+0xe>
  800b68:	3c 09                	cmp    $0x9,%al
  800b6a:	74 f2                	je     800b5e <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b6c:	3c 2b                	cmp    $0x2b,%al
  800b6e:	74 2a                	je     800b9a <strtol+0x4a>
	int neg = 0;
  800b70:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b75:	3c 2d                	cmp    $0x2d,%al
  800b77:	74 2b                	je     800ba4 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b79:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b7f:	75 0f                	jne    800b90 <strtol+0x40>
  800b81:	80 3a 30             	cmpb   $0x30,(%edx)
  800b84:	74 28                	je     800bae <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b86:	85 db                	test   %ebx,%ebx
  800b88:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b8d:	0f 44 d8             	cmove  %eax,%ebx
  800b90:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b95:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b98:	eb 46                	jmp    800be0 <strtol+0x90>
		s++;
  800b9a:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800b9d:	bf 00 00 00 00       	mov    $0x0,%edi
  800ba2:	eb d5                	jmp    800b79 <strtol+0x29>
		s++, neg = 1;
  800ba4:	83 c2 01             	add    $0x1,%edx
  800ba7:	bf 01 00 00 00       	mov    $0x1,%edi
  800bac:	eb cb                	jmp    800b79 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bae:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bb2:	74 0e                	je     800bc2 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800bb4:	85 db                	test   %ebx,%ebx
  800bb6:	75 d8                	jne    800b90 <strtol+0x40>
		s++, base = 8;
  800bb8:	83 c2 01             	add    $0x1,%edx
  800bbb:	bb 08 00 00 00       	mov    $0x8,%ebx
  800bc0:	eb ce                	jmp    800b90 <strtol+0x40>
		s += 2, base = 16;
  800bc2:	83 c2 02             	add    $0x2,%edx
  800bc5:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bca:	eb c4                	jmp    800b90 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800bcc:	0f be c0             	movsbl %al,%eax
  800bcf:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bd2:	3b 45 10             	cmp    0x10(%ebp),%eax
  800bd5:	7d 3a                	jge    800c11 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800bd7:	83 c2 01             	add    $0x1,%edx
  800bda:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800bde:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800be0:	0f b6 02             	movzbl (%edx),%eax
  800be3:	8d 70 d0             	lea    -0x30(%eax),%esi
  800be6:	89 f3                	mov    %esi,%ebx
  800be8:	80 fb 09             	cmp    $0x9,%bl
  800beb:	76 df                	jbe    800bcc <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800bed:	8d 70 9f             	lea    -0x61(%eax),%esi
  800bf0:	89 f3                	mov    %esi,%ebx
  800bf2:	80 fb 19             	cmp    $0x19,%bl
  800bf5:	77 08                	ja     800bff <strtol+0xaf>
			dig = *s - 'a' + 10;
  800bf7:	0f be c0             	movsbl %al,%eax
  800bfa:	83 e8 57             	sub    $0x57,%eax
  800bfd:	eb d3                	jmp    800bd2 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800bff:	8d 70 bf             	lea    -0x41(%eax),%esi
  800c02:	89 f3                	mov    %esi,%ebx
  800c04:	80 fb 19             	cmp    $0x19,%bl
  800c07:	77 08                	ja     800c11 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800c09:	0f be c0             	movsbl %al,%eax
  800c0c:	83 e8 37             	sub    $0x37,%eax
  800c0f:	eb c1                	jmp    800bd2 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c11:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c15:	74 05                	je     800c1c <strtol+0xcc>
		*endptr = (char *) s;
  800c17:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c1a:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800c1c:	89 c8                	mov    %ecx,%eax
  800c1e:	f7 d8                	neg    %eax
  800c20:	85 ff                	test   %edi,%edi
  800c22:	0f 45 c8             	cmovne %eax,%ecx
}
  800c25:	89 c8                	mov    %ecx,%eax
  800c27:	5b                   	pop    %ebx
  800c28:	5e                   	pop    %esi
  800c29:	5f                   	pop    %edi
  800c2a:	5d                   	pop    %ebp
  800c2b:	c3                   	ret    
  800c2c:	66 90                	xchg   %ax,%ax
  800c2e:	66 90                	xchg   %ax,%ax

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
