
obj/user/divzero:     formato del fichero elf32-i386


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
  80002c:	e8 2f 00 00 00       	call   800060 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	zero = 0;
  800039:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800040:	00 00 00 
	cprintf("1/0 is %08x!\n", 1 / zero);
  800043:	b8 01 00 00 00       	mov    $0x1,%eax
  800048:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004d:	99                   	cltd   
  80004e:	f7 f9                	idiv   %ecx
  800050:	50                   	push   %eax
  800051:	68 a0 0e 80 00       	push   $0x800ea0
  800056:	e8 f9 00 00 00       	call   800154 <cprintf>
}
  80005b:	83 c4 10             	add    $0x10,%esp
  80005e:	c9                   	leave  
  80005f:	c3                   	ret    

00800060 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	56                   	push   %esi
  800064:	53                   	push   %ebx
  800065:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800068:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	envid_t id = sys_getenvid();
  80006b:	e8 16 0a 00 00       	call   800a86 <sys_getenvid>
	if (id >= 0)
  800070:	85 c0                	test   %eax,%eax
  800072:	78 15                	js     800089 <libmain+0x29>
		thisenv = &envs[ENVX(id)];
  800074:	25 ff 03 00 00       	and    $0x3ff,%eax
  800079:	69 c0 88 00 00 00    	imul   $0x88,%eax,%eax
  80007f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800084:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800089:	85 db                	test   %ebx,%ebx
  80008b:	7e 07                	jle    800094 <libmain+0x34>
		binaryname = argv[0];
  80008d:	8b 06                	mov    (%esi),%eax
  80008f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800094:	83 ec 08             	sub    $0x8,%esp
  800097:	56                   	push   %esi
  800098:	53                   	push   %ebx
  800099:	e8 95 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80009e:	e8 0a 00 00 00       	call   8000ad <exit>
}
  8000a3:	83 c4 10             	add    $0x10,%esp
  8000a6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a9:	5b                   	pop    %ebx
  8000aa:	5e                   	pop    %esi
  8000ab:	5d                   	pop    %ebp
  8000ac:	c3                   	ret    

008000ad <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ad:	55                   	push   %ebp
  8000ae:	89 e5                	mov    %esp,%ebp
  8000b0:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000b3:	6a 00                	push   $0x0
  8000b5:	e8 aa 09 00 00       	call   800a64 <sys_env_destroy>
}
  8000ba:	83 c4 10             	add    $0x10,%esp
  8000bd:	c9                   	leave  
  8000be:	c3                   	ret    

008000bf <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000bf:	55                   	push   %ebp
  8000c0:	89 e5                	mov    %esp,%ebp
  8000c2:	53                   	push   %ebx
  8000c3:	83 ec 04             	sub    $0x4,%esp
  8000c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c9:	8b 13                	mov    (%ebx),%edx
  8000cb:	8d 42 01             	lea    0x1(%edx),%eax
  8000ce:	89 03                	mov    %eax,(%ebx)
  8000d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256 - 1) {
  8000d7:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000dc:	74 09                	je     8000e7 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000de:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000e5:	c9                   	leave  
  8000e6:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8000e7:	83 ec 08             	sub    $0x8,%esp
  8000ea:	68 ff 00 00 00       	push   $0xff
  8000ef:	8d 43 08             	lea    0x8(%ebx),%eax
  8000f2:	50                   	push   %eax
  8000f3:	e8 22 09 00 00       	call   800a1a <sys_cputs>
		b->idx = 0;
  8000f8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000fe:	83 c4 10             	add    $0x10,%esp
  800101:	eb db                	jmp    8000de <putch+0x1f>

00800103 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800103:	55                   	push   %ebp
  800104:	89 e5                	mov    %esp,%ebp
  800106:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80010c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800113:	00 00 00 
	b.cnt = 0;
  800116:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80011d:	00 00 00 
	vprintfmt((void *) putch, &b, fmt, ap);
  800120:	ff 75 0c             	push   0xc(%ebp)
  800123:	ff 75 08             	push   0x8(%ebp)
  800126:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80012c:	50                   	push   %eax
  80012d:	68 bf 00 80 00       	push   $0x8000bf
  800132:	e8 74 01 00 00       	call   8002ab <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800137:	83 c4 08             	add    $0x8,%esp
  80013a:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800140:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800146:	50                   	push   %eax
  800147:	e8 ce 08 00 00       	call   800a1a <sys_cputs>

	return b.cnt;
}
  80014c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800152:	c9                   	leave  
  800153:	c3                   	ret    

00800154 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800154:	55                   	push   %ebp
  800155:	89 e5                	mov    %esp,%ebp
  800157:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80015a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80015d:	50                   	push   %eax
  80015e:	ff 75 08             	push   0x8(%ebp)
  800161:	e8 9d ff ff ff       	call   800103 <vcprintf>
	va_end(ap);

	return cnt;
}
  800166:	c9                   	leave  
  800167:	c3                   	ret    

00800168 <printnum>:
         void *putdat,
         unsigned long long num,
         unsigned base,
         int width,
         int padc)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	57                   	push   %edi
  80016c:	56                   	push   %esi
  80016d:	53                   	push   %ebx
  80016e:	83 ec 1c             	sub    $0x1c,%esp
  800171:	89 c7                	mov    %eax,%edi
  800173:	89 d6                	mov    %edx,%esi
  800175:	8b 45 08             	mov    0x8(%ebp),%eax
  800178:	8b 55 0c             	mov    0xc(%ebp),%edx
  80017b:	89 d1                	mov    %edx,%ecx
  80017d:	89 c2                	mov    %eax,%edx
  80017f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800182:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800185:	8b 45 10             	mov    0x10(%ebp),%eax
  800188:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80018b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80018e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800195:	39 c2                	cmp    %eax,%edx
  800197:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80019a:	72 3e                	jb     8001da <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80019c:	83 ec 0c             	sub    $0xc,%esp
  80019f:	ff 75 18             	push   0x18(%ebp)
  8001a2:	83 eb 01             	sub    $0x1,%ebx
  8001a5:	53                   	push   %ebx
  8001a6:	50                   	push   %eax
  8001a7:	83 ec 08             	sub    $0x8,%esp
  8001aa:	ff 75 e4             	push   -0x1c(%ebp)
  8001ad:	ff 75 e0             	push   -0x20(%ebp)
  8001b0:	ff 75 dc             	push   -0x24(%ebp)
  8001b3:	ff 75 d8             	push   -0x28(%ebp)
  8001b6:	e8 a5 0a 00 00       	call   800c60 <__udivdi3>
  8001bb:	83 c4 18             	add    $0x18,%esp
  8001be:	52                   	push   %edx
  8001bf:	50                   	push   %eax
  8001c0:	89 f2                	mov    %esi,%edx
  8001c2:	89 f8                	mov    %edi,%eax
  8001c4:	e8 9f ff ff ff       	call   800168 <printnum>
  8001c9:	83 c4 20             	add    $0x20,%esp
  8001cc:	eb 13                	jmp    8001e1 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001ce:	83 ec 08             	sub    $0x8,%esp
  8001d1:	56                   	push   %esi
  8001d2:	ff 75 18             	push   0x18(%ebp)
  8001d5:	ff d7                	call   *%edi
  8001d7:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001da:	83 eb 01             	sub    $0x1,%ebx
  8001dd:	85 db                	test   %ebx,%ebx
  8001df:	7f ed                	jg     8001ce <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001e1:	83 ec 08             	sub    $0x8,%esp
  8001e4:	56                   	push   %esi
  8001e5:	83 ec 04             	sub    $0x4,%esp
  8001e8:	ff 75 e4             	push   -0x1c(%ebp)
  8001eb:	ff 75 e0             	push   -0x20(%ebp)
  8001ee:	ff 75 dc             	push   -0x24(%ebp)
  8001f1:	ff 75 d8             	push   -0x28(%ebp)
  8001f4:	e8 87 0b 00 00       	call   800d80 <__umoddi3>
  8001f9:	83 c4 14             	add    $0x14,%esp
  8001fc:	0f be 80 b8 0e 80 00 	movsbl 0x800eb8(%eax),%eax
  800203:	50                   	push   %eax
  800204:	ff d7                	call   *%edi
}
  800206:	83 c4 10             	add    $0x10,%esp
  800209:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020c:	5b                   	pop    %ebx
  80020d:	5e                   	pop    %esi
  80020e:	5f                   	pop    %edi
  80020f:	5d                   	pop    %ebp
  800210:	c3                   	ret    

00800211 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800211:	83 fa 01             	cmp    $0x1,%edx
  800214:	7f 13                	jg     800229 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800216:	85 d2                	test   %edx,%edx
  800218:	74 1c                	je     800236 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  80021a:	8b 10                	mov    (%eax),%edx
  80021c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80021f:	89 08                	mov    %ecx,(%eax)
  800221:	8b 02                	mov    (%edx),%eax
  800223:	ba 00 00 00 00       	mov    $0x0,%edx
  800228:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  800229:	8b 10                	mov    (%eax),%edx
  80022b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80022e:	89 08                	mov    %ecx,(%eax)
  800230:	8b 02                	mov    (%edx),%eax
  800232:	8b 52 04             	mov    0x4(%edx),%edx
  800235:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  800236:	8b 10                	mov    (%eax),%edx
  800238:	8d 4a 04             	lea    0x4(%edx),%ecx
  80023b:	89 08                	mov    %ecx,(%eax)
  80023d:	8b 02                	mov    (%edx),%eax
  80023f:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800244:	c3                   	ret    

00800245 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800245:	83 fa 01             	cmp    $0x1,%edx
  800248:	7f 0f                	jg     800259 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  80024a:	85 d2                	test   %edx,%edx
  80024c:	74 18                	je     800266 <getint+0x21>
		return va_arg(*ap, long);
  80024e:	8b 10                	mov    (%eax),%edx
  800250:	8d 4a 04             	lea    0x4(%edx),%ecx
  800253:	89 08                	mov    %ecx,(%eax)
  800255:	8b 02                	mov    (%edx),%eax
  800257:	99                   	cltd   
  800258:	c3                   	ret    
		return va_arg(*ap, long long);
  800259:	8b 10                	mov    (%eax),%edx
  80025b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80025e:	89 08                	mov    %ecx,(%eax)
  800260:	8b 02                	mov    (%edx),%eax
  800262:	8b 52 04             	mov    0x4(%edx),%edx
  800265:	c3                   	ret    
	else
		return va_arg(*ap, int);
  800266:	8b 10                	mov    (%eax),%edx
  800268:	8d 4a 04             	lea    0x4(%edx),%ecx
  80026b:	89 08                	mov    %ecx,(%eax)
  80026d:	8b 02                	mov    (%edx),%eax
  80026f:	99                   	cltd   
}
  800270:	c3                   	ret    

00800271 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800271:	55                   	push   %ebp
  800272:	89 e5                	mov    %esp,%ebp
  800274:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800277:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80027b:	8b 10                	mov    (%eax),%edx
  80027d:	3b 50 04             	cmp    0x4(%eax),%edx
  800280:	73 0a                	jae    80028c <sprintputch+0x1b>
		*b->buf++ = ch;
  800282:	8d 4a 01             	lea    0x1(%edx),%ecx
  800285:	89 08                	mov    %ecx,(%eax)
  800287:	8b 45 08             	mov    0x8(%ebp),%eax
  80028a:	88 02                	mov    %al,(%edx)
}
  80028c:	5d                   	pop    %ebp
  80028d:	c3                   	ret    

0080028e <printfmt>:
{
  80028e:	55                   	push   %ebp
  80028f:	89 e5                	mov    %esp,%ebp
  800291:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800294:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800297:	50                   	push   %eax
  800298:	ff 75 10             	push   0x10(%ebp)
  80029b:	ff 75 0c             	push   0xc(%ebp)
  80029e:	ff 75 08             	push   0x8(%ebp)
  8002a1:	e8 05 00 00 00       	call   8002ab <vprintfmt>
}
  8002a6:	83 c4 10             	add    $0x10,%esp
  8002a9:	c9                   	leave  
  8002aa:	c3                   	ret    

008002ab <vprintfmt>:
{
  8002ab:	55                   	push   %ebp
  8002ac:	89 e5                	mov    %esp,%ebp
  8002ae:	57                   	push   %edi
  8002af:	56                   	push   %esi
  8002b0:	53                   	push   %ebx
  8002b1:	83 ec 2c             	sub    $0x2c,%esp
  8002b4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002b7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8002ba:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002bd:	eb 0a                	jmp    8002c9 <vprintfmt+0x1e>
			putch(ch, putdat);
  8002bf:	83 ec 08             	sub    $0x8,%esp
  8002c2:	56                   	push   %esi
  8002c3:	50                   	push   %eax
  8002c4:	ff d3                	call   *%ebx
  8002c6:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002c9:	83 c7 01             	add    $0x1,%edi
  8002cc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002d0:	83 f8 25             	cmp    $0x25,%eax
  8002d3:	74 0c                	je     8002e1 <vprintfmt+0x36>
			if (ch == '\0')
  8002d5:	85 c0                	test   %eax,%eax
  8002d7:	75 e6                	jne    8002bf <vprintfmt+0x14>
}
  8002d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002dc:	5b                   	pop    %ebx
  8002dd:	5e                   	pop    %esi
  8002de:	5f                   	pop    %edi
  8002df:	5d                   	pop    %ebp
  8002e0:	c3                   	ret    
		padc = ' ';
  8002e1:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
		altflag = 0;
  8002e5:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002ec:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002f3:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002fa:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002ff:	8d 47 01             	lea    0x1(%edi),%eax
  800302:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800305:	0f b6 17             	movzbl (%edi),%edx
  800308:	8d 42 dd             	lea    -0x23(%edx),%eax
  80030b:	3c 55                	cmp    $0x55,%al
  80030d:	0f 87 b7 02 00 00    	ja     8005ca <vprintfmt+0x31f>
  800313:	0f b6 c0             	movzbl %al,%eax
  800316:	ff 24 85 80 0f 80 00 	jmp    *0x800f80(,%eax,4)
  80031d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800320:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800324:	eb d9                	jmp    8002ff <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800326:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800329:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  80032d:	eb d0                	jmp    8002ff <vprintfmt+0x54>
  80032f:	0f b6 d2             	movzbl %dl,%edx
  800332:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0;; ++fmt) {
  800335:	b8 00 00 00 00       	mov    $0x0,%eax
  80033a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80033d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800340:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800344:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800347:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80034a:	83 f9 09             	cmp    $0x9,%ecx
  80034d:	77 52                	ja     8003a1 <vprintfmt+0xf6>
			for (precision = 0;; ++fmt) {
  80034f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800352:	eb e9                	jmp    80033d <vprintfmt+0x92>
			precision = va_arg(ap, int);
  800354:	8b 45 14             	mov    0x14(%ebp),%eax
  800357:	8d 50 04             	lea    0x4(%eax),%edx
  80035a:	89 55 14             	mov    %edx,0x14(%ebp)
  80035d:	8b 00                	mov    (%eax),%eax
  80035f:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800362:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800365:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800369:	79 94                	jns    8002ff <vprintfmt+0x54>
				width = precision, precision = -1;
  80036b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80036e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800371:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800378:	eb 85                	jmp    8002ff <vprintfmt+0x54>
  80037a:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80037d:	85 d2                	test   %edx,%edx
  80037f:	b8 00 00 00 00       	mov    $0x0,%eax
  800384:	0f 49 c2             	cmovns %edx,%eax
  800387:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80038a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80038d:	e9 6d ff ff ff       	jmp    8002ff <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800392:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800395:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80039c:	e9 5e ff ff ff       	jmp    8002ff <vprintfmt+0x54>
  8003a1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003a4:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003a7:	eb bc                	jmp    800365 <vprintfmt+0xba>
			lflag++;
  8003a9:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003af:	e9 4b ff ff ff       	jmp    8002ff <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8003b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b7:	8d 50 04             	lea    0x4(%eax),%edx
  8003ba:	89 55 14             	mov    %edx,0x14(%ebp)
  8003bd:	83 ec 08             	sub    $0x8,%esp
  8003c0:	56                   	push   %esi
  8003c1:	ff 30                	push   (%eax)
  8003c3:	ff d3                	call   *%ebx
			break;
  8003c5:	83 c4 10             	add    $0x10,%esp
  8003c8:	e9 94 01 00 00       	jmp    800561 <vprintfmt+0x2b6>
			err = va_arg(ap, int);
  8003cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d0:	8d 50 04             	lea    0x4(%eax),%edx
  8003d3:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d6:	8b 10                	mov    (%eax),%edx
  8003d8:	89 d0                	mov    %edx,%eax
  8003da:	f7 d8                	neg    %eax
  8003dc:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003df:	83 f8 08             	cmp    $0x8,%eax
  8003e2:	7f 20                	jg     800404 <vprintfmt+0x159>
  8003e4:	8b 14 85 e0 10 80 00 	mov    0x8010e0(,%eax,4),%edx
  8003eb:	85 d2                	test   %edx,%edx
  8003ed:	74 15                	je     800404 <vprintfmt+0x159>
				printfmt(putch, putdat, "%s", p);
  8003ef:	52                   	push   %edx
  8003f0:	68 d9 0e 80 00       	push   $0x800ed9
  8003f5:	56                   	push   %esi
  8003f6:	53                   	push   %ebx
  8003f7:	e8 92 fe ff ff       	call   80028e <printfmt>
  8003fc:	83 c4 10             	add    $0x10,%esp
  8003ff:	e9 5d 01 00 00       	jmp    800561 <vprintfmt+0x2b6>
				printfmt(putch, putdat, "error %d", err);
  800404:	50                   	push   %eax
  800405:	68 d0 0e 80 00       	push   $0x800ed0
  80040a:	56                   	push   %esi
  80040b:	53                   	push   %ebx
  80040c:	e8 7d fe ff ff       	call   80028e <printfmt>
  800411:	83 c4 10             	add    $0x10,%esp
  800414:	e9 48 01 00 00       	jmp    800561 <vprintfmt+0x2b6>
			if ((p = va_arg(ap, char *)) == NULL)
  800419:	8b 45 14             	mov    0x14(%ebp),%eax
  80041c:	8d 50 04             	lea    0x4(%eax),%edx
  80041f:	89 55 14             	mov    %edx,0x14(%ebp)
  800422:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800424:	85 ff                	test   %edi,%edi
  800426:	b8 c9 0e 80 00       	mov    $0x800ec9,%eax
  80042b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80042e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800432:	7e 06                	jle    80043a <vprintfmt+0x18f>
  800434:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  800438:	75 0a                	jne    800444 <vprintfmt+0x199>
  80043a:	89 f8                	mov    %edi,%eax
  80043c:	03 45 e0             	add    -0x20(%ebp),%eax
  80043f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800442:	eb 59                	jmp    80049d <vprintfmt+0x1f2>
				for (width -= strnlen(p, precision); width > 0;
  800444:	83 ec 08             	sub    $0x8,%esp
  800447:	ff 75 d8             	push   -0x28(%ebp)
  80044a:	57                   	push   %edi
  80044b:	e8 1a 02 00 00       	call   80066a <strnlen>
  800450:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800453:	29 c1                	sub    %eax,%ecx
  800455:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800458:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80045b:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  80045f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800462:	89 7d d0             	mov    %edi,-0x30(%ebp)
  800465:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0;
  800467:	eb 0f                	jmp    800478 <vprintfmt+0x1cd>
					putch(padc, putdat);
  800469:	83 ec 08             	sub    $0x8,%esp
  80046c:	56                   	push   %esi
  80046d:	ff 75 e0             	push   -0x20(%ebp)
  800470:	ff d3                	call   *%ebx
				     width--)
  800472:	83 ef 01             	sub    $0x1,%edi
  800475:	83 c4 10             	add    $0x10,%esp
				for (width -= strnlen(p, precision); width > 0;
  800478:	85 ff                	test   %edi,%edi
  80047a:	7f ed                	jg     800469 <vprintfmt+0x1be>
  80047c:	8b 7d d0             	mov    -0x30(%ebp),%edi
  80047f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800482:	85 c9                	test   %ecx,%ecx
  800484:	b8 00 00 00 00       	mov    $0x0,%eax
  800489:	0f 49 c1             	cmovns %ecx,%eax
  80048c:	29 c1                	sub    %eax,%ecx
  80048e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800491:	eb a7                	jmp    80043a <vprintfmt+0x18f>
					putch(ch, putdat);
  800493:	83 ec 08             	sub    $0x8,%esp
  800496:	56                   	push   %esi
  800497:	52                   	push   %edx
  800498:	ff d3                	call   *%ebx
  80049a:	83 c4 10             	add    $0x10,%esp
  80049d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004a0:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' &&
  8004a2:	83 c7 01             	add    $0x1,%edi
  8004a5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004a9:	0f be d0             	movsbl %al,%edx
  8004ac:	85 d2                	test   %edx,%edx
  8004ae:	74 42                	je     8004f2 <vprintfmt+0x247>
  8004b0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004b4:	78 06                	js     8004bc <vprintfmt+0x211>
			       (precision < 0 || --precision >= 0);
  8004b6:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004ba:	78 1e                	js     8004da <vprintfmt+0x22f>
				if (altflag && (ch < ' ' || ch > '~'))
  8004bc:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004c0:	74 d1                	je     800493 <vprintfmt+0x1e8>
  8004c2:	0f be c0             	movsbl %al,%eax
  8004c5:	83 e8 20             	sub    $0x20,%eax
  8004c8:	83 f8 5e             	cmp    $0x5e,%eax
  8004cb:	76 c6                	jbe    800493 <vprintfmt+0x1e8>
					putch('?', putdat);
  8004cd:	83 ec 08             	sub    $0x8,%esp
  8004d0:	56                   	push   %esi
  8004d1:	6a 3f                	push   $0x3f
  8004d3:	ff d3                	call   *%ebx
  8004d5:	83 c4 10             	add    $0x10,%esp
  8004d8:	eb c3                	jmp    80049d <vprintfmt+0x1f2>
  8004da:	89 cf                	mov    %ecx,%edi
  8004dc:	eb 0e                	jmp    8004ec <vprintfmt+0x241>
				putch(' ', putdat);
  8004de:	83 ec 08             	sub    $0x8,%esp
  8004e1:	56                   	push   %esi
  8004e2:	6a 20                	push   $0x20
  8004e4:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  8004e6:	83 ef 01             	sub    $0x1,%edi
  8004e9:	83 c4 10             	add    $0x10,%esp
  8004ec:	85 ff                	test   %edi,%edi
  8004ee:	7f ee                	jg     8004de <vprintfmt+0x233>
  8004f0:	eb 6f                	jmp    800561 <vprintfmt+0x2b6>
  8004f2:	89 cf                	mov    %ecx,%edi
  8004f4:	eb f6                	jmp    8004ec <vprintfmt+0x241>
			num = getint(&ap, lflag);
  8004f6:	89 ca                	mov    %ecx,%edx
  8004f8:	8d 45 14             	lea    0x14(%ebp),%eax
  8004fb:	e8 45 fd ff ff       	call   800245 <getint>
  800500:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800503:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800506:	85 d2                	test   %edx,%edx
  800508:	78 0b                	js     800515 <vprintfmt+0x26a>
			num = getint(&ap, lflag);
  80050a:	89 d1                	mov    %edx,%ecx
  80050c:	89 c2                	mov    %eax,%edx
			base = 10;
  80050e:	bf 0a 00 00 00       	mov    $0xa,%edi
  800513:	eb 32                	jmp    800547 <vprintfmt+0x29c>
				putch('-', putdat);
  800515:	83 ec 08             	sub    $0x8,%esp
  800518:	56                   	push   %esi
  800519:	6a 2d                	push   $0x2d
  80051b:	ff d3                	call   *%ebx
				num = -(long long) num;
  80051d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800520:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800523:	f7 da                	neg    %edx
  800525:	83 d1 00             	adc    $0x0,%ecx
  800528:	f7 d9                	neg    %ecx
  80052a:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80052d:	bf 0a 00 00 00       	mov    $0xa,%edi
  800532:	eb 13                	jmp    800547 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  800534:	89 ca                	mov    %ecx,%edx
  800536:	8d 45 14             	lea    0x14(%ebp),%eax
  800539:	e8 d3 fc ff ff       	call   800211 <getuint>
  80053e:	89 d1                	mov    %edx,%ecx
  800540:	89 c2                	mov    %eax,%edx
			base = 10;
  800542:	bf 0a 00 00 00       	mov    $0xa,%edi
			printnum(putch, putdat, num, base, width, padc);
  800547:	83 ec 0c             	sub    $0xc,%esp
  80054a:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  80054e:	50                   	push   %eax
  80054f:	ff 75 e0             	push   -0x20(%ebp)
  800552:	57                   	push   %edi
  800553:	51                   	push   %ecx
  800554:	52                   	push   %edx
  800555:	89 f2                	mov    %esi,%edx
  800557:	89 d8                	mov    %ebx,%eax
  800559:	e8 0a fc ff ff       	call   800168 <printnum>
			break;
  80055e:	83 c4 20             	add    $0x20,%esp
{
  800561:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800564:	e9 60 fd ff ff       	jmp    8002c9 <vprintfmt+0x1e>
			num = getuint(&ap, lflag);
  800569:	89 ca                	mov    %ecx,%edx
  80056b:	8d 45 14             	lea    0x14(%ebp),%eax
  80056e:	e8 9e fc ff ff       	call   800211 <getuint>
  800573:	89 d1                	mov    %edx,%ecx
  800575:	89 c2                	mov    %eax,%edx
			base = 8;
  800577:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  80057c:	eb c9                	jmp    800547 <vprintfmt+0x29c>
			putch('0', putdat);
  80057e:	83 ec 08             	sub    $0x8,%esp
  800581:	56                   	push   %esi
  800582:	6a 30                	push   $0x30
  800584:	ff d3                	call   *%ebx
			putch('x', putdat);
  800586:	83 c4 08             	add    $0x8,%esp
  800589:	56                   	push   %esi
  80058a:	6a 78                	push   $0x78
  80058c:	ff d3                	call   *%ebx
			num = (unsigned long long) (uintptr_t) va_arg(ap, void *);
  80058e:	8b 45 14             	mov    0x14(%ebp),%eax
  800591:	8d 50 04             	lea    0x4(%eax),%edx
  800594:	89 55 14             	mov    %edx,0x14(%ebp)
  800597:	8b 10                	mov    (%eax),%edx
  800599:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80059e:	83 c4 10             	add    $0x10,%esp
			base = 16;
  8005a1:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  8005a6:	eb 9f                	jmp    800547 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  8005a8:	89 ca                	mov    %ecx,%edx
  8005aa:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ad:	e8 5f fc ff ff       	call   800211 <getuint>
  8005b2:	89 d1                	mov    %edx,%ecx
  8005b4:	89 c2                	mov    %eax,%edx
			base = 16;
  8005b6:	bf 10 00 00 00       	mov    $0x10,%edi
  8005bb:	eb 8a                	jmp    800547 <vprintfmt+0x29c>
			putch(ch, putdat);
  8005bd:	83 ec 08             	sub    $0x8,%esp
  8005c0:	56                   	push   %esi
  8005c1:	6a 25                	push   $0x25
  8005c3:	ff d3                	call   *%ebx
			break;
  8005c5:	83 c4 10             	add    $0x10,%esp
  8005c8:	eb 97                	jmp    800561 <vprintfmt+0x2b6>
			putch('%', putdat);
  8005ca:	83 ec 08             	sub    $0x8,%esp
  8005cd:	56                   	push   %esi
  8005ce:	6a 25                	push   $0x25
  8005d0:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  8005d2:	83 c4 10             	add    $0x10,%esp
  8005d5:	89 f8                	mov    %edi,%eax
  8005d7:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8005db:	74 05                	je     8005e2 <vprintfmt+0x337>
  8005dd:	83 e8 01             	sub    $0x1,%eax
  8005e0:	eb f5                	jmp    8005d7 <vprintfmt+0x32c>
  8005e2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005e5:	e9 77 ff ff ff       	jmp    800561 <vprintfmt+0x2b6>

008005ea <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8005ea:	55                   	push   %ebp
  8005eb:	89 e5                	mov    %esp,%ebp
  8005ed:	83 ec 18             	sub    $0x18,%esp
  8005f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8005f3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = { buf, buf + n - 1, 0 };
  8005f6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8005f9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8005fd:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800600:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800607:	85 c0                	test   %eax,%eax
  800609:	74 26                	je     800631 <vsnprintf+0x47>
  80060b:	85 d2                	test   %edx,%edx
  80060d:	7e 22                	jle    800631 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *) sprintputch, &b, fmt, ap);
  80060f:	ff 75 14             	push   0x14(%ebp)
  800612:	ff 75 10             	push   0x10(%ebp)
  800615:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800618:	50                   	push   %eax
  800619:	68 71 02 80 00       	push   $0x800271
  80061e:	e8 88 fc ff ff       	call   8002ab <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800623:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800626:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800629:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80062c:	83 c4 10             	add    $0x10,%esp
}
  80062f:	c9                   	leave  
  800630:	c3                   	ret    
		return -E_INVAL;
  800631:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800636:	eb f7                	jmp    80062f <vsnprintf+0x45>

00800638 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800638:	55                   	push   %ebp
  800639:	89 e5                	mov    %esp,%ebp
  80063b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80063e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800641:	50                   	push   %eax
  800642:	ff 75 10             	push   0x10(%ebp)
  800645:	ff 75 0c             	push   0xc(%ebp)
  800648:	ff 75 08             	push   0x8(%ebp)
  80064b:	e8 9a ff ff ff       	call   8005ea <vsnprintf>
	va_end(ap);

	return rc;
}
  800650:	c9                   	leave  
  800651:	c3                   	ret    

00800652 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800652:	55                   	push   %ebp
  800653:	89 e5                	mov    %esp,%ebp
  800655:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800658:	b8 00 00 00 00       	mov    $0x0,%eax
  80065d:	eb 03                	jmp    800662 <strlen+0x10>
		n++;
  80065f:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800662:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800666:	75 f7                	jne    80065f <strlen+0xd>
	return n;
}
  800668:	5d                   	pop    %ebp
  800669:	c3                   	ret    

0080066a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80066a:	55                   	push   %ebp
  80066b:	89 e5                	mov    %esp,%ebp
  80066d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800670:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800673:	b8 00 00 00 00       	mov    $0x0,%eax
  800678:	eb 03                	jmp    80067d <strnlen+0x13>
		n++;
  80067a:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80067d:	39 d0                	cmp    %edx,%eax
  80067f:	74 08                	je     800689 <strnlen+0x1f>
  800681:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800685:	75 f3                	jne    80067a <strnlen+0x10>
  800687:	89 c2                	mov    %eax,%edx
	return n;
}
  800689:	89 d0                	mov    %edx,%eax
  80068b:	5d                   	pop    %ebp
  80068c:	c3                   	ret    

0080068d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80068d:	55                   	push   %ebp
  80068e:	89 e5                	mov    %esp,%ebp
  800690:	53                   	push   %ebx
  800691:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800694:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800697:	b8 00 00 00 00       	mov    $0x0,%eax
  80069c:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8006a0:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8006a3:	83 c0 01             	add    $0x1,%eax
  8006a6:	84 d2                	test   %dl,%dl
  8006a8:	75 f2                	jne    80069c <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8006aa:	89 c8                	mov    %ecx,%eax
  8006ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006af:	c9                   	leave  
  8006b0:	c3                   	ret    

008006b1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8006b1:	55                   	push   %ebp
  8006b2:	89 e5                	mov    %esp,%ebp
  8006b4:	53                   	push   %ebx
  8006b5:	83 ec 10             	sub    $0x10,%esp
  8006b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8006bb:	53                   	push   %ebx
  8006bc:	e8 91 ff ff ff       	call   800652 <strlen>
  8006c1:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8006c4:	ff 75 0c             	push   0xc(%ebp)
  8006c7:	01 d8                	add    %ebx,%eax
  8006c9:	50                   	push   %eax
  8006ca:	e8 be ff ff ff       	call   80068d <strcpy>
	return dst;
}
  8006cf:	89 d8                	mov    %ebx,%eax
  8006d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006d4:	c9                   	leave  
  8006d5:	c3                   	ret    

008006d6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size)
{
  8006d6:	55                   	push   %ebp
  8006d7:	89 e5                	mov    %esp,%ebp
  8006d9:	56                   	push   %esi
  8006da:	53                   	push   %ebx
  8006db:	8b 75 08             	mov    0x8(%ebp),%esi
  8006de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006e1:	89 f3                	mov    %esi,%ebx
  8006e3:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8006e6:	89 f0                	mov    %esi,%eax
  8006e8:	eb 0f                	jmp    8006f9 <strncpy+0x23>
		*dst++ = *src;
  8006ea:	83 c0 01             	add    $0x1,%eax
  8006ed:	0f b6 0a             	movzbl (%edx),%ecx
  8006f0:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8006f3:	80 f9 01             	cmp    $0x1,%cl
  8006f6:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  8006f9:	39 d8                	cmp    %ebx,%eax
  8006fb:	75 ed                	jne    8006ea <strncpy+0x14>
	}
	return ret;
}
  8006fd:	89 f0                	mov    %esi,%eax
  8006ff:	5b                   	pop    %ebx
  800700:	5e                   	pop    %esi
  800701:	5d                   	pop    %ebp
  800702:	c3                   	ret    

00800703 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800703:	55                   	push   %ebp
  800704:	89 e5                	mov    %esp,%ebp
  800706:	56                   	push   %esi
  800707:	53                   	push   %ebx
  800708:	8b 75 08             	mov    0x8(%ebp),%esi
  80070b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80070e:	8b 55 10             	mov    0x10(%ebp),%edx
  800711:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800713:	85 d2                	test   %edx,%edx
  800715:	74 21                	je     800738 <strlcpy+0x35>
  800717:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80071b:	89 f2                	mov    %esi,%edx
  80071d:	eb 09                	jmp    800728 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80071f:	83 c1 01             	add    $0x1,%ecx
  800722:	83 c2 01             	add    $0x1,%edx
  800725:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800728:	39 c2                	cmp    %eax,%edx
  80072a:	74 09                	je     800735 <strlcpy+0x32>
  80072c:	0f b6 19             	movzbl (%ecx),%ebx
  80072f:	84 db                	test   %bl,%bl
  800731:	75 ec                	jne    80071f <strlcpy+0x1c>
  800733:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800735:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800738:	29 f0                	sub    %esi,%eax
}
  80073a:	5b                   	pop    %ebx
  80073b:	5e                   	pop    %esi
  80073c:	5d                   	pop    %ebp
  80073d:	c3                   	ret    

0080073e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80073e:	55                   	push   %ebp
  80073f:	89 e5                	mov    %esp,%ebp
  800741:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800744:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800747:	eb 06                	jmp    80074f <strcmp+0x11>
		p++, q++;
  800749:	83 c1 01             	add    $0x1,%ecx
  80074c:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80074f:	0f b6 01             	movzbl (%ecx),%eax
  800752:	84 c0                	test   %al,%al
  800754:	74 04                	je     80075a <strcmp+0x1c>
  800756:	3a 02                	cmp    (%edx),%al
  800758:	74 ef                	je     800749 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80075a:	0f b6 c0             	movzbl %al,%eax
  80075d:	0f b6 12             	movzbl (%edx),%edx
  800760:	29 d0                	sub    %edx,%eax
}
  800762:	5d                   	pop    %ebp
  800763:	c3                   	ret    

00800764 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800764:	55                   	push   %ebp
  800765:	89 e5                	mov    %esp,%ebp
  800767:	53                   	push   %ebx
  800768:	8b 45 08             	mov    0x8(%ebp),%eax
  80076b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80076e:	89 c3                	mov    %eax,%ebx
  800770:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800773:	eb 06                	jmp    80077b <strncmp+0x17>
		n--, p++, q++;
  800775:	83 c0 01             	add    $0x1,%eax
  800778:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80077b:	39 d8                	cmp    %ebx,%eax
  80077d:	74 18                	je     800797 <strncmp+0x33>
  80077f:	0f b6 08             	movzbl (%eax),%ecx
  800782:	84 c9                	test   %cl,%cl
  800784:	74 04                	je     80078a <strncmp+0x26>
  800786:	3a 0a                	cmp    (%edx),%cl
  800788:	74 eb                	je     800775 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80078a:	0f b6 00             	movzbl (%eax),%eax
  80078d:	0f b6 12             	movzbl (%edx),%edx
  800790:	29 d0                	sub    %edx,%eax
}
  800792:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800795:	c9                   	leave  
  800796:	c3                   	ret    
		return 0;
  800797:	b8 00 00 00 00       	mov    $0x0,%eax
  80079c:	eb f4                	jmp    800792 <strncmp+0x2e>

0080079e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80079e:	55                   	push   %ebp
  80079f:	89 e5                	mov    %esp,%ebp
  8007a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007a8:	eb 03                	jmp    8007ad <strchr+0xf>
  8007aa:	83 c0 01             	add    $0x1,%eax
  8007ad:	0f b6 10             	movzbl (%eax),%edx
  8007b0:	84 d2                	test   %dl,%dl
  8007b2:	74 06                	je     8007ba <strchr+0x1c>
		if (*s == c)
  8007b4:	38 ca                	cmp    %cl,%dl
  8007b6:	75 f2                	jne    8007aa <strchr+0xc>
  8007b8:	eb 05                	jmp    8007bf <strchr+0x21>
			return (char *) s;
	return 0;
  8007ba:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007bf:	5d                   	pop    %ebp
  8007c0:	c3                   	ret    

008007c1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8007c1:	55                   	push   %ebp
  8007c2:	89 e5                	mov    %esp,%ebp
  8007c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007cb:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8007ce:	38 ca                	cmp    %cl,%dl
  8007d0:	74 09                	je     8007db <strfind+0x1a>
  8007d2:	84 d2                	test   %dl,%dl
  8007d4:	74 05                	je     8007db <strfind+0x1a>
	for (; *s; s++)
  8007d6:	83 c0 01             	add    $0x1,%eax
  8007d9:	eb f0                	jmp    8007cb <strfind+0xa>
			break;
	return (char *) s;
}
  8007db:	5d                   	pop    %ebp
  8007dc:	c3                   	ret    

008007dd <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8007dd:	55                   	push   %ebp
  8007de:	89 e5                	mov    %esp,%ebp
  8007e0:	57                   	push   %edi
  8007e1:	56                   	push   %esi
  8007e2:	53                   	push   %ebx
  8007e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8007e6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  8007e9:	85 c9                	test   %ecx,%ecx
  8007eb:	74 33                	je     800820 <memset+0x43>
		return v;
	if ((int) v % 4 == 0 && n % 4 == 0) {
  8007ed:	89 d0                	mov    %edx,%eax
  8007ef:	09 c8                	or     %ecx,%eax
  8007f1:	a8 03                	test   $0x3,%al
  8007f3:	75 23                	jne    800818 <memset+0x3b>
		c &= 0xFF;
  8007f5:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  8007f9:	89 d8                	mov    %ebx,%eax
  8007fb:	c1 e0 08             	shl    $0x8,%eax
  8007fe:	89 df                	mov    %ebx,%edi
  800800:	c1 e7 18             	shl    $0x18,%edi
  800803:	89 de                	mov    %ebx,%esi
  800805:	c1 e6 10             	shl    $0x10,%esi
  800808:	09 f7                	or     %esi,%edi
  80080a:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
		             : "=D"(p), "=c"(n)
		             : "D"(p), "a"(c), "c"(n / 4)
  80080c:	c1 e9 02             	shr    $0x2,%ecx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  80080f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800811:	89 d7                	mov    %edx,%edi
  800813:	fc                   	cld    
  800814:	f3 ab                	rep stos %eax,%es:(%edi)
  800816:	eb 08                	jmp    800820 <memset+0x43>
		             : "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800818:	89 d7                	mov    %edx,%edi
  80081a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80081d:	fc                   	cld    
  80081e:	f3 aa                	rep stos %al,%es:(%edi)
		             : "=D"(p), "=c"(n)
		             : "0"(p), "a"(c), "1"(n)
		             : "cc", "memory");
	return v;
}
  800820:	89 d0                	mov    %edx,%eax
  800822:	5b                   	pop    %ebx
  800823:	5e                   	pop    %esi
  800824:	5f                   	pop    %edi
  800825:	5d                   	pop    %ebp
  800826:	c3                   	ret    

00800827 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800827:	55                   	push   %ebp
  800828:	89 e5                	mov    %esp,%ebp
  80082a:	57                   	push   %edi
  80082b:	56                   	push   %esi
  80082c:	8b 45 08             	mov    0x8(%ebp),%eax
  80082f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800832:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800835:	39 c6                	cmp    %eax,%esi
  800837:	73 32                	jae    80086b <memmove+0x44>
  800839:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80083c:	39 c2                	cmp    %eax,%edx
  80083e:	76 2b                	jbe    80086b <memmove+0x44>
		s += n;
		d += n;
  800840:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  800843:	89 d6                	mov    %edx,%esi
  800845:	09 fe                	or     %edi,%esi
  800847:	09 ce                	or     %ecx,%esi
  800849:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80084f:	75 0e                	jne    80085f <memmove+0x38>
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  800851:	83 ef 04             	sub    $0x4,%edi
			             "S"(s - 4),
  800854:	8d 72 fc             	lea    -0x4(%edx),%esi
			             "c"(n / 4)
  800857:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  80085a:	fd                   	std    
  80085b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80085d:	eb 09                	jmp    800868 <memmove+0x41>
			             : "cc", "memory");
		else
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  80085f:	83 ef 01             	sub    $0x1,%edi
			             "S"(s - 1),
  800862:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  800865:	fd                   	std    
  800866:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             "c"(n)
			             : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800868:	fc                   	cld    
  800869:	eb 1a                	jmp    800885 <memmove+0x5e>
	} else {
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  80086b:	89 f2                	mov    %esi,%edx
  80086d:	09 c2                	or     %eax,%edx
  80086f:	09 ca                	or     %ecx,%edx
  800871:	f6 c2 03             	test   $0x3,%dl
  800874:	75 0a                	jne    800880 <memmove+0x59>
			asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800876:	c1 e9 02             	shr    $0x2,%ecx
  800879:	89 c7                	mov    %eax,%edi
  80087b:	fc                   	cld    
  80087c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80087e:	eb 05                	jmp    800885 <memmove+0x5e>
			             : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800880:	89 c7                	mov    %eax,%edi
  800882:	fc                   	cld    
  800883:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             : "cc", "memory");
	}
	return dst;
}
  800885:	5e                   	pop    %esi
  800886:	5f                   	pop    %edi
  800887:	5d                   	pop    %ebp
  800888:	c3                   	ret    

00800889 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800889:	55                   	push   %ebp
  80088a:	89 e5                	mov    %esp,%ebp
  80088c:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80088f:	ff 75 10             	push   0x10(%ebp)
  800892:	ff 75 0c             	push   0xc(%ebp)
  800895:	ff 75 08             	push   0x8(%ebp)
  800898:	e8 8a ff ff ff       	call   800827 <memmove>
}
  80089d:	c9                   	leave  
  80089e:	c3                   	ret    

0080089f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80089f:	55                   	push   %ebp
  8008a0:	89 e5                	mov    %esp,%ebp
  8008a2:	56                   	push   %esi
  8008a3:	53                   	push   %ebx
  8008a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008aa:	89 c6                	mov    %eax,%esi
  8008ac:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8008af:	eb 06                	jmp    8008b7 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8008b1:	83 c0 01             	add    $0x1,%eax
  8008b4:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  8008b7:	39 f0                	cmp    %esi,%eax
  8008b9:	74 14                	je     8008cf <memcmp+0x30>
		if (*s1 != *s2)
  8008bb:	0f b6 08             	movzbl (%eax),%ecx
  8008be:	0f b6 1a             	movzbl (%edx),%ebx
  8008c1:	38 d9                	cmp    %bl,%cl
  8008c3:	74 ec                	je     8008b1 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  8008c5:	0f b6 c1             	movzbl %cl,%eax
  8008c8:	0f b6 db             	movzbl %bl,%ebx
  8008cb:	29 d8                	sub    %ebx,%eax
  8008cd:	eb 05                	jmp    8008d4 <memcmp+0x35>
	}

	return 0;
  8008cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008d4:	5b                   	pop    %ebx
  8008d5:	5e                   	pop    %esi
  8008d6:	5d                   	pop    %ebp
  8008d7:	c3                   	ret    

008008d8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8008d8:	55                   	push   %ebp
  8008d9:	89 e5                	mov    %esp,%ebp
  8008db:	8b 45 08             	mov    0x8(%ebp),%eax
  8008de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8008e1:	89 c2                	mov    %eax,%edx
  8008e3:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8008e6:	eb 03                	jmp    8008eb <memfind+0x13>
  8008e8:	83 c0 01             	add    $0x1,%eax
  8008eb:	39 d0                	cmp    %edx,%eax
  8008ed:	73 04                	jae    8008f3 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8008ef:	38 08                	cmp    %cl,(%eax)
  8008f1:	75 f5                	jne    8008e8 <memfind+0x10>
			break;
	return (void *) s;
}
  8008f3:	5d                   	pop    %ebp
  8008f4:	c3                   	ret    

008008f5 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
  8008f8:	57                   	push   %edi
  8008f9:	56                   	push   %esi
  8008fa:	53                   	push   %ebx
  8008fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8008fe:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800901:	eb 03                	jmp    800906 <strtol+0x11>
		s++;
  800903:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800906:	0f b6 02             	movzbl (%edx),%eax
  800909:	3c 20                	cmp    $0x20,%al
  80090b:	74 f6                	je     800903 <strtol+0xe>
  80090d:	3c 09                	cmp    $0x9,%al
  80090f:	74 f2                	je     800903 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800911:	3c 2b                	cmp    $0x2b,%al
  800913:	74 2a                	je     80093f <strtol+0x4a>
	int neg = 0;
  800915:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  80091a:	3c 2d                	cmp    $0x2d,%al
  80091c:	74 2b                	je     800949 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80091e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800924:	75 0f                	jne    800935 <strtol+0x40>
  800926:	80 3a 30             	cmpb   $0x30,(%edx)
  800929:	74 28                	je     800953 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80092b:	85 db                	test   %ebx,%ebx
  80092d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800932:	0f 44 d8             	cmove  %eax,%ebx
  800935:	b9 00 00 00 00       	mov    $0x0,%ecx
  80093a:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80093d:	eb 46                	jmp    800985 <strtol+0x90>
		s++;
  80093f:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800942:	bf 00 00 00 00       	mov    $0x0,%edi
  800947:	eb d5                	jmp    80091e <strtol+0x29>
		s++, neg = 1;
  800949:	83 c2 01             	add    $0x1,%edx
  80094c:	bf 01 00 00 00       	mov    $0x1,%edi
  800951:	eb cb                	jmp    80091e <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800953:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800957:	74 0e                	je     800967 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800959:	85 db                	test   %ebx,%ebx
  80095b:	75 d8                	jne    800935 <strtol+0x40>
		s++, base = 8;
  80095d:	83 c2 01             	add    $0x1,%edx
  800960:	bb 08 00 00 00       	mov    $0x8,%ebx
  800965:	eb ce                	jmp    800935 <strtol+0x40>
		s += 2, base = 16;
  800967:	83 c2 02             	add    $0x2,%edx
  80096a:	bb 10 00 00 00       	mov    $0x10,%ebx
  80096f:	eb c4                	jmp    800935 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800971:	0f be c0             	movsbl %al,%eax
  800974:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800977:	3b 45 10             	cmp    0x10(%ebp),%eax
  80097a:	7d 3a                	jge    8009b6 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  80097c:	83 c2 01             	add    $0x1,%edx
  80097f:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800983:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800985:	0f b6 02             	movzbl (%edx),%eax
  800988:	8d 70 d0             	lea    -0x30(%eax),%esi
  80098b:	89 f3                	mov    %esi,%ebx
  80098d:	80 fb 09             	cmp    $0x9,%bl
  800990:	76 df                	jbe    800971 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800992:	8d 70 9f             	lea    -0x61(%eax),%esi
  800995:	89 f3                	mov    %esi,%ebx
  800997:	80 fb 19             	cmp    $0x19,%bl
  80099a:	77 08                	ja     8009a4 <strtol+0xaf>
			dig = *s - 'a' + 10;
  80099c:	0f be c0             	movsbl %al,%eax
  80099f:	83 e8 57             	sub    $0x57,%eax
  8009a2:	eb d3                	jmp    800977 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  8009a4:	8d 70 bf             	lea    -0x41(%eax),%esi
  8009a7:	89 f3                	mov    %esi,%ebx
  8009a9:	80 fb 19             	cmp    $0x19,%bl
  8009ac:	77 08                	ja     8009b6 <strtol+0xc1>
			dig = *s - 'A' + 10;
  8009ae:	0f be c0             	movsbl %al,%eax
  8009b1:	83 e8 37             	sub    $0x37,%eax
  8009b4:	eb c1                	jmp    800977 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  8009b6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8009ba:	74 05                	je     8009c1 <strtol+0xcc>
		*endptr = (char *) s;
  8009bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009bf:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  8009c1:	89 c8                	mov    %ecx,%eax
  8009c3:	f7 d8                	neg    %eax
  8009c5:	85 ff                	test   %edi,%edi
  8009c7:	0f 45 c8             	cmovne %eax,%ecx
}
  8009ca:	89 c8                	mov    %ecx,%eax
  8009cc:	5b                   	pop    %ebx
  8009cd:	5e                   	pop    %esi
  8009ce:	5f                   	pop    %edi
  8009cf:	5d                   	pop    %ebp
  8009d0:	c3                   	ret    

008009d1 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8009d1:	55                   	push   %ebp
  8009d2:	89 e5                	mov    %esp,%ebp
  8009d4:	57                   	push   %edi
  8009d5:	56                   	push   %esi
  8009d6:	53                   	push   %ebx
  8009d7:	83 ec 1c             	sub    $0x1c,%esp
  8009da:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009dd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8009e0:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile(
  8009e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009e8:	8b 7d 10             	mov    0x10(%ebp),%edi
  8009eb:	8b 75 14             	mov    0x14(%ebp),%esi
  8009ee:	cd 30                	int    $0x30
	        "int %1\n"
	        : "=a"(ret)
	        : "i"(T_SYSCALL), "a"(num), "d"(a1), "c"(a2), "b"(a3), "D"(a4), "S"(a5)
	        : "cc", "memory");

	if (check && ret > 0)
  8009f0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8009f4:	74 04                	je     8009fa <syscall+0x29>
  8009f6:	85 c0                	test   %eax,%eax
  8009f8:	7f 08                	jg     800a02 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  8009fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009fd:	5b                   	pop    %ebx
  8009fe:	5e                   	pop    %esi
  8009ff:	5f                   	pop    %edi
  800a00:	5d                   	pop    %ebp
  800a01:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800a02:	83 ec 0c             	sub    $0xc,%esp
  800a05:	50                   	push   %eax
  800a06:	ff 75 e0             	push   -0x20(%ebp)
  800a09:	68 04 11 80 00       	push   $0x801104
  800a0e:	6a 1e                	push   $0x1e
  800a10:	68 21 11 80 00       	push   $0x801121
  800a15:	e8 f7 01 00 00       	call   800c11 <_panic>

00800a1a <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800a1a:	55                   	push   %ebp
  800a1b:	89 e5                	mov    %esp,%ebp
  800a1d:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t) s, len, 0, 0, 0);
  800a20:	6a 00                	push   $0x0
  800a22:	6a 00                	push   $0x0
  800a24:	6a 00                	push   $0x0
  800a26:	ff 75 0c             	push   0xc(%ebp)
  800a29:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a2c:	ba 00 00 00 00       	mov    $0x0,%edx
  800a31:	b8 00 00 00 00       	mov    $0x0,%eax
  800a36:	e8 96 ff ff ff       	call   8009d1 <syscall>
}
  800a3b:	83 c4 10             	add    $0x10,%esp
  800a3e:	c9                   	leave  
  800a3f:	c3                   	ret    

00800a40 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a40:	55                   	push   %ebp
  800a41:	89 e5                	mov    %esp,%ebp
  800a43:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800a46:	6a 00                	push   $0x0
  800a48:	6a 00                	push   $0x0
  800a4a:	6a 00                	push   $0x0
  800a4c:	6a 00                	push   $0x0
  800a4e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a53:	ba 00 00 00 00       	mov    $0x0,%edx
  800a58:	b8 01 00 00 00       	mov    $0x1,%eax
  800a5d:	e8 6f ff ff ff       	call   8009d1 <syscall>
}
  800a62:	c9                   	leave  
  800a63:	c3                   	ret    

00800a64 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a64:	55                   	push   %ebp
  800a65:	89 e5                	mov    %esp,%ebp
  800a67:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800a6a:	6a 00                	push   $0x0
  800a6c:	6a 00                	push   $0x0
  800a6e:	6a 00                	push   $0x0
  800a70:	6a 00                	push   $0x0
  800a72:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a75:	ba 01 00 00 00       	mov    $0x1,%edx
  800a7a:	b8 03 00 00 00       	mov    $0x3,%eax
  800a7f:	e8 4d ff ff ff       	call   8009d1 <syscall>
}
  800a84:	c9                   	leave  
  800a85:	c3                   	ret    

00800a86 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800a86:	55                   	push   %ebp
  800a87:	89 e5                	mov    %esp,%ebp
  800a89:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800a8c:	6a 00                	push   $0x0
  800a8e:	6a 00                	push   $0x0
  800a90:	6a 00                	push   $0x0
  800a92:	6a 00                	push   $0x0
  800a94:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a99:	ba 00 00 00 00       	mov    $0x0,%edx
  800a9e:	b8 02 00 00 00       	mov    $0x2,%eax
  800aa3:	e8 29 ff ff ff       	call   8009d1 <syscall>
}
  800aa8:	c9                   	leave  
  800aa9:	c3                   	ret    

00800aaa <sys_yield>:

void
sys_yield(void)
{
  800aaa:	55                   	push   %ebp
  800aab:	89 e5                	mov    %esp,%ebp
  800aad:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800ab0:	6a 00                	push   $0x0
  800ab2:	6a 00                	push   $0x0
  800ab4:	6a 00                	push   $0x0
  800ab6:	6a 00                	push   $0x0
  800ab8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800abd:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ac7:	e8 05 ff ff ff       	call   8009d1 <syscall>
}
  800acc:	83 c4 10             	add    $0x10,%esp
  800acf:	c9                   	leave  
  800ad0:	c3                   	ret    

00800ad1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ad1:	55                   	push   %ebp
  800ad2:	89 e5                	mov    %esp,%ebp
  800ad4:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800ad7:	6a 00                	push   $0x0
  800ad9:	6a 00                	push   $0x0
  800adb:	ff 75 10             	push   0x10(%ebp)
  800ade:	ff 75 0c             	push   0xc(%ebp)
  800ae1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ae4:	ba 01 00 00 00       	mov    $0x1,%edx
  800ae9:	b8 04 00 00 00       	mov    $0x4,%eax
  800aee:	e8 de fe ff ff       	call   8009d1 <syscall>
}
  800af3:	c9                   	leave  
  800af4:	c3                   	ret    

00800af5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800af5:	55                   	push   %ebp
  800af6:	89 e5                	mov    %esp,%ebp
  800af8:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map,
  800afb:	ff 75 18             	push   0x18(%ebp)
  800afe:	ff 75 14             	push   0x14(%ebp)
  800b01:	ff 75 10             	push   0x10(%ebp)
  800b04:	ff 75 0c             	push   0xc(%ebp)
  800b07:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b0a:	ba 01 00 00 00       	mov    $0x1,%edx
  800b0f:	b8 05 00 00 00       	mov    $0x5,%eax
  800b14:	e8 b8 fe ff ff       	call   8009d1 <syscall>
	               srcenv,
	               (uint32_t) srcva,
	               dstenv,
	               (uint32_t) dstva,
	               perm);
}
  800b19:	c9                   	leave  
  800b1a:	c3                   	ret    

00800b1b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b1b:	55                   	push   %ebp
  800b1c:	89 e5                	mov    %esp,%ebp
  800b1e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800b21:	6a 00                	push   $0x0
  800b23:	6a 00                	push   $0x0
  800b25:	6a 00                	push   $0x0
  800b27:	ff 75 0c             	push   0xc(%ebp)
  800b2a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b2d:	ba 01 00 00 00       	mov    $0x1,%edx
  800b32:	b8 06 00 00 00       	mov    $0x6,%eax
  800b37:	e8 95 fe ff ff       	call   8009d1 <syscall>
}
  800b3c:	c9                   	leave  
  800b3d:	c3                   	ret    

00800b3e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800b3e:	55                   	push   %ebp
  800b3f:	89 e5                	mov    %esp,%ebp
  800b41:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800b44:	6a 00                	push   $0x0
  800b46:	6a 00                	push   $0x0
  800b48:	6a 00                	push   $0x0
  800b4a:	ff 75 0c             	push   0xc(%ebp)
  800b4d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b50:	ba 01 00 00 00       	mov    $0x1,%edx
  800b55:	b8 08 00 00 00       	mov    $0x8,%eax
  800b5a:	e8 72 fe ff ff       	call   8009d1 <syscall>
}
  800b5f:	c9                   	leave  
  800b60:	c3                   	ret    

00800b61 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800b61:	55                   	push   %ebp
  800b62:	89 e5                	mov    %esp,%ebp
  800b64:	83 ec 08             	sub    $0x8,%esp
	return syscall(
  800b67:	6a 00                	push   $0x0
  800b69:	6a 00                	push   $0x0
  800b6b:	6a 00                	push   $0x0
  800b6d:	ff 75 0c             	push   0xc(%ebp)
  800b70:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b73:	ba 01 00 00 00       	mov    $0x1,%edx
  800b78:	b8 09 00 00 00       	mov    $0x9,%eax
  800b7d:	e8 4f fe ff ff       	call   8009d1 <syscall>
	        SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800b82:	c9                   	leave  
  800b83:	c3                   	ret    

00800b84 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800b84:	55                   	push   %ebp
  800b85:	89 e5                	mov    %esp,%ebp
  800b87:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800b8a:	6a 00                	push   $0x0
  800b8c:	ff 75 14             	push   0x14(%ebp)
  800b8f:	ff 75 10             	push   0x10(%ebp)
  800b92:	ff 75 0c             	push   0xc(%ebp)
  800b95:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b98:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ba2:	e8 2a fe ff ff       	call   8009d1 <syscall>
}
  800ba7:	c9                   	leave  
  800ba8:	c3                   	ret    

00800ba9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ba9:	55                   	push   %ebp
  800baa:	89 e5                	mov    %esp,%ebp
  800bac:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t) dstva, 0, 0, 0, 0);
  800baf:	6a 00                	push   $0x0
  800bb1:	6a 00                	push   $0x0
  800bb3:	6a 00                	push   $0x0
  800bb5:	6a 00                	push   $0x0
  800bb7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bba:	ba 01 00 00 00       	mov    $0x1,%edx
  800bbf:	b8 0c 00 00 00       	mov    $0xc,%eax
  800bc4:	e8 08 fe ff ff       	call   8009d1 <syscall>
}
  800bc9:	c9                   	leave  
  800bca:	c3                   	ret    

00800bcb <sys_get_priority>:

// Get priority of the current process
int
sys_get_priority(void)
{
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_get_priority, 0, 0, 0, 0, 0, 0);
  800bd1:	6a 00                	push   $0x0
  800bd3:	6a 00                	push   $0x0
  800bd5:	6a 00                	push   $0x0
  800bd7:	6a 00                	push   $0x0
  800bd9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bde:	ba 00 00 00 00       	mov    $0x0,%edx
  800be3:	b8 0d 00 00 00       	mov    $0xd,%eax
  800be8:	e8 e4 fd ff ff       	call   8009d1 <syscall>
}
  800bed:	c9                   	leave  
  800bee:	c3                   	ret    

00800bef <sys_set_priority>:

// Get priority of the current process
int
sys_set_priority(unsigned int priority)
{
  800bef:	55                   	push   %ebp
  800bf0:	89 e5                	mov    %esp,%ebp
  800bf2:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, (uint32_t) priority, 0, 0, 0, 0);
  800bf5:	6a 00                	push   $0x0
  800bf7:	6a 00                	push   $0x0
  800bf9:	6a 00                	push   $0x0
  800bfb:	6a 00                	push   $0x0
  800bfd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c00:	ba 00 00 00 00       	mov    $0x0,%edx
  800c05:	b8 0e 00 00 00       	mov    $0xe,%eax
  800c0a:	e8 c2 fd ff ff       	call   8009d1 <syscall>
}
  800c0f:	c9                   	leave  
  800c10:	c3                   	ret    

00800c11 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800c11:	55                   	push   %ebp
  800c12:	89 e5                	mov    %esp,%ebp
  800c14:	56                   	push   %esi
  800c15:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800c16:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800c19:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800c1f:	e8 62 fe ff ff       	call   800a86 <sys_getenvid>
  800c24:	83 ec 0c             	sub    $0xc,%esp
  800c27:	ff 75 0c             	push   0xc(%ebp)
  800c2a:	ff 75 08             	push   0x8(%ebp)
  800c2d:	56                   	push   %esi
  800c2e:	50                   	push   %eax
  800c2f:	68 30 11 80 00       	push   $0x801130
  800c34:	e8 1b f5 ff ff       	call   800154 <cprintf>
	        sys_getenvid(),
	        binaryname,
	        file,
	        line);
	vcprintf(fmt, ap);
  800c39:	83 c4 18             	add    $0x18,%esp
  800c3c:	53                   	push   %ebx
  800c3d:	ff 75 10             	push   0x10(%ebp)
  800c40:	e8 be f4 ff ff       	call   800103 <vcprintf>
	cprintf("\n");
  800c45:	c7 04 24 ac 0e 80 00 	movl   $0x800eac,(%esp)
  800c4c:	e8 03 f5 ff ff       	call   800154 <cprintf>
  800c51:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800c54:	cc                   	int3   
  800c55:	eb fd                	jmp    800c54 <_panic+0x43>
  800c57:	66 90                	xchg   %ax,%ax
  800c59:	66 90                	xchg   %ax,%ax
  800c5b:	66 90                	xchg   %ax,%ax
  800c5d:	66 90                	xchg   %ax,%ax
  800c5f:	90                   	nop

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
