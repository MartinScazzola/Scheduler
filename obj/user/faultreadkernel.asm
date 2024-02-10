
obj/user/faultreadkernel:     formato del fichero elf32-i386


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

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	cprintf("I read %08x from location 0xf0100000!\n",
  800039:	ff 35 00 00 10 f0    	push   0xf0100000
  80003f:	68 a0 0e 80 00       	push   $0x800ea0
  800044:	e8 f9 00 00 00       	call   800142 <cprintf>
	        *(unsigned *) 0xf0100000);
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
  800059:	e8 16 0a 00 00       	call   800a74 <sys_getenvid>
	if (id >= 0)
  80005e:	85 c0                	test   %eax,%eax
  800060:	78 15                	js     800077 <libmain+0x29>
		thisenv = &envs[ENVX(id)];
  800062:	25 ff 03 00 00       	and    $0x3ff,%eax
  800067:	69 c0 88 00 00 00    	imul   $0x88,%eax,%eax
  80006d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800072:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800077:	85 db                	test   %ebx,%ebx
  800079:	7e 07                	jle    800082 <libmain+0x34>
		binaryname = argv[0];
  80007b:	8b 06                	mov    (%esi),%eax
  80007d:	a3 00 20 80 00       	mov    %eax,0x802000

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
  8000a3:	e8 aa 09 00 00       	call   800a52 <sys_env_destroy>
}
  8000a8:	83 c4 10             	add    $0x10,%esp
  8000ab:	c9                   	leave  
  8000ac:	c3                   	ret    

008000ad <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000ad:	55                   	push   %ebp
  8000ae:	89 e5                	mov    %esp,%ebp
  8000b0:	53                   	push   %ebx
  8000b1:	83 ec 04             	sub    $0x4,%esp
  8000b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000b7:	8b 13                	mov    (%ebx),%edx
  8000b9:	8d 42 01             	lea    0x1(%edx),%eax
  8000bc:	89 03                	mov    %eax,(%ebx)
  8000be:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000c1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256 - 1) {
  8000c5:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000ca:	74 09                	je     8000d5 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000cc:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000d3:	c9                   	leave  
  8000d4:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8000d5:	83 ec 08             	sub    $0x8,%esp
  8000d8:	68 ff 00 00 00       	push   $0xff
  8000dd:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e0:	50                   	push   %eax
  8000e1:	e8 22 09 00 00       	call   800a08 <sys_cputs>
		b->idx = 0;
  8000e6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000ec:	83 c4 10             	add    $0x10,%esp
  8000ef:	eb db                	jmp    8000cc <putch+0x1f>

008000f1 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000f1:	55                   	push   %ebp
  8000f2:	89 e5                	mov    %esp,%ebp
  8000f4:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8000fa:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800101:	00 00 00 
	b.cnt = 0;
  800104:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80010b:	00 00 00 
	vprintfmt((void *) putch, &b, fmt, ap);
  80010e:	ff 75 0c             	push   0xc(%ebp)
  800111:	ff 75 08             	push   0x8(%ebp)
  800114:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80011a:	50                   	push   %eax
  80011b:	68 ad 00 80 00       	push   $0x8000ad
  800120:	e8 74 01 00 00       	call   800299 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800125:	83 c4 08             	add    $0x8,%esp
  800128:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  80012e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800134:	50                   	push   %eax
  800135:	e8 ce 08 00 00       	call   800a08 <sys_cputs>

	return b.cnt;
}
  80013a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800140:	c9                   	leave  
  800141:	c3                   	ret    

00800142 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800142:	55                   	push   %ebp
  800143:	89 e5                	mov    %esp,%ebp
  800145:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800148:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80014b:	50                   	push   %eax
  80014c:	ff 75 08             	push   0x8(%ebp)
  80014f:	e8 9d ff ff ff       	call   8000f1 <vcprintf>
	va_end(ap);

	return cnt;
}
  800154:	c9                   	leave  
  800155:	c3                   	ret    

00800156 <printnum>:
         void *putdat,
         unsigned long long num,
         unsigned base,
         int width,
         int padc)
{
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	57                   	push   %edi
  80015a:	56                   	push   %esi
  80015b:	53                   	push   %ebx
  80015c:	83 ec 1c             	sub    $0x1c,%esp
  80015f:	89 c7                	mov    %eax,%edi
  800161:	89 d6                	mov    %edx,%esi
  800163:	8b 45 08             	mov    0x8(%ebp),%eax
  800166:	8b 55 0c             	mov    0xc(%ebp),%edx
  800169:	89 d1                	mov    %edx,%ecx
  80016b:	89 c2                	mov    %eax,%edx
  80016d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800170:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800173:	8b 45 10             	mov    0x10(%ebp),%eax
  800176:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800179:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80017c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800183:	39 c2                	cmp    %eax,%edx
  800185:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800188:	72 3e                	jb     8001c8 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80018a:	83 ec 0c             	sub    $0xc,%esp
  80018d:	ff 75 18             	push   0x18(%ebp)
  800190:	83 eb 01             	sub    $0x1,%ebx
  800193:	53                   	push   %ebx
  800194:	50                   	push   %eax
  800195:	83 ec 08             	sub    $0x8,%esp
  800198:	ff 75 e4             	push   -0x1c(%ebp)
  80019b:	ff 75 e0             	push   -0x20(%ebp)
  80019e:	ff 75 dc             	push   -0x24(%ebp)
  8001a1:	ff 75 d8             	push   -0x28(%ebp)
  8001a4:	e8 a7 0a 00 00       	call   800c50 <__udivdi3>
  8001a9:	83 c4 18             	add    $0x18,%esp
  8001ac:	52                   	push   %edx
  8001ad:	50                   	push   %eax
  8001ae:	89 f2                	mov    %esi,%edx
  8001b0:	89 f8                	mov    %edi,%eax
  8001b2:	e8 9f ff ff ff       	call   800156 <printnum>
  8001b7:	83 c4 20             	add    $0x20,%esp
  8001ba:	eb 13                	jmp    8001cf <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001bc:	83 ec 08             	sub    $0x8,%esp
  8001bf:	56                   	push   %esi
  8001c0:	ff 75 18             	push   0x18(%ebp)
  8001c3:	ff d7                	call   *%edi
  8001c5:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001c8:	83 eb 01             	sub    $0x1,%ebx
  8001cb:	85 db                	test   %ebx,%ebx
  8001cd:	7f ed                	jg     8001bc <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001cf:	83 ec 08             	sub    $0x8,%esp
  8001d2:	56                   	push   %esi
  8001d3:	83 ec 04             	sub    $0x4,%esp
  8001d6:	ff 75 e4             	push   -0x1c(%ebp)
  8001d9:	ff 75 e0             	push   -0x20(%ebp)
  8001dc:	ff 75 dc             	push   -0x24(%ebp)
  8001df:	ff 75 d8             	push   -0x28(%ebp)
  8001e2:	e8 89 0b 00 00       	call   800d70 <__umoddi3>
  8001e7:	83 c4 14             	add    $0x14,%esp
  8001ea:	0f be 80 d1 0e 80 00 	movsbl 0x800ed1(%eax),%eax
  8001f1:	50                   	push   %eax
  8001f2:	ff d7                	call   *%edi
}
  8001f4:	83 c4 10             	add    $0x10,%esp
  8001f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001fa:	5b                   	pop    %ebx
  8001fb:	5e                   	pop    %esi
  8001fc:	5f                   	pop    %edi
  8001fd:	5d                   	pop    %ebp
  8001fe:	c3                   	ret    

008001ff <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8001ff:	83 fa 01             	cmp    $0x1,%edx
  800202:	7f 13                	jg     800217 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800204:	85 d2                	test   %edx,%edx
  800206:	74 1c                	je     800224 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  800208:	8b 10                	mov    (%eax),%edx
  80020a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80020d:	89 08                	mov    %ecx,(%eax)
  80020f:	8b 02                	mov    (%edx),%eax
  800211:	ba 00 00 00 00       	mov    $0x0,%edx
  800216:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  800217:	8b 10                	mov    (%eax),%edx
  800219:	8d 4a 08             	lea    0x8(%edx),%ecx
  80021c:	89 08                	mov    %ecx,(%eax)
  80021e:	8b 02                	mov    (%edx),%eax
  800220:	8b 52 04             	mov    0x4(%edx),%edx
  800223:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  800224:	8b 10                	mov    (%eax),%edx
  800226:	8d 4a 04             	lea    0x4(%edx),%ecx
  800229:	89 08                	mov    %ecx,(%eax)
  80022b:	8b 02                	mov    (%edx),%eax
  80022d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800232:	c3                   	ret    

00800233 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800233:	83 fa 01             	cmp    $0x1,%edx
  800236:	7f 0f                	jg     800247 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  800238:	85 d2                	test   %edx,%edx
  80023a:	74 18                	je     800254 <getint+0x21>
		return va_arg(*ap, long);
  80023c:	8b 10                	mov    (%eax),%edx
  80023e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800241:	89 08                	mov    %ecx,(%eax)
  800243:	8b 02                	mov    (%edx),%eax
  800245:	99                   	cltd   
  800246:	c3                   	ret    
		return va_arg(*ap, long long);
  800247:	8b 10                	mov    (%eax),%edx
  800249:	8d 4a 08             	lea    0x8(%edx),%ecx
  80024c:	89 08                	mov    %ecx,(%eax)
  80024e:	8b 02                	mov    (%edx),%eax
  800250:	8b 52 04             	mov    0x4(%edx),%edx
  800253:	c3                   	ret    
	else
		return va_arg(*ap, int);
  800254:	8b 10                	mov    (%eax),%edx
  800256:	8d 4a 04             	lea    0x4(%edx),%ecx
  800259:	89 08                	mov    %ecx,(%eax)
  80025b:	8b 02                	mov    (%edx),%eax
  80025d:	99                   	cltd   
}
  80025e:	c3                   	ret    

0080025f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80025f:	55                   	push   %ebp
  800260:	89 e5                	mov    %esp,%ebp
  800262:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800265:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800269:	8b 10                	mov    (%eax),%edx
  80026b:	3b 50 04             	cmp    0x4(%eax),%edx
  80026e:	73 0a                	jae    80027a <sprintputch+0x1b>
		*b->buf++ = ch;
  800270:	8d 4a 01             	lea    0x1(%edx),%ecx
  800273:	89 08                	mov    %ecx,(%eax)
  800275:	8b 45 08             	mov    0x8(%ebp),%eax
  800278:	88 02                	mov    %al,(%edx)
}
  80027a:	5d                   	pop    %ebp
  80027b:	c3                   	ret    

0080027c <printfmt>:
{
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
  80027f:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800282:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800285:	50                   	push   %eax
  800286:	ff 75 10             	push   0x10(%ebp)
  800289:	ff 75 0c             	push   0xc(%ebp)
  80028c:	ff 75 08             	push   0x8(%ebp)
  80028f:	e8 05 00 00 00       	call   800299 <vprintfmt>
}
  800294:	83 c4 10             	add    $0x10,%esp
  800297:	c9                   	leave  
  800298:	c3                   	ret    

00800299 <vprintfmt>:
{
  800299:	55                   	push   %ebp
  80029a:	89 e5                	mov    %esp,%ebp
  80029c:	57                   	push   %edi
  80029d:	56                   	push   %esi
  80029e:	53                   	push   %ebx
  80029f:	83 ec 2c             	sub    $0x2c,%esp
  8002a2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002a5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8002a8:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002ab:	eb 0a                	jmp    8002b7 <vprintfmt+0x1e>
			putch(ch, putdat);
  8002ad:	83 ec 08             	sub    $0x8,%esp
  8002b0:	56                   	push   %esi
  8002b1:	50                   	push   %eax
  8002b2:	ff d3                	call   *%ebx
  8002b4:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002b7:	83 c7 01             	add    $0x1,%edi
  8002ba:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002be:	83 f8 25             	cmp    $0x25,%eax
  8002c1:	74 0c                	je     8002cf <vprintfmt+0x36>
			if (ch == '\0')
  8002c3:	85 c0                	test   %eax,%eax
  8002c5:	75 e6                	jne    8002ad <vprintfmt+0x14>
}
  8002c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ca:	5b                   	pop    %ebx
  8002cb:	5e                   	pop    %esi
  8002cc:	5f                   	pop    %edi
  8002cd:	5d                   	pop    %ebp
  8002ce:	c3                   	ret    
		padc = ' ';
  8002cf:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
		altflag = 0;
  8002d3:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002da:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002e1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002e8:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002ed:	8d 47 01             	lea    0x1(%edi),%eax
  8002f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002f3:	0f b6 17             	movzbl (%edi),%edx
  8002f6:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002f9:	3c 55                	cmp    $0x55,%al
  8002fb:	0f 87 b7 02 00 00    	ja     8005b8 <vprintfmt+0x31f>
  800301:	0f b6 c0             	movzbl %al,%eax
  800304:	ff 24 85 a0 0f 80 00 	jmp    *0x800fa0(,%eax,4)
  80030b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80030e:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800312:	eb d9                	jmp    8002ed <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800314:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800317:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  80031b:	eb d0                	jmp    8002ed <vprintfmt+0x54>
  80031d:	0f b6 d2             	movzbl %dl,%edx
  800320:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0;; ++fmt) {
  800323:	b8 00 00 00 00       	mov    $0x0,%eax
  800328:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80032b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80032e:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800332:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800335:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800338:	83 f9 09             	cmp    $0x9,%ecx
  80033b:	77 52                	ja     80038f <vprintfmt+0xf6>
			for (precision = 0;; ++fmt) {
  80033d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800340:	eb e9                	jmp    80032b <vprintfmt+0x92>
			precision = va_arg(ap, int);
  800342:	8b 45 14             	mov    0x14(%ebp),%eax
  800345:	8d 50 04             	lea    0x4(%eax),%edx
  800348:	89 55 14             	mov    %edx,0x14(%ebp)
  80034b:	8b 00                	mov    (%eax),%eax
  80034d:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800350:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800353:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800357:	79 94                	jns    8002ed <vprintfmt+0x54>
				width = precision, precision = -1;
  800359:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80035c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80035f:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800366:	eb 85                	jmp    8002ed <vprintfmt+0x54>
  800368:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80036b:	85 d2                	test   %edx,%edx
  80036d:	b8 00 00 00 00       	mov    $0x0,%eax
  800372:	0f 49 c2             	cmovns %edx,%eax
  800375:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800378:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80037b:	e9 6d ff ff ff       	jmp    8002ed <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800380:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800383:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80038a:	e9 5e ff ff ff       	jmp    8002ed <vprintfmt+0x54>
  80038f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800392:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800395:	eb bc                	jmp    800353 <vprintfmt+0xba>
			lflag++;
  800397:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80039a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80039d:	e9 4b ff ff ff       	jmp    8002ed <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8003a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a5:	8d 50 04             	lea    0x4(%eax),%edx
  8003a8:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ab:	83 ec 08             	sub    $0x8,%esp
  8003ae:	56                   	push   %esi
  8003af:	ff 30                	push   (%eax)
  8003b1:	ff d3                	call   *%ebx
			break;
  8003b3:	83 c4 10             	add    $0x10,%esp
  8003b6:	e9 94 01 00 00       	jmp    80054f <vprintfmt+0x2b6>
			err = va_arg(ap, int);
  8003bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003be:	8d 50 04             	lea    0x4(%eax),%edx
  8003c1:	89 55 14             	mov    %edx,0x14(%ebp)
  8003c4:	8b 10                	mov    (%eax),%edx
  8003c6:	89 d0                	mov    %edx,%eax
  8003c8:	f7 d8                	neg    %eax
  8003ca:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003cd:	83 f8 08             	cmp    $0x8,%eax
  8003d0:	7f 20                	jg     8003f2 <vprintfmt+0x159>
  8003d2:	8b 14 85 00 11 80 00 	mov    0x801100(,%eax,4),%edx
  8003d9:	85 d2                	test   %edx,%edx
  8003db:	74 15                	je     8003f2 <vprintfmt+0x159>
				printfmt(putch, putdat, "%s", p);
  8003dd:	52                   	push   %edx
  8003de:	68 f2 0e 80 00       	push   $0x800ef2
  8003e3:	56                   	push   %esi
  8003e4:	53                   	push   %ebx
  8003e5:	e8 92 fe ff ff       	call   80027c <printfmt>
  8003ea:	83 c4 10             	add    $0x10,%esp
  8003ed:	e9 5d 01 00 00       	jmp    80054f <vprintfmt+0x2b6>
				printfmt(putch, putdat, "error %d", err);
  8003f2:	50                   	push   %eax
  8003f3:	68 e9 0e 80 00       	push   $0x800ee9
  8003f8:	56                   	push   %esi
  8003f9:	53                   	push   %ebx
  8003fa:	e8 7d fe ff ff       	call   80027c <printfmt>
  8003ff:	83 c4 10             	add    $0x10,%esp
  800402:	e9 48 01 00 00       	jmp    80054f <vprintfmt+0x2b6>
			if ((p = va_arg(ap, char *)) == NULL)
  800407:	8b 45 14             	mov    0x14(%ebp),%eax
  80040a:	8d 50 04             	lea    0x4(%eax),%edx
  80040d:	89 55 14             	mov    %edx,0x14(%ebp)
  800410:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800412:	85 ff                	test   %edi,%edi
  800414:	b8 e2 0e 80 00       	mov    $0x800ee2,%eax
  800419:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80041c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800420:	7e 06                	jle    800428 <vprintfmt+0x18f>
  800422:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  800426:	75 0a                	jne    800432 <vprintfmt+0x199>
  800428:	89 f8                	mov    %edi,%eax
  80042a:	03 45 e0             	add    -0x20(%ebp),%eax
  80042d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800430:	eb 59                	jmp    80048b <vprintfmt+0x1f2>
				for (width -= strnlen(p, precision); width > 0;
  800432:	83 ec 08             	sub    $0x8,%esp
  800435:	ff 75 d8             	push   -0x28(%ebp)
  800438:	57                   	push   %edi
  800439:	e8 1a 02 00 00       	call   800658 <strnlen>
  80043e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800441:	29 c1                	sub    %eax,%ecx
  800443:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800446:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800449:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  80044d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800450:	89 7d d0             	mov    %edi,-0x30(%ebp)
  800453:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0;
  800455:	eb 0f                	jmp    800466 <vprintfmt+0x1cd>
					putch(padc, putdat);
  800457:	83 ec 08             	sub    $0x8,%esp
  80045a:	56                   	push   %esi
  80045b:	ff 75 e0             	push   -0x20(%ebp)
  80045e:	ff d3                	call   *%ebx
				     width--)
  800460:	83 ef 01             	sub    $0x1,%edi
  800463:	83 c4 10             	add    $0x10,%esp
				for (width -= strnlen(p, precision); width > 0;
  800466:	85 ff                	test   %edi,%edi
  800468:	7f ed                	jg     800457 <vprintfmt+0x1be>
  80046a:	8b 7d d0             	mov    -0x30(%ebp),%edi
  80046d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800470:	85 c9                	test   %ecx,%ecx
  800472:	b8 00 00 00 00       	mov    $0x0,%eax
  800477:	0f 49 c1             	cmovns %ecx,%eax
  80047a:	29 c1                	sub    %eax,%ecx
  80047c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80047f:	eb a7                	jmp    800428 <vprintfmt+0x18f>
					putch(ch, putdat);
  800481:	83 ec 08             	sub    $0x8,%esp
  800484:	56                   	push   %esi
  800485:	52                   	push   %edx
  800486:	ff d3                	call   *%ebx
  800488:	83 c4 10             	add    $0x10,%esp
  80048b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80048e:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' &&
  800490:	83 c7 01             	add    $0x1,%edi
  800493:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800497:	0f be d0             	movsbl %al,%edx
  80049a:	85 d2                	test   %edx,%edx
  80049c:	74 42                	je     8004e0 <vprintfmt+0x247>
  80049e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004a2:	78 06                	js     8004aa <vprintfmt+0x211>
			       (precision < 0 || --precision >= 0);
  8004a4:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004a8:	78 1e                	js     8004c8 <vprintfmt+0x22f>
				if (altflag && (ch < ' ' || ch > '~'))
  8004aa:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004ae:	74 d1                	je     800481 <vprintfmt+0x1e8>
  8004b0:	0f be c0             	movsbl %al,%eax
  8004b3:	83 e8 20             	sub    $0x20,%eax
  8004b6:	83 f8 5e             	cmp    $0x5e,%eax
  8004b9:	76 c6                	jbe    800481 <vprintfmt+0x1e8>
					putch('?', putdat);
  8004bb:	83 ec 08             	sub    $0x8,%esp
  8004be:	56                   	push   %esi
  8004bf:	6a 3f                	push   $0x3f
  8004c1:	ff d3                	call   *%ebx
  8004c3:	83 c4 10             	add    $0x10,%esp
  8004c6:	eb c3                	jmp    80048b <vprintfmt+0x1f2>
  8004c8:	89 cf                	mov    %ecx,%edi
  8004ca:	eb 0e                	jmp    8004da <vprintfmt+0x241>
				putch(' ', putdat);
  8004cc:	83 ec 08             	sub    $0x8,%esp
  8004cf:	56                   	push   %esi
  8004d0:	6a 20                	push   $0x20
  8004d2:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  8004d4:	83 ef 01             	sub    $0x1,%edi
  8004d7:	83 c4 10             	add    $0x10,%esp
  8004da:	85 ff                	test   %edi,%edi
  8004dc:	7f ee                	jg     8004cc <vprintfmt+0x233>
  8004de:	eb 6f                	jmp    80054f <vprintfmt+0x2b6>
  8004e0:	89 cf                	mov    %ecx,%edi
  8004e2:	eb f6                	jmp    8004da <vprintfmt+0x241>
			num = getint(&ap, lflag);
  8004e4:	89 ca                	mov    %ecx,%edx
  8004e6:	8d 45 14             	lea    0x14(%ebp),%eax
  8004e9:	e8 45 fd ff ff       	call   800233 <getint>
  8004ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004f1:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  8004f4:	85 d2                	test   %edx,%edx
  8004f6:	78 0b                	js     800503 <vprintfmt+0x26a>
			num = getint(&ap, lflag);
  8004f8:	89 d1                	mov    %edx,%ecx
  8004fa:	89 c2                	mov    %eax,%edx
			base = 10;
  8004fc:	bf 0a 00 00 00       	mov    $0xa,%edi
  800501:	eb 32                	jmp    800535 <vprintfmt+0x29c>
				putch('-', putdat);
  800503:	83 ec 08             	sub    $0x8,%esp
  800506:	56                   	push   %esi
  800507:	6a 2d                	push   $0x2d
  800509:	ff d3                	call   *%ebx
				num = -(long long) num;
  80050b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80050e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800511:	f7 da                	neg    %edx
  800513:	83 d1 00             	adc    $0x0,%ecx
  800516:	f7 d9                	neg    %ecx
  800518:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80051b:	bf 0a 00 00 00       	mov    $0xa,%edi
  800520:	eb 13                	jmp    800535 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  800522:	89 ca                	mov    %ecx,%edx
  800524:	8d 45 14             	lea    0x14(%ebp),%eax
  800527:	e8 d3 fc ff ff       	call   8001ff <getuint>
  80052c:	89 d1                	mov    %edx,%ecx
  80052e:	89 c2                	mov    %eax,%edx
			base = 10;
  800530:	bf 0a 00 00 00       	mov    $0xa,%edi
			printnum(putch, putdat, num, base, width, padc);
  800535:	83 ec 0c             	sub    $0xc,%esp
  800538:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  80053c:	50                   	push   %eax
  80053d:	ff 75 e0             	push   -0x20(%ebp)
  800540:	57                   	push   %edi
  800541:	51                   	push   %ecx
  800542:	52                   	push   %edx
  800543:	89 f2                	mov    %esi,%edx
  800545:	89 d8                	mov    %ebx,%eax
  800547:	e8 0a fc ff ff       	call   800156 <printnum>
			break;
  80054c:	83 c4 20             	add    $0x20,%esp
{
  80054f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800552:	e9 60 fd ff ff       	jmp    8002b7 <vprintfmt+0x1e>
			num = getuint(&ap, lflag);
  800557:	89 ca                	mov    %ecx,%edx
  800559:	8d 45 14             	lea    0x14(%ebp),%eax
  80055c:	e8 9e fc ff ff       	call   8001ff <getuint>
  800561:	89 d1                	mov    %edx,%ecx
  800563:	89 c2                	mov    %eax,%edx
			base = 8;
  800565:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  80056a:	eb c9                	jmp    800535 <vprintfmt+0x29c>
			putch('0', putdat);
  80056c:	83 ec 08             	sub    $0x8,%esp
  80056f:	56                   	push   %esi
  800570:	6a 30                	push   $0x30
  800572:	ff d3                	call   *%ebx
			putch('x', putdat);
  800574:	83 c4 08             	add    $0x8,%esp
  800577:	56                   	push   %esi
  800578:	6a 78                	push   $0x78
  80057a:	ff d3                	call   *%ebx
			num = (unsigned long long) (uintptr_t) va_arg(ap, void *);
  80057c:	8b 45 14             	mov    0x14(%ebp),%eax
  80057f:	8d 50 04             	lea    0x4(%eax),%edx
  800582:	89 55 14             	mov    %edx,0x14(%ebp)
  800585:	8b 10                	mov    (%eax),%edx
  800587:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80058c:	83 c4 10             	add    $0x10,%esp
			base = 16;
  80058f:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  800594:	eb 9f                	jmp    800535 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  800596:	89 ca                	mov    %ecx,%edx
  800598:	8d 45 14             	lea    0x14(%ebp),%eax
  80059b:	e8 5f fc ff ff       	call   8001ff <getuint>
  8005a0:	89 d1                	mov    %edx,%ecx
  8005a2:	89 c2                	mov    %eax,%edx
			base = 16;
  8005a4:	bf 10 00 00 00       	mov    $0x10,%edi
  8005a9:	eb 8a                	jmp    800535 <vprintfmt+0x29c>
			putch(ch, putdat);
  8005ab:	83 ec 08             	sub    $0x8,%esp
  8005ae:	56                   	push   %esi
  8005af:	6a 25                	push   $0x25
  8005b1:	ff d3                	call   *%ebx
			break;
  8005b3:	83 c4 10             	add    $0x10,%esp
  8005b6:	eb 97                	jmp    80054f <vprintfmt+0x2b6>
			putch('%', putdat);
  8005b8:	83 ec 08             	sub    $0x8,%esp
  8005bb:	56                   	push   %esi
  8005bc:	6a 25                	push   $0x25
  8005be:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  8005c0:	83 c4 10             	add    $0x10,%esp
  8005c3:	89 f8                	mov    %edi,%eax
  8005c5:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8005c9:	74 05                	je     8005d0 <vprintfmt+0x337>
  8005cb:	83 e8 01             	sub    $0x1,%eax
  8005ce:	eb f5                	jmp    8005c5 <vprintfmt+0x32c>
  8005d0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005d3:	e9 77 ff ff ff       	jmp    80054f <vprintfmt+0x2b6>

008005d8 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8005d8:	55                   	push   %ebp
  8005d9:	89 e5                	mov    %esp,%ebp
  8005db:	83 ec 18             	sub    $0x18,%esp
  8005de:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = { buf, buf + n - 1, 0 };
  8005e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8005e7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8005eb:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8005ee:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8005f5:	85 c0                	test   %eax,%eax
  8005f7:	74 26                	je     80061f <vsnprintf+0x47>
  8005f9:	85 d2                	test   %edx,%edx
  8005fb:	7e 22                	jle    80061f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *) sprintputch, &b, fmt, ap);
  8005fd:	ff 75 14             	push   0x14(%ebp)
  800600:	ff 75 10             	push   0x10(%ebp)
  800603:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800606:	50                   	push   %eax
  800607:	68 5f 02 80 00       	push   $0x80025f
  80060c:	e8 88 fc ff ff       	call   800299 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800611:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800614:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800617:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80061a:	83 c4 10             	add    $0x10,%esp
}
  80061d:	c9                   	leave  
  80061e:	c3                   	ret    
		return -E_INVAL;
  80061f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800624:	eb f7                	jmp    80061d <vsnprintf+0x45>

00800626 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800626:	55                   	push   %ebp
  800627:	89 e5                	mov    %esp,%ebp
  800629:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80062c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80062f:	50                   	push   %eax
  800630:	ff 75 10             	push   0x10(%ebp)
  800633:	ff 75 0c             	push   0xc(%ebp)
  800636:	ff 75 08             	push   0x8(%ebp)
  800639:	e8 9a ff ff ff       	call   8005d8 <vsnprintf>
	va_end(ap);

	return rc;
}
  80063e:	c9                   	leave  
  80063f:	c3                   	ret    

00800640 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800640:	55                   	push   %ebp
  800641:	89 e5                	mov    %esp,%ebp
  800643:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800646:	b8 00 00 00 00       	mov    $0x0,%eax
  80064b:	eb 03                	jmp    800650 <strlen+0x10>
		n++;
  80064d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800650:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800654:	75 f7                	jne    80064d <strlen+0xd>
	return n;
}
  800656:	5d                   	pop    %ebp
  800657:	c3                   	ret    

00800658 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800658:	55                   	push   %ebp
  800659:	89 e5                	mov    %esp,%ebp
  80065b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80065e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800661:	b8 00 00 00 00       	mov    $0x0,%eax
  800666:	eb 03                	jmp    80066b <strnlen+0x13>
		n++;
  800668:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80066b:	39 d0                	cmp    %edx,%eax
  80066d:	74 08                	je     800677 <strnlen+0x1f>
  80066f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800673:	75 f3                	jne    800668 <strnlen+0x10>
  800675:	89 c2                	mov    %eax,%edx
	return n;
}
  800677:	89 d0                	mov    %edx,%eax
  800679:	5d                   	pop    %ebp
  80067a:	c3                   	ret    

0080067b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80067b:	55                   	push   %ebp
  80067c:	89 e5                	mov    %esp,%ebp
  80067e:	53                   	push   %ebx
  80067f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800682:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800685:	b8 00 00 00 00       	mov    $0x0,%eax
  80068a:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80068e:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800691:	83 c0 01             	add    $0x1,%eax
  800694:	84 d2                	test   %dl,%dl
  800696:	75 f2                	jne    80068a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800698:	89 c8                	mov    %ecx,%eax
  80069a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80069d:	c9                   	leave  
  80069e:	c3                   	ret    

0080069f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80069f:	55                   	push   %ebp
  8006a0:	89 e5                	mov    %esp,%ebp
  8006a2:	53                   	push   %ebx
  8006a3:	83 ec 10             	sub    $0x10,%esp
  8006a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8006a9:	53                   	push   %ebx
  8006aa:	e8 91 ff ff ff       	call   800640 <strlen>
  8006af:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8006b2:	ff 75 0c             	push   0xc(%ebp)
  8006b5:	01 d8                	add    %ebx,%eax
  8006b7:	50                   	push   %eax
  8006b8:	e8 be ff ff ff       	call   80067b <strcpy>
	return dst;
}
  8006bd:	89 d8                	mov    %ebx,%eax
  8006bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006c2:	c9                   	leave  
  8006c3:	c3                   	ret    

008006c4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size)
{
  8006c4:	55                   	push   %ebp
  8006c5:	89 e5                	mov    %esp,%ebp
  8006c7:	56                   	push   %esi
  8006c8:	53                   	push   %ebx
  8006c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8006cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006cf:	89 f3                	mov    %esi,%ebx
  8006d1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8006d4:	89 f0                	mov    %esi,%eax
  8006d6:	eb 0f                	jmp    8006e7 <strncpy+0x23>
		*dst++ = *src;
  8006d8:	83 c0 01             	add    $0x1,%eax
  8006db:	0f b6 0a             	movzbl (%edx),%ecx
  8006de:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8006e1:	80 f9 01             	cmp    $0x1,%cl
  8006e4:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  8006e7:	39 d8                	cmp    %ebx,%eax
  8006e9:	75 ed                	jne    8006d8 <strncpy+0x14>
	}
	return ret;
}
  8006eb:	89 f0                	mov    %esi,%eax
  8006ed:	5b                   	pop    %ebx
  8006ee:	5e                   	pop    %esi
  8006ef:	5d                   	pop    %ebp
  8006f0:	c3                   	ret    

008006f1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8006f1:	55                   	push   %ebp
  8006f2:	89 e5                	mov    %esp,%ebp
  8006f4:	56                   	push   %esi
  8006f5:	53                   	push   %ebx
  8006f6:	8b 75 08             	mov    0x8(%ebp),%esi
  8006f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006fc:	8b 55 10             	mov    0x10(%ebp),%edx
  8006ff:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800701:	85 d2                	test   %edx,%edx
  800703:	74 21                	je     800726 <strlcpy+0x35>
  800705:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800709:	89 f2                	mov    %esi,%edx
  80070b:	eb 09                	jmp    800716 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80070d:	83 c1 01             	add    $0x1,%ecx
  800710:	83 c2 01             	add    $0x1,%edx
  800713:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800716:	39 c2                	cmp    %eax,%edx
  800718:	74 09                	je     800723 <strlcpy+0x32>
  80071a:	0f b6 19             	movzbl (%ecx),%ebx
  80071d:	84 db                	test   %bl,%bl
  80071f:	75 ec                	jne    80070d <strlcpy+0x1c>
  800721:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800723:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800726:	29 f0                	sub    %esi,%eax
}
  800728:	5b                   	pop    %ebx
  800729:	5e                   	pop    %esi
  80072a:	5d                   	pop    %ebp
  80072b:	c3                   	ret    

0080072c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80072c:	55                   	push   %ebp
  80072d:	89 e5                	mov    %esp,%ebp
  80072f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800732:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800735:	eb 06                	jmp    80073d <strcmp+0x11>
		p++, q++;
  800737:	83 c1 01             	add    $0x1,%ecx
  80073a:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80073d:	0f b6 01             	movzbl (%ecx),%eax
  800740:	84 c0                	test   %al,%al
  800742:	74 04                	je     800748 <strcmp+0x1c>
  800744:	3a 02                	cmp    (%edx),%al
  800746:	74 ef                	je     800737 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800748:	0f b6 c0             	movzbl %al,%eax
  80074b:	0f b6 12             	movzbl (%edx),%edx
  80074e:	29 d0                	sub    %edx,%eax
}
  800750:	5d                   	pop    %ebp
  800751:	c3                   	ret    

00800752 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800752:	55                   	push   %ebp
  800753:	89 e5                	mov    %esp,%ebp
  800755:	53                   	push   %ebx
  800756:	8b 45 08             	mov    0x8(%ebp),%eax
  800759:	8b 55 0c             	mov    0xc(%ebp),%edx
  80075c:	89 c3                	mov    %eax,%ebx
  80075e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800761:	eb 06                	jmp    800769 <strncmp+0x17>
		n--, p++, q++;
  800763:	83 c0 01             	add    $0x1,%eax
  800766:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800769:	39 d8                	cmp    %ebx,%eax
  80076b:	74 18                	je     800785 <strncmp+0x33>
  80076d:	0f b6 08             	movzbl (%eax),%ecx
  800770:	84 c9                	test   %cl,%cl
  800772:	74 04                	je     800778 <strncmp+0x26>
  800774:	3a 0a                	cmp    (%edx),%cl
  800776:	74 eb                	je     800763 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800778:	0f b6 00             	movzbl (%eax),%eax
  80077b:	0f b6 12             	movzbl (%edx),%edx
  80077e:	29 d0                	sub    %edx,%eax
}
  800780:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800783:	c9                   	leave  
  800784:	c3                   	ret    
		return 0;
  800785:	b8 00 00 00 00       	mov    $0x0,%eax
  80078a:	eb f4                	jmp    800780 <strncmp+0x2e>

0080078c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80078c:	55                   	push   %ebp
  80078d:	89 e5                	mov    %esp,%ebp
  80078f:	8b 45 08             	mov    0x8(%ebp),%eax
  800792:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800796:	eb 03                	jmp    80079b <strchr+0xf>
  800798:	83 c0 01             	add    $0x1,%eax
  80079b:	0f b6 10             	movzbl (%eax),%edx
  80079e:	84 d2                	test   %dl,%dl
  8007a0:	74 06                	je     8007a8 <strchr+0x1c>
		if (*s == c)
  8007a2:	38 ca                	cmp    %cl,%dl
  8007a4:	75 f2                	jne    800798 <strchr+0xc>
  8007a6:	eb 05                	jmp    8007ad <strchr+0x21>
			return (char *) s;
	return 0;
  8007a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007ad:	5d                   	pop    %ebp
  8007ae:	c3                   	ret    

008007af <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8007af:	55                   	push   %ebp
  8007b0:	89 e5                	mov    %esp,%ebp
  8007b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007b9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8007bc:	38 ca                	cmp    %cl,%dl
  8007be:	74 09                	je     8007c9 <strfind+0x1a>
  8007c0:	84 d2                	test   %dl,%dl
  8007c2:	74 05                	je     8007c9 <strfind+0x1a>
	for (; *s; s++)
  8007c4:	83 c0 01             	add    $0x1,%eax
  8007c7:	eb f0                	jmp    8007b9 <strfind+0xa>
			break;
	return (char *) s;
}
  8007c9:	5d                   	pop    %ebp
  8007ca:	c3                   	ret    

008007cb <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8007cb:	55                   	push   %ebp
  8007cc:	89 e5                	mov    %esp,%ebp
  8007ce:	57                   	push   %edi
  8007cf:	56                   	push   %esi
  8007d0:	53                   	push   %ebx
  8007d1:	8b 55 08             	mov    0x8(%ebp),%edx
  8007d4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  8007d7:	85 c9                	test   %ecx,%ecx
  8007d9:	74 33                	je     80080e <memset+0x43>
		return v;
	if ((int) v % 4 == 0 && n % 4 == 0) {
  8007db:	89 d0                	mov    %edx,%eax
  8007dd:	09 c8                	or     %ecx,%eax
  8007df:	a8 03                	test   $0x3,%al
  8007e1:	75 23                	jne    800806 <memset+0x3b>
		c &= 0xFF;
  8007e3:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  8007e7:	89 d8                	mov    %ebx,%eax
  8007e9:	c1 e0 08             	shl    $0x8,%eax
  8007ec:	89 df                	mov    %ebx,%edi
  8007ee:	c1 e7 18             	shl    $0x18,%edi
  8007f1:	89 de                	mov    %ebx,%esi
  8007f3:	c1 e6 10             	shl    $0x10,%esi
  8007f6:	09 f7                	or     %esi,%edi
  8007f8:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
		             : "=D"(p), "=c"(n)
		             : "D"(p), "a"(c), "c"(n / 4)
  8007fa:	c1 e9 02             	shr    $0x2,%ecx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  8007fd:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  8007ff:	89 d7                	mov    %edx,%edi
  800801:	fc                   	cld    
  800802:	f3 ab                	rep stos %eax,%es:(%edi)
  800804:	eb 08                	jmp    80080e <memset+0x43>
		             : "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800806:	89 d7                	mov    %edx,%edi
  800808:	8b 45 0c             	mov    0xc(%ebp),%eax
  80080b:	fc                   	cld    
  80080c:	f3 aa                	rep stos %al,%es:(%edi)
		             : "=D"(p), "=c"(n)
		             : "0"(p), "a"(c), "1"(n)
		             : "cc", "memory");
	return v;
}
  80080e:	89 d0                	mov    %edx,%eax
  800810:	5b                   	pop    %ebx
  800811:	5e                   	pop    %esi
  800812:	5f                   	pop    %edi
  800813:	5d                   	pop    %ebp
  800814:	c3                   	ret    

00800815 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800815:	55                   	push   %ebp
  800816:	89 e5                	mov    %esp,%ebp
  800818:	57                   	push   %edi
  800819:	56                   	push   %esi
  80081a:	8b 45 08             	mov    0x8(%ebp),%eax
  80081d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800820:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800823:	39 c6                	cmp    %eax,%esi
  800825:	73 32                	jae    800859 <memmove+0x44>
  800827:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80082a:	39 c2                	cmp    %eax,%edx
  80082c:	76 2b                	jbe    800859 <memmove+0x44>
		s += n;
		d += n;
  80082e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  800831:	89 d6                	mov    %edx,%esi
  800833:	09 fe                	or     %edi,%esi
  800835:	09 ce                	or     %ecx,%esi
  800837:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80083d:	75 0e                	jne    80084d <memmove+0x38>
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  80083f:	83 ef 04             	sub    $0x4,%edi
			             "S"(s - 4),
  800842:	8d 72 fc             	lea    -0x4(%edx),%esi
			             "c"(n / 4)
  800845:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  800848:	fd                   	std    
  800849:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80084b:	eb 09                	jmp    800856 <memmove+0x41>
			             : "cc", "memory");
		else
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  80084d:	83 ef 01             	sub    $0x1,%edi
			             "S"(s - 1),
  800850:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  800853:	fd                   	std    
  800854:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             "c"(n)
			             : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800856:	fc                   	cld    
  800857:	eb 1a                	jmp    800873 <memmove+0x5e>
	} else {
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  800859:	89 f2                	mov    %esi,%edx
  80085b:	09 c2                	or     %eax,%edx
  80085d:	09 ca                	or     %ecx,%edx
  80085f:	f6 c2 03             	test   $0x3,%dl
  800862:	75 0a                	jne    80086e <memmove+0x59>
			asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800864:	c1 e9 02             	shr    $0x2,%ecx
  800867:	89 c7                	mov    %eax,%edi
  800869:	fc                   	cld    
  80086a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80086c:	eb 05                	jmp    800873 <memmove+0x5e>
			             : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  80086e:	89 c7                	mov    %eax,%edi
  800870:	fc                   	cld    
  800871:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             : "cc", "memory");
	}
	return dst;
}
  800873:	5e                   	pop    %esi
  800874:	5f                   	pop    %edi
  800875:	5d                   	pop    %ebp
  800876:	c3                   	ret    

00800877 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80087d:	ff 75 10             	push   0x10(%ebp)
  800880:	ff 75 0c             	push   0xc(%ebp)
  800883:	ff 75 08             	push   0x8(%ebp)
  800886:	e8 8a ff ff ff       	call   800815 <memmove>
}
  80088b:	c9                   	leave  
  80088c:	c3                   	ret    

0080088d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80088d:	55                   	push   %ebp
  80088e:	89 e5                	mov    %esp,%ebp
  800890:	56                   	push   %esi
  800891:	53                   	push   %ebx
  800892:	8b 45 08             	mov    0x8(%ebp),%eax
  800895:	8b 55 0c             	mov    0xc(%ebp),%edx
  800898:	89 c6                	mov    %eax,%esi
  80089a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80089d:	eb 06                	jmp    8008a5 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  80089f:	83 c0 01             	add    $0x1,%eax
  8008a2:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  8008a5:	39 f0                	cmp    %esi,%eax
  8008a7:	74 14                	je     8008bd <memcmp+0x30>
		if (*s1 != *s2)
  8008a9:	0f b6 08             	movzbl (%eax),%ecx
  8008ac:	0f b6 1a             	movzbl (%edx),%ebx
  8008af:	38 d9                	cmp    %bl,%cl
  8008b1:	74 ec                	je     80089f <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  8008b3:	0f b6 c1             	movzbl %cl,%eax
  8008b6:	0f b6 db             	movzbl %bl,%ebx
  8008b9:	29 d8                	sub    %ebx,%eax
  8008bb:	eb 05                	jmp    8008c2 <memcmp+0x35>
	}

	return 0;
  8008bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008c2:	5b                   	pop    %ebx
  8008c3:	5e                   	pop    %esi
  8008c4:	5d                   	pop    %ebp
  8008c5:	c3                   	ret    

008008c6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8008c6:	55                   	push   %ebp
  8008c7:	89 e5                	mov    %esp,%ebp
  8008c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8008cf:	89 c2                	mov    %eax,%edx
  8008d1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8008d4:	eb 03                	jmp    8008d9 <memfind+0x13>
  8008d6:	83 c0 01             	add    $0x1,%eax
  8008d9:	39 d0                	cmp    %edx,%eax
  8008db:	73 04                	jae    8008e1 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8008dd:	38 08                	cmp    %cl,(%eax)
  8008df:	75 f5                	jne    8008d6 <memfind+0x10>
			break;
	return (void *) s;
}
  8008e1:	5d                   	pop    %ebp
  8008e2:	c3                   	ret    

008008e3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8008e3:	55                   	push   %ebp
  8008e4:	89 e5                	mov    %esp,%ebp
  8008e6:	57                   	push   %edi
  8008e7:	56                   	push   %esi
  8008e8:	53                   	push   %ebx
  8008e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8008ec:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8008ef:	eb 03                	jmp    8008f4 <strtol+0x11>
		s++;
  8008f1:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  8008f4:	0f b6 02             	movzbl (%edx),%eax
  8008f7:	3c 20                	cmp    $0x20,%al
  8008f9:	74 f6                	je     8008f1 <strtol+0xe>
  8008fb:	3c 09                	cmp    $0x9,%al
  8008fd:	74 f2                	je     8008f1 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8008ff:	3c 2b                	cmp    $0x2b,%al
  800901:	74 2a                	je     80092d <strtol+0x4a>
	int neg = 0;
  800903:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800908:	3c 2d                	cmp    $0x2d,%al
  80090a:	74 2b                	je     800937 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80090c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800912:	75 0f                	jne    800923 <strtol+0x40>
  800914:	80 3a 30             	cmpb   $0x30,(%edx)
  800917:	74 28                	je     800941 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800919:	85 db                	test   %ebx,%ebx
  80091b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800920:	0f 44 d8             	cmove  %eax,%ebx
  800923:	b9 00 00 00 00       	mov    $0x0,%ecx
  800928:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80092b:	eb 46                	jmp    800973 <strtol+0x90>
		s++;
  80092d:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800930:	bf 00 00 00 00       	mov    $0x0,%edi
  800935:	eb d5                	jmp    80090c <strtol+0x29>
		s++, neg = 1;
  800937:	83 c2 01             	add    $0x1,%edx
  80093a:	bf 01 00 00 00       	mov    $0x1,%edi
  80093f:	eb cb                	jmp    80090c <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800941:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800945:	74 0e                	je     800955 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800947:	85 db                	test   %ebx,%ebx
  800949:	75 d8                	jne    800923 <strtol+0x40>
		s++, base = 8;
  80094b:	83 c2 01             	add    $0x1,%edx
  80094e:	bb 08 00 00 00       	mov    $0x8,%ebx
  800953:	eb ce                	jmp    800923 <strtol+0x40>
		s += 2, base = 16;
  800955:	83 c2 02             	add    $0x2,%edx
  800958:	bb 10 00 00 00       	mov    $0x10,%ebx
  80095d:	eb c4                	jmp    800923 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  80095f:	0f be c0             	movsbl %al,%eax
  800962:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800965:	3b 45 10             	cmp    0x10(%ebp),%eax
  800968:	7d 3a                	jge    8009a4 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  80096a:	83 c2 01             	add    $0x1,%edx
  80096d:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800971:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800973:	0f b6 02             	movzbl (%edx),%eax
  800976:	8d 70 d0             	lea    -0x30(%eax),%esi
  800979:	89 f3                	mov    %esi,%ebx
  80097b:	80 fb 09             	cmp    $0x9,%bl
  80097e:	76 df                	jbe    80095f <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800980:	8d 70 9f             	lea    -0x61(%eax),%esi
  800983:	89 f3                	mov    %esi,%ebx
  800985:	80 fb 19             	cmp    $0x19,%bl
  800988:	77 08                	ja     800992 <strtol+0xaf>
			dig = *s - 'a' + 10;
  80098a:	0f be c0             	movsbl %al,%eax
  80098d:	83 e8 57             	sub    $0x57,%eax
  800990:	eb d3                	jmp    800965 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800992:	8d 70 bf             	lea    -0x41(%eax),%esi
  800995:	89 f3                	mov    %esi,%ebx
  800997:	80 fb 19             	cmp    $0x19,%bl
  80099a:	77 08                	ja     8009a4 <strtol+0xc1>
			dig = *s - 'A' + 10;
  80099c:	0f be c0             	movsbl %al,%eax
  80099f:	83 e8 37             	sub    $0x37,%eax
  8009a2:	eb c1                	jmp    800965 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  8009a4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8009a8:	74 05                	je     8009af <strtol+0xcc>
		*endptr = (char *) s;
  8009aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ad:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  8009af:	89 c8                	mov    %ecx,%eax
  8009b1:	f7 d8                	neg    %eax
  8009b3:	85 ff                	test   %edi,%edi
  8009b5:	0f 45 c8             	cmovne %eax,%ecx
}
  8009b8:	89 c8                	mov    %ecx,%eax
  8009ba:	5b                   	pop    %ebx
  8009bb:	5e                   	pop    %esi
  8009bc:	5f                   	pop    %edi
  8009bd:	5d                   	pop    %ebp
  8009be:	c3                   	ret    

008009bf <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8009bf:	55                   	push   %ebp
  8009c0:	89 e5                	mov    %esp,%ebp
  8009c2:	57                   	push   %edi
  8009c3:	56                   	push   %esi
  8009c4:	53                   	push   %ebx
  8009c5:	83 ec 1c             	sub    $0x1c,%esp
  8009c8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009cb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8009ce:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile(
  8009d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009d6:	8b 7d 10             	mov    0x10(%ebp),%edi
  8009d9:	8b 75 14             	mov    0x14(%ebp),%esi
  8009dc:	cd 30                	int    $0x30
	        "int %1\n"
	        : "=a"(ret)
	        : "i"(T_SYSCALL), "a"(num), "d"(a1), "c"(a2), "b"(a3), "D"(a4), "S"(a5)
	        : "cc", "memory");

	if (check && ret > 0)
  8009de:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8009e2:	74 04                	je     8009e8 <syscall+0x29>
  8009e4:	85 c0                	test   %eax,%eax
  8009e6:	7f 08                	jg     8009f0 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  8009e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009eb:	5b                   	pop    %ebx
  8009ec:	5e                   	pop    %esi
  8009ed:	5f                   	pop    %edi
  8009ee:	5d                   	pop    %ebp
  8009ef:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8009f0:	83 ec 0c             	sub    $0xc,%esp
  8009f3:	50                   	push   %eax
  8009f4:	ff 75 e0             	push   -0x20(%ebp)
  8009f7:	68 24 11 80 00       	push   $0x801124
  8009fc:	6a 1e                	push   $0x1e
  8009fe:	68 41 11 80 00       	push   $0x801141
  800a03:	e8 f7 01 00 00       	call   800bff <_panic>

00800a08 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800a08:	55                   	push   %ebp
  800a09:	89 e5                	mov    %esp,%ebp
  800a0b:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t) s, len, 0, 0, 0);
  800a0e:	6a 00                	push   $0x0
  800a10:	6a 00                	push   $0x0
  800a12:	6a 00                	push   $0x0
  800a14:	ff 75 0c             	push   0xc(%ebp)
  800a17:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a1a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a1f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a24:	e8 96 ff ff ff       	call   8009bf <syscall>
}
  800a29:	83 c4 10             	add    $0x10,%esp
  800a2c:	c9                   	leave  
  800a2d:	c3                   	ret    

00800a2e <sys_cgetc>:

int
sys_cgetc(void)
{
  800a2e:	55                   	push   %ebp
  800a2f:	89 e5                	mov    %esp,%ebp
  800a31:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800a34:	6a 00                	push   $0x0
  800a36:	6a 00                	push   $0x0
  800a38:	6a 00                	push   $0x0
  800a3a:	6a 00                	push   $0x0
  800a3c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a41:	ba 00 00 00 00       	mov    $0x0,%edx
  800a46:	b8 01 00 00 00       	mov    $0x1,%eax
  800a4b:	e8 6f ff ff ff       	call   8009bf <syscall>
}
  800a50:	c9                   	leave  
  800a51:	c3                   	ret    

00800a52 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a52:	55                   	push   %ebp
  800a53:	89 e5                	mov    %esp,%ebp
  800a55:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800a58:	6a 00                	push   $0x0
  800a5a:	6a 00                	push   $0x0
  800a5c:	6a 00                	push   $0x0
  800a5e:	6a 00                	push   $0x0
  800a60:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a63:	ba 01 00 00 00       	mov    $0x1,%edx
  800a68:	b8 03 00 00 00       	mov    $0x3,%eax
  800a6d:	e8 4d ff ff ff       	call   8009bf <syscall>
}
  800a72:	c9                   	leave  
  800a73:	c3                   	ret    

00800a74 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800a74:	55                   	push   %ebp
  800a75:	89 e5                	mov    %esp,%ebp
  800a77:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800a7a:	6a 00                	push   $0x0
  800a7c:	6a 00                	push   $0x0
  800a7e:	6a 00                	push   $0x0
  800a80:	6a 00                	push   $0x0
  800a82:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a87:	ba 00 00 00 00       	mov    $0x0,%edx
  800a8c:	b8 02 00 00 00       	mov    $0x2,%eax
  800a91:	e8 29 ff ff ff       	call   8009bf <syscall>
}
  800a96:	c9                   	leave  
  800a97:	c3                   	ret    

00800a98 <sys_yield>:

void
sys_yield(void)
{
  800a98:	55                   	push   %ebp
  800a99:	89 e5                	mov    %esp,%ebp
  800a9b:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800a9e:	6a 00                	push   $0x0
  800aa0:	6a 00                	push   $0x0
  800aa2:	6a 00                	push   $0x0
  800aa4:	6a 00                	push   $0x0
  800aa6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aab:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab0:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ab5:	e8 05 ff ff ff       	call   8009bf <syscall>
}
  800aba:	83 c4 10             	add    $0x10,%esp
  800abd:	c9                   	leave  
  800abe:	c3                   	ret    

00800abf <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800abf:	55                   	push   %ebp
  800ac0:	89 e5                	mov    %esp,%ebp
  800ac2:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800ac5:	6a 00                	push   $0x0
  800ac7:	6a 00                	push   $0x0
  800ac9:	ff 75 10             	push   0x10(%ebp)
  800acc:	ff 75 0c             	push   0xc(%ebp)
  800acf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ad2:	ba 01 00 00 00       	mov    $0x1,%edx
  800ad7:	b8 04 00 00 00       	mov    $0x4,%eax
  800adc:	e8 de fe ff ff       	call   8009bf <syscall>
}
  800ae1:	c9                   	leave  
  800ae2:	c3                   	ret    

00800ae3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ae3:	55                   	push   %ebp
  800ae4:	89 e5                	mov    %esp,%ebp
  800ae6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map,
  800ae9:	ff 75 18             	push   0x18(%ebp)
  800aec:	ff 75 14             	push   0x14(%ebp)
  800aef:	ff 75 10             	push   0x10(%ebp)
  800af2:	ff 75 0c             	push   0xc(%ebp)
  800af5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800af8:	ba 01 00 00 00       	mov    $0x1,%edx
  800afd:	b8 05 00 00 00       	mov    $0x5,%eax
  800b02:	e8 b8 fe ff ff       	call   8009bf <syscall>
	               srcenv,
	               (uint32_t) srcva,
	               dstenv,
	               (uint32_t) dstva,
	               perm);
}
  800b07:	c9                   	leave  
  800b08:	c3                   	ret    

00800b09 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b09:	55                   	push   %ebp
  800b0a:	89 e5                	mov    %esp,%ebp
  800b0c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800b0f:	6a 00                	push   $0x0
  800b11:	6a 00                	push   $0x0
  800b13:	6a 00                	push   $0x0
  800b15:	ff 75 0c             	push   0xc(%ebp)
  800b18:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b1b:	ba 01 00 00 00       	mov    $0x1,%edx
  800b20:	b8 06 00 00 00       	mov    $0x6,%eax
  800b25:	e8 95 fe ff ff       	call   8009bf <syscall>
}
  800b2a:	c9                   	leave  
  800b2b:	c3                   	ret    

00800b2c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800b2c:	55                   	push   %ebp
  800b2d:	89 e5                	mov    %esp,%ebp
  800b2f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800b32:	6a 00                	push   $0x0
  800b34:	6a 00                	push   $0x0
  800b36:	6a 00                	push   $0x0
  800b38:	ff 75 0c             	push   0xc(%ebp)
  800b3b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b3e:	ba 01 00 00 00       	mov    $0x1,%edx
  800b43:	b8 08 00 00 00       	mov    $0x8,%eax
  800b48:	e8 72 fe ff ff       	call   8009bf <syscall>
}
  800b4d:	c9                   	leave  
  800b4e:	c3                   	ret    

00800b4f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800b4f:	55                   	push   %ebp
  800b50:	89 e5                	mov    %esp,%ebp
  800b52:	83 ec 08             	sub    $0x8,%esp
	return syscall(
  800b55:	6a 00                	push   $0x0
  800b57:	6a 00                	push   $0x0
  800b59:	6a 00                	push   $0x0
  800b5b:	ff 75 0c             	push   0xc(%ebp)
  800b5e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b61:	ba 01 00 00 00       	mov    $0x1,%edx
  800b66:	b8 09 00 00 00       	mov    $0x9,%eax
  800b6b:	e8 4f fe ff ff       	call   8009bf <syscall>
	        SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800b70:	c9                   	leave  
  800b71:	c3                   	ret    

00800b72 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800b72:	55                   	push   %ebp
  800b73:	89 e5                	mov    %esp,%ebp
  800b75:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800b78:	6a 00                	push   $0x0
  800b7a:	ff 75 14             	push   0x14(%ebp)
  800b7d:	ff 75 10             	push   0x10(%ebp)
  800b80:	ff 75 0c             	push   0xc(%ebp)
  800b83:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b86:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b90:	e8 2a fe ff ff       	call   8009bf <syscall>
}
  800b95:	c9                   	leave  
  800b96:	c3                   	ret    

00800b97 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800b97:	55                   	push   %ebp
  800b98:	89 e5                	mov    %esp,%ebp
  800b9a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t) dstva, 0, 0, 0, 0);
  800b9d:	6a 00                	push   $0x0
  800b9f:	6a 00                	push   $0x0
  800ba1:	6a 00                	push   $0x0
  800ba3:	6a 00                	push   $0x0
  800ba5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ba8:	ba 01 00 00 00       	mov    $0x1,%edx
  800bad:	b8 0c 00 00 00       	mov    $0xc,%eax
  800bb2:	e8 08 fe ff ff       	call   8009bf <syscall>
}
  800bb7:	c9                   	leave  
  800bb8:	c3                   	ret    

00800bb9 <sys_get_priority>:

// Get priority of the current process
int
sys_get_priority(void)
{
  800bb9:	55                   	push   %ebp
  800bba:	89 e5                	mov    %esp,%ebp
  800bbc:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_get_priority, 0, 0, 0, 0, 0, 0);
  800bbf:	6a 00                	push   $0x0
  800bc1:	6a 00                	push   $0x0
  800bc3:	6a 00                	push   $0x0
  800bc5:	6a 00                	push   $0x0
  800bc7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bcc:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd1:	b8 0d 00 00 00       	mov    $0xd,%eax
  800bd6:	e8 e4 fd ff ff       	call   8009bf <syscall>
}
  800bdb:	c9                   	leave  
  800bdc:	c3                   	ret    

00800bdd <sys_set_priority>:

// Get priority of the current process
int
sys_set_priority(unsigned int priority)
{
  800bdd:	55                   	push   %ebp
  800bde:	89 e5                	mov    %esp,%ebp
  800be0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, (uint32_t) priority, 0, 0, 0, 0);
  800be3:	6a 00                	push   $0x0
  800be5:	6a 00                	push   $0x0
  800be7:	6a 00                	push   $0x0
  800be9:	6a 00                	push   $0x0
  800beb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bee:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf3:	b8 0e 00 00 00       	mov    $0xe,%eax
  800bf8:	e8 c2 fd ff ff       	call   8009bf <syscall>
}
  800bfd:	c9                   	leave  
  800bfe:	c3                   	ret    

00800bff <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800bff:	55                   	push   %ebp
  800c00:	89 e5                	mov    %esp,%ebp
  800c02:	56                   	push   %esi
  800c03:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800c04:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800c07:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800c0d:	e8 62 fe ff ff       	call   800a74 <sys_getenvid>
  800c12:	83 ec 0c             	sub    $0xc,%esp
  800c15:	ff 75 0c             	push   0xc(%ebp)
  800c18:	ff 75 08             	push   0x8(%ebp)
  800c1b:	56                   	push   %esi
  800c1c:	50                   	push   %eax
  800c1d:	68 50 11 80 00       	push   $0x801150
  800c22:	e8 1b f5 ff ff       	call   800142 <cprintf>
	        sys_getenvid(),
	        binaryname,
	        file,
	        line);
	vcprintf(fmt, ap);
  800c27:	83 c4 18             	add    $0x18,%esp
  800c2a:	53                   	push   %ebx
  800c2b:	ff 75 10             	push   0x10(%ebp)
  800c2e:	e8 be f4 ff ff       	call   8000f1 <vcprintf>
	cprintf("\n");
  800c33:	c7 04 24 73 11 80 00 	movl   $0x801173,(%esp)
  800c3a:	e8 03 f5 ff ff       	call   800142 <cprintf>
  800c3f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800c42:	cc                   	int3   
  800c43:	eb fd                	jmp    800c42 <_panic+0x43>
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
