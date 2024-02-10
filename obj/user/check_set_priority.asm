
obj/user/check_set_priority:     formato del fichero elf32-i386


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
  80002c:	e8 27 00 00 00       	call   800058 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#define PRIORITY 79

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	sys_set_priority(PRIORITY);
  800039:	6a 4f                	push   $0x4f
  80003b:	e8 a7 0b 00 00       	call   800be7 <sys_set_priority>

	cprintf("La prioridad deberia ser 79 y es: %d\n", sys_get_priority());
  800040:	e8 7e 0b 00 00       	call   800bc3 <sys_get_priority>
  800045:	83 c4 08             	add    $0x8,%esp
  800048:	50                   	push   %eax
  800049:	68 a0 0e 80 00       	push   $0x800ea0
  80004e:	e8 f9 00 00 00       	call   80014c <cprintf>
  800053:	83 c4 10             	add    $0x10,%esp
  800056:	c9                   	leave  
  800057:	c3                   	ret    

00800058 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800058:	55                   	push   %ebp
  800059:	89 e5                	mov    %esp,%ebp
  80005b:	56                   	push   %esi
  80005c:	53                   	push   %ebx
  80005d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800060:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	envid_t id = sys_getenvid();
  800063:	e8 16 0a 00 00       	call   800a7e <sys_getenvid>
	if (id >= 0)
  800068:	85 c0                	test   %eax,%eax
  80006a:	78 15                	js     800081 <libmain+0x29>
		thisenv = &envs[ENVX(id)];
  80006c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800071:	69 c0 88 00 00 00    	imul   $0x88,%eax,%eax
  800077:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007c:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800081:	85 db                	test   %ebx,%ebx
  800083:	7e 07                	jle    80008c <libmain+0x34>
		binaryname = argv[0];
  800085:	8b 06                	mov    (%esi),%eax
  800087:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80008c:	83 ec 08             	sub    $0x8,%esp
  80008f:	56                   	push   %esi
  800090:	53                   	push   %ebx
  800091:	e8 9d ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800096:	e8 0a 00 00 00       	call   8000a5 <exit>
}
  80009b:	83 c4 10             	add    $0x10,%esp
  80009e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a1:	5b                   	pop    %ebx
  8000a2:	5e                   	pop    %esi
  8000a3:	5d                   	pop    %ebp
  8000a4:	c3                   	ret    

008000a5 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a5:	55                   	push   %ebp
  8000a6:	89 e5                	mov    %esp,%ebp
  8000a8:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000ab:	6a 00                	push   $0x0
  8000ad:	e8 aa 09 00 00       	call   800a5c <sys_env_destroy>
}
  8000b2:	83 c4 10             	add    $0x10,%esp
  8000b5:	c9                   	leave  
  8000b6:	c3                   	ret    

008000b7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000b7:	55                   	push   %ebp
  8000b8:	89 e5                	mov    %esp,%ebp
  8000ba:	53                   	push   %ebx
  8000bb:	83 ec 04             	sub    $0x4,%esp
  8000be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c1:	8b 13                	mov    (%ebx),%edx
  8000c3:	8d 42 01             	lea    0x1(%edx),%eax
  8000c6:	89 03                	mov    %eax,(%ebx)
  8000c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000cb:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256 - 1) {
  8000cf:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000d4:	74 09                	je     8000df <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000d6:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000dd:	c9                   	leave  
  8000de:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8000df:	83 ec 08             	sub    $0x8,%esp
  8000e2:	68 ff 00 00 00       	push   $0xff
  8000e7:	8d 43 08             	lea    0x8(%ebx),%eax
  8000ea:	50                   	push   %eax
  8000eb:	e8 22 09 00 00       	call   800a12 <sys_cputs>
		b->idx = 0;
  8000f0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000f6:	83 c4 10             	add    $0x10,%esp
  8000f9:	eb db                	jmp    8000d6 <putch+0x1f>

008000fb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800104:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80010b:	00 00 00 
	b.cnt = 0;
  80010e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800115:	00 00 00 
	vprintfmt((void *) putch, &b, fmt, ap);
  800118:	ff 75 0c             	push   0xc(%ebp)
  80011b:	ff 75 08             	push   0x8(%ebp)
  80011e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800124:	50                   	push   %eax
  800125:	68 b7 00 80 00       	push   $0x8000b7
  80012a:	e8 74 01 00 00       	call   8002a3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80012f:	83 c4 08             	add    $0x8,%esp
  800132:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800138:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80013e:	50                   	push   %eax
  80013f:	e8 ce 08 00 00       	call   800a12 <sys_cputs>

	return b.cnt;
}
  800144:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80014a:	c9                   	leave  
  80014b:	c3                   	ret    

0080014c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800152:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800155:	50                   	push   %eax
  800156:	ff 75 08             	push   0x8(%ebp)
  800159:	e8 9d ff ff ff       	call   8000fb <vcprintf>
	va_end(ap);

	return cnt;
}
  80015e:	c9                   	leave  
  80015f:	c3                   	ret    

00800160 <printnum>:
         void *putdat,
         unsigned long long num,
         unsigned base,
         int width,
         int padc)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	57                   	push   %edi
  800164:	56                   	push   %esi
  800165:	53                   	push   %ebx
  800166:	83 ec 1c             	sub    $0x1c,%esp
  800169:	89 c7                	mov    %eax,%edi
  80016b:	89 d6                	mov    %edx,%esi
  80016d:	8b 45 08             	mov    0x8(%ebp),%eax
  800170:	8b 55 0c             	mov    0xc(%ebp),%edx
  800173:	89 d1                	mov    %edx,%ecx
  800175:	89 c2                	mov    %eax,%edx
  800177:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80017a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80017d:	8b 45 10             	mov    0x10(%ebp),%eax
  800180:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800183:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800186:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80018d:	39 c2                	cmp    %eax,%edx
  80018f:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800192:	72 3e                	jb     8001d2 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800194:	83 ec 0c             	sub    $0xc,%esp
  800197:	ff 75 18             	push   0x18(%ebp)
  80019a:	83 eb 01             	sub    $0x1,%ebx
  80019d:	53                   	push   %ebx
  80019e:	50                   	push   %eax
  80019f:	83 ec 08             	sub    $0x8,%esp
  8001a2:	ff 75 e4             	push   -0x1c(%ebp)
  8001a5:	ff 75 e0             	push   -0x20(%ebp)
  8001a8:	ff 75 dc             	push   -0x24(%ebp)
  8001ab:	ff 75 d8             	push   -0x28(%ebp)
  8001ae:	e8 9d 0a 00 00       	call   800c50 <__udivdi3>
  8001b3:	83 c4 18             	add    $0x18,%esp
  8001b6:	52                   	push   %edx
  8001b7:	50                   	push   %eax
  8001b8:	89 f2                	mov    %esi,%edx
  8001ba:	89 f8                	mov    %edi,%eax
  8001bc:	e8 9f ff ff ff       	call   800160 <printnum>
  8001c1:	83 c4 20             	add    $0x20,%esp
  8001c4:	eb 13                	jmp    8001d9 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001c6:	83 ec 08             	sub    $0x8,%esp
  8001c9:	56                   	push   %esi
  8001ca:	ff 75 18             	push   0x18(%ebp)
  8001cd:	ff d7                	call   *%edi
  8001cf:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001d2:	83 eb 01             	sub    $0x1,%ebx
  8001d5:	85 db                	test   %ebx,%ebx
  8001d7:	7f ed                	jg     8001c6 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001d9:	83 ec 08             	sub    $0x8,%esp
  8001dc:	56                   	push   %esi
  8001dd:	83 ec 04             	sub    $0x4,%esp
  8001e0:	ff 75 e4             	push   -0x1c(%ebp)
  8001e3:	ff 75 e0             	push   -0x20(%ebp)
  8001e6:	ff 75 dc             	push   -0x24(%ebp)
  8001e9:	ff 75 d8             	push   -0x28(%ebp)
  8001ec:	e8 7f 0b 00 00       	call   800d70 <__umoddi3>
  8001f1:	83 c4 14             	add    $0x14,%esp
  8001f4:	0f be 80 d0 0e 80 00 	movsbl 0x800ed0(%eax),%eax
  8001fb:	50                   	push   %eax
  8001fc:	ff d7                	call   *%edi
}
  8001fe:	83 c4 10             	add    $0x10,%esp
  800201:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800204:	5b                   	pop    %ebx
  800205:	5e                   	pop    %esi
  800206:	5f                   	pop    %edi
  800207:	5d                   	pop    %ebp
  800208:	c3                   	ret    

00800209 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800209:	83 fa 01             	cmp    $0x1,%edx
  80020c:	7f 13                	jg     800221 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80020e:	85 d2                	test   %edx,%edx
  800210:	74 1c                	je     80022e <getuint+0x25>
		return va_arg(*ap, unsigned long);
  800212:	8b 10                	mov    (%eax),%edx
  800214:	8d 4a 04             	lea    0x4(%edx),%ecx
  800217:	89 08                	mov    %ecx,(%eax)
  800219:	8b 02                	mov    (%edx),%eax
  80021b:	ba 00 00 00 00       	mov    $0x0,%edx
  800220:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  800221:	8b 10                	mov    (%eax),%edx
  800223:	8d 4a 08             	lea    0x8(%edx),%ecx
  800226:	89 08                	mov    %ecx,(%eax)
  800228:	8b 02                	mov    (%edx),%eax
  80022a:	8b 52 04             	mov    0x4(%edx),%edx
  80022d:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  80022e:	8b 10                	mov    (%eax),%edx
  800230:	8d 4a 04             	lea    0x4(%edx),%ecx
  800233:	89 08                	mov    %ecx,(%eax)
  800235:	8b 02                	mov    (%edx),%eax
  800237:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80023c:	c3                   	ret    

0080023d <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80023d:	83 fa 01             	cmp    $0x1,%edx
  800240:	7f 0f                	jg     800251 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  800242:	85 d2                	test   %edx,%edx
  800244:	74 18                	je     80025e <getint+0x21>
		return va_arg(*ap, long);
  800246:	8b 10                	mov    (%eax),%edx
  800248:	8d 4a 04             	lea    0x4(%edx),%ecx
  80024b:	89 08                	mov    %ecx,(%eax)
  80024d:	8b 02                	mov    (%edx),%eax
  80024f:	99                   	cltd   
  800250:	c3                   	ret    
		return va_arg(*ap, long long);
  800251:	8b 10                	mov    (%eax),%edx
  800253:	8d 4a 08             	lea    0x8(%edx),%ecx
  800256:	89 08                	mov    %ecx,(%eax)
  800258:	8b 02                	mov    (%edx),%eax
  80025a:	8b 52 04             	mov    0x4(%edx),%edx
  80025d:	c3                   	ret    
	else
		return va_arg(*ap, int);
  80025e:	8b 10                	mov    (%eax),%edx
  800260:	8d 4a 04             	lea    0x4(%edx),%ecx
  800263:	89 08                	mov    %ecx,(%eax)
  800265:	8b 02                	mov    (%edx),%eax
  800267:	99                   	cltd   
}
  800268:	c3                   	ret    

00800269 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800269:	55                   	push   %ebp
  80026a:	89 e5                	mov    %esp,%ebp
  80026c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80026f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800273:	8b 10                	mov    (%eax),%edx
  800275:	3b 50 04             	cmp    0x4(%eax),%edx
  800278:	73 0a                	jae    800284 <sprintputch+0x1b>
		*b->buf++ = ch;
  80027a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80027d:	89 08                	mov    %ecx,(%eax)
  80027f:	8b 45 08             	mov    0x8(%ebp),%eax
  800282:	88 02                	mov    %al,(%edx)
}
  800284:	5d                   	pop    %ebp
  800285:	c3                   	ret    

00800286 <printfmt>:
{
  800286:	55                   	push   %ebp
  800287:	89 e5                	mov    %esp,%ebp
  800289:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80028c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80028f:	50                   	push   %eax
  800290:	ff 75 10             	push   0x10(%ebp)
  800293:	ff 75 0c             	push   0xc(%ebp)
  800296:	ff 75 08             	push   0x8(%ebp)
  800299:	e8 05 00 00 00       	call   8002a3 <vprintfmt>
}
  80029e:	83 c4 10             	add    $0x10,%esp
  8002a1:	c9                   	leave  
  8002a2:	c3                   	ret    

008002a3 <vprintfmt>:
{
  8002a3:	55                   	push   %ebp
  8002a4:	89 e5                	mov    %esp,%ebp
  8002a6:	57                   	push   %edi
  8002a7:	56                   	push   %esi
  8002a8:	53                   	push   %ebx
  8002a9:	83 ec 2c             	sub    $0x2c,%esp
  8002ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002af:	8b 75 0c             	mov    0xc(%ebp),%esi
  8002b2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002b5:	eb 0a                	jmp    8002c1 <vprintfmt+0x1e>
			putch(ch, putdat);
  8002b7:	83 ec 08             	sub    $0x8,%esp
  8002ba:	56                   	push   %esi
  8002bb:	50                   	push   %eax
  8002bc:	ff d3                	call   *%ebx
  8002be:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002c1:	83 c7 01             	add    $0x1,%edi
  8002c4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002c8:	83 f8 25             	cmp    $0x25,%eax
  8002cb:	74 0c                	je     8002d9 <vprintfmt+0x36>
			if (ch == '\0')
  8002cd:	85 c0                	test   %eax,%eax
  8002cf:	75 e6                	jne    8002b7 <vprintfmt+0x14>
}
  8002d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d4:	5b                   	pop    %ebx
  8002d5:	5e                   	pop    %esi
  8002d6:	5f                   	pop    %edi
  8002d7:	5d                   	pop    %ebp
  8002d8:	c3                   	ret    
		padc = ' ';
  8002d9:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
		altflag = 0;
  8002dd:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002e4:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002eb:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002f2:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002f7:	8d 47 01             	lea    0x1(%edi),%eax
  8002fa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002fd:	0f b6 17             	movzbl (%edi),%edx
  800300:	8d 42 dd             	lea    -0x23(%edx),%eax
  800303:	3c 55                	cmp    $0x55,%al
  800305:	0f 87 b7 02 00 00    	ja     8005c2 <vprintfmt+0x31f>
  80030b:	0f b6 c0             	movzbl %al,%eax
  80030e:	ff 24 85 a0 0f 80 00 	jmp    *0x800fa0(,%eax,4)
  800315:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800318:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  80031c:	eb d9                	jmp    8002f7 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80031e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800321:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800325:	eb d0                	jmp    8002f7 <vprintfmt+0x54>
  800327:	0f b6 d2             	movzbl %dl,%edx
  80032a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0;; ++fmt) {
  80032d:	b8 00 00 00 00       	mov    $0x0,%eax
  800332:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800335:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800338:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80033c:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80033f:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800342:	83 f9 09             	cmp    $0x9,%ecx
  800345:	77 52                	ja     800399 <vprintfmt+0xf6>
			for (precision = 0;; ++fmt) {
  800347:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80034a:	eb e9                	jmp    800335 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  80034c:	8b 45 14             	mov    0x14(%ebp),%eax
  80034f:	8d 50 04             	lea    0x4(%eax),%edx
  800352:	89 55 14             	mov    %edx,0x14(%ebp)
  800355:	8b 00                	mov    (%eax),%eax
  800357:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80035a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80035d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800361:	79 94                	jns    8002f7 <vprintfmt+0x54>
				width = precision, precision = -1;
  800363:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800366:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800369:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800370:	eb 85                	jmp    8002f7 <vprintfmt+0x54>
  800372:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800375:	85 d2                	test   %edx,%edx
  800377:	b8 00 00 00 00       	mov    $0x0,%eax
  80037c:	0f 49 c2             	cmovns %edx,%eax
  80037f:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800382:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800385:	e9 6d ff ff ff       	jmp    8002f7 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80038a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80038d:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800394:	e9 5e ff ff ff       	jmp    8002f7 <vprintfmt+0x54>
  800399:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80039c:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80039f:	eb bc                	jmp    80035d <vprintfmt+0xba>
			lflag++;
  8003a1:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003a7:	e9 4b ff ff ff       	jmp    8002f7 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8003ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8003af:	8d 50 04             	lea    0x4(%eax),%edx
  8003b2:	89 55 14             	mov    %edx,0x14(%ebp)
  8003b5:	83 ec 08             	sub    $0x8,%esp
  8003b8:	56                   	push   %esi
  8003b9:	ff 30                	push   (%eax)
  8003bb:	ff d3                	call   *%ebx
			break;
  8003bd:	83 c4 10             	add    $0x10,%esp
  8003c0:	e9 94 01 00 00       	jmp    800559 <vprintfmt+0x2b6>
			err = va_arg(ap, int);
  8003c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c8:	8d 50 04             	lea    0x4(%eax),%edx
  8003cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ce:	8b 10                	mov    (%eax),%edx
  8003d0:	89 d0                	mov    %edx,%eax
  8003d2:	f7 d8                	neg    %eax
  8003d4:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003d7:	83 f8 08             	cmp    $0x8,%eax
  8003da:	7f 20                	jg     8003fc <vprintfmt+0x159>
  8003dc:	8b 14 85 00 11 80 00 	mov    0x801100(,%eax,4),%edx
  8003e3:	85 d2                	test   %edx,%edx
  8003e5:	74 15                	je     8003fc <vprintfmt+0x159>
				printfmt(putch, putdat, "%s", p);
  8003e7:	52                   	push   %edx
  8003e8:	68 f1 0e 80 00       	push   $0x800ef1
  8003ed:	56                   	push   %esi
  8003ee:	53                   	push   %ebx
  8003ef:	e8 92 fe ff ff       	call   800286 <printfmt>
  8003f4:	83 c4 10             	add    $0x10,%esp
  8003f7:	e9 5d 01 00 00       	jmp    800559 <vprintfmt+0x2b6>
				printfmt(putch, putdat, "error %d", err);
  8003fc:	50                   	push   %eax
  8003fd:	68 e8 0e 80 00       	push   $0x800ee8
  800402:	56                   	push   %esi
  800403:	53                   	push   %ebx
  800404:	e8 7d fe ff ff       	call   800286 <printfmt>
  800409:	83 c4 10             	add    $0x10,%esp
  80040c:	e9 48 01 00 00       	jmp    800559 <vprintfmt+0x2b6>
			if ((p = va_arg(ap, char *)) == NULL)
  800411:	8b 45 14             	mov    0x14(%ebp),%eax
  800414:	8d 50 04             	lea    0x4(%eax),%edx
  800417:	89 55 14             	mov    %edx,0x14(%ebp)
  80041a:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80041c:	85 ff                	test   %edi,%edi
  80041e:	b8 e1 0e 80 00       	mov    $0x800ee1,%eax
  800423:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800426:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80042a:	7e 06                	jle    800432 <vprintfmt+0x18f>
  80042c:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  800430:	75 0a                	jne    80043c <vprintfmt+0x199>
  800432:	89 f8                	mov    %edi,%eax
  800434:	03 45 e0             	add    -0x20(%ebp),%eax
  800437:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80043a:	eb 59                	jmp    800495 <vprintfmt+0x1f2>
				for (width -= strnlen(p, precision); width > 0;
  80043c:	83 ec 08             	sub    $0x8,%esp
  80043f:	ff 75 d8             	push   -0x28(%ebp)
  800442:	57                   	push   %edi
  800443:	e8 1a 02 00 00       	call   800662 <strnlen>
  800448:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80044b:	29 c1                	sub    %eax,%ecx
  80044d:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800450:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800453:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  800457:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80045a:	89 7d d0             	mov    %edi,-0x30(%ebp)
  80045d:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0;
  80045f:	eb 0f                	jmp    800470 <vprintfmt+0x1cd>
					putch(padc, putdat);
  800461:	83 ec 08             	sub    $0x8,%esp
  800464:	56                   	push   %esi
  800465:	ff 75 e0             	push   -0x20(%ebp)
  800468:	ff d3                	call   *%ebx
				     width--)
  80046a:	83 ef 01             	sub    $0x1,%edi
  80046d:	83 c4 10             	add    $0x10,%esp
				for (width -= strnlen(p, precision); width > 0;
  800470:	85 ff                	test   %edi,%edi
  800472:	7f ed                	jg     800461 <vprintfmt+0x1be>
  800474:	8b 7d d0             	mov    -0x30(%ebp),%edi
  800477:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80047a:	85 c9                	test   %ecx,%ecx
  80047c:	b8 00 00 00 00       	mov    $0x0,%eax
  800481:	0f 49 c1             	cmovns %ecx,%eax
  800484:	29 c1                	sub    %eax,%ecx
  800486:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800489:	eb a7                	jmp    800432 <vprintfmt+0x18f>
					putch(ch, putdat);
  80048b:	83 ec 08             	sub    $0x8,%esp
  80048e:	56                   	push   %esi
  80048f:	52                   	push   %edx
  800490:	ff d3                	call   *%ebx
  800492:	83 c4 10             	add    $0x10,%esp
  800495:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800498:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' &&
  80049a:	83 c7 01             	add    $0x1,%edi
  80049d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004a1:	0f be d0             	movsbl %al,%edx
  8004a4:	85 d2                	test   %edx,%edx
  8004a6:	74 42                	je     8004ea <vprintfmt+0x247>
  8004a8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004ac:	78 06                	js     8004b4 <vprintfmt+0x211>
			       (precision < 0 || --precision >= 0);
  8004ae:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004b2:	78 1e                	js     8004d2 <vprintfmt+0x22f>
				if (altflag && (ch < ' ' || ch > '~'))
  8004b4:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004b8:	74 d1                	je     80048b <vprintfmt+0x1e8>
  8004ba:	0f be c0             	movsbl %al,%eax
  8004bd:	83 e8 20             	sub    $0x20,%eax
  8004c0:	83 f8 5e             	cmp    $0x5e,%eax
  8004c3:	76 c6                	jbe    80048b <vprintfmt+0x1e8>
					putch('?', putdat);
  8004c5:	83 ec 08             	sub    $0x8,%esp
  8004c8:	56                   	push   %esi
  8004c9:	6a 3f                	push   $0x3f
  8004cb:	ff d3                	call   *%ebx
  8004cd:	83 c4 10             	add    $0x10,%esp
  8004d0:	eb c3                	jmp    800495 <vprintfmt+0x1f2>
  8004d2:	89 cf                	mov    %ecx,%edi
  8004d4:	eb 0e                	jmp    8004e4 <vprintfmt+0x241>
				putch(' ', putdat);
  8004d6:	83 ec 08             	sub    $0x8,%esp
  8004d9:	56                   	push   %esi
  8004da:	6a 20                	push   $0x20
  8004dc:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  8004de:	83 ef 01             	sub    $0x1,%edi
  8004e1:	83 c4 10             	add    $0x10,%esp
  8004e4:	85 ff                	test   %edi,%edi
  8004e6:	7f ee                	jg     8004d6 <vprintfmt+0x233>
  8004e8:	eb 6f                	jmp    800559 <vprintfmt+0x2b6>
  8004ea:	89 cf                	mov    %ecx,%edi
  8004ec:	eb f6                	jmp    8004e4 <vprintfmt+0x241>
			num = getint(&ap, lflag);
  8004ee:	89 ca                	mov    %ecx,%edx
  8004f0:	8d 45 14             	lea    0x14(%ebp),%eax
  8004f3:	e8 45 fd ff ff       	call   80023d <getint>
  8004f8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004fb:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  8004fe:	85 d2                	test   %edx,%edx
  800500:	78 0b                	js     80050d <vprintfmt+0x26a>
			num = getint(&ap, lflag);
  800502:	89 d1                	mov    %edx,%ecx
  800504:	89 c2                	mov    %eax,%edx
			base = 10;
  800506:	bf 0a 00 00 00       	mov    $0xa,%edi
  80050b:	eb 32                	jmp    80053f <vprintfmt+0x29c>
				putch('-', putdat);
  80050d:	83 ec 08             	sub    $0x8,%esp
  800510:	56                   	push   %esi
  800511:	6a 2d                	push   $0x2d
  800513:	ff d3                	call   *%ebx
				num = -(long long) num;
  800515:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800518:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80051b:	f7 da                	neg    %edx
  80051d:	83 d1 00             	adc    $0x0,%ecx
  800520:	f7 d9                	neg    %ecx
  800522:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800525:	bf 0a 00 00 00       	mov    $0xa,%edi
  80052a:	eb 13                	jmp    80053f <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  80052c:	89 ca                	mov    %ecx,%edx
  80052e:	8d 45 14             	lea    0x14(%ebp),%eax
  800531:	e8 d3 fc ff ff       	call   800209 <getuint>
  800536:	89 d1                	mov    %edx,%ecx
  800538:	89 c2                	mov    %eax,%edx
			base = 10;
  80053a:	bf 0a 00 00 00       	mov    $0xa,%edi
			printnum(putch, putdat, num, base, width, padc);
  80053f:	83 ec 0c             	sub    $0xc,%esp
  800542:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  800546:	50                   	push   %eax
  800547:	ff 75 e0             	push   -0x20(%ebp)
  80054a:	57                   	push   %edi
  80054b:	51                   	push   %ecx
  80054c:	52                   	push   %edx
  80054d:	89 f2                	mov    %esi,%edx
  80054f:	89 d8                	mov    %ebx,%eax
  800551:	e8 0a fc ff ff       	call   800160 <printnum>
			break;
  800556:	83 c4 20             	add    $0x20,%esp
{
  800559:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80055c:	e9 60 fd ff ff       	jmp    8002c1 <vprintfmt+0x1e>
			num = getuint(&ap, lflag);
  800561:	89 ca                	mov    %ecx,%edx
  800563:	8d 45 14             	lea    0x14(%ebp),%eax
  800566:	e8 9e fc ff ff       	call   800209 <getuint>
  80056b:	89 d1                	mov    %edx,%ecx
  80056d:	89 c2                	mov    %eax,%edx
			base = 8;
  80056f:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  800574:	eb c9                	jmp    80053f <vprintfmt+0x29c>
			putch('0', putdat);
  800576:	83 ec 08             	sub    $0x8,%esp
  800579:	56                   	push   %esi
  80057a:	6a 30                	push   $0x30
  80057c:	ff d3                	call   *%ebx
			putch('x', putdat);
  80057e:	83 c4 08             	add    $0x8,%esp
  800581:	56                   	push   %esi
  800582:	6a 78                	push   $0x78
  800584:	ff d3                	call   *%ebx
			num = (unsigned long long) (uintptr_t) va_arg(ap, void *);
  800586:	8b 45 14             	mov    0x14(%ebp),%eax
  800589:	8d 50 04             	lea    0x4(%eax),%edx
  80058c:	89 55 14             	mov    %edx,0x14(%ebp)
  80058f:	8b 10                	mov    (%eax),%edx
  800591:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800596:	83 c4 10             	add    $0x10,%esp
			base = 16;
  800599:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  80059e:	eb 9f                	jmp    80053f <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  8005a0:	89 ca                	mov    %ecx,%edx
  8005a2:	8d 45 14             	lea    0x14(%ebp),%eax
  8005a5:	e8 5f fc ff ff       	call   800209 <getuint>
  8005aa:	89 d1                	mov    %edx,%ecx
  8005ac:	89 c2                	mov    %eax,%edx
			base = 16;
  8005ae:	bf 10 00 00 00       	mov    $0x10,%edi
  8005b3:	eb 8a                	jmp    80053f <vprintfmt+0x29c>
			putch(ch, putdat);
  8005b5:	83 ec 08             	sub    $0x8,%esp
  8005b8:	56                   	push   %esi
  8005b9:	6a 25                	push   $0x25
  8005bb:	ff d3                	call   *%ebx
			break;
  8005bd:	83 c4 10             	add    $0x10,%esp
  8005c0:	eb 97                	jmp    800559 <vprintfmt+0x2b6>
			putch('%', putdat);
  8005c2:	83 ec 08             	sub    $0x8,%esp
  8005c5:	56                   	push   %esi
  8005c6:	6a 25                	push   $0x25
  8005c8:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  8005ca:	83 c4 10             	add    $0x10,%esp
  8005cd:	89 f8                	mov    %edi,%eax
  8005cf:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8005d3:	74 05                	je     8005da <vprintfmt+0x337>
  8005d5:	83 e8 01             	sub    $0x1,%eax
  8005d8:	eb f5                	jmp    8005cf <vprintfmt+0x32c>
  8005da:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005dd:	e9 77 ff ff ff       	jmp    800559 <vprintfmt+0x2b6>

008005e2 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8005e2:	55                   	push   %ebp
  8005e3:	89 e5                	mov    %esp,%ebp
  8005e5:	83 ec 18             	sub    $0x18,%esp
  8005e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8005eb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = { buf, buf + n - 1, 0 };
  8005ee:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8005f1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8005f5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8005f8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8005ff:	85 c0                	test   %eax,%eax
  800601:	74 26                	je     800629 <vsnprintf+0x47>
  800603:	85 d2                	test   %edx,%edx
  800605:	7e 22                	jle    800629 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *) sprintputch, &b, fmt, ap);
  800607:	ff 75 14             	push   0x14(%ebp)
  80060a:	ff 75 10             	push   0x10(%ebp)
  80060d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800610:	50                   	push   %eax
  800611:	68 69 02 80 00       	push   $0x800269
  800616:	e8 88 fc ff ff       	call   8002a3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80061b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80061e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800621:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800624:	83 c4 10             	add    $0x10,%esp
}
  800627:	c9                   	leave  
  800628:	c3                   	ret    
		return -E_INVAL;
  800629:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80062e:	eb f7                	jmp    800627 <vsnprintf+0x45>

00800630 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800630:	55                   	push   %ebp
  800631:	89 e5                	mov    %esp,%ebp
  800633:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800636:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800639:	50                   	push   %eax
  80063a:	ff 75 10             	push   0x10(%ebp)
  80063d:	ff 75 0c             	push   0xc(%ebp)
  800640:	ff 75 08             	push   0x8(%ebp)
  800643:	e8 9a ff ff ff       	call   8005e2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800648:	c9                   	leave  
  800649:	c3                   	ret    

0080064a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80064a:	55                   	push   %ebp
  80064b:	89 e5                	mov    %esp,%ebp
  80064d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800650:	b8 00 00 00 00       	mov    $0x0,%eax
  800655:	eb 03                	jmp    80065a <strlen+0x10>
		n++;
  800657:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80065a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80065e:	75 f7                	jne    800657 <strlen+0xd>
	return n;
}
  800660:	5d                   	pop    %ebp
  800661:	c3                   	ret    

00800662 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800662:	55                   	push   %ebp
  800663:	89 e5                	mov    %esp,%ebp
  800665:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800668:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80066b:	b8 00 00 00 00       	mov    $0x0,%eax
  800670:	eb 03                	jmp    800675 <strnlen+0x13>
		n++;
  800672:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800675:	39 d0                	cmp    %edx,%eax
  800677:	74 08                	je     800681 <strnlen+0x1f>
  800679:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80067d:	75 f3                	jne    800672 <strnlen+0x10>
  80067f:	89 c2                	mov    %eax,%edx
	return n;
}
  800681:	89 d0                	mov    %edx,%eax
  800683:	5d                   	pop    %ebp
  800684:	c3                   	ret    

00800685 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800685:	55                   	push   %ebp
  800686:	89 e5                	mov    %esp,%ebp
  800688:	53                   	push   %ebx
  800689:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80068c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80068f:	b8 00 00 00 00       	mov    $0x0,%eax
  800694:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800698:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  80069b:	83 c0 01             	add    $0x1,%eax
  80069e:	84 d2                	test   %dl,%dl
  8006a0:	75 f2                	jne    800694 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8006a2:	89 c8                	mov    %ecx,%eax
  8006a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006a7:	c9                   	leave  
  8006a8:	c3                   	ret    

008006a9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8006a9:	55                   	push   %ebp
  8006aa:	89 e5                	mov    %esp,%ebp
  8006ac:	53                   	push   %ebx
  8006ad:	83 ec 10             	sub    $0x10,%esp
  8006b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8006b3:	53                   	push   %ebx
  8006b4:	e8 91 ff ff ff       	call   80064a <strlen>
  8006b9:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8006bc:	ff 75 0c             	push   0xc(%ebp)
  8006bf:	01 d8                	add    %ebx,%eax
  8006c1:	50                   	push   %eax
  8006c2:	e8 be ff ff ff       	call   800685 <strcpy>
	return dst;
}
  8006c7:	89 d8                	mov    %ebx,%eax
  8006c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006cc:	c9                   	leave  
  8006cd:	c3                   	ret    

008006ce <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size)
{
  8006ce:	55                   	push   %ebp
  8006cf:	89 e5                	mov    %esp,%ebp
  8006d1:	56                   	push   %esi
  8006d2:	53                   	push   %ebx
  8006d3:	8b 75 08             	mov    0x8(%ebp),%esi
  8006d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006d9:	89 f3                	mov    %esi,%ebx
  8006db:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8006de:	89 f0                	mov    %esi,%eax
  8006e0:	eb 0f                	jmp    8006f1 <strncpy+0x23>
		*dst++ = *src;
  8006e2:	83 c0 01             	add    $0x1,%eax
  8006e5:	0f b6 0a             	movzbl (%edx),%ecx
  8006e8:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8006eb:	80 f9 01             	cmp    $0x1,%cl
  8006ee:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  8006f1:	39 d8                	cmp    %ebx,%eax
  8006f3:	75 ed                	jne    8006e2 <strncpy+0x14>
	}
	return ret;
}
  8006f5:	89 f0                	mov    %esi,%eax
  8006f7:	5b                   	pop    %ebx
  8006f8:	5e                   	pop    %esi
  8006f9:	5d                   	pop    %ebp
  8006fa:	c3                   	ret    

008006fb <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8006fb:	55                   	push   %ebp
  8006fc:	89 e5                	mov    %esp,%ebp
  8006fe:	56                   	push   %esi
  8006ff:	53                   	push   %ebx
  800700:	8b 75 08             	mov    0x8(%ebp),%esi
  800703:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800706:	8b 55 10             	mov    0x10(%ebp),%edx
  800709:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80070b:	85 d2                	test   %edx,%edx
  80070d:	74 21                	je     800730 <strlcpy+0x35>
  80070f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800713:	89 f2                	mov    %esi,%edx
  800715:	eb 09                	jmp    800720 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800717:	83 c1 01             	add    $0x1,%ecx
  80071a:	83 c2 01             	add    $0x1,%edx
  80071d:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800720:	39 c2                	cmp    %eax,%edx
  800722:	74 09                	je     80072d <strlcpy+0x32>
  800724:	0f b6 19             	movzbl (%ecx),%ebx
  800727:	84 db                	test   %bl,%bl
  800729:	75 ec                	jne    800717 <strlcpy+0x1c>
  80072b:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80072d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800730:	29 f0                	sub    %esi,%eax
}
  800732:	5b                   	pop    %ebx
  800733:	5e                   	pop    %esi
  800734:	5d                   	pop    %ebp
  800735:	c3                   	ret    

00800736 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800736:	55                   	push   %ebp
  800737:	89 e5                	mov    %esp,%ebp
  800739:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80073c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80073f:	eb 06                	jmp    800747 <strcmp+0x11>
		p++, q++;
  800741:	83 c1 01             	add    $0x1,%ecx
  800744:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800747:	0f b6 01             	movzbl (%ecx),%eax
  80074a:	84 c0                	test   %al,%al
  80074c:	74 04                	je     800752 <strcmp+0x1c>
  80074e:	3a 02                	cmp    (%edx),%al
  800750:	74 ef                	je     800741 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800752:	0f b6 c0             	movzbl %al,%eax
  800755:	0f b6 12             	movzbl (%edx),%edx
  800758:	29 d0                	sub    %edx,%eax
}
  80075a:	5d                   	pop    %ebp
  80075b:	c3                   	ret    

0080075c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80075c:	55                   	push   %ebp
  80075d:	89 e5                	mov    %esp,%ebp
  80075f:	53                   	push   %ebx
  800760:	8b 45 08             	mov    0x8(%ebp),%eax
  800763:	8b 55 0c             	mov    0xc(%ebp),%edx
  800766:	89 c3                	mov    %eax,%ebx
  800768:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80076b:	eb 06                	jmp    800773 <strncmp+0x17>
		n--, p++, q++;
  80076d:	83 c0 01             	add    $0x1,%eax
  800770:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800773:	39 d8                	cmp    %ebx,%eax
  800775:	74 18                	je     80078f <strncmp+0x33>
  800777:	0f b6 08             	movzbl (%eax),%ecx
  80077a:	84 c9                	test   %cl,%cl
  80077c:	74 04                	je     800782 <strncmp+0x26>
  80077e:	3a 0a                	cmp    (%edx),%cl
  800780:	74 eb                	je     80076d <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800782:	0f b6 00             	movzbl (%eax),%eax
  800785:	0f b6 12             	movzbl (%edx),%edx
  800788:	29 d0                	sub    %edx,%eax
}
  80078a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80078d:	c9                   	leave  
  80078e:	c3                   	ret    
		return 0;
  80078f:	b8 00 00 00 00       	mov    $0x0,%eax
  800794:	eb f4                	jmp    80078a <strncmp+0x2e>

00800796 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	8b 45 08             	mov    0x8(%ebp),%eax
  80079c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007a0:	eb 03                	jmp    8007a5 <strchr+0xf>
  8007a2:	83 c0 01             	add    $0x1,%eax
  8007a5:	0f b6 10             	movzbl (%eax),%edx
  8007a8:	84 d2                	test   %dl,%dl
  8007aa:	74 06                	je     8007b2 <strchr+0x1c>
		if (*s == c)
  8007ac:	38 ca                	cmp    %cl,%dl
  8007ae:	75 f2                	jne    8007a2 <strchr+0xc>
  8007b0:	eb 05                	jmp    8007b7 <strchr+0x21>
			return (char *) s;
	return 0;
  8007b2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007b7:	5d                   	pop    %ebp
  8007b8:	c3                   	ret    

008007b9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8007b9:	55                   	push   %ebp
  8007ba:	89 e5                	mov    %esp,%ebp
  8007bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bf:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007c3:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8007c6:	38 ca                	cmp    %cl,%dl
  8007c8:	74 09                	je     8007d3 <strfind+0x1a>
  8007ca:	84 d2                	test   %dl,%dl
  8007cc:	74 05                	je     8007d3 <strfind+0x1a>
	for (; *s; s++)
  8007ce:	83 c0 01             	add    $0x1,%eax
  8007d1:	eb f0                	jmp    8007c3 <strfind+0xa>
			break;
	return (char *) s;
}
  8007d3:	5d                   	pop    %ebp
  8007d4:	c3                   	ret    

008007d5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8007d5:	55                   	push   %ebp
  8007d6:	89 e5                	mov    %esp,%ebp
  8007d8:	57                   	push   %edi
  8007d9:	56                   	push   %esi
  8007da:	53                   	push   %ebx
  8007db:	8b 55 08             	mov    0x8(%ebp),%edx
  8007de:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  8007e1:	85 c9                	test   %ecx,%ecx
  8007e3:	74 33                	je     800818 <memset+0x43>
		return v;
	if ((int) v % 4 == 0 && n % 4 == 0) {
  8007e5:	89 d0                	mov    %edx,%eax
  8007e7:	09 c8                	or     %ecx,%eax
  8007e9:	a8 03                	test   $0x3,%al
  8007eb:	75 23                	jne    800810 <memset+0x3b>
		c &= 0xFF;
  8007ed:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  8007f1:	89 d8                	mov    %ebx,%eax
  8007f3:	c1 e0 08             	shl    $0x8,%eax
  8007f6:	89 df                	mov    %ebx,%edi
  8007f8:	c1 e7 18             	shl    $0x18,%edi
  8007fb:	89 de                	mov    %ebx,%esi
  8007fd:	c1 e6 10             	shl    $0x10,%esi
  800800:	09 f7                	or     %esi,%edi
  800802:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
		             : "=D"(p), "=c"(n)
		             : "D"(p), "a"(c), "c"(n / 4)
  800804:	c1 e9 02             	shr    $0x2,%ecx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  800807:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800809:	89 d7                	mov    %edx,%edi
  80080b:	fc                   	cld    
  80080c:	f3 ab                	rep stos %eax,%es:(%edi)
  80080e:	eb 08                	jmp    800818 <memset+0x43>
		             : "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800810:	89 d7                	mov    %edx,%edi
  800812:	8b 45 0c             	mov    0xc(%ebp),%eax
  800815:	fc                   	cld    
  800816:	f3 aa                	rep stos %al,%es:(%edi)
		             : "=D"(p), "=c"(n)
		             : "0"(p), "a"(c), "1"(n)
		             : "cc", "memory");
	return v;
}
  800818:	89 d0                	mov    %edx,%eax
  80081a:	5b                   	pop    %ebx
  80081b:	5e                   	pop    %esi
  80081c:	5f                   	pop    %edi
  80081d:	5d                   	pop    %ebp
  80081e:	c3                   	ret    

0080081f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80081f:	55                   	push   %ebp
  800820:	89 e5                	mov    %esp,%ebp
  800822:	57                   	push   %edi
  800823:	56                   	push   %esi
  800824:	8b 45 08             	mov    0x8(%ebp),%eax
  800827:	8b 75 0c             	mov    0xc(%ebp),%esi
  80082a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80082d:	39 c6                	cmp    %eax,%esi
  80082f:	73 32                	jae    800863 <memmove+0x44>
  800831:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800834:	39 c2                	cmp    %eax,%edx
  800836:	76 2b                	jbe    800863 <memmove+0x44>
		s += n;
		d += n;
  800838:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  80083b:	89 d6                	mov    %edx,%esi
  80083d:	09 fe                	or     %edi,%esi
  80083f:	09 ce                	or     %ecx,%esi
  800841:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800847:	75 0e                	jne    800857 <memmove+0x38>
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  800849:	83 ef 04             	sub    $0x4,%edi
			             "S"(s - 4),
  80084c:	8d 72 fc             	lea    -0x4(%edx),%esi
			             "c"(n / 4)
  80084f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  800852:	fd                   	std    
  800853:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800855:	eb 09                	jmp    800860 <memmove+0x41>
			             : "cc", "memory");
		else
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  800857:	83 ef 01             	sub    $0x1,%edi
			             "S"(s - 1),
  80085a:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  80085d:	fd                   	std    
  80085e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             "c"(n)
			             : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800860:	fc                   	cld    
  800861:	eb 1a                	jmp    80087d <memmove+0x5e>
	} else {
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  800863:	89 f2                	mov    %esi,%edx
  800865:	09 c2                	or     %eax,%edx
  800867:	09 ca                	or     %ecx,%edx
  800869:	f6 c2 03             	test   $0x3,%dl
  80086c:	75 0a                	jne    800878 <memmove+0x59>
			asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  80086e:	c1 e9 02             	shr    $0x2,%ecx
  800871:	89 c7                	mov    %eax,%edi
  800873:	fc                   	cld    
  800874:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800876:	eb 05                	jmp    80087d <memmove+0x5e>
			             : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800878:	89 c7                	mov    %eax,%edi
  80087a:	fc                   	cld    
  80087b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             : "cc", "memory");
	}
	return dst;
}
  80087d:	5e                   	pop    %esi
  80087e:	5f                   	pop    %edi
  80087f:	5d                   	pop    %ebp
  800880:	c3                   	ret    

00800881 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800881:	55                   	push   %ebp
  800882:	89 e5                	mov    %esp,%ebp
  800884:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800887:	ff 75 10             	push   0x10(%ebp)
  80088a:	ff 75 0c             	push   0xc(%ebp)
  80088d:	ff 75 08             	push   0x8(%ebp)
  800890:	e8 8a ff ff ff       	call   80081f <memmove>
}
  800895:	c9                   	leave  
  800896:	c3                   	ret    

00800897 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800897:	55                   	push   %ebp
  800898:	89 e5                	mov    %esp,%ebp
  80089a:	56                   	push   %esi
  80089b:	53                   	push   %ebx
  80089c:	8b 45 08             	mov    0x8(%ebp),%eax
  80089f:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a2:	89 c6                	mov    %eax,%esi
  8008a4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8008a7:	eb 06                	jmp    8008af <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8008a9:	83 c0 01             	add    $0x1,%eax
  8008ac:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  8008af:	39 f0                	cmp    %esi,%eax
  8008b1:	74 14                	je     8008c7 <memcmp+0x30>
		if (*s1 != *s2)
  8008b3:	0f b6 08             	movzbl (%eax),%ecx
  8008b6:	0f b6 1a             	movzbl (%edx),%ebx
  8008b9:	38 d9                	cmp    %bl,%cl
  8008bb:	74 ec                	je     8008a9 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  8008bd:	0f b6 c1             	movzbl %cl,%eax
  8008c0:	0f b6 db             	movzbl %bl,%ebx
  8008c3:	29 d8                	sub    %ebx,%eax
  8008c5:	eb 05                	jmp    8008cc <memcmp+0x35>
	}

	return 0;
  8008c7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008cc:	5b                   	pop    %ebx
  8008cd:	5e                   	pop    %esi
  8008ce:	5d                   	pop    %ebp
  8008cf:	c3                   	ret    

008008d0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8008d0:	55                   	push   %ebp
  8008d1:	89 e5                	mov    %esp,%ebp
  8008d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8008d9:	89 c2                	mov    %eax,%edx
  8008db:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8008de:	eb 03                	jmp    8008e3 <memfind+0x13>
  8008e0:	83 c0 01             	add    $0x1,%eax
  8008e3:	39 d0                	cmp    %edx,%eax
  8008e5:	73 04                	jae    8008eb <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8008e7:	38 08                	cmp    %cl,(%eax)
  8008e9:	75 f5                	jne    8008e0 <memfind+0x10>
			break;
	return (void *) s;
}
  8008eb:	5d                   	pop    %ebp
  8008ec:	c3                   	ret    

008008ed <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8008ed:	55                   	push   %ebp
  8008ee:	89 e5                	mov    %esp,%ebp
  8008f0:	57                   	push   %edi
  8008f1:	56                   	push   %esi
  8008f2:	53                   	push   %ebx
  8008f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8008f6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8008f9:	eb 03                	jmp    8008fe <strtol+0x11>
		s++;
  8008fb:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  8008fe:	0f b6 02             	movzbl (%edx),%eax
  800901:	3c 20                	cmp    $0x20,%al
  800903:	74 f6                	je     8008fb <strtol+0xe>
  800905:	3c 09                	cmp    $0x9,%al
  800907:	74 f2                	je     8008fb <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800909:	3c 2b                	cmp    $0x2b,%al
  80090b:	74 2a                	je     800937 <strtol+0x4a>
	int neg = 0;
  80090d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800912:	3c 2d                	cmp    $0x2d,%al
  800914:	74 2b                	je     800941 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800916:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80091c:	75 0f                	jne    80092d <strtol+0x40>
  80091e:	80 3a 30             	cmpb   $0x30,(%edx)
  800921:	74 28                	je     80094b <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800923:	85 db                	test   %ebx,%ebx
  800925:	b8 0a 00 00 00       	mov    $0xa,%eax
  80092a:	0f 44 d8             	cmove  %eax,%ebx
  80092d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800932:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800935:	eb 46                	jmp    80097d <strtol+0x90>
		s++;
  800937:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  80093a:	bf 00 00 00 00       	mov    $0x0,%edi
  80093f:	eb d5                	jmp    800916 <strtol+0x29>
		s++, neg = 1;
  800941:	83 c2 01             	add    $0x1,%edx
  800944:	bf 01 00 00 00       	mov    $0x1,%edi
  800949:	eb cb                	jmp    800916 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80094b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80094f:	74 0e                	je     80095f <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800951:	85 db                	test   %ebx,%ebx
  800953:	75 d8                	jne    80092d <strtol+0x40>
		s++, base = 8;
  800955:	83 c2 01             	add    $0x1,%edx
  800958:	bb 08 00 00 00       	mov    $0x8,%ebx
  80095d:	eb ce                	jmp    80092d <strtol+0x40>
		s += 2, base = 16;
  80095f:	83 c2 02             	add    $0x2,%edx
  800962:	bb 10 00 00 00       	mov    $0x10,%ebx
  800967:	eb c4                	jmp    80092d <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800969:	0f be c0             	movsbl %al,%eax
  80096c:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  80096f:	3b 45 10             	cmp    0x10(%ebp),%eax
  800972:	7d 3a                	jge    8009ae <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800974:	83 c2 01             	add    $0x1,%edx
  800977:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  80097b:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  80097d:	0f b6 02             	movzbl (%edx),%eax
  800980:	8d 70 d0             	lea    -0x30(%eax),%esi
  800983:	89 f3                	mov    %esi,%ebx
  800985:	80 fb 09             	cmp    $0x9,%bl
  800988:	76 df                	jbe    800969 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  80098a:	8d 70 9f             	lea    -0x61(%eax),%esi
  80098d:	89 f3                	mov    %esi,%ebx
  80098f:	80 fb 19             	cmp    $0x19,%bl
  800992:	77 08                	ja     80099c <strtol+0xaf>
			dig = *s - 'a' + 10;
  800994:	0f be c0             	movsbl %al,%eax
  800997:	83 e8 57             	sub    $0x57,%eax
  80099a:	eb d3                	jmp    80096f <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  80099c:	8d 70 bf             	lea    -0x41(%eax),%esi
  80099f:	89 f3                	mov    %esi,%ebx
  8009a1:	80 fb 19             	cmp    $0x19,%bl
  8009a4:	77 08                	ja     8009ae <strtol+0xc1>
			dig = *s - 'A' + 10;
  8009a6:	0f be c0             	movsbl %al,%eax
  8009a9:	83 e8 37             	sub    $0x37,%eax
  8009ac:	eb c1                	jmp    80096f <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  8009ae:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8009b2:	74 05                	je     8009b9 <strtol+0xcc>
		*endptr = (char *) s;
  8009b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b7:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  8009b9:	89 c8                	mov    %ecx,%eax
  8009bb:	f7 d8                	neg    %eax
  8009bd:	85 ff                	test   %edi,%edi
  8009bf:	0f 45 c8             	cmovne %eax,%ecx
}
  8009c2:	89 c8                	mov    %ecx,%eax
  8009c4:	5b                   	pop    %ebx
  8009c5:	5e                   	pop    %esi
  8009c6:	5f                   	pop    %edi
  8009c7:	5d                   	pop    %ebp
  8009c8:	c3                   	ret    

008009c9 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8009c9:	55                   	push   %ebp
  8009ca:	89 e5                	mov    %esp,%ebp
  8009cc:	57                   	push   %edi
  8009cd:	56                   	push   %esi
  8009ce:	53                   	push   %ebx
  8009cf:	83 ec 1c             	sub    $0x1c,%esp
  8009d2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009d5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8009d8:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile(
  8009da:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009e0:	8b 7d 10             	mov    0x10(%ebp),%edi
  8009e3:	8b 75 14             	mov    0x14(%ebp),%esi
  8009e6:	cd 30                	int    $0x30
	        "int %1\n"
	        : "=a"(ret)
	        : "i"(T_SYSCALL), "a"(num), "d"(a1), "c"(a2), "b"(a3), "D"(a4), "S"(a5)
	        : "cc", "memory");

	if (check && ret > 0)
  8009e8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8009ec:	74 04                	je     8009f2 <syscall+0x29>
  8009ee:	85 c0                	test   %eax,%eax
  8009f0:	7f 08                	jg     8009fa <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  8009f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009f5:	5b                   	pop    %ebx
  8009f6:	5e                   	pop    %esi
  8009f7:	5f                   	pop    %edi
  8009f8:	5d                   	pop    %ebp
  8009f9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8009fa:	83 ec 0c             	sub    $0xc,%esp
  8009fd:	50                   	push   %eax
  8009fe:	ff 75 e0             	push   -0x20(%ebp)
  800a01:	68 24 11 80 00       	push   $0x801124
  800a06:	6a 1e                	push   $0x1e
  800a08:	68 41 11 80 00       	push   $0x801141
  800a0d:	e8 f7 01 00 00       	call   800c09 <_panic>

00800a12 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800a12:	55                   	push   %ebp
  800a13:	89 e5                	mov    %esp,%ebp
  800a15:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t) s, len, 0, 0, 0);
  800a18:	6a 00                	push   $0x0
  800a1a:	6a 00                	push   $0x0
  800a1c:	6a 00                	push   $0x0
  800a1e:	ff 75 0c             	push   0xc(%ebp)
  800a21:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a24:	ba 00 00 00 00       	mov    $0x0,%edx
  800a29:	b8 00 00 00 00       	mov    $0x0,%eax
  800a2e:	e8 96 ff ff ff       	call   8009c9 <syscall>
}
  800a33:	83 c4 10             	add    $0x10,%esp
  800a36:	c9                   	leave  
  800a37:	c3                   	ret    

00800a38 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a38:	55                   	push   %ebp
  800a39:	89 e5                	mov    %esp,%ebp
  800a3b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800a3e:	6a 00                	push   $0x0
  800a40:	6a 00                	push   $0x0
  800a42:	6a 00                	push   $0x0
  800a44:	6a 00                	push   $0x0
  800a46:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a4b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a50:	b8 01 00 00 00       	mov    $0x1,%eax
  800a55:	e8 6f ff ff ff       	call   8009c9 <syscall>
}
  800a5a:	c9                   	leave  
  800a5b:	c3                   	ret    

00800a5c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a5c:	55                   	push   %ebp
  800a5d:	89 e5                	mov    %esp,%ebp
  800a5f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800a62:	6a 00                	push   $0x0
  800a64:	6a 00                	push   $0x0
  800a66:	6a 00                	push   $0x0
  800a68:	6a 00                	push   $0x0
  800a6a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a6d:	ba 01 00 00 00       	mov    $0x1,%edx
  800a72:	b8 03 00 00 00       	mov    $0x3,%eax
  800a77:	e8 4d ff ff ff       	call   8009c9 <syscall>
}
  800a7c:	c9                   	leave  
  800a7d:	c3                   	ret    

00800a7e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800a7e:	55                   	push   %ebp
  800a7f:	89 e5                	mov    %esp,%ebp
  800a81:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800a84:	6a 00                	push   $0x0
  800a86:	6a 00                	push   $0x0
  800a88:	6a 00                	push   $0x0
  800a8a:	6a 00                	push   $0x0
  800a8c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a91:	ba 00 00 00 00       	mov    $0x0,%edx
  800a96:	b8 02 00 00 00       	mov    $0x2,%eax
  800a9b:	e8 29 ff ff ff       	call   8009c9 <syscall>
}
  800aa0:	c9                   	leave  
  800aa1:	c3                   	ret    

00800aa2 <sys_yield>:

void
sys_yield(void)
{
  800aa2:	55                   	push   %ebp
  800aa3:	89 e5                	mov    %esp,%ebp
  800aa5:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800aa8:	6a 00                	push   $0x0
  800aaa:	6a 00                	push   $0x0
  800aac:	6a 00                	push   $0x0
  800aae:	6a 00                	push   $0x0
  800ab0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ab5:	ba 00 00 00 00       	mov    $0x0,%edx
  800aba:	b8 0a 00 00 00       	mov    $0xa,%eax
  800abf:	e8 05 ff ff ff       	call   8009c9 <syscall>
}
  800ac4:	83 c4 10             	add    $0x10,%esp
  800ac7:	c9                   	leave  
  800ac8:	c3                   	ret    

00800ac9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ac9:	55                   	push   %ebp
  800aca:	89 e5                	mov    %esp,%ebp
  800acc:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800acf:	6a 00                	push   $0x0
  800ad1:	6a 00                	push   $0x0
  800ad3:	ff 75 10             	push   0x10(%ebp)
  800ad6:	ff 75 0c             	push   0xc(%ebp)
  800ad9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800adc:	ba 01 00 00 00       	mov    $0x1,%edx
  800ae1:	b8 04 00 00 00       	mov    $0x4,%eax
  800ae6:	e8 de fe ff ff       	call   8009c9 <syscall>
}
  800aeb:	c9                   	leave  
  800aec:	c3                   	ret    

00800aed <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800aed:	55                   	push   %ebp
  800aee:	89 e5                	mov    %esp,%ebp
  800af0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map,
  800af3:	ff 75 18             	push   0x18(%ebp)
  800af6:	ff 75 14             	push   0x14(%ebp)
  800af9:	ff 75 10             	push   0x10(%ebp)
  800afc:	ff 75 0c             	push   0xc(%ebp)
  800aff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b02:	ba 01 00 00 00       	mov    $0x1,%edx
  800b07:	b8 05 00 00 00       	mov    $0x5,%eax
  800b0c:	e8 b8 fe ff ff       	call   8009c9 <syscall>
	               srcenv,
	               (uint32_t) srcva,
	               dstenv,
	               (uint32_t) dstva,
	               perm);
}
  800b11:	c9                   	leave  
  800b12:	c3                   	ret    

00800b13 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b13:	55                   	push   %ebp
  800b14:	89 e5                	mov    %esp,%ebp
  800b16:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800b19:	6a 00                	push   $0x0
  800b1b:	6a 00                	push   $0x0
  800b1d:	6a 00                	push   $0x0
  800b1f:	ff 75 0c             	push   0xc(%ebp)
  800b22:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b25:	ba 01 00 00 00       	mov    $0x1,%edx
  800b2a:	b8 06 00 00 00       	mov    $0x6,%eax
  800b2f:	e8 95 fe ff ff       	call   8009c9 <syscall>
}
  800b34:	c9                   	leave  
  800b35:	c3                   	ret    

00800b36 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800b36:	55                   	push   %ebp
  800b37:	89 e5                	mov    %esp,%ebp
  800b39:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800b3c:	6a 00                	push   $0x0
  800b3e:	6a 00                	push   $0x0
  800b40:	6a 00                	push   $0x0
  800b42:	ff 75 0c             	push   0xc(%ebp)
  800b45:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b48:	ba 01 00 00 00       	mov    $0x1,%edx
  800b4d:	b8 08 00 00 00       	mov    $0x8,%eax
  800b52:	e8 72 fe ff ff       	call   8009c9 <syscall>
}
  800b57:	c9                   	leave  
  800b58:	c3                   	ret    

00800b59 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800b59:	55                   	push   %ebp
  800b5a:	89 e5                	mov    %esp,%ebp
  800b5c:	83 ec 08             	sub    $0x8,%esp
	return syscall(
  800b5f:	6a 00                	push   $0x0
  800b61:	6a 00                	push   $0x0
  800b63:	6a 00                	push   $0x0
  800b65:	ff 75 0c             	push   0xc(%ebp)
  800b68:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b6b:	ba 01 00 00 00       	mov    $0x1,%edx
  800b70:	b8 09 00 00 00       	mov    $0x9,%eax
  800b75:	e8 4f fe ff ff       	call   8009c9 <syscall>
	        SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800b7a:	c9                   	leave  
  800b7b:	c3                   	ret    

00800b7c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800b82:	6a 00                	push   $0x0
  800b84:	ff 75 14             	push   0x14(%ebp)
  800b87:	ff 75 10             	push   0x10(%ebp)
  800b8a:	ff 75 0c             	push   0xc(%ebp)
  800b8d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b90:	ba 00 00 00 00       	mov    $0x0,%edx
  800b95:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b9a:	e8 2a fe ff ff       	call   8009c9 <syscall>
}
  800b9f:	c9                   	leave  
  800ba0:	c3                   	ret    

00800ba1 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ba1:	55                   	push   %ebp
  800ba2:	89 e5                	mov    %esp,%ebp
  800ba4:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t) dstva, 0, 0, 0, 0);
  800ba7:	6a 00                	push   $0x0
  800ba9:	6a 00                	push   $0x0
  800bab:	6a 00                	push   $0x0
  800bad:	6a 00                	push   $0x0
  800baf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bb2:	ba 01 00 00 00       	mov    $0x1,%edx
  800bb7:	b8 0c 00 00 00       	mov    $0xc,%eax
  800bbc:	e8 08 fe ff ff       	call   8009c9 <syscall>
}
  800bc1:	c9                   	leave  
  800bc2:	c3                   	ret    

00800bc3 <sys_get_priority>:

// Get priority of the current process
int
sys_get_priority(void)
{
  800bc3:	55                   	push   %ebp
  800bc4:	89 e5                	mov    %esp,%ebp
  800bc6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_get_priority, 0, 0, 0, 0, 0, 0);
  800bc9:	6a 00                	push   $0x0
  800bcb:	6a 00                	push   $0x0
  800bcd:	6a 00                	push   $0x0
  800bcf:	6a 00                	push   $0x0
  800bd1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bd6:	ba 00 00 00 00       	mov    $0x0,%edx
  800bdb:	b8 0d 00 00 00       	mov    $0xd,%eax
  800be0:	e8 e4 fd ff ff       	call   8009c9 <syscall>
}
  800be5:	c9                   	leave  
  800be6:	c3                   	ret    

00800be7 <sys_set_priority>:

// Get priority of the current process
int
sys_set_priority(unsigned int priority)
{
  800be7:	55                   	push   %ebp
  800be8:	89 e5                	mov    %esp,%ebp
  800bea:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, (uint32_t) priority, 0, 0, 0, 0);
  800bed:	6a 00                	push   $0x0
  800bef:	6a 00                	push   $0x0
  800bf1:	6a 00                	push   $0x0
  800bf3:	6a 00                	push   $0x0
  800bf5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bf8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bfd:	b8 0e 00 00 00       	mov    $0xe,%eax
  800c02:	e8 c2 fd ff ff       	call   8009c9 <syscall>
}
  800c07:	c9                   	leave  
  800c08:	c3                   	ret    

00800c09 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800c09:	55                   	push   %ebp
  800c0a:	89 e5                	mov    %esp,%ebp
  800c0c:	56                   	push   %esi
  800c0d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800c0e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800c11:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800c17:	e8 62 fe ff ff       	call   800a7e <sys_getenvid>
  800c1c:	83 ec 0c             	sub    $0xc,%esp
  800c1f:	ff 75 0c             	push   0xc(%ebp)
  800c22:	ff 75 08             	push   0x8(%ebp)
  800c25:	56                   	push   %esi
  800c26:	50                   	push   %eax
  800c27:	68 50 11 80 00       	push   $0x801150
  800c2c:	e8 1b f5 ff ff       	call   80014c <cprintf>
	        sys_getenvid(),
	        binaryname,
	        file,
	        line);
	vcprintf(fmt, ap);
  800c31:	83 c4 18             	add    $0x18,%esp
  800c34:	53                   	push   %ebx
  800c35:	ff 75 10             	push   0x10(%ebp)
  800c38:	e8 be f4 ff ff       	call   8000fb <vcprintf>
	cprintf("\n");
  800c3d:	c7 04 24 73 11 80 00 	movl   $0x801173,(%esp)
  800c44:	e8 03 f5 ff ff       	call   80014c <cprintf>
  800c49:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800c4c:	cc                   	int3   
  800c4d:	eb fd                	jmp    800c4c <_panic+0x43>
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
