
obj/user/hello:     formato del fichero elf32-i386


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
  80002c:	e8 2d 00 00 00       	call   80005e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	cprintf("hello, world\n");
  800039:	68 a0 0e 80 00       	push   $0x800ea0
  80003e:	e8 0f 01 00 00       	call   800152 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800043:	a1 04 20 80 00       	mov    0x802004,%eax
  800048:	8b 40 48             	mov    0x48(%eax),%eax
  80004b:	83 c4 08             	add    $0x8,%esp
  80004e:	50                   	push   %eax
  80004f:	68 ae 0e 80 00       	push   $0x800eae
  800054:	e8 f9 00 00 00       	call   800152 <cprintf>
}
  800059:	83 c4 10             	add    $0x10,%esp
  80005c:	c9                   	leave  
  80005d:	c3                   	ret    

0080005e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005e:	55                   	push   %ebp
  80005f:	89 e5                	mov    %esp,%ebp
  800061:	56                   	push   %esi
  800062:	53                   	push   %ebx
  800063:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800066:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	envid_t id = sys_getenvid();
  800069:	e8 16 0a 00 00       	call   800a84 <sys_getenvid>
	if (id >= 0)
  80006e:	85 c0                	test   %eax,%eax
  800070:	78 15                	js     800087 <libmain+0x29>
		thisenv = &envs[ENVX(id)];
  800072:	25 ff 03 00 00       	and    $0x3ff,%eax
  800077:	69 c0 88 00 00 00    	imul   $0x88,%eax,%eax
  80007d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800082:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800087:	85 db                	test   %ebx,%ebx
  800089:	7e 07                	jle    800092 <libmain+0x34>
		binaryname = argv[0];
  80008b:	8b 06                	mov    (%esi),%eax
  80008d:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800092:	83 ec 08             	sub    $0x8,%esp
  800095:	56                   	push   %esi
  800096:	53                   	push   %ebx
  800097:	e8 97 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80009c:	e8 0a 00 00 00       	call   8000ab <exit>
}
  8000a1:	83 c4 10             	add    $0x10,%esp
  8000a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a7:	5b                   	pop    %ebx
  8000a8:	5e                   	pop    %esi
  8000a9:	5d                   	pop    %ebp
  8000aa:	c3                   	ret    

008000ab <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ab:	55                   	push   %ebp
  8000ac:	89 e5                	mov    %esp,%ebp
  8000ae:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000b1:	6a 00                	push   $0x0
  8000b3:	e8 aa 09 00 00       	call   800a62 <sys_env_destroy>
}
  8000b8:	83 c4 10             	add    $0x10,%esp
  8000bb:	c9                   	leave  
  8000bc:	c3                   	ret    

008000bd <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000bd:	55                   	push   %ebp
  8000be:	89 e5                	mov    %esp,%ebp
  8000c0:	53                   	push   %ebx
  8000c1:	83 ec 04             	sub    $0x4,%esp
  8000c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c7:	8b 13                	mov    (%ebx),%edx
  8000c9:	8d 42 01             	lea    0x1(%edx),%eax
  8000cc:	89 03                	mov    %eax,(%ebx)
  8000ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256 - 1) {
  8000d5:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000da:	74 09                	je     8000e5 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000dc:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000e3:	c9                   	leave  
  8000e4:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8000e5:	83 ec 08             	sub    $0x8,%esp
  8000e8:	68 ff 00 00 00       	push   $0xff
  8000ed:	8d 43 08             	lea    0x8(%ebx),%eax
  8000f0:	50                   	push   %eax
  8000f1:	e8 22 09 00 00       	call   800a18 <sys_cputs>
		b->idx = 0;
  8000f6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000fc:	83 c4 10             	add    $0x10,%esp
  8000ff:	eb db                	jmp    8000dc <putch+0x1f>

00800101 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800101:	55                   	push   %ebp
  800102:	89 e5                	mov    %esp,%ebp
  800104:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80010a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800111:	00 00 00 
	b.cnt = 0;
  800114:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80011b:	00 00 00 
	vprintfmt((void *) putch, &b, fmt, ap);
  80011e:	ff 75 0c             	push   0xc(%ebp)
  800121:	ff 75 08             	push   0x8(%ebp)
  800124:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80012a:	50                   	push   %eax
  80012b:	68 bd 00 80 00       	push   $0x8000bd
  800130:	e8 74 01 00 00       	call   8002a9 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800135:	83 c4 08             	add    $0x8,%esp
  800138:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  80013e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800144:	50                   	push   %eax
  800145:	e8 ce 08 00 00       	call   800a18 <sys_cputs>

	return b.cnt;
}
  80014a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800150:	c9                   	leave  
  800151:	c3                   	ret    

00800152 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800152:	55                   	push   %ebp
  800153:	89 e5                	mov    %esp,%ebp
  800155:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800158:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80015b:	50                   	push   %eax
  80015c:	ff 75 08             	push   0x8(%ebp)
  80015f:	e8 9d ff ff ff       	call   800101 <vcprintf>
	va_end(ap);

	return cnt;
}
  800164:	c9                   	leave  
  800165:	c3                   	ret    

00800166 <printnum>:
         void *putdat,
         unsigned long long num,
         unsigned base,
         int width,
         int padc)
{
  800166:	55                   	push   %ebp
  800167:	89 e5                	mov    %esp,%ebp
  800169:	57                   	push   %edi
  80016a:	56                   	push   %esi
  80016b:	53                   	push   %ebx
  80016c:	83 ec 1c             	sub    $0x1c,%esp
  80016f:	89 c7                	mov    %eax,%edi
  800171:	89 d6                	mov    %edx,%esi
  800173:	8b 45 08             	mov    0x8(%ebp),%eax
  800176:	8b 55 0c             	mov    0xc(%ebp),%edx
  800179:	89 d1                	mov    %edx,%ecx
  80017b:	89 c2                	mov    %eax,%edx
  80017d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800180:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800183:	8b 45 10             	mov    0x10(%ebp),%eax
  800186:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800189:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80018c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800193:	39 c2                	cmp    %eax,%edx
  800195:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800198:	72 3e                	jb     8001d8 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80019a:	83 ec 0c             	sub    $0xc,%esp
  80019d:	ff 75 18             	push   0x18(%ebp)
  8001a0:	83 eb 01             	sub    $0x1,%ebx
  8001a3:	53                   	push   %ebx
  8001a4:	50                   	push   %eax
  8001a5:	83 ec 08             	sub    $0x8,%esp
  8001a8:	ff 75 e4             	push   -0x1c(%ebp)
  8001ab:	ff 75 e0             	push   -0x20(%ebp)
  8001ae:	ff 75 dc             	push   -0x24(%ebp)
  8001b1:	ff 75 d8             	push   -0x28(%ebp)
  8001b4:	e8 a7 0a 00 00       	call   800c60 <__udivdi3>
  8001b9:	83 c4 18             	add    $0x18,%esp
  8001bc:	52                   	push   %edx
  8001bd:	50                   	push   %eax
  8001be:	89 f2                	mov    %esi,%edx
  8001c0:	89 f8                	mov    %edi,%eax
  8001c2:	e8 9f ff ff ff       	call   800166 <printnum>
  8001c7:	83 c4 20             	add    $0x20,%esp
  8001ca:	eb 13                	jmp    8001df <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001cc:	83 ec 08             	sub    $0x8,%esp
  8001cf:	56                   	push   %esi
  8001d0:	ff 75 18             	push   0x18(%ebp)
  8001d3:	ff d7                	call   *%edi
  8001d5:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001d8:	83 eb 01             	sub    $0x1,%ebx
  8001db:	85 db                	test   %ebx,%ebx
  8001dd:	7f ed                	jg     8001cc <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001df:	83 ec 08             	sub    $0x8,%esp
  8001e2:	56                   	push   %esi
  8001e3:	83 ec 04             	sub    $0x4,%esp
  8001e6:	ff 75 e4             	push   -0x1c(%ebp)
  8001e9:	ff 75 e0             	push   -0x20(%ebp)
  8001ec:	ff 75 dc             	push   -0x24(%ebp)
  8001ef:	ff 75 d8             	push   -0x28(%ebp)
  8001f2:	e8 89 0b 00 00       	call   800d80 <__umoddi3>
  8001f7:	83 c4 14             	add    $0x14,%esp
  8001fa:	0f be 80 cf 0e 80 00 	movsbl 0x800ecf(%eax),%eax
  800201:	50                   	push   %eax
  800202:	ff d7                	call   *%edi
}
  800204:	83 c4 10             	add    $0x10,%esp
  800207:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020a:	5b                   	pop    %ebx
  80020b:	5e                   	pop    %esi
  80020c:	5f                   	pop    %edi
  80020d:	5d                   	pop    %ebp
  80020e:	c3                   	ret    

0080020f <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80020f:	83 fa 01             	cmp    $0x1,%edx
  800212:	7f 13                	jg     800227 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800214:	85 d2                	test   %edx,%edx
  800216:	74 1c                	je     800234 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  800218:	8b 10                	mov    (%eax),%edx
  80021a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80021d:	89 08                	mov    %ecx,(%eax)
  80021f:	8b 02                	mov    (%edx),%eax
  800221:	ba 00 00 00 00       	mov    $0x0,%edx
  800226:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  800227:	8b 10                	mov    (%eax),%edx
  800229:	8d 4a 08             	lea    0x8(%edx),%ecx
  80022c:	89 08                	mov    %ecx,(%eax)
  80022e:	8b 02                	mov    (%edx),%eax
  800230:	8b 52 04             	mov    0x4(%edx),%edx
  800233:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  800234:	8b 10                	mov    (%eax),%edx
  800236:	8d 4a 04             	lea    0x4(%edx),%ecx
  800239:	89 08                	mov    %ecx,(%eax)
  80023b:	8b 02                	mov    (%edx),%eax
  80023d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800242:	c3                   	ret    

00800243 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800243:	83 fa 01             	cmp    $0x1,%edx
  800246:	7f 0f                	jg     800257 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  800248:	85 d2                	test   %edx,%edx
  80024a:	74 18                	je     800264 <getint+0x21>
		return va_arg(*ap, long);
  80024c:	8b 10                	mov    (%eax),%edx
  80024e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800251:	89 08                	mov    %ecx,(%eax)
  800253:	8b 02                	mov    (%edx),%eax
  800255:	99                   	cltd   
  800256:	c3                   	ret    
		return va_arg(*ap, long long);
  800257:	8b 10                	mov    (%eax),%edx
  800259:	8d 4a 08             	lea    0x8(%edx),%ecx
  80025c:	89 08                	mov    %ecx,(%eax)
  80025e:	8b 02                	mov    (%edx),%eax
  800260:	8b 52 04             	mov    0x4(%edx),%edx
  800263:	c3                   	ret    
	else
		return va_arg(*ap, int);
  800264:	8b 10                	mov    (%eax),%edx
  800266:	8d 4a 04             	lea    0x4(%edx),%ecx
  800269:	89 08                	mov    %ecx,(%eax)
  80026b:	8b 02                	mov    (%edx),%eax
  80026d:	99                   	cltd   
}
  80026e:	c3                   	ret    

0080026f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80026f:	55                   	push   %ebp
  800270:	89 e5                	mov    %esp,%ebp
  800272:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800275:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800279:	8b 10                	mov    (%eax),%edx
  80027b:	3b 50 04             	cmp    0x4(%eax),%edx
  80027e:	73 0a                	jae    80028a <sprintputch+0x1b>
		*b->buf++ = ch;
  800280:	8d 4a 01             	lea    0x1(%edx),%ecx
  800283:	89 08                	mov    %ecx,(%eax)
  800285:	8b 45 08             	mov    0x8(%ebp),%eax
  800288:	88 02                	mov    %al,(%edx)
}
  80028a:	5d                   	pop    %ebp
  80028b:	c3                   	ret    

0080028c <printfmt>:
{
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800292:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800295:	50                   	push   %eax
  800296:	ff 75 10             	push   0x10(%ebp)
  800299:	ff 75 0c             	push   0xc(%ebp)
  80029c:	ff 75 08             	push   0x8(%ebp)
  80029f:	e8 05 00 00 00       	call   8002a9 <vprintfmt>
}
  8002a4:	83 c4 10             	add    $0x10,%esp
  8002a7:	c9                   	leave  
  8002a8:	c3                   	ret    

008002a9 <vprintfmt>:
{
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	57                   	push   %edi
  8002ad:	56                   	push   %esi
  8002ae:	53                   	push   %ebx
  8002af:	83 ec 2c             	sub    $0x2c,%esp
  8002b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002b5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8002b8:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002bb:	eb 0a                	jmp    8002c7 <vprintfmt+0x1e>
			putch(ch, putdat);
  8002bd:	83 ec 08             	sub    $0x8,%esp
  8002c0:	56                   	push   %esi
  8002c1:	50                   	push   %eax
  8002c2:	ff d3                	call   *%ebx
  8002c4:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002c7:	83 c7 01             	add    $0x1,%edi
  8002ca:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002ce:	83 f8 25             	cmp    $0x25,%eax
  8002d1:	74 0c                	je     8002df <vprintfmt+0x36>
			if (ch == '\0')
  8002d3:	85 c0                	test   %eax,%eax
  8002d5:	75 e6                	jne    8002bd <vprintfmt+0x14>
}
  8002d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002da:	5b                   	pop    %ebx
  8002db:	5e                   	pop    %esi
  8002dc:	5f                   	pop    %edi
  8002dd:	5d                   	pop    %ebp
  8002de:	c3                   	ret    
		padc = ' ';
  8002df:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
		altflag = 0;
  8002e3:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002ea:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002f1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002f8:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002fd:	8d 47 01             	lea    0x1(%edi),%eax
  800300:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800303:	0f b6 17             	movzbl (%edi),%edx
  800306:	8d 42 dd             	lea    -0x23(%edx),%eax
  800309:	3c 55                	cmp    $0x55,%al
  80030b:	0f 87 b7 02 00 00    	ja     8005c8 <vprintfmt+0x31f>
  800311:	0f b6 c0             	movzbl %al,%eax
  800314:	ff 24 85 a0 0f 80 00 	jmp    *0x800fa0(,%eax,4)
  80031b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80031e:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800322:	eb d9                	jmp    8002fd <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800324:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800327:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  80032b:	eb d0                	jmp    8002fd <vprintfmt+0x54>
  80032d:	0f b6 d2             	movzbl %dl,%edx
  800330:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0;; ++fmt) {
  800333:	b8 00 00 00 00       	mov    $0x0,%eax
  800338:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80033b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80033e:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800342:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800345:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800348:	83 f9 09             	cmp    $0x9,%ecx
  80034b:	77 52                	ja     80039f <vprintfmt+0xf6>
			for (precision = 0;; ++fmt) {
  80034d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800350:	eb e9                	jmp    80033b <vprintfmt+0x92>
			precision = va_arg(ap, int);
  800352:	8b 45 14             	mov    0x14(%ebp),%eax
  800355:	8d 50 04             	lea    0x4(%eax),%edx
  800358:	89 55 14             	mov    %edx,0x14(%ebp)
  80035b:	8b 00                	mov    (%eax),%eax
  80035d:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800360:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800363:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800367:	79 94                	jns    8002fd <vprintfmt+0x54>
				width = precision, precision = -1;
  800369:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80036c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80036f:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800376:	eb 85                	jmp    8002fd <vprintfmt+0x54>
  800378:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80037b:	85 d2                	test   %edx,%edx
  80037d:	b8 00 00 00 00       	mov    $0x0,%eax
  800382:	0f 49 c2             	cmovns %edx,%eax
  800385:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800388:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80038b:	e9 6d ff ff ff       	jmp    8002fd <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800390:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800393:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80039a:	e9 5e ff ff ff       	jmp    8002fd <vprintfmt+0x54>
  80039f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003a2:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003a5:	eb bc                	jmp    800363 <vprintfmt+0xba>
			lflag++;
  8003a7:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003ad:	e9 4b ff ff ff       	jmp    8002fd <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8003b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b5:	8d 50 04             	lea    0x4(%eax),%edx
  8003b8:	89 55 14             	mov    %edx,0x14(%ebp)
  8003bb:	83 ec 08             	sub    $0x8,%esp
  8003be:	56                   	push   %esi
  8003bf:	ff 30                	push   (%eax)
  8003c1:	ff d3                	call   *%ebx
			break;
  8003c3:	83 c4 10             	add    $0x10,%esp
  8003c6:	e9 94 01 00 00       	jmp    80055f <vprintfmt+0x2b6>
			err = va_arg(ap, int);
  8003cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ce:	8d 50 04             	lea    0x4(%eax),%edx
  8003d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d4:	8b 10                	mov    (%eax),%edx
  8003d6:	89 d0                	mov    %edx,%eax
  8003d8:	f7 d8                	neg    %eax
  8003da:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003dd:	83 f8 08             	cmp    $0x8,%eax
  8003e0:	7f 20                	jg     800402 <vprintfmt+0x159>
  8003e2:	8b 14 85 00 11 80 00 	mov    0x801100(,%eax,4),%edx
  8003e9:	85 d2                	test   %edx,%edx
  8003eb:	74 15                	je     800402 <vprintfmt+0x159>
				printfmt(putch, putdat, "%s", p);
  8003ed:	52                   	push   %edx
  8003ee:	68 f0 0e 80 00       	push   $0x800ef0
  8003f3:	56                   	push   %esi
  8003f4:	53                   	push   %ebx
  8003f5:	e8 92 fe ff ff       	call   80028c <printfmt>
  8003fa:	83 c4 10             	add    $0x10,%esp
  8003fd:	e9 5d 01 00 00       	jmp    80055f <vprintfmt+0x2b6>
				printfmt(putch, putdat, "error %d", err);
  800402:	50                   	push   %eax
  800403:	68 e7 0e 80 00       	push   $0x800ee7
  800408:	56                   	push   %esi
  800409:	53                   	push   %ebx
  80040a:	e8 7d fe ff ff       	call   80028c <printfmt>
  80040f:	83 c4 10             	add    $0x10,%esp
  800412:	e9 48 01 00 00       	jmp    80055f <vprintfmt+0x2b6>
			if ((p = va_arg(ap, char *)) == NULL)
  800417:	8b 45 14             	mov    0x14(%ebp),%eax
  80041a:	8d 50 04             	lea    0x4(%eax),%edx
  80041d:	89 55 14             	mov    %edx,0x14(%ebp)
  800420:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800422:	85 ff                	test   %edi,%edi
  800424:	b8 e0 0e 80 00       	mov    $0x800ee0,%eax
  800429:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80042c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800430:	7e 06                	jle    800438 <vprintfmt+0x18f>
  800432:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  800436:	75 0a                	jne    800442 <vprintfmt+0x199>
  800438:	89 f8                	mov    %edi,%eax
  80043a:	03 45 e0             	add    -0x20(%ebp),%eax
  80043d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800440:	eb 59                	jmp    80049b <vprintfmt+0x1f2>
				for (width -= strnlen(p, precision); width > 0;
  800442:	83 ec 08             	sub    $0x8,%esp
  800445:	ff 75 d8             	push   -0x28(%ebp)
  800448:	57                   	push   %edi
  800449:	e8 1a 02 00 00       	call   800668 <strnlen>
  80044e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800451:	29 c1                	sub    %eax,%ecx
  800453:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800456:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800459:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  80045d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800460:	89 7d d0             	mov    %edi,-0x30(%ebp)
  800463:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0;
  800465:	eb 0f                	jmp    800476 <vprintfmt+0x1cd>
					putch(padc, putdat);
  800467:	83 ec 08             	sub    $0x8,%esp
  80046a:	56                   	push   %esi
  80046b:	ff 75 e0             	push   -0x20(%ebp)
  80046e:	ff d3                	call   *%ebx
				     width--)
  800470:	83 ef 01             	sub    $0x1,%edi
  800473:	83 c4 10             	add    $0x10,%esp
				for (width -= strnlen(p, precision); width > 0;
  800476:	85 ff                	test   %edi,%edi
  800478:	7f ed                	jg     800467 <vprintfmt+0x1be>
  80047a:	8b 7d d0             	mov    -0x30(%ebp),%edi
  80047d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800480:	85 c9                	test   %ecx,%ecx
  800482:	b8 00 00 00 00       	mov    $0x0,%eax
  800487:	0f 49 c1             	cmovns %ecx,%eax
  80048a:	29 c1                	sub    %eax,%ecx
  80048c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80048f:	eb a7                	jmp    800438 <vprintfmt+0x18f>
					putch(ch, putdat);
  800491:	83 ec 08             	sub    $0x8,%esp
  800494:	56                   	push   %esi
  800495:	52                   	push   %edx
  800496:	ff d3                	call   *%ebx
  800498:	83 c4 10             	add    $0x10,%esp
  80049b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80049e:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' &&
  8004a0:	83 c7 01             	add    $0x1,%edi
  8004a3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004a7:	0f be d0             	movsbl %al,%edx
  8004aa:	85 d2                	test   %edx,%edx
  8004ac:	74 42                	je     8004f0 <vprintfmt+0x247>
  8004ae:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004b2:	78 06                	js     8004ba <vprintfmt+0x211>
			       (precision < 0 || --precision >= 0);
  8004b4:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004b8:	78 1e                	js     8004d8 <vprintfmt+0x22f>
				if (altflag && (ch < ' ' || ch > '~'))
  8004ba:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004be:	74 d1                	je     800491 <vprintfmt+0x1e8>
  8004c0:	0f be c0             	movsbl %al,%eax
  8004c3:	83 e8 20             	sub    $0x20,%eax
  8004c6:	83 f8 5e             	cmp    $0x5e,%eax
  8004c9:	76 c6                	jbe    800491 <vprintfmt+0x1e8>
					putch('?', putdat);
  8004cb:	83 ec 08             	sub    $0x8,%esp
  8004ce:	56                   	push   %esi
  8004cf:	6a 3f                	push   $0x3f
  8004d1:	ff d3                	call   *%ebx
  8004d3:	83 c4 10             	add    $0x10,%esp
  8004d6:	eb c3                	jmp    80049b <vprintfmt+0x1f2>
  8004d8:	89 cf                	mov    %ecx,%edi
  8004da:	eb 0e                	jmp    8004ea <vprintfmt+0x241>
				putch(' ', putdat);
  8004dc:	83 ec 08             	sub    $0x8,%esp
  8004df:	56                   	push   %esi
  8004e0:	6a 20                	push   $0x20
  8004e2:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  8004e4:	83 ef 01             	sub    $0x1,%edi
  8004e7:	83 c4 10             	add    $0x10,%esp
  8004ea:	85 ff                	test   %edi,%edi
  8004ec:	7f ee                	jg     8004dc <vprintfmt+0x233>
  8004ee:	eb 6f                	jmp    80055f <vprintfmt+0x2b6>
  8004f0:	89 cf                	mov    %ecx,%edi
  8004f2:	eb f6                	jmp    8004ea <vprintfmt+0x241>
			num = getint(&ap, lflag);
  8004f4:	89 ca                	mov    %ecx,%edx
  8004f6:	8d 45 14             	lea    0x14(%ebp),%eax
  8004f9:	e8 45 fd ff ff       	call   800243 <getint>
  8004fe:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800501:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800504:	85 d2                	test   %edx,%edx
  800506:	78 0b                	js     800513 <vprintfmt+0x26a>
			num = getint(&ap, lflag);
  800508:	89 d1                	mov    %edx,%ecx
  80050a:	89 c2                	mov    %eax,%edx
			base = 10;
  80050c:	bf 0a 00 00 00       	mov    $0xa,%edi
  800511:	eb 32                	jmp    800545 <vprintfmt+0x29c>
				putch('-', putdat);
  800513:	83 ec 08             	sub    $0x8,%esp
  800516:	56                   	push   %esi
  800517:	6a 2d                	push   $0x2d
  800519:	ff d3                	call   *%ebx
				num = -(long long) num;
  80051b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80051e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800521:	f7 da                	neg    %edx
  800523:	83 d1 00             	adc    $0x0,%ecx
  800526:	f7 d9                	neg    %ecx
  800528:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80052b:	bf 0a 00 00 00       	mov    $0xa,%edi
  800530:	eb 13                	jmp    800545 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  800532:	89 ca                	mov    %ecx,%edx
  800534:	8d 45 14             	lea    0x14(%ebp),%eax
  800537:	e8 d3 fc ff ff       	call   80020f <getuint>
  80053c:	89 d1                	mov    %edx,%ecx
  80053e:	89 c2                	mov    %eax,%edx
			base = 10;
  800540:	bf 0a 00 00 00       	mov    $0xa,%edi
			printnum(putch, putdat, num, base, width, padc);
  800545:	83 ec 0c             	sub    $0xc,%esp
  800548:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  80054c:	50                   	push   %eax
  80054d:	ff 75 e0             	push   -0x20(%ebp)
  800550:	57                   	push   %edi
  800551:	51                   	push   %ecx
  800552:	52                   	push   %edx
  800553:	89 f2                	mov    %esi,%edx
  800555:	89 d8                	mov    %ebx,%eax
  800557:	e8 0a fc ff ff       	call   800166 <printnum>
			break;
  80055c:	83 c4 20             	add    $0x20,%esp
{
  80055f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800562:	e9 60 fd ff ff       	jmp    8002c7 <vprintfmt+0x1e>
			num = getuint(&ap, lflag);
  800567:	89 ca                	mov    %ecx,%edx
  800569:	8d 45 14             	lea    0x14(%ebp),%eax
  80056c:	e8 9e fc ff ff       	call   80020f <getuint>
  800571:	89 d1                	mov    %edx,%ecx
  800573:	89 c2                	mov    %eax,%edx
			base = 8;
  800575:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  80057a:	eb c9                	jmp    800545 <vprintfmt+0x29c>
			putch('0', putdat);
  80057c:	83 ec 08             	sub    $0x8,%esp
  80057f:	56                   	push   %esi
  800580:	6a 30                	push   $0x30
  800582:	ff d3                	call   *%ebx
			putch('x', putdat);
  800584:	83 c4 08             	add    $0x8,%esp
  800587:	56                   	push   %esi
  800588:	6a 78                	push   $0x78
  80058a:	ff d3                	call   *%ebx
			num = (unsigned long long) (uintptr_t) va_arg(ap, void *);
  80058c:	8b 45 14             	mov    0x14(%ebp),%eax
  80058f:	8d 50 04             	lea    0x4(%eax),%edx
  800592:	89 55 14             	mov    %edx,0x14(%ebp)
  800595:	8b 10                	mov    (%eax),%edx
  800597:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80059c:	83 c4 10             	add    $0x10,%esp
			base = 16;
  80059f:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  8005a4:	eb 9f                	jmp    800545 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  8005a6:	89 ca                	mov    %ecx,%edx
  8005a8:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ab:	e8 5f fc ff ff       	call   80020f <getuint>
  8005b0:	89 d1                	mov    %edx,%ecx
  8005b2:	89 c2                	mov    %eax,%edx
			base = 16;
  8005b4:	bf 10 00 00 00       	mov    $0x10,%edi
  8005b9:	eb 8a                	jmp    800545 <vprintfmt+0x29c>
			putch(ch, putdat);
  8005bb:	83 ec 08             	sub    $0x8,%esp
  8005be:	56                   	push   %esi
  8005bf:	6a 25                	push   $0x25
  8005c1:	ff d3                	call   *%ebx
			break;
  8005c3:	83 c4 10             	add    $0x10,%esp
  8005c6:	eb 97                	jmp    80055f <vprintfmt+0x2b6>
			putch('%', putdat);
  8005c8:	83 ec 08             	sub    $0x8,%esp
  8005cb:	56                   	push   %esi
  8005cc:	6a 25                	push   $0x25
  8005ce:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  8005d0:	83 c4 10             	add    $0x10,%esp
  8005d3:	89 f8                	mov    %edi,%eax
  8005d5:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8005d9:	74 05                	je     8005e0 <vprintfmt+0x337>
  8005db:	83 e8 01             	sub    $0x1,%eax
  8005de:	eb f5                	jmp    8005d5 <vprintfmt+0x32c>
  8005e0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005e3:	e9 77 ff ff ff       	jmp    80055f <vprintfmt+0x2b6>

008005e8 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8005e8:	55                   	push   %ebp
  8005e9:	89 e5                	mov    %esp,%ebp
  8005eb:	83 ec 18             	sub    $0x18,%esp
  8005ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8005f1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = { buf, buf + n - 1, 0 };
  8005f4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8005f7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8005fb:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8005fe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800605:	85 c0                	test   %eax,%eax
  800607:	74 26                	je     80062f <vsnprintf+0x47>
  800609:	85 d2                	test   %edx,%edx
  80060b:	7e 22                	jle    80062f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *) sprintputch, &b, fmt, ap);
  80060d:	ff 75 14             	push   0x14(%ebp)
  800610:	ff 75 10             	push   0x10(%ebp)
  800613:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800616:	50                   	push   %eax
  800617:	68 6f 02 80 00       	push   $0x80026f
  80061c:	e8 88 fc ff ff       	call   8002a9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800621:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800624:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800627:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80062a:	83 c4 10             	add    $0x10,%esp
}
  80062d:	c9                   	leave  
  80062e:	c3                   	ret    
		return -E_INVAL;
  80062f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800634:	eb f7                	jmp    80062d <vsnprintf+0x45>

00800636 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800636:	55                   	push   %ebp
  800637:	89 e5                	mov    %esp,%ebp
  800639:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80063c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80063f:	50                   	push   %eax
  800640:	ff 75 10             	push   0x10(%ebp)
  800643:	ff 75 0c             	push   0xc(%ebp)
  800646:	ff 75 08             	push   0x8(%ebp)
  800649:	e8 9a ff ff ff       	call   8005e8 <vsnprintf>
	va_end(ap);

	return rc;
}
  80064e:	c9                   	leave  
  80064f:	c3                   	ret    

00800650 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800650:	55                   	push   %ebp
  800651:	89 e5                	mov    %esp,%ebp
  800653:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800656:	b8 00 00 00 00       	mov    $0x0,%eax
  80065b:	eb 03                	jmp    800660 <strlen+0x10>
		n++;
  80065d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800660:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800664:	75 f7                	jne    80065d <strlen+0xd>
	return n;
}
  800666:	5d                   	pop    %ebp
  800667:	c3                   	ret    

00800668 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800668:	55                   	push   %ebp
  800669:	89 e5                	mov    %esp,%ebp
  80066b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80066e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800671:	b8 00 00 00 00       	mov    $0x0,%eax
  800676:	eb 03                	jmp    80067b <strnlen+0x13>
		n++;
  800678:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80067b:	39 d0                	cmp    %edx,%eax
  80067d:	74 08                	je     800687 <strnlen+0x1f>
  80067f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800683:	75 f3                	jne    800678 <strnlen+0x10>
  800685:	89 c2                	mov    %eax,%edx
	return n;
}
  800687:	89 d0                	mov    %edx,%eax
  800689:	5d                   	pop    %ebp
  80068a:	c3                   	ret    

0080068b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80068b:	55                   	push   %ebp
  80068c:	89 e5                	mov    %esp,%ebp
  80068e:	53                   	push   %ebx
  80068f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800692:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800695:	b8 00 00 00 00       	mov    $0x0,%eax
  80069a:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80069e:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8006a1:	83 c0 01             	add    $0x1,%eax
  8006a4:	84 d2                	test   %dl,%dl
  8006a6:	75 f2                	jne    80069a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8006a8:	89 c8                	mov    %ecx,%eax
  8006aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006ad:	c9                   	leave  
  8006ae:	c3                   	ret    

008006af <strcat>:

char *
strcat(char *dst, const char *src)
{
  8006af:	55                   	push   %ebp
  8006b0:	89 e5                	mov    %esp,%ebp
  8006b2:	53                   	push   %ebx
  8006b3:	83 ec 10             	sub    $0x10,%esp
  8006b6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8006b9:	53                   	push   %ebx
  8006ba:	e8 91 ff ff ff       	call   800650 <strlen>
  8006bf:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8006c2:	ff 75 0c             	push   0xc(%ebp)
  8006c5:	01 d8                	add    %ebx,%eax
  8006c7:	50                   	push   %eax
  8006c8:	e8 be ff ff ff       	call   80068b <strcpy>
	return dst;
}
  8006cd:	89 d8                	mov    %ebx,%eax
  8006cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006d2:	c9                   	leave  
  8006d3:	c3                   	ret    

008006d4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size)
{
  8006d4:	55                   	push   %ebp
  8006d5:	89 e5                	mov    %esp,%ebp
  8006d7:	56                   	push   %esi
  8006d8:	53                   	push   %ebx
  8006d9:	8b 75 08             	mov    0x8(%ebp),%esi
  8006dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006df:	89 f3                	mov    %esi,%ebx
  8006e1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8006e4:	89 f0                	mov    %esi,%eax
  8006e6:	eb 0f                	jmp    8006f7 <strncpy+0x23>
		*dst++ = *src;
  8006e8:	83 c0 01             	add    $0x1,%eax
  8006eb:	0f b6 0a             	movzbl (%edx),%ecx
  8006ee:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8006f1:	80 f9 01             	cmp    $0x1,%cl
  8006f4:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  8006f7:	39 d8                	cmp    %ebx,%eax
  8006f9:	75 ed                	jne    8006e8 <strncpy+0x14>
	}
	return ret;
}
  8006fb:	89 f0                	mov    %esi,%eax
  8006fd:	5b                   	pop    %ebx
  8006fe:	5e                   	pop    %esi
  8006ff:	5d                   	pop    %ebp
  800700:	c3                   	ret    

00800701 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800701:	55                   	push   %ebp
  800702:	89 e5                	mov    %esp,%ebp
  800704:	56                   	push   %esi
  800705:	53                   	push   %ebx
  800706:	8b 75 08             	mov    0x8(%ebp),%esi
  800709:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80070c:	8b 55 10             	mov    0x10(%ebp),%edx
  80070f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800711:	85 d2                	test   %edx,%edx
  800713:	74 21                	je     800736 <strlcpy+0x35>
  800715:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800719:	89 f2                	mov    %esi,%edx
  80071b:	eb 09                	jmp    800726 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80071d:	83 c1 01             	add    $0x1,%ecx
  800720:	83 c2 01             	add    $0x1,%edx
  800723:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800726:	39 c2                	cmp    %eax,%edx
  800728:	74 09                	je     800733 <strlcpy+0x32>
  80072a:	0f b6 19             	movzbl (%ecx),%ebx
  80072d:	84 db                	test   %bl,%bl
  80072f:	75 ec                	jne    80071d <strlcpy+0x1c>
  800731:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800733:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800736:	29 f0                	sub    %esi,%eax
}
  800738:	5b                   	pop    %ebx
  800739:	5e                   	pop    %esi
  80073a:	5d                   	pop    %ebp
  80073b:	c3                   	ret    

0080073c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80073c:	55                   	push   %ebp
  80073d:	89 e5                	mov    %esp,%ebp
  80073f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800742:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800745:	eb 06                	jmp    80074d <strcmp+0x11>
		p++, q++;
  800747:	83 c1 01             	add    $0x1,%ecx
  80074a:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80074d:	0f b6 01             	movzbl (%ecx),%eax
  800750:	84 c0                	test   %al,%al
  800752:	74 04                	je     800758 <strcmp+0x1c>
  800754:	3a 02                	cmp    (%edx),%al
  800756:	74 ef                	je     800747 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800758:	0f b6 c0             	movzbl %al,%eax
  80075b:	0f b6 12             	movzbl (%edx),%edx
  80075e:	29 d0                	sub    %edx,%eax
}
  800760:	5d                   	pop    %ebp
  800761:	c3                   	ret    

00800762 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800762:	55                   	push   %ebp
  800763:	89 e5                	mov    %esp,%ebp
  800765:	53                   	push   %ebx
  800766:	8b 45 08             	mov    0x8(%ebp),%eax
  800769:	8b 55 0c             	mov    0xc(%ebp),%edx
  80076c:	89 c3                	mov    %eax,%ebx
  80076e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800771:	eb 06                	jmp    800779 <strncmp+0x17>
		n--, p++, q++;
  800773:	83 c0 01             	add    $0x1,%eax
  800776:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800779:	39 d8                	cmp    %ebx,%eax
  80077b:	74 18                	je     800795 <strncmp+0x33>
  80077d:	0f b6 08             	movzbl (%eax),%ecx
  800780:	84 c9                	test   %cl,%cl
  800782:	74 04                	je     800788 <strncmp+0x26>
  800784:	3a 0a                	cmp    (%edx),%cl
  800786:	74 eb                	je     800773 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800788:	0f b6 00             	movzbl (%eax),%eax
  80078b:	0f b6 12             	movzbl (%edx),%edx
  80078e:	29 d0                	sub    %edx,%eax
}
  800790:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800793:	c9                   	leave  
  800794:	c3                   	ret    
		return 0;
  800795:	b8 00 00 00 00       	mov    $0x0,%eax
  80079a:	eb f4                	jmp    800790 <strncmp+0x2e>

0080079c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80079c:	55                   	push   %ebp
  80079d:	89 e5                	mov    %esp,%ebp
  80079f:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007a6:	eb 03                	jmp    8007ab <strchr+0xf>
  8007a8:	83 c0 01             	add    $0x1,%eax
  8007ab:	0f b6 10             	movzbl (%eax),%edx
  8007ae:	84 d2                	test   %dl,%dl
  8007b0:	74 06                	je     8007b8 <strchr+0x1c>
		if (*s == c)
  8007b2:	38 ca                	cmp    %cl,%dl
  8007b4:	75 f2                	jne    8007a8 <strchr+0xc>
  8007b6:	eb 05                	jmp    8007bd <strchr+0x21>
			return (char *) s;
	return 0;
  8007b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007bd:	5d                   	pop    %ebp
  8007be:	c3                   	ret    

008007bf <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8007bf:	55                   	push   %ebp
  8007c0:	89 e5                	mov    %esp,%ebp
  8007c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007c9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8007cc:	38 ca                	cmp    %cl,%dl
  8007ce:	74 09                	je     8007d9 <strfind+0x1a>
  8007d0:	84 d2                	test   %dl,%dl
  8007d2:	74 05                	je     8007d9 <strfind+0x1a>
	for (; *s; s++)
  8007d4:	83 c0 01             	add    $0x1,%eax
  8007d7:	eb f0                	jmp    8007c9 <strfind+0xa>
			break;
	return (char *) s;
}
  8007d9:	5d                   	pop    %ebp
  8007da:	c3                   	ret    

008007db <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8007db:	55                   	push   %ebp
  8007dc:	89 e5                	mov    %esp,%ebp
  8007de:	57                   	push   %edi
  8007df:	56                   	push   %esi
  8007e0:	53                   	push   %ebx
  8007e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8007e4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  8007e7:	85 c9                	test   %ecx,%ecx
  8007e9:	74 33                	je     80081e <memset+0x43>
		return v;
	if ((int) v % 4 == 0 && n % 4 == 0) {
  8007eb:	89 d0                	mov    %edx,%eax
  8007ed:	09 c8                	or     %ecx,%eax
  8007ef:	a8 03                	test   $0x3,%al
  8007f1:	75 23                	jne    800816 <memset+0x3b>
		c &= 0xFF;
  8007f3:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  8007f7:	89 d8                	mov    %ebx,%eax
  8007f9:	c1 e0 08             	shl    $0x8,%eax
  8007fc:	89 df                	mov    %ebx,%edi
  8007fe:	c1 e7 18             	shl    $0x18,%edi
  800801:	89 de                	mov    %ebx,%esi
  800803:	c1 e6 10             	shl    $0x10,%esi
  800806:	09 f7                	or     %esi,%edi
  800808:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
		             : "=D"(p), "=c"(n)
		             : "D"(p), "a"(c), "c"(n / 4)
  80080a:	c1 e9 02             	shr    $0x2,%ecx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  80080d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  80080f:	89 d7                	mov    %edx,%edi
  800811:	fc                   	cld    
  800812:	f3 ab                	rep stos %eax,%es:(%edi)
  800814:	eb 08                	jmp    80081e <memset+0x43>
		             : "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800816:	89 d7                	mov    %edx,%edi
  800818:	8b 45 0c             	mov    0xc(%ebp),%eax
  80081b:	fc                   	cld    
  80081c:	f3 aa                	rep stos %al,%es:(%edi)
		             : "=D"(p), "=c"(n)
		             : "0"(p), "a"(c), "1"(n)
		             : "cc", "memory");
	return v;
}
  80081e:	89 d0                	mov    %edx,%eax
  800820:	5b                   	pop    %ebx
  800821:	5e                   	pop    %esi
  800822:	5f                   	pop    %edi
  800823:	5d                   	pop    %ebp
  800824:	c3                   	ret    

00800825 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800825:	55                   	push   %ebp
  800826:	89 e5                	mov    %esp,%ebp
  800828:	57                   	push   %edi
  800829:	56                   	push   %esi
  80082a:	8b 45 08             	mov    0x8(%ebp),%eax
  80082d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800830:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800833:	39 c6                	cmp    %eax,%esi
  800835:	73 32                	jae    800869 <memmove+0x44>
  800837:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80083a:	39 c2                	cmp    %eax,%edx
  80083c:	76 2b                	jbe    800869 <memmove+0x44>
		s += n;
		d += n;
  80083e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  800841:	89 d6                	mov    %edx,%esi
  800843:	09 fe                	or     %edi,%esi
  800845:	09 ce                	or     %ecx,%esi
  800847:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80084d:	75 0e                	jne    80085d <memmove+0x38>
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  80084f:	83 ef 04             	sub    $0x4,%edi
			             "S"(s - 4),
  800852:	8d 72 fc             	lea    -0x4(%edx),%esi
			             "c"(n / 4)
  800855:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  800858:	fd                   	std    
  800859:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80085b:	eb 09                	jmp    800866 <memmove+0x41>
			             : "cc", "memory");
		else
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  80085d:	83 ef 01             	sub    $0x1,%edi
			             "S"(s - 1),
  800860:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  800863:	fd                   	std    
  800864:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             "c"(n)
			             : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800866:	fc                   	cld    
  800867:	eb 1a                	jmp    800883 <memmove+0x5e>
	} else {
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  800869:	89 f2                	mov    %esi,%edx
  80086b:	09 c2                	or     %eax,%edx
  80086d:	09 ca                	or     %ecx,%edx
  80086f:	f6 c2 03             	test   $0x3,%dl
  800872:	75 0a                	jne    80087e <memmove+0x59>
			asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800874:	c1 e9 02             	shr    $0x2,%ecx
  800877:	89 c7                	mov    %eax,%edi
  800879:	fc                   	cld    
  80087a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80087c:	eb 05                	jmp    800883 <memmove+0x5e>
			             : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  80087e:	89 c7                	mov    %eax,%edi
  800880:	fc                   	cld    
  800881:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             : "cc", "memory");
	}
	return dst;
}
  800883:	5e                   	pop    %esi
  800884:	5f                   	pop    %edi
  800885:	5d                   	pop    %ebp
  800886:	c3                   	ret    

00800887 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80088d:	ff 75 10             	push   0x10(%ebp)
  800890:	ff 75 0c             	push   0xc(%ebp)
  800893:	ff 75 08             	push   0x8(%ebp)
  800896:	e8 8a ff ff ff       	call   800825 <memmove>
}
  80089b:	c9                   	leave  
  80089c:	c3                   	ret    

0080089d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80089d:	55                   	push   %ebp
  80089e:	89 e5                	mov    %esp,%ebp
  8008a0:	56                   	push   %esi
  8008a1:	53                   	push   %ebx
  8008a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a8:	89 c6                	mov    %eax,%esi
  8008aa:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8008ad:	eb 06                	jmp    8008b5 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8008af:	83 c0 01             	add    $0x1,%eax
  8008b2:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  8008b5:	39 f0                	cmp    %esi,%eax
  8008b7:	74 14                	je     8008cd <memcmp+0x30>
		if (*s1 != *s2)
  8008b9:	0f b6 08             	movzbl (%eax),%ecx
  8008bc:	0f b6 1a             	movzbl (%edx),%ebx
  8008bf:	38 d9                	cmp    %bl,%cl
  8008c1:	74 ec                	je     8008af <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  8008c3:	0f b6 c1             	movzbl %cl,%eax
  8008c6:	0f b6 db             	movzbl %bl,%ebx
  8008c9:	29 d8                	sub    %ebx,%eax
  8008cb:	eb 05                	jmp    8008d2 <memcmp+0x35>
	}

	return 0;
  8008cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008d2:	5b                   	pop    %ebx
  8008d3:	5e                   	pop    %esi
  8008d4:	5d                   	pop    %ebp
  8008d5:	c3                   	ret    

008008d6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8008d6:	55                   	push   %ebp
  8008d7:	89 e5                	mov    %esp,%ebp
  8008d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8008df:	89 c2                	mov    %eax,%edx
  8008e1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8008e4:	eb 03                	jmp    8008e9 <memfind+0x13>
  8008e6:	83 c0 01             	add    $0x1,%eax
  8008e9:	39 d0                	cmp    %edx,%eax
  8008eb:	73 04                	jae    8008f1 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8008ed:	38 08                	cmp    %cl,(%eax)
  8008ef:	75 f5                	jne    8008e6 <memfind+0x10>
			break;
	return (void *) s;
}
  8008f1:	5d                   	pop    %ebp
  8008f2:	c3                   	ret    

008008f3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8008f3:	55                   	push   %ebp
  8008f4:	89 e5                	mov    %esp,%ebp
  8008f6:	57                   	push   %edi
  8008f7:	56                   	push   %esi
  8008f8:	53                   	push   %ebx
  8008f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8008fc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8008ff:	eb 03                	jmp    800904 <strtol+0x11>
		s++;
  800901:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800904:	0f b6 02             	movzbl (%edx),%eax
  800907:	3c 20                	cmp    $0x20,%al
  800909:	74 f6                	je     800901 <strtol+0xe>
  80090b:	3c 09                	cmp    $0x9,%al
  80090d:	74 f2                	je     800901 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  80090f:	3c 2b                	cmp    $0x2b,%al
  800911:	74 2a                	je     80093d <strtol+0x4a>
	int neg = 0;
  800913:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800918:	3c 2d                	cmp    $0x2d,%al
  80091a:	74 2b                	je     800947 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80091c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800922:	75 0f                	jne    800933 <strtol+0x40>
  800924:	80 3a 30             	cmpb   $0x30,(%edx)
  800927:	74 28                	je     800951 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800929:	85 db                	test   %ebx,%ebx
  80092b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800930:	0f 44 d8             	cmove  %eax,%ebx
  800933:	b9 00 00 00 00       	mov    $0x0,%ecx
  800938:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80093b:	eb 46                	jmp    800983 <strtol+0x90>
		s++;
  80093d:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800940:	bf 00 00 00 00       	mov    $0x0,%edi
  800945:	eb d5                	jmp    80091c <strtol+0x29>
		s++, neg = 1;
  800947:	83 c2 01             	add    $0x1,%edx
  80094a:	bf 01 00 00 00       	mov    $0x1,%edi
  80094f:	eb cb                	jmp    80091c <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800951:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800955:	74 0e                	je     800965 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800957:	85 db                	test   %ebx,%ebx
  800959:	75 d8                	jne    800933 <strtol+0x40>
		s++, base = 8;
  80095b:	83 c2 01             	add    $0x1,%edx
  80095e:	bb 08 00 00 00       	mov    $0x8,%ebx
  800963:	eb ce                	jmp    800933 <strtol+0x40>
		s += 2, base = 16;
  800965:	83 c2 02             	add    $0x2,%edx
  800968:	bb 10 00 00 00       	mov    $0x10,%ebx
  80096d:	eb c4                	jmp    800933 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  80096f:	0f be c0             	movsbl %al,%eax
  800972:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800975:	3b 45 10             	cmp    0x10(%ebp),%eax
  800978:	7d 3a                	jge    8009b4 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  80097a:	83 c2 01             	add    $0x1,%edx
  80097d:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800981:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800983:	0f b6 02             	movzbl (%edx),%eax
  800986:	8d 70 d0             	lea    -0x30(%eax),%esi
  800989:	89 f3                	mov    %esi,%ebx
  80098b:	80 fb 09             	cmp    $0x9,%bl
  80098e:	76 df                	jbe    80096f <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800990:	8d 70 9f             	lea    -0x61(%eax),%esi
  800993:	89 f3                	mov    %esi,%ebx
  800995:	80 fb 19             	cmp    $0x19,%bl
  800998:	77 08                	ja     8009a2 <strtol+0xaf>
			dig = *s - 'a' + 10;
  80099a:	0f be c0             	movsbl %al,%eax
  80099d:	83 e8 57             	sub    $0x57,%eax
  8009a0:	eb d3                	jmp    800975 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  8009a2:	8d 70 bf             	lea    -0x41(%eax),%esi
  8009a5:	89 f3                	mov    %esi,%ebx
  8009a7:	80 fb 19             	cmp    $0x19,%bl
  8009aa:	77 08                	ja     8009b4 <strtol+0xc1>
			dig = *s - 'A' + 10;
  8009ac:	0f be c0             	movsbl %al,%eax
  8009af:	83 e8 37             	sub    $0x37,%eax
  8009b2:	eb c1                	jmp    800975 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  8009b4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8009b8:	74 05                	je     8009bf <strtol+0xcc>
		*endptr = (char *) s;
  8009ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009bd:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  8009bf:	89 c8                	mov    %ecx,%eax
  8009c1:	f7 d8                	neg    %eax
  8009c3:	85 ff                	test   %edi,%edi
  8009c5:	0f 45 c8             	cmovne %eax,%ecx
}
  8009c8:	89 c8                	mov    %ecx,%eax
  8009ca:	5b                   	pop    %ebx
  8009cb:	5e                   	pop    %esi
  8009cc:	5f                   	pop    %edi
  8009cd:	5d                   	pop    %ebp
  8009ce:	c3                   	ret    

008009cf <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8009cf:	55                   	push   %ebp
  8009d0:	89 e5                	mov    %esp,%ebp
  8009d2:	57                   	push   %edi
  8009d3:	56                   	push   %esi
  8009d4:	53                   	push   %ebx
  8009d5:	83 ec 1c             	sub    $0x1c,%esp
  8009d8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009db:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8009de:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile(
  8009e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009e6:	8b 7d 10             	mov    0x10(%ebp),%edi
  8009e9:	8b 75 14             	mov    0x14(%ebp),%esi
  8009ec:	cd 30                	int    $0x30
	        "int %1\n"
	        : "=a"(ret)
	        : "i"(T_SYSCALL), "a"(num), "d"(a1), "c"(a2), "b"(a3), "D"(a4), "S"(a5)
	        : "cc", "memory");

	if (check && ret > 0)
  8009ee:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8009f2:	74 04                	je     8009f8 <syscall+0x29>
  8009f4:	85 c0                	test   %eax,%eax
  8009f6:	7f 08                	jg     800a00 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  8009f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009fb:	5b                   	pop    %ebx
  8009fc:	5e                   	pop    %esi
  8009fd:	5f                   	pop    %edi
  8009fe:	5d                   	pop    %ebp
  8009ff:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800a00:	83 ec 0c             	sub    $0xc,%esp
  800a03:	50                   	push   %eax
  800a04:	ff 75 e0             	push   -0x20(%ebp)
  800a07:	68 24 11 80 00       	push   $0x801124
  800a0c:	6a 1e                	push   $0x1e
  800a0e:	68 41 11 80 00       	push   $0x801141
  800a13:	e8 f7 01 00 00       	call   800c0f <_panic>

00800a18 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800a18:	55                   	push   %ebp
  800a19:	89 e5                	mov    %esp,%ebp
  800a1b:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t) s, len, 0, 0, 0);
  800a1e:	6a 00                	push   $0x0
  800a20:	6a 00                	push   $0x0
  800a22:	6a 00                	push   $0x0
  800a24:	ff 75 0c             	push   0xc(%ebp)
  800a27:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a2f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a34:	e8 96 ff ff ff       	call   8009cf <syscall>
}
  800a39:	83 c4 10             	add    $0x10,%esp
  800a3c:	c9                   	leave  
  800a3d:	c3                   	ret    

00800a3e <sys_cgetc>:

int
sys_cgetc(void)
{
  800a3e:	55                   	push   %ebp
  800a3f:	89 e5                	mov    %esp,%ebp
  800a41:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800a44:	6a 00                	push   $0x0
  800a46:	6a 00                	push   $0x0
  800a48:	6a 00                	push   $0x0
  800a4a:	6a 00                	push   $0x0
  800a4c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a51:	ba 00 00 00 00       	mov    $0x0,%edx
  800a56:	b8 01 00 00 00       	mov    $0x1,%eax
  800a5b:	e8 6f ff ff ff       	call   8009cf <syscall>
}
  800a60:	c9                   	leave  
  800a61:	c3                   	ret    

00800a62 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a62:	55                   	push   %ebp
  800a63:	89 e5                	mov    %esp,%ebp
  800a65:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800a68:	6a 00                	push   $0x0
  800a6a:	6a 00                	push   $0x0
  800a6c:	6a 00                	push   $0x0
  800a6e:	6a 00                	push   $0x0
  800a70:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a73:	ba 01 00 00 00       	mov    $0x1,%edx
  800a78:	b8 03 00 00 00       	mov    $0x3,%eax
  800a7d:	e8 4d ff ff ff       	call   8009cf <syscall>
}
  800a82:	c9                   	leave  
  800a83:	c3                   	ret    

00800a84 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800a84:	55                   	push   %ebp
  800a85:	89 e5                	mov    %esp,%ebp
  800a87:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800a8a:	6a 00                	push   $0x0
  800a8c:	6a 00                	push   $0x0
  800a8e:	6a 00                	push   $0x0
  800a90:	6a 00                	push   $0x0
  800a92:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a97:	ba 00 00 00 00       	mov    $0x0,%edx
  800a9c:	b8 02 00 00 00       	mov    $0x2,%eax
  800aa1:	e8 29 ff ff ff       	call   8009cf <syscall>
}
  800aa6:	c9                   	leave  
  800aa7:	c3                   	ret    

00800aa8 <sys_yield>:

void
sys_yield(void)
{
  800aa8:	55                   	push   %ebp
  800aa9:	89 e5                	mov    %esp,%ebp
  800aab:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800aae:	6a 00                	push   $0x0
  800ab0:	6a 00                	push   $0x0
  800ab2:	6a 00                	push   $0x0
  800ab4:	6a 00                	push   $0x0
  800ab6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800abb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac0:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ac5:	e8 05 ff ff ff       	call   8009cf <syscall>
}
  800aca:	83 c4 10             	add    $0x10,%esp
  800acd:	c9                   	leave  
  800ace:	c3                   	ret    

00800acf <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800acf:	55                   	push   %ebp
  800ad0:	89 e5                	mov    %esp,%ebp
  800ad2:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800ad5:	6a 00                	push   $0x0
  800ad7:	6a 00                	push   $0x0
  800ad9:	ff 75 10             	push   0x10(%ebp)
  800adc:	ff 75 0c             	push   0xc(%ebp)
  800adf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ae2:	ba 01 00 00 00       	mov    $0x1,%edx
  800ae7:	b8 04 00 00 00       	mov    $0x4,%eax
  800aec:	e8 de fe ff ff       	call   8009cf <syscall>
}
  800af1:	c9                   	leave  
  800af2:	c3                   	ret    

00800af3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800af3:	55                   	push   %ebp
  800af4:	89 e5                	mov    %esp,%ebp
  800af6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map,
  800af9:	ff 75 18             	push   0x18(%ebp)
  800afc:	ff 75 14             	push   0x14(%ebp)
  800aff:	ff 75 10             	push   0x10(%ebp)
  800b02:	ff 75 0c             	push   0xc(%ebp)
  800b05:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b08:	ba 01 00 00 00       	mov    $0x1,%edx
  800b0d:	b8 05 00 00 00       	mov    $0x5,%eax
  800b12:	e8 b8 fe ff ff       	call   8009cf <syscall>
	               srcenv,
	               (uint32_t) srcva,
	               dstenv,
	               (uint32_t) dstva,
	               perm);
}
  800b17:	c9                   	leave  
  800b18:	c3                   	ret    

00800b19 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b19:	55                   	push   %ebp
  800b1a:	89 e5                	mov    %esp,%ebp
  800b1c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800b1f:	6a 00                	push   $0x0
  800b21:	6a 00                	push   $0x0
  800b23:	6a 00                	push   $0x0
  800b25:	ff 75 0c             	push   0xc(%ebp)
  800b28:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b2b:	ba 01 00 00 00       	mov    $0x1,%edx
  800b30:	b8 06 00 00 00       	mov    $0x6,%eax
  800b35:	e8 95 fe ff ff       	call   8009cf <syscall>
}
  800b3a:	c9                   	leave  
  800b3b:	c3                   	ret    

00800b3c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800b42:	6a 00                	push   $0x0
  800b44:	6a 00                	push   $0x0
  800b46:	6a 00                	push   $0x0
  800b48:	ff 75 0c             	push   0xc(%ebp)
  800b4b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b4e:	ba 01 00 00 00       	mov    $0x1,%edx
  800b53:	b8 08 00 00 00       	mov    $0x8,%eax
  800b58:	e8 72 fe ff ff       	call   8009cf <syscall>
}
  800b5d:	c9                   	leave  
  800b5e:	c3                   	ret    

00800b5f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	83 ec 08             	sub    $0x8,%esp
	return syscall(
  800b65:	6a 00                	push   $0x0
  800b67:	6a 00                	push   $0x0
  800b69:	6a 00                	push   $0x0
  800b6b:	ff 75 0c             	push   0xc(%ebp)
  800b6e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b71:	ba 01 00 00 00       	mov    $0x1,%edx
  800b76:	b8 09 00 00 00       	mov    $0x9,%eax
  800b7b:	e8 4f fe ff ff       	call   8009cf <syscall>
	        SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800b80:	c9                   	leave  
  800b81:	c3                   	ret    

00800b82 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800b82:	55                   	push   %ebp
  800b83:	89 e5                	mov    %esp,%ebp
  800b85:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800b88:	6a 00                	push   $0x0
  800b8a:	ff 75 14             	push   0x14(%ebp)
  800b8d:	ff 75 10             	push   0x10(%ebp)
  800b90:	ff 75 0c             	push   0xc(%ebp)
  800b93:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b96:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ba0:	e8 2a fe ff ff       	call   8009cf <syscall>
}
  800ba5:	c9                   	leave  
  800ba6:	c3                   	ret    

00800ba7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ba7:	55                   	push   %ebp
  800ba8:	89 e5                	mov    %esp,%ebp
  800baa:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t) dstva, 0, 0, 0, 0);
  800bad:	6a 00                	push   $0x0
  800baf:	6a 00                	push   $0x0
  800bb1:	6a 00                	push   $0x0
  800bb3:	6a 00                	push   $0x0
  800bb5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bb8:	ba 01 00 00 00       	mov    $0x1,%edx
  800bbd:	b8 0c 00 00 00       	mov    $0xc,%eax
  800bc2:	e8 08 fe ff ff       	call   8009cf <syscall>
}
  800bc7:	c9                   	leave  
  800bc8:	c3                   	ret    

00800bc9 <sys_get_priority>:

// Get priority of the current process
int
sys_get_priority(void)
{
  800bc9:	55                   	push   %ebp
  800bca:	89 e5                	mov    %esp,%ebp
  800bcc:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_get_priority, 0, 0, 0, 0, 0, 0);
  800bcf:	6a 00                	push   $0x0
  800bd1:	6a 00                	push   $0x0
  800bd3:	6a 00                	push   $0x0
  800bd5:	6a 00                	push   $0x0
  800bd7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bdc:	ba 00 00 00 00       	mov    $0x0,%edx
  800be1:	b8 0d 00 00 00       	mov    $0xd,%eax
  800be6:	e8 e4 fd ff ff       	call   8009cf <syscall>
}
  800beb:	c9                   	leave  
  800bec:	c3                   	ret    

00800bed <sys_set_priority>:

// Get priority of the current process
int
sys_set_priority(unsigned int priority)
{
  800bed:	55                   	push   %ebp
  800bee:	89 e5                	mov    %esp,%ebp
  800bf0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, (uint32_t) priority, 0, 0, 0, 0);
  800bf3:	6a 00                	push   $0x0
  800bf5:	6a 00                	push   $0x0
  800bf7:	6a 00                	push   $0x0
  800bf9:	6a 00                	push   $0x0
  800bfb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bfe:	ba 00 00 00 00       	mov    $0x0,%edx
  800c03:	b8 0e 00 00 00       	mov    $0xe,%eax
  800c08:	e8 c2 fd ff ff       	call   8009cf <syscall>
}
  800c0d:	c9                   	leave  
  800c0e:	c3                   	ret    

00800c0f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800c0f:	55                   	push   %ebp
  800c10:	89 e5                	mov    %esp,%ebp
  800c12:	56                   	push   %esi
  800c13:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800c14:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800c17:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800c1d:	e8 62 fe ff ff       	call   800a84 <sys_getenvid>
  800c22:	83 ec 0c             	sub    $0xc,%esp
  800c25:	ff 75 0c             	push   0xc(%ebp)
  800c28:	ff 75 08             	push   0x8(%ebp)
  800c2b:	56                   	push   %esi
  800c2c:	50                   	push   %eax
  800c2d:	68 50 11 80 00       	push   $0x801150
  800c32:	e8 1b f5 ff ff       	call   800152 <cprintf>
	        sys_getenvid(),
	        binaryname,
	        file,
	        line);
	vcprintf(fmt, ap);
  800c37:	83 c4 18             	add    $0x18,%esp
  800c3a:	53                   	push   %ebx
  800c3b:	ff 75 10             	push   0x10(%ebp)
  800c3e:	e8 be f4 ff ff       	call   800101 <vcprintf>
	cprintf("\n");
  800c43:	c7 04 24 ac 0e 80 00 	movl   $0x800eac,(%esp)
  800c4a:	e8 03 f5 ff ff       	call   800152 <cprintf>
  800c4f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800c52:	cc                   	int3   
  800c53:	eb fd                	jmp    800c52 <_panic+0x43>
  800c55:	66 90                	xchg   %ax,%ax
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
