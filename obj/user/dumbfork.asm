
obj/user/dumbfork:     formato del fichero elf32-i386


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
  80002c:	e8 9d 01 00 00       	call   8001ce <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
  80003b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P | PTE_U | PTE_W)) < 0)
  80003e:	83 ec 04             	sub    $0x4,%esp
  800041:	6a 07                	push   $0x7
  800043:	53                   	push   %ebx
  800044:	56                   	push   %esi
  800045:	e8 3b 0c 00 00       	call   800c85 <sys_page_alloc>
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	78 4a                	js     80009b <duppage+0x68>
		panic("sys_page_alloc: %e", r);
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  800051:	83 ec 0c             	sub    $0xc,%esp
  800054:	6a 07                	push   $0x7
  800056:	68 00 00 40 00       	push   $0x400000
  80005b:	6a 00                	push   $0x0
  80005d:	53                   	push   %ebx
  80005e:	56                   	push   %esi
  80005f:	e8 45 0c 00 00       	call   800ca9 <sys_page_map>
  800064:	83 c4 20             	add    $0x20,%esp
  800067:	85 c0                	test   %eax,%eax
  800069:	78 42                	js     8000ad <duppage+0x7a>
		panic("sys_page_map: %e", r);
	memmove(UTEMP, addr, PGSIZE);
  80006b:	83 ec 04             	sub    $0x4,%esp
  80006e:	68 00 10 00 00       	push   $0x1000
  800073:	53                   	push   %ebx
  800074:	68 00 00 40 00       	push   $0x400000
  800079:	e8 5d 09 00 00       	call   8009db <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  80007e:	83 c4 08             	add    $0x8,%esp
  800081:	68 00 00 40 00       	push   $0x400000
  800086:	6a 00                	push   $0x0
  800088:	e8 42 0c 00 00       	call   800ccf <sys_page_unmap>
  80008d:	83 c4 10             	add    $0x10,%esp
  800090:	85 c0                	test   %eax,%eax
  800092:	78 2b                	js     8000bf <duppage+0x8c>
		panic("sys_page_unmap: %e", r);
}
  800094:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800097:	5b                   	pop    %ebx
  800098:	5e                   	pop    %esi
  800099:	5d                   	pop    %ebp
  80009a:	c3                   	ret    
		panic("sys_page_alloc: %e", r);
  80009b:	50                   	push   %eax
  80009c:	68 20 10 80 00       	push   $0x801020
  8000a1:	6a 20                	push   $0x20
  8000a3:	68 33 10 80 00       	push   $0x801033
  8000a8:	e8 80 01 00 00       	call   80022d <_panic>
		panic("sys_page_map: %e", r);
  8000ad:	50                   	push   %eax
  8000ae:	68 43 10 80 00       	push   $0x801043
  8000b3:	6a 22                	push   $0x22
  8000b5:	68 33 10 80 00       	push   $0x801033
  8000ba:	e8 6e 01 00 00       	call   80022d <_panic>
		panic("sys_page_unmap: %e", r);
  8000bf:	50                   	push   %eax
  8000c0:	68 54 10 80 00       	push   $0x801054
  8000c5:	6a 25                	push   $0x25
  8000c7:	68 33 10 80 00       	push   $0x801033
  8000cc:	e8 5c 01 00 00       	call   80022d <_panic>

008000d1 <dumbfork>:

envid_t
dumbfork(void)
{
  8000d1:	55                   	push   %ebp
  8000d2:	89 e5                	mov    %esp,%ebp
  8000d4:	53                   	push   %ebx
  8000d5:	83 ec 14             	sub    $0x14,%esp

// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline)) sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2" : "=a"(ret) : "a"(SYS_exofork), "i"(T_SYSCALL));
  8000d8:	b8 07 00 00 00       	mov    $0x7,%eax
  8000dd:	cd 30                	int    $0x30
  8000df:	89 c3                	mov    %eax,%ebx
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  8000e1:	85 c0                	test   %eax,%eax
  8000e3:	78 23                	js     800108 <dumbfork+0x37>
  8000e5:	ba 00 00 80 00       	mov    $0x800000,%edx
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
  8000ea:	75 44                	jne    800130 <dumbfork+0x5f>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  8000ec:	e8 49 0b 00 00       	call   800c3a <sys_getenvid>
  8000f1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f6:	69 c0 88 00 00 00    	imul   $0x88,%eax,%eax
  8000fc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800101:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800106:	eb 57                	jmp    80015f <dumbfork+0x8e>
		panic("sys_exofork: %e", envid);
  800108:	50                   	push   %eax
  800109:	68 67 10 80 00       	push   $0x801067
  80010e:	6a 37                	push   $0x37
  800110:	68 33 10 80 00       	push   $0x801033
  800115:	e8 13 01 00 00       	call   80022d <_panic>

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t *) UTEXT; addr < end; addr += PGSIZE)
		duppage(envid, addr);
  80011a:	83 ec 08             	sub    $0x8,%esp
  80011d:	52                   	push   %edx
  80011e:	53                   	push   %ebx
  80011f:	e8 0f ff ff ff       	call   800033 <duppage>
	for (addr = (uint8_t *) UTEXT; addr < end; addr += PGSIZE)
  800124:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800127:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
  80012d:	83 c4 10             	add    $0x10,%esp
  800130:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800133:	81 fa 08 20 80 00    	cmp    $0x802008,%edx
  800139:	72 df                	jb     80011a <dumbfork+0x49>

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  80013b:	83 ec 08             	sub    $0x8,%esp
  80013e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800141:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800146:	50                   	push   %eax
  800147:	53                   	push   %ebx
  800148:	e8 e6 fe ff ff       	call   800033 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  80014d:	83 c4 08             	add    $0x8,%esp
  800150:	6a 02                	push   $0x2
  800152:	53                   	push   %ebx
  800153:	e8 9a 0b 00 00       	call   800cf2 <sys_env_set_status>
  800158:	83 c4 10             	add    $0x10,%esp
  80015b:	85 c0                	test   %eax,%eax
  80015d:	78 07                	js     800166 <dumbfork+0x95>
		panic("sys_env_set_status: %e", r);

	return envid;
}
  80015f:	89 d8                	mov    %ebx,%eax
  800161:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800164:	c9                   	leave  
  800165:	c3                   	ret    
		panic("sys_env_set_status: %e", r);
  800166:	50                   	push   %eax
  800167:	68 77 10 80 00       	push   $0x801077
  80016c:	6a 4c                	push   $0x4c
  80016e:	68 33 10 80 00       	push   $0x801033
  800173:	e8 b5 00 00 00       	call   80022d <_panic>

00800178 <umain>:
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	57                   	push   %edi
  80017c:	56                   	push   %esi
  80017d:	53                   	push   %ebx
  80017e:	83 ec 0c             	sub    $0xc,%esp
	who = dumbfork();
  800181:	e8 4b ff ff ff       	call   8000d1 <dumbfork>
  800186:	89 c6                	mov    %eax,%esi
  800188:	85 c0                	test   %eax,%eax
  80018a:	bf 8e 10 80 00       	mov    $0x80108e,%edi
  80018f:	b8 95 10 80 00       	mov    $0x801095,%eax
  800194:	0f 44 f8             	cmove  %eax,%edi
	for (i = 0; i < (who ? 10 : 20); i++) {
  800197:	bb 00 00 00 00       	mov    $0x0,%ebx
  80019c:	eb 1f                	jmp    8001bd <umain+0x45>
  80019e:	83 fb 13             	cmp    $0x13,%ebx
  8001a1:	7f 23                	jg     8001c6 <umain+0x4e>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  8001a3:	83 ec 04             	sub    $0x4,%esp
  8001a6:	57                   	push   %edi
  8001a7:	53                   	push   %ebx
  8001a8:	68 9b 10 80 00       	push   $0x80109b
  8001ad:	e8 56 01 00 00       	call   800308 <cprintf>
		sys_yield();
  8001b2:	e8 a7 0a 00 00       	call   800c5e <sys_yield>
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001b7:	83 c3 01             	add    $0x1,%ebx
  8001ba:	83 c4 10             	add    $0x10,%esp
  8001bd:	85 f6                	test   %esi,%esi
  8001bf:	74 dd                	je     80019e <umain+0x26>
  8001c1:	83 fb 09             	cmp    $0x9,%ebx
  8001c4:	7e dd                	jle    8001a3 <umain+0x2b>
}
  8001c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001c9:	5b                   	pop    %ebx
  8001ca:	5e                   	pop    %esi
  8001cb:	5f                   	pop    %edi
  8001cc:	5d                   	pop    %ebp
  8001cd:	c3                   	ret    

008001ce <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001ce:	55                   	push   %ebp
  8001cf:	89 e5                	mov    %esp,%ebp
  8001d1:	56                   	push   %esi
  8001d2:	53                   	push   %ebx
  8001d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001d6:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	envid_t id = sys_getenvid();
  8001d9:	e8 5c 0a 00 00       	call   800c3a <sys_getenvid>
	if (id >= 0)
  8001de:	85 c0                	test   %eax,%eax
  8001e0:	78 15                	js     8001f7 <libmain+0x29>
		thisenv = &envs[ENVX(id)];
  8001e2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001e7:	69 c0 88 00 00 00    	imul   $0x88,%eax,%eax
  8001ed:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001f2:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001f7:	85 db                	test   %ebx,%ebx
  8001f9:	7e 07                	jle    800202 <libmain+0x34>
		binaryname = argv[0];
  8001fb:	8b 06                	mov    (%esi),%eax
  8001fd:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800202:	83 ec 08             	sub    $0x8,%esp
  800205:	56                   	push   %esi
  800206:	53                   	push   %ebx
  800207:	e8 6c ff ff ff       	call   800178 <umain>

	// exit gracefully
	exit();
  80020c:	e8 0a 00 00 00       	call   80021b <exit>
}
  800211:	83 c4 10             	add    $0x10,%esp
  800214:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800217:	5b                   	pop    %ebx
  800218:	5e                   	pop    %esi
  800219:	5d                   	pop    %ebp
  80021a:	c3                   	ret    

0080021b <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80021b:	55                   	push   %ebp
  80021c:	89 e5                	mov    %esp,%ebp
  80021e:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800221:	6a 00                	push   $0x0
  800223:	e8 f0 09 00 00       	call   800c18 <sys_env_destroy>
}
  800228:	83 c4 10             	add    $0x10,%esp
  80022b:	c9                   	leave  
  80022c:	c3                   	ret    

0080022d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80022d:	55                   	push   %ebp
  80022e:	89 e5                	mov    %esp,%ebp
  800230:	56                   	push   %esi
  800231:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800232:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800235:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80023b:	e8 fa 09 00 00       	call   800c3a <sys_getenvid>
  800240:	83 ec 0c             	sub    $0xc,%esp
  800243:	ff 75 0c             	push   0xc(%ebp)
  800246:	ff 75 08             	push   0x8(%ebp)
  800249:	56                   	push   %esi
  80024a:	50                   	push   %eax
  80024b:	68 b8 10 80 00       	push   $0x8010b8
  800250:	e8 b3 00 00 00       	call   800308 <cprintf>
	        sys_getenvid(),
	        binaryname,
	        file,
	        line);
	vcprintf(fmt, ap);
  800255:	83 c4 18             	add    $0x18,%esp
  800258:	53                   	push   %ebx
  800259:	ff 75 10             	push   0x10(%ebp)
  80025c:	e8 56 00 00 00       	call   8002b7 <vcprintf>
	cprintf("\n");
  800261:	c7 04 24 ab 10 80 00 	movl   $0x8010ab,(%esp)
  800268:	e8 9b 00 00 00       	call   800308 <cprintf>
  80026d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800270:	cc                   	int3   
  800271:	eb fd                	jmp    800270 <_panic+0x43>

00800273 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800273:	55                   	push   %ebp
  800274:	89 e5                	mov    %esp,%ebp
  800276:	53                   	push   %ebx
  800277:	83 ec 04             	sub    $0x4,%esp
  80027a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80027d:	8b 13                	mov    (%ebx),%edx
  80027f:	8d 42 01             	lea    0x1(%edx),%eax
  800282:	89 03                	mov    %eax,(%ebx)
  800284:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800287:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256 - 1) {
  80028b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800290:	74 09                	je     80029b <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800292:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800296:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800299:	c9                   	leave  
  80029a:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80029b:	83 ec 08             	sub    $0x8,%esp
  80029e:	68 ff 00 00 00       	push   $0xff
  8002a3:	8d 43 08             	lea    0x8(%ebx),%eax
  8002a6:	50                   	push   %eax
  8002a7:	e8 22 09 00 00       	call   800bce <sys_cputs>
		b->idx = 0;
  8002ac:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002b2:	83 c4 10             	add    $0x10,%esp
  8002b5:	eb db                	jmp    800292 <putch+0x1f>

008002b7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002b7:	55                   	push   %ebp
  8002b8:	89 e5                	mov    %esp,%ebp
  8002ba:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002c0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002c7:	00 00 00 
	b.cnt = 0;
  8002ca:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002d1:	00 00 00 
	vprintfmt((void *) putch, &b, fmt, ap);
  8002d4:	ff 75 0c             	push   0xc(%ebp)
  8002d7:	ff 75 08             	push   0x8(%ebp)
  8002da:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002e0:	50                   	push   %eax
  8002e1:	68 73 02 80 00       	push   $0x800273
  8002e6:	e8 74 01 00 00       	call   80045f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002eb:	83 c4 08             	add    $0x8,%esp
  8002ee:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8002f4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002fa:	50                   	push   %eax
  8002fb:	e8 ce 08 00 00       	call   800bce <sys_cputs>

	return b.cnt;
}
  800300:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800306:	c9                   	leave  
  800307:	c3                   	ret    

00800308 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800308:	55                   	push   %ebp
  800309:	89 e5                	mov    %esp,%ebp
  80030b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80030e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800311:	50                   	push   %eax
  800312:	ff 75 08             	push   0x8(%ebp)
  800315:	e8 9d ff ff ff       	call   8002b7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80031a:	c9                   	leave  
  80031b:	c3                   	ret    

0080031c <printnum>:
         void *putdat,
         unsigned long long num,
         unsigned base,
         int width,
         int padc)
{
  80031c:	55                   	push   %ebp
  80031d:	89 e5                	mov    %esp,%ebp
  80031f:	57                   	push   %edi
  800320:	56                   	push   %esi
  800321:	53                   	push   %ebx
  800322:	83 ec 1c             	sub    $0x1c,%esp
  800325:	89 c7                	mov    %eax,%edi
  800327:	89 d6                	mov    %edx,%esi
  800329:	8b 45 08             	mov    0x8(%ebp),%eax
  80032c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80032f:	89 d1                	mov    %edx,%ecx
  800331:	89 c2                	mov    %eax,%edx
  800333:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800336:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800339:	8b 45 10             	mov    0x10(%ebp),%eax
  80033c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80033f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800342:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800349:	39 c2                	cmp    %eax,%edx
  80034b:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80034e:	72 3e                	jb     80038e <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800350:	83 ec 0c             	sub    $0xc,%esp
  800353:	ff 75 18             	push   0x18(%ebp)
  800356:	83 eb 01             	sub    $0x1,%ebx
  800359:	53                   	push   %ebx
  80035a:	50                   	push   %eax
  80035b:	83 ec 08             	sub    $0x8,%esp
  80035e:	ff 75 e4             	push   -0x1c(%ebp)
  800361:	ff 75 e0             	push   -0x20(%ebp)
  800364:	ff 75 dc             	push   -0x24(%ebp)
  800367:	ff 75 d8             	push   -0x28(%ebp)
  80036a:	e8 61 0a 00 00       	call   800dd0 <__udivdi3>
  80036f:	83 c4 18             	add    $0x18,%esp
  800372:	52                   	push   %edx
  800373:	50                   	push   %eax
  800374:	89 f2                	mov    %esi,%edx
  800376:	89 f8                	mov    %edi,%eax
  800378:	e8 9f ff ff ff       	call   80031c <printnum>
  80037d:	83 c4 20             	add    $0x20,%esp
  800380:	eb 13                	jmp    800395 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800382:	83 ec 08             	sub    $0x8,%esp
  800385:	56                   	push   %esi
  800386:	ff 75 18             	push   0x18(%ebp)
  800389:	ff d7                	call   *%edi
  80038b:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80038e:	83 eb 01             	sub    $0x1,%ebx
  800391:	85 db                	test   %ebx,%ebx
  800393:	7f ed                	jg     800382 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800395:	83 ec 08             	sub    $0x8,%esp
  800398:	56                   	push   %esi
  800399:	83 ec 04             	sub    $0x4,%esp
  80039c:	ff 75 e4             	push   -0x1c(%ebp)
  80039f:	ff 75 e0             	push   -0x20(%ebp)
  8003a2:	ff 75 dc             	push   -0x24(%ebp)
  8003a5:	ff 75 d8             	push   -0x28(%ebp)
  8003a8:	e8 43 0b 00 00       	call   800ef0 <__umoddi3>
  8003ad:	83 c4 14             	add    $0x14,%esp
  8003b0:	0f be 80 db 10 80 00 	movsbl 0x8010db(%eax),%eax
  8003b7:	50                   	push   %eax
  8003b8:	ff d7                	call   *%edi
}
  8003ba:	83 c4 10             	add    $0x10,%esp
  8003bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003c0:	5b                   	pop    %ebx
  8003c1:	5e                   	pop    %esi
  8003c2:	5f                   	pop    %edi
  8003c3:	5d                   	pop    %ebp
  8003c4:	c3                   	ret    

008003c5 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8003c5:	83 fa 01             	cmp    $0x1,%edx
  8003c8:	7f 13                	jg     8003dd <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8003ca:	85 d2                	test   %edx,%edx
  8003cc:	74 1c                	je     8003ea <getuint+0x25>
		return va_arg(*ap, unsigned long);
  8003ce:	8b 10                	mov    (%eax),%edx
  8003d0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003d3:	89 08                	mov    %ecx,(%eax)
  8003d5:	8b 02                	mov    (%edx),%eax
  8003d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8003dc:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  8003dd:	8b 10                	mov    (%eax),%edx
  8003df:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003e2:	89 08                	mov    %ecx,(%eax)
  8003e4:	8b 02                	mov    (%edx),%eax
  8003e6:	8b 52 04             	mov    0x4(%edx),%edx
  8003e9:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  8003ea:	8b 10                	mov    (%eax),%edx
  8003ec:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ef:	89 08                	mov    %ecx,(%eax)
  8003f1:	8b 02                	mov    (%edx),%eax
  8003f3:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003f8:	c3                   	ret    

008003f9 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8003f9:	83 fa 01             	cmp    $0x1,%edx
  8003fc:	7f 0f                	jg     80040d <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  8003fe:	85 d2                	test   %edx,%edx
  800400:	74 18                	je     80041a <getint+0x21>
		return va_arg(*ap, long);
  800402:	8b 10                	mov    (%eax),%edx
  800404:	8d 4a 04             	lea    0x4(%edx),%ecx
  800407:	89 08                	mov    %ecx,(%eax)
  800409:	8b 02                	mov    (%edx),%eax
  80040b:	99                   	cltd   
  80040c:	c3                   	ret    
		return va_arg(*ap, long long);
  80040d:	8b 10                	mov    (%eax),%edx
  80040f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800412:	89 08                	mov    %ecx,(%eax)
  800414:	8b 02                	mov    (%edx),%eax
  800416:	8b 52 04             	mov    0x4(%edx),%edx
  800419:	c3                   	ret    
	else
		return va_arg(*ap, int);
  80041a:	8b 10                	mov    (%eax),%edx
  80041c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80041f:	89 08                	mov    %ecx,(%eax)
  800421:	8b 02                	mov    (%edx),%eax
  800423:	99                   	cltd   
}
  800424:	c3                   	ret    

00800425 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800425:	55                   	push   %ebp
  800426:	89 e5                	mov    %esp,%ebp
  800428:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80042b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80042f:	8b 10                	mov    (%eax),%edx
  800431:	3b 50 04             	cmp    0x4(%eax),%edx
  800434:	73 0a                	jae    800440 <sprintputch+0x1b>
		*b->buf++ = ch;
  800436:	8d 4a 01             	lea    0x1(%edx),%ecx
  800439:	89 08                	mov    %ecx,(%eax)
  80043b:	8b 45 08             	mov    0x8(%ebp),%eax
  80043e:	88 02                	mov    %al,(%edx)
}
  800440:	5d                   	pop    %ebp
  800441:	c3                   	ret    

00800442 <printfmt>:
{
  800442:	55                   	push   %ebp
  800443:	89 e5                	mov    %esp,%ebp
  800445:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800448:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80044b:	50                   	push   %eax
  80044c:	ff 75 10             	push   0x10(%ebp)
  80044f:	ff 75 0c             	push   0xc(%ebp)
  800452:	ff 75 08             	push   0x8(%ebp)
  800455:	e8 05 00 00 00       	call   80045f <vprintfmt>
}
  80045a:	83 c4 10             	add    $0x10,%esp
  80045d:	c9                   	leave  
  80045e:	c3                   	ret    

0080045f <vprintfmt>:
{
  80045f:	55                   	push   %ebp
  800460:	89 e5                	mov    %esp,%ebp
  800462:	57                   	push   %edi
  800463:	56                   	push   %esi
  800464:	53                   	push   %ebx
  800465:	83 ec 2c             	sub    $0x2c,%esp
  800468:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80046b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80046e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800471:	eb 0a                	jmp    80047d <vprintfmt+0x1e>
			putch(ch, putdat);
  800473:	83 ec 08             	sub    $0x8,%esp
  800476:	56                   	push   %esi
  800477:	50                   	push   %eax
  800478:	ff d3                	call   *%ebx
  80047a:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80047d:	83 c7 01             	add    $0x1,%edi
  800480:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800484:	83 f8 25             	cmp    $0x25,%eax
  800487:	74 0c                	je     800495 <vprintfmt+0x36>
			if (ch == '\0')
  800489:	85 c0                	test   %eax,%eax
  80048b:	75 e6                	jne    800473 <vprintfmt+0x14>
}
  80048d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800490:	5b                   	pop    %ebx
  800491:	5e                   	pop    %esi
  800492:	5f                   	pop    %edi
  800493:	5d                   	pop    %ebp
  800494:	c3                   	ret    
		padc = ' ';
  800495:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
		altflag = 0;
  800499:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8004a0:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8004a7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8004ae:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8004b3:	8d 47 01             	lea    0x1(%edi),%eax
  8004b6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004b9:	0f b6 17             	movzbl (%edi),%edx
  8004bc:	8d 42 dd             	lea    -0x23(%edx),%eax
  8004bf:	3c 55                	cmp    $0x55,%al
  8004c1:	0f 87 b7 02 00 00    	ja     80077e <vprintfmt+0x31f>
  8004c7:	0f b6 c0             	movzbl %al,%eax
  8004ca:	ff 24 85 a0 11 80 00 	jmp    *0x8011a0(,%eax,4)
  8004d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8004d4:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  8004d8:	eb d9                	jmp    8004b3 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8004da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004dd:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  8004e1:	eb d0                	jmp    8004b3 <vprintfmt+0x54>
  8004e3:	0f b6 d2             	movzbl %dl,%edx
  8004e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0;; ++fmt) {
  8004e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ee:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8004f1:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004f4:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8004f8:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8004fb:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8004fe:	83 f9 09             	cmp    $0x9,%ecx
  800501:	77 52                	ja     800555 <vprintfmt+0xf6>
			for (precision = 0;; ++fmt) {
  800503:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800506:	eb e9                	jmp    8004f1 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  800508:	8b 45 14             	mov    0x14(%ebp),%eax
  80050b:	8d 50 04             	lea    0x4(%eax),%edx
  80050e:	89 55 14             	mov    %edx,0x14(%ebp)
  800511:	8b 00                	mov    (%eax),%eax
  800513:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800516:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800519:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80051d:	79 94                	jns    8004b3 <vprintfmt+0x54>
				width = precision, precision = -1;
  80051f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800522:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800525:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80052c:	eb 85                	jmp    8004b3 <vprintfmt+0x54>
  80052e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800531:	85 d2                	test   %edx,%edx
  800533:	b8 00 00 00 00       	mov    $0x0,%eax
  800538:	0f 49 c2             	cmovns %edx,%eax
  80053b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80053e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800541:	e9 6d ff ff ff       	jmp    8004b3 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800546:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800549:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800550:	e9 5e ff ff ff       	jmp    8004b3 <vprintfmt+0x54>
  800555:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800558:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80055b:	eb bc                	jmp    800519 <vprintfmt+0xba>
			lflag++;
  80055d:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800560:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800563:	e9 4b ff ff ff       	jmp    8004b3 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800568:	8b 45 14             	mov    0x14(%ebp),%eax
  80056b:	8d 50 04             	lea    0x4(%eax),%edx
  80056e:	89 55 14             	mov    %edx,0x14(%ebp)
  800571:	83 ec 08             	sub    $0x8,%esp
  800574:	56                   	push   %esi
  800575:	ff 30                	push   (%eax)
  800577:	ff d3                	call   *%ebx
			break;
  800579:	83 c4 10             	add    $0x10,%esp
  80057c:	e9 94 01 00 00       	jmp    800715 <vprintfmt+0x2b6>
			err = va_arg(ap, int);
  800581:	8b 45 14             	mov    0x14(%ebp),%eax
  800584:	8d 50 04             	lea    0x4(%eax),%edx
  800587:	89 55 14             	mov    %edx,0x14(%ebp)
  80058a:	8b 10                	mov    (%eax),%edx
  80058c:	89 d0                	mov    %edx,%eax
  80058e:	f7 d8                	neg    %eax
  800590:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800593:	83 f8 08             	cmp    $0x8,%eax
  800596:	7f 20                	jg     8005b8 <vprintfmt+0x159>
  800598:	8b 14 85 00 13 80 00 	mov    0x801300(,%eax,4),%edx
  80059f:	85 d2                	test   %edx,%edx
  8005a1:	74 15                	je     8005b8 <vprintfmt+0x159>
				printfmt(putch, putdat, "%s", p);
  8005a3:	52                   	push   %edx
  8005a4:	68 fc 10 80 00       	push   $0x8010fc
  8005a9:	56                   	push   %esi
  8005aa:	53                   	push   %ebx
  8005ab:	e8 92 fe ff ff       	call   800442 <printfmt>
  8005b0:	83 c4 10             	add    $0x10,%esp
  8005b3:	e9 5d 01 00 00       	jmp    800715 <vprintfmt+0x2b6>
				printfmt(putch, putdat, "error %d", err);
  8005b8:	50                   	push   %eax
  8005b9:	68 f3 10 80 00       	push   $0x8010f3
  8005be:	56                   	push   %esi
  8005bf:	53                   	push   %ebx
  8005c0:	e8 7d fe ff ff       	call   800442 <printfmt>
  8005c5:	83 c4 10             	add    $0x10,%esp
  8005c8:	e9 48 01 00 00       	jmp    800715 <vprintfmt+0x2b6>
			if ((p = va_arg(ap, char *)) == NULL)
  8005cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d0:	8d 50 04             	lea    0x4(%eax),%edx
  8005d3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d6:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005d8:	85 ff                	test   %edi,%edi
  8005da:	b8 ec 10 80 00       	mov    $0x8010ec,%eax
  8005df:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005e2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005e6:	7e 06                	jle    8005ee <vprintfmt+0x18f>
  8005e8:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8005ec:	75 0a                	jne    8005f8 <vprintfmt+0x199>
  8005ee:	89 f8                	mov    %edi,%eax
  8005f0:	03 45 e0             	add    -0x20(%ebp),%eax
  8005f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005f6:	eb 59                	jmp    800651 <vprintfmt+0x1f2>
				for (width -= strnlen(p, precision); width > 0;
  8005f8:	83 ec 08             	sub    $0x8,%esp
  8005fb:	ff 75 d8             	push   -0x28(%ebp)
  8005fe:	57                   	push   %edi
  8005ff:	e8 1a 02 00 00       	call   80081e <strnlen>
  800604:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800607:	29 c1                	sub    %eax,%ecx
  800609:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80060c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80060f:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  800613:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800616:	89 7d d0             	mov    %edi,-0x30(%ebp)
  800619:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0;
  80061b:	eb 0f                	jmp    80062c <vprintfmt+0x1cd>
					putch(padc, putdat);
  80061d:	83 ec 08             	sub    $0x8,%esp
  800620:	56                   	push   %esi
  800621:	ff 75 e0             	push   -0x20(%ebp)
  800624:	ff d3                	call   *%ebx
				     width--)
  800626:	83 ef 01             	sub    $0x1,%edi
  800629:	83 c4 10             	add    $0x10,%esp
				for (width -= strnlen(p, precision); width > 0;
  80062c:	85 ff                	test   %edi,%edi
  80062e:	7f ed                	jg     80061d <vprintfmt+0x1be>
  800630:	8b 7d d0             	mov    -0x30(%ebp),%edi
  800633:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800636:	85 c9                	test   %ecx,%ecx
  800638:	b8 00 00 00 00       	mov    $0x0,%eax
  80063d:	0f 49 c1             	cmovns %ecx,%eax
  800640:	29 c1                	sub    %eax,%ecx
  800642:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800645:	eb a7                	jmp    8005ee <vprintfmt+0x18f>
					putch(ch, putdat);
  800647:	83 ec 08             	sub    $0x8,%esp
  80064a:	56                   	push   %esi
  80064b:	52                   	push   %edx
  80064c:	ff d3                	call   *%ebx
  80064e:	83 c4 10             	add    $0x10,%esp
  800651:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800654:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' &&
  800656:	83 c7 01             	add    $0x1,%edi
  800659:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80065d:	0f be d0             	movsbl %al,%edx
  800660:	85 d2                	test   %edx,%edx
  800662:	74 42                	je     8006a6 <vprintfmt+0x247>
  800664:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800668:	78 06                	js     800670 <vprintfmt+0x211>
			       (precision < 0 || --precision >= 0);
  80066a:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80066e:	78 1e                	js     80068e <vprintfmt+0x22f>
				if (altflag && (ch < ' ' || ch > '~'))
  800670:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800674:	74 d1                	je     800647 <vprintfmt+0x1e8>
  800676:	0f be c0             	movsbl %al,%eax
  800679:	83 e8 20             	sub    $0x20,%eax
  80067c:	83 f8 5e             	cmp    $0x5e,%eax
  80067f:	76 c6                	jbe    800647 <vprintfmt+0x1e8>
					putch('?', putdat);
  800681:	83 ec 08             	sub    $0x8,%esp
  800684:	56                   	push   %esi
  800685:	6a 3f                	push   $0x3f
  800687:	ff d3                	call   *%ebx
  800689:	83 c4 10             	add    $0x10,%esp
  80068c:	eb c3                	jmp    800651 <vprintfmt+0x1f2>
  80068e:	89 cf                	mov    %ecx,%edi
  800690:	eb 0e                	jmp    8006a0 <vprintfmt+0x241>
				putch(' ', putdat);
  800692:	83 ec 08             	sub    $0x8,%esp
  800695:	56                   	push   %esi
  800696:	6a 20                	push   $0x20
  800698:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  80069a:	83 ef 01             	sub    $0x1,%edi
  80069d:	83 c4 10             	add    $0x10,%esp
  8006a0:	85 ff                	test   %edi,%edi
  8006a2:	7f ee                	jg     800692 <vprintfmt+0x233>
  8006a4:	eb 6f                	jmp    800715 <vprintfmt+0x2b6>
  8006a6:	89 cf                	mov    %ecx,%edi
  8006a8:	eb f6                	jmp    8006a0 <vprintfmt+0x241>
			num = getint(&ap, lflag);
  8006aa:	89 ca                	mov    %ecx,%edx
  8006ac:	8d 45 14             	lea    0x14(%ebp),%eax
  8006af:	e8 45 fd ff ff       	call   8003f9 <getint>
  8006b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006b7:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  8006ba:	85 d2                	test   %edx,%edx
  8006bc:	78 0b                	js     8006c9 <vprintfmt+0x26a>
			num = getint(&ap, lflag);
  8006be:	89 d1                	mov    %edx,%ecx
  8006c0:	89 c2                	mov    %eax,%edx
			base = 10;
  8006c2:	bf 0a 00 00 00       	mov    $0xa,%edi
  8006c7:	eb 32                	jmp    8006fb <vprintfmt+0x29c>
				putch('-', putdat);
  8006c9:	83 ec 08             	sub    $0x8,%esp
  8006cc:	56                   	push   %esi
  8006cd:	6a 2d                	push   $0x2d
  8006cf:	ff d3                	call   *%ebx
				num = -(long long) num;
  8006d1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006d4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006d7:	f7 da                	neg    %edx
  8006d9:	83 d1 00             	adc    $0x0,%ecx
  8006dc:	f7 d9                	neg    %ecx
  8006de:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8006e1:	bf 0a 00 00 00       	mov    $0xa,%edi
  8006e6:	eb 13                	jmp    8006fb <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  8006e8:	89 ca                	mov    %ecx,%edx
  8006ea:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ed:	e8 d3 fc ff ff       	call   8003c5 <getuint>
  8006f2:	89 d1                	mov    %edx,%ecx
  8006f4:	89 c2                	mov    %eax,%edx
			base = 10;
  8006f6:	bf 0a 00 00 00       	mov    $0xa,%edi
			printnum(putch, putdat, num, base, width, padc);
  8006fb:	83 ec 0c             	sub    $0xc,%esp
  8006fe:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  800702:	50                   	push   %eax
  800703:	ff 75 e0             	push   -0x20(%ebp)
  800706:	57                   	push   %edi
  800707:	51                   	push   %ecx
  800708:	52                   	push   %edx
  800709:	89 f2                	mov    %esi,%edx
  80070b:	89 d8                	mov    %ebx,%eax
  80070d:	e8 0a fc ff ff       	call   80031c <printnum>
			break;
  800712:	83 c4 20             	add    $0x20,%esp
{
  800715:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800718:	e9 60 fd ff ff       	jmp    80047d <vprintfmt+0x1e>
			num = getuint(&ap, lflag);
  80071d:	89 ca                	mov    %ecx,%edx
  80071f:	8d 45 14             	lea    0x14(%ebp),%eax
  800722:	e8 9e fc ff ff       	call   8003c5 <getuint>
  800727:	89 d1                	mov    %edx,%ecx
  800729:	89 c2                	mov    %eax,%edx
			base = 8;
  80072b:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  800730:	eb c9                	jmp    8006fb <vprintfmt+0x29c>
			putch('0', putdat);
  800732:	83 ec 08             	sub    $0x8,%esp
  800735:	56                   	push   %esi
  800736:	6a 30                	push   $0x30
  800738:	ff d3                	call   *%ebx
			putch('x', putdat);
  80073a:	83 c4 08             	add    $0x8,%esp
  80073d:	56                   	push   %esi
  80073e:	6a 78                	push   $0x78
  800740:	ff d3                	call   *%ebx
			num = (unsigned long long) (uintptr_t) va_arg(ap, void *);
  800742:	8b 45 14             	mov    0x14(%ebp),%eax
  800745:	8d 50 04             	lea    0x4(%eax),%edx
  800748:	89 55 14             	mov    %edx,0x14(%ebp)
  80074b:	8b 10                	mov    (%eax),%edx
  80074d:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800752:	83 c4 10             	add    $0x10,%esp
			base = 16;
  800755:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  80075a:	eb 9f                	jmp    8006fb <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  80075c:	89 ca                	mov    %ecx,%edx
  80075e:	8d 45 14             	lea    0x14(%ebp),%eax
  800761:	e8 5f fc ff ff       	call   8003c5 <getuint>
  800766:	89 d1                	mov    %edx,%ecx
  800768:	89 c2                	mov    %eax,%edx
			base = 16;
  80076a:	bf 10 00 00 00       	mov    $0x10,%edi
  80076f:	eb 8a                	jmp    8006fb <vprintfmt+0x29c>
			putch(ch, putdat);
  800771:	83 ec 08             	sub    $0x8,%esp
  800774:	56                   	push   %esi
  800775:	6a 25                	push   $0x25
  800777:	ff d3                	call   *%ebx
			break;
  800779:	83 c4 10             	add    $0x10,%esp
  80077c:	eb 97                	jmp    800715 <vprintfmt+0x2b6>
			putch('%', putdat);
  80077e:	83 ec 08             	sub    $0x8,%esp
  800781:	56                   	push   %esi
  800782:	6a 25                	push   $0x25
  800784:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  800786:	83 c4 10             	add    $0x10,%esp
  800789:	89 f8                	mov    %edi,%eax
  80078b:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80078f:	74 05                	je     800796 <vprintfmt+0x337>
  800791:	83 e8 01             	sub    $0x1,%eax
  800794:	eb f5                	jmp    80078b <vprintfmt+0x32c>
  800796:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800799:	e9 77 ff ff ff       	jmp    800715 <vprintfmt+0x2b6>

0080079e <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80079e:	55                   	push   %ebp
  80079f:	89 e5                	mov    %esp,%ebp
  8007a1:	83 ec 18             	sub    $0x18,%esp
  8007a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = { buf, buf + n - 1, 0 };
  8007aa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007ad:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007b1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007b4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007bb:	85 c0                	test   %eax,%eax
  8007bd:	74 26                	je     8007e5 <vsnprintf+0x47>
  8007bf:	85 d2                	test   %edx,%edx
  8007c1:	7e 22                	jle    8007e5 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *) sprintputch, &b, fmt, ap);
  8007c3:	ff 75 14             	push   0x14(%ebp)
  8007c6:	ff 75 10             	push   0x10(%ebp)
  8007c9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007cc:	50                   	push   %eax
  8007cd:	68 25 04 80 00       	push   $0x800425
  8007d2:	e8 88 fc ff ff       	call   80045f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007da:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007e0:	83 c4 10             	add    $0x10,%esp
}
  8007e3:	c9                   	leave  
  8007e4:	c3                   	ret    
		return -E_INVAL;
  8007e5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007ea:	eb f7                	jmp    8007e3 <vsnprintf+0x45>

008007ec <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007ec:	55                   	push   %ebp
  8007ed:	89 e5                	mov    %esp,%ebp
  8007ef:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007f2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007f5:	50                   	push   %eax
  8007f6:	ff 75 10             	push   0x10(%ebp)
  8007f9:	ff 75 0c             	push   0xc(%ebp)
  8007fc:	ff 75 08             	push   0x8(%ebp)
  8007ff:	e8 9a ff ff ff       	call   80079e <vsnprintf>
	va_end(ap);

	return rc;
}
  800804:	c9                   	leave  
  800805:	c3                   	ret    

00800806 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800806:	55                   	push   %ebp
  800807:	89 e5                	mov    %esp,%ebp
  800809:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80080c:	b8 00 00 00 00       	mov    $0x0,%eax
  800811:	eb 03                	jmp    800816 <strlen+0x10>
		n++;
  800813:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800816:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80081a:	75 f7                	jne    800813 <strlen+0xd>
	return n;
}
  80081c:	5d                   	pop    %ebp
  80081d:	c3                   	ret    

0080081e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80081e:	55                   	push   %ebp
  80081f:	89 e5                	mov    %esp,%ebp
  800821:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800824:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800827:	b8 00 00 00 00       	mov    $0x0,%eax
  80082c:	eb 03                	jmp    800831 <strnlen+0x13>
		n++;
  80082e:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800831:	39 d0                	cmp    %edx,%eax
  800833:	74 08                	je     80083d <strnlen+0x1f>
  800835:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800839:	75 f3                	jne    80082e <strnlen+0x10>
  80083b:	89 c2                	mov    %eax,%edx
	return n;
}
  80083d:	89 d0                	mov    %edx,%eax
  80083f:	5d                   	pop    %ebp
  800840:	c3                   	ret    

00800841 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800841:	55                   	push   %ebp
  800842:	89 e5                	mov    %esp,%ebp
  800844:	53                   	push   %ebx
  800845:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800848:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80084b:	b8 00 00 00 00       	mov    $0x0,%eax
  800850:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800854:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800857:	83 c0 01             	add    $0x1,%eax
  80085a:	84 d2                	test   %dl,%dl
  80085c:	75 f2                	jne    800850 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80085e:	89 c8                	mov    %ecx,%eax
  800860:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800863:	c9                   	leave  
  800864:	c3                   	ret    

00800865 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800865:	55                   	push   %ebp
  800866:	89 e5                	mov    %esp,%ebp
  800868:	53                   	push   %ebx
  800869:	83 ec 10             	sub    $0x10,%esp
  80086c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80086f:	53                   	push   %ebx
  800870:	e8 91 ff ff ff       	call   800806 <strlen>
  800875:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800878:	ff 75 0c             	push   0xc(%ebp)
  80087b:	01 d8                	add    %ebx,%eax
  80087d:	50                   	push   %eax
  80087e:	e8 be ff ff ff       	call   800841 <strcpy>
	return dst;
}
  800883:	89 d8                	mov    %ebx,%eax
  800885:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800888:	c9                   	leave  
  800889:	c3                   	ret    

0080088a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	56                   	push   %esi
  80088e:	53                   	push   %ebx
  80088f:	8b 75 08             	mov    0x8(%ebp),%esi
  800892:	8b 55 0c             	mov    0xc(%ebp),%edx
  800895:	89 f3                	mov    %esi,%ebx
  800897:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80089a:	89 f0                	mov    %esi,%eax
  80089c:	eb 0f                	jmp    8008ad <strncpy+0x23>
		*dst++ = *src;
  80089e:	83 c0 01             	add    $0x1,%eax
  8008a1:	0f b6 0a             	movzbl (%edx),%ecx
  8008a4:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008a7:	80 f9 01             	cmp    $0x1,%cl
  8008aa:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  8008ad:	39 d8                	cmp    %ebx,%eax
  8008af:	75 ed                	jne    80089e <strncpy+0x14>
	}
	return ret;
}
  8008b1:	89 f0                	mov    %esi,%eax
  8008b3:	5b                   	pop    %ebx
  8008b4:	5e                   	pop    %esi
  8008b5:	5d                   	pop    %ebp
  8008b6:	c3                   	ret    

008008b7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008b7:	55                   	push   %ebp
  8008b8:	89 e5                	mov    %esp,%ebp
  8008ba:	56                   	push   %esi
  8008bb:	53                   	push   %ebx
  8008bc:	8b 75 08             	mov    0x8(%ebp),%esi
  8008bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008c2:	8b 55 10             	mov    0x10(%ebp),%edx
  8008c5:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008c7:	85 d2                	test   %edx,%edx
  8008c9:	74 21                	je     8008ec <strlcpy+0x35>
  8008cb:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008cf:	89 f2                	mov    %esi,%edx
  8008d1:	eb 09                	jmp    8008dc <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008d3:	83 c1 01             	add    $0x1,%ecx
  8008d6:	83 c2 01             	add    $0x1,%edx
  8008d9:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  8008dc:	39 c2                	cmp    %eax,%edx
  8008de:	74 09                	je     8008e9 <strlcpy+0x32>
  8008e0:	0f b6 19             	movzbl (%ecx),%ebx
  8008e3:	84 db                	test   %bl,%bl
  8008e5:	75 ec                	jne    8008d3 <strlcpy+0x1c>
  8008e7:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8008e9:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008ec:	29 f0                	sub    %esi,%eax
}
  8008ee:	5b                   	pop    %ebx
  8008ef:	5e                   	pop    %esi
  8008f0:	5d                   	pop    %ebp
  8008f1:	c3                   	ret    

008008f2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
  8008f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008f8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008fb:	eb 06                	jmp    800903 <strcmp+0x11>
		p++, q++;
  8008fd:	83 c1 01             	add    $0x1,%ecx
  800900:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800903:	0f b6 01             	movzbl (%ecx),%eax
  800906:	84 c0                	test   %al,%al
  800908:	74 04                	je     80090e <strcmp+0x1c>
  80090a:	3a 02                	cmp    (%edx),%al
  80090c:	74 ef                	je     8008fd <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80090e:	0f b6 c0             	movzbl %al,%eax
  800911:	0f b6 12             	movzbl (%edx),%edx
  800914:	29 d0                	sub    %edx,%eax
}
  800916:	5d                   	pop    %ebp
  800917:	c3                   	ret    

00800918 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800918:	55                   	push   %ebp
  800919:	89 e5                	mov    %esp,%ebp
  80091b:	53                   	push   %ebx
  80091c:	8b 45 08             	mov    0x8(%ebp),%eax
  80091f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800922:	89 c3                	mov    %eax,%ebx
  800924:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800927:	eb 06                	jmp    80092f <strncmp+0x17>
		n--, p++, q++;
  800929:	83 c0 01             	add    $0x1,%eax
  80092c:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80092f:	39 d8                	cmp    %ebx,%eax
  800931:	74 18                	je     80094b <strncmp+0x33>
  800933:	0f b6 08             	movzbl (%eax),%ecx
  800936:	84 c9                	test   %cl,%cl
  800938:	74 04                	je     80093e <strncmp+0x26>
  80093a:	3a 0a                	cmp    (%edx),%cl
  80093c:	74 eb                	je     800929 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80093e:	0f b6 00             	movzbl (%eax),%eax
  800941:	0f b6 12             	movzbl (%edx),%edx
  800944:	29 d0                	sub    %edx,%eax
}
  800946:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800949:	c9                   	leave  
  80094a:	c3                   	ret    
		return 0;
  80094b:	b8 00 00 00 00       	mov    $0x0,%eax
  800950:	eb f4                	jmp    800946 <strncmp+0x2e>

00800952 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800952:	55                   	push   %ebp
  800953:	89 e5                	mov    %esp,%ebp
  800955:	8b 45 08             	mov    0x8(%ebp),%eax
  800958:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80095c:	eb 03                	jmp    800961 <strchr+0xf>
  80095e:	83 c0 01             	add    $0x1,%eax
  800961:	0f b6 10             	movzbl (%eax),%edx
  800964:	84 d2                	test   %dl,%dl
  800966:	74 06                	je     80096e <strchr+0x1c>
		if (*s == c)
  800968:	38 ca                	cmp    %cl,%dl
  80096a:	75 f2                	jne    80095e <strchr+0xc>
  80096c:	eb 05                	jmp    800973 <strchr+0x21>
			return (char *) s;
	return 0;
  80096e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800973:	5d                   	pop    %ebp
  800974:	c3                   	ret    

00800975 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800975:	55                   	push   %ebp
  800976:	89 e5                	mov    %esp,%ebp
  800978:	8b 45 08             	mov    0x8(%ebp),%eax
  80097b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80097f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800982:	38 ca                	cmp    %cl,%dl
  800984:	74 09                	je     80098f <strfind+0x1a>
  800986:	84 d2                	test   %dl,%dl
  800988:	74 05                	je     80098f <strfind+0x1a>
	for (; *s; s++)
  80098a:	83 c0 01             	add    $0x1,%eax
  80098d:	eb f0                	jmp    80097f <strfind+0xa>
			break;
	return (char *) s;
}
  80098f:	5d                   	pop    %ebp
  800990:	c3                   	ret    

00800991 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800991:	55                   	push   %ebp
  800992:	89 e5                	mov    %esp,%ebp
  800994:	57                   	push   %edi
  800995:	56                   	push   %esi
  800996:	53                   	push   %ebx
  800997:	8b 55 08             	mov    0x8(%ebp),%edx
  80099a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  80099d:	85 c9                	test   %ecx,%ecx
  80099f:	74 33                	je     8009d4 <memset+0x43>
		return v;
	if ((int) v % 4 == 0 && n % 4 == 0) {
  8009a1:	89 d0                	mov    %edx,%eax
  8009a3:	09 c8                	or     %ecx,%eax
  8009a5:	a8 03                	test   $0x3,%al
  8009a7:	75 23                	jne    8009cc <memset+0x3b>
		c &= 0xFF;
  8009a9:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  8009ad:	89 d8                	mov    %ebx,%eax
  8009af:	c1 e0 08             	shl    $0x8,%eax
  8009b2:	89 df                	mov    %ebx,%edi
  8009b4:	c1 e7 18             	shl    $0x18,%edi
  8009b7:	89 de                	mov    %ebx,%esi
  8009b9:	c1 e6 10             	shl    $0x10,%esi
  8009bc:	09 f7                	or     %esi,%edi
  8009be:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
		             : "=D"(p), "=c"(n)
		             : "D"(p), "a"(c), "c"(n / 4)
  8009c0:	c1 e9 02             	shr    $0x2,%ecx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  8009c3:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  8009c5:	89 d7                	mov    %edx,%edi
  8009c7:	fc                   	cld    
  8009c8:	f3 ab                	rep stos %eax,%es:(%edi)
  8009ca:	eb 08                	jmp    8009d4 <memset+0x43>
		             : "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009cc:	89 d7                	mov    %edx,%edi
  8009ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d1:	fc                   	cld    
  8009d2:	f3 aa                	rep stos %al,%es:(%edi)
		             : "=D"(p), "=c"(n)
		             : "0"(p), "a"(c), "1"(n)
		             : "cc", "memory");
	return v;
}
  8009d4:	89 d0                	mov    %edx,%eax
  8009d6:	5b                   	pop    %ebx
  8009d7:	5e                   	pop    %esi
  8009d8:	5f                   	pop    %edi
  8009d9:	5d                   	pop    %ebp
  8009da:	c3                   	ret    

008009db <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	57                   	push   %edi
  8009df:	56                   	push   %esi
  8009e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009e6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009e9:	39 c6                	cmp    %eax,%esi
  8009eb:	73 32                	jae    800a1f <memmove+0x44>
  8009ed:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009f0:	39 c2                	cmp    %eax,%edx
  8009f2:	76 2b                	jbe    800a1f <memmove+0x44>
		s += n;
		d += n;
  8009f4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  8009f7:	89 d6                	mov    %edx,%esi
  8009f9:	09 fe                	or     %edi,%esi
  8009fb:	09 ce                	or     %ecx,%esi
  8009fd:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a03:	75 0e                	jne    800a13 <memmove+0x38>
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  800a05:	83 ef 04             	sub    $0x4,%edi
			             "S"(s - 4),
  800a08:	8d 72 fc             	lea    -0x4(%edx),%esi
			             "c"(n / 4)
  800a0b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  800a0e:	fd                   	std    
  800a0f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a11:	eb 09                	jmp    800a1c <memmove+0x41>
			             : "cc", "memory");
		else
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  800a13:	83 ef 01             	sub    $0x1,%edi
			             "S"(s - 1),
  800a16:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  800a19:	fd                   	std    
  800a1a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             "c"(n)
			             : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a1c:	fc                   	cld    
  800a1d:	eb 1a                	jmp    800a39 <memmove+0x5e>
	} else {
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  800a1f:	89 f2                	mov    %esi,%edx
  800a21:	09 c2                	or     %eax,%edx
  800a23:	09 ca                	or     %ecx,%edx
  800a25:	f6 c2 03             	test   $0x3,%dl
  800a28:	75 0a                	jne    800a34 <memmove+0x59>
			asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800a2a:	c1 e9 02             	shr    $0x2,%ecx
  800a2d:	89 c7                	mov    %eax,%edi
  800a2f:	fc                   	cld    
  800a30:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a32:	eb 05                	jmp    800a39 <memmove+0x5e>
			             : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800a34:	89 c7                	mov    %eax,%edi
  800a36:	fc                   	cld    
  800a37:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             : "cc", "memory");
	}
	return dst;
}
  800a39:	5e                   	pop    %esi
  800a3a:	5f                   	pop    %edi
  800a3b:	5d                   	pop    %ebp
  800a3c:	c3                   	ret    

00800a3d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a3d:	55                   	push   %ebp
  800a3e:	89 e5                	mov    %esp,%ebp
  800a40:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a43:	ff 75 10             	push   0x10(%ebp)
  800a46:	ff 75 0c             	push   0xc(%ebp)
  800a49:	ff 75 08             	push   0x8(%ebp)
  800a4c:	e8 8a ff ff ff       	call   8009db <memmove>
}
  800a51:	c9                   	leave  
  800a52:	c3                   	ret    

00800a53 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a53:	55                   	push   %ebp
  800a54:	89 e5                	mov    %esp,%ebp
  800a56:	56                   	push   %esi
  800a57:	53                   	push   %ebx
  800a58:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a5e:	89 c6                	mov    %eax,%esi
  800a60:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a63:	eb 06                	jmp    800a6b <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a65:	83 c0 01             	add    $0x1,%eax
  800a68:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800a6b:	39 f0                	cmp    %esi,%eax
  800a6d:	74 14                	je     800a83 <memcmp+0x30>
		if (*s1 != *s2)
  800a6f:	0f b6 08             	movzbl (%eax),%ecx
  800a72:	0f b6 1a             	movzbl (%edx),%ebx
  800a75:	38 d9                	cmp    %bl,%cl
  800a77:	74 ec                	je     800a65 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800a79:	0f b6 c1             	movzbl %cl,%eax
  800a7c:	0f b6 db             	movzbl %bl,%ebx
  800a7f:	29 d8                	sub    %ebx,%eax
  800a81:	eb 05                	jmp    800a88 <memcmp+0x35>
	}

	return 0;
  800a83:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a88:	5b                   	pop    %ebx
  800a89:	5e                   	pop    %esi
  800a8a:	5d                   	pop    %ebp
  800a8b:	c3                   	ret    

00800a8c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a8c:	55                   	push   %ebp
  800a8d:	89 e5                	mov    %esp,%ebp
  800a8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a95:	89 c2                	mov    %eax,%edx
  800a97:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a9a:	eb 03                	jmp    800a9f <memfind+0x13>
  800a9c:	83 c0 01             	add    $0x1,%eax
  800a9f:	39 d0                	cmp    %edx,%eax
  800aa1:	73 04                	jae    800aa7 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aa3:	38 08                	cmp    %cl,(%eax)
  800aa5:	75 f5                	jne    800a9c <memfind+0x10>
			break;
	return (void *) s;
}
  800aa7:	5d                   	pop    %ebp
  800aa8:	c3                   	ret    

00800aa9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aa9:	55                   	push   %ebp
  800aaa:	89 e5                	mov    %esp,%ebp
  800aac:	57                   	push   %edi
  800aad:	56                   	push   %esi
  800aae:	53                   	push   %ebx
  800aaf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ab5:	eb 03                	jmp    800aba <strtol+0x11>
		s++;
  800ab7:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800aba:	0f b6 02             	movzbl (%edx),%eax
  800abd:	3c 20                	cmp    $0x20,%al
  800abf:	74 f6                	je     800ab7 <strtol+0xe>
  800ac1:	3c 09                	cmp    $0x9,%al
  800ac3:	74 f2                	je     800ab7 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800ac5:	3c 2b                	cmp    $0x2b,%al
  800ac7:	74 2a                	je     800af3 <strtol+0x4a>
	int neg = 0;
  800ac9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800ace:	3c 2d                	cmp    $0x2d,%al
  800ad0:	74 2b                	je     800afd <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ad2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ad8:	75 0f                	jne    800ae9 <strtol+0x40>
  800ada:	80 3a 30             	cmpb   $0x30,(%edx)
  800add:	74 28                	je     800b07 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800adf:	85 db                	test   %ebx,%ebx
  800ae1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ae6:	0f 44 d8             	cmove  %eax,%ebx
  800ae9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aee:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800af1:	eb 46                	jmp    800b39 <strtol+0x90>
		s++;
  800af3:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800af6:	bf 00 00 00 00       	mov    $0x0,%edi
  800afb:	eb d5                	jmp    800ad2 <strtol+0x29>
		s++, neg = 1;
  800afd:	83 c2 01             	add    $0x1,%edx
  800b00:	bf 01 00 00 00       	mov    $0x1,%edi
  800b05:	eb cb                	jmp    800ad2 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b07:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b0b:	74 0e                	je     800b1b <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800b0d:	85 db                	test   %ebx,%ebx
  800b0f:	75 d8                	jne    800ae9 <strtol+0x40>
		s++, base = 8;
  800b11:	83 c2 01             	add    $0x1,%edx
  800b14:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b19:	eb ce                	jmp    800ae9 <strtol+0x40>
		s += 2, base = 16;
  800b1b:	83 c2 02             	add    $0x2,%edx
  800b1e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b23:	eb c4                	jmp    800ae9 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b25:	0f be c0             	movsbl %al,%eax
  800b28:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b2b:	3b 45 10             	cmp    0x10(%ebp),%eax
  800b2e:	7d 3a                	jge    800b6a <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800b30:	83 c2 01             	add    $0x1,%edx
  800b33:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800b37:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800b39:	0f b6 02             	movzbl (%edx),%eax
  800b3c:	8d 70 d0             	lea    -0x30(%eax),%esi
  800b3f:	89 f3                	mov    %esi,%ebx
  800b41:	80 fb 09             	cmp    $0x9,%bl
  800b44:	76 df                	jbe    800b25 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800b46:	8d 70 9f             	lea    -0x61(%eax),%esi
  800b49:	89 f3                	mov    %esi,%ebx
  800b4b:	80 fb 19             	cmp    $0x19,%bl
  800b4e:	77 08                	ja     800b58 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800b50:	0f be c0             	movsbl %al,%eax
  800b53:	83 e8 57             	sub    $0x57,%eax
  800b56:	eb d3                	jmp    800b2b <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800b58:	8d 70 bf             	lea    -0x41(%eax),%esi
  800b5b:	89 f3                	mov    %esi,%ebx
  800b5d:	80 fb 19             	cmp    $0x19,%bl
  800b60:	77 08                	ja     800b6a <strtol+0xc1>
			dig = *s - 'A' + 10;
  800b62:	0f be c0             	movsbl %al,%eax
  800b65:	83 e8 37             	sub    $0x37,%eax
  800b68:	eb c1                	jmp    800b2b <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b6a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b6e:	74 05                	je     800b75 <strtol+0xcc>
		*endptr = (char *) s;
  800b70:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b73:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800b75:	89 c8                	mov    %ecx,%eax
  800b77:	f7 d8                	neg    %eax
  800b79:	85 ff                	test   %edi,%edi
  800b7b:	0f 45 c8             	cmovne %eax,%ecx
}
  800b7e:	89 c8                	mov    %ecx,%eax
  800b80:	5b                   	pop    %ebx
  800b81:	5e                   	pop    %esi
  800b82:	5f                   	pop    %edi
  800b83:	5d                   	pop    %ebp
  800b84:	c3                   	ret    

00800b85 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
  800b88:	57                   	push   %edi
  800b89:	56                   	push   %esi
  800b8a:	53                   	push   %ebx
  800b8b:	83 ec 1c             	sub    $0x1c,%esp
  800b8e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b91:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800b94:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile(
  800b96:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b99:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b9c:	8b 7d 10             	mov    0x10(%ebp),%edi
  800b9f:	8b 75 14             	mov    0x14(%ebp),%esi
  800ba2:	cd 30                	int    $0x30
	        "int %1\n"
	        : "=a"(ret)
	        : "i"(T_SYSCALL), "a"(num), "d"(a1), "c"(a2), "b"(a3), "D"(a4), "S"(a5)
	        : "cc", "memory");

	if (check && ret > 0)
  800ba4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ba8:	74 04                	je     800bae <syscall+0x29>
  800baa:	85 c0                	test   %eax,%eax
  800bac:	7f 08                	jg     800bb6 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800bae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb1:	5b                   	pop    %ebx
  800bb2:	5e                   	pop    %esi
  800bb3:	5f                   	pop    %edi
  800bb4:	5d                   	pop    %ebp
  800bb5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb6:	83 ec 0c             	sub    $0xc,%esp
  800bb9:	50                   	push   %eax
  800bba:	ff 75 e0             	push   -0x20(%ebp)
  800bbd:	68 24 13 80 00       	push   $0x801324
  800bc2:	6a 1e                	push   $0x1e
  800bc4:	68 41 13 80 00       	push   $0x801341
  800bc9:	e8 5f f6 ff ff       	call   80022d <_panic>

00800bce <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800bce:	55                   	push   %ebp
  800bcf:	89 e5                	mov    %esp,%ebp
  800bd1:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t) s, len, 0, 0, 0);
  800bd4:	6a 00                	push   $0x0
  800bd6:	6a 00                	push   $0x0
  800bd8:	6a 00                	push   $0x0
  800bda:	ff 75 0c             	push   0xc(%ebp)
  800bdd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800be0:	ba 00 00 00 00       	mov    $0x0,%edx
  800be5:	b8 00 00 00 00       	mov    $0x0,%eax
  800bea:	e8 96 ff ff ff       	call   800b85 <syscall>
}
  800bef:	83 c4 10             	add    $0x10,%esp
  800bf2:	c9                   	leave  
  800bf3:	c3                   	ret    

00800bf4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bf4:	55                   	push   %ebp
  800bf5:	89 e5                	mov    %esp,%ebp
  800bf7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800bfa:	6a 00                	push   $0x0
  800bfc:	6a 00                	push   $0x0
  800bfe:	6a 00                	push   $0x0
  800c00:	6a 00                	push   $0x0
  800c02:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c07:	ba 00 00 00 00       	mov    $0x0,%edx
  800c0c:	b8 01 00 00 00       	mov    $0x1,%eax
  800c11:	e8 6f ff ff ff       	call   800b85 <syscall>
}
  800c16:	c9                   	leave  
  800c17:	c3                   	ret    

00800c18 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c18:	55                   	push   %ebp
  800c19:	89 e5                	mov    %esp,%ebp
  800c1b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800c1e:	6a 00                	push   $0x0
  800c20:	6a 00                	push   $0x0
  800c22:	6a 00                	push   $0x0
  800c24:	6a 00                	push   $0x0
  800c26:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c29:	ba 01 00 00 00       	mov    $0x1,%edx
  800c2e:	b8 03 00 00 00       	mov    $0x3,%eax
  800c33:	e8 4d ff ff ff       	call   800b85 <syscall>
}
  800c38:	c9                   	leave  
  800c39:	c3                   	ret    

00800c3a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c3a:	55                   	push   %ebp
  800c3b:	89 e5                	mov    %esp,%ebp
  800c3d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800c40:	6a 00                	push   $0x0
  800c42:	6a 00                	push   $0x0
  800c44:	6a 00                	push   $0x0
  800c46:	6a 00                	push   $0x0
  800c48:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c4d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c52:	b8 02 00 00 00       	mov    $0x2,%eax
  800c57:	e8 29 ff ff ff       	call   800b85 <syscall>
}
  800c5c:	c9                   	leave  
  800c5d:	c3                   	ret    

00800c5e <sys_yield>:

void
sys_yield(void)
{
  800c5e:	55                   	push   %ebp
  800c5f:	89 e5                	mov    %esp,%ebp
  800c61:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800c64:	6a 00                	push   $0x0
  800c66:	6a 00                	push   $0x0
  800c68:	6a 00                	push   $0x0
  800c6a:	6a 00                	push   $0x0
  800c6c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c71:	ba 00 00 00 00       	mov    $0x0,%edx
  800c76:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c7b:	e8 05 ff ff ff       	call   800b85 <syscall>
}
  800c80:	83 c4 10             	add    $0x10,%esp
  800c83:	c9                   	leave  
  800c84:	c3                   	ret    

00800c85 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c85:	55                   	push   %ebp
  800c86:	89 e5                	mov    %esp,%ebp
  800c88:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800c8b:	6a 00                	push   $0x0
  800c8d:	6a 00                	push   $0x0
  800c8f:	ff 75 10             	push   0x10(%ebp)
  800c92:	ff 75 0c             	push   0xc(%ebp)
  800c95:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c98:	ba 01 00 00 00       	mov    $0x1,%edx
  800c9d:	b8 04 00 00 00       	mov    $0x4,%eax
  800ca2:	e8 de fe ff ff       	call   800b85 <syscall>
}
  800ca7:	c9                   	leave  
  800ca8:	c3                   	ret    

00800ca9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ca9:	55                   	push   %ebp
  800caa:	89 e5                	mov    %esp,%ebp
  800cac:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map,
  800caf:	ff 75 18             	push   0x18(%ebp)
  800cb2:	ff 75 14             	push   0x14(%ebp)
  800cb5:	ff 75 10             	push   0x10(%ebp)
  800cb8:	ff 75 0c             	push   0xc(%ebp)
  800cbb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cbe:	ba 01 00 00 00       	mov    $0x1,%edx
  800cc3:	b8 05 00 00 00       	mov    $0x5,%eax
  800cc8:	e8 b8 fe ff ff       	call   800b85 <syscall>
	               srcenv,
	               (uint32_t) srcva,
	               dstenv,
	               (uint32_t) dstva,
	               perm);
}
  800ccd:	c9                   	leave  
  800cce:	c3                   	ret    

00800ccf <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ccf:	55                   	push   %ebp
  800cd0:	89 e5                	mov    %esp,%ebp
  800cd2:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800cd5:	6a 00                	push   $0x0
  800cd7:	6a 00                	push   $0x0
  800cd9:	6a 00                	push   $0x0
  800cdb:	ff 75 0c             	push   0xc(%ebp)
  800cde:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ce1:	ba 01 00 00 00       	mov    $0x1,%edx
  800ce6:	b8 06 00 00 00       	mov    $0x6,%eax
  800ceb:	e8 95 fe ff ff       	call   800b85 <syscall>
}
  800cf0:	c9                   	leave  
  800cf1:	c3                   	ret    

00800cf2 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cf2:	55                   	push   %ebp
  800cf3:	89 e5                	mov    %esp,%ebp
  800cf5:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800cf8:	6a 00                	push   $0x0
  800cfa:	6a 00                	push   $0x0
  800cfc:	6a 00                	push   $0x0
  800cfe:	ff 75 0c             	push   0xc(%ebp)
  800d01:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d04:	ba 01 00 00 00       	mov    $0x1,%edx
  800d09:	b8 08 00 00 00       	mov    $0x8,%eax
  800d0e:	e8 72 fe ff ff       	call   800b85 <syscall>
}
  800d13:	c9                   	leave  
  800d14:	c3                   	ret    

00800d15 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d15:	55                   	push   %ebp
  800d16:	89 e5                	mov    %esp,%ebp
  800d18:	83 ec 08             	sub    $0x8,%esp
	return syscall(
  800d1b:	6a 00                	push   $0x0
  800d1d:	6a 00                	push   $0x0
  800d1f:	6a 00                	push   $0x0
  800d21:	ff 75 0c             	push   0xc(%ebp)
  800d24:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d27:	ba 01 00 00 00       	mov    $0x1,%edx
  800d2c:	b8 09 00 00 00       	mov    $0x9,%eax
  800d31:	e8 4f fe ff ff       	call   800b85 <syscall>
	        SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d36:	c9                   	leave  
  800d37:	c3                   	ret    

00800d38 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d38:	55                   	push   %ebp
  800d39:	89 e5                	mov    %esp,%ebp
  800d3b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800d3e:	6a 00                	push   $0x0
  800d40:	ff 75 14             	push   0x14(%ebp)
  800d43:	ff 75 10             	push   0x10(%ebp)
  800d46:	ff 75 0c             	push   0xc(%ebp)
  800d49:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d4c:	ba 00 00 00 00       	mov    $0x0,%edx
  800d51:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d56:	e8 2a fe ff ff       	call   800b85 <syscall>
}
  800d5b:	c9                   	leave  
  800d5c:	c3                   	ret    

00800d5d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d5d:	55                   	push   %ebp
  800d5e:	89 e5                	mov    %esp,%ebp
  800d60:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t) dstva, 0, 0, 0, 0);
  800d63:	6a 00                	push   $0x0
  800d65:	6a 00                	push   $0x0
  800d67:	6a 00                	push   $0x0
  800d69:	6a 00                	push   $0x0
  800d6b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d6e:	ba 01 00 00 00       	mov    $0x1,%edx
  800d73:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d78:	e8 08 fe ff ff       	call   800b85 <syscall>
}
  800d7d:	c9                   	leave  
  800d7e:	c3                   	ret    

00800d7f <sys_get_priority>:

// Get priority of the current process
int
sys_get_priority(void)
{
  800d7f:	55                   	push   %ebp
  800d80:	89 e5                	mov    %esp,%ebp
  800d82:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_get_priority, 0, 0, 0, 0, 0, 0);
  800d85:	6a 00                	push   $0x0
  800d87:	6a 00                	push   $0x0
  800d89:	6a 00                	push   $0x0
  800d8b:	6a 00                	push   $0x0
  800d8d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d92:	ba 00 00 00 00       	mov    $0x0,%edx
  800d97:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d9c:	e8 e4 fd ff ff       	call   800b85 <syscall>
}
  800da1:	c9                   	leave  
  800da2:	c3                   	ret    

00800da3 <sys_set_priority>:

// Get priority of the current process
int
sys_set_priority(unsigned int priority)
{
  800da3:	55                   	push   %ebp
  800da4:	89 e5                	mov    %esp,%ebp
  800da6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, (uint32_t) priority, 0, 0, 0, 0);
  800da9:	6a 00                	push   $0x0
  800dab:	6a 00                	push   $0x0
  800dad:	6a 00                	push   $0x0
  800daf:	6a 00                	push   $0x0
  800db1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800db4:	ba 00 00 00 00       	mov    $0x0,%edx
  800db9:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dbe:	e8 c2 fd ff ff       	call   800b85 <syscall>
}
  800dc3:	c9                   	leave  
  800dc4:	c3                   	ret    
  800dc5:	66 90                	xchg   %ax,%ax
  800dc7:	66 90                	xchg   %ax,%ax
  800dc9:	66 90                	xchg   %ax,%ax
  800dcb:	66 90                	xchg   %ax,%ax
  800dcd:	66 90                	xchg   %ax,%ax
  800dcf:	90                   	nop

00800dd0 <__udivdi3>:
  800dd0:	f3 0f 1e fb          	endbr32 
  800dd4:	55                   	push   %ebp
  800dd5:	57                   	push   %edi
  800dd6:	56                   	push   %esi
  800dd7:	53                   	push   %ebx
  800dd8:	83 ec 1c             	sub    $0x1c,%esp
  800ddb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800ddf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800de3:	8b 74 24 34          	mov    0x34(%esp),%esi
  800de7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800deb:	85 c0                	test   %eax,%eax
  800ded:	75 19                	jne    800e08 <__udivdi3+0x38>
  800def:	39 f3                	cmp    %esi,%ebx
  800df1:	76 4d                	jbe    800e40 <__udivdi3+0x70>
  800df3:	31 ff                	xor    %edi,%edi
  800df5:	89 e8                	mov    %ebp,%eax
  800df7:	89 f2                	mov    %esi,%edx
  800df9:	f7 f3                	div    %ebx
  800dfb:	89 fa                	mov    %edi,%edx
  800dfd:	83 c4 1c             	add    $0x1c,%esp
  800e00:	5b                   	pop    %ebx
  800e01:	5e                   	pop    %esi
  800e02:	5f                   	pop    %edi
  800e03:	5d                   	pop    %ebp
  800e04:	c3                   	ret    
  800e05:	8d 76 00             	lea    0x0(%esi),%esi
  800e08:	39 f0                	cmp    %esi,%eax
  800e0a:	76 14                	jbe    800e20 <__udivdi3+0x50>
  800e0c:	31 ff                	xor    %edi,%edi
  800e0e:	31 c0                	xor    %eax,%eax
  800e10:	89 fa                	mov    %edi,%edx
  800e12:	83 c4 1c             	add    $0x1c,%esp
  800e15:	5b                   	pop    %ebx
  800e16:	5e                   	pop    %esi
  800e17:	5f                   	pop    %edi
  800e18:	5d                   	pop    %ebp
  800e19:	c3                   	ret    
  800e1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e20:	0f bd f8             	bsr    %eax,%edi
  800e23:	83 f7 1f             	xor    $0x1f,%edi
  800e26:	75 48                	jne    800e70 <__udivdi3+0xa0>
  800e28:	39 f0                	cmp    %esi,%eax
  800e2a:	72 06                	jb     800e32 <__udivdi3+0x62>
  800e2c:	31 c0                	xor    %eax,%eax
  800e2e:	39 eb                	cmp    %ebp,%ebx
  800e30:	77 de                	ja     800e10 <__udivdi3+0x40>
  800e32:	b8 01 00 00 00       	mov    $0x1,%eax
  800e37:	eb d7                	jmp    800e10 <__udivdi3+0x40>
  800e39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e40:	89 d9                	mov    %ebx,%ecx
  800e42:	85 db                	test   %ebx,%ebx
  800e44:	75 0b                	jne    800e51 <__udivdi3+0x81>
  800e46:	b8 01 00 00 00       	mov    $0x1,%eax
  800e4b:	31 d2                	xor    %edx,%edx
  800e4d:	f7 f3                	div    %ebx
  800e4f:	89 c1                	mov    %eax,%ecx
  800e51:	31 d2                	xor    %edx,%edx
  800e53:	89 f0                	mov    %esi,%eax
  800e55:	f7 f1                	div    %ecx
  800e57:	89 c6                	mov    %eax,%esi
  800e59:	89 e8                	mov    %ebp,%eax
  800e5b:	89 f7                	mov    %esi,%edi
  800e5d:	f7 f1                	div    %ecx
  800e5f:	89 fa                	mov    %edi,%edx
  800e61:	83 c4 1c             	add    $0x1c,%esp
  800e64:	5b                   	pop    %ebx
  800e65:	5e                   	pop    %esi
  800e66:	5f                   	pop    %edi
  800e67:	5d                   	pop    %ebp
  800e68:	c3                   	ret    
  800e69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e70:	89 f9                	mov    %edi,%ecx
  800e72:	ba 20 00 00 00       	mov    $0x20,%edx
  800e77:	29 fa                	sub    %edi,%edx
  800e79:	d3 e0                	shl    %cl,%eax
  800e7b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e7f:	89 d1                	mov    %edx,%ecx
  800e81:	89 d8                	mov    %ebx,%eax
  800e83:	d3 e8                	shr    %cl,%eax
  800e85:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800e89:	09 c1                	or     %eax,%ecx
  800e8b:	89 f0                	mov    %esi,%eax
  800e8d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e91:	89 f9                	mov    %edi,%ecx
  800e93:	d3 e3                	shl    %cl,%ebx
  800e95:	89 d1                	mov    %edx,%ecx
  800e97:	d3 e8                	shr    %cl,%eax
  800e99:	89 f9                	mov    %edi,%ecx
  800e9b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800e9f:	89 eb                	mov    %ebp,%ebx
  800ea1:	d3 e6                	shl    %cl,%esi
  800ea3:	89 d1                	mov    %edx,%ecx
  800ea5:	d3 eb                	shr    %cl,%ebx
  800ea7:	09 f3                	or     %esi,%ebx
  800ea9:	89 c6                	mov    %eax,%esi
  800eab:	89 f2                	mov    %esi,%edx
  800ead:	89 d8                	mov    %ebx,%eax
  800eaf:	f7 74 24 08          	divl   0x8(%esp)
  800eb3:	89 d6                	mov    %edx,%esi
  800eb5:	89 c3                	mov    %eax,%ebx
  800eb7:	f7 64 24 0c          	mull   0xc(%esp)
  800ebb:	39 d6                	cmp    %edx,%esi
  800ebd:	72 19                	jb     800ed8 <__udivdi3+0x108>
  800ebf:	89 f9                	mov    %edi,%ecx
  800ec1:	d3 e5                	shl    %cl,%ebp
  800ec3:	39 c5                	cmp    %eax,%ebp
  800ec5:	73 04                	jae    800ecb <__udivdi3+0xfb>
  800ec7:	39 d6                	cmp    %edx,%esi
  800ec9:	74 0d                	je     800ed8 <__udivdi3+0x108>
  800ecb:	89 d8                	mov    %ebx,%eax
  800ecd:	31 ff                	xor    %edi,%edi
  800ecf:	e9 3c ff ff ff       	jmp    800e10 <__udivdi3+0x40>
  800ed4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ed8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800edb:	31 ff                	xor    %edi,%edi
  800edd:	e9 2e ff ff ff       	jmp    800e10 <__udivdi3+0x40>
  800ee2:	66 90                	xchg   %ax,%ax
  800ee4:	66 90                	xchg   %ax,%ax
  800ee6:	66 90                	xchg   %ax,%ax
  800ee8:	66 90                	xchg   %ax,%ax
  800eea:	66 90                	xchg   %ax,%ax
  800eec:	66 90                	xchg   %ax,%ax
  800eee:	66 90                	xchg   %ax,%ax

00800ef0 <__umoddi3>:
  800ef0:	f3 0f 1e fb          	endbr32 
  800ef4:	55                   	push   %ebp
  800ef5:	57                   	push   %edi
  800ef6:	56                   	push   %esi
  800ef7:	53                   	push   %ebx
  800ef8:	83 ec 1c             	sub    $0x1c,%esp
  800efb:	8b 74 24 30          	mov    0x30(%esp),%esi
  800eff:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800f03:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  800f07:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  800f0b:	89 f0                	mov    %esi,%eax
  800f0d:	89 da                	mov    %ebx,%edx
  800f0f:	85 ff                	test   %edi,%edi
  800f11:	75 15                	jne    800f28 <__umoddi3+0x38>
  800f13:	39 dd                	cmp    %ebx,%ebp
  800f15:	76 39                	jbe    800f50 <__umoddi3+0x60>
  800f17:	f7 f5                	div    %ebp
  800f19:	89 d0                	mov    %edx,%eax
  800f1b:	31 d2                	xor    %edx,%edx
  800f1d:	83 c4 1c             	add    $0x1c,%esp
  800f20:	5b                   	pop    %ebx
  800f21:	5e                   	pop    %esi
  800f22:	5f                   	pop    %edi
  800f23:	5d                   	pop    %ebp
  800f24:	c3                   	ret    
  800f25:	8d 76 00             	lea    0x0(%esi),%esi
  800f28:	39 df                	cmp    %ebx,%edi
  800f2a:	77 f1                	ja     800f1d <__umoddi3+0x2d>
  800f2c:	0f bd cf             	bsr    %edi,%ecx
  800f2f:	83 f1 1f             	xor    $0x1f,%ecx
  800f32:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800f36:	75 40                	jne    800f78 <__umoddi3+0x88>
  800f38:	39 df                	cmp    %ebx,%edi
  800f3a:	72 04                	jb     800f40 <__umoddi3+0x50>
  800f3c:	39 f5                	cmp    %esi,%ebp
  800f3e:	77 dd                	ja     800f1d <__umoddi3+0x2d>
  800f40:	89 da                	mov    %ebx,%edx
  800f42:	89 f0                	mov    %esi,%eax
  800f44:	29 e8                	sub    %ebp,%eax
  800f46:	19 fa                	sbb    %edi,%edx
  800f48:	eb d3                	jmp    800f1d <__umoddi3+0x2d>
  800f4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f50:	89 e9                	mov    %ebp,%ecx
  800f52:	85 ed                	test   %ebp,%ebp
  800f54:	75 0b                	jne    800f61 <__umoddi3+0x71>
  800f56:	b8 01 00 00 00       	mov    $0x1,%eax
  800f5b:	31 d2                	xor    %edx,%edx
  800f5d:	f7 f5                	div    %ebp
  800f5f:	89 c1                	mov    %eax,%ecx
  800f61:	89 d8                	mov    %ebx,%eax
  800f63:	31 d2                	xor    %edx,%edx
  800f65:	f7 f1                	div    %ecx
  800f67:	89 f0                	mov    %esi,%eax
  800f69:	f7 f1                	div    %ecx
  800f6b:	89 d0                	mov    %edx,%eax
  800f6d:	31 d2                	xor    %edx,%edx
  800f6f:	eb ac                	jmp    800f1d <__umoddi3+0x2d>
  800f71:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f78:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f7c:	ba 20 00 00 00       	mov    $0x20,%edx
  800f81:	29 c2                	sub    %eax,%edx
  800f83:	89 c1                	mov    %eax,%ecx
  800f85:	89 e8                	mov    %ebp,%eax
  800f87:	d3 e7                	shl    %cl,%edi
  800f89:	89 d1                	mov    %edx,%ecx
  800f8b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f8f:	d3 e8                	shr    %cl,%eax
  800f91:	89 c1                	mov    %eax,%ecx
  800f93:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f97:	09 f9                	or     %edi,%ecx
  800f99:	89 df                	mov    %ebx,%edi
  800f9b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f9f:	89 c1                	mov    %eax,%ecx
  800fa1:	d3 e5                	shl    %cl,%ebp
  800fa3:	89 d1                	mov    %edx,%ecx
  800fa5:	d3 ef                	shr    %cl,%edi
  800fa7:	89 c1                	mov    %eax,%ecx
  800fa9:	89 f0                	mov    %esi,%eax
  800fab:	d3 e3                	shl    %cl,%ebx
  800fad:	89 d1                	mov    %edx,%ecx
  800faf:	89 fa                	mov    %edi,%edx
  800fb1:	d3 e8                	shr    %cl,%eax
  800fb3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800fb8:	09 d8                	or     %ebx,%eax
  800fba:	f7 74 24 08          	divl   0x8(%esp)
  800fbe:	89 d3                	mov    %edx,%ebx
  800fc0:	d3 e6                	shl    %cl,%esi
  800fc2:	f7 e5                	mul    %ebp
  800fc4:	89 c7                	mov    %eax,%edi
  800fc6:	89 d1                	mov    %edx,%ecx
  800fc8:	39 d3                	cmp    %edx,%ebx
  800fca:	72 06                	jb     800fd2 <__umoddi3+0xe2>
  800fcc:	75 0e                	jne    800fdc <__umoddi3+0xec>
  800fce:	39 c6                	cmp    %eax,%esi
  800fd0:	73 0a                	jae    800fdc <__umoddi3+0xec>
  800fd2:	29 e8                	sub    %ebp,%eax
  800fd4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800fd8:	89 d1                	mov    %edx,%ecx
  800fda:	89 c7                	mov    %eax,%edi
  800fdc:	89 f5                	mov    %esi,%ebp
  800fde:	8b 74 24 04          	mov    0x4(%esp),%esi
  800fe2:	29 fd                	sub    %edi,%ebp
  800fe4:	19 cb                	sbb    %ecx,%ebx
  800fe6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800feb:	89 d8                	mov    %ebx,%eax
  800fed:	d3 e0                	shl    %cl,%eax
  800fef:	89 f1                	mov    %esi,%ecx
  800ff1:	d3 ed                	shr    %cl,%ebp
  800ff3:	d3 eb                	shr    %cl,%ebx
  800ff5:	09 e8                	or     %ebp,%eax
  800ff7:	89 da                	mov    %ebx,%edx
  800ff9:	83 c4 1c             	add    $0x1c,%esp
  800ffc:	5b                   	pop    %ebx
  800ffd:	5e                   	pop    %esi
  800ffe:	5f                   	pop    %edi
  800fff:	5d                   	pop    %ebp
  801000:	c3                   	ret    
