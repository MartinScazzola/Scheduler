
obj/user/faultallocbad:     formato del fichero elf32-i386


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
  80002c:	e8 84 00 00 00       	call   8000b5 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int r;
	void *addr = (void *) utf->utf_fault_va;
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
  80003d:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  80003f:	53                   	push   %ebx
  800040:	68 60 0f 80 00       	push   $0x800f60
  800045:	e8 a5 01 00 00       	call   8001ef <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE), PTE_P | PTE_U | PTE_W)) <
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 0e 0b 00 00       	call   800b6c <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	78 16                	js     80007b <handler+0x48>
	    0)
		panic("allocating at %x in page fault handler: %e", addr, r);
	snprintf((char *) addr, 100, "this string was faulted in at %x", addr);
  800065:	53                   	push   %ebx
  800066:	68 ac 0f 80 00       	push   $0x800fac
  80006b:	6a 64                	push   $0x64
  80006d:	53                   	push   %ebx
  80006e:	e8 60 06 00 00       	call   8006d3 <snprintf>
}
  800073:	83 c4 10             	add    $0x10,%esp
  800076:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800079:	c9                   	leave  
  80007a:	c3                   	ret    
		panic("allocating at %x in page fault handler: %e", addr, r);
  80007b:	83 ec 0c             	sub    $0xc,%esp
  80007e:	50                   	push   %eax
  80007f:	53                   	push   %ebx
  800080:	68 80 0f 80 00       	push   $0x800f80
  800085:	6a 0f                	push   $0xf
  800087:	68 6a 0f 80 00       	push   $0x800f6a
  80008c:	e8 83 00 00 00       	call   800114 <_panic>

00800091 <umain>:

void
umain(int argc, char **argv)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800097:	68 33 00 80 00       	push   $0x800033
  80009c:	e8 0b 0c 00 00       	call   800cac <set_pgfault_handler>
	sys_cputs((char *) 0xDEADBEEF, 4);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	6a 04                	push   $0x4
  8000a6:	68 ef be ad de       	push   $0xdeadbeef
  8000ab:	e8 05 0a 00 00       	call   800ab5 <sys_cputs>
}
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
  8000ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	envid_t id = sys_getenvid();
  8000c0:	e8 5c 0a 00 00       	call   800b21 <sys_getenvid>
	if (id >= 0)
  8000c5:	85 c0                	test   %eax,%eax
  8000c7:	78 15                	js     8000de <libmain+0x29>
		thisenv = &envs[ENVX(id)];
  8000c9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ce:	69 c0 88 00 00 00    	imul   $0x88,%eax,%eax
  8000d4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d9:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000de:	85 db                	test   %ebx,%ebx
  8000e0:	7e 07                	jle    8000e9 <libmain+0x34>
		binaryname = argv[0];
  8000e2:	8b 06                	mov    (%esi),%eax
  8000e4:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000e9:	83 ec 08             	sub    $0x8,%esp
  8000ec:	56                   	push   %esi
  8000ed:	53                   	push   %ebx
  8000ee:	e8 9e ff ff ff       	call   800091 <umain>

	// exit gracefully
	exit();
  8000f3:	e8 0a 00 00 00       	call   800102 <exit>
}
  8000f8:	83 c4 10             	add    $0x10,%esp
  8000fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000fe:	5b                   	pop    %ebx
  8000ff:	5e                   	pop    %esi
  800100:	5d                   	pop    %ebp
  800101:	c3                   	ret    

00800102 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800102:	55                   	push   %ebp
  800103:	89 e5                	mov    %esp,%ebp
  800105:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800108:	6a 00                	push   $0x0
  80010a:	e8 f0 09 00 00       	call   800aff <sys_env_destroy>
}
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	c9                   	leave  
  800113:	c3                   	ret    

00800114 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800114:	55                   	push   %ebp
  800115:	89 e5                	mov    %esp,%ebp
  800117:	56                   	push   %esi
  800118:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800119:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80011c:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800122:	e8 fa 09 00 00       	call   800b21 <sys_getenvid>
  800127:	83 ec 0c             	sub    $0xc,%esp
  80012a:	ff 75 0c             	push   0xc(%ebp)
  80012d:	ff 75 08             	push   0x8(%ebp)
  800130:	56                   	push   %esi
  800131:	50                   	push   %eax
  800132:	68 d8 0f 80 00       	push   $0x800fd8
  800137:	e8 b3 00 00 00       	call   8001ef <cprintf>
	        sys_getenvid(),
	        binaryname,
	        file,
	        line);
	vcprintf(fmt, ap);
  80013c:	83 c4 18             	add    $0x18,%esp
  80013f:	53                   	push   %ebx
  800140:	ff 75 10             	push   0x10(%ebp)
  800143:	e8 56 00 00 00       	call   80019e <vcprintf>
	cprintf("\n");
  800148:	c7 04 24 68 0f 80 00 	movl   $0x800f68,(%esp)
  80014f:	e8 9b 00 00 00       	call   8001ef <cprintf>
  800154:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800157:	cc                   	int3   
  800158:	eb fd                	jmp    800157 <_panic+0x43>

0080015a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80015a:	55                   	push   %ebp
  80015b:	89 e5                	mov    %esp,%ebp
  80015d:	53                   	push   %ebx
  80015e:	83 ec 04             	sub    $0x4,%esp
  800161:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800164:	8b 13                	mov    (%ebx),%edx
  800166:	8d 42 01             	lea    0x1(%edx),%eax
  800169:	89 03                	mov    %eax,(%ebx)
  80016b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80016e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256 - 1) {
  800172:	3d ff 00 00 00       	cmp    $0xff,%eax
  800177:	74 09                	je     800182 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800179:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80017d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800180:	c9                   	leave  
  800181:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800182:	83 ec 08             	sub    $0x8,%esp
  800185:	68 ff 00 00 00       	push   $0xff
  80018a:	8d 43 08             	lea    0x8(%ebx),%eax
  80018d:	50                   	push   %eax
  80018e:	e8 22 09 00 00       	call   800ab5 <sys_cputs>
		b->idx = 0;
  800193:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800199:	83 c4 10             	add    $0x10,%esp
  80019c:	eb db                	jmp    800179 <putch+0x1f>

0080019e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80019e:	55                   	push   %ebp
  80019f:	89 e5                	mov    %esp,%ebp
  8001a1:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001a7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ae:	00 00 00 
	b.cnt = 0;
  8001b1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001b8:	00 00 00 
	vprintfmt((void *) putch, &b, fmt, ap);
  8001bb:	ff 75 0c             	push   0xc(%ebp)
  8001be:	ff 75 08             	push   0x8(%ebp)
  8001c1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c7:	50                   	push   %eax
  8001c8:	68 5a 01 80 00       	push   $0x80015a
  8001cd:	e8 74 01 00 00       	call   800346 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d2:	83 c4 08             	add    $0x8,%esp
  8001d5:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8001db:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e1:	50                   	push   %eax
  8001e2:	e8 ce 08 00 00       	call   800ab5 <sys_cputs>

	return b.cnt;
}
  8001e7:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ed:	c9                   	leave  
  8001ee:	c3                   	ret    

008001ef <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001ef:	55                   	push   %ebp
  8001f0:	89 e5                	mov    %esp,%ebp
  8001f2:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001f5:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001f8:	50                   	push   %eax
  8001f9:	ff 75 08             	push   0x8(%ebp)
  8001fc:	e8 9d ff ff ff       	call   80019e <vcprintf>
	va_end(ap);

	return cnt;
}
  800201:	c9                   	leave  
  800202:	c3                   	ret    

00800203 <printnum>:
         void *putdat,
         unsigned long long num,
         unsigned base,
         int width,
         int padc)
{
  800203:	55                   	push   %ebp
  800204:	89 e5                	mov    %esp,%ebp
  800206:	57                   	push   %edi
  800207:	56                   	push   %esi
  800208:	53                   	push   %ebx
  800209:	83 ec 1c             	sub    $0x1c,%esp
  80020c:	89 c7                	mov    %eax,%edi
  80020e:	89 d6                	mov    %edx,%esi
  800210:	8b 45 08             	mov    0x8(%ebp),%eax
  800213:	8b 55 0c             	mov    0xc(%ebp),%edx
  800216:	89 d1                	mov    %edx,%ecx
  800218:	89 c2                	mov    %eax,%edx
  80021a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80021d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800220:	8b 45 10             	mov    0x10(%ebp),%eax
  800223:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800226:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800229:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800230:	39 c2                	cmp    %eax,%edx
  800232:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800235:	72 3e                	jb     800275 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800237:	83 ec 0c             	sub    $0xc,%esp
  80023a:	ff 75 18             	push   0x18(%ebp)
  80023d:	83 eb 01             	sub    $0x1,%ebx
  800240:	53                   	push   %ebx
  800241:	50                   	push   %eax
  800242:	83 ec 08             	sub    $0x8,%esp
  800245:	ff 75 e4             	push   -0x1c(%ebp)
  800248:	ff 75 e0             	push   -0x20(%ebp)
  80024b:	ff 75 dc             	push   -0x24(%ebp)
  80024e:	ff 75 d8             	push   -0x28(%ebp)
  800251:	e8 ca 0a 00 00       	call   800d20 <__udivdi3>
  800256:	83 c4 18             	add    $0x18,%esp
  800259:	52                   	push   %edx
  80025a:	50                   	push   %eax
  80025b:	89 f2                	mov    %esi,%edx
  80025d:	89 f8                	mov    %edi,%eax
  80025f:	e8 9f ff ff ff       	call   800203 <printnum>
  800264:	83 c4 20             	add    $0x20,%esp
  800267:	eb 13                	jmp    80027c <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800269:	83 ec 08             	sub    $0x8,%esp
  80026c:	56                   	push   %esi
  80026d:	ff 75 18             	push   0x18(%ebp)
  800270:	ff d7                	call   *%edi
  800272:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800275:	83 eb 01             	sub    $0x1,%ebx
  800278:	85 db                	test   %ebx,%ebx
  80027a:	7f ed                	jg     800269 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80027c:	83 ec 08             	sub    $0x8,%esp
  80027f:	56                   	push   %esi
  800280:	83 ec 04             	sub    $0x4,%esp
  800283:	ff 75 e4             	push   -0x1c(%ebp)
  800286:	ff 75 e0             	push   -0x20(%ebp)
  800289:	ff 75 dc             	push   -0x24(%ebp)
  80028c:	ff 75 d8             	push   -0x28(%ebp)
  80028f:	e8 ac 0b 00 00       	call   800e40 <__umoddi3>
  800294:	83 c4 14             	add    $0x14,%esp
  800297:	0f be 80 fb 0f 80 00 	movsbl 0x800ffb(%eax),%eax
  80029e:	50                   	push   %eax
  80029f:	ff d7                	call   *%edi
}
  8002a1:	83 c4 10             	add    $0x10,%esp
  8002a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a7:	5b                   	pop    %ebx
  8002a8:	5e                   	pop    %esi
  8002a9:	5f                   	pop    %edi
  8002aa:	5d                   	pop    %ebp
  8002ab:	c3                   	ret    

008002ac <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8002ac:	83 fa 01             	cmp    $0x1,%edx
  8002af:	7f 13                	jg     8002c4 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8002b1:	85 d2                	test   %edx,%edx
  8002b3:	74 1c                	je     8002d1 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  8002b5:	8b 10                	mov    (%eax),%edx
  8002b7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ba:	89 08                	mov    %ecx,(%eax)
  8002bc:	8b 02                	mov    (%edx),%eax
  8002be:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c3:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  8002c4:	8b 10                	mov    (%eax),%edx
  8002c6:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002c9:	89 08                	mov    %ecx,(%eax)
  8002cb:	8b 02                	mov    (%edx),%eax
  8002cd:	8b 52 04             	mov    0x4(%edx),%edx
  8002d0:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  8002d1:	8b 10                	mov    (%eax),%edx
  8002d3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d6:	89 08                	mov    %ecx,(%eax)
  8002d8:	8b 02                	mov    (%edx),%eax
  8002da:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002df:	c3                   	ret    

008002e0 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8002e0:	83 fa 01             	cmp    $0x1,%edx
  8002e3:	7f 0f                	jg     8002f4 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  8002e5:	85 d2                	test   %edx,%edx
  8002e7:	74 18                	je     800301 <getint+0x21>
		return va_arg(*ap, long);
  8002e9:	8b 10                	mov    (%eax),%edx
  8002eb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ee:	89 08                	mov    %ecx,(%eax)
  8002f0:	8b 02                	mov    (%edx),%eax
  8002f2:	99                   	cltd   
  8002f3:	c3                   	ret    
		return va_arg(*ap, long long);
  8002f4:	8b 10                	mov    (%eax),%edx
  8002f6:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002f9:	89 08                	mov    %ecx,(%eax)
  8002fb:	8b 02                	mov    (%edx),%eax
  8002fd:	8b 52 04             	mov    0x4(%edx),%edx
  800300:	c3                   	ret    
	else
		return va_arg(*ap, int);
  800301:	8b 10                	mov    (%eax),%edx
  800303:	8d 4a 04             	lea    0x4(%edx),%ecx
  800306:	89 08                	mov    %ecx,(%eax)
  800308:	8b 02                	mov    (%edx),%eax
  80030a:	99                   	cltd   
}
  80030b:	c3                   	ret    

0080030c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80030c:	55                   	push   %ebp
  80030d:	89 e5                	mov    %esp,%ebp
  80030f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800312:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800316:	8b 10                	mov    (%eax),%edx
  800318:	3b 50 04             	cmp    0x4(%eax),%edx
  80031b:	73 0a                	jae    800327 <sprintputch+0x1b>
		*b->buf++ = ch;
  80031d:	8d 4a 01             	lea    0x1(%edx),%ecx
  800320:	89 08                	mov    %ecx,(%eax)
  800322:	8b 45 08             	mov    0x8(%ebp),%eax
  800325:	88 02                	mov    %al,(%edx)
}
  800327:	5d                   	pop    %ebp
  800328:	c3                   	ret    

00800329 <printfmt>:
{
  800329:	55                   	push   %ebp
  80032a:	89 e5                	mov    %esp,%ebp
  80032c:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80032f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800332:	50                   	push   %eax
  800333:	ff 75 10             	push   0x10(%ebp)
  800336:	ff 75 0c             	push   0xc(%ebp)
  800339:	ff 75 08             	push   0x8(%ebp)
  80033c:	e8 05 00 00 00       	call   800346 <vprintfmt>
}
  800341:	83 c4 10             	add    $0x10,%esp
  800344:	c9                   	leave  
  800345:	c3                   	ret    

00800346 <vprintfmt>:
{
  800346:	55                   	push   %ebp
  800347:	89 e5                	mov    %esp,%ebp
  800349:	57                   	push   %edi
  80034a:	56                   	push   %esi
  80034b:	53                   	push   %ebx
  80034c:	83 ec 2c             	sub    $0x2c,%esp
  80034f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800352:	8b 75 0c             	mov    0xc(%ebp),%esi
  800355:	8b 7d 10             	mov    0x10(%ebp),%edi
  800358:	eb 0a                	jmp    800364 <vprintfmt+0x1e>
			putch(ch, putdat);
  80035a:	83 ec 08             	sub    $0x8,%esp
  80035d:	56                   	push   %esi
  80035e:	50                   	push   %eax
  80035f:	ff d3                	call   *%ebx
  800361:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800364:	83 c7 01             	add    $0x1,%edi
  800367:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80036b:	83 f8 25             	cmp    $0x25,%eax
  80036e:	74 0c                	je     80037c <vprintfmt+0x36>
			if (ch == '\0')
  800370:	85 c0                	test   %eax,%eax
  800372:	75 e6                	jne    80035a <vprintfmt+0x14>
}
  800374:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800377:	5b                   	pop    %ebx
  800378:	5e                   	pop    %esi
  800379:	5f                   	pop    %edi
  80037a:	5d                   	pop    %ebp
  80037b:	c3                   	ret    
		padc = ' ';
  80037c:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
		altflag = 0;
  800380:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800387:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80038e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800395:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80039a:	8d 47 01             	lea    0x1(%edi),%eax
  80039d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003a0:	0f b6 17             	movzbl (%edi),%edx
  8003a3:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003a6:	3c 55                	cmp    $0x55,%al
  8003a8:	0f 87 b7 02 00 00    	ja     800665 <vprintfmt+0x31f>
  8003ae:	0f b6 c0             	movzbl %al,%eax
  8003b1:	ff 24 85 c0 10 80 00 	jmp    *0x8010c0(,%eax,4)
  8003b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8003bb:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  8003bf:	eb d9                	jmp    80039a <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8003c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003c4:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  8003c8:	eb d0                	jmp    80039a <vprintfmt+0x54>
  8003ca:	0f b6 d2             	movzbl %dl,%edx
  8003cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0;; ++fmt) {
  8003d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8003d5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003d8:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003db:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003df:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003e2:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003e5:	83 f9 09             	cmp    $0x9,%ecx
  8003e8:	77 52                	ja     80043c <vprintfmt+0xf6>
			for (precision = 0;; ++fmt) {
  8003ea:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003ed:	eb e9                	jmp    8003d8 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  8003ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f2:	8d 50 04             	lea    0x4(%eax),%edx
  8003f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f8:	8b 00                	mov    (%eax),%eax
  8003fa:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800400:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800404:	79 94                	jns    80039a <vprintfmt+0x54>
				width = precision, precision = -1;
  800406:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800409:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80040c:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800413:	eb 85                	jmp    80039a <vprintfmt+0x54>
  800415:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800418:	85 d2                	test   %edx,%edx
  80041a:	b8 00 00 00 00       	mov    $0x0,%eax
  80041f:	0f 49 c2             	cmovns %edx,%eax
  800422:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800425:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800428:	e9 6d ff ff ff       	jmp    80039a <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80042d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800430:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800437:	e9 5e ff ff ff       	jmp    80039a <vprintfmt+0x54>
  80043c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80043f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800442:	eb bc                	jmp    800400 <vprintfmt+0xba>
			lflag++;
  800444:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800447:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80044a:	e9 4b ff ff ff       	jmp    80039a <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  80044f:	8b 45 14             	mov    0x14(%ebp),%eax
  800452:	8d 50 04             	lea    0x4(%eax),%edx
  800455:	89 55 14             	mov    %edx,0x14(%ebp)
  800458:	83 ec 08             	sub    $0x8,%esp
  80045b:	56                   	push   %esi
  80045c:	ff 30                	push   (%eax)
  80045e:	ff d3                	call   *%ebx
			break;
  800460:	83 c4 10             	add    $0x10,%esp
  800463:	e9 94 01 00 00       	jmp    8005fc <vprintfmt+0x2b6>
			err = va_arg(ap, int);
  800468:	8b 45 14             	mov    0x14(%ebp),%eax
  80046b:	8d 50 04             	lea    0x4(%eax),%edx
  80046e:	89 55 14             	mov    %edx,0x14(%ebp)
  800471:	8b 10                	mov    (%eax),%edx
  800473:	89 d0                	mov    %edx,%eax
  800475:	f7 d8                	neg    %eax
  800477:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80047a:	83 f8 08             	cmp    $0x8,%eax
  80047d:	7f 20                	jg     80049f <vprintfmt+0x159>
  80047f:	8b 14 85 20 12 80 00 	mov    0x801220(,%eax,4),%edx
  800486:	85 d2                	test   %edx,%edx
  800488:	74 15                	je     80049f <vprintfmt+0x159>
				printfmt(putch, putdat, "%s", p);
  80048a:	52                   	push   %edx
  80048b:	68 1c 10 80 00       	push   $0x80101c
  800490:	56                   	push   %esi
  800491:	53                   	push   %ebx
  800492:	e8 92 fe ff ff       	call   800329 <printfmt>
  800497:	83 c4 10             	add    $0x10,%esp
  80049a:	e9 5d 01 00 00       	jmp    8005fc <vprintfmt+0x2b6>
				printfmt(putch, putdat, "error %d", err);
  80049f:	50                   	push   %eax
  8004a0:	68 13 10 80 00       	push   $0x801013
  8004a5:	56                   	push   %esi
  8004a6:	53                   	push   %ebx
  8004a7:	e8 7d fe ff ff       	call   800329 <printfmt>
  8004ac:	83 c4 10             	add    $0x10,%esp
  8004af:	e9 48 01 00 00       	jmp    8005fc <vprintfmt+0x2b6>
			if ((p = va_arg(ap, char *)) == NULL)
  8004b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b7:	8d 50 04             	lea    0x4(%eax),%edx
  8004ba:	89 55 14             	mov    %edx,0x14(%ebp)
  8004bd:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004bf:	85 ff                	test   %edi,%edi
  8004c1:	b8 0c 10 80 00       	mov    $0x80100c,%eax
  8004c6:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004c9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004cd:	7e 06                	jle    8004d5 <vprintfmt+0x18f>
  8004cf:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8004d3:	75 0a                	jne    8004df <vprintfmt+0x199>
  8004d5:	89 f8                	mov    %edi,%eax
  8004d7:	03 45 e0             	add    -0x20(%ebp),%eax
  8004da:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004dd:	eb 59                	jmp    800538 <vprintfmt+0x1f2>
				for (width -= strnlen(p, precision); width > 0;
  8004df:	83 ec 08             	sub    $0x8,%esp
  8004e2:	ff 75 d8             	push   -0x28(%ebp)
  8004e5:	57                   	push   %edi
  8004e6:	e8 1a 02 00 00       	call   800705 <strnlen>
  8004eb:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004ee:	29 c1                	sub    %eax,%ecx
  8004f0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004f3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004f6:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  8004fa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004fd:	89 7d d0             	mov    %edi,-0x30(%ebp)
  800500:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0;
  800502:	eb 0f                	jmp    800513 <vprintfmt+0x1cd>
					putch(padc, putdat);
  800504:	83 ec 08             	sub    $0x8,%esp
  800507:	56                   	push   %esi
  800508:	ff 75 e0             	push   -0x20(%ebp)
  80050b:	ff d3                	call   *%ebx
				     width--)
  80050d:	83 ef 01             	sub    $0x1,%edi
  800510:	83 c4 10             	add    $0x10,%esp
				for (width -= strnlen(p, precision); width > 0;
  800513:	85 ff                	test   %edi,%edi
  800515:	7f ed                	jg     800504 <vprintfmt+0x1be>
  800517:	8b 7d d0             	mov    -0x30(%ebp),%edi
  80051a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80051d:	85 c9                	test   %ecx,%ecx
  80051f:	b8 00 00 00 00       	mov    $0x0,%eax
  800524:	0f 49 c1             	cmovns %ecx,%eax
  800527:	29 c1                	sub    %eax,%ecx
  800529:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80052c:	eb a7                	jmp    8004d5 <vprintfmt+0x18f>
					putch(ch, putdat);
  80052e:	83 ec 08             	sub    $0x8,%esp
  800531:	56                   	push   %esi
  800532:	52                   	push   %edx
  800533:	ff d3                	call   *%ebx
  800535:	83 c4 10             	add    $0x10,%esp
  800538:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80053b:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' &&
  80053d:	83 c7 01             	add    $0x1,%edi
  800540:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800544:	0f be d0             	movsbl %al,%edx
  800547:	85 d2                	test   %edx,%edx
  800549:	74 42                	je     80058d <vprintfmt+0x247>
  80054b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80054f:	78 06                	js     800557 <vprintfmt+0x211>
			       (precision < 0 || --precision >= 0);
  800551:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800555:	78 1e                	js     800575 <vprintfmt+0x22f>
				if (altflag && (ch < ' ' || ch > '~'))
  800557:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80055b:	74 d1                	je     80052e <vprintfmt+0x1e8>
  80055d:	0f be c0             	movsbl %al,%eax
  800560:	83 e8 20             	sub    $0x20,%eax
  800563:	83 f8 5e             	cmp    $0x5e,%eax
  800566:	76 c6                	jbe    80052e <vprintfmt+0x1e8>
					putch('?', putdat);
  800568:	83 ec 08             	sub    $0x8,%esp
  80056b:	56                   	push   %esi
  80056c:	6a 3f                	push   $0x3f
  80056e:	ff d3                	call   *%ebx
  800570:	83 c4 10             	add    $0x10,%esp
  800573:	eb c3                	jmp    800538 <vprintfmt+0x1f2>
  800575:	89 cf                	mov    %ecx,%edi
  800577:	eb 0e                	jmp    800587 <vprintfmt+0x241>
				putch(' ', putdat);
  800579:	83 ec 08             	sub    $0x8,%esp
  80057c:	56                   	push   %esi
  80057d:	6a 20                	push   $0x20
  80057f:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  800581:	83 ef 01             	sub    $0x1,%edi
  800584:	83 c4 10             	add    $0x10,%esp
  800587:	85 ff                	test   %edi,%edi
  800589:	7f ee                	jg     800579 <vprintfmt+0x233>
  80058b:	eb 6f                	jmp    8005fc <vprintfmt+0x2b6>
  80058d:	89 cf                	mov    %ecx,%edi
  80058f:	eb f6                	jmp    800587 <vprintfmt+0x241>
			num = getint(&ap, lflag);
  800591:	89 ca                	mov    %ecx,%edx
  800593:	8d 45 14             	lea    0x14(%ebp),%eax
  800596:	e8 45 fd ff ff       	call   8002e0 <getint>
  80059b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80059e:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  8005a1:	85 d2                	test   %edx,%edx
  8005a3:	78 0b                	js     8005b0 <vprintfmt+0x26a>
			num = getint(&ap, lflag);
  8005a5:	89 d1                	mov    %edx,%ecx
  8005a7:	89 c2                	mov    %eax,%edx
			base = 10;
  8005a9:	bf 0a 00 00 00       	mov    $0xa,%edi
  8005ae:	eb 32                	jmp    8005e2 <vprintfmt+0x29c>
				putch('-', putdat);
  8005b0:	83 ec 08             	sub    $0x8,%esp
  8005b3:	56                   	push   %esi
  8005b4:	6a 2d                	push   $0x2d
  8005b6:	ff d3                	call   *%ebx
				num = -(long long) num;
  8005b8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005bb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005be:	f7 da                	neg    %edx
  8005c0:	83 d1 00             	adc    $0x0,%ecx
  8005c3:	f7 d9                	neg    %ecx
  8005c5:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005c8:	bf 0a 00 00 00       	mov    $0xa,%edi
  8005cd:	eb 13                	jmp    8005e2 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  8005cf:	89 ca                	mov    %ecx,%edx
  8005d1:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d4:	e8 d3 fc ff ff       	call   8002ac <getuint>
  8005d9:	89 d1                	mov    %edx,%ecx
  8005db:	89 c2                	mov    %eax,%edx
			base = 10;
  8005dd:	bf 0a 00 00 00       	mov    $0xa,%edi
			printnum(putch, putdat, num, base, width, padc);
  8005e2:	83 ec 0c             	sub    $0xc,%esp
  8005e5:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  8005e9:	50                   	push   %eax
  8005ea:	ff 75 e0             	push   -0x20(%ebp)
  8005ed:	57                   	push   %edi
  8005ee:	51                   	push   %ecx
  8005ef:	52                   	push   %edx
  8005f0:	89 f2                	mov    %esi,%edx
  8005f2:	89 d8                	mov    %ebx,%eax
  8005f4:	e8 0a fc ff ff       	call   800203 <printnum>
			break;
  8005f9:	83 c4 20             	add    $0x20,%esp
{
  8005fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005ff:	e9 60 fd ff ff       	jmp    800364 <vprintfmt+0x1e>
			num = getuint(&ap, lflag);
  800604:	89 ca                	mov    %ecx,%edx
  800606:	8d 45 14             	lea    0x14(%ebp),%eax
  800609:	e8 9e fc ff ff       	call   8002ac <getuint>
  80060e:	89 d1                	mov    %edx,%ecx
  800610:	89 c2                	mov    %eax,%edx
			base = 8;
  800612:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  800617:	eb c9                	jmp    8005e2 <vprintfmt+0x29c>
			putch('0', putdat);
  800619:	83 ec 08             	sub    $0x8,%esp
  80061c:	56                   	push   %esi
  80061d:	6a 30                	push   $0x30
  80061f:	ff d3                	call   *%ebx
			putch('x', putdat);
  800621:	83 c4 08             	add    $0x8,%esp
  800624:	56                   	push   %esi
  800625:	6a 78                	push   $0x78
  800627:	ff d3                	call   *%ebx
			num = (unsigned long long) (uintptr_t) va_arg(ap, void *);
  800629:	8b 45 14             	mov    0x14(%ebp),%eax
  80062c:	8d 50 04             	lea    0x4(%eax),%edx
  80062f:	89 55 14             	mov    %edx,0x14(%ebp)
  800632:	8b 10                	mov    (%eax),%edx
  800634:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800639:	83 c4 10             	add    $0x10,%esp
			base = 16;
  80063c:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  800641:	eb 9f                	jmp    8005e2 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  800643:	89 ca                	mov    %ecx,%edx
  800645:	8d 45 14             	lea    0x14(%ebp),%eax
  800648:	e8 5f fc ff ff       	call   8002ac <getuint>
  80064d:	89 d1                	mov    %edx,%ecx
  80064f:	89 c2                	mov    %eax,%edx
			base = 16;
  800651:	bf 10 00 00 00       	mov    $0x10,%edi
  800656:	eb 8a                	jmp    8005e2 <vprintfmt+0x29c>
			putch(ch, putdat);
  800658:	83 ec 08             	sub    $0x8,%esp
  80065b:	56                   	push   %esi
  80065c:	6a 25                	push   $0x25
  80065e:	ff d3                	call   *%ebx
			break;
  800660:	83 c4 10             	add    $0x10,%esp
  800663:	eb 97                	jmp    8005fc <vprintfmt+0x2b6>
			putch('%', putdat);
  800665:	83 ec 08             	sub    $0x8,%esp
  800668:	56                   	push   %esi
  800669:	6a 25                	push   $0x25
  80066b:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  80066d:	83 c4 10             	add    $0x10,%esp
  800670:	89 f8                	mov    %edi,%eax
  800672:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800676:	74 05                	je     80067d <vprintfmt+0x337>
  800678:	83 e8 01             	sub    $0x1,%eax
  80067b:	eb f5                	jmp    800672 <vprintfmt+0x32c>
  80067d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800680:	e9 77 ff ff ff       	jmp    8005fc <vprintfmt+0x2b6>

00800685 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800685:	55                   	push   %ebp
  800686:	89 e5                	mov    %esp,%ebp
  800688:	83 ec 18             	sub    $0x18,%esp
  80068b:	8b 45 08             	mov    0x8(%ebp),%eax
  80068e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = { buf, buf + n - 1, 0 };
  800691:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800694:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800698:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80069b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006a2:	85 c0                	test   %eax,%eax
  8006a4:	74 26                	je     8006cc <vsnprintf+0x47>
  8006a6:	85 d2                	test   %edx,%edx
  8006a8:	7e 22                	jle    8006cc <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *) sprintputch, &b, fmt, ap);
  8006aa:	ff 75 14             	push   0x14(%ebp)
  8006ad:	ff 75 10             	push   0x10(%ebp)
  8006b0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006b3:	50                   	push   %eax
  8006b4:	68 0c 03 80 00       	push   $0x80030c
  8006b9:	e8 88 fc ff ff       	call   800346 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006be:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006c1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006c7:	83 c4 10             	add    $0x10,%esp
}
  8006ca:	c9                   	leave  
  8006cb:	c3                   	ret    
		return -E_INVAL;
  8006cc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006d1:	eb f7                	jmp    8006ca <vsnprintf+0x45>

008006d3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006d3:	55                   	push   %ebp
  8006d4:	89 e5                	mov    %esp,%ebp
  8006d6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006d9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006dc:	50                   	push   %eax
  8006dd:	ff 75 10             	push   0x10(%ebp)
  8006e0:	ff 75 0c             	push   0xc(%ebp)
  8006e3:	ff 75 08             	push   0x8(%ebp)
  8006e6:	e8 9a ff ff ff       	call   800685 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006eb:	c9                   	leave  
  8006ec:	c3                   	ret    

008006ed <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006ed:	55                   	push   %ebp
  8006ee:	89 e5                	mov    %esp,%ebp
  8006f0:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f8:	eb 03                	jmp    8006fd <strlen+0x10>
		n++;
  8006fa:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8006fd:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800701:	75 f7                	jne    8006fa <strlen+0xd>
	return n;
}
  800703:	5d                   	pop    %ebp
  800704:	c3                   	ret    

00800705 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800705:	55                   	push   %ebp
  800706:	89 e5                	mov    %esp,%ebp
  800708:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80070b:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80070e:	b8 00 00 00 00       	mov    $0x0,%eax
  800713:	eb 03                	jmp    800718 <strnlen+0x13>
		n++;
  800715:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800718:	39 d0                	cmp    %edx,%eax
  80071a:	74 08                	je     800724 <strnlen+0x1f>
  80071c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800720:	75 f3                	jne    800715 <strnlen+0x10>
  800722:	89 c2                	mov    %eax,%edx
	return n;
}
  800724:	89 d0                	mov    %edx,%eax
  800726:	5d                   	pop    %ebp
  800727:	c3                   	ret    

00800728 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800728:	55                   	push   %ebp
  800729:	89 e5                	mov    %esp,%ebp
  80072b:	53                   	push   %ebx
  80072c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80072f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800732:	b8 00 00 00 00       	mov    $0x0,%eax
  800737:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80073b:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  80073e:	83 c0 01             	add    $0x1,%eax
  800741:	84 d2                	test   %dl,%dl
  800743:	75 f2                	jne    800737 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800745:	89 c8                	mov    %ecx,%eax
  800747:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80074a:	c9                   	leave  
  80074b:	c3                   	ret    

0080074c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80074c:	55                   	push   %ebp
  80074d:	89 e5                	mov    %esp,%ebp
  80074f:	53                   	push   %ebx
  800750:	83 ec 10             	sub    $0x10,%esp
  800753:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800756:	53                   	push   %ebx
  800757:	e8 91 ff ff ff       	call   8006ed <strlen>
  80075c:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80075f:	ff 75 0c             	push   0xc(%ebp)
  800762:	01 d8                	add    %ebx,%eax
  800764:	50                   	push   %eax
  800765:	e8 be ff ff ff       	call   800728 <strcpy>
	return dst;
}
  80076a:	89 d8                	mov    %ebx,%eax
  80076c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80076f:	c9                   	leave  
  800770:	c3                   	ret    

00800771 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size)
{
  800771:	55                   	push   %ebp
  800772:	89 e5                	mov    %esp,%ebp
  800774:	56                   	push   %esi
  800775:	53                   	push   %ebx
  800776:	8b 75 08             	mov    0x8(%ebp),%esi
  800779:	8b 55 0c             	mov    0xc(%ebp),%edx
  80077c:	89 f3                	mov    %esi,%ebx
  80077e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800781:	89 f0                	mov    %esi,%eax
  800783:	eb 0f                	jmp    800794 <strncpy+0x23>
		*dst++ = *src;
  800785:	83 c0 01             	add    $0x1,%eax
  800788:	0f b6 0a             	movzbl (%edx),%ecx
  80078b:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80078e:	80 f9 01             	cmp    $0x1,%cl
  800791:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800794:	39 d8                	cmp    %ebx,%eax
  800796:	75 ed                	jne    800785 <strncpy+0x14>
	}
	return ret;
}
  800798:	89 f0                	mov    %esi,%eax
  80079a:	5b                   	pop    %ebx
  80079b:	5e                   	pop    %esi
  80079c:	5d                   	pop    %ebp
  80079d:	c3                   	ret    

0080079e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80079e:	55                   	push   %ebp
  80079f:	89 e5                	mov    %esp,%ebp
  8007a1:	56                   	push   %esi
  8007a2:	53                   	push   %ebx
  8007a3:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a9:	8b 55 10             	mov    0x10(%ebp),%edx
  8007ac:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007ae:	85 d2                	test   %edx,%edx
  8007b0:	74 21                	je     8007d3 <strlcpy+0x35>
  8007b2:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007b6:	89 f2                	mov    %esi,%edx
  8007b8:	eb 09                	jmp    8007c3 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007ba:	83 c1 01             	add    $0x1,%ecx
  8007bd:	83 c2 01             	add    $0x1,%edx
  8007c0:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  8007c3:	39 c2                	cmp    %eax,%edx
  8007c5:	74 09                	je     8007d0 <strlcpy+0x32>
  8007c7:	0f b6 19             	movzbl (%ecx),%ebx
  8007ca:	84 db                	test   %bl,%bl
  8007cc:	75 ec                	jne    8007ba <strlcpy+0x1c>
  8007ce:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8007d0:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007d3:	29 f0                	sub    %esi,%eax
}
  8007d5:	5b                   	pop    %ebx
  8007d6:	5e                   	pop    %esi
  8007d7:	5d                   	pop    %ebp
  8007d8:	c3                   	ret    

008007d9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007d9:	55                   	push   %ebp
  8007da:	89 e5                	mov    %esp,%ebp
  8007dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007df:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007e2:	eb 06                	jmp    8007ea <strcmp+0x11>
		p++, q++;
  8007e4:	83 c1 01             	add    $0x1,%ecx
  8007e7:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8007ea:	0f b6 01             	movzbl (%ecx),%eax
  8007ed:	84 c0                	test   %al,%al
  8007ef:	74 04                	je     8007f5 <strcmp+0x1c>
  8007f1:	3a 02                	cmp    (%edx),%al
  8007f3:	74 ef                	je     8007e4 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007f5:	0f b6 c0             	movzbl %al,%eax
  8007f8:	0f b6 12             	movzbl (%edx),%edx
  8007fb:	29 d0                	sub    %edx,%eax
}
  8007fd:	5d                   	pop    %ebp
  8007fe:	c3                   	ret    

008007ff <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007ff:	55                   	push   %ebp
  800800:	89 e5                	mov    %esp,%ebp
  800802:	53                   	push   %ebx
  800803:	8b 45 08             	mov    0x8(%ebp),%eax
  800806:	8b 55 0c             	mov    0xc(%ebp),%edx
  800809:	89 c3                	mov    %eax,%ebx
  80080b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80080e:	eb 06                	jmp    800816 <strncmp+0x17>
		n--, p++, q++;
  800810:	83 c0 01             	add    $0x1,%eax
  800813:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800816:	39 d8                	cmp    %ebx,%eax
  800818:	74 18                	je     800832 <strncmp+0x33>
  80081a:	0f b6 08             	movzbl (%eax),%ecx
  80081d:	84 c9                	test   %cl,%cl
  80081f:	74 04                	je     800825 <strncmp+0x26>
  800821:	3a 0a                	cmp    (%edx),%cl
  800823:	74 eb                	je     800810 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800825:	0f b6 00             	movzbl (%eax),%eax
  800828:	0f b6 12             	movzbl (%edx),%edx
  80082b:	29 d0                	sub    %edx,%eax
}
  80082d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800830:	c9                   	leave  
  800831:	c3                   	ret    
		return 0;
  800832:	b8 00 00 00 00       	mov    $0x0,%eax
  800837:	eb f4                	jmp    80082d <strncmp+0x2e>

00800839 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800839:	55                   	push   %ebp
  80083a:	89 e5                	mov    %esp,%ebp
  80083c:	8b 45 08             	mov    0x8(%ebp),%eax
  80083f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800843:	eb 03                	jmp    800848 <strchr+0xf>
  800845:	83 c0 01             	add    $0x1,%eax
  800848:	0f b6 10             	movzbl (%eax),%edx
  80084b:	84 d2                	test   %dl,%dl
  80084d:	74 06                	je     800855 <strchr+0x1c>
		if (*s == c)
  80084f:	38 ca                	cmp    %cl,%dl
  800851:	75 f2                	jne    800845 <strchr+0xc>
  800853:	eb 05                	jmp    80085a <strchr+0x21>
			return (char *) s;
	return 0;
  800855:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80085a:	5d                   	pop    %ebp
  80085b:	c3                   	ret    

0080085c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80085c:	55                   	push   %ebp
  80085d:	89 e5                	mov    %esp,%ebp
  80085f:	8b 45 08             	mov    0x8(%ebp),%eax
  800862:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800866:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800869:	38 ca                	cmp    %cl,%dl
  80086b:	74 09                	je     800876 <strfind+0x1a>
  80086d:	84 d2                	test   %dl,%dl
  80086f:	74 05                	je     800876 <strfind+0x1a>
	for (; *s; s++)
  800871:	83 c0 01             	add    $0x1,%eax
  800874:	eb f0                	jmp    800866 <strfind+0xa>
			break;
	return (char *) s;
}
  800876:	5d                   	pop    %ebp
  800877:	c3                   	ret    

00800878 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800878:	55                   	push   %ebp
  800879:	89 e5                	mov    %esp,%ebp
  80087b:	57                   	push   %edi
  80087c:	56                   	push   %esi
  80087d:	53                   	push   %ebx
  80087e:	8b 55 08             	mov    0x8(%ebp),%edx
  800881:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  800884:	85 c9                	test   %ecx,%ecx
  800886:	74 33                	je     8008bb <memset+0x43>
		return v;
	if ((int) v % 4 == 0 && n % 4 == 0) {
  800888:	89 d0                	mov    %edx,%eax
  80088a:	09 c8                	or     %ecx,%eax
  80088c:	a8 03                	test   $0x3,%al
  80088e:	75 23                	jne    8008b3 <memset+0x3b>
		c &= 0xFF;
  800890:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  800894:	89 d8                	mov    %ebx,%eax
  800896:	c1 e0 08             	shl    $0x8,%eax
  800899:	89 df                	mov    %ebx,%edi
  80089b:	c1 e7 18             	shl    $0x18,%edi
  80089e:	89 de                	mov    %ebx,%esi
  8008a0:	c1 e6 10             	shl    $0x10,%esi
  8008a3:	09 f7                	or     %esi,%edi
  8008a5:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
		             : "=D"(p), "=c"(n)
		             : "D"(p), "a"(c), "c"(n / 4)
  8008a7:	c1 e9 02             	shr    $0x2,%ecx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  8008aa:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  8008ac:	89 d7                	mov    %edx,%edi
  8008ae:	fc                   	cld    
  8008af:	f3 ab                	rep stos %eax,%es:(%edi)
  8008b1:	eb 08                	jmp    8008bb <memset+0x43>
		             : "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008b3:	89 d7                	mov    %edx,%edi
  8008b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008b8:	fc                   	cld    
  8008b9:	f3 aa                	rep stos %al,%es:(%edi)
		             : "=D"(p), "=c"(n)
		             : "0"(p), "a"(c), "1"(n)
		             : "cc", "memory");
	return v;
}
  8008bb:	89 d0                	mov    %edx,%eax
  8008bd:	5b                   	pop    %ebx
  8008be:	5e                   	pop    %esi
  8008bf:	5f                   	pop    %edi
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    

008008c2 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	57                   	push   %edi
  8008c6:	56                   	push   %esi
  8008c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ca:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008cd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008d0:	39 c6                	cmp    %eax,%esi
  8008d2:	73 32                	jae    800906 <memmove+0x44>
  8008d4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008d7:	39 c2                	cmp    %eax,%edx
  8008d9:	76 2b                	jbe    800906 <memmove+0x44>
		s += n;
		d += n;
  8008db:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  8008de:	89 d6                	mov    %edx,%esi
  8008e0:	09 fe                	or     %edi,%esi
  8008e2:	09 ce                	or     %ecx,%esi
  8008e4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008ea:	75 0e                	jne    8008fa <memmove+0x38>
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  8008ec:	83 ef 04             	sub    $0x4,%edi
			             "S"(s - 4),
  8008ef:	8d 72 fc             	lea    -0x4(%edx),%esi
			             "c"(n / 4)
  8008f2:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  8008f5:	fd                   	std    
  8008f6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008f8:	eb 09                	jmp    800903 <memmove+0x41>
			             : "cc", "memory");
		else
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  8008fa:	83 ef 01             	sub    $0x1,%edi
			             "S"(s - 1),
  8008fd:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  800900:	fd                   	std    
  800901:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             "c"(n)
			             : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800903:	fc                   	cld    
  800904:	eb 1a                	jmp    800920 <memmove+0x5e>
	} else {
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  800906:	89 f2                	mov    %esi,%edx
  800908:	09 c2                	or     %eax,%edx
  80090a:	09 ca                	or     %ecx,%edx
  80090c:	f6 c2 03             	test   $0x3,%dl
  80090f:	75 0a                	jne    80091b <memmove+0x59>
			asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800911:	c1 e9 02             	shr    $0x2,%ecx
  800914:	89 c7                	mov    %eax,%edi
  800916:	fc                   	cld    
  800917:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800919:	eb 05                	jmp    800920 <memmove+0x5e>
			             : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  80091b:	89 c7                	mov    %eax,%edi
  80091d:	fc                   	cld    
  80091e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             : "cc", "memory");
	}
	return dst;
}
  800920:	5e                   	pop    %esi
  800921:	5f                   	pop    %edi
  800922:	5d                   	pop    %ebp
  800923:	c3                   	ret    

00800924 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800924:	55                   	push   %ebp
  800925:	89 e5                	mov    %esp,%ebp
  800927:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80092a:	ff 75 10             	push   0x10(%ebp)
  80092d:	ff 75 0c             	push   0xc(%ebp)
  800930:	ff 75 08             	push   0x8(%ebp)
  800933:	e8 8a ff ff ff       	call   8008c2 <memmove>
}
  800938:	c9                   	leave  
  800939:	c3                   	ret    

0080093a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	56                   	push   %esi
  80093e:	53                   	push   %ebx
  80093f:	8b 45 08             	mov    0x8(%ebp),%eax
  800942:	8b 55 0c             	mov    0xc(%ebp),%edx
  800945:	89 c6                	mov    %eax,%esi
  800947:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80094a:	eb 06                	jmp    800952 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  80094c:	83 c0 01             	add    $0x1,%eax
  80094f:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800952:	39 f0                	cmp    %esi,%eax
  800954:	74 14                	je     80096a <memcmp+0x30>
		if (*s1 != *s2)
  800956:	0f b6 08             	movzbl (%eax),%ecx
  800959:	0f b6 1a             	movzbl (%edx),%ebx
  80095c:	38 d9                	cmp    %bl,%cl
  80095e:	74 ec                	je     80094c <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800960:	0f b6 c1             	movzbl %cl,%eax
  800963:	0f b6 db             	movzbl %bl,%ebx
  800966:	29 d8                	sub    %ebx,%eax
  800968:	eb 05                	jmp    80096f <memcmp+0x35>
	}

	return 0;
  80096a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80096f:	5b                   	pop    %ebx
  800970:	5e                   	pop    %esi
  800971:	5d                   	pop    %ebp
  800972:	c3                   	ret    

00800973 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800973:	55                   	push   %ebp
  800974:	89 e5                	mov    %esp,%ebp
  800976:	8b 45 08             	mov    0x8(%ebp),%eax
  800979:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80097c:	89 c2                	mov    %eax,%edx
  80097e:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800981:	eb 03                	jmp    800986 <memfind+0x13>
  800983:	83 c0 01             	add    $0x1,%eax
  800986:	39 d0                	cmp    %edx,%eax
  800988:	73 04                	jae    80098e <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  80098a:	38 08                	cmp    %cl,(%eax)
  80098c:	75 f5                	jne    800983 <memfind+0x10>
			break;
	return (void *) s;
}
  80098e:	5d                   	pop    %ebp
  80098f:	c3                   	ret    

00800990 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800990:	55                   	push   %ebp
  800991:	89 e5                	mov    %esp,%ebp
  800993:	57                   	push   %edi
  800994:	56                   	push   %esi
  800995:	53                   	push   %ebx
  800996:	8b 55 08             	mov    0x8(%ebp),%edx
  800999:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80099c:	eb 03                	jmp    8009a1 <strtol+0x11>
		s++;
  80099e:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  8009a1:	0f b6 02             	movzbl (%edx),%eax
  8009a4:	3c 20                	cmp    $0x20,%al
  8009a6:	74 f6                	je     80099e <strtol+0xe>
  8009a8:	3c 09                	cmp    $0x9,%al
  8009aa:	74 f2                	je     80099e <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8009ac:	3c 2b                	cmp    $0x2b,%al
  8009ae:	74 2a                	je     8009da <strtol+0x4a>
	int neg = 0;
  8009b0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8009b5:	3c 2d                	cmp    $0x2d,%al
  8009b7:	74 2b                	je     8009e4 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009b9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009bf:	75 0f                	jne    8009d0 <strtol+0x40>
  8009c1:	80 3a 30             	cmpb   $0x30,(%edx)
  8009c4:	74 28                	je     8009ee <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009c6:	85 db                	test   %ebx,%ebx
  8009c8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009cd:	0f 44 d8             	cmove  %eax,%ebx
  8009d0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009d5:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8009d8:	eb 46                	jmp    800a20 <strtol+0x90>
		s++;
  8009da:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  8009dd:	bf 00 00 00 00       	mov    $0x0,%edi
  8009e2:	eb d5                	jmp    8009b9 <strtol+0x29>
		s++, neg = 1;
  8009e4:	83 c2 01             	add    $0x1,%edx
  8009e7:	bf 01 00 00 00       	mov    $0x1,%edi
  8009ec:	eb cb                	jmp    8009b9 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009ee:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009f2:	74 0e                	je     800a02 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  8009f4:	85 db                	test   %ebx,%ebx
  8009f6:	75 d8                	jne    8009d0 <strtol+0x40>
		s++, base = 8;
  8009f8:	83 c2 01             	add    $0x1,%edx
  8009fb:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a00:	eb ce                	jmp    8009d0 <strtol+0x40>
		s += 2, base = 16;
  800a02:	83 c2 02             	add    $0x2,%edx
  800a05:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a0a:	eb c4                	jmp    8009d0 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a0c:	0f be c0             	movsbl %al,%eax
  800a0f:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a12:	3b 45 10             	cmp    0x10(%ebp),%eax
  800a15:	7d 3a                	jge    800a51 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800a17:	83 c2 01             	add    $0x1,%edx
  800a1a:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800a1e:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800a20:	0f b6 02             	movzbl (%edx),%eax
  800a23:	8d 70 d0             	lea    -0x30(%eax),%esi
  800a26:	89 f3                	mov    %esi,%ebx
  800a28:	80 fb 09             	cmp    $0x9,%bl
  800a2b:	76 df                	jbe    800a0c <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800a2d:	8d 70 9f             	lea    -0x61(%eax),%esi
  800a30:	89 f3                	mov    %esi,%ebx
  800a32:	80 fb 19             	cmp    $0x19,%bl
  800a35:	77 08                	ja     800a3f <strtol+0xaf>
			dig = *s - 'a' + 10;
  800a37:	0f be c0             	movsbl %al,%eax
  800a3a:	83 e8 57             	sub    $0x57,%eax
  800a3d:	eb d3                	jmp    800a12 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800a3f:	8d 70 bf             	lea    -0x41(%eax),%esi
  800a42:	89 f3                	mov    %esi,%ebx
  800a44:	80 fb 19             	cmp    $0x19,%bl
  800a47:	77 08                	ja     800a51 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800a49:	0f be c0             	movsbl %al,%eax
  800a4c:	83 e8 37             	sub    $0x37,%eax
  800a4f:	eb c1                	jmp    800a12 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a51:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a55:	74 05                	je     800a5c <strtol+0xcc>
		*endptr = (char *) s;
  800a57:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a5a:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800a5c:	89 c8                	mov    %ecx,%eax
  800a5e:	f7 d8                	neg    %eax
  800a60:	85 ff                	test   %edi,%edi
  800a62:	0f 45 c8             	cmovne %eax,%ecx
}
  800a65:	89 c8                	mov    %ecx,%eax
  800a67:	5b                   	pop    %ebx
  800a68:	5e                   	pop    %esi
  800a69:	5f                   	pop    %edi
  800a6a:	5d                   	pop    %ebp
  800a6b:	c3                   	ret    

00800a6c <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	57                   	push   %edi
  800a70:	56                   	push   %esi
  800a71:	53                   	push   %ebx
  800a72:	83 ec 1c             	sub    $0x1c,%esp
  800a75:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a78:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800a7b:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile(
  800a7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a80:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a83:	8b 7d 10             	mov    0x10(%ebp),%edi
  800a86:	8b 75 14             	mov    0x14(%ebp),%esi
  800a89:	cd 30                	int    $0x30
	        "int %1\n"
	        : "=a"(ret)
	        : "i"(T_SYSCALL), "a"(num), "d"(a1), "c"(a2), "b"(a3), "D"(a4), "S"(a5)
	        : "cc", "memory");

	if (check && ret > 0)
  800a8b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a8f:	74 04                	je     800a95 <syscall+0x29>
  800a91:	85 c0                	test   %eax,%eax
  800a93:	7f 08                	jg     800a9d <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800a95:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a98:	5b                   	pop    %ebx
  800a99:	5e                   	pop    %esi
  800a9a:	5f                   	pop    %edi
  800a9b:	5d                   	pop    %ebp
  800a9c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800a9d:	83 ec 0c             	sub    $0xc,%esp
  800aa0:	50                   	push   %eax
  800aa1:	ff 75 e0             	push   -0x20(%ebp)
  800aa4:	68 44 12 80 00       	push   $0x801244
  800aa9:	6a 1e                	push   $0x1e
  800aab:	68 61 12 80 00       	push   $0x801261
  800ab0:	e8 5f f6 ff ff       	call   800114 <_panic>

00800ab5 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800ab5:	55                   	push   %ebp
  800ab6:	89 e5                	mov    %esp,%ebp
  800ab8:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t) s, len, 0, 0, 0);
  800abb:	6a 00                	push   $0x0
  800abd:	6a 00                	push   $0x0
  800abf:	6a 00                	push   $0x0
  800ac1:	ff 75 0c             	push   0xc(%ebp)
  800ac4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ac7:	ba 00 00 00 00       	mov    $0x0,%edx
  800acc:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad1:	e8 96 ff ff ff       	call   800a6c <syscall>
}
  800ad6:	83 c4 10             	add    $0x10,%esp
  800ad9:	c9                   	leave  
  800ada:	c3                   	ret    

00800adb <sys_cgetc>:

int
sys_cgetc(void)
{
  800adb:	55                   	push   %ebp
  800adc:	89 e5                	mov    %esp,%ebp
  800ade:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800ae1:	6a 00                	push   $0x0
  800ae3:	6a 00                	push   $0x0
  800ae5:	6a 00                	push   $0x0
  800ae7:	6a 00                	push   $0x0
  800ae9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aee:	ba 00 00 00 00       	mov    $0x0,%edx
  800af3:	b8 01 00 00 00       	mov    $0x1,%eax
  800af8:	e8 6f ff ff ff       	call   800a6c <syscall>
}
  800afd:	c9                   	leave  
  800afe:	c3                   	ret    

00800aff <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aff:	55                   	push   %ebp
  800b00:	89 e5                	mov    %esp,%ebp
  800b02:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800b05:	6a 00                	push   $0x0
  800b07:	6a 00                	push   $0x0
  800b09:	6a 00                	push   $0x0
  800b0b:	6a 00                	push   $0x0
  800b0d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b10:	ba 01 00 00 00       	mov    $0x1,%edx
  800b15:	b8 03 00 00 00       	mov    $0x3,%eax
  800b1a:	e8 4d ff ff ff       	call   800a6c <syscall>
}
  800b1f:	c9                   	leave  
  800b20:	c3                   	ret    

00800b21 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b21:	55                   	push   %ebp
  800b22:	89 e5                	mov    %esp,%ebp
  800b24:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800b27:	6a 00                	push   $0x0
  800b29:	6a 00                	push   $0x0
  800b2b:	6a 00                	push   $0x0
  800b2d:	6a 00                	push   $0x0
  800b2f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b34:	ba 00 00 00 00       	mov    $0x0,%edx
  800b39:	b8 02 00 00 00       	mov    $0x2,%eax
  800b3e:	e8 29 ff ff ff       	call   800a6c <syscall>
}
  800b43:	c9                   	leave  
  800b44:	c3                   	ret    

00800b45 <sys_yield>:

void
sys_yield(void)
{
  800b45:	55                   	push   %ebp
  800b46:	89 e5                	mov    %esp,%ebp
  800b48:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800b4b:	6a 00                	push   $0x0
  800b4d:	6a 00                	push   $0x0
  800b4f:	6a 00                	push   $0x0
  800b51:	6a 00                	push   $0x0
  800b53:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b58:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b62:	e8 05 ff ff ff       	call   800a6c <syscall>
}
  800b67:	83 c4 10             	add    $0x10,%esp
  800b6a:	c9                   	leave  
  800b6b:	c3                   	ret    

00800b6c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800b72:	6a 00                	push   $0x0
  800b74:	6a 00                	push   $0x0
  800b76:	ff 75 10             	push   0x10(%ebp)
  800b79:	ff 75 0c             	push   0xc(%ebp)
  800b7c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b7f:	ba 01 00 00 00       	mov    $0x1,%edx
  800b84:	b8 04 00 00 00       	mov    $0x4,%eax
  800b89:	e8 de fe ff ff       	call   800a6c <syscall>
}
  800b8e:	c9                   	leave  
  800b8f:	c3                   	ret    

00800b90 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b90:	55                   	push   %ebp
  800b91:	89 e5                	mov    %esp,%ebp
  800b93:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map,
  800b96:	ff 75 18             	push   0x18(%ebp)
  800b99:	ff 75 14             	push   0x14(%ebp)
  800b9c:	ff 75 10             	push   0x10(%ebp)
  800b9f:	ff 75 0c             	push   0xc(%ebp)
  800ba2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ba5:	ba 01 00 00 00       	mov    $0x1,%edx
  800baa:	b8 05 00 00 00       	mov    $0x5,%eax
  800baf:	e8 b8 fe ff ff       	call   800a6c <syscall>
	               srcenv,
	               (uint32_t) srcva,
	               dstenv,
	               (uint32_t) dstva,
	               perm);
}
  800bb4:	c9                   	leave  
  800bb5:	c3                   	ret    

00800bb6 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bb6:	55                   	push   %ebp
  800bb7:	89 e5                	mov    %esp,%ebp
  800bb9:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800bbc:	6a 00                	push   $0x0
  800bbe:	6a 00                	push   $0x0
  800bc0:	6a 00                	push   $0x0
  800bc2:	ff 75 0c             	push   0xc(%ebp)
  800bc5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bc8:	ba 01 00 00 00       	mov    $0x1,%edx
  800bcd:	b8 06 00 00 00       	mov    $0x6,%eax
  800bd2:	e8 95 fe ff ff       	call   800a6c <syscall>
}
  800bd7:	c9                   	leave  
  800bd8:	c3                   	ret    

00800bd9 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bd9:	55                   	push   %ebp
  800bda:	89 e5                	mov    %esp,%ebp
  800bdc:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800bdf:	6a 00                	push   $0x0
  800be1:	6a 00                	push   $0x0
  800be3:	6a 00                	push   $0x0
  800be5:	ff 75 0c             	push   0xc(%ebp)
  800be8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800beb:	ba 01 00 00 00       	mov    $0x1,%edx
  800bf0:	b8 08 00 00 00       	mov    $0x8,%eax
  800bf5:	e8 72 fe ff ff       	call   800a6c <syscall>
}
  800bfa:	c9                   	leave  
  800bfb:	c3                   	ret    

00800bfc <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	83 ec 08             	sub    $0x8,%esp
	return syscall(
  800c02:	6a 00                	push   $0x0
  800c04:	6a 00                	push   $0x0
  800c06:	6a 00                	push   $0x0
  800c08:	ff 75 0c             	push   0xc(%ebp)
  800c0b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c0e:	ba 01 00 00 00       	mov    $0x1,%edx
  800c13:	b8 09 00 00 00       	mov    $0x9,%eax
  800c18:	e8 4f fe ff ff       	call   800a6c <syscall>
	        SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c1d:	c9                   	leave  
  800c1e:	c3                   	ret    

00800c1f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c1f:	55                   	push   %ebp
  800c20:	89 e5                	mov    %esp,%ebp
  800c22:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800c25:	6a 00                	push   $0x0
  800c27:	ff 75 14             	push   0x14(%ebp)
  800c2a:	ff 75 10             	push   0x10(%ebp)
  800c2d:	ff 75 0c             	push   0xc(%ebp)
  800c30:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c33:	ba 00 00 00 00       	mov    $0x0,%edx
  800c38:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c3d:	e8 2a fe ff ff       	call   800a6c <syscall>
}
  800c42:	c9                   	leave  
  800c43:	c3                   	ret    

00800c44 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c44:	55                   	push   %ebp
  800c45:	89 e5                	mov    %esp,%ebp
  800c47:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t) dstva, 0, 0, 0, 0);
  800c4a:	6a 00                	push   $0x0
  800c4c:	6a 00                	push   $0x0
  800c4e:	6a 00                	push   $0x0
  800c50:	6a 00                	push   $0x0
  800c52:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c55:	ba 01 00 00 00       	mov    $0x1,%edx
  800c5a:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c5f:	e8 08 fe ff ff       	call   800a6c <syscall>
}
  800c64:	c9                   	leave  
  800c65:	c3                   	ret    

00800c66 <sys_get_priority>:

// Get priority of the current process
int
sys_get_priority(void)
{
  800c66:	55                   	push   %ebp
  800c67:	89 e5                	mov    %esp,%ebp
  800c69:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_get_priority, 0, 0, 0, 0, 0, 0);
  800c6c:	6a 00                	push   $0x0
  800c6e:	6a 00                	push   $0x0
  800c70:	6a 00                	push   $0x0
  800c72:	6a 00                	push   $0x0
  800c74:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c79:	ba 00 00 00 00       	mov    $0x0,%edx
  800c7e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800c83:	e8 e4 fd ff ff       	call   800a6c <syscall>
}
  800c88:	c9                   	leave  
  800c89:	c3                   	ret    

00800c8a <sys_set_priority>:

// Get priority of the current process
int
sys_set_priority(unsigned int priority)
{
  800c8a:	55                   	push   %ebp
  800c8b:	89 e5                	mov    %esp,%ebp
  800c8d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, (uint32_t) priority, 0, 0, 0, 0);
  800c90:	6a 00                	push   $0x0
  800c92:	6a 00                	push   $0x0
  800c94:	6a 00                	push   $0x0
  800c96:	6a 00                	push   $0x0
  800c98:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c9b:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca0:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ca5:	e8 c2 fd ff ff       	call   800a6c <syscall>
}
  800caa:	c9                   	leave  
  800cab:	c3                   	ret    

00800cac <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800cac:	55                   	push   %ebp
  800cad:	89 e5                	mov    %esp,%ebp
  800caf:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800cb2:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800cb9:	74 0a                	je     800cc5 <set_pgfault_handler+0x19>
		if (r < 0)
			return;
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800cbb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbe:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800cc3:	c9                   	leave  
  800cc4:	c3                   	ret    
		r = sys_page_alloc(0, (void *) exstk, perm);
  800cc5:	83 ec 04             	sub    $0x4,%esp
  800cc8:	6a 07                	push   $0x7
  800cca:	68 00 f0 bf ee       	push   $0xeebff000
  800ccf:	6a 00                	push   $0x0
  800cd1:	e8 96 fe ff ff       	call   800b6c <sys_page_alloc>
		if (r < 0)
  800cd6:	83 c4 10             	add    $0x10,%esp
  800cd9:	85 c0                	test   %eax,%eax
  800cdb:	78 e6                	js     800cc3 <set_pgfault_handler+0x17>
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  800cdd:	83 ec 08             	sub    $0x8,%esp
  800ce0:	68 f5 0c 80 00       	push   $0x800cf5
  800ce5:	6a 00                	push   $0x0
  800ce7:	e8 10 ff ff ff       	call   800bfc <sys_env_set_pgfault_upcall>
		if (r < 0)
  800cec:	83 c4 10             	add    $0x10,%esp
  800cef:	85 c0                	test   %eax,%eax
  800cf1:	79 c8                	jns    800cbb <set_pgfault_handler+0xf>
  800cf3:	eb ce                	jmp    800cc3 <set_pgfault_handler+0x17>

00800cf5 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800cf5:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800cf6:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800cfb:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800cfd:	83 c4 04             	add    $0x4,%esp
	// Throughout the remaining code, think carefully about what
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	movl 40(%esp), %eax	// trap-time %epi -> %eax 
  800d00:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %ebx	// trap-time %esp -> %ebx
  800d04:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4, %ebx
  800d08:	83 eb 04             	sub    $0x4,%ebx
	movl %eax, 0(%ebx)	// push %eip in trap-time stack
  800d0b:	89 03                	mov    %eax,(%ebx)

	movl %ebx, 48(%esp)
  800d0d:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	popl %eax
  800d11:	58                   	pop    %eax
	popl %eax
  800d12:	58                   	pop    %eax
	popal
  800d13:	61                   	popa   
	

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	addl $4, %esp
  800d14:	83 c4 04             	add    $0x4,%esp
	popfl
  800d17:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	popl %esp
  800d18:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	ret
  800d19:	c3                   	ret    
  800d1a:	66 90                	xchg   %ax,%ax
  800d1c:	66 90                	xchg   %ax,%ax
  800d1e:	66 90                	xchg   %ax,%ax

00800d20 <__udivdi3>:
  800d20:	f3 0f 1e fb          	endbr32 
  800d24:	55                   	push   %ebp
  800d25:	57                   	push   %edi
  800d26:	56                   	push   %esi
  800d27:	53                   	push   %ebx
  800d28:	83 ec 1c             	sub    $0x1c,%esp
  800d2b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800d2f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800d33:	8b 74 24 34          	mov    0x34(%esp),%esi
  800d37:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800d3b:	85 c0                	test   %eax,%eax
  800d3d:	75 19                	jne    800d58 <__udivdi3+0x38>
  800d3f:	39 f3                	cmp    %esi,%ebx
  800d41:	76 4d                	jbe    800d90 <__udivdi3+0x70>
  800d43:	31 ff                	xor    %edi,%edi
  800d45:	89 e8                	mov    %ebp,%eax
  800d47:	89 f2                	mov    %esi,%edx
  800d49:	f7 f3                	div    %ebx
  800d4b:	89 fa                	mov    %edi,%edx
  800d4d:	83 c4 1c             	add    $0x1c,%esp
  800d50:	5b                   	pop    %ebx
  800d51:	5e                   	pop    %esi
  800d52:	5f                   	pop    %edi
  800d53:	5d                   	pop    %ebp
  800d54:	c3                   	ret    
  800d55:	8d 76 00             	lea    0x0(%esi),%esi
  800d58:	39 f0                	cmp    %esi,%eax
  800d5a:	76 14                	jbe    800d70 <__udivdi3+0x50>
  800d5c:	31 ff                	xor    %edi,%edi
  800d5e:	31 c0                	xor    %eax,%eax
  800d60:	89 fa                	mov    %edi,%edx
  800d62:	83 c4 1c             	add    $0x1c,%esp
  800d65:	5b                   	pop    %ebx
  800d66:	5e                   	pop    %esi
  800d67:	5f                   	pop    %edi
  800d68:	5d                   	pop    %ebp
  800d69:	c3                   	ret    
  800d6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d70:	0f bd f8             	bsr    %eax,%edi
  800d73:	83 f7 1f             	xor    $0x1f,%edi
  800d76:	75 48                	jne    800dc0 <__udivdi3+0xa0>
  800d78:	39 f0                	cmp    %esi,%eax
  800d7a:	72 06                	jb     800d82 <__udivdi3+0x62>
  800d7c:	31 c0                	xor    %eax,%eax
  800d7e:	39 eb                	cmp    %ebp,%ebx
  800d80:	77 de                	ja     800d60 <__udivdi3+0x40>
  800d82:	b8 01 00 00 00       	mov    $0x1,%eax
  800d87:	eb d7                	jmp    800d60 <__udivdi3+0x40>
  800d89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d90:	89 d9                	mov    %ebx,%ecx
  800d92:	85 db                	test   %ebx,%ebx
  800d94:	75 0b                	jne    800da1 <__udivdi3+0x81>
  800d96:	b8 01 00 00 00       	mov    $0x1,%eax
  800d9b:	31 d2                	xor    %edx,%edx
  800d9d:	f7 f3                	div    %ebx
  800d9f:	89 c1                	mov    %eax,%ecx
  800da1:	31 d2                	xor    %edx,%edx
  800da3:	89 f0                	mov    %esi,%eax
  800da5:	f7 f1                	div    %ecx
  800da7:	89 c6                	mov    %eax,%esi
  800da9:	89 e8                	mov    %ebp,%eax
  800dab:	89 f7                	mov    %esi,%edi
  800dad:	f7 f1                	div    %ecx
  800daf:	89 fa                	mov    %edi,%edx
  800db1:	83 c4 1c             	add    $0x1c,%esp
  800db4:	5b                   	pop    %ebx
  800db5:	5e                   	pop    %esi
  800db6:	5f                   	pop    %edi
  800db7:	5d                   	pop    %ebp
  800db8:	c3                   	ret    
  800db9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800dc0:	89 f9                	mov    %edi,%ecx
  800dc2:	ba 20 00 00 00       	mov    $0x20,%edx
  800dc7:	29 fa                	sub    %edi,%edx
  800dc9:	d3 e0                	shl    %cl,%eax
  800dcb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800dcf:	89 d1                	mov    %edx,%ecx
  800dd1:	89 d8                	mov    %ebx,%eax
  800dd3:	d3 e8                	shr    %cl,%eax
  800dd5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800dd9:	09 c1                	or     %eax,%ecx
  800ddb:	89 f0                	mov    %esi,%eax
  800ddd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800de1:	89 f9                	mov    %edi,%ecx
  800de3:	d3 e3                	shl    %cl,%ebx
  800de5:	89 d1                	mov    %edx,%ecx
  800de7:	d3 e8                	shr    %cl,%eax
  800de9:	89 f9                	mov    %edi,%ecx
  800deb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800def:	89 eb                	mov    %ebp,%ebx
  800df1:	d3 e6                	shl    %cl,%esi
  800df3:	89 d1                	mov    %edx,%ecx
  800df5:	d3 eb                	shr    %cl,%ebx
  800df7:	09 f3                	or     %esi,%ebx
  800df9:	89 c6                	mov    %eax,%esi
  800dfb:	89 f2                	mov    %esi,%edx
  800dfd:	89 d8                	mov    %ebx,%eax
  800dff:	f7 74 24 08          	divl   0x8(%esp)
  800e03:	89 d6                	mov    %edx,%esi
  800e05:	89 c3                	mov    %eax,%ebx
  800e07:	f7 64 24 0c          	mull   0xc(%esp)
  800e0b:	39 d6                	cmp    %edx,%esi
  800e0d:	72 19                	jb     800e28 <__udivdi3+0x108>
  800e0f:	89 f9                	mov    %edi,%ecx
  800e11:	d3 e5                	shl    %cl,%ebp
  800e13:	39 c5                	cmp    %eax,%ebp
  800e15:	73 04                	jae    800e1b <__udivdi3+0xfb>
  800e17:	39 d6                	cmp    %edx,%esi
  800e19:	74 0d                	je     800e28 <__udivdi3+0x108>
  800e1b:	89 d8                	mov    %ebx,%eax
  800e1d:	31 ff                	xor    %edi,%edi
  800e1f:	e9 3c ff ff ff       	jmp    800d60 <__udivdi3+0x40>
  800e24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e28:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800e2b:	31 ff                	xor    %edi,%edi
  800e2d:	e9 2e ff ff ff       	jmp    800d60 <__udivdi3+0x40>
  800e32:	66 90                	xchg   %ax,%ax
  800e34:	66 90                	xchg   %ax,%ax
  800e36:	66 90                	xchg   %ax,%ax
  800e38:	66 90                	xchg   %ax,%ax
  800e3a:	66 90                	xchg   %ax,%ax
  800e3c:	66 90                	xchg   %ax,%ax
  800e3e:	66 90                	xchg   %ax,%ax

00800e40 <__umoddi3>:
  800e40:	f3 0f 1e fb          	endbr32 
  800e44:	55                   	push   %ebp
  800e45:	57                   	push   %edi
  800e46:	56                   	push   %esi
  800e47:	53                   	push   %ebx
  800e48:	83 ec 1c             	sub    $0x1c,%esp
  800e4b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800e4f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800e53:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  800e57:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  800e5b:	89 f0                	mov    %esi,%eax
  800e5d:	89 da                	mov    %ebx,%edx
  800e5f:	85 ff                	test   %edi,%edi
  800e61:	75 15                	jne    800e78 <__umoddi3+0x38>
  800e63:	39 dd                	cmp    %ebx,%ebp
  800e65:	76 39                	jbe    800ea0 <__umoddi3+0x60>
  800e67:	f7 f5                	div    %ebp
  800e69:	89 d0                	mov    %edx,%eax
  800e6b:	31 d2                	xor    %edx,%edx
  800e6d:	83 c4 1c             	add    $0x1c,%esp
  800e70:	5b                   	pop    %ebx
  800e71:	5e                   	pop    %esi
  800e72:	5f                   	pop    %edi
  800e73:	5d                   	pop    %ebp
  800e74:	c3                   	ret    
  800e75:	8d 76 00             	lea    0x0(%esi),%esi
  800e78:	39 df                	cmp    %ebx,%edi
  800e7a:	77 f1                	ja     800e6d <__umoddi3+0x2d>
  800e7c:	0f bd cf             	bsr    %edi,%ecx
  800e7f:	83 f1 1f             	xor    $0x1f,%ecx
  800e82:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800e86:	75 40                	jne    800ec8 <__umoddi3+0x88>
  800e88:	39 df                	cmp    %ebx,%edi
  800e8a:	72 04                	jb     800e90 <__umoddi3+0x50>
  800e8c:	39 f5                	cmp    %esi,%ebp
  800e8e:	77 dd                	ja     800e6d <__umoddi3+0x2d>
  800e90:	89 da                	mov    %ebx,%edx
  800e92:	89 f0                	mov    %esi,%eax
  800e94:	29 e8                	sub    %ebp,%eax
  800e96:	19 fa                	sbb    %edi,%edx
  800e98:	eb d3                	jmp    800e6d <__umoddi3+0x2d>
  800e9a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ea0:	89 e9                	mov    %ebp,%ecx
  800ea2:	85 ed                	test   %ebp,%ebp
  800ea4:	75 0b                	jne    800eb1 <__umoddi3+0x71>
  800ea6:	b8 01 00 00 00       	mov    $0x1,%eax
  800eab:	31 d2                	xor    %edx,%edx
  800ead:	f7 f5                	div    %ebp
  800eaf:	89 c1                	mov    %eax,%ecx
  800eb1:	89 d8                	mov    %ebx,%eax
  800eb3:	31 d2                	xor    %edx,%edx
  800eb5:	f7 f1                	div    %ecx
  800eb7:	89 f0                	mov    %esi,%eax
  800eb9:	f7 f1                	div    %ecx
  800ebb:	89 d0                	mov    %edx,%eax
  800ebd:	31 d2                	xor    %edx,%edx
  800ebf:	eb ac                	jmp    800e6d <__umoddi3+0x2d>
  800ec1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ec8:	8b 44 24 04          	mov    0x4(%esp),%eax
  800ecc:	ba 20 00 00 00       	mov    $0x20,%edx
  800ed1:	29 c2                	sub    %eax,%edx
  800ed3:	89 c1                	mov    %eax,%ecx
  800ed5:	89 e8                	mov    %ebp,%eax
  800ed7:	d3 e7                	shl    %cl,%edi
  800ed9:	89 d1                	mov    %edx,%ecx
  800edb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800edf:	d3 e8                	shr    %cl,%eax
  800ee1:	89 c1                	mov    %eax,%ecx
  800ee3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800ee7:	09 f9                	or     %edi,%ecx
  800ee9:	89 df                	mov    %ebx,%edi
  800eeb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800eef:	89 c1                	mov    %eax,%ecx
  800ef1:	d3 e5                	shl    %cl,%ebp
  800ef3:	89 d1                	mov    %edx,%ecx
  800ef5:	d3 ef                	shr    %cl,%edi
  800ef7:	89 c1                	mov    %eax,%ecx
  800ef9:	89 f0                	mov    %esi,%eax
  800efb:	d3 e3                	shl    %cl,%ebx
  800efd:	89 d1                	mov    %edx,%ecx
  800eff:	89 fa                	mov    %edi,%edx
  800f01:	d3 e8                	shr    %cl,%eax
  800f03:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f08:	09 d8                	or     %ebx,%eax
  800f0a:	f7 74 24 08          	divl   0x8(%esp)
  800f0e:	89 d3                	mov    %edx,%ebx
  800f10:	d3 e6                	shl    %cl,%esi
  800f12:	f7 e5                	mul    %ebp
  800f14:	89 c7                	mov    %eax,%edi
  800f16:	89 d1                	mov    %edx,%ecx
  800f18:	39 d3                	cmp    %edx,%ebx
  800f1a:	72 06                	jb     800f22 <__umoddi3+0xe2>
  800f1c:	75 0e                	jne    800f2c <__umoddi3+0xec>
  800f1e:	39 c6                	cmp    %eax,%esi
  800f20:	73 0a                	jae    800f2c <__umoddi3+0xec>
  800f22:	29 e8                	sub    %ebp,%eax
  800f24:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800f28:	89 d1                	mov    %edx,%ecx
  800f2a:	89 c7                	mov    %eax,%edi
  800f2c:	89 f5                	mov    %esi,%ebp
  800f2e:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f32:	29 fd                	sub    %edi,%ebp
  800f34:	19 cb                	sbb    %ecx,%ebx
  800f36:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800f3b:	89 d8                	mov    %ebx,%eax
  800f3d:	d3 e0                	shl    %cl,%eax
  800f3f:	89 f1                	mov    %esi,%ecx
  800f41:	d3 ed                	shr    %cl,%ebp
  800f43:	d3 eb                	shr    %cl,%ebx
  800f45:	09 e8                	or     %ebp,%eax
  800f47:	89 da                	mov    %ebx,%edx
  800f49:	83 c4 1c             	add    $0x1c,%esp
  800f4c:	5b                   	pop    %ebx
  800f4d:	5e                   	pop    %esi
  800f4e:	5f                   	pop    %edi
  800f4f:	5d                   	pop    %ebp
  800f50:	c3                   	ret    
