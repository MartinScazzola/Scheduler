
obj/user/faultdie:     formato del fichero elf32-i386


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
  80002c:	e8 4f 00 00 00       	call   800080 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
  800039:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  80003c:	8b 42 04             	mov    0x4(%edx),%eax
  80003f:	83 e0 07             	and    $0x7,%eax
  800042:	50                   	push   %eax
  800043:	ff 32                	push   (%edx)
  800045:	68 40 0f 80 00       	push   $0x800f40
  80004a:	e8 25 01 00 00       	call   800174 <cprintf>
	sys_env_destroy(sys_getenvid());
  80004f:	e8 52 0a 00 00       	call   800aa6 <sys_getenvid>
  800054:	89 04 24             	mov    %eax,(%esp)
  800057:	e8 28 0a 00 00       	call   800a84 <sys_env_destroy>
}
  80005c:	83 c4 10             	add    $0x10,%esp
  80005f:	c9                   	leave  
  800060:	c3                   	ret    

00800061 <umain>:

void
umain(int argc, char **argv)
{
  800061:	55                   	push   %ebp
  800062:	89 e5                	mov    %esp,%ebp
  800064:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800067:	68 33 00 80 00       	push   $0x800033
  80006c:	e8 c0 0b 00 00       	call   800c31 <set_pgfault_handler>
	*(int *) 0xDeadBeef = 0;
  800071:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800078:	00 00 00 
}
  80007b:	83 c4 10             	add    $0x10,%esp
  80007e:	c9                   	leave  
  80007f:	c3                   	ret    

00800080 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	56                   	push   %esi
  800084:	53                   	push   %ebx
  800085:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800088:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	envid_t id = sys_getenvid();
  80008b:	e8 16 0a 00 00       	call   800aa6 <sys_getenvid>
	if (id >= 0)
  800090:	85 c0                	test   %eax,%eax
  800092:	78 15                	js     8000a9 <libmain+0x29>
		thisenv = &envs[ENVX(id)];
  800094:	25 ff 03 00 00       	and    $0x3ff,%eax
  800099:	69 c0 88 00 00 00    	imul   $0x88,%eax,%eax
  80009f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000a4:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a9:	85 db                	test   %ebx,%ebx
  8000ab:	7e 07                	jle    8000b4 <libmain+0x34>
		binaryname = argv[0];
  8000ad:	8b 06                	mov    (%esi),%eax
  8000af:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000b4:	83 ec 08             	sub    $0x8,%esp
  8000b7:	56                   	push   %esi
  8000b8:	53                   	push   %ebx
  8000b9:	e8 a3 ff ff ff       	call   800061 <umain>

	// exit gracefully
	exit();
  8000be:	e8 0a 00 00 00       	call   8000cd <exit>
}
  8000c3:	83 c4 10             	add    $0x10,%esp
  8000c6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c9:	5b                   	pop    %ebx
  8000ca:	5e                   	pop    %esi
  8000cb:	5d                   	pop    %ebp
  8000cc:	c3                   	ret    

008000cd <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000cd:	55                   	push   %ebp
  8000ce:	89 e5                	mov    %esp,%ebp
  8000d0:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000d3:	6a 00                	push   $0x0
  8000d5:	e8 aa 09 00 00       	call   800a84 <sys_env_destroy>
}
  8000da:	83 c4 10             	add    $0x10,%esp
  8000dd:	c9                   	leave  
  8000de:	c3                   	ret    

008000df <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000df:	55                   	push   %ebp
  8000e0:	89 e5                	mov    %esp,%ebp
  8000e2:	53                   	push   %ebx
  8000e3:	83 ec 04             	sub    $0x4,%esp
  8000e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000e9:	8b 13                	mov    (%ebx),%edx
  8000eb:	8d 42 01             	lea    0x1(%edx),%eax
  8000ee:	89 03                	mov    %eax,(%ebx)
  8000f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000f3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256 - 1) {
  8000f7:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000fc:	74 09                	je     800107 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000fe:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800102:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800105:	c9                   	leave  
  800106:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800107:	83 ec 08             	sub    $0x8,%esp
  80010a:	68 ff 00 00 00       	push   $0xff
  80010f:	8d 43 08             	lea    0x8(%ebx),%eax
  800112:	50                   	push   %eax
  800113:	e8 22 09 00 00       	call   800a3a <sys_cputs>
		b->idx = 0;
  800118:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80011e:	83 c4 10             	add    $0x10,%esp
  800121:	eb db                	jmp    8000fe <putch+0x1f>

00800123 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800123:	55                   	push   %ebp
  800124:	89 e5                	mov    %esp,%ebp
  800126:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80012c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800133:	00 00 00 
	b.cnt = 0;
  800136:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80013d:	00 00 00 
	vprintfmt((void *) putch, &b, fmt, ap);
  800140:	ff 75 0c             	push   0xc(%ebp)
  800143:	ff 75 08             	push   0x8(%ebp)
  800146:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80014c:	50                   	push   %eax
  80014d:	68 df 00 80 00       	push   $0x8000df
  800152:	e8 74 01 00 00       	call   8002cb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800157:	83 c4 08             	add    $0x8,%esp
  80015a:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800160:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800166:	50                   	push   %eax
  800167:	e8 ce 08 00 00       	call   800a3a <sys_cputs>

	return b.cnt;
}
  80016c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800172:	c9                   	leave  
  800173:	c3                   	ret    

00800174 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800174:	55                   	push   %ebp
  800175:	89 e5                	mov    %esp,%ebp
  800177:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80017a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80017d:	50                   	push   %eax
  80017e:	ff 75 08             	push   0x8(%ebp)
  800181:	e8 9d ff ff ff       	call   800123 <vcprintf>
	va_end(ap);

	return cnt;
}
  800186:	c9                   	leave  
  800187:	c3                   	ret    

00800188 <printnum>:
         void *putdat,
         unsigned long long num,
         unsigned base,
         int width,
         int padc)
{
  800188:	55                   	push   %ebp
  800189:	89 e5                	mov    %esp,%ebp
  80018b:	57                   	push   %edi
  80018c:	56                   	push   %esi
  80018d:	53                   	push   %ebx
  80018e:	83 ec 1c             	sub    $0x1c,%esp
  800191:	89 c7                	mov    %eax,%edi
  800193:	89 d6                	mov    %edx,%esi
  800195:	8b 45 08             	mov    0x8(%ebp),%eax
  800198:	8b 55 0c             	mov    0xc(%ebp),%edx
  80019b:	89 d1                	mov    %edx,%ecx
  80019d:	89 c2                	mov    %eax,%edx
  80019f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001a2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001a5:	8b 45 10             	mov    0x10(%ebp),%eax
  8001a8:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001ab:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001ae:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001b5:	39 c2                	cmp    %eax,%edx
  8001b7:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001ba:	72 3e                	jb     8001fa <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001bc:	83 ec 0c             	sub    $0xc,%esp
  8001bf:	ff 75 18             	push   0x18(%ebp)
  8001c2:	83 eb 01             	sub    $0x1,%ebx
  8001c5:	53                   	push   %ebx
  8001c6:	50                   	push   %eax
  8001c7:	83 ec 08             	sub    $0x8,%esp
  8001ca:	ff 75 e4             	push   -0x1c(%ebp)
  8001cd:	ff 75 e0             	push   -0x20(%ebp)
  8001d0:	ff 75 dc             	push   -0x24(%ebp)
  8001d3:	ff 75 d8             	push   -0x28(%ebp)
  8001d6:	e8 15 0b 00 00       	call   800cf0 <__udivdi3>
  8001db:	83 c4 18             	add    $0x18,%esp
  8001de:	52                   	push   %edx
  8001df:	50                   	push   %eax
  8001e0:	89 f2                	mov    %esi,%edx
  8001e2:	89 f8                	mov    %edi,%eax
  8001e4:	e8 9f ff ff ff       	call   800188 <printnum>
  8001e9:	83 c4 20             	add    $0x20,%esp
  8001ec:	eb 13                	jmp    800201 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001ee:	83 ec 08             	sub    $0x8,%esp
  8001f1:	56                   	push   %esi
  8001f2:	ff 75 18             	push   0x18(%ebp)
  8001f5:	ff d7                	call   *%edi
  8001f7:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001fa:	83 eb 01             	sub    $0x1,%ebx
  8001fd:	85 db                	test   %ebx,%ebx
  8001ff:	7f ed                	jg     8001ee <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800201:	83 ec 08             	sub    $0x8,%esp
  800204:	56                   	push   %esi
  800205:	83 ec 04             	sub    $0x4,%esp
  800208:	ff 75 e4             	push   -0x1c(%ebp)
  80020b:	ff 75 e0             	push   -0x20(%ebp)
  80020e:	ff 75 dc             	push   -0x24(%ebp)
  800211:	ff 75 d8             	push   -0x28(%ebp)
  800214:	e8 f7 0b 00 00       	call   800e10 <__umoddi3>
  800219:	83 c4 14             	add    $0x14,%esp
  80021c:	0f be 80 66 0f 80 00 	movsbl 0x800f66(%eax),%eax
  800223:	50                   	push   %eax
  800224:	ff d7                	call   *%edi
}
  800226:	83 c4 10             	add    $0x10,%esp
  800229:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80022c:	5b                   	pop    %ebx
  80022d:	5e                   	pop    %esi
  80022e:	5f                   	pop    %edi
  80022f:	5d                   	pop    %ebp
  800230:	c3                   	ret    

00800231 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800231:	83 fa 01             	cmp    $0x1,%edx
  800234:	7f 13                	jg     800249 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800236:	85 d2                	test   %edx,%edx
  800238:	74 1c                	je     800256 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  80023a:	8b 10                	mov    (%eax),%edx
  80023c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80023f:	89 08                	mov    %ecx,(%eax)
  800241:	8b 02                	mov    (%edx),%eax
  800243:	ba 00 00 00 00       	mov    $0x0,%edx
  800248:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  800249:	8b 10                	mov    (%eax),%edx
  80024b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80024e:	89 08                	mov    %ecx,(%eax)
  800250:	8b 02                	mov    (%edx),%eax
  800252:	8b 52 04             	mov    0x4(%edx),%edx
  800255:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  800256:	8b 10                	mov    (%eax),%edx
  800258:	8d 4a 04             	lea    0x4(%edx),%ecx
  80025b:	89 08                	mov    %ecx,(%eax)
  80025d:	8b 02                	mov    (%edx),%eax
  80025f:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800264:	c3                   	ret    

00800265 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800265:	83 fa 01             	cmp    $0x1,%edx
  800268:	7f 0f                	jg     800279 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  80026a:	85 d2                	test   %edx,%edx
  80026c:	74 18                	je     800286 <getint+0x21>
		return va_arg(*ap, long);
  80026e:	8b 10                	mov    (%eax),%edx
  800270:	8d 4a 04             	lea    0x4(%edx),%ecx
  800273:	89 08                	mov    %ecx,(%eax)
  800275:	8b 02                	mov    (%edx),%eax
  800277:	99                   	cltd   
  800278:	c3                   	ret    
		return va_arg(*ap, long long);
  800279:	8b 10                	mov    (%eax),%edx
  80027b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80027e:	89 08                	mov    %ecx,(%eax)
  800280:	8b 02                	mov    (%edx),%eax
  800282:	8b 52 04             	mov    0x4(%edx),%edx
  800285:	c3                   	ret    
	else
		return va_arg(*ap, int);
  800286:	8b 10                	mov    (%eax),%edx
  800288:	8d 4a 04             	lea    0x4(%edx),%ecx
  80028b:	89 08                	mov    %ecx,(%eax)
  80028d:	8b 02                	mov    (%edx),%eax
  80028f:	99                   	cltd   
}
  800290:	c3                   	ret    

00800291 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800291:	55                   	push   %ebp
  800292:	89 e5                	mov    %esp,%ebp
  800294:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800297:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80029b:	8b 10                	mov    (%eax),%edx
  80029d:	3b 50 04             	cmp    0x4(%eax),%edx
  8002a0:	73 0a                	jae    8002ac <sprintputch+0x1b>
		*b->buf++ = ch;
  8002a2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002a5:	89 08                	mov    %ecx,(%eax)
  8002a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002aa:	88 02                	mov    %al,(%edx)
}
  8002ac:	5d                   	pop    %ebp
  8002ad:	c3                   	ret    

008002ae <printfmt>:
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002b4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002b7:	50                   	push   %eax
  8002b8:	ff 75 10             	push   0x10(%ebp)
  8002bb:	ff 75 0c             	push   0xc(%ebp)
  8002be:	ff 75 08             	push   0x8(%ebp)
  8002c1:	e8 05 00 00 00       	call   8002cb <vprintfmt>
}
  8002c6:	83 c4 10             	add    $0x10,%esp
  8002c9:	c9                   	leave  
  8002ca:	c3                   	ret    

008002cb <vprintfmt>:
{
  8002cb:	55                   	push   %ebp
  8002cc:	89 e5                	mov    %esp,%ebp
  8002ce:	57                   	push   %edi
  8002cf:	56                   	push   %esi
  8002d0:	53                   	push   %ebx
  8002d1:	83 ec 2c             	sub    $0x2c,%esp
  8002d4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002d7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8002da:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002dd:	eb 0a                	jmp    8002e9 <vprintfmt+0x1e>
			putch(ch, putdat);
  8002df:	83 ec 08             	sub    $0x8,%esp
  8002e2:	56                   	push   %esi
  8002e3:	50                   	push   %eax
  8002e4:	ff d3                	call   *%ebx
  8002e6:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002e9:	83 c7 01             	add    $0x1,%edi
  8002ec:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002f0:	83 f8 25             	cmp    $0x25,%eax
  8002f3:	74 0c                	je     800301 <vprintfmt+0x36>
			if (ch == '\0')
  8002f5:	85 c0                	test   %eax,%eax
  8002f7:	75 e6                	jne    8002df <vprintfmt+0x14>
}
  8002f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002fc:	5b                   	pop    %ebx
  8002fd:	5e                   	pop    %esi
  8002fe:	5f                   	pop    %edi
  8002ff:	5d                   	pop    %ebp
  800300:	c3                   	ret    
		padc = ' ';
  800301:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
		altflag = 0;
  800305:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80030c:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800313:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80031a:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80031f:	8d 47 01             	lea    0x1(%edi),%eax
  800322:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800325:	0f b6 17             	movzbl (%edi),%edx
  800328:	8d 42 dd             	lea    -0x23(%edx),%eax
  80032b:	3c 55                	cmp    $0x55,%al
  80032d:	0f 87 b7 02 00 00    	ja     8005ea <vprintfmt+0x31f>
  800333:	0f b6 c0             	movzbl %al,%eax
  800336:	ff 24 85 20 10 80 00 	jmp    *0x801020(,%eax,4)
  80033d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800340:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800344:	eb d9                	jmp    80031f <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800346:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800349:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  80034d:	eb d0                	jmp    80031f <vprintfmt+0x54>
  80034f:	0f b6 d2             	movzbl %dl,%edx
  800352:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0;; ++fmt) {
  800355:	b8 00 00 00 00       	mov    $0x0,%eax
  80035a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80035d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800360:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800364:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800367:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80036a:	83 f9 09             	cmp    $0x9,%ecx
  80036d:	77 52                	ja     8003c1 <vprintfmt+0xf6>
			for (precision = 0;; ++fmt) {
  80036f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800372:	eb e9                	jmp    80035d <vprintfmt+0x92>
			precision = va_arg(ap, int);
  800374:	8b 45 14             	mov    0x14(%ebp),%eax
  800377:	8d 50 04             	lea    0x4(%eax),%edx
  80037a:	89 55 14             	mov    %edx,0x14(%ebp)
  80037d:	8b 00                	mov    (%eax),%eax
  80037f:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800382:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800385:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800389:	79 94                	jns    80031f <vprintfmt+0x54>
				width = precision, precision = -1;
  80038b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80038e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800391:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800398:	eb 85                	jmp    80031f <vprintfmt+0x54>
  80039a:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80039d:	85 d2                	test   %edx,%edx
  80039f:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a4:	0f 49 c2             	cmovns %edx,%eax
  8003a7:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003ad:	e9 6d ff ff ff       	jmp    80031f <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8003b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003b5:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003bc:	e9 5e ff ff ff       	jmp    80031f <vprintfmt+0x54>
  8003c1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003c4:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003c7:	eb bc                	jmp    800385 <vprintfmt+0xba>
			lflag++;
  8003c9:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003cf:	e9 4b ff ff ff       	jmp    80031f <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8003d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d7:	8d 50 04             	lea    0x4(%eax),%edx
  8003da:	89 55 14             	mov    %edx,0x14(%ebp)
  8003dd:	83 ec 08             	sub    $0x8,%esp
  8003e0:	56                   	push   %esi
  8003e1:	ff 30                	push   (%eax)
  8003e3:	ff d3                	call   *%ebx
			break;
  8003e5:	83 c4 10             	add    $0x10,%esp
  8003e8:	e9 94 01 00 00       	jmp    800581 <vprintfmt+0x2b6>
			err = va_arg(ap, int);
  8003ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f0:	8d 50 04             	lea    0x4(%eax),%edx
  8003f3:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f6:	8b 10                	mov    (%eax),%edx
  8003f8:	89 d0                	mov    %edx,%eax
  8003fa:	f7 d8                	neg    %eax
  8003fc:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003ff:	83 f8 08             	cmp    $0x8,%eax
  800402:	7f 20                	jg     800424 <vprintfmt+0x159>
  800404:	8b 14 85 80 11 80 00 	mov    0x801180(,%eax,4),%edx
  80040b:	85 d2                	test   %edx,%edx
  80040d:	74 15                	je     800424 <vprintfmt+0x159>
				printfmt(putch, putdat, "%s", p);
  80040f:	52                   	push   %edx
  800410:	68 87 0f 80 00       	push   $0x800f87
  800415:	56                   	push   %esi
  800416:	53                   	push   %ebx
  800417:	e8 92 fe ff ff       	call   8002ae <printfmt>
  80041c:	83 c4 10             	add    $0x10,%esp
  80041f:	e9 5d 01 00 00       	jmp    800581 <vprintfmt+0x2b6>
				printfmt(putch, putdat, "error %d", err);
  800424:	50                   	push   %eax
  800425:	68 7e 0f 80 00       	push   $0x800f7e
  80042a:	56                   	push   %esi
  80042b:	53                   	push   %ebx
  80042c:	e8 7d fe ff ff       	call   8002ae <printfmt>
  800431:	83 c4 10             	add    $0x10,%esp
  800434:	e9 48 01 00 00       	jmp    800581 <vprintfmt+0x2b6>
			if ((p = va_arg(ap, char *)) == NULL)
  800439:	8b 45 14             	mov    0x14(%ebp),%eax
  80043c:	8d 50 04             	lea    0x4(%eax),%edx
  80043f:	89 55 14             	mov    %edx,0x14(%ebp)
  800442:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800444:	85 ff                	test   %edi,%edi
  800446:	b8 77 0f 80 00       	mov    $0x800f77,%eax
  80044b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80044e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800452:	7e 06                	jle    80045a <vprintfmt+0x18f>
  800454:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  800458:	75 0a                	jne    800464 <vprintfmt+0x199>
  80045a:	89 f8                	mov    %edi,%eax
  80045c:	03 45 e0             	add    -0x20(%ebp),%eax
  80045f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800462:	eb 59                	jmp    8004bd <vprintfmt+0x1f2>
				for (width -= strnlen(p, precision); width > 0;
  800464:	83 ec 08             	sub    $0x8,%esp
  800467:	ff 75 d8             	push   -0x28(%ebp)
  80046a:	57                   	push   %edi
  80046b:	e8 1a 02 00 00       	call   80068a <strnlen>
  800470:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800473:	29 c1                	sub    %eax,%ecx
  800475:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800478:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80047b:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  80047f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800482:	89 7d d0             	mov    %edi,-0x30(%ebp)
  800485:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0;
  800487:	eb 0f                	jmp    800498 <vprintfmt+0x1cd>
					putch(padc, putdat);
  800489:	83 ec 08             	sub    $0x8,%esp
  80048c:	56                   	push   %esi
  80048d:	ff 75 e0             	push   -0x20(%ebp)
  800490:	ff d3                	call   *%ebx
				     width--)
  800492:	83 ef 01             	sub    $0x1,%edi
  800495:	83 c4 10             	add    $0x10,%esp
				for (width -= strnlen(p, precision); width > 0;
  800498:	85 ff                	test   %edi,%edi
  80049a:	7f ed                	jg     800489 <vprintfmt+0x1be>
  80049c:	8b 7d d0             	mov    -0x30(%ebp),%edi
  80049f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004a2:	85 c9                	test   %ecx,%ecx
  8004a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a9:	0f 49 c1             	cmovns %ecx,%eax
  8004ac:	29 c1                	sub    %eax,%ecx
  8004ae:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8004b1:	eb a7                	jmp    80045a <vprintfmt+0x18f>
					putch(ch, putdat);
  8004b3:	83 ec 08             	sub    $0x8,%esp
  8004b6:	56                   	push   %esi
  8004b7:	52                   	push   %edx
  8004b8:	ff d3                	call   *%ebx
  8004ba:	83 c4 10             	add    $0x10,%esp
  8004bd:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004c0:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' &&
  8004c2:	83 c7 01             	add    $0x1,%edi
  8004c5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004c9:	0f be d0             	movsbl %al,%edx
  8004cc:	85 d2                	test   %edx,%edx
  8004ce:	74 42                	je     800512 <vprintfmt+0x247>
  8004d0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004d4:	78 06                	js     8004dc <vprintfmt+0x211>
			       (precision < 0 || --precision >= 0);
  8004d6:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004da:	78 1e                	js     8004fa <vprintfmt+0x22f>
				if (altflag && (ch < ' ' || ch > '~'))
  8004dc:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004e0:	74 d1                	je     8004b3 <vprintfmt+0x1e8>
  8004e2:	0f be c0             	movsbl %al,%eax
  8004e5:	83 e8 20             	sub    $0x20,%eax
  8004e8:	83 f8 5e             	cmp    $0x5e,%eax
  8004eb:	76 c6                	jbe    8004b3 <vprintfmt+0x1e8>
					putch('?', putdat);
  8004ed:	83 ec 08             	sub    $0x8,%esp
  8004f0:	56                   	push   %esi
  8004f1:	6a 3f                	push   $0x3f
  8004f3:	ff d3                	call   *%ebx
  8004f5:	83 c4 10             	add    $0x10,%esp
  8004f8:	eb c3                	jmp    8004bd <vprintfmt+0x1f2>
  8004fa:	89 cf                	mov    %ecx,%edi
  8004fc:	eb 0e                	jmp    80050c <vprintfmt+0x241>
				putch(' ', putdat);
  8004fe:	83 ec 08             	sub    $0x8,%esp
  800501:	56                   	push   %esi
  800502:	6a 20                	push   $0x20
  800504:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  800506:	83 ef 01             	sub    $0x1,%edi
  800509:	83 c4 10             	add    $0x10,%esp
  80050c:	85 ff                	test   %edi,%edi
  80050e:	7f ee                	jg     8004fe <vprintfmt+0x233>
  800510:	eb 6f                	jmp    800581 <vprintfmt+0x2b6>
  800512:	89 cf                	mov    %ecx,%edi
  800514:	eb f6                	jmp    80050c <vprintfmt+0x241>
			num = getint(&ap, lflag);
  800516:	89 ca                	mov    %ecx,%edx
  800518:	8d 45 14             	lea    0x14(%ebp),%eax
  80051b:	e8 45 fd ff ff       	call   800265 <getint>
  800520:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800523:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800526:	85 d2                	test   %edx,%edx
  800528:	78 0b                	js     800535 <vprintfmt+0x26a>
			num = getint(&ap, lflag);
  80052a:	89 d1                	mov    %edx,%ecx
  80052c:	89 c2                	mov    %eax,%edx
			base = 10;
  80052e:	bf 0a 00 00 00       	mov    $0xa,%edi
  800533:	eb 32                	jmp    800567 <vprintfmt+0x29c>
				putch('-', putdat);
  800535:	83 ec 08             	sub    $0x8,%esp
  800538:	56                   	push   %esi
  800539:	6a 2d                	push   $0x2d
  80053b:	ff d3                	call   *%ebx
				num = -(long long) num;
  80053d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800540:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800543:	f7 da                	neg    %edx
  800545:	83 d1 00             	adc    $0x0,%ecx
  800548:	f7 d9                	neg    %ecx
  80054a:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80054d:	bf 0a 00 00 00       	mov    $0xa,%edi
  800552:	eb 13                	jmp    800567 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  800554:	89 ca                	mov    %ecx,%edx
  800556:	8d 45 14             	lea    0x14(%ebp),%eax
  800559:	e8 d3 fc ff ff       	call   800231 <getuint>
  80055e:	89 d1                	mov    %edx,%ecx
  800560:	89 c2                	mov    %eax,%edx
			base = 10;
  800562:	bf 0a 00 00 00       	mov    $0xa,%edi
			printnum(putch, putdat, num, base, width, padc);
  800567:	83 ec 0c             	sub    $0xc,%esp
  80056a:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  80056e:	50                   	push   %eax
  80056f:	ff 75 e0             	push   -0x20(%ebp)
  800572:	57                   	push   %edi
  800573:	51                   	push   %ecx
  800574:	52                   	push   %edx
  800575:	89 f2                	mov    %esi,%edx
  800577:	89 d8                	mov    %ebx,%eax
  800579:	e8 0a fc ff ff       	call   800188 <printnum>
			break;
  80057e:	83 c4 20             	add    $0x20,%esp
{
  800581:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800584:	e9 60 fd ff ff       	jmp    8002e9 <vprintfmt+0x1e>
			num = getuint(&ap, lflag);
  800589:	89 ca                	mov    %ecx,%edx
  80058b:	8d 45 14             	lea    0x14(%ebp),%eax
  80058e:	e8 9e fc ff ff       	call   800231 <getuint>
  800593:	89 d1                	mov    %edx,%ecx
  800595:	89 c2                	mov    %eax,%edx
			base = 8;
  800597:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  80059c:	eb c9                	jmp    800567 <vprintfmt+0x29c>
			putch('0', putdat);
  80059e:	83 ec 08             	sub    $0x8,%esp
  8005a1:	56                   	push   %esi
  8005a2:	6a 30                	push   $0x30
  8005a4:	ff d3                	call   *%ebx
			putch('x', putdat);
  8005a6:	83 c4 08             	add    $0x8,%esp
  8005a9:	56                   	push   %esi
  8005aa:	6a 78                	push   $0x78
  8005ac:	ff d3                	call   *%ebx
			num = (unsigned long long) (uintptr_t) va_arg(ap, void *);
  8005ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b1:	8d 50 04             	lea    0x4(%eax),%edx
  8005b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b7:	8b 10                	mov    (%eax),%edx
  8005b9:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8005be:	83 c4 10             	add    $0x10,%esp
			base = 16;
  8005c1:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  8005c6:	eb 9f                	jmp    800567 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  8005c8:	89 ca                	mov    %ecx,%edx
  8005ca:	8d 45 14             	lea    0x14(%ebp),%eax
  8005cd:	e8 5f fc ff ff       	call   800231 <getuint>
  8005d2:	89 d1                	mov    %edx,%ecx
  8005d4:	89 c2                	mov    %eax,%edx
			base = 16;
  8005d6:	bf 10 00 00 00       	mov    $0x10,%edi
  8005db:	eb 8a                	jmp    800567 <vprintfmt+0x29c>
			putch(ch, putdat);
  8005dd:	83 ec 08             	sub    $0x8,%esp
  8005e0:	56                   	push   %esi
  8005e1:	6a 25                	push   $0x25
  8005e3:	ff d3                	call   *%ebx
			break;
  8005e5:	83 c4 10             	add    $0x10,%esp
  8005e8:	eb 97                	jmp    800581 <vprintfmt+0x2b6>
			putch('%', putdat);
  8005ea:	83 ec 08             	sub    $0x8,%esp
  8005ed:	56                   	push   %esi
  8005ee:	6a 25                	push   $0x25
  8005f0:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  8005f2:	83 c4 10             	add    $0x10,%esp
  8005f5:	89 f8                	mov    %edi,%eax
  8005f7:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8005fb:	74 05                	je     800602 <vprintfmt+0x337>
  8005fd:	83 e8 01             	sub    $0x1,%eax
  800600:	eb f5                	jmp    8005f7 <vprintfmt+0x32c>
  800602:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800605:	e9 77 ff ff ff       	jmp    800581 <vprintfmt+0x2b6>

0080060a <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80060a:	55                   	push   %ebp
  80060b:	89 e5                	mov    %esp,%ebp
  80060d:	83 ec 18             	sub    $0x18,%esp
  800610:	8b 45 08             	mov    0x8(%ebp),%eax
  800613:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = { buf, buf + n - 1, 0 };
  800616:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800619:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80061d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800620:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800627:	85 c0                	test   %eax,%eax
  800629:	74 26                	je     800651 <vsnprintf+0x47>
  80062b:	85 d2                	test   %edx,%edx
  80062d:	7e 22                	jle    800651 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *) sprintputch, &b, fmt, ap);
  80062f:	ff 75 14             	push   0x14(%ebp)
  800632:	ff 75 10             	push   0x10(%ebp)
  800635:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800638:	50                   	push   %eax
  800639:	68 91 02 80 00       	push   $0x800291
  80063e:	e8 88 fc ff ff       	call   8002cb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800643:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800646:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800649:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80064c:	83 c4 10             	add    $0x10,%esp
}
  80064f:	c9                   	leave  
  800650:	c3                   	ret    
		return -E_INVAL;
  800651:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800656:	eb f7                	jmp    80064f <vsnprintf+0x45>

00800658 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800658:	55                   	push   %ebp
  800659:	89 e5                	mov    %esp,%ebp
  80065b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80065e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800661:	50                   	push   %eax
  800662:	ff 75 10             	push   0x10(%ebp)
  800665:	ff 75 0c             	push   0xc(%ebp)
  800668:	ff 75 08             	push   0x8(%ebp)
  80066b:	e8 9a ff ff ff       	call   80060a <vsnprintf>
	va_end(ap);

	return rc;
}
  800670:	c9                   	leave  
  800671:	c3                   	ret    

00800672 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800672:	55                   	push   %ebp
  800673:	89 e5                	mov    %esp,%ebp
  800675:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800678:	b8 00 00 00 00       	mov    $0x0,%eax
  80067d:	eb 03                	jmp    800682 <strlen+0x10>
		n++;
  80067f:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800682:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800686:	75 f7                	jne    80067f <strlen+0xd>
	return n;
}
  800688:	5d                   	pop    %ebp
  800689:	c3                   	ret    

0080068a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80068a:	55                   	push   %ebp
  80068b:	89 e5                	mov    %esp,%ebp
  80068d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800690:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800693:	b8 00 00 00 00       	mov    $0x0,%eax
  800698:	eb 03                	jmp    80069d <strnlen+0x13>
		n++;
  80069a:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80069d:	39 d0                	cmp    %edx,%eax
  80069f:	74 08                	je     8006a9 <strnlen+0x1f>
  8006a1:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8006a5:	75 f3                	jne    80069a <strnlen+0x10>
  8006a7:	89 c2                	mov    %eax,%edx
	return n;
}
  8006a9:	89 d0                	mov    %edx,%eax
  8006ab:	5d                   	pop    %ebp
  8006ac:	c3                   	ret    

008006ad <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006ad:	55                   	push   %ebp
  8006ae:	89 e5                	mov    %esp,%ebp
  8006b0:	53                   	push   %ebx
  8006b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8006bc:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8006c0:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8006c3:	83 c0 01             	add    $0x1,%eax
  8006c6:	84 d2                	test   %dl,%dl
  8006c8:	75 f2                	jne    8006bc <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8006ca:	89 c8                	mov    %ecx,%eax
  8006cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006cf:	c9                   	leave  
  8006d0:	c3                   	ret    

008006d1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8006d1:	55                   	push   %ebp
  8006d2:	89 e5                	mov    %esp,%ebp
  8006d4:	53                   	push   %ebx
  8006d5:	83 ec 10             	sub    $0x10,%esp
  8006d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8006db:	53                   	push   %ebx
  8006dc:	e8 91 ff ff ff       	call   800672 <strlen>
  8006e1:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8006e4:	ff 75 0c             	push   0xc(%ebp)
  8006e7:	01 d8                	add    %ebx,%eax
  8006e9:	50                   	push   %eax
  8006ea:	e8 be ff ff ff       	call   8006ad <strcpy>
	return dst;
}
  8006ef:	89 d8                	mov    %ebx,%eax
  8006f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006f4:	c9                   	leave  
  8006f5:	c3                   	ret    

008006f6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size)
{
  8006f6:	55                   	push   %ebp
  8006f7:	89 e5                	mov    %esp,%ebp
  8006f9:	56                   	push   %esi
  8006fa:	53                   	push   %ebx
  8006fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8006fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800701:	89 f3                	mov    %esi,%ebx
  800703:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800706:	89 f0                	mov    %esi,%eax
  800708:	eb 0f                	jmp    800719 <strncpy+0x23>
		*dst++ = *src;
  80070a:	83 c0 01             	add    $0x1,%eax
  80070d:	0f b6 0a             	movzbl (%edx),%ecx
  800710:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800713:	80 f9 01             	cmp    $0x1,%cl
  800716:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800719:	39 d8                	cmp    %ebx,%eax
  80071b:	75 ed                	jne    80070a <strncpy+0x14>
	}
	return ret;
}
  80071d:	89 f0                	mov    %esi,%eax
  80071f:	5b                   	pop    %ebx
  800720:	5e                   	pop    %esi
  800721:	5d                   	pop    %ebp
  800722:	c3                   	ret    

00800723 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800723:	55                   	push   %ebp
  800724:	89 e5                	mov    %esp,%ebp
  800726:	56                   	push   %esi
  800727:	53                   	push   %ebx
  800728:	8b 75 08             	mov    0x8(%ebp),%esi
  80072b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80072e:	8b 55 10             	mov    0x10(%ebp),%edx
  800731:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800733:	85 d2                	test   %edx,%edx
  800735:	74 21                	je     800758 <strlcpy+0x35>
  800737:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80073b:	89 f2                	mov    %esi,%edx
  80073d:	eb 09                	jmp    800748 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80073f:	83 c1 01             	add    $0x1,%ecx
  800742:	83 c2 01             	add    $0x1,%edx
  800745:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800748:	39 c2                	cmp    %eax,%edx
  80074a:	74 09                	je     800755 <strlcpy+0x32>
  80074c:	0f b6 19             	movzbl (%ecx),%ebx
  80074f:	84 db                	test   %bl,%bl
  800751:	75 ec                	jne    80073f <strlcpy+0x1c>
  800753:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800755:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800758:	29 f0                	sub    %esi,%eax
}
  80075a:	5b                   	pop    %ebx
  80075b:	5e                   	pop    %esi
  80075c:	5d                   	pop    %ebp
  80075d:	c3                   	ret    

0080075e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80075e:	55                   	push   %ebp
  80075f:	89 e5                	mov    %esp,%ebp
  800761:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800764:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800767:	eb 06                	jmp    80076f <strcmp+0x11>
		p++, q++;
  800769:	83 c1 01             	add    $0x1,%ecx
  80076c:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80076f:	0f b6 01             	movzbl (%ecx),%eax
  800772:	84 c0                	test   %al,%al
  800774:	74 04                	je     80077a <strcmp+0x1c>
  800776:	3a 02                	cmp    (%edx),%al
  800778:	74 ef                	je     800769 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80077a:	0f b6 c0             	movzbl %al,%eax
  80077d:	0f b6 12             	movzbl (%edx),%edx
  800780:	29 d0                	sub    %edx,%eax
}
  800782:	5d                   	pop    %ebp
  800783:	c3                   	ret    

00800784 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800784:	55                   	push   %ebp
  800785:	89 e5                	mov    %esp,%ebp
  800787:	53                   	push   %ebx
  800788:	8b 45 08             	mov    0x8(%ebp),%eax
  80078b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80078e:	89 c3                	mov    %eax,%ebx
  800790:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800793:	eb 06                	jmp    80079b <strncmp+0x17>
		n--, p++, q++;
  800795:	83 c0 01             	add    $0x1,%eax
  800798:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80079b:	39 d8                	cmp    %ebx,%eax
  80079d:	74 18                	je     8007b7 <strncmp+0x33>
  80079f:	0f b6 08             	movzbl (%eax),%ecx
  8007a2:	84 c9                	test   %cl,%cl
  8007a4:	74 04                	je     8007aa <strncmp+0x26>
  8007a6:	3a 0a                	cmp    (%edx),%cl
  8007a8:	74 eb                	je     800795 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007aa:	0f b6 00             	movzbl (%eax),%eax
  8007ad:	0f b6 12             	movzbl (%edx),%edx
  8007b0:	29 d0                	sub    %edx,%eax
}
  8007b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b5:	c9                   	leave  
  8007b6:	c3                   	ret    
		return 0;
  8007b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8007bc:	eb f4                	jmp    8007b2 <strncmp+0x2e>

008007be <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007be:	55                   	push   %ebp
  8007bf:	89 e5                	mov    %esp,%ebp
  8007c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007c8:	eb 03                	jmp    8007cd <strchr+0xf>
  8007ca:	83 c0 01             	add    $0x1,%eax
  8007cd:	0f b6 10             	movzbl (%eax),%edx
  8007d0:	84 d2                	test   %dl,%dl
  8007d2:	74 06                	je     8007da <strchr+0x1c>
		if (*s == c)
  8007d4:	38 ca                	cmp    %cl,%dl
  8007d6:	75 f2                	jne    8007ca <strchr+0xc>
  8007d8:	eb 05                	jmp    8007df <strchr+0x21>
			return (char *) s;
	return 0;
  8007da:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007df:	5d                   	pop    %ebp
  8007e0:	c3                   	ret    

008007e1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8007e1:	55                   	push   %ebp
  8007e2:	89 e5                	mov    %esp,%ebp
  8007e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007eb:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8007ee:	38 ca                	cmp    %cl,%dl
  8007f0:	74 09                	je     8007fb <strfind+0x1a>
  8007f2:	84 d2                	test   %dl,%dl
  8007f4:	74 05                	je     8007fb <strfind+0x1a>
	for (; *s; s++)
  8007f6:	83 c0 01             	add    $0x1,%eax
  8007f9:	eb f0                	jmp    8007eb <strfind+0xa>
			break;
	return (char *) s;
}
  8007fb:	5d                   	pop    %ebp
  8007fc:	c3                   	ret    

008007fd <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8007fd:	55                   	push   %ebp
  8007fe:	89 e5                	mov    %esp,%ebp
  800800:	57                   	push   %edi
  800801:	56                   	push   %esi
  800802:	53                   	push   %ebx
  800803:	8b 55 08             	mov    0x8(%ebp),%edx
  800806:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  800809:	85 c9                	test   %ecx,%ecx
  80080b:	74 33                	je     800840 <memset+0x43>
		return v;
	if ((int) v % 4 == 0 && n % 4 == 0) {
  80080d:	89 d0                	mov    %edx,%eax
  80080f:	09 c8                	or     %ecx,%eax
  800811:	a8 03                	test   $0x3,%al
  800813:	75 23                	jne    800838 <memset+0x3b>
		c &= 0xFF;
  800815:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  800819:	89 d8                	mov    %ebx,%eax
  80081b:	c1 e0 08             	shl    $0x8,%eax
  80081e:	89 df                	mov    %ebx,%edi
  800820:	c1 e7 18             	shl    $0x18,%edi
  800823:	89 de                	mov    %ebx,%esi
  800825:	c1 e6 10             	shl    $0x10,%esi
  800828:	09 f7                	or     %esi,%edi
  80082a:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
		             : "=D"(p), "=c"(n)
		             : "D"(p), "a"(c), "c"(n / 4)
  80082c:	c1 e9 02             	shr    $0x2,%ecx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  80082f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800831:	89 d7                	mov    %edx,%edi
  800833:	fc                   	cld    
  800834:	f3 ab                	rep stos %eax,%es:(%edi)
  800836:	eb 08                	jmp    800840 <memset+0x43>
		             : "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800838:	89 d7                	mov    %edx,%edi
  80083a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80083d:	fc                   	cld    
  80083e:	f3 aa                	rep stos %al,%es:(%edi)
		             : "=D"(p), "=c"(n)
		             : "0"(p), "a"(c), "1"(n)
		             : "cc", "memory");
	return v;
}
  800840:	89 d0                	mov    %edx,%eax
  800842:	5b                   	pop    %ebx
  800843:	5e                   	pop    %esi
  800844:	5f                   	pop    %edi
  800845:	5d                   	pop    %ebp
  800846:	c3                   	ret    

00800847 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800847:	55                   	push   %ebp
  800848:	89 e5                	mov    %esp,%ebp
  80084a:	57                   	push   %edi
  80084b:	56                   	push   %esi
  80084c:	8b 45 08             	mov    0x8(%ebp),%eax
  80084f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800852:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800855:	39 c6                	cmp    %eax,%esi
  800857:	73 32                	jae    80088b <memmove+0x44>
  800859:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80085c:	39 c2                	cmp    %eax,%edx
  80085e:	76 2b                	jbe    80088b <memmove+0x44>
		s += n;
		d += n;
  800860:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  800863:	89 d6                	mov    %edx,%esi
  800865:	09 fe                	or     %edi,%esi
  800867:	09 ce                	or     %ecx,%esi
  800869:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80086f:	75 0e                	jne    80087f <memmove+0x38>
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  800871:	83 ef 04             	sub    $0x4,%edi
			             "S"(s - 4),
  800874:	8d 72 fc             	lea    -0x4(%edx),%esi
			             "c"(n / 4)
  800877:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  80087a:	fd                   	std    
  80087b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80087d:	eb 09                	jmp    800888 <memmove+0x41>
			             : "cc", "memory");
		else
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  80087f:	83 ef 01             	sub    $0x1,%edi
			             "S"(s - 1),
  800882:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  800885:	fd                   	std    
  800886:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             "c"(n)
			             : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800888:	fc                   	cld    
  800889:	eb 1a                	jmp    8008a5 <memmove+0x5e>
	} else {
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  80088b:	89 f2                	mov    %esi,%edx
  80088d:	09 c2                	or     %eax,%edx
  80088f:	09 ca                	or     %ecx,%edx
  800891:	f6 c2 03             	test   $0x3,%dl
  800894:	75 0a                	jne    8008a0 <memmove+0x59>
			asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800896:	c1 e9 02             	shr    $0x2,%ecx
  800899:	89 c7                	mov    %eax,%edi
  80089b:	fc                   	cld    
  80089c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80089e:	eb 05                	jmp    8008a5 <memmove+0x5e>
			             : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  8008a0:	89 c7                	mov    %eax,%edi
  8008a2:	fc                   	cld    
  8008a3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             : "cc", "memory");
	}
	return dst;
}
  8008a5:	5e                   	pop    %esi
  8008a6:	5f                   	pop    %edi
  8008a7:	5d                   	pop    %ebp
  8008a8:	c3                   	ret    

008008a9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008a9:	55                   	push   %ebp
  8008aa:	89 e5                	mov    %esp,%ebp
  8008ac:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8008af:	ff 75 10             	push   0x10(%ebp)
  8008b2:	ff 75 0c             	push   0xc(%ebp)
  8008b5:	ff 75 08             	push   0x8(%ebp)
  8008b8:	e8 8a ff ff ff       	call   800847 <memmove>
}
  8008bd:	c9                   	leave  
  8008be:	c3                   	ret    

008008bf <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008bf:	55                   	push   %ebp
  8008c0:	89 e5                	mov    %esp,%ebp
  8008c2:	56                   	push   %esi
  8008c3:	53                   	push   %ebx
  8008c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ca:	89 c6                	mov    %eax,%esi
  8008cc:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8008cf:	eb 06                	jmp    8008d7 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8008d1:	83 c0 01             	add    $0x1,%eax
  8008d4:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  8008d7:	39 f0                	cmp    %esi,%eax
  8008d9:	74 14                	je     8008ef <memcmp+0x30>
		if (*s1 != *s2)
  8008db:	0f b6 08             	movzbl (%eax),%ecx
  8008de:	0f b6 1a             	movzbl (%edx),%ebx
  8008e1:	38 d9                	cmp    %bl,%cl
  8008e3:	74 ec                	je     8008d1 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  8008e5:	0f b6 c1             	movzbl %cl,%eax
  8008e8:	0f b6 db             	movzbl %bl,%ebx
  8008eb:	29 d8                	sub    %ebx,%eax
  8008ed:	eb 05                	jmp    8008f4 <memcmp+0x35>
	}

	return 0;
  8008ef:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008f4:	5b                   	pop    %ebx
  8008f5:	5e                   	pop    %esi
  8008f6:	5d                   	pop    %ebp
  8008f7:	c3                   	ret    

008008f8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8008f8:	55                   	push   %ebp
  8008f9:	89 e5                	mov    %esp,%ebp
  8008fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800901:	89 c2                	mov    %eax,%edx
  800903:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800906:	eb 03                	jmp    80090b <memfind+0x13>
  800908:	83 c0 01             	add    $0x1,%eax
  80090b:	39 d0                	cmp    %edx,%eax
  80090d:	73 04                	jae    800913 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  80090f:	38 08                	cmp    %cl,(%eax)
  800911:	75 f5                	jne    800908 <memfind+0x10>
			break;
	return (void *) s;
}
  800913:	5d                   	pop    %ebp
  800914:	c3                   	ret    

00800915 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800915:	55                   	push   %ebp
  800916:	89 e5                	mov    %esp,%ebp
  800918:	57                   	push   %edi
  800919:	56                   	push   %esi
  80091a:	53                   	push   %ebx
  80091b:	8b 55 08             	mov    0x8(%ebp),%edx
  80091e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800921:	eb 03                	jmp    800926 <strtol+0x11>
		s++;
  800923:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800926:	0f b6 02             	movzbl (%edx),%eax
  800929:	3c 20                	cmp    $0x20,%al
  80092b:	74 f6                	je     800923 <strtol+0xe>
  80092d:	3c 09                	cmp    $0x9,%al
  80092f:	74 f2                	je     800923 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800931:	3c 2b                	cmp    $0x2b,%al
  800933:	74 2a                	je     80095f <strtol+0x4a>
	int neg = 0;
  800935:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  80093a:	3c 2d                	cmp    $0x2d,%al
  80093c:	74 2b                	je     800969 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80093e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800944:	75 0f                	jne    800955 <strtol+0x40>
  800946:	80 3a 30             	cmpb   $0x30,(%edx)
  800949:	74 28                	je     800973 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80094b:	85 db                	test   %ebx,%ebx
  80094d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800952:	0f 44 d8             	cmove  %eax,%ebx
  800955:	b9 00 00 00 00       	mov    $0x0,%ecx
  80095a:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80095d:	eb 46                	jmp    8009a5 <strtol+0x90>
		s++;
  80095f:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800962:	bf 00 00 00 00       	mov    $0x0,%edi
  800967:	eb d5                	jmp    80093e <strtol+0x29>
		s++, neg = 1;
  800969:	83 c2 01             	add    $0x1,%edx
  80096c:	bf 01 00 00 00       	mov    $0x1,%edi
  800971:	eb cb                	jmp    80093e <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800973:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800977:	74 0e                	je     800987 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800979:	85 db                	test   %ebx,%ebx
  80097b:	75 d8                	jne    800955 <strtol+0x40>
		s++, base = 8;
  80097d:	83 c2 01             	add    $0x1,%edx
  800980:	bb 08 00 00 00       	mov    $0x8,%ebx
  800985:	eb ce                	jmp    800955 <strtol+0x40>
		s += 2, base = 16;
  800987:	83 c2 02             	add    $0x2,%edx
  80098a:	bb 10 00 00 00       	mov    $0x10,%ebx
  80098f:	eb c4                	jmp    800955 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800991:	0f be c0             	movsbl %al,%eax
  800994:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800997:	3b 45 10             	cmp    0x10(%ebp),%eax
  80099a:	7d 3a                	jge    8009d6 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  80099c:	83 c2 01             	add    $0x1,%edx
  80099f:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  8009a3:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  8009a5:	0f b6 02             	movzbl (%edx),%eax
  8009a8:	8d 70 d0             	lea    -0x30(%eax),%esi
  8009ab:	89 f3                	mov    %esi,%ebx
  8009ad:	80 fb 09             	cmp    $0x9,%bl
  8009b0:	76 df                	jbe    800991 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  8009b2:	8d 70 9f             	lea    -0x61(%eax),%esi
  8009b5:	89 f3                	mov    %esi,%ebx
  8009b7:	80 fb 19             	cmp    $0x19,%bl
  8009ba:	77 08                	ja     8009c4 <strtol+0xaf>
			dig = *s - 'a' + 10;
  8009bc:	0f be c0             	movsbl %al,%eax
  8009bf:	83 e8 57             	sub    $0x57,%eax
  8009c2:	eb d3                	jmp    800997 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  8009c4:	8d 70 bf             	lea    -0x41(%eax),%esi
  8009c7:	89 f3                	mov    %esi,%ebx
  8009c9:	80 fb 19             	cmp    $0x19,%bl
  8009cc:	77 08                	ja     8009d6 <strtol+0xc1>
			dig = *s - 'A' + 10;
  8009ce:	0f be c0             	movsbl %al,%eax
  8009d1:	83 e8 37             	sub    $0x37,%eax
  8009d4:	eb c1                	jmp    800997 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  8009d6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8009da:	74 05                	je     8009e1 <strtol+0xcc>
		*endptr = (char *) s;
  8009dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009df:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  8009e1:	89 c8                	mov    %ecx,%eax
  8009e3:	f7 d8                	neg    %eax
  8009e5:	85 ff                	test   %edi,%edi
  8009e7:	0f 45 c8             	cmovne %eax,%ecx
}
  8009ea:	89 c8                	mov    %ecx,%eax
  8009ec:	5b                   	pop    %ebx
  8009ed:	5e                   	pop    %esi
  8009ee:	5f                   	pop    %edi
  8009ef:	5d                   	pop    %ebp
  8009f0:	c3                   	ret    

008009f1 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8009f1:	55                   	push   %ebp
  8009f2:	89 e5                	mov    %esp,%ebp
  8009f4:	57                   	push   %edi
  8009f5:	56                   	push   %esi
  8009f6:	53                   	push   %ebx
  8009f7:	83 ec 1c             	sub    $0x1c,%esp
  8009fa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009fd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800a00:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile(
  800a02:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a05:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a08:	8b 7d 10             	mov    0x10(%ebp),%edi
  800a0b:	8b 75 14             	mov    0x14(%ebp),%esi
  800a0e:	cd 30                	int    $0x30
	        "int %1\n"
	        : "=a"(ret)
	        : "i"(T_SYSCALL), "a"(num), "d"(a1), "c"(a2), "b"(a3), "D"(a4), "S"(a5)
	        : "cc", "memory");

	if (check && ret > 0)
  800a10:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a14:	74 04                	je     800a1a <syscall+0x29>
  800a16:	85 c0                	test   %eax,%eax
  800a18:	7f 08                	jg     800a22 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800a1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a1d:	5b                   	pop    %ebx
  800a1e:	5e                   	pop    %esi
  800a1f:	5f                   	pop    %edi
  800a20:	5d                   	pop    %ebp
  800a21:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800a22:	83 ec 0c             	sub    $0xc,%esp
  800a25:	50                   	push   %eax
  800a26:	ff 75 e0             	push   -0x20(%ebp)
  800a29:	68 a4 11 80 00       	push   $0x8011a4
  800a2e:	6a 1e                	push   $0x1e
  800a30:	68 c1 11 80 00       	push   $0x8011c1
  800a35:	e8 65 02 00 00       	call   800c9f <_panic>

00800a3a <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800a3a:	55                   	push   %ebp
  800a3b:	89 e5                	mov    %esp,%ebp
  800a3d:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t) s, len, 0, 0, 0);
  800a40:	6a 00                	push   $0x0
  800a42:	6a 00                	push   $0x0
  800a44:	6a 00                	push   $0x0
  800a46:	ff 75 0c             	push   0xc(%ebp)
  800a49:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a4c:	ba 00 00 00 00       	mov    $0x0,%edx
  800a51:	b8 00 00 00 00       	mov    $0x0,%eax
  800a56:	e8 96 ff ff ff       	call   8009f1 <syscall>
}
  800a5b:	83 c4 10             	add    $0x10,%esp
  800a5e:	c9                   	leave  
  800a5f:	c3                   	ret    

00800a60 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a60:	55                   	push   %ebp
  800a61:	89 e5                	mov    %esp,%ebp
  800a63:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800a66:	6a 00                	push   $0x0
  800a68:	6a 00                	push   $0x0
  800a6a:	6a 00                	push   $0x0
  800a6c:	6a 00                	push   $0x0
  800a6e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a73:	ba 00 00 00 00       	mov    $0x0,%edx
  800a78:	b8 01 00 00 00       	mov    $0x1,%eax
  800a7d:	e8 6f ff ff ff       	call   8009f1 <syscall>
}
  800a82:	c9                   	leave  
  800a83:	c3                   	ret    

00800a84 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a84:	55                   	push   %ebp
  800a85:	89 e5                	mov    %esp,%ebp
  800a87:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800a8a:	6a 00                	push   $0x0
  800a8c:	6a 00                	push   $0x0
  800a8e:	6a 00                	push   $0x0
  800a90:	6a 00                	push   $0x0
  800a92:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a95:	ba 01 00 00 00       	mov    $0x1,%edx
  800a9a:	b8 03 00 00 00       	mov    $0x3,%eax
  800a9f:	e8 4d ff ff ff       	call   8009f1 <syscall>
}
  800aa4:	c9                   	leave  
  800aa5:	c3                   	ret    

00800aa6 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800aa6:	55                   	push   %ebp
  800aa7:	89 e5                	mov    %esp,%ebp
  800aa9:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800aac:	6a 00                	push   $0x0
  800aae:	6a 00                	push   $0x0
  800ab0:	6a 00                	push   $0x0
  800ab2:	6a 00                	push   $0x0
  800ab4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ab9:	ba 00 00 00 00       	mov    $0x0,%edx
  800abe:	b8 02 00 00 00       	mov    $0x2,%eax
  800ac3:	e8 29 ff ff ff       	call   8009f1 <syscall>
}
  800ac8:	c9                   	leave  
  800ac9:	c3                   	ret    

00800aca <sys_yield>:

void
sys_yield(void)
{
  800aca:	55                   	push   %ebp
  800acb:	89 e5                	mov    %esp,%ebp
  800acd:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800ad0:	6a 00                	push   $0x0
  800ad2:	6a 00                	push   $0x0
  800ad4:	6a 00                	push   $0x0
  800ad6:	6a 00                	push   $0x0
  800ad8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800add:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ae7:	e8 05 ff ff ff       	call   8009f1 <syscall>
}
  800aec:	83 c4 10             	add    $0x10,%esp
  800aef:	c9                   	leave  
  800af0:	c3                   	ret    

00800af1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800af1:	55                   	push   %ebp
  800af2:	89 e5                	mov    %esp,%ebp
  800af4:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800af7:	6a 00                	push   $0x0
  800af9:	6a 00                	push   $0x0
  800afb:	ff 75 10             	push   0x10(%ebp)
  800afe:	ff 75 0c             	push   0xc(%ebp)
  800b01:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b04:	ba 01 00 00 00       	mov    $0x1,%edx
  800b09:	b8 04 00 00 00       	mov    $0x4,%eax
  800b0e:	e8 de fe ff ff       	call   8009f1 <syscall>
}
  800b13:	c9                   	leave  
  800b14:	c3                   	ret    

00800b15 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b15:	55                   	push   %ebp
  800b16:	89 e5                	mov    %esp,%ebp
  800b18:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map,
  800b1b:	ff 75 18             	push   0x18(%ebp)
  800b1e:	ff 75 14             	push   0x14(%ebp)
  800b21:	ff 75 10             	push   0x10(%ebp)
  800b24:	ff 75 0c             	push   0xc(%ebp)
  800b27:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b2a:	ba 01 00 00 00       	mov    $0x1,%edx
  800b2f:	b8 05 00 00 00       	mov    $0x5,%eax
  800b34:	e8 b8 fe ff ff       	call   8009f1 <syscall>
	               srcenv,
	               (uint32_t) srcva,
	               dstenv,
	               (uint32_t) dstva,
	               perm);
}
  800b39:	c9                   	leave  
  800b3a:	c3                   	ret    

00800b3b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b3b:	55                   	push   %ebp
  800b3c:	89 e5                	mov    %esp,%ebp
  800b3e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800b41:	6a 00                	push   $0x0
  800b43:	6a 00                	push   $0x0
  800b45:	6a 00                	push   $0x0
  800b47:	ff 75 0c             	push   0xc(%ebp)
  800b4a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b4d:	ba 01 00 00 00       	mov    $0x1,%edx
  800b52:	b8 06 00 00 00       	mov    $0x6,%eax
  800b57:	e8 95 fe ff ff       	call   8009f1 <syscall>
}
  800b5c:	c9                   	leave  
  800b5d:	c3                   	ret    

00800b5e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800b5e:	55                   	push   %ebp
  800b5f:	89 e5                	mov    %esp,%ebp
  800b61:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800b64:	6a 00                	push   $0x0
  800b66:	6a 00                	push   $0x0
  800b68:	6a 00                	push   $0x0
  800b6a:	ff 75 0c             	push   0xc(%ebp)
  800b6d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b70:	ba 01 00 00 00       	mov    $0x1,%edx
  800b75:	b8 08 00 00 00       	mov    $0x8,%eax
  800b7a:	e8 72 fe ff ff       	call   8009f1 <syscall>
}
  800b7f:	c9                   	leave  
  800b80:	c3                   	ret    

00800b81 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	83 ec 08             	sub    $0x8,%esp
	return syscall(
  800b87:	6a 00                	push   $0x0
  800b89:	6a 00                	push   $0x0
  800b8b:	6a 00                	push   $0x0
  800b8d:	ff 75 0c             	push   0xc(%ebp)
  800b90:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b93:	ba 01 00 00 00       	mov    $0x1,%edx
  800b98:	b8 09 00 00 00       	mov    $0x9,%eax
  800b9d:	e8 4f fe ff ff       	call   8009f1 <syscall>
	        SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ba2:	c9                   	leave  
  800ba3:	c3                   	ret    

00800ba4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ba4:	55                   	push   %ebp
  800ba5:	89 e5                	mov    %esp,%ebp
  800ba7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800baa:	6a 00                	push   $0x0
  800bac:	ff 75 14             	push   0x14(%ebp)
  800baf:	ff 75 10             	push   0x10(%ebp)
  800bb2:	ff 75 0c             	push   0xc(%ebp)
  800bb5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bb8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bbd:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bc2:	e8 2a fe ff ff       	call   8009f1 <syscall>
}
  800bc7:	c9                   	leave  
  800bc8:	c3                   	ret    

00800bc9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800bc9:	55                   	push   %ebp
  800bca:	89 e5                	mov    %esp,%ebp
  800bcc:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t) dstva, 0, 0, 0, 0);
  800bcf:	6a 00                	push   $0x0
  800bd1:	6a 00                	push   $0x0
  800bd3:	6a 00                	push   $0x0
  800bd5:	6a 00                	push   $0x0
  800bd7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bda:	ba 01 00 00 00       	mov    $0x1,%edx
  800bdf:	b8 0c 00 00 00       	mov    $0xc,%eax
  800be4:	e8 08 fe ff ff       	call   8009f1 <syscall>
}
  800be9:	c9                   	leave  
  800bea:	c3                   	ret    

00800beb <sys_get_priority>:

// Get priority of the current process
int
sys_get_priority(void)
{
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_get_priority, 0, 0, 0, 0, 0, 0);
  800bf1:	6a 00                	push   $0x0
  800bf3:	6a 00                	push   $0x0
  800bf5:	6a 00                	push   $0x0
  800bf7:	6a 00                	push   $0x0
  800bf9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bfe:	ba 00 00 00 00       	mov    $0x0,%edx
  800c03:	b8 0d 00 00 00       	mov    $0xd,%eax
  800c08:	e8 e4 fd ff ff       	call   8009f1 <syscall>
}
  800c0d:	c9                   	leave  
  800c0e:	c3                   	ret    

00800c0f <sys_set_priority>:

// Get priority of the current process
int
sys_set_priority(unsigned int priority)
{
  800c0f:	55                   	push   %ebp
  800c10:	89 e5                	mov    %esp,%ebp
  800c12:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, (uint32_t) priority, 0, 0, 0, 0);
  800c15:	6a 00                	push   $0x0
  800c17:	6a 00                	push   $0x0
  800c19:	6a 00                	push   $0x0
  800c1b:	6a 00                	push   $0x0
  800c1d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c20:	ba 00 00 00 00       	mov    $0x0,%edx
  800c25:	b8 0e 00 00 00       	mov    $0xe,%eax
  800c2a:	e8 c2 fd ff ff       	call   8009f1 <syscall>
}
  800c2f:	c9                   	leave  
  800c30:	c3                   	ret    

00800c31 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800c31:	55                   	push   %ebp
  800c32:	89 e5                	mov    %esp,%ebp
  800c34:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800c37:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800c3e:	74 0a                	je     800c4a <set_pgfault_handler+0x19>
		if (r < 0)
			return;
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800c40:	8b 45 08             	mov    0x8(%ebp),%eax
  800c43:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800c48:	c9                   	leave  
  800c49:	c3                   	ret    
		r = sys_page_alloc(0, (void *) exstk, perm);
  800c4a:	83 ec 04             	sub    $0x4,%esp
  800c4d:	6a 07                	push   $0x7
  800c4f:	68 00 f0 bf ee       	push   $0xeebff000
  800c54:	6a 00                	push   $0x0
  800c56:	e8 96 fe ff ff       	call   800af1 <sys_page_alloc>
		if (r < 0)
  800c5b:	83 c4 10             	add    $0x10,%esp
  800c5e:	85 c0                	test   %eax,%eax
  800c60:	78 e6                	js     800c48 <set_pgfault_handler+0x17>
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  800c62:	83 ec 08             	sub    $0x8,%esp
  800c65:	68 7a 0c 80 00       	push   $0x800c7a
  800c6a:	6a 00                	push   $0x0
  800c6c:	e8 10 ff ff ff       	call   800b81 <sys_env_set_pgfault_upcall>
		if (r < 0)
  800c71:	83 c4 10             	add    $0x10,%esp
  800c74:	85 c0                	test   %eax,%eax
  800c76:	79 c8                	jns    800c40 <set_pgfault_handler+0xf>
  800c78:	eb ce                	jmp    800c48 <set_pgfault_handler+0x17>

00800c7a <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800c7a:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800c7b:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800c80:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800c82:	83 c4 04             	add    $0x4,%esp
	// Throughout the remaining code, think carefully about what
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	movl 40(%esp), %eax	// trap-time %epi -> %eax 
  800c85:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %ebx	// trap-time %esp -> %ebx
  800c89:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4, %ebx
  800c8d:	83 eb 04             	sub    $0x4,%ebx
	movl %eax, 0(%ebx)	// push %eip in trap-time stack
  800c90:	89 03                	mov    %eax,(%ebx)

	movl %ebx, 48(%esp)
  800c92:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	popl %eax
  800c96:	58                   	pop    %eax
	popl %eax
  800c97:	58                   	pop    %eax
	popal
  800c98:	61                   	popa   
	

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	addl $4, %esp
  800c99:	83 c4 04             	add    $0x4,%esp
	popfl
  800c9c:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	popl %esp
  800c9d:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	ret
  800c9e:	c3                   	ret    

00800c9f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800c9f:	55                   	push   %ebp
  800ca0:	89 e5                	mov    %esp,%ebp
  800ca2:	56                   	push   %esi
  800ca3:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800ca4:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800ca7:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800cad:	e8 f4 fd ff ff       	call   800aa6 <sys_getenvid>
  800cb2:	83 ec 0c             	sub    $0xc,%esp
  800cb5:	ff 75 0c             	push   0xc(%ebp)
  800cb8:	ff 75 08             	push   0x8(%ebp)
  800cbb:	56                   	push   %esi
  800cbc:	50                   	push   %eax
  800cbd:	68 d0 11 80 00       	push   $0x8011d0
  800cc2:	e8 ad f4 ff ff       	call   800174 <cprintf>
	        sys_getenvid(),
	        binaryname,
	        file,
	        line);
	vcprintf(fmt, ap);
  800cc7:	83 c4 18             	add    $0x18,%esp
  800cca:	53                   	push   %ebx
  800ccb:	ff 75 10             	push   0x10(%ebp)
  800cce:	e8 50 f4 ff ff       	call   800123 <vcprintf>
	cprintf("\n");
  800cd3:	c7 04 24 5a 0f 80 00 	movl   $0x800f5a,(%esp)
  800cda:	e8 95 f4 ff ff       	call   800174 <cprintf>
  800cdf:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800ce2:	cc                   	int3   
  800ce3:	eb fd                	jmp    800ce2 <_panic+0x43>
  800ce5:	66 90                	xchg   %ax,%ax
  800ce7:	66 90                	xchg   %ax,%ax
  800ce9:	66 90                	xchg   %ax,%ax
  800ceb:	66 90                	xchg   %ax,%ax
  800ced:	66 90                	xchg   %ax,%ax
  800cef:	90                   	nop

00800cf0 <__udivdi3>:
  800cf0:	f3 0f 1e fb          	endbr32 
  800cf4:	55                   	push   %ebp
  800cf5:	57                   	push   %edi
  800cf6:	56                   	push   %esi
  800cf7:	53                   	push   %ebx
  800cf8:	83 ec 1c             	sub    $0x1c,%esp
  800cfb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800cff:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800d03:	8b 74 24 34          	mov    0x34(%esp),%esi
  800d07:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800d0b:	85 c0                	test   %eax,%eax
  800d0d:	75 19                	jne    800d28 <__udivdi3+0x38>
  800d0f:	39 f3                	cmp    %esi,%ebx
  800d11:	76 4d                	jbe    800d60 <__udivdi3+0x70>
  800d13:	31 ff                	xor    %edi,%edi
  800d15:	89 e8                	mov    %ebp,%eax
  800d17:	89 f2                	mov    %esi,%edx
  800d19:	f7 f3                	div    %ebx
  800d1b:	89 fa                	mov    %edi,%edx
  800d1d:	83 c4 1c             	add    $0x1c,%esp
  800d20:	5b                   	pop    %ebx
  800d21:	5e                   	pop    %esi
  800d22:	5f                   	pop    %edi
  800d23:	5d                   	pop    %ebp
  800d24:	c3                   	ret    
  800d25:	8d 76 00             	lea    0x0(%esi),%esi
  800d28:	39 f0                	cmp    %esi,%eax
  800d2a:	76 14                	jbe    800d40 <__udivdi3+0x50>
  800d2c:	31 ff                	xor    %edi,%edi
  800d2e:	31 c0                	xor    %eax,%eax
  800d30:	89 fa                	mov    %edi,%edx
  800d32:	83 c4 1c             	add    $0x1c,%esp
  800d35:	5b                   	pop    %ebx
  800d36:	5e                   	pop    %esi
  800d37:	5f                   	pop    %edi
  800d38:	5d                   	pop    %ebp
  800d39:	c3                   	ret    
  800d3a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d40:	0f bd f8             	bsr    %eax,%edi
  800d43:	83 f7 1f             	xor    $0x1f,%edi
  800d46:	75 48                	jne    800d90 <__udivdi3+0xa0>
  800d48:	39 f0                	cmp    %esi,%eax
  800d4a:	72 06                	jb     800d52 <__udivdi3+0x62>
  800d4c:	31 c0                	xor    %eax,%eax
  800d4e:	39 eb                	cmp    %ebp,%ebx
  800d50:	77 de                	ja     800d30 <__udivdi3+0x40>
  800d52:	b8 01 00 00 00       	mov    $0x1,%eax
  800d57:	eb d7                	jmp    800d30 <__udivdi3+0x40>
  800d59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d60:	89 d9                	mov    %ebx,%ecx
  800d62:	85 db                	test   %ebx,%ebx
  800d64:	75 0b                	jne    800d71 <__udivdi3+0x81>
  800d66:	b8 01 00 00 00       	mov    $0x1,%eax
  800d6b:	31 d2                	xor    %edx,%edx
  800d6d:	f7 f3                	div    %ebx
  800d6f:	89 c1                	mov    %eax,%ecx
  800d71:	31 d2                	xor    %edx,%edx
  800d73:	89 f0                	mov    %esi,%eax
  800d75:	f7 f1                	div    %ecx
  800d77:	89 c6                	mov    %eax,%esi
  800d79:	89 e8                	mov    %ebp,%eax
  800d7b:	89 f7                	mov    %esi,%edi
  800d7d:	f7 f1                	div    %ecx
  800d7f:	89 fa                	mov    %edi,%edx
  800d81:	83 c4 1c             	add    $0x1c,%esp
  800d84:	5b                   	pop    %ebx
  800d85:	5e                   	pop    %esi
  800d86:	5f                   	pop    %edi
  800d87:	5d                   	pop    %ebp
  800d88:	c3                   	ret    
  800d89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d90:	89 f9                	mov    %edi,%ecx
  800d92:	ba 20 00 00 00       	mov    $0x20,%edx
  800d97:	29 fa                	sub    %edi,%edx
  800d99:	d3 e0                	shl    %cl,%eax
  800d9b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d9f:	89 d1                	mov    %edx,%ecx
  800da1:	89 d8                	mov    %ebx,%eax
  800da3:	d3 e8                	shr    %cl,%eax
  800da5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800da9:	09 c1                	or     %eax,%ecx
  800dab:	89 f0                	mov    %esi,%eax
  800dad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800db1:	89 f9                	mov    %edi,%ecx
  800db3:	d3 e3                	shl    %cl,%ebx
  800db5:	89 d1                	mov    %edx,%ecx
  800db7:	d3 e8                	shr    %cl,%eax
  800db9:	89 f9                	mov    %edi,%ecx
  800dbb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800dbf:	89 eb                	mov    %ebp,%ebx
  800dc1:	d3 e6                	shl    %cl,%esi
  800dc3:	89 d1                	mov    %edx,%ecx
  800dc5:	d3 eb                	shr    %cl,%ebx
  800dc7:	09 f3                	or     %esi,%ebx
  800dc9:	89 c6                	mov    %eax,%esi
  800dcb:	89 f2                	mov    %esi,%edx
  800dcd:	89 d8                	mov    %ebx,%eax
  800dcf:	f7 74 24 08          	divl   0x8(%esp)
  800dd3:	89 d6                	mov    %edx,%esi
  800dd5:	89 c3                	mov    %eax,%ebx
  800dd7:	f7 64 24 0c          	mull   0xc(%esp)
  800ddb:	39 d6                	cmp    %edx,%esi
  800ddd:	72 19                	jb     800df8 <__udivdi3+0x108>
  800ddf:	89 f9                	mov    %edi,%ecx
  800de1:	d3 e5                	shl    %cl,%ebp
  800de3:	39 c5                	cmp    %eax,%ebp
  800de5:	73 04                	jae    800deb <__udivdi3+0xfb>
  800de7:	39 d6                	cmp    %edx,%esi
  800de9:	74 0d                	je     800df8 <__udivdi3+0x108>
  800deb:	89 d8                	mov    %ebx,%eax
  800ded:	31 ff                	xor    %edi,%edi
  800def:	e9 3c ff ff ff       	jmp    800d30 <__udivdi3+0x40>
  800df4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800df8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800dfb:	31 ff                	xor    %edi,%edi
  800dfd:	e9 2e ff ff ff       	jmp    800d30 <__udivdi3+0x40>
  800e02:	66 90                	xchg   %ax,%ax
  800e04:	66 90                	xchg   %ax,%ax
  800e06:	66 90                	xchg   %ax,%ax
  800e08:	66 90                	xchg   %ax,%ax
  800e0a:	66 90                	xchg   %ax,%ax
  800e0c:	66 90                	xchg   %ax,%ax
  800e0e:	66 90                	xchg   %ax,%ax

00800e10 <__umoddi3>:
  800e10:	f3 0f 1e fb          	endbr32 
  800e14:	55                   	push   %ebp
  800e15:	57                   	push   %edi
  800e16:	56                   	push   %esi
  800e17:	53                   	push   %ebx
  800e18:	83 ec 1c             	sub    $0x1c,%esp
  800e1b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800e1f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800e23:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  800e27:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  800e2b:	89 f0                	mov    %esi,%eax
  800e2d:	89 da                	mov    %ebx,%edx
  800e2f:	85 ff                	test   %edi,%edi
  800e31:	75 15                	jne    800e48 <__umoddi3+0x38>
  800e33:	39 dd                	cmp    %ebx,%ebp
  800e35:	76 39                	jbe    800e70 <__umoddi3+0x60>
  800e37:	f7 f5                	div    %ebp
  800e39:	89 d0                	mov    %edx,%eax
  800e3b:	31 d2                	xor    %edx,%edx
  800e3d:	83 c4 1c             	add    $0x1c,%esp
  800e40:	5b                   	pop    %ebx
  800e41:	5e                   	pop    %esi
  800e42:	5f                   	pop    %edi
  800e43:	5d                   	pop    %ebp
  800e44:	c3                   	ret    
  800e45:	8d 76 00             	lea    0x0(%esi),%esi
  800e48:	39 df                	cmp    %ebx,%edi
  800e4a:	77 f1                	ja     800e3d <__umoddi3+0x2d>
  800e4c:	0f bd cf             	bsr    %edi,%ecx
  800e4f:	83 f1 1f             	xor    $0x1f,%ecx
  800e52:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800e56:	75 40                	jne    800e98 <__umoddi3+0x88>
  800e58:	39 df                	cmp    %ebx,%edi
  800e5a:	72 04                	jb     800e60 <__umoddi3+0x50>
  800e5c:	39 f5                	cmp    %esi,%ebp
  800e5e:	77 dd                	ja     800e3d <__umoddi3+0x2d>
  800e60:	89 da                	mov    %ebx,%edx
  800e62:	89 f0                	mov    %esi,%eax
  800e64:	29 e8                	sub    %ebp,%eax
  800e66:	19 fa                	sbb    %edi,%edx
  800e68:	eb d3                	jmp    800e3d <__umoddi3+0x2d>
  800e6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e70:	89 e9                	mov    %ebp,%ecx
  800e72:	85 ed                	test   %ebp,%ebp
  800e74:	75 0b                	jne    800e81 <__umoddi3+0x71>
  800e76:	b8 01 00 00 00       	mov    $0x1,%eax
  800e7b:	31 d2                	xor    %edx,%edx
  800e7d:	f7 f5                	div    %ebp
  800e7f:	89 c1                	mov    %eax,%ecx
  800e81:	89 d8                	mov    %ebx,%eax
  800e83:	31 d2                	xor    %edx,%edx
  800e85:	f7 f1                	div    %ecx
  800e87:	89 f0                	mov    %esi,%eax
  800e89:	f7 f1                	div    %ecx
  800e8b:	89 d0                	mov    %edx,%eax
  800e8d:	31 d2                	xor    %edx,%edx
  800e8f:	eb ac                	jmp    800e3d <__umoddi3+0x2d>
  800e91:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e98:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e9c:	ba 20 00 00 00       	mov    $0x20,%edx
  800ea1:	29 c2                	sub    %eax,%edx
  800ea3:	89 c1                	mov    %eax,%ecx
  800ea5:	89 e8                	mov    %ebp,%eax
  800ea7:	d3 e7                	shl    %cl,%edi
  800ea9:	89 d1                	mov    %edx,%ecx
  800eab:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800eaf:	d3 e8                	shr    %cl,%eax
  800eb1:	89 c1                	mov    %eax,%ecx
  800eb3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800eb7:	09 f9                	or     %edi,%ecx
  800eb9:	89 df                	mov    %ebx,%edi
  800ebb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ebf:	89 c1                	mov    %eax,%ecx
  800ec1:	d3 e5                	shl    %cl,%ebp
  800ec3:	89 d1                	mov    %edx,%ecx
  800ec5:	d3 ef                	shr    %cl,%edi
  800ec7:	89 c1                	mov    %eax,%ecx
  800ec9:	89 f0                	mov    %esi,%eax
  800ecb:	d3 e3                	shl    %cl,%ebx
  800ecd:	89 d1                	mov    %edx,%ecx
  800ecf:	89 fa                	mov    %edi,%edx
  800ed1:	d3 e8                	shr    %cl,%eax
  800ed3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800ed8:	09 d8                	or     %ebx,%eax
  800eda:	f7 74 24 08          	divl   0x8(%esp)
  800ede:	89 d3                	mov    %edx,%ebx
  800ee0:	d3 e6                	shl    %cl,%esi
  800ee2:	f7 e5                	mul    %ebp
  800ee4:	89 c7                	mov    %eax,%edi
  800ee6:	89 d1                	mov    %edx,%ecx
  800ee8:	39 d3                	cmp    %edx,%ebx
  800eea:	72 06                	jb     800ef2 <__umoddi3+0xe2>
  800eec:	75 0e                	jne    800efc <__umoddi3+0xec>
  800eee:	39 c6                	cmp    %eax,%esi
  800ef0:	73 0a                	jae    800efc <__umoddi3+0xec>
  800ef2:	29 e8                	sub    %ebp,%eax
  800ef4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800ef8:	89 d1                	mov    %edx,%ecx
  800efa:	89 c7                	mov    %eax,%edi
  800efc:	89 f5                	mov    %esi,%ebp
  800efe:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f02:	29 fd                	sub    %edi,%ebp
  800f04:	19 cb                	sbb    %ecx,%ebx
  800f06:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800f0b:	89 d8                	mov    %ebx,%eax
  800f0d:	d3 e0                	shl    %cl,%eax
  800f0f:	89 f1                	mov    %esi,%ecx
  800f11:	d3 ed                	shr    %cl,%ebp
  800f13:	d3 eb                	shr    %cl,%ebx
  800f15:	09 e8                	or     %ebp,%eax
  800f17:	89 da                	mov    %ebx,%edx
  800f19:	83 c4 1c             	add    $0x1c,%esp
  800f1c:	5b                   	pop    %ebx
  800f1d:	5e                   	pop    %esi
  800f1e:	5f                   	pop    %edi
  800f1f:	5d                   	pop    %ebp
  800f20:	c3                   	ret    
