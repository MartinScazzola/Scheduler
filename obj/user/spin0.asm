
obj/user/spin0:     formato del fichero elf32-i386


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
  80002c:	e8 72 00 00 00       	call   8000a3 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>
#define TICK (1U << 15)

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 0c             	sub    $0xc,%esp
	envid_t me = sys_getenvid();
  80003c:	e8 88 0a 00 00       	call   800ac9 <sys_getenvid>
  800041:	89 c7                	mov    %eax,%edi
	unsigned n = 0;
	bool yield = me & 1;
  800043:	89 c6                	mov    %eax,%esi
  800045:	83 e6 01             	and    $0x1,%esi
  800048:	bb 01 00 00 00       	mov    $0x1,%ebx
  80004d:	eb 15                	jmp    800064 <umain+0x31>
			;
		if (yield) {
			cprintf("I am %08x and I like my interrupt #%u\n", me, n);
			sys_yield();
		} else {
			cprintf("I am %08x and my spin will go on #%u\n", me, n);
  80004f:	83 ec 04             	sub    $0x4,%esp
  800052:	53                   	push   %ebx
  800053:	57                   	push   %edi
  800054:	68 08 0f 80 00       	push   $0x800f08
  800059:	e8 39 01 00 00       	call   800197 <cprintf>
	while (n++ < 5 || !yield) {
  80005e:	83 c3 01             	add    $0x1,%ebx
  800061:	83 c4 10             	add    $0x10,%esp
	bool yield = me & 1;
  800064:	b8 01 80 00 00       	mov    $0x8001,%eax
		while (i--)
  800069:	83 e8 01             	sub    $0x1,%eax
  80006c:	75 fb                	jne    800069 <umain+0x36>
		if (yield) {
  80006e:	85 f6                	test   %esi,%esi
  800070:	74 dd                	je     80004f <umain+0x1c>
			cprintf("I am %08x and I like my interrupt #%u\n", me, n);
  800072:	83 ec 04             	sub    $0x4,%esp
  800075:	53                   	push   %ebx
  800076:	57                   	push   %edi
  800077:	68 e0 0e 80 00       	push   $0x800ee0
  80007c:	e8 16 01 00 00       	call   800197 <cprintf>
			sys_yield();
  800081:	e8 67 0a 00 00       	call   800aed <sys_yield>
	while (n++ < 5 || !yield) {
  800086:	83 c4 10             	add    $0x10,%esp
  800089:	83 fb 04             	cmp    $0x4,%ebx
  80008c:	0f 96 c0             	setbe  %al
  80008f:	85 f6                	test   %esi,%esi
  800091:	0f 94 c2             	sete   %dl
  800094:	83 c3 01             	add    $0x1,%ebx
  800097:	08 d0                	or     %dl,%al
  800099:	75 c9                	jne    800064 <umain+0x31>
		}
	}
}
  80009b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80009e:	5b                   	pop    %ebx
  80009f:	5e                   	pop    %esi
  8000a0:	5f                   	pop    %edi
  8000a1:	5d                   	pop    %ebp
  8000a2:	c3                   	ret    

008000a3 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a3:	55                   	push   %ebp
  8000a4:	89 e5                	mov    %esp,%ebp
  8000a6:	56                   	push   %esi
  8000a7:	53                   	push   %ebx
  8000a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000ab:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	envid_t id = sys_getenvid();
  8000ae:	e8 16 0a 00 00       	call   800ac9 <sys_getenvid>
	if (id >= 0)
  8000b3:	85 c0                	test   %eax,%eax
  8000b5:	78 15                	js     8000cc <libmain+0x29>
		thisenv = &envs[ENVX(id)];
  8000b7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000bc:	69 c0 88 00 00 00    	imul   $0x88,%eax,%eax
  8000c2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000c7:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000cc:	85 db                	test   %ebx,%ebx
  8000ce:	7e 07                	jle    8000d7 <libmain+0x34>
		binaryname = argv[0];
  8000d0:	8b 06                	mov    (%esi),%eax
  8000d2:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000d7:	83 ec 08             	sub    $0x8,%esp
  8000da:	56                   	push   %esi
  8000db:	53                   	push   %ebx
  8000dc:	e8 52 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000e1:	e8 0a 00 00 00       	call   8000f0 <exit>
}
  8000e6:	83 c4 10             	add    $0x10,%esp
  8000e9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000ec:	5b                   	pop    %ebx
  8000ed:	5e                   	pop    %esi
  8000ee:	5d                   	pop    %ebp
  8000ef:	c3                   	ret    

008000f0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000f0:	55                   	push   %ebp
  8000f1:	89 e5                	mov    %esp,%ebp
  8000f3:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000f6:	6a 00                	push   $0x0
  8000f8:	e8 aa 09 00 00       	call   800aa7 <sys_env_destroy>
}
  8000fd:	83 c4 10             	add    $0x10,%esp
  800100:	c9                   	leave  
  800101:	c3                   	ret    

00800102 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800102:	55                   	push   %ebp
  800103:	89 e5                	mov    %esp,%ebp
  800105:	53                   	push   %ebx
  800106:	83 ec 04             	sub    $0x4,%esp
  800109:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80010c:	8b 13                	mov    (%ebx),%edx
  80010e:	8d 42 01             	lea    0x1(%edx),%eax
  800111:	89 03                	mov    %eax,(%ebx)
  800113:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800116:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256 - 1) {
  80011a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80011f:	74 09                	je     80012a <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800121:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800125:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800128:	c9                   	leave  
  800129:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80012a:	83 ec 08             	sub    $0x8,%esp
  80012d:	68 ff 00 00 00       	push   $0xff
  800132:	8d 43 08             	lea    0x8(%ebx),%eax
  800135:	50                   	push   %eax
  800136:	e8 22 09 00 00       	call   800a5d <sys_cputs>
		b->idx = 0;
  80013b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800141:	83 c4 10             	add    $0x10,%esp
  800144:	eb db                	jmp    800121 <putch+0x1f>

00800146 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800146:	55                   	push   %ebp
  800147:	89 e5                	mov    %esp,%ebp
  800149:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80014f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800156:	00 00 00 
	b.cnt = 0;
  800159:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800160:	00 00 00 
	vprintfmt((void *) putch, &b, fmt, ap);
  800163:	ff 75 0c             	push   0xc(%ebp)
  800166:	ff 75 08             	push   0x8(%ebp)
  800169:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80016f:	50                   	push   %eax
  800170:	68 02 01 80 00       	push   $0x800102
  800175:	e8 74 01 00 00       	call   8002ee <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80017a:	83 c4 08             	add    $0x8,%esp
  80017d:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800183:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800189:	50                   	push   %eax
  80018a:	e8 ce 08 00 00       	call   800a5d <sys_cputs>

	return b.cnt;
}
  80018f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800195:	c9                   	leave  
  800196:	c3                   	ret    

00800197 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800197:	55                   	push   %ebp
  800198:	89 e5                	mov    %esp,%ebp
  80019a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80019d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001a0:	50                   	push   %eax
  8001a1:	ff 75 08             	push   0x8(%ebp)
  8001a4:	e8 9d ff ff ff       	call   800146 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a9:	c9                   	leave  
  8001aa:	c3                   	ret    

008001ab <printnum>:
         void *putdat,
         unsigned long long num,
         unsigned base,
         int width,
         int padc)
{
  8001ab:	55                   	push   %ebp
  8001ac:	89 e5                	mov    %esp,%ebp
  8001ae:	57                   	push   %edi
  8001af:	56                   	push   %esi
  8001b0:	53                   	push   %ebx
  8001b1:	83 ec 1c             	sub    $0x1c,%esp
  8001b4:	89 c7                	mov    %eax,%edi
  8001b6:	89 d6                	mov    %edx,%esi
  8001b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8001bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001be:	89 d1                	mov    %edx,%ecx
  8001c0:	89 c2                	mov    %eax,%edx
  8001c2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001c5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001c8:	8b 45 10             	mov    0x10(%ebp),%eax
  8001cb:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001ce:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001d1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001d8:	39 c2                	cmp    %eax,%edx
  8001da:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001dd:	72 3e                	jb     80021d <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001df:	83 ec 0c             	sub    $0xc,%esp
  8001e2:	ff 75 18             	push   0x18(%ebp)
  8001e5:	83 eb 01             	sub    $0x1,%ebx
  8001e8:	53                   	push   %ebx
  8001e9:	50                   	push   %eax
  8001ea:	83 ec 08             	sub    $0x8,%esp
  8001ed:	ff 75 e4             	push   -0x1c(%ebp)
  8001f0:	ff 75 e0             	push   -0x20(%ebp)
  8001f3:	ff 75 dc             	push   -0x24(%ebp)
  8001f6:	ff 75 d8             	push   -0x28(%ebp)
  8001f9:	e8 a2 0a 00 00       	call   800ca0 <__udivdi3>
  8001fe:	83 c4 18             	add    $0x18,%esp
  800201:	52                   	push   %edx
  800202:	50                   	push   %eax
  800203:	89 f2                	mov    %esi,%edx
  800205:	89 f8                	mov    %edi,%eax
  800207:	e8 9f ff ff ff       	call   8001ab <printnum>
  80020c:	83 c4 20             	add    $0x20,%esp
  80020f:	eb 13                	jmp    800224 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800211:	83 ec 08             	sub    $0x8,%esp
  800214:	56                   	push   %esi
  800215:	ff 75 18             	push   0x18(%ebp)
  800218:	ff d7                	call   *%edi
  80021a:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80021d:	83 eb 01             	sub    $0x1,%ebx
  800220:	85 db                	test   %ebx,%ebx
  800222:	7f ed                	jg     800211 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800224:	83 ec 08             	sub    $0x8,%esp
  800227:	56                   	push   %esi
  800228:	83 ec 04             	sub    $0x4,%esp
  80022b:	ff 75 e4             	push   -0x1c(%ebp)
  80022e:	ff 75 e0             	push   -0x20(%ebp)
  800231:	ff 75 dc             	push   -0x24(%ebp)
  800234:	ff 75 d8             	push   -0x28(%ebp)
  800237:	e8 84 0b 00 00       	call   800dc0 <__umoddi3>
  80023c:	83 c4 14             	add    $0x14,%esp
  80023f:	0f be 80 38 0f 80 00 	movsbl 0x800f38(%eax),%eax
  800246:	50                   	push   %eax
  800247:	ff d7                	call   *%edi
}
  800249:	83 c4 10             	add    $0x10,%esp
  80024c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024f:	5b                   	pop    %ebx
  800250:	5e                   	pop    %esi
  800251:	5f                   	pop    %edi
  800252:	5d                   	pop    %ebp
  800253:	c3                   	ret    

00800254 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800254:	83 fa 01             	cmp    $0x1,%edx
  800257:	7f 13                	jg     80026c <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800259:	85 d2                	test   %edx,%edx
  80025b:	74 1c                	je     800279 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  80025d:	8b 10                	mov    (%eax),%edx
  80025f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800262:	89 08                	mov    %ecx,(%eax)
  800264:	8b 02                	mov    (%edx),%eax
  800266:	ba 00 00 00 00       	mov    $0x0,%edx
  80026b:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  80026c:	8b 10                	mov    (%eax),%edx
  80026e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800271:	89 08                	mov    %ecx,(%eax)
  800273:	8b 02                	mov    (%edx),%eax
  800275:	8b 52 04             	mov    0x4(%edx),%edx
  800278:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  800279:	8b 10                	mov    (%eax),%edx
  80027b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80027e:	89 08                	mov    %ecx,(%eax)
  800280:	8b 02                	mov    (%edx),%eax
  800282:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800287:	c3                   	ret    

00800288 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800288:	83 fa 01             	cmp    $0x1,%edx
  80028b:	7f 0f                	jg     80029c <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  80028d:	85 d2                	test   %edx,%edx
  80028f:	74 18                	je     8002a9 <getint+0x21>
		return va_arg(*ap, long);
  800291:	8b 10                	mov    (%eax),%edx
  800293:	8d 4a 04             	lea    0x4(%edx),%ecx
  800296:	89 08                	mov    %ecx,(%eax)
  800298:	8b 02                	mov    (%edx),%eax
  80029a:	99                   	cltd   
  80029b:	c3                   	ret    
		return va_arg(*ap, long long);
  80029c:	8b 10                	mov    (%eax),%edx
  80029e:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002a1:	89 08                	mov    %ecx,(%eax)
  8002a3:	8b 02                	mov    (%edx),%eax
  8002a5:	8b 52 04             	mov    0x4(%edx),%edx
  8002a8:	c3                   	ret    
	else
		return va_arg(*ap, int);
  8002a9:	8b 10                	mov    (%eax),%edx
  8002ab:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ae:	89 08                	mov    %ecx,(%eax)
  8002b0:	8b 02                	mov    (%edx),%eax
  8002b2:	99                   	cltd   
}
  8002b3:	c3                   	ret    

008002b4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b4:	55                   	push   %ebp
  8002b5:	89 e5                	mov    %esp,%ebp
  8002b7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ba:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002be:	8b 10                	mov    (%eax),%edx
  8002c0:	3b 50 04             	cmp    0x4(%eax),%edx
  8002c3:	73 0a                	jae    8002cf <sprintputch+0x1b>
		*b->buf++ = ch;
  8002c5:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002c8:	89 08                	mov    %ecx,(%eax)
  8002ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8002cd:	88 02                	mov    %al,(%edx)
}
  8002cf:	5d                   	pop    %ebp
  8002d0:	c3                   	ret    

008002d1 <printfmt>:
{
  8002d1:	55                   	push   %ebp
  8002d2:	89 e5                	mov    %esp,%ebp
  8002d4:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002d7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002da:	50                   	push   %eax
  8002db:	ff 75 10             	push   0x10(%ebp)
  8002de:	ff 75 0c             	push   0xc(%ebp)
  8002e1:	ff 75 08             	push   0x8(%ebp)
  8002e4:	e8 05 00 00 00       	call   8002ee <vprintfmt>
}
  8002e9:	83 c4 10             	add    $0x10,%esp
  8002ec:	c9                   	leave  
  8002ed:	c3                   	ret    

008002ee <vprintfmt>:
{
  8002ee:	55                   	push   %ebp
  8002ef:	89 e5                	mov    %esp,%ebp
  8002f1:	57                   	push   %edi
  8002f2:	56                   	push   %esi
  8002f3:	53                   	push   %ebx
  8002f4:	83 ec 2c             	sub    $0x2c,%esp
  8002f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002fa:	8b 75 0c             	mov    0xc(%ebp),%esi
  8002fd:	8b 7d 10             	mov    0x10(%ebp),%edi
  800300:	eb 0a                	jmp    80030c <vprintfmt+0x1e>
			putch(ch, putdat);
  800302:	83 ec 08             	sub    $0x8,%esp
  800305:	56                   	push   %esi
  800306:	50                   	push   %eax
  800307:	ff d3                	call   *%ebx
  800309:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80030c:	83 c7 01             	add    $0x1,%edi
  80030f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800313:	83 f8 25             	cmp    $0x25,%eax
  800316:	74 0c                	je     800324 <vprintfmt+0x36>
			if (ch == '\0')
  800318:	85 c0                	test   %eax,%eax
  80031a:	75 e6                	jne    800302 <vprintfmt+0x14>
}
  80031c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80031f:	5b                   	pop    %ebx
  800320:	5e                   	pop    %esi
  800321:	5f                   	pop    %edi
  800322:	5d                   	pop    %ebp
  800323:	c3                   	ret    
		padc = ' ';
  800324:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
		altflag = 0;
  800328:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80032f:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800336:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80033d:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800342:	8d 47 01             	lea    0x1(%edi),%eax
  800345:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800348:	0f b6 17             	movzbl (%edi),%edx
  80034b:	8d 42 dd             	lea    -0x23(%edx),%eax
  80034e:	3c 55                	cmp    $0x55,%al
  800350:	0f 87 b7 02 00 00    	ja     80060d <vprintfmt+0x31f>
  800356:	0f b6 c0             	movzbl %al,%eax
  800359:	ff 24 85 00 10 80 00 	jmp    *0x801000(,%eax,4)
  800360:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800363:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800367:	eb d9                	jmp    800342 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800369:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80036c:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800370:	eb d0                	jmp    800342 <vprintfmt+0x54>
  800372:	0f b6 d2             	movzbl %dl,%edx
  800375:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0;; ++fmt) {
  800378:	b8 00 00 00 00       	mov    $0x0,%eax
  80037d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800380:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800383:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800387:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80038a:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80038d:	83 f9 09             	cmp    $0x9,%ecx
  800390:	77 52                	ja     8003e4 <vprintfmt+0xf6>
			for (precision = 0;; ++fmt) {
  800392:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800395:	eb e9                	jmp    800380 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  800397:	8b 45 14             	mov    0x14(%ebp),%eax
  80039a:	8d 50 04             	lea    0x4(%eax),%edx
  80039d:	89 55 14             	mov    %edx,0x14(%ebp)
  8003a0:	8b 00                	mov    (%eax),%eax
  8003a2:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003a8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003ac:	79 94                	jns    800342 <vprintfmt+0x54>
				width = precision, precision = -1;
  8003ae:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003b4:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003bb:	eb 85                	jmp    800342 <vprintfmt+0x54>
  8003bd:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003c0:	85 d2                	test   %edx,%edx
  8003c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c7:	0f 49 c2             	cmovns %edx,%eax
  8003ca:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003d0:	e9 6d ff ff ff       	jmp    800342 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8003d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003d8:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003df:	e9 5e ff ff ff       	jmp    800342 <vprintfmt+0x54>
  8003e4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003e7:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003ea:	eb bc                	jmp    8003a8 <vprintfmt+0xba>
			lflag++;
  8003ec:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003f2:	e9 4b ff ff ff       	jmp    800342 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8003f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fa:	8d 50 04             	lea    0x4(%eax),%edx
  8003fd:	89 55 14             	mov    %edx,0x14(%ebp)
  800400:	83 ec 08             	sub    $0x8,%esp
  800403:	56                   	push   %esi
  800404:	ff 30                	push   (%eax)
  800406:	ff d3                	call   *%ebx
			break;
  800408:	83 c4 10             	add    $0x10,%esp
  80040b:	e9 94 01 00 00       	jmp    8005a4 <vprintfmt+0x2b6>
			err = va_arg(ap, int);
  800410:	8b 45 14             	mov    0x14(%ebp),%eax
  800413:	8d 50 04             	lea    0x4(%eax),%edx
  800416:	89 55 14             	mov    %edx,0x14(%ebp)
  800419:	8b 10                	mov    (%eax),%edx
  80041b:	89 d0                	mov    %edx,%eax
  80041d:	f7 d8                	neg    %eax
  80041f:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800422:	83 f8 08             	cmp    $0x8,%eax
  800425:	7f 20                	jg     800447 <vprintfmt+0x159>
  800427:	8b 14 85 60 11 80 00 	mov    0x801160(,%eax,4),%edx
  80042e:	85 d2                	test   %edx,%edx
  800430:	74 15                	je     800447 <vprintfmt+0x159>
				printfmt(putch, putdat, "%s", p);
  800432:	52                   	push   %edx
  800433:	68 59 0f 80 00       	push   $0x800f59
  800438:	56                   	push   %esi
  800439:	53                   	push   %ebx
  80043a:	e8 92 fe ff ff       	call   8002d1 <printfmt>
  80043f:	83 c4 10             	add    $0x10,%esp
  800442:	e9 5d 01 00 00       	jmp    8005a4 <vprintfmt+0x2b6>
				printfmt(putch, putdat, "error %d", err);
  800447:	50                   	push   %eax
  800448:	68 50 0f 80 00       	push   $0x800f50
  80044d:	56                   	push   %esi
  80044e:	53                   	push   %ebx
  80044f:	e8 7d fe ff ff       	call   8002d1 <printfmt>
  800454:	83 c4 10             	add    $0x10,%esp
  800457:	e9 48 01 00 00       	jmp    8005a4 <vprintfmt+0x2b6>
			if ((p = va_arg(ap, char *)) == NULL)
  80045c:	8b 45 14             	mov    0x14(%ebp),%eax
  80045f:	8d 50 04             	lea    0x4(%eax),%edx
  800462:	89 55 14             	mov    %edx,0x14(%ebp)
  800465:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800467:	85 ff                	test   %edi,%edi
  800469:	b8 49 0f 80 00       	mov    $0x800f49,%eax
  80046e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800471:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800475:	7e 06                	jle    80047d <vprintfmt+0x18f>
  800477:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  80047b:	75 0a                	jne    800487 <vprintfmt+0x199>
  80047d:	89 f8                	mov    %edi,%eax
  80047f:	03 45 e0             	add    -0x20(%ebp),%eax
  800482:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800485:	eb 59                	jmp    8004e0 <vprintfmt+0x1f2>
				for (width -= strnlen(p, precision); width > 0;
  800487:	83 ec 08             	sub    $0x8,%esp
  80048a:	ff 75 d8             	push   -0x28(%ebp)
  80048d:	57                   	push   %edi
  80048e:	e8 1a 02 00 00       	call   8006ad <strnlen>
  800493:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800496:	29 c1                	sub    %eax,%ecx
  800498:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80049b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80049e:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  8004a2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a5:	89 7d d0             	mov    %edi,-0x30(%ebp)
  8004a8:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0;
  8004aa:	eb 0f                	jmp    8004bb <vprintfmt+0x1cd>
					putch(padc, putdat);
  8004ac:	83 ec 08             	sub    $0x8,%esp
  8004af:	56                   	push   %esi
  8004b0:	ff 75 e0             	push   -0x20(%ebp)
  8004b3:	ff d3                	call   *%ebx
				     width--)
  8004b5:	83 ef 01             	sub    $0x1,%edi
  8004b8:	83 c4 10             	add    $0x10,%esp
				for (width -= strnlen(p, precision); width > 0;
  8004bb:	85 ff                	test   %edi,%edi
  8004bd:	7f ed                	jg     8004ac <vprintfmt+0x1be>
  8004bf:	8b 7d d0             	mov    -0x30(%ebp),%edi
  8004c2:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004c5:	85 c9                	test   %ecx,%ecx
  8004c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8004cc:	0f 49 c1             	cmovns %ecx,%eax
  8004cf:	29 c1                	sub    %eax,%ecx
  8004d1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8004d4:	eb a7                	jmp    80047d <vprintfmt+0x18f>
					putch(ch, putdat);
  8004d6:	83 ec 08             	sub    $0x8,%esp
  8004d9:	56                   	push   %esi
  8004da:	52                   	push   %edx
  8004db:	ff d3                	call   *%ebx
  8004dd:	83 c4 10             	add    $0x10,%esp
  8004e0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004e3:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' &&
  8004e5:	83 c7 01             	add    $0x1,%edi
  8004e8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004ec:	0f be d0             	movsbl %al,%edx
  8004ef:	85 d2                	test   %edx,%edx
  8004f1:	74 42                	je     800535 <vprintfmt+0x247>
  8004f3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004f7:	78 06                	js     8004ff <vprintfmt+0x211>
			       (precision < 0 || --precision >= 0);
  8004f9:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004fd:	78 1e                	js     80051d <vprintfmt+0x22f>
				if (altflag && (ch < ' ' || ch > '~'))
  8004ff:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800503:	74 d1                	je     8004d6 <vprintfmt+0x1e8>
  800505:	0f be c0             	movsbl %al,%eax
  800508:	83 e8 20             	sub    $0x20,%eax
  80050b:	83 f8 5e             	cmp    $0x5e,%eax
  80050e:	76 c6                	jbe    8004d6 <vprintfmt+0x1e8>
					putch('?', putdat);
  800510:	83 ec 08             	sub    $0x8,%esp
  800513:	56                   	push   %esi
  800514:	6a 3f                	push   $0x3f
  800516:	ff d3                	call   *%ebx
  800518:	83 c4 10             	add    $0x10,%esp
  80051b:	eb c3                	jmp    8004e0 <vprintfmt+0x1f2>
  80051d:	89 cf                	mov    %ecx,%edi
  80051f:	eb 0e                	jmp    80052f <vprintfmt+0x241>
				putch(' ', putdat);
  800521:	83 ec 08             	sub    $0x8,%esp
  800524:	56                   	push   %esi
  800525:	6a 20                	push   $0x20
  800527:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  800529:	83 ef 01             	sub    $0x1,%edi
  80052c:	83 c4 10             	add    $0x10,%esp
  80052f:	85 ff                	test   %edi,%edi
  800531:	7f ee                	jg     800521 <vprintfmt+0x233>
  800533:	eb 6f                	jmp    8005a4 <vprintfmt+0x2b6>
  800535:	89 cf                	mov    %ecx,%edi
  800537:	eb f6                	jmp    80052f <vprintfmt+0x241>
			num = getint(&ap, lflag);
  800539:	89 ca                	mov    %ecx,%edx
  80053b:	8d 45 14             	lea    0x14(%ebp),%eax
  80053e:	e8 45 fd ff ff       	call   800288 <getint>
  800543:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800546:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800549:	85 d2                	test   %edx,%edx
  80054b:	78 0b                	js     800558 <vprintfmt+0x26a>
			num = getint(&ap, lflag);
  80054d:	89 d1                	mov    %edx,%ecx
  80054f:	89 c2                	mov    %eax,%edx
			base = 10;
  800551:	bf 0a 00 00 00       	mov    $0xa,%edi
  800556:	eb 32                	jmp    80058a <vprintfmt+0x29c>
				putch('-', putdat);
  800558:	83 ec 08             	sub    $0x8,%esp
  80055b:	56                   	push   %esi
  80055c:	6a 2d                	push   $0x2d
  80055e:	ff d3                	call   *%ebx
				num = -(long long) num;
  800560:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800563:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800566:	f7 da                	neg    %edx
  800568:	83 d1 00             	adc    $0x0,%ecx
  80056b:	f7 d9                	neg    %ecx
  80056d:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800570:	bf 0a 00 00 00       	mov    $0xa,%edi
  800575:	eb 13                	jmp    80058a <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  800577:	89 ca                	mov    %ecx,%edx
  800579:	8d 45 14             	lea    0x14(%ebp),%eax
  80057c:	e8 d3 fc ff ff       	call   800254 <getuint>
  800581:	89 d1                	mov    %edx,%ecx
  800583:	89 c2                	mov    %eax,%edx
			base = 10;
  800585:	bf 0a 00 00 00       	mov    $0xa,%edi
			printnum(putch, putdat, num, base, width, padc);
  80058a:	83 ec 0c             	sub    $0xc,%esp
  80058d:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  800591:	50                   	push   %eax
  800592:	ff 75 e0             	push   -0x20(%ebp)
  800595:	57                   	push   %edi
  800596:	51                   	push   %ecx
  800597:	52                   	push   %edx
  800598:	89 f2                	mov    %esi,%edx
  80059a:	89 d8                	mov    %ebx,%eax
  80059c:	e8 0a fc ff ff       	call   8001ab <printnum>
			break;
  8005a1:	83 c4 20             	add    $0x20,%esp
{
  8005a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005a7:	e9 60 fd ff ff       	jmp    80030c <vprintfmt+0x1e>
			num = getuint(&ap, lflag);
  8005ac:	89 ca                	mov    %ecx,%edx
  8005ae:	8d 45 14             	lea    0x14(%ebp),%eax
  8005b1:	e8 9e fc ff ff       	call   800254 <getuint>
  8005b6:	89 d1                	mov    %edx,%ecx
  8005b8:	89 c2                	mov    %eax,%edx
			base = 8;
  8005ba:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  8005bf:	eb c9                	jmp    80058a <vprintfmt+0x29c>
			putch('0', putdat);
  8005c1:	83 ec 08             	sub    $0x8,%esp
  8005c4:	56                   	push   %esi
  8005c5:	6a 30                	push   $0x30
  8005c7:	ff d3                	call   *%ebx
			putch('x', putdat);
  8005c9:	83 c4 08             	add    $0x8,%esp
  8005cc:	56                   	push   %esi
  8005cd:	6a 78                	push   $0x78
  8005cf:	ff d3                	call   *%ebx
			num = (unsigned long long) (uintptr_t) va_arg(ap, void *);
  8005d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d4:	8d 50 04             	lea    0x4(%eax),%edx
  8005d7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005da:	8b 10                	mov    (%eax),%edx
  8005dc:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8005e1:	83 c4 10             	add    $0x10,%esp
			base = 16;
  8005e4:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  8005e9:	eb 9f                	jmp    80058a <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  8005eb:	89 ca                	mov    %ecx,%edx
  8005ed:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f0:	e8 5f fc ff ff       	call   800254 <getuint>
  8005f5:	89 d1                	mov    %edx,%ecx
  8005f7:	89 c2                	mov    %eax,%edx
			base = 16;
  8005f9:	bf 10 00 00 00       	mov    $0x10,%edi
  8005fe:	eb 8a                	jmp    80058a <vprintfmt+0x29c>
			putch(ch, putdat);
  800600:	83 ec 08             	sub    $0x8,%esp
  800603:	56                   	push   %esi
  800604:	6a 25                	push   $0x25
  800606:	ff d3                	call   *%ebx
			break;
  800608:	83 c4 10             	add    $0x10,%esp
  80060b:	eb 97                	jmp    8005a4 <vprintfmt+0x2b6>
			putch('%', putdat);
  80060d:	83 ec 08             	sub    $0x8,%esp
  800610:	56                   	push   %esi
  800611:	6a 25                	push   $0x25
  800613:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  800615:	83 c4 10             	add    $0x10,%esp
  800618:	89 f8                	mov    %edi,%eax
  80061a:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80061e:	74 05                	je     800625 <vprintfmt+0x337>
  800620:	83 e8 01             	sub    $0x1,%eax
  800623:	eb f5                	jmp    80061a <vprintfmt+0x32c>
  800625:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800628:	e9 77 ff ff ff       	jmp    8005a4 <vprintfmt+0x2b6>

0080062d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80062d:	55                   	push   %ebp
  80062e:	89 e5                	mov    %esp,%ebp
  800630:	83 ec 18             	sub    $0x18,%esp
  800633:	8b 45 08             	mov    0x8(%ebp),%eax
  800636:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = { buf, buf + n - 1, 0 };
  800639:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80063c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800640:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800643:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80064a:	85 c0                	test   %eax,%eax
  80064c:	74 26                	je     800674 <vsnprintf+0x47>
  80064e:	85 d2                	test   %edx,%edx
  800650:	7e 22                	jle    800674 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *) sprintputch, &b, fmt, ap);
  800652:	ff 75 14             	push   0x14(%ebp)
  800655:	ff 75 10             	push   0x10(%ebp)
  800658:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80065b:	50                   	push   %eax
  80065c:	68 b4 02 80 00       	push   $0x8002b4
  800661:	e8 88 fc ff ff       	call   8002ee <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800666:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800669:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80066c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80066f:	83 c4 10             	add    $0x10,%esp
}
  800672:	c9                   	leave  
  800673:	c3                   	ret    
		return -E_INVAL;
  800674:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800679:	eb f7                	jmp    800672 <vsnprintf+0x45>

0080067b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80067b:	55                   	push   %ebp
  80067c:	89 e5                	mov    %esp,%ebp
  80067e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800681:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800684:	50                   	push   %eax
  800685:	ff 75 10             	push   0x10(%ebp)
  800688:	ff 75 0c             	push   0xc(%ebp)
  80068b:	ff 75 08             	push   0x8(%ebp)
  80068e:	e8 9a ff ff ff       	call   80062d <vsnprintf>
	va_end(ap);

	return rc;
}
  800693:	c9                   	leave  
  800694:	c3                   	ret    

00800695 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800695:	55                   	push   %ebp
  800696:	89 e5                	mov    %esp,%ebp
  800698:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80069b:	b8 00 00 00 00       	mov    $0x0,%eax
  8006a0:	eb 03                	jmp    8006a5 <strlen+0x10>
		n++;
  8006a2:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8006a5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006a9:	75 f7                	jne    8006a2 <strlen+0xd>
	return n;
}
  8006ab:	5d                   	pop    %ebp
  8006ac:	c3                   	ret    

008006ad <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006ad:	55                   	push   %ebp
  8006ae:	89 e5                	mov    %esp,%ebp
  8006b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006b3:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8006bb:	eb 03                	jmp    8006c0 <strnlen+0x13>
		n++;
  8006bd:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006c0:	39 d0                	cmp    %edx,%eax
  8006c2:	74 08                	je     8006cc <strnlen+0x1f>
  8006c4:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8006c8:	75 f3                	jne    8006bd <strnlen+0x10>
  8006ca:	89 c2                	mov    %eax,%edx
	return n;
}
  8006cc:	89 d0                	mov    %edx,%eax
  8006ce:	5d                   	pop    %ebp
  8006cf:	c3                   	ret    

008006d0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006d0:	55                   	push   %ebp
  8006d1:	89 e5                	mov    %esp,%ebp
  8006d3:	53                   	push   %ebx
  8006d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006da:	b8 00 00 00 00       	mov    $0x0,%eax
  8006df:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8006e3:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8006e6:	83 c0 01             	add    $0x1,%eax
  8006e9:	84 d2                	test   %dl,%dl
  8006eb:	75 f2                	jne    8006df <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8006ed:	89 c8                	mov    %ecx,%eax
  8006ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006f2:	c9                   	leave  
  8006f3:	c3                   	ret    

008006f4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8006f4:	55                   	push   %ebp
  8006f5:	89 e5                	mov    %esp,%ebp
  8006f7:	53                   	push   %ebx
  8006f8:	83 ec 10             	sub    $0x10,%esp
  8006fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8006fe:	53                   	push   %ebx
  8006ff:	e8 91 ff ff ff       	call   800695 <strlen>
  800704:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800707:	ff 75 0c             	push   0xc(%ebp)
  80070a:	01 d8                	add    %ebx,%eax
  80070c:	50                   	push   %eax
  80070d:	e8 be ff ff ff       	call   8006d0 <strcpy>
	return dst;
}
  800712:	89 d8                	mov    %ebx,%eax
  800714:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800717:	c9                   	leave  
  800718:	c3                   	ret    

00800719 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size)
{
  800719:	55                   	push   %ebp
  80071a:	89 e5                	mov    %esp,%ebp
  80071c:	56                   	push   %esi
  80071d:	53                   	push   %ebx
  80071e:	8b 75 08             	mov    0x8(%ebp),%esi
  800721:	8b 55 0c             	mov    0xc(%ebp),%edx
  800724:	89 f3                	mov    %esi,%ebx
  800726:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800729:	89 f0                	mov    %esi,%eax
  80072b:	eb 0f                	jmp    80073c <strncpy+0x23>
		*dst++ = *src;
  80072d:	83 c0 01             	add    $0x1,%eax
  800730:	0f b6 0a             	movzbl (%edx),%ecx
  800733:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800736:	80 f9 01             	cmp    $0x1,%cl
  800739:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  80073c:	39 d8                	cmp    %ebx,%eax
  80073e:	75 ed                	jne    80072d <strncpy+0x14>
	}
	return ret;
}
  800740:	89 f0                	mov    %esi,%eax
  800742:	5b                   	pop    %ebx
  800743:	5e                   	pop    %esi
  800744:	5d                   	pop    %ebp
  800745:	c3                   	ret    

00800746 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800746:	55                   	push   %ebp
  800747:	89 e5                	mov    %esp,%ebp
  800749:	56                   	push   %esi
  80074a:	53                   	push   %ebx
  80074b:	8b 75 08             	mov    0x8(%ebp),%esi
  80074e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800751:	8b 55 10             	mov    0x10(%ebp),%edx
  800754:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800756:	85 d2                	test   %edx,%edx
  800758:	74 21                	je     80077b <strlcpy+0x35>
  80075a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80075e:	89 f2                	mov    %esi,%edx
  800760:	eb 09                	jmp    80076b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800762:	83 c1 01             	add    $0x1,%ecx
  800765:	83 c2 01             	add    $0x1,%edx
  800768:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  80076b:	39 c2                	cmp    %eax,%edx
  80076d:	74 09                	je     800778 <strlcpy+0x32>
  80076f:	0f b6 19             	movzbl (%ecx),%ebx
  800772:	84 db                	test   %bl,%bl
  800774:	75 ec                	jne    800762 <strlcpy+0x1c>
  800776:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800778:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80077b:	29 f0                	sub    %esi,%eax
}
  80077d:	5b                   	pop    %ebx
  80077e:	5e                   	pop    %esi
  80077f:	5d                   	pop    %ebp
  800780:	c3                   	ret    

00800781 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800781:	55                   	push   %ebp
  800782:	89 e5                	mov    %esp,%ebp
  800784:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800787:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80078a:	eb 06                	jmp    800792 <strcmp+0x11>
		p++, q++;
  80078c:	83 c1 01             	add    $0x1,%ecx
  80078f:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800792:	0f b6 01             	movzbl (%ecx),%eax
  800795:	84 c0                	test   %al,%al
  800797:	74 04                	je     80079d <strcmp+0x1c>
  800799:	3a 02                	cmp    (%edx),%al
  80079b:	74 ef                	je     80078c <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80079d:	0f b6 c0             	movzbl %al,%eax
  8007a0:	0f b6 12             	movzbl (%edx),%edx
  8007a3:	29 d0                	sub    %edx,%eax
}
  8007a5:	5d                   	pop    %ebp
  8007a6:	c3                   	ret    

008007a7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007a7:	55                   	push   %ebp
  8007a8:	89 e5                	mov    %esp,%ebp
  8007aa:	53                   	push   %ebx
  8007ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b1:	89 c3                	mov    %eax,%ebx
  8007b3:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007b6:	eb 06                	jmp    8007be <strncmp+0x17>
		n--, p++, q++;
  8007b8:	83 c0 01             	add    $0x1,%eax
  8007bb:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8007be:	39 d8                	cmp    %ebx,%eax
  8007c0:	74 18                	je     8007da <strncmp+0x33>
  8007c2:	0f b6 08             	movzbl (%eax),%ecx
  8007c5:	84 c9                	test   %cl,%cl
  8007c7:	74 04                	je     8007cd <strncmp+0x26>
  8007c9:	3a 0a                	cmp    (%edx),%cl
  8007cb:	74 eb                	je     8007b8 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007cd:	0f b6 00             	movzbl (%eax),%eax
  8007d0:	0f b6 12             	movzbl (%edx),%edx
  8007d3:	29 d0                	sub    %edx,%eax
}
  8007d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d8:	c9                   	leave  
  8007d9:	c3                   	ret    
		return 0;
  8007da:	b8 00 00 00 00       	mov    $0x0,%eax
  8007df:	eb f4                	jmp    8007d5 <strncmp+0x2e>

008007e1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007e1:	55                   	push   %ebp
  8007e2:	89 e5                	mov    %esp,%ebp
  8007e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007eb:	eb 03                	jmp    8007f0 <strchr+0xf>
  8007ed:	83 c0 01             	add    $0x1,%eax
  8007f0:	0f b6 10             	movzbl (%eax),%edx
  8007f3:	84 d2                	test   %dl,%dl
  8007f5:	74 06                	je     8007fd <strchr+0x1c>
		if (*s == c)
  8007f7:	38 ca                	cmp    %cl,%dl
  8007f9:	75 f2                	jne    8007ed <strchr+0xc>
  8007fb:	eb 05                	jmp    800802 <strchr+0x21>
			return (char *) s;
	return 0;
  8007fd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800802:	5d                   	pop    %ebp
  800803:	c3                   	ret    

00800804 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800804:	55                   	push   %ebp
  800805:	89 e5                	mov    %esp,%ebp
  800807:	8b 45 08             	mov    0x8(%ebp),%eax
  80080a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80080e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800811:	38 ca                	cmp    %cl,%dl
  800813:	74 09                	je     80081e <strfind+0x1a>
  800815:	84 d2                	test   %dl,%dl
  800817:	74 05                	je     80081e <strfind+0x1a>
	for (; *s; s++)
  800819:	83 c0 01             	add    $0x1,%eax
  80081c:	eb f0                	jmp    80080e <strfind+0xa>
			break;
	return (char *) s;
}
  80081e:	5d                   	pop    %ebp
  80081f:	c3                   	ret    

00800820 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800820:	55                   	push   %ebp
  800821:	89 e5                	mov    %esp,%ebp
  800823:	57                   	push   %edi
  800824:	56                   	push   %esi
  800825:	53                   	push   %ebx
  800826:	8b 55 08             	mov    0x8(%ebp),%edx
  800829:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  80082c:	85 c9                	test   %ecx,%ecx
  80082e:	74 33                	je     800863 <memset+0x43>
		return v;
	if ((int) v % 4 == 0 && n % 4 == 0) {
  800830:	89 d0                	mov    %edx,%eax
  800832:	09 c8                	or     %ecx,%eax
  800834:	a8 03                	test   $0x3,%al
  800836:	75 23                	jne    80085b <memset+0x3b>
		c &= 0xFF;
  800838:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  80083c:	89 d8                	mov    %ebx,%eax
  80083e:	c1 e0 08             	shl    $0x8,%eax
  800841:	89 df                	mov    %ebx,%edi
  800843:	c1 e7 18             	shl    $0x18,%edi
  800846:	89 de                	mov    %ebx,%esi
  800848:	c1 e6 10             	shl    $0x10,%esi
  80084b:	09 f7                	or     %esi,%edi
  80084d:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
		             : "=D"(p), "=c"(n)
		             : "D"(p), "a"(c), "c"(n / 4)
  80084f:	c1 e9 02             	shr    $0x2,%ecx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  800852:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800854:	89 d7                	mov    %edx,%edi
  800856:	fc                   	cld    
  800857:	f3 ab                	rep stos %eax,%es:(%edi)
  800859:	eb 08                	jmp    800863 <memset+0x43>
		             : "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80085b:	89 d7                	mov    %edx,%edi
  80085d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800860:	fc                   	cld    
  800861:	f3 aa                	rep stos %al,%es:(%edi)
		             : "=D"(p), "=c"(n)
		             : "0"(p), "a"(c), "1"(n)
		             : "cc", "memory");
	return v;
}
  800863:	89 d0                	mov    %edx,%eax
  800865:	5b                   	pop    %ebx
  800866:	5e                   	pop    %esi
  800867:	5f                   	pop    %edi
  800868:	5d                   	pop    %ebp
  800869:	c3                   	ret    

0080086a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80086a:	55                   	push   %ebp
  80086b:	89 e5                	mov    %esp,%ebp
  80086d:	57                   	push   %edi
  80086e:	56                   	push   %esi
  80086f:	8b 45 08             	mov    0x8(%ebp),%eax
  800872:	8b 75 0c             	mov    0xc(%ebp),%esi
  800875:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800878:	39 c6                	cmp    %eax,%esi
  80087a:	73 32                	jae    8008ae <memmove+0x44>
  80087c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80087f:	39 c2                	cmp    %eax,%edx
  800881:	76 2b                	jbe    8008ae <memmove+0x44>
		s += n;
		d += n;
  800883:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  800886:	89 d6                	mov    %edx,%esi
  800888:	09 fe                	or     %edi,%esi
  80088a:	09 ce                	or     %ecx,%esi
  80088c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800892:	75 0e                	jne    8008a2 <memmove+0x38>
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  800894:	83 ef 04             	sub    $0x4,%edi
			             "S"(s - 4),
  800897:	8d 72 fc             	lea    -0x4(%edx),%esi
			             "c"(n / 4)
  80089a:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  80089d:	fd                   	std    
  80089e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008a0:	eb 09                	jmp    8008ab <memmove+0x41>
			             : "cc", "memory");
		else
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  8008a2:	83 ef 01             	sub    $0x1,%edi
			             "S"(s - 1),
  8008a5:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  8008a8:	fd                   	std    
  8008a9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             "c"(n)
			             : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008ab:	fc                   	cld    
  8008ac:	eb 1a                	jmp    8008c8 <memmove+0x5e>
	} else {
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  8008ae:	89 f2                	mov    %esi,%edx
  8008b0:	09 c2                	or     %eax,%edx
  8008b2:	09 ca                	or     %ecx,%edx
  8008b4:	f6 c2 03             	test   $0x3,%dl
  8008b7:	75 0a                	jne    8008c3 <memmove+0x59>
			asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  8008b9:	c1 e9 02             	shr    $0x2,%ecx
  8008bc:	89 c7                	mov    %eax,%edi
  8008be:	fc                   	cld    
  8008bf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008c1:	eb 05                	jmp    8008c8 <memmove+0x5e>
			             : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  8008c3:	89 c7                	mov    %eax,%edi
  8008c5:	fc                   	cld    
  8008c6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             : "cc", "memory");
	}
	return dst;
}
  8008c8:	5e                   	pop    %esi
  8008c9:	5f                   	pop    %edi
  8008ca:	5d                   	pop    %ebp
  8008cb:	c3                   	ret    

008008cc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008cc:	55                   	push   %ebp
  8008cd:	89 e5                	mov    %esp,%ebp
  8008cf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8008d2:	ff 75 10             	push   0x10(%ebp)
  8008d5:	ff 75 0c             	push   0xc(%ebp)
  8008d8:	ff 75 08             	push   0x8(%ebp)
  8008db:	e8 8a ff ff ff       	call   80086a <memmove>
}
  8008e0:	c9                   	leave  
  8008e1:	c3                   	ret    

008008e2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008e2:	55                   	push   %ebp
  8008e3:	89 e5                	mov    %esp,%ebp
  8008e5:	56                   	push   %esi
  8008e6:	53                   	push   %ebx
  8008e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ed:	89 c6                	mov    %eax,%esi
  8008ef:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8008f2:	eb 06                	jmp    8008fa <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8008f4:	83 c0 01             	add    $0x1,%eax
  8008f7:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  8008fa:	39 f0                	cmp    %esi,%eax
  8008fc:	74 14                	je     800912 <memcmp+0x30>
		if (*s1 != *s2)
  8008fe:	0f b6 08             	movzbl (%eax),%ecx
  800901:	0f b6 1a             	movzbl (%edx),%ebx
  800904:	38 d9                	cmp    %bl,%cl
  800906:	74 ec                	je     8008f4 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800908:	0f b6 c1             	movzbl %cl,%eax
  80090b:	0f b6 db             	movzbl %bl,%ebx
  80090e:	29 d8                	sub    %ebx,%eax
  800910:	eb 05                	jmp    800917 <memcmp+0x35>
	}

	return 0;
  800912:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800917:	5b                   	pop    %ebx
  800918:	5e                   	pop    %esi
  800919:	5d                   	pop    %ebp
  80091a:	c3                   	ret    

0080091b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	8b 45 08             	mov    0x8(%ebp),%eax
  800921:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800924:	89 c2                	mov    %eax,%edx
  800926:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800929:	eb 03                	jmp    80092e <memfind+0x13>
  80092b:	83 c0 01             	add    $0x1,%eax
  80092e:	39 d0                	cmp    %edx,%eax
  800930:	73 04                	jae    800936 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800932:	38 08                	cmp    %cl,(%eax)
  800934:	75 f5                	jne    80092b <memfind+0x10>
			break;
	return (void *) s;
}
  800936:	5d                   	pop    %ebp
  800937:	c3                   	ret    

00800938 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800938:	55                   	push   %ebp
  800939:	89 e5                	mov    %esp,%ebp
  80093b:	57                   	push   %edi
  80093c:	56                   	push   %esi
  80093d:	53                   	push   %ebx
  80093e:	8b 55 08             	mov    0x8(%ebp),%edx
  800941:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800944:	eb 03                	jmp    800949 <strtol+0x11>
		s++;
  800946:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800949:	0f b6 02             	movzbl (%edx),%eax
  80094c:	3c 20                	cmp    $0x20,%al
  80094e:	74 f6                	je     800946 <strtol+0xe>
  800950:	3c 09                	cmp    $0x9,%al
  800952:	74 f2                	je     800946 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800954:	3c 2b                	cmp    $0x2b,%al
  800956:	74 2a                	je     800982 <strtol+0x4a>
	int neg = 0;
  800958:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  80095d:	3c 2d                	cmp    $0x2d,%al
  80095f:	74 2b                	je     80098c <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800961:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800967:	75 0f                	jne    800978 <strtol+0x40>
  800969:	80 3a 30             	cmpb   $0x30,(%edx)
  80096c:	74 28                	je     800996 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80096e:	85 db                	test   %ebx,%ebx
  800970:	b8 0a 00 00 00       	mov    $0xa,%eax
  800975:	0f 44 d8             	cmove  %eax,%ebx
  800978:	b9 00 00 00 00       	mov    $0x0,%ecx
  80097d:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800980:	eb 46                	jmp    8009c8 <strtol+0x90>
		s++;
  800982:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800985:	bf 00 00 00 00       	mov    $0x0,%edi
  80098a:	eb d5                	jmp    800961 <strtol+0x29>
		s++, neg = 1;
  80098c:	83 c2 01             	add    $0x1,%edx
  80098f:	bf 01 00 00 00       	mov    $0x1,%edi
  800994:	eb cb                	jmp    800961 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800996:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80099a:	74 0e                	je     8009aa <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  80099c:	85 db                	test   %ebx,%ebx
  80099e:	75 d8                	jne    800978 <strtol+0x40>
		s++, base = 8;
  8009a0:	83 c2 01             	add    $0x1,%edx
  8009a3:	bb 08 00 00 00       	mov    $0x8,%ebx
  8009a8:	eb ce                	jmp    800978 <strtol+0x40>
		s += 2, base = 16;
  8009aa:	83 c2 02             	add    $0x2,%edx
  8009ad:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009b2:	eb c4                	jmp    800978 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  8009b4:	0f be c0             	movsbl %al,%eax
  8009b7:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8009ba:	3b 45 10             	cmp    0x10(%ebp),%eax
  8009bd:	7d 3a                	jge    8009f9 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  8009bf:	83 c2 01             	add    $0x1,%edx
  8009c2:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  8009c6:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  8009c8:	0f b6 02             	movzbl (%edx),%eax
  8009cb:	8d 70 d0             	lea    -0x30(%eax),%esi
  8009ce:	89 f3                	mov    %esi,%ebx
  8009d0:	80 fb 09             	cmp    $0x9,%bl
  8009d3:	76 df                	jbe    8009b4 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  8009d5:	8d 70 9f             	lea    -0x61(%eax),%esi
  8009d8:	89 f3                	mov    %esi,%ebx
  8009da:	80 fb 19             	cmp    $0x19,%bl
  8009dd:	77 08                	ja     8009e7 <strtol+0xaf>
			dig = *s - 'a' + 10;
  8009df:	0f be c0             	movsbl %al,%eax
  8009e2:	83 e8 57             	sub    $0x57,%eax
  8009e5:	eb d3                	jmp    8009ba <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  8009e7:	8d 70 bf             	lea    -0x41(%eax),%esi
  8009ea:	89 f3                	mov    %esi,%ebx
  8009ec:	80 fb 19             	cmp    $0x19,%bl
  8009ef:	77 08                	ja     8009f9 <strtol+0xc1>
			dig = *s - 'A' + 10;
  8009f1:	0f be c0             	movsbl %al,%eax
  8009f4:	83 e8 37             	sub    $0x37,%eax
  8009f7:	eb c1                	jmp    8009ba <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  8009f9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8009fd:	74 05                	je     800a04 <strtol+0xcc>
		*endptr = (char *) s;
  8009ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a02:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800a04:	89 c8                	mov    %ecx,%eax
  800a06:	f7 d8                	neg    %eax
  800a08:	85 ff                	test   %edi,%edi
  800a0a:	0f 45 c8             	cmovne %eax,%ecx
}
  800a0d:	89 c8                	mov    %ecx,%eax
  800a0f:	5b                   	pop    %ebx
  800a10:	5e                   	pop    %esi
  800a11:	5f                   	pop    %edi
  800a12:	5d                   	pop    %ebp
  800a13:	c3                   	ret    

00800a14 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	57                   	push   %edi
  800a18:	56                   	push   %esi
  800a19:	53                   	push   %ebx
  800a1a:	83 ec 1c             	sub    $0x1c,%esp
  800a1d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a20:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800a23:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile(
  800a25:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a28:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a2b:	8b 7d 10             	mov    0x10(%ebp),%edi
  800a2e:	8b 75 14             	mov    0x14(%ebp),%esi
  800a31:	cd 30                	int    $0x30
	        "int %1\n"
	        : "=a"(ret)
	        : "i"(T_SYSCALL), "a"(num), "d"(a1), "c"(a2), "b"(a3), "D"(a4), "S"(a5)
	        : "cc", "memory");

	if (check && ret > 0)
  800a33:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a37:	74 04                	je     800a3d <syscall+0x29>
  800a39:	85 c0                	test   %eax,%eax
  800a3b:	7f 08                	jg     800a45 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800a3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a40:	5b                   	pop    %ebx
  800a41:	5e                   	pop    %esi
  800a42:	5f                   	pop    %edi
  800a43:	5d                   	pop    %ebp
  800a44:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800a45:	83 ec 0c             	sub    $0xc,%esp
  800a48:	50                   	push   %eax
  800a49:	ff 75 e0             	push   -0x20(%ebp)
  800a4c:	68 84 11 80 00       	push   $0x801184
  800a51:	6a 1e                	push   $0x1e
  800a53:	68 a1 11 80 00       	push   $0x8011a1
  800a58:	e8 f7 01 00 00       	call   800c54 <_panic>

00800a5d <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800a5d:	55                   	push   %ebp
  800a5e:	89 e5                	mov    %esp,%ebp
  800a60:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t) s, len, 0, 0, 0);
  800a63:	6a 00                	push   $0x0
  800a65:	6a 00                	push   $0x0
  800a67:	6a 00                	push   $0x0
  800a69:	ff 75 0c             	push   0xc(%ebp)
  800a6c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a6f:	ba 00 00 00 00       	mov    $0x0,%edx
  800a74:	b8 00 00 00 00       	mov    $0x0,%eax
  800a79:	e8 96 ff ff ff       	call   800a14 <syscall>
}
  800a7e:	83 c4 10             	add    $0x10,%esp
  800a81:	c9                   	leave  
  800a82:	c3                   	ret    

00800a83 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a83:	55                   	push   %ebp
  800a84:	89 e5                	mov    %esp,%ebp
  800a86:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800a89:	6a 00                	push   $0x0
  800a8b:	6a 00                	push   $0x0
  800a8d:	6a 00                	push   $0x0
  800a8f:	6a 00                	push   $0x0
  800a91:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a96:	ba 00 00 00 00       	mov    $0x0,%edx
  800a9b:	b8 01 00 00 00       	mov    $0x1,%eax
  800aa0:	e8 6f ff ff ff       	call   800a14 <syscall>
}
  800aa5:	c9                   	leave  
  800aa6:	c3                   	ret    

00800aa7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aa7:	55                   	push   %ebp
  800aa8:	89 e5                	mov    %esp,%ebp
  800aaa:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800aad:	6a 00                	push   $0x0
  800aaf:	6a 00                	push   $0x0
  800ab1:	6a 00                	push   $0x0
  800ab3:	6a 00                	push   $0x0
  800ab5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ab8:	ba 01 00 00 00       	mov    $0x1,%edx
  800abd:	b8 03 00 00 00       	mov    $0x3,%eax
  800ac2:	e8 4d ff ff ff       	call   800a14 <syscall>
}
  800ac7:	c9                   	leave  
  800ac8:	c3                   	ret    

00800ac9 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ac9:	55                   	push   %ebp
  800aca:	89 e5                	mov    %esp,%ebp
  800acc:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800acf:	6a 00                	push   $0x0
  800ad1:	6a 00                	push   $0x0
  800ad3:	6a 00                	push   $0x0
  800ad5:	6a 00                	push   $0x0
  800ad7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800adc:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae1:	b8 02 00 00 00       	mov    $0x2,%eax
  800ae6:	e8 29 ff ff ff       	call   800a14 <syscall>
}
  800aeb:	c9                   	leave  
  800aec:	c3                   	ret    

00800aed <sys_yield>:

void
sys_yield(void)
{
  800aed:	55                   	push   %ebp
  800aee:	89 e5                	mov    %esp,%ebp
  800af0:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800af3:	6a 00                	push   $0x0
  800af5:	6a 00                	push   $0x0
  800af7:	6a 00                	push   $0x0
  800af9:	6a 00                	push   $0x0
  800afb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b00:	ba 00 00 00 00       	mov    $0x0,%edx
  800b05:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b0a:	e8 05 ff ff ff       	call   800a14 <syscall>
}
  800b0f:	83 c4 10             	add    $0x10,%esp
  800b12:	c9                   	leave  
  800b13:	c3                   	ret    

00800b14 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b14:	55                   	push   %ebp
  800b15:	89 e5                	mov    %esp,%ebp
  800b17:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800b1a:	6a 00                	push   $0x0
  800b1c:	6a 00                	push   $0x0
  800b1e:	ff 75 10             	push   0x10(%ebp)
  800b21:	ff 75 0c             	push   0xc(%ebp)
  800b24:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b27:	ba 01 00 00 00       	mov    $0x1,%edx
  800b2c:	b8 04 00 00 00       	mov    $0x4,%eax
  800b31:	e8 de fe ff ff       	call   800a14 <syscall>
}
  800b36:	c9                   	leave  
  800b37:	c3                   	ret    

00800b38 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
  800b3b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map,
  800b3e:	ff 75 18             	push   0x18(%ebp)
  800b41:	ff 75 14             	push   0x14(%ebp)
  800b44:	ff 75 10             	push   0x10(%ebp)
  800b47:	ff 75 0c             	push   0xc(%ebp)
  800b4a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b4d:	ba 01 00 00 00       	mov    $0x1,%edx
  800b52:	b8 05 00 00 00       	mov    $0x5,%eax
  800b57:	e8 b8 fe ff ff       	call   800a14 <syscall>
	               srcenv,
	               (uint32_t) srcva,
	               dstenv,
	               (uint32_t) dstva,
	               perm);
}
  800b5c:	c9                   	leave  
  800b5d:	c3                   	ret    

00800b5e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b5e:	55                   	push   %ebp
  800b5f:	89 e5                	mov    %esp,%ebp
  800b61:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800b64:	6a 00                	push   $0x0
  800b66:	6a 00                	push   $0x0
  800b68:	6a 00                	push   $0x0
  800b6a:	ff 75 0c             	push   0xc(%ebp)
  800b6d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b70:	ba 01 00 00 00       	mov    $0x1,%edx
  800b75:	b8 06 00 00 00       	mov    $0x6,%eax
  800b7a:	e8 95 fe ff ff       	call   800a14 <syscall>
}
  800b7f:	c9                   	leave  
  800b80:	c3                   	ret    

00800b81 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800b87:	6a 00                	push   $0x0
  800b89:	6a 00                	push   $0x0
  800b8b:	6a 00                	push   $0x0
  800b8d:	ff 75 0c             	push   0xc(%ebp)
  800b90:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b93:	ba 01 00 00 00       	mov    $0x1,%edx
  800b98:	b8 08 00 00 00       	mov    $0x8,%eax
  800b9d:	e8 72 fe ff ff       	call   800a14 <syscall>
}
  800ba2:	c9                   	leave  
  800ba3:	c3                   	ret    

00800ba4 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ba4:	55                   	push   %ebp
  800ba5:	89 e5                	mov    %esp,%ebp
  800ba7:	83 ec 08             	sub    $0x8,%esp
	return syscall(
  800baa:	6a 00                	push   $0x0
  800bac:	6a 00                	push   $0x0
  800bae:	6a 00                	push   $0x0
  800bb0:	ff 75 0c             	push   0xc(%ebp)
  800bb3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bb6:	ba 01 00 00 00       	mov    $0x1,%edx
  800bbb:	b8 09 00 00 00       	mov    $0x9,%eax
  800bc0:	e8 4f fe ff ff       	call   800a14 <syscall>
	        SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800bc5:	c9                   	leave  
  800bc6:	c3                   	ret    

00800bc7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800bc7:	55                   	push   %ebp
  800bc8:	89 e5                	mov    %esp,%ebp
  800bca:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800bcd:	6a 00                	push   $0x0
  800bcf:	ff 75 14             	push   0x14(%ebp)
  800bd2:	ff 75 10             	push   0x10(%ebp)
  800bd5:	ff 75 0c             	push   0xc(%ebp)
  800bd8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bdb:	ba 00 00 00 00       	mov    $0x0,%edx
  800be0:	b8 0b 00 00 00       	mov    $0xb,%eax
  800be5:	e8 2a fe ff ff       	call   800a14 <syscall>
}
  800bea:	c9                   	leave  
  800beb:	c3                   	ret    

00800bec <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
  800bef:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t) dstva, 0, 0, 0, 0);
  800bf2:	6a 00                	push   $0x0
  800bf4:	6a 00                	push   $0x0
  800bf6:	6a 00                	push   $0x0
  800bf8:	6a 00                	push   $0x0
  800bfa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bfd:	ba 01 00 00 00       	mov    $0x1,%edx
  800c02:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c07:	e8 08 fe ff ff       	call   800a14 <syscall>
}
  800c0c:	c9                   	leave  
  800c0d:	c3                   	ret    

00800c0e <sys_get_priority>:

// Get priority of the current process
int
sys_get_priority(void)
{
  800c0e:	55                   	push   %ebp
  800c0f:	89 e5                	mov    %esp,%ebp
  800c11:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_get_priority, 0, 0, 0, 0, 0, 0);
  800c14:	6a 00                	push   $0x0
  800c16:	6a 00                	push   $0x0
  800c18:	6a 00                	push   $0x0
  800c1a:	6a 00                	push   $0x0
  800c1c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c21:	ba 00 00 00 00       	mov    $0x0,%edx
  800c26:	b8 0d 00 00 00       	mov    $0xd,%eax
  800c2b:	e8 e4 fd ff ff       	call   800a14 <syscall>
}
  800c30:	c9                   	leave  
  800c31:	c3                   	ret    

00800c32 <sys_set_priority>:

// Get priority of the current process
int
sys_set_priority(unsigned int priority)
{
  800c32:	55                   	push   %ebp
  800c33:	89 e5                	mov    %esp,%ebp
  800c35:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, (uint32_t) priority, 0, 0, 0, 0);
  800c38:	6a 00                	push   $0x0
  800c3a:	6a 00                	push   $0x0
  800c3c:	6a 00                	push   $0x0
  800c3e:	6a 00                	push   $0x0
  800c40:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c43:	ba 00 00 00 00       	mov    $0x0,%edx
  800c48:	b8 0e 00 00 00       	mov    $0xe,%eax
  800c4d:	e8 c2 fd ff ff       	call   800a14 <syscall>
}
  800c52:	c9                   	leave  
  800c53:	c3                   	ret    

00800c54 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800c54:	55                   	push   %ebp
  800c55:	89 e5                	mov    %esp,%ebp
  800c57:	56                   	push   %esi
  800c58:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800c59:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800c5c:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800c62:	e8 62 fe ff ff       	call   800ac9 <sys_getenvid>
  800c67:	83 ec 0c             	sub    $0xc,%esp
  800c6a:	ff 75 0c             	push   0xc(%ebp)
  800c6d:	ff 75 08             	push   0x8(%ebp)
  800c70:	56                   	push   %esi
  800c71:	50                   	push   %eax
  800c72:	68 b0 11 80 00       	push   $0x8011b0
  800c77:	e8 1b f5 ff ff       	call   800197 <cprintf>
	        sys_getenvid(),
	        binaryname,
	        file,
	        line);
	vcprintf(fmt, ap);
  800c7c:	83 c4 18             	add    $0x18,%esp
  800c7f:	53                   	push   %ebx
  800c80:	ff 75 10             	push   0x10(%ebp)
  800c83:	e8 be f4 ff ff       	call   800146 <vcprintf>
	cprintf("\n");
  800c88:	c7 04 24 d3 11 80 00 	movl   $0x8011d3,(%esp)
  800c8f:	e8 03 f5 ff ff       	call   800197 <cprintf>
  800c94:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800c97:	cc                   	int3   
  800c98:	eb fd                	jmp    800c97 <_panic+0x43>
  800c9a:	66 90                	xchg   %ax,%ax
  800c9c:	66 90                	xchg   %ax,%ax
  800c9e:	66 90                	xchg   %ax,%ax

00800ca0 <__udivdi3>:
  800ca0:	f3 0f 1e fb          	endbr32 
  800ca4:	55                   	push   %ebp
  800ca5:	57                   	push   %edi
  800ca6:	56                   	push   %esi
  800ca7:	53                   	push   %ebx
  800ca8:	83 ec 1c             	sub    $0x1c,%esp
  800cab:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800caf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800cb3:	8b 74 24 34          	mov    0x34(%esp),%esi
  800cb7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800cbb:	85 c0                	test   %eax,%eax
  800cbd:	75 19                	jne    800cd8 <__udivdi3+0x38>
  800cbf:	39 f3                	cmp    %esi,%ebx
  800cc1:	76 4d                	jbe    800d10 <__udivdi3+0x70>
  800cc3:	31 ff                	xor    %edi,%edi
  800cc5:	89 e8                	mov    %ebp,%eax
  800cc7:	89 f2                	mov    %esi,%edx
  800cc9:	f7 f3                	div    %ebx
  800ccb:	89 fa                	mov    %edi,%edx
  800ccd:	83 c4 1c             	add    $0x1c,%esp
  800cd0:	5b                   	pop    %ebx
  800cd1:	5e                   	pop    %esi
  800cd2:	5f                   	pop    %edi
  800cd3:	5d                   	pop    %ebp
  800cd4:	c3                   	ret    
  800cd5:	8d 76 00             	lea    0x0(%esi),%esi
  800cd8:	39 f0                	cmp    %esi,%eax
  800cda:	76 14                	jbe    800cf0 <__udivdi3+0x50>
  800cdc:	31 ff                	xor    %edi,%edi
  800cde:	31 c0                	xor    %eax,%eax
  800ce0:	89 fa                	mov    %edi,%edx
  800ce2:	83 c4 1c             	add    $0x1c,%esp
  800ce5:	5b                   	pop    %ebx
  800ce6:	5e                   	pop    %esi
  800ce7:	5f                   	pop    %edi
  800ce8:	5d                   	pop    %ebp
  800ce9:	c3                   	ret    
  800cea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800cf0:	0f bd f8             	bsr    %eax,%edi
  800cf3:	83 f7 1f             	xor    $0x1f,%edi
  800cf6:	75 48                	jne    800d40 <__udivdi3+0xa0>
  800cf8:	39 f0                	cmp    %esi,%eax
  800cfa:	72 06                	jb     800d02 <__udivdi3+0x62>
  800cfc:	31 c0                	xor    %eax,%eax
  800cfe:	39 eb                	cmp    %ebp,%ebx
  800d00:	77 de                	ja     800ce0 <__udivdi3+0x40>
  800d02:	b8 01 00 00 00       	mov    $0x1,%eax
  800d07:	eb d7                	jmp    800ce0 <__udivdi3+0x40>
  800d09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d10:	89 d9                	mov    %ebx,%ecx
  800d12:	85 db                	test   %ebx,%ebx
  800d14:	75 0b                	jne    800d21 <__udivdi3+0x81>
  800d16:	b8 01 00 00 00       	mov    $0x1,%eax
  800d1b:	31 d2                	xor    %edx,%edx
  800d1d:	f7 f3                	div    %ebx
  800d1f:	89 c1                	mov    %eax,%ecx
  800d21:	31 d2                	xor    %edx,%edx
  800d23:	89 f0                	mov    %esi,%eax
  800d25:	f7 f1                	div    %ecx
  800d27:	89 c6                	mov    %eax,%esi
  800d29:	89 e8                	mov    %ebp,%eax
  800d2b:	89 f7                	mov    %esi,%edi
  800d2d:	f7 f1                	div    %ecx
  800d2f:	89 fa                	mov    %edi,%edx
  800d31:	83 c4 1c             	add    $0x1c,%esp
  800d34:	5b                   	pop    %ebx
  800d35:	5e                   	pop    %esi
  800d36:	5f                   	pop    %edi
  800d37:	5d                   	pop    %ebp
  800d38:	c3                   	ret    
  800d39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d40:	89 f9                	mov    %edi,%ecx
  800d42:	ba 20 00 00 00       	mov    $0x20,%edx
  800d47:	29 fa                	sub    %edi,%edx
  800d49:	d3 e0                	shl    %cl,%eax
  800d4b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d4f:	89 d1                	mov    %edx,%ecx
  800d51:	89 d8                	mov    %ebx,%eax
  800d53:	d3 e8                	shr    %cl,%eax
  800d55:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800d59:	09 c1                	or     %eax,%ecx
  800d5b:	89 f0                	mov    %esi,%eax
  800d5d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d61:	89 f9                	mov    %edi,%ecx
  800d63:	d3 e3                	shl    %cl,%ebx
  800d65:	89 d1                	mov    %edx,%ecx
  800d67:	d3 e8                	shr    %cl,%eax
  800d69:	89 f9                	mov    %edi,%ecx
  800d6b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800d6f:	89 eb                	mov    %ebp,%ebx
  800d71:	d3 e6                	shl    %cl,%esi
  800d73:	89 d1                	mov    %edx,%ecx
  800d75:	d3 eb                	shr    %cl,%ebx
  800d77:	09 f3                	or     %esi,%ebx
  800d79:	89 c6                	mov    %eax,%esi
  800d7b:	89 f2                	mov    %esi,%edx
  800d7d:	89 d8                	mov    %ebx,%eax
  800d7f:	f7 74 24 08          	divl   0x8(%esp)
  800d83:	89 d6                	mov    %edx,%esi
  800d85:	89 c3                	mov    %eax,%ebx
  800d87:	f7 64 24 0c          	mull   0xc(%esp)
  800d8b:	39 d6                	cmp    %edx,%esi
  800d8d:	72 19                	jb     800da8 <__udivdi3+0x108>
  800d8f:	89 f9                	mov    %edi,%ecx
  800d91:	d3 e5                	shl    %cl,%ebp
  800d93:	39 c5                	cmp    %eax,%ebp
  800d95:	73 04                	jae    800d9b <__udivdi3+0xfb>
  800d97:	39 d6                	cmp    %edx,%esi
  800d99:	74 0d                	je     800da8 <__udivdi3+0x108>
  800d9b:	89 d8                	mov    %ebx,%eax
  800d9d:	31 ff                	xor    %edi,%edi
  800d9f:	e9 3c ff ff ff       	jmp    800ce0 <__udivdi3+0x40>
  800da4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800da8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800dab:	31 ff                	xor    %edi,%edi
  800dad:	e9 2e ff ff ff       	jmp    800ce0 <__udivdi3+0x40>
  800db2:	66 90                	xchg   %ax,%ax
  800db4:	66 90                	xchg   %ax,%ax
  800db6:	66 90                	xchg   %ax,%ax
  800db8:	66 90                	xchg   %ax,%ax
  800dba:	66 90                	xchg   %ax,%ax
  800dbc:	66 90                	xchg   %ax,%ax
  800dbe:	66 90                	xchg   %ax,%ax

00800dc0 <__umoddi3>:
  800dc0:	f3 0f 1e fb          	endbr32 
  800dc4:	55                   	push   %ebp
  800dc5:	57                   	push   %edi
  800dc6:	56                   	push   %esi
  800dc7:	53                   	push   %ebx
  800dc8:	83 ec 1c             	sub    $0x1c,%esp
  800dcb:	8b 74 24 30          	mov    0x30(%esp),%esi
  800dcf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800dd3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  800dd7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  800ddb:	89 f0                	mov    %esi,%eax
  800ddd:	89 da                	mov    %ebx,%edx
  800ddf:	85 ff                	test   %edi,%edi
  800de1:	75 15                	jne    800df8 <__umoddi3+0x38>
  800de3:	39 dd                	cmp    %ebx,%ebp
  800de5:	76 39                	jbe    800e20 <__umoddi3+0x60>
  800de7:	f7 f5                	div    %ebp
  800de9:	89 d0                	mov    %edx,%eax
  800deb:	31 d2                	xor    %edx,%edx
  800ded:	83 c4 1c             	add    $0x1c,%esp
  800df0:	5b                   	pop    %ebx
  800df1:	5e                   	pop    %esi
  800df2:	5f                   	pop    %edi
  800df3:	5d                   	pop    %ebp
  800df4:	c3                   	ret    
  800df5:	8d 76 00             	lea    0x0(%esi),%esi
  800df8:	39 df                	cmp    %ebx,%edi
  800dfa:	77 f1                	ja     800ded <__umoddi3+0x2d>
  800dfc:	0f bd cf             	bsr    %edi,%ecx
  800dff:	83 f1 1f             	xor    $0x1f,%ecx
  800e02:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800e06:	75 40                	jne    800e48 <__umoddi3+0x88>
  800e08:	39 df                	cmp    %ebx,%edi
  800e0a:	72 04                	jb     800e10 <__umoddi3+0x50>
  800e0c:	39 f5                	cmp    %esi,%ebp
  800e0e:	77 dd                	ja     800ded <__umoddi3+0x2d>
  800e10:	89 da                	mov    %ebx,%edx
  800e12:	89 f0                	mov    %esi,%eax
  800e14:	29 e8                	sub    %ebp,%eax
  800e16:	19 fa                	sbb    %edi,%edx
  800e18:	eb d3                	jmp    800ded <__umoddi3+0x2d>
  800e1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e20:	89 e9                	mov    %ebp,%ecx
  800e22:	85 ed                	test   %ebp,%ebp
  800e24:	75 0b                	jne    800e31 <__umoddi3+0x71>
  800e26:	b8 01 00 00 00       	mov    $0x1,%eax
  800e2b:	31 d2                	xor    %edx,%edx
  800e2d:	f7 f5                	div    %ebp
  800e2f:	89 c1                	mov    %eax,%ecx
  800e31:	89 d8                	mov    %ebx,%eax
  800e33:	31 d2                	xor    %edx,%edx
  800e35:	f7 f1                	div    %ecx
  800e37:	89 f0                	mov    %esi,%eax
  800e39:	f7 f1                	div    %ecx
  800e3b:	89 d0                	mov    %edx,%eax
  800e3d:	31 d2                	xor    %edx,%edx
  800e3f:	eb ac                	jmp    800ded <__umoddi3+0x2d>
  800e41:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e48:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e4c:	ba 20 00 00 00       	mov    $0x20,%edx
  800e51:	29 c2                	sub    %eax,%edx
  800e53:	89 c1                	mov    %eax,%ecx
  800e55:	89 e8                	mov    %ebp,%eax
  800e57:	d3 e7                	shl    %cl,%edi
  800e59:	89 d1                	mov    %edx,%ecx
  800e5b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e5f:	d3 e8                	shr    %cl,%eax
  800e61:	89 c1                	mov    %eax,%ecx
  800e63:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e67:	09 f9                	or     %edi,%ecx
  800e69:	89 df                	mov    %ebx,%edi
  800e6b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e6f:	89 c1                	mov    %eax,%ecx
  800e71:	d3 e5                	shl    %cl,%ebp
  800e73:	89 d1                	mov    %edx,%ecx
  800e75:	d3 ef                	shr    %cl,%edi
  800e77:	89 c1                	mov    %eax,%ecx
  800e79:	89 f0                	mov    %esi,%eax
  800e7b:	d3 e3                	shl    %cl,%ebx
  800e7d:	89 d1                	mov    %edx,%ecx
  800e7f:	89 fa                	mov    %edi,%edx
  800e81:	d3 e8                	shr    %cl,%eax
  800e83:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e88:	09 d8                	or     %ebx,%eax
  800e8a:	f7 74 24 08          	divl   0x8(%esp)
  800e8e:	89 d3                	mov    %edx,%ebx
  800e90:	d3 e6                	shl    %cl,%esi
  800e92:	f7 e5                	mul    %ebp
  800e94:	89 c7                	mov    %eax,%edi
  800e96:	89 d1                	mov    %edx,%ecx
  800e98:	39 d3                	cmp    %edx,%ebx
  800e9a:	72 06                	jb     800ea2 <__umoddi3+0xe2>
  800e9c:	75 0e                	jne    800eac <__umoddi3+0xec>
  800e9e:	39 c6                	cmp    %eax,%esi
  800ea0:	73 0a                	jae    800eac <__umoddi3+0xec>
  800ea2:	29 e8                	sub    %ebp,%eax
  800ea4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800ea8:	89 d1                	mov    %edx,%ecx
  800eaa:	89 c7                	mov    %eax,%edi
  800eac:	89 f5                	mov    %esi,%ebp
  800eae:	8b 74 24 04          	mov    0x4(%esp),%esi
  800eb2:	29 fd                	sub    %edi,%ebp
  800eb4:	19 cb                	sbb    %ecx,%ebx
  800eb6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800ebb:	89 d8                	mov    %ebx,%eax
  800ebd:	d3 e0                	shl    %cl,%eax
  800ebf:	89 f1                	mov    %esi,%ecx
  800ec1:	d3 ed                	shr    %cl,%ebp
  800ec3:	d3 eb                	shr    %cl,%ebx
  800ec5:	09 e8                	or     %ebp,%eax
  800ec7:	89 da                	mov    %ebx,%edx
  800ec9:	83 c4 1c             	add    $0x1c,%esp
  800ecc:	5b                   	pop    %ebx
  800ecd:	5e                   	pop    %esi
  800ece:	5f                   	pop    %edi
  800ecf:	5d                   	pop    %ebp
  800ed0:	c3                   	ret    
