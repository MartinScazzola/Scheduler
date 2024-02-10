
obj/user/same_priority:     formato del fichero elf32-i386


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
  80002c:	e8 55 00 00 00       	call   800086 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 08             	sub    $0x8,%esp
	int i = fork();
  800039:	e8 1f 0f 00 00       	call   800f5d <fork>

	if (i < 0) {
  80003e:	85 c0                	test   %eax,%eax
  800040:	78 1a                	js     80005c <umain+0x29>
		cprintf("Error in fork\n");
		return;
	}

	if (i == 0) {
  800042:	75 2a                	jne    80006e <umain+0x3b>
		// Child
		cprintf("Child priority: %d\n", sys_get_priority());
  800044:	e8 a8 0b 00 00       	call   800bf1 <sys_get_priority>
  800049:	83 ec 08             	sub    $0x8,%esp
  80004c:	50                   	push   %eax
  80004d:	68 af 13 80 00       	push   $0x8013af
  800052:	e8 23 01 00 00       	call   80017a <cprintf>
  800057:	83 c4 10             	add    $0x10,%esp
	} else {
		// Parent
		cprintf("Parent priority: %d\n", sys_get_priority());
	}
  80005a:	c9                   	leave  
  80005b:	c3                   	ret    
		cprintf("Error in fork\n");
  80005c:	83 ec 0c             	sub    $0xc,%esp
  80005f:	68 a0 13 80 00       	push   $0x8013a0
  800064:	e8 11 01 00 00       	call   80017a <cprintf>
		return;
  800069:	83 c4 10             	add    $0x10,%esp
  80006c:	eb ec                	jmp    80005a <umain+0x27>
		cprintf("Parent priority: %d\n", sys_get_priority());
  80006e:	e8 7e 0b 00 00       	call   800bf1 <sys_get_priority>
  800073:	83 ec 08             	sub    $0x8,%esp
  800076:	50                   	push   %eax
  800077:	68 c3 13 80 00       	push   $0x8013c3
  80007c:	e8 f9 00 00 00       	call   80017a <cprintf>
  800081:	83 c4 10             	add    $0x10,%esp
  800084:	eb d4                	jmp    80005a <umain+0x27>

00800086 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800086:	55                   	push   %ebp
  800087:	89 e5                	mov    %esp,%ebp
  800089:	56                   	push   %esi
  80008a:	53                   	push   %ebx
  80008b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80008e:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	envid_t id = sys_getenvid();
  800091:	e8 16 0a 00 00       	call   800aac <sys_getenvid>
	if (id >= 0)
  800096:	85 c0                	test   %eax,%eax
  800098:	78 15                	js     8000af <libmain+0x29>
		thisenv = &envs[ENVX(id)];
  80009a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80009f:	69 c0 88 00 00 00    	imul   $0x88,%eax,%eax
  8000a5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000aa:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000af:	85 db                	test   %ebx,%ebx
  8000b1:	7e 07                	jle    8000ba <libmain+0x34>
		binaryname = argv[0];
  8000b3:	8b 06                	mov    (%esi),%eax
  8000b5:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000ba:	83 ec 08             	sub    $0x8,%esp
  8000bd:	56                   	push   %esi
  8000be:	53                   	push   %ebx
  8000bf:	e8 6f ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000c4:	e8 0a 00 00 00       	call   8000d3 <exit>
}
  8000c9:	83 c4 10             	add    $0x10,%esp
  8000cc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000cf:	5b                   	pop    %ebx
  8000d0:	5e                   	pop    %esi
  8000d1:	5d                   	pop    %ebp
  8000d2:	c3                   	ret    

008000d3 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000d3:	55                   	push   %ebp
  8000d4:	89 e5                	mov    %esp,%ebp
  8000d6:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000d9:	6a 00                	push   $0x0
  8000db:	e8 aa 09 00 00       	call   800a8a <sys_env_destroy>
}
  8000e0:	83 c4 10             	add    $0x10,%esp
  8000e3:	c9                   	leave  
  8000e4:	c3                   	ret    

008000e5 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000e5:	55                   	push   %ebp
  8000e6:	89 e5                	mov    %esp,%ebp
  8000e8:	53                   	push   %ebx
  8000e9:	83 ec 04             	sub    $0x4,%esp
  8000ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ef:	8b 13                	mov    (%ebx),%edx
  8000f1:	8d 42 01             	lea    0x1(%edx),%eax
  8000f4:	89 03                	mov    %eax,(%ebx)
  8000f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000f9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256 - 1) {
  8000fd:	3d ff 00 00 00       	cmp    $0xff,%eax
  800102:	74 09                	je     80010d <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800104:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800108:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80010b:	c9                   	leave  
  80010c:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80010d:	83 ec 08             	sub    $0x8,%esp
  800110:	68 ff 00 00 00       	push   $0xff
  800115:	8d 43 08             	lea    0x8(%ebx),%eax
  800118:	50                   	push   %eax
  800119:	e8 22 09 00 00       	call   800a40 <sys_cputs>
		b->idx = 0;
  80011e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800124:	83 c4 10             	add    $0x10,%esp
  800127:	eb db                	jmp    800104 <putch+0x1f>

00800129 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800129:	55                   	push   %ebp
  80012a:	89 e5                	mov    %esp,%ebp
  80012c:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800132:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800139:	00 00 00 
	b.cnt = 0;
  80013c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800143:	00 00 00 
	vprintfmt((void *) putch, &b, fmt, ap);
  800146:	ff 75 0c             	push   0xc(%ebp)
  800149:	ff 75 08             	push   0x8(%ebp)
  80014c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800152:	50                   	push   %eax
  800153:	68 e5 00 80 00       	push   $0x8000e5
  800158:	e8 74 01 00 00       	call   8002d1 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80015d:	83 c4 08             	add    $0x8,%esp
  800160:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800166:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80016c:	50                   	push   %eax
  80016d:	e8 ce 08 00 00       	call   800a40 <sys_cputs>

	return b.cnt;
}
  800172:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800178:	c9                   	leave  
  800179:	c3                   	ret    

0080017a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80017a:	55                   	push   %ebp
  80017b:	89 e5                	mov    %esp,%ebp
  80017d:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800180:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800183:	50                   	push   %eax
  800184:	ff 75 08             	push   0x8(%ebp)
  800187:	e8 9d ff ff ff       	call   800129 <vcprintf>
	va_end(ap);

	return cnt;
}
  80018c:	c9                   	leave  
  80018d:	c3                   	ret    

0080018e <printnum>:
         void *putdat,
         unsigned long long num,
         unsigned base,
         int width,
         int padc)
{
  80018e:	55                   	push   %ebp
  80018f:	89 e5                	mov    %esp,%ebp
  800191:	57                   	push   %edi
  800192:	56                   	push   %esi
  800193:	53                   	push   %ebx
  800194:	83 ec 1c             	sub    $0x1c,%esp
  800197:	89 c7                	mov    %eax,%edi
  800199:	89 d6                	mov    %edx,%esi
  80019b:	8b 45 08             	mov    0x8(%ebp),%eax
  80019e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001a1:	89 d1                	mov    %edx,%ecx
  8001a3:	89 c2                	mov    %eax,%edx
  8001a5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001a8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001ab:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ae:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001b4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001bb:	39 c2                	cmp    %eax,%edx
  8001bd:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001c0:	72 3e                	jb     800200 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001c2:	83 ec 0c             	sub    $0xc,%esp
  8001c5:	ff 75 18             	push   0x18(%ebp)
  8001c8:	83 eb 01             	sub    $0x1,%ebx
  8001cb:	53                   	push   %ebx
  8001cc:	50                   	push   %eax
  8001cd:	83 ec 08             	sub    $0x8,%esp
  8001d0:	ff 75 e4             	push   -0x1c(%ebp)
  8001d3:	ff 75 e0             	push   -0x20(%ebp)
  8001d6:	ff 75 dc             	push   -0x24(%ebp)
  8001d9:	ff 75 d8             	push   -0x28(%ebp)
  8001dc:	e8 6f 0f 00 00       	call   801150 <__udivdi3>
  8001e1:	83 c4 18             	add    $0x18,%esp
  8001e4:	52                   	push   %edx
  8001e5:	50                   	push   %eax
  8001e6:	89 f2                	mov    %esi,%edx
  8001e8:	89 f8                	mov    %edi,%eax
  8001ea:	e8 9f ff ff ff       	call   80018e <printnum>
  8001ef:	83 c4 20             	add    $0x20,%esp
  8001f2:	eb 13                	jmp    800207 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001f4:	83 ec 08             	sub    $0x8,%esp
  8001f7:	56                   	push   %esi
  8001f8:	ff 75 18             	push   0x18(%ebp)
  8001fb:	ff d7                	call   *%edi
  8001fd:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800200:	83 eb 01             	sub    $0x1,%ebx
  800203:	85 db                	test   %ebx,%ebx
  800205:	7f ed                	jg     8001f4 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800207:	83 ec 08             	sub    $0x8,%esp
  80020a:	56                   	push   %esi
  80020b:	83 ec 04             	sub    $0x4,%esp
  80020e:	ff 75 e4             	push   -0x1c(%ebp)
  800211:	ff 75 e0             	push   -0x20(%ebp)
  800214:	ff 75 dc             	push   -0x24(%ebp)
  800217:	ff 75 d8             	push   -0x28(%ebp)
  80021a:	e8 51 10 00 00       	call   801270 <__umoddi3>
  80021f:	83 c4 14             	add    $0x14,%esp
  800222:	0f be 80 e2 13 80 00 	movsbl 0x8013e2(%eax),%eax
  800229:	50                   	push   %eax
  80022a:	ff d7                	call   *%edi
}
  80022c:	83 c4 10             	add    $0x10,%esp
  80022f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800232:	5b                   	pop    %ebx
  800233:	5e                   	pop    %esi
  800234:	5f                   	pop    %edi
  800235:	5d                   	pop    %ebp
  800236:	c3                   	ret    

00800237 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800237:	83 fa 01             	cmp    $0x1,%edx
  80023a:	7f 13                	jg     80024f <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80023c:	85 d2                	test   %edx,%edx
  80023e:	74 1c                	je     80025c <getuint+0x25>
		return va_arg(*ap, unsigned long);
  800240:	8b 10                	mov    (%eax),%edx
  800242:	8d 4a 04             	lea    0x4(%edx),%ecx
  800245:	89 08                	mov    %ecx,(%eax)
  800247:	8b 02                	mov    (%edx),%eax
  800249:	ba 00 00 00 00       	mov    $0x0,%edx
  80024e:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  80024f:	8b 10                	mov    (%eax),%edx
  800251:	8d 4a 08             	lea    0x8(%edx),%ecx
  800254:	89 08                	mov    %ecx,(%eax)
  800256:	8b 02                	mov    (%edx),%eax
  800258:	8b 52 04             	mov    0x4(%edx),%edx
  80025b:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  80025c:	8b 10                	mov    (%eax),%edx
  80025e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800261:	89 08                	mov    %ecx,(%eax)
  800263:	8b 02                	mov    (%edx),%eax
  800265:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80026a:	c3                   	ret    

0080026b <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80026b:	83 fa 01             	cmp    $0x1,%edx
  80026e:	7f 0f                	jg     80027f <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  800270:	85 d2                	test   %edx,%edx
  800272:	74 18                	je     80028c <getint+0x21>
		return va_arg(*ap, long);
  800274:	8b 10                	mov    (%eax),%edx
  800276:	8d 4a 04             	lea    0x4(%edx),%ecx
  800279:	89 08                	mov    %ecx,(%eax)
  80027b:	8b 02                	mov    (%edx),%eax
  80027d:	99                   	cltd   
  80027e:	c3                   	ret    
		return va_arg(*ap, long long);
  80027f:	8b 10                	mov    (%eax),%edx
  800281:	8d 4a 08             	lea    0x8(%edx),%ecx
  800284:	89 08                	mov    %ecx,(%eax)
  800286:	8b 02                	mov    (%edx),%eax
  800288:	8b 52 04             	mov    0x4(%edx),%edx
  80028b:	c3                   	ret    
	else
		return va_arg(*ap, int);
  80028c:	8b 10                	mov    (%eax),%edx
  80028e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800291:	89 08                	mov    %ecx,(%eax)
  800293:	8b 02                	mov    (%edx),%eax
  800295:	99                   	cltd   
}
  800296:	c3                   	ret    

00800297 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800297:	55                   	push   %ebp
  800298:	89 e5                	mov    %esp,%ebp
  80029a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80029d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002a1:	8b 10                	mov    (%eax),%edx
  8002a3:	3b 50 04             	cmp    0x4(%eax),%edx
  8002a6:	73 0a                	jae    8002b2 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002a8:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002ab:	89 08                	mov    %ecx,(%eax)
  8002ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b0:	88 02                	mov    %al,(%edx)
}
  8002b2:	5d                   	pop    %ebp
  8002b3:	c3                   	ret    

008002b4 <printfmt>:
{
  8002b4:	55                   	push   %ebp
  8002b5:	89 e5                	mov    %esp,%ebp
  8002b7:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002ba:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002bd:	50                   	push   %eax
  8002be:	ff 75 10             	push   0x10(%ebp)
  8002c1:	ff 75 0c             	push   0xc(%ebp)
  8002c4:	ff 75 08             	push   0x8(%ebp)
  8002c7:	e8 05 00 00 00       	call   8002d1 <vprintfmt>
}
  8002cc:	83 c4 10             	add    $0x10,%esp
  8002cf:	c9                   	leave  
  8002d0:	c3                   	ret    

008002d1 <vprintfmt>:
{
  8002d1:	55                   	push   %ebp
  8002d2:	89 e5                	mov    %esp,%ebp
  8002d4:	57                   	push   %edi
  8002d5:	56                   	push   %esi
  8002d6:	53                   	push   %ebx
  8002d7:	83 ec 2c             	sub    $0x2c,%esp
  8002da:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002dd:	8b 75 0c             	mov    0xc(%ebp),%esi
  8002e0:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002e3:	eb 0a                	jmp    8002ef <vprintfmt+0x1e>
			putch(ch, putdat);
  8002e5:	83 ec 08             	sub    $0x8,%esp
  8002e8:	56                   	push   %esi
  8002e9:	50                   	push   %eax
  8002ea:	ff d3                	call   *%ebx
  8002ec:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002ef:	83 c7 01             	add    $0x1,%edi
  8002f2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002f6:	83 f8 25             	cmp    $0x25,%eax
  8002f9:	74 0c                	je     800307 <vprintfmt+0x36>
			if (ch == '\0')
  8002fb:	85 c0                	test   %eax,%eax
  8002fd:	75 e6                	jne    8002e5 <vprintfmt+0x14>
}
  8002ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800302:	5b                   	pop    %ebx
  800303:	5e                   	pop    %esi
  800304:	5f                   	pop    %edi
  800305:	5d                   	pop    %ebp
  800306:	c3                   	ret    
		padc = ' ';
  800307:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
		altflag = 0;
  80030b:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800312:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800319:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800320:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800325:	8d 47 01             	lea    0x1(%edi),%eax
  800328:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80032b:	0f b6 17             	movzbl (%edi),%edx
  80032e:	8d 42 dd             	lea    -0x23(%edx),%eax
  800331:	3c 55                	cmp    $0x55,%al
  800333:	0f 87 b7 02 00 00    	ja     8005f0 <vprintfmt+0x31f>
  800339:	0f b6 c0             	movzbl %al,%eax
  80033c:	ff 24 85 a0 14 80 00 	jmp    *0x8014a0(,%eax,4)
  800343:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800346:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  80034a:	eb d9                	jmp    800325 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80034c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80034f:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800353:	eb d0                	jmp    800325 <vprintfmt+0x54>
  800355:	0f b6 d2             	movzbl %dl,%edx
  800358:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0;; ++fmt) {
  80035b:	b8 00 00 00 00       	mov    $0x0,%eax
  800360:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800363:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800366:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80036a:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80036d:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800370:	83 f9 09             	cmp    $0x9,%ecx
  800373:	77 52                	ja     8003c7 <vprintfmt+0xf6>
			for (precision = 0;; ++fmt) {
  800375:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800378:	eb e9                	jmp    800363 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  80037a:	8b 45 14             	mov    0x14(%ebp),%eax
  80037d:	8d 50 04             	lea    0x4(%eax),%edx
  800380:	89 55 14             	mov    %edx,0x14(%ebp)
  800383:	8b 00                	mov    (%eax),%eax
  800385:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800388:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80038b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80038f:	79 94                	jns    800325 <vprintfmt+0x54>
				width = precision, precision = -1;
  800391:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800394:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800397:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80039e:	eb 85                	jmp    800325 <vprintfmt+0x54>
  8003a0:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003a3:	85 d2                	test   %edx,%edx
  8003a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8003aa:	0f 49 c2             	cmovns %edx,%eax
  8003ad:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003b3:	e9 6d ff ff ff       	jmp    800325 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8003b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003bb:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003c2:	e9 5e ff ff ff       	jmp    800325 <vprintfmt+0x54>
  8003c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003ca:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003cd:	eb bc                	jmp    80038b <vprintfmt+0xba>
			lflag++;
  8003cf:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003d5:	e9 4b ff ff ff       	jmp    800325 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8003da:	8b 45 14             	mov    0x14(%ebp),%eax
  8003dd:	8d 50 04             	lea    0x4(%eax),%edx
  8003e0:	89 55 14             	mov    %edx,0x14(%ebp)
  8003e3:	83 ec 08             	sub    $0x8,%esp
  8003e6:	56                   	push   %esi
  8003e7:	ff 30                	push   (%eax)
  8003e9:	ff d3                	call   *%ebx
			break;
  8003eb:	83 c4 10             	add    $0x10,%esp
  8003ee:	e9 94 01 00 00       	jmp    800587 <vprintfmt+0x2b6>
			err = va_arg(ap, int);
  8003f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f6:	8d 50 04             	lea    0x4(%eax),%edx
  8003f9:	89 55 14             	mov    %edx,0x14(%ebp)
  8003fc:	8b 10                	mov    (%eax),%edx
  8003fe:	89 d0                	mov    %edx,%eax
  800400:	f7 d8                	neg    %eax
  800402:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800405:	83 f8 08             	cmp    $0x8,%eax
  800408:	7f 20                	jg     80042a <vprintfmt+0x159>
  80040a:	8b 14 85 00 16 80 00 	mov    0x801600(,%eax,4),%edx
  800411:	85 d2                	test   %edx,%edx
  800413:	74 15                	je     80042a <vprintfmt+0x159>
				printfmt(putch, putdat, "%s", p);
  800415:	52                   	push   %edx
  800416:	68 03 14 80 00       	push   $0x801403
  80041b:	56                   	push   %esi
  80041c:	53                   	push   %ebx
  80041d:	e8 92 fe ff ff       	call   8002b4 <printfmt>
  800422:	83 c4 10             	add    $0x10,%esp
  800425:	e9 5d 01 00 00       	jmp    800587 <vprintfmt+0x2b6>
				printfmt(putch, putdat, "error %d", err);
  80042a:	50                   	push   %eax
  80042b:	68 fa 13 80 00       	push   $0x8013fa
  800430:	56                   	push   %esi
  800431:	53                   	push   %ebx
  800432:	e8 7d fe ff ff       	call   8002b4 <printfmt>
  800437:	83 c4 10             	add    $0x10,%esp
  80043a:	e9 48 01 00 00       	jmp    800587 <vprintfmt+0x2b6>
			if ((p = va_arg(ap, char *)) == NULL)
  80043f:	8b 45 14             	mov    0x14(%ebp),%eax
  800442:	8d 50 04             	lea    0x4(%eax),%edx
  800445:	89 55 14             	mov    %edx,0x14(%ebp)
  800448:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80044a:	85 ff                	test   %edi,%edi
  80044c:	b8 f3 13 80 00       	mov    $0x8013f3,%eax
  800451:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800454:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800458:	7e 06                	jle    800460 <vprintfmt+0x18f>
  80045a:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  80045e:	75 0a                	jne    80046a <vprintfmt+0x199>
  800460:	89 f8                	mov    %edi,%eax
  800462:	03 45 e0             	add    -0x20(%ebp),%eax
  800465:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800468:	eb 59                	jmp    8004c3 <vprintfmt+0x1f2>
				for (width -= strnlen(p, precision); width > 0;
  80046a:	83 ec 08             	sub    $0x8,%esp
  80046d:	ff 75 d8             	push   -0x28(%ebp)
  800470:	57                   	push   %edi
  800471:	e8 1a 02 00 00       	call   800690 <strnlen>
  800476:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800479:	29 c1                	sub    %eax,%ecx
  80047b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80047e:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800481:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  800485:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800488:	89 7d d0             	mov    %edi,-0x30(%ebp)
  80048b:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0;
  80048d:	eb 0f                	jmp    80049e <vprintfmt+0x1cd>
					putch(padc, putdat);
  80048f:	83 ec 08             	sub    $0x8,%esp
  800492:	56                   	push   %esi
  800493:	ff 75 e0             	push   -0x20(%ebp)
  800496:	ff d3                	call   *%ebx
				     width--)
  800498:	83 ef 01             	sub    $0x1,%edi
  80049b:	83 c4 10             	add    $0x10,%esp
				for (width -= strnlen(p, precision); width > 0;
  80049e:	85 ff                	test   %edi,%edi
  8004a0:	7f ed                	jg     80048f <vprintfmt+0x1be>
  8004a2:	8b 7d d0             	mov    -0x30(%ebp),%edi
  8004a5:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004a8:	85 c9                	test   %ecx,%ecx
  8004aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8004af:	0f 49 c1             	cmovns %ecx,%eax
  8004b2:	29 c1                	sub    %eax,%ecx
  8004b4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8004b7:	eb a7                	jmp    800460 <vprintfmt+0x18f>
					putch(ch, putdat);
  8004b9:	83 ec 08             	sub    $0x8,%esp
  8004bc:	56                   	push   %esi
  8004bd:	52                   	push   %edx
  8004be:	ff d3                	call   *%ebx
  8004c0:	83 c4 10             	add    $0x10,%esp
  8004c3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004c6:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' &&
  8004c8:	83 c7 01             	add    $0x1,%edi
  8004cb:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004cf:	0f be d0             	movsbl %al,%edx
  8004d2:	85 d2                	test   %edx,%edx
  8004d4:	74 42                	je     800518 <vprintfmt+0x247>
  8004d6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004da:	78 06                	js     8004e2 <vprintfmt+0x211>
			       (precision < 0 || --precision >= 0);
  8004dc:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004e0:	78 1e                	js     800500 <vprintfmt+0x22f>
				if (altflag && (ch < ' ' || ch > '~'))
  8004e2:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004e6:	74 d1                	je     8004b9 <vprintfmt+0x1e8>
  8004e8:	0f be c0             	movsbl %al,%eax
  8004eb:	83 e8 20             	sub    $0x20,%eax
  8004ee:	83 f8 5e             	cmp    $0x5e,%eax
  8004f1:	76 c6                	jbe    8004b9 <vprintfmt+0x1e8>
					putch('?', putdat);
  8004f3:	83 ec 08             	sub    $0x8,%esp
  8004f6:	56                   	push   %esi
  8004f7:	6a 3f                	push   $0x3f
  8004f9:	ff d3                	call   *%ebx
  8004fb:	83 c4 10             	add    $0x10,%esp
  8004fe:	eb c3                	jmp    8004c3 <vprintfmt+0x1f2>
  800500:	89 cf                	mov    %ecx,%edi
  800502:	eb 0e                	jmp    800512 <vprintfmt+0x241>
				putch(' ', putdat);
  800504:	83 ec 08             	sub    $0x8,%esp
  800507:	56                   	push   %esi
  800508:	6a 20                	push   $0x20
  80050a:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  80050c:	83 ef 01             	sub    $0x1,%edi
  80050f:	83 c4 10             	add    $0x10,%esp
  800512:	85 ff                	test   %edi,%edi
  800514:	7f ee                	jg     800504 <vprintfmt+0x233>
  800516:	eb 6f                	jmp    800587 <vprintfmt+0x2b6>
  800518:	89 cf                	mov    %ecx,%edi
  80051a:	eb f6                	jmp    800512 <vprintfmt+0x241>
			num = getint(&ap, lflag);
  80051c:	89 ca                	mov    %ecx,%edx
  80051e:	8d 45 14             	lea    0x14(%ebp),%eax
  800521:	e8 45 fd ff ff       	call   80026b <getint>
  800526:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800529:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  80052c:	85 d2                	test   %edx,%edx
  80052e:	78 0b                	js     80053b <vprintfmt+0x26a>
			num = getint(&ap, lflag);
  800530:	89 d1                	mov    %edx,%ecx
  800532:	89 c2                	mov    %eax,%edx
			base = 10;
  800534:	bf 0a 00 00 00       	mov    $0xa,%edi
  800539:	eb 32                	jmp    80056d <vprintfmt+0x29c>
				putch('-', putdat);
  80053b:	83 ec 08             	sub    $0x8,%esp
  80053e:	56                   	push   %esi
  80053f:	6a 2d                	push   $0x2d
  800541:	ff d3                	call   *%ebx
				num = -(long long) num;
  800543:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800546:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800549:	f7 da                	neg    %edx
  80054b:	83 d1 00             	adc    $0x0,%ecx
  80054e:	f7 d9                	neg    %ecx
  800550:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800553:	bf 0a 00 00 00       	mov    $0xa,%edi
  800558:	eb 13                	jmp    80056d <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  80055a:	89 ca                	mov    %ecx,%edx
  80055c:	8d 45 14             	lea    0x14(%ebp),%eax
  80055f:	e8 d3 fc ff ff       	call   800237 <getuint>
  800564:	89 d1                	mov    %edx,%ecx
  800566:	89 c2                	mov    %eax,%edx
			base = 10;
  800568:	bf 0a 00 00 00       	mov    $0xa,%edi
			printnum(putch, putdat, num, base, width, padc);
  80056d:	83 ec 0c             	sub    $0xc,%esp
  800570:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  800574:	50                   	push   %eax
  800575:	ff 75 e0             	push   -0x20(%ebp)
  800578:	57                   	push   %edi
  800579:	51                   	push   %ecx
  80057a:	52                   	push   %edx
  80057b:	89 f2                	mov    %esi,%edx
  80057d:	89 d8                	mov    %ebx,%eax
  80057f:	e8 0a fc ff ff       	call   80018e <printnum>
			break;
  800584:	83 c4 20             	add    $0x20,%esp
{
  800587:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80058a:	e9 60 fd ff ff       	jmp    8002ef <vprintfmt+0x1e>
			num = getuint(&ap, lflag);
  80058f:	89 ca                	mov    %ecx,%edx
  800591:	8d 45 14             	lea    0x14(%ebp),%eax
  800594:	e8 9e fc ff ff       	call   800237 <getuint>
  800599:	89 d1                	mov    %edx,%ecx
  80059b:	89 c2                	mov    %eax,%edx
			base = 8;
  80059d:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  8005a2:	eb c9                	jmp    80056d <vprintfmt+0x29c>
			putch('0', putdat);
  8005a4:	83 ec 08             	sub    $0x8,%esp
  8005a7:	56                   	push   %esi
  8005a8:	6a 30                	push   $0x30
  8005aa:	ff d3                	call   *%ebx
			putch('x', putdat);
  8005ac:	83 c4 08             	add    $0x8,%esp
  8005af:	56                   	push   %esi
  8005b0:	6a 78                	push   $0x78
  8005b2:	ff d3                	call   *%ebx
			num = (unsigned long long) (uintptr_t) va_arg(ap, void *);
  8005b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b7:	8d 50 04             	lea    0x4(%eax),%edx
  8005ba:	89 55 14             	mov    %edx,0x14(%ebp)
  8005bd:	8b 10                	mov    (%eax),%edx
  8005bf:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8005c4:	83 c4 10             	add    $0x10,%esp
			base = 16;
  8005c7:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  8005cc:	eb 9f                	jmp    80056d <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  8005ce:	89 ca                	mov    %ecx,%edx
  8005d0:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d3:	e8 5f fc ff ff       	call   800237 <getuint>
  8005d8:	89 d1                	mov    %edx,%ecx
  8005da:	89 c2                	mov    %eax,%edx
			base = 16;
  8005dc:	bf 10 00 00 00       	mov    $0x10,%edi
  8005e1:	eb 8a                	jmp    80056d <vprintfmt+0x29c>
			putch(ch, putdat);
  8005e3:	83 ec 08             	sub    $0x8,%esp
  8005e6:	56                   	push   %esi
  8005e7:	6a 25                	push   $0x25
  8005e9:	ff d3                	call   *%ebx
			break;
  8005eb:	83 c4 10             	add    $0x10,%esp
  8005ee:	eb 97                	jmp    800587 <vprintfmt+0x2b6>
			putch('%', putdat);
  8005f0:	83 ec 08             	sub    $0x8,%esp
  8005f3:	56                   	push   %esi
  8005f4:	6a 25                	push   $0x25
  8005f6:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  8005f8:	83 c4 10             	add    $0x10,%esp
  8005fb:	89 f8                	mov    %edi,%eax
  8005fd:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800601:	74 05                	je     800608 <vprintfmt+0x337>
  800603:	83 e8 01             	sub    $0x1,%eax
  800606:	eb f5                	jmp    8005fd <vprintfmt+0x32c>
  800608:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80060b:	e9 77 ff ff ff       	jmp    800587 <vprintfmt+0x2b6>

00800610 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800610:	55                   	push   %ebp
  800611:	89 e5                	mov    %esp,%ebp
  800613:	83 ec 18             	sub    $0x18,%esp
  800616:	8b 45 08             	mov    0x8(%ebp),%eax
  800619:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = { buf, buf + n - 1, 0 };
  80061c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80061f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800623:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800626:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80062d:	85 c0                	test   %eax,%eax
  80062f:	74 26                	je     800657 <vsnprintf+0x47>
  800631:	85 d2                	test   %edx,%edx
  800633:	7e 22                	jle    800657 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *) sprintputch, &b, fmt, ap);
  800635:	ff 75 14             	push   0x14(%ebp)
  800638:	ff 75 10             	push   0x10(%ebp)
  80063b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80063e:	50                   	push   %eax
  80063f:	68 97 02 80 00       	push   $0x800297
  800644:	e8 88 fc ff ff       	call   8002d1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800649:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80064c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80064f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800652:	83 c4 10             	add    $0x10,%esp
}
  800655:	c9                   	leave  
  800656:	c3                   	ret    
		return -E_INVAL;
  800657:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80065c:	eb f7                	jmp    800655 <vsnprintf+0x45>

0080065e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80065e:	55                   	push   %ebp
  80065f:	89 e5                	mov    %esp,%ebp
  800661:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800664:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800667:	50                   	push   %eax
  800668:	ff 75 10             	push   0x10(%ebp)
  80066b:	ff 75 0c             	push   0xc(%ebp)
  80066e:	ff 75 08             	push   0x8(%ebp)
  800671:	e8 9a ff ff ff       	call   800610 <vsnprintf>
	va_end(ap);

	return rc;
}
  800676:	c9                   	leave  
  800677:	c3                   	ret    

00800678 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800678:	55                   	push   %ebp
  800679:	89 e5                	mov    %esp,%ebp
  80067b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80067e:	b8 00 00 00 00       	mov    $0x0,%eax
  800683:	eb 03                	jmp    800688 <strlen+0x10>
		n++;
  800685:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800688:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80068c:	75 f7                	jne    800685 <strlen+0xd>
	return n;
}
  80068e:	5d                   	pop    %ebp
  80068f:	c3                   	ret    

00800690 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800690:	55                   	push   %ebp
  800691:	89 e5                	mov    %esp,%ebp
  800693:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800696:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800699:	b8 00 00 00 00       	mov    $0x0,%eax
  80069e:	eb 03                	jmp    8006a3 <strnlen+0x13>
		n++;
  8006a0:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006a3:	39 d0                	cmp    %edx,%eax
  8006a5:	74 08                	je     8006af <strnlen+0x1f>
  8006a7:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8006ab:	75 f3                	jne    8006a0 <strnlen+0x10>
  8006ad:	89 c2                	mov    %eax,%edx
	return n;
}
  8006af:	89 d0                	mov    %edx,%eax
  8006b1:	5d                   	pop    %ebp
  8006b2:	c3                   	ret    

008006b3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006b3:	55                   	push   %ebp
  8006b4:	89 e5                	mov    %esp,%ebp
  8006b6:	53                   	push   %ebx
  8006b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8006c2:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8006c6:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8006c9:	83 c0 01             	add    $0x1,%eax
  8006cc:	84 d2                	test   %dl,%dl
  8006ce:	75 f2                	jne    8006c2 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8006d0:	89 c8                	mov    %ecx,%eax
  8006d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006d5:	c9                   	leave  
  8006d6:	c3                   	ret    

008006d7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8006d7:	55                   	push   %ebp
  8006d8:	89 e5                	mov    %esp,%ebp
  8006da:	53                   	push   %ebx
  8006db:	83 ec 10             	sub    $0x10,%esp
  8006de:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8006e1:	53                   	push   %ebx
  8006e2:	e8 91 ff ff ff       	call   800678 <strlen>
  8006e7:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8006ea:	ff 75 0c             	push   0xc(%ebp)
  8006ed:	01 d8                	add    %ebx,%eax
  8006ef:	50                   	push   %eax
  8006f0:	e8 be ff ff ff       	call   8006b3 <strcpy>
	return dst;
}
  8006f5:	89 d8                	mov    %ebx,%eax
  8006f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006fa:	c9                   	leave  
  8006fb:	c3                   	ret    

008006fc <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size)
{
  8006fc:	55                   	push   %ebp
  8006fd:	89 e5                	mov    %esp,%ebp
  8006ff:	56                   	push   %esi
  800700:	53                   	push   %ebx
  800701:	8b 75 08             	mov    0x8(%ebp),%esi
  800704:	8b 55 0c             	mov    0xc(%ebp),%edx
  800707:	89 f3                	mov    %esi,%ebx
  800709:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80070c:	89 f0                	mov    %esi,%eax
  80070e:	eb 0f                	jmp    80071f <strncpy+0x23>
		*dst++ = *src;
  800710:	83 c0 01             	add    $0x1,%eax
  800713:	0f b6 0a             	movzbl (%edx),%ecx
  800716:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800719:	80 f9 01             	cmp    $0x1,%cl
  80071c:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  80071f:	39 d8                	cmp    %ebx,%eax
  800721:	75 ed                	jne    800710 <strncpy+0x14>
	}
	return ret;
}
  800723:	89 f0                	mov    %esi,%eax
  800725:	5b                   	pop    %ebx
  800726:	5e                   	pop    %esi
  800727:	5d                   	pop    %ebp
  800728:	c3                   	ret    

00800729 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800729:	55                   	push   %ebp
  80072a:	89 e5                	mov    %esp,%ebp
  80072c:	56                   	push   %esi
  80072d:	53                   	push   %ebx
  80072e:	8b 75 08             	mov    0x8(%ebp),%esi
  800731:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800734:	8b 55 10             	mov    0x10(%ebp),%edx
  800737:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800739:	85 d2                	test   %edx,%edx
  80073b:	74 21                	je     80075e <strlcpy+0x35>
  80073d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800741:	89 f2                	mov    %esi,%edx
  800743:	eb 09                	jmp    80074e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800745:	83 c1 01             	add    $0x1,%ecx
  800748:	83 c2 01             	add    $0x1,%edx
  80074b:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  80074e:	39 c2                	cmp    %eax,%edx
  800750:	74 09                	je     80075b <strlcpy+0x32>
  800752:	0f b6 19             	movzbl (%ecx),%ebx
  800755:	84 db                	test   %bl,%bl
  800757:	75 ec                	jne    800745 <strlcpy+0x1c>
  800759:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80075b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80075e:	29 f0                	sub    %esi,%eax
}
  800760:	5b                   	pop    %ebx
  800761:	5e                   	pop    %esi
  800762:	5d                   	pop    %ebp
  800763:	c3                   	ret    

00800764 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800764:	55                   	push   %ebp
  800765:	89 e5                	mov    %esp,%ebp
  800767:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80076a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80076d:	eb 06                	jmp    800775 <strcmp+0x11>
		p++, q++;
  80076f:	83 c1 01             	add    $0x1,%ecx
  800772:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800775:	0f b6 01             	movzbl (%ecx),%eax
  800778:	84 c0                	test   %al,%al
  80077a:	74 04                	je     800780 <strcmp+0x1c>
  80077c:	3a 02                	cmp    (%edx),%al
  80077e:	74 ef                	je     80076f <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800780:	0f b6 c0             	movzbl %al,%eax
  800783:	0f b6 12             	movzbl (%edx),%edx
  800786:	29 d0                	sub    %edx,%eax
}
  800788:	5d                   	pop    %ebp
  800789:	c3                   	ret    

0080078a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80078a:	55                   	push   %ebp
  80078b:	89 e5                	mov    %esp,%ebp
  80078d:	53                   	push   %ebx
  80078e:	8b 45 08             	mov    0x8(%ebp),%eax
  800791:	8b 55 0c             	mov    0xc(%ebp),%edx
  800794:	89 c3                	mov    %eax,%ebx
  800796:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800799:	eb 06                	jmp    8007a1 <strncmp+0x17>
		n--, p++, q++;
  80079b:	83 c0 01             	add    $0x1,%eax
  80079e:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8007a1:	39 d8                	cmp    %ebx,%eax
  8007a3:	74 18                	je     8007bd <strncmp+0x33>
  8007a5:	0f b6 08             	movzbl (%eax),%ecx
  8007a8:	84 c9                	test   %cl,%cl
  8007aa:	74 04                	je     8007b0 <strncmp+0x26>
  8007ac:	3a 0a                	cmp    (%edx),%cl
  8007ae:	74 eb                	je     80079b <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007b0:	0f b6 00             	movzbl (%eax),%eax
  8007b3:	0f b6 12             	movzbl (%edx),%edx
  8007b6:	29 d0                	sub    %edx,%eax
}
  8007b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007bb:	c9                   	leave  
  8007bc:	c3                   	ret    
		return 0;
  8007bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c2:	eb f4                	jmp    8007b8 <strncmp+0x2e>

008007c4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007c4:	55                   	push   %ebp
  8007c5:	89 e5                	mov    %esp,%ebp
  8007c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ca:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007ce:	eb 03                	jmp    8007d3 <strchr+0xf>
  8007d0:	83 c0 01             	add    $0x1,%eax
  8007d3:	0f b6 10             	movzbl (%eax),%edx
  8007d6:	84 d2                	test   %dl,%dl
  8007d8:	74 06                	je     8007e0 <strchr+0x1c>
		if (*s == c)
  8007da:	38 ca                	cmp    %cl,%dl
  8007dc:	75 f2                	jne    8007d0 <strchr+0xc>
  8007de:	eb 05                	jmp    8007e5 <strchr+0x21>
			return (char *) s;
	return 0;
  8007e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007e5:	5d                   	pop    %ebp
  8007e6:	c3                   	ret    

008007e7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8007e7:	55                   	push   %ebp
  8007e8:	89 e5                	mov    %esp,%ebp
  8007ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ed:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007f1:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8007f4:	38 ca                	cmp    %cl,%dl
  8007f6:	74 09                	je     800801 <strfind+0x1a>
  8007f8:	84 d2                	test   %dl,%dl
  8007fa:	74 05                	je     800801 <strfind+0x1a>
	for (; *s; s++)
  8007fc:	83 c0 01             	add    $0x1,%eax
  8007ff:	eb f0                	jmp    8007f1 <strfind+0xa>
			break;
	return (char *) s;
}
  800801:	5d                   	pop    %ebp
  800802:	c3                   	ret    

00800803 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800803:	55                   	push   %ebp
  800804:	89 e5                	mov    %esp,%ebp
  800806:	57                   	push   %edi
  800807:	56                   	push   %esi
  800808:	53                   	push   %ebx
  800809:	8b 55 08             	mov    0x8(%ebp),%edx
  80080c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  80080f:	85 c9                	test   %ecx,%ecx
  800811:	74 33                	je     800846 <memset+0x43>
		return v;
	if ((int) v % 4 == 0 && n % 4 == 0) {
  800813:	89 d0                	mov    %edx,%eax
  800815:	09 c8                	or     %ecx,%eax
  800817:	a8 03                	test   $0x3,%al
  800819:	75 23                	jne    80083e <memset+0x3b>
		c &= 0xFF;
  80081b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  80081f:	89 d8                	mov    %ebx,%eax
  800821:	c1 e0 08             	shl    $0x8,%eax
  800824:	89 df                	mov    %ebx,%edi
  800826:	c1 e7 18             	shl    $0x18,%edi
  800829:	89 de                	mov    %ebx,%esi
  80082b:	c1 e6 10             	shl    $0x10,%esi
  80082e:	09 f7                	or     %esi,%edi
  800830:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
		             : "=D"(p), "=c"(n)
		             : "D"(p), "a"(c), "c"(n / 4)
  800832:	c1 e9 02             	shr    $0x2,%ecx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  800835:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800837:	89 d7                	mov    %edx,%edi
  800839:	fc                   	cld    
  80083a:	f3 ab                	rep stos %eax,%es:(%edi)
  80083c:	eb 08                	jmp    800846 <memset+0x43>
		             : "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80083e:	89 d7                	mov    %edx,%edi
  800840:	8b 45 0c             	mov    0xc(%ebp),%eax
  800843:	fc                   	cld    
  800844:	f3 aa                	rep stos %al,%es:(%edi)
		             : "=D"(p), "=c"(n)
		             : "0"(p), "a"(c), "1"(n)
		             : "cc", "memory");
	return v;
}
  800846:	89 d0                	mov    %edx,%eax
  800848:	5b                   	pop    %ebx
  800849:	5e                   	pop    %esi
  80084a:	5f                   	pop    %edi
  80084b:	5d                   	pop    %ebp
  80084c:	c3                   	ret    

0080084d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80084d:	55                   	push   %ebp
  80084e:	89 e5                	mov    %esp,%ebp
  800850:	57                   	push   %edi
  800851:	56                   	push   %esi
  800852:	8b 45 08             	mov    0x8(%ebp),%eax
  800855:	8b 75 0c             	mov    0xc(%ebp),%esi
  800858:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80085b:	39 c6                	cmp    %eax,%esi
  80085d:	73 32                	jae    800891 <memmove+0x44>
  80085f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800862:	39 c2                	cmp    %eax,%edx
  800864:	76 2b                	jbe    800891 <memmove+0x44>
		s += n;
		d += n;
  800866:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  800869:	89 d6                	mov    %edx,%esi
  80086b:	09 fe                	or     %edi,%esi
  80086d:	09 ce                	or     %ecx,%esi
  80086f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800875:	75 0e                	jne    800885 <memmove+0x38>
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  800877:	83 ef 04             	sub    $0x4,%edi
			             "S"(s - 4),
  80087a:	8d 72 fc             	lea    -0x4(%edx),%esi
			             "c"(n / 4)
  80087d:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  800880:	fd                   	std    
  800881:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800883:	eb 09                	jmp    80088e <memmove+0x41>
			             : "cc", "memory");
		else
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  800885:	83 ef 01             	sub    $0x1,%edi
			             "S"(s - 1),
  800888:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  80088b:	fd                   	std    
  80088c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             "c"(n)
			             : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80088e:	fc                   	cld    
  80088f:	eb 1a                	jmp    8008ab <memmove+0x5e>
	} else {
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  800891:	89 f2                	mov    %esi,%edx
  800893:	09 c2                	or     %eax,%edx
  800895:	09 ca                	or     %ecx,%edx
  800897:	f6 c2 03             	test   $0x3,%dl
  80089a:	75 0a                	jne    8008a6 <memmove+0x59>
			asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  80089c:	c1 e9 02             	shr    $0x2,%ecx
  80089f:	89 c7                	mov    %eax,%edi
  8008a1:	fc                   	cld    
  8008a2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008a4:	eb 05                	jmp    8008ab <memmove+0x5e>
			             : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  8008a6:	89 c7                	mov    %eax,%edi
  8008a8:	fc                   	cld    
  8008a9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             : "cc", "memory");
	}
	return dst;
}
  8008ab:	5e                   	pop    %esi
  8008ac:	5f                   	pop    %edi
  8008ad:	5d                   	pop    %ebp
  8008ae:	c3                   	ret    

008008af <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008af:	55                   	push   %ebp
  8008b0:	89 e5                	mov    %esp,%ebp
  8008b2:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8008b5:	ff 75 10             	push   0x10(%ebp)
  8008b8:	ff 75 0c             	push   0xc(%ebp)
  8008bb:	ff 75 08             	push   0x8(%ebp)
  8008be:	e8 8a ff ff ff       	call   80084d <memmove>
}
  8008c3:	c9                   	leave  
  8008c4:	c3                   	ret    

008008c5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008c5:	55                   	push   %ebp
  8008c6:	89 e5                	mov    %esp,%ebp
  8008c8:	56                   	push   %esi
  8008c9:	53                   	push   %ebx
  8008ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d0:	89 c6                	mov    %eax,%esi
  8008d2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8008d5:	eb 06                	jmp    8008dd <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8008d7:	83 c0 01             	add    $0x1,%eax
  8008da:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  8008dd:	39 f0                	cmp    %esi,%eax
  8008df:	74 14                	je     8008f5 <memcmp+0x30>
		if (*s1 != *s2)
  8008e1:	0f b6 08             	movzbl (%eax),%ecx
  8008e4:	0f b6 1a             	movzbl (%edx),%ebx
  8008e7:	38 d9                	cmp    %bl,%cl
  8008e9:	74 ec                	je     8008d7 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  8008eb:	0f b6 c1             	movzbl %cl,%eax
  8008ee:	0f b6 db             	movzbl %bl,%ebx
  8008f1:	29 d8                	sub    %ebx,%eax
  8008f3:	eb 05                	jmp    8008fa <memcmp+0x35>
	}

	return 0;
  8008f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008fa:	5b                   	pop    %ebx
  8008fb:	5e                   	pop    %esi
  8008fc:	5d                   	pop    %ebp
  8008fd:	c3                   	ret    

008008fe <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8008fe:	55                   	push   %ebp
  8008ff:	89 e5                	mov    %esp,%ebp
  800901:	8b 45 08             	mov    0x8(%ebp),%eax
  800904:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800907:	89 c2                	mov    %eax,%edx
  800909:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80090c:	eb 03                	jmp    800911 <memfind+0x13>
  80090e:	83 c0 01             	add    $0x1,%eax
  800911:	39 d0                	cmp    %edx,%eax
  800913:	73 04                	jae    800919 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800915:	38 08                	cmp    %cl,(%eax)
  800917:	75 f5                	jne    80090e <memfind+0x10>
			break;
	return (void *) s;
}
  800919:	5d                   	pop    %ebp
  80091a:	c3                   	ret    

0080091b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	57                   	push   %edi
  80091f:	56                   	push   %esi
  800920:	53                   	push   %ebx
  800921:	8b 55 08             	mov    0x8(%ebp),%edx
  800924:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800927:	eb 03                	jmp    80092c <strtol+0x11>
		s++;
  800929:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  80092c:	0f b6 02             	movzbl (%edx),%eax
  80092f:	3c 20                	cmp    $0x20,%al
  800931:	74 f6                	je     800929 <strtol+0xe>
  800933:	3c 09                	cmp    $0x9,%al
  800935:	74 f2                	je     800929 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800937:	3c 2b                	cmp    $0x2b,%al
  800939:	74 2a                	je     800965 <strtol+0x4a>
	int neg = 0;
  80093b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800940:	3c 2d                	cmp    $0x2d,%al
  800942:	74 2b                	je     80096f <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800944:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80094a:	75 0f                	jne    80095b <strtol+0x40>
  80094c:	80 3a 30             	cmpb   $0x30,(%edx)
  80094f:	74 28                	je     800979 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800951:	85 db                	test   %ebx,%ebx
  800953:	b8 0a 00 00 00       	mov    $0xa,%eax
  800958:	0f 44 d8             	cmove  %eax,%ebx
  80095b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800960:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800963:	eb 46                	jmp    8009ab <strtol+0x90>
		s++;
  800965:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800968:	bf 00 00 00 00       	mov    $0x0,%edi
  80096d:	eb d5                	jmp    800944 <strtol+0x29>
		s++, neg = 1;
  80096f:	83 c2 01             	add    $0x1,%edx
  800972:	bf 01 00 00 00       	mov    $0x1,%edi
  800977:	eb cb                	jmp    800944 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800979:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80097d:	74 0e                	je     80098d <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  80097f:	85 db                	test   %ebx,%ebx
  800981:	75 d8                	jne    80095b <strtol+0x40>
		s++, base = 8;
  800983:	83 c2 01             	add    $0x1,%edx
  800986:	bb 08 00 00 00       	mov    $0x8,%ebx
  80098b:	eb ce                	jmp    80095b <strtol+0x40>
		s += 2, base = 16;
  80098d:	83 c2 02             	add    $0x2,%edx
  800990:	bb 10 00 00 00       	mov    $0x10,%ebx
  800995:	eb c4                	jmp    80095b <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800997:	0f be c0             	movsbl %al,%eax
  80099a:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  80099d:	3b 45 10             	cmp    0x10(%ebp),%eax
  8009a0:	7d 3a                	jge    8009dc <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  8009a2:	83 c2 01             	add    $0x1,%edx
  8009a5:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  8009a9:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  8009ab:	0f b6 02             	movzbl (%edx),%eax
  8009ae:	8d 70 d0             	lea    -0x30(%eax),%esi
  8009b1:	89 f3                	mov    %esi,%ebx
  8009b3:	80 fb 09             	cmp    $0x9,%bl
  8009b6:	76 df                	jbe    800997 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  8009b8:	8d 70 9f             	lea    -0x61(%eax),%esi
  8009bb:	89 f3                	mov    %esi,%ebx
  8009bd:	80 fb 19             	cmp    $0x19,%bl
  8009c0:	77 08                	ja     8009ca <strtol+0xaf>
			dig = *s - 'a' + 10;
  8009c2:	0f be c0             	movsbl %al,%eax
  8009c5:	83 e8 57             	sub    $0x57,%eax
  8009c8:	eb d3                	jmp    80099d <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  8009ca:	8d 70 bf             	lea    -0x41(%eax),%esi
  8009cd:	89 f3                	mov    %esi,%ebx
  8009cf:	80 fb 19             	cmp    $0x19,%bl
  8009d2:	77 08                	ja     8009dc <strtol+0xc1>
			dig = *s - 'A' + 10;
  8009d4:	0f be c0             	movsbl %al,%eax
  8009d7:	83 e8 37             	sub    $0x37,%eax
  8009da:	eb c1                	jmp    80099d <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  8009dc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8009e0:	74 05                	je     8009e7 <strtol+0xcc>
		*endptr = (char *) s;
  8009e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e5:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  8009e7:	89 c8                	mov    %ecx,%eax
  8009e9:	f7 d8                	neg    %eax
  8009eb:	85 ff                	test   %edi,%edi
  8009ed:	0f 45 c8             	cmovne %eax,%ecx
}
  8009f0:	89 c8                	mov    %ecx,%eax
  8009f2:	5b                   	pop    %ebx
  8009f3:	5e                   	pop    %esi
  8009f4:	5f                   	pop    %edi
  8009f5:	5d                   	pop    %ebp
  8009f6:	c3                   	ret    

008009f7 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8009f7:	55                   	push   %ebp
  8009f8:	89 e5                	mov    %esp,%ebp
  8009fa:	57                   	push   %edi
  8009fb:	56                   	push   %esi
  8009fc:	53                   	push   %ebx
  8009fd:	83 ec 1c             	sub    $0x1c,%esp
  800a00:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a03:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800a06:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile(
  800a08:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a0b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a0e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800a11:	8b 75 14             	mov    0x14(%ebp),%esi
  800a14:	cd 30                	int    $0x30
	        "int %1\n"
	        : "=a"(ret)
	        : "i"(T_SYSCALL), "a"(num), "d"(a1), "c"(a2), "b"(a3), "D"(a4), "S"(a5)
	        : "cc", "memory");

	if (check && ret > 0)
  800a16:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a1a:	74 04                	je     800a20 <syscall+0x29>
  800a1c:	85 c0                	test   %eax,%eax
  800a1e:	7f 08                	jg     800a28 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800a20:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a23:	5b                   	pop    %ebx
  800a24:	5e                   	pop    %esi
  800a25:	5f                   	pop    %edi
  800a26:	5d                   	pop    %ebp
  800a27:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800a28:	83 ec 0c             	sub    $0xc,%esp
  800a2b:	50                   	push   %eax
  800a2c:	ff 75 e0             	push   -0x20(%ebp)
  800a2f:	68 24 16 80 00       	push   $0x801624
  800a34:	6a 1e                	push   $0x1e
  800a36:	68 41 16 80 00       	push   $0x801641
  800a3b:	e8 59 06 00 00       	call   801099 <_panic>

00800a40 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800a40:	55                   	push   %ebp
  800a41:	89 e5                	mov    %esp,%ebp
  800a43:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t) s, len, 0, 0, 0);
  800a46:	6a 00                	push   $0x0
  800a48:	6a 00                	push   $0x0
  800a4a:	6a 00                	push   $0x0
  800a4c:	ff 75 0c             	push   0xc(%ebp)
  800a4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a52:	ba 00 00 00 00       	mov    $0x0,%edx
  800a57:	b8 00 00 00 00       	mov    $0x0,%eax
  800a5c:	e8 96 ff ff ff       	call   8009f7 <syscall>
}
  800a61:	83 c4 10             	add    $0x10,%esp
  800a64:	c9                   	leave  
  800a65:	c3                   	ret    

00800a66 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a66:	55                   	push   %ebp
  800a67:	89 e5                	mov    %esp,%ebp
  800a69:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800a6c:	6a 00                	push   $0x0
  800a6e:	6a 00                	push   $0x0
  800a70:	6a 00                	push   $0x0
  800a72:	6a 00                	push   $0x0
  800a74:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a79:	ba 00 00 00 00       	mov    $0x0,%edx
  800a7e:	b8 01 00 00 00       	mov    $0x1,%eax
  800a83:	e8 6f ff ff ff       	call   8009f7 <syscall>
}
  800a88:	c9                   	leave  
  800a89:	c3                   	ret    

00800a8a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a8a:	55                   	push   %ebp
  800a8b:	89 e5                	mov    %esp,%ebp
  800a8d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800a90:	6a 00                	push   $0x0
  800a92:	6a 00                	push   $0x0
  800a94:	6a 00                	push   $0x0
  800a96:	6a 00                	push   $0x0
  800a98:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a9b:	ba 01 00 00 00       	mov    $0x1,%edx
  800aa0:	b8 03 00 00 00       	mov    $0x3,%eax
  800aa5:	e8 4d ff ff ff       	call   8009f7 <syscall>
}
  800aaa:	c9                   	leave  
  800aab:	c3                   	ret    

00800aac <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800aac:	55                   	push   %ebp
  800aad:	89 e5                	mov    %esp,%ebp
  800aaf:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800ab2:	6a 00                	push   $0x0
  800ab4:	6a 00                	push   $0x0
  800ab6:	6a 00                	push   $0x0
  800ab8:	6a 00                	push   $0x0
  800aba:	b9 00 00 00 00       	mov    $0x0,%ecx
  800abf:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac4:	b8 02 00 00 00       	mov    $0x2,%eax
  800ac9:	e8 29 ff ff ff       	call   8009f7 <syscall>
}
  800ace:	c9                   	leave  
  800acf:	c3                   	ret    

00800ad0 <sys_yield>:

void
sys_yield(void)
{
  800ad0:	55                   	push   %ebp
  800ad1:	89 e5                	mov    %esp,%ebp
  800ad3:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800ad6:	6a 00                	push   $0x0
  800ad8:	6a 00                	push   $0x0
  800ada:	6a 00                	push   $0x0
  800adc:	6a 00                	push   $0x0
  800ade:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ae3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae8:	b8 0a 00 00 00       	mov    $0xa,%eax
  800aed:	e8 05 ff ff ff       	call   8009f7 <syscall>
}
  800af2:	83 c4 10             	add    $0x10,%esp
  800af5:	c9                   	leave  
  800af6:	c3                   	ret    

00800af7 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800af7:	55                   	push   %ebp
  800af8:	89 e5                	mov    %esp,%ebp
  800afa:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800afd:	6a 00                	push   $0x0
  800aff:	6a 00                	push   $0x0
  800b01:	ff 75 10             	push   0x10(%ebp)
  800b04:	ff 75 0c             	push   0xc(%ebp)
  800b07:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b0a:	ba 01 00 00 00       	mov    $0x1,%edx
  800b0f:	b8 04 00 00 00       	mov    $0x4,%eax
  800b14:	e8 de fe ff ff       	call   8009f7 <syscall>
}
  800b19:	c9                   	leave  
  800b1a:	c3                   	ret    

00800b1b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b1b:	55                   	push   %ebp
  800b1c:	89 e5                	mov    %esp,%ebp
  800b1e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map,
  800b21:	ff 75 18             	push   0x18(%ebp)
  800b24:	ff 75 14             	push   0x14(%ebp)
  800b27:	ff 75 10             	push   0x10(%ebp)
  800b2a:	ff 75 0c             	push   0xc(%ebp)
  800b2d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b30:	ba 01 00 00 00       	mov    $0x1,%edx
  800b35:	b8 05 00 00 00       	mov    $0x5,%eax
  800b3a:	e8 b8 fe ff ff       	call   8009f7 <syscall>
	               srcenv,
	               (uint32_t) srcva,
	               dstenv,
	               (uint32_t) dstva,
	               perm);
}
  800b3f:	c9                   	leave  
  800b40:	c3                   	ret    

00800b41 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b41:	55                   	push   %ebp
  800b42:	89 e5                	mov    %esp,%ebp
  800b44:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800b47:	6a 00                	push   $0x0
  800b49:	6a 00                	push   $0x0
  800b4b:	6a 00                	push   $0x0
  800b4d:	ff 75 0c             	push   0xc(%ebp)
  800b50:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b53:	ba 01 00 00 00       	mov    $0x1,%edx
  800b58:	b8 06 00 00 00       	mov    $0x6,%eax
  800b5d:	e8 95 fe ff ff       	call   8009f7 <syscall>
}
  800b62:	c9                   	leave  
  800b63:	c3                   	ret    

00800b64 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800b64:	55                   	push   %ebp
  800b65:	89 e5                	mov    %esp,%ebp
  800b67:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800b6a:	6a 00                	push   $0x0
  800b6c:	6a 00                	push   $0x0
  800b6e:	6a 00                	push   $0x0
  800b70:	ff 75 0c             	push   0xc(%ebp)
  800b73:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b76:	ba 01 00 00 00       	mov    $0x1,%edx
  800b7b:	b8 08 00 00 00       	mov    $0x8,%eax
  800b80:	e8 72 fe ff ff       	call   8009f7 <syscall>
}
  800b85:	c9                   	leave  
  800b86:	c3                   	ret    

00800b87 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800b87:	55                   	push   %ebp
  800b88:	89 e5                	mov    %esp,%ebp
  800b8a:	83 ec 08             	sub    $0x8,%esp
	return syscall(
  800b8d:	6a 00                	push   $0x0
  800b8f:	6a 00                	push   $0x0
  800b91:	6a 00                	push   $0x0
  800b93:	ff 75 0c             	push   0xc(%ebp)
  800b96:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b99:	ba 01 00 00 00       	mov    $0x1,%edx
  800b9e:	b8 09 00 00 00       	mov    $0x9,%eax
  800ba3:	e8 4f fe ff ff       	call   8009f7 <syscall>
	        SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ba8:	c9                   	leave  
  800ba9:	c3                   	ret    

00800baa <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800baa:	55                   	push   %ebp
  800bab:	89 e5                	mov    %esp,%ebp
  800bad:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800bb0:	6a 00                	push   $0x0
  800bb2:	ff 75 14             	push   0x14(%ebp)
  800bb5:	ff 75 10             	push   0x10(%ebp)
  800bb8:	ff 75 0c             	push   0xc(%ebp)
  800bbb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bbe:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc3:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bc8:	e8 2a fe ff ff       	call   8009f7 <syscall>
}
  800bcd:	c9                   	leave  
  800bce:	c3                   	ret    

00800bcf <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800bcf:	55                   	push   %ebp
  800bd0:	89 e5                	mov    %esp,%ebp
  800bd2:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t) dstva, 0, 0, 0, 0);
  800bd5:	6a 00                	push   $0x0
  800bd7:	6a 00                	push   $0x0
  800bd9:	6a 00                	push   $0x0
  800bdb:	6a 00                	push   $0x0
  800bdd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800be0:	ba 01 00 00 00       	mov    $0x1,%edx
  800be5:	b8 0c 00 00 00       	mov    $0xc,%eax
  800bea:	e8 08 fe ff ff       	call   8009f7 <syscall>
}
  800bef:	c9                   	leave  
  800bf0:	c3                   	ret    

00800bf1 <sys_get_priority>:

// Get priority of the current process
int
sys_get_priority(void)
{
  800bf1:	55                   	push   %ebp
  800bf2:	89 e5                	mov    %esp,%ebp
  800bf4:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_get_priority, 0, 0, 0, 0, 0, 0);
  800bf7:	6a 00                	push   $0x0
  800bf9:	6a 00                	push   $0x0
  800bfb:	6a 00                	push   $0x0
  800bfd:	6a 00                	push   $0x0
  800bff:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c04:	ba 00 00 00 00       	mov    $0x0,%edx
  800c09:	b8 0d 00 00 00       	mov    $0xd,%eax
  800c0e:	e8 e4 fd ff ff       	call   8009f7 <syscall>
}
  800c13:	c9                   	leave  
  800c14:	c3                   	ret    

00800c15 <sys_set_priority>:

// Get priority of the current process
int
sys_set_priority(unsigned int priority)
{
  800c15:	55                   	push   %ebp
  800c16:	89 e5                	mov    %esp,%ebp
  800c18:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, (uint32_t) priority, 0, 0, 0, 0);
  800c1b:	6a 00                	push   $0x0
  800c1d:	6a 00                	push   $0x0
  800c1f:	6a 00                	push   $0x0
  800c21:	6a 00                	push   $0x0
  800c23:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c26:	ba 00 00 00 00       	mov    $0x0,%edx
  800c2b:	b8 0e 00 00 00       	mov    $0xe,%eax
  800c30:	e8 c2 fd ff ff       	call   8009f7 <syscall>
}
  800c35:	c9                   	leave  
  800c36:	c3                   	ret    

00800c37 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	56                   	push   %esi
  800c3b:	53                   	push   %ebx
  800c3c:	89 c1                	mov    %eax,%ecx
	int r;

	void *addr = (void *) (pn << PGSHIFT);
  800c3e:	89 d6                	mov    %edx,%esi
  800c40:	c1 e6 0c             	shl    $0xc,%esi

	pte_t pte = uvpt[pn];
  800c43:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx

	if (!(pte & PTE_P) || !(pte & PTE_U))
  800c4a:	89 d0                	mov    %edx,%eax
  800c4c:	83 e0 05             	and    $0x5,%eax
  800c4f:	83 f8 05             	cmp    $0x5,%eax
  800c52:	75 5a                	jne    800cae <duppage+0x77>
		panic("duppage: copy a non-present or non-user page");

	int perm = PTE_U | PTE_P;
	// Verifico permisos para páginas de IO
	if (pte & (PTE_PCD | PTE_PWT))
  800c54:	89 d0                	mov    %edx,%eax
  800c56:	83 e0 18             	and    $0x18,%eax
		perm |= PTE_PCD | PTE_PWT;
  800c59:	83 f8 01             	cmp    $0x1,%eax
  800c5c:	19 c0                	sbb    %eax,%eax
  800c5e:	83 e0 e8             	and    $0xffffffe8,%eax
  800c61:	83 c0 1d             	add    $0x1d,%eax


	// Si es de escritura o copy-on-write y NO es de IO
	if ((pte & PTE_W) || (pte & PTE_COW)) {
  800c64:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800c6a:	74 68                	je     800cd4 <duppage+0x9d>
		// Mappeo en el hijo la página
		if ((r = sys_page_map(0, addr, envid, addr, perm | PTE_COW)) < 0)
  800c6c:	80 cc 08             	or     $0x8,%ah
  800c6f:	89 c3                	mov    %eax,%ebx
  800c71:	83 ec 0c             	sub    $0xc,%esp
  800c74:	50                   	push   %eax
  800c75:	56                   	push   %esi
  800c76:	51                   	push   %ecx
  800c77:	56                   	push   %esi
  800c78:	6a 00                	push   $0x0
  800c7a:	e8 9c fe ff ff       	call   800b1b <sys_page_map>
  800c7f:	83 c4 20             	add    $0x20,%esp
  800c82:	85 c0                	test   %eax,%eax
  800c84:	78 3c                	js     800cc2 <duppage+0x8b>
			panic("duppage: sys_page_map on childern COW: %e", r);

		// Cambio los permisos del padre
		if ((r = sys_page_map(0, addr, 0, addr, perm | PTE_COW)) < 0)
  800c86:	83 ec 0c             	sub    $0xc,%esp
  800c89:	53                   	push   %ebx
  800c8a:	56                   	push   %esi
  800c8b:	6a 00                	push   $0x0
  800c8d:	56                   	push   %esi
  800c8e:	6a 00                	push   $0x0
  800c90:	e8 86 fe ff ff       	call   800b1b <sys_page_map>
  800c95:	83 c4 20             	add    $0x20,%esp
  800c98:	85 c0                	test   %eax,%eax
  800c9a:	79 4d                	jns    800ce9 <duppage+0xb2>
			panic("duppage: sys_page_map on parent COW: %e", r);
  800c9c:	50                   	push   %eax
  800c9d:	68 ac 16 80 00       	push   $0x8016ac
  800ca2:	6a 57                	push   $0x57
  800ca4:	68 a1 17 80 00       	push   $0x8017a1
  800ca9:	e8 eb 03 00 00       	call   801099 <_panic>
		panic("duppage: copy a non-present or non-user page");
  800cae:	83 ec 04             	sub    $0x4,%esp
  800cb1:	68 50 16 80 00       	push   $0x801650
  800cb6:	6a 47                	push   $0x47
  800cb8:	68 a1 17 80 00       	push   $0x8017a1
  800cbd:	e8 d7 03 00 00       	call   801099 <_panic>
			panic("duppage: sys_page_map on childern COW: %e", r);
  800cc2:	50                   	push   %eax
  800cc3:	68 80 16 80 00       	push   $0x801680
  800cc8:	6a 53                	push   $0x53
  800cca:	68 a1 17 80 00       	push   $0x8017a1
  800ccf:	e8 c5 03 00 00       	call   801099 <_panic>
	} else {
		// Solo mappeo la página de solo lectura
		if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  800cd4:	83 ec 0c             	sub    $0xc,%esp
  800cd7:	50                   	push   %eax
  800cd8:	56                   	push   %esi
  800cd9:	51                   	push   %ecx
  800cda:	56                   	push   %esi
  800cdb:	6a 00                	push   $0x0
  800cdd:	e8 39 fe ff ff       	call   800b1b <sys_page_map>
  800ce2:	83 c4 20             	add    $0x20,%esp
  800ce5:	85 c0                	test   %eax,%eax
  800ce7:	78 0c                	js     800cf5 <duppage+0xbe>
			panic("duppage: sys_page_map on childern RO: %e", r);
	}

	// panic("duppage not implemented");
	return 0;
}
  800ce9:	b8 00 00 00 00       	mov    $0x0,%eax
  800cee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cf1:	5b                   	pop    %ebx
  800cf2:	5e                   	pop    %esi
  800cf3:	5d                   	pop    %ebp
  800cf4:	c3                   	ret    
			panic("duppage: sys_page_map on childern RO: %e", r);
  800cf5:	50                   	push   %eax
  800cf6:	68 d4 16 80 00       	push   $0x8016d4
  800cfb:	6a 5b                	push   $0x5b
  800cfd:	68 a1 17 80 00       	push   $0x8017a1
  800d02:	e8 92 03 00 00       	call   801099 <_panic>

00800d07 <dup_or_share>:
 *
 * Hace uso de uvpd y uvpt para chequear permisos.
 */
static void
dup_or_share(envid_t envid, uint32_t pnum, int perm)
{
  800d07:	55                   	push   %ebp
  800d08:	89 e5                	mov    %esp,%ebp
  800d0a:	57                   	push   %edi
  800d0b:	56                   	push   %esi
  800d0c:	53                   	push   %ebx
  800d0d:	83 ec 0c             	sub    $0xc,%esp
  800d10:	89 c7                	mov    %eax,%edi
	int r;
	void *addr = (void *) (pnum << PGSHIFT);

	pte_t pte = uvpt[pnum];
  800d12:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax

	if (!(pte & PTE_P))
  800d19:	a8 01                	test   $0x1,%al
  800d1b:	74 33                	je     800d50 <dup_or_share+0x49>
  800d1d:	89 d6                	mov    %edx,%esi
		return;

	// Filtro permisos
	perm &= (pte & PTE_W);
  800d1f:	21 c1                	and    %eax,%ecx
  800d21:	89 cb                	mov    %ecx,%ebx
  800d23:	83 e3 02             	and    $0x2,%ebx
	perm &= PTE_SYSCALL;


	if (pte & (PTE_PCD | PTE_PWT))
		perm |= PTE_PCD | PTE_PWT;
  800d26:	89 da                	mov    %ebx,%edx
  800d28:	83 ca 18             	or     $0x18,%edx
  800d2b:	a8 18                	test   $0x18,%al
  800d2d:	0f 45 da             	cmovne %edx,%ebx
	void *addr = (void *) (pnum << PGSHIFT);
  800d30:	c1 e6 0c             	shl    $0xc,%esi

	// Si tengo que copiar
	if (!(pte & PTE_W) || (pte & (PTE_PCD | PTE_PWT))) {
  800d33:	83 e0 1a             	and    $0x1a,%eax
  800d36:	83 f8 02             	cmp    $0x2,%eax
  800d39:	74 32                	je     800d6d <dup_or_share+0x66>
		if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  800d3b:	83 ec 0c             	sub    $0xc,%esp
  800d3e:	53                   	push   %ebx
  800d3f:	56                   	push   %esi
  800d40:	57                   	push   %edi
  800d41:	56                   	push   %esi
  800d42:	6a 00                	push   $0x0
  800d44:	e8 d2 fd ff ff       	call   800b1b <sys_page_map>
  800d49:	83 c4 20             	add    $0x20,%esp
  800d4c:	85 c0                	test   %eax,%eax
  800d4e:	78 08                	js     800d58 <dup_or_share+0x51>
			panic("dup_or_share: sys_page_map: %e", r);
		memmove(UTEMP, addr, PGSIZE);
		if ((r = sys_page_unmap(0, UTEMP)) < 0)
			panic("sys_page_unmap: %e", r);
	}
}
  800d50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d53:	5b                   	pop    %ebx
  800d54:	5e                   	pop    %esi
  800d55:	5f                   	pop    %edi
  800d56:	5d                   	pop    %ebp
  800d57:	c3                   	ret    
			panic("dup_or_share: sys_page_map: %e", r);
  800d58:	50                   	push   %eax
  800d59:	68 00 17 80 00       	push   $0x801700
  800d5e:	68 84 00 00 00       	push   $0x84
  800d63:	68 a1 17 80 00       	push   $0x8017a1
  800d68:	e8 2c 03 00 00       	call   801099 <_panic>
		if ((r = sys_page_alloc(envid, addr, perm)) < 0)
  800d6d:	83 ec 04             	sub    $0x4,%esp
  800d70:	53                   	push   %ebx
  800d71:	56                   	push   %esi
  800d72:	57                   	push   %edi
  800d73:	e8 7f fd ff ff       	call   800af7 <sys_page_alloc>
  800d78:	83 c4 10             	add    $0x10,%esp
  800d7b:	85 c0                	test   %eax,%eax
  800d7d:	78 57                	js     800dd6 <dup_or_share+0xcf>
		if ((r = sys_page_map(envid, addr, 0, UTEMP, perm)) < 0)
  800d7f:	83 ec 0c             	sub    $0xc,%esp
  800d82:	53                   	push   %ebx
  800d83:	68 00 00 40 00       	push   $0x400000
  800d88:	6a 00                	push   $0x0
  800d8a:	56                   	push   %esi
  800d8b:	57                   	push   %edi
  800d8c:	e8 8a fd ff ff       	call   800b1b <sys_page_map>
  800d91:	83 c4 20             	add    $0x20,%esp
  800d94:	85 c0                	test   %eax,%eax
  800d96:	78 53                	js     800deb <dup_or_share+0xe4>
		memmove(UTEMP, addr, PGSIZE);
  800d98:	83 ec 04             	sub    $0x4,%esp
  800d9b:	68 00 10 00 00       	push   $0x1000
  800da0:	56                   	push   %esi
  800da1:	68 00 00 40 00       	push   $0x400000
  800da6:	e8 a2 fa ff ff       	call   80084d <memmove>
		if ((r = sys_page_unmap(0, UTEMP)) < 0)
  800dab:	83 c4 08             	add    $0x8,%esp
  800dae:	68 00 00 40 00       	push   $0x400000
  800db3:	6a 00                	push   $0x0
  800db5:	e8 87 fd ff ff       	call   800b41 <sys_page_unmap>
  800dba:	83 c4 10             	add    $0x10,%esp
  800dbd:	85 c0                	test   %eax,%eax
  800dbf:	79 8f                	jns    800d50 <dup_or_share+0x49>
			panic("sys_page_unmap: %e", r);
  800dc1:	50                   	push   %eax
  800dc2:	68 eb 17 80 00       	push   $0x8017eb
  800dc7:	68 8d 00 00 00       	push   $0x8d
  800dcc:	68 a1 17 80 00       	push   $0x8017a1
  800dd1:	e8 c3 02 00 00       	call   801099 <_panic>
			panic("dup_or_share: sys_page_alloc: %e", r);
  800dd6:	50                   	push   %eax
  800dd7:	68 20 17 80 00       	push   $0x801720
  800ddc:	68 88 00 00 00       	push   $0x88
  800de1:	68 a1 17 80 00       	push   $0x8017a1
  800de6:	e8 ae 02 00 00       	call   801099 <_panic>
			panic("dup_or_share: sys_page_map: %e", r);
  800deb:	50                   	push   %eax
  800dec:	68 00 17 80 00       	push   $0x801700
  800df1:	68 8a 00 00 00       	push   $0x8a
  800df6:	68 a1 17 80 00       	push   $0x8017a1
  800dfb:	e8 99 02 00 00       	call   801099 <_panic>

00800e00 <pgfault>:
{
  800e00:	55                   	push   %ebp
  800e01:	89 e5                	mov    %esp,%ebp
  800e03:	53                   	push   %ebx
  800e04:	83 ec 08             	sub    $0x8,%esp
	void *addr = (void *) utf->utf_fault_va;
  800e07:	8b 45 08             	mov    0x8(%ebp),%eax
  800e0a:	8b 18                	mov    (%eax),%ebx
	pte_t fault_pte = uvpt[((uint32_t) addr) >> PGSHIFT];
  800e0c:	89 d8                	mov    %ebx,%eax
  800e0e:	c1 e8 0c             	shr    $0xc,%eax
  800e11:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if ((r = sys_page_alloc(0, PFTEMP, perm)) < 0)
  800e18:	6a 07                	push   $0x7
  800e1a:	68 00 f0 7f 00       	push   $0x7ff000
  800e1f:	6a 00                	push   $0x0
  800e21:	e8 d1 fc ff ff       	call   800af7 <sys_page_alloc>
  800e26:	83 c4 10             	add    $0x10,%esp
  800e29:	85 c0                	test   %eax,%eax
  800e2b:	78 51                	js     800e7e <pgfault+0x7e>
	addr = ROUNDDOWN(addr, PGSIZE);
  800e2d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr, PGSIZE);
  800e33:	83 ec 04             	sub    $0x4,%esp
  800e36:	68 00 10 00 00       	push   $0x1000
  800e3b:	53                   	push   %ebx
  800e3c:	68 00 f0 7f 00       	push   $0x7ff000
  800e41:	e8 07 fa ff ff       	call   80084d <memmove>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, perm)) < 0)
  800e46:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e4d:	53                   	push   %ebx
  800e4e:	6a 00                	push   $0x0
  800e50:	68 00 f0 7f 00       	push   $0x7ff000
  800e55:	6a 00                	push   $0x0
  800e57:	e8 bf fc ff ff       	call   800b1b <sys_page_map>
  800e5c:	83 c4 20             	add    $0x20,%esp
  800e5f:	85 c0                	test   %eax,%eax
  800e61:	78 2d                	js     800e90 <pgfault+0x90>
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800e63:	83 ec 08             	sub    $0x8,%esp
  800e66:	68 00 f0 7f 00       	push   $0x7ff000
  800e6b:	6a 00                	push   $0x0
  800e6d:	e8 cf fc ff ff       	call   800b41 <sys_page_unmap>
  800e72:	83 c4 10             	add    $0x10,%esp
  800e75:	85 c0                	test   %eax,%eax
  800e77:	78 29                	js     800ea2 <pgfault+0xa2>
}
  800e79:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e7c:	c9                   	leave  
  800e7d:	c3                   	ret    
		panic("pgfault: sys_page_alloc: %e", r);
  800e7e:	50                   	push   %eax
  800e7f:	68 ac 17 80 00       	push   $0x8017ac
  800e84:	6a 27                	push   $0x27
  800e86:	68 a1 17 80 00       	push   $0x8017a1
  800e8b:	e8 09 02 00 00       	call   801099 <_panic>
		panic("pgfault: sys_page_map: %e", r);
  800e90:	50                   	push   %eax
  800e91:	68 c8 17 80 00       	push   $0x8017c8
  800e96:	6a 2c                	push   $0x2c
  800e98:	68 a1 17 80 00       	push   $0x8017a1
  800e9d:	e8 f7 01 00 00       	call   801099 <_panic>
		panic("pgfault: sys_page_unmap: %e", r);
  800ea2:	50                   	push   %eax
  800ea3:	68 e2 17 80 00       	push   $0x8017e2
  800ea8:	6a 2f                	push   $0x2f
  800eaa:	68 a1 17 80 00       	push   $0x8017a1
  800eaf:	e8 e5 01 00 00       	call   801099 <_panic>

00800eb4 <fork_v0>:
 *  	-- Para ello se utiliza la funcion dup_or_share()
 *  	-- Se copian todas las paginas desde 0 hasta UTOP
 */
envid_t
fork_v0(void)
{
  800eb4:	55                   	push   %ebp
  800eb5:	89 e5                	mov    %esp,%ebp
  800eb7:	56                   	push   %esi
  800eb8:	53                   	push   %ebx

// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline)) sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2" : "=a"(ret) : "a"(SYS_exofork), "i"(T_SYSCALL));
  800eb9:	b8 07 00 00 00       	mov    $0x7,%eax
  800ebe:	cd 30                	int    $0x30
  800ec0:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();
	if (envid < 0)
  800ec2:	85 c0                	test   %eax,%eax
  800ec4:	78 23                	js     800ee9 <fork_v0+0x35>
	// Parent
	uint32_t pnum = 0;
	uint32_t pnum_end = (UTOP >> PGSHIFT);
	int perm = PTE_P | PTE_U | PTE_W;

	for (pnum = 0; pnum < pnum_end; pnum++) {
  800ec6:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid == 0) {
  800ecb:	75 3c                	jne    800f09 <fork_v0+0x55>
		thisenv = &envs[ENVX(sys_getenvid())];
  800ecd:	e8 da fb ff ff       	call   800aac <sys_getenvid>
  800ed2:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ed7:	69 c0 88 00 00 00    	imul   $0x88,%eax,%eax
  800edd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ee2:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800ee7:	eb 56                	jmp    800f3f <fork_v0+0x8b>
		panic("sys_exofork: %e", envid);
  800ee9:	50                   	push   %eax
  800eea:	68 fe 17 80 00       	push   $0x8017fe
  800eef:	68 a2 00 00 00       	push   $0xa2
  800ef4:	68 a1 17 80 00       	push   $0x8017a1
  800ef9:	e8 9b 01 00 00       	call   801099 <_panic>
	for (pnum = 0; pnum < pnum_end; pnum++) {
  800efe:	83 c3 01             	add    $0x1,%ebx
  800f01:	81 fb 00 ec 0e 00    	cmp    $0xeec00,%ebx
  800f07:	74 24                	je     800f2d <fork_v0+0x79>
		pde_t pde = uvpd[pnum >> 10];
  800f09:	89 d8                	mov    %ebx,%eax
  800f0b:	c1 e8 0a             	shr    $0xa,%eax
  800f0e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
		if (!(pde & PTE_P) || !(pde & PTE_U))
  800f15:	83 e0 05             	and    $0x5,%eax
  800f18:	83 f8 05             	cmp    $0x5,%eax
  800f1b:	75 e1                	jne    800efe <fork_v0+0x4a>
			continue;
		dup_or_share(envid, pnum, perm);
  800f1d:	b9 07 00 00 00       	mov    $0x7,%ecx
  800f22:	89 da                	mov    %ebx,%edx
  800f24:	89 f0                	mov    %esi,%eax
  800f26:	e8 dc fd ff ff       	call   800d07 <dup_or_share>
  800f2b:	eb d1                	jmp    800efe <fork_v0+0x4a>
	}


	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800f2d:	83 ec 08             	sub    $0x8,%esp
  800f30:	6a 02                	push   $0x2
  800f32:	56                   	push   %esi
  800f33:	e8 2c fc ff ff       	call   800b64 <sys_env_set_status>
  800f38:	83 c4 10             	add    $0x10,%esp
  800f3b:	85 c0                	test   %eax,%eax
  800f3d:	78 09                	js     800f48 <fork_v0+0x94>
		panic("sys_env_set_status: %e", r);

	return envid;
}
  800f3f:	89 f0                	mov    %esi,%eax
  800f41:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f44:	5b                   	pop    %ebx
  800f45:	5e                   	pop    %esi
  800f46:	5d                   	pop    %ebp
  800f47:	c3                   	ret    
		panic("sys_env_set_status: %e", r);
  800f48:	50                   	push   %eax
  800f49:	68 0e 18 80 00       	push   $0x80180e
  800f4e:	68 b8 00 00 00       	push   $0xb8
  800f53:	68 a1 17 80 00       	push   $0x8017a1
  800f58:	e8 3c 01 00 00       	call   801099 <_panic>

00800f5d <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f5d:	55                   	push   %ebp
  800f5e:	89 e5                	mov    %esp,%ebp
  800f60:	56                   	push   %esi
  800f61:	53                   	push   %ebx
	set_pgfault_handler(pgfault);
  800f62:	83 ec 0c             	sub    $0xc,%esp
  800f65:	68 00 0e 80 00       	push   $0x800e00
  800f6a:	e8 70 01 00 00       	call   8010df <set_pgfault_handler>
  800f6f:	b8 07 00 00 00       	mov    $0x7,%eax
  800f74:	cd 30                	int    $0x30
  800f76:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();

	if (envid < 0)
  800f78:	83 c4 10             	add    $0x10,%esp
  800f7b:	85 c0                	test   %eax,%eax
  800f7d:	78 26                	js     800fa5 <fork+0x48>
	// Parent
	uint32_t pnum = 0;
	uint32_t pnum_end = (UTOP >> PGSHIFT);

	// Handle all pages below UTOP
	for (pnum = 0; pnum < pnum_end; pnum++) {
  800f7f:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid == 0) {
  800f84:	75 41                	jne    800fc7 <fork+0x6a>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f86:	e8 21 fb ff ff       	call   800aac <sys_getenvid>
  800f8b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f90:	69 c0 88 00 00 00    	imul   $0x88,%eax,%eax
  800f96:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f9b:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800fa0:	e9 92 00 00 00       	jmp    801037 <fork+0xda>
		panic("sys_exofork: %e", envid);
  800fa5:	50                   	push   %eax
  800fa6:	68 fe 17 80 00       	push   $0x8017fe
  800fab:	68 d5 00 00 00       	push   $0xd5
  800fb0:	68 a1 17 80 00       	push   $0x8017a1
  800fb5:	e8 df 00 00 00       	call   801099 <_panic>
	for (pnum = 0; pnum < pnum_end; pnum++) {
  800fba:	83 c3 01             	add    $0x1,%ebx
  800fbd:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  800fc3:	77 30                	ja     800ff5 <fork+0x98>
		if (pnum == ((UXSTACKTOP >> PGSHIFT) - 1))
  800fc5:	74 f3                	je     800fba <fork+0x5d>
			continue;

		pde_t pde = uvpd[pnum >> 10];
  800fc7:	89 d8                	mov    %ebx,%eax
  800fc9:	c1 e8 0a             	shr    $0xa,%eax
  800fcc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
		if (!(pde & PTE_P) || !(pde & PTE_U))
  800fd3:	83 e0 05             	and    $0x5,%eax
  800fd6:	83 f8 05             	cmp    $0x5,%eax
  800fd9:	75 df                	jne    800fba <fork+0x5d>
			continue;

		pte_t pte = uvpt[pnum];
  800fdb:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
		if (!(pte & PTE_P) || !(pte & PTE_U))
  800fe2:	83 e0 05             	and    $0x5,%eax
  800fe5:	83 f8 05             	cmp    $0x5,%eax
  800fe8:	75 d0                	jne    800fba <fork+0x5d>
			continue;
		duppage(envid, pnum);
  800fea:	89 da                	mov    %ebx,%edx
  800fec:	89 f0                	mov    %esi,%eax
  800fee:	e8 44 fc ff ff       	call   800c37 <duppage>
  800ff3:	eb c5                	jmp    800fba <fork+0x5d>
	}

	uint32_t exstk = (UXSTACKTOP - PGSIZE);
	int r = sys_page_alloc(envid, (void *) exstk, PTE_U | PTE_P | PTE_W);
  800ff5:	83 ec 04             	sub    $0x4,%esp
  800ff8:	6a 07                	push   $0x7
  800ffa:	68 00 f0 bf ee       	push   $0xeebff000
  800fff:	56                   	push   %esi
  801000:	e8 f2 fa ff ff       	call   800af7 <sys_page_alloc>
	if (r < 0)
  801005:	83 c4 10             	add    $0x10,%esp
  801008:	85 c0                	test   %eax,%eax
  80100a:	78 34                	js     801040 <fork+0xe3>
		panic("fork: sys_page_alloc of exception stk: %e", r);
	r = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  80100c:	a1 04 20 80 00       	mov    0x802004,%eax
  801011:	8b 40 70             	mov    0x70(%eax),%eax
  801014:	83 ec 08             	sub    $0x8,%esp
  801017:	50                   	push   %eax
  801018:	56                   	push   %esi
  801019:	e8 69 fb ff ff       	call   800b87 <sys_env_set_pgfault_upcall>
	if (r < 0)
  80101e:	83 c4 10             	add    $0x10,%esp
  801021:	85 c0                	test   %eax,%eax
  801023:	78 30                	js     801055 <fork+0xf8>
		panic("fork: sys_env_set_pgfault_upcall on childern: %e", r);

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  801025:	83 ec 08             	sub    $0x8,%esp
  801028:	6a 02                	push   $0x2
  80102a:	56                   	push   %esi
  80102b:	e8 34 fb ff ff       	call   800b64 <sys_env_set_status>
  801030:	83 c4 10             	add    $0x10,%esp
  801033:	85 c0                	test   %eax,%eax
  801035:	78 33                	js     80106a <fork+0x10d>
		panic("sys_env_set_status: %e", r);

	return envid;
}
  801037:	89 f0                	mov    %esi,%eax
  801039:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80103c:	5b                   	pop    %ebx
  80103d:	5e                   	pop    %esi
  80103e:	5d                   	pop    %ebp
  80103f:	c3                   	ret    
		panic("fork: sys_page_alloc of exception stk: %e", r);
  801040:	50                   	push   %eax
  801041:	68 44 17 80 00       	push   $0x801744
  801046:	68 f2 00 00 00       	push   $0xf2
  80104b:	68 a1 17 80 00       	push   $0x8017a1
  801050:	e8 44 00 00 00       	call   801099 <_panic>
		panic("fork: sys_env_set_pgfault_upcall on childern: %e", r);
  801055:	50                   	push   %eax
  801056:	68 70 17 80 00       	push   $0x801770
  80105b:	68 f5 00 00 00       	push   $0xf5
  801060:	68 a1 17 80 00       	push   $0x8017a1
  801065:	e8 2f 00 00 00       	call   801099 <_panic>
		panic("sys_env_set_status: %e", r);
  80106a:	50                   	push   %eax
  80106b:	68 0e 18 80 00       	push   $0x80180e
  801070:	68 f8 00 00 00       	push   $0xf8
  801075:	68 a1 17 80 00       	push   $0x8017a1
  80107a:	e8 1a 00 00 00       	call   801099 <_panic>

0080107f <sfork>:

// Challenge!
int
sfork(void)
{
  80107f:	55                   	push   %ebp
  801080:	89 e5                	mov    %esp,%ebp
  801082:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801085:	68 25 18 80 00       	push   $0x801825
  80108a:	68 01 01 00 00       	push   $0x101
  80108f:	68 a1 17 80 00       	push   $0x8017a1
  801094:	e8 00 00 00 00       	call   801099 <_panic>

00801099 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801099:	55                   	push   %ebp
  80109a:	89 e5                	mov    %esp,%ebp
  80109c:	56                   	push   %esi
  80109d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80109e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8010a1:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8010a7:	e8 00 fa ff ff       	call   800aac <sys_getenvid>
  8010ac:	83 ec 0c             	sub    $0xc,%esp
  8010af:	ff 75 0c             	push   0xc(%ebp)
  8010b2:	ff 75 08             	push   0x8(%ebp)
  8010b5:	56                   	push   %esi
  8010b6:	50                   	push   %eax
  8010b7:	68 3c 18 80 00       	push   $0x80183c
  8010bc:	e8 b9 f0 ff ff       	call   80017a <cprintf>
	        sys_getenvid(),
	        binaryname,
	        file,
	        line);
	vcprintf(fmt, ap);
  8010c1:	83 c4 18             	add    $0x18,%esp
  8010c4:	53                   	push   %ebx
  8010c5:	ff 75 10             	push   0x10(%ebp)
  8010c8:	e8 5c f0 ff ff       	call   800129 <vcprintf>
	cprintf("\n");
  8010cd:	c7 04 24 c1 13 80 00 	movl   $0x8013c1,(%esp)
  8010d4:	e8 a1 f0 ff ff       	call   80017a <cprintf>
  8010d9:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010dc:	cc                   	int3   
  8010dd:	eb fd                	jmp    8010dc <_panic+0x43>

008010df <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8010df:	55                   	push   %ebp
  8010e0:	89 e5                	mov    %esp,%ebp
  8010e2:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8010e5:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  8010ec:	74 0a                	je     8010f8 <set_pgfault_handler+0x19>
		if (r < 0)
			return;
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8010ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f1:	a3 08 20 80 00       	mov    %eax,0x802008
}
  8010f6:	c9                   	leave  
  8010f7:	c3                   	ret    
		r = sys_page_alloc(0, (void *) exstk, perm);
  8010f8:	83 ec 04             	sub    $0x4,%esp
  8010fb:	6a 07                	push   $0x7
  8010fd:	68 00 f0 bf ee       	push   $0xeebff000
  801102:	6a 00                	push   $0x0
  801104:	e8 ee f9 ff ff       	call   800af7 <sys_page_alloc>
		if (r < 0)
  801109:	83 c4 10             	add    $0x10,%esp
  80110c:	85 c0                	test   %eax,%eax
  80110e:	78 e6                	js     8010f6 <set_pgfault_handler+0x17>
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801110:	83 ec 08             	sub    $0x8,%esp
  801113:	68 28 11 80 00       	push   $0x801128
  801118:	6a 00                	push   $0x0
  80111a:	e8 68 fa ff ff       	call   800b87 <sys_env_set_pgfault_upcall>
		if (r < 0)
  80111f:	83 c4 10             	add    $0x10,%esp
  801122:	85 c0                	test   %eax,%eax
  801124:	79 c8                	jns    8010ee <set_pgfault_handler+0xf>
  801126:	eb ce                	jmp    8010f6 <set_pgfault_handler+0x17>

00801128 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801128:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801129:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  80112e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801130:	83 c4 04             	add    $0x4,%esp
	// Throughout the remaining code, think carefully about what
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	movl 40(%esp), %eax	// trap-time %epi -> %eax 
  801133:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %ebx	// trap-time %esp -> %ebx
  801137:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4, %ebx
  80113b:	83 eb 04             	sub    $0x4,%ebx
	movl %eax, 0(%ebx)	// push %eip in trap-time stack
  80113e:	89 03                	mov    %eax,(%ebx)

	movl %ebx, 48(%esp)
  801140:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	popl %eax
  801144:	58                   	pop    %eax
	popl %eax
  801145:	58                   	pop    %eax
	popal
  801146:	61                   	popa   
	

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	addl $4, %esp
  801147:	83 c4 04             	add    $0x4,%esp
	popfl
  80114a:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	popl %esp
  80114b:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	ret
  80114c:	c3                   	ret    
  80114d:	66 90                	xchg   %ax,%ax
  80114f:	90                   	nop

00801150 <__udivdi3>:
  801150:	f3 0f 1e fb          	endbr32 
  801154:	55                   	push   %ebp
  801155:	57                   	push   %edi
  801156:	56                   	push   %esi
  801157:	53                   	push   %ebx
  801158:	83 ec 1c             	sub    $0x1c,%esp
  80115b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80115f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801163:	8b 74 24 34          	mov    0x34(%esp),%esi
  801167:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80116b:	85 c0                	test   %eax,%eax
  80116d:	75 19                	jne    801188 <__udivdi3+0x38>
  80116f:	39 f3                	cmp    %esi,%ebx
  801171:	76 4d                	jbe    8011c0 <__udivdi3+0x70>
  801173:	31 ff                	xor    %edi,%edi
  801175:	89 e8                	mov    %ebp,%eax
  801177:	89 f2                	mov    %esi,%edx
  801179:	f7 f3                	div    %ebx
  80117b:	89 fa                	mov    %edi,%edx
  80117d:	83 c4 1c             	add    $0x1c,%esp
  801180:	5b                   	pop    %ebx
  801181:	5e                   	pop    %esi
  801182:	5f                   	pop    %edi
  801183:	5d                   	pop    %ebp
  801184:	c3                   	ret    
  801185:	8d 76 00             	lea    0x0(%esi),%esi
  801188:	39 f0                	cmp    %esi,%eax
  80118a:	76 14                	jbe    8011a0 <__udivdi3+0x50>
  80118c:	31 ff                	xor    %edi,%edi
  80118e:	31 c0                	xor    %eax,%eax
  801190:	89 fa                	mov    %edi,%edx
  801192:	83 c4 1c             	add    $0x1c,%esp
  801195:	5b                   	pop    %ebx
  801196:	5e                   	pop    %esi
  801197:	5f                   	pop    %edi
  801198:	5d                   	pop    %ebp
  801199:	c3                   	ret    
  80119a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8011a0:	0f bd f8             	bsr    %eax,%edi
  8011a3:	83 f7 1f             	xor    $0x1f,%edi
  8011a6:	75 48                	jne    8011f0 <__udivdi3+0xa0>
  8011a8:	39 f0                	cmp    %esi,%eax
  8011aa:	72 06                	jb     8011b2 <__udivdi3+0x62>
  8011ac:	31 c0                	xor    %eax,%eax
  8011ae:	39 eb                	cmp    %ebp,%ebx
  8011b0:	77 de                	ja     801190 <__udivdi3+0x40>
  8011b2:	b8 01 00 00 00       	mov    $0x1,%eax
  8011b7:	eb d7                	jmp    801190 <__udivdi3+0x40>
  8011b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011c0:	89 d9                	mov    %ebx,%ecx
  8011c2:	85 db                	test   %ebx,%ebx
  8011c4:	75 0b                	jne    8011d1 <__udivdi3+0x81>
  8011c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8011cb:	31 d2                	xor    %edx,%edx
  8011cd:	f7 f3                	div    %ebx
  8011cf:	89 c1                	mov    %eax,%ecx
  8011d1:	31 d2                	xor    %edx,%edx
  8011d3:	89 f0                	mov    %esi,%eax
  8011d5:	f7 f1                	div    %ecx
  8011d7:	89 c6                	mov    %eax,%esi
  8011d9:	89 e8                	mov    %ebp,%eax
  8011db:	89 f7                	mov    %esi,%edi
  8011dd:	f7 f1                	div    %ecx
  8011df:	89 fa                	mov    %edi,%edx
  8011e1:	83 c4 1c             	add    $0x1c,%esp
  8011e4:	5b                   	pop    %ebx
  8011e5:	5e                   	pop    %esi
  8011e6:	5f                   	pop    %edi
  8011e7:	5d                   	pop    %ebp
  8011e8:	c3                   	ret    
  8011e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011f0:	89 f9                	mov    %edi,%ecx
  8011f2:	ba 20 00 00 00       	mov    $0x20,%edx
  8011f7:	29 fa                	sub    %edi,%edx
  8011f9:	d3 e0                	shl    %cl,%eax
  8011fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011ff:	89 d1                	mov    %edx,%ecx
  801201:	89 d8                	mov    %ebx,%eax
  801203:	d3 e8                	shr    %cl,%eax
  801205:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801209:	09 c1                	or     %eax,%ecx
  80120b:	89 f0                	mov    %esi,%eax
  80120d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801211:	89 f9                	mov    %edi,%ecx
  801213:	d3 e3                	shl    %cl,%ebx
  801215:	89 d1                	mov    %edx,%ecx
  801217:	d3 e8                	shr    %cl,%eax
  801219:	89 f9                	mov    %edi,%ecx
  80121b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80121f:	89 eb                	mov    %ebp,%ebx
  801221:	d3 e6                	shl    %cl,%esi
  801223:	89 d1                	mov    %edx,%ecx
  801225:	d3 eb                	shr    %cl,%ebx
  801227:	09 f3                	or     %esi,%ebx
  801229:	89 c6                	mov    %eax,%esi
  80122b:	89 f2                	mov    %esi,%edx
  80122d:	89 d8                	mov    %ebx,%eax
  80122f:	f7 74 24 08          	divl   0x8(%esp)
  801233:	89 d6                	mov    %edx,%esi
  801235:	89 c3                	mov    %eax,%ebx
  801237:	f7 64 24 0c          	mull   0xc(%esp)
  80123b:	39 d6                	cmp    %edx,%esi
  80123d:	72 19                	jb     801258 <__udivdi3+0x108>
  80123f:	89 f9                	mov    %edi,%ecx
  801241:	d3 e5                	shl    %cl,%ebp
  801243:	39 c5                	cmp    %eax,%ebp
  801245:	73 04                	jae    80124b <__udivdi3+0xfb>
  801247:	39 d6                	cmp    %edx,%esi
  801249:	74 0d                	je     801258 <__udivdi3+0x108>
  80124b:	89 d8                	mov    %ebx,%eax
  80124d:	31 ff                	xor    %edi,%edi
  80124f:	e9 3c ff ff ff       	jmp    801190 <__udivdi3+0x40>
  801254:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801258:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80125b:	31 ff                	xor    %edi,%edi
  80125d:	e9 2e ff ff ff       	jmp    801190 <__udivdi3+0x40>
  801262:	66 90                	xchg   %ax,%ax
  801264:	66 90                	xchg   %ax,%ax
  801266:	66 90                	xchg   %ax,%ax
  801268:	66 90                	xchg   %ax,%ax
  80126a:	66 90                	xchg   %ax,%ax
  80126c:	66 90                	xchg   %ax,%ax
  80126e:	66 90                	xchg   %ax,%ax

00801270 <__umoddi3>:
  801270:	f3 0f 1e fb          	endbr32 
  801274:	55                   	push   %ebp
  801275:	57                   	push   %edi
  801276:	56                   	push   %esi
  801277:	53                   	push   %ebx
  801278:	83 ec 1c             	sub    $0x1c,%esp
  80127b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80127f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801283:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  801287:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80128b:	89 f0                	mov    %esi,%eax
  80128d:	89 da                	mov    %ebx,%edx
  80128f:	85 ff                	test   %edi,%edi
  801291:	75 15                	jne    8012a8 <__umoddi3+0x38>
  801293:	39 dd                	cmp    %ebx,%ebp
  801295:	76 39                	jbe    8012d0 <__umoddi3+0x60>
  801297:	f7 f5                	div    %ebp
  801299:	89 d0                	mov    %edx,%eax
  80129b:	31 d2                	xor    %edx,%edx
  80129d:	83 c4 1c             	add    $0x1c,%esp
  8012a0:	5b                   	pop    %ebx
  8012a1:	5e                   	pop    %esi
  8012a2:	5f                   	pop    %edi
  8012a3:	5d                   	pop    %ebp
  8012a4:	c3                   	ret    
  8012a5:	8d 76 00             	lea    0x0(%esi),%esi
  8012a8:	39 df                	cmp    %ebx,%edi
  8012aa:	77 f1                	ja     80129d <__umoddi3+0x2d>
  8012ac:	0f bd cf             	bsr    %edi,%ecx
  8012af:	83 f1 1f             	xor    $0x1f,%ecx
  8012b2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8012b6:	75 40                	jne    8012f8 <__umoddi3+0x88>
  8012b8:	39 df                	cmp    %ebx,%edi
  8012ba:	72 04                	jb     8012c0 <__umoddi3+0x50>
  8012bc:	39 f5                	cmp    %esi,%ebp
  8012be:	77 dd                	ja     80129d <__umoddi3+0x2d>
  8012c0:	89 da                	mov    %ebx,%edx
  8012c2:	89 f0                	mov    %esi,%eax
  8012c4:	29 e8                	sub    %ebp,%eax
  8012c6:	19 fa                	sbb    %edi,%edx
  8012c8:	eb d3                	jmp    80129d <__umoddi3+0x2d>
  8012ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012d0:	89 e9                	mov    %ebp,%ecx
  8012d2:	85 ed                	test   %ebp,%ebp
  8012d4:	75 0b                	jne    8012e1 <__umoddi3+0x71>
  8012d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8012db:	31 d2                	xor    %edx,%edx
  8012dd:	f7 f5                	div    %ebp
  8012df:	89 c1                	mov    %eax,%ecx
  8012e1:	89 d8                	mov    %ebx,%eax
  8012e3:	31 d2                	xor    %edx,%edx
  8012e5:	f7 f1                	div    %ecx
  8012e7:	89 f0                	mov    %esi,%eax
  8012e9:	f7 f1                	div    %ecx
  8012eb:	89 d0                	mov    %edx,%eax
  8012ed:	31 d2                	xor    %edx,%edx
  8012ef:	eb ac                	jmp    80129d <__umoddi3+0x2d>
  8012f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012f8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8012fc:	ba 20 00 00 00       	mov    $0x20,%edx
  801301:	29 c2                	sub    %eax,%edx
  801303:	89 c1                	mov    %eax,%ecx
  801305:	89 e8                	mov    %ebp,%eax
  801307:	d3 e7                	shl    %cl,%edi
  801309:	89 d1                	mov    %edx,%ecx
  80130b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80130f:	d3 e8                	shr    %cl,%eax
  801311:	89 c1                	mov    %eax,%ecx
  801313:	8b 44 24 04          	mov    0x4(%esp),%eax
  801317:	09 f9                	or     %edi,%ecx
  801319:	89 df                	mov    %ebx,%edi
  80131b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80131f:	89 c1                	mov    %eax,%ecx
  801321:	d3 e5                	shl    %cl,%ebp
  801323:	89 d1                	mov    %edx,%ecx
  801325:	d3 ef                	shr    %cl,%edi
  801327:	89 c1                	mov    %eax,%ecx
  801329:	89 f0                	mov    %esi,%eax
  80132b:	d3 e3                	shl    %cl,%ebx
  80132d:	89 d1                	mov    %edx,%ecx
  80132f:	89 fa                	mov    %edi,%edx
  801331:	d3 e8                	shr    %cl,%eax
  801333:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801338:	09 d8                	or     %ebx,%eax
  80133a:	f7 74 24 08          	divl   0x8(%esp)
  80133e:	89 d3                	mov    %edx,%ebx
  801340:	d3 e6                	shl    %cl,%esi
  801342:	f7 e5                	mul    %ebp
  801344:	89 c7                	mov    %eax,%edi
  801346:	89 d1                	mov    %edx,%ecx
  801348:	39 d3                	cmp    %edx,%ebx
  80134a:	72 06                	jb     801352 <__umoddi3+0xe2>
  80134c:	75 0e                	jne    80135c <__umoddi3+0xec>
  80134e:	39 c6                	cmp    %eax,%esi
  801350:	73 0a                	jae    80135c <__umoddi3+0xec>
  801352:	29 e8                	sub    %ebp,%eax
  801354:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801358:	89 d1                	mov    %edx,%ecx
  80135a:	89 c7                	mov    %eax,%edi
  80135c:	89 f5                	mov    %esi,%ebp
  80135e:	8b 74 24 04          	mov    0x4(%esp),%esi
  801362:	29 fd                	sub    %edi,%ebp
  801364:	19 cb                	sbb    %ecx,%ebx
  801366:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80136b:	89 d8                	mov    %ebx,%eax
  80136d:	d3 e0                	shl    %cl,%eax
  80136f:	89 f1                	mov    %esi,%ecx
  801371:	d3 ed                	shr    %cl,%ebp
  801373:	d3 eb                	shr    %cl,%ebx
  801375:	09 e8                	or     %ebp,%eax
  801377:	89 da                	mov    %ebx,%edx
  801379:	83 c4 1c             	add    $0x1c,%esp
  80137c:	5b                   	pop    %ebx
  80137d:	5e                   	pop    %esi
  80137e:	5f                   	pop    %edi
  80137f:	5d                   	pop    %ebp
  801380:	c3                   	ret    
