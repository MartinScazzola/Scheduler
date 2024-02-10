
obj/user/faultevilhandler:     formato del fichero elf32-i386


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
  80002c:	e8 34 00 00 00       	call   800065 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
	sys_page_alloc(0, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  800039:	6a 07                	push   $0x7
  80003b:	68 00 f0 bf ee       	push   $0xeebff000
  800040:	6a 00                	push   $0x0
  800042:	e8 7d 01 00 00       	call   8001c4 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void *) 0xF0100020);
  800047:	83 c4 08             	add    $0x8,%esp
  80004a:	68 20 00 10 f0       	push   $0xf0100020
  80004f:	6a 00                	push   $0x0
  800051:	e8 fe 01 00 00       	call   800254 <sys_env_set_pgfault_upcall>
	*(int *) 0 = 0;
  800056:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80005d:	00 00 00 
}
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	c9                   	leave  
  800064:	c3                   	ret    

00800065 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800065:	55                   	push   %ebp
  800066:	89 e5                	mov    %esp,%ebp
  800068:	56                   	push   %esi
  800069:	53                   	push   %ebx
  80006a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80006d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	envid_t id = sys_getenvid();
  800070:	e8 04 01 00 00       	call   800179 <sys_getenvid>
	if (id >= 0)
  800075:	85 c0                	test   %eax,%eax
  800077:	78 15                	js     80008e <libmain+0x29>
		thisenv = &envs[ENVX(id)];
  800079:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007e:	69 c0 88 00 00 00    	imul   $0x88,%eax,%eax
  800084:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800089:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008e:	85 db                	test   %ebx,%ebx
  800090:	7e 07                	jle    800099 <libmain+0x34>
		binaryname = argv[0];
  800092:	8b 06                	mov    (%esi),%eax
  800094:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800099:	83 ec 08             	sub    $0x8,%esp
  80009c:	56                   	push   %esi
  80009d:	53                   	push   %ebx
  80009e:	e8 90 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000a3:	e8 0a 00 00 00       	call   8000b2 <exit>
}
  8000a8:	83 c4 10             	add    $0x10,%esp
  8000ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000ae:	5b                   	pop    %ebx
  8000af:	5e                   	pop    %esi
  8000b0:	5d                   	pop    %ebp
  8000b1:	c3                   	ret    

008000b2 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b2:	55                   	push   %ebp
  8000b3:	89 e5                	mov    %esp,%ebp
  8000b5:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000b8:	6a 00                	push   $0x0
  8000ba:	e8 98 00 00 00       	call   800157 <sys_env_destroy>
}
  8000bf:	83 c4 10             	add    $0x10,%esp
  8000c2:	c9                   	leave  
  8000c3:	c3                   	ret    

008000c4 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	57                   	push   %edi
  8000c8:	56                   	push   %esi
  8000c9:	53                   	push   %ebx
  8000ca:	83 ec 1c             	sub    $0x1c,%esp
  8000cd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8000d0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8000d3:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile(
  8000d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000db:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000de:	8b 75 14             	mov    0x14(%ebp),%esi
  8000e1:	cd 30                	int    $0x30
	        "int %1\n"
	        : "=a"(ret)
	        : "i"(T_SYSCALL), "a"(num), "d"(a1), "c"(a2), "b"(a3), "D"(a4), "S"(a5)
	        : "cc", "memory");

	if (check && ret > 0)
  8000e3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000e7:	74 04                	je     8000ed <syscall+0x29>
  8000e9:	85 c0                	test   %eax,%eax
  8000eb:	7f 08                	jg     8000f5 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  8000ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000f0:	5b                   	pop    %ebx
  8000f1:	5e                   	pop    %esi
  8000f2:	5f                   	pop    %edi
  8000f3:	5d                   	pop    %ebp
  8000f4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f5:	83 ec 0c             	sub    $0xc,%esp
  8000f8:	50                   	push   %eax
  8000f9:	ff 75 e0             	push   -0x20(%ebp)
  8000fc:	68 aa 0e 80 00       	push   $0x800eaa
  800101:	6a 1e                	push   $0x1e
  800103:	68 c7 0e 80 00       	push   $0x800ec7
  800108:	e8 f7 01 00 00       	call   800304 <_panic>

0080010d <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t) s, len, 0, 0, 0);
  800113:	6a 00                	push   $0x0
  800115:	6a 00                	push   $0x0
  800117:	6a 00                	push   $0x0
  800119:	ff 75 0c             	push   0xc(%ebp)
  80011c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80011f:	ba 00 00 00 00       	mov    $0x0,%edx
  800124:	b8 00 00 00 00       	mov    $0x0,%eax
  800129:	e8 96 ff ff ff       	call   8000c4 <syscall>
}
  80012e:	83 c4 10             	add    $0x10,%esp
  800131:	c9                   	leave  
  800132:	c3                   	ret    

00800133 <sys_cgetc>:

int
sys_cgetc(void)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800139:	6a 00                	push   $0x0
  80013b:	6a 00                	push   $0x0
  80013d:	6a 00                	push   $0x0
  80013f:	6a 00                	push   $0x0
  800141:	b9 00 00 00 00       	mov    $0x0,%ecx
  800146:	ba 00 00 00 00       	mov    $0x0,%edx
  80014b:	b8 01 00 00 00       	mov    $0x1,%eax
  800150:	e8 6f ff ff ff       	call   8000c4 <syscall>
}
  800155:	c9                   	leave  
  800156:	c3                   	ret    

00800157 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800157:	55                   	push   %ebp
  800158:	89 e5                	mov    %esp,%ebp
  80015a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80015d:	6a 00                	push   $0x0
  80015f:	6a 00                	push   $0x0
  800161:	6a 00                	push   $0x0
  800163:	6a 00                	push   $0x0
  800165:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800168:	ba 01 00 00 00       	mov    $0x1,%edx
  80016d:	b8 03 00 00 00       	mov    $0x3,%eax
  800172:	e8 4d ff ff ff       	call   8000c4 <syscall>
}
  800177:	c9                   	leave  
  800178:	c3                   	ret    

00800179 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  80017f:	6a 00                	push   $0x0
  800181:	6a 00                	push   $0x0
  800183:	6a 00                	push   $0x0
  800185:	6a 00                	push   $0x0
  800187:	b9 00 00 00 00       	mov    $0x0,%ecx
  80018c:	ba 00 00 00 00       	mov    $0x0,%edx
  800191:	b8 02 00 00 00       	mov    $0x2,%eax
  800196:	e8 29 ff ff ff       	call   8000c4 <syscall>
}
  80019b:	c9                   	leave  
  80019c:	c3                   	ret    

0080019d <sys_yield>:

void
sys_yield(void)
{
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  8001a3:	6a 00                	push   $0x0
  8001a5:	6a 00                	push   $0x0
  8001a7:	6a 00                	push   $0x0
  8001a9:	6a 00                	push   $0x0
  8001ab:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8001b5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8001ba:	e8 05 ff ff ff       	call   8000c4 <syscall>
}
  8001bf:	83 c4 10             	add    $0x10,%esp
  8001c2:	c9                   	leave  
  8001c3:	c3                   	ret    

008001c4 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8001ca:	6a 00                	push   $0x0
  8001cc:	6a 00                	push   $0x0
  8001ce:	ff 75 10             	push   0x10(%ebp)
  8001d1:	ff 75 0c             	push   0xc(%ebp)
  8001d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001d7:	ba 01 00 00 00       	mov    $0x1,%edx
  8001dc:	b8 04 00 00 00       	mov    $0x4,%eax
  8001e1:	e8 de fe ff ff       	call   8000c4 <syscall>
}
  8001e6:	c9                   	leave  
  8001e7:	c3                   	ret    

008001e8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map,
  8001ee:	ff 75 18             	push   0x18(%ebp)
  8001f1:	ff 75 14             	push   0x14(%ebp)
  8001f4:	ff 75 10             	push   0x10(%ebp)
  8001f7:	ff 75 0c             	push   0xc(%ebp)
  8001fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001fd:	ba 01 00 00 00       	mov    $0x1,%edx
  800202:	b8 05 00 00 00       	mov    $0x5,%eax
  800207:	e8 b8 fe ff ff       	call   8000c4 <syscall>
	               srcenv,
	               (uint32_t) srcva,
	               dstenv,
	               (uint32_t) dstva,
	               perm);
}
  80020c:	c9                   	leave  
  80020d:	c3                   	ret    

0080020e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80020e:	55                   	push   %ebp
  80020f:	89 e5                	mov    %esp,%ebp
  800211:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800214:	6a 00                	push   $0x0
  800216:	6a 00                	push   $0x0
  800218:	6a 00                	push   $0x0
  80021a:	ff 75 0c             	push   0xc(%ebp)
  80021d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800220:	ba 01 00 00 00       	mov    $0x1,%edx
  800225:	b8 06 00 00 00       	mov    $0x6,%eax
  80022a:	e8 95 fe ff ff       	call   8000c4 <syscall>
}
  80022f:	c9                   	leave  
  800230:	c3                   	ret    

00800231 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800231:	55                   	push   %ebp
  800232:	89 e5                	mov    %esp,%ebp
  800234:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800237:	6a 00                	push   $0x0
  800239:	6a 00                	push   $0x0
  80023b:	6a 00                	push   $0x0
  80023d:	ff 75 0c             	push   0xc(%ebp)
  800240:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800243:	ba 01 00 00 00       	mov    $0x1,%edx
  800248:	b8 08 00 00 00       	mov    $0x8,%eax
  80024d:	e8 72 fe ff ff       	call   8000c4 <syscall>
}
  800252:	c9                   	leave  
  800253:	c3                   	ret    

00800254 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800254:	55                   	push   %ebp
  800255:	89 e5                	mov    %esp,%ebp
  800257:	83 ec 08             	sub    $0x8,%esp
	return syscall(
  80025a:	6a 00                	push   $0x0
  80025c:	6a 00                	push   $0x0
  80025e:	6a 00                	push   $0x0
  800260:	ff 75 0c             	push   0xc(%ebp)
  800263:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800266:	ba 01 00 00 00       	mov    $0x1,%edx
  80026b:	b8 09 00 00 00       	mov    $0x9,%eax
  800270:	e8 4f fe ff ff       	call   8000c4 <syscall>
	        SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800275:	c9                   	leave  
  800276:	c3                   	ret    

00800277 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800277:	55                   	push   %ebp
  800278:	89 e5                	mov    %esp,%ebp
  80027a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  80027d:	6a 00                	push   $0x0
  80027f:	ff 75 14             	push   0x14(%ebp)
  800282:	ff 75 10             	push   0x10(%ebp)
  800285:	ff 75 0c             	push   0xc(%ebp)
  800288:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80028b:	ba 00 00 00 00       	mov    $0x0,%edx
  800290:	b8 0b 00 00 00       	mov    $0xb,%eax
  800295:	e8 2a fe ff ff       	call   8000c4 <syscall>
}
  80029a:	c9                   	leave  
  80029b:	c3                   	ret    

0080029c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80029c:	55                   	push   %ebp
  80029d:	89 e5                	mov    %esp,%ebp
  80029f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t) dstva, 0, 0, 0, 0);
  8002a2:	6a 00                	push   $0x0
  8002a4:	6a 00                	push   $0x0
  8002a6:	6a 00                	push   $0x0
  8002a8:	6a 00                	push   $0x0
  8002aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002ad:	ba 01 00 00 00       	mov    $0x1,%edx
  8002b2:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002b7:	e8 08 fe ff ff       	call   8000c4 <syscall>
}
  8002bc:	c9                   	leave  
  8002bd:	c3                   	ret    

008002be <sys_get_priority>:

// Get priority of the current process
int
sys_get_priority(void)
{
  8002be:	55                   	push   %ebp
  8002bf:	89 e5                	mov    %esp,%ebp
  8002c1:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_get_priority, 0, 0, 0, 0, 0, 0);
  8002c4:	6a 00                	push   $0x0
  8002c6:	6a 00                	push   $0x0
  8002c8:	6a 00                	push   $0x0
  8002ca:	6a 00                	push   $0x0
  8002cc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d6:	b8 0d 00 00 00       	mov    $0xd,%eax
  8002db:	e8 e4 fd ff ff       	call   8000c4 <syscall>
}
  8002e0:	c9                   	leave  
  8002e1:	c3                   	ret    

008002e2 <sys_set_priority>:

// Get priority of the current process
int
sys_set_priority(unsigned int priority)
{
  8002e2:	55                   	push   %ebp
  8002e3:	89 e5                	mov    %esp,%ebp
  8002e5:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, (uint32_t) priority, 0, 0, 0, 0);
  8002e8:	6a 00                	push   $0x0
  8002ea:	6a 00                	push   $0x0
  8002ec:	6a 00                	push   $0x0
  8002ee:	6a 00                	push   $0x0
  8002f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8002f8:	b8 0e 00 00 00       	mov    $0xe,%eax
  8002fd:	e8 c2 fd ff ff       	call   8000c4 <syscall>
}
  800302:	c9                   	leave  
  800303:	c3                   	ret    

00800304 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800304:	55                   	push   %ebp
  800305:	89 e5                	mov    %esp,%ebp
  800307:	56                   	push   %esi
  800308:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800309:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80030c:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800312:	e8 62 fe ff ff       	call   800179 <sys_getenvid>
  800317:	83 ec 0c             	sub    $0xc,%esp
  80031a:	ff 75 0c             	push   0xc(%ebp)
  80031d:	ff 75 08             	push   0x8(%ebp)
  800320:	56                   	push   %esi
  800321:	50                   	push   %eax
  800322:	68 d8 0e 80 00       	push   $0x800ed8
  800327:	e8 b3 00 00 00       	call   8003df <cprintf>
	        sys_getenvid(),
	        binaryname,
	        file,
	        line);
	vcprintf(fmt, ap);
  80032c:	83 c4 18             	add    $0x18,%esp
  80032f:	53                   	push   %ebx
  800330:	ff 75 10             	push   0x10(%ebp)
  800333:	e8 56 00 00 00       	call   80038e <vcprintf>
	cprintf("\n");
  800338:	c7 04 24 fb 0e 80 00 	movl   $0x800efb,(%esp)
  80033f:	e8 9b 00 00 00       	call   8003df <cprintf>
  800344:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800347:	cc                   	int3   
  800348:	eb fd                	jmp    800347 <_panic+0x43>

0080034a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80034a:	55                   	push   %ebp
  80034b:	89 e5                	mov    %esp,%ebp
  80034d:	53                   	push   %ebx
  80034e:	83 ec 04             	sub    $0x4,%esp
  800351:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800354:	8b 13                	mov    (%ebx),%edx
  800356:	8d 42 01             	lea    0x1(%edx),%eax
  800359:	89 03                	mov    %eax,(%ebx)
  80035b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80035e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256 - 1) {
  800362:	3d ff 00 00 00       	cmp    $0xff,%eax
  800367:	74 09                	je     800372 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800369:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80036d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800370:	c9                   	leave  
  800371:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800372:	83 ec 08             	sub    $0x8,%esp
  800375:	68 ff 00 00 00       	push   $0xff
  80037a:	8d 43 08             	lea    0x8(%ebx),%eax
  80037d:	50                   	push   %eax
  80037e:	e8 8a fd ff ff       	call   80010d <sys_cputs>
		b->idx = 0;
  800383:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800389:	83 c4 10             	add    $0x10,%esp
  80038c:	eb db                	jmp    800369 <putch+0x1f>

0080038e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80038e:	55                   	push   %ebp
  80038f:	89 e5                	mov    %esp,%ebp
  800391:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800397:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80039e:	00 00 00 
	b.cnt = 0;
  8003a1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003a8:	00 00 00 
	vprintfmt((void *) putch, &b, fmt, ap);
  8003ab:	ff 75 0c             	push   0xc(%ebp)
  8003ae:	ff 75 08             	push   0x8(%ebp)
  8003b1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003b7:	50                   	push   %eax
  8003b8:	68 4a 03 80 00       	push   $0x80034a
  8003bd:	e8 74 01 00 00       	call   800536 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003c2:	83 c4 08             	add    $0x8,%esp
  8003c5:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8003cb:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003d1:	50                   	push   %eax
  8003d2:	e8 36 fd ff ff       	call   80010d <sys_cputs>

	return b.cnt;
}
  8003d7:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003dd:	c9                   	leave  
  8003de:	c3                   	ret    

008003df <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003df:	55                   	push   %ebp
  8003e0:	89 e5                	mov    %esp,%ebp
  8003e2:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003e5:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003e8:	50                   	push   %eax
  8003e9:	ff 75 08             	push   0x8(%ebp)
  8003ec:	e8 9d ff ff ff       	call   80038e <vcprintf>
	va_end(ap);

	return cnt;
}
  8003f1:	c9                   	leave  
  8003f2:	c3                   	ret    

008003f3 <printnum>:
         void *putdat,
         unsigned long long num,
         unsigned base,
         int width,
         int padc)
{
  8003f3:	55                   	push   %ebp
  8003f4:	89 e5                	mov    %esp,%ebp
  8003f6:	57                   	push   %edi
  8003f7:	56                   	push   %esi
  8003f8:	53                   	push   %ebx
  8003f9:	83 ec 1c             	sub    $0x1c,%esp
  8003fc:	89 c7                	mov    %eax,%edi
  8003fe:	89 d6                	mov    %edx,%esi
  800400:	8b 45 08             	mov    0x8(%ebp),%eax
  800403:	8b 55 0c             	mov    0xc(%ebp),%edx
  800406:	89 d1                	mov    %edx,%ecx
  800408:	89 c2                	mov    %eax,%edx
  80040a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80040d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800410:	8b 45 10             	mov    0x10(%ebp),%eax
  800413:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800416:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800419:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800420:	39 c2                	cmp    %eax,%edx
  800422:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800425:	72 3e                	jb     800465 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800427:	83 ec 0c             	sub    $0xc,%esp
  80042a:	ff 75 18             	push   0x18(%ebp)
  80042d:	83 eb 01             	sub    $0x1,%ebx
  800430:	53                   	push   %ebx
  800431:	50                   	push   %eax
  800432:	83 ec 08             	sub    $0x8,%esp
  800435:	ff 75 e4             	push   -0x1c(%ebp)
  800438:	ff 75 e0             	push   -0x20(%ebp)
  80043b:	ff 75 dc             	push   -0x24(%ebp)
  80043e:	ff 75 d8             	push   -0x28(%ebp)
  800441:	e8 1a 08 00 00       	call   800c60 <__udivdi3>
  800446:	83 c4 18             	add    $0x18,%esp
  800449:	52                   	push   %edx
  80044a:	50                   	push   %eax
  80044b:	89 f2                	mov    %esi,%edx
  80044d:	89 f8                	mov    %edi,%eax
  80044f:	e8 9f ff ff ff       	call   8003f3 <printnum>
  800454:	83 c4 20             	add    $0x20,%esp
  800457:	eb 13                	jmp    80046c <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800459:	83 ec 08             	sub    $0x8,%esp
  80045c:	56                   	push   %esi
  80045d:	ff 75 18             	push   0x18(%ebp)
  800460:	ff d7                	call   *%edi
  800462:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800465:	83 eb 01             	sub    $0x1,%ebx
  800468:	85 db                	test   %ebx,%ebx
  80046a:	7f ed                	jg     800459 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80046c:	83 ec 08             	sub    $0x8,%esp
  80046f:	56                   	push   %esi
  800470:	83 ec 04             	sub    $0x4,%esp
  800473:	ff 75 e4             	push   -0x1c(%ebp)
  800476:	ff 75 e0             	push   -0x20(%ebp)
  800479:	ff 75 dc             	push   -0x24(%ebp)
  80047c:	ff 75 d8             	push   -0x28(%ebp)
  80047f:	e8 fc 08 00 00       	call   800d80 <__umoddi3>
  800484:	83 c4 14             	add    $0x14,%esp
  800487:	0f be 80 fd 0e 80 00 	movsbl 0x800efd(%eax),%eax
  80048e:	50                   	push   %eax
  80048f:	ff d7                	call   *%edi
}
  800491:	83 c4 10             	add    $0x10,%esp
  800494:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800497:	5b                   	pop    %ebx
  800498:	5e                   	pop    %esi
  800499:	5f                   	pop    %edi
  80049a:	5d                   	pop    %ebp
  80049b:	c3                   	ret    

0080049c <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80049c:	83 fa 01             	cmp    $0x1,%edx
  80049f:	7f 13                	jg     8004b4 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8004a1:	85 d2                	test   %edx,%edx
  8004a3:	74 1c                	je     8004c1 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  8004a5:	8b 10                	mov    (%eax),%edx
  8004a7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004aa:	89 08                	mov    %ecx,(%eax)
  8004ac:	8b 02                	mov    (%edx),%eax
  8004ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8004b3:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  8004b4:	8b 10                	mov    (%eax),%edx
  8004b6:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004b9:	89 08                	mov    %ecx,(%eax)
  8004bb:	8b 02                	mov    (%edx),%eax
  8004bd:	8b 52 04             	mov    0x4(%edx),%edx
  8004c0:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  8004c1:	8b 10                	mov    (%eax),%edx
  8004c3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004c6:	89 08                	mov    %ecx,(%eax)
  8004c8:	8b 02                	mov    (%edx),%eax
  8004ca:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004cf:	c3                   	ret    

008004d0 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004d0:	83 fa 01             	cmp    $0x1,%edx
  8004d3:	7f 0f                	jg     8004e4 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  8004d5:	85 d2                	test   %edx,%edx
  8004d7:	74 18                	je     8004f1 <getint+0x21>
		return va_arg(*ap, long);
  8004d9:	8b 10                	mov    (%eax),%edx
  8004db:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004de:	89 08                	mov    %ecx,(%eax)
  8004e0:	8b 02                	mov    (%edx),%eax
  8004e2:	99                   	cltd   
  8004e3:	c3                   	ret    
		return va_arg(*ap, long long);
  8004e4:	8b 10                	mov    (%eax),%edx
  8004e6:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004e9:	89 08                	mov    %ecx,(%eax)
  8004eb:	8b 02                	mov    (%edx),%eax
  8004ed:	8b 52 04             	mov    0x4(%edx),%edx
  8004f0:	c3                   	ret    
	else
		return va_arg(*ap, int);
  8004f1:	8b 10                	mov    (%eax),%edx
  8004f3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004f6:	89 08                	mov    %ecx,(%eax)
  8004f8:	8b 02                	mov    (%edx),%eax
  8004fa:	99                   	cltd   
}
  8004fb:	c3                   	ret    

008004fc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004fc:	55                   	push   %ebp
  8004fd:	89 e5                	mov    %esp,%ebp
  8004ff:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800502:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800506:	8b 10                	mov    (%eax),%edx
  800508:	3b 50 04             	cmp    0x4(%eax),%edx
  80050b:	73 0a                	jae    800517 <sprintputch+0x1b>
		*b->buf++ = ch;
  80050d:	8d 4a 01             	lea    0x1(%edx),%ecx
  800510:	89 08                	mov    %ecx,(%eax)
  800512:	8b 45 08             	mov    0x8(%ebp),%eax
  800515:	88 02                	mov    %al,(%edx)
}
  800517:	5d                   	pop    %ebp
  800518:	c3                   	ret    

00800519 <printfmt>:
{
  800519:	55                   	push   %ebp
  80051a:	89 e5                	mov    %esp,%ebp
  80051c:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80051f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800522:	50                   	push   %eax
  800523:	ff 75 10             	push   0x10(%ebp)
  800526:	ff 75 0c             	push   0xc(%ebp)
  800529:	ff 75 08             	push   0x8(%ebp)
  80052c:	e8 05 00 00 00       	call   800536 <vprintfmt>
}
  800531:	83 c4 10             	add    $0x10,%esp
  800534:	c9                   	leave  
  800535:	c3                   	ret    

00800536 <vprintfmt>:
{
  800536:	55                   	push   %ebp
  800537:	89 e5                	mov    %esp,%ebp
  800539:	57                   	push   %edi
  80053a:	56                   	push   %esi
  80053b:	53                   	push   %ebx
  80053c:	83 ec 2c             	sub    $0x2c,%esp
  80053f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800542:	8b 75 0c             	mov    0xc(%ebp),%esi
  800545:	8b 7d 10             	mov    0x10(%ebp),%edi
  800548:	eb 0a                	jmp    800554 <vprintfmt+0x1e>
			putch(ch, putdat);
  80054a:	83 ec 08             	sub    $0x8,%esp
  80054d:	56                   	push   %esi
  80054e:	50                   	push   %eax
  80054f:	ff d3                	call   *%ebx
  800551:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800554:	83 c7 01             	add    $0x1,%edi
  800557:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80055b:	83 f8 25             	cmp    $0x25,%eax
  80055e:	74 0c                	je     80056c <vprintfmt+0x36>
			if (ch == '\0')
  800560:	85 c0                	test   %eax,%eax
  800562:	75 e6                	jne    80054a <vprintfmt+0x14>
}
  800564:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800567:	5b                   	pop    %ebx
  800568:	5e                   	pop    %esi
  800569:	5f                   	pop    %edi
  80056a:	5d                   	pop    %ebp
  80056b:	c3                   	ret    
		padc = ' ';
  80056c:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
		altflag = 0;
  800570:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800577:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80057e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800585:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80058a:	8d 47 01             	lea    0x1(%edi),%eax
  80058d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800590:	0f b6 17             	movzbl (%edi),%edx
  800593:	8d 42 dd             	lea    -0x23(%edx),%eax
  800596:	3c 55                	cmp    $0x55,%al
  800598:	0f 87 b7 02 00 00    	ja     800855 <vprintfmt+0x31f>
  80059e:	0f b6 c0             	movzbl %al,%eax
  8005a1:	ff 24 85 c0 0f 80 00 	jmp    *0x800fc0(,%eax,4)
  8005a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8005ab:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  8005af:	eb d9                	jmp    80058a <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8005b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b4:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  8005b8:	eb d0                	jmp    80058a <vprintfmt+0x54>
  8005ba:	0f b6 d2             	movzbl %dl,%edx
  8005bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0;; ++fmt) {
  8005c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8005c5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8005c8:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005cb:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8005cf:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8005d2:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8005d5:	83 f9 09             	cmp    $0x9,%ecx
  8005d8:	77 52                	ja     80062c <vprintfmt+0xf6>
			for (precision = 0;; ++fmt) {
  8005da:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8005dd:	eb e9                	jmp    8005c8 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  8005df:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e2:	8d 50 04             	lea    0x4(%eax),%edx
  8005e5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e8:	8b 00                	mov    (%eax),%eax
  8005ea:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8005f0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005f4:	79 94                	jns    80058a <vprintfmt+0x54>
				width = precision, precision = -1;
  8005f6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005f9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005fc:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800603:	eb 85                	jmp    80058a <vprintfmt+0x54>
  800605:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800608:	85 d2                	test   %edx,%edx
  80060a:	b8 00 00 00 00       	mov    $0x0,%eax
  80060f:	0f 49 c2             	cmovns %edx,%eax
  800612:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800615:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800618:	e9 6d ff ff ff       	jmp    80058a <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80061d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800620:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800627:	e9 5e ff ff ff       	jmp    80058a <vprintfmt+0x54>
  80062c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80062f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800632:	eb bc                	jmp    8005f0 <vprintfmt+0xba>
			lflag++;
  800634:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800637:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80063a:	e9 4b ff ff ff       	jmp    80058a <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  80063f:	8b 45 14             	mov    0x14(%ebp),%eax
  800642:	8d 50 04             	lea    0x4(%eax),%edx
  800645:	89 55 14             	mov    %edx,0x14(%ebp)
  800648:	83 ec 08             	sub    $0x8,%esp
  80064b:	56                   	push   %esi
  80064c:	ff 30                	push   (%eax)
  80064e:	ff d3                	call   *%ebx
			break;
  800650:	83 c4 10             	add    $0x10,%esp
  800653:	e9 94 01 00 00       	jmp    8007ec <vprintfmt+0x2b6>
			err = va_arg(ap, int);
  800658:	8b 45 14             	mov    0x14(%ebp),%eax
  80065b:	8d 50 04             	lea    0x4(%eax),%edx
  80065e:	89 55 14             	mov    %edx,0x14(%ebp)
  800661:	8b 10                	mov    (%eax),%edx
  800663:	89 d0                	mov    %edx,%eax
  800665:	f7 d8                	neg    %eax
  800667:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80066a:	83 f8 08             	cmp    $0x8,%eax
  80066d:	7f 20                	jg     80068f <vprintfmt+0x159>
  80066f:	8b 14 85 20 11 80 00 	mov    0x801120(,%eax,4),%edx
  800676:	85 d2                	test   %edx,%edx
  800678:	74 15                	je     80068f <vprintfmt+0x159>
				printfmt(putch, putdat, "%s", p);
  80067a:	52                   	push   %edx
  80067b:	68 1e 0f 80 00       	push   $0x800f1e
  800680:	56                   	push   %esi
  800681:	53                   	push   %ebx
  800682:	e8 92 fe ff ff       	call   800519 <printfmt>
  800687:	83 c4 10             	add    $0x10,%esp
  80068a:	e9 5d 01 00 00       	jmp    8007ec <vprintfmt+0x2b6>
				printfmt(putch, putdat, "error %d", err);
  80068f:	50                   	push   %eax
  800690:	68 15 0f 80 00       	push   $0x800f15
  800695:	56                   	push   %esi
  800696:	53                   	push   %ebx
  800697:	e8 7d fe ff ff       	call   800519 <printfmt>
  80069c:	83 c4 10             	add    $0x10,%esp
  80069f:	e9 48 01 00 00       	jmp    8007ec <vprintfmt+0x2b6>
			if ((p = va_arg(ap, char *)) == NULL)
  8006a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a7:	8d 50 04             	lea    0x4(%eax),%edx
  8006aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ad:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006af:	85 ff                	test   %edi,%edi
  8006b1:	b8 0e 0f 80 00       	mov    $0x800f0e,%eax
  8006b6:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006b9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006bd:	7e 06                	jle    8006c5 <vprintfmt+0x18f>
  8006bf:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8006c3:	75 0a                	jne    8006cf <vprintfmt+0x199>
  8006c5:	89 f8                	mov    %edi,%eax
  8006c7:	03 45 e0             	add    -0x20(%ebp),%eax
  8006ca:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006cd:	eb 59                	jmp    800728 <vprintfmt+0x1f2>
				for (width -= strnlen(p, precision); width > 0;
  8006cf:	83 ec 08             	sub    $0x8,%esp
  8006d2:	ff 75 d8             	push   -0x28(%ebp)
  8006d5:	57                   	push   %edi
  8006d6:	e8 1a 02 00 00       	call   8008f5 <strnlen>
  8006db:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006de:	29 c1                	sub    %eax,%ecx
  8006e0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006e3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006e6:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  8006ea:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006ed:	89 7d d0             	mov    %edi,-0x30(%ebp)
  8006f0:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0;
  8006f2:	eb 0f                	jmp    800703 <vprintfmt+0x1cd>
					putch(padc, putdat);
  8006f4:	83 ec 08             	sub    $0x8,%esp
  8006f7:	56                   	push   %esi
  8006f8:	ff 75 e0             	push   -0x20(%ebp)
  8006fb:	ff d3                	call   *%ebx
				     width--)
  8006fd:	83 ef 01             	sub    $0x1,%edi
  800700:	83 c4 10             	add    $0x10,%esp
				for (width -= strnlen(p, precision); width > 0;
  800703:	85 ff                	test   %edi,%edi
  800705:	7f ed                	jg     8006f4 <vprintfmt+0x1be>
  800707:	8b 7d d0             	mov    -0x30(%ebp),%edi
  80070a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80070d:	85 c9                	test   %ecx,%ecx
  80070f:	b8 00 00 00 00       	mov    $0x0,%eax
  800714:	0f 49 c1             	cmovns %ecx,%eax
  800717:	29 c1                	sub    %eax,%ecx
  800719:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80071c:	eb a7                	jmp    8006c5 <vprintfmt+0x18f>
					putch(ch, putdat);
  80071e:	83 ec 08             	sub    $0x8,%esp
  800721:	56                   	push   %esi
  800722:	52                   	push   %edx
  800723:	ff d3                	call   *%ebx
  800725:	83 c4 10             	add    $0x10,%esp
  800728:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80072b:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' &&
  80072d:	83 c7 01             	add    $0x1,%edi
  800730:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800734:	0f be d0             	movsbl %al,%edx
  800737:	85 d2                	test   %edx,%edx
  800739:	74 42                	je     80077d <vprintfmt+0x247>
  80073b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80073f:	78 06                	js     800747 <vprintfmt+0x211>
			       (precision < 0 || --precision >= 0);
  800741:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800745:	78 1e                	js     800765 <vprintfmt+0x22f>
				if (altflag && (ch < ' ' || ch > '~'))
  800747:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80074b:	74 d1                	je     80071e <vprintfmt+0x1e8>
  80074d:	0f be c0             	movsbl %al,%eax
  800750:	83 e8 20             	sub    $0x20,%eax
  800753:	83 f8 5e             	cmp    $0x5e,%eax
  800756:	76 c6                	jbe    80071e <vprintfmt+0x1e8>
					putch('?', putdat);
  800758:	83 ec 08             	sub    $0x8,%esp
  80075b:	56                   	push   %esi
  80075c:	6a 3f                	push   $0x3f
  80075e:	ff d3                	call   *%ebx
  800760:	83 c4 10             	add    $0x10,%esp
  800763:	eb c3                	jmp    800728 <vprintfmt+0x1f2>
  800765:	89 cf                	mov    %ecx,%edi
  800767:	eb 0e                	jmp    800777 <vprintfmt+0x241>
				putch(' ', putdat);
  800769:	83 ec 08             	sub    $0x8,%esp
  80076c:	56                   	push   %esi
  80076d:	6a 20                	push   $0x20
  80076f:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  800771:	83 ef 01             	sub    $0x1,%edi
  800774:	83 c4 10             	add    $0x10,%esp
  800777:	85 ff                	test   %edi,%edi
  800779:	7f ee                	jg     800769 <vprintfmt+0x233>
  80077b:	eb 6f                	jmp    8007ec <vprintfmt+0x2b6>
  80077d:	89 cf                	mov    %ecx,%edi
  80077f:	eb f6                	jmp    800777 <vprintfmt+0x241>
			num = getint(&ap, lflag);
  800781:	89 ca                	mov    %ecx,%edx
  800783:	8d 45 14             	lea    0x14(%ebp),%eax
  800786:	e8 45 fd ff ff       	call   8004d0 <getint>
  80078b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80078e:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800791:	85 d2                	test   %edx,%edx
  800793:	78 0b                	js     8007a0 <vprintfmt+0x26a>
			num = getint(&ap, lflag);
  800795:	89 d1                	mov    %edx,%ecx
  800797:	89 c2                	mov    %eax,%edx
			base = 10;
  800799:	bf 0a 00 00 00       	mov    $0xa,%edi
  80079e:	eb 32                	jmp    8007d2 <vprintfmt+0x29c>
				putch('-', putdat);
  8007a0:	83 ec 08             	sub    $0x8,%esp
  8007a3:	56                   	push   %esi
  8007a4:	6a 2d                	push   $0x2d
  8007a6:	ff d3                	call   *%ebx
				num = -(long long) num;
  8007a8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007ab:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007ae:	f7 da                	neg    %edx
  8007b0:	83 d1 00             	adc    $0x0,%ecx
  8007b3:	f7 d9                	neg    %ecx
  8007b5:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8007b8:	bf 0a 00 00 00       	mov    $0xa,%edi
  8007bd:	eb 13                	jmp    8007d2 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  8007bf:	89 ca                	mov    %ecx,%edx
  8007c1:	8d 45 14             	lea    0x14(%ebp),%eax
  8007c4:	e8 d3 fc ff ff       	call   80049c <getuint>
  8007c9:	89 d1                	mov    %edx,%ecx
  8007cb:	89 c2                	mov    %eax,%edx
			base = 10;
  8007cd:	bf 0a 00 00 00       	mov    $0xa,%edi
			printnum(putch, putdat, num, base, width, padc);
  8007d2:	83 ec 0c             	sub    $0xc,%esp
  8007d5:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  8007d9:	50                   	push   %eax
  8007da:	ff 75 e0             	push   -0x20(%ebp)
  8007dd:	57                   	push   %edi
  8007de:	51                   	push   %ecx
  8007df:	52                   	push   %edx
  8007e0:	89 f2                	mov    %esi,%edx
  8007e2:	89 d8                	mov    %ebx,%eax
  8007e4:	e8 0a fc ff ff       	call   8003f3 <printnum>
			break;
  8007e9:	83 c4 20             	add    $0x20,%esp
{
  8007ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007ef:	e9 60 fd ff ff       	jmp    800554 <vprintfmt+0x1e>
			num = getuint(&ap, lflag);
  8007f4:	89 ca                	mov    %ecx,%edx
  8007f6:	8d 45 14             	lea    0x14(%ebp),%eax
  8007f9:	e8 9e fc ff ff       	call   80049c <getuint>
  8007fe:	89 d1                	mov    %edx,%ecx
  800800:	89 c2                	mov    %eax,%edx
			base = 8;
  800802:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  800807:	eb c9                	jmp    8007d2 <vprintfmt+0x29c>
			putch('0', putdat);
  800809:	83 ec 08             	sub    $0x8,%esp
  80080c:	56                   	push   %esi
  80080d:	6a 30                	push   $0x30
  80080f:	ff d3                	call   *%ebx
			putch('x', putdat);
  800811:	83 c4 08             	add    $0x8,%esp
  800814:	56                   	push   %esi
  800815:	6a 78                	push   $0x78
  800817:	ff d3                	call   *%ebx
			num = (unsigned long long) (uintptr_t) va_arg(ap, void *);
  800819:	8b 45 14             	mov    0x14(%ebp),%eax
  80081c:	8d 50 04             	lea    0x4(%eax),%edx
  80081f:	89 55 14             	mov    %edx,0x14(%ebp)
  800822:	8b 10                	mov    (%eax),%edx
  800824:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800829:	83 c4 10             	add    $0x10,%esp
			base = 16;
  80082c:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  800831:	eb 9f                	jmp    8007d2 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  800833:	89 ca                	mov    %ecx,%edx
  800835:	8d 45 14             	lea    0x14(%ebp),%eax
  800838:	e8 5f fc ff ff       	call   80049c <getuint>
  80083d:	89 d1                	mov    %edx,%ecx
  80083f:	89 c2                	mov    %eax,%edx
			base = 16;
  800841:	bf 10 00 00 00       	mov    $0x10,%edi
  800846:	eb 8a                	jmp    8007d2 <vprintfmt+0x29c>
			putch(ch, putdat);
  800848:	83 ec 08             	sub    $0x8,%esp
  80084b:	56                   	push   %esi
  80084c:	6a 25                	push   $0x25
  80084e:	ff d3                	call   *%ebx
			break;
  800850:	83 c4 10             	add    $0x10,%esp
  800853:	eb 97                	jmp    8007ec <vprintfmt+0x2b6>
			putch('%', putdat);
  800855:	83 ec 08             	sub    $0x8,%esp
  800858:	56                   	push   %esi
  800859:	6a 25                	push   $0x25
  80085b:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  80085d:	83 c4 10             	add    $0x10,%esp
  800860:	89 f8                	mov    %edi,%eax
  800862:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800866:	74 05                	je     80086d <vprintfmt+0x337>
  800868:	83 e8 01             	sub    $0x1,%eax
  80086b:	eb f5                	jmp    800862 <vprintfmt+0x32c>
  80086d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800870:	e9 77 ff ff ff       	jmp    8007ec <vprintfmt+0x2b6>

00800875 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800875:	55                   	push   %ebp
  800876:	89 e5                	mov    %esp,%ebp
  800878:	83 ec 18             	sub    $0x18,%esp
  80087b:	8b 45 08             	mov    0x8(%ebp),%eax
  80087e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = { buf, buf + n - 1, 0 };
  800881:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800884:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800888:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80088b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800892:	85 c0                	test   %eax,%eax
  800894:	74 26                	je     8008bc <vsnprintf+0x47>
  800896:	85 d2                	test   %edx,%edx
  800898:	7e 22                	jle    8008bc <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *) sprintputch, &b, fmt, ap);
  80089a:	ff 75 14             	push   0x14(%ebp)
  80089d:	ff 75 10             	push   0x10(%ebp)
  8008a0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008a3:	50                   	push   %eax
  8008a4:	68 fc 04 80 00       	push   $0x8004fc
  8008a9:	e8 88 fc ff ff       	call   800536 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008b1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008b7:	83 c4 10             	add    $0x10,%esp
}
  8008ba:	c9                   	leave  
  8008bb:	c3                   	ret    
		return -E_INVAL;
  8008bc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008c1:	eb f7                	jmp    8008ba <vsnprintf+0x45>

008008c3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008c3:	55                   	push   %ebp
  8008c4:	89 e5                	mov    %esp,%ebp
  8008c6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008c9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008cc:	50                   	push   %eax
  8008cd:	ff 75 10             	push   0x10(%ebp)
  8008d0:	ff 75 0c             	push   0xc(%ebp)
  8008d3:	ff 75 08             	push   0x8(%ebp)
  8008d6:	e8 9a ff ff ff       	call   800875 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008db:	c9                   	leave  
  8008dc:	c3                   	ret    

008008dd <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008dd:	55                   	push   %ebp
  8008de:	89 e5                	mov    %esp,%ebp
  8008e0:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e8:	eb 03                	jmp    8008ed <strlen+0x10>
		n++;
  8008ea:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008ed:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008f1:	75 f7                	jne    8008ea <strlen+0xd>
	return n;
}
  8008f3:	5d                   	pop    %ebp
  8008f4:	c3                   	ret    

008008f5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
  8008f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008fb:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008fe:	b8 00 00 00 00       	mov    $0x0,%eax
  800903:	eb 03                	jmp    800908 <strnlen+0x13>
		n++;
  800905:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800908:	39 d0                	cmp    %edx,%eax
  80090a:	74 08                	je     800914 <strnlen+0x1f>
  80090c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800910:	75 f3                	jne    800905 <strnlen+0x10>
  800912:	89 c2                	mov    %eax,%edx
	return n;
}
  800914:	89 d0                	mov    %edx,%eax
  800916:	5d                   	pop    %ebp
  800917:	c3                   	ret    

00800918 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800918:	55                   	push   %ebp
  800919:	89 e5                	mov    %esp,%ebp
  80091b:	53                   	push   %ebx
  80091c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80091f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800922:	b8 00 00 00 00       	mov    $0x0,%eax
  800927:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80092b:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  80092e:	83 c0 01             	add    $0x1,%eax
  800931:	84 d2                	test   %dl,%dl
  800933:	75 f2                	jne    800927 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800935:	89 c8                	mov    %ecx,%eax
  800937:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80093a:	c9                   	leave  
  80093b:	c3                   	ret    

0080093c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80093c:	55                   	push   %ebp
  80093d:	89 e5                	mov    %esp,%ebp
  80093f:	53                   	push   %ebx
  800940:	83 ec 10             	sub    $0x10,%esp
  800943:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800946:	53                   	push   %ebx
  800947:	e8 91 ff ff ff       	call   8008dd <strlen>
  80094c:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80094f:	ff 75 0c             	push   0xc(%ebp)
  800952:	01 d8                	add    %ebx,%eax
  800954:	50                   	push   %eax
  800955:	e8 be ff ff ff       	call   800918 <strcpy>
	return dst;
}
  80095a:	89 d8                	mov    %ebx,%eax
  80095c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80095f:	c9                   	leave  
  800960:	c3                   	ret    

00800961 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size)
{
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	56                   	push   %esi
  800965:	53                   	push   %ebx
  800966:	8b 75 08             	mov    0x8(%ebp),%esi
  800969:	8b 55 0c             	mov    0xc(%ebp),%edx
  80096c:	89 f3                	mov    %esi,%ebx
  80096e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800971:	89 f0                	mov    %esi,%eax
  800973:	eb 0f                	jmp    800984 <strncpy+0x23>
		*dst++ = *src;
  800975:	83 c0 01             	add    $0x1,%eax
  800978:	0f b6 0a             	movzbl (%edx),%ecx
  80097b:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80097e:	80 f9 01             	cmp    $0x1,%cl
  800981:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800984:	39 d8                	cmp    %ebx,%eax
  800986:	75 ed                	jne    800975 <strncpy+0x14>
	}
	return ret;
}
  800988:	89 f0                	mov    %esi,%eax
  80098a:	5b                   	pop    %ebx
  80098b:	5e                   	pop    %esi
  80098c:	5d                   	pop    %ebp
  80098d:	c3                   	ret    

0080098e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80098e:	55                   	push   %ebp
  80098f:	89 e5                	mov    %esp,%ebp
  800991:	56                   	push   %esi
  800992:	53                   	push   %ebx
  800993:	8b 75 08             	mov    0x8(%ebp),%esi
  800996:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800999:	8b 55 10             	mov    0x10(%ebp),%edx
  80099c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80099e:	85 d2                	test   %edx,%edx
  8009a0:	74 21                	je     8009c3 <strlcpy+0x35>
  8009a2:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009a6:	89 f2                	mov    %esi,%edx
  8009a8:	eb 09                	jmp    8009b3 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009aa:	83 c1 01             	add    $0x1,%ecx
  8009ad:	83 c2 01             	add    $0x1,%edx
  8009b0:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  8009b3:	39 c2                	cmp    %eax,%edx
  8009b5:	74 09                	je     8009c0 <strlcpy+0x32>
  8009b7:	0f b6 19             	movzbl (%ecx),%ebx
  8009ba:	84 db                	test   %bl,%bl
  8009bc:	75 ec                	jne    8009aa <strlcpy+0x1c>
  8009be:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8009c0:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009c3:	29 f0                	sub    %esi,%eax
}
  8009c5:	5b                   	pop    %ebx
  8009c6:	5e                   	pop    %esi
  8009c7:	5d                   	pop    %ebp
  8009c8:	c3                   	ret    

008009c9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009c9:	55                   	push   %ebp
  8009ca:	89 e5                	mov    %esp,%ebp
  8009cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009cf:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009d2:	eb 06                	jmp    8009da <strcmp+0x11>
		p++, q++;
  8009d4:	83 c1 01             	add    $0x1,%ecx
  8009d7:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8009da:	0f b6 01             	movzbl (%ecx),%eax
  8009dd:	84 c0                	test   %al,%al
  8009df:	74 04                	je     8009e5 <strcmp+0x1c>
  8009e1:	3a 02                	cmp    (%edx),%al
  8009e3:	74 ef                	je     8009d4 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009e5:	0f b6 c0             	movzbl %al,%eax
  8009e8:	0f b6 12             	movzbl (%edx),%edx
  8009eb:	29 d0                	sub    %edx,%eax
}
  8009ed:	5d                   	pop    %ebp
  8009ee:	c3                   	ret    

008009ef <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009ef:	55                   	push   %ebp
  8009f0:	89 e5                	mov    %esp,%ebp
  8009f2:	53                   	push   %ebx
  8009f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009f9:	89 c3                	mov    %eax,%ebx
  8009fb:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009fe:	eb 06                	jmp    800a06 <strncmp+0x17>
		n--, p++, q++;
  800a00:	83 c0 01             	add    $0x1,%eax
  800a03:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a06:	39 d8                	cmp    %ebx,%eax
  800a08:	74 18                	je     800a22 <strncmp+0x33>
  800a0a:	0f b6 08             	movzbl (%eax),%ecx
  800a0d:	84 c9                	test   %cl,%cl
  800a0f:	74 04                	je     800a15 <strncmp+0x26>
  800a11:	3a 0a                	cmp    (%edx),%cl
  800a13:	74 eb                	je     800a00 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a15:	0f b6 00             	movzbl (%eax),%eax
  800a18:	0f b6 12             	movzbl (%edx),%edx
  800a1b:	29 d0                	sub    %edx,%eax
}
  800a1d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a20:	c9                   	leave  
  800a21:	c3                   	ret    
		return 0;
  800a22:	b8 00 00 00 00       	mov    $0x0,%eax
  800a27:	eb f4                	jmp    800a1d <strncmp+0x2e>

00800a29 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a29:	55                   	push   %ebp
  800a2a:	89 e5                	mov    %esp,%ebp
  800a2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a33:	eb 03                	jmp    800a38 <strchr+0xf>
  800a35:	83 c0 01             	add    $0x1,%eax
  800a38:	0f b6 10             	movzbl (%eax),%edx
  800a3b:	84 d2                	test   %dl,%dl
  800a3d:	74 06                	je     800a45 <strchr+0x1c>
		if (*s == c)
  800a3f:	38 ca                	cmp    %cl,%dl
  800a41:	75 f2                	jne    800a35 <strchr+0xc>
  800a43:	eb 05                	jmp    800a4a <strchr+0x21>
			return (char *) s;
	return 0;
  800a45:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a4a:	5d                   	pop    %ebp
  800a4b:	c3                   	ret    

00800a4c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a4c:	55                   	push   %ebp
  800a4d:	89 e5                	mov    %esp,%ebp
  800a4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a52:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a56:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a59:	38 ca                	cmp    %cl,%dl
  800a5b:	74 09                	je     800a66 <strfind+0x1a>
  800a5d:	84 d2                	test   %dl,%dl
  800a5f:	74 05                	je     800a66 <strfind+0x1a>
	for (; *s; s++)
  800a61:	83 c0 01             	add    $0x1,%eax
  800a64:	eb f0                	jmp    800a56 <strfind+0xa>
			break;
	return (char *) s;
}
  800a66:	5d                   	pop    %ebp
  800a67:	c3                   	ret    

00800a68 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a68:	55                   	push   %ebp
  800a69:	89 e5                	mov    %esp,%ebp
  800a6b:	57                   	push   %edi
  800a6c:	56                   	push   %esi
  800a6d:	53                   	push   %ebx
  800a6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a71:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  800a74:	85 c9                	test   %ecx,%ecx
  800a76:	74 33                	je     800aab <memset+0x43>
		return v;
	if ((int) v % 4 == 0 && n % 4 == 0) {
  800a78:	89 d0                	mov    %edx,%eax
  800a7a:	09 c8                	or     %ecx,%eax
  800a7c:	a8 03                	test   $0x3,%al
  800a7e:	75 23                	jne    800aa3 <memset+0x3b>
		c &= 0xFF;
  800a80:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  800a84:	89 d8                	mov    %ebx,%eax
  800a86:	c1 e0 08             	shl    $0x8,%eax
  800a89:	89 df                	mov    %ebx,%edi
  800a8b:	c1 e7 18             	shl    $0x18,%edi
  800a8e:	89 de                	mov    %ebx,%esi
  800a90:	c1 e6 10             	shl    $0x10,%esi
  800a93:	09 f7                	or     %esi,%edi
  800a95:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
		             : "=D"(p), "=c"(n)
		             : "D"(p), "a"(c), "c"(n / 4)
  800a97:	c1 e9 02             	shr    $0x2,%ecx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  800a9a:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800a9c:	89 d7                	mov    %edx,%edi
  800a9e:	fc                   	cld    
  800a9f:	f3 ab                	rep stos %eax,%es:(%edi)
  800aa1:	eb 08                	jmp    800aab <memset+0x43>
		             : "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800aa3:	89 d7                	mov    %edx,%edi
  800aa5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa8:	fc                   	cld    
  800aa9:	f3 aa                	rep stos %al,%es:(%edi)
		             : "=D"(p), "=c"(n)
		             : "0"(p), "a"(c), "1"(n)
		             : "cc", "memory");
	return v;
}
  800aab:	89 d0                	mov    %edx,%eax
  800aad:	5b                   	pop    %ebx
  800aae:	5e                   	pop    %esi
  800aaf:	5f                   	pop    %edi
  800ab0:	5d                   	pop    %ebp
  800ab1:	c3                   	ret    

00800ab2 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ab2:	55                   	push   %ebp
  800ab3:	89 e5                	mov    %esp,%ebp
  800ab5:	57                   	push   %edi
  800ab6:	56                   	push   %esi
  800ab7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aba:	8b 75 0c             	mov    0xc(%ebp),%esi
  800abd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ac0:	39 c6                	cmp    %eax,%esi
  800ac2:	73 32                	jae    800af6 <memmove+0x44>
  800ac4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ac7:	39 c2                	cmp    %eax,%edx
  800ac9:	76 2b                	jbe    800af6 <memmove+0x44>
		s += n;
		d += n;
  800acb:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  800ace:	89 d6                	mov    %edx,%esi
  800ad0:	09 fe                	or     %edi,%esi
  800ad2:	09 ce                	or     %ecx,%esi
  800ad4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ada:	75 0e                	jne    800aea <memmove+0x38>
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  800adc:	83 ef 04             	sub    $0x4,%edi
			             "S"(s - 4),
  800adf:	8d 72 fc             	lea    -0x4(%edx),%esi
			             "c"(n / 4)
  800ae2:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  800ae5:	fd                   	std    
  800ae6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ae8:	eb 09                	jmp    800af3 <memmove+0x41>
			             : "cc", "memory");
		else
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  800aea:	83 ef 01             	sub    $0x1,%edi
			             "S"(s - 1),
  800aed:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  800af0:	fd                   	std    
  800af1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             "c"(n)
			             : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800af3:	fc                   	cld    
  800af4:	eb 1a                	jmp    800b10 <memmove+0x5e>
	} else {
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  800af6:	89 f2                	mov    %esi,%edx
  800af8:	09 c2                	or     %eax,%edx
  800afa:	09 ca                	or     %ecx,%edx
  800afc:	f6 c2 03             	test   $0x3,%dl
  800aff:	75 0a                	jne    800b0b <memmove+0x59>
			asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800b01:	c1 e9 02             	shr    $0x2,%ecx
  800b04:	89 c7                	mov    %eax,%edi
  800b06:	fc                   	cld    
  800b07:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b09:	eb 05                	jmp    800b10 <memmove+0x5e>
			             : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800b0b:	89 c7                	mov    %eax,%edi
  800b0d:	fc                   	cld    
  800b0e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             : "cc", "memory");
	}
	return dst;
}
  800b10:	5e                   	pop    %esi
  800b11:	5f                   	pop    %edi
  800b12:	5d                   	pop    %ebp
  800b13:	c3                   	ret    

00800b14 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b14:	55                   	push   %ebp
  800b15:	89 e5                	mov    %esp,%ebp
  800b17:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b1a:	ff 75 10             	push   0x10(%ebp)
  800b1d:	ff 75 0c             	push   0xc(%ebp)
  800b20:	ff 75 08             	push   0x8(%ebp)
  800b23:	e8 8a ff ff ff       	call   800ab2 <memmove>
}
  800b28:	c9                   	leave  
  800b29:	c3                   	ret    

00800b2a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b2a:	55                   	push   %ebp
  800b2b:	89 e5                	mov    %esp,%ebp
  800b2d:	56                   	push   %esi
  800b2e:	53                   	push   %ebx
  800b2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b32:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b35:	89 c6                	mov    %eax,%esi
  800b37:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b3a:	eb 06                	jmp    800b42 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b3c:	83 c0 01             	add    $0x1,%eax
  800b3f:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800b42:	39 f0                	cmp    %esi,%eax
  800b44:	74 14                	je     800b5a <memcmp+0x30>
		if (*s1 != *s2)
  800b46:	0f b6 08             	movzbl (%eax),%ecx
  800b49:	0f b6 1a             	movzbl (%edx),%ebx
  800b4c:	38 d9                	cmp    %bl,%cl
  800b4e:	74 ec                	je     800b3c <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800b50:	0f b6 c1             	movzbl %cl,%eax
  800b53:	0f b6 db             	movzbl %bl,%ebx
  800b56:	29 d8                	sub    %ebx,%eax
  800b58:	eb 05                	jmp    800b5f <memcmp+0x35>
	}

	return 0;
  800b5a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b5f:	5b                   	pop    %ebx
  800b60:	5e                   	pop    %esi
  800b61:	5d                   	pop    %ebp
  800b62:	c3                   	ret    

00800b63 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b63:	55                   	push   %ebp
  800b64:	89 e5                	mov    %esp,%ebp
  800b66:	8b 45 08             	mov    0x8(%ebp),%eax
  800b69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b6c:	89 c2                	mov    %eax,%edx
  800b6e:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b71:	eb 03                	jmp    800b76 <memfind+0x13>
  800b73:	83 c0 01             	add    $0x1,%eax
  800b76:	39 d0                	cmp    %edx,%eax
  800b78:	73 04                	jae    800b7e <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b7a:	38 08                	cmp    %cl,(%eax)
  800b7c:	75 f5                	jne    800b73 <memfind+0x10>
			break;
	return (void *) s;
}
  800b7e:	5d                   	pop    %ebp
  800b7f:	c3                   	ret    

00800b80 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	57                   	push   %edi
  800b84:	56                   	push   %esi
  800b85:	53                   	push   %ebx
  800b86:	8b 55 08             	mov    0x8(%ebp),%edx
  800b89:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b8c:	eb 03                	jmp    800b91 <strtol+0x11>
		s++;
  800b8e:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b91:	0f b6 02             	movzbl (%edx),%eax
  800b94:	3c 20                	cmp    $0x20,%al
  800b96:	74 f6                	je     800b8e <strtol+0xe>
  800b98:	3c 09                	cmp    $0x9,%al
  800b9a:	74 f2                	je     800b8e <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b9c:	3c 2b                	cmp    $0x2b,%al
  800b9e:	74 2a                	je     800bca <strtol+0x4a>
	int neg = 0;
  800ba0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800ba5:	3c 2d                	cmp    $0x2d,%al
  800ba7:	74 2b                	je     800bd4 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ba9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800baf:	75 0f                	jne    800bc0 <strtol+0x40>
  800bb1:	80 3a 30             	cmpb   $0x30,(%edx)
  800bb4:	74 28                	je     800bde <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bb6:	85 db                	test   %ebx,%ebx
  800bb8:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bbd:	0f 44 d8             	cmove  %eax,%ebx
  800bc0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bc5:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800bc8:	eb 46                	jmp    800c10 <strtol+0x90>
		s++;
  800bca:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800bcd:	bf 00 00 00 00       	mov    $0x0,%edi
  800bd2:	eb d5                	jmp    800ba9 <strtol+0x29>
		s++, neg = 1;
  800bd4:	83 c2 01             	add    $0x1,%edx
  800bd7:	bf 01 00 00 00       	mov    $0x1,%edi
  800bdc:	eb cb                	jmp    800ba9 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bde:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800be2:	74 0e                	je     800bf2 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800be4:	85 db                	test   %ebx,%ebx
  800be6:	75 d8                	jne    800bc0 <strtol+0x40>
		s++, base = 8;
  800be8:	83 c2 01             	add    $0x1,%edx
  800beb:	bb 08 00 00 00       	mov    $0x8,%ebx
  800bf0:	eb ce                	jmp    800bc0 <strtol+0x40>
		s += 2, base = 16;
  800bf2:	83 c2 02             	add    $0x2,%edx
  800bf5:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bfa:	eb c4                	jmp    800bc0 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800bfc:	0f be c0             	movsbl %al,%eax
  800bff:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c02:	3b 45 10             	cmp    0x10(%ebp),%eax
  800c05:	7d 3a                	jge    800c41 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800c07:	83 c2 01             	add    $0x1,%edx
  800c0a:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800c0e:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800c10:	0f b6 02             	movzbl (%edx),%eax
  800c13:	8d 70 d0             	lea    -0x30(%eax),%esi
  800c16:	89 f3                	mov    %esi,%ebx
  800c18:	80 fb 09             	cmp    $0x9,%bl
  800c1b:	76 df                	jbe    800bfc <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800c1d:	8d 70 9f             	lea    -0x61(%eax),%esi
  800c20:	89 f3                	mov    %esi,%ebx
  800c22:	80 fb 19             	cmp    $0x19,%bl
  800c25:	77 08                	ja     800c2f <strtol+0xaf>
			dig = *s - 'a' + 10;
  800c27:	0f be c0             	movsbl %al,%eax
  800c2a:	83 e8 57             	sub    $0x57,%eax
  800c2d:	eb d3                	jmp    800c02 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800c2f:	8d 70 bf             	lea    -0x41(%eax),%esi
  800c32:	89 f3                	mov    %esi,%ebx
  800c34:	80 fb 19             	cmp    $0x19,%bl
  800c37:	77 08                	ja     800c41 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800c39:	0f be c0             	movsbl %al,%eax
  800c3c:	83 e8 37             	sub    $0x37,%eax
  800c3f:	eb c1                	jmp    800c02 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c41:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c45:	74 05                	je     800c4c <strtol+0xcc>
		*endptr = (char *) s;
  800c47:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c4a:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800c4c:	89 c8                	mov    %ecx,%eax
  800c4e:	f7 d8                	neg    %eax
  800c50:	85 ff                	test   %edi,%edi
  800c52:	0f 45 c8             	cmovne %eax,%ecx
}
  800c55:	89 c8                	mov    %ecx,%eax
  800c57:	5b                   	pop    %ebx
  800c58:	5e                   	pop    %esi
  800c59:	5f                   	pop    %edi
  800c5a:	5d                   	pop    %ebp
  800c5b:	c3                   	ret    
  800c5c:	66 90                	xchg   %ax,%ax
  800c5e:	66 90                	xchg   %ax,%ax

00800c60 <__udivdi3>:
  800c60:	f3 0f 1e fb          	endbr32 
  800c64:	55                   	push   %ebp
  800c65:	57                   	push   %edi
  800c66:	56                   	push   %esi
  800c67:	53                   	push   %ebx
  800c68:	83 ec 1c             	sub    $0x1c,%esp
  800c6b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800c6f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800c73:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c77:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800c7b:	85 c0                	test   %eax,%eax
  800c7d:	75 19                	jne    800c98 <__udivdi3+0x38>
  800c7f:	39 f3                	cmp    %esi,%ebx
  800c81:	76 4d                	jbe    800cd0 <__udivdi3+0x70>
  800c83:	31 ff                	xor    %edi,%edi
  800c85:	89 e8                	mov    %ebp,%eax
  800c87:	89 f2                	mov    %esi,%edx
  800c89:	f7 f3                	div    %ebx
  800c8b:	89 fa                	mov    %edi,%edx
  800c8d:	83 c4 1c             	add    $0x1c,%esp
  800c90:	5b                   	pop    %ebx
  800c91:	5e                   	pop    %esi
  800c92:	5f                   	pop    %edi
  800c93:	5d                   	pop    %ebp
  800c94:	c3                   	ret    
  800c95:	8d 76 00             	lea    0x0(%esi),%esi
  800c98:	39 f0                	cmp    %esi,%eax
  800c9a:	76 14                	jbe    800cb0 <__udivdi3+0x50>
  800c9c:	31 ff                	xor    %edi,%edi
  800c9e:	31 c0                	xor    %eax,%eax
  800ca0:	89 fa                	mov    %edi,%edx
  800ca2:	83 c4 1c             	add    $0x1c,%esp
  800ca5:	5b                   	pop    %ebx
  800ca6:	5e                   	pop    %esi
  800ca7:	5f                   	pop    %edi
  800ca8:	5d                   	pop    %ebp
  800ca9:	c3                   	ret    
  800caa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800cb0:	0f bd f8             	bsr    %eax,%edi
  800cb3:	83 f7 1f             	xor    $0x1f,%edi
  800cb6:	75 48                	jne    800d00 <__udivdi3+0xa0>
  800cb8:	39 f0                	cmp    %esi,%eax
  800cba:	72 06                	jb     800cc2 <__udivdi3+0x62>
  800cbc:	31 c0                	xor    %eax,%eax
  800cbe:	39 eb                	cmp    %ebp,%ebx
  800cc0:	77 de                	ja     800ca0 <__udivdi3+0x40>
  800cc2:	b8 01 00 00 00       	mov    $0x1,%eax
  800cc7:	eb d7                	jmp    800ca0 <__udivdi3+0x40>
  800cc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800cd0:	89 d9                	mov    %ebx,%ecx
  800cd2:	85 db                	test   %ebx,%ebx
  800cd4:	75 0b                	jne    800ce1 <__udivdi3+0x81>
  800cd6:	b8 01 00 00 00       	mov    $0x1,%eax
  800cdb:	31 d2                	xor    %edx,%edx
  800cdd:	f7 f3                	div    %ebx
  800cdf:	89 c1                	mov    %eax,%ecx
  800ce1:	31 d2                	xor    %edx,%edx
  800ce3:	89 f0                	mov    %esi,%eax
  800ce5:	f7 f1                	div    %ecx
  800ce7:	89 c6                	mov    %eax,%esi
  800ce9:	89 e8                	mov    %ebp,%eax
  800ceb:	89 f7                	mov    %esi,%edi
  800ced:	f7 f1                	div    %ecx
  800cef:	89 fa                	mov    %edi,%edx
  800cf1:	83 c4 1c             	add    $0x1c,%esp
  800cf4:	5b                   	pop    %ebx
  800cf5:	5e                   	pop    %esi
  800cf6:	5f                   	pop    %edi
  800cf7:	5d                   	pop    %ebp
  800cf8:	c3                   	ret    
  800cf9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d00:	89 f9                	mov    %edi,%ecx
  800d02:	ba 20 00 00 00       	mov    $0x20,%edx
  800d07:	29 fa                	sub    %edi,%edx
  800d09:	d3 e0                	shl    %cl,%eax
  800d0b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d0f:	89 d1                	mov    %edx,%ecx
  800d11:	89 d8                	mov    %ebx,%eax
  800d13:	d3 e8                	shr    %cl,%eax
  800d15:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800d19:	09 c1                	or     %eax,%ecx
  800d1b:	89 f0                	mov    %esi,%eax
  800d1d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d21:	89 f9                	mov    %edi,%ecx
  800d23:	d3 e3                	shl    %cl,%ebx
  800d25:	89 d1                	mov    %edx,%ecx
  800d27:	d3 e8                	shr    %cl,%eax
  800d29:	89 f9                	mov    %edi,%ecx
  800d2b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800d2f:	89 eb                	mov    %ebp,%ebx
  800d31:	d3 e6                	shl    %cl,%esi
  800d33:	89 d1                	mov    %edx,%ecx
  800d35:	d3 eb                	shr    %cl,%ebx
  800d37:	09 f3                	or     %esi,%ebx
  800d39:	89 c6                	mov    %eax,%esi
  800d3b:	89 f2                	mov    %esi,%edx
  800d3d:	89 d8                	mov    %ebx,%eax
  800d3f:	f7 74 24 08          	divl   0x8(%esp)
  800d43:	89 d6                	mov    %edx,%esi
  800d45:	89 c3                	mov    %eax,%ebx
  800d47:	f7 64 24 0c          	mull   0xc(%esp)
  800d4b:	39 d6                	cmp    %edx,%esi
  800d4d:	72 19                	jb     800d68 <__udivdi3+0x108>
  800d4f:	89 f9                	mov    %edi,%ecx
  800d51:	d3 e5                	shl    %cl,%ebp
  800d53:	39 c5                	cmp    %eax,%ebp
  800d55:	73 04                	jae    800d5b <__udivdi3+0xfb>
  800d57:	39 d6                	cmp    %edx,%esi
  800d59:	74 0d                	je     800d68 <__udivdi3+0x108>
  800d5b:	89 d8                	mov    %ebx,%eax
  800d5d:	31 ff                	xor    %edi,%edi
  800d5f:	e9 3c ff ff ff       	jmp    800ca0 <__udivdi3+0x40>
  800d64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d68:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800d6b:	31 ff                	xor    %edi,%edi
  800d6d:	e9 2e ff ff ff       	jmp    800ca0 <__udivdi3+0x40>
  800d72:	66 90                	xchg   %ax,%ax
  800d74:	66 90                	xchg   %ax,%ax
  800d76:	66 90                	xchg   %ax,%ax
  800d78:	66 90                	xchg   %ax,%ax
  800d7a:	66 90                	xchg   %ax,%ax
  800d7c:	66 90                	xchg   %ax,%ax
  800d7e:	66 90                	xchg   %ax,%ax

00800d80 <__umoddi3>:
  800d80:	f3 0f 1e fb          	endbr32 
  800d84:	55                   	push   %ebp
  800d85:	57                   	push   %edi
  800d86:	56                   	push   %esi
  800d87:	53                   	push   %ebx
  800d88:	83 ec 1c             	sub    $0x1c,%esp
  800d8b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800d8f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800d93:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  800d97:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  800d9b:	89 f0                	mov    %esi,%eax
  800d9d:	89 da                	mov    %ebx,%edx
  800d9f:	85 ff                	test   %edi,%edi
  800da1:	75 15                	jne    800db8 <__umoddi3+0x38>
  800da3:	39 dd                	cmp    %ebx,%ebp
  800da5:	76 39                	jbe    800de0 <__umoddi3+0x60>
  800da7:	f7 f5                	div    %ebp
  800da9:	89 d0                	mov    %edx,%eax
  800dab:	31 d2                	xor    %edx,%edx
  800dad:	83 c4 1c             	add    $0x1c,%esp
  800db0:	5b                   	pop    %ebx
  800db1:	5e                   	pop    %esi
  800db2:	5f                   	pop    %edi
  800db3:	5d                   	pop    %ebp
  800db4:	c3                   	ret    
  800db5:	8d 76 00             	lea    0x0(%esi),%esi
  800db8:	39 df                	cmp    %ebx,%edi
  800dba:	77 f1                	ja     800dad <__umoddi3+0x2d>
  800dbc:	0f bd cf             	bsr    %edi,%ecx
  800dbf:	83 f1 1f             	xor    $0x1f,%ecx
  800dc2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800dc6:	75 40                	jne    800e08 <__umoddi3+0x88>
  800dc8:	39 df                	cmp    %ebx,%edi
  800dca:	72 04                	jb     800dd0 <__umoddi3+0x50>
  800dcc:	39 f5                	cmp    %esi,%ebp
  800dce:	77 dd                	ja     800dad <__umoddi3+0x2d>
  800dd0:	89 da                	mov    %ebx,%edx
  800dd2:	89 f0                	mov    %esi,%eax
  800dd4:	29 e8                	sub    %ebp,%eax
  800dd6:	19 fa                	sbb    %edi,%edx
  800dd8:	eb d3                	jmp    800dad <__umoddi3+0x2d>
  800dda:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800de0:	89 e9                	mov    %ebp,%ecx
  800de2:	85 ed                	test   %ebp,%ebp
  800de4:	75 0b                	jne    800df1 <__umoddi3+0x71>
  800de6:	b8 01 00 00 00       	mov    $0x1,%eax
  800deb:	31 d2                	xor    %edx,%edx
  800ded:	f7 f5                	div    %ebp
  800def:	89 c1                	mov    %eax,%ecx
  800df1:	89 d8                	mov    %ebx,%eax
  800df3:	31 d2                	xor    %edx,%edx
  800df5:	f7 f1                	div    %ecx
  800df7:	89 f0                	mov    %esi,%eax
  800df9:	f7 f1                	div    %ecx
  800dfb:	89 d0                	mov    %edx,%eax
  800dfd:	31 d2                	xor    %edx,%edx
  800dff:	eb ac                	jmp    800dad <__umoddi3+0x2d>
  800e01:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e08:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e0c:	ba 20 00 00 00       	mov    $0x20,%edx
  800e11:	29 c2                	sub    %eax,%edx
  800e13:	89 c1                	mov    %eax,%ecx
  800e15:	89 e8                	mov    %ebp,%eax
  800e17:	d3 e7                	shl    %cl,%edi
  800e19:	89 d1                	mov    %edx,%ecx
  800e1b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e1f:	d3 e8                	shr    %cl,%eax
  800e21:	89 c1                	mov    %eax,%ecx
  800e23:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e27:	09 f9                	or     %edi,%ecx
  800e29:	89 df                	mov    %ebx,%edi
  800e2b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e2f:	89 c1                	mov    %eax,%ecx
  800e31:	d3 e5                	shl    %cl,%ebp
  800e33:	89 d1                	mov    %edx,%ecx
  800e35:	d3 ef                	shr    %cl,%edi
  800e37:	89 c1                	mov    %eax,%ecx
  800e39:	89 f0                	mov    %esi,%eax
  800e3b:	d3 e3                	shl    %cl,%ebx
  800e3d:	89 d1                	mov    %edx,%ecx
  800e3f:	89 fa                	mov    %edi,%edx
  800e41:	d3 e8                	shr    %cl,%eax
  800e43:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e48:	09 d8                	or     %ebx,%eax
  800e4a:	f7 74 24 08          	divl   0x8(%esp)
  800e4e:	89 d3                	mov    %edx,%ebx
  800e50:	d3 e6                	shl    %cl,%esi
  800e52:	f7 e5                	mul    %ebp
  800e54:	89 c7                	mov    %eax,%edi
  800e56:	89 d1                	mov    %edx,%ecx
  800e58:	39 d3                	cmp    %edx,%ebx
  800e5a:	72 06                	jb     800e62 <__umoddi3+0xe2>
  800e5c:	75 0e                	jne    800e6c <__umoddi3+0xec>
  800e5e:	39 c6                	cmp    %eax,%esi
  800e60:	73 0a                	jae    800e6c <__umoddi3+0xec>
  800e62:	29 e8                	sub    %ebp,%eax
  800e64:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800e68:	89 d1                	mov    %edx,%ecx
  800e6a:	89 c7                	mov    %eax,%edi
  800e6c:	89 f5                	mov    %esi,%ebp
  800e6e:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e72:	29 fd                	sub    %edi,%ebp
  800e74:	19 cb                	sbb    %ecx,%ebx
  800e76:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800e7b:	89 d8                	mov    %ebx,%eax
  800e7d:	d3 e0                	shl    %cl,%eax
  800e7f:	89 f1                	mov    %esi,%ecx
  800e81:	d3 ed                	shr    %cl,%ebp
  800e83:	d3 eb                	shr    %cl,%ebx
  800e85:	09 e8                	or     %ebp,%eax
  800e87:	89 da                	mov    %ebx,%edx
  800e89:	83 c4 1c             	add    $0x1c,%esp
  800e8c:	5b                   	pop    %ebx
  800e8d:	5e                   	pop    %esi
  800e8e:	5f                   	pop    %edi
  800e8f:	5d                   	pop    %ebp
  800e90:	c3                   	ret    
