
obj/user/priority_decrease:     formato del fichero elf32-i386


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
  80002c:	e8 4e 00 00 00       	call   80007f <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#define PRIORITY 80

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 10             	sub    $0x10,%esp
	sys_set_priority(PRIORITY);
  80003a:	6a 50                	push   $0x50
  80003c:	e8 cd 0b 00 00       	call   800c0e <sys_set_priority>
  800041:	83 c4 10             	add    $0x10,%esp
  800044:	bb 14 00 00 00       	mov    $0x14,%ebx

	for (int i = 0; i < 20; i++) {
		cprintf("La prioridad es: %d\n", sys_get_priority());
  800049:	e8 9c 0b 00 00       	call   800bea <sys_get_priority>
  80004e:	83 ec 08             	sub    $0x8,%esp
  800051:	50                   	push   %eax
  800052:	68 c0 0e 80 00       	push   $0x800ec0
  800057:	e8 17 01 00 00       	call   800173 <cprintf>
		sys_yield();
  80005c:	e8 68 0a 00 00       	call   800ac9 <sys_yield>
	for (int i = 0; i < 20; i++) {
  800061:	83 c4 10             	add    $0x10,%esp
  800064:	83 eb 01             	sub    $0x1,%ebx
  800067:	75 e0                	jne    800049 <umain+0x16>
	}
	sys_env_destroy(sys_getenvid());
  800069:	e8 37 0a 00 00       	call   800aa5 <sys_getenvid>
  80006e:	83 ec 0c             	sub    $0xc,%esp
  800071:	50                   	push   %eax
  800072:	e8 0c 0a 00 00       	call   800a83 <sys_env_destroy>
  800077:	83 c4 10             	add    $0x10,%esp
  80007a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80007d:	c9                   	leave  
  80007e:	c3                   	ret    

0080007f <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80007f:	55                   	push   %ebp
  800080:	89 e5                	mov    %esp,%ebp
  800082:	56                   	push   %esi
  800083:	53                   	push   %ebx
  800084:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800087:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	envid_t id = sys_getenvid();
  80008a:	e8 16 0a 00 00       	call   800aa5 <sys_getenvid>
	if (id >= 0)
  80008f:	85 c0                	test   %eax,%eax
  800091:	78 15                	js     8000a8 <libmain+0x29>
		thisenv = &envs[ENVX(id)];
  800093:	25 ff 03 00 00       	and    $0x3ff,%eax
  800098:	69 c0 88 00 00 00    	imul   $0x88,%eax,%eax
  80009e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000a3:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a8:	85 db                	test   %ebx,%ebx
  8000aa:	7e 07                	jle    8000b3 <libmain+0x34>
		binaryname = argv[0];
  8000ac:	8b 06                	mov    (%esi),%eax
  8000ae:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000b3:	83 ec 08             	sub    $0x8,%esp
  8000b6:	56                   	push   %esi
  8000b7:	53                   	push   %ebx
  8000b8:	e8 76 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000bd:	e8 0a 00 00 00       	call   8000cc <exit>
}
  8000c2:	83 c4 10             	add    $0x10,%esp
  8000c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c8:	5b                   	pop    %ebx
  8000c9:	5e                   	pop    %esi
  8000ca:	5d                   	pop    %ebp
  8000cb:	c3                   	ret    

008000cc <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000d2:	6a 00                	push   $0x0
  8000d4:	e8 aa 09 00 00       	call   800a83 <sys_env_destroy>
}
  8000d9:	83 c4 10             	add    $0x10,%esp
  8000dc:	c9                   	leave  
  8000dd:	c3                   	ret    

008000de <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000de:	55                   	push   %ebp
  8000df:	89 e5                	mov    %esp,%ebp
  8000e1:	53                   	push   %ebx
  8000e2:	83 ec 04             	sub    $0x4,%esp
  8000e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000e8:	8b 13                	mov    (%ebx),%edx
  8000ea:	8d 42 01             	lea    0x1(%edx),%eax
  8000ed:	89 03                	mov    %eax,(%ebx)
  8000ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000f2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256 - 1) {
  8000f6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000fb:	74 09                	je     800106 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000fd:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800101:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800104:	c9                   	leave  
  800105:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800106:	83 ec 08             	sub    $0x8,%esp
  800109:	68 ff 00 00 00       	push   $0xff
  80010e:	8d 43 08             	lea    0x8(%ebx),%eax
  800111:	50                   	push   %eax
  800112:	e8 22 09 00 00       	call   800a39 <sys_cputs>
		b->idx = 0;
  800117:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80011d:	83 c4 10             	add    $0x10,%esp
  800120:	eb db                	jmp    8000fd <putch+0x1f>

00800122 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800122:	55                   	push   %ebp
  800123:	89 e5                	mov    %esp,%ebp
  800125:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80012b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800132:	00 00 00 
	b.cnt = 0;
  800135:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80013c:	00 00 00 
	vprintfmt((void *) putch, &b, fmt, ap);
  80013f:	ff 75 0c             	push   0xc(%ebp)
  800142:	ff 75 08             	push   0x8(%ebp)
  800145:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80014b:	50                   	push   %eax
  80014c:	68 de 00 80 00       	push   $0x8000de
  800151:	e8 74 01 00 00       	call   8002ca <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800156:	83 c4 08             	add    $0x8,%esp
  800159:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  80015f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800165:	50                   	push   %eax
  800166:	e8 ce 08 00 00       	call   800a39 <sys_cputs>

	return b.cnt;
}
  80016b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800171:	c9                   	leave  
  800172:	c3                   	ret    

00800173 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800173:	55                   	push   %ebp
  800174:	89 e5                	mov    %esp,%ebp
  800176:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800179:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80017c:	50                   	push   %eax
  80017d:	ff 75 08             	push   0x8(%ebp)
  800180:	e8 9d ff ff ff       	call   800122 <vcprintf>
	va_end(ap);

	return cnt;
}
  800185:	c9                   	leave  
  800186:	c3                   	ret    

00800187 <printnum>:
         void *putdat,
         unsigned long long num,
         unsigned base,
         int width,
         int padc)
{
  800187:	55                   	push   %ebp
  800188:	89 e5                	mov    %esp,%ebp
  80018a:	57                   	push   %edi
  80018b:	56                   	push   %esi
  80018c:	53                   	push   %ebx
  80018d:	83 ec 1c             	sub    $0x1c,%esp
  800190:	89 c7                	mov    %eax,%edi
  800192:	89 d6                	mov    %edx,%esi
  800194:	8b 45 08             	mov    0x8(%ebp),%eax
  800197:	8b 55 0c             	mov    0xc(%ebp),%edx
  80019a:	89 d1                	mov    %edx,%ecx
  80019c:	89 c2                	mov    %eax,%edx
  80019e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001a1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001a4:	8b 45 10             	mov    0x10(%ebp),%eax
  8001a7:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001ad:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001b4:	39 c2                	cmp    %eax,%edx
  8001b6:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001b9:	72 3e                	jb     8001f9 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001bb:	83 ec 0c             	sub    $0xc,%esp
  8001be:	ff 75 18             	push   0x18(%ebp)
  8001c1:	83 eb 01             	sub    $0x1,%ebx
  8001c4:	53                   	push   %ebx
  8001c5:	50                   	push   %eax
  8001c6:	83 ec 08             	sub    $0x8,%esp
  8001c9:	ff 75 e4             	push   -0x1c(%ebp)
  8001cc:	ff 75 e0             	push   -0x20(%ebp)
  8001cf:	ff 75 dc             	push   -0x24(%ebp)
  8001d2:	ff 75 d8             	push   -0x28(%ebp)
  8001d5:	e8 a6 0a 00 00       	call   800c80 <__udivdi3>
  8001da:	83 c4 18             	add    $0x18,%esp
  8001dd:	52                   	push   %edx
  8001de:	50                   	push   %eax
  8001df:	89 f2                	mov    %esi,%edx
  8001e1:	89 f8                	mov    %edi,%eax
  8001e3:	e8 9f ff ff ff       	call   800187 <printnum>
  8001e8:	83 c4 20             	add    $0x20,%esp
  8001eb:	eb 13                	jmp    800200 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001ed:	83 ec 08             	sub    $0x8,%esp
  8001f0:	56                   	push   %esi
  8001f1:	ff 75 18             	push   0x18(%ebp)
  8001f4:	ff d7                	call   *%edi
  8001f6:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001f9:	83 eb 01             	sub    $0x1,%ebx
  8001fc:	85 db                	test   %ebx,%ebx
  8001fe:	7f ed                	jg     8001ed <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800200:	83 ec 08             	sub    $0x8,%esp
  800203:	56                   	push   %esi
  800204:	83 ec 04             	sub    $0x4,%esp
  800207:	ff 75 e4             	push   -0x1c(%ebp)
  80020a:	ff 75 e0             	push   -0x20(%ebp)
  80020d:	ff 75 dc             	push   -0x24(%ebp)
  800210:	ff 75 d8             	push   -0x28(%ebp)
  800213:	e8 88 0b 00 00       	call   800da0 <__umoddi3>
  800218:	83 c4 14             	add    $0x14,%esp
  80021b:	0f be 80 df 0e 80 00 	movsbl 0x800edf(%eax),%eax
  800222:	50                   	push   %eax
  800223:	ff d7                	call   *%edi
}
  800225:	83 c4 10             	add    $0x10,%esp
  800228:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80022b:	5b                   	pop    %ebx
  80022c:	5e                   	pop    %esi
  80022d:	5f                   	pop    %edi
  80022e:	5d                   	pop    %ebp
  80022f:	c3                   	ret    

00800230 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800230:	83 fa 01             	cmp    $0x1,%edx
  800233:	7f 13                	jg     800248 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800235:	85 d2                	test   %edx,%edx
  800237:	74 1c                	je     800255 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  800239:	8b 10                	mov    (%eax),%edx
  80023b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80023e:	89 08                	mov    %ecx,(%eax)
  800240:	8b 02                	mov    (%edx),%eax
  800242:	ba 00 00 00 00       	mov    $0x0,%edx
  800247:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  800248:	8b 10                	mov    (%eax),%edx
  80024a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80024d:	89 08                	mov    %ecx,(%eax)
  80024f:	8b 02                	mov    (%edx),%eax
  800251:	8b 52 04             	mov    0x4(%edx),%edx
  800254:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  800255:	8b 10                	mov    (%eax),%edx
  800257:	8d 4a 04             	lea    0x4(%edx),%ecx
  80025a:	89 08                	mov    %ecx,(%eax)
  80025c:	8b 02                	mov    (%edx),%eax
  80025e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800263:	c3                   	ret    

00800264 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800264:	83 fa 01             	cmp    $0x1,%edx
  800267:	7f 0f                	jg     800278 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  800269:	85 d2                	test   %edx,%edx
  80026b:	74 18                	je     800285 <getint+0x21>
		return va_arg(*ap, long);
  80026d:	8b 10                	mov    (%eax),%edx
  80026f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800272:	89 08                	mov    %ecx,(%eax)
  800274:	8b 02                	mov    (%edx),%eax
  800276:	99                   	cltd   
  800277:	c3                   	ret    
		return va_arg(*ap, long long);
  800278:	8b 10                	mov    (%eax),%edx
  80027a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80027d:	89 08                	mov    %ecx,(%eax)
  80027f:	8b 02                	mov    (%edx),%eax
  800281:	8b 52 04             	mov    0x4(%edx),%edx
  800284:	c3                   	ret    
	else
		return va_arg(*ap, int);
  800285:	8b 10                	mov    (%eax),%edx
  800287:	8d 4a 04             	lea    0x4(%edx),%ecx
  80028a:	89 08                	mov    %ecx,(%eax)
  80028c:	8b 02                	mov    (%edx),%eax
  80028e:	99                   	cltd   
}
  80028f:	c3                   	ret    

00800290 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
  800293:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800296:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80029a:	8b 10                	mov    (%eax),%edx
  80029c:	3b 50 04             	cmp    0x4(%eax),%edx
  80029f:	73 0a                	jae    8002ab <sprintputch+0x1b>
		*b->buf++ = ch;
  8002a1:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002a4:	89 08                	mov    %ecx,(%eax)
  8002a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a9:	88 02                	mov    %al,(%edx)
}
  8002ab:	5d                   	pop    %ebp
  8002ac:	c3                   	ret    

008002ad <printfmt>:
{
  8002ad:	55                   	push   %ebp
  8002ae:	89 e5                	mov    %esp,%ebp
  8002b0:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002b3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002b6:	50                   	push   %eax
  8002b7:	ff 75 10             	push   0x10(%ebp)
  8002ba:	ff 75 0c             	push   0xc(%ebp)
  8002bd:	ff 75 08             	push   0x8(%ebp)
  8002c0:	e8 05 00 00 00       	call   8002ca <vprintfmt>
}
  8002c5:	83 c4 10             	add    $0x10,%esp
  8002c8:	c9                   	leave  
  8002c9:	c3                   	ret    

008002ca <vprintfmt>:
{
  8002ca:	55                   	push   %ebp
  8002cb:	89 e5                	mov    %esp,%ebp
  8002cd:	57                   	push   %edi
  8002ce:	56                   	push   %esi
  8002cf:	53                   	push   %ebx
  8002d0:	83 ec 2c             	sub    $0x2c,%esp
  8002d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002d6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8002d9:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002dc:	eb 0a                	jmp    8002e8 <vprintfmt+0x1e>
			putch(ch, putdat);
  8002de:	83 ec 08             	sub    $0x8,%esp
  8002e1:	56                   	push   %esi
  8002e2:	50                   	push   %eax
  8002e3:	ff d3                	call   *%ebx
  8002e5:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002e8:	83 c7 01             	add    $0x1,%edi
  8002eb:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002ef:	83 f8 25             	cmp    $0x25,%eax
  8002f2:	74 0c                	je     800300 <vprintfmt+0x36>
			if (ch == '\0')
  8002f4:	85 c0                	test   %eax,%eax
  8002f6:	75 e6                	jne    8002de <vprintfmt+0x14>
}
  8002f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002fb:	5b                   	pop    %ebx
  8002fc:	5e                   	pop    %esi
  8002fd:	5f                   	pop    %edi
  8002fe:	5d                   	pop    %ebp
  8002ff:	c3                   	ret    
		padc = ' ';
  800300:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
		altflag = 0;
  800304:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80030b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800312:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800319:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80031e:	8d 47 01             	lea    0x1(%edi),%eax
  800321:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800324:	0f b6 17             	movzbl (%edi),%edx
  800327:	8d 42 dd             	lea    -0x23(%edx),%eax
  80032a:	3c 55                	cmp    $0x55,%al
  80032c:	0f 87 b7 02 00 00    	ja     8005e9 <vprintfmt+0x31f>
  800332:	0f b6 c0             	movzbl %al,%eax
  800335:	ff 24 85 a0 0f 80 00 	jmp    *0x800fa0(,%eax,4)
  80033c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80033f:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800343:	eb d9                	jmp    80031e <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800345:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800348:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  80034c:	eb d0                	jmp    80031e <vprintfmt+0x54>
  80034e:	0f b6 d2             	movzbl %dl,%edx
  800351:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0;; ++fmt) {
  800354:	b8 00 00 00 00       	mov    $0x0,%eax
  800359:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80035c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80035f:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800363:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800366:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800369:	83 f9 09             	cmp    $0x9,%ecx
  80036c:	77 52                	ja     8003c0 <vprintfmt+0xf6>
			for (precision = 0;; ++fmt) {
  80036e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800371:	eb e9                	jmp    80035c <vprintfmt+0x92>
			precision = va_arg(ap, int);
  800373:	8b 45 14             	mov    0x14(%ebp),%eax
  800376:	8d 50 04             	lea    0x4(%eax),%edx
  800379:	89 55 14             	mov    %edx,0x14(%ebp)
  80037c:	8b 00                	mov    (%eax),%eax
  80037e:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800381:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800384:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800388:	79 94                	jns    80031e <vprintfmt+0x54>
				width = precision, precision = -1;
  80038a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80038d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800390:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800397:	eb 85                	jmp    80031e <vprintfmt+0x54>
  800399:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80039c:	85 d2                	test   %edx,%edx
  80039e:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a3:	0f 49 c2             	cmovns %edx,%eax
  8003a6:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003ac:	e9 6d ff ff ff       	jmp    80031e <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8003b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003b4:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003bb:	e9 5e ff ff ff       	jmp    80031e <vprintfmt+0x54>
  8003c0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003c3:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003c6:	eb bc                	jmp    800384 <vprintfmt+0xba>
			lflag++;
  8003c8:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003ce:	e9 4b ff ff ff       	jmp    80031e <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8003d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d6:	8d 50 04             	lea    0x4(%eax),%edx
  8003d9:	89 55 14             	mov    %edx,0x14(%ebp)
  8003dc:	83 ec 08             	sub    $0x8,%esp
  8003df:	56                   	push   %esi
  8003e0:	ff 30                	push   (%eax)
  8003e2:	ff d3                	call   *%ebx
			break;
  8003e4:	83 c4 10             	add    $0x10,%esp
  8003e7:	e9 94 01 00 00       	jmp    800580 <vprintfmt+0x2b6>
			err = va_arg(ap, int);
  8003ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ef:	8d 50 04             	lea    0x4(%eax),%edx
  8003f2:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f5:	8b 10                	mov    (%eax),%edx
  8003f7:	89 d0                	mov    %edx,%eax
  8003f9:	f7 d8                	neg    %eax
  8003fb:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003fe:	83 f8 08             	cmp    $0x8,%eax
  800401:	7f 20                	jg     800423 <vprintfmt+0x159>
  800403:	8b 14 85 00 11 80 00 	mov    0x801100(,%eax,4),%edx
  80040a:	85 d2                	test   %edx,%edx
  80040c:	74 15                	je     800423 <vprintfmt+0x159>
				printfmt(putch, putdat, "%s", p);
  80040e:	52                   	push   %edx
  80040f:	68 00 0f 80 00       	push   $0x800f00
  800414:	56                   	push   %esi
  800415:	53                   	push   %ebx
  800416:	e8 92 fe ff ff       	call   8002ad <printfmt>
  80041b:	83 c4 10             	add    $0x10,%esp
  80041e:	e9 5d 01 00 00       	jmp    800580 <vprintfmt+0x2b6>
				printfmt(putch, putdat, "error %d", err);
  800423:	50                   	push   %eax
  800424:	68 f7 0e 80 00       	push   $0x800ef7
  800429:	56                   	push   %esi
  80042a:	53                   	push   %ebx
  80042b:	e8 7d fe ff ff       	call   8002ad <printfmt>
  800430:	83 c4 10             	add    $0x10,%esp
  800433:	e9 48 01 00 00       	jmp    800580 <vprintfmt+0x2b6>
			if ((p = va_arg(ap, char *)) == NULL)
  800438:	8b 45 14             	mov    0x14(%ebp),%eax
  80043b:	8d 50 04             	lea    0x4(%eax),%edx
  80043e:	89 55 14             	mov    %edx,0x14(%ebp)
  800441:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800443:	85 ff                	test   %edi,%edi
  800445:	b8 f0 0e 80 00       	mov    $0x800ef0,%eax
  80044a:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80044d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800451:	7e 06                	jle    800459 <vprintfmt+0x18f>
  800453:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  800457:	75 0a                	jne    800463 <vprintfmt+0x199>
  800459:	89 f8                	mov    %edi,%eax
  80045b:	03 45 e0             	add    -0x20(%ebp),%eax
  80045e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800461:	eb 59                	jmp    8004bc <vprintfmt+0x1f2>
				for (width -= strnlen(p, precision); width > 0;
  800463:	83 ec 08             	sub    $0x8,%esp
  800466:	ff 75 d8             	push   -0x28(%ebp)
  800469:	57                   	push   %edi
  80046a:	e8 1a 02 00 00       	call   800689 <strnlen>
  80046f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800472:	29 c1                	sub    %eax,%ecx
  800474:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800477:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80047a:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  80047e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800481:	89 7d d0             	mov    %edi,-0x30(%ebp)
  800484:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0;
  800486:	eb 0f                	jmp    800497 <vprintfmt+0x1cd>
					putch(padc, putdat);
  800488:	83 ec 08             	sub    $0x8,%esp
  80048b:	56                   	push   %esi
  80048c:	ff 75 e0             	push   -0x20(%ebp)
  80048f:	ff d3                	call   *%ebx
				     width--)
  800491:	83 ef 01             	sub    $0x1,%edi
  800494:	83 c4 10             	add    $0x10,%esp
				for (width -= strnlen(p, precision); width > 0;
  800497:	85 ff                	test   %edi,%edi
  800499:	7f ed                	jg     800488 <vprintfmt+0x1be>
  80049b:	8b 7d d0             	mov    -0x30(%ebp),%edi
  80049e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004a1:	85 c9                	test   %ecx,%ecx
  8004a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a8:	0f 49 c1             	cmovns %ecx,%eax
  8004ab:	29 c1                	sub    %eax,%ecx
  8004ad:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8004b0:	eb a7                	jmp    800459 <vprintfmt+0x18f>
					putch(ch, putdat);
  8004b2:	83 ec 08             	sub    $0x8,%esp
  8004b5:	56                   	push   %esi
  8004b6:	52                   	push   %edx
  8004b7:	ff d3                	call   *%ebx
  8004b9:	83 c4 10             	add    $0x10,%esp
  8004bc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004bf:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' &&
  8004c1:	83 c7 01             	add    $0x1,%edi
  8004c4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004c8:	0f be d0             	movsbl %al,%edx
  8004cb:	85 d2                	test   %edx,%edx
  8004cd:	74 42                	je     800511 <vprintfmt+0x247>
  8004cf:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004d3:	78 06                	js     8004db <vprintfmt+0x211>
			       (precision < 0 || --precision >= 0);
  8004d5:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004d9:	78 1e                	js     8004f9 <vprintfmt+0x22f>
				if (altflag && (ch < ' ' || ch > '~'))
  8004db:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004df:	74 d1                	je     8004b2 <vprintfmt+0x1e8>
  8004e1:	0f be c0             	movsbl %al,%eax
  8004e4:	83 e8 20             	sub    $0x20,%eax
  8004e7:	83 f8 5e             	cmp    $0x5e,%eax
  8004ea:	76 c6                	jbe    8004b2 <vprintfmt+0x1e8>
					putch('?', putdat);
  8004ec:	83 ec 08             	sub    $0x8,%esp
  8004ef:	56                   	push   %esi
  8004f0:	6a 3f                	push   $0x3f
  8004f2:	ff d3                	call   *%ebx
  8004f4:	83 c4 10             	add    $0x10,%esp
  8004f7:	eb c3                	jmp    8004bc <vprintfmt+0x1f2>
  8004f9:	89 cf                	mov    %ecx,%edi
  8004fb:	eb 0e                	jmp    80050b <vprintfmt+0x241>
				putch(' ', putdat);
  8004fd:	83 ec 08             	sub    $0x8,%esp
  800500:	56                   	push   %esi
  800501:	6a 20                	push   $0x20
  800503:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  800505:	83 ef 01             	sub    $0x1,%edi
  800508:	83 c4 10             	add    $0x10,%esp
  80050b:	85 ff                	test   %edi,%edi
  80050d:	7f ee                	jg     8004fd <vprintfmt+0x233>
  80050f:	eb 6f                	jmp    800580 <vprintfmt+0x2b6>
  800511:	89 cf                	mov    %ecx,%edi
  800513:	eb f6                	jmp    80050b <vprintfmt+0x241>
			num = getint(&ap, lflag);
  800515:	89 ca                	mov    %ecx,%edx
  800517:	8d 45 14             	lea    0x14(%ebp),%eax
  80051a:	e8 45 fd ff ff       	call   800264 <getint>
  80051f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800522:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800525:	85 d2                	test   %edx,%edx
  800527:	78 0b                	js     800534 <vprintfmt+0x26a>
			num = getint(&ap, lflag);
  800529:	89 d1                	mov    %edx,%ecx
  80052b:	89 c2                	mov    %eax,%edx
			base = 10;
  80052d:	bf 0a 00 00 00       	mov    $0xa,%edi
  800532:	eb 32                	jmp    800566 <vprintfmt+0x29c>
				putch('-', putdat);
  800534:	83 ec 08             	sub    $0x8,%esp
  800537:	56                   	push   %esi
  800538:	6a 2d                	push   $0x2d
  80053a:	ff d3                	call   *%ebx
				num = -(long long) num;
  80053c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80053f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800542:	f7 da                	neg    %edx
  800544:	83 d1 00             	adc    $0x0,%ecx
  800547:	f7 d9                	neg    %ecx
  800549:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80054c:	bf 0a 00 00 00       	mov    $0xa,%edi
  800551:	eb 13                	jmp    800566 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  800553:	89 ca                	mov    %ecx,%edx
  800555:	8d 45 14             	lea    0x14(%ebp),%eax
  800558:	e8 d3 fc ff ff       	call   800230 <getuint>
  80055d:	89 d1                	mov    %edx,%ecx
  80055f:	89 c2                	mov    %eax,%edx
			base = 10;
  800561:	bf 0a 00 00 00       	mov    $0xa,%edi
			printnum(putch, putdat, num, base, width, padc);
  800566:	83 ec 0c             	sub    $0xc,%esp
  800569:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  80056d:	50                   	push   %eax
  80056e:	ff 75 e0             	push   -0x20(%ebp)
  800571:	57                   	push   %edi
  800572:	51                   	push   %ecx
  800573:	52                   	push   %edx
  800574:	89 f2                	mov    %esi,%edx
  800576:	89 d8                	mov    %ebx,%eax
  800578:	e8 0a fc ff ff       	call   800187 <printnum>
			break;
  80057d:	83 c4 20             	add    $0x20,%esp
{
  800580:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800583:	e9 60 fd ff ff       	jmp    8002e8 <vprintfmt+0x1e>
			num = getuint(&ap, lflag);
  800588:	89 ca                	mov    %ecx,%edx
  80058a:	8d 45 14             	lea    0x14(%ebp),%eax
  80058d:	e8 9e fc ff ff       	call   800230 <getuint>
  800592:	89 d1                	mov    %edx,%ecx
  800594:	89 c2                	mov    %eax,%edx
			base = 8;
  800596:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  80059b:	eb c9                	jmp    800566 <vprintfmt+0x29c>
			putch('0', putdat);
  80059d:	83 ec 08             	sub    $0x8,%esp
  8005a0:	56                   	push   %esi
  8005a1:	6a 30                	push   $0x30
  8005a3:	ff d3                	call   *%ebx
			putch('x', putdat);
  8005a5:	83 c4 08             	add    $0x8,%esp
  8005a8:	56                   	push   %esi
  8005a9:	6a 78                	push   $0x78
  8005ab:	ff d3                	call   *%ebx
			num = (unsigned long long) (uintptr_t) va_arg(ap, void *);
  8005ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b0:	8d 50 04             	lea    0x4(%eax),%edx
  8005b3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b6:	8b 10                	mov    (%eax),%edx
  8005b8:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8005bd:	83 c4 10             	add    $0x10,%esp
			base = 16;
  8005c0:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  8005c5:	eb 9f                	jmp    800566 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  8005c7:	89 ca                	mov    %ecx,%edx
  8005c9:	8d 45 14             	lea    0x14(%ebp),%eax
  8005cc:	e8 5f fc ff ff       	call   800230 <getuint>
  8005d1:	89 d1                	mov    %edx,%ecx
  8005d3:	89 c2                	mov    %eax,%edx
			base = 16;
  8005d5:	bf 10 00 00 00       	mov    $0x10,%edi
  8005da:	eb 8a                	jmp    800566 <vprintfmt+0x29c>
			putch(ch, putdat);
  8005dc:	83 ec 08             	sub    $0x8,%esp
  8005df:	56                   	push   %esi
  8005e0:	6a 25                	push   $0x25
  8005e2:	ff d3                	call   *%ebx
			break;
  8005e4:	83 c4 10             	add    $0x10,%esp
  8005e7:	eb 97                	jmp    800580 <vprintfmt+0x2b6>
			putch('%', putdat);
  8005e9:	83 ec 08             	sub    $0x8,%esp
  8005ec:	56                   	push   %esi
  8005ed:	6a 25                	push   $0x25
  8005ef:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  8005f1:	83 c4 10             	add    $0x10,%esp
  8005f4:	89 f8                	mov    %edi,%eax
  8005f6:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8005fa:	74 05                	je     800601 <vprintfmt+0x337>
  8005fc:	83 e8 01             	sub    $0x1,%eax
  8005ff:	eb f5                	jmp    8005f6 <vprintfmt+0x32c>
  800601:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800604:	e9 77 ff ff ff       	jmp    800580 <vprintfmt+0x2b6>

00800609 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800609:	55                   	push   %ebp
  80060a:	89 e5                	mov    %esp,%ebp
  80060c:	83 ec 18             	sub    $0x18,%esp
  80060f:	8b 45 08             	mov    0x8(%ebp),%eax
  800612:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = { buf, buf + n - 1, 0 };
  800615:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800618:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80061c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80061f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800626:	85 c0                	test   %eax,%eax
  800628:	74 26                	je     800650 <vsnprintf+0x47>
  80062a:	85 d2                	test   %edx,%edx
  80062c:	7e 22                	jle    800650 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *) sprintputch, &b, fmt, ap);
  80062e:	ff 75 14             	push   0x14(%ebp)
  800631:	ff 75 10             	push   0x10(%ebp)
  800634:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800637:	50                   	push   %eax
  800638:	68 90 02 80 00       	push   $0x800290
  80063d:	e8 88 fc ff ff       	call   8002ca <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800642:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800645:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800648:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80064b:	83 c4 10             	add    $0x10,%esp
}
  80064e:	c9                   	leave  
  80064f:	c3                   	ret    
		return -E_INVAL;
  800650:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800655:	eb f7                	jmp    80064e <vsnprintf+0x45>

00800657 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800657:	55                   	push   %ebp
  800658:	89 e5                	mov    %esp,%ebp
  80065a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80065d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800660:	50                   	push   %eax
  800661:	ff 75 10             	push   0x10(%ebp)
  800664:	ff 75 0c             	push   0xc(%ebp)
  800667:	ff 75 08             	push   0x8(%ebp)
  80066a:	e8 9a ff ff ff       	call   800609 <vsnprintf>
	va_end(ap);

	return rc;
}
  80066f:	c9                   	leave  
  800670:	c3                   	ret    

00800671 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800671:	55                   	push   %ebp
  800672:	89 e5                	mov    %esp,%ebp
  800674:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800677:	b8 00 00 00 00       	mov    $0x0,%eax
  80067c:	eb 03                	jmp    800681 <strlen+0x10>
		n++;
  80067e:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800681:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800685:	75 f7                	jne    80067e <strlen+0xd>
	return n;
}
  800687:	5d                   	pop    %ebp
  800688:	c3                   	ret    

00800689 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800689:	55                   	push   %ebp
  80068a:	89 e5                	mov    %esp,%ebp
  80068c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80068f:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800692:	b8 00 00 00 00       	mov    $0x0,%eax
  800697:	eb 03                	jmp    80069c <strnlen+0x13>
		n++;
  800699:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80069c:	39 d0                	cmp    %edx,%eax
  80069e:	74 08                	je     8006a8 <strnlen+0x1f>
  8006a0:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8006a4:	75 f3                	jne    800699 <strnlen+0x10>
  8006a6:	89 c2                	mov    %eax,%edx
	return n;
}
  8006a8:	89 d0                	mov    %edx,%eax
  8006aa:	5d                   	pop    %ebp
  8006ab:	c3                   	ret    

008006ac <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006ac:	55                   	push   %ebp
  8006ad:	89 e5                	mov    %esp,%ebp
  8006af:	53                   	push   %ebx
  8006b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8006bb:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8006bf:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8006c2:	83 c0 01             	add    $0x1,%eax
  8006c5:	84 d2                	test   %dl,%dl
  8006c7:	75 f2                	jne    8006bb <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8006c9:	89 c8                	mov    %ecx,%eax
  8006cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006ce:	c9                   	leave  
  8006cf:	c3                   	ret    

008006d0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8006d0:	55                   	push   %ebp
  8006d1:	89 e5                	mov    %esp,%ebp
  8006d3:	53                   	push   %ebx
  8006d4:	83 ec 10             	sub    $0x10,%esp
  8006d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8006da:	53                   	push   %ebx
  8006db:	e8 91 ff ff ff       	call   800671 <strlen>
  8006e0:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8006e3:	ff 75 0c             	push   0xc(%ebp)
  8006e6:	01 d8                	add    %ebx,%eax
  8006e8:	50                   	push   %eax
  8006e9:	e8 be ff ff ff       	call   8006ac <strcpy>
	return dst;
}
  8006ee:	89 d8                	mov    %ebx,%eax
  8006f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006f3:	c9                   	leave  
  8006f4:	c3                   	ret    

008006f5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size)
{
  8006f5:	55                   	push   %ebp
  8006f6:	89 e5                	mov    %esp,%ebp
  8006f8:	56                   	push   %esi
  8006f9:	53                   	push   %ebx
  8006fa:	8b 75 08             	mov    0x8(%ebp),%esi
  8006fd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800700:	89 f3                	mov    %esi,%ebx
  800702:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800705:	89 f0                	mov    %esi,%eax
  800707:	eb 0f                	jmp    800718 <strncpy+0x23>
		*dst++ = *src;
  800709:	83 c0 01             	add    $0x1,%eax
  80070c:	0f b6 0a             	movzbl (%edx),%ecx
  80070f:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800712:	80 f9 01             	cmp    $0x1,%cl
  800715:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800718:	39 d8                	cmp    %ebx,%eax
  80071a:	75 ed                	jne    800709 <strncpy+0x14>
	}
	return ret;
}
  80071c:	89 f0                	mov    %esi,%eax
  80071e:	5b                   	pop    %ebx
  80071f:	5e                   	pop    %esi
  800720:	5d                   	pop    %ebp
  800721:	c3                   	ret    

00800722 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800722:	55                   	push   %ebp
  800723:	89 e5                	mov    %esp,%ebp
  800725:	56                   	push   %esi
  800726:	53                   	push   %ebx
  800727:	8b 75 08             	mov    0x8(%ebp),%esi
  80072a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80072d:	8b 55 10             	mov    0x10(%ebp),%edx
  800730:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800732:	85 d2                	test   %edx,%edx
  800734:	74 21                	je     800757 <strlcpy+0x35>
  800736:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80073a:	89 f2                	mov    %esi,%edx
  80073c:	eb 09                	jmp    800747 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80073e:	83 c1 01             	add    $0x1,%ecx
  800741:	83 c2 01             	add    $0x1,%edx
  800744:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800747:	39 c2                	cmp    %eax,%edx
  800749:	74 09                	je     800754 <strlcpy+0x32>
  80074b:	0f b6 19             	movzbl (%ecx),%ebx
  80074e:	84 db                	test   %bl,%bl
  800750:	75 ec                	jne    80073e <strlcpy+0x1c>
  800752:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800754:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800757:	29 f0                	sub    %esi,%eax
}
  800759:	5b                   	pop    %ebx
  80075a:	5e                   	pop    %esi
  80075b:	5d                   	pop    %ebp
  80075c:	c3                   	ret    

0080075d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80075d:	55                   	push   %ebp
  80075e:	89 e5                	mov    %esp,%ebp
  800760:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800763:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800766:	eb 06                	jmp    80076e <strcmp+0x11>
		p++, q++;
  800768:	83 c1 01             	add    $0x1,%ecx
  80076b:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80076e:	0f b6 01             	movzbl (%ecx),%eax
  800771:	84 c0                	test   %al,%al
  800773:	74 04                	je     800779 <strcmp+0x1c>
  800775:	3a 02                	cmp    (%edx),%al
  800777:	74 ef                	je     800768 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800779:	0f b6 c0             	movzbl %al,%eax
  80077c:	0f b6 12             	movzbl (%edx),%edx
  80077f:	29 d0                	sub    %edx,%eax
}
  800781:	5d                   	pop    %ebp
  800782:	c3                   	ret    

00800783 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800783:	55                   	push   %ebp
  800784:	89 e5                	mov    %esp,%ebp
  800786:	53                   	push   %ebx
  800787:	8b 45 08             	mov    0x8(%ebp),%eax
  80078a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80078d:	89 c3                	mov    %eax,%ebx
  80078f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800792:	eb 06                	jmp    80079a <strncmp+0x17>
		n--, p++, q++;
  800794:	83 c0 01             	add    $0x1,%eax
  800797:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80079a:	39 d8                	cmp    %ebx,%eax
  80079c:	74 18                	je     8007b6 <strncmp+0x33>
  80079e:	0f b6 08             	movzbl (%eax),%ecx
  8007a1:	84 c9                	test   %cl,%cl
  8007a3:	74 04                	je     8007a9 <strncmp+0x26>
  8007a5:	3a 0a                	cmp    (%edx),%cl
  8007a7:	74 eb                	je     800794 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007a9:	0f b6 00             	movzbl (%eax),%eax
  8007ac:	0f b6 12             	movzbl (%edx),%edx
  8007af:	29 d0                	sub    %edx,%eax
}
  8007b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b4:	c9                   	leave  
  8007b5:	c3                   	ret    
		return 0;
  8007b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007bb:	eb f4                	jmp    8007b1 <strncmp+0x2e>

008007bd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007bd:	55                   	push   %ebp
  8007be:	89 e5                	mov    %esp,%ebp
  8007c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007c7:	eb 03                	jmp    8007cc <strchr+0xf>
  8007c9:	83 c0 01             	add    $0x1,%eax
  8007cc:	0f b6 10             	movzbl (%eax),%edx
  8007cf:	84 d2                	test   %dl,%dl
  8007d1:	74 06                	je     8007d9 <strchr+0x1c>
		if (*s == c)
  8007d3:	38 ca                	cmp    %cl,%dl
  8007d5:	75 f2                	jne    8007c9 <strchr+0xc>
  8007d7:	eb 05                	jmp    8007de <strchr+0x21>
			return (char *) s;
	return 0;
  8007d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007de:	5d                   	pop    %ebp
  8007df:	c3                   	ret    

008007e0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007ea:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8007ed:	38 ca                	cmp    %cl,%dl
  8007ef:	74 09                	je     8007fa <strfind+0x1a>
  8007f1:	84 d2                	test   %dl,%dl
  8007f3:	74 05                	je     8007fa <strfind+0x1a>
	for (; *s; s++)
  8007f5:	83 c0 01             	add    $0x1,%eax
  8007f8:	eb f0                	jmp    8007ea <strfind+0xa>
			break;
	return (char *) s;
}
  8007fa:	5d                   	pop    %ebp
  8007fb:	c3                   	ret    

008007fc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8007fc:	55                   	push   %ebp
  8007fd:	89 e5                	mov    %esp,%ebp
  8007ff:	57                   	push   %edi
  800800:	56                   	push   %esi
  800801:	53                   	push   %ebx
  800802:	8b 55 08             	mov    0x8(%ebp),%edx
  800805:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  800808:	85 c9                	test   %ecx,%ecx
  80080a:	74 33                	je     80083f <memset+0x43>
		return v;
	if ((int) v % 4 == 0 && n % 4 == 0) {
  80080c:	89 d0                	mov    %edx,%eax
  80080e:	09 c8                	or     %ecx,%eax
  800810:	a8 03                	test   $0x3,%al
  800812:	75 23                	jne    800837 <memset+0x3b>
		c &= 0xFF;
  800814:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  800818:	89 d8                	mov    %ebx,%eax
  80081a:	c1 e0 08             	shl    $0x8,%eax
  80081d:	89 df                	mov    %ebx,%edi
  80081f:	c1 e7 18             	shl    $0x18,%edi
  800822:	89 de                	mov    %ebx,%esi
  800824:	c1 e6 10             	shl    $0x10,%esi
  800827:	09 f7                	or     %esi,%edi
  800829:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
		             : "=D"(p), "=c"(n)
		             : "D"(p), "a"(c), "c"(n / 4)
  80082b:	c1 e9 02             	shr    $0x2,%ecx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  80082e:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800830:	89 d7                	mov    %edx,%edi
  800832:	fc                   	cld    
  800833:	f3 ab                	rep stos %eax,%es:(%edi)
  800835:	eb 08                	jmp    80083f <memset+0x43>
		             : "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800837:	89 d7                	mov    %edx,%edi
  800839:	8b 45 0c             	mov    0xc(%ebp),%eax
  80083c:	fc                   	cld    
  80083d:	f3 aa                	rep stos %al,%es:(%edi)
		             : "=D"(p), "=c"(n)
		             : "0"(p), "a"(c), "1"(n)
		             : "cc", "memory");
	return v;
}
  80083f:	89 d0                	mov    %edx,%eax
  800841:	5b                   	pop    %ebx
  800842:	5e                   	pop    %esi
  800843:	5f                   	pop    %edi
  800844:	5d                   	pop    %ebp
  800845:	c3                   	ret    

00800846 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800846:	55                   	push   %ebp
  800847:	89 e5                	mov    %esp,%ebp
  800849:	57                   	push   %edi
  80084a:	56                   	push   %esi
  80084b:	8b 45 08             	mov    0x8(%ebp),%eax
  80084e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800851:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800854:	39 c6                	cmp    %eax,%esi
  800856:	73 32                	jae    80088a <memmove+0x44>
  800858:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80085b:	39 c2                	cmp    %eax,%edx
  80085d:	76 2b                	jbe    80088a <memmove+0x44>
		s += n;
		d += n;
  80085f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  800862:	89 d6                	mov    %edx,%esi
  800864:	09 fe                	or     %edi,%esi
  800866:	09 ce                	or     %ecx,%esi
  800868:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80086e:	75 0e                	jne    80087e <memmove+0x38>
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  800870:	83 ef 04             	sub    $0x4,%edi
			             "S"(s - 4),
  800873:	8d 72 fc             	lea    -0x4(%edx),%esi
			             "c"(n / 4)
  800876:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  800879:	fd                   	std    
  80087a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80087c:	eb 09                	jmp    800887 <memmove+0x41>
			             : "cc", "memory");
		else
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  80087e:	83 ef 01             	sub    $0x1,%edi
			             "S"(s - 1),
  800881:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  800884:	fd                   	std    
  800885:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             "c"(n)
			             : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800887:	fc                   	cld    
  800888:	eb 1a                	jmp    8008a4 <memmove+0x5e>
	} else {
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  80088a:	89 f2                	mov    %esi,%edx
  80088c:	09 c2                	or     %eax,%edx
  80088e:	09 ca                	or     %ecx,%edx
  800890:	f6 c2 03             	test   $0x3,%dl
  800893:	75 0a                	jne    80089f <memmove+0x59>
			asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800895:	c1 e9 02             	shr    $0x2,%ecx
  800898:	89 c7                	mov    %eax,%edi
  80089a:	fc                   	cld    
  80089b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80089d:	eb 05                	jmp    8008a4 <memmove+0x5e>
			             : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  80089f:	89 c7                	mov    %eax,%edi
  8008a1:	fc                   	cld    
  8008a2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             : "cc", "memory");
	}
	return dst;
}
  8008a4:	5e                   	pop    %esi
  8008a5:	5f                   	pop    %edi
  8008a6:	5d                   	pop    %ebp
  8008a7:	c3                   	ret    

008008a8 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008a8:	55                   	push   %ebp
  8008a9:	89 e5                	mov    %esp,%ebp
  8008ab:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8008ae:	ff 75 10             	push   0x10(%ebp)
  8008b1:	ff 75 0c             	push   0xc(%ebp)
  8008b4:	ff 75 08             	push   0x8(%ebp)
  8008b7:	e8 8a ff ff ff       	call   800846 <memmove>
}
  8008bc:	c9                   	leave  
  8008bd:	c3                   	ret    

008008be <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008be:	55                   	push   %ebp
  8008bf:	89 e5                	mov    %esp,%ebp
  8008c1:	56                   	push   %esi
  8008c2:	53                   	push   %ebx
  8008c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c9:	89 c6                	mov    %eax,%esi
  8008cb:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8008ce:	eb 06                	jmp    8008d6 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8008d0:	83 c0 01             	add    $0x1,%eax
  8008d3:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  8008d6:	39 f0                	cmp    %esi,%eax
  8008d8:	74 14                	je     8008ee <memcmp+0x30>
		if (*s1 != *s2)
  8008da:	0f b6 08             	movzbl (%eax),%ecx
  8008dd:	0f b6 1a             	movzbl (%edx),%ebx
  8008e0:	38 d9                	cmp    %bl,%cl
  8008e2:	74 ec                	je     8008d0 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  8008e4:	0f b6 c1             	movzbl %cl,%eax
  8008e7:	0f b6 db             	movzbl %bl,%ebx
  8008ea:	29 d8                	sub    %ebx,%eax
  8008ec:	eb 05                	jmp    8008f3 <memcmp+0x35>
	}

	return 0;
  8008ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008f3:	5b                   	pop    %ebx
  8008f4:	5e                   	pop    %esi
  8008f5:	5d                   	pop    %ebp
  8008f6:	c3                   	ret    

008008f7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8008f7:	55                   	push   %ebp
  8008f8:	89 e5                	mov    %esp,%ebp
  8008fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800900:	89 c2                	mov    %eax,%edx
  800902:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800905:	eb 03                	jmp    80090a <memfind+0x13>
  800907:	83 c0 01             	add    $0x1,%eax
  80090a:	39 d0                	cmp    %edx,%eax
  80090c:	73 04                	jae    800912 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  80090e:	38 08                	cmp    %cl,(%eax)
  800910:	75 f5                	jne    800907 <memfind+0x10>
			break;
	return (void *) s;
}
  800912:	5d                   	pop    %ebp
  800913:	c3                   	ret    

00800914 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800914:	55                   	push   %ebp
  800915:	89 e5                	mov    %esp,%ebp
  800917:	57                   	push   %edi
  800918:	56                   	push   %esi
  800919:	53                   	push   %ebx
  80091a:	8b 55 08             	mov    0x8(%ebp),%edx
  80091d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800920:	eb 03                	jmp    800925 <strtol+0x11>
		s++;
  800922:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800925:	0f b6 02             	movzbl (%edx),%eax
  800928:	3c 20                	cmp    $0x20,%al
  80092a:	74 f6                	je     800922 <strtol+0xe>
  80092c:	3c 09                	cmp    $0x9,%al
  80092e:	74 f2                	je     800922 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800930:	3c 2b                	cmp    $0x2b,%al
  800932:	74 2a                	je     80095e <strtol+0x4a>
	int neg = 0;
  800934:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800939:	3c 2d                	cmp    $0x2d,%al
  80093b:	74 2b                	je     800968 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80093d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800943:	75 0f                	jne    800954 <strtol+0x40>
  800945:	80 3a 30             	cmpb   $0x30,(%edx)
  800948:	74 28                	je     800972 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80094a:	85 db                	test   %ebx,%ebx
  80094c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800951:	0f 44 d8             	cmove  %eax,%ebx
  800954:	b9 00 00 00 00       	mov    $0x0,%ecx
  800959:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80095c:	eb 46                	jmp    8009a4 <strtol+0x90>
		s++;
  80095e:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800961:	bf 00 00 00 00       	mov    $0x0,%edi
  800966:	eb d5                	jmp    80093d <strtol+0x29>
		s++, neg = 1;
  800968:	83 c2 01             	add    $0x1,%edx
  80096b:	bf 01 00 00 00       	mov    $0x1,%edi
  800970:	eb cb                	jmp    80093d <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800972:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800976:	74 0e                	je     800986 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800978:	85 db                	test   %ebx,%ebx
  80097a:	75 d8                	jne    800954 <strtol+0x40>
		s++, base = 8;
  80097c:	83 c2 01             	add    $0x1,%edx
  80097f:	bb 08 00 00 00       	mov    $0x8,%ebx
  800984:	eb ce                	jmp    800954 <strtol+0x40>
		s += 2, base = 16;
  800986:	83 c2 02             	add    $0x2,%edx
  800989:	bb 10 00 00 00       	mov    $0x10,%ebx
  80098e:	eb c4                	jmp    800954 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800990:	0f be c0             	movsbl %al,%eax
  800993:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800996:	3b 45 10             	cmp    0x10(%ebp),%eax
  800999:	7d 3a                	jge    8009d5 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  80099b:	83 c2 01             	add    $0x1,%edx
  80099e:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  8009a2:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  8009a4:	0f b6 02             	movzbl (%edx),%eax
  8009a7:	8d 70 d0             	lea    -0x30(%eax),%esi
  8009aa:	89 f3                	mov    %esi,%ebx
  8009ac:	80 fb 09             	cmp    $0x9,%bl
  8009af:	76 df                	jbe    800990 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  8009b1:	8d 70 9f             	lea    -0x61(%eax),%esi
  8009b4:	89 f3                	mov    %esi,%ebx
  8009b6:	80 fb 19             	cmp    $0x19,%bl
  8009b9:	77 08                	ja     8009c3 <strtol+0xaf>
			dig = *s - 'a' + 10;
  8009bb:	0f be c0             	movsbl %al,%eax
  8009be:	83 e8 57             	sub    $0x57,%eax
  8009c1:	eb d3                	jmp    800996 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  8009c3:	8d 70 bf             	lea    -0x41(%eax),%esi
  8009c6:	89 f3                	mov    %esi,%ebx
  8009c8:	80 fb 19             	cmp    $0x19,%bl
  8009cb:	77 08                	ja     8009d5 <strtol+0xc1>
			dig = *s - 'A' + 10;
  8009cd:	0f be c0             	movsbl %al,%eax
  8009d0:	83 e8 37             	sub    $0x37,%eax
  8009d3:	eb c1                	jmp    800996 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  8009d5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8009d9:	74 05                	je     8009e0 <strtol+0xcc>
		*endptr = (char *) s;
  8009db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009de:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  8009e0:	89 c8                	mov    %ecx,%eax
  8009e2:	f7 d8                	neg    %eax
  8009e4:	85 ff                	test   %edi,%edi
  8009e6:	0f 45 c8             	cmovne %eax,%ecx
}
  8009e9:	89 c8                	mov    %ecx,%eax
  8009eb:	5b                   	pop    %ebx
  8009ec:	5e                   	pop    %esi
  8009ed:	5f                   	pop    %edi
  8009ee:	5d                   	pop    %ebp
  8009ef:	c3                   	ret    

008009f0 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8009f0:	55                   	push   %ebp
  8009f1:	89 e5                	mov    %esp,%ebp
  8009f3:	57                   	push   %edi
  8009f4:	56                   	push   %esi
  8009f5:	53                   	push   %ebx
  8009f6:	83 ec 1c             	sub    $0x1c,%esp
  8009f9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009fc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8009ff:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile(
  800a01:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a04:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a07:	8b 7d 10             	mov    0x10(%ebp),%edi
  800a0a:	8b 75 14             	mov    0x14(%ebp),%esi
  800a0d:	cd 30                	int    $0x30
	        "int %1\n"
	        : "=a"(ret)
	        : "i"(T_SYSCALL), "a"(num), "d"(a1), "c"(a2), "b"(a3), "D"(a4), "S"(a5)
	        : "cc", "memory");

	if (check && ret > 0)
  800a0f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a13:	74 04                	je     800a19 <syscall+0x29>
  800a15:	85 c0                	test   %eax,%eax
  800a17:	7f 08                	jg     800a21 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800a19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a1c:	5b                   	pop    %ebx
  800a1d:	5e                   	pop    %esi
  800a1e:	5f                   	pop    %edi
  800a1f:	5d                   	pop    %ebp
  800a20:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800a21:	83 ec 0c             	sub    $0xc,%esp
  800a24:	50                   	push   %eax
  800a25:	ff 75 e0             	push   -0x20(%ebp)
  800a28:	68 24 11 80 00       	push   $0x801124
  800a2d:	6a 1e                	push   $0x1e
  800a2f:	68 41 11 80 00       	push   $0x801141
  800a34:	e8 f7 01 00 00       	call   800c30 <_panic>

00800a39 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800a39:	55                   	push   %ebp
  800a3a:	89 e5                	mov    %esp,%ebp
  800a3c:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t) s, len, 0, 0, 0);
  800a3f:	6a 00                	push   $0x0
  800a41:	6a 00                	push   $0x0
  800a43:	6a 00                	push   $0x0
  800a45:	ff 75 0c             	push   0xc(%ebp)
  800a48:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a4b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a50:	b8 00 00 00 00       	mov    $0x0,%eax
  800a55:	e8 96 ff ff ff       	call   8009f0 <syscall>
}
  800a5a:	83 c4 10             	add    $0x10,%esp
  800a5d:	c9                   	leave  
  800a5e:	c3                   	ret    

00800a5f <sys_cgetc>:

int
sys_cgetc(void)
{
  800a5f:	55                   	push   %ebp
  800a60:	89 e5                	mov    %esp,%ebp
  800a62:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800a65:	6a 00                	push   $0x0
  800a67:	6a 00                	push   $0x0
  800a69:	6a 00                	push   $0x0
  800a6b:	6a 00                	push   $0x0
  800a6d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a72:	ba 00 00 00 00       	mov    $0x0,%edx
  800a77:	b8 01 00 00 00       	mov    $0x1,%eax
  800a7c:	e8 6f ff ff ff       	call   8009f0 <syscall>
}
  800a81:	c9                   	leave  
  800a82:	c3                   	ret    

00800a83 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a83:	55                   	push   %ebp
  800a84:	89 e5                	mov    %esp,%ebp
  800a86:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800a89:	6a 00                	push   $0x0
  800a8b:	6a 00                	push   $0x0
  800a8d:	6a 00                	push   $0x0
  800a8f:	6a 00                	push   $0x0
  800a91:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a94:	ba 01 00 00 00       	mov    $0x1,%edx
  800a99:	b8 03 00 00 00       	mov    $0x3,%eax
  800a9e:	e8 4d ff ff ff       	call   8009f0 <syscall>
}
  800aa3:	c9                   	leave  
  800aa4:	c3                   	ret    

00800aa5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800aa5:	55                   	push   %ebp
  800aa6:	89 e5                	mov    %esp,%ebp
  800aa8:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800aab:	6a 00                	push   $0x0
  800aad:	6a 00                	push   $0x0
  800aaf:	6a 00                	push   $0x0
  800ab1:	6a 00                	push   $0x0
  800ab3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ab8:	ba 00 00 00 00       	mov    $0x0,%edx
  800abd:	b8 02 00 00 00       	mov    $0x2,%eax
  800ac2:	e8 29 ff ff ff       	call   8009f0 <syscall>
}
  800ac7:	c9                   	leave  
  800ac8:	c3                   	ret    

00800ac9 <sys_yield>:

void
sys_yield(void)
{
  800ac9:	55                   	push   %ebp
  800aca:	89 e5                	mov    %esp,%ebp
  800acc:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800acf:	6a 00                	push   $0x0
  800ad1:	6a 00                	push   $0x0
  800ad3:	6a 00                	push   $0x0
  800ad5:	6a 00                	push   $0x0
  800ad7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800adc:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ae6:	e8 05 ff ff ff       	call   8009f0 <syscall>
}
  800aeb:	83 c4 10             	add    $0x10,%esp
  800aee:	c9                   	leave  
  800aef:	c3                   	ret    

00800af0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800af0:	55                   	push   %ebp
  800af1:	89 e5                	mov    %esp,%ebp
  800af3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800af6:	6a 00                	push   $0x0
  800af8:	6a 00                	push   $0x0
  800afa:	ff 75 10             	push   0x10(%ebp)
  800afd:	ff 75 0c             	push   0xc(%ebp)
  800b00:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b03:	ba 01 00 00 00       	mov    $0x1,%edx
  800b08:	b8 04 00 00 00       	mov    $0x4,%eax
  800b0d:	e8 de fe ff ff       	call   8009f0 <syscall>
}
  800b12:	c9                   	leave  
  800b13:	c3                   	ret    

00800b14 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b14:	55                   	push   %ebp
  800b15:	89 e5                	mov    %esp,%ebp
  800b17:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map,
  800b1a:	ff 75 18             	push   0x18(%ebp)
  800b1d:	ff 75 14             	push   0x14(%ebp)
  800b20:	ff 75 10             	push   0x10(%ebp)
  800b23:	ff 75 0c             	push   0xc(%ebp)
  800b26:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b29:	ba 01 00 00 00       	mov    $0x1,%edx
  800b2e:	b8 05 00 00 00       	mov    $0x5,%eax
  800b33:	e8 b8 fe ff ff       	call   8009f0 <syscall>
	               srcenv,
	               (uint32_t) srcva,
	               dstenv,
	               (uint32_t) dstva,
	               perm);
}
  800b38:	c9                   	leave  
  800b39:	c3                   	ret    

00800b3a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b3a:	55                   	push   %ebp
  800b3b:	89 e5                	mov    %esp,%ebp
  800b3d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800b40:	6a 00                	push   $0x0
  800b42:	6a 00                	push   $0x0
  800b44:	6a 00                	push   $0x0
  800b46:	ff 75 0c             	push   0xc(%ebp)
  800b49:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b4c:	ba 01 00 00 00       	mov    $0x1,%edx
  800b51:	b8 06 00 00 00       	mov    $0x6,%eax
  800b56:	e8 95 fe ff ff       	call   8009f0 <syscall>
}
  800b5b:	c9                   	leave  
  800b5c:	c3                   	ret    

00800b5d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800b5d:	55                   	push   %ebp
  800b5e:	89 e5                	mov    %esp,%ebp
  800b60:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800b63:	6a 00                	push   $0x0
  800b65:	6a 00                	push   $0x0
  800b67:	6a 00                	push   $0x0
  800b69:	ff 75 0c             	push   0xc(%ebp)
  800b6c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b6f:	ba 01 00 00 00       	mov    $0x1,%edx
  800b74:	b8 08 00 00 00       	mov    $0x8,%eax
  800b79:	e8 72 fe ff ff       	call   8009f0 <syscall>
}
  800b7e:	c9                   	leave  
  800b7f:	c3                   	ret    

00800b80 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	83 ec 08             	sub    $0x8,%esp
	return syscall(
  800b86:	6a 00                	push   $0x0
  800b88:	6a 00                	push   $0x0
  800b8a:	6a 00                	push   $0x0
  800b8c:	ff 75 0c             	push   0xc(%ebp)
  800b8f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b92:	ba 01 00 00 00       	mov    $0x1,%edx
  800b97:	b8 09 00 00 00       	mov    $0x9,%eax
  800b9c:	e8 4f fe ff ff       	call   8009f0 <syscall>
	        SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ba1:	c9                   	leave  
  800ba2:	c3                   	ret    

00800ba3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ba3:	55                   	push   %ebp
  800ba4:	89 e5                	mov    %esp,%ebp
  800ba6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800ba9:	6a 00                	push   $0x0
  800bab:	ff 75 14             	push   0x14(%ebp)
  800bae:	ff 75 10             	push   0x10(%ebp)
  800bb1:	ff 75 0c             	push   0xc(%ebp)
  800bb4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bb7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bbc:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bc1:	e8 2a fe ff ff       	call   8009f0 <syscall>
}
  800bc6:	c9                   	leave  
  800bc7:	c3                   	ret    

00800bc8 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800bc8:	55                   	push   %ebp
  800bc9:	89 e5                	mov    %esp,%ebp
  800bcb:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t) dstva, 0, 0, 0, 0);
  800bce:	6a 00                	push   $0x0
  800bd0:	6a 00                	push   $0x0
  800bd2:	6a 00                	push   $0x0
  800bd4:	6a 00                	push   $0x0
  800bd6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bd9:	ba 01 00 00 00       	mov    $0x1,%edx
  800bde:	b8 0c 00 00 00       	mov    $0xc,%eax
  800be3:	e8 08 fe ff ff       	call   8009f0 <syscall>
}
  800be8:	c9                   	leave  
  800be9:	c3                   	ret    

00800bea <sys_get_priority>:

// Get priority of the current process
int
sys_get_priority(void)
{
  800bea:	55                   	push   %ebp
  800beb:	89 e5                	mov    %esp,%ebp
  800bed:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_get_priority, 0, 0, 0, 0, 0, 0);
  800bf0:	6a 00                	push   $0x0
  800bf2:	6a 00                	push   $0x0
  800bf4:	6a 00                	push   $0x0
  800bf6:	6a 00                	push   $0x0
  800bf8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bfd:	ba 00 00 00 00       	mov    $0x0,%edx
  800c02:	b8 0d 00 00 00       	mov    $0xd,%eax
  800c07:	e8 e4 fd ff ff       	call   8009f0 <syscall>
}
  800c0c:	c9                   	leave  
  800c0d:	c3                   	ret    

00800c0e <sys_set_priority>:

// Get priority of the current process
int
sys_set_priority(unsigned int priority)
{
  800c0e:	55                   	push   %ebp
  800c0f:	89 e5                	mov    %esp,%ebp
  800c11:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, (uint32_t) priority, 0, 0, 0, 0);
  800c14:	6a 00                	push   $0x0
  800c16:	6a 00                	push   $0x0
  800c18:	6a 00                	push   $0x0
  800c1a:	6a 00                	push   $0x0
  800c1c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c1f:	ba 00 00 00 00       	mov    $0x0,%edx
  800c24:	b8 0e 00 00 00       	mov    $0xe,%eax
  800c29:	e8 c2 fd ff ff       	call   8009f0 <syscall>
}
  800c2e:	c9                   	leave  
  800c2f:	c3                   	ret    

00800c30 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800c30:	55                   	push   %ebp
  800c31:	89 e5                	mov    %esp,%ebp
  800c33:	56                   	push   %esi
  800c34:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800c35:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800c38:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800c3e:	e8 62 fe ff ff       	call   800aa5 <sys_getenvid>
  800c43:	83 ec 0c             	sub    $0xc,%esp
  800c46:	ff 75 0c             	push   0xc(%ebp)
  800c49:	ff 75 08             	push   0x8(%ebp)
  800c4c:	56                   	push   %esi
  800c4d:	50                   	push   %eax
  800c4e:	68 50 11 80 00       	push   $0x801150
  800c53:	e8 1b f5 ff ff       	call   800173 <cprintf>
	        sys_getenvid(),
	        binaryname,
	        file,
	        line);
	vcprintf(fmt, ap);
  800c58:	83 c4 18             	add    $0x18,%esp
  800c5b:	53                   	push   %ebx
  800c5c:	ff 75 10             	push   0x10(%ebp)
  800c5f:	e8 be f4 ff ff       	call   800122 <vcprintf>
	cprintf("\n");
  800c64:	c7 04 24 d3 0e 80 00 	movl   $0x800ed3,(%esp)
  800c6b:	e8 03 f5 ff ff       	call   800173 <cprintf>
  800c70:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800c73:	cc                   	int3   
  800c74:	eb fd                	jmp    800c73 <_panic+0x43>
  800c76:	66 90                	xchg   %ax,%ax
  800c78:	66 90                	xchg   %ax,%ax
  800c7a:	66 90                	xchg   %ax,%ax
  800c7c:	66 90                	xchg   %ax,%ax
  800c7e:	66 90                	xchg   %ax,%ax

00800c80 <__udivdi3>:
  800c80:	f3 0f 1e fb          	endbr32 
  800c84:	55                   	push   %ebp
  800c85:	57                   	push   %edi
  800c86:	56                   	push   %esi
  800c87:	53                   	push   %ebx
  800c88:	83 ec 1c             	sub    $0x1c,%esp
  800c8b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800c8f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800c93:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c97:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800c9b:	85 c0                	test   %eax,%eax
  800c9d:	75 19                	jne    800cb8 <__udivdi3+0x38>
  800c9f:	39 f3                	cmp    %esi,%ebx
  800ca1:	76 4d                	jbe    800cf0 <__udivdi3+0x70>
  800ca3:	31 ff                	xor    %edi,%edi
  800ca5:	89 e8                	mov    %ebp,%eax
  800ca7:	89 f2                	mov    %esi,%edx
  800ca9:	f7 f3                	div    %ebx
  800cab:	89 fa                	mov    %edi,%edx
  800cad:	83 c4 1c             	add    $0x1c,%esp
  800cb0:	5b                   	pop    %ebx
  800cb1:	5e                   	pop    %esi
  800cb2:	5f                   	pop    %edi
  800cb3:	5d                   	pop    %ebp
  800cb4:	c3                   	ret    
  800cb5:	8d 76 00             	lea    0x0(%esi),%esi
  800cb8:	39 f0                	cmp    %esi,%eax
  800cba:	76 14                	jbe    800cd0 <__udivdi3+0x50>
  800cbc:	31 ff                	xor    %edi,%edi
  800cbe:	31 c0                	xor    %eax,%eax
  800cc0:	89 fa                	mov    %edi,%edx
  800cc2:	83 c4 1c             	add    $0x1c,%esp
  800cc5:	5b                   	pop    %ebx
  800cc6:	5e                   	pop    %esi
  800cc7:	5f                   	pop    %edi
  800cc8:	5d                   	pop    %ebp
  800cc9:	c3                   	ret    
  800cca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800cd0:	0f bd f8             	bsr    %eax,%edi
  800cd3:	83 f7 1f             	xor    $0x1f,%edi
  800cd6:	75 48                	jne    800d20 <__udivdi3+0xa0>
  800cd8:	39 f0                	cmp    %esi,%eax
  800cda:	72 06                	jb     800ce2 <__udivdi3+0x62>
  800cdc:	31 c0                	xor    %eax,%eax
  800cde:	39 eb                	cmp    %ebp,%ebx
  800ce0:	77 de                	ja     800cc0 <__udivdi3+0x40>
  800ce2:	b8 01 00 00 00       	mov    $0x1,%eax
  800ce7:	eb d7                	jmp    800cc0 <__udivdi3+0x40>
  800ce9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800cf0:	89 d9                	mov    %ebx,%ecx
  800cf2:	85 db                	test   %ebx,%ebx
  800cf4:	75 0b                	jne    800d01 <__udivdi3+0x81>
  800cf6:	b8 01 00 00 00       	mov    $0x1,%eax
  800cfb:	31 d2                	xor    %edx,%edx
  800cfd:	f7 f3                	div    %ebx
  800cff:	89 c1                	mov    %eax,%ecx
  800d01:	31 d2                	xor    %edx,%edx
  800d03:	89 f0                	mov    %esi,%eax
  800d05:	f7 f1                	div    %ecx
  800d07:	89 c6                	mov    %eax,%esi
  800d09:	89 e8                	mov    %ebp,%eax
  800d0b:	89 f7                	mov    %esi,%edi
  800d0d:	f7 f1                	div    %ecx
  800d0f:	89 fa                	mov    %edi,%edx
  800d11:	83 c4 1c             	add    $0x1c,%esp
  800d14:	5b                   	pop    %ebx
  800d15:	5e                   	pop    %esi
  800d16:	5f                   	pop    %edi
  800d17:	5d                   	pop    %ebp
  800d18:	c3                   	ret    
  800d19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d20:	89 f9                	mov    %edi,%ecx
  800d22:	ba 20 00 00 00       	mov    $0x20,%edx
  800d27:	29 fa                	sub    %edi,%edx
  800d29:	d3 e0                	shl    %cl,%eax
  800d2b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d2f:	89 d1                	mov    %edx,%ecx
  800d31:	89 d8                	mov    %ebx,%eax
  800d33:	d3 e8                	shr    %cl,%eax
  800d35:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800d39:	09 c1                	or     %eax,%ecx
  800d3b:	89 f0                	mov    %esi,%eax
  800d3d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d41:	89 f9                	mov    %edi,%ecx
  800d43:	d3 e3                	shl    %cl,%ebx
  800d45:	89 d1                	mov    %edx,%ecx
  800d47:	d3 e8                	shr    %cl,%eax
  800d49:	89 f9                	mov    %edi,%ecx
  800d4b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800d4f:	89 eb                	mov    %ebp,%ebx
  800d51:	d3 e6                	shl    %cl,%esi
  800d53:	89 d1                	mov    %edx,%ecx
  800d55:	d3 eb                	shr    %cl,%ebx
  800d57:	09 f3                	or     %esi,%ebx
  800d59:	89 c6                	mov    %eax,%esi
  800d5b:	89 f2                	mov    %esi,%edx
  800d5d:	89 d8                	mov    %ebx,%eax
  800d5f:	f7 74 24 08          	divl   0x8(%esp)
  800d63:	89 d6                	mov    %edx,%esi
  800d65:	89 c3                	mov    %eax,%ebx
  800d67:	f7 64 24 0c          	mull   0xc(%esp)
  800d6b:	39 d6                	cmp    %edx,%esi
  800d6d:	72 19                	jb     800d88 <__udivdi3+0x108>
  800d6f:	89 f9                	mov    %edi,%ecx
  800d71:	d3 e5                	shl    %cl,%ebp
  800d73:	39 c5                	cmp    %eax,%ebp
  800d75:	73 04                	jae    800d7b <__udivdi3+0xfb>
  800d77:	39 d6                	cmp    %edx,%esi
  800d79:	74 0d                	je     800d88 <__udivdi3+0x108>
  800d7b:	89 d8                	mov    %ebx,%eax
  800d7d:	31 ff                	xor    %edi,%edi
  800d7f:	e9 3c ff ff ff       	jmp    800cc0 <__udivdi3+0x40>
  800d84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d88:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800d8b:	31 ff                	xor    %edi,%edi
  800d8d:	e9 2e ff ff ff       	jmp    800cc0 <__udivdi3+0x40>
  800d92:	66 90                	xchg   %ax,%ax
  800d94:	66 90                	xchg   %ax,%ax
  800d96:	66 90                	xchg   %ax,%ax
  800d98:	66 90                	xchg   %ax,%ax
  800d9a:	66 90                	xchg   %ax,%ax
  800d9c:	66 90                	xchg   %ax,%ax
  800d9e:	66 90                	xchg   %ax,%ax

00800da0 <__umoddi3>:
  800da0:	f3 0f 1e fb          	endbr32 
  800da4:	55                   	push   %ebp
  800da5:	57                   	push   %edi
  800da6:	56                   	push   %esi
  800da7:	53                   	push   %ebx
  800da8:	83 ec 1c             	sub    $0x1c,%esp
  800dab:	8b 74 24 30          	mov    0x30(%esp),%esi
  800daf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800db3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  800db7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  800dbb:	89 f0                	mov    %esi,%eax
  800dbd:	89 da                	mov    %ebx,%edx
  800dbf:	85 ff                	test   %edi,%edi
  800dc1:	75 15                	jne    800dd8 <__umoddi3+0x38>
  800dc3:	39 dd                	cmp    %ebx,%ebp
  800dc5:	76 39                	jbe    800e00 <__umoddi3+0x60>
  800dc7:	f7 f5                	div    %ebp
  800dc9:	89 d0                	mov    %edx,%eax
  800dcb:	31 d2                	xor    %edx,%edx
  800dcd:	83 c4 1c             	add    $0x1c,%esp
  800dd0:	5b                   	pop    %ebx
  800dd1:	5e                   	pop    %esi
  800dd2:	5f                   	pop    %edi
  800dd3:	5d                   	pop    %ebp
  800dd4:	c3                   	ret    
  800dd5:	8d 76 00             	lea    0x0(%esi),%esi
  800dd8:	39 df                	cmp    %ebx,%edi
  800dda:	77 f1                	ja     800dcd <__umoddi3+0x2d>
  800ddc:	0f bd cf             	bsr    %edi,%ecx
  800ddf:	83 f1 1f             	xor    $0x1f,%ecx
  800de2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800de6:	75 40                	jne    800e28 <__umoddi3+0x88>
  800de8:	39 df                	cmp    %ebx,%edi
  800dea:	72 04                	jb     800df0 <__umoddi3+0x50>
  800dec:	39 f5                	cmp    %esi,%ebp
  800dee:	77 dd                	ja     800dcd <__umoddi3+0x2d>
  800df0:	89 da                	mov    %ebx,%edx
  800df2:	89 f0                	mov    %esi,%eax
  800df4:	29 e8                	sub    %ebp,%eax
  800df6:	19 fa                	sbb    %edi,%edx
  800df8:	eb d3                	jmp    800dcd <__umoddi3+0x2d>
  800dfa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e00:	89 e9                	mov    %ebp,%ecx
  800e02:	85 ed                	test   %ebp,%ebp
  800e04:	75 0b                	jne    800e11 <__umoddi3+0x71>
  800e06:	b8 01 00 00 00       	mov    $0x1,%eax
  800e0b:	31 d2                	xor    %edx,%edx
  800e0d:	f7 f5                	div    %ebp
  800e0f:	89 c1                	mov    %eax,%ecx
  800e11:	89 d8                	mov    %ebx,%eax
  800e13:	31 d2                	xor    %edx,%edx
  800e15:	f7 f1                	div    %ecx
  800e17:	89 f0                	mov    %esi,%eax
  800e19:	f7 f1                	div    %ecx
  800e1b:	89 d0                	mov    %edx,%eax
  800e1d:	31 d2                	xor    %edx,%edx
  800e1f:	eb ac                	jmp    800dcd <__umoddi3+0x2d>
  800e21:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e28:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e2c:	ba 20 00 00 00       	mov    $0x20,%edx
  800e31:	29 c2                	sub    %eax,%edx
  800e33:	89 c1                	mov    %eax,%ecx
  800e35:	89 e8                	mov    %ebp,%eax
  800e37:	d3 e7                	shl    %cl,%edi
  800e39:	89 d1                	mov    %edx,%ecx
  800e3b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e3f:	d3 e8                	shr    %cl,%eax
  800e41:	89 c1                	mov    %eax,%ecx
  800e43:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e47:	09 f9                	or     %edi,%ecx
  800e49:	89 df                	mov    %ebx,%edi
  800e4b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e4f:	89 c1                	mov    %eax,%ecx
  800e51:	d3 e5                	shl    %cl,%ebp
  800e53:	89 d1                	mov    %edx,%ecx
  800e55:	d3 ef                	shr    %cl,%edi
  800e57:	89 c1                	mov    %eax,%ecx
  800e59:	89 f0                	mov    %esi,%eax
  800e5b:	d3 e3                	shl    %cl,%ebx
  800e5d:	89 d1                	mov    %edx,%ecx
  800e5f:	89 fa                	mov    %edi,%edx
  800e61:	d3 e8                	shr    %cl,%eax
  800e63:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e68:	09 d8                	or     %ebx,%eax
  800e6a:	f7 74 24 08          	divl   0x8(%esp)
  800e6e:	89 d3                	mov    %edx,%ebx
  800e70:	d3 e6                	shl    %cl,%esi
  800e72:	f7 e5                	mul    %ebp
  800e74:	89 c7                	mov    %eax,%edi
  800e76:	89 d1                	mov    %edx,%ecx
  800e78:	39 d3                	cmp    %edx,%ebx
  800e7a:	72 06                	jb     800e82 <__umoddi3+0xe2>
  800e7c:	75 0e                	jne    800e8c <__umoddi3+0xec>
  800e7e:	39 c6                	cmp    %eax,%esi
  800e80:	73 0a                	jae    800e8c <__umoddi3+0xec>
  800e82:	29 e8                	sub    %ebp,%eax
  800e84:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800e88:	89 d1                	mov    %edx,%ecx
  800e8a:	89 c7                	mov    %eax,%edi
  800e8c:	89 f5                	mov    %esi,%ebp
  800e8e:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e92:	29 fd                	sub    %edi,%ebp
  800e94:	19 cb                	sbb    %ecx,%ebx
  800e96:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800e9b:	89 d8                	mov    %ebx,%eax
  800e9d:	d3 e0                	shl    %cl,%eax
  800e9f:	89 f1                	mov    %esi,%ecx
  800ea1:	d3 ed                	shr    %cl,%ebp
  800ea3:	d3 eb                	shr    %cl,%ebx
  800ea5:	09 e8                	or     %ebp,%eax
  800ea7:	89 da                	mov    %ebx,%edx
  800ea9:	83 c4 1c             	add    $0x1c,%esp
  800eac:	5b                   	pop    %ebx
  800ead:	5e                   	pop    %esi
  800eae:	5f                   	pop    %edi
  800eaf:	5d                   	pop    %ebp
  800eb0:	c3                   	ret    
