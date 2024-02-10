
obj/user/evilhello:     formato del fichero elf32-i386


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
  80002c:	e8 19 00 00 00       	call   80004a <libmain>
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
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char *) 0xf010000c, 100);
  800039:	6a 64                	push   $0x64
  80003b:	68 0c 00 10 f0       	push   $0xf010000c
  800040:	e8 ad 00 00 00       	call   8000f2 <sys_cputs>
}
  800045:	83 c4 10             	add    $0x10,%esp
  800048:	c9                   	leave  
  800049:	c3                   	ret    

0080004a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004a:	55                   	push   %ebp
  80004b:	89 e5                	mov    %esp,%ebp
  80004d:	56                   	push   %esi
  80004e:	53                   	push   %ebx
  80004f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800052:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	envid_t id = sys_getenvid();
  800055:	e8 04 01 00 00       	call   80015e <sys_getenvid>
	if (id >= 0)
  80005a:	85 c0                	test   %eax,%eax
  80005c:	78 15                	js     800073 <libmain+0x29>
		thisenv = &envs[ENVX(id)];
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	69 c0 88 00 00 00    	imul   $0x88,%eax,%eax
  800069:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006e:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800073:	85 db                	test   %ebx,%ebx
  800075:	7e 07                	jle    80007e <libmain+0x34>
		binaryname = argv[0];
  800077:	8b 06                	mov    (%esi),%eax
  800079:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80007e:	83 ec 08             	sub    $0x8,%esp
  800081:	56                   	push   %esi
  800082:	53                   	push   %ebx
  800083:	e8 ab ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800088:	e8 0a 00 00 00       	call   800097 <exit>
}
  80008d:	83 c4 10             	add    $0x10,%esp
  800090:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800093:	5b                   	pop    %ebx
  800094:	5e                   	pop    %esi
  800095:	5d                   	pop    %ebp
  800096:	c3                   	ret    

00800097 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800097:	55                   	push   %ebp
  800098:	89 e5                	mov    %esp,%ebp
  80009a:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80009d:	6a 00                	push   $0x0
  80009f:	e8 98 00 00 00       	call   80013c <sys_env_destroy>
}
  8000a4:	83 c4 10             	add    $0x10,%esp
  8000a7:	c9                   	leave  
  8000a8:	c3                   	ret    

008000a9 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000a9:	55                   	push   %ebp
  8000aa:	89 e5                	mov    %esp,%ebp
  8000ac:	57                   	push   %edi
  8000ad:	56                   	push   %esi
  8000ae:	53                   	push   %ebx
  8000af:	83 ec 1c             	sub    $0x1c,%esp
  8000b2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8000b5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8000b8:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile(
  8000ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000c0:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000c3:	8b 75 14             	mov    0x14(%ebp),%esi
  8000c6:	cd 30                	int    $0x30
	        "int %1\n"
	        : "=a"(ret)
	        : "i"(T_SYSCALL), "a"(num), "d"(a1), "c"(a2), "b"(a3), "D"(a4), "S"(a5)
	        : "cc", "memory");

	if (check && ret > 0)
  8000c8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000cc:	74 04                	je     8000d2 <syscall+0x29>
  8000ce:	85 c0                	test   %eax,%eax
  8000d0:	7f 08                	jg     8000da <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  8000d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000d5:	5b                   	pop    %ebx
  8000d6:	5e                   	pop    %esi
  8000d7:	5f                   	pop    %edi
  8000d8:	5d                   	pop    %ebp
  8000d9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8000da:	83 ec 0c             	sub    $0xc,%esp
  8000dd:	50                   	push   %eax
  8000de:	ff 75 e0             	push   -0x20(%ebp)
  8000e1:	68 aa 0e 80 00       	push   $0x800eaa
  8000e6:	6a 1e                	push   $0x1e
  8000e8:	68 c7 0e 80 00       	push   $0x800ec7
  8000ed:	e8 f7 01 00 00       	call   8002e9 <_panic>

008000f2 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  8000f2:	55                   	push   %ebp
  8000f3:	89 e5                	mov    %esp,%ebp
  8000f5:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t) s, len, 0, 0, 0);
  8000f8:	6a 00                	push   $0x0
  8000fa:	6a 00                	push   $0x0
  8000fc:	6a 00                	push   $0x0
  8000fe:	ff 75 0c             	push   0xc(%ebp)
  800101:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800104:	ba 00 00 00 00       	mov    $0x0,%edx
  800109:	b8 00 00 00 00       	mov    $0x0,%eax
  80010e:	e8 96 ff ff ff       	call   8000a9 <syscall>
}
  800113:	83 c4 10             	add    $0x10,%esp
  800116:	c9                   	leave  
  800117:	c3                   	ret    

00800118 <sys_cgetc>:

int
sys_cgetc(void)
{
  800118:	55                   	push   %ebp
  800119:	89 e5                	mov    %esp,%ebp
  80011b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  80011e:	6a 00                	push   $0x0
  800120:	6a 00                	push   $0x0
  800122:	6a 00                	push   $0x0
  800124:	6a 00                	push   $0x0
  800126:	b9 00 00 00 00       	mov    $0x0,%ecx
  80012b:	ba 00 00 00 00       	mov    $0x0,%edx
  800130:	b8 01 00 00 00       	mov    $0x1,%eax
  800135:	e8 6f ff ff ff       	call   8000a9 <syscall>
}
  80013a:	c9                   	leave  
  80013b:	c3                   	ret    

0080013c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800142:	6a 00                	push   $0x0
  800144:	6a 00                	push   $0x0
  800146:	6a 00                	push   $0x0
  800148:	6a 00                	push   $0x0
  80014a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80014d:	ba 01 00 00 00       	mov    $0x1,%edx
  800152:	b8 03 00 00 00       	mov    $0x3,%eax
  800157:	e8 4d ff ff ff       	call   8000a9 <syscall>
}
  80015c:	c9                   	leave  
  80015d:	c3                   	ret    

0080015e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80015e:	55                   	push   %ebp
  80015f:	89 e5                	mov    %esp,%ebp
  800161:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800164:	6a 00                	push   $0x0
  800166:	6a 00                	push   $0x0
  800168:	6a 00                	push   $0x0
  80016a:	6a 00                	push   $0x0
  80016c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800171:	ba 00 00 00 00       	mov    $0x0,%edx
  800176:	b8 02 00 00 00       	mov    $0x2,%eax
  80017b:	e8 29 ff ff ff       	call   8000a9 <syscall>
}
  800180:	c9                   	leave  
  800181:	c3                   	ret    

00800182 <sys_yield>:

void
sys_yield(void)
{
  800182:	55                   	push   %ebp
  800183:	89 e5                	mov    %esp,%ebp
  800185:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800188:	6a 00                	push   $0x0
  80018a:	6a 00                	push   $0x0
  80018c:	6a 00                	push   $0x0
  80018e:	6a 00                	push   $0x0
  800190:	b9 00 00 00 00       	mov    $0x0,%ecx
  800195:	ba 00 00 00 00       	mov    $0x0,%edx
  80019a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80019f:	e8 05 ff ff ff       	call   8000a9 <syscall>
}
  8001a4:	83 c4 10             	add    $0x10,%esp
  8001a7:	c9                   	leave  
  8001a8:	c3                   	ret    

008001a9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001a9:	55                   	push   %ebp
  8001aa:	89 e5                	mov    %esp,%ebp
  8001ac:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8001af:	6a 00                	push   $0x0
  8001b1:	6a 00                	push   $0x0
  8001b3:	ff 75 10             	push   0x10(%ebp)
  8001b6:	ff 75 0c             	push   0xc(%ebp)
  8001b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001bc:	ba 01 00 00 00       	mov    $0x1,%edx
  8001c1:	b8 04 00 00 00       	mov    $0x4,%eax
  8001c6:	e8 de fe ff ff       	call   8000a9 <syscall>
}
  8001cb:	c9                   	leave  
  8001cc:	c3                   	ret    

008001cd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001cd:	55                   	push   %ebp
  8001ce:	89 e5                	mov    %esp,%ebp
  8001d0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map,
  8001d3:	ff 75 18             	push   0x18(%ebp)
  8001d6:	ff 75 14             	push   0x14(%ebp)
  8001d9:	ff 75 10             	push   0x10(%ebp)
  8001dc:	ff 75 0c             	push   0xc(%ebp)
  8001df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001e2:	ba 01 00 00 00       	mov    $0x1,%edx
  8001e7:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ec:	e8 b8 fe ff ff       	call   8000a9 <syscall>
	               srcenv,
	               (uint32_t) srcva,
	               dstenv,
	               (uint32_t) dstva,
	               perm);
}
  8001f1:	c9                   	leave  
  8001f2:	c3                   	ret    

008001f3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001f3:	55                   	push   %ebp
  8001f4:	89 e5                	mov    %esp,%ebp
  8001f6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8001f9:	6a 00                	push   $0x0
  8001fb:	6a 00                	push   $0x0
  8001fd:	6a 00                	push   $0x0
  8001ff:	ff 75 0c             	push   0xc(%ebp)
  800202:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800205:	ba 01 00 00 00       	mov    $0x1,%edx
  80020a:	b8 06 00 00 00       	mov    $0x6,%eax
  80020f:	e8 95 fe ff ff       	call   8000a9 <syscall>
}
  800214:	c9                   	leave  
  800215:	c3                   	ret    

00800216 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800216:	55                   	push   %ebp
  800217:	89 e5                	mov    %esp,%ebp
  800219:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80021c:	6a 00                	push   $0x0
  80021e:	6a 00                	push   $0x0
  800220:	6a 00                	push   $0x0
  800222:	ff 75 0c             	push   0xc(%ebp)
  800225:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800228:	ba 01 00 00 00       	mov    $0x1,%edx
  80022d:	b8 08 00 00 00       	mov    $0x8,%eax
  800232:	e8 72 fe ff ff       	call   8000a9 <syscall>
}
  800237:	c9                   	leave  
  800238:	c3                   	ret    

00800239 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800239:	55                   	push   %ebp
  80023a:	89 e5                	mov    %esp,%ebp
  80023c:	83 ec 08             	sub    $0x8,%esp
	return syscall(
  80023f:	6a 00                	push   $0x0
  800241:	6a 00                	push   $0x0
  800243:	6a 00                	push   $0x0
  800245:	ff 75 0c             	push   0xc(%ebp)
  800248:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80024b:	ba 01 00 00 00       	mov    $0x1,%edx
  800250:	b8 09 00 00 00       	mov    $0x9,%eax
  800255:	e8 4f fe ff ff       	call   8000a9 <syscall>
	        SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80025a:	c9                   	leave  
  80025b:	c3                   	ret    

0080025c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80025c:	55                   	push   %ebp
  80025d:	89 e5                	mov    %esp,%ebp
  80025f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800262:	6a 00                	push   $0x0
  800264:	ff 75 14             	push   0x14(%ebp)
  800267:	ff 75 10             	push   0x10(%ebp)
  80026a:	ff 75 0c             	push   0xc(%ebp)
  80026d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800270:	ba 00 00 00 00       	mov    $0x0,%edx
  800275:	b8 0b 00 00 00       	mov    $0xb,%eax
  80027a:	e8 2a fe ff ff       	call   8000a9 <syscall>
}
  80027f:	c9                   	leave  
  800280:	c3                   	ret    

00800281 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800281:	55                   	push   %ebp
  800282:	89 e5                	mov    %esp,%ebp
  800284:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t) dstva, 0, 0, 0, 0);
  800287:	6a 00                	push   $0x0
  800289:	6a 00                	push   $0x0
  80028b:	6a 00                	push   $0x0
  80028d:	6a 00                	push   $0x0
  80028f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800292:	ba 01 00 00 00       	mov    $0x1,%edx
  800297:	b8 0c 00 00 00       	mov    $0xc,%eax
  80029c:	e8 08 fe ff ff       	call   8000a9 <syscall>
}
  8002a1:	c9                   	leave  
  8002a2:	c3                   	ret    

008002a3 <sys_get_priority>:

// Get priority of the current process
int
sys_get_priority(void)
{
  8002a3:	55                   	push   %ebp
  8002a4:	89 e5                	mov    %esp,%ebp
  8002a6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_get_priority, 0, 0, 0, 0, 0, 0);
  8002a9:	6a 00                	push   $0x0
  8002ab:	6a 00                	push   $0x0
  8002ad:	6a 00                	push   $0x0
  8002af:	6a 00                	push   $0x0
  8002b1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8002bb:	b8 0d 00 00 00       	mov    $0xd,%eax
  8002c0:	e8 e4 fd ff ff       	call   8000a9 <syscall>
}
  8002c5:	c9                   	leave  
  8002c6:	c3                   	ret    

008002c7 <sys_set_priority>:

// Get priority of the current process
int
sys_set_priority(unsigned int priority)
{
  8002c7:	55                   	push   %ebp
  8002c8:	89 e5                	mov    %esp,%ebp
  8002ca:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, (uint32_t) priority, 0, 0, 0, 0);
  8002cd:	6a 00                	push   $0x0
  8002cf:	6a 00                	push   $0x0
  8002d1:	6a 00                	push   $0x0
  8002d3:	6a 00                	push   $0x0
  8002d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8002dd:	b8 0e 00 00 00       	mov    $0xe,%eax
  8002e2:	e8 c2 fd ff ff       	call   8000a9 <syscall>
}
  8002e7:	c9                   	leave  
  8002e8:	c3                   	ret    

008002e9 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002e9:	55                   	push   %ebp
  8002ea:	89 e5                	mov    %esp,%ebp
  8002ec:	56                   	push   %esi
  8002ed:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002ee:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002f1:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8002f7:	e8 62 fe ff ff       	call   80015e <sys_getenvid>
  8002fc:	83 ec 0c             	sub    $0xc,%esp
  8002ff:	ff 75 0c             	push   0xc(%ebp)
  800302:	ff 75 08             	push   0x8(%ebp)
  800305:	56                   	push   %esi
  800306:	50                   	push   %eax
  800307:	68 d8 0e 80 00       	push   $0x800ed8
  80030c:	e8 b3 00 00 00       	call   8003c4 <cprintf>
	        sys_getenvid(),
	        binaryname,
	        file,
	        line);
	vcprintf(fmt, ap);
  800311:	83 c4 18             	add    $0x18,%esp
  800314:	53                   	push   %ebx
  800315:	ff 75 10             	push   0x10(%ebp)
  800318:	e8 56 00 00 00       	call   800373 <vcprintf>
	cprintf("\n");
  80031d:	c7 04 24 fb 0e 80 00 	movl   $0x800efb,(%esp)
  800324:	e8 9b 00 00 00       	call   8003c4 <cprintf>
  800329:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80032c:	cc                   	int3   
  80032d:	eb fd                	jmp    80032c <_panic+0x43>

0080032f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80032f:	55                   	push   %ebp
  800330:	89 e5                	mov    %esp,%ebp
  800332:	53                   	push   %ebx
  800333:	83 ec 04             	sub    $0x4,%esp
  800336:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800339:	8b 13                	mov    (%ebx),%edx
  80033b:	8d 42 01             	lea    0x1(%edx),%eax
  80033e:	89 03                	mov    %eax,(%ebx)
  800340:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800343:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256 - 1) {
  800347:	3d ff 00 00 00       	cmp    $0xff,%eax
  80034c:	74 09                	je     800357 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80034e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800352:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800355:	c9                   	leave  
  800356:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800357:	83 ec 08             	sub    $0x8,%esp
  80035a:	68 ff 00 00 00       	push   $0xff
  80035f:	8d 43 08             	lea    0x8(%ebx),%eax
  800362:	50                   	push   %eax
  800363:	e8 8a fd ff ff       	call   8000f2 <sys_cputs>
		b->idx = 0;
  800368:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80036e:	83 c4 10             	add    $0x10,%esp
  800371:	eb db                	jmp    80034e <putch+0x1f>

00800373 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800373:	55                   	push   %ebp
  800374:	89 e5                	mov    %esp,%ebp
  800376:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80037c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800383:	00 00 00 
	b.cnt = 0;
  800386:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80038d:	00 00 00 
	vprintfmt((void *) putch, &b, fmt, ap);
  800390:	ff 75 0c             	push   0xc(%ebp)
  800393:	ff 75 08             	push   0x8(%ebp)
  800396:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80039c:	50                   	push   %eax
  80039d:	68 2f 03 80 00       	push   $0x80032f
  8003a2:	e8 74 01 00 00       	call   80051b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003a7:	83 c4 08             	add    $0x8,%esp
  8003aa:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8003b0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003b6:	50                   	push   %eax
  8003b7:	e8 36 fd ff ff       	call   8000f2 <sys_cputs>

	return b.cnt;
}
  8003bc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003c2:	c9                   	leave  
  8003c3:	c3                   	ret    

008003c4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003c4:	55                   	push   %ebp
  8003c5:	89 e5                	mov    %esp,%ebp
  8003c7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003ca:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003cd:	50                   	push   %eax
  8003ce:	ff 75 08             	push   0x8(%ebp)
  8003d1:	e8 9d ff ff ff       	call   800373 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003d6:	c9                   	leave  
  8003d7:	c3                   	ret    

008003d8 <printnum>:
         void *putdat,
         unsigned long long num,
         unsigned base,
         int width,
         int padc)
{
  8003d8:	55                   	push   %ebp
  8003d9:	89 e5                	mov    %esp,%ebp
  8003db:	57                   	push   %edi
  8003dc:	56                   	push   %esi
  8003dd:	53                   	push   %ebx
  8003de:	83 ec 1c             	sub    $0x1c,%esp
  8003e1:	89 c7                	mov    %eax,%edi
  8003e3:	89 d6                	mov    %edx,%esi
  8003e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003eb:	89 d1                	mov    %edx,%ecx
  8003ed:	89 c2                	mov    %eax,%edx
  8003ef:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003f2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8003f5:	8b 45 10             	mov    0x10(%ebp),%eax
  8003f8:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003fb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003fe:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800405:	39 c2                	cmp    %eax,%edx
  800407:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80040a:	72 3e                	jb     80044a <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80040c:	83 ec 0c             	sub    $0xc,%esp
  80040f:	ff 75 18             	push   0x18(%ebp)
  800412:	83 eb 01             	sub    $0x1,%ebx
  800415:	53                   	push   %ebx
  800416:	50                   	push   %eax
  800417:	83 ec 08             	sub    $0x8,%esp
  80041a:	ff 75 e4             	push   -0x1c(%ebp)
  80041d:	ff 75 e0             	push   -0x20(%ebp)
  800420:	ff 75 dc             	push   -0x24(%ebp)
  800423:	ff 75 d8             	push   -0x28(%ebp)
  800426:	e8 25 08 00 00       	call   800c50 <__udivdi3>
  80042b:	83 c4 18             	add    $0x18,%esp
  80042e:	52                   	push   %edx
  80042f:	50                   	push   %eax
  800430:	89 f2                	mov    %esi,%edx
  800432:	89 f8                	mov    %edi,%eax
  800434:	e8 9f ff ff ff       	call   8003d8 <printnum>
  800439:	83 c4 20             	add    $0x20,%esp
  80043c:	eb 13                	jmp    800451 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80043e:	83 ec 08             	sub    $0x8,%esp
  800441:	56                   	push   %esi
  800442:	ff 75 18             	push   0x18(%ebp)
  800445:	ff d7                	call   *%edi
  800447:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80044a:	83 eb 01             	sub    $0x1,%ebx
  80044d:	85 db                	test   %ebx,%ebx
  80044f:	7f ed                	jg     80043e <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800451:	83 ec 08             	sub    $0x8,%esp
  800454:	56                   	push   %esi
  800455:	83 ec 04             	sub    $0x4,%esp
  800458:	ff 75 e4             	push   -0x1c(%ebp)
  80045b:	ff 75 e0             	push   -0x20(%ebp)
  80045e:	ff 75 dc             	push   -0x24(%ebp)
  800461:	ff 75 d8             	push   -0x28(%ebp)
  800464:	e8 07 09 00 00       	call   800d70 <__umoddi3>
  800469:	83 c4 14             	add    $0x14,%esp
  80046c:	0f be 80 fd 0e 80 00 	movsbl 0x800efd(%eax),%eax
  800473:	50                   	push   %eax
  800474:	ff d7                	call   *%edi
}
  800476:	83 c4 10             	add    $0x10,%esp
  800479:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80047c:	5b                   	pop    %ebx
  80047d:	5e                   	pop    %esi
  80047e:	5f                   	pop    %edi
  80047f:	5d                   	pop    %ebp
  800480:	c3                   	ret    

00800481 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800481:	83 fa 01             	cmp    $0x1,%edx
  800484:	7f 13                	jg     800499 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800486:	85 d2                	test   %edx,%edx
  800488:	74 1c                	je     8004a6 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  80048a:	8b 10                	mov    (%eax),%edx
  80048c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80048f:	89 08                	mov    %ecx,(%eax)
  800491:	8b 02                	mov    (%edx),%eax
  800493:	ba 00 00 00 00       	mov    $0x0,%edx
  800498:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  800499:	8b 10                	mov    (%eax),%edx
  80049b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80049e:	89 08                	mov    %ecx,(%eax)
  8004a0:	8b 02                	mov    (%edx),%eax
  8004a2:	8b 52 04             	mov    0x4(%edx),%edx
  8004a5:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  8004a6:	8b 10                	mov    (%eax),%edx
  8004a8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004ab:	89 08                	mov    %ecx,(%eax)
  8004ad:	8b 02                	mov    (%edx),%eax
  8004af:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004b4:	c3                   	ret    

008004b5 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004b5:	83 fa 01             	cmp    $0x1,%edx
  8004b8:	7f 0f                	jg     8004c9 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  8004ba:	85 d2                	test   %edx,%edx
  8004bc:	74 18                	je     8004d6 <getint+0x21>
		return va_arg(*ap, long);
  8004be:	8b 10                	mov    (%eax),%edx
  8004c0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004c3:	89 08                	mov    %ecx,(%eax)
  8004c5:	8b 02                	mov    (%edx),%eax
  8004c7:	99                   	cltd   
  8004c8:	c3                   	ret    
		return va_arg(*ap, long long);
  8004c9:	8b 10                	mov    (%eax),%edx
  8004cb:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004ce:	89 08                	mov    %ecx,(%eax)
  8004d0:	8b 02                	mov    (%edx),%eax
  8004d2:	8b 52 04             	mov    0x4(%edx),%edx
  8004d5:	c3                   	ret    
	else
		return va_arg(*ap, int);
  8004d6:	8b 10                	mov    (%eax),%edx
  8004d8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004db:	89 08                	mov    %ecx,(%eax)
  8004dd:	8b 02                	mov    (%edx),%eax
  8004df:	99                   	cltd   
}
  8004e0:	c3                   	ret    

008004e1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004e1:	55                   	push   %ebp
  8004e2:	89 e5                	mov    %esp,%ebp
  8004e4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004e7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004eb:	8b 10                	mov    (%eax),%edx
  8004ed:	3b 50 04             	cmp    0x4(%eax),%edx
  8004f0:	73 0a                	jae    8004fc <sprintputch+0x1b>
		*b->buf++ = ch;
  8004f2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004f5:	89 08                	mov    %ecx,(%eax)
  8004f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8004fa:	88 02                	mov    %al,(%edx)
}
  8004fc:	5d                   	pop    %ebp
  8004fd:	c3                   	ret    

008004fe <printfmt>:
{
  8004fe:	55                   	push   %ebp
  8004ff:	89 e5                	mov    %esp,%ebp
  800501:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800504:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800507:	50                   	push   %eax
  800508:	ff 75 10             	push   0x10(%ebp)
  80050b:	ff 75 0c             	push   0xc(%ebp)
  80050e:	ff 75 08             	push   0x8(%ebp)
  800511:	e8 05 00 00 00       	call   80051b <vprintfmt>
}
  800516:	83 c4 10             	add    $0x10,%esp
  800519:	c9                   	leave  
  80051a:	c3                   	ret    

0080051b <vprintfmt>:
{
  80051b:	55                   	push   %ebp
  80051c:	89 e5                	mov    %esp,%ebp
  80051e:	57                   	push   %edi
  80051f:	56                   	push   %esi
  800520:	53                   	push   %ebx
  800521:	83 ec 2c             	sub    $0x2c,%esp
  800524:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800527:	8b 75 0c             	mov    0xc(%ebp),%esi
  80052a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80052d:	eb 0a                	jmp    800539 <vprintfmt+0x1e>
			putch(ch, putdat);
  80052f:	83 ec 08             	sub    $0x8,%esp
  800532:	56                   	push   %esi
  800533:	50                   	push   %eax
  800534:	ff d3                	call   *%ebx
  800536:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800539:	83 c7 01             	add    $0x1,%edi
  80053c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800540:	83 f8 25             	cmp    $0x25,%eax
  800543:	74 0c                	je     800551 <vprintfmt+0x36>
			if (ch == '\0')
  800545:	85 c0                	test   %eax,%eax
  800547:	75 e6                	jne    80052f <vprintfmt+0x14>
}
  800549:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80054c:	5b                   	pop    %ebx
  80054d:	5e                   	pop    %esi
  80054e:	5f                   	pop    %edi
  80054f:	5d                   	pop    %ebp
  800550:	c3                   	ret    
		padc = ' ';
  800551:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
		altflag = 0;
  800555:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80055c:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800563:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80056a:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80056f:	8d 47 01             	lea    0x1(%edi),%eax
  800572:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800575:	0f b6 17             	movzbl (%edi),%edx
  800578:	8d 42 dd             	lea    -0x23(%edx),%eax
  80057b:	3c 55                	cmp    $0x55,%al
  80057d:	0f 87 b7 02 00 00    	ja     80083a <vprintfmt+0x31f>
  800583:	0f b6 c0             	movzbl %al,%eax
  800586:	ff 24 85 c0 0f 80 00 	jmp    *0x800fc0(,%eax,4)
  80058d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800590:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800594:	eb d9                	jmp    80056f <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800596:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800599:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  80059d:	eb d0                	jmp    80056f <vprintfmt+0x54>
  80059f:	0f b6 d2             	movzbl %dl,%edx
  8005a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0;; ++fmt) {
  8005a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8005aa:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8005ad:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005b0:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8005b4:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8005b7:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8005ba:	83 f9 09             	cmp    $0x9,%ecx
  8005bd:	77 52                	ja     800611 <vprintfmt+0xf6>
			for (precision = 0;; ++fmt) {
  8005bf:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8005c2:	eb e9                	jmp    8005ad <vprintfmt+0x92>
			precision = va_arg(ap, int);
  8005c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c7:	8d 50 04             	lea    0x4(%eax),%edx
  8005ca:	89 55 14             	mov    %edx,0x14(%ebp)
  8005cd:	8b 00                	mov    (%eax),%eax
  8005cf:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8005d5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005d9:	79 94                	jns    80056f <vprintfmt+0x54>
				width = precision, precision = -1;
  8005db:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005de:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005e1:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8005e8:	eb 85                	jmp    80056f <vprintfmt+0x54>
  8005ea:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005ed:	85 d2                	test   %edx,%edx
  8005ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8005f4:	0f 49 c2             	cmovns %edx,%eax
  8005f7:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005fd:	e9 6d ff ff ff       	jmp    80056f <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800602:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800605:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80060c:	e9 5e ff ff ff       	jmp    80056f <vprintfmt+0x54>
  800611:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800614:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800617:	eb bc                	jmp    8005d5 <vprintfmt+0xba>
			lflag++;
  800619:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80061c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80061f:	e9 4b ff ff ff       	jmp    80056f <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800624:	8b 45 14             	mov    0x14(%ebp),%eax
  800627:	8d 50 04             	lea    0x4(%eax),%edx
  80062a:	89 55 14             	mov    %edx,0x14(%ebp)
  80062d:	83 ec 08             	sub    $0x8,%esp
  800630:	56                   	push   %esi
  800631:	ff 30                	push   (%eax)
  800633:	ff d3                	call   *%ebx
			break;
  800635:	83 c4 10             	add    $0x10,%esp
  800638:	e9 94 01 00 00       	jmp    8007d1 <vprintfmt+0x2b6>
			err = va_arg(ap, int);
  80063d:	8b 45 14             	mov    0x14(%ebp),%eax
  800640:	8d 50 04             	lea    0x4(%eax),%edx
  800643:	89 55 14             	mov    %edx,0x14(%ebp)
  800646:	8b 10                	mov    (%eax),%edx
  800648:	89 d0                	mov    %edx,%eax
  80064a:	f7 d8                	neg    %eax
  80064c:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80064f:	83 f8 08             	cmp    $0x8,%eax
  800652:	7f 20                	jg     800674 <vprintfmt+0x159>
  800654:	8b 14 85 20 11 80 00 	mov    0x801120(,%eax,4),%edx
  80065b:	85 d2                	test   %edx,%edx
  80065d:	74 15                	je     800674 <vprintfmt+0x159>
				printfmt(putch, putdat, "%s", p);
  80065f:	52                   	push   %edx
  800660:	68 1e 0f 80 00       	push   $0x800f1e
  800665:	56                   	push   %esi
  800666:	53                   	push   %ebx
  800667:	e8 92 fe ff ff       	call   8004fe <printfmt>
  80066c:	83 c4 10             	add    $0x10,%esp
  80066f:	e9 5d 01 00 00       	jmp    8007d1 <vprintfmt+0x2b6>
				printfmt(putch, putdat, "error %d", err);
  800674:	50                   	push   %eax
  800675:	68 15 0f 80 00       	push   $0x800f15
  80067a:	56                   	push   %esi
  80067b:	53                   	push   %ebx
  80067c:	e8 7d fe ff ff       	call   8004fe <printfmt>
  800681:	83 c4 10             	add    $0x10,%esp
  800684:	e9 48 01 00 00       	jmp    8007d1 <vprintfmt+0x2b6>
			if ((p = va_arg(ap, char *)) == NULL)
  800689:	8b 45 14             	mov    0x14(%ebp),%eax
  80068c:	8d 50 04             	lea    0x4(%eax),%edx
  80068f:	89 55 14             	mov    %edx,0x14(%ebp)
  800692:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800694:	85 ff                	test   %edi,%edi
  800696:	b8 0e 0f 80 00       	mov    $0x800f0e,%eax
  80069b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80069e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006a2:	7e 06                	jle    8006aa <vprintfmt+0x18f>
  8006a4:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8006a8:	75 0a                	jne    8006b4 <vprintfmt+0x199>
  8006aa:	89 f8                	mov    %edi,%eax
  8006ac:	03 45 e0             	add    -0x20(%ebp),%eax
  8006af:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006b2:	eb 59                	jmp    80070d <vprintfmt+0x1f2>
				for (width -= strnlen(p, precision); width > 0;
  8006b4:	83 ec 08             	sub    $0x8,%esp
  8006b7:	ff 75 d8             	push   -0x28(%ebp)
  8006ba:	57                   	push   %edi
  8006bb:	e8 1a 02 00 00       	call   8008da <strnlen>
  8006c0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006c3:	29 c1                	sub    %eax,%ecx
  8006c5:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006c8:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006cb:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  8006cf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006d2:	89 7d d0             	mov    %edi,-0x30(%ebp)
  8006d5:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0;
  8006d7:	eb 0f                	jmp    8006e8 <vprintfmt+0x1cd>
					putch(padc, putdat);
  8006d9:	83 ec 08             	sub    $0x8,%esp
  8006dc:	56                   	push   %esi
  8006dd:	ff 75 e0             	push   -0x20(%ebp)
  8006e0:	ff d3                	call   *%ebx
				     width--)
  8006e2:	83 ef 01             	sub    $0x1,%edi
  8006e5:	83 c4 10             	add    $0x10,%esp
				for (width -= strnlen(p, precision); width > 0;
  8006e8:	85 ff                	test   %edi,%edi
  8006ea:	7f ed                	jg     8006d9 <vprintfmt+0x1be>
  8006ec:	8b 7d d0             	mov    -0x30(%ebp),%edi
  8006ef:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006f2:	85 c9                	test   %ecx,%ecx
  8006f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f9:	0f 49 c1             	cmovns %ecx,%eax
  8006fc:	29 c1                	sub    %eax,%ecx
  8006fe:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800701:	eb a7                	jmp    8006aa <vprintfmt+0x18f>
					putch(ch, putdat);
  800703:	83 ec 08             	sub    $0x8,%esp
  800706:	56                   	push   %esi
  800707:	52                   	push   %edx
  800708:	ff d3                	call   *%ebx
  80070a:	83 c4 10             	add    $0x10,%esp
  80070d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800710:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' &&
  800712:	83 c7 01             	add    $0x1,%edi
  800715:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800719:	0f be d0             	movsbl %al,%edx
  80071c:	85 d2                	test   %edx,%edx
  80071e:	74 42                	je     800762 <vprintfmt+0x247>
  800720:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800724:	78 06                	js     80072c <vprintfmt+0x211>
			       (precision < 0 || --precision >= 0);
  800726:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80072a:	78 1e                	js     80074a <vprintfmt+0x22f>
				if (altflag && (ch < ' ' || ch > '~'))
  80072c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800730:	74 d1                	je     800703 <vprintfmt+0x1e8>
  800732:	0f be c0             	movsbl %al,%eax
  800735:	83 e8 20             	sub    $0x20,%eax
  800738:	83 f8 5e             	cmp    $0x5e,%eax
  80073b:	76 c6                	jbe    800703 <vprintfmt+0x1e8>
					putch('?', putdat);
  80073d:	83 ec 08             	sub    $0x8,%esp
  800740:	56                   	push   %esi
  800741:	6a 3f                	push   $0x3f
  800743:	ff d3                	call   *%ebx
  800745:	83 c4 10             	add    $0x10,%esp
  800748:	eb c3                	jmp    80070d <vprintfmt+0x1f2>
  80074a:	89 cf                	mov    %ecx,%edi
  80074c:	eb 0e                	jmp    80075c <vprintfmt+0x241>
				putch(' ', putdat);
  80074e:	83 ec 08             	sub    $0x8,%esp
  800751:	56                   	push   %esi
  800752:	6a 20                	push   $0x20
  800754:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  800756:	83 ef 01             	sub    $0x1,%edi
  800759:	83 c4 10             	add    $0x10,%esp
  80075c:	85 ff                	test   %edi,%edi
  80075e:	7f ee                	jg     80074e <vprintfmt+0x233>
  800760:	eb 6f                	jmp    8007d1 <vprintfmt+0x2b6>
  800762:	89 cf                	mov    %ecx,%edi
  800764:	eb f6                	jmp    80075c <vprintfmt+0x241>
			num = getint(&ap, lflag);
  800766:	89 ca                	mov    %ecx,%edx
  800768:	8d 45 14             	lea    0x14(%ebp),%eax
  80076b:	e8 45 fd ff ff       	call   8004b5 <getint>
  800770:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800773:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800776:	85 d2                	test   %edx,%edx
  800778:	78 0b                	js     800785 <vprintfmt+0x26a>
			num = getint(&ap, lflag);
  80077a:	89 d1                	mov    %edx,%ecx
  80077c:	89 c2                	mov    %eax,%edx
			base = 10;
  80077e:	bf 0a 00 00 00       	mov    $0xa,%edi
  800783:	eb 32                	jmp    8007b7 <vprintfmt+0x29c>
				putch('-', putdat);
  800785:	83 ec 08             	sub    $0x8,%esp
  800788:	56                   	push   %esi
  800789:	6a 2d                	push   $0x2d
  80078b:	ff d3                	call   *%ebx
				num = -(long long) num;
  80078d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800790:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800793:	f7 da                	neg    %edx
  800795:	83 d1 00             	adc    $0x0,%ecx
  800798:	f7 d9                	neg    %ecx
  80079a:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80079d:	bf 0a 00 00 00       	mov    $0xa,%edi
  8007a2:	eb 13                	jmp    8007b7 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  8007a4:	89 ca                	mov    %ecx,%edx
  8007a6:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a9:	e8 d3 fc ff ff       	call   800481 <getuint>
  8007ae:	89 d1                	mov    %edx,%ecx
  8007b0:	89 c2                	mov    %eax,%edx
			base = 10;
  8007b2:	bf 0a 00 00 00       	mov    $0xa,%edi
			printnum(putch, putdat, num, base, width, padc);
  8007b7:	83 ec 0c             	sub    $0xc,%esp
  8007ba:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  8007be:	50                   	push   %eax
  8007bf:	ff 75 e0             	push   -0x20(%ebp)
  8007c2:	57                   	push   %edi
  8007c3:	51                   	push   %ecx
  8007c4:	52                   	push   %edx
  8007c5:	89 f2                	mov    %esi,%edx
  8007c7:	89 d8                	mov    %ebx,%eax
  8007c9:	e8 0a fc ff ff       	call   8003d8 <printnum>
			break;
  8007ce:	83 c4 20             	add    $0x20,%esp
{
  8007d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007d4:	e9 60 fd ff ff       	jmp    800539 <vprintfmt+0x1e>
			num = getuint(&ap, lflag);
  8007d9:	89 ca                	mov    %ecx,%edx
  8007db:	8d 45 14             	lea    0x14(%ebp),%eax
  8007de:	e8 9e fc ff ff       	call   800481 <getuint>
  8007e3:	89 d1                	mov    %edx,%ecx
  8007e5:	89 c2                	mov    %eax,%edx
			base = 8;
  8007e7:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  8007ec:	eb c9                	jmp    8007b7 <vprintfmt+0x29c>
			putch('0', putdat);
  8007ee:	83 ec 08             	sub    $0x8,%esp
  8007f1:	56                   	push   %esi
  8007f2:	6a 30                	push   $0x30
  8007f4:	ff d3                	call   *%ebx
			putch('x', putdat);
  8007f6:	83 c4 08             	add    $0x8,%esp
  8007f9:	56                   	push   %esi
  8007fa:	6a 78                	push   $0x78
  8007fc:	ff d3                	call   *%ebx
			num = (unsigned long long) (uintptr_t) va_arg(ap, void *);
  8007fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800801:	8d 50 04             	lea    0x4(%eax),%edx
  800804:	89 55 14             	mov    %edx,0x14(%ebp)
  800807:	8b 10                	mov    (%eax),%edx
  800809:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80080e:	83 c4 10             	add    $0x10,%esp
			base = 16;
  800811:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  800816:	eb 9f                	jmp    8007b7 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  800818:	89 ca                	mov    %ecx,%edx
  80081a:	8d 45 14             	lea    0x14(%ebp),%eax
  80081d:	e8 5f fc ff ff       	call   800481 <getuint>
  800822:	89 d1                	mov    %edx,%ecx
  800824:	89 c2                	mov    %eax,%edx
			base = 16;
  800826:	bf 10 00 00 00       	mov    $0x10,%edi
  80082b:	eb 8a                	jmp    8007b7 <vprintfmt+0x29c>
			putch(ch, putdat);
  80082d:	83 ec 08             	sub    $0x8,%esp
  800830:	56                   	push   %esi
  800831:	6a 25                	push   $0x25
  800833:	ff d3                	call   *%ebx
			break;
  800835:	83 c4 10             	add    $0x10,%esp
  800838:	eb 97                	jmp    8007d1 <vprintfmt+0x2b6>
			putch('%', putdat);
  80083a:	83 ec 08             	sub    $0x8,%esp
  80083d:	56                   	push   %esi
  80083e:	6a 25                	push   $0x25
  800840:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  800842:	83 c4 10             	add    $0x10,%esp
  800845:	89 f8                	mov    %edi,%eax
  800847:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80084b:	74 05                	je     800852 <vprintfmt+0x337>
  80084d:	83 e8 01             	sub    $0x1,%eax
  800850:	eb f5                	jmp    800847 <vprintfmt+0x32c>
  800852:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800855:	e9 77 ff ff ff       	jmp    8007d1 <vprintfmt+0x2b6>

0080085a <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80085a:	55                   	push   %ebp
  80085b:	89 e5                	mov    %esp,%ebp
  80085d:	83 ec 18             	sub    $0x18,%esp
  800860:	8b 45 08             	mov    0x8(%ebp),%eax
  800863:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = { buf, buf + n - 1, 0 };
  800866:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800869:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80086d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800870:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800877:	85 c0                	test   %eax,%eax
  800879:	74 26                	je     8008a1 <vsnprintf+0x47>
  80087b:	85 d2                	test   %edx,%edx
  80087d:	7e 22                	jle    8008a1 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *) sprintputch, &b, fmt, ap);
  80087f:	ff 75 14             	push   0x14(%ebp)
  800882:	ff 75 10             	push   0x10(%ebp)
  800885:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800888:	50                   	push   %eax
  800889:	68 e1 04 80 00       	push   $0x8004e1
  80088e:	e8 88 fc ff ff       	call   80051b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800893:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800896:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800899:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80089c:	83 c4 10             	add    $0x10,%esp
}
  80089f:	c9                   	leave  
  8008a0:	c3                   	ret    
		return -E_INVAL;
  8008a1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008a6:	eb f7                	jmp    80089f <vsnprintf+0x45>

008008a8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008a8:	55                   	push   %ebp
  8008a9:	89 e5                	mov    %esp,%ebp
  8008ab:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008ae:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008b1:	50                   	push   %eax
  8008b2:	ff 75 10             	push   0x10(%ebp)
  8008b5:	ff 75 0c             	push   0xc(%ebp)
  8008b8:	ff 75 08             	push   0x8(%ebp)
  8008bb:	e8 9a ff ff ff       	call   80085a <vsnprintf>
	va_end(ap);

	return rc;
}
  8008c0:	c9                   	leave  
  8008c1:	c3                   	ret    

008008c2 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8008cd:	eb 03                	jmp    8008d2 <strlen+0x10>
		n++;
  8008cf:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008d2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008d6:	75 f7                	jne    8008cf <strlen+0xd>
	return n;
}
  8008d8:	5d                   	pop    %ebp
  8008d9:	c3                   	ret    

008008da <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008da:	55                   	push   %ebp
  8008db:	89 e5                	mov    %esp,%ebp
  8008dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008e0:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e8:	eb 03                	jmp    8008ed <strnlen+0x13>
		n++;
  8008ea:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008ed:	39 d0                	cmp    %edx,%eax
  8008ef:	74 08                	je     8008f9 <strnlen+0x1f>
  8008f1:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008f5:	75 f3                	jne    8008ea <strnlen+0x10>
  8008f7:	89 c2                	mov    %eax,%edx
	return n;
}
  8008f9:	89 d0                	mov    %edx,%eax
  8008fb:	5d                   	pop    %ebp
  8008fc:	c3                   	ret    

008008fd <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008fd:	55                   	push   %ebp
  8008fe:	89 e5                	mov    %esp,%ebp
  800900:	53                   	push   %ebx
  800901:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800904:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800907:	b8 00 00 00 00       	mov    $0x0,%eax
  80090c:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800910:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800913:	83 c0 01             	add    $0x1,%eax
  800916:	84 d2                	test   %dl,%dl
  800918:	75 f2                	jne    80090c <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80091a:	89 c8                	mov    %ecx,%eax
  80091c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80091f:	c9                   	leave  
  800920:	c3                   	ret    

00800921 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800921:	55                   	push   %ebp
  800922:	89 e5                	mov    %esp,%ebp
  800924:	53                   	push   %ebx
  800925:	83 ec 10             	sub    $0x10,%esp
  800928:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80092b:	53                   	push   %ebx
  80092c:	e8 91 ff ff ff       	call   8008c2 <strlen>
  800931:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800934:	ff 75 0c             	push   0xc(%ebp)
  800937:	01 d8                	add    %ebx,%eax
  800939:	50                   	push   %eax
  80093a:	e8 be ff ff ff       	call   8008fd <strcpy>
	return dst;
}
  80093f:	89 d8                	mov    %ebx,%eax
  800941:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800944:	c9                   	leave  
  800945:	c3                   	ret    

00800946 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size)
{
  800946:	55                   	push   %ebp
  800947:	89 e5                	mov    %esp,%ebp
  800949:	56                   	push   %esi
  80094a:	53                   	push   %ebx
  80094b:	8b 75 08             	mov    0x8(%ebp),%esi
  80094e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800951:	89 f3                	mov    %esi,%ebx
  800953:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800956:	89 f0                	mov    %esi,%eax
  800958:	eb 0f                	jmp    800969 <strncpy+0x23>
		*dst++ = *src;
  80095a:	83 c0 01             	add    $0x1,%eax
  80095d:	0f b6 0a             	movzbl (%edx),%ecx
  800960:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800963:	80 f9 01             	cmp    $0x1,%cl
  800966:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800969:	39 d8                	cmp    %ebx,%eax
  80096b:	75 ed                	jne    80095a <strncpy+0x14>
	}
	return ret;
}
  80096d:	89 f0                	mov    %esi,%eax
  80096f:	5b                   	pop    %ebx
  800970:	5e                   	pop    %esi
  800971:	5d                   	pop    %ebp
  800972:	c3                   	ret    

00800973 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800973:	55                   	push   %ebp
  800974:	89 e5                	mov    %esp,%ebp
  800976:	56                   	push   %esi
  800977:	53                   	push   %ebx
  800978:	8b 75 08             	mov    0x8(%ebp),%esi
  80097b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80097e:	8b 55 10             	mov    0x10(%ebp),%edx
  800981:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800983:	85 d2                	test   %edx,%edx
  800985:	74 21                	je     8009a8 <strlcpy+0x35>
  800987:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80098b:	89 f2                	mov    %esi,%edx
  80098d:	eb 09                	jmp    800998 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80098f:	83 c1 01             	add    $0x1,%ecx
  800992:	83 c2 01             	add    $0x1,%edx
  800995:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800998:	39 c2                	cmp    %eax,%edx
  80099a:	74 09                	je     8009a5 <strlcpy+0x32>
  80099c:	0f b6 19             	movzbl (%ecx),%ebx
  80099f:	84 db                	test   %bl,%bl
  8009a1:	75 ec                	jne    80098f <strlcpy+0x1c>
  8009a3:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8009a5:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009a8:	29 f0                	sub    %esi,%eax
}
  8009aa:	5b                   	pop    %ebx
  8009ab:	5e                   	pop    %esi
  8009ac:	5d                   	pop    %ebp
  8009ad:	c3                   	ret    

008009ae <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009ae:	55                   	push   %ebp
  8009af:	89 e5                	mov    %esp,%ebp
  8009b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009b4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009b7:	eb 06                	jmp    8009bf <strcmp+0x11>
		p++, q++;
  8009b9:	83 c1 01             	add    $0x1,%ecx
  8009bc:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8009bf:	0f b6 01             	movzbl (%ecx),%eax
  8009c2:	84 c0                	test   %al,%al
  8009c4:	74 04                	je     8009ca <strcmp+0x1c>
  8009c6:	3a 02                	cmp    (%edx),%al
  8009c8:	74 ef                	je     8009b9 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009ca:	0f b6 c0             	movzbl %al,%eax
  8009cd:	0f b6 12             	movzbl (%edx),%edx
  8009d0:	29 d0                	sub    %edx,%eax
}
  8009d2:	5d                   	pop    %ebp
  8009d3:	c3                   	ret    

008009d4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009d4:	55                   	push   %ebp
  8009d5:	89 e5                	mov    %esp,%ebp
  8009d7:	53                   	push   %ebx
  8009d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009db:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009de:	89 c3                	mov    %eax,%ebx
  8009e0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009e3:	eb 06                	jmp    8009eb <strncmp+0x17>
		n--, p++, q++;
  8009e5:	83 c0 01             	add    $0x1,%eax
  8009e8:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009eb:	39 d8                	cmp    %ebx,%eax
  8009ed:	74 18                	je     800a07 <strncmp+0x33>
  8009ef:	0f b6 08             	movzbl (%eax),%ecx
  8009f2:	84 c9                	test   %cl,%cl
  8009f4:	74 04                	je     8009fa <strncmp+0x26>
  8009f6:	3a 0a                	cmp    (%edx),%cl
  8009f8:	74 eb                	je     8009e5 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009fa:	0f b6 00             	movzbl (%eax),%eax
  8009fd:	0f b6 12             	movzbl (%edx),%edx
  800a00:	29 d0                	sub    %edx,%eax
}
  800a02:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a05:	c9                   	leave  
  800a06:	c3                   	ret    
		return 0;
  800a07:	b8 00 00 00 00       	mov    $0x0,%eax
  800a0c:	eb f4                	jmp    800a02 <strncmp+0x2e>

00800a0e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a0e:	55                   	push   %ebp
  800a0f:	89 e5                	mov    %esp,%ebp
  800a11:	8b 45 08             	mov    0x8(%ebp),%eax
  800a14:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a18:	eb 03                	jmp    800a1d <strchr+0xf>
  800a1a:	83 c0 01             	add    $0x1,%eax
  800a1d:	0f b6 10             	movzbl (%eax),%edx
  800a20:	84 d2                	test   %dl,%dl
  800a22:	74 06                	je     800a2a <strchr+0x1c>
		if (*s == c)
  800a24:	38 ca                	cmp    %cl,%dl
  800a26:	75 f2                	jne    800a1a <strchr+0xc>
  800a28:	eb 05                	jmp    800a2f <strchr+0x21>
			return (char *) s;
	return 0;
  800a2a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a2f:	5d                   	pop    %ebp
  800a30:	c3                   	ret    

00800a31 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a31:	55                   	push   %ebp
  800a32:	89 e5                	mov    %esp,%ebp
  800a34:	8b 45 08             	mov    0x8(%ebp),%eax
  800a37:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a3b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a3e:	38 ca                	cmp    %cl,%dl
  800a40:	74 09                	je     800a4b <strfind+0x1a>
  800a42:	84 d2                	test   %dl,%dl
  800a44:	74 05                	je     800a4b <strfind+0x1a>
	for (; *s; s++)
  800a46:	83 c0 01             	add    $0x1,%eax
  800a49:	eb f0                	jmp    800a3b <strfind+0xa>
			break;
	return (char *) s;
}
  800a4b:	5d                   	pop    %ebp
  800a4c:	c3                   	ret    

00800a4d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a4d:	55                   	push   %ebp
  800a4e:	89 e5                	mov    %esp,%ebp
  800a50:	57                   	push   %edi
  800a51:	56                   	push   %esi
  800a52:	53                   	push   %ebx
  800a53:	8b 55 08             	mov    0x8(%ebp),%edx
  800a56:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  800a59:	85 c9                	test   %ecx,%ecx
  800a5b:	74 33                	je     800a90 <memset+0x43>
		return v;
	if ((int) v % 4 == 0 && n % 4 == 0) {
  800a5d:	89 d0                	mov    %edx,%eax
  800a5f:	09 c8                	or     %ecx,%eax
  800a61:	a8 03                	test   $0x3,%al
  800a63:	75 23                	jne    800a88 <memset+0x3b>
		c &= 0xFF;
  800a65:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  800a69:	89 d8                	mov    %ebx,%eax
  800a6b:	c1 e0 08             	shl    $0x8,%eax
  800a6e:	89 df                	mov    %ebx,%edi
  800a70:	c1 e7 18             	shl    $0x18,%edi
  800a73:	89 de                	mov    %ebx,%esi
  800a75:	c1 e6 10             	shl    $0x10,%esi
  800a78:	09 f7                	or     %esi,%edi
  800a7a:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
		             : "=D"(p), "=c"(n)
		             : "D"(p), "a"(c), "c"(n / 4)
  800a7c:	c1 e9 02             	shr    $0x2,%ecx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  800a7f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800a81:	89 d7                	mov    %edx,%edi
  800a83:	fc                   	cld    
  800a84:	f3 ab                	rep stos %eax,%es:(%edi)
  800a86:	eb 08                	jmp    800a90 <memset+0x43>
		             : "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a88:	89 d7                	mov    %edx,%edi
  800a8a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a8d:	fc                   	cld    
  800a8e:	f3 aa                	rep stos %al,%es:(%edi)
		             : "=D"(p), "=c"(n)
		             : "0"(p), "a"(c), "1"(n)
		             : "cc", "memory");
	return v;
}
  800a90:	89 d0                	mov    %edx,%eax
  800a92:	5b                   	pop    %ebx
  800a93:	5e                   	pop    %esi
  800a94:	5f                   	pop    %edi
  800a95:	5d                   	pop    %ebp
  800a96:	c3                   	ret    

00800a97 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a97:	55                   	push   %ebp
  800a98:	89 e5                	mov    %esp,%ebp
  800a9a:	57                   	push   %edi
  800a9b:	56                   	push   %esi
  800a9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800aa5:	39 c6                	cmp    %eax,%esi
  800aa7:	73 32                	jae    800adb <memmove+0x44>
  800aa9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800aac:	39 c2                	cmp    %eax,%edx
  800aae:	76 2b                	jbe    800adb <memmove+0x44>
		s += n;
		d += n;
  800ab0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  800ab3:	89 d6                	mov    %edx,%esi
  800ab5:	09 fe                	or     %edi,%esi
  800ab7:	09 ce                	or     %ecx,%esi
  800ab9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800abf:	75 0e                	jne    800acf <memmove+0x38>
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  800ac1:	83 ef 04             	sub    $0x4,%edi
			             "S"(s - 4),
  800ac4:	8d 72 fc             	lea    -0x4(%edx),%esi
			             "c"(n / 4)
  800ac7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  800aca:	fd                   	std    
  800acb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800acd:	eb 09                	jmp    800ad8 <memmove+0x41>
			             : "cc", "memory");
		else
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  800acf:	83 ef 01             	sub    $0x1,%edi
			             "S"(s - 1),
  800ad2:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  800ad5:	fd                   	std    
  800ad6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             "c"(n)
			             : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ad8:	fc                   	cld    
  800ad9:	eb 1a                	jmp    800af5 <memmove+0x5e>
	} else {
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  800adb:	89 f2                	mov    %esi,%edx
  800add:	09 c2                	or     %eax,%edx
  800adf:	09 ca                	or     %ecx,%edx
  800ae1:	f6 c2 03             	test   $0x3,%dl
  800ae4:	75 0a                	jne    800af0 <memmove+0x59>
			asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800ae6:	c1 e9 02             	shr    $0x2,%ecx
  800ae9:	89 c7                	mov    %eax,%edi
  800aeb:	fc                   	cld    
  800aec:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aee:	eb 05                	jmp    800af5 <memmove+0x5e>
			             : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800af0:	89 c7                	mov    %eax,%edi
  800af2:	fc                   	cld    
  800af3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             : "cc", "memory");
	}
	return dst;
}
  800af5:	5e                   	pop    %esi
  800af6:	5f                   	pop    %edi
  800af7:	5d                   	pop    %ebp
  800af8:	c3                   	ret    

00800af9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800af9:	55                   	push   %ebp
  800afa:	89 e5                	mov    %esp,%ebp
  800afc:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800aff:	ff 75 10             	push   0x10(%ebp)
  800b02:	ff 75 0c             	push   0xc(%ebp)
  800b05:	ff 75 08             	push   0x8(%ebp)
  800b08:	e8 8a ff ff ff       	call   800a97 <memmove>
}
  800b0d:	c9                   	leave  
  800b0e:	c3                   	ret    

00800b0f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b0f:	55                   	push   %ebp
  800b10:	89 e5                	mov    %esp,%ebp
  800b12:	56                   	push   %esi
  800b13:	53                   	push   %ebx
  800b14:	8b 45 08             	mov    0x8(%ebp),%eax
  800b17:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b1a:	89 c6                	mov    %eax,%esi
  800b1c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b1f:	eb 06                	jmp    800b27 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b21:	83 c0 01             	add    $0x1,%eax
  800b24:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800b27:	39 f0                	cmp    %esi,%eax
  800b29:	74 14                	je     800b3f <memcmp+0x30>
		if (*s1 != *s2)
  800b2b:	0f b6 08             	movzbl (%eax),%ecx
  800b2e:	0f b6 1a             	movzbl (%edx),%ebx
  800b31:	38 d9                	cmp    %bl,%cl
  800b33:	74 ec                	je     800b21 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800b35:	0f b6 c1             	movzbl %cl,%eax
  800b38:	0f b6 db             	movzbl %bl,%ebx
  800b3b:	29 d8                	sub    %ebx,%eax
  800b3d:	eb 05                	jmp    800b44 <memcmp+0x35>
	}

	return 0;
  800b3f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b44:	5b                   	pop    %ebx
  800b45:	5e                   	pop    %esi
  800b46:	5d                   	pop    %ebp
  800b47:	c3                   	ret    

00800b48 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b48:	55                   	push   %ebp
  800b49:	89 e5                	mov    %esp,%ebp
  800b4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b51:	89 c2                	mov    %eax,%edx
  800b53:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b56:	eb 03                	jmp    800b5b <memfind+0x13>
  800b58:	83 c0 01             	add    $0x1,%eax
  800b5b:	39 d0                	cmp    %edx,%eax
  800b5d:	73 04                	jae    800b63 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b5f:	38 08                	cmp    %cl,(%eax)
  800b61:	75 f5                	jne    800b58 <memfind+0x10>
			break;
	return (void *) s;
}
  800b63:	5d                   	pop    %ebp
  800b64:	c3                   	ret    

00800b65 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b65:	55                   	push   %ebp
  800b66:	89 e5                	mov    %esp,%ebp
  800b68:	57                   	push   %edi
  800b69:	56                   	push   %esi
  800b6a:	53                   	push   %ebx
  800b6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b71:	eb 03                	jmp    800b76 <strtol+0x11>
		s++;
  800b73:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b76:	0f b6 02             	movzbl (%edx),%eax
  800b79:	3c 20                	cmp    $0x20,%al
  800b7b:	74 f6                	je     800b73 <strtol+0xe>
  800b7d:	3c 09                	cmp    $0x9,%al
  800b7f:	74 f2                	je     800b73 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b81:	3c 2b                	cmp    $0x2b,%al
  800b83:	74 2a                	je     800baf <strtol+0x4a>
	int neg = 0;
  800b85:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b8a:	3c 2d                	cmp    $0x2d,%al
  800b8c:	74 2b                	je     800bb9 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b8e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b94:	75 0f                	jne    800ba5 <strtol+0x40>
  800b96:	80 3a 30             	cmpb   $0x30,(%edx)
  800b99:	74 28                	je     800bc3 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b9b:	85 db                	test   %ebx,%ebx
  800b9d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ba2:	0f 44 d8             	cmove  %eax,%ebx
  800ba5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800baa:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800bad:	eb 46                	jmp    800bf5 <strtol+0x90>
		s++;
  800baf:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800bb2:	bf 00 00 00 00       	mov    $0x0,%edi
  800bb7:	eb d5                	jmp    800b8e <strtol+0x29>
		s++, neg = 1;
  800bb9:	83 c2 01             	add    $0x1,%edx
  800bbc:	bf 01 00 00 00       	mov    $0x1,%edi
  800bc1:	eb cb                	jmp    800b8e <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bc3:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bc7:	74 0e                	je     800bd7 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800bc9:	85 db                	test   %ebx,%ebx
  800bcb:	75 d8                	jne    800ba5 <strtol+0x40>
		s++, base = 8;
  800bcd:	83 c2 01             	add    $0x1,%edx
  800bd0:	bb 08 00 00 00       	mov    $0x8,%ebx
  800bd5:	eb ce                	jmp    800ba5 <strtol+0x40>
		s += 2, base = 16;
  800bd7:	83 c2 02             	add    $0x2,%edx
  800bda:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bdf:	eb c4                	jmp    800ba5 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800be1:	0f be c0             	movsbl %al,%eax
  800be4:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800be7:	3b 45 10             	cmp    0x10(%ebp),%eax
  800bea:	7d 3a                	jge    800c26 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800bec:	83 c2 01             	add    $0x1,%edx
  800bef:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800bf3:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800bf5:	0f b6 02             	movzbl (%edx),%eax
  800bf8:	8d 70 d0             	lea    -0x30(%eax),%esi
  800bfb:	89 f3                	mov    %esi,%ebx
  800bfd:	80 fb 09             	cmp    $0x9,%bl
  800c00:	76 df                	jbe    800be1 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800c02:	8d 70 9f             	lea    -0x61(%eax),%esi
  800c05:	89 f3                	mov    %esi,%ebx
  800c07:	80 fb 19             	cmp    $0x19,%bl
  800c0a:	77 08                	ja     800c14 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800c0c:	0f be c0             	movsbl %al,%eax
  800c0f:	83 e8 57             	sub    $0x57,%eax
  800c12:	eb d3                	jmp    800be7 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800c14:	8d 70 bf             	lea    -0x41(%eax),%esi
  800c17:	89 f3                	mov    %esi,%ebx
  800c19:	80 fb 19             	cmp    $0x19,%bl
  800c1c:	77 08                	ja     800c26 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800c1e:	0f be c0             	movsbl %al,%eax
  800c21:	83 e8 37             	sub    $0x37,%eax
  800c24:	eb c1                	jmp    800be7 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c26:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c2a:	74 05                	je     800c31 <strtol+0xcc>
		*endptr = (char *) s;
  800c2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c2f:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800c31:	89 c8                	mov    %ecx,%eax
  800c33:	f7 d8                	neg    %eax
  800c35:	85 ff                	test   %edi,%edi
  800c37:	0f 45 c8             	cmovne %eax,%ecx
}
  800c3a:	89 c8                	mov    %ecx,%eax
  800c3c:	5b                   	pop    %ebx
  800c3d:	5e                   	pop    %esi
  800c3e:	5f                   	pop    %edi
  800c3f:	5d                   	pop    %ebp
  800c40:	c3                   	ret    
  800c41:	66 90                	xchg   %ax,%ax
  800c43:	66 90                	xchg   %ax,%ax
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
