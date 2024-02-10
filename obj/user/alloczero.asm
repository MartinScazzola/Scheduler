
obj/user/alloczero:     formato del fichero elf32-i386


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
  80002c:	e8 03 01 00 00       	call   800134 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <write>:

#include <inc/lib.h>

void
write(uint16_t *addr, uint16_t value)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80003b:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;

	if ((r = sys_page_alloc(0, addr, PTE_P | PTE_U | PTE_W)) < 0)
  80003e:	83 ec 04             	sub    $0x4,%esp
  800041:	6a 07                	push   $0x7
  800043:	53                   	push   %ebx
  800044:	6a 00                	push   $0x0
  800046:	e8 a0 0b 00 00       	call   800beb <sys_page_alloc>
  80004b:	83 c4 10             	add    $0x10,%esp
  80004e:	85 c0                	test   %eax,%eax
  800050:	78 1c                	js     80006e <write+0x3b>
		panic("sys_page_alloc: %e", r);
	addr[0] = value;
  800052:	66 89 33             	mov    %si,(%ebx)
	if ((r = sys_page_unmap(0, addr)) < 0)
  800055:	83 ec 08             	sub    $0x8,%esp
  800058:	53                   	push   %ebx
  800059:	6a 00                	push   $0x0
  80005b:	e8 d5 0b 00 00       	call   800c35 <sys_page_unmap>
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	85 c0                	test   %eax,%eax
  800065:	78 19                	js     800080 <write+0x4d>
		panic("sys_page_unmap: %e", r);
}
  800067:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80006a:	5b                   	pop    %ebx
  80006b:	5e                   	pop    %esi
  80006c:	5d                   	pop    %ebp
  80006d:	c3                   	ret    
		panic("sys_page_alloc: %e", r);
  80006e:	50                   	push   %eax
  80006f:	68 80 0f 80 00       	push   $0x800f80
  800074:	6a 0b                	push   $0xb
  800076:	68 93 0f 80 00       	push   $0x800f93
  80007b:	e8 13 01 00 00       	call   800193 <_panic>
		panic("sys_page_unmap: %e", r);
  800080:	50                   	push   %eax
  800081:	68 a4 0f 80 00       	push   $0x800fa4
  800086:	6a 0e                	push   $0xe
  800088:	68 93 0f 80 00       	push   $0x800f93
  80008d:	e8 01 01 00 00       	call   800193 <_panic>

00800092 <check>:

void
check(uint16_t *addr)
{
  800092:	55                   	push   %ebp
  800093:	89 e5                	mov    %esp,%ebp
  800095:	53                   	push   %ebx
  800096:	83 ec 08             	sub    $0x8,%esp
  800099:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;

	if ((r = sys_page_alloc(0, addr, PTE_P | PTE_U)) < 0)
  80009c:	6a 05                	push   $0x5
  80009e:	53                   	push   %ebx
  80009f:	6a 00                	push   $0x0
  8000a1:	e8 45 0b 00 00       	call   800beb <sys_page_alloc>
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	85 c0                	test   %eax,%eax
  8000ab:	78 1d                	js     8000ca <check+0x38>
		panic("sys_page_alloc: %e", r);
	if (addr[0] != '\0')
  8000ad:	66 83 3b 00          	cmpw   $0x0,(%ebx)
  8000b1:	75 29                	jne    8000dc <check+0x4a>
		panic("The allocated memory is not initialized to zero");
	if ((r = sys_page_unmap(0, addr)) < 0)
  8000b3:	83 ec 08             	sub    $0x8,%esp
  8000b6:	53                   	push   %ebx
  8000b7:	6a 00                	push   $0x0
  8000b9:	e8 77 0b 00 00       	call   800c35 <sys_page_unmap>
  8000be:	83 c4 10             	add    $0x10,%esp
  8000c1:	85 c0                	test   %eax,%eax
  8000c3:	78 2b                	js     8000f0 <check+0x5e>
		panic("sys_page_unmap: %e", r);
}
  8000c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000c8:	c9                   	leave  
  8000c9:	c3                   	ret    
		panic("sys_page_alloc: %e", r);
  8000ca:	50                   	push   %eax
  8000cb:	68 80 0f 80 00       	push   $0x800f80
  8000d0:	6a 17                	push   $0x17
  8000d2:	68 93 0f 80 00       	push   $0x800f93
  8000d7:	e8 b7 00 00 00       	call   800193 <_panic>
		panic("The allocated memory is not initialized to zero");
  8000dc:	83 ec 04             	sub    $0x4,%esp
  8000df:	68 b8 0f 80 00       	push   $0x800fb8
  8000e4:	6a 19                	push   $0x19
  8000e6:	68 93 0f 80 00       	push   $0x800f93
  8000eb:	e8 a3 00 00 00       	call   800193 <_panic>
		panic("sys_page_unmap: %e", r);
  8000f0:	50                   	push   %eax
  8000f1:	68 a4 0f 80 00       	push   $0x800fa4
  8000f6:	6a 1b                	push   $0x1b
  8000f8:	68 93 0f 80 00       	push   $0x800f93
  8000fd:	e8 91 00 00 00       	call   800193 <_panic>

00800102 <umain>:

void
umain(int argc, char **argv)
{
  800102:	55                   	push   %ebp
  800103:	89 e5                	mov    %esp,%ebp
  800105:	83 ec 10             	sub    $0x10,%esp
	write(UTEMP, 0x7508);
  800108:	68 08 75 00 00       	push   $0x7508
  80010d:	68 00 00 40 00       	push   $0x400000
  800112:	e8 1c ff ff ff       	call   800033 <write>
	check(UTEMP);
  800117:	c7 04 24 00 00 40 00 	movl   $0x400000,(%esp)
  80011e:	e8 6f ff ff ff       	call   800092 <check>
	cprintf("The allocated memory is initialized to zero\n");
  800123:	c7 04 24 e8 0f 80 00 	movl   $0x800fe8,(%esp)
  80012a:	e8 3f 01 00 00       	call   80026e <cprintf>
}
  80012f:	83 c4 10             	add    $0x10,%esp
  800132:	c9                   	leave  
  800133:	c3                   	ret    

00800134 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	56                   	push   %esi
  800138:	53                   	push   %ebx
  800139:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80013c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	envid_t id = sys_getenvid();
  80013f:	e8 5c 0a 00 00       	call   800ba0 <sys_getenvid>
	if (id >= 0)
  800144:	85 c0                	test   %eax,%eax
  800146:	78 15                	js     80015d <libmain+0x29>
		thisenv = &envs[ENVX(id)];
  800148:	25 ff 03 00 00       	and    $0x3ff,%eax
  80014d:	69 c0 88 00 00 00    	imul   $0x88,%eax,%eax
  800153:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800158:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80015d:	85 db                	test   %ebx,%ebx
  80015f:	7e 07                	jle    800168 <libmain+0x34>
		binaryname = argv[0];
  800161:	8b 06                	mov    (%esi),%eax
  800163:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800168:	83 ec 08             	sub    $0x8,%esp
  80016b:	56                   	push   %esi
  80016c:	53                   	push   %ebx
  80016d:	e8 90 ff ff ff       	call   800102 <umain>

	// exit gracefully
	exit();
  800172:	e8 0a 00 00 00       	call   800181 <exit>
}
  800177:	83 c4 10             	add    $0x10,%esp
  80017a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80017d:	5b                   	pop    %ebx
  80017e:	5e                   	pop    %esi
  80017f:	5d                   	pop    %ebp
  800180:	c3                   	ret    

00800181 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800181:	55                   	push   %ebp
  800182:	89 e5                	mov    %esp,%ebp
  800184:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800187:	6a 00                	push   $0x0
  800189:	e8 f0 09 00 00       	call   800b7e <sys_env_destroy>
}
  80018e:	83 c4 10             	add    $0x10,%esp
  800191:	c9                   	leave  
  800192:	c3                   	ret    

00800193 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800193:	55                   	push   %ebp
  800194:	89 e5                	mov    %esp,%ebp
  800196:	56                   	push   %esi
  800197:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800198:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80019b:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8001a1:	e8 fa 09 00 00       	call   800ba0 <sys_getenvid>
  8001a6:	83 ec 0c             	sub    $0xc,%esp
  8001a9:	ff 75 0c             	push   0xc(%ebp)
  8001ac:	ff 75 08             	push   0x8(%ebp)
  8001af:	56                   	push   %esi
  8001b0:	50                   	push   %eax
  8001b1:	68 20 10 80 00       	push   $0x801020
  8001b6:	e8 b3 00 00 00       	call   80026e <cprintf>
	        sys_getenvid(),
	        binaryname,
	        file,
	        line);
	vcprintf(fmt, ap);
  8001bb:	83 c4 18             	add    $0x18,%esp
  8001be:	53                   	push   %ebx
  8001bf:	ff 75 10             	push   0x10(%ebp)
  8001c2:	e8 56 00 00 00       	call   80021d <vcprintf>
	cprintf("\n");
  8001c7:	c7 04 24 43 10 80 00 	movl   $0x801043,(%esp)
  8001ce:	e8 9b 00 00 00       	call   80026e <cprintf>
  8001d3:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001d6:	cc                   	int3   
  8001d7:	eb fd                	jmp    8001d6 <_panic+0x43>

008001d9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d9:	55                   	push   %ebp
  8001da:	89 e5                	mov    %esp,%ebp
  8001dc:	53                   	push   %ebx
  8001dd:	83 ec 04             	sub    $0x4,%esp
  8001e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001e3:	8b 13                	mov    (%ebx),%edx
  8001e5:	8d 42 01             	lea    0x1(%edx),%eax
  8001e8:	89 03                	mov    %eax,(%ebx)
  8001ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ed:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256 - 1) {
  8001f1:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f6:	74 09                	je     800201 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001f8:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001ff:	c9                   	leave  
  800200:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800201:	83 ec 08             	sub    $0x8,%esp
  800204:	68 ff 00 00 00       	push   $0xff
  800209:	8d 43 08             	lea    0x8(%ebx),%eax
  80020c:	50                   	push   %eax
  80020d:	e8 22 09 00 00       	call   800b34 <sys_cputs>
		b->idx = 0;
  800212:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800218:	83 c4 10             	add    $0x10,%esp
  80021b:	eb db                	jmp    8001f8 <putch+0x1f>

0080021d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80021d:	55                   	push   %ebp
  80021e:	89 e5                	mov    %esp,%ebp
  800220:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800226:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80022d:	00 00 00 
	b.cnt = 0;
  800230:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800237:	00 00 00 
	vprintfmt((void *) putch, &b, fmt, ap);
  80023a:	ff 75 0c             	push   0xc(%ebp)
  80023d:	ff 75 08             	push   0x8(%ebp)
  800240:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800246:	50                   	push   %eax
  800247:	68 d9 01 80 00       	push   $0x8001d9
  80024c:	e8 74 01 00 00       	call   8003c5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800251:	83 c4 08             	add    $0x8,%esp
  800254:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  80025a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800260:	50                   	push   %eax
  800261:	e8 ce 08 00 00       	call   800b34 <sys_cputs>

	return b.cnt;
}
  800266:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80026c:	c9                   	leave  
  80026d:	c3                   	ret    

0080026e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80026e:	55                   	push   %ebp
  80026f:	89 e5                	mov    %esp,%ebp
  800271:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800274:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800277:	50                   	push   %eax
  800278:	ff 75 08             	push   0x8(%ebp)
  80027b:	e8 9d ff ff ff       	call   80021d <vcprintf>
	va_end(ap);

	return cnt;
}
  800280:	c9                   	leave  
  800281:	c3                   	ret    

00800282 <printnum>:
         void *putdat,
         unsigned long long num,
         unsigned base,
         int width,
         int padc)
{
  800282:	55                   	push   %ebp
  800283:	89 e5                	mov    %esp,%ebp
  800285:	57                   	push   %edi
  800286:	56                   	push   %esi
  800287:	53                   	push   %ebx
  800288:	83 ec 1c             	sub    $0x1c,%esp
  80028b:	89 c7                	mov    %eax,%edi
  80028d:	89 d6                	mov    %edx,%esi
  80028f:	8b 45 08             	mov    0x8(%ebp),%eax
  800292:	8b 55 0c             	mov    0xc(%ebp),%edx
  800295:	89 d1                	mov    %edx,%ecx
  800297:	89 c2                	mov    %eax,%edx
  800299:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80029c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80029f:	8b 45 10             	mov    0x10(%ebp),%eax
  8002a2:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002a5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002a8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002af:	39 c2                	cmp    %eax,%edx
  8002b1:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8002b4:	72 3e                	jb     8002f4 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b6:	83 ec 0c             	sub    $0xc,%esp
  8002b9:	ff 75 18             	push   0x18(%ebp)
  8002bc:	83 eb 01             	sub    $0x1,%ebx
  8002bf:	53                   	push   %ebx
  8002c0:	50                   	push   %eax
  8002c1:	83 ec 08             	sub    $0x8,%esp
  8002c4:	ff 75 e4             	push   -0x1c(%ebp)
  8002c7:	ff 75 e0             	push   -0x20(%ebp)
  8002ca:	ff 75 dc             	push   -0x24(%ebp)
  8002cd:	ff 75 d8             	push   -0x28(%ebp)
  8002d0:	e8 5b 0a 00 00       	call   800d30 <__udivdi3>
  8002d5:	83 c4 18             	add    $0x18,%esp
  8002d8:	52                   	push   %edx
  8002d9:	50                   	push   %eax
  8002da:	89 f2                	mov    %esi,%edx
  8002dc:	89 f8                	mov    %edi,%eax
  8002de:	e8 9f ff ff ff       	call   800282 <printnum>
  8002e3:	83 c4 20             	add    $0x20,%esp
  8002e6:	eb 13                	jmp    8002fb <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002e8:	83 ec 08             	sub    $0x8,%esp
  8002eb:	56                   	push   %esi
  8002ec:	ff 75 18             	push   0x18(%ebp)
  8002ef:	ff d7                	call   *%edi
  8002f1:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002f4:	83 eb 01             	sub    $0x1,%ebx
  8002f7:	85 db                	test   %ebx,%ebx
  8002f9:	7f ed                	jg     8002e8 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002fb:	83 ec 08             	sub    $0x8,%esp
  8002fe:	56                   	push   %esi
  8002ff:	83 ec 04             	sub    $0x4,%esp
  800302:	ff 75 e4             	push   -0x1c(%ebp)
  800305:	ff 75 e0             	push   -0x20(%ebp)
  800308:	ff 75 dc             	push   -0x24(%ebp)
  80030b:	ff 75 d8             	push   -0x28(%ebp)
  80030e:	e8 3d 0b 00 00       	call   800e50 <__umoddi3>
  800313:	83 c4 14             	add    $0x14,%esp
  800316:	0f be 80 45 10 80 00 	movsbl 0x801045(%eax),%eax
  80031d:	50                   	push   %eax
  80031e:	ff d7                	call   *%edi
}
  800320:	83 c4 10             	add    $0x10,%esp
  800323:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800326:	5b                   	pop    %ebx
  800327:	5e                   	pop    %esi
  800328:	5f                   	pop    %edi
  800329:	5d                   	pop    %ebp
  80032a:	c3                   	ret    

0080032b <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80032b:	83 fa 01             	cmp    $0x1,%edx
  80032e:	7f 13                	jg     800343 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800330:	85 d2                	test   %edx,%edx
  800332:	74 1c                	je     800350 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  800334:	8b 10                	mov    (%eax),%edx
  800336:	8d 4a 04             	lea    0x4(%edx),%ecx
  800339:	89 08                	mov    %ecx,(%eax)
  80033b:	8b 02                	mov    (%edx),%eax
  80033d:	ba 00 00 00 00       	mov    $0x0,%edx
  800342:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  800343:	8b 10                	mov    (%eax),%edx
  800345:	8d 4a 08             	lea    0x8(%edx),%ecx
  800348:	89 08                	mov    %ecx,(%eax)
  80034a:	8b 02                	mov    (%edx),%eax
  80034c:	8b 52 04             	mov    0x4(%edx),%edx
  80034f:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  800350:	8b 10                	mov    (%eax),%edx
  800352:	8d 4a 04             	lea    0x4(%edx),%ecx
  800355:	89 08                	mov    %ecx,(%eax)
  800357:	8b 02                	mov    (%edx),%eax
  800359:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80035e:	c3                   	ret    

0080035f <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80035f:	83 fa 01             	cmp    $0x1,%edx
  800362:	7f 0f                	jg     800373 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  800364:	85 d2                	test   %edx,%edx
  800366:	74 18                	je     800380 <getint+0x21>
		return va_arg(*ap, long);
  800368:	8b 10                	mov    (%eax),%edx
  80036a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80036d:	89 08                	mov    %ecx,(%eax)
  80036f:	8b 02                	mov    (%edx),%eax
  800371:	99                   	cltd   
  800372:	c3                   	ret    
		return va_arg(*ap, long long);
  800373:	8b 10                	mov    (%eax),%edx
  800375:	8d 4a 08             	lea    0x8(%edx),%ecx
  800378:	89 08                	mov    %ecx,(%eax)
  80037a:	8b 02                	mov    (%edx),%eax
  80037c:	8b 52 04             	mov    0x4(%edx),%edx
  80037f:	c3                   	ret    
	else
		return va_arg(*ap, int);
  800380:	8b 10                	mov    (%eax),%edx
  800382:	8d 4a 04             	lea    0x4(%edx),%ecx
  800385:	89 08                	mov    %ecx,(%eax)
  800387:	8b 02                	mov    (%edx),%eax
  800389:	99                   	cltd   
}
  80038a:	c3                   	ret    

0080038b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80038b:	55                   	push   %ebp
  80038c:	89 e5                	mov    %esp,%ebp
  80038e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800391:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800395:	8b 10                	mov    (%eax),%edx
  800397:	3b 50 04             	cmp    0x4(%eax),%edx
  80039a:	73 0a                	jae    8003a6 <sprintputch+0x1b>
		*b->buf++ = ch;
  80039c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80039f:	89 08                	mov    %ecx,(%eax)
  8003a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a4:	88 02                	mov    %al,(%edx)
}
  8003a6:	5d                   	pop    %ebp
  8003a7:	c3                   	ret    

008003a8 <printfmt>:
{
  8003a8:	55                   	push   %ebp
  8003a9:	89 e5                	mov    %esp,%ebp
  8003ab:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8003ae:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003b1:	50                   	push   %eax
  8003b2:	ff 75 10             	push   0x10(%ebp)
  8003b5:	ff 75 0c             	push   0xc(%ebp)
  8003b8:	ff 75 08             	push   0x8(%ebp)
  8003bb:	e8 05 00 00 00       	call   8003c5 <vprintfmt>
}
  8003c0:	83 c4 10             	add    $0x10,%esp
  8003c3:	c9                   	leave  
  8003c4:	c3                   	ret    

008003c5 <vprintfmt>:
{
  8003c5:	55                   	push   %ebp
  8003c6:	89 e5                	mov    %esp,%ebp
  8003c8:	57                   	push   %edi
  8003c9:	56                   	push   %esi
  8003ca:	53                   	push   %ebx
  8003cb:	83 ec 2c             	sub    $0x2c,%esp
  8003ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8003d1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003d4:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003d7:	eb 0a                	jmp    8003e3 <vprintfmt+0x1e>
			putch(ch, putdat);
  8003d9:	83 ec 08             	sub    $0x8,%esp
  8003dc:	56                   	push   %esi
  8003dd:	50                   	push   %eax
  8003de:	ff d3                	call   *%ebx
  8003e0:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003e3:	83 c7 01             	add    $0x1,%edi
  8003e6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003ea:	83 f8 25             	cmp    $0x25,%eax
  8003ed:	74 0c                	je     8003fb <vprintfmt+0x36>
			if (ch == '\0')
  8003ef:	85 c0                	test   %eax,%eax
  8003f1:	75 e6                	jne    8003d9 <vprintfmt+0x14>
}
  8003f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003f6:	5b                   	pop    %ebx
  8003f7:	5e                   	pop    %esi
  8003f8:	5f                   	pop    %edi
  8003f9:	5d                   	pop    %ebp
  8003fa:	c3                   	ret    
		padc = ' ';
  8003fb:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
		altflag = 0;
  8003ff:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800406:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80040d:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800414:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800419:	8d 47 01             	lea    0x1(%edi),%eax
  80041c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80041f:	0f b6 17             	movzbl (%edi),%edx
  800422:	8d 42 dd             	lea    -0x23(%edx),%eax
  800425:	3c 55                	cmp    $0x55,%al
  800427:	0f 87 b7 02 00 00    	ja     8006e4 <vprintfmt+0x31f>
  80042d:	0f b6 c0             	movzbl %al,%eax
  800430:	ff 24 85 00 11 80 00 	jmp    *0x801100(,%eax,4)
  800437:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80043a:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  80043e:	eb d9                	jmp    800419 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800440:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800443:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800447:	eb d0                	jmp    800419 <vprintfmt+0x54>
  800449:	0f b6 d2             	movzbl %dl,%edx
  80044c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0;; ++fmt) {
  80044f:	b8 00 00 00 00       	mov    $0x0,%eax
  800454:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800457:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80045a:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80045e:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800461:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800464:	83 f9 09             	cmp    $0x9,%ecx
  800467:	77 52                	ja     8004bb <vprintfmt+0xf6>
			for (precision = 0;; ++fmt) {
  800469:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80046c:	eb e9                	jmp    800457 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  80046e:	8b 45 14             	mov    0x14(%ebp),%eax
  800471:	8d 50 04             	lea    0x4(%eax),%edx
  800474:	89 55 14             	mov    %edx,0x14(%ebp)
  800477:	8b 00                	mov    (%eax),%eax
  800479:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80047c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80047f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800483:	79 94                	jns    800419 <vprintfmt+0x54>
				width = precision, precision = -1;
  800485:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800488:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80048b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800492:	eb 85                	jmp    800419 <vprintfmt+0x54>
  800494:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800497:	85 d2                	test   %edx,%edx
  800499:	b8 00 00 00 00       	mov    $0x0,%eax
  80049e:	0f 49 c2             	cmovns %edx,%eax
  8004a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8004a7:	e9 6d ff ff ff       	jmp    800419 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8004ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8004af:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8004b6:	e9 5e ff ff ff       	jmp    800419 <vprintfmt+0x54>
  8004bb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004be:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004c1:	eb bc                	jmp    80047f <vprintfmt+0xba>
			lflag++;
  8004c3:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8004c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8004c9:	e9 4b ff ff ff       	jmp    800419 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8004ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d1:	8d 50 04             	lea    0x4(%eax),%edx
  8004d4:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d7:	83 ec 08             	sub    $0x8,%esp
  8004da:	56                   	push   %esi
  8004db:	ff 30                	push   (%eax)
  8004dd:	ff d3                	call   *%ebx
			break;
  8004df:	83 c4 10             	add    $0x10,%esp
  8004e2:	e9 94 01 00 00       	jmp    80067b <vprintfmt+0x2b6>
			err = va_arg(ap, int);
  8004e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ea:	8d 50 04             	lea    0x4(%eax),%edx
  8004ed:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f0:	8b 10                	mov    (%eax),%edx
  8004f2:	89 d0                	mov    %edx,%eax
  8004f4:	f7 d8                	neg    %eax
  8004f6:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004f9:	83 f8 08             	cmp    $0x8,%eax
  8004fc:	7f 20                	jg     80051e <vprintfmt+0x159>
  8004fe:	8b 14 85 60 12 80 00 	mov    0x801260(,%eax,4),%edx
  800505:	85 d2                	test   %edx,%edx
  800507:	74 15                	je     80051e <vprintfmt+0x159>
				printfmt(putch, putdat, "%s", p);
  800509:	52                   	push   %edx
  80050a:	68 66 10 80 00       	push   $0x801066
  80050f:	56                   	push   %esi
  800510:	53                   	push   %ebx
  800511:	e8 92 fe ff ff       	call   8003a8 <printfmt>
  800516:	83 c4 10             	add    $0x10,%esp
  800519:	e9 5d 01 00 00       	jmp    80067b <vprintfmt+0x2b6>
				printfmt(putch, putdat, "error %d", err);
  80051e:	50                   	push   %eax
  80051f:	68 5d 10 80 00       	push   $0x80105d
  800524:	56                   	push   %esi
  800525:	53                   	push   %ebx
  800526:	e8 7d fe ff ff       	call   8003a8 <printfmt>
  80052b:	83 c4 10             	add    $0x10,%esp
  80052e:	e9 48 01 00 00       	jmp    80067b <vprintfmt+0x2b6>
			if ((p = va_arg(ap, char *)) == NULL)
  800533:	8b 45 14             	mov    0x14(%ebp),%eax
  800536:	8d 50 04             	lea    0x4(%eax),%edx
  800539:	89 55 14             	mov    %edx,0x14(%ebp)
  80053c:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80053e:	85 ff                	test   %edi,%edi
  800540:	b8 56 10 80 00       	mov    $0x801056,%eax
  800545:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800548:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80054c:	7e 06                	jle    800554 <vprintfmt+0x18f>
  80054e:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  800552:	75 0a                	jne    80055e <vprintfmt+0x199>
  800554:	89 f8                	mov    %edi,%eax
  800556:	03 45 e0             	add    -0x20(%ebp),%eax
  800559:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80055c:	eb 59                	jmp    8005b7 <vprintfmt+0x1f2>
				for (width -= strnlen(p, precision); width > 0;
  80055e:	83 ec 08             	sub    $0x8,%esp
  800561:	ff 75 d8             	push   -0x28(%ebp)
  800564:	57                   	push   %edi
  800565:	e8 1a 02 00 00       	call   800784 <strnlen>
  80056a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80056d:	29 c1                	sub    %eax,%ecx
  80056f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800572:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800575:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  800579:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80057c:	89 7d d0             	mov    %edi,-0x30(%ebp)
  80057f:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0;
  800581:	eb 0f                	jmp    800592 <vprintfmt+0x1cd>
					putch(padc, putdat);
  800583:	83 ec 08             	sub    $0x8,%esp
  800586:	56                   	push   %esi
  800587:	ff 75 e0             	push   -0x20(%ebp)
  80058a:	ff d3                	call   *%ebx
				     width--)
  80058c:	83 ef 01             	sub    $0x1,%edi
  80058f:	83 c4 10             	add    $0x10,%esp
				for (width -= strnlen(p, precision); width > 0;
  800592:	85 ff                	test   %edi,%edi
  800594:	7f ed                	jg     800583 <vprintfmt+0x1be>
  800596:	8b 7d d0             	mov    -0x30(%ebp),%edi
  800599:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80059c:	85 c9                	test   %ecx,%ecx
  80059e:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a3:	0f 49 c1             	cmovns %ecx,%eax
  8005a6:	29 c1                	sub    %eax,%ecx
  8005a8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8005ab:	eb a7                	jmp    800554 <vprintfmt+0x18f>
					putch(ch, putdat);
  8005ad:	83 ec 08             	sub    $0x8,%esp
  8005b0:	56                   	push   %esi
  8005b1:	52                   	push   %edx
  8005b2:	ff d3                	call   *%ebx
  8005b4:	83 c4 10             	add    $0x10,%esp
  8005b7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005ba:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' &&
  8005bc:	83 c7 01             	add    $0x1,%edi
  8005bf:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005c3:	0f be d0             	movsbl %al,%edx
  8005c6:	85 d2                	test   %edx,%edx
  8005c8:	74 42                	je     80060c <vprintfmt+0x247>
  8005ca:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005ce:	78 06                	js     8005d6 <vprintfmt+0x211>
			       (precision < 0 || --precision >= 0);
  8005d0:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8005d4:	78 1e                	js     8005f4 <vprintfmt+0x22f>
				if (altflag && (ch < ' ' || ch > '~'))
  8005d6:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005da:	74 d1                	je     8005ad <vprintfmt+0x1e8>
  8005dc:	0f be c0             	movsbl %al,%eax
  8005df:	83 e8 20             	sub    $0x20,%eax
  8005e2:	83 f8 5e             	cmp    $0x5e,%eax
  8005e5:	76 c6                	jbe    8005ad <vprintfmt+0x1e8>
					putch('?', putdat);
  8005e7:	83 ec 08             	sub    $0x8,%esp
  8005ea:	56                   	push   %esi
  8005eb:	6a 3f                	push   $0x3f
  8005ed:	ff d3                	call   *%ebx
  8005ef:	83 c4 10             	add    $0x10,%esp
  8005f2:	eb c3                	jmp    8005b7 <vprintfmt+0x1f2>
  8005f4:	89 cf                	mov    %ecx,%edi
  8005f6:	eb 0e                	jmp    800606 <vprintfmt+0x241>
				putch(' ', putdat);
  8005f8:	83 ec 08             	sub    $0x8,%esp
  8005fb:	56                   	push   %esi
  8005fc:	6a 20                	push   $0x20
  8005fe:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  800600:	83 ef 01             	sub    $0x1,%edi
  800603:	83 c4 10             	add    $0x10,%esp
  800606:	85 ff                	test   %edi,%edi
  800608:	7f ee                	jg     8005f8 <vprintfmt+0x233>
  80060a:	eb 6f                	jmp    80067b <vprintfmt+0x2b6>
  80060c:	89 cf                	mov    %ecx,%edi
  80060e:	eb f6                	jmp    800606 <vprintfmt+0x241>
			num = getint(&ap, lflag);
  800610:	89 ca                	mov    %ecx,%edx
  800612:	8d 45 14             	lea    0x14(%ebp),%eax
  800615:	e8 45 fd ff ff       	call   80035f <getint>
  80061a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80061d:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800620:	85 d2                	test   %edx,%edx
  800622:	78 0b                	js     80062f <vprintfmt+0x26a>
			num = getint(&ap, lflag);
  800624:	89 d1                	mov    %edx,%ecx
  800626:	89 c2                	mov    %eax,%edx
			base = 10;
  800628:	bf 0a 00 00 00       	mov    $0xa,%edi
  80062d:	eb 32                	jmp    800661 <vprintfmt+0x29c>
				putch('-', putdat);
  80062f:	83 ec 08             	sub    $0x8,%esp
  800632:	56                   	push   %esi
  800633:	6a 2d                	push   $0x2d
  800635:	ff d3                	call   *%ebx
				num = -(long long) num;
  800637:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80063a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80063d:	f7 da                	neg    %edx
  80063f:	83 d1 00             	adc    $0x0,%ecx
  800642:	f7 d9                	neg    %ecx
  800644:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800647:	bf 0a 00 00 00       	mov    $0xa,%edi
  80064c:	eb 13                	jmp    800661 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  80064e:	89 ca                	mov    %ecx,%edx
  800650:	8d 45 14             	lea    0x14(%ebp),%eax
  800653:	e8 d3 fc ff ff       	call   80032b <getuint>
  800658:	89 d1                	mov    %edx,%ecx
  80065a:	89 c2                	mov    %eax,%edx
			base = 10;
  80065c:	bf 0a 00 00 00       	mov    $0xa,%edi
			printnum(putch, putdat, num, base, width, padc);
  800661:	83 ec 0c             	sub    $0xc,%esp
  800664:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  800668:	50                   	push   %eax
  800669:	ff 75 e0             	push   -0x20(%ebp)
  80066c:	57                   	push   %edi
  80066d:	51                   	push   %ecx
  80066e:	52                   	push   %edx
  80066f:	89 f2                	mov    %esi,%edx
  800671:	89 d8                	mov    %ebx,%eax
  800673:	e8 0a fc ff ff       	call   800282 <printnum>
			break;
  800678:	83 c4 20             	add    $0x20,%esp
{
  80067b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80067e:	e9 60 fd ff ff       	jmp    8003e3 <vprintfmt+0x1e>
			num = getuint(&ap, lflag);
  800683:	89 ca                	mov    %ecx,%edx
  800685:	8d 45 14             	lea    0x14(%ebp),%eax
  800688:	e8 9e fc ff ff       	call   80032b <getuint>
  80068d:	89 d1                	mov    %edx,%ecx
  80068f:	89 c2                	mov    %eax,%edx
			base = 8;
  800691:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  800696:	eb c9                	jmp    800661 <vprintfmt+0x29c>
			putch('0', putdat);
  800698:	83 ec 08             	sub    $0x8,%esp
  80069b:	56                   	push   %esi
  80069c:	6a 30                	push   $0x30
  80069e:	ff d3                	call   *%ebx
			putch('x', putdat);
  8006a0:	83 c4 08             	add    $0x8,%esp
  8006a3:	56                   	push   %esi
  8006a4:	6a 78                	push   $0x78
  8006a6:	ff d3                	call   *%ebx
			num = (unsigned long long) (uintptr_t) va_arg(ap, void *);
  8006a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ab:	8d 50 04             	lea    0x4(%eax),%edx
  8006ae:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b1:	8b 10                	mov    (%eax),%edx
  8006b3:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006b8:	83 c4 10             	add    $0x10,%esp
			base = 16;
  8006bb:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  8006c0:	eb 9f                	jmp    800661 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  8006c2:	89 ca                	mov    %ecx,%edx
  8006c4:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c7:	e8 5f fc ff ff       	call   80032b <getuint>
  8006cc:	89 d1                	mov    %edx,%ecx
  8006ce:	89 c2                	mov    %eax,%edx
			base = 16;
  8006d0:	bf 10 00 00 00       	mov    $0x10,%edi
  8006d5:	eb 8a                	jmp    800661 <vprintfmt+0x29c>
			putch(ch, putdat);
  8006d7:	83 ec 08             	sub    $0x8,%esp
  8006da:	56                   	push   %esi
  8006db:	6a 25                	push   $0x25
  8006dd:	ff d3                	call   *%ebx
			break;
  8006df:	83 c4 10             	add    $0x10,%esp
  8006e2:	eb 97                	jmp    80067b <vprintfmt+0x2b6>
			putch('%', putdat);
  8006e4:	83 ec 08             	sub    $0x8,%esp
  8006e7:	56                   	push   %esi
  8006e8:	6a 25                	push   $0x25
  8006ea:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006ec:	83 c4 10             	add    $0x10,%esp
  8006ef:	89 f8                	mov    %edi,%eax
  8006f1:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006f5:	74 05                	je     8006fc <vprintfmt+0x337>
  8006f7:	83 e8 01             	sub    $0x1,%eax
  8006fa:	eb f5                	jmp    8006f1 <vprintfmt+0x32c>
  8006fc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006ff:	e9 77 ff ff ff       	jmp    80067b <vprintfmt+0x2b6>

00800704 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800704:	55                   	push   %ebp
  800705:	89 e5                	mov    %esp,%ebp
  800707:	83 ec 18             	sub    $0x18,%esp
  80070a:	8b 45 08             	mov    0x8(%ebp),%eax
  80070d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = { buf, buf + n - 1, 0 };
  800710:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800713:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800717:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80071a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800721:	85 c0                	test   %eax,%eax
  800723:	74 26                	je     80074b <vsnprintf+0x47>
  800725:	85 d2                	test   %edx,%edx
  800727:	7e 22                	jle    80074b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *) sprintputch, &b, fmt, ap);
  800729:	ff 75 14             	push   0x14(%ebp)
  80072c:	ff 75 10             	push   0x10(%ebp)
  80072f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800732:	50                   	push   %eax
  800733:	68 8b 03 80 00       	push   $0x80038b
  800738:	e8 88 fc ff ff       	call   8003c5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80073d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800740:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800743:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800746:	83 c4 10             	add    $0x10,%esp
}
  800749:	c9                   	leave  
  80074a:	c3                   	ret    
		return -E_INVAL;
  80074b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800750:	eb f7                	jmp    800749 <vsnprintf+0x45>

00800752 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800752:	55                   	push   %ebp
  800753:	89 e5                	mov    %esp,%ebp
  800755:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800758:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80075b:	50                   	push   %eax
  80075c:	ff 75 10             	push   0x10(%ebp)
  80075f:	ff 75 0c             	push   0xc(%ebp)
  800762:	ff 75 08             	push   0x8(%ebp)
  800765:	e8 9a ff ff ff       	call   800704 <vsnprintf>
	va_end(ap);

	return rc;
}
  80076a:	c9                   	leave  
  80076b:	c3                   	ret    

0080076c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80076c:	55                   	push   %ebp
  80076d:	89 e5                	mov    %esp,%ebp
  80076f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800772:	b8 00 00 00 00       	mov    $0x0,%eax
  800777:	eb 03                	jmp    80077c <strlen+0x10>
		n++;
  800779:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80077c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800780:	75 f7                	jne    800779 <strlen+0xd>
	return n;
}
  800782:	5d                   	pop    %ebp
  800783:	c3                   	ret    

00800784 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800784:	55                   	push   %ebp
  800785:	89 e5                	mov    %esp,%ebp
  800787:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80078a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80078d:	b8 00 00 00 00       	mov    $0x0,%eax
  800792:	eb 03                	jmp    800797 <strnlen+0x13>
		n++;
  800794:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800797:	39 d0                	cmp    %edx,%eax
  800799:	74 08                	je     8007a3 <strnlen+0x1f>
  80079b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80079f:	75 f3                	jne    800794 <strnlen+0x10>
  8007a1:	89 c2                	mov    %eax,%edx
	return n;
}
  8007a3:	89 d0                	mov    %edx,%eax
  8007a5:	5d                   	pop    %ebp
  8007a6:	c3                   	ret    

008007a7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007a7:	55                   	push   %ebp
  8007a8:	89 e5                	mov    %esp,%ebp
  8007aa:	53                   	push   %ebx
  8007ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b6:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007ba:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007bd:	83 c0 01             	add    $0x1,%eax
  8007c0:	84 d2                	test   %dl,%dl
  8007c2:	75 f2                	jne    8007b6 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007c4:	89 c8                	mov    %ecx,%eax
  8007c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007c9:	c9                   	leave  
  8007ca:	c3                   	ret    

008007cb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007cb:	55                   	push   %ebp
  8007cc:	89 e5                	mov    %esp,%ebp
  8007ce:	53                   	push   %ebx
  8007cf:	83 ec 10             	sub    $0x10,%esp
  8007d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007d5:	53                   	push   %ebx
  8007d6:	e8 91 ff ff ff       	call   80076c <strlen>
  8007db:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007de:	ff 75 0c             	push   0xc(%ebp)
  8007e1:	01 d8                	add    %ebx,%eax
  8007e3:	50                   	push   %eax
  8007e4:	e8 be ff ff ff       	call   8007a7 <strcpy>
	return dst;
}
  8007e9:	89 d8                	mov    %ebx,%eax
  8007eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007ee:	c9                   	leave  
  8007ef:	c3                   	ret    

008007f0 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	56                   	push   %esi
  8007f4:	53                   	push   %ebx
  8007f5:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007fb:	89 f3                	mov    %esi,%ebx
  8007fd:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800800:	89 f0                	mov    %esi,%eax
  800802:	eb 0f                	jmp    800813 <strncpy+0x23>
		*dst++ = *src;
  800804:	83 c0 01             	add    $0x1,%eax
  800807:	0f b6 0a             	movzbl (%edx),%ecx
  80080a:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80080d:	80 f9 01             	cmp    $0x1,%cl
  800810:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800813:	39 d8                	cmp    %ebx,%eax
  800815:	75 ed                	jne    800804 <strncpy+0x14>
	}
	return ret;
}
  800817:	89 f0                	mov    %esi,%eax
  800819:	5b                   	pop    %ebx
  80081a:	5e                   	pop    %esi
  80081b:	5d                   	pop    %ebp
  80081c:	c3                   	ret    

0080081d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80081d:	55                   	push   %ebp
  80081e:	89 e5                	mov    %esp,%ebp
  800820:	56                   	push   %esi
  800821:	53                   	push   %ebx
  800822:	8b 75 08             	mov    0x8(%ebp),%esi
  800825:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800828:	8b 55 10             	mov    0x10(%ebp),%edx
  80082b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80082d:	85 d2                	test   %edx,%edx
  80082f:	74 21                	je     800852 <strlcpy+0x35>
  800831:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800835:	89 f2                	mov    %esi,%edx
  800837:	eb 09                	jmp    800842 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800839:	83 c1 01             	add    $0x1,%ecx
  80083c:	83 c2 01             	add    $0x1,%edx
  80083f:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800842:	39 c2                	cmp    %eax,%edx
  800844:	74 09                	je     80084f <strlcpy+0x32>
  800846:	0f b6 19             	movzbl (%ecx),%ebx
  800849:	84 db                	test   %bl,%bl
  80084b:	75 ec                	jne    800839 <strlcpy+0x1c>
  80084d:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80084f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800852:	29 f0                	sub    %esi,%eax
}
  800854:	5b                   	pop    %ebx
  800855:	5e                   	pop    %esi
  800856:	5d                   	pop    %ebp
  800857:	c3                   	ret    

00800858 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800858:	55                   	push   %ebp
  800859:	89 e5                	mov    %esp,%ebp
  80085b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80085e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800861:	eb 06                	jmp    800869 <strcmp+0x11>
		p++, q++;
  800863:	83 c1 01             	add    $0x1,%ecx
  800866:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800869:	0f b6 01             	movzbl (%ecx),%eax
  80086c:	84 c0                	test   %al,%al
  80086e:	74 04                	je     800874 <strcmp+0x1c>
  800870:	3a 02                	cmp    (%edx),%al
  800872:	74 ef                	je     800863 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800874:	0f b6 c0             	movzbl %al,%eax
  800877:	0f b6 12             	movzbl (%edx),%edx
  80087a:	29 d0                	sub    %edx,%eax
}
  80087c:	5d                   	pop    %ebp
  80087d:	c3                   	ret    

0080087e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80087e:	55                   	push   %ebp
  80087f:	89 e5                	mov    %esp,%ebp
  800881:	53                   	push   %ebx
  800882:	8b 45 08             	mov    0x8(%ebp),%eax
  800885:	8b 55 0c             	mov    0xc(%ebp),%edx
  800888:	89 c3                	mov    %eax,%ebx
  80088a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80088d:	eb 06                	jmp    800895 <strncmp+0x17>
		n--, p++, q++;
  80088f:	83 c0 01             	add    $0x1,%eax
  800892:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800895:	39 d8                	cmp    %ebx,%eax
  800897:	74 18                	je     8008b1 <strncmp+0x33>
  800899:	0f b6 08             	movzbl (%eax),%ecx
  80089c:	84 c9                	test   %cl,%cl
  80089e:	74 04                	je     8008a4 <strncmp+0x26>
  8008a0:	3a 0a                	cmp    (%edx),%cl
  8008a2:	74 eb                	je     80088f <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a4:	0f b6 00             	movzbl (%eax),%eax
  8008a7:	0f b6 12             	movzbl (%edx),%edx
  8008aa:	29 d0                	sub    %edx,%eax
}
  8008ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008af:	c9                   	leave  
  8008b0:	c3                   	ret    
		return 0;
  8008b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b6:	eb f4                	jmp    8008ac <strncmp+0x2e>

008008b8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008be:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c2:	eb 03                	jmp    8008c7 <strchr+0xf>
  8008c4:	83 c0 01             	add    $0x1,%eax
  8008c7:	0f b6 10             	movzbl (%eax),%edx
  8008ca:	84 d2                	test   %dl,%dl
  8008cc:	74 06                	je     8008d4 <strchr+0x1c>
		if (*s == c)
  8008ce:	38 ca                	cmp    %cl,%dl
  8008d0:	75 f2                	jne    8008c4 <strchr+0xc>
  8008d2:	eb 05                	jmp    8008d9 <strchr+0x21>
			return (char *) s;
	return 0;
  8008d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008d9:	5d                   	pop    %ebp
  8008da:	c3                   	ret    

008008db <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e5:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008e8:	38 ca                	cmp    %cl,%dl
  8008ea:	74 09                	je     8008f5 <strfind+0x1a>
  8008ec:	84 d2                	test   %dl,%dl
  8008ee:	74 05                	je     8008f5 <strfind+0x1a>
	for (; *s; s++)
  8008f0:	83 c0 01             	add    $0x1,%eax
  8008f3:	eb f0                	jmp    8008e5 <strfind+0xa>
			break;
	return (char *) s;
}
  8008f5:	5d                   	pop    %ebp
  8008f6:	c3                   	ret    

008008f7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008f7:	55                   	push   %ebp
  8008f8:	89 e5                	mov    %esp,%ebp
  8008fa:	57                   	push   %edi
  8008fb:	56                   	push   %esi
  8008fc:	53                   	push   %ebx
  8008fd:	8b 55 08             	mov    0x8(%ebp),%edx
  800900:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  800903:	85 c9                	test   %ecx,%ecx
  800905:	74 33                	je     80093a <memset+0x43>
		return v;
	if ((int) v % 4 == 0 && n % 4 == 0) {
  800907:	89 d0                	mov    %edx,%eax
  800909:	09 c8                	or     %ecx,%eax
  80090b:	a8 03                	test   $0x3,%al
  80090d:	75 23                	jne    800932 <memset+0x3b>
		c &= 0xFF;
  80090f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  800913:	89 d8                	mov    %ebx,%eax
  800915:	c1 e0 08             	shl    $0x8,%eax
  800918:	89 df                	mov    %ebx,%edi
  80091a:	c1 e7 18             	shl    $0x18,%edi
  80091d:	89 de                	mov    %ebx,%esi
  80091f:	c1 e6 10             	shl    $0x10,%esi
  800922:	09 f7                	or     %esi,%edi
  800924:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
		             : "=D"(p), "=c"(n)
		             : "D"(p), "a"(c), "c"(n / 4)
  800926:	c1 e9 02             	shr    $0x2,%ecx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  800929:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  80092b:	89 d7                	mov    %edx,%edi
  80092d:	fc                   	cld    
  80092e:	f3 ab                	rep stos %eax,%es:(%edi)
  800930:	eb 08                	jmp    80093a <memset+0x43>
		             : "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800932:	89 d7                	mov    %edx,%edi
  800934:	8b 45 0c             	mov    0xc(%ebp),%eax
  800937:	fc                   	cld    
  800938:	f3 aa                	rep stos %al,%es:(%edi)
		             : "=D"(p), "=c"(n)
		             : "0"(p), "a"(c), "1"(n)
		             : "cc", "memory");
	return v;
}
  80093a:	89 d0                	mov    %edx,%eax
  80093c:	5b                   	pop    %ebx
  80093d:	5e                   	pop    %esi
  80093e:	5f                   	pop    %edi
  80093f:	5d                   	pop    %ebp
  800940:	c3                   	ret    

00800941 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800941:	55                   	push   %ebp
  800942:	89 e5                	mov    %esp,%ebp
  800944:	57                   	push   %edi
  800945:	56                   	push   %esi
  800946:	8b 45 08             	mov    0x8(%ebp),%eax
  800949:	8b 75 0c             	mov    0xc(%ebp),%esi
  80094c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80094f:	39 c6                	cmp    %eax,%esi
  800951:	73 32                	jae    800985 <memmove+0x44>
  800953:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800956:	39 c2                	cmp    %eax,%edx
  800958:	76 2b                	jbe    800985 <memmove+0x44>
		s += n;
		d += n;
  80095a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  80095d:	89 d6                	mov    %edx,%esi
  80095f:	09 fe                	or     %edi,%esi
  800961:	09 ce                	or     %ecx,%esi
  800963:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800969:	75 0e                	jne    800979 <memmove+0x38>
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  80096b:	83 ef 04             	sub    $0x4,%edi
			             "S"(s - 4),
  80096e:	8d 72 fc             	lea    -0x4(%edx),%esi
			             "c"(n / 4)
  800971:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  800974:	fd                   	std    
  800975:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800977:	eb 09                	jmp    800982 <memmove+0x41>
			             : "cc", "memory");
		else
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  800979:	83 ef 01             	sub    $0x1,%edi
			             "S"(s - 1),
  80097c:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  80097f:	fd                   	std    
  800980:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             "c"(n)
			             : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800982:	fc                   	cld    
  800983:	eb 1a                	jmp    80099f <memmove+0x5e>
	} else {
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  800985:	89 f2                	mov    %esi,%edx
  800987:	09 c2                	or     %eax,%edx
  800989:	09 ca                	or     %ecx,%edx
  80098b:	f6 c2 03             	test   $0x3,%dl
  80098e:	75 0a                	jne    80099a <memmove+0x59>
			asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800990:	c1 e9 02             	shr    $0x2,%ecx
  800993:	89 c7                	mov    %eax,%edi
  800995:	fc                   	cld    
  800996:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800998:	eb 05                	jmp    80099f <memmove+0x5e>
			             : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  80099a:	89 c7                	mov    %eax,%edi
  80099c:	fc                   	cld    
  80099d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             : "cc", "memory");
	}
	return dst;
}
  80099f:	5e                   	pop    %esi
  8009a0:	5f                   	pop    %edi
  8009a1:	5d                   	pop    %ebp
  8009a2:	c3                   	ret    

008009a3 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009a3:	55                   	push   %ebp
  8009a4:	89 e5                	mov    %esp,%ebp
  8009a6:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009a9:	ff 75 10             	push   0x10(%ebp)
  8009ac:	ff 75 0c             	push   0xc(%ebp)
  8009af:	ff 75 08             	push   0x8(%ebp)
  8009b2:	e8 8a ff ff ff       	call   800941 <memmove>
}
  8009b7:	c9                   	leave  
  8009b8:	c3                   	ret    

008009b9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009b9:	55                   	push   %ebp
  8009ba:	89 e5                	mov    %esp,%ebp
  8009bc:	56                   	push   %esi
  8009bd:	53                   	push   %ebx
  8009be:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c4:	89 c6                	mov    %eax,%esi
  8009c6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c9:	eb 06                	jmp    8009d1 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009cb:	83 c0 01             	add    $0x1,%eax
  8009ce:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  8009d1:	39 f0                	cmp    %esi,%eax
  8009d3:	74 14                	je     8009e9 <memcmp+0x30>
		if (*s1 != *s2)
  8009d5:	0f b6 08             	movzbl (%eax),%ecx
  8009d8:	0f b6 1a             	movzbl (%edx),%ebx
  8009db:	38 d9                	cmp    %bl,%cl
  8009dd:	74 ec                	je     8009cb <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  8009df:	0f b6 c1             	movzbl %cl,%eax
  8009e2:	0f b6 db             	movzbl %bl,%ebx
  8009e5:	29 d8                	sub    %ebx,%eax
  8009e7:	eb 05                	jmp    8009ee <memcmp+0x35>
	}

	return 0;
  8009e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ee:	5b                   	pop    %ebx
  8009ef:	5e                   	pop    %esi
  8009f0:	5d                   	pop    %ebp
  8009f1:	c3                   	ret    

008009f2 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009f2:	55                   	push   %ebp
  8009f3:	89 e5                	mov    %esp,%ebp
  8009f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009fb:	89 c2                	mov    %eax,%edx
  8009fd:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a00:	eb 03                	jmp    800a05 <memfind+0x13>
  800a02:	83 c0 01             	add    $0x1,%eax
  800a05:	39 d0                	cmp    %edx,%eax
  800a07:	73 04                	jae    800a0d <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a09:	38 08                	cmp    %cl,(%eax)
  800a0b:	75 f5                	jne    800a02 <memfind+0x10>
			break;
	return (void *) s;
}
  800a0d:	5d                   	pop    %ebp
  800a0e:	c3                   	ret    

00800a0f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a0f:	55                   	push   %ebp
  800a10:	89 e5                	mov    %esp,%ebp
  800a12:	57                   	push   %edi
  800a13:	56                   	push   %esi
  800a14:	53                   	push   %ebx
  800a15:	8b 55 08             	mov    0x8(%ebp),%edx
  800a18:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a1b:	eb 03                	jmp    800a20 <strtol+0x11>
		s++;
  800a1d:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800a20:	0f b6 02             	movzbl (%edx),%eax
  800a23:	3c 20                	cmp    $0x20,%al
  800a25:	74 f6                	je     800a1d <strtol+0xe>
  800a27:	3c 09                	cmp    $0x9,%al
  800a29:	74 f2                	je     800a1d <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a2b:	3c 2b                	cmp    $0x2b,%al
  800a2d:	74 2a                	je     800a59 <strtol+0x4a>
	int neg = 0;
  800a2f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a34:	3c 2d                	cmp    $0x2d,%al
  800a36:	74 2b                	je     800a63 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a38:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a3e:	75 0f                	jne    800a4f <strtol+0x40>
  800a40:	80 3a 30             	cmpb   $0x30,(%edx)
  800a43:	74 28                	je     800a6d <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a45:	85 db                	test   %ebx,%ebx
  800a47:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a4c:	0f 44 d8             	cmove  %eax,%ebx
  800a4f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a54:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a57:	eb 46                	jmp    800a9f <strtol+0x90>
		s++;
  800a59:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800a5c:	bf 00 00 00 00       	mov    $0x0,%edi
  800a61:	eb d5                	jmp    800a38 <strtol+0x29>
		s++, neg = 1;
  800a63:	83 c2 01             	add    $0x1,%edx
  800a66:	bf 01 00 00 00       	mov    $0x1,%edi
  800a6b:	eb cb                	jmp    800a38 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a6d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a71:	74 0e                	je     800a81 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800a73:	85 db                	test   %ebx,%ebx
  800a75:	75 d8                	jne    800a4f <strtol+0x40>
		s++, base = 8;
  800a77:	83 c2 01             	add    $0x1,%edx
  800a7a:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a7f:	eb ce                	jmp    800a4f <strtol+0x40>
		s += 2, base = 16;
  800a81:	83 c2 02             	add    $0x2,%edx
  800a84:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a89:	eb c4                	jmp    800a4f <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a8b:	0f be c0             	movsbl %al,%eax
  800a8e:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a91:	3b 45 10             	cmp    0x10(%ebp),%eax
  800a94:	7d 3a                	jge    800ad0 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800a96:	83 c2 01             	add    $0x1,%edx
  800a99:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800a9d:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800a9f:	0f b6 02             	movzbl (%edx),%eax
  800aa2:	8d 70 d0             	lea    -0x30(%eax),%esi
  800aa5:	89 f3                	mov    %esi,%ebx
  800aa7:	80 fb 09             	cmp    $0x9,%bl
  800aaa:	76 df                	jbe    800a8b <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800aac:	8d 70 9f             	lea    -0x61(%eax),%esi
  800aaf:	89 f3                	mov    %esi,%ebx
  800ab1:	80 fb 19             	cmp    $0x19,%bl
  800ab4:	77 08                	ja     800abe <strtol+0xaf>
			dig = *s - 'a' + 10;
  800ab6:	0f be c0             	movsbl %al,%eax
  800ab9:	83 e8 57             	sub    $0x57,%eax
  800abc:	eb d3                	jmp    800a91 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800abe:	8d 70 bf             	lea    -0x41(%eax),%esi
  800ac1:	89 f3                	mov    %esi,%ebx
  800ac3:	80 fb 19             	cmp    $0x19,%bl
  800ac6:	77 08                	ja     800ad0 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800ac8:	0f be c0             	movsbl %al,%eax
  800acb:	83 e8 37             	sub    $0x37,%eax
  800ace:	eb c1                	jmp    800a91 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ad0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ad4:	74 05                	je     800adb <strtol+0xcc>
		*endptr = (char *) s;
  800ad6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad9:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800adb:	89 c8                	mov    %ecx,%eax
  800add:	f7 d8                	neg    %eax
  800adf:	85 ff                	test   %edi,%edi
  800ae1:	0f 45 c8             	cmovne %eax,%ecx
}
  800ae4:	89 c8                	mov    %ecx,%eax
  800ae6:	5b                   	pop    %ebx
  800ae7:	5e                   	pop    %esi
  800ae8:	5f                   	pop    %edi
  800ae9:	5d                   	pop    %ebp
  800aea:	c3                   	ret    

00800aeb <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800aeb:	55                   	push   %ebp
  800aec:	89 e5                	mov    %esp,%ebp
  800aee:	57                   	push   %edi
  800aef:	56                   	push   %esi
  800af0:	53                   	push   %ebx
  800af1:	83 ec 1c             	sub    $0x1c,%esp
  800af4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800af7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800afa:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile(
  800afc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b02:	8b 7d 10             	mov    0x10(%ebp),%edi
  800b05:	8b 75 14             	mov    0x14(%ebp),%esi
  800b08:	cd 30                	int    $0x30
	        "int %1\n"
	        : "=a"(ret)
	        : "i"(T_SYSCALL), "a"(num), "d"(a1), "c"(a2), "b"(a3), "D"(a4), "S"(a5)
	        : "cc", "memory");

	if (check && ret > 0)
  800b0a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800b0e:	74 04                	je     800b14 <syscall+0x29>
  800b10:	85 c0                	test   %eax,%eax
  800b12:	7f 08                	jg     800b1c <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800b14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b17:	5b                   	pop    %ebx
  800b18:	5e                   	pop    %esi
  800b19:	5f                   	pop    %edi
  800b1a:	5d                   	pop    %ebp
  800b1b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b1c:	83 ec 0c             	sub    $0xc,%esp
  800b1f:	50                   	push   %eax
  800b20:	ff 75 e0             	push   -0x20(%ebp)
  800b23:	68 84 12 80 00       	push   $0x801284
  800b28:	6a 1e                	push   $0x1e
  800b2a:	68 a1 12 80 00       	push   $0x8012a1
  800b2f:	e8 5f f6 ff ff       	call   800193 <_panic>

00800b34 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
  800b37:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t) s, len, 0, 0, 0);
  800b3a:	6a 00                	push   $0x0
  800b3c:	6a 00                	push   $0x0
  800b3e:	6a 00                	push   $0x0
  800b40:	ff 75 0c             	push   0xc(%ebp)
  800b43:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b46:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b50:	e8 96 ff ff ff       	call   800aeb <syscall>
}
  800b55:	83 c4 10             	add    $0x10,%esp
  800b58:	c9                   	leave  
  800b59:	c3                   	ret    

00800b5a <sys_cgetc>:

int
sys_cgetc(void)
{
  800b5a:	55                   	push   %ebp
  800b5b:	89 e5                	mov    %esp,%ebp
  800b5d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800b60:	6a 00                	push   $0x0
  800b62:	6a 00                	push   $0x0
  800b64:	6a 00                	push   $0x0
  800b66:	6a 00                	push   $0x0
  800b68:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b6d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b72:	b8 01 00 00 00       	mov    $0x1,%eax
  800b77:	e8 6f ff ff ff       	call   800aeb <syscall>
}
  800b7c:	c9                   	leave  
  800b7d:	c3                   	ret    

00800b7e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b7e:	55                   	push   %ebp
  800b7f:	89 e5                	mov    %esp,%ebp
  800b81:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800b84:	6a 00                	push   $0x0
  800b86:	6a 00                	push   $0x0
  800b88:	6a 00                	push   $0x0
  800b8a:	6a 00                	push   $0x0
  800b8c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b8f:	ba 01 00 00 00       	mov    $0x1,%edx
  800b94:	b8 03 00 00 00       	mov    $0x3,%eax
  800b99:	e8 4d ff ff ff       	call   800aeb <syscall>
}
  800b9e:	c9                   	leave  
  800b9f:	c3                   	ret    

00800ba0 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ba0:	55                   	push   %ebp
  800ba1:	89 e5                	mov    %esp,%ebp
  800ba3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800ba6:	6a 00                	push   $0x0
  800ba8:	6a 00                	push   $0x0
  800baa:	6a 00                	push   $0x0
  800bac:	6a 00                	push   $0x0
  800bae:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bb3:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb8:	b8 02 00 00 00       	mov    $0x2,%eax
  800bbd:	e8 29 ff ff ff       	call   800aeb <syscall>
}
  800bc2:	c9                   	leave  
  800bc3:	c3                   	ret    

00800bc4 <sys_yield>:

void
sys_yield(void)
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800bca:	6a 00                	push   $0x0
  800bcc:	6a 00                	push   $0x0
  800bce:	6a 00                	push   $0x0
  800bd0:	6a 00                	push   $0x0
  800bd2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bd7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bdc:	b8 0a 00 00 00       	mov    $0xa,%eax
  800be1:	e8 05 ff ff ff       	call   800aeb <syscall>
}
  800be6:	83 c4 10             	add    $0x10,%esp
  800be9:	c9                   	leave  
  800bea:	c3                   	ret    

00800beb <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800bf1:	6a 00                	push   $0x0
  800bf3:	6a 00                	push   $0x0
  800bf5:	ff 75 10             	push   0x10(%ebp)
  800bf8:	ff 75 0c             	push   0xc(%ebp)
  800bfb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bfe:	ba 01 00 00 00       	mov    $0x1,%edx
  800c03:	b8 04 00 00 00       	mov    $0x4,%eax
  800c08:	e8 de fe ff ff       	call   800aeb <syscall>
}
  800c0d:	c9                   	leave  
  800c0e:	c3                   	ret    

00800c0f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c0f:	55                   	push   %ebp
  800c10:	89 e5                	mov    %esp,%ebp
  800c12:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map,
  800c15:	ff 75 18             	push   0x18(%ebp)
  800c18:	ff 75 14             	push   0x14(%ebp)
  800c1b:	ff 75 10             	push   0x10(%ebp)
  800c1e:	ff 75 0c             	push   0xc(%ebp)
  800c21:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c24:	ba 01 00 00 00       	mov    $0x1,%edx
  800c29:	b8 05 00 00 00       	mov    $0x5,%eax
  800c2e:	e8 b8 fe ff ff       	call   800aeb <syscall>
	               srcenv,
	               (uint32_t) srcva,
	               dstenv,
	               (uint32_t) dstva,
	               perm);
}
  800c33:	c9                   	leave  
  800c34:	c3                   	ret    

00800c35 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c35:	55                   	push   %ebp
  800c36:	89 e5                	mov    %esp,%ebp
  800c38:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800c3b:	6a 00                	push   $0x0
  800c3d:	6a 00                	push   $0x0
  800c3f:	6a 00                	push   $0x0
  800c41:	ff 75 0c             	push   0xc(%ebp)
  800c44:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c47:	ba 01 00 00 00       	mov    $0x1,%edx
  800c4c:	b8 06 00 00 00       	mov    $0x6,%eax
  800c51:	e8 95 fe ff ff       	call   800aeb <syscall>
}
  800c56:	c9                   	leave  
  800c57:	c3                   	ret    

00800c58 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c58:	55                   	push   %ebp
  800c59:	89 e5                	mov    %esp,%ebp
  800c5b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800c5e:	6a 00                	push   $0x0
  800c60:	6a 00                	push   $0x0
  800c62:	6a 00                	push   $0x0
  800c64:	ff 75 0c             	push   0xc(%ebp)
  800c67:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c6a:	ba 01 00 00 00       	mov    $0x1,%edx
  800c6f:	b8 08 00 00 00       	mov    $0x8,%eax
  800c74:	e8 72 fe ff ff       	call   800aeb <syscall>
}
  800c79:	c9                   	leave  
  800c7a:	c3                   	ret    

00800c7b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c7b:	55                   	push   %ebp
  800c7c:	89 e5                	mov    %esp,%ebp
  800c7e:	83 ec 08             	sub    $0x8,%esp
	return syscall(
  800c81:	6a 00                	push   $0x0
  800c83:	6a 00                	push   $0x0
  800c85:	6a 00                	push   $0x0
  800c87:	ff 75 0c             	push   0xc(%ebp)
  800c8a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c8d:	ba 01 00 00 00       	mov    $0x1,%edx
  800c92:	b8 09 00 00 00       	mov    $0x9,%eax
  800c97:	e8 4f fe ff ff       	call   800aeb <syscall>
	        SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c9c:	c9                   	leave  
  800c9d:	c3                   	ret    

00800c9e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c9e:	55                   	push   %ebp
  800c9f:	89 e5                	mov    %esp,%ebp
  800ca1:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800ca4:	6a 00                	push   $0x0
  800ca6:	ff 75 14             	push   0x14(%ebp)
  800ca9:	ff 75 10             	push   0x10(%ebp)
  800cac:	ff 75 0c             	push   0xc(%ebp)
  800caf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cb2:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb7:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cbc:	e8 2a fe ff ff       	call   800aeb <syscall>
}
  800cc1:	c9                   	leave  
  800cc2:	c3                   	ret    

00800cc3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cc3:	55                   	push   %ebp
  800cc4:	89 e5                	mov    %esp,%ebp
  800cc6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t) dstva, 0, 0, 0, 0);
  800cc9:	6a 00                	push   $0x0
  800ccb:	6a 00                	push   $0x0
  800ccd:	6a 00                	push   $0x0
  800ccf:	6a 00                	push   $0x0
  800cd1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cd4:	ba 01 00 00 00       	mov    $0x1,%edx
  800cd9:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cde:	e8 08 fe ff ff       	call   800aeb <syscall>
}
  800ce3:	c9                   	leave  
  800ce4:	c3                   	ret    

00800ce5 <sys_get_priority>:

// Get priority of the current process
int
sys_get_priority(void)
{
  800ce5:	55                   	push   %ebp
  800ce6:	89 e5                	mov    %esp,%ebp
  800ce8:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_get_priority, 0, 0, 0, 0, 0, 0);
  800ceb:	6a 00                	push   $0x0
  800ced:	6a 00                	push   $0x0
  800cef:	6a 00                	push   $0x0
  800cf1:	6a 00                	push   $0x0
  800cf3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cf8:	ba 00 00 00 00       	mov    $0x0,%edx
  800cfd:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d02:	e8 e4 fd ff ff       	call   800aeb <syscall>
}
  800d07:	c9                   	leave  
  800d08:	c3                   	ret    

00800d09 <sys_set_priority>:

// Get priority of the current process
int
sys_set_priority(unsigned int priority)
{
  800d09:	55                   	push   %ebp
  800d0a:	89 e5                	mov    %esp,%ebp
  800d0c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, (uint32_t) priority, 0, 0, 0, 0);
  800d0f:	6a 00                	push   $0x0
  800d11:	6a 00                	push   $0x0
  800d13:	6a 00                	push   $0x0
  800d15:	6a 00                	push   $0x0
  800d17:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d1a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d1f:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d24:	e8 c2 fd ff ff       	call   800aeb <syscall>
}
  800d29:	c9                   	leave  
  800d2a:	c3                   	ret    
  800d2b:	66 90                	xchg   %ax,%ax
  800d2d:	66 90                	xchg   %ax,%ax
  800d2f:	90                   	nop

00800d30 <__udivdi3>:
  800d30:	f3 0f 1e fb          	endbr32 
  800d34:	55                   	push   %ebp
  800d35:	57                   	push   %edi
  800d36:	56                   	push   %esi
  800d37:	53                   	push   %ebx
  800d38:	83 ec 1c             	sub    $0x1c,%esp
  800d3b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800d3f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800d43:	8b 74 24 34          	mov    0x34(%esp),%esi
  800d47:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800d4b:	85 c0                	test   %eax,%eax
  800d4d:	75 19                	jne    800d68 <__udivdi3+0x38>
  800d4f:	39 f3                	cmp    %esi,%ebx
  800d51:	76 4d                	jbe    800da0 <__udivdi3+0x70>
  800d53:	31 ff                	xor    %edi,%edi
  800d55:	89 e8                	mov    %ebp,%eax
  800d57:	89 f2                	mov    %esi,%edx
  800d59:	f7 f3                	div    %ebx
  800d5b:	89 fa                	mov    %edi,%edx
  800d5d:	83 c4 1c             	add    $0x1c,%esp
  800d60:	5b                   	pop    %ebx
  800d61:	5e                   	pop    %esi
  800d62:	5f                   	pop    %edi
  800d63:	5d                   	pop    %ebp
  800d64:	c3                   	ret    
  800d65:	8d 76 00             	lea    0x0(%esi),%esi
  800d68:	39 f0                	cmp    %esi,%eax
  800d6a:	76 14                	jbe    800d80 <__udivdi3+0x50>
  800d6c:	31 ff                	xor    %edi,%edi
  800d6e:	31 c0                	xor    %eax,%eax
  800d70:	89 fa                	mov    %edi,%edx
  800d72:	83 c4 1c             	add    $0x1c,%esp
  800d75:	5b                   	pop    %ebx
  800d76:	5e                   	pop    %esi
  800d77:	5f                   	pop    %edi
  800d78:	5d                   	pop    %ebp
  800d79:	c3                   	ret    
  800d7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d80:	0f bd f8             	bsr    %eax,%edi
  800d83:	83 f7 1f             	xor    $0x1f,%edi
  800d86:	75 48                	jne    800dd0 <__udivdi3+0xa0>
  800d88:	39 f0                	cmp    %esi,%eax
  800d8a:	72 06                	jb     800d92 <__udivdi3+0x62>
  800d8c:	31 c0                	xor    %eax,%eax
  800d8e:	39 eb                	cmp    %ebp,%ebx
  800d90:	77 de                	ja     800d70 <__udivdi3+0x40>
  800d92:	b8 01 00 00 00       	mov    $0x1,%eax
  800d97:	eb d7                	jmp    800d70 <__udivdi3+0x40>
  800d99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800da0:	89 d9                	mov    %ebx,%ecx
  800da2:	85 db                	test   %ebx,%ebx
  800da4:	75 0b                	jne    800db1 <__udivdi3+0x81>
  800da6:	b8 01 00 00 00       	mov    $0x1,%eax
  800dab:	31 d2                	xor    %edx,%edx
  800dad:	f7 f3                	div    %ebx
  800daf:	89 c1                	mov    %eax,%ecx
  800db1:	31 d2                	xor    %edx,%edx
  800db3:	89 f0                	mov    %esi,%eax
  800db5:	f7 f1                	div    %ecx
  800db7:	89 c6                	mov    %eax,%esi
  800db9:	89 e8                	mov    %ebp,%eax
  800dbb:	89 f7                	mov    %esi,%edi
  800dbd:	f7 f1                	div    %ecx
  800dbf:	89 fa                	mov    %edi,%edx
  800dc1:	83 c4 1c             	add    $0x1c,%esp
  800dc4:	5b                   	pop    %ebx
  800dc5:	5e                   	pop    %esi
  800dc6:	5f                   	pop    %edi
  800dc7:	5d                   	pop    %ebp
  800dc8:	c3                   	ret    
  800dc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800dd0:	89 f9                	mov    %edi,%ecx
  800dd2:	ba 20 00 00 00       	mov    $0x20,%edx
  800dd7:	29 fa                	sub    %edi,%edx
  800dd9:	d3 e0                	shl    %cl,%eax
  800ddb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ddf:	89 d1                	mov    %edx,%ecx
  800de1:	89 d8                	mov    %ebx,%eax
  800de3:	d3 e8                	shr    %cl,%eax
  800de5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800de9:	09 c1                	or     %eax,%ecx
  800deb:	89 f0                	mov    %esi,%eax
  800ded:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800df1:	89 f9                	mov    %edi,%ecx
  800df3:	d3 e3                	shl    %cl,%ebx
  800df5:	89 d1                	mov    %edx,%ecx
  800df7:	d3 e8                	shr    %cl,%eax
  800df9:	89 f9                	mov    %edi,%ecx
  800dfb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800dff:	89 eb                	mov    %ebp,%ebx
  800e01:	d3 e6                	shl    %cl,%esi
  800e03:	89 d1                	mov    %edx,%ecx
  800e05:	d3 eb                	shr    %cl,%ebx
  800e07:	09 f3                	or     %esi,%ebx
  800e09:	89 c6                	mov    %eax,%esi
  800e0b:	89 f2                	mov    %esi,%edx
  800e0d:	89 d8                	mov    %ebx,%eax
  800e0f:	f7 74 24 08          	divl   0x8(%esp)
  800e13:	89 d6                	mov    %edx,%esi
  800e15:	89 c3                	mov    %eax,%ebx
  800e17:	f7 64 24 0c          	mull   0xc(%esp)
  800e1b:	39 d6                	cmp    %edx,%esi
  800e1d:	72 19                	jb     800e38 <__udivdi3+0x108>
  800e1f:	89 f9                	mov    %edi,%ecx
  800e21:	d3 e5                	shl    %cl,%ebp
  800e23:	39 c5                	cmp    %eax,%ebp
  800e25:	73 04                	jae    800e2b <__udivdi3+0xfb>
  800e27:	39 d6                	cmp    %edx,%esi
  800e29:	74 0d                	je     800e38 <__udivdi3+0x108>
  800e2b:	89 d8                	mov    %ebx,%eax
  800e2d:	31 ff                	xor    %edi,%edi
  800e2f:	e9 3c ff ff ff       	jmp    800d70 <__udivdi3+0x40>
  800e34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e38:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800e3b:	31 ff                	xor    %edi,%edi
  800e3d:	e9 2e ff ff ff       	jmp    800d70 <__udivdi3+0x40>
  800e42:	66 90                	xchg   %ax,%ax
  800e44:	66 90                	xchg   %ax,%ax
  800e46:	66 90                	xchg   %ax,%ax
  800e48:	66 90                	xchg   %ax,%ax
  800e4a:	66 90                	xchg   %ax,%ax
  800e4c:	66 90                	xchg   %ax,%ax
  800e4e:	66 90                	xchg   %ax,%ax

00800e50 <__umoddi3>:
  800e50:	f3 0f 1e fb          	endbr32 
  800e54:	55                   	push   %ebp
  800e55:	57                   	push   %edi
  800e56:	56                   	push   %esi
  800e57:	53                   	push   %ebx
  800e58:	83 ec 1c             	sub    $0x1c,%esp
  800e5b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800e5f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800e63:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  800e67:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  800e6b:	89 f0                	mov    %esi,%eax
  800e6d:	89 da                	mov    %ebx,%edx
  800e6f:	85 ff                	test   %edi,%edi
  800e71:	75 15                	jne    800e88 <__umoddi3+0x38>
  800e73:	39 dd                	cmp    %ebx,%ebp
  800e75:	76 39                	jbe    800eb0 <__umoddi3+0x60>
  800e77:	f7 f5                	div    %ebp
  800e79:	89 d0                	mov    %edx,%eax
  800e7b:	31 d2                	xor    %edx,%edx
  800e7d:	83 c4 1c             	add    $0x1c,%esp
  800e80:	5b                   	pop    %ebx
  800e81:	5e                   	pop    %esi
  800e82:	5f                   	pop    %edi
  800e83:	5d                   	pop    %ebp
  800e84:	c3                   	ret    
  800e85:	8d 76 00             	lea    0x0(%esi),%esi
  800e88:	39 df                	cmp    %ebx,%edi
  800e8a:	77 f1                	ja     800e7d <__umoddi3+0x2d>
  800e8c:	0f bd cf             	bsr    %edi,%ecx
  800e8f:	83 f1 1f             	xor    $0x1f,%ecx
  800e92:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800e96:	75 40                	jne    800ed8 <__umoddi3+0x88>
  800e98:	39 df                	cmp    %ebx,%edi
  800e9a:	72 04                	jb     800ea0 <__umoddi3+0x50>
  800e9c:	39 f5                	cmp    %esi,%ebp
  800e9e:	77 dd                	ja     800e7d <__umoddi3+0x2d>
  800ea0:	89 da                	mov    %ebx,%edx
  800ea2:	89 f0                	mov    %esi,%eax
  800ea4:	29 e8                	sub    %ebp,%eax
  800ea6:	19 fa                	sbb    %edi,%edx
  800ea8:	eb d3                	jmp    800e7d <__umoddi3+0x2d>
  800eaa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800eb0:	89 e9                	mov    %ebp,%ecx
  800eb2:	85 ed                	test   %ebp,%ebp
  800eb4:	75 0b                	jne    800ec1 <__umoddi3+0x71>
  800eb6:	b8 01 00 00 00       	mov    $0x1,%eax
  800ebb:	31 d2                	xor    %edx,%edx
  800ebd:	f7 f5                	div    %ebp
  800ebf:	89 c1                	mov    %eax,%ecx
  800ec1:	89 d8                	mov    %ebx,%eax
  800ec3:	31 d2                	xor    %edx,%edx
  800ec5:	f7 f1                	div    %ecx
  800ec7:	89 f0                	mov    %esi,%eax
  800ec9:	f7 f1                	div    %ecx
  800ecb:	89 d0                	mov    %edx,%eax
  800ecd:	31 d2                	xor    %edx,%edx
  800ecf:	eb ac                	jmp    800e7d <__umoddi3+0x2d>
  800ed1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ed8:	8b 44 24 04          	mov    0x4(%esp),%eax
  800edc:	ba 20 00 00 00       	mov    $0x20,%edx
  800ee1:	29 c2                	sub    %eax,%edx
  800ee3:	89 c1                	mov    %eax,%ecx
  800ee5:	89 e8                	mov    %ebp,%eax
  800ee7:	d3 e7                	shl    %cl,%edi
  800ee9:	89 d1                	mov    %edx,%ecx
  800eeb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800eef:	d3 e8                	shr    %cl,%eax
  800ef1:	89 c1                	mov    %eax,%ecx
  800ef3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800ef7:	09 f9                	or     %edi,%ecx
  800ef9:	89 df                	mov    %ebx,%edi
  800efb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800eff:	89 c1                	mov    %eax,%ecx
  800f01:	d3 e5                	shl    %cl,%ebp
  800f03:	89 d1                	mov    %edx,%ecx
  800f05:	d3 ef                	shr    %cl,%edi
  800f07:	89 c1                	mov    %eax,%ecx
  800f09:	89 f0                	mov    %esi,%eax
  800f0b:	d3 e3                	shl    %cl,%ebx
  800f0d:	89 d1                	mov    %edx,%ecx
  800f0f:	89 fa                	mov    %edi,%edx
  800f11:	d3 e8                	shr    %cl,%eax
  800f13:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f18:	09 d8                	or     %ebx,%eax
  800f1a:	f7 74 24 08          	divl   0x8(%esp)
  800f1e:	89 d3                	mov    %edx,%ebx
  800f20:	d3 e6                	shl    %cl,%esi
  800f22:	f7 e5                	mul    %ebp
  800f24:	89 c7                	mov    %eax,%edi
  800f26:	89 d1                	mov    %edx,%ecx
  800f28:	39 d3                	cmp    %edx,%ebx
  800f2a:	72 06                	jb     800f32 <__umoddi3+0xe2>
  800f2c:	75 0e                	jne    800f3c <__umoddi3+0xec>
  800f2e:	39 c6                	cmp    %eax,%esi
  800f30:	73 0a                	jae    800f3c <__umoddi3+0xec>
  800f32:	29 e8                	sub    %ebp,%eax
  800f34:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800f38:	89 d1                	mov    %edx,%ecx
  800f3a:	89 c7                	mov    %eax,%edi
  800f3c:	89 f5                	mov    %esi,%ebp
  800f3e:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f42:	29 fd                	sub    %edi,%ebp
  800f44:	19 cb                	sbb    %ecx,%ebx
  800f46:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800f4b:	89 d8                	mov    %ebx,%eax
  800f4d:	d3 e0                	shl    %cl,%eax
  800f4f:	89 f1                	mov    %esi,%ecx
  800f51:	d3 ed                	shr    %cl,%ebp
  800f53:	d3 eb                	shr    %cl,%ebx
  800f55:	09 e8                	or     %ebp,%eax
  800f57:	89 da                	mov    %ebx,%edx
  800f59:	83 c4 1c             	add    $0x1c,%esp
  800f5c:	5b                   	pop    %ebx
  800f5d:	5e                   	pop    %esi
  800f5e:	5f                   	pop    %edi
  800f5f:	5d                   	pop    %ebp
  800f60:	c3                   	ret    
