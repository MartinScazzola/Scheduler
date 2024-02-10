
obj/user/spin:     formato del fichero elf32-i386


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

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 10             	sub    $0x10,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  80003a:	68 c0 13 80 00       	push   $0x8013c0
  80003f:	e8 65 01 00 00       	call   8001a9 <cprintf>
	if ((env = fork()) == 0) {
  800044:	e8 43 0f 00 00       	call   800f8c <fork>
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	85 c0                	test   %eax,%eax
  80004e:	75 12                	jne    800062 <umain+0x2f>
		cprintf("I am the child.  Spinning...\n");
  800050:	83 ec 0c             	sub    $0xc,%esp
  800053:	68 38 14 80 00       	push   $0x801438
  800058:	e8 4c 01 00 00       	call   8001a9 <cprintf>
  80005d:	83 c4 10             	add    $0x10,%esp
  800060:	eb fe                	jmp    800060 <umain+0x2d>
  800062:	89 c3                	mov    %eax,%ebx
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800064:	83 ec 0c             	sub    $0xc,%esp
  800067:	68 e8 13 80 00       	push   $0x8013e8
  80006c:	e8 38 01 00 00       	call   8001a9 <cprintf>
	sys_yield();
  800071:	e8 89 0a 00 00       	call   800aff <sys_yield>
	sys_yield();
  800076:	e8 84 0a 00 00       	call   800aff <sys_yield>
	sys_yield();
  80007b:	e8 7f 0a 00 00       	call   800aff <sys_yield>
	sys_yield();
  800080:	e8 7a 0a 00 00       	call   800aff <sys_yield>
	sys_yield();
  800085:	e8 75 0a 00 00       	call   800aff <sys_yield>
	sys_yield();
  80008a:	e8 70 0a 00 00       	call   800aff <sys_yield>
	sys_yield();
  80008f:	e8 6b 0a 00 00       	call   800aff <sys_yield>
	sys_yield();
  800094:	e8 66 0a 00 00       	call   800aff <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  800099:	c7 04 24 10 14 80 00 	movl   $0x801410,(%esp)
  8000a0:	e8 04 01 00 00       	call   8001a9 <cprintf>
	sys_env_destroy(env);
  8000a5:	89 1c 24             	mov    %ebx,(%esp)
  8000a8:	e8 0c 0a 00 00       	call   800ab9 <sys_env_destroy>
}
  8000ad:	83 c4 10             	add    $0x10,%esp
  8000b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
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
  8000c0:	e8 16 0a 00 00       	call   800adb <sys_getenvid>
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
  8000ee:	e8 40 ff ff ff       	call   800033 <umain>

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
  80010a:	e8 aa 09 00 00       	call   800ab9 <sys_env_destroy>
}
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	c9                   	leave  
  800113:	c3                   	ret    

00800114 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800114:	55                   	push   %ebp
  800115:	89 e5                	mov    %esp,%ebp
  800117:	53                   	push   %ebx
  800118:	83 ec 04             	sub    $0x4,%esp
  80011b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80011e:	8b 13                	mov    (%ebx),%edx
  800120:	8d 42 01             	lea    0x1(%edx),%eax
  800123:	89 03                	mov    %eax,(%ebx)
  800125:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800128:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256 - 1) {
  80012c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800131:	74 09                	je     80013c <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800133:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800137:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80013a:	c9                   	leave  
  80013b:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80013c:	83 ec 08             	sub    $0x8,%esp
  80013f:	68 ff 00 00 00       	push   $0xff
  800144:	8d 43 08             	lea    0x8(%ebx),%eax
  800147:	50                   	push   %eax
  800148:	e8 22 09 00 00       	call   800a6f <sys_cputs>
		b->idx = 0;
  80014d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800153:	83 c4 10             	add    $0x10,%esp
  800156:	eb db                	jmp    800133 <putch+0x1f>

00800158 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800161:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800168:	00 00 00 
	b.cnt = 0;
  80016b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800172:	00 00 00 
	vprintfmt((void *) putch, &b, fmt, ap);
  800175:	ff 75 0c             	push   0xc(%ebp)
  800178:	ff 75 08             	push   0x8(%ebp)
  80017b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800181:	50                   	push   %eax
  800182:	68 14 01 80 00       	push   $0x800114
  800187:	e8 74 01 00 00       	call   800300 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80018c:	83 c4 08             	add    $0x8,%esp
  80018f:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800195:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80019b:	50                   	push   %eax
  80019c:	e8 ce 08 00 00       	call   800a6f <sys_cputs>

	return b.cnt;
}
  8001a1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a7:	c9                   	leave  
  8001a8:	c3                   	ret    

008001a9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a9:	55                   	push   %ebp
  8001aa:	89 e5                	mov    %esp,%ebp
  8001ac:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001af:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b2:	50                   	push   %eax
  8001b3:	ff 75 08             	push   0x8(%ebp)
  8001b6:	e8 9d ff ff ff       	call   800158 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001bb:	c9                   	leave  
  8001bc:	c3                   	ret    

008001bd <printnum>:
         void *putdat,
         unsigned long long num,
         unsigned base,
         int width,
         int padc)
{
  8001bd:	55                   	push   %ebp
  8001be:	89 e5                	mov    %esp,%ebp
  8001c0:	57                   	push   %edi
  8001c1:	56                   	push   %esi
  8001c2:	53                   	push   %ebx
  8001c3:	83 ec 1c             	sub    $0x1c,%esp
  8001c6:	89 c7                	mov    %eax,%edi
  8001c8:	89 d6                	mov    %edx,%esi
  8001ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8001cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d0:	89 d1                	mov    %edx,%ecx
  8001d2:	89 c2                	mov    %eax,%edx
  8001d4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001d7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001da:	8b 45 10             	mov    0x10(%ebp),%eax
  8001dd:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001e3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001ea:	39 c2                	cmp    %eax,%edx
  8001ec:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001ef:	72 3e                	jb     80022f <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f1:	83 ec 0c             	sub    $0xc,%esp
  8001f4:	ff 75 18             	push   0x18(%ebp)
  8001f7:	83 eb 01             	sub    $0x1,%ebx
  8001fa:	53                   	push   %ebx
  8001fb:	50                   	push   %eax
  8001fc:	83 ec 08             	sub    $0x8,%esp
  8001ff:	ff 75 e4             	push   -0x1c(%ebp)
  800202:	ff 75 e0             	push   -0x20(%ebp)
  800205:	ff 75 dc             	push   -0x24(%ebp)
  800208:	ff 75 d8             	push   -0x28(%ebp)
  80020b:	e8 70 0f 00 00       	call   801180 <__udivdi3>
  800210:	83 c4 18             	add    $0x18,%esp
  800213:	52                   	push   %edx
  800214:	50                   	push   %eax
  800215:	89 f2                	mov    %esi,%edx
  800217:	89 f8                	mov    %edi,%eax
  800219:	e8 9f ff ff ff       	call   8001bd <printnum>
  80021e:	83 c4 20             	add    $0x20,%esp
  800221:	eb 13                	jmp    800236 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800223:	83 ec 08             	sub    $0x8,%esp
  800226:	56                   	push   %esi
  800227:	ff 75 18             	push   0x18(%ebp)
  80022a:	ff d7                	call   *%edi
  80022c:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80022f:	83 eb 01             	sub    $0x1,%ebx
  800232:	85 db                	test   %ebx,%ebx
  800234:	7f ed                	jg     800223 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800236:	83 ec 08             	sub    $0x8,%esp
  800239:	56                   	push   %esi
  80023a:	83 ec 04             	sub    $0x4,%esp
  80023d:	ff 75 e4             	push   -0x1c(%ebp)
  800240:	ff 75 e0             	push   -0x20(%ebp)
  800243:	ff 75 dc             	push   -0x24(%ebp)
  800246:	ff 75 d8             	push   -0x28(%ebp)
  800249:	e8 52 10 00 00       	call   8012a0 <__umoddi3>
  80024e:	83 c4 14             	add    $0x14,%esp
  800251:	0f be 80 60 14 80 00 	movsbl 0x801460(%eax),%eax
  800258:	50                   	push   %eax
  800259:	ff d7                	call   *%edi
}
  80025b:	83 c4 10             	add    $0x10,%esp
  80025e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800261:	5b                   	pop    %ebx
  800262:	5e                   	pop    %esi
  800263:	5f                   	pop    %edi
  800264:	5d                   	pop    %ebp
  800265:	c3                   	ret    

00800266 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800266:	83 fa 01             	cmp    $0x1,%edx
  800269:	7f 13                	jg     80027e <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80026b:	85 d2                	test   %edx,%edx
  80026d:	74 1c                	je     80028b <getuint+0x25>
		return va_arg(*ap, unsigned long);
  80026f:	8b 10                	mov    (%eax),%edx
  800271:	8d 4a 04             	lea    0x4(%edx),%ecx
  800274:	89 08                	mov    %ecx,(%eax)
  800276:	8b 02                	mov    (%edx),%eax
  800278:	ba 00 00 00 00       	mov    $0x0,%edx
  80027d:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  80027e:	8b 10                	mov    (%eax),%edx
  800280:	8d 4a 08             	lea    0x8(%edx),%ecx
  800283:	89 08                	mov    %ecx,(%eax)
  800285:	8b 02                	mov    (%edx),%eax
  800287:	8b 52 04             	mov    0x4(%edx),%edx
  80028a:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  80028b:	8b 10                	mov    (%eax),%edx
  80028d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800290:	89 08                	mov    %ecx,(%eax)
  800292:	8b 02                	mov    (%edx),%eax
  800294:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800299:	c3                   	ret    

0080029a <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80029a:	83 fa 01             	cmp    $0x1,%edx
  80029d:	7f 0f                	jg     8002ae <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  80029f:	85 d2                	test   %edx,%edx
  8002a1:	74 18                	je     8002bb <getint+0x21>
		return va_arg(*ap, long);
  8002a3:	8b 10                	mov    (%eax),%edx
  8002a5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a8:	89 08                	mov    %ecx,(%eax)
  8002aa:	8b 02                	mov    (%edx),%eax
  8002ac:	99                   	cltd   
  8002ad:	c3                   	ret    
		return va_arg(*ap, long long);
  8002ae:	8b 10                	mov    (%eax),%edx
  8002b0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002b3:	89 08                	mov    %ecx,(%eax)
  8002b5:	8b 02                	mov    (%edx),%eax
  8002b7:	8b 52 04             	mov    0x4(%edx),%edx
  8002ba:	c3                   	ret    
	else
		return va_arg(*ap, int);
  8002bb:	8b 10                	mov    (%eax),%edx
  8002bd:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c0:	89 08                	mov    %ecx,(%eax)
  8002c2:	8b 02                	mov    (%edx),%eax
  8002c4:	99                   	cltd   
}
  8002c5:	c3                   	ret    

008002c6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002c6:	55                   	push   %ebp
  8002c7:	89 e5                	mov    %esp,%ebp
  8002c9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002cc:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002d0:	8b 10                	mov    (%eax),%edx
  8002d2:	3b 50 04             	cmp    0x4(%eax),%edx
  8002d5:	73 0a                	jae    8002e1 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002d7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002da:	89 08                	mov    %ecx,(%eax)
  8002dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8002df:	88 02                	mov    %al,(%edx)
}
  8002e1:	5d                   	pop    %ebp
  8002e2:	c3                   	ret    

008002e3 <printfmt>:
{
  8002e3:	55                   	push   %ebp
  8002e4:	89 e5                	mov    %esp,%ebp
  8002e6:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002e9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002ec:	50                   	push   %eax
  8002ed:	ff 75 10             	push   0x10(%ebp)
  8002f0:	ff 75 0c             	push   0xc(%ebp)
  8002f3:	ff 75 08             	push   0x8(%ebp)
  8002f6:	e8 05 00 00 00       	call   800300 <vprintfmt>
}
  8002fb:	83 c4 10             	add    $0x10,%esp
  8002fe:	c9                   	leave  
  8002ff:	c3                   	ret    

00800300 <vprintfmt>:
{
  800300:	55                   	push   %ebp
  800301:	89 e5                	mov    %esp,%ebp
  800303:	57                   	push   %edi
  800304:	56                   	push   %esi
  800305:	53                   	push   %ebx
  800306:	83 ec 2c             	sub    $0x2c,%esp
  800309:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80030c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80030f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800312:	eb 0a                	jmp    80031e <vprintfmt+0x1e>
			putch(ch, putdat);
  800314:	83 ec 08             	sub    $0x8,%esp
  800317:	56                   	push   %esi
  800318:	50                   	push   %eax
  800319:	ff d3                	call   *%ebx
  80031b:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80031e:	83 c7 01             	add    $0x1,%edi
  800321:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800325:	83 f8 25             	cmp    $0x25,%eax
  800328:	74 0c                	je     800336 <vprintfmt+0x36>
			if (ch == '\0')
  80032a:	85 c0                	test   %eax,%eax
  80032c:	75 e6                	jne    800314 <vprintfmt+0x14>
}
  80032e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800331:	5b                   	pop    %ebx
  800332:	5e                   	pop    %esi
  800333:	5f                   	pop    %edi
  800334:	5d                   	pop    %ebp
  800335:	c3                   	ret    
		padc = ' ';
  800336:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
		altflag = 0;
  80033a:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800341:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800348:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80034f:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800354:	8d 47 01             	lea    0x1(%edi),%eax
  800357:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80035a:	0f b6 17             	movzbl (%edi),%edx
  80035d:	8d 42 dd             	lea    -0x23(%edx),%eax
  800360:	3c 55                	cmp    $0x55,%al
  800362:	0f 87 b7 02 00 00    	ja     80061f <vprintfmt+0x31f>
  800368:	0f b6 c0             	movzbl %al,%eax
  80036b:	ff 24 85 20 15 80 00 	jmp    *0x801520(,%eax,4)
  800372:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800375:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800379:	eb d9                	jmp    800354 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80037b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80037e:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800382:	eb d0                	jmp    800354 <vprintfmt+0x54>
  800384:	0f b6 d2             	movzbl %dl,%edx
  800387:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0;; ++fmt) {
  80038a:	b8 00 00 00 00       	mov    $0x0,%eax
  80038f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800392:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800395:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800399:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80039c:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80039f:	83 f9 09             	cmp    $0x9,%ecx
  8003a2:	77 52                	ja     8003f6 <vprintfmt+0xf6>
			for (precision = 0;; ++fmt) {
  8003a4:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003a7:	eb e9                	jmp    800392 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  8003a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ac:	8d 50 04             	lea    0x4(%eax),%edx
  8003af:	89 55 14             	mov    %edx,0x14(%ebp)
  8003b2:	8b 00                	mov    (%eax),%eax
  8003b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003ba:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003be:	79 94                	jns    800354 <vprintfmt+0x54>
				width = precision, precision = -1;
  8003c0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003c6:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003cd:	eb 85                	jmp    800354 <vprintfmt+0x54>
  8003cf:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003d2:	85 d2                	test   %edx,%edx
  8003d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8003d9:	0f 49 c2             	cmovns %edx,%eax
  8003dc:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003e2:	e9 6d ff ff ff       	jmp    800354 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8003e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003ea:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003f1:	e9 5e ff ff ff       	jmp    800354 <vprintfmt+0x54>
  8003f6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003f9:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003fc:	eb bc                	jmp    8003ba <vprintfmt+0xba>
			lflag++;
  8003fe:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800401:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800404:	e9 4b ff ff ff       	jmp    800354 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800409:	8b 45 14             	mov    0x14(%ebp),%eax
  80040c:	8d 50 04             	lea    0x4(%eax),%edx
  80040f:	89 55 14             	mov    %edx,0x14(%ebp)
  800412:	83 ec 08             	sub    $0x8,%esp
  800415:	56                   	push   %esi
  800416:	ff 30                	push   (%eax)
  800418:	ff d3                	call   *%ebx
			break;
  80041a:	83 c4 10             	add    $0x10,%esp
  80041d:	e9 94 01 00 00       	jmp    8005b6 <vprintfmt+0x2b6>
			err = va_arg(ap, int);
  800422:	8b 45 14             	mov    0x14(%ebp),%eax
  800425:	8d 50 04             	lea    0x4(%eax),%edx
  800428:	89 55 14             	mov    %edx,0x14(%ebp)
  80042b:	8b 10                	mov    (%eax),%edx
  80042d:	89 d0                	mov    %edx,%eax
  80042f:	f7 d8                	neg    %eax
  800431:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800434:	83 f8 08             	cmp    $0x8,%eax
  800437:	7f 20                	jg     800459 <vprintfmt+0x159>
  800439:	8b 14 85 80 16 80 00 	mov    0x801680(,%eax,4),%edx
  800440:	85 d2                	test   %edx,%edx
  800442:	74 15                	je     800459 <vprintfmt+0x159>
				printfmt(putch, putdat, "%s", p);
  800444:	52                   	push   %edx
  800445:	68 81 14 80 00       	push   $0x801481
  80044a:	56                   	push   %esi
  80044b:	53                   	push   %ebx
  80044c:	e8 92 fe ff ff       	call   8002e3 <printfmt>
  800451:	83 c4 10             	add    $0x10,%esp
  800454:	e9 5d 01 00 00       	jmp    8005b6 <vprintfmt+0x2b6>
				printfmt(putch, putdat, "error %d", err);
  800459:	50                   	push   %eax
  80045a:	68 78 14 80 00       	push   $0x801478
  80045f:	56                   	push   %esi
  800460:	53                   	push   %ebx
  800461:	e8 7d fe ff ff       	call   8002e3 <printfmt>
  800466:	83 c4 10             	add    $0x10,%esp
  800469:	e9 48 01 00 00       	jmp    8005b6 <vprintfmt+0x2b6>
			if ((p = va_arg(ap, char *)) == NULL)
  80046e:	8b 45 14             	mov    0x14(%ebp),%eax
  800471:	8d 50 04             	lea    0x4(%eax),%edx
  800474:	89 55 14             	mov    %edx,0x14(%ebp)
  800477:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800479:	85 ff                	test   %edi,%edi
  80047b:	b8 71 14 80 00       	mov    $0x801471,%eax
  800480:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800483:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800487:	7e 06                	jle    80048f <vprintfmt+0x18f>
  800489:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  80048d:	75 0a                	jne    800499 <vprintfmt+0x199>
  80048f:	89 f8                	mov    %edi,%eax
  800491:	03 45 e0             	add    -0x20(%ebp),%eax
  800494:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800497:	eb 59                	jmp    8004f2 <vprintfmt+0x1f2>
				for (width -= strnlen(p, precision); width > 0;
  800499:	83 ec 08             	sub    $0x8,%esp
  80049c:	ff 75 d8             	push   -0x28(%ebp)
  80049f:	57                   	push   %edi
  8004a0:	e8 1a 02 00 00       	call   8006bf <strnlen>
  8004a5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004a8:	29 c1                	sub    %eax,%ecx
  8004aa:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004ad:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004b0:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  8004b4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b7:	89 7d d0             	mov    %edi,-0x30(%ebp)
  8004ba:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0;
  8004bc:	eb 0f                	jmp    8004cd <vprintfmt+0x1cd>
					putch(padc, putdat);
  8004be:	83 ec 08             	sub    $0x8,%esp
  8004c1:	56                   	push   %esi
  8004c2:	ff 75 e0             	push   -0x20(%ebp)
  8004c5:	ff d3                	call   *%ebx
				     width--)
  8004c7:	83 ef 01             	sub    $0x1,%edi
  8004ca:	83 c4 10             	add    $0x10,%esp
				for (width -= strnlen(p, precision); width > 0;
  8004cd:	85 ff                	test   %edi,%edi
  8004cf:	7f ed                	jg     8004be <vprintfmt+0x1be>
  8004d1:	8b 7d d0             	mov    -0x30(%ebp),%edi
  8004d4:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004d7:	85 c9                	test   %ecx,%ecx
  8004d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8004de:	0f 49 c1             	cmovns %ecx,%eax
  8004e1:	29 c1                	sub    %eax,%ecx
  8004e3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8004e6:	eb a7                	jmp    80048f <vprintfmt+0x18f>
					putch(ch, putdat);
  8004e8:	83 ec 08             	sub    $0x8,%esp
  8004eb:	56                   	push   %esi
  8004ec:	52                   	push   %edx
  8004ed:	ff d3                	call   *%ebx
  8004ef:	83 c4 10             	add    $0x10,%esp
  8004f2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004f5:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' &&
  8004f7:	83 c7 01             	add    $0x1,%edi
  8004fa:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004fe:	0f be d0             	movsbl %al,%edx
  800501:	85 d2                	test   %edx,%edx
  800503:	74 42                	je     800547 <vprintfmt+0x247>
  800505:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800509:	78 06                	js     800511 <vprintfmt+0x211>
			       (precision < 0 || --precision >= 0);
  80050b:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80050f:	78 1e                	js     80052f <vprintfmt+0x22f>
				if (altflag && (ch < ' ' || ch > '~'))
  800511:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800515:	74 d1                	je     8004e8 <vprintfmt+0x1e8>
  800517:	0f be c0             	movsbl %al,%eax
  80051a:	83 e8 20             	sub    $0x20,%eax
  80051d:	83 f8 5e             	cmp    $0x5e,%eax
  800520:	76 c6                	jbe    8004e8 <vprintfmt+0x1e8>
					putch('?', putdat);
  800522:	83 ec 08             	sub    $0x8,%esp
  800525:	56                   	push   %esi
  800526:	6a 3f                	push   $0x3f
  800528:	ff d3                	call   *%ebx
  80052a:	83 c4 10             	add    $0x10,%esp
  80052d:	eb c3                	jmp    8004f2 <vprintfmt+0x1f2>
  80052f:	89 cf                	mov    %ecx,%edi
  800531:	eb 0e                	jmp    800541 <vprintfmt+0x241>
				putch(' ', putdat);
  800533:	83 ec 08             	sub    $0x8,%esp
  800536:	56                   	push   %esi
  800537:	6a 20                	push   $0x20
  800539:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  80053b:	83 ef 01             	sub    $0x1,%edi
  80053e:	83 c4 10             	add    $0x10,%esp
  800541:	85 ff                	test   %edi,%edi
  800543:	7f ee                	jg     800533 <vprintfmt+0x233>
  800545:	eb 6f                	jmp    8005b6 <vprintfmt+0x2b6>
  800547:	89 cf                	mov    %ecx,%edi
  800549:	eb f6                	jmp    800541 <vprintfmt+0x241>
			num = getint(&ap, lflag);
  80054b:	89 ca                	mov    %ecx,%edx
  80054d:	8d 45 14             	lea    0x14(%ebp),%eax
  800550:	e8 45 fd ff ff       	call   80029a <getint>
  800555:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800558:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  80055b:	85 d2                	test   %edx,%edx
  80055d:	78 0b                	js     80056a <vprintfmt+0x26a>
			num = getint(&ap, lflag);
  80055f:	89 d1                	mov    %edx,%ecx
  800561:	89 c2                	mov    %eax,%edx
			base = 10;
  800563:	bf 0a 00 00 00       	mov    $0xa,%edi
  800568:	eb 32                	jmp    80059c <vprintfmt+0x29c>
				putch('-', putdat);
  80056a:	83 ec 08             	sub    $0x8,%esp
  80056d:	56                   	push   %esi
  80056e:	6a 2d                	push   $0x2d
  800570:	ff d3                	call   *%ebx
				num = -(long long) num;
  800572:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800575:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800578:	f7 da                	neg    %edx
  80057a:	83 d1 00             	adc    $0x0,%ecx
  80057d:	f7 d9                	neg    %ecx
  80057f:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800582:	bf 0a 00 00 00       	mov    $0xa,%edi
  800587:	eb 13                	jmp    80059c <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  800589:	89 ca                	mov    %ecx,%edx
  80058b:	8d 45 14             	lea    0x14(%ebp),%eax
  80058e:	e8 d3 fc ff ff       	call   800266 <getuint>
  800593:	89 d1                	mov    %edx,%ecx
  800595:	89 c2                	mov    %eax,%edx
			base = 10;
  800597:	bf 0a 00 00 00       	mov    $0xa,%edi
			printnum(putch, putdat, num, base, width, padc);
  80059c:	83 ec 0c             	sub    $0xc,%esp
  80059f:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  8005a3:	50                   	push   %eax
  8005a4:	ff 75 e0             	push   -0x20(%ebp)
  8005a7:	57                   	push   %edi
  8005a8:	51                   	push   %ecx
  8005a9:	52                   	push   %edx
  8005aa:	89 f2                	mov    %esi,%edx
  8005ac:	89 d8                	mov    %ebx,%eax
  8005ae:	e8 0a fc ff ff       	call   8001bd <printnum>
			break;
  8005b3:	83 c4 20             	add    $0x20,%esp
{
  8005b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005b9:	e9 60 fd ff ff       	jmp    80031e <vprintfmt+0x1e>
			num = getuint(&ap, lflag);
  8005be:	89 ca                	mov    %ecx,%edx
  8005c0:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c3:	e8 9e fc ff ff       	call   800266 <getuint>
  8005c8:	89 d1                	mov    %edx,%ecx
  8005ca:	89 c2                	mov    %eax,%edx
			base = 8;
  8005cc:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  8005d1:	eb c9                	jmp    80059c <vprintfmt+0x29c>
			putch('0', putdat);
  8005d3:	83 ec 08             	sub    $0x8,%esp
  8005d6:	56                   	push   %esi
  8005d7:	6a 30                	push   $0x30
  8005d9:	ff d3                	call   *%ebx
			putch('x', putdat);
  8005db:	83 c4 08             	add    $0x8,%esp
  8005de:	56                   	push   %esi
  8005df:	6a 78                	push   $0x78
  8005e1:	ff d3                	call   *%ebx
			num = (unsigned long long) (uintptr_t) va_arg(ap, void *);
  8005e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e6:	8d 50 04             	lea    0x4(%eax),%edx
  8005e9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ec:	8b 10                	mov    (%eax),%edx
  8005ee:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8005f3:	83 c4 10             	add    $0x10,%esp
			base = 16;
  8005f6:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  8005fb:	eb 9f                	jmp    80059c <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  8005fd:	89 ca                	mov    %ecx,%edx
  8005ff:	8d 45 14             	lea    0x14(%ebp),%eax
  800602:	e8 5f fc ff ff       	call   800266 <getuint>
  800607:	89 d1                	mov    %edx,%ecx
  800609:	89 c2                	mov    %eax,%edx
			base = 16;
  80060b:	bf 10 00 00 00       	mov    $0x10,%edi
  800610:	eb 8a                	jmp    80059c <vprintfmt+0x29c>
			putch(ch, putdat);
  800612:	83 ec 08             	sub    $0x8,%esp
  800615:	56                   	push   %esi
  800616:	6a 25                	push   $0x25
  800618:	ff d3                	call   *%ebx
			break;
  80061a:	83 c4 10             	add    $0x10,%esp
  80061d:	eb 97                	jmp    8005b6 <vprintfmt+0x2b6>
			putch('%', putdat);
  80061f:	83 ec 08             	sub    $0x8,%esp
  800622:	56                   	push   %esi
  800623:	6a 25                	push   $0x25
  800625:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  800627:	83 c4 10             	add    $0x10,%esp
  80062a:	89 f8                	mov    %edi,%eax
  80062c:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800630:	74 05                	je     800637 <vprintfmt+0x337>
  800632:	83 e8 01             	sub    $0x1,%eax
  800635:	eb f5                	jmp    80062c <vprintfmt+0x32c>
  800637:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80063a:	e9 77 ff ff ff       	jmp    8005b6 <vprintfmt+0x2b6>

0080063f <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80063f:	55                   	push   %ebp
  800640:	89 e5                	mov    %esp,%ebp
  800642:	83 ec 18             	sub    $0x18,%esp
  800645:	8b 45 08             	mov    0x8(%ebp),%eax
  800648:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = { buf, buf + n - 1, 0 };
  80064b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80064e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800652:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800655:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80065c:	85 c0                	test   %eax,%eax
  80065e:	74 26                	je     800686 <vsnprintf+0x47>
  800660:	85 d2                	test   %edx,%edx
  800662:	7e 22                	jle    800686 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *) sprintputch, &b, fmt, ap);
  800664:	ff 75 14             	push   0x14(%ebp)
  800667:	ff 75 10             	push   0x10(%ebp)
  80066a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80066d:	50                   	push   %eax
  80066e:	68 c6 02 80 00       	push   $0x8002c6
  800673:	e8 88 fc ff ff       	call   800300 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800678:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80067b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80067e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800681:	83 c4 10             	add    $0x10,%esp
}
  800684:	c9                   	leave  
  800685:	c3                   	ret    
		return -E_INVAL;
  800686:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80068b:	eb f7                	jmp    800684 <vsnprintf+0x45>

0080068d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80068d:	55                   	push   %ebp
  80068e:	89 e5                	mov    %esp,%ebp
  800690:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800693:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800696:	50                   	push   %eax
  800697:	ff 75 10             	push   0x10(%ebp)
  80069a:	ff 75 0c             	push   0xc(%ebp)
  80069d:	ff 75 08             	push   0x8(%ebp)
  8006a0:	e8 9a ff ff ff       	call   80063f <vsnprintf>
	va_end(ap);

	return rc;
}
  8006a5:	c9                   	leave  
  8006a6:	c3                   	ret    

008006a7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006a7:	55                   	push   %ebp
  8006a8:	89 e5                	mov    %esp,%ebp
  8006aa:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8006b2:	eb 03                	jmp    8006b7 <strlen+0x10>
		n++;
  8006b4:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8006b7:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006bb:	75 f7                	jne    8006b4 <strlen+0xd>
	return n;
}
  8006bd:	5d                   	pop    %ebp
  8006be:	c3                   	ret    

008006bf <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006bf:	55                   	push   %ebp
  8006c0:	89 e5                	mov    %esp,%ebp
  8006c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006c5:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8006cd:	eb 03                	jmp    8006d2 <strnlen+0x13>
		n++;
  8006cf:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006d2:	39 d0                	cmp    %edx,%eax
  8006d4:	74 08                	je     8006de <strnlen+0x1f>
  8006d6:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8006da:	75 f3                	jne    8006cf <strnlen+0x10>
  8006dc:	89 c2                	mov    %eax,%edx
	return n;
}
  8006de:	89 d0                	mov    %edx,%eax
  8006e0:	5d                   	pop    %ebp
  8006e1:	c3                   	ret    

008006e2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006e2:	55                   	push   %ebp
  8006e3:	89 e5                	mov    %esp,%ebp
  8006e5:	53                   	push   %ebx
  8006e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f1:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8006f5:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8006f8:	83 c0 01             	add    $0x1,%eax
  8006fb:	84 d2                	test   %dl,%dl
  8006fd:	75 f2                	jne    8006f1 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8006ff:	89 c8                	mov    %ecx,%eax
  800701:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800704:	c9                   	leave  
  800705:	c3                   	ret    

00800706 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800706:	55                   	push   %ebp
  800707:	89 e5                	mov    %esp,%ebp
  800709:	53                   	push   %ebx
  80070a:	83 ec 10             	sub    $0x10,%esp
  80070d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800710:	53                   	push   %ebx
  800711:	e8 91 ff ff ff       	call   8006a7 <strlen>
  800716:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800719:	ff 75 0c             	push   0xc(%ebp)
  80071c:	01 d8                	add    %ebx,%eax
  80071e:	50                   	push   %eax
  80071f:	e8 be ff ff ff       	call   8006e2 <strcpy>
	return dst;
}
  800724:	89 d8                	mov    %ebx,%eax
  800726:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800729:	c9                   	leave  
  80072a:	c3                   	ret    

0080072b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size)
{
  80072b:	55                   	push   %ebp
  80072c:	89 e5                	mov    %esp,%ebp
  80072e:	56                   	push   %esi
  80072f:	53                   	push   %ebx
  800730:	8b 75 08             	mov    0x8(%ebp),%esi
  800733:	8b 55 0c             	mov    0xc(%ebp),%edx
  800736:	89 f3                	mov    %esi,%ebx
  800738:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80073b:	89 f0                	mov    %esi,%eax
  80073d:	eb 0f                	jmp    80074e <strncpy+0x23>
		*dst++ = *src;
  80073f:	83 c0 01             	add    $0x1,%eax
  800742:	0f b6 0a             	movzbl (%edx),%ecx
  800745:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800748:	80 f9 01             	cmp    $0x1,%cl
  80074b:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  80074e:	39 d8                	cmp    %ebx,%eax
  800750:	75 ed                	jne    80073f <strncpy+0x14>
	}
	return ret;
}
  800752:	89 f0                	mov    %esi,%eax
  800754:	5b                   	pop    %ebx
  800755:	5e                   	pop    %esi
  800756:	5d                   	pop    %ebp
  800757:	c3                   	ret    

00800758 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800758:	55                   	push   %ebp
  800759:	89 e5                	mov    %esp,%ebp
  80075b:	56                   	push   %esi
  80075c:	53                   	push   %ebx
  80075d:	8b 75 08             	mov    0x8(%ebp),%esi
  800760:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800763:	8b 55 10             	mov    0x10(%ebp),%edx
  800766:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800768:	85 d2                	test   %edx,%edx
  80076a:	74 21                	je     80078d <strlcpy+0x35>
  80076c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800770:	89 f2                	mov    %esi,%edx
  800772:	eb 09                	jmp    80077d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800774:	83 c1 01             	add    $0x1,%ecx
  800777:	83 c2 01             	add    $0x1,%edx
  80077a:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  80077d:	39 c2                	cmp    %eax,%edx
  80077f:	74 09                	je     80078a <strlcpy+0x32>
  800781:	0f b6 19             	movzbl (%ecx),%ebx
  800784:	84 db                	test   %bl,%bl
  800786:	75 ec                	jne    800774 <strlcpy+0x1c>
  800788:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80078a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80078d:	29 f0                	sub    %esi,%eax
}
  80078f:	5b                   	pop    %ebx
  800790:	5e                   	pop    %esi
  800791:	5d                   	pop    %ebp
  800792:	c3                   	ret    

00800793 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800793:	55                   	push   %ebp
  800794:	89 e5                	mov    %esp,%ebp
  800796:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800799:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80079c:	eb 06                	jmp    8007a4 <strcmp+0x11>
		p++, q++;
  80079e:	83 c1 01             	add    $0x1,%ecx
  8007a1:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8007a4:	0f b6 01             	movzbl (%ecx),%eax
  8007a7:	84 c0                	test   %al,%al
  8007a9:	74 04                	je     8007af <strcmp+0x1c>
  8007ab:	3a 02                	cmp    (%edx),%al
  8007ad:	74 ef                	je     80079e <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007af:	0f b6 c0             	movzbl %al,%eax
  8007b2:	0f b6 12             	movzbl (%edx),%edx
  8007b5:	29 d0                	sub    %edx,%eax
}
  8007b7:	5d                   	pop    %ebp
  8007b8:	c3                   	ret    

008007b9 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007b9:	55                   	push   %ebp
  8007ba:	89 e5                	mov    %esp,%ebp
  8007bc:	53                   	push   %ebx
  8007bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007c3:	89 c3                	mov    %eax,%ebx
  8007c5:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007c8:	eb 06                	jmp    8007d0 <strncmp+0x17>
		n--, p++, q++;
  8007ca:	83 c0 01             	add    $0x1,%eax
  8007cd:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8007d0:	39 d8                	cmp    %ebx,%eax
  8007d2:	74 18                	je     8007ec <strncmp+0x33>
  8007d4:	0f b6 08             	movzbl (%eax),%ecx
  8007d7:	84 c9                	test   %cl,%cl
  8007d9:	74 04                	je     8007df <strncmp+0x26>
  8007db:	3a 0a                	cmp    (%edx),%cl
  8007dd:	74 eb                	je     8007ca <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007df:	0f b6 00             	movzbl (%eax),%eax
  8007e2:	0f b6 12             	movzbl (%edx),%edx
  8007e5:	29 d0                	sub    %edx,%eax
}
  8007e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007ea:	c9                   	leave  
  8007eb:	c3                   	ret    
		return 0;
  8007ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f1:	eb f4                	jmp    8007e7 <strncmp+0x2e>

008007f3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007f3:	55                   	push   %ebp
  8007f4:	89 e5                	mov    %esp,%ebp
  8007f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007fd:	eb 03                	jmp    800802 <strchr+0xf>
  8007ff:	83 c0 01             	add    $0x1,%eax
  800802:	0f b6 10             	movzbl (%eax),%edx
  800805:	84 d2                	test   %dl,%dl
  800807:	74 06                	je     80080f <strchr+0x1c>
		if (*s == c)
  800809:	38 ca                	cmp    %cl,%dl
  80080b:	75 f2                	jne    8007ff <strchr+0xc>
  80080d:	eb 05                	jmp    800814 <strchr+0x21>
			return (char *) s;
	return 0;
  80080f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800814:	5d                   	pop    %ebp
  800815:	c3                   	ret    

00800816 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800816:	55                   	push   %ebp
  800817:	89 e5                	mov    %esp,%ebp
  800819:	8b 45 08             	mov    0x8(%ebp),%eax
  80081c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800820:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800823:	38 ca                	cmp    %cl,%dl
  800825:	74 09                	je     800830 <strfind+0x1a>
  800827:	84 d2                	test   %dl,%dl
  800829:	74 05                	je     800830 <strfind+0x1a>
	for (; *s; s++)
  80082b:	83 c0 01             	add    $0x1,%eax
  80082e:	eb f0                	jmp    800820 <strfind+0xa>
			break;
	return (char *) s;
}
  800830:	5d                   	pop    %ebp
  800831:	c3                   	ret    

00800832 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
  800835:	57                   	push   %edi
  800836:	56                   	push   %esi
  800837:	53                   	push   %ebx
  800838:	8b 55 08             	mov    0x8(%ebp),%edx
  80083b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  80083e:	85 c9                	test   %ecx,%ecx
  800840:	74 33                	je     800875 <memset+0x43>
		return v;
	if ((int) v % 4 == 0 && n % 4 == 0) {
  800842:	89 d0                	mov    %edx,%eax
  800844:	09 c8                	or     %ecx,%eax
  800846:	a8 03                	test   $0x3,%al
  800848:	75 23                	jne    80086d <memset+0x3b>
		c &= 0xFF;
  80084a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  80084e:	89 d8                	mov    %ebx,%eax
  800850:	c1 e0 08             	shl    $0x8,%eax
  800853:	89 df                	mov    %ebx,%edi
  800855:	c1 e7 18             	shl    $0x18,%edi
  800858:	89 de                	mov    %ebx,%esi
  80085a:	c1 e6 10             	shl    $0x10,%esi
  80085d:	09 f7                	or     %esi,%edi
  80085f:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
		             : "=D"(p), "=c"(n)
		             : "D"(p), "a"(c), "c"(n / 4)
  800861:	c1 e9 02             	shr    $0x2,%ecx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  800864:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800866:	89 d7                	mov    %edx,%edi
  800868:	fc                   	cld    
  800869:	f3 ab                	rep stos %eax,%es:(%edi)
  80086b:	eb 08                	jmp    800875 <memset+0x43>
		             : "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80086d:	89 d7                	mov    %edx,%edi
  80086f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800872:	fc                   	cld    
  800873:	f3 aa                	rep stos %al,%es:(%edi)
		             : "=D"(p), "=c"(n)
		             : "0"(p), "a"(c), "1"(n)
		             : "cc", "memory");
	return v;
}
  800875:	89 d0                	mov    %edx,%eax
  800877:	5b                   	pop    %ebx
  800878:	5e                   	pop    %esi
  800879:	5f                   	pop    %edi
  80087a:	5d                   	pop    %ebp
  80087b:	c3                   	ret    

0080087c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80087c:	55                   	push   %ebp
  80087d:	89 e5                	mov    %esp,%ebp
  80087f:	57                   	push   %edi
  800880:	56                   	push   %esi
  800881:	8b 45 08             	mov    0x8(%ebp),%eax
  800884:	8b 75 0c             	mov    0xc(%ebp),%esi
  800887:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80088a:	39 c6                	cmp    %eax,%esi
  80088c:	73 32                	jae    8008c0 <memmove+0x44>
  80088e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800891:	39 c2                	cmp    %eax,%edx
  800893:	76 2b                	jbe    8008c0 <memmove+0x44>
		s += n;
		d += n;
  800895:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  800898:	89 d6                	mov    %edx,%esi
  80089a:	09 fe                	or     %edi,%esi
  80089c:	09 ce                	or     %ecx,%esi
  80089e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008a4:	75 0e                	jne    8008b4 <memmove+0x38>
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  8008a6:	83 ef 04             	sub    $0x4,%edi
			             "S"(s - 4),
  8008a9:	8d 72 fc             	lea    -0x4(%edx),%esi
			             "c"(n / 4)
  8008ac:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  8008af:	fd                   	std    
  8008b0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008b2:	eb 09                	jmp    8008bd <memmove+0x41>
			             : "cc", "memory");
		else
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  8008b4:	83 ef 01             	sub    $0x1,%edi
			             "S"(s - 1),
  8008b7:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  8008ba:	fd                   	std    
  8008bb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             "c"(n)
			             : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008bd:	fc                   	cld    
  8008be:	eb 1a                	jmp    8008da <memmove+0x5e>
	} else {
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  8008c0:	89 f2                	mov    %esi,%edx
  8008c2:	09 c2                	or     %eax,%edx
  8008c4:	09 ca                	or     %ecx,%edx
  8008c6:	f6 c2 03             	test   $0x3,%dl
  8008c9:	75 0a                	jne    8008d5 <memmove+0x59>
			asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  8008cb:	c1 e9 02             	shr    $0x2,%ecx
  8008ce:	89 c7                	mov    %eax,%edi
  8008d0:	fc                   	cld    
  8008d1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008d3:	eb 05                	jmp    8008da <memmove+0x5e>
			             : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  8008d5:	89 c7                	mov    %eax,%edi
  8008d7:	fc                   	cld    
  8008d8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             : "cc", "memory");
	}
	return dst;
}
  8008da:	5e                   	pop    %esi
  8008db:	5f                   	pop    %edi
  8008dc:	5d                   	pop    %ebp
  8008dd:	c3                   	ret    

008008de <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008de:	55                   	push   %ebp
  8008df:	89 e5                	mov    %esp,%ebp
  8008e1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8008e4:	ff 75 10             	push   0x10(%ebp)
  8008e7:	ff 75 0c             	push   0xc(%ebp)
  8008ea:	ff 75 08             	push   0x8(%ebp)
  8008ed:	e8 8a ff ff ff       	call   80087c <memmove>
}
  8008f2:	c9                   	leave  
  8008f3:	c3                   	ret    

008008f4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008f4:	55                   	push   %ebp
  8008f5:	89 e5                	mov    %esp,%ebp
  8008f7:	56                   	push   %esi
  8008f8:	53                   	push   %ebx
  8008f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ff:	89 c6                	mov    %eax,%esi
  800901:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800904:	eb 06                	jmp    80090c <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800906:	83 c0 01             	add    $0x1,%eax
  800909:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  80090c:	39 f0                	cmp    %esi,%eax
  80090e:	74 14                	je     800924 <memcmp+0x30>
		if (*s1 != *s2)
  800910:	0f b6 08             	movzbl (%eax),%ecx
  800913:	0f b6 1a             	movzbl (%edx),%ebx
  800916:	38 d9                	cmp    %bl,%cl
  800918:	74 ec                	je     800906 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  80091a:	0f b6 c1             	movzbl %cl,%eax
  80091d:	0f b6 db             	movzbl %bl,%ebx
  800920:	29 d8                	sub    %ebx,%eax
  800922:	eb 05                	jmp    800929 <memcmp+0x35>
	}

	return 0;
  800924:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800929:	5b                   	pop    %ebx
  80092a:	5e                   	pop    %esi
  80092b:	5d                   	pop    %ebp
  80092c:	c3                   	ret    

0080092d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80092d:	55                   	push   %ebp
  80092e:	89 e5                	mov    %esp,%ebp
  800930:	8b 45 08             	mov    0x8(%ebp),%eax
  800933:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800936:	89 c2                	mov    %eax,%edx
  800938:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80093b:	eb 03                	jmp    800940 <memfind+0x13>
  80093d:	83 c0 01             	add    $0x1,%eax
  800940:	39 d0                	cmp    %edx,%eax
  800942:	73 04                	jae    800948 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800944:	38 08                	cmp    %cl,(%eax)
  800946:	75 f5                	jne    80093d <memfind+0x10>
			break;
	return (void *) s;
}
  800948:	5d                   	pop    %ebp
  800949:	c3                   	ret    

0080094a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
  80094d:	57                   	push   %edi
  80094e:	56                   	push   %esi
  80094f:	53                   	push   %ebx
  800950:	8b 55 08             	mov    0x8(%ebp),%edx
  800953:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800956:	eb 03                	jmp    80095b <strtol+0x11>
		s++;
  800958:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  80095b:	0f b6 02             	movzbl (%edx),%eax
  80095e:	3c 20                	cmp    $0x20,%al
  800960:	74 f6                	je     800958 <strtol+0xe>
  800962:	3c 09                	cmp    $0x9,%al
  800964:	74 f2                	je     800958 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800966:	3c 2b                	cmp    $0x2b,%al
  800968:	74 2a                	je     800994 <strtol+0x4a>
	int neg = 0;
  80096a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  80096f:	3c 2d                	cmp    $0x2d,%al
  800971:	74 2b                	je     80099e <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800973:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800979:	75 0f                	jne    80098a <strtol+0x40>
  80097b:	80 3a 30             	cmpb   $0x30,(%edx)
  80097e:	74 28                	je     8009a8 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800980:	85 db                	test   %ebx,%ebx
  800982:	b8 0a 00 00 00       	mov    $0xa,%eax
  800987:	0f 44 d8             	cmove  %eax,%ebx
  80098a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80098f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800992:	eb 46                	jmp    8009da <strtol+0x90>
		s++;
  800994:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800997:	bf 00 00 00 00       	mov    $0x0,%edi
  80099c:	eb d5                	jmp    800973 <strtol+0x29>
		s++, neg = 1;
  80099e:	83 c2 01             	add    $0x1,%edx
  8009a1:	bf 01 00 00 00       	mov    $0x1,%edi
  8009a6:	eb cb                	jmp    800973 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009a8:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009ac:	74 0e                	je     8009bc <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  8009ae:	85 db                	test   %ebx,%ebx
  8009b0:	75 d8                	jne    80098a <strtol+0x40>
		s++, base = 8;
  8009b2:	83 c2 01             	add    $0x1,%edx
  8009b5:	bb 08 00 00 00       	mov    $0x8,%ebx
  8009ba:	eb ce                	jmp    80098a <strtol+0x40>
		s += 2, base = 16;
  8009bc:	83 c2 02             	add    $0x2,%edx
  8009bf:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009c4:	eb c4                	jmp    80098a <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  8009c6:	0f be c0             	movsbl %al,%eax
  8009c9:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8009cc:	3b 45 10             	cmp    0x10(%ebp),%eax
  8009cf:	7d 3a                	jge    800a0b <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  8009d1:	83 c2 01             	add    $0x1,%edx
  8009d4:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  8009d8:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  8009da:	0f b6 02             	movzbl (%edx),%eax
  8009dd:	8d 70 d0             	lea    -0x30(%eax),%esi
  8009e0:	89 f3                	mov    %esi,%ebx
  8009e2:	80 fb 09             	cmp    $0x9,%bl
  8009e5:	76 df                	jbe    8009c6 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  8009e7:	8d 70 9f             	lea    -0x61(%eax),%esi
  8009ea:	89 f3                	mov    %esi,%ebx
  8009ec:	80 fb 19             	cmp    $0x19,%bl
  8009ef:	77 08                	ja     8009f9 <strtol+0xaf>
			dig = *s - 'a' + 10;
  8009f1:	0f be c0             	movsbl %al,%eax
  8009f4:	83 e8 57             	sub    $0x57,%eax
  8009f7:	eb d3                	jmp    8009cc <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  8009f9:	8d 70 bf             	lea    -0x41(%eax),%esi
  8009fc:	89 f3                	mov    %esi,%ebx
  8009fe:	80 fb 19             	cmp    $0x19,%bl
  800a01:	77 08                	ja     800a0b <strtol+0xc1>
			dig = *s - 'A' + 10;
  800a03:	0f be c0             	movsbl %al,%eax
  800a06:	83 e8 37             	sub    $0x37,%eax
  800a09:	eb c1                	jmp    8009cc <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a0b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a0f:	74 05                	je     800a16 <strtol+0xcc>
		*endptr = (char *) s;
  800a11:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a14:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800a16:	89 c8                	mov    %ecx,%eax
  800a18:	f7 d8                	neg    %eax
  800a1a:	85 ff                	test   %edi,%edi
  800a1c:	0f 45 c8             	cmovne %eax,%ecx
}
  800a1f:	89 c8                	mov    %ecx,%eax
  800a21:	5b                   	pop    %ebx
  800a22:	5e                   	pop    %esi
  800a23:	5f                   	pop    %edi
  800a24:	5d                   	pop    %ebp
  800a25:	c3                   	ret    

00800a26 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
  800a29:	57                   	push   %edi
  800a2a:	56                   	push   %esi
  800a2b:	53                   	push   %ebx
  800a2c:	83 ec 1c             	sub    $0x1c,%esp
  800a2f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a32:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800a35:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile(
  800a37:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a3a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a3d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800a40:	8b 75 14             	mov    0x14(%ebp),%esi
  800a43:	cd 30                	int    $0x30
	        "int %1\n"
	        : "=a"(ret)
	        : "i"(T_SYSCALL), "a"(num), "d"(a1), "c"(a2), "b"(a3), "D"(a4), "S"(a5)
	        : "cc", "memory");

	if (check && ret > 0)
  800a45:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a49:	74 04                	je     800a4f <syscall+0x29>
  800a4b:	85 c0                	test   %eax,%eax
  800a4d:	7f 08                	jg     800a57 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800a4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a52:	5b                   	pop    %ebx
  800a53:	5e                   	pop    %esi
  800a54:	5f                   	pop    %edi
  800a55:	5d                   	pop    %ebp
  800a56:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800a57:	83 ec 0c             	sub    $0xc,%esp
  800a5a:	50                   	push   %eax
  800a5b:	ff 75 e0             	push   -0x20(%ebp)
  800a5e:	68 a4 16 80 00       	push   $0x8016a4
  800a63:	6a 1e                	push   $0x1e
  800a65:	68 c1 16 80 00       	push   $0x8016c1
  800a6a:	e8 59 06 00 00       	call   8010c8 <_panic>

00800a6f <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800a6f:	55                   	push   %ebp
  800a70:	89 e5                	mov    %esp,%ebp
  800a72:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t) s, len, 0, 0, 0);
  800a75:	6a 00                	push   $0x0
  800a77:	6a 00                	push   $0x0
  800a79:	6a 00                	push   $0x0
  800a7b:	ff 75 0c             	push   0xc(%ebp)
  800a7e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a81:	ba 00 00 00 00       	mov    $0x0,%edx
  800a86:	b8 00 00 00 00       	mov    $0x0,%eax
  800a8b:	e8 96 ff ff ff       	call   800a26 <syscall>
}
  800a90:	83 c4 10             	add    $0x10,%esp
  800a93:	c9                   	leave  
  800a94:	c3                   	ret    

00800a95 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a95:	55                   	push   %ebp
  800a96:	89 e5                	mov    %esp,%ebp
  800a98:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800a9b:	6a 00                	push   $0x0
  800a9d:	6a 00                	push   $0x0
  800a9f:	6a 00                	push   $0x0
  800aa1:	6a 00                	push   $0x0
  800aa3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aa8:	ba 00 00 00 00       	mov    $0x0,%edx
  800aad:	b8 01 00 00 00       	mov    $0x1,%eax
  800ab2:	e8 6f ff ff ff       	call   800a26 <syscall>
}
  800ab7:	c9                   	leave  
  800ab8:	c3                   	ret    

00800ab9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ab9:	55                   	push   %ebp
  800aba:	89 e5                	mov    %esp,%ebp
  800abc:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800abf:	6a 00                	push   $0x0
  800ac1:	6a 00                	push   $0x0
  800ac3:	6a 00                	push   $0x0
  800ac5:	6a 00                	push   $0x0
  800ac7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aca:	ba 01 00 00 00       	mov    $0x1,%edx
  800acf:	b8 03 00 00 00       	mov    $0x3,%eax
  800ad4:	e8 4d ff ff ff       	call   800a26 <syscall>
}
  800ad9:	c9                   	leave  
  800ada:	c3                   	ret    

00800adb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800adb:	55                   	push   %ebp
  800adc:	89 e5                	mov    %esp,%ebp
  800ade:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800ae1:	6a 00                	push   $0x0
  800ae3:	6a 00                	push   $0x0
  800ae5:	6a 00                	push   $0x0
  800ae7:	6a 00                	push   $0x0
  800ae9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aee:	ba 00 00 00 00       	mov    $0x0,%edx
  800af3:	b8 02 00 00 00       	mov    $0x2,%eax
  800af8:	e8 29 ff ff ff       	call   800a26 <syscall>
}
  800afd:	c9                   	leave  
  800afe:	c3                   	ret    

00800aff <sys_yield>:

void
sys_yield(void)
{
  800aff:	55                   	push   %ebp
  800b00:	89 e5                	mov    %esp,%ebp
  800b02:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800b05:	6a 00                	push   $0x0
  800b07:	6a 00                	push   $0x0
  800b09:	6a 00                	push   $0x0
  800b0b:	6a 00                	push   $0x0
  800b0d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b12:	ba 00 00 00 00       	mov    $0x0,%edx
  800b17:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b1c:	e8 05 ff ff ff       	call   800a26 <syscall>
}
  800b21:	83 c4 10             	add    $0x10,%esp
  800b24:	c9                   	leave  
  800b25:	c3                   	ret    

00800b26 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b26:	55                   	push   %ebp
  800b27:	89 e5                	mov    %esp,%ebp
  800b29:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800b2c:	6a 00                	push   $0x0
  800b2e:	6a 00                	push   $0x0
  800b30:	ff 75 10             	push   0x10(%ebp)
  800b33:	ff 75 0c             	push   0xc(%ebp)
  800b36:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b39:	ba 01 00 00 00       	mov    $0x1,%edx
  800b3e:	b8 04 00 00 00       	mov    $0x4,%eax
  800b43:	e8 de fe ff ff       	call   800a26 <syscall>
}
  800b48:	c9                   	leave  
  800b49:	c3                   	ret    

00800b4a <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b4a:	55                   	push   %ebp
  800b4b:	89 e5                	mov    %esp,%ebp
  800b4d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map,
  800b50:	ff 75 18             	push   0x18(%ebp)
  800b53:	ff 75 14             	push   0x14(%ebp)
  800b56:	ff 75 10             	push   0x10(%ebp)
  800b59:	ff 75 0c             	push   0xc(%ebp)
  800b5c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b5f:	ba 01 00 00 00       	mov    $0x1,%edx
  800b64:	b8 05 00 00 00       	mov    $0x5,%eax
  800b69:	e8 b8 fe ff ff       	call   800a26 <syscall>
	               srcenv,
	               (uint32_t) srcva,
	               dstenv,
	               (uint32_t) dstva,
	               perm);
}
  800b6e:	c9                   	leave  
  800b6f:	c3                   	ret    

00800b70 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b70:	55                   	push   %ebp
  800b71:	89 e5                	mov    %esp,%ebp
  800b73:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800b76:	6a 00                	push   $0x0
  800b78:	6a 00                	push   $0x0
  800b7a:	6a 00                	push   $0x0
  800b7c:	ff 75 0c             	push   0xc(%ebp)
  800b7f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b82:	ba 01 00 00 00       	mov    $0x1,%edx
  800b87:	b8 06 00 00 00       	mov    $0x6,%eax
  800b8c:	e8 95 fe ff ff       	call   800a26 <syscall>
}
  800b91:	c9                   	leave  
  800b92:	c3                   	ret    

00800b93 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800b93:	55                   	push   %ebp
  800b94:	89 e5                	mov    %esp,%ebp
  800b96:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800b99:	6a 00                	push   $0x0
  800b9b:	6a 00                	push   $0x0
  800b9d:	6a 00                	push   $0x0
  800b9f:	ff 75 0c             	push   0xc(%ebp)
  800ba2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ba5:	ba 01 00 00 00       	mov    $0x1,%edx
  800baa:	b8 08 00 00 00       	mov    $0x8,%eax
  800baf:	e8 72 fe ff ff       	call   800a26 <syscall>
}
  800bb4:	c9                   	leave  
  800bb5:	c3                   	ret    

00800bb6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800bb6:	55                   	push   %ebp
  800bb7:	89 e5                	mov    %esp,%ebp
  800bb9:	83 ec 08             	sub    $0x8,%esp
	return syscall(
  800bbc:	6a 00                	push   $0x0
  800bbe:	6a 00                	push   $0x0
  800bc0:	6a 00                	push   $0x0
  800bc2:	ff 75 0c             	push   0xc(%ebp)
  800bc5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bc8:	ba 01 00 00 00       	mov    $0x1,%edx
  800bcd:	b8 09 00 00 00       	mov    $0x9,%eax
  800bd2:	e8 4f fe ff ff       	call   800a26 <syscall>
	        SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800bd7:	c9                   	leave  
  800bd8:	c3                   	ret    

00800bd9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800bd9:	55                   	push   %ebp
  800bda:	89 e5                	mov    %esp,%ebp
  800bdc:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800bdf:	6a 00                	push   $0x0
  800be1:	ff 75 14             	push   0x14(%ebp)
  800be4:	ff 75 10             	push   0x10(%ebp)
  800be7:	ff 75 0c             	push   0xc(%ebp)
  800bea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bed:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf2:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bf7:	e8 2a fe ff ff       	call   800a26 <syscall>
}
  800bfc:	c9                   	leave  
  800bfd:	c3                   	ret    

00800bfe <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800bfe:	55                   	push   %ebp
  800bff:	89 e5                	mov    %esp,%ebp
  800c01:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t) dstva, 0, 0, 0, 0);
  800c04:	6a 00                	push   $0x0
  800c06:	6a 00                	push   $0x0
  800c08:	6a 00                	push   $0x0
  800c0a:	6a 00                	push   $0x0
  800c0c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c0f:	ba 01 00 00 00       	mov    $0x1,%edx
  800c14:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c19:	e8 08 fe ff ff       	call   800a26 <syscall>
}
  800c1e:	c9                   	leave  
  800c1f:	c3                   	ret    

00800c20 <sys_get_priority>:

// Get priority of the current process
int
sys_get_priority(void)
{
  800c20:	55                   	push   %ebp
  800c21:	89 e5                	mov    %esp,%ebp
  800c23:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_get_priority, 0, 0, 0, 0, 0, 0);
  800c26:	6a 00                	push   $0x0
  800c28:	6a 00                	push   $0x0
  800c2a:	6a 00                	push   $0x0
  800c2c:	6a 00                	push   $0x0
  800c2e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c33:	ba 00 00 00 00       	mov    $0x0,%edx
  800c38:	b8 0d 00 00 00       	mov    $0xd,%eax
  800c3d:	e8 e4 fd ff ff       	call   800a26 <syscall>
}
  800c42:	c9                   	leave  
  800c43:	c3                   	ret    

00800c44 <sys_set_priority>:

// Get priority of the current process
int
sys_set_priority(unsigned int priority)
{
  800c44:	55                   	push   %ebp
  800c45:	89 e5                	mov    %esp,%ebp
  800c47:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, (uint32_t) priority, 0, 0, 0, 0);
  800c4a:	6a 00                	push   $0x0
  800c4c:	6a 00                	push   $0x0
  800c4e:	6a 00                	push   $0x0
  800c50:	6a 00                	push   $0x0
  800c52:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c55:	ba 00 00 00 00       	mov    $0x0,%edx
  800c5a:	b8 0e 00 00 00       	mov    $0xe,%eax
  800c5f:	e8 c2 fd ff ff       	call   800a26 <syscall>
}
  800c64:	c9                   	leave  
  800c65:	c3                   	ret    

00800c66 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800c66:	55                   	push   %ebp
  800c67:	89 e5                	mov    %esp,%ebp
  800c69:	56                   	push   %esi
  800c6a:	53                   	push   %ebx
  800c6b:	89 c1                	mov    %eax,%ecx
	int r;

	void *addr = (void *) (pn << PGSHIFT);
  800c6d:	89 d6                	mov    %edx,%esi
  800c6f:	c1 e6 0c             	shl    $0xc,%esi

	pte_t pte = uvpt[pn];
  800c72:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx

	if (!(pte & PTE_P) || !(pte & PTE_U))
  800c79:	89 d0                	mov    %edx,%eax
  800c7b:	83 e0 05             	and    $0x5,%eax
  800c7e:	83 f8 05             	cmp    $0x5,%eax
  800c81:	75 5a                	jne    800cdd <duppage+0x77>
		panic("duppage: copy a non-present or non-user page");

	int perm = PTE_U | PTE_P;
	// Verifico permisos para páginas de IO
	if (pte & (PTE_PCD | PTE_PWT))
  800c83:	89 d0                	mov    %edx,%eax
  800c85:	83 e0 18             	and    $0x18,%eax
		perm |= PTE_PCD | PTE_PWT;
  800c88:	83 f8 01             	cmp    $0x1,%eax
  800c8b:	19 c0                	sbb    %eax,%eax
  800c8d:	83 e0 e8             	and    $0xffffffe8,%eax
  800c90:	83 c0 1d             	add    $0x1d,%eax


	// Si es de escritura o copy-on-write y NO es de IO
	if ((pte & PTE_W) || (pte & PTE_COW)) {
  800c93:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800c99:	74 68                	je     800d03 <duppage+0x9d>
		// Mappeo en el hijo la página
		if ((r = sys_page_map(0, addr, envid, addr, perm | PTE_COW)) < 0)
  800c9b:	80 cc 08             	or     $0x8,%ah
  800c9e:	89 c3                	mov    %eax,%ebx
  800ca0:	83 ec 0c             	sub    $0xc,%esp
  800ca3:	50                   	push   %eax
  800ca4:	56                   	push   %esi
  800ca5:	51                   	push   %ecx
  800ca6:	56                   	push   %esi
  800ca7:	6a 00                	push   $0x0
  800ca9:	e8 9c fe ff ff       	call   800b4a <sys_page_map>
  800cae:	83 c4 20             	add    $0x20,%esp
  800cb1:	85 c0                	test   %eax,%eax
  800cb3:	78 3c                	js     800cf1 <duppage+0x8b>
			panic("duppage: sys_page_map on childern COW: %e", r);

		// Cambio los permisos del padre
		if ((r = sys_page_map(0, addr, 0, addr, perm | PTE_COW)) < 0)
  800cb5:	83 ec 0c             	sub    $0xc,%esp
  800cb8:	53                   	push   %ebx
  800cb9:	56                   	push   %esi
  800cba:	6a 00                	push   $0x0
  800cbc:	56                   	push   %esi
  800cbd:	6a 00                	push   $0x0
  800cbf:	e8 86 fe ff ff       	call   800b4a <sys_page_map>
  800cc4:	83 c4 20             	add    $0x20,%esp
  800cc7:	85 c0                	test   %eax,%eax
  800cc9:	79 4d                	jns    800d18 <duppage+0xb2>
			panic("duppage: sys_page_map on parent COW: %e", r);
  800ccb:	50                   	push   %eax
  800ccc:	68 2c 17 80 00       	push   $0x80172c
  800cd1:	6a 57                	push   $0x57
  800cd3:	68 21 18 80 00       	push   $0x801821
  800cd8:	e8 eb 03 00 00       	call   8010c8 <_panic>
		panic("duppage: copy a non-present or non-user page");
  800cdd:	83 ec 04             	sub    $0x4,%esp
  800ce0:	68 d0 16 80 00       	push   $0x8016d0
  800ce5:	6a 47                	push   $0x47
  800ce7:	68 21 18 80 00       	push   $0x801821
  800cec:	e8 d7 03 00 00       	call   8010c8 <_panic>
			panic("duppage: sys_page_map on childern COW: %e", r);
  800cf1:	50                   	push   %eax
  800cf2:	68 00 17 80 00       	push   $0x801700
  800cf7:	6a 53                	push   $0x53
  800cf9:	68 21 18 80 00       	push   $0x801821
  800cfe:	e8 c5 03 00 00       	call   8010c8 <_panic>
	} else {
		// Solo mappeo la página de solo lectura
		if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  800d03:	83 ec 0c             	sub    $0xc,%esp
  800d06:	50                   	push   %eax
  800d07:	56                   	push   %esi
  800d08:	51                   	push   %ecx
  800d09:	56                   	push   %esi
  800d0a:	6a 00                	push   $0x0
  800d0c:	e8 39 fe ff ff       	call   800b4a <sys_page_map>
  800d11:	83 c4 20             	add    $0x20,%esp
  800d14:	85 c0                	test   %eax,%eax
  800d16:	78 0c                	js     800d24 <duppage+0xbe>
			panic("duppage: sys_page_map on childern RO: %e", r);
	}

	// panic("duppage not implemented");
	return 0;
}
  800d18:	b8 00 00 00 00       	mov    $0x0,%eax
  800d1d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d20:	5b                   	pop    %ebx
  800d21:	5e                   	pop    %esi
  800d22:	5d                   	pop    %ebp
  800d23:	c3                   	ret    
			panic("duppage: sys_page_map on childern RO: %e", r);
  800d24:	50                   	push   %eax
  800d25:	68 54 17 80 00       	push   $0x801754
  800d2a:	6a 5b                	push   $0x5b
  800d2c:	68 21 18 80 00       	push   $0x801821
  800d31:	e8 92 03 00 00       	call   8010c8 <_panic>

00800d36 <dup_or_share>:
 *
 * Hace uso de uvpd y uvpt para chequear permisos.
 */
static void
dup_or_share(envid_t envid, uint32_t pnum, int perm)
{
  800d36:	55                   	push   %ebp
  800d37:	89 e5                	mov    %esp,%ebp
  800d39:	57                   	push   %edi
  800d3a:	56                   	push   %esi
  800d3b:	53                   	push   %ebx
  800d3c:	83 ec 0c             	sub    $0xc,%esp
  800d3f:	89 c7                	mov    %eax,%edi
	int r;
	void *addr = (void *) (pnum << PGSHIFT);

	pte_t pte = uvpt[pnum];
  800d41:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax

	if (!(pte & PTE_P))
  800d48:	a8 01                	test   $0x1,%al
  800d4a:	74 33                	je     800d7f <dup_or_share+0x49>
  800d4c:	89 d6                	mov    %edx,%esi
		return;

	// Filtro permisos
	perm &= (pte & PTE_W);
  800d4e:	21 c1                	and    %eax,%ecx
  800d50:	89 cb                	mov    %ecx,%ebx
  800d52:	83 e3 02             	and    $0x2,%ebx
	perm &= PTE_SYSCALL;


	if (pte & (PTE_PCD | PTE_PWT))
		perm |= PTE_PCD | PTE_PWT;
  800d55:	89 da                	mov    %ebx,%edx
  800d57:	83 ca 18             	or     $0x18,%edx
  800d5a:	a8 18                	test   $0x18,%al
  800d5c:	0f 45 da             	cmovne %edx,%ebx
	void *addr = (void *) (pnum << PGSHIFT);
  800d5f:	c1 e6 0c             	shl    $0xc,%esi

	// Si tengo que copiar
	if (!(pte & PTE_W) || (pte & (PTE_PCD | PTE_PWT))) {
  800d62:	83 e0 1a             	and    $0x1a,%eax
  800d65:	83 f8 02             	cmp    $0x2,%eax
  800d68:	74 32                	je     800d9c <dup_or_share+0x66>
		if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  800d6a:	83 ec 0c             	sub    $0xc,%esp
  800d6d:	53                   	push   %ebx
  800d6e:	56                   	push   %esi
  800d6f:	57                   	push   %edi
  800d70:	56                   	push   %esi
  800d71:	6a 00                	push   $0x0
  800d73:	e8 d2 fd ff ff       	call   800b4a <sys_page_map>
  800d78:	83 c4 20             	add    $0x20,%esp
  800d7b:	85 c0                	test   %eax,%eax
  800d7d:	78 08                	js     800d87 <dup_or_share+0x51>
			panic("dup_or_share: sys_page_map: %e", r);
		memmove(UTEMP, addr, PGSIZE);
		if ((r = sys_page_unmap(0, UTEMP)) < 0)
			panic("sys_page_unmap: %e", r);
	}
}
  800d7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d82:	5b                   	pop    %ebx
  800d83:	5e                   	pop    %esi
  800d84:	5f                   	pop    %edi
  800d85:	5d                   	pop    %ebp
  800d86:	c3                   	ret    
			panic("dup_or_share: sys_page_map: %e", r);
  800d87:	50                   	push   %eax
  800d88:	68 80 17 80 00       	push   $0x801780
  800d8d:	68 84 00 00 00       	push   $0x84
  800d92:	68 21 18 80 00       	push   $0x801821
  800d97:	e8 2c 03 00 00       	call   8010c8 <_panic>
		if ((r = sys_page_alloc(envid, addr, perm)) < 0)
  800d9c:	83 ec 04             	sub    $0x4,%esp
  800d9f:	53                   	push   %ebx
  800da0:	56                   	push   %esi
  800da1:	57                   	push   %edi
  800da2:	e8 7f fd ff ff       	call   800b26 <sys_page_alloc>
  800da7:	83 c4 10             	add    $0x10,%esp
  800daa:	85 c0                	test   %eax,%eax
  800dac:	78 57                	js     800e05 <dup_or_share+0xcf>
		if ((r = sys_page_map(envid, addr, 0, UTEMP, perm)) < 0)
  800dae:	83 ec 0c             	sub    $0xc,%esp
  800db1:	53                   	push   %ebx
  800db2:	68 00 00 40 00       	push   $0x400000
  800db7:	6a 00                	push   $0x0
  800db9:	56                   	push   %esi
  800dba:	57                   	push   %edi
  800dbb:	e8 8a fd ff ff       	call   800b4a <sys_page_map>
  800dc0:	83 c4 20             	add    $0x20,%esp
  800dc3:	85 c0                	test   %eax,%eax
  800dc5:	78 53                	js     800e1a <dup_or_share+0xe4>
		memmove(UTEMP, addr, PGSIZE);
  800dc7:	83 ec 04             	sub    $0x4,%esp
  800dca:	68 00 10 00 00       	push   $0x1000
  800dcf:	56                   	push   %esi
  800dd0:	68 00 00 40 00       	push   $0x400000
  800dd5:	e8 a2 fa ff ff       	call   80087c <memmove>
		if ((r = sys_page_unmap(0, UTEMP)) < 0)
  800dda:	83 c4 08             	add    $0x8,%esp
  800ddd:	68 00 00 40 00       	push   $0x400000
  800de2:	6a 00                	push   $0x0
  800de4:	e8 87 fd ff ff       	call   800b70 <sys_page_unmap>
  800de9:	83 c4 10             	add    $0x10,%esp
  800dec:	85 c0                	test   %eax,%eax
  800dee:	79 8f                	jns    800d7f <dup_or_share+0x49>
			panic("sys_page_unmap: %e", r);
  800df0:	50                   	push   %eax
  800df1:	68 6b 18 80 00       	push   $0x80186b
  800df6:	68 8d 00 00 00       	push   $0x8d
  800dfb:	68 21 18 80 00       	push   $0x801821
  800e00:	e8 c3 02 00 00       	call   8010c8 <_panic>
			panic("dup_or_share: sys_page_alloc: %e", r);
  800e05:	50                   	push   %eax
  800e06:	68 a0 17 80 00       	push   $0x8017a0
  800e0b:	68 88 00 00 00       	push   $0x88
  800e10:	68 21 18 80 00       	push   $0x801821
  800e15:	e8 ae 02 00 00       	call   8010c8 <_panic>
			panic("dup_or_share: sys_page_map: %e", r);
  800e1a:	50                   	push   %eax
  800e1b:	68 80 17 80 00       	push   $0x801780
  800e20:	68 8a 00 00 00       	push   $0x8a
  800e25:	68 21 18 80 00       	push   $0x801821
  800e2a:	e8 99 02 00 00       	call   8010c8 <_panic>

00800e2f <pgfault>:
{
  800e2f:	55                   	push   %ebp
  800e30:	89 e5                	mov    %esp,%ebp
  800e32:	53                   	push   %ebx
  800e33:	83 ec 08             	sub    $0x8,%esp
	void *addr = (void *) utf->utf_fault_va;
  800e36:	8b 45 08             	mov    0x8(%ebp),%eax
  800e39:	8b 18                	mov    (%eax),%ebx
	pte_t fault_pte = uvpt[((uint32_t) addr) >> PGSHIFT];
  800e3b:	89 d8                	mov    %ebx,%eax
  800e3d:	c1 e8 0c             	shr    $0xc,%eax
  800e40:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if ((r = sys_page_alloc(0, PFTEMP, perm)) < 0)
  800e47:	6a 07                	push   $0x7
  800e49:	68 00 f0 7f 00       	push   $0x7ff000
  800e4e:	6a 00                	push   $0x0
  800e50:	e8 d1 fc ff ff       	call   800b26 <sys_page_alloc>
  800e55:	83 c4 10             	add    $0x10,%esp
  800e58:	85 c0                	test   %eax,%eax
  800e5a:	78 51                	js     800ead <pgfault+0x7e>
	addr = ROUNDDOWN(addr, PGSIZE);
  800e5c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr, PGSIZE);
  800e62:	83 ec 04             	sub    $0x4,%esp
  800e65:	68 00 10 00 00       	push   $0x1000
  800e6a:	53                   	push   %ebx
  800e6b:	68 00 f0 7f 00       	push   $0x7ff000
  800e70:	e8 07 fa ff ff       	call   80087c <memmove>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, perm)) < 0)
  800e75:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e7c:	53                   	push   %ebx
  800e7d:	6a 00                	push   $0x0
  800e7f:	68 00 f0 7f 00       	push   $0x7ff000
  800e84:	6a 00                	push   $0x0
  800e86:	e8 bf fc ff ff       	call   800b4a <sys_page_map>
  800e8b:	83 c4 20             	add    $0x20,%esp
  800e8e:	85 c0                	test   %eax,%eax
  800e90:	78 2d                	js     800ebf <pgfault+0x90>
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800e92:	83 ec 08             	sub    $0x8,%esp
  800e95:	68 00 f0 7f 00       	push   $0x7ff000
  800e9a:	6a 00                	push   $0x0
  800e9c:	e8 cf fc ff ff       	call   800b70 <sys_page_unmap>
  800ea1:	83 c4 10             	add    $0x10,%esp
  800ea4:	85 c0                	test   %eax,%eax
  800ea6:	78 29                	js     800ed1 <pgfault+0xa2>
}
  800ea8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eab:	c9                   	leave  
  800eac:	c3                   	ret    
		panic("pgfault: sys_page_alloc: %e", r);
  800ead:	50                   	push   %eax
  800eae:	68 2c 18 80 00       	push   $0x80182c
  800eb3:	6a 27                	push   $0x27
  800eb5:	68 21 18 80 00       	push   $0x801821
  800eba:	e8 09 02 00 00       	call   8010c8 <_panic>
		panic("pgfault: sys_page_map: %e", r);
  800ebf:	50                   	push   %eax
  800ec0:	68 48 18 80 00       	push   $0x801848
  800ec5:	6a 2c                	push   $0x2c
  800ec7:	68 21 18 80 00       	push   $0x801821
  800ecc:	e8 f7 01 00 00       	call   8010c8 <_panic>
		panic("pgfault: sys_page_unmap: %e", r);
  800ed1:	50                   	push   %eax
  800ed2:	68 62 18 80 00       	push   $0x801862
  800ed7:	6a 2f                	push   $0x2f
  800ed9:	68 21 18 80 00       	push   $0x801821
  800ede:	e8 e5 01 00 00       	call   8010c8 <_panic>

00800ee3 <fork_v0>:
 *  	-- Para ello se utiliza la funcion dup_or_share()
 *  	-- Se copian todas las paginas desde 0 hasta UTOP
 */
envid_t
fork_v0(void)
{
  800ee3:	55                   	push   %ebp
  800ee4:	89 e5                	mov    %esp,%ebp
  800ee6:	56                   	push   %esi
  800ee7:	53                   	push   %ebx

// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline)) sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2" : "=a"(ret) : "a"(SYS_exofork), "i"(T_SYSCALL));
  800ee8:	b8 07 00 00 00       	mov    $0x7,%eax
  800eed:	cd 30                	int    $0x30
  800eef:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();
	if (envid < 0)
  800ef1:	85 c0                	test   %eax,%eax
  800ef3:	78 23                	js     800f18 <fork_v0+0x35>
	// Parent
	uint32_t pnum = 0;
	uint32_t pnum_end = (UTOP >> PGSHIFT);
	int perm = PTE_P | PTE_U | PTE_W;

	for (pnum = 0; pnum < pnum_end; pnum++) {
  800ef5:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid == 0) {
  800efa:	75 3c                	jne    800f38 <fork_v0+0x55>
		thisenv = &envs[ENVX(sys_getenvid())];
  800efc:	e8 da fb ff ff       	call   800adb <sys_getenvid>
  800f01:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f06:	69 c0 88 00 00 00    	imul   $0x88,%eax,%eax
  800f0c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f11:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800f16:	eb 56                	jmp    800f6e <fork_v0+0x8b>
		panic("sys_exofork: %e", envid);
  800f18:	50                   	push   %eax
  800f19:	68 7e 18 80 00       	push   $0x80187e
  800f1e:	68 a2 00 00 00       	push   $0xa2
  800f23:	68 21 18 80 00       	push   $0x801821
  800f28:	e8 9b 01 00 00       	call   8010c8 <_panic>
	for (pnum = 0; pnum < pnum_end; pnum++) {
  800f2d:	83 c3 01             	add    $0x1,%ebx
  800f30:	81 fb 00 ec 0e 00    	cmp    $0xeec00,%ebx
  800f36:	74 24                	je     800f5c <fork_v0+0x79>
		pde_t pde = uvpd[pnum >> 10];
  800f38:	89 d8                	mov    %ebx,%eax
  800f3a:	c1 e8 0a             	shr    $0xa,%eax
  800f3d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
		if (!(pde & PTE_P) || !(pde & PTE_U))
  800f44:	83 e0 05             	and    $0x5,%eax
  800f47:	83 f8 05             	cmp    $0x5,%eax
  800f4a:	75 e1                	jne    800f2d <fork_v0+0x4a>
			continue;
		dup_or_share(envid, pnum, perm);
  800f4c:	b9 07 00 00 00       	mov    $0x7,%ecx
  800f51:	89 da                	mov    %ebx,%edx
  800f53:	89 f0                	mov    %esi,%eax
  800f55:	e8 dc fd ff ff       	call   800d36 <dup_or_share>
  800f5a:	eb d1                	jmp    800f2d <fork_v0+0x4a>
	}


	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800f5c:	83 ec 08             	sub    $0x8,%esp
  800f5f:	6a 02                	push   $0x2
  800f61:	56                   	push   %esi
  800f62:	e8 2c fc ff ff       	call   800b93 <sys_env_set_status>
  800f67:	83 c4 10             	add    $0x10,%esp
  800f6a:	85 c0                	test   %eax,%eax
  800f6c:	78 09                	js     800f77 <fork_v0+0x94>
		panic("sys_env_set_status: %e", r);

	return envid;
}
  800f6e:	89 f0                	mov    %esi,%eax
  800f70:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f73:	5b                   	pop    %ebx
  800f74:	5e                   	pop    %esi
  800f75:	5d                   	pop    %ebp
  800f76:	c3                   	ret    
		panic("sys_env_set_status: %e", r);
  800f77:	50                   	push   %eax
  800f78:	68 8e 18 80 00       	push   $0x80188e
  800f7d:	68 b8 00 00 00       	push   $0xb8
  800f82:	68 21 18 80 00       	push   $0x801821
  800f87:	e8 3c 01 00 00       	call   8010c8 <_panic>

00800f8c <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f8c:	55                   	push   %ebp
  800f8d:	89 e5                	mov    %esp,%ebp
  800f8f:	56                   	push   %esi
  800f90:	53                   	push   %ebx
	set_pgfault_handler(pgfault);
  800f91:	83 ec 0c             	sub    $0xc,%esp
  800f94:	68 2f 0e 80 00       	push   $0x800e2f
  800f99:	e8 70 01 00 00       	call   80110e <set_pgfault_handler>
  800f9e:	b8 07 00 00 00       	mov    $0x7,%eax
  800fa3:	cd 30                	int    $0x30
  800fa5:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();

	if (envid < 0)
  800fa7:	83 c4 10             	add    $0x10,%esp
  800faa:	85 c0                	test   %eax,%eax
  800fac:	78 26                	js     800fd4 <fork+0x48>
	// Parent
	uint32_t pnum = 0;
	uint32_t pnum_end = (UTOP >> PGSHIFT);

	// Handle all pages below UTOP
	for (pnum = 0; pnum < pnum_end; pnum++) {
  800fae:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid == 0) {
  800fb3:	75 41                	jne    800ff6 <fork+0x6a>
		thisenv = &envs[ENVX(sys_getenvid())];
  800fb5:	e8 21 fb ff ff       	call   800adb <sys_getenvid>
  800fba:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fbf:	69 c0 88 00 00 00    	imul   $0x88,%eax,%eax
  800fc5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fca:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800fcf:	e9 92 00 00 00       	jmp    801066 <fork+0xda>
		panic("sys_exofork: %e", envid);
  800fd4:	50                   	push   %eax
  800fd5:	68 7e 18 80 00       	push   $0x80187e
  800fda:	68 d5 00 00 00       	push   $0xd5
  800fdf:	68 21 18 80 00       	push   $0x801821
  800fe4:	e8 df 00 00 00       	call   8010c8 <_panic>
	for (pnum = 0; pnum < pnum_end; pnum++) {
  800fe9:	83 c3 01             	add    $0x1,%ebx
  800fec:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  800ff2:	77 30                	ja     801024 <fork+0x98>
		if (pnum == ((UXSTACKTOP >> PGSHIFT) - 1))
  800ff4:	74 f3                	je     800fe9 <fork+0x5d>
			continue;

		pde_t pde = uvpd[pnum >> 10];
  800ff6:	89 d8                	mov    %ebx,%eax
  800ff8:	c1 e8 0a             	shr    $0xa,%eax
  800ffb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
		if (!(pde & PTE_P) || !(pde & PTE_U))
  801002:	83 e0 05             	and    $0x5,%eax
  801005:	83 f8 05             	cmp    $0x5,%eax
  801008:	75 df                	jne    800fe9 <fork+0x5d>
			continue;

		pte_t pte = uvpt[pnum];
  80100a:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
		if (!(pte & PTE_P) || !(pte & PTE_U))
  801011:	83 e0 05             	and    $0x5,%eax
  801014:	83 f8 05             	cmp    $0x5,%eax
  801017:	75 d0                	jne    800fe9 <fork+0x5d>
			continue;
		duppage(envid, pnum);
  801019:	89 da                	mov    %ebx,%edx
  80101b:	89 f0                	mov    %esi,%eax
  80101d:	e8 44 fc ff ff       	call   800c66 <duppage>
  801022:	eb c5                	jmp    800fe9 <fork+0x5d>
	}

	uint32_t exstk = (UXSTACKTOP - PGSIZE);
	int r = sys_page_alloc(envid, (void *) exstk, PTE_U | PTE_P | PTE_W);
  801024:	83 ec 04             	sub    $0x4,%esp
  801027:	6a 07                	push   $0x7
  801029:	68 00 f0 bf ee       	push   $0xeebff000
  80102e:	56                   	push   %esi
  80102f:	e8 f2 fa ff ff       	call   800b26 <sys_page_alloc>
	if (r < 0)
  801034:	83 c4 10             	add    $0x10,%esp
  801037:	85 c0                	test   %eax,%eax
  801039:	78 34                	js     80106f <fork+0xe3>
		panic("fork: sys_page_alloc of exception stk: %e", r);
	r = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  80103b:	a1 04 20 80 00       	mov    0x802004,%eax
  801040:	8b 40 70             	mov    0x70(%eax),%eax
  801043:	83 ec 08             	sub    $0x8,%esp
  801046:	50                   	push   %eax
  801047:	56                   	push   %esi
  801048:	e8 69 fb ff ff       	call   800bb6 <sys_env_set_pgfault_upcall>
	if (r < 0)
  80104d:	83 c4 10             	add    $0x10,%esp
  801050:	85 c0                	test   %eax,%eax
  801052:	78 30                	js     801084 <fork+0xf8>
		panic("fork: sys_env_set_pgfault_upcall on childern: %e", r);

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  801054:	83 ec 08             	sub    $0x8,%esp
  801057:	6a 02                	push   $0x2
  801059:	56                   	push   %esi
  80105a:	e8 34 fb ff ff       	call   800b93 <sys_env_set_status>
  80105f:	83 c4 10             	add    $0x10,%esp
  801062:	85 c0                	test   %eax,%eax
  801064:	78 33                	js     801099 <fork+0x10d>
		panic("sys_env_set_status: %e", r);

	return envid;
}
  801066:	89 f0                	mov    %esi,%eax
  801068:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80106b:	5b                   	pop    %ebx
  80106c:	5e                   	pop    %esi
  80106d:	5d                   	pop    %ebp
  80106e:	c3                   	ret    
		panic("fork: sys_page_alloc of exception stk: %e", r);
  80106f:	50                   	push   %eax
  801070:	68 c4 17 80 00       	push   $0x8017c4
  801075:	68 f2 00 00 00       	push   $0xf2
  80107a:	68 21 18 80 00       	push   $0x801821
  80107f:	e8 44 00 00 00       	call   8010c8 <_panic>
		panic("fork: sys_env_set_pgfault_upcall on childern: %e", r);
  801084:	50                   	push   %eax
  801085:	68 f0 17 80 00       	push   $0x8017f0
  80108a:	68 f5 00 00 00       	push   $0xf5
  80108f:	68 21 18 80 00       	push   $0x801821
  801094:	e8 2f 00 00 00       	call   8010c8 <_panic>
		panic("sys_env_set_status: %e", r);
  801099:	50                   	push   %eax
  80109a:	68 8e 18 80 00       	push   $0x80188e
  80109f:	68 f8 00 00 00       	push   $0xf8
  8010a4:	68 21 18 80 00       	push   $0x801821
  8010a9:	e8 1a 00 00 00       	call   8010c8 <_panic>

008010ae <sfork>:

// Challenge!
int
sfork(void)
{
  8010ae:	55                   	push   %ebp
  8010af:	89 e5                	mov    %esp,%ebp
  8010b1:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010b4:	68 a5 18 80 00       	push   $0x8018a5
  8010b9:	68 01 01 00 00       	push   $0x101
  8010be:	68 21 18 80 00       	push   $0x801821
  8010c3:	e8 00 00 00 00       	call   8010c8 <_panic>

008010c8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8010c8:	55                   	push   %ebp
  8010c9:	89 e5                	mov    %esp,%ebp
  8010cb:	56                   	push   %esi
  8010cc:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8010cd:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8010d0:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8010d6:	e8 00 fa ff ff       	call   800adb <sys_getenvid>
  8010db:	83 ec 0c             	sub    $0xc,%esp
  8010de:	ff 75 0c             	push   0xc(%ebp)
  8010e1:	ff 75 08             	push   0x8(%ebp)
  8010e4:	56                   	push   %esi
  8010e5:	50                   	push   %eax
  8010e6:	68 bc 18 80 00       	push   $0x8018bc
  8010eb:	e8 b9 f0 ff ff       	call   8001a9 <cprintf>
	        sys_getenvid(),
	        binaryname,
	        file,
	        line);
	vcprintf(fmt, ap);
  8010f0:	83 c4 18             	add    $0x18,%esp
  8010f3:	53                   	push   %ebx
  8010f4:	ff 75 10             	push   0x10(%ebp)
  8010f7:	e8 5c f0 ff ff       	call   800158 <vcprintf>
	cprintf("\n");
  8010fc:	c7 04 24 54 14 80 00 	movl   $0x801454,(%esp)
  801103:	e8 a1 f0 ff ff       	call   8001a9 <cprintf>
  801108:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80110b:	cc                   	int3   
  80110c:	eb fd                	jmp    80110b <_panic+0x43>

0080110e <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80110e:	55                   	push   %ebp
  80110f:	89 e5                	mov    %esp,%ebp
  801111:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801114:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  80111b:	74 0a                	je     801127 <set_pgfault_handler+0x19>
		if (r < 0)
			return;
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80111d:	8b 45 08             	mov    0x8(%ebp),%eax
  801120:	a3 08 20 80 00       	mov    %eax,0x802008
}
  801125:	c9                   	leave  
  801126:	c3                   	ret    
		r = sys_page_alloc(0, (void *) exstk, perm);
  801127:	83 ec 04             	sub    $0x4,%esp
  80112a:	6a 07                	push   $0x7
  80112c:	68 00 f0 bf ee       	push   $0xeebff000
  801131:	6a 00                	push   $0x0
  801133:	e8 ee f9 ff ff       	call   800b26 <sys_page_alloc>
		if (r < 0)
  801138:	83 c4 10             	add    $0x10,%esp
  80113b:	85 c0                	test   %eax,%eax
  80113d:	78 e6                	js     801125 <set_pgfault_handler+0x17>
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  80113f:	83 ec 08             	sub    $0x8,%esp
  801142:	68 57 11 80 00       	push   $0x801157
  801147:	6a 00                	push   $0x0
  801149:	e8 68 fa ff ff       	call   800bb6 <sys_env_set_pgfault_upcall>
		if (r < 0)
  80114e:	83 c4 10             	add    $0x10,%esp
  801151:	85 c0                	test   %eax,%eax
  801153:	79 c8                	jns    80111d <set_pgfault_handler+0xf>
  801155:	eb ce                	jmp    801125 <set_pgfault_handler+0x17>

00801157 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801157:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801158:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  80115d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80115f:	83 c4 04             	add    $0x4,%esp
	// Throughout the remaining code, think carefully about what
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	movl 40(%esp), %eax	// trap-time %epi -> %eax 
  801162:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %ebx	// trap-time %esp -> %ebx
  801166:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4, %ebx
  80116a:	83 eb 04             	sub    $0x4,%ebx
	movl %eax, 0(%ebx)	// push %eip in trap-time stack
  80116d:	89 03                	mov    %eax,(%ebx)

	movl %ebx, 48(%esp)
  80116f:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	popl %eax
  801173:	58                   	pop    %eax
	popl %eax
  801174:	58                   	pop    %eax
	popal
  801175:	61                   	popa   
	

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	addl $4, %esp
  801176:	83 c4 04             	add    $0x4,%esp
	popfl
  801179:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	popl %esp
  80117a:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	ret
  80117b:	c3                   	ret    
  80117c:	66 90                	xchg   %ax,%ax
  80117e:	66 90                	xchg   %ax,%ax

00801180 <__udivdi3>:
  801180:	f3 0f 1e fb          	endbr32 
  801184:	55                   	push   %ebp
  801185:	57                   	push   %edi
  801186:	56                   	push   %esi
  801187:	53                   	push   %ebx
  801188:	83 ec 1c             	sub    $0x1c,%esp
  80118b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80118f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801193:	8b 74 24 34          	mov    0x34(%esp),%esi
  801197:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80119b:	85 c0                	test   %eax,%eax
  80119d:	75 19                	jne    8011b8 <__udivdi3+0x38>
  80119f:	39 f3                	cmp    %esi,%ebx
  8011a1:	76 4d                	jbe    8011f0 <__udivdi3+0x70>
  8011a3:	31 ff                	xor    %edi,%edi
  8011a5:	89 e8                	mov    %ebp,%eax
  8011a7:	89 f2                	mov    %esi,%edx
  8011a9:	f7 f3                	div    %ebx
  8011ab:	89 fa                	mov    %edi,%edx
  8011ad:	83 c4 1c             	add    $0x1c,%esp
  8011b0:	5b                   	pop    %ebx
  8011b1:	5e                   	pop    %esi
  8011b2:	5f                   	pop    %edi
  8011b3:	5d                   	pop    %ebp
  8011b4:	c3                   	ret    
  8011b5:	8d 76 00             	lea    0x0(%esi),%esi
  8011b8:	39 f0                	cmp    %esi,%eax
  8011ba:	76 14                	jbe    8011d0 <__udivdi3+0x50>
  8011bc:	31 ff                	xor    %edi,%edi
  8011be:	31 c0                	xor    %eax,%eax
  8011c0:	89 fa                	mov    %edi,%edx
  8011c2:	83 c4 1c             	add    $0x1c,%esp
  8011c5:	5b                   	pop    %ebx
  8011c6:	5e                   	pop    %esi
  8011c7:	5f                   	pop    %edi
  8011c8:	5d                   	pop    %ebp
  8011c9:	c3                   	ret    
  8011ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8011d0:	0f bd f8             	bsr    %eax,%edi
  8011d3:	83 f7 1f             	xor    $0x1f,%edi
  8011d6:	75 48                	jne    801220 <__udivdi3+0xa0>
  8011d8:	39 f0                	cmp    %esi,%eax
  8011da:	72 06                	jb     8011e2 <__udivdi3+0x62>
  8011dc:	31 c0                	xor    %eax,%eax
  8011de:	39 eb                	cmp    %ebp,%ebx
  8011e0:	77 de                	ja     8011c0 <__udivdi3+0x40>
  8011e2:	b8 01 00 00 00       	mov    $0x1,%eax
  8011e7:	eb d7                	jmp    8011c0 <__udivdi3+0x40>
  8011e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011f0:	89 d9                	mov    %ebx,%ecx
  8011f2:	85 db                	test   %ebx,%ebx
  8011f4:	75 0b                	jne    801201 <__udivdi3+0x81>
  8011f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8011fb:	31 d2                	xor    %edx,%edx
  8011fd:	f7 f3                	div    %ebx
  8011ff:	89 c1                	mov    %eax,%ecx
  801201:	31 d2                	xor    %edx,%edx
  801203:	89 f0                	mov    %esi,%eax
  801205:	f7 f1                	div    %ecx
  801207:	89 c6                	mov    %eax,%esi
  801209:	89 e8                	mov    %ebp,%eax
  80120b:	89 f7                	mov    %esi,%edi
  80120d:	f7 f1                	div    %ecx
  80120f:	89 fa                	mov    %edi,%edx
  801211:	83 c4 1c             	add    $0x1c,%esp
  801214:	5b                   	pop    %ebx
  801215:	5e                   	pop    %esi
  801216:	5f                   	pop    %edi
  801217:	5d                   	pop    %ebp
  801218:	c3                   	ret    
  801219:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801220:	89 f9                	mov    %edi,%ecx
  801222:	ba 20 00 00 00       	mov    $0x20,%edx
  801227:	29 fa                	sub    %edi,%edx
  801229:	d3 e0                	shl    %cl,%eax
  80122b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80122f:	89 d1                	mov    %edx,%ecx
  801231:	89 d8                	mov    %ebx,%eax
  801233:	d3 e8                	shr    %cl,%eax
  801235:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801239:	09 c1                	or     %eax,%ecx
  80123b:	89 f0                	mov    %esi,%eax
  80123d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801241:	89 f9                	mov    %edi,%ecx
  801243:	d3 e3                	shl    %cl,%ebx
  801245:	89 d1                	mov    %edx,%ecx
  801247:	d3 e8                	shr    %cl,%eax
  801249:	89 f9                	mov    %edi,%ecx
  80124b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80124f:	89 eb                	mov    %ebp,%ebx
  801251:	d3 e6                	shl    %cl,%esi
  801253:	89 d1                	mov    %edx,%ecx
  801255:	d3 eb                	shr    %cl,%ebx
  801257:	09 f3                	or     %esi,%ebx
  801259:	89 c6                	mov    %eax,%esi
  80125b:	89 f2                	mov    %esi,%edx
  80125d:	89 d8                	mov    %ebx,%eax
  80125f:	f7 74 24 08          	divl   0x8(%esp)
  801263:	89 d6                	mov    %edx,%esi
  801265:	89 c3                	mov    %eax,%ebx
  801267:	f7 64 24 0c          	mull   0xc(%esp)
  80126b:	39 d6                	cmp    %edx,%esi
  80126d:	72 19                	jb     801288 <__udivdi3+0x108>
  80126f:	89 f9                	mov    %edi,%ecx
  801271:	d3 e5                	shl    %cl,%ebp
  801273:	39 c5                	cmp    %eax,%ebp
  801275:	73 04                	jae    80127b <__udivdi3+0xfb>
  801277:	39 d6                	cmp    %edx,%esi
  801279:	74 0d                	je     801288 <__udivdi3+0x108>
  80127b:	89 d8                	mov    %ebx,%eax
  80127d:	31 ff                	xor    %edi,%edi
  80127f:	e9 3c ff ff ff       	jmp    8011c0 <__udivdi3+0x40>
  801284:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801288:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80128b:	31 ff                	xor    %edi,%edi
  80128d:	e9 2e ff ff ff       	jmp    8011c0 <__udivdi3+0x40>
  801292:	66 90                	xchg   %ax,%ax
  801294:	66 90                	xchg   %ax,%ax
  801296:	66 90                	xchg   %ax,%ax
  801298:	66 90                	xchg   %ax,%ax
  80129a:	66 90                	xchg   %ax,%ax
  80129c:	66 90                	xchg   %ax,%ax
  80129e:	66 90                	xchg   %ax,%ax

008012a0 <__umoddi3>:
  8012a0:	f3 0f 1e fb          	endbr32 
  8012a4:	55                   	push   %ebp
  8012a5:	57                   	push   %edi
  8012a6:	56                   	push   %esi
  8012a7:	53                   	push   %ebx
  8012a8:	83 ec 1c             	sub    $0x1c,%esp
  8012ab:	8b 74 24 30          	mov    0x30(%esp),%esi
  8012af:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8012b3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  8012b7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  8012bb:	89 f0                	mov    %esi,%eax
  8012bd:	89 da                	mov    %ebx,%edx
  8012bf:	85 ff                	test   %edi,%edi
  8012c1:	75 15                	jne    8012d8 <__umoddi3+0x38>
  8012c3:	39 dd                	cmp    %ebx,%ebp
  8012c5:	76 39                	jbe    801300 <__umoddi3+0x60>
  8012c7:	f7 f5                	div    %ebp
  8012c9:	89 d0                	mov    %edx,%eax
  8012cb:	31 d2                	xor    %edx,%edx
  8012cd:	83 c4 1c             	add    $0x1c,%esp
  8012d0:	5b                   	pop    %ebx
  8012d1:	5e                   	pop    %esi
  8012d2:	5f                   	pop    %edi
  8012d3:	5d                   	pop    %ebp
  8012d4:	c3                   	ret    
  8012d5:	8d 76 00             	lea    0x0(%esi),%esi
  8012d8:	39 df                	cmp    %ebx,%edi
  8012da:	77 f1                	ja     8012cd <__umoddi3+0x2d>
  8012dc:	0f bd cf             	bsr    %edi,%ecx
  8012df:	83 f1 1f             	xor    $0x1f,%ecx
  8012e2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8012e6:	75 40                	jne    801328 <__umoddi3+0x88>
  8012e8:	39 df                	cmp    %ebx,%edi
  8012ea:	72 04                	jb     8012f0 <__umoddi3+0x50>
  8012ec:	39 f5                	cmp    %esi,%ebp
  8012ee:	77 dd                	ja     8012cd <__umoddi3+0x2d>
  8012f0:	89 da                	mov    %ebx,%edx
  8012f2:	89 f0                	mov    %esi,%eax
  8012f4:	29 e8                	sub    %ebp,%eax
  8012f6:	19 fa                	sbb    %edi,%edx
  8012f8:	eb d3                	jmp    8012cd <__umoddi3+0x2d>
  8012fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801300:	89 e9                	mov    %ebp,%ecx
  801302:	85 ed                	test   %ebp,%ebp
  801304:	75 0b                	jne    801311 <__umoddi3+0x71>
  801306:	b8 01 00 00 00       	mov    $0x1,%eax
  80130b:	31 d2                	xor    %edx,%edx
  80130d:	f7 f5                	div    %ebp
  80130f:	89 c1                	mov    %eax,%ecx
  801311:	89 d8                	mov    %ebx,%eax
  801313:	31 d2                	xor    %edx,%edx
  801315:	f7 f1                	div    %ecx
  801317:	89 f0                	mov    %esi,%eax
  801319:	f7 f1                	div    %ecx
  80131b:	89 d0                	mov    %edx,%eax
  80131d:	31 d2                	xor    %edx,%edx
  80131f:	eb ac                	jmp    8012cd <__umoddi3+0x2d>
  801321:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801328:	8b 44 24 04          	mov    0x4(%esp),%eax
  80132c:	ba 20 00 00 00       	mov    $0x20,%edx
  801331:	29 c2                	sub    %eax,%edx
  801333:	89 c1                	mov    %eax,%ecx
  801335:	89 e8                	mov    %ebp,%eax
  801337:	d3 e7                	shl    %cl,%edi
  801339:	89 d1                	mov    %edx,%ecx
  80133b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80133f:	d3 e8                	shr    %cl,%eax
  801341:	89 c1                	mov    %eax,%ecx
  801343:	8b 44 24 04          	mov    0x4(%esp),%eax
  801347:	09 f9                	or     %edi,%ecx
  801349:	89 df                	mov    %ebx,%edi
  80134b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80134f:	89 c1                	mov    %eax,%ecx
  801351:	d3 e5                	shl    %cl,%ebp
  801353:	89 d1                	mov    %edx,%ecx
  801355:	d3 ef                	shr    %cl,%edi
  801357:	89 c1                	mov    %eax,%ecx
  801359:	89 f0                	mov    %esi,%eax
  80135b:	d3 e3                	shl    %cl,%ebx
  80135d:	89 d1                	mov    %edx,%ecx
  80135f:	89 fa                	mov    %edi,%edx
  801361:	d3 e8                	shr    %cl,%eax
  801363:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801368:	09 d8                	or     %ebx,%eax
  80136a:	f7 74 24 08          	divl   0x8(%esp)
  80136e:	89 d3                	mov    %edx,%ebx
  801370:	d3 e6                	shl    %cl,%esi
  801372:	f7 e5                	mul    %ebp
  801374:	89 c7                	mov    %eax,%edi
  801376:	89 d1                	mov    %edx,%ecx
  801378:	39 d3                	cmp    %edx,%ebx
  80137a:	72 06                	jb     801382 <__umoddi3+0xe2>
  80137c:	75 0e                	jne    80138c <__umoddi3+0xec>
  80137e:	39 c6                	cmp    %eax,%esi
  801380:	73 0a                	jae    80138c <__umoddi3+0xec>
  801382:	29 e8                	sub    %ebp,%eax
  801384:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801388:	89 d1                	mov    %edx,%ecx
  80138a:	89 c7                	mov    %eax,%edi
  80138c:	89 f5                	mov    %esi,%ebp
  80138e:	8b 74 24 04          	mov    0x4(%esp),%esi
  801392:	29 fd                	sub    %edi,%ebp
  801394:	19 cb                	sbb    %ecx,%ebx
  801396:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80139b:	89 d8                	mov    %ebx,%eax
  80139d:	d3 e0                	shl    %cl,%eax
  80139f:	89 f1                	mov    %esi,%ecx
  8013a1:	d3 ed                	shr    %cl,%ebp
  8013a3:	d3 eb                	shr    %cl,%ebx
  8013a5:	09 e8                	or     %ebp,%eax
  8013a7:	89 da                	mov    %ebx,%edx
  8013a9:	83 c4 1c             	add    $0x1c,%esp
  8013ac:	5b                   	pop    %ebx
  8013ad:	5e                   	pop    %esi
  8013ae:	5f                   	pop    %edi
  8013af:	5d                   	pop    %ebp
  8013b0:	c3                   	ret    
