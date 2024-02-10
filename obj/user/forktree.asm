
obj/user/forktree:     formato del fichero elf32-i386


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
  80002c:	e8 b2 00 00 00       	call   8000e3 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <forktree>:
	}
}

void
forktree(const char *cur)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 04             	sub    $0x4,%esp
  80003a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  80003d:	e8 c7 0a 00 00       	call   800b09 <sys_getenvid>
  800042:	83 ec 04             	sub    $0x4,%esp
  800045:	53                   	push   %ebx
  800046:	50                   	push   %eax
  800047:	68 00 14 80 00       	push   $0x801400
  80004c:	e8 86 01 00 00       	call   8001d7 <cprintf>

	forkchild(cur, '0');
  800051:	83 c4 08             	add    $0x8,%esp
  800054:	6a 30                	push   $0x30
  800056:	53                   	push   %ebx
  800057:	e8 13 00 00 00       	call   80006f <forkchild>
	forkchild(cur, '1');
  80005c:	83 c4 08             	add    $0x8,%esp
  80005f:	6a 31                	push   $0x31
  800061:	53                   	push   %ebx
  800062:	e8 08 00 00 00       	call   80006f <forkchild>
}
  800067:	83 c4 10             	add    $0x10,%esp
  80006a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80006d:	c9                   	leave  
  80006e:	c3                   	ret    

0080006f <forkchild>:
{
  80006f:	55                   	push   %ebp
  800070:	89 e5                	mov    %esp,%ebp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	83 ec 1c             	sub    $0x1c,%esp
  800077:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80007a:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (strlen(cur) >= DEPTH)
  80007d:	53                   	push   %ebx
  80007e:	e8 52 06 00 00       	call   8006d5 <strlen>
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	83 f8 02             	cmp    $0x2,%eax
  800089:	7e 07                	jle    800092 <forkchild+0x23>
}
  80008b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008e:	5b                   	pop    %ebx
  80008f:	5e                   	pop    %esi
  800090:	5d                   	pop    %ebp
  800091:	c3                   	ret    
	snprintf(nxt, DEPTH + 1, "%s%c", cur, branch);
  800092:	83 ec 0c             	sub    $0xc,%esp
  800095:	89 f0                	mov    %esi,%eax
  800097:	0f be f0             	movsbl %al,%esi
  80009a:	56                   	push   %esi
  80009b:	53                   	push   %ebx
  80009c:	68 11 14 80 00       	push   $0x801411
  8000a1:	6a 04                	push   $0x4
  8000a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000a6:	50                   	push   %eax
  8000a7:	e8 0f 06 00 00       	call   8006bb <snprintf>
	if (fork() == 0) {
  8000ac:	83 c4 20             	add    $0x20,%esp
  8000af:	e8 06 0f 00 00       	call   800fba <fork>
  8000b4:	85 c0                	test   %eax,%eax
  8000b6:	75 d3                	jne    80008b <forkchild+0x1c>
		forktree(nxt);
  8000b8:	83 ec 0c             	sub    $0xc,%esp
  8000bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000be:	50                   	push   %eax
  8000bf:	e8 6f ff ff ff       	call   800033 <forktree>
		exit();
  8000c4:	e8 67 00 00 00       	call   800130 <exit>
  8000c9:	83 c4 10             	add    $0x10,%esp
  8000cc:	eb bd                	jmp    80008b <forkchild+0x1c>

008000ce <umain>:

void
umain(int argc, char **argv)
{
  8000ce:	55                   	push   %ebp
  8000cf:	89 e5                	mov    %esp,%ebp
  8000d1:	83 ec 14             	sub    $0x14,%esp
	forktree("");
  8000d4:	68 10 14 80 00       	push   $0x801410
  8000d9:	e8 55 ff ff ff       	call   800033 <forktree>
}
  8000de:	83 c4 10             	add    $0x10,%esp
  8000e1:	c9                   	leave  
  8000e2:	c3                   	ret    

008000e3 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	56                   	push   %esi
  8000e7:	53                   	push   %ebx
  8000e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000eb:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	envid_t id = sys_getenvid();
  8000ee:	e8 16 0a 00 00       	call   800b09 <sys_getenvid>
	if (id >= 0)
  8000f3:	85 c0                	test   %eax,%eax
  8000f5:	78 15                	js     80010c <libmain+0x29>
		thisenv = &envs[ENVX(id)];
  8000f7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000fc:	69 c0 88 00 00 00    	imul   $0x88,%eax,%eax
  800102:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800107:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80010c:	85 db                	test   %ebx,%ebx
  80010e:	7e 07                	jle    800117 <libmain+0x34>
		binaryname = argv[0];
  800110:	8b 06                	mov    (%esi),%eax
  800112:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800117:	83 ec 08             	sub    $0x8,%esp
  80011a:	56                   	push   %esi
  80011b:	53                   	push   %ebx
  80011c:	e8 ad ff ff ff       	call   8000ce <umain>

	// exit gracefully
	exit();
  800121:	e8 0a 00 00 00       	call   800130 <exit>
}
  800126:	83 c4 10             	add    $0x10,%esp
  800129:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80012c:	5b                   	pop    %ebx
  80012d:	5e                   	pop    %esi
  80012e:	5d                   	pop    %ebp
  80012f:	c3                   	ret    

00800130 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800130:	55                   	push   %ebp
  800131:	89 e5                	mov    %esp,%ebp
  800133:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800136:	6a 00                	push   $0x0
  800138:	e8 aa 09 00 00       	call   800ae7 <sys_env_destroy>
}
  80013d:	83 c4 10             	add    $0x10,%esp
  800140:	c9                   	leave  
  800141:	c3                   	ret    

00800142 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800142:	55                   	push   %ebp
  800143:	89 e5                	mov    %esp,%ebp
  800145:	53                   	push   %ebx
  800146:	83 ec 04             	sub    $0x4,%esp
  800149:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80014c:	8b 13                	mov    (%ebx),%edx
  80014e:	8d 42 01             	lea    0x1(%edx),%eax
  800151:	89 03                	mov    %eax,(%ebx)
  800153:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800156:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256 - 1) {
  80015a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80015f:	74 09                	je     80016a <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800161:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800165:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800168:	c9                   	leave  
  800169:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80016a:	83 ec 08             	sub    $0x8,%esp
  80016d:	68 ff 00 00 00       	push   $0xff
  800172:	8d 43 08             	lea    0x8(%ebx),%eax
  800175:	50                   	push   %eax
  800176:	e8 22 09 00 00       	call   800a9d <sys_cputs>
		b->idx = 0;
  80017b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800181:	83 c4 10             	add    $0x10,%esp
  800184:	eb db                	jmp    800161 <putch+0x1f>

00800186 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800186:	55                   	push   %ebp
  800187:	89 e5                	mov    %esp,%ebp
  800189:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80018f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800196:	00 00 00 
	b.cnt = 0;
  800199:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001a0:	00 00 00 
	vprintfmt((void *) putch, &b, fmt, ap);
  8001a3:	ff 75 0c             	push   0xc(%ebp)
  8001a6:	ff 75 08             	push   0x8(%ebp)
  8001a9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001af:	50                   	push   %eax
  8001b0:	68 42 01 80 00       	push   $0x800142
  8001b5:	e8 74 01 00 00       	call   80032e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001ba:	83 c4 08             	add    $0x8,%esp
  8001bd:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8001c3:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001c9:	50                   	push   %eax
  8001ca:	e8 ce 08 00 00       	call   800a9d <sys_cputs>

	return b.cnt;
}
  8001cf:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001d5:	c9                   	leave  
  8001d6:	c3                   	ret    

008001d7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001d7:	55                   	push   %ebp
  8001d8:	89 e5                	mov    %esp,%ebp
  8001da:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001dd:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001e0:	50                   	push   %eax
  8001e1:	ff 75 08             	push   0x8(%ebp)
  8001e4:	e8 9d ff ff ff       	call   800186 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001e9:	c9                   	leave  
  8001ea:	c3                   	ret    

008001eb <printnum>:
         void *putdat,
         unsigned long long num,
         unsigned base,
         int width,
         int padc)
{
  8001eb:	55                   	push   %ebp
  8001ec:	89 e5                	mov    %esp,%ebp
  8001ee:	57                   	push   %edi
  8001ef:	56                   	push   %esi
  8001f0:	53                   	push   %ebx
  8001f1:	83 ec 1c             	sub    $0x1c,%esp
  8001f4:	89 c7                	mov    %eax,%edi
  8001f6:	89 d6                	mov    %edx,%esi
  8001f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8001fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001fe:	89 d1                	mov    %edx,%ecx
  800200:	89 c2                	mov    %eax,%edx
  800202:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800205:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800208:	8b 45 10             	mov    0x10(%ebp),%eax
  80020b:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80020e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800211:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800218:	39 c2                	cmp    %eax,%edx
  80021a:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80021d:	72 3e                	jb     80025d <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80021f:	83 ec 0c             	sub    $0xc,%esp
  800222:	ff 75 18             	push   0x18(%ebp)
  800225:	83 eb 01             	sub    $0x1,%ebx
  800228:	53                   	push   %ebx
  800229:	50                   	push   %eax
  80022a:	83 ec 08             	sub    $0x8,%esp
  80022d:	ff 75 e4             	push   -0x1c(%ebp)
  800230:	ff 75 e0             	push   -0x20(%ebp)
  800233:	ff 75 dc             	push   -0x24(%ebp)
  800236:	ff 75 d8             	push   -0x28(%ebp)
  800239:	e8 72 0f 00 00       	call   8011b0 <__udivdi3>
  80023e:	83 c4 18             	add    $0x18,%esp
  800241:	52                   	push   %edx
  800242:	50                   	push   %eax
  800243:	89 f2                	mov    %esi,%edx
  800245:	89 f8                	mov    %edi,%eax
  800247:	e8 9f ff ff ff       	call   8001eb <printnum>
  80024c:	83 c4 20             	add    $0x20,%esp
  80024f:	eb 13                	jmp    800264 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800251:	83 ec 08             	sub    $0x8,%esp
  800254:	56                   	push   %esi
  800255:	ff 75 18             	push   0x18(%ebp)
  800258:	ff d7                	call   *%edi
  80025a:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80025d:	83 eb 01             	sub    $0x1,%ebx
  800260:	85 db                	test   %ebx,%ebx
  800262:	7f ed                	jg     800251 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800264:	83 ec 08             	sub    $0x8,%esp
  800267:	56                   	push   %esi
  800268:	83 ec 04             	sub    $0x4,%esp
  80026b:	ff 75 e4             	push   -0x1c(%ebp)
  80026e:	ff 75 e0             	push   -0x20(%ebp)
  800271:	ff 75 dc             	push   -0x24(%ebp)
  800274:	ff 75 d8             	push   -0x28(%ebp)
  800277:	e8 54 10 00 00       	call   8012d0 <__umoddi3>
  80027c:	83 c4 14             	add    $0x14,%esp
  80027f:	0f be 80 20 14 80 00 	movsbl 0x801420(%eax),%eax
  800286:	50                   	push   %eax
  800287:	ff d7                	call   *%edi
}
  800289:	83 c4 10             	add    $0x10,%esp
  80028c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80028f:	5b                   	pop    %ebx
  800290:	5e                   	pop    %esi
  800291:	5f                   	pop    %edi
  800292:	5d                   	pop    %ebp
  800293:	c3                   	ret    

00800294 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800294:	83 fa 01             	cmp    $0x1,%edx
  800297:	7f 13                	jg     8002ac <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800299:	85 d2                	test   %edx,%edx
  80029b:	74 1c                	je     8002b9 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  80029d:	8b 10                	mov    (%eax),%edx
  80029f:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a2:	89 08                	mov    %ecx,(%eax)
  8002a4:	8b 02                	mov    (%edx),%eax
  8002a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ab:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  8002ac:	8b 10                	mov    (%eax),%edx
  8002ae:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002b1:	89 08                	mov    %ecx,(%eax)
  8002b3:	8b 02                	mov    (%edx),%eax
  8002b5:	8b 52 04             	mov    0x4(%edx),%edx
  8002b8:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  8002b9:	8b 10                	mov    (%eax),%edx
  8002bb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002be:	89 08                	mov    %ecx,(%eax)
  8002c0:	8b 02                	mov    (%edx),%eax
  8002c2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002c7:	c3                   	ret    

008002c8 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8002c8:	83 fa 01             	cmp    $0x1,%edx
  8002cb:	7f 0f                	jg     8002dc <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  8002cd:	85 d2                	test   %edx,%edx
  8002cf:	74 18                	je     8002e9 <getint+0x21>
		return va_arg(*ap, long);
  8002d1:	8b 10                	mov    (%eax),%edx
  8002d3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d6:	89 08                	mov    %ecx,(%eax)
  8002d8:	8b 02                	mov    (%edx),%eax
  8002da:	99                   	cltd   
  8002db:	c3                   	ret    
		return va_arg(*ap, long long);
  8002dc:	8b 10                	mov    (%eax),%edx
  8002de:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002e1:	89 08                	mov    %ecx,(%eax)
  8002e3:	8b 02                	mov    (%edx),%eax
  8002e5:	8b 52 04             	mov    0x4(%edx),%edx
  8002e8:	c3                   	ret    
	else
		return va_arg(*ap, int);
  8002e9:	8b 10                	mov    (%eax),%edx
  8002eb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ee:	89 08                	mov    %ecx,(%eax)
  8002f0:	8b 02                	mov    (%edx),%eax
  8002f2:	99                   	cltd   
}
  8002f3:	c3                   	ret    

008002f4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002f4:	55                   	push   %ebp
  8002f5:	89 e5                	mov    %esp,%ebp
  8002f7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002fa:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002fe:	8b 10                	mov    (%eax),%edx
  800300:	3b 50 04             	cmp    0x4(%eax),%edx
  800303:	73 0a                	jae    80030f <sprintputch+0x1b>
		*b->buf++ = ch;
  800305:	8d 4a 01             	lea    0x1(%edx),%ecx
  800308:	89 08                	mov    %ecx,(%eax)
  80030a:	8b 45 08             	mov    0x8(%ebp),%eax
  80030d:	88 02                	mov    %al,(%edx)
}
  80030f:	5d                   	pop    %ebp
  800310:	c3                   	ret    

00800311 <printfmt>:
{
  800311:	55                   	push   %ebp
  800312:	89 e5                	mov    %esp,%ebp
  800314:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800317:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80031a:	50                   	push   %eax
  80031b:	ff 75 10             	push   0x10(%ebp)
  80031e:	ff 75 0c             	push   0xc(%ebp)
  800321:	ff 75 08             	push   0x8(%ebp)
  800324:	e8 05 00 00 00       	call   80032e <vprintfmt>
}
  800329:	83 c4 10             	add    $0x10,%esp
  80032c:	c9                   	leave  
  80032d:	c3                   	ret    

0080032e <vprintfmt>:
{
  80032e:	55                   	push   %ebp
  80032f:	89 e5                	mov    %esp,%ebp
  800331:	57                   	push   %edi
  800332:	56                   	push   %esi
  800333:	53                   	push   %ebx
  800334:	83 ec 2c             	sub    $0x2c,%esp
  800337:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80033a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80033d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800340:	eb 0a                	jmp    80034c <vprintfmt+0x1e>
			putch(ch, putdat);
  800342:	83 ec 08             	sub    $0x8,%esp
  800345:	56                   	push   %esi
  800346:	50                   	push   %eax
  800347:	ff d3                	call   *%ebx
  800349:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80034c:	83 c7 01             	add    $0x1,%edi
  80034f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800353:	83 f8 25             	cmp    $0x25,%eax
  800356:	74 0c                	je     800364 <vprintfmt+0x36>
			if (ch == '\0')
  800358:	85 c0                	test   %eax,%eax
  80035a:	75 e6                	jne    800342 <vprintfmt+0x14>
}
  80035c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80035f:	5b                   	pop    %ebx
  800360:	5e                   	pop    %esi
  800361:	5f                   	pop    %edi
  800362:	5d                   	pop    %ebp
  800363:	c3                   	ret    
		padc = ' ';
  800364:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
		altflag = 0;
  800368:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80036f:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800376:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80037d:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800382:	8d 47 01             	lea    0x1(%edi),%eax
  800385:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800388:	0f b6 17             	movzbl (%edi),%edx
  80038b:	8d 42 dd             	lea    -0x23(%edx),%eax
  80038e:	3c 55                	cmp    $0x55,%al
  800390:	0f 87 b7 02 00 00    	ja     80064d <vprintfmt+0x31f>
  800396:	0f b6 c0             	movzbl %al,%eax
  800399:	ff 24 85 e0 14 80 00 	jmp    *0x8014e0(,%eax,4)
  8003a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8003a3:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  8003a7:	eb d9                	jmp    800382 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8003a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ac:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  8003b0:	eb d0                	jmp    800382 <vprintfmt+0x54>
  8003b2:	0f b6 d2             	movzbl %dl,%edx
  8003b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0;; ++fmt) {
  8003b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8003bd:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003c0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003c3:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003c7:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003ca:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003cd:	83 f9 09             	cmp    $0x9,%ecx
  8003d0:	77 52                	ja     800424 <vprintfmt+0xf6>
			for (precision = 0;; ++fmt) {
  8003d2:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003d5:	eb e9                	jmp    8003c0 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  8003d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003da:	8d 50 04             	lea    0x4(%eax),%edx
  8003dd:	89 55 14             	mov    %edx,0x14(%ebp)
  8003e0:	8b 00                	mov    (%eax),%eax
  8003e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003e8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003ec:	79 94                	jns    800382 <vprintfmt+0x54>
				width = precision, precision = -1;
  8003ee:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003f1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003f4:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003fb:	eb 85                	jmp    800382 <vprintfmt+0x54>
  8003fd:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800400:	85 d2                	test   %edx,%edx
  800402:	b8 00 00 00 00       	mov    $0x0,%eax
  800407:	0f 49 c2             	cmovns %edx,%eax
  80040a:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80040d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800410:	e9 6d ff ff ff       	jmp    800382 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800415:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800418:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80041f:	e9 5e ff ff ff       	jmp    800382 <vprintfmt+0x54>
  800424:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800427:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80042a:	eb bc                	jmp    8003e8 <vprintfmt+0xba>
			lflag++;
  80042c:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80042f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800432:	e9 4b ff ff ff       	jmp    800382 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800437:	8b 45 14             	mov    0x14(%ebp),%eax
  80043a:	8d 50 04             	lea    0x4(%eax),%edx
  80043d:	89 55 14             	mov    %edx,0x14(%ebp)
  800440:	83 ec 08             	sub    $0x8,%esp
  800443:	56                   	push   %esi
  800444:	ff 30                	push   (%eax)
  800446:	ff d3                	call   *%ebx
			break;
  800448:	83 c4 10             	add    $0x10,%esp
  80044b:	e9 94 01 00 00       	jmp    8005e4 <vprintfmt+0x2b6>
			err = va_arg(ap, int);
  800450:	8b 45 14             	mov    0x14(%ebp),%eax
  800453:	8d 50 04             	lea    0x4(%eax),%edx
  800456:	89 55 14             	mov    %edx,0x14(%ebp)
  800459:	8b 10                	mov    (%eax),%edx
  80045b:	89 d0                	mov    %edx,%eax
  80045d:	f7 d8                	neg    %eax
  80045f:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800462:	83 f8 08             	cmp    $0x8,%eax
  800465:	7f 20                	jg     800487 <vprintfmt+0x159>
  800467:	8b 14 85 40 16 80 00 	mov    0x801640(,%eax,4),%edx
  80046e:	85 d2                	test   %edx,%edx
  800470:	74 15                	je     800487 <vprintfmt+0x159>
				printfmt(putch, putdat, "%s", p);
  800472:	52                   	push   %edx
  800473:	68 41 14 80 00       	push   $0x801441
  800478:	56                   	push   %esi
  800479:	53                   	push   %ebx
  80047a:	e8 92 fe ff ff       	call   800311 <printfmt>
  80047f:	83 c4 10             	add    $0x10,%esp
  800482:	e9 5d 01 00 00       	jmp    8005e4 <vprintfmt+0x2b6>
				printfmt(putch, putdat, "error %d", err);
  800487:	50                   	push   %eax
  800488:	68 38 14 80 00       	push   $0x801438
  80048d:	56                   	push   %esi
  80048e:	53                   	push   %ebx
  80048f:	e8 7d fe ff ff       	call   800311 <printfmt>
  800494:	83 c4 10             	add    $0x10,%esp
  800497:	e9 48 01 00 00       	jmp    8005e4 <vprintfmt+0x2b6>
			if ((p = va_arg(ap, char *)) == NULL)
  80049c:	8b 45 14             	mov    0x14(%ebp),%eax
  80049f:	8d 50 04             	lea    0x4(%eax),%edx
  8004a2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a5:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004a7:	85 ff                	test   %edi,%edi
  8004a9:	b8 31 14 80 00       	mov    $0x801431,%eax
  8004ae:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004b1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004b5:	7e 06                	jle    8004bd <vprintfmt+0x18f>
  8004b7:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8004bb:	75 0a                	jne    8004c7 <vprintfmt+0x199>
  8004bd:	89 f8                	mov    %edi,%eax
  8004bf:	03 45 e0             	add    -0x20(%ebp),%eax
  8004c2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c5:	eb 59                	jmp    800520 <vprintfmt+0x1f2>
				for (width -= strnlen(p, precision); width > 0;
  8004c7:	83 ec 08             	sub    $0x8,%esp
  8004ca:	ff 75 d8             	push   -0x28(%ebp)
  8004cd:	57                   	push   %edi
  8004ce:	e8 1a 02 00 00       	call   8006ed <strnlen>
  8004d3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004d6:	29 c1                	sub    %eax,%ecx
  8004d8:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004db:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004de:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  8004e2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004e5:	89 7d d0             	mov    %edi,-0x30(%ebp)
  8004e8:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0;
  8004ea:	eb 0f                	jmp    8004fb <vprintfmt+0x1cd>
					putch(padc, putdat);
  8004ec:	83 ec 08             	sub    $0x8,%esp
  8004ef:	56                   	push   %esi
  8004f0:	ff 75 e0             	push   -0x20(%ebp)
  8004f3:	ff d3                	call   *%ebx
				     width--)
  8004f5:	83 ef 01             	sub    $0x1,%edi
  8004f8:	83 c4 10             	add    $0x10,%esp
				for (width -= strnlen(p, precision); width > 0;
  8004fb:	85 ff                	test   %edi,%edi
  8004fd:	7f ed                	jg     8004ec <vprintfmt+0x1be>
  8004ff:	8b 7d d0             	mov    -0x30(%ebp),%edi
  800502:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800505:	85 c9                	test   %ecx,%ecx
  800507:	b8 00 00 00 00       	mov    $0x0,%eax
  80050c:	0f 49 c1             	cmovns %ecx,%eax
  80050f:	29 c1                	sub    %eax,%ecx
  800511:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800514:	eb a7                	jmp    8004bd <vprintfmt+0x18f>
					putch(ch, putdat);
  800516:	83 ec 08             	sub    $0x8,%esp
  800519:	56                   	push   %esi
  80051a:	52                   	push   %edx
  80051b:	ff d3                	call   *%ebx
  80051d:	83 c4 10             	add    $0x10,%esp
  800520:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800523:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' &&
  800525:	83 c7 01             	add    $0x1,%edi
  800528:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80052c:	0f be d0             	movsbl %al,%edx
  80052f:	85 d2                	test   %edx,%edx
  800531:	74 42                	je     800575 <vprintfmt+0x247>
  800533:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800537:	78 06                	js     80053f <vprintfmt+0x211>
			       (precision < 0 || --precision >= 0);
  800539:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80053d:	78 1e                	js     80055d <vprintfmt+0x22f>
				if (altflag && (ch < ' ' || ch > '~'))
  80053f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800543:	74 d1                	je     800516 <vprintfmt+0x1e8>
  800545:	0f be c0             	movsbl %al,%eax
  800548:	83 e8 20             	sub    $0x20,%eax
  80054b:	83 f8 5e             	cmp    $0x5e,%eax
  80054e:	76 c6                	jbe    800516 <vprintfmt+0x1e8>
					putch('?', putdat);
  800550:	83 ec 08             	sub    $0x8,%esp
  800553:	56                   	push   %esi
  800554:	6a 3f                	push   $0x3f
  800556:	ff d3                	call   *%ebx
  800558:	83 c4 10             	add    $0x10,%esp
  80055b:	eb c3                	jmp    800520 <vprintfmt+0x1f2>
  80055d:	89 cf                	mov    %ecx,%edi
  80055f:	eb 0e                	jmp    80056f <vprintfmt+0x241>
				putch(' ', putdat);
  800561:	83 ec 08             	sub    $0x8,%esp
  800564:	56                   	push   %esi
  800565:	6a 20                	push   $0x20
  800567:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  800569:	83 ef 01             	sub    $0x1,%edi
  80056c:	83 c4 10             	add    $0x10,%esp
  80056f:	85 ff                	test   %edi,%edi
  800571:	7f ee                	jg     800561 <vprintfmt+0x233>
  800573:	eb 6f                	jmp    8005e4 <vprintfmt+0x2b6>
  800575:	89 cf                	mov    %ecx,%edi
  800577:	eb f6                	jmp    80056f <vprintfmt+0x241>
			num = getint(&ap, lflag);
  800579:	89 ca                	mov    %ecx,%edx
  80057b:	8d 45 14             	lea    0x14(%ebp),%eax
  80057e:	e8 45 fd ff ff       	call   8002c8 <getint>
  800583:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800586:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800589:	85 d2                	test   %edx,%edx
  80058b:	78 0b                	js     800598 <vprintfmt+0x26a>
			num = getint(&ap, lflag);
  80058d:	89 d1                	mov    %edx,%ecx
  80058f:	89 c2                	mov    %eax,%edx
			base = 10;
  800591:	bf 0a 00 00 00       	mov    $0xa,%edi
  800596:	eb 32                	jmp    8005ca <vprintfmt+0x29c>
				putch('-', putdat);
  800598:	83 ec 08             	sub    $0x8,%esp
  80059b:	56                   	push   %esi
  80059c:	6a 2d                	push   $0x2d
  80059e:	ff d3                	call   *%ebx
				num = -(long long) num;
  8005a0:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005a3:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005a6:	f7 da                	neg    %edx
  8005a8:	83 d1 00             	adc    $0x0,%ecx
  8005ab:	f7 d9                	neg    %ecx
  8005ad:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005b0:	bf 0a 00 00 00       	mov    $0xa,%edi
  8005b5:	eb 13                	jmp    8005ca <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  8005b7:	89 ca                	mov    %ecx,%edx
  8005b9:	8d 45 14             	lea    0x14(%ebp),%eax
  8005bc:	e8 d3 fc ff ff       	call   800294 <getuint>
  8005c1:	89 d1                	mov    %edx,%ecx
  8005c3:	89 c2                	mov    %eax,%edx
			base = 10;
  8005c5:	bf 0a 00 00 00       	mov    $0xa,%edi
			printnum(putch, putdat, num, base, width, padc);
  8005ca:	83 ec 0c             	sub    $0xc,%esp
  8005cd:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  8005d1:	50                   	push   %eax
  8005d2:	ff 75 e0             	push   -0x20(%ebp)
  8005d5:	57                   	push   %edi
  8005d6:	51                   	push   %ecx
  8005d7:	52                   	push   %edx
  8005d8:	89 f2                	mov    %esi,%edx
  8005da:	89 d8                	mov    %ebx,%eax
  8005dc:	e8 0a fc ff ff       	call   8001eb <printnum>
			break;
  8005e1:	83 c4 20             	add    $0x20,%esp
{
  8005e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005e7:	e9 60 fd ff ff       	jmp    80034c <vprintfmt+0x1e>
			num = getuint(&ap, lflag);
  8005ec:	89 ca                	mov    %ecx,%edx
  8005ee:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f1:	e8 9e fc ff ff       	call   800294 <getuint>
  8005f6:	89 d1                	mov    %edx,%ecx
  8005f8:	89 c2                	mov    %eax,%edx
			base = 8;
  8005fa:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  8005ff:	eb c9                	jmp    8005ca <vprintfmt+0x29c>
			putch('0', putdat);
  800601:	83 ec 08             	sub    $0x8,%esp
  800604:	56                   	push   %esi
  800605:	6a 30                	push   $0x30
  800607:	ff d3                	call   *%ebx
			putch('x', putdat);
  800609:	83 c4 08             	add    $0x8,%esp
  80060c:	56                   	push   %esi
  80060d:	6a 78                	push   $0x78
  80060f:	ff d3                	call   *%ebx
			num = (unsigned long long) (uintptr_t) va_arg(ap, void *);
  800611:	8b 45 14             	mov    0x14(%ebp),%eax
  800614:	8d 50 04             	lea    0x4(%eax),%edx
  800617:	89 55 14             	mov    %edx,0x14(%ebp)
  80061a:	8b 10                	mov    (%eax),%edx
  80061c:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800621:	83 c4 10             	add    $0x10,%esp
			base = 16;
  800624:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  800629:	eb 9f                	jmp    8005ca <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  80062b:	89 ca                	mov    %ecx,%edx
  80062d:	8d 45 14             	lea    0x14(%ebp),%eax
  800630:	e8 5f fc ff ff       	call   800294 <getuint>
  800635:	89 d1                	mov    %edx,%ecx
  800637:	89 c2                	mov    %eax,%edx
			base = 16;
  800639:	bf 10 00 00 00       	mov    $0x10,%edi
  80063e:	eb 8a                	jmp    8005ca <vprintfmt+0x29c>
			putch(ch, putdat);
  800640:	83 ec 08             	sub    $0x8,%esp
  800643:	56                   	push   %esi
  800644:	6a 25                	push   $0x25
  800646:	ff d3                	call   *%ebx
			break;
  800648:	83 c4 10             	add    $0x10,%esp
  80064b:	eb 97                	jmp    8005e4 <vprintfmt+0x2b6>
			putch('%', putdat);
  80064d:	83 ec 08             	sub    $0x8,%esp
  800650:	56                   	push   %esi
  800651:	6a 25                	push   $0x25
  800653:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  800655:	83 c4 10             	add    $0x10,%esp
  800658:	89 f8                	mov    %edi,%eax
  80065a:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80065e:	74 05                	je     800665 <vprintfmt+0x337>
  800660:	83 e8 01             	sub    $0x1,%eax
  800663:	eb f5                	jmp    80065a <vprintfmt+0x32c>
  800665:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800668:	e9 77 ff ff ff       	jmp    8005e4 <vprintfmt+0x2b6>

0080066d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80066d:	55                   	push   %ebp
  80066e:	89 e5                	mov    %esp,%ebp
  800670:	83 ec 18             	sub    $0x18,%esp
  800673:	8b 45 08             	mov    0x8(%ebp),%eax
  800676:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = { buf, buf + n - 1, 0 };
  800679:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80067c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800680:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800683:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80068a:	85 c0                	test   %eax,%eax
  80068c:	74 26                	je     8006b4 <vsnprintf+0x47>
  80068e:	85 d2                	test   %edx,%edx
  800690:	7e 22                	jle    8006b4 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *) sprintputch, &b, fmt, ap);
  800692:	ff 75 14             	push   0x14(%ebp)
  800695:	ff 75 10             	push   0x10(%ebp)
  800698:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80069b:	50                   	push   %eax
  80069c:	68 f4 02 80 00       	push   $0x8002f4
  8006a1:	e8 88 fc ff ff       	call   80032e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006a9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006af:	83 c4 10             	add    $0x10,%esp
}
  8006b2:	c9                   	leave  
  8006b3:	c3                   	ret    
		return -E_INVAL;
  8006b4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006b9:	eb f7                	jmp    8006b2 <vsnprintf+0x45>

008006bb <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006bb:	55                   	push   %ebp
  8006bc:	89 e5                	mov    %esp,%ebp
  8006be:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006c1:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006c4:	50                   	push   %eax
  8006c5:	ff 75 10             	push   0x10(%ebp)
  8006c8:	ff 75 0c             	push   0xc(%ebp)
  8006cb:	ff 75 08             	push   0x8(%ebp)
  8006ce:	e8 9a ff ff ff       	call   80066d <vsnprintf>
	va_end(ap);

	return rc;
}
  8006d3:	c9                   	leave  
  8006d4:	c3                   	ret    

008006d5 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006d5:	55                   	push   %ebp
  8006d6:	89 e5                	mov    %esp,%ebp
  8006d8:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006db:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e0:	eb 03                	jmp    8006e5 <strlen+0x10>
		n++;
  8006e2:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8006e5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006e9:	75 f7                	jne    8006e2 <strlen+0xd>
	return n;
}
  8006eb:	5d                   	pop    %ebp
  8006ec:	c3                   	ret    

008006ed <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006ed:	55                   	push   %ebp
  8006ee:	89 e5                	mov    %esp,%ebp
  8006f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006f3:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8006fb:	eb 03                	jmp    800700 <strnlen+0x13>
		n++;
  8006fd:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800700:	39 d0                	cmp    %edx,%eax
  800702:	74 08                	je     80070c <strnlen+0x1f>
  800704:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800708:	75 f3                	jne    8006fd <strnlen+0x10>
  80070a:	89 c2                	mov    %eax,%edx
	return n;
}
  80070c:	89 d0                	mov    %edx,%eax
  80070e:	5d                   	pop    %ebp
  80070f:	c3                   	ret    

00800710 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800710:	55                   	push   %ebp
  800711:	89 e5                	mov    %esp,%ebp
  800713:	53                   	push   %ebx
  800714:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800717:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80071a:	b8 00 00 00 00       	mov    $0x0,%eax
  80071f:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800723:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800726:	83 c0 01             	add    $0x1,%eax
  800729:	84 d2                	test   %dl,%dl
  80072b:	75 f2                	jne    80071f <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80072d:	89 c8                	mov    %ecx,%eax
  80072f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800732:	c9                   	leave  
  800733:	c3                   	ret    

00800734 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800734:	55                   	push   %ebp
  800735:	89 e5                	mov    %esp,%ebp
  800737:	53                   	push   %ebx
  800738:	83 ec 10             	sub    $0x10,%esp
  80073b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80073e:	53                   	push   %ebx
  80073f:	e8 91 ff ff ff       	call   8006d5 <strlen>
  800744:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800747:	ff 75 0c             	push   0xc(%ebp)
  80074a:	01 d8                	add    %ebx,%eax
  80074c:	50                   	push   %eax
  80074d:	e8 be ff ff ff       	call   800710 <strcpy>
	return dst;
}
  800752:	89 d8                	mov    %ebx,%eax
  800754:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800757:	c9                   	leave  
  800758:	c3                   	ret    

00800759 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size)
{
  800759:	55                   	push   %ebp
  80075a:	89 e5                	mov    %esp,%ebp
  80075c:	56                   	push   %esi
  80075d:	53                   	push   %ebx
  80075e:	8b 75 08             	mov    0x8(%ebp),%esi
  800761:	8b 55 0c             	mov    0xc(%ebp),%edx
  800764:	89 f3                	mov    %esi,%ebx
  800766:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800769:	89 f0                	mov    %esi,%eax
  80076b:	eb 0f                	jmp    80077c <strncpy+0x23>
		*dst++ = *src;
  80076d:	83 c0 01             	add    $0x1,%eax
  800770:	0f b6 0a             	movzbl (%edx),%ecx
  800773:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800776:	80 f9 01             	cmp    $0x1,%cl
  800779:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  80077c:	39 d8                	cmp    %ebx,%eax
  80077e:	75 ed                	jne    80076d <strncpy+0x14>
	}
	return ret;
}
  800780:	89 f0                	mov    %esi,%eax
  800782:	5b                   	pop    %ebx
  800783:	5e                   	pop    %esi
  800784:	5d                   	pop    %ebp
  800785:	c3                   	ret    

00800786 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800786:	55                   	push   %ebp
  800787:	89 e5                	mov    %esp,%ebp
  800789:	56                   	push   %esi
  80078a:	53                   	push   %ebx
  80078b:	8b 75 08             	mov    0x8(%ebp),%esi
  80078e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800791:	8b 55 10             	mov    0x10(%ebp),%edx
  800794:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800796:	85 d2                	test   %edx,%edx
  800798:	74 21                	je     8007bb <strlcpy+0x35>
  80079a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80079e:	89 f2                	mov    %esi,%edx
  8007a0:	eb 09                	jmp    8007ab <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007a2:	83 c1 01             	add    $0x1,%ecx
  8007a5:	83 c2 01             	add    $0x1,%edx
  8007a8:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  8007ab:	39 c2                	cmp    %eax,%edx
  8007ad:	74 09                	je     8007b8 <strlcpy+0x32>
  8007af:	0f b6 19             	movzbl (%ecx),%ebx
  8007b2:	84 db                	test   %bl,%bl
  8007b4:	75 ec                	jne    8007a2 <strlcpy+0x1c>
  8007b6:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8007b8:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007bb:	29 f0                	sub    %esi,%eax
}
  8007bd:	5b                   	pop    %ebx
  8007be:	5e                   	pop    %esi
  8007bf:	5d                   	pop    %ebp
  8007c0:	c3                   	ret    

008007c1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007c1:	55                   	push   %ebp
  8007c2:	89 e5                	mov    %esp,%ebp
  8007c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007ca:	eb 06                	jmp    8007d2 <strcmp+0x11>
		p++, q++;
  8007cc:	83 c1 01             	add    $0x1,%ecx
  8007cf:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8007d2:	0f b6 01             	movzbl (%ecx),%eax
  8007d5:	84 c0                	test   %al,%al
  8007d7:	74 04                	je     8007dd <strcmp+0x1c>
  8007d9:	3a 02                	cmp    (%edx),%al
  8007db:	74 ef                	je     8007cc <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007dd:	0f b6 c0             	movzbl %al,%eax
  8007e0:	0f b6 12             	movzbl (%edx),%edx
  8007e3:	29 d0                	sub    %edx,%eax
}
  8007e5:	5d                   	pop    %ebp
  8007e6:	c3                   	ret    

008007e7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007e7:	55                   	push   %ebp
  8007e8:	89 e5                	mov    %esp,%ebp
  8007ea:	53                   	push   %ebx
  8007eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f1:	89 c3                	mov    %eax,%ebx
  8007f3:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007f6:	eb 06                	jmp    8007fe <strncmp+0x17>
		n--, p++, q++;
  8007f8:	83 c0 01             	add    $0x1,%eax
  8007fb:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8007fe:	39 d8                	cmp    %ebx,%eax
  800800:	74 18                	je     80081a <strncmp+0x33>
  800802:	0f b6 08             	movzbl (%eax),%ecx
  800805:	84 c9                	test   %cl,%cl
  800807:	74 04                	je     80080d <strncmp+0x26>
  800809:	3a 0a                	cmp    (%edx),%cl
  80080b:	74 eb                	je     8007f8 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80080d:	0f b6 00             	movzbl (%eax),%eax
  800810:	0f b6 12             	movzbl (%edx),%edx
  800813:	29 d0                	sub    %edx,%eax
}
  800815:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800818:	c9                   	leave  
  800819:	c3                   	ret    
		return 0;
  80081a:	b8 00 00 00 00       	mov    $0x0,%eax
  80081f:	eb f4                	jmp    800815 <strncmp+0x2e>

00800821 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800821:	55                   	push   %ebp
  800822:	89 e5                	mov    %esp,%ebp
  800824:	8b 45 08             	mov    0x8(%ebp),%eax
  800827:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80082b:	eb 03                	jmp    800830 <strchr+0xf>
  80082d:	83 c0 01             	add    $0x1,%eax
  800830:	0f b6 10             	movzbl (%eax),%edx
  800833:	84 d2                	test   %dl,%dl
  800835:	74 06                	je     80083d <strchr+0x1c>
		if (*s == c)
  800837:	38 ca                	cmp    %cl,%dl
  800839:	75 f2                	jne    80082d <strchr+0xc>
  80083b:	eb 05                	jmp    800842 <strchr+0x21>
			return (char *) s;
	return 0;
  80083d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800842:	5d                   	pop    %ebp
  800843:	c3                   	ret    

00800844 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800844:	55                   	push   %ebp
  800845:	89 e5                	mov    %esp,%ebp
  800847:	8b 45 08             	mov    0x8(%ebp),%eax
  80084a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80084e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800851:	38 ca                	cmp    %cl,%dl
  800853:	74 09                	je     80085e <strfind+0x1a>
  800855:	84 d2                	test   %dl,%dl
  800857:	74 05                	je     80085e <strfind+0x1a>
	for (; *s; s++)
  800859:	83 c0 01             	add    $0x1,%eax
  80085c:	eb f0                	jmp    80084e <strfind+0xa>
			break;
	return (char *) s;
}
  80085e:	5d                   	pop    %ebp
  80085f:	c3                   	ret    

00800860 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	57                   	push   %edi
  800864:	56                   	push   %esi
  800865:	53                   	push   %ebx
  800866:	8b 55 08             	mov    0x8(%ebp),%edx
  800869:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  80086c:	85 c9                	test   %ecx,%ecx
  80086e:	74 33                	je     8008a3 <memset+0x43>
		return v;
	if ((int) v % 4 == 0 && n % 4 == 0) {
  800870:	89 d0                	mov    %edx,%eax
  800872:	09 c8                	or     %ecx,%eax
  800874:	a8 03                	test   $0x3,%al
  800876:	75 23                	jne    80089b <memset+0x3b>
		c &= 0xFF;
  800878:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  80087c:	89 d8                	mov    %ebx,%eax
  80087e:	c1 e0 08             	shl    $0x8,%eax
  800881:	89 df                	mov    %ebx,%edi
  800883:	c1 e7 18             	shl    $0x18,%edi
  800886:	89 de                	mov    %ebx,%esi
  800888:	c1 e6 10             	shl    $0x10,%esi
  80088b:	09 f7                	or     %esi,%edi
  80088d:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
		             : "=D"(p), "=c"(n)
		             : "D"(p), "a"(c), "c"(n / 4)
  80088f:	c1 e9 02             	shr    $0x2,%ecx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  800892:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800894:	89 d7                	mov    %edx,%edi
  800896:	fc                   	cld    
  800897:	f3 ab                	rep stos %eax,%es:(%edi)
  800899:	eb 08                	jmp    8008a3 <memset+0x43>
		             : "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80089b:	89 d7                	mov    %edx,%edi
  80089d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a0:	fc                   	cld    
  8008a1:	f3 aa                	rep stos %al,%es:(%edi)
		             : "=D"(p), "=c"(n)
		             : "0"(p), "a"(c), "1"(n)
		             : "cc", "memory");
	return v;
}
  8008a3:	89 d0                	mov    %edx,%eax
  8008a5:	5b                   	pop    %ebx
  8008a6:	5e                   	pop    %esi
  8008a7:	5f                   	pop    %edi
  8008a8:	5d                   	pop    %ebp
  8008a9:	c3                   	ret    

008008aa <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008aa:	55                   	push   %ebp
  8008ab:	89 e5                	mov    %esp,%ebp
  8008ad:	57                   	push   %edi
  8008ae:	56                   	push   %esi
  8008af:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008b5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008b8:	39 c6                	cmp    %eax,%esi
  8008ba:	73 32                	jae    8008ee <memmove+0x44>
  8008bc:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008bf:	39 c2                	cmp    %eax,%edx
  8008c1:	76 2b                	jbe    8008ee <memmove+0x44>
		s += n;
		d += n;
  8008c3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  8008c6:	89 d6                	mov    %edx,%esi
  8008c8:	09 fe                	or     %edi,%esi
  8008ca:	09 ce                	or     %ecx,%esi
  8008cc:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008d2:	75 0e                	jne    8008e2 <memmove+0x38>
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  8008d4:	83 ef 04             	sub    $0x4,%edi
			             "S"(s - 4),
  8008d7:	8d 72 fc             	lea    -0x4(%edx),%esi
			             "c"(n / 4)
  8008da:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  8008dd:	fd                   	std    
  8008de:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008e0:	eb 09                	jmp    8008eb <memmove+0x41>
			             : "cc", "memory");
		else
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  8008e2:	83 ef 01             	sub    $0x1,%edi
			             "S"(s - 1),
  8008e5:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  8008e8:	fd                   	std    
  8008e9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             "c"(n)
			             : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008eb:	fc                   	cld    
  8008ec:	eb 1a                	jmp    800908 <memmove+0x5e>
	} else {
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  8008ee:	89 f2                	mov    %esi,%edx
  8008f0:	09 c2                	or     %eax,%edx
  8008f2:	09 ca                	or     %ecx,%edx
  8008f4:	f6 c2 03             	test   $0x3,%dl
  8008f7:	75 0a                	jne    800903 <memmove+0x59>
			asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  8008f9:	c1 e9 02             	shr    $0x2,%ecx
  8008fc:	89 c7                	mov    %eax,%edi
  8008fe:	fc                   	cld    
  8008ff:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800901:	eb 05                	jmp    800908 <memmove+0x5e>
			             : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800903:	89 c7                	mov    %eax,%edi
  800905:	fc                   	cld    
  800906:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             : "cc", "memory");
	}
	return dst;
}
  800908:	5e                   	pop    %esi
  800909:	5f                   	pop    %edi
  80090a:	5d                   	pop    %ebp
  80090b:	c3                   	ret    

0080090c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80090c:	55                   	push   %ebp
  80090d:	89 e5                	mov    %esp,%ebp
  80090f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800912:	ff 75 10             	push   0x10(%ebp)
  800915:	ff 75 0c             	push   0xc(%ebp)
  800918:	ff 75 08             	push   0x8(%ebp)
  80091b:	e8 8a ff ff ff       	call   8008aa <memmove>
}
  800920:	c9                   	leave  
  800921:	c3                   	ret    

00800922 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
  800925:	56                   	push   %esi
  800926:	53                   	push   %ebx
  800927:	8b 45 08             	mov    0x8(%ebp),%eax
  80092a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80092d:	89 c6                	mov    %eax,%esi
  80092f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800932:	eb 06                	jmp    80093a <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800934:	83 c0 01             	add    $0x1,%eax
  800937:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  80093a:	39 f0                	cmp    %esi,%eax
  80093c:	74 14                	je     800952 <memcmp+0x30>
		if (*s1 != *s2)
  80093e:	0f b6 08             	movzbl (%eax),%ecx
  800941:	0f b6 1a             	movzbl (%edx),%ebx
  800944:	38 d9                	cmp    %bl,%cl
  800946:	74 ec                	je     800934 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800948:	0f b6 c1             	movzbl %cl,%eax
  80094b:	0f b6 db             	movzbl %bl,%ebx
  80094e:	29 d8                	sub    %ebx,%eax
  800950:	eb 05                	jmp    800957 <memcmp+0x35>
	}

	return 0;
  800952:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800957:	5b                   	pop    %ebx
  800958:	5e                   	pop    %esi
  800959:	5d                   	pop    %ebp
  80095a:	c3                   	ret    

0080095b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	8b 45 08             	mov    0x8(%ebp),%eax
  800961:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800964:	89 c2                	mov    %eax,%edx
  800966:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800969:	eb 03                	jmp    80096e <memfind+0x13>
  80096b:	83 c0 01             	add    $0x1,%eax
  80096e:	39 d0                	cmp    %edx,%eax
  800970:	73 04                	jae    800976 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800972:	38 08                	cmp    %cl,(%eax)
  800974:	75 f5                	jne    80096b <memfind+0x10>
			break;
	return (void *) s;
}
  800976:	5d                   	pop    %ebp
  800977:	c3                   	ret    

00800978 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800978:	55                   	push   %ebp
  800979:	89 e5                	mov    %esp,%ebp
  80097b:	57                   	push   %edi
  80097c:	56                   	push   %esi
  80097d:	53                   	push   %ebx
  80097e:	8b 55 08             	mov    0x8(%ebp),%edx
  800981:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800984:	eb 03                	jmp    800989 <strtol+0x11>
		s++;
  800986:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800989:	0f b6 02             	movzbl (%edx),%eax
  80098c:	3c 20                	cmp    $0x20,%al
  80098e:	74 f6                	je     800986 <strtol+0xe>
  800990:	3c 09                	cmp    $0x9,%al
  800992:	74 f2                	je     800986 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800994:	3c 2b                	cmp    $0x2b,%al
  800996:	74 2a                	je     8009c2 <strtol+0x4a>
	int neg = 0;
  800998:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  80099d:	3c 2d                	cmp    $0x2d,%al
  80099f:	74 2b                	je     8009cc <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009a1:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009a7:	75 0f                	jne    8009b8 <strtol+0x40>
  8009a9:	80 3a 30             	cmpb   $0x30,(%edx)
  8009ac:	74 28                	je     8009d6 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009ae:	85 db                	test   %ebx,%ebx
  8009b0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009b5:	0f 44 d8             	cmove  %eax,%ebx
  8009b8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009bd:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8009c0:	eb 46                	jmp    800a08 <strtol+0x90>
		s++;
  8009c2:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  8009c5:	bf 00 00 00 00       	mov    $0x0,%edi
  8009ca:	eb d5                	jmp    8009a1 <strtol+0x29>
		s++, neg = 1;
  8009cc:	83 c2 01             	add    $0x1,%edx
  8009cf:	bf 01 00 00 00       	mov    $0x1,%edi
  8009d4:	eb cb                	jmp    8009a1 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009d6:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009da:	74 0e                	je     8009ea <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  8009dc:	85 db                	test   %ebx,%ebx
  8009de:	75 d8                	jne    8009b8 <strtol+0x40>
		s++, base = 8;
  8009e0:	83 c2 01             	add    $0x1,%edx
  8009e3:	bb 08 00 00 00       	mov    $0x8,%ebx
  8009e8:	eb ce                	jmp    8009b8 <strtol+0x40>
		s += 2, base = 16;
  8009ea:	83 c2 02             	add    $0x2,%edx
  8009ed:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009f2:	eb c4                	jmp    8009b8 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  8009f4:	0f be c0             	movsbl %al,%eax
  8009f7:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8009fa:	3b 45 10             	cmp    0x10(%ebp),%eax
  8009fd:	7d 3a                	jge    800a39 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  8009ff:	83 c2 01             	add    $0x1,%edx
  800a02:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800a06:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800a08:	0f b6 02             	movzbl (%edx),%eax
  800a0b:	8d 70 d0             	lea    -0x30(%eax),%esi
  800a0e:	89 f3                	mov    %esi,%ebx
  800a10:	80 fb 09             	cmp    $0x9,%bl
  800a13:	76 df                	jbe    8009f4 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800a15:	8d 70 9f             	lea    -0x61(%eax),%esi
  800a18:	89 f3                	mov    %esi,%ebx
  800a1a:	80 fb 19             	cmp    $0x19,%bl
  800a1d:	77 08                	ja     800a27 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800a1f:	0f be c0             	movsbl %al,%eax
  800a22:	83 e8 57             	sub    $0x57,%eax
  800a25:	eb d3                	jmp    8009fa <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800a27:	8d 70 bf             	lea    -0x41(%eax),%esi
  800a2a:	89 f3                	mov    %esi,%ebx
  800a2c:	80 fb 19             	cmp    $0x19,%bl
  800a2f:	77 08                	ja     800a39 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800a31:	0f be c0             	movsbl %al,%eax
  800a34:	83 e8 37             	sub    $0x37,%eax
  800a37:	eb c1                	jmp    8009fa <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a39:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a3d:	74 05                	je     800a44 <strtol+0xcc>
		*endptr = (char *) s;
  800a3f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a42:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800a44:	89 c8                	mov    %ecx,%eax
  800a46:	f7 d8                	neg    %eax
  800a48:	85 ff                	test   %edi,%edi
  800a4a:	0f 45 c8             	cmovne %eax,%ecx
}
  800a4d:	89 c8                	mov    %ecx,%eax
  800a4f:	5b                   	pop    %ebx
  800a50:	5e                   	pop    %esi
  800a51:	5f                   	pop    %edi
  800a52:	5d                   	pop    %ebp
  800a53:	c3                   	ret    

00800a54 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a54:	55                   	push   %ebp
  800a55:	89 e5                	mov    %esp,%ebp
  800a57:	57                   	push   %edi
  800a58:	56                   	push   %esi
  800a59:	53                   	push   %ebx
  800a5a:	83 ec 1c             	sub    $0x1c,%esp
  800a5d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a60:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800a63:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile(
  800a65:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a68:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a6b:	8b 7d 10             	mov    0x10(%ebp),%edi
  800a6e:	8b 75 14             	mov    0x14(%ebp),%esi
  800a71:	cd 30                	int    $0x30
	        "int %1\n"
	        : "=a"(ret)
	        : "i"(T_SYSCALL), "a"(num), "d"(a1), "c"(a2), "b"(a3), "D"(a4), "S"(a5)
	        : "cc", "memory");

	if (check && ret > 0)
  800a73:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a77:	74 04                	je     800a7d <syscall+0x29>
  800a79:	85 c0                	test   %eax,%eax
  800a7b:	7f 08                	jg     800a85 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800a7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a80:	5b                   	pop    %ebx
  800a81:	5e                   	pop    %esi
  800a82:	5f                   	pop    %edi
  800a83:	5d                   	pop    %ebp
  800a84:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800a85:	83 ec 0c             	sub    $0xc,%esp
  800a88:	50                   	push   %eax
  800a89:	ff 75 e0             	push   -0x20(%ebp)
  800a8c:	68 64 16 80 00       	push   $0x801664
  800a91:	6a 1e                	push   $0x1e
  800a93:	68 81 16 80 00       	push   $0x801681
  800a98:	e8 59 06 00 00       	call   8010f6 <_panic>

00800a9d <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800a9d:	55                   	push   %ebp
  800a9e:	89 e5                	mov    %esp,%ebp
  800aa0:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t) s, len, 0, 0, 0);
  800aa3:	6a 00                	push   $0x0
  800aa5:	6a 00                	push   $0x0
  800aa7:	6a 00                	push   $0x0
  800aa9:	ff 75 0c             	push   0xc(%ebp)
  800aac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aaf:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab9:	e8 96 ff ff ff       	call   800a54 <syscall>
}
  800abe:	83 c4 10             	add    $0x10,%esp
  800ac1:	c9                   	leave  
  800ac2:	c3                   	ret    

00800ac3 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ac3:	55                   	push   %ebp
  800ac4:	89 e5                	mov    %esp,%ebp
  800ac6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800ac9:	6a 00                	push   $0x0
  800acb:	6a 00                	push   $0x0
  800acd:	6a 00                	push   $0x0
  800acf:	6a 00                	push   $0x0
  800ad1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ad6:	ba 00 00 00 00       	mov    $0x0,%edx
  800adb:	b8 01 00 00 00       	mov    $0x1,%eax
  800ae0:	e8 6f ff ff ff       	call   800a54 <syscall>
}
  800ae5:	c9                   	leave  
  800ae6:	c3                   	ret    

00800ae7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ae7:	55                   	push   %ebp
  800ae8:	89 e5                	mov    %esp,%ebp
  800aea:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800aed:	6a 00                	push   $0x0
  800aef:	6a 00                	push   $0x0
  800af1:	6a 00                	push   $0x0
  800af3:	6a 00                	push   $0x0
  800af5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800af8:	ba 01 00 00 00       	mov    $0x1,%edx
  800afd:	b8 03 00 00 00       	mov    $0x3,%eax
  800b02:	e8 4d ff ff ff       	call   800a54 <syscall>
}
  800b07:	c9                   	leave  
  800b08:	c3                   	ret    

00800b09 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b09:	55                   	push   %ebp
  800b0a:	89 e5                	mov    %esp,%ebp
  800b0c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800b0f:	6a 00                	push   $0x0
  800b11:	6a 00                	push   $0x0
  800b13:	6a 00                	push   $0x0
  800b15:	6a 00                	push   $0x0
  800b17:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b1c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b21:	b8 02 00 00 00       	mov    $0x2,%eax
  800b26:	e8 29 ff ff ff       	call   800a54 <syscall>
}
  800b2b:	c9                   	leave  
  800b2c:	c3                   	ret    

00800b2d <sys_yield>:

void
sys_yield(void)
{
  800b2d:	55                   	push   %ebp
  800b2e:	89 e5                	mov    %esp,%ebp
  800b30:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800b33:	6a 00                	push   $0x0
  800b35:	6a 00                	push   $0x0
  800b37:	6a 00                	push   $0x0
  800b39:	6a 00                	push   $0x0
  800b3b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b40:	ba 00 00 00 00       	mov    $0x0,%edx
  800b45:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b4a:	e8 05 ff ff ff       	call   800a54 <syscall>
}
  800b4f:	83 c4 10             	add    $0x10,%esp
  800b52:	c9                   	leave  
  800b53:	c3                   	ret    

00800b54 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b54:	55                   	push   %ebp
  800b55:	89 e5                	mov    %esp,%ebp
  800b57:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800b5a:	6a 00                	push   $0x0
  800b5c:	6a 00                	push   $0x0
  800b5e:	ff 75 10             	push   0x10(%ebp)
  800b61:	ff 75 0c             	push   0xc(%ebp)
  800b64:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b67:	ba 01 00 00 00       	mov    $0x1,%edx
  800b6c:	b8 04 00 00 00       	mov    $0x4,%eax
  800b71:	e8 de fe ff ff       	call   800a54 <syscall>
}
  800b76:	c9                   	leave  
  800b77:	c3                   	ret    

00800b78 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b78:	55                   	push   %ebp
  800b79:	89 e5                	mov    %esp,%ebp
  800b7b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map,
  800b7e:	ff 75 18             	push   0x18(%ebp)
  800b81:	ff 75 14             	push   0x14(%ebp)
  800b84:	ff 75 10             	push   0x10(%ebp)
  800b87:	ff 75 0c             	push   0xc(%ebp)
  800b8a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b8d:	ba 01 00 00 00       	mov    $0x1,%edx
  800b92:	b8 05 00 00 00       	mov    $0x5,%eax
  800b97:	e8 b8 fe ff ff       	call   800a54 <syscall>
	               srcenv,
	               (uint32_t) srcva,
	               dstenv,
	               (uint32_t) dstva,
	               perm);
}
  800b9c:	c9                   	leave  
  800b9d:	c3                   	ret    

00800b9e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b9e:	55                   	push   %ebp
  800b9f:	89 e5                	mov    %esp,%ebp
  800ba1:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800ba4:	6a 00                	push   $0x0
  800ba6:	6a 00                	push   $0x0
  800ba8:	6a 00                	push   $0x0
  800baa:	ff 75 0c             	push   0xc(%ebp)
  800bad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bb0:	ba 01 00 00 00       	mov    $0x1,%edx
  800bb5:	b8 06 00 00 00       	mov    $0x6,%eax
  800bba:	e8 95 fe ff ff       	call   800a54 <syscall>
}
  800bbf:	c9                   	leave  
  800bc0:	c3                   	ret    

00800bc1 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bc1:	55                   	push   %ebp
  800bc2:	89 e5                	mov    %esp,%ebp
  800bc4:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800bc7:	6a 00                	push   $0x0
  800bc9:	6a 00                	push   $0x0
  800bcb:	6a 00                	push   $0x0
  800bcd:	ff 75 0c             	push   0xc(%ebp)
  800bd0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bd3:	ba 01 00 00 00       	mov    $0x1,%edx
  800bd8:	b8 08 00 00 00       	mov    $0x8,%eax
  800bdd:	e8 72 fe ff ff       	call   800a54 <syscall>
}
  800be2:	c9                   	leave  
  800be3:	c3                   	ret    

00800be4 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800be4:	55                   	push   %ebp
  800be5:	89 e5                	mov    %esp,%ebp
  800be7:	83 ec 08             	sub    $0x8,%esp
	return syscall(
  800bea:	6a 00                	push   $0x0
  800bec:	6a 00                	push   $0x0
  800bee:	6a 00                	push   $0x0
  800bf0:	ff 75 0c             	push   0xc(%ebp)
  800bf3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bf6:	ba 01 00 00 00       	mov    $0x1,%edx
  800bfb:	b8 09 00 00 00       	mov    $0x9,%eax
  800c00:	e8 4f fe ff ff       	call   800a54 <syscall>
	        SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c05:	c9                   	leave  
  800c06:	c3                   	ret    

00800c07 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c07:	55                   	push   %ebp
  800c08:	89 e5                	mov    %esp,%ebp
  800c0a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800c0d:	6a 00                	push   $0x0
  800c0f:	ff 75 14             	push   0x14(%ebp)
  800c12:	ff 75 10             	push   0x10(%ebp)
  800c15:	ff 75 0c             	push   0xc(%ebp)
  800c18:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c1b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c20:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c25:	e8 2a fe ff ff       	call   800a54 <syscall>
}
  800c2a:	c9                   	leave  
  800c2b:	c3                   	ret    

00800c2c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c2c:	55                   	push   %ebp
  800c2d:	89 e5                	mov    %esp,%ebp
  800c2f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t) dstva, 0, 0, 0, 0);
  800c32:	6a 00                	push   $0x0
  800c34:	6a 00                	push   $0x0
  800c36:	6a 00                	push   $0x0
  800c38:	6a 00                	push   $0x0
  800c3a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c3d:	ba 01 00 00 00       	mov    $0x1,%edx
  800c42:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c47:	e8 08 fe ff ff       	call   800a54 <syscall>
}
  800c4c:	c9                   	leave  
  800c4d:	c3                   	ret    

00800c4e <sys_get_priority>:

// Get priority of the current process
int
sys_get_priority(void)
{
  800c4e:	55                   	push   %ebp
  800c4f:	89 e5                	mov    %esp,%ebp
  800c51:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_get_priority, 0, 0, 0, 0, 0, 0);
  800c54:	6a 00                	push   $0x0
  800c56:	6a 00                	push   $0x0
  800c58:	6a 00                	push   $0x0
  800c5a:	6a 00                	push   $0x0
  800c5c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c61:	ba 00 00 00 00       	mov    $0x0,%edx
  800c66:	b8 0d 00 00 00       	mov    $0xd,%eax
  800c6b:	e8 e4 fd ff ff       	call   800a54 <syscall>
}
  800c70:	c9                   	leave  
  800c71:	c3                   	ret    

00800c72 <sys_set_priority>:

// Get priority of the current process
int
sys_set_priority(unsigned int priority)
{
  800c72:	55                   	push   %ebp
  800c73:	89 e5                	mov    %esp,%ebp
  800c75:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, (uint32_t) priority, 0, 0, 0, 0);
  800c78:	6a 00                	push   $0x0
  800c7a:	6a 00                	push   $0x0
  800c7c:	6a 00                	push   $0x0
  800c7e:	6a 00                	push   $0x0
  800c80:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c83:	ba 00 00 00 00       	mov    $0x0,%edx
  800c88:	b8 0e 00 00 00       	mov    $0xe,%eax
  800c8d:	e8 c2 fd ff ff       	call   800a54 <syscall>
}
  800c92:	c9                   	leave  
  800c93:	c3                   	ret    

00800c94 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	56                   	push   %esi
  800c98:	53                   	push   %ebx
  800c99:	89 c1                	mov    %eax,%ecx
	int r;

	void *addr = (void *) (pn << PGSHIFT);
  800c9b:	89 d6                	mov    %edx,%esi
  800c9d:	c1 e6 0c             	shl    $0xc,%esi

	pte_t pte = uvpt[pn];
  800ca0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx

	if (!(pte & PTE_P) || !(pte & PTE_U))
  800ca7:	89 d0                	mov    %edx,%eax
  800ca9:	83 e0 05             	and    $0x5,%eax
  800cac:	83 f8 05             	cmp    $0x5,%eax
  800caf:	75 5a                	jne    800d0b <duppage+0x77>
		panic("duppage: copy a non-present or non-user page");

	int perm = PTE_U | PTE_P;
	// Verifico permisos para páginas de IO
	if (pte & (PTE_PCD | PTE_PWT))
  800cb1:	89 d0                	mov    %edx,%eax
  800cb3:	83 e0 18             	and    $0x18,%eax
		perm |= PTE_PCD | PTE_PWT;
  800cb6:	83 f8 01             	cmp    $0x1,%eax
  800cb9:	19 c0                	sbb    %eax,%eax
  800cbb:	83 e0 e8             	and    $0xffffffe8,%eax
  800cbe:	83 c0 1d             	add    $0x1d,%eax


	// Si es de escritura o copy-on-write y NO es de IO
	if ((pte & PTE_W) || (pte & PTE_COW)) {
  800cc1:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800cc7:	74 68                	je     800d31 <duppage+0x9d>
		// Mappeo en el hijo la página
		if ((r = sys_page_map(0, addr, envid, addr, perm | PTE_COW)) < 0)
  800cc9:	80 cc 08             	or     $0x8,%ah
  800ccc:	89 c3                	mov    %eax,%ebx
  800cce:	83 ec 0c             	sub    $0xc,%esp
  800cd1:	50                   	push   %eax
  800cd2:	56                   	push   %esi
  800cd3:	51                   	push   %ecx
  800cd4:	56                   	push   %esi
  800cd5:	6a 00                	push   $0x0
  800cd7:	e8 9c fe ff ff       	call   800b78 <sys_page_map>
  800cdc:	83 c4 20             	add    $0x20,%esp
  800cdf:	85 c0                	test   %eax,%eax
  800ce1:	78 3c                	js     800d1f <duppage+0x8b>
			panic("duppage: sys_page_map on childern COW: %e", r);

		// Cambio los permisos del padre
		if ((r = sys_page_map(0, addr, 0, addr, perm | PTE_COW)) < 0)
  800ce3:	83 ec 0c             	sub    $0xc,%esp
  800ce6:	53                   	push   %ebx
  800ce7:	56                   	push   %esi
  800ce8:	6a 00                	push   $0x0
  800cea:	56                   	push   %esi
  800ceb:	6a 00                	push   $0x0
  800ced:	e8 86 fe ff ff       	call   800b78 <sys_page_map>
  800cf2:	83 c4 20             	add    $0x20,%esp
  800cf5:	85 c0                	test   %eax,%eax
  800cf7:	79 4d                	jns    800d46 <duppage+0xb2>
			panic("duppage: sys_page_map on parent COW: %e", r);
  800cf9:	50                   	push   %eax
  800cfa:	68 ec 16 80 00       	push   $0x8016ec
  800cff:	6a 57                	push   $0x57
  800d01:	68 e1 17 80 00       	push   $0x8017e1
  800d06:	e8 eb 03 00 00       	call   8010f6 <_panic>
		panic("duppage: copy a non-present or non-user page");
  800d0b:	83 ec 04             	sub    $0x4,%esp
  800d0e:	68 90 16 80 00       	push   $0x801690
  800d13:	6a 47                	push   $0x47
  800d15:	68 e1 17 80 00       	push   $0x8017e1
  800d1a:	e8 d7 03 00 00       	call   8010f6 <_panic>
			panic("duppage: sys_page_map on childern COW: %e", r);
  800d1f:	50                   	push   %eax
  800d20:	68 c0 16 80 00       	push   $0x8016c0
  800d25:	6a 53                	push   $0x53
  800d27:	68 e1 17 80 00       	push   $0x8017e1
  800d2c:	e8 c5 03 00 00       	call   8010f6 <_panic>
	} else {
		// Solo mappeo la página de solo lectura
		if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  800d31:	83 ec 0c             	sub    $0xc,%esp
  800d34:	50                   	push   %eax
  800d35:	56                   	push   %esi
  800d36:	51                   	push   %ecx
  800d37:	56                   	push   %esi
  800d38:	6a 00                	push   $0x0
  800d3a:	e8 39 fe ff ff       	call   800b78 <sys_page_map>
  800d3f:	83 c4 20             	add    $0x20,%esp
  800d42:	85 c0                	test   %eax,%eax
  800d44:	78 0c                	js     800d52 <duppage+0xbe>
			panic("duppage: sys_page_map on childern RO: %e", r);
	}

	// panic("duppage not implemented");
	return 0;
}
  800d46:	b8 00 00 00 00       	mov    $0x0,%eax
  800d4b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d4e:	5b                   	pop    %ebx
  800d4f:	5e                   	pop    %esi
  800d50:	5d                   	pop    %ebp
  800d51:	c3                   	ret    
			panic("duppage: sys_page_map on childern RO: %e", r);
  800d52:	50                   	push   %eax
  800d53:	68 14 17 80 00       	push   $0x801714
  800d58:	6a 5b                	push   $0x5b
  800d5a:	68 e1 17 80 00       	push   $0x8017e1
  800d5f:	e8 92 03 00 00       	call   8010f6 <_panic>

00800d64 <dup_or_share>:
 *
 * Hace uso de uvpd y uvpt para chequear permisos.
 */
static void
dup_or_share(envid_t envid, uint32_t pnum, int perm)
{
  800d64:	55                   	push   %ebp
  800d65:	89 e5                	mov    %esp,%ebp
  800d67:	57                   	push   %edi
  800d68:	56                   	push   %esi
  800d69:	53                   	push   %ebx
  800d6a:	83 ec 0c             	sub    $0xc,%esp
  800d6d:	89 c7                	mov    %eax,%edi
	int r;
	void *addr = (void *) (pnum << PGSHIFT);

	pte_t pte = uvpt[pnum];
  800d6f:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax

	if (!(pte & PTE_P))
  800d76:	a8 01                	test   $0x1,%al
  800d78:	74 33                	je     800dad <dup_or_share+0x49>
  800d7a:	89 d6                	mov    %edx,%esi
		return;

	// Filtro permisos
	perm &= (pte & PTE_W);
  800d7c:	21 c1                	and    %eax,%ecx
  800d7e:	89 cb                	mov    %ecx,%ebx
  800d80:	83 e3 02             	and    $0x2,%ebx
	perm &= PTE_SYSCALL;


	if (pte & (PTE_PCD | PTE_PWT))
		perm |= PTE_PCD | PTE_PWT;
  800d83:	89 da                	mov    %ebx,%edx
  800d85:	83 ca 18             	or     $0x18,%edx
  800d88:	a8 18                	test   $0x18,%al
  800d8a:	0f 45 da             	cmovne %edx,%ebx
	void *addr = (void *) (pnum << PGSHIFT);
  800d8d:	c1 e6 0c             	shl    $0xc,%esi

	// Si tengo que copiar
	if (!(pte & PTE_W) || (pte & (PTE_PCD | PTE_PWT))) {
  800d90:	83 e0 1a             	and    $0x1a,%eax
  800d93:	83 f8 02             	cmp    $0x2,%eax
  800d96:	74 32                	je     800dca <dup_or_share+0x66>
		if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  800d98:	83 ec 0c             	sub    $0xc,%esp
  800d9b:	53                   	push   %ebx
  800d9c:	56                   	push   %esi
  800d9d:	57                   	push   %edi
  800d9e:	56                   	push   %esi
  800d9f:	6a 00                	push   $0x0
  800da1:	e8 d2 fd ff ff       	call   800b78 <sys_page_map>
  800da6:	83 c4 20             	add    $0x20,%esp
  800da9:	85 c0                	test   %eax,%eax
  800dab:	78 08                	js     800db5 <dup_or_share+0x51>
			panic("dup_or_share: sys_page_map: %e", r);
		memmove(UTEMP, addr, PGSIZE);
		if ((r = sys_page_unmap(0, UTEMP)) < 0)
			panic("sys_page_unmap: %e", r);
	}
}
  800dad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800db0:	5b                   	pop    %ebx
  800db1:	5e                   	pop    %esi
  800db2:	5f                   	pop    %edi
  800db3:	5d                   	pop    %ebp
  800db4:	c3                   	ret    
			panic("dup_or_share: sys_page_map: %e", r);
  800db5:	50                   	push   %eax
  800db6:	68 40 17 80 00       	push   $0x801740
  800dbb:	68 84 00 00 00       	push   $0x84
  800dc0:	68 e1 17 80 00       	push   $0x8017e1
  800dc5:	e8 2c 03 00 00       	call   8010f6 <_panic>
		if ((r = sys_page_alloc(envid, addr, perm)) < 0)
  800dca:	83 ec 04             	sub    $0x4,%esp
  800dcd:	53                   	push   %ebx
  800dce:	56                   	push   %esi
  800dcf:	57                   	push   %edi
  800dd0:	e8 7f fd ff ff       	call   800b54 <sys_page_alloc>
  800dd5:	83 c4 10             	add    $0x10,%esp
  800dd8:	85 c0                	test   %eax,%eax
  800dda:	78 57                	js     800e33 <dup_or_share+0xcf>
		if ((r = sys_page_map(envid, addr, 0, UTEMP, perm)) < 0)
  800ddc:	83 ec 0c             	sub    $0xc,%esp
  800ddf:	53                   	push   %ebx
  800de0:	68 00 00 40 00       	push   $0x400000
  800de5:	6a 00                	push   $0x0
  800de7:	56                   	push   %esi
  800de8:	57                   	push   %edi
  800de9:	e8 8a fd ff ff       	call   800b78 <sys_page_map>
  800dee:	83 c4 20             	add    $0x20,%esp
  800df1:	85 c0                	test   %eax,%eax
  800df3:	78 53                	js     800e48 <dup_or_share+0xe4>
		memmove(UTEMP, addr, PGSIZE);
  800df5:	83 ec 04             	sub    $0x4,%esp
  800df8:	68 00 10 00 00       	push   $0x1000
  800dfd:	56                   	push   %esi
  800dfe:	68 00 00 40 00       	push   $0x400000
  800e03:	e8 a2 fa ff ff       	call   8008aa <memmove>
		if ((r = sys_page_unmap(0, UTEMP)) < 0)
  800e08:	83 c4 08             	add    $0x8,%esp
  800e0b:	68 00 00 40 00       	push   $0x400000
  800e10:	6a 00                	push   $0x0
  800e12:	e8 87 fd ff ff       	call   800b9e <sys_page_unmap>
  800e17:	83 c4 10             	add    $0x10,%esp
  800e1a:	85 c0                	test   %eax,%eax
  800e1c:	79 8f                	jns    800dad <dup_or_share+0x49>
			panic("sys_page_unmap: %e", r);
  800e1e:	50                   	push   %eax
  800e1f:	68 2b 18 80 00       	push   $0x80182b
  800e24:	68 8d 00 00 00       	push   $0x8d
  800e29:	68 e1 17 80 00       	push   $0x8017e1
  800e2e:	e8 c3 02 00 00       	call   8010f6 <_panic>
			panic("dup_or_share: sys_page_alloc: %e", r);
  800e33:	50                   	push   %eax
  800e34:	68 60 17 80 00       	push   $0x801760
  800e39:	68 88 00 00 00       	push   $0x88
  800e3e:	68 e1 17 80 00       	push   $0x8017e1
  800e43:	e8 ae 02 00 00       	call   8010f6 <_panic>
			panic("dup_or_share: sys_page_map: %e", r);
  800e48:	50                   	push   %eax
  800e49:	68 40 17 80 00       	push   $0x801740
  800e4e:	68 8a 00 00 00       	push   $0x8a
  800e53:	68 e1 17 80 00       	push   $0x8017e1
  800e58:	e8 99 02 00 00       	call   8010f6 <_panic>

00800e5d <pgfault>:
{
  800e5d:	55                   	push   %ebp
  800e5e:	89 e5                	mov    %esp,%ebp
  800e60:	53                   	push   %ebx
  800e61:	83 ec 08             	sub    $0x8,%esp
	void *addr = (void *) utf->utf_fault_va;
  800e64:	8b 45 08             	mov    0x8(%ebp),%eax
  800e67:	8b 18                	mov    (%eax),%ebx
	pte_t fault_pte = uvpt[((uint32_t) addr) >> PGSHIFT];
  800e69:	89 d8                	mov    %ebx,%eax
  800e6b:	c1 e8 0c             	shr    $0xc,%eax
  800e6e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if ((r = sys_page_alloc(0, PFTEMP, perm)) < 0)
  800e75:	6a 07                	push   $0x7
  800e77:	68 00 f0 7f 00       	push   $0x7ff000
  800e7c:	6a 00                	push   $0x0
  800e7e:	e8 d1 fc ff ff       	call   800b54 <sys_page_alloc>
  800e83:	83 c4 10             	add    $0x10,%esp
  800e86:	85 c0                	test   %eax,%eax
  800e88:	78 51                	js     800edb <pgfault+0x7e>
	addr = ROUNDDOWN(addr, PGSIZE);
  800e8a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr, PGSIZE);
  800e90:	83 ec 04             	sub    $0x4,%esp
  800e93:	68 00 10 00 00       	push   $0x1000
  800e98:	53                   	push   %ebx
  800e99:	68 00 f0 7f 00       	push   $0x7ff000
  800e9e:	e8 07 fa ff ff       	call   8008aa <memmove>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, perm)) < 0)
  800ea3:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800eaa:	53                   	push   %ebx
  800eab:	6a 00                	push   $0x0
  800ead:	68 00 f0 7f 00       	push   $0x7ff000
  800eb2:	6a 00                	push   $0x0
  800eb4:	e8 bf fc ff ff       	call   800b78 <sys_page_map>
  800eb9:	83 c4 20             	add    $0x20,%esp
  800ebc:	85 c0                	test   %eax,%eax
  800ebe:	78 2d                	js     800eed <pgfault+0x90>
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800ec0:	83 ec 08             	sub    $0x8,%esp
  800ec3:	68 00 f0 7f 00       	push   $0x7ff000
  800ec8:	6a 00                	push   $0x0
  800eca:	e8 cf fc ff ff       	call   800b9e <sys_page_unmap>
  800ecf:	83 c4 10             	add    $0x10,%esp
  800ed2:	85 c0                	test   %eax,%eax
  800ed4:	78 29                	js     800eff <pgfault+0xa2>
}
  800ed6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ed9:	c9                   	leave  
  800eda:	c3                   	ret    
		panic("pgfault: sys_page_alloc: %e", r);
  800edb:	50                   	push   %eax
  800edc:	68 ec 17 80 00       	push   $0x8017ec
  800ee1:	6a 27                	push   $0x27
  800ee3:	68 e1 17 80 00       	push   $0x8017e1
  800ee8:	e8 09 02 00 00       	call   8010f6 <_panic>
		panic("pgfault: sys_page_map: %e", r);
  800eed:	50                   	push   %eax
  800eee:	68 08 18 80 00       	push   $0x801808
  800ef3:	6a 2c                	push   $0x2c
  800ef5:	68 e1 17 80 00       	push   $0x8017e1
  800efa:	e8 f7 01 00 00       	call   8010f6 <_panic>
		panic("pgfault: sys_page_unmap: %e", r);
  800eff:	50                   	push   %eax
  800f00:	68 22 18 80 00       	push   $0x801822
  800f05:	6a 2f                	push   $0x2f
  800f07:	68 e1 17 80 00       	push   $0x8017e1
  800f0c:	e8 e5 01 00 00       	call   8010f6 <_panic>

00800f11 <fork_v0>:
 *  	-- Para ello se utiliza la funcion dup_or_share()
 *  	-- Se copian todas las paginas desde 0 hasta UTOP
 */
envid_t
fork_v0(void)
{
  800f11:	55                   	push   %ebp
  800f12:	89 e5                	mov    %esp,%ebp
  800f14:	56                   	push   %esi
  800f15:	53                   	push   %ebx

// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline)) sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2" : "=a"(ret) : "a"(SYS_exofork), "i"(T_SYSCALL));
  800f16:	b8 07 00 00 00       	mov    $0x7,%eax
  800f1b:	cd 30                	int    $0x30
  800f1d:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();
	if (envid < 0)
  800f1f:	85 c0                	test   %eax,%eax
  800f21:	78 23                	js     800f46 <fork_v0+0x35>
	// Parent
	uint32_t pnum = 0;
	uint32_t pnum_end = (UTOP >> PGSHIFT);
	int perm = PTE_P | PTE_U | PTE_W;

	for (pnum = 0; pnum < pnum_end; pnum++) {
  800f23:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid == 0) {
  800f28:	75 3c                	jne    800f66 <fork_v0+0x55>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f2a:	e8 da fb ff ff       	call   800b09 <sys_getenvid>
  800f2f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f34:	69 c0 88 00 00 00    	imul   $0x88,%eax,%eax
  800f3a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f3f:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800f44:	eb 56                	jmp    800f9c <fork_v0+0x8b>
		panic("sys_exofork: %e", envid);
  800f46:	50                   	push   %eax
  800f47:	68 3e 18 80 00       	push   $0x80183e
  800f4c:	68 a2 00 00 00       	push   $0xa2
  800f51:	68 e1 17 80 00       	push   $0x8017e1
  800f56:	e8 9b 01 00 00       	call   8010f6 <_panic>
	for (pnum = 0; pnum < pnum_end; pnum++) {
  800f5b:	83 c3 01             	add    $0x1,%ebx
  800f5e:	81 fb 00 ec 0e 00    	cmp    $0xeec00,%ebx
  800f64:	74 24                	je     800f8a <fork_v0+0x79>
		pde_t pde = uvpd[pnum >> 10];
  800f66:	89 d8                	mov    %ebx,%eax
  800f68:	c1 e8 0a             	shr    $0xa,%eax
  800f6b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
		if (!(pde & PTE_P) || !(pde & PTE_U))
  800f72:	83 e0 05             	and    $0x5,%eax
  800f75:	83 f8 05             	cmp    $0x5,%eax
  800f78:	75 e1                	jne    800f5b <fork_v0+0x4a>
			continue;
		dup_or_share(envid, pnum, perm);
  800f7a:	b9 07 00 00 00       	mov    $0x7,%ecx
  800f7f:	89 da                	mov    %ebx,%edx
  800f81:	89 f0                	mov    %esi,%eax
  800f83:	e8 dc fd ff ff       	call   800d64 <dup_or_share>
  800f88:	eb d1                	jmp    800f5b <fork_v0+0x4a>
	}


	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800f8a:	83 ec 08             	sub    $0x8,%esp
  800f8d:	6a 02                	push   $0x2
  800f8f:	56                   	push   %esi
  800f90:	e8 2c fc ff ff       	call   800bc1 <sys_env_set_status>
  800f95:	83 c4 10             	add    $0x10,%esp
  800f98:	85 c0                	test   %eax,%eax
  800f9a:	78 09                	js     800fa5 <fork_v0+0x94>
		panic("sys_env_set_status: %e", r);

	return envid;
}
  800f9c:	89 f0                	mov    %esi,%eax
  800f9e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fa1:	5b                   	pop    %ebx
  800fa2:	5e                   	pop    %esi
  800fa3:	5d                   	pop    %ebp
  800fa4:	c3                   	ret    
		panic("sys_env_set_status: %e", r);
  800fa5:	50                   	push   %eax
  800fa6:	68 4e 18 80 00       	push   $0x80184e
  800fab:	68 b8 00 00 00       	push   $0xb8
  800fb0:	68 e1 17 80 00       	push   $0x8017e1
  800fb5:	e8 3c 01 00 00       	call   8010f6 <_panic>

00800fba <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fba:	55                   	push   %ebp
  800fbb:	89 e5                	mov    %esp,%ebp
  800fbd:	56                   	push   %esi
  800fbe:	53                   	push   %ebx
	set_pgfault_handler(pgfault);
  800fbf:	83 ec 0c             	sub    $0xc,%esp
  800fc2:	68 5d 0e 80 00       	push   $0x800e5d
  800fc7:	e8 70 01 00 00       	call   80113c <set_pgfault_handler>
  800fcc:	b8 07 00 00 00       	mov    $0x7,%eax
  800fd1:	cd 30                	int    $0x30
  800fd3:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();

	if (envid < 0)
  800fd5:	83 c4 10             	add    $0x10,%esp
  800fd8:	85 c0                	test   %eax,%eax
  800fda:	78 26                	js     801002 <fork+0x48>
	// Parent
	uint32_t pnum = 0;
	uint32_t pnum_end = (UTOP >> PGSHIFT);

	// Handle all pages below UTOP
	for (pnum = 0; pnum < pnum_end; pnum++) {
  800fdc:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid == 0) {
  800fe1:	75 41                	jne    801024 <fork+0x6a>
		thisenv = &envs[ENVX(sys_getenvid())];
  800fe3:	e8 21 fb ff ff       	call   800b09 <sys_getenvid>
  800fe8:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fed:	69 c0 88 00 00 00    	imul   $0x88,%eax,%eax
  800ff3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ff8:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800ffd:	e9 92 00 00 00       	jmp    801094 <fork+0xda>
		panic("sys_exofork: %e", envid);
  801002:	50                   	push   %eax
  801003:	68 3e 18 80 00       	push   $0x80183e
  801008:	68 d5 00 00 00       	push   $0xd5
  80100d:	68 e1 17 80 00       	push   $0x8017e1
  801012:	e8 df 00 00 00       	call   8010f6 <_panic>
	for (pnum = 0; pnum < pnum_end; pnum++) {
  801017:	83 c3 01             	add    $0x1,%ebx
  80101a:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  801020:	77 30                	ja     801052 <fork+0x98>
		if (pnum == ((UXSTACKTOP >> PGSHIFT) - 1))
  801022:	74 f3                	je     801017 <fork+0x5d>
			continue;

		pde_t pde = uvpd[pnum >> 10];
  801024:	89 d8                	mov    %ebx,%eax
  801026:	c1 e8 0a             	shr    $0xa,%eax
  801029:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
		if (!(pde & PTE_P) || !(pde & PTE_U))
  801030:	83 e0 05             	and    $0x5,%eax
  801033:	83 f8 05             	cmp    $0x5,%eax
  801036:	75 df                	jne    801017 <fork+0x5d>
			continue;

		pte_t pte = uvpt[pnum];
  801038:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
		if (!(pte & PTE_P) || !(pte & PTE_U))
  80103f:	83 e0 05             	and    $0x5,%eax
  801042:	83 f8 05             	cmp    $0x5,%eax
  801045:	75 d0                	jne    801017 <fork+0x5d>
			continue;
		duppage(envid, pnum);
  801047:	89 da                	mov    %ebx,%edx
  801049:	89 f0                	mov    %esi,%eax
  80104b:	e8 44 fc ff ff       	call   800c94 <duppage>
  801050:	eb c5                	jmp    801017 <fork+0x5d>
	}

	uint32_t exstk = (UXSTACKTOP - PGSIZE);
	int r = sys_page_alloc(envid, (void *) exstk, PTE_U | PTE_P | PTE_W);
  801052:	83 ec 04             	sub    $0x4,%esp
  801055:	6a 07                	push   $0x7
  801057:	68 00 f0 bf ee       	push   $0xeebff000
  80105c:	56                   	push   %esi
  80105d:	e8 f2 fa ff ff       	call   800b54 <sys_page_alloc>
	if (r < 0)
  801062:	83 c4 10             	add    $0x10,%esp
  801065:	85 c0                	test   %eax,%eax
  801067:	78 34                	js     80109d <fork+0xe3>
		panic("fork: sys_page_alloc of exception stk: %e", r);
	r = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801069:	a1 04 20 80 00       	mov    0x802004,%eax
  80106e:	8b 40 70             	mov    0x70(%eax),%eax
  801071:	83 ec 08             	sub    $0x8,%esp
  801074:	50                   	push   %eax
  801075:	56                   	push   %esi
  801076:	e8 69 fb ff ff       	call   800be4 <sys_env_set_pgfault_upcall>
	if (r < 0)
  80107b:	83 c4 10             	add    $0x10,%esp
  80107e:	85 c0                	test   %eax,%eax
  801080:	78 30                	js     8010b2 <fork+0xf8>
		panic("fork: sys_env_set_pgfault_upcall on childern: %e", r);

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  801082:	83 ec 08             	sub    $0x8,%esp
  801085:	6a 02                	push   $0x2
  801087:	56                   	push   %esi
  801088:	e8 34 fb ff ff       	call   800bc1 <sys_env_set_status>
  80108d:	83 c4 10             	add    $0x10,%esp
  801090:	85 c0                	test   %eax,%eax
  801092:	78 33                	js     8010c7 <fork+0x10d>
		panic("sys_env_set_status: %e", r);

	return envid;
}
  801094:	89 f0                	mov    %esi,%eax
  801096:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801099:	5b                   	pop    %ebx
  80109a:	5e                   	pop    %esi
  80109b:	5d                   	pop    %ebp
  80109c:	c3                   	ret    
		panic("fork: sys_page_alloc of exception stk: %e", r);
  80109d:	50                   	push   %eax
  80109e:	68 84 17 80 00       	push   $0x801784
  8010a3:	68 f2 00 00 00       	push   $0xf2
  8010a8:	68 e1 17 80 00       	push   $0x8017e1
  8010ad:	e8 44 00 00 00       	call   8010f6 <_panic>
		panic("fork: sys_env_set_pgfault_upcall on childern: %e", r);
  8010b2:	50                   	push   %eax
  8010b3:	68 b0 17 80 00       	push   $0x8017b0
  8010b8:	68 f5 00 00 00       	push   $0xf5
  8010bd:	68 e1 17 80 00       	push   $0x8017e1
  8010c2:	e8 2f 00 00 00       	call   8010f6 <_panic>
		panic("sys_env_set_status: %e", r);
  8010c7:	50                   	push   %eax
  8010c8:	68 4e 18 80 00       	push   $0x80184e
  8010cd:	68 f8 00 00 00       	push   $0xf8
  8010d2:	68 e1 17 80 00       	push   $0x8017e1
  8010d7:	e8 1a 00 00 00       	call   8010f6 <_panic>

008010dc <sfork>:

// Challenge!
int
sfork(void)
{
  8010dc:	55                   	push   %ebp
  8010dd:	89 e5                	mov    %esp,%ebp
  8010df:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010e2:	68 65 18 80 00       	push   $0x801865
  8010e7:	68 01 01 00 00       	push   $0x101
  8010ec:	68 e1 17 80 00       	push   $0x8017e1
  8010f1:	e8 00 00 00 00       	call   8010f6 <_panic>

008010f6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8010f6:	55                   	push   %ebp
  8010f7:	89 e5                	mov    %esp,%ebp
  8010f9:	56                   	push   %esi
  8010fa:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8010fb:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8010fe:	8b 35 00 20 80 00    	mov    0x802000,%esi
  801104:	e8 00 fa ff ff       	call   800b09 <sys_getenvid>
  801109:	83 ec 0c             	sub    $0xc,%esp
  80110c:	ff 75 0c             	push   0xc(%ebp)
  80110f:	ff 75 08             	push   0x8(%ebp)
  801112:	56                   	push   %esi
  801113:	50                   	push   %eax
  801114:	68 7c 18 80 00       	push   $0x80187c
  801119:	e8 b9 f0 ff ff       	call   8001d7 <cprintf>
	        sys_getenvid(),
	        binaryname,
	        file,
	        line);
	vcprintf(fmt, ap);
  80111e:	83 c4 18             	add    $0x18,%esp
  801121:	53                   	push   %ebx
  801122:	ff 75 10             	push   0x10(%ebp)
  801125:	e8 5c f0 ff ff       	call   800186 <vcprintf>
	cprintf("\n");
  80112a:	c7 04 24 0f 14 80 00 	movl   $0x80140f,(%esp)
  801131:	e8 a1 f0 ff ff       	call   8001d7 <cprintf>
  801136:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801139:	cc                   	int3   
  80113a:	eb fd                	jmp    801139 <_panic+0x43>

0080113c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80113c:	55                   	push   %ebp
  80113d:	89 e5                	mov    %esp,%ebp
  80113f:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801142:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  801149:	74 0a                	je     801155 <set_pgfault_handler+0x19>
		if (r < 0)
			return;
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80114b:	8b 45 08             	mov    0x8(%ebp),%eax
  80114e:	a3 08 20 80 00       	mov    %eax,0x802008
}
  801153:	c9                   	leave  
  801154:	c3                   	ret    
		r = sys_page_alloc(0, (void *) exstk, perm);
  801155:	83 ec 04             	sub    $0x4,%esp
  801158:	6a 07                	push   $0x7
  80115a:	68 00 f0 bf ee       	push   $0xeebff000
  80115f:	6a 00                	push   $0x0
  801161:	e8 ee f9 ff ff       	call   800b54 <sys_page_alloc>
		if (r < 0)
  801166:	83 c4 10             	add    $0x10,%esp
  801169:	85 c0                	test   %eax,%eax
  80116b:	78 e6                	js     801153 <set_pgfault_handler+0x17>
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  80116d:	83 ec 08             	sub    $0x8,%esp
  801170:	68 85 11 80 00       	push   $0x801185
  801175:	6a 00                	push   $0x0
  801177:	e8 68 fa ff ff       	call   800be4 <sys_env_set_pgfault_upcall>
		if (r < 0)
  80117c:	83 c4 10             	add    $0x10,%esp
  80117f:	85 c0                	test   %eax,%eax
  801181:	79 c8                	jns    80114b <set_pgfault_handler+0xf>
  801183:	eb ce                	jmp    801153 <set_pgfault_handler+0x17>

00801185 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801185:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801186:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  80118b:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80118d:	83 c4 04             	add    $0x4,%esp
	// Throughout the remaining code, think carefully about what
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	movl 40(%esp), %eax	// trap-time %epi -> %eax 
  801190:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %ebx	// trap-time %esp -> %ebx
  801194:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4, %ebx
  801198:	83 eb 04             	sub    $0x4,%ebx
	movl %eax, 0(%ebx)	// push %eip in trap-time stack
  80119b:	89 03                	mov    %eax,(%ebx)

	movl %ebx, 48(%esp)
  80119d:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	popl %eax
  8011a1:	58                   	pop    %eax
	popl %eax
  8011a2:	58                   	pop    %eax
	popal
  8011a3:	61                   	popa   
	

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	addl $4, %esp
  8011a4:	83 c4 04             	add    $0x4,%esp
	popfl
  8011a7:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	popl %esp
  8011a8:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	ret
  8011a9:	c3                   	ret    
  8011aa:	66 90                	xchg   %ax,%ax
  8011ac:	66 90                	xchg   %ax,%ax
  8011ae:	66 90                	xchg   %ax,%ax

008011b0 <__udivdi3>:
  8011b0:	f3 0f 1e fb          	endbr32 
  8011b4:	55                   	push   %ebp
  8011b5:	57                   	push   %edi
  8011b6:	56                   	push   %esi
  8011b7:	53                   	push   %ebx
  8011b8:	83 ec 1c             	sub    $0x1c,%esp
  8011bb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8011bf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8011c3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8011c7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8011cb:	85 c0                	test   %eax,%eax
  8011cd:	75 19                	jne    8011e8 <__udivdi3+0x38>
  8011cf:	39 f3                	cmp    %esi,%ebx
  8011d1:	76 4d                	jbe    801220 <__udivdi3+0x70>
  8011d3:	31 ff                	xor    %edi,%edi
  8011d5:	89 e8                	mov    %ebp,%eax
  8011d7:	89 f2                	mov    %esi,%edx
  8011d9:	f7 f3                	div    %ebx
  8011db:	89 fa                	mov    %edi,%edx
  8011dd:	83 c4 1c             	add    $0x1c,%esp
  8011e0:	5b                   	pop    %ebx
  8011e1:	5e                   	pop    %esi
  8011e2:	5f                   	pop    %edi
  8011e3:	5d                   	pop    %ebp
  8011e4:	c3                   	ret    
  8011e5:	8d 76 00             	lea    0x0(%esi),%esi
  8011e8:	39 f0                	cmp    %esi,%eax
  8011ea:	76 14                	jbe    801200 <__udivdi3+0x50>
  8011ec:	31 ff                	xor    %edi,%edi
  8011ee:	31 c0                	xor    %eax,%eax
  8011f0:	89 fa                	mov    %edi,%edx
  8011f2:	83 c4 1c             	add    $0x1c,%esp
  8011f5:	5b                   	pop    %ebx
  8011f6:	5e                   	pop    %esi
  8011f7:	5f                   	pop    %edi
  8011f8:	5d                   	pop    %ebp
  8011f9:	c3                   	ret    
  8011fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801200:	0f bd f8             	bsr    %eax,%edi
  801203:	83 f7 1f             	xor    $0x1f,%edi
  801206:	75 48                	jne    801250 <__udivdi3+0xa0>
  801208:	39 f0                	cmp    %esi,%eax
  80120a:	72 06                	jb     801212 <__udivdi3+0x62>
  80120c:	31 c0                	xor    %eax,%eax
  80120e:	39 eb                	cmp    %ebp,%ebx
  801210:	77 de                	ja     8011f0 <__udivdi3+0x40>
  801212:	b8 01 00 00 00       	mov    $0x1,%eax
  801217:	eb d7                	jmp    8011f0 <__udivdi3+0x40>
  801219:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801220:	89 d9                	mov    %ebx,%ecx
  801222:	85 db                	test   %ebx,%ebx
  801224:	75 0b                	jne    801231 <__udivdi3+0x81>
  801226:	b8 01 00 00 00       	mov    $0x1,%eax
  80122b:	31 d2                	xor    %edx,%edx
  80122d:	f7 f3                	div    %ebx
  80122f:	89 c1                	mov    %eax,%ecx
  801231:	31 d2                	xor    %edx,%edx
  801233:	89 f0                	mov    %esi,%eax
  801235:	f7 f1                	div    %ecx
  801237:	89 c6                	mov    %eax,%esi
  801239:	89 e8                	mov    %ebp,%eax
  80123b:	89 f7                	mov    %esi,%edi
  80123d:	f7 f1                	div    %ecx
  80123f:	89 fa                	mov    %edi,%edx
  801241:	83 c4 1c             	add    $0x1c,%esp
  801244:	5b                   	pop    %ebx
  801245:	5e                   	pop    %esi
  801246:	5f                   	pop    %edi
  801247:	5d                   	pop    %ebp
  801248:	c3                   	ret    
  801249:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801250:	89 f9                	mov    %edi,%ecx
  801252:	ba 20 00 00 00       	mov    $0x20,%edx
  801257:	29 fa                	sub    %edi,%edx
  801259:	d3 e0                	shl    %cl,%eax
  80125b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80125f:	89 d1                	mov    %edx,%ecx
  801261:	89 d8                	mov    %ebx,%eax
  801263:	d3 e8                	shr    %cl,%eax
  801265:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801269:	09 c1                	or     %eax,%ecx
  80126b:	89 f0                	mov    %esi,%eax
  80126d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801271:	89 f9                	mov    %edi,%ecx
  801273:	d3 e3                	shl    %cl,%ebx
  801275:	89 d1                	mov    %edx,%ecx
  801277:	d3 e8                	shr    %cl,%eax
  801279:	89 f9                	mov    %edi,%ecx
  80127b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80127f:	89 eb                	mov    %ebp,%ebx
  801281:	d3 e6                	shl    %cl,%esi
  801283:	89 d1                	mov    %edx,%ecx
  801285:	d3 eb                	shr    %cl,%ebx
  801287:	09 f3                	or     %esi,%ebx
  801289:	89 c6                	mov    %eax,%esi
  80128b:	89 f2                	mov    %esi,%edx
  80128d:	89 d8                	mov    %ebx,%eax
  80128f:	f7 74 24 08          	divl   0x8(%esp)
  801293:	89 d6                	mov    %edx,%esi
  801295:	89 c3                	mov    %eax,%ebx
  801297:	f7 64 24 0c          	mull   0xc(%esp)
  80129b:	39 d6                	cmp    %edx,%esi
  80129d:	72 19                	jb     8012b8 <__udivdi3+0x108>
  80129f:	89 f9                	mov    %edi,%ecx
  8012a1:	d3 e5                	shl    %cl,%ebp
  8012a3:	39 c5                	cmp    %eax,%ebp
  8012a5:	73 04                	jae    8012ab <__udivdi3+0xfb>
  8012a7:	39 d6                	cmp    %edx,%esi
  8012a9:	74 0d                	je     8012b8 <__udivdi3+0x108>
  8012ab:	89 d8                	mov    %ebx,%eax
  8012ad:	31 ff                	xor    %edi,%edi
  8012af:	e9 3c ff ff ff       	jmp    8011f0 <__udivdi3+0x40>
  8012b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012b8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8012bb:	31 ff                	xor    %edi,%edi
  8012bd:	e9 2e ff ff ff       	jmp    8011f0 <__udivdi3+0x40>
  8012c2:	66 90                	xchg   %ax,%ax
  8012c4:	66 90                	xchg   %ax,%ax
  8012c6:	66 90                	xchg   %ax,%ax
  8012c8:	66 90                	xchg   %ax,%ax
  8012ca:	66 90                	xchg   %ax,%ax
  8012cc:	66 90                	xchg   %ax,%ax
  8012ce:	66 90                	xchg   %ax,%ax

008012d0 <__umoddi3>:
  8012d0:	f3 0f 1e fb          	endbr32 
  8012d4:	55                   	push   %ebp
  8012d5:	57                   	push   %edi
  8012d6:	56                   	push   %esi
  8012d7:	53                   	push   %ebx
  8012d8:	83 ec 1c             	sub    $0x1c,%esp
  8012db:	8b 74 24 30          	mov    0x30(%esp),%esi
  8012df:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8012e3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  8012e7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  8012eb:	89 f0                	mov    %esi,%eax
  8012ed:	89 da                	mov    %ebx,%edx
  8012ef:	85 ff                	test   %edi,%edi
  8012f1:	75 15                	jne    801308 <__umoddi3+0x38>
  8012f3:	39 dd                	cmp    %ebx,%ebp
  8012f5:	76 39                	jbe    801330 <__umoddi3+0x60>
  8012f7:	f7 f5                	div    %ebp
  8012f9:	89 d0                	mov    %edx,%eax
  8012fb:	31 d2                	xor    %edx,%edx
  8012fd:	83 c4 1c             	add    $0x1c,%esp
  801300:	5b                   	pop    %ebx
  801301:	5e                   	pop    %esi
  801302:	5f                   	pop    %edi
  801303:	5d                   	pop    %ebp
  801304:	c3                   	ret    
  801305:	8d 76 00             	lea    0x0(%esi),%esi
  801308:	39 df                	cmp    %ebx,%edi
  80130a:	77 f1                	ja     8012fd <__umoddi3+0x2d>
  80130c:	0f bd cf             	bsr    %edi,%ecx
  80130f:	83 f1 1f             	xor    $0x1f,%ecx
  801312:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801316:	75 40                	jne    801358 <__umoddi3+0x88>
  801318:	39 df                	cmp    %ebx,%edi
  80131a:	72 04                	jb     801320 <__umoddi3+0x50>
  80131c:	39 f5                	cmp    %esi,%ebp
  80131e:	77 dd                	ja     8012fd <__umoddi3+0x2d>
  801320:	89 da                	mov    %ebx,%edx
  801322:	89 f0                	mov    %esi,%eax
  801324:	29 e8                	sub    %ebp,%eax
  801326:	19 fa                	sbb    %edi,%edx
  801328:	eb d3                	jmp    8012fd <__umoddi3+0x2d>
  80132a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801330:	89 e9                	mov    %ebp,%ecx
  801332:	85 ed                	test   %ebp,%ebp
  801334:	75 0b                	jne    801341 <__umoddi3+0x71>
  801336:	b8 01 00 00 00       	mov    $0x1,%eax
  80133b:	31 d2                	xor    %edx,%edx
  80133d:	f7 f5                	div    %ebp
  80133f:	89 c1                	mov    %eax,%ecx
  801341:	89 d8                	mov    %ebx,%eax
  801343:	31 d2                	xor    %edx,%edx
  801345:	f7 f1                	div    %ecx
  801347:	89 f0                	mov    %esi,%eax
  801349:	f7 f1                	div    %ecx
  80134b:	89 d0                	mov    %edx,%eax
  80134d:	31 d2                	xor    %edx,%edx
  80134f:	eb ac                	jmp    8012fd <__umoddi3+0x2d>
  801351:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801358:	8b 44 24 04          	mov    0x4(%esp),%eax
  80135c:	ba 20 00 00 00       	mov    $0x20,%edx
  801361:	29 c2                	sub    %eax,%edx
  801363:	89 c1                	mov    %eax,%ecx
  801365:	89 e8                	mov    %ebp,%eax
  801367:	d3 e7                	shl    %cl,%edi
  801369:	89 d1                	mov    %edx,%ecx
  80136b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80136f:	d3 e8                	shr    %cl,%eax
  801371:	89 c1                	mov    %eax,%ecx
  801373:	8b 44 24 04          	mov    0x4(%esp),%eax
  801377:	09 f9                	or     %edi,%ecx
  801379:	89 df                	mov    %ebx,%edi
  80137b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80137f:	89 c1                	mov    %eax,%ecx
  801381:	d3 e5                	shl    %cl,%ebp
  801383:	89 d1                	mov    %edx,%ecx
  801385:	d3 ef                	shr    %cl,%edi
  801387:	89 c1                	mov    %eax,%ecx
  801389:	89 f0                	mov    %esi,%eax
  80138b:	d3 e3                	shl    %cl,%ebx
  80138d:	89 d1                	mov    %edx,%ecx
  80138f:	89 fa                	mov    %edi,%edx
  801391:	d3 e8                	shr    %cl,%eax
  801393:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801398:	09 d8                	or     %ebx,%eax
  80139a:	f7 74 24 08          	divl   0x8(%esp)
  80139e:	89 d3                	mov    %edx,%ebx
  8013a0:	d3 e6                	shl    %cl,%esi
  8013a2:	f7 e5                	mul    %ebp
  8013a4:	89 c7                	mov    %eax,%edi
  8013a6:	89 d1                	mov    %edx,%ecx
  8013a8:	39 d3                	cmp    %edx,%ebx
  8013aa:	72 06                	jb     8013b2 <__umoddi3+0xe2>
  8013ac:	75 0e                	jne    8013bc <__umoddi3+0xec>
  8013ae:	39 c6                	cmp    %eax,%esi
  8013b0:	73 0a                	jae    8013bc <__umoddi3+0xec>
  8013b2:	29 e8                	sub    %ebp,%eax
  8013b4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8013b8:	89 d1                	mov    %edx,%ecx
  8013ba:	89 c7                	mov    %eax,%edi
  8013bc:	89 f5                	mov    %esi,%ebp
  8013be:	8b 74 24 04          	mov    0x4(%esp),%esi
  8013c2:	29 fd                	sub    %edi,%ebp
  8013c4:	19 cb                	sbb    %ecx,%ebx
  8013c6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8013cb:	89 d8                	mov    %ebx,%eax
  8013cd:	d3 e0                	shl    %cl,%eax
  8013cf:	89 f1                	mov    %esi,%ecx
  8013d1:	d3 ed                	shr    %cl,%ebp
  8013d3:	d3 eb                	shr    %cl,%ebx
  8013d5:	09 e8                	or     %ebp,%eax
  8013d7:	89 da                	mov    %ebx,%edx
  8013d9:	83 c4 1c             	add    $0x1c,%esp
  8013dc:	5b                   	pop    %ebx
  8013dd:	5e                   	pop    %esi
  8013de:	5f                   	pop    %edi
  8013df:	5d                   	pop    %ebp
  8013e0:	c3                   	ret    
