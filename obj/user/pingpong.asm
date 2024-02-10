
obj/user/pingpong:     formato del fichero elf32-i386


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
  80002c:	e8 8f 00 00 00       	call   8000c0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003c:	e8 56 0f 00 00       	call   800f97 <fork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	75 4f                	jne    800097 <umain+0x64>
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
		ipc_send(who, 0, 0, 0);
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  800048:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80004b:	83 ec 04             	sub    $0x4,%esp
  80004e:	6a 00                	push   $0x0
  800050:	6a 00                	push   $0x0
  800052:	56                   	push   %esi
  800053:	e8 7b 10 00 00       	call   8010d3 <ipc_recv>
  800058:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  80005a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80005d:	e8 84 0a 00 00       	call   800ae6 <sys_getenvid>
  800062:	57                   	push   %edi
  800063:	53                   	push   %ebx
  800064:	50                   	push   %eax
  800065:	68 f6 14 80 00       	push   $0x8014f6
  80006a:	e8 45 01 00 00       	call   8001b4 <cprintf>
		if (i == 10)
  80006f:	83 c4 20             	add    $0x20,%esp
  800072:	83 fb 0a             	cmp    $0xa,%ebx
  800075:	74 18                	je     80008f <umain+0x5c>
			return;
		i++;
  800077:	83 c3 01             	add    $0x1,%ebx
		ipc_send(who, i, 0, 0);
  80007a:	6a 00                	push   $0x0
  80007c:	6a 00                	push   $0x0
  80007e:	53                   	push   %ebx
  80007f:	ff 75 e4             	push   -0x1c(%ebp)
  800082:	e8 ae 10 00 00       	call   801135 <ipc_send>
		if (i == 10)
  800087:	83 c4 10             	add    $0x10,%esp
  80008a:	83 fb 0a             	cmp    $0xa,%ebx
  80008d:	75 bc                	jne    80004b <umain+0x18>
			return;
	}
}
  80008f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800092:	5b                   	pop    %ebx
  800093:	5e                   	pop    %esi
  800094:	5f                   	pop    %edi
  800095:	5d                   	pop    %ebp
  800096:	c3                   	ret    
  800097:	89 c3                	mov    %eax,%ebx
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800099:	e8 48 0a 00 00       	call   800ae6 <sys_getenvid>
  80009e:	83 ec 04             	sub    $0x4,%esp
  8000a1:	53                   	push   %ebx
  8000a2:	50                   	push   %eax
  8000a3:	68 e0 14 80 00       	push   $0x8014e0
  8000a8:	e8 07 01 00 00       	call   8001b4 <cprintf>
		ipc_send(who, 0, 0, 0);
  8000ad:	6a 00                	push   $0x0
  8000af:	6a 00                	push   $0x0
  8000b1:	6a 00                	push   $0x0
  8000b3:	ff 75 e4             	push   -0x1c(%ebp)
  8000b6:	e8 7a 10 00 00       	call   801135 <ipc_send>
  8000bb:	83 c4 20             	add    $0x20,%esp
  8000be:	eb 88                	jmp    800048 <umain+0x15>

008000c0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	56                   	push   %esi
  8000c4:	53                   	push   %ebx
  8000c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000c8:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	envid_t id = sys_getenvid();
  8000cb:	e8 16 0a 00 00       	call   800ae6 <sys_getenvid>
	if (id >= 0)
  8000d0:	85 c0                	test   %eax,%eax
  8000d2:	78 15                	js     8000e9 <libmain+0x29>
		thisenv = &envs[ENVX(id)];
  8000d4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d9:	69 c0 88 00 00 00    	imul   $0x88,%eax,%eax
  8000df:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e4:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e9:	85 db                	test   %ebx,%ebx
  8000eb:	7e 07                	jle    8000f4 <libmain+0x34>
		binaryname = argv[0];
  8000ed:	8b 06                	mov    (%esi),%eax
  8000ef:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000f4:	83 ec 08             	sub    $0x8,%esp
  8000f7:	56                   	push   %esi
  8000f8:	53                   	push   %ebx
  8000f9:	e8 35 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000fe:	e8 0a 00 00 00       	call   80010d <exit>
}
  800103:	83 c4 10             	add    $0x10,%esp
  800106:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800109:	5b                   	pop    %ebx
  80010a:	5e                   	pop    %esi
  80010b:	5d                   	pop    %ebp
  80010c:	c3                   	ret    

0080010d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800113:	6a 00                	push   $0x0
  800115:	e8 aa 09 00 00       	call   800ac4 <sys_env_destroy>
}
  80011a:	83 c4 10             	add    $0x10,%esp
  80011d:	c9                   	leave  
  80011e:	c3                   	ret    

0080011f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80011f:	55                   	push   %ebp
  800120:	89 e5                	mov    %esp,%ebp
  800122:	53                   	push   %ebx
  800123:	83 ec 04             	sub    $0x4,%esp
  800126:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800129:	8b 13                	mov    (%ebx),%edx
  80012b:	8d 42 01             	lea    0x1(%edx),%eax
  80012e:	89 03                	mov    %eax,(%ebx)
  800130:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800133:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256 - 1) {
  800137:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013c:	74 09                	je     800147 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80013e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800142:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800145:	c9                   	leave  
  800146:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800147:	83 ec 08             	sub    $0x8,%esp
  80014a:	68 ff 00 00 00       	push   $0xff
  80014f:	8d 43 08             	lea    0x8(%ebx),%eax
  800152:	50                   	push   %eax
  800153:	e8 22 09 00 00       	call   800a7a <sys_cputs>
		b->idx = 0;
  800158:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80015e:	83 c4 10             	add    $0x10,%esp
  800161:	eb db                	jmp    80013e <putch+0x1f>

00800163 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80016c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800173:	00 00 00 
	b.cnt = 0;
  800176:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017d:	00 00 00 
	vprintfmt((void *) putch, &b, fmt, ap);
  800180:	ff 75 0c             	push   0xc(%ebp)
  800183:	ff 75 08             	push   0x8(%ebp)
  800186:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80018c:	50                   	push   %eax
  80018d:	68 1f 01 80 00       	push   $0x80011f
  800192:	e8 74 01 00 00       	call   80030b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800197:	83 c4 08             	add    $0x8,%esp
  80019a:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8001a0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a6:	50                   	push   %eax
  8001a7:	e8 ce 08 00 00       	call   800a7a <sys_cputs>

	return b.cnt;
}
  8001ac:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001b2:	c9                   	leave  
  8001b3:	c3                   	ret    

008001b4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ba:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001bd:	50                   	push   %eax
  8001be:	ff 75 08             	push   0x8(%ebp)
  8001c1:	e8 9d ff ff ff       	call   800163 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c6:	c9                   	leave  
  8001c7:	c3                   	ret    

008001c8 <printnum>:
         void *putdat,
         unsigned long long num,
         unsigned base,
         int width,
         int padc)
{
  8001c8:	55                   	push   %ebp
  8001c9:	89 e5                	mov    %esp,%ebp
  8001cb:	57                   	push   %edi
  8001cc:	56                   	push   %esi
  8001cd:	53                   	push   %ebx
  8001ce:	83 ec 1c             	sub    $0x1c,%esp
  8001d1:	89 c7                	mov    %eax,%edi
  8001d3:	89 d6                	mov    %edx,%esi
  8001d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001db:	89 d1                	mov    %edx,%ecx
  8001dd:	89 c2                	mov    %eax,%edx
  8001df:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001e2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001e5:	8b 45 10             	mov    0x10(%ebp),%eax
  8001e8:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001eb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001ee:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001f5:	39 c2                	cmp    %eax,%edx
  8001f7:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001fa:	72 3e                	jb     80023a <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001fc:	83 ec 0c             	sub    $0xc,%esp
  8001ff:	ff 75 18             	push   0x18(%ebp)
  800202:	83 eb 01             	sub    $0x1,%ebx
  800205:	53                   	push   %ebx
  800206:	50                   	push   %eax
  800207:	83 ec 08             	sub    $0x8,%esp
  80020a:	ff 75 e4             	push   -0x1c(%ebp)
  80020d:	ff 75 e0             	push   -0x20(%ebp)
  800210:	ff 75 dc             	push   -0x24(%ebp)
  800213:	ff 75 d8             	push   -0x28(%ebp)
  800216:	e8 75 10 00 00       	call   801290 <__udivdi3>
  80021b:	83 c4 18             	add    $0x18,%esp
  80021e:	52                   	push   %edx
  80021f:	50                   	push   %eax
  800220:	89 f2                	mov    %esi,%edx
  800222:	89 f8                	mov    %edi,%eax
  800224:	e8 9f ff ff ff       	call   8001c8 <printnum>
  800229:	83 c4 20             	add    $0x20,%esp
  80022c:	eb 13                	jmp    800241 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80022e:	83 ec 08             	sub    $0x8,%esp
  800231:	56                   	push   %esi
  800232:	ff 75 18             	push   0x18(%ebp)
  800235:	ff d7                	call   *%edi
  800237:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80023a:	83 eb 01             	sub    $0x1,%ebx
  80023d:	85 db                	test   %ebx,%ebx
  80023f:	7f ed                	jg     80022e <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800241:	83 ec 08             	sub    $0x8,%esp
  800244:	56                   	push   %esi
  800245:	83 ec 04             	sub    $0x4,%esp
  800248:	ff 75 e4             	push   -0x1c(%ebp)
  80024b:	ff 75 e0             	push   -0x20(%ebp)
  80024e:	ff 75 dc             	push   -0x24(%ebp)
  800251:	ff 75 d8             	push   -0x28(%ebp)
  800254:	e8 57 11 00 00       	call   8013b0 <__umoddi3>
  800259:	83 c4 14             	add    $0x14,%esp
  80025c:	0f be 80 13 15 80 00 	movsbl 0x801513(%eax),%eax
  800263:	50                   	push   %eax
  800264:	ff d7                	call   *%edi
}
  800266:	83 c4 10             	add    $0x10,%esp
  800269:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026c:	5b                   	pop    %ebx
  80026d:	5e                   	pop    %esi
  80026e:	5f                   	pop    %edi
  80026f:	5d                   	pop    %ebp
  800270:	c3                   	ret    

00800271 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800271:	83 fa 01             	cmp    $0x1,%edx
  800274:	7f 13                	jg     800289 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800276:	85 d2                	test   %edx,%edx
  800278:	74 1c                	je     800296 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  80027a:	8b 10                	mov    (%eax),%edx
  80027c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80027f:	89 08                	mov    %ecx,(%eax)
  800281:	8b 02                	mov    (%edx),%eax
  800283:	ba 00 00 00 00       	mov    $0x0,%edx
  800288:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  800289:	8b 10                	mov    (%eax),%edx
  80028b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80028e:	89 08                	mov    %ecx,(%eax)
  800290:	8b 02                	mov    (%edx),%eax
  800292:	8b 52 04             	mov    0x4(%edx),%edx
  800295:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  800296:	8b 10                	mov    (%eax),%edx
  800298:	8d 4a 04             	lea    0x4(%edx),%ecx
  80029b:	89 08                	mov    %ecx,(%eax)
  80029d:	8b 02                	mov    (%edx),%eax
  80029f:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002a4:	c3                   	ret    

008002a5 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8002a5:	83 fa 01             	cmp    $0x1,%edx
  8002a8:	7f 0f                	jg     8002b9 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  8002aa:	85 d2                	test   %edx,%edx
  8002ac:	74 18                	je     8002c6 <getint+0x21>
		return va_arg(*ap, long);
  8002ae:	8b 10                	mov    (%eax),%edx
  8002b0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b3:	89 08                	mov    %ecx,(%eax)
  8002b5:	8b 02                	mov    (%edx),%eax
  8002b7:	99                   	cltd   
  8002b8:	c3                   	ret    
		return va_arg(*ap, long long);
  8002b9:	8b 10                	mov    (%eax),%edx
  8002bb:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002be:	89 08                	mov    %ecx,(%eax)
  8002c0:	8b 02                	mov    (%edx),%eax
  8002c2:	8b 52 04             	mov    0x4(%edx),%edx
  8002c5:	c3                   	ret    
	else
		return va_arg(*ap, int);
  8002c6:	8b 10                	mov    (%eax),%edx
  8002c8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002cb:	89 08                	mov    %ecx,(%eax)
  8002cd:	8b 02                	mov    (%edx),%eax
  8002cf:	99                   	cltd   
}
  8002d0:	c3                   	ret    

008002d1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002d1:	55                   	push   %ebp
  8002d2:	89 e5                	mov    %esp,%ebp
  8002d4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002d7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002db:	8b 10                	mov    (%eax),%edx
  8002dd:	3b 50 04             	cmp    0x4(%eax),%edx
  8002e0:	73 0a                	jae    8002ec <sprintputch+0x1b>
		*b->buf++ = ch;
  8002e2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002e5:	89 08                	mov    %ecx,(%eax)
  8002e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ea:	88 02                	mov    %al,(%edx)
}
  8002ec:	5d                   	pop    %ebp
  8002ed:	c3                   	ret    

008002ee <printfmt>:
{
  8002ee:	55                   	push   %ebp
  8002ef:	89 e5                	mov    %esp,%ebp
  8002f1:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002f4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002f7:	50                   	push   %eax
  8002f8:	ff 75 10             	push   0x10(%ebp)
  8002fb:	ff 75 0c             	push   0xc(%ebp)
  8002fe:	ff 75 08             	push   0x8(%ebp)
  800301:	e8 05 00 00 00       	call   80030b <vprintfmt>
}
  800306:	83 c4 10             	add    $0x10,%esp
  800309:	c9                   	leave  
  80030a:	c3                   	ret    

0080030b <vprintfmt>:
{
  80030b:	55                   	push   %ebp
  80030c:	89 e5                	mov    %esp,%ebp
  80030e:	57                   	push   %edi
  80030f:	56                   	push   %esi
  800310:	53                   	push   %ebx
  800311:	83 ec 2c             	sub    $0x2c,%esp
  800314:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800317:	8b 75 0c             	mov    0xc(%ebp),%esi
  80031a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80031d:	eb 0a                	jmp    800329 <vprintfmt+0x1e>
			putch(ch, putdat);
  80031f:	83 ec 08             	sub    $0x8,%esp
  800322:	56                   	push   %esi
  800323:	50                   	push   %eax
  800324:	ff d3                	call   *%ebx
  800326:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800329:	83 c7 01             	add    $0x1,%edi
  80032c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800330:	83 f8 25             	cmp    $0x25,%eax
  800333:	74 0c                	je     800341 <vprintfmt+0x36>
			if (ch == '\0')
  800335:	85 c0                	test   %eax,%eax
  800337:	75 e6                	jne    80031f <vprintfmt+0x14>
}
  800339:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80033c:	5b                   	pop    %ebx
  80033d:	5e                   	pop    %esi
  80033e:	5f                   	pop    %edi
  80033f:	5d                   	pop    %ebp
  800340:	c3                   	ret    
		padc = ' ';
  800341:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
		altflag = 0;
  800345:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80034c:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800353:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80035a:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80035f:	8d 47 01             	lea    0x1(%edi),%eax
  800362:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800365:	0f b6 17             	movzbl (%edi),%edx
  800368:	8d 42 dd             	lea    -0x23(%edx),%eax
  80036b:	3c 55                	cmp    $0x55,%al
  80036d:	0f 87 b7 02 00 00    	ja     80062a <vprintfmt+0x31f>
  800373:	0f b6 c0             	movzbl %al,%eax
  800376:	ff 24 85 e0 15 80 00 	jmp    *0x8015e0(,%eax,4)
  80037d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800380:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800384:	eb d9                	jmp    80035f <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800386:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800389:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  80038d:	eb d0                	jmp    80035f <vprintfmt+0x54>
  80038f:	0f b6 d2             	movzbl %dl,%edx
  800392:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0;; ++fmt) {
  800395:	b8 00 00 00 00       	mov    $0x0,%eax
  80039a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80039d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003a0:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003a4:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003a7:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003aa:	83 f9 09             	cmp    $0x9,%ecx
  8003ad:	77 52                	ja     800401 <vprintfmt+0xf6>
			for (precision = 0;; ++fmt) {
  8003af:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003b2:	eb e9                	jmp    80039d <vprintfmt+0x92>
			precision = va_arg(ap, int);
  8003b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b7:	8d 50 04             	lea    0x4(%eax),%edx
  8003ba:	89 55 14             	mov    %edx,0x14(%ebp)
  8003bd:	8b 00                	mov    (%eax),%eax
  8003bf:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003c5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003c9:	79 94                	jns    80035f <vprintfmt+0x54>
				width = precision, precision = -1;
  8003cb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003ce:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003d1:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003d8:	eb 85                	jmp    80035f <vprintfmt+0x54>
  8003da:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003dd:	85 d2                	test   %edx,%edx
  8003df:	b8 00 00 00 00       	mov    $0x0,%eax
  8003e4:	0f 49 c2             	cmovns %edx,%eax
  8003e7:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003ed:	e9 6d ff ff ff       	jmp    80035f <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8003f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003f5:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003fc:	e9 5e ff ff ff       	jmp    80035f <vprintfmt+0x54>
  800401:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800404:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800407:	eb bc                	jmp    8003c5 <vprintfmt+0xba>
			lflag++;
  800409:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80040c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80040f:	e9 4b ff ff ff       	jmp    80035f <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800414:	8b 45 14             	mov    0x14(%ebp),%eax
  800417:	8d 50 04             	lea    0x4(%eax),%edx
  80041a:	89 55 14             	mov    %edx,0x14(%ebp)
  80041d:	83 ec 08             	sub    $0x8,%esp
  800420:	56                   	push   %esi
  800421:	ff 30                	push   (%eax)
  800423:	ff d3                	call   *%ebx
			break;
  800425:	83 c4 10             	add    $0x10,%esp
  800428:	e9 94 01 00 00       	jmp    8005c1 <vprintfmt+0x2b6>
			err = va_arg(ap, int);
  80042d:	8b 45 14             	mov    0x14(%ebp),%eax
  800430:	8d 50 04             	lea    0x4(%eax),%edx
  800433:	89 55 14             	mov    %edx,0x14(%ebp)
  800436:	8b 10                	mov    (%eax),%edx
  800438:	89 d0                	mov    %edx,%eax
  80043a:	f7 d8                	neg    %eax
  80043c:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80043f:	83 f8 08             	cmp    $0x8,%eax
  800442:	7f 20                	jg     800464 <vprintfmt+0x159>
  800444:	8b 14 85 40 17 80 00 	mov    0x801740(,%eax,4),%edx
  80044b:	85 d2                	test   %edx,%edx
  80044d:	74 15                	je     800464 <vprintfmt+0x159>
				printfmt(putch, putdat, "%s", p);
  80044f:	52                   	push   %edx
  800450:	68 34 15 80 00       	push   $0x801534
  800455:	56                   	push   %esi
  800456:	53                   	push   %ebx
  800457:	e8 92 fe ff ff       	call   8002ee <printfmt>
  80045c:	83 c4 10             	add    $0x10,%esp
  80045f:	e9 5d 01 00 00       	jmp    8005c1 <vprintfmt+0x2b6>
				printfmt(putch, putdat, "error %d", err);
  800464:	50                   	push   %eax
  800465:	68 2b 15 80 00       	push   $0x80152b
  80046a:	56                   	push   %esi
  80046b:	53                   	push   %ebx
  80046c:	e8 7d fe ff ff       	call   8002ee <printfmt>
  800471:	83 c4 10             	add    $0x10,%esp
  800474:	e9 48 01 00 00       	jmp    8005c1 <vprintfmt+0x2b6>
			if ((p = va_arg(ap, char *)) == NULL)
  800479:	8b 45 14             	mov    0x14(%ebp),%eax
  80047c:	8d 50 04             	lea    0x4(%eax),%edx
  80047f:	89 55 14             	mov    %edx,0x14(%ebp)
  800482:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800484:	85 ff                	test   %edi,%edi
  800486:	b8 24 15 80 00       	mov    $0x801524,%eax
  80048b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80048e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800492:	7e 06                	jle    80049a <vprintfmt+0x18f>
  800494:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  800498:	75 0a                	jne    8004a4 <vprintfmt+0x199>
  80049a:	89 f8                	mov    %edi,%eax
  80049c:	03 45 e0             	add    -0x20(%ebp),%eax
  80049f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a2:	eb 59                	jmp    8004fd <vprintfmt+0x1f2>
				for (width -= strnlen(p, precision); width > 0;
  8004a4:	83 ec 08             	sub    $0x8,%esp
  8004a7:	ff 75 d8             	push   -0x28(%ebp)
  8004aa:	57                   	push   %edi
  8004ab:	e8 1a 02 00 00       	call   8006ca <strnlen>
  8004b0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004b3:	29 c1                	sub    %eax,%ecx
  8004b5:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004b8:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004bb:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  8004bf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c2:	89 7d d0             	mov    %edi,-0x30(%ebp)
  8004c5:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0;
  8004c7:	eb 0f                	jmp    8004d8 <vprintfmt+0x1cd>
					putch(padc, putdat);
  8004c9:	83 ec 08             	sub    $0x8,%esp
  8004cc:	56                   	push   %esi
  8004cd:	ff 75 e0             	push   -0x20(%ebp)
  8004d0:	ff d3                	call   *%ebx
				     width--)
  8004d2:	83 ef 01             	sub    $0x1,%edi
  8004d5:	83 c4 10             	add    $0x10,%esp
				for (width -= strnlen(p, precision); width > 0;
  8004d8:	85 ff                	test   %edi,%edi
  8004da:	7f ed                	jg     8004c9 <vprintfmt+0x1be>
  8004dc:	8b 7d d0             	mov    -0x30(%ebp),%edi
  8004df:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004e2:	85 c9                	test   %ecx,%ecx
  8004e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e9:	0f 49 c1             	cmovns %ecx,%eax
  8004ec:	29 c1                	sub    %eax,%ecx
  8004ee:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8004f1:	eb a7                	jmp    80049a <vprintfmt+0x18f>
					putch(ch, putdat);
  8004f3:	83 ec 08             	sub    $0x8,%esp
  8004f6:	56                   	push   %esi
  8004f7:	52                   	push   %edx
  8004f8:	ff d3                	call   *%ebx
  8004fa:	83 c4 10             	add    $0x10,%esp
  8004fd:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800500:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' &&
  800502:	83 c7 01             	add    $0x1,%edi
  800505:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800509:	0f be d0             	movsbl %al,%edx
  80050c:	85 d2                	test   %edx,%edx
  80050e:	74 42                	je     800552 <vprintfmt+0x247>
  800510:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800514:	78 06                	js     80051c <vprintfmt+0x211>
			       (precision < 0 || --precision >= 0);
  800516:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80051a:	78 1e                	js     80053a <vprintfmt+0x22f>
				if (altflag && (ch < ' ' || ch > '~'))
  80051c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800520:	74 d1                	je     8004f3 <vprintfmt+0x1e8>
  800522:	0f be c0             	movsbl %al,%eax
  800525:	83 e8 20             	sub    $0x20,%eax
  800528:	83 f8 5e             	cmp    $0x5e,%eax
  80052b:	76 c6                	jbe    8004f3 <vprintfmt+0x1e8>
					putch('?', putdat);
  80052d:	83 ec 08             	sub    $0x8,%esp
  800530:	56                   	push   %esi
  800531:	6a 3f                	push   $0x3f
  800533:	ff d3                	call   *%ebx
  800535:	83 c4 10             	add    $0x10,%esp
  800538:	eb c3                	jmp    8004fd <vprintfmt+0x1f2>
  80053a:	89 cf                	mov    %ecx,%edi
  80053c:	eb 0e                	jmp    80054c <vprintfmt+0x241>
				putch(' ', putdat);
  80053e:	83 ec 08             	sub    $0x8,%esp
  800541:	56                   	push   %esi
  800542:	6a 20                	push   $0x20
  800544:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  800546:	83 ef 01             	sub    $0x1,%edi
  800549:	83 c4 10             	add    $0x10,%esp
  80054c:	85 ff                	test   %edi,%edi
  80054e:	7f ee                	jg     80053e <vprintfmt+0x233>
  800550:	eb 6f                	jmp    8005c1 <vprintfmt+0x2b6>
  800552:	89 cf                	mov    %ecx,%edi
  800554:	eb f6                	jmp    80054c <vprintfmt+0x241>
			num = getint(&ap, lflag);
  800556:	89 ca                	mov    %ecx,%edx
  800558:	8d 45 14             	lea    0x14(%ebp),%eax
  80055b:	e8 45 fd ff ff       	call   8002a5 <getint>
  800560:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800563:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800566:	85 d2                	test   %edx,%edx
  800568:	78 0b                	js     800575 <vprintfmt+0x26a>
			num = getint(&ap, lflag);
  80056a:	89 d1                	mov    %edx,%ecx
  80056c:	89 c2                	mov    %eax,%edx
			base = 10;
  80056e:	bf 0a 00 00 00       	mov    $0xa,%edi
  800573:	eb 32                	jmp    8005a7 <vprintfmt+0x29c>
				putch('-', putdat);
  800575:	83 ec 08             	sub    $0x8,%esp
  800578:	56                   	push   %esi
  800579:	6a 2d                	push   $0x2d
  80057b:	ff d3                	call   *%ebx
				num = -(long long) num;
  80057d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800580:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800583:	f7 da                	neg    %edx
  800585:	83 d1 00             	adc    $0x0,%ecx
  800588:	f7 d9                	neg    %ecx
  80058a:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80058d:	bf 0a 00 00 00       	mov    $0xa,%edi
  800592:	eb 13                	jmp    8005a7 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  800594:	89 ca                	mov    %ecx,%edx
  800596:	8d 45 14             	lea    0x14(%ebp),%eax
  800599:	e8 d3 fc ff ff       	call   800271 <getuint>
  80059e:	89 d1                	mov    %edx,%ecx
  8005a0:	89 c2                	mov    %eax,%edx
			base = 10;
  8005a2:	bf 0a 00 00 00       	mov    $0xa,%edi
			printnum(putch, putdat, num, base, width, padc);
  8005a7:	83 ec 0c             	sub    $0xc,%esp
  8005aa:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  8005ae:	50                   	push   %eax
  8005af:	ff 75 e0             	push   -0x20(%ebp)
  8005b2:	57                   	push   %edi
  8005b3:	51                   	push   %ecx
  8005b4:	52                   	push   %edx
  8005b5:	89 f2                	mov    %esi,%edx
  8005b7:	89 d8                	mov    %ebx,%eax
  8005b9:	e8 0a fc ff ff       	call   8001c8 <printnum>
			break;
  8005be:	83 c4 20             	add    $0x20,%esp
{
  8005c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005c4:	e9 60 fd ff ff       	jmp    800329 <vprintfmt+0x1e>
			num = getuint(&ap, lflag);
  8005c9:	89 ca                	mov    %ecx,%edx
  8005cb:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ce:	e8 9e fc ff ff       	call   800271 <getuint>
  8005d3:	89 d1                	mov    %edx,%ecx
  8005d5:	89 c2                	mov    %eax,%edx
			base = 8;
  8005d7:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  8005dc:	eb c9                	jmp    8005a7 <vprintfmt+0x29c>
			putch('0', putdat);
  8005de:	83 ec 08             	sub    $0x8,%esp
  8005e1:	56                   	push   %esi
  8005e2:	6a 30                	push   $0x30
  8005e4:	ff d3                	call   *%ebx
			putch('x', putdat);
  8005e6:	83 c4 08             	add    $0x8,%esp
  8005e9:	56                   	push   %esi
  8005ea:	6a 78                	push   $0x78
  8005ec:	ff d3                	call   *%ebx
			num = (unsigned long long) (uintptr_t) va_arg(ap, void *);
  8005ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f1:	8d 50 04             	lea    0x4(%eax),%edx
  8005f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f7:	8b 10                	mov    (%eax),%edx
  8005f9:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8005fe:	83 c4 10             	add    $0x10,%esp
			base = 16;
  800601:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  800606:	eb 9f                	jmp    8005a7 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  800608:	89 ca                	mov    %ecx,%edx
  80060a:	8d 45 14             	lea    0x14(%ebp),%eax
  80060d:	e8 5f fc ff ff       	call   800271 <getuint>
  800612:	89 d1                	mov    %edx,%ecx
  800614:	89 c2                	mov    %eax,%edx
			base = 16;
  800616:	bf 10 00 00 00       	mov    $0x10,%edi
  80061b:	eb 8a                	jmp    8005a7 <vprintfmt+0x29c>
			putch(ch, putdat);
  80061d:	83 ec 08             	sub    $0x8,%esp
  800620:	56                   	push   %esi
  800621:	6a 25                	push   $0x25
  800623:	ff d3                	call   *%ebx
			break;
  800625:	83 c4 10             	add    $0x10,%esp
  800628:	eb 97                	jmp    8005c1 <vprintfmt+0x2b6>
			putch('%', putdat);
  80062a:	83 ec 08             	sub    $0x8,%esp
  80062d:	56                   	push   %esi
  80062e:	6a 25                	push   $0x25
  800630:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  800632:	83 c4 10             	add    $0x10,%esp
  800635:	89 f8                	mov    %edi,%eax
  800637:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80063b:	74 05                	je     800642 <vprintfmt+0x337>
  80063d:	83 e8 01             	sub    $0x1,%eax
  800640:	eb f5                	jmp    800637 <vprintfmt+0x32c>
  800642:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800645:	e9 77 ff ff ff       	jmp    8005c1 <vprintfmt+0x2b6>

0080064a <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80064a:	55                   	push   %ebp
  80064b:	89 e5                	mov    %esp,%ebp
  80064d:	83 ec 18             	sub    $0x18,%esp
  800650:	8b 45 08             	mov    0x8(%ebp),%eax
  800653:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = { buf, buf + n - 1, 0 };
  800656:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800659:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80065d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800660:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800667:	85 c0                	test   %eax,%eax
  800669:	74 26                	je     800691 <vsnprintf+0x47>
  80066b:	85 d2                	test   %edx,%edx
  80066d:	7e 22                	jle    800691 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *) sprintputch, &b, fmt, ap);
  80066f:	ff 75 14             	push   0x14(%ebp)
  800672:	ff 75 10             	push   0x10(%ebp)
  800675:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800678:	50                   	push   %eax
  800679:	68 d1 02 80 00       	push   $0x8002d1
  80067e:	e8 88 fc ff ff       	call   80030b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800683:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800686:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800689:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80068c:	83 c4 10             	add    $0x10,%esp
}
  80068f:	c9                   	leave  
  800690:	c3                   	ret    
		return -E_INVAL;
  800691:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800696:	eb f7                	jmp    80068f <vsnprintf+0x45>

00800698 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800698:	55                   	push   %ebp
  800699:	89 e5                	mov    %esp,%ebp
  80069b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80069e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006a1:	50                   	push   %eax
  8006a2:	ff 75 10             	push   0x10(%ebp)
  8006a5:	ff 75 0c             	push   0xc(%ebp)
  8006a8:	ff 75 08             	push   0x8(%ebp)
  8006ab:	e8 9a ff ff ff       	call   80064a <vsnprintf>
	va_end(ap);

	return rc;
}
  8006b0:	c9                   	leave  
  8006b1:	c3                   	ret    

008006b2 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006b2:	55                   	push   %ebp
  8006b3:	89 e5                	mov    %esp,%ebp
  8006b5:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8006bd:	eb 03                	jmp    8006c2 <strlen+0x10>
		n++;
  8006bf:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8006c2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006c6:	75 f7                	jne    8006bf <strlen+0xd>
	return n;
}
  8006c8:	5d                   	pop    %ebp
  8006c9:	c3                   	ret    

008006ca <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006ca:	55                   	push   %ebp
  8006cb:	89 e5                	mov    %esp,%ebp
  8006cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006d0:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8006d8:	eb 03                	jmp    8006dd <strnlen+0x13>
		n++;
  8006da:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006dd:	39 d0                	cmp    %edx,%eax
  8006df:	74 08                	je     8006e9 <strnlen+0x1f>
  8006e1:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8006e5:	75 f3                	jne    8006da <strnlen+0x10>
  8006e7:	89 c2                	mov    %eax,%edx
	return n;
}
  8006e9:	89 d0                	mov    %edx,%eax
  8006eb:	5d                   	pop    %ebp
  8006ec:	c3                   	ret    

008006ed <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006ed:	55                   	push   %ebp
  8006ee:	89 e5                	mov    %esp,%ebp
  8006f0:	53                   	push   %ebx
  8006f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8006fc:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800700:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800703:	83 c0 01             	add    $0x1,%eax
  800706:	84 d2                	test   %dl,%dl
  800708:	75 f2                	jne    8006fc <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80070a:	89 c8                	mov    %ecx,%eax
  80070c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80070f:	c9                   	leave  
  800710:	c3                   	ret    

00800711 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800711:	55                   	push   %ebp
  800712:	89 e5                	mov    %esp,%ebp
  800714:	53                   	push   %ebx
  800715:	83 ec 10             	sub    $0x10,%esp
  800718:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80071b:	53                   	push   %ebx
  80071c:	e8 91 ff ff ff       	call   8006b2 <strlen>
  800721:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800724:	ff 75 0c             	push   0xc(%ebp)
  800727:	01 d8                	add    %ebx,%eax
  800729:	50                   	push   %eax
  80072a:	e8 be ff ff ff       	call   8006ed <strcpy>
	return dst;
}
  80072f:	89 d8                	mov    %ebx,%eax
  800731:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800734:	c9                   	leave  
  800735:	c3                   	ret    

00800736 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size)
{
  800736:	55                   	push   %ebp
  800737:	89 e5                	mov    %esp,%ebp
  800739:	56                   	push   %esi
  80073a:	53                   	push   %ebx
  80073b:	8b 75 08             	mov    0x8(%ebp),%esi
  80073e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800741:	89 f3                	mov    %esi,%ebx
  800743:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800746:	89 f0                	mov    %esi,%eax
  800748:	eb 0f                	jmp    800759 <strncpy+0x23>
		*dst++ = *src;
  80074a:	83 c0 01             	add    $0x1,%eax
  80074d:	0f b6 0a             	movzbl (%edx),%ecx
  800750:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800753:	80 f9 01             	cmp    $0x1,%cl
  800756:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800759:	39 d8                	cmp    %ebx,%eax
  80075b:	75 ed                	jne    80074a <strncpy+0x14>
	}
	return ret;
}
  80075d:	89 f0                	mov    %esi,%eax
  80075f:	5b                   	pop    %ebx
  800760:	5e                   	pop    %esi
  800761:	5d                   	pop    %ebp
  800762:	c3                   	ret    

00800763 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800763:	55                   	push   %ebp
  800764:	89 e5                	mov    %esp,%ebp
  800766:	56                   	push   %esi
  800767:	53                   	push   %ebx
  800768:	8b 75 08             	mov    0x8(%ebp),%esi
  80076b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80076e:	8b 55 10             	mov    0x10(%ebp),%edx
  800771:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800773:	85 d2                	test   %edx,%edx
  800775:	74 21                	je     800798 <strlcpy+0x35>
  800777:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80077b:	89 f2                	mov    %esi,%edx
  80077d:	eb 09                	jmp    800788 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80077f:	83 c1 01             	add    $0x1,%ecx
  800782:	83 c2 01             	add    $0x1,%edx
  800785:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800788:	39 c2                	cmp    %eax,%edx
  80078a:	74 09                	je     800795 <strlcpy+0x32>
  80078c:	0f b6 19             	movzbl (%ecx),%ebx
  80078f:	84 db                	test   %bl,%bl
  800791:	75 ec                	jne    80077f <strlcpy+0x1c>
  800793:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800795:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800798:	29 f0                	sub    %esi,%eax
}
  80079a:	5b                   	pop    %ebx
  80079b:	5e                   	pop    %esi
  80079c:	5d                   	pop    %ebp
  80079d:	c3                   	ret    

0080079e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80079e:	55                   	push   %ebp
  80079f:	89 e5                	mov    %esp,%ebp
  8007a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007a4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007a7:	eb 06                	jmp    8007af <strcmp+0x11>
		p++, q++;
  8007a9:	83 c1 01             	add    $0x1,%ecx
  8007ac:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8007af:	0f b6 01             	movzbl (%ecx),%eax
  8007b2:	84 c0                	test   %al,%al
  8007b4:	74 04                	je     8007ba <strcmp+0x1c>
  8007b6:	3a 02                	cmp    (%edx),%al
  8007b8:	74 ef                	je     8007a9 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007ba:	0f b6 c0             	movzbl %al,%eax
  8007bd:	0f b6 12             	movzbl (%edx),%edx
  8007c0:	29 d0                	sub    %edx,%eax
}
  8007c2:	5d                   	pop    %ebp
  8007c3:	c3                   	ret    

008007c4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007c4:	55                   	push   %ebp
  8007c5:	89 e5                	mov    %esp,%ebp
  8007c7:	53                   	push   %ebx
  8007c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ce:	89 c3                	mov    %eax,%ebx
  8007d0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007d3:	eb 06                	jmp    8007db <strncmp+0x17>
		n--, p++, q++;
  8007d5:	83 c0 01             	add    $0x1,%eax
  8007d8:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8007db:	39 d8                	cmp    %ebx,%eax
  8007dd:	74 18                	je     8007f7 <strncmp+0x33>
  8007df:	0f b6 08             	movzbl (%eax),%ecx
  8007e2:	84 c9                	test   %cl,%cl
  8007e4:	74 04                	je     8007ea <strncmp+0x26>
  8007e6:	3a 0a                	cmp    (%edx),%cl
  8007e8:	74 eb                	je     8007d5 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007ea:	0f b6 00             	movzbl (%eax),%eax
  8007ed:	0f b6 12             	movzbl (%edx),%edx
  8007f0:	29 d0                	sub    %edx,%eax
}
  8007f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f5:	c9                   	leave  
  8007f6:	c3                   	ret    
		return 0;
  8007f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8007fc:	eb f4                	jmp    8007f2 <strncmp+0x2e>

008007fe <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007fe:	55                   	push   %ebp
  8007ff:	89 e5                	mov    %esp,%ebp
  800801:	8b 45 08             	mov    0x8(%ebp),%eax
  800804:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800808:	eb 03                	jmp    80080d <strchr+0xf>
  80080a:	83 c0 01             	add    $0x1,%eax
  80080d:	0f b6 10             	movzbl (%eax),%edx
  800810:	84 d2                	test   %dl,%dl
  800812:	74 06                	je     80081a <strchr+0x1c>
		if (*s == c)
  800814:	38 ca                	cmp    %cl,%dl
  800816:	75 f2                	jne    80080a <strchr+0xc>
  800818:	eb 05                	jmp    80081f <strchr+0x21>
			return (char *) s;
	return 0;
  80081a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80081f:	5d                   	pop    %ebp
  800820:	c3                   	ret    

00800821 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800821:	55                   	push   %ebp
  800822:	89 e5                	mov    %esp,%ebp
  800824:	8b 45 08             	mov    0x8(%ebp),%eax
  800827:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80082b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80082e:	38 ca                	cmp    %cl,%dl
  800830:	74 09                	je     80083b <strfind+0x1a>
  800832:	84 d2                	test   %dl,%dl
  800834:	74 05                	je     80083b <strfind+0x1a>
	for (; *s; s++)
  800836:	83 c0 01             	add    $0x1,%eax
  800839:	eb f0                	jmp    80082b <strfind+0xa>
			break;
	return (char *) s;
}
  80083b:	5d                   	pop    %ebp
  80083c:	c3                   	ret    

0080083d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80083d:	55                   	push   %ebp
  80083e:	89 e5                	mov    %esp,%ebp
  800840:	57                   	push   %edi
  800841:	56                   	push   %esi
  800842:	53                   	push   %ebx
  800843:	8b 55 08             	mov    0x8(%ebp),%edx
  800846:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  800849:	85 c9                	test   %ecx,%ecx
  80084b:	74 33                	je     800880 <memset+0x43>
		return v;
	if ((int) v % 4 == 0 && n % 4 == 0) {
  80084d:	89 d0                	mov    %edx,%eax
  80084f:	09 c8                	or     %ecx,%eax
  800851:	a8 03                	test   $0x3,%al
  800853:	75 23                	jne    800878 <memset+0x3b>
		c &= 0xFF;
  800855:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  800859:	89 d8                	mov    %ebx,%eax
  80085b:	c1 e0 08             	shl    $0x8,%eax
  80085e:	89 df                	mov    %ebx,%edi
  800860:	c1 e7 18             	shl    $0x18,%edi
  800863:	89 de                	mov    %ebx,%esi
  800865:	c1 e6 10             	shl    $0x10,%esi
  800868:	09 f7                	or     %esi,%edi
  80086a:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
		             : "=D"(p), "=c"(n)
		             : "D"(p), "a"(c), "c"(n / 4)
  80086c:	c1 e9 02             	shr    $0x2,%ecx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  80086f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800871:	89 d7                	mov    %edx,%edi
  800873:	fc                   	cld    
  800874:	f3 ab                	rep stos %eax,%es:(%edi)
  800876:	eb 08                	jmp    800880 <memset+0x43>
		             : "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800878:	89 d7                	mov    %edx,%edi
  80087a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80087d:	fc                   	cld    
  80087e:	f3 aa                	rep stos %al,%es:(%edi)
		             : "=D"(p), "=c"(n)
		             : "0"(p), "a"(c), "1"(n)
		             : "cc", "memory");
	return v;
}
  800880:	89 d0                	mov    %edx,%eax
  800882:	5b                   	pop    %ebx
  800883:	5e                   	pop    %esi
  800884:	5f                   	pop    %edi
  800885:	5d                   	pop    %ebp
  800886:	c3                   	ret    

00800887 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	57                   	push   %edi
  80088b:	56                   	push   %esi
  80088c:	8b 45 08             	mov    0x8(%ebp),%eax
  80088f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800892:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800895:	39 c6                	cmp    %eax,%esi
  800897:	73 32                	jae    8008cb <memmove+0x44>
  800899:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80089c:	39 c2                	cmp    %eax,%edx
  80089e:	76 2b                	jbe    8008cb <memmove+0x44>
		s += n;
		d += n;
  8008a0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  8008a3:	89 d6                	mov    %edx,%esi
  8008a5:	09 fe                	or     %edi,%esi
  8008a7:	09 ce                	or     %ecx,%esi
  8008a9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008af:	75 0e                	jne    8008bf <memmove+0x38>
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  8008b1:	83 ef 04             	sub    $0x4,%edi
			             "S"(s - 4),
  8008b4:	8d 72 fc             	lea    -0x4(%edx),%esi
			             "c"(n / 4)
  8008b7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  8008ba:	fd                   	std    
  8008bb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008bd:	eb 09                	jmp    8008c8 <memmove+0x41>
			             : "cc", "memory");
		else
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  8008bf:	83 ef 01             	sub    $0x1,%edi
			             "S"(s - 1),
  8008c2:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  8008c5:	fd                   	std    
  8008c6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             "c"(n)
			             : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008c8:	fc                   	cld    
  8008c9:	eb 1a                	jmp    8008e5 <memmove+0x5e>
	} else {
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  8008cb:	89 f2                	mov    %esi,%edx
  8008cd:	09 c2                	or     %eax,%edx
  8008cf:	09 ca                	or     %ecx,%edx
  8008d1:	f6 c2 03             	test   $0x3,%dl
  8008d4:	75 0a                	jne    8008e0 <memmove+0x59>
			asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  8008d6:	c1 e9 02             	shr    $0x2,%ecx
  8008d9:	89 c7                	mov    %eax,%edi
  8008db:	fc                   	cld    
  8008dc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008de:	eb 05                	jmp    8008e5 <memmove+0x5e>
			             : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  8008e0:	89 c7                	mov    %eax,%edi
  8008e2:	fc                   	cld    
  8008e3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             : "cc", "memory");
	}
	return dst;
}
  8008e5:	5e                   	pop    %esi
  8008e6:	5f                   	pop    %edi
  8008e7:	5d                   	pop    %ebp
  8008e8:	c3                   	ret    

008008e9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008e9:	55                   	push   %ebp
  8008ea:	89 e5                	mov    %esp,%ebp
  8008ec:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8008ef:	ff 75 10             	push   0x10(%ebp)
  8008f2:	ff 75 0c             	push   0xc(%ebp)
  8008f5:	ff 75 08             	push   0x8(%ebp)
  8008f8:	e8 8a ff ff ff       	call   800887 <memmove>
}
  8008fd:	c9                   	leave  
  8008fe:	c3                   	ret    

008008ff <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008ff:	55                   	push   %ebp
  800900:	89 e5                	mov    %esp,%ebp
  800902:	56                   	push   %esi
  800903:	53                   	push   %ebx
  800904:	8b 45 08             	mov    0x8(%ebp),%eax
  800907:	8b 55 0c             	mov    0xc(%ebp),%edx
  80090a:	89 c6                	mov    %eax,%esi
  80090c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80090f:	eb 06                	jmp    800917 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800911:	83 c0 01             	add    $0x1,%eax
  800914:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800917:	39 f0                	cmp    %esi,%eax
  800919:	74 14                	je     80092f <memcmp+0x30>
		if (*s1 != *s2)
  80091b:	0f b6 08             	movzbl (%eax),%ecx
  80091e:	0f b6 1a             	movzbl (%edx),%ebx
  800921:	38 d9                	cmp    %bl,%cl
  800923:	74 ec                	je     800911 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800925:	0f b6 c1             	movzbl %cl,%eax
  800928:	0f b6 db             	movzbl %bl,%ebx
  80092b:	29 d8                	sub    %ebx,%eax
  80092d:	eb 05                	jmp    800934 <memcmp+0x35>
	}

	return 0;
  80092f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800934:	5b                   	pop    %ebx
  800935:	5e                   	pop    %esi
  800936:	5d                   	pop    %ebp
  800937:	c3                   	ret    

00800938 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800938:	55                   	push   %ebp
  800939:	89 e5                	mov    %esp,%ebp
  80093b:	8b 45 08             	mov    0x8(%ebp),%eax
  80093e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800941:	89 c2                	mov    %eax,%edx
  800943:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800946:	eb 03                	jmp    80094b <memfind+0x13>
  800948:	83 c0 01             	add    $0x1,%eax
  80094b:	39 d0                	cmp    %edx,%eax
  80094d:	73 04                	jae    800953 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  80094f:	38 08                	cmp    %cl,(%eax)
  800951:	75 f5                	jne    800948 <memfind+0x10>
			break;
	return (void *) s;
}
  800953:	5d                   	pop    %ebp
  800954:	c3                   	ret    

00800955 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800955:	55                   	push   %ebp
  800956:	89 e5                	mov    %esp,%ebp
  800958:	57                   	push   %edi
  800959:	56                   	push   %esi
  80095a:	53                   	push   %ebx
  80095b:	8b 55 08             	mov    0x8(%ebp),%edx
  80095e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800961:	eb 03                	jmp    800966 <strtol+0x11>
		s++;
  800963:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800966:	0f b6 02             	movzbl (%edx),%eax
  800969:	3c 20                	cmp    $0x20,%al
  80096b:	74 f6                	je     800963 <strtol+0xe>
  80096d:	3c 09                	cmp    $0x9,%al
  80096f:	74 f2                	je     800963 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800971:	3c 2b                	cmp    $0x2b,%al
  800973:	74 2a                	je     80099f <strtol+0x4a>
	int neg = 0;
  800975:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  80097a:	3c 2d                	cmp    $0x2d,%al
  80097c:	74 2b                	je     8009a9 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80097e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800984:	75 0f                	jne    800995 <strtol+0x40>
  800986:	80 3a 30             	cmpb   $0x30,(%edx)
  800989:	74 28                	je     8009b3 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80098b:	85 db                	test   %ebx,%ebx
  80098d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800992:	0f 44 d8             	cmove  %eax,%ebx
  800995:	b9 00 00 00 00       	mov    $0x0,%ecx
  80099a:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80099d:	eb 46                	jmp    8009e5 <strtol+0x90>
		s++;
  80099f:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  8009a2:	bf 00 00 00 00       	mov    $0x0,%edi
  8009a7:	eb d5                	jmp    80097e <strtol+0x29>
		s++, neg = 1;
  8009a9:	83 c2 01             	add    $0x1,%edx
  8009ac:	bf 01 00 00 00       	mov    $0x1,%edi
  8009b1:	eb cb                	jmp    80097e <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009b3:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009b7:	74 0e                	je     8009c7 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  8009b9:	85 db                	test   %ebx,%ebx
  8009bb:	75 d8                	jne    800995 <strtol+0x40>
		s++, base = 8;
  8009bd:	83 c2 01             	add    $0x1,%edx
  8009c0:	bb 08 00 00 00       	mov    $0x8,%ebx
  8009c5:	eb ce                	jmp    800995 <strtol+0x40>
		s += 2, base = 16;
  8009c7:	83 c2 02             	add    $0x2,%edx
  8009ca:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009cf:	eb c4                	jmp    800995 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  8009d1:	0f be c0             	movsbl %al,%eax
  8009d4:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8009d7:	3b 45 10             	cmp    0x10(%ebp),%eax
  8009da:	7d 3a                	jge    800a16 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  8009dc:	83 c2 01             	add    $0x1,%edx
  8009df:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  8009e3:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  8009e5:	0f b6 02             	movzbl (%edx),%eax
  8009e8:	8d 70 d0             	lea    -0x30(%eax),%esi
  8009eb:	89 f3                	mov    %esi,%ebx
  8009ed:	80 fb 09             	cmp    $0x9,%bl
  8009f0:	76 df                	jbe    8009d1 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  8009f2:	8d 70 9f             	lea    -0x61(%eax),%esi
  8009f5:	89 f3                	mov    %esi,%ebx
  8009f7:	80 fb 19             	cmp    $0x19,%bl
  8009fa:	77 08                	ja     800a04 <strtol+0xaf>
			dig = *s - 'a' + 10;
  8009fc:	0f be c0             	movsbl %al,%eax
  8009ff:	83 e8 57             	sub    $0x57,%eax
  800a02:	eb d3                	jmp    8009d7 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800a04:	8d 70 bf             	lea    -0x41(%eax),%esi
  800a07:	89 f3                	mov    %esi,%ebx
  800a09:	80 fb 19             	cmp    $0x19,%bl
  800a0c:	77 08                	ja     800a16 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800a0e:	0f be c0             	movsbl %al,%eax
  800a11:	83 e8 37             	sub    $0x37,%eax
  800a14:	eb c1                	jmp    8009d7 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a16:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a1a:	74 05                	je     800a21 <strtol+0xcc>
		*endptr = (char *) s;
  800a1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1f:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800a21:	89 c8                	mov    %ecx,%eax
  800a23:	f7 d8                	neg    %eax
  800a25:	85 ff                	test   %edi,%edi
  800a27:	0f 45 c8             	cmovne %eax,%ecx
}
  800a2a:	89 c8                	mov    %ecx,%eax
  800a2c:	5b                   	pop    %ebx
  800a2d:	5e                   	pop    %esi
  800a2e:	5f                   	pop    %edi
  800a2f:	5d                   	pop    %ebp
  800a30:	c3                   	ret    

00800a31 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a31:	55                   	push   %ebp
  800a32:	89 e5                	mov    %esp,%ebp
  800a34:	57                   	push   %edi
  800a35:	56                   	push   %esi
  800a36:	53                   	push   %ebx
  800a37:	83 ec 1c             	sub    $0x1c,%esp
  800a3a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a3d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800a40:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile(
  800a42:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a45:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a48:	8b 7d 10             	mov    0x10(%ebp),%edi
  800a4b:	8b 75 14             	mov    0x14(%ebp),%esi
  800a4e:	cd 30                	int    $0x30
	        "int %1\n"
	        : "=a"(ret)
	        : "i"(T_SYSCALL), "a"(num), "d"(a1), "c"(a2), "b"(a3), "D"(a4), "S"(a5)
	        : "cc", "memory");

	if (check && ret > 0)
  800a50:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a54:	74 04                	je     800a5a <syscall+0x29>
  800a56:	85 c0                	test   %eax,%eax
  800a58:	7f 08                	jg     800a62 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800a5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a5d:	5b                   	pop    %ebx
  800a5e:	5e                   	pop    %esi
  800a5f:	5f                   	pop    %edi
  800a60:	5d                   	pop    %ebp
  800a61:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800a62:	83 ec 0c             	sub    $0xc,%esp
  800a65:	50                   	push   %eax
  800a66:	ff 75 e0             	push   -0x20(%ebp)
  800a69:	68 64 17 80 00       	push   $0x801764
  800a6e:	6a 1e                	push   $0x1e
  800a70:	68 81 17 80 00       	push   $0x801781
  800a75:	e8 5c 07 00 00       	call   8011d6 <_panic>

00800a7a <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800a7a:	55                   	push   %ebp
  800a7b:	89 e5                	mov    %esp,%ebp
  800a7d:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t) s, len, 0, 0, 0);
  800a80:	6a 00                	push   $0x0
  800a82:	6a 00                	push   $0x0
  800a84:	6a 00                	push   $0x0
  800a86:	ff 75 0c             	push   0xc(%ebp)
  800a89:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a8c:	ba 00 00 00 00       	mov    $0x0,%edx
  800a91:	b8 00 00 00 00       	mov    $0x0,%eax
  800a96:	e8 96 ff ff ff       	call   800a31 <syscall>
}
  800a9b:	83 c4 10             	add    $0x10,%esp
  800a9e:	c9                   	leave  
  800a9f:	c3                   	ret    

00800aa0 <sys_cgetc>:

int
sys_cgetc(void)
{
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800aa6:	6a 00                	push   $0x0
  800aa8:	6a 00                	push   $0x0
  800aaa:	6a 00                	push   $0x0
  800aac:	6a 00                	push   $0x0
  800aae:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ab3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab8:	b8 01 00 00 00       	mov    $0x1,%eax
  800abd:	e8 6f ff ff ff       	call   800a31 <syscall>
}
  800ac2:	c9                   	leave  
  800ac3:	c3                   	ret    

00800ac4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ac4:	55                   	push   %ebp
  800ac5:	89 e5                	mov    %esp,%ebp
  800ac7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800aca:	6a 00                	push   $0x0
  800acc:	6a 00                	push   $0x0
  800ace:	6a 00                	push   $0x0
  800ad0:	6a 00                	push   $0x0
  800ad2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ad5:	ba 01 00 00 00       	mov    $0x1,%edx
  800ada:	b8 03 00 00 00       	mov    $0x3,%eax
  800adf:	e8 4d ff ff ff       	call   800a31 <syscall>
}
  800ae4:	c9                   	leave  
  800ae5:	c3                   	ret    

00800ae6 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ae6:	55                   	push   %ebp
  800ae7:	89 e5                	mov    %esp,%ebp
  800ae9:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800aec:	6a 00                	push   $0x0
  800aee:	6a 00                	push   $0x0
  800af0:	6a 00                	push   $0x0
  800af2:	6a 00                	push   $0x0
  800af4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800af9:	ba 00 00 00 00       	mov    $0x0,%edx
  800afe:	b8 02 00 00 00       	mov    $0x2,%eax
  800b03:	e8 29 ff ff ff       	call   800a31 <syscall>
}
  800b08:	c9                   	leave  
  800b09:	c3                   	ret    

00800b0a <sys_yield>:

void
sys_yield(void)
{
  800b0a:	55                   	push   %ebp
  800b0b:	89 e5                	mov    %esp,%ebp
  800b0d:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800b10:	6a 00                	push   $0x0
  800b12:	6a 00                	push   $0x0
  800b14:	6a 00                	push   $0x0
  800b16:	6a 00                	push   $0x0
  800b18:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b1d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b22:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b27:	e8 05 ff ff ff       	call   800a31 <syscall>
}
  800b2c:	83 c4 10             	add    $0x10,%esp
  800b2f:	c9                   	leave  
  800b30:	c3                   	ret    

00800b31 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b31:	55                   	push   %ebp
  800b32:	89 e5                	mov    %esp,%ebp
  800b34:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800b37:	6a 00                	push   $0x0
  800b39:	6a 00                	push   $0x0
  800b3b:	ff 75 10             	push   0x10(%ebp)
  800b3e:	ff 75 0c             	push   0xc(%ebp)
  800b41:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b44:	ba 01 00 00 00       	mov    $0x1,%edx
  800b49:	b8 04 00 00 00       	mov    $0x4,%eax
  800b4e:	e8 de fe ff ff       	call   800a31 <syscall>
}
  800b53:	c9                   	leave  
  800b54:	c3                   	ret    

00800b55 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b55:	55                   	push   %ebp
  800b56:	89 e5                	mov    %esp,%ebp
  800b58:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map,
  800b5b:	ff 75 18             	push   0x18(%ebp)
  800b5e:	ff 75 14             	push   0x14(%ebp)
  800b61:	ff 75 10             	push   0x10(%ebp)
  800b64:	ff 75 0c             	push   0xc(%ebp)
  800b67:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b6a:	ba 01 00 00 00       	mov    $0x1,%edx
  800b6f:	b8 05 00 00 00       	mov    $0x5,%eax
  800b74:	e8 b8 fe ff ff       	call   800a31 <syscall>
	               srcenv,
	               (uint32_t) srcva,
	               dstenv,
	               (uint32_t) dstva,
	               perm);
}
  800b79:	c9                   	leave  
  800b7a:	c3                   	ret    

00800b7b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b7b:	55                   	push   %ebp
  800b7c:	89 e5                	mov    %esp,%ebp
  800b7e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800b81:	6a 00                	push   $0x0
  800b83:	6a 00                	push   $0x0
  800b85:	6a 00                	push   $0x0
  800b87:	ff 75 0c             	push   0xc(%ebp)
  800b8a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b8d:	ba 01 00 00 00       	mov    $0x1,%edx
  800b92:	b8 06 00 00 00       	mov    $0x6,%eax
  800b97:	e8 95 fe ff ff       	call   800a31 <syscall>
}
  800b9c:	c9                   	leave  
  800b9d:	c3                   	ret    

00800b9e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800b9e:	55                   	push   %ebp
  800b9f:	89 e5                	mov    %esp,%ebp
  800ba1:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800ba4:	6a 00                	push   $0x0
  800ba6:	6a 00                	push   $0x0
  800ba8:	6a 00                	push   $0x0
  800baa:	ff 75 0c             	push   0xc(%ebp)
  800bad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bb0:	ba 01 00 00 00       	mov    $0x1,%edx
  800bb5:	b8 08 00 00 00       	mov    $0x8,%eax
  800bba:	e8 72 fe ff ff       	call   800a31 <syscall>
}
  800bbf:	c9                   	leave  
  800bc0:	c3                   	ret    

00800bc1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800bc1:	55                   	push   %ebp
  800bc2:	89 e5                	mov    %esp,%ebp
  800bc4:	83 ec 08             	sub    $0x8,%esp
	return syscall(
  800bc7:	6a 00                	push   $0x0
  800bc9:	6a 00                	push   $0x0
  800bcb:	6a 00                	push   $0x0
  800bcd:	ff 75 0c             	push   0xc(%ebp)
  800bd0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bd3:	ba 01 00 00 00       	mov    $0x1,%edx
  800bd8:	b8 09 00 00 00       	mov    $0x9,%eax
  800bdd:	e8 4f fe ff ff       	call   800a31 <syscall>
	        SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800be2:	c9                   	leave  
  800be3:	c3                   	ret    

00800be4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800be4:	55                   	push   %ebp
  800be5:	89 e5                	mov    %esp,%ebp
  800be7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800bea:	6a 00                	push   $0x0
  800bec:	ff 75 14             	push   0x14(%ebp)
  800bef:	ff 75 10             	push   0x10(%ebp)
  800bf2:	ff 75 0c             	push   0xc(%ebp)
  800bf5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bf8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bfd:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c02:	e8 2a fe ff ff       	call   800a31 <syscall>
}
  800c07:	c9                   	leave  
  800c08:	c3                   	ret    

00800c09 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c09:	55                   	push   %ebp
  800c0a:	89 e5                	mov    %esp,%ebp
  800c0c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t) dstva, 0, 0, 0, 0);
  800c0f:	6a 00                	push   $0x0
  800c11:	6a 00                	push   $0x0
  800c13:	6a 00                	push   $0x0
  800c15:	6a 00                	push   $0x0
  800c17:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c1a:	ba 01 00 00 00       	mov    $0x1,%edx
  800c1f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c24:	e8 08 fe ff ff       	call   800a31 <syscall>
}
  800c29:	c9                   	leave  
  800c2a:	c3                   	ret    

00800c2b <sys_get_priority>:

// Get priority of the current process
int
sys_get_priority(void)
{
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
  800c2e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_get_priority, 0, 0, 0, 0, 0, 0);
  800c31:	6a 00                	push   $0x0
  800c33:	6a 00                	push   $0x0
  800c35:	6a 00                	push   $0x0
  800c37:	6a 00                	push   $0x0
  800c39:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c3e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c43:	b8 0d 00 00 00       	mov    $0xd,%eax
  800c48:	e8 e4 fd ff ff       	call   800a31 <syscall>
}
  800c4d:	c9                   	leave  
  800c4e:	c3                   	ret    

00800c4f <sys_set_priority>:

// Get priority of the current process
int
sys_set_priority(unsigned int priority)
{
  800c4f:	55                   	push   %ebp
  800c50:	89 e5                	mov    %esp,%ebp
  800c52:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, (uint32_t) priority, 0, 0, 0, 0);
  800c55:	6a 00                	push   $0x0
  800c57:	6a 00                	push   $0x0
  800c59:	6a 00                	push   $0x0
  800c5b:	6a 00                	push   $0x0
  800c5d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c60:	ba 00 00 00 00       	mov    $0x0,%edx
  800c65:	b8 0e 00 00 00       	mov    $0xe,%eax
  800c6a:	e8 c2 fd ff ff       	call   800a31 <syscall>
}
  800c6f:	c9                   	leave  
  800c70:	c3                   	ret    

00800c71 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800c71:	55                   	push   %ebp
  800c72:	89 e5                	mov    %esp,%ebp
  800c74:	56                   	push   %esi
  800c75:	53                   	push   %ebx
  800c76:	89 c1                	mov    %eax,%ecx
	int r;

	void *addr = (void *) (pn << PGSHIFT);
  800c78:	89 d6                	mov    %edx,%esi
  800c7a:	c1 e6 0c             	shl    $0xc,%esi

	pte_t pte = uvpt[pn];
  800c7d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx

	if (!(pte & PTE_P) || !(pte & PTE_U))
  800c84:	89 d0                	mov    %edx,%eax
  800c86:	83 e0 05             	and    $0x5,%eax
  800c89:	83 f8 05             	cmp    $0x5,%eax
  800c8c:	75 5a                	jne    800ce8 <duppage+0x77>
		panic("duppage: copy a non-present or non-user page");

	int perm = PTE_U | PTE_P;
	// Verifico permisos para páginas de IO
	if (pte & (PTE_PCD | PTE_PWT))
  800c8e:	89 d0                	mov    %edx,%eax
  800c90:	83 e0 18             	and    $0x18,%eax
		perm |= PTE_PCD | PTE_PWT;
  800c93:	83 f8 01             	cmp    $0x1,%eax
  800c96:	19 c0                	sbb    %eax,%eax
  800c98:	83 e0 e8             	and    $0xffffffe8,%eax
  800c9b:	83 c0 1d             	add    $0x1d,%eax


	// Si es de escritura o copy-on-write y NO es de IO
	if ((pte & PTE_W) || (pte & PTE_COW)) {
  800c9e:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800ca4:	74 68                	je     800d0e <duppage+0x9d>
		// Mappeo en el hijo la página
		if ((r = sys_page_map(0, addr, envid, addr, perm | PTE_COW)) < 0)
  800ca6:	80 cc 08             	or     $0x8,%ah
  800ca9:	89 c3                	mov    %eax,%ebx
  800cab:	83 ec 0c             	sub    $0xc,%esp
  800cae:	50                   	push   %eax
  800caf:	56                   	push   %esi
  800cb0:	51                   	push   %ecx
  800cb1:	56                   	push   %esi
  800cb2:	6a 00                	push   $0x0
  800cb4:	e8 9c fe ff ff       	call   800b55 <sys_page_map>
  800cb9:	83 c4 20             	add    $0x20,%esp
  800cbc:	85 c0                	test   %eax,%eax
  800cbe:	78 3c                	js     800cfc <duppage+0x8b>
			panic("duppage: sys_page_map on childern COW: %e", r);

		// Cambio los permisos del padre
		if ((r = sys_page_map(0, addr, 0, addr, perm | PTE_COW)) < 0)
  800cc0:	83 ec 0c             	sub    $0xc,%esp
  800cc3:	53                   	push   %ebx
  800cc4:	56                   	push   %esi
  800cc5:	6a 00                	push   $0x0
  800cc7:	56                   	push   %esi
  800cc8:	6a 00                	push   $0x0
  800cca:	e8 86 fe ff ff       	call   800b55 <sys_page_map>
  800ccf:	83 c4 20             	add    $0x20,%esp
  800cd2:	85 c0                	test   %eax,%eax
  800cd4:	79 4d                	jns    800d23 <duppage+0xb2>
			panic("duppage: sys_page_map on parent COW: %e", r);
  800cd6:	50                   	push   %eax
  800cd7:	68 ec 17 80 00       	push   $0x8017ec
  800cdc:	6a 57                	push   $0x57
  800cde:	68 e1 18 80 00       	push   $0x8018e1
  800ce3:	e8 ee 04 00 00       	call   8011d6 <_panic>
		panic("duppage: copy a non-present or non-user page");
  800ce8:	83 ec 04             	sub    $0x4,%esp
  800ceb:	68 90 17 80 00       	push   $0x801790
  800cf0:	6a 47                	push   $0x47
  800cf2:	68 e1 18 80 00       	push   $0x8018e1
  800cf7:	e8 da 04 00 00       	call   8011d6 <_panic>
			panic("duppage: sys_page_map on childern COW: %e", r);
  800cfc:	50                   	push   %eax
  800cfd:	68 c0 17 80 00       	push   $0x8017c0
  800d02:	6a 53                	push   $0x53
  800d04:	68 e1 18 80 00       	push   $0x8018e1
  800d09:	e8 c8 04 00 00       	call   8011d6 <_panic>
	} else {
		// Solo mappeo la página de solo lectura
		if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  800d0e:	83 ec 0c             	sub    $0xc,%esp
  800d11:	50                   	push   %eax
  800d12:	56                   	push   %esi
  800d13:	51                   	push   %ecx
  800d14:	56                   	push   %esi
  800d15:	6a 00                	push   $0x0
  800d17:	e8 39 fe ff ff       	call   800b55 <sys_page_map>
  800d1c:	83 c4 20             	add    $0x20,%esp
  800d1f:	85 c0                	test   %eax,%eax
  800d21:	78 0c                	js     800d2f <duppage+0xbe>
			panic("duppage: sys_page_map on childern RO: %e", r);
	}

	// panic("duppage not implemented");
	return 0;
}
  800d23:	b8 00 00 00 00       	mov    $0x0,%eax
  800d28:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d2b:	5b                   	pop    %ebx
  800d2c:	5e                   	pop    %esi
  800d2d:	5d                   	pop    %ebp
  800d2e:	c3                   	ret    
			panic("duppage: sys_page_map on childern RO: %e", r);
  800d2f:	50                   	push   %eax
  800d30:	68 14 18 80 00       	push   $0x801814
  800d35:	6a 5b                	push   $0x5b
  800d37:	68 e1 18 80 00       	push   $0x8018e1
  800d3c:	e8 95 04 00 00       	call   8011d6 <_panic>

00800d41 <dup_or_share>:
 *
 * Hace uso de uvpd y uvpt para chequear permisos.
 */
static void
dup_or_share(envid_t envid, uint32_t pnum, int perm)
{
  800d41:	55                   	push   %ebp
  800d42:	89 e5                	mov    %esp,%ebp
  800d44:	57                   	push   %edi
  800d45:	56                   	push   %esi
  800d46:	53                   	push   %ebx
  800d47:	83 ec 0c             	sub    $0xc,%esp
  800d4a:	89 c7                	mov    %eax,%edi
	int r;
	void *addr = (void *) (pnum << PGSHIFT);

	pte_t pte = uvpt[pnum];
  800d4c:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax

	if (!(pte & PTE_P))
  800d53:	a8 01                	test   $0x1,%al
  800d55:	74 33                	je     800d8a <dup_or_share+0x49>
  800d57:	89 d6                	mov    %edx,%esi
		return;

	// Filtro permisos
	perm &= (pte & PTE_W);
  800d59:	21 c1                	and    %eax,%ecx
  800d5b:	89 cb                	mov    %ecx,%ebx
  800d5d:	83 e3 02             	and    $0x2,%ebx
	perm &= PTE_SYSCALL;


	if (pte & (PTE_PCD | PTE_PWT))
		perm |= PTE_PCD | PTE_PWT;
  800d60:	89 da                	mov    %ebx,%edx
  800d62:	83 ca 18             	or     $0x18,%edx
  800d65:	a8 18                	test   $0x18,%al
  800d67:	0f 45 da             	cmovne %edx,%ebx
	void *addr = (void *) (pnum << PGSHIFT);
  800d6a:	c1 e6 0c             	shl    $0xc,%esi

	// Si tengo que copiar
	if (!(pte & PTE_W) || (pte & (PTE_PCD | PTE_PWT))) {
  800d6d:	83 e0 1a             	and    $0x1a,%eax
  800d70:	83 f8 02             	cmp    $0x2,%eax
  800d73:	74 32                	je     800da7 <dup_or_share+0x66>
		if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  800d75:	83 ec 0c             	sub    $0xc,%esp
  800d78:	53                   	push   %ebx
  800d79:	56                   	push   %esi
  800d7a:	57                   	push   %edi
  800d7b:	56                   	push   %esi
  800d7c:	6a 00                	push   $0x0
  800d7e:	e8 d2 fd ff ff       	call   800b55 <sys_page_map>
  800d83:	83 c4 20             	add    $0x20,%esp
  800d86:	85 c0                	test   %eax,%eax
  800d88:	78 08                	js     800d92 <dup_or_share+0x51>
			panic("dup_or_share: sys_page_map: %e", r);
		memmove(UTEMP, addr, PGSIZE);
		if ((r = sys_page_unmap(0, UTEMP)) < 0)
			panic("sys_page_unmap: %e", r);
	}
}
  800d8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d8d:	5b                   	pop    %ebx
  800d8e:	5e                   	pop    %esi
  800d8f:	5f                   	pop    %edi
  800d90:	5d                   	pop    %ebp
  800d91:	c3                   	ret    
			panic("dup_or_share: sys_page_map: %e", r);
  800d92:	50                   	push   %eax
  800d93:	68 40 18 80 00       	push   $0x801840
  800d98:	68 84 00 00 00       	push   $0x84
  800d9d:	68 e1 18 80 00       	push   $0x8018e1
  800da2:	e8 2f 04 00 00       	call   8011d6 <_panic>
		if ((r = sys_page_alloc(envid, addr, perm)) < 0)
  800da7:	83 ec 04             	sub    $0x4,%esp
  800daa:	53                   	push   %ebx
  800dab:	56                   	push   %esi
  800dac:	57                   	push   %edi
  800dad:	e8 7f fd ff ff       	call   800b31 <sys_page_alloc>
  800db2:	83 c4 10             	add    $0x10,%esp
  800db5:	85 c0                	test   %eax,%eax
  800db7:	78 57                	js     800e10 <dup_or_share+0xcf>
		if ((r = sys_page_map(envid, addr, 0, UTEMP, perm)) < 0)
  800db9:	83 ec 0c             	sub    $0xc,%esp
  800dbc:	53                   	push   %ebx
  800dbd:	68 00 00 40 00       	push   $0x400000
  800dc2:	6a 00                	push   $0x0
  800dc4:	56                   	push   %esi
  800dc5:	57                   	push   %edi
  800dc6:	e8 8a fd ff ff       	call   800b55 <sys_page_map>
  800dcb:	83 c4 20             	add    $0x20,%esp
  800dce:	85 c0                	test   %eax,%eax
  800dd0:	78 53                	js     800e25 <dup_or_share+0xe4>
		memmove(UTEMP, addr, PGSIZE);
  800dd2:	83 ec 04             	sub    $0x4,%esp
  800dd5:	68 00 10 00 00       	push   $0x1000
  800dda:	56                   	push   %esi
  800ddb:	68 00 00 40 00       	push   $0x400000
  800de0:	e8 a2 fa ff ff       	call   800887 <memmove>
		if ((r = sys_page_unmap(0, UTEMP)) < 0)
  800de5:	83 c4 08             	add    $0x8,%esp
  800de8:	68 00 00 40 00       	push   $0x400000
  800ded:	6a 00                	push   $0x0
  800def:	e8 87 fd ff ff       	call   800b7b <sys_page_unmap>
  800df4:	83 c4 10             	add    $0x10,%esp
  800df7:	85 c0                	test   %eax,%eax
  800df9:	79 8f                	jns    800d8a <dup_or_share+0x49>
			panic("sys_page_unmap: %e", r);
  800dfb:	50                   	push   %eax
  800dfc:	68 2b 19 80 00       	push   $0x80192b
  800e01:	68 8d 00 00 00       	push   $0x8d
  800e06:	68 e1 18 80 00       	push   $0x8018e1
  800e0b:	e8 c6 03 00 00       	call   8011d6 <_panic>
			panic("dup_or_share: sys_page_alloc: %e", r);
  800e10:	50                   	push   %eax
  800e11:	68 60 18 80 00       	push   $0x801860
  800e16:	68 88 00 00 00       	push   $0x88
  800e1b:	68 e1 18 80 00       	push   $0x8018e1
  800e20:	e8 b1 03 00 00       	call   8011d6 <_panic>
			panic("dup_or_share: sys_page_map: %e", r);
  800e25:	50                   	push   %eax
  800e26:	68 40 18 80 00       	push   $0x801840
  800e2b:	68 8a 00 00 00       	push   $0x8a
  800e30:	68 e1 18 80 00       	push   $0x8018e1
  800e35:	e8 9c 03 00 00       	call   8011d6 <_panic>

00800e3a <pgfault>:
{
  800e3a:	55                   	push   %ebp
  800e3b:	89 e5                	mov    %esp,%ebp
  800e3d:	53                   	push   %ebx
  800e3e:	83 ec 08             	sub    $0x8,%esp
	void *addr = (void *) utf->utf_fault_va;
  800e41:	8b 45 08             	mov    0x8(%ebp),%eax
  800e44:	8b 18                	mov    (%eax),%ebx
	pte_t fault_pte = uvpt[((uint32_t) addr) >> PGSHIFT];
  800e46:	89 d8                	mov    %ebx,%eax
  800e48:	c1 e8 0c             	shr    $0xc,%eax
  800e4b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if ((r = sys_page_alloc(0, PFTEMP, perm)) < 0)
  800e52:	6a 07                	push   $0x7
  800e54:	68 00 f0 7f 00       	push   $0x7ff000
  800e59:	6a 00                	push   $0x0
  800e5b:	e8 d1 fc ff ff       	call   800b31 <sys_page_alloc>
  800e60:	83 c4 10             	add    $0x10,%esp
  800e63:	85 c0                	test   %eax,%eax
  800e65:	78 51                	js     800eb8 <pgfault+0x7e>
	addr = ROUNDDOWN(addr, PGSIZE);
  800e67:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr, PGSIZE);
  800e6d:	83 ec 04             	sub    $0x4,%esp
  800e70:	68 00 10 00 00       	push   $0x1000
  800e75:	53                   	push   %ebx
  800e76:	68 00 f0 7f 00       	push   $0x7ff000
  800e7b:	e8 07 fa ff ff       	call   800887 <memmove>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, perm)) < 0)
  800e80:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e87:	53                   	push   %ebx
  800e88:	6a 00                	push   $0x0
  800e8a:	68 00 f0 7f 00       	push   $0x7ff000
  800e8f:	6a 00                	push   $0x0
  800e91:	e8 bf fc ff ff       	call   800b55 <sys_page_map>
  800e96:	83 c4 20             	add    $0x20,%esp
  800e99:	85 c0                	test   %eax,%eax
  800e9b:	78 2d                	js     800eca <pgfault+0x90>
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800e9d:	83 ec 08             	sub    $0x8,%esp
  800ea0:	68 00 f0 7f 00       	push   $0x7ff000
  800ea5:	6a 00                	push   $0x0
  800ea7:	e8 cf fc ff ff       	call   800b7b <sys_page_unmap>
  800eac:	83 c4 10             	add    $0x10,%esp
  800eaf:	85 c0                	test   %eax,%eax
  800eb1:	78 29                	js     800edc <pgfault+0xa2>
}
  800eb3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eb6:	c9                   	leave  
  800eb7:	c3                   	ret    
		panic("pgfault: sys_page_alloc: %e", r);
  800eb8:	50                   	push   %eax
  800eb9:	68 ec 18 80 00       	push   $0x8018ec
  800ebe:	6a 27                	push   $0x27
  800ec0:	68 e1 18 80 00       	push   $0x8018e1
  800ec5:	e8 0c 03 00 00       	call   8011d6 <_panic>
		panic("pgfault: sys_page_map: %e", r);
  800eca:	50                   	push   %eax
  800ecb:	68 08 19 80 00       	push   $0x801908
  800ed0:	6a 2c                	push   $0x2c
  800ed2:	68 e1 18 80 00       	push   $0x8018e1
  800ed7:	e8 fa 02 00 00       	call   8011d6 <_panic>
		panic("pgfault: sys_page_unmap: %e", r);
  800edc:	50                   	push   %eax
  800edd:	68 22 19 80 00       	push   $0x801922
  800ee2:	6a 2f                	push   $0x2f
  800ee4:	68 e1 18 80 00       	push   $0x8018e1
  800ee9:	e8 e8 02 00 00       	call   8011d6 <_panic>

00800eee <fork_v0>:
 *  	-- Para ello se utiliza la funcion dup_or_share()
 *  	-- Se copian todas las paginas desde 0 hasta UTOP
 */
envid_t
fork_v0(void)
{
  800eee:	55                   	push   %ebp
  800eef:	89 e5                	mov    %esp,%ebp
  800ef1:	56                   	push   %esi
  800ef2:	53                   	push   %ebx

// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline)) sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2" : "=a"(ret) : "a"(SYS_exofork), "i"(T_SYSCALL));
  800ef3:	b8 07 00 00 00       	mov    $0x7,%eax
  800ef8:	cd 30                	int    $0x30
  800efa:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();
	if (envid < 0)
  800efc:	85 c0                	test   %eax,%eax
  800efe:	78 23                	js     800f23 <fork_v0+0x35>
	// Parent
	uint32_t pnum = 0;
	uint32_t pnum_end = (UTOP >> PGSHIFT);
	int perm = PTE_P | PTE_U | PTE_W;

	for (pnum = 0; pnum < pnum_end; pnum++) {
  800f00:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid == 0) {
  800f05:	75 3c                	jne    800f43 <fork_v0+0x55>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f07:	e8 da fb ff ff       	call   800ae6 <sys_getenvid>
  800f0c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f11:	69 c0 88 00 00 00    	imul   $0x88,%eax,%eax
  800f17:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f1c:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800f21:	eb 56                	jmp    800f79 <fork_v0+0x8b>
		panic("sys_exofork: %e", envid);
  800f23:	50                   	push   %eax
  800f24:	68 3e 19 80 00       	push   $0x80193e
  800f29:	68 a2 00 00 00       	push   $0xa2
  800f2e:	68 e1 18 80 00       	push   $0x8018e1
  800f33:	e8 9e 02 00 00       	call   8011d6 <_panic>
	for (pnum = 0; pnum < pnum_end; pnum++) {
  800f38:	83 c3 01             	add    $0x1,%ebx
  800f3b:	81 fb 00 ec 0e 00    	cmp    $0xeec00,%ebx
  800f41:	74 24                	je     800f67 <fork_v0+0x79>
		pde_t pde = uvpd[pnum >> 10];
  800f43:	89 d8                	mov    %ebx,%eax
  800f45:	c1 e8 0a             	shr    $0xa,%eax
  800f48:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
		if (!(pde & PTE_P) || !(pde & PTE_U))
  800f4f:	83 e0 05             	and    $0x5,%eax
  800f52:	83 f8 05             	cmp    $0x5,%eax
  800f55:	75 e1                	jne    800f38 <fork_v0+0x4a>
			continue;
		dup_or_share(envid, pnum, perm);
  800f57:	b9 07 00 00 00       	mov    $0x7,%ecx
  800f5c:	89 da                	mov    %ebx,%edx
  800f5e:	89 f0                	mov    %esi,%eax
  800f60:	e8 dc fd ff ff       	call   800d41 <dup_or_share>
  800f65:	eb d1                	jmp    800f38 <fork_v0+0x4a>
	}


	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800f67:	83 ec 08             	sub    $0x8,%esp
  800f6a:	6a 02                	push   $0x2
  800f6c:	56                   	push   %esi
  800f6d:	e8 2c fc ff ff       	call   800b9e <sys_env_set_status>
  800f72:	83 c4 10             	add    $0x10,%esp
  800f75:	85 c0                	test   %eax,%eax
  800f77:	78 09                	js     800f82 <fork_v0+0x94>
		panic("sys_env_set_status: %e", r);

	return envid;
}
  800f79:	89 f0                	mov    %esi,%eax
  800f7b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f7e:	5b                   	pop    %ebx
  800f7f:	5e                   	pop    %esi
  800f80:	5d                   	pop    %ebp
  800f81:	c3                   	ret    
		panic("sys_env_set_status: %e", r);
  800f82:	50                   	push   %eax
  800f83:	68 4e 19 80 00       	push   $0x80194e
  800f88:	68 b8 00 00 00       	push   $0xb8
  800f8d:	68 e1 18 80 00       	push   $0x8018e1
  800f92:	e8 3f 02 00 00       	call   8011d6 <_panic>

00800f97 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f97:	55                   	push   %ebp
  800f98:	89 e5                	mov    %esp,%ebp
  800f9a:	56                   	push   %esi
  800f9b:	53                   	push   %ebx
	set_pgfault_handler(pgfault);
  800f9c:	83 ec 0c             	sub    $0xc,%esp
  800f9f:	68 3a 0e 80 00       	push   $0x800e3a
  800fa4:	e8 73 02 00 00       	call   80121c <set_pgfault_handler>
  800fa9:	b8 07 00 00 00       	mov    $0x7,%eax
  800fae:	cd 30                	int    $0x30
  800fb0:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();

	if (envid < 0)
  800fb2:	83 c4 10             	add    $0x10,%esp
  800fb5:	85 c0                	test   %eax,%eax
  800fb7:	78 26                	js     800fdf <fork+0x48>
	// Parent
	uint32_t pnum = 0;
	uint32_t pnum_end = (UTOP >> PGSHIFT);

	// Handle all pages below UTOP
	for (pnum = 0; pnum < pnum_end; pnum++) {
  800fb9:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid == 0) {
  800fbe:	75 41                	jne    801001 <fork+0x6a>
		thisenv = &envs[ENVX(sys_getenvid())];
  800fc0:	e8 21 fb ff ff       	call   800ae6 <sys_getenvid>
  800fc5:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fca:	69 c0 88 00 00 00    	imul   $0x88,%eax,%eax
  800fd0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fd5:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800fda:	e9 92 00 00 00       	jmp    801071 <fork+0xda>
		panic("sys_exofork: %e", envid);
  800fdf:	50                   	push   %eax
  800fe0:	68 3e 19 80 00       	push   $0x80193e
  800fe5:	68 d5 00 00 00       	push   $0xd5
  800fea:	68 e1 18 80 00       	push   $0x8018e1
  800fef:	e8 e2 01 00 00       	call   8011d6 <_panic>
	for (pnum = 0; pnum < pnum_end; pnum++) {
  800ff4:	83 c3 01             	add    $0x1,%ebx
  800ff7:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  800ffd:	77 30                	ja     80102f <fork+0x98>
		if (pnum == ((UXSTACKTOP >> PGSHIFT) - 1))
  800fff:	74 f3                	je     800ff4 <fork+0x5d>
			continue;

		pde_t pde = uvpd[pnum >> 10];
  801001:	89 d8                	mov    %ebx,%eax
  801003:	c1 e8 0a             	shr    $0xa,%eax
  801006:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
		if (!(pde & PTE_P) || !(pde & PTE_U))
  80100d:	83 e0 05             	and    $0x5,%eax
  801010:	83 f8 05             	cmp    $0x5,%eax
  801013:	75 df                	jne    800ff4 <fork+0x5d>
			continue;

		pte_t pte = uvpt[pnum];
  801015:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
		if (!(pte & PTE_P) || !(pte & PTE_U))
  80101c:	83 e0 05             	and    $0x5,%eax
  80101f:	83 f8 05             	cmp    $0x5,%eax
  801022:	75 d0                	jne    800ff4 <fork+0x5d>
			continue;
		duppage(envid, pnum);
  801024:	89 da                	mov    %ebx,%edx
  801026:	89 f0                	mov    %esi,%eax
  801028:	e8 44 fc ff ff       	call   800c71 <duppage>
  80102d:	eb c5                	jmp    800ff4 <fork+0x5d>
	}

	uint32_t exstk = (UXSTACKTOP - PGSIZE);
	int r = sys_page_alloc(envid, (void *) exstk, PTE_U | PTE_P | PTE_W);
  80102f:	83 ec 04             	sub    $0x4,%esp
  801032:	6a 07                	push   $0x7
  801034:	68 00 f0 bf ee       	push   $0xeebff000
  801039:	56                   	push   %esi
  80103a:	e8 f2 fa ff ff       	call   800b31 <sys_page_alloc>
	if (r < 0)
  80103f:	83 c4 10             	add    $0x10,%esp
  801042:	85 c0                	test   %eax,%eax
  801044:	78 34                	js     80107a <fork+0xe3>
		panic("fork: sys_page_alloc of exception stk: %e", r);
	r = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801046:	a1 04 20 80 00       	mov    0x802004,%eax
  80104b:	8b 40 70             	mov    0x70(%eax),%eax
  80104e:	83 ec 08             	sub    $0x8,%esp
  801051:	50                   	push   %eax
  801052:	56                   	push   %esi
  801053:	e8 69 fb ff ff       	call   800bc1 <sys_env_set_pgfault_upcall>
	if (r < 0)
  801058:	83 c4 10             	add    $0x10,%esp
  80105b:	85 c0                	test   %eax,%eax
  80105d:	78 30                	js     80108f <fork+0xf8>
		panic("fork: sys_env_set_pgfault_upcall on childern: %e", r);

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  80105f:	83 ec 08             	sub    $0x8,%esp
  801062:	6a 02                	push   $0x2
  801064:	56                   	push   %esi
  801065:	e8 34 fb ff ff       	call   800b9e <sys_env_set_status>
  80106a:	83 c4 10             	add    $0x10,%esp
  80106d:	85 c0                	test   %eax,%eax
  80106f:	78 33                	js     8010a4 <fork+0x10d>
		panic("sys_env_set_status: %e", r);

	return envid;
}
  801071:	89 f0                	mov    %esi,%eax
  801073:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801076:	5b                   	pop    %ebx
  801077:	5e                   	pop    %esi
  801078:	5d                   	pop    %ebp
  801079:	c3                   	ret    
		panic("fork: sys_page_alloc of exception stk: %e", r);
  80107a:	50                   	push   %eax
  80107b:	68 84 18 80 00       	push   $0x801884
  801080:	68 f2 00 00 00       	push   $0xf2
  801085:	68 e1 18 80 00       	push   $0x8018e1
  80108a:	e8 47 01 00 00       	call   8011d6 <_panic>
		panic("fork: sys_env_set_pgfault_upcall on childern: %e", r);
  80108f:	50                   	push   %eax
  801090:	68 b0 18 80 00       	push   $0x8018b0
  801095:	68 f5 00 00 00       	push   $0xf5
  80109a:	68 e1 18 80 00       	push   $0x8018e1
  80109f:	e8 32 01 00 00       	call   8011d6 <_panic>
		panic("sys_env_set_status: %e", r);
  8010a4:	50                   	push   %eax
  8010a5:	68 4e 19 80 00       	push   $0x80194e
  8010aa:	68 f8 00 00 00       	push   $0xf8
  8010af:	68 e1 18 80 00       	push   $0x8018e1
  8010b4:	e8 1d 01 00 00       	call   8011d6 <_panic>

008010b9 <sfork>:

// Challenge!
int
sfork(void)
{
  8010b9:	55                   	push   %ebp
  8010ba:	89 e5                	mov    %esp,%ebp
  8010bc:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010bf:	68 65 19 80 00       	push   $0x801965
  8010c4:	68 01 01 00 00       	push   $0x101
  8010c9:	68 e1 18 80 00       	push   $0x8018e1
  8010ce:	e8 03 01 00 00       	call   8011d6 <_panic>

008010d3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8010d3:	55                   	push   %ebp
  8010d4:	89 e5                	mov    %esp,%ebp
  8010d6:	56                   	push   %esi
  8010d7:	53                   	push   %ebx
  8010d8:	8b 75 08             	mov    0x8(%ebp),%esi
  8010db:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int err = sys_ipc_recv(pg);
  8010de:	83 ec 0c             	sub    $0xc,%esp
  8010e1:	ff 75 0c             	push   0xc(%ebp)
  8010e4:	e8 20 fb ff ff       	call   800c09 <sys_ipc_recv>

	if (from_env_store)
  8010e9:	83 c4 10             	add    $0x10,%esp
  8010ec:	85 f6                	test   %esi,%esi
  8010ee:	74 17                	je     801107 <ipc_recv+0x34>
		*from_env_store = (!err) ? thisenv->env_ipc_from : 0;
  8010f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8010f5:	85 c0                	test   %eax,%eax
  8010f7:	75 0c                	jne    801105 <ipc_recv+0x32>
  8010f9:	8b 15 04 20 80 00    	mov    0x802004,%edx
  8010ff:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
  801105:	89 16                	mov    %edx,(%esi)

	if (perm_store)
  801107:	85 db                	test   %ebx,%ebx
  801109:	74 17                	je     801122 <ipc_recv+0x4f>
		*perm_store = (!err) ? thisenv->env_ipc_perm : 0;
  80110b:	ba 00 00 00 00       	mov    $0x0,%edx
  801110:	85 c0                	test   %eax,%eax
  801112:	75 0c                	jne    801120 <ipc_recv+0x4d>
  801114:	8b 15 04 20 80 00    	mov    0x802004,%edx
  80111a:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  801120:	89 13                	mov    %edx,(%ebx)

	if (!err)
  801122:	85 c0                	test   %eax,%eax
  801124:	75 08                	jne    80112e <ipc_recv+0x5b>
		err = thisenv->env_ipc_value;
  801126:	a1 04 20 80 00       	mov    0x802004,%eax
  80112b:	8b 40 7c             	mov    0x7c(%eax),%eax

	return err;
}
  80112e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801131:	5b                   	pop    %ebx
  801132:	5e                   	pop    %esi
  801133:	5d                   	pop    %ebp
  801134:	c3                   	ret    

00801135 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801135:	55                   	push   %ebp
  801136:	89 e5                	mov    %esp,%ebp
  801138:	57                   	push   %edi
  801139:	56                   	push   %esi
  80113a:	53                   	push   %ebx
  80113b:	83 ec 0c             	sub    $0xc,%esp
  80113e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801141:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801144:	8b 7d 14             	mov    0x14(%ebp),%edi
	if (!pg)
		pg = (void *) UTOP;
  801147:	85 db                	test   %ebx,%ebx
  801149:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80114e:	0f 44 d8             	cmove  %eax,%ebx
	int r = sys_ipc_try_send(to_env, val, pg, perm);
  801151:	57                   	push   %edi
  801152:	53                   	push   %ebx
  801153:	56                   	push   %esi
  801154:	ff 75 08             	push   0x8(%ebp)
  801157:	e8 88 fa ff ff       	call   800be4 <sys_ipc_try_send>
	while (r == -E_IPC_NOT_RECV) {
  80115c:	83 c4 10             	add    $0x10,%esp
  80115f:	eb 13                	jmp    801174 <ipc_send+0x3f>
		sys_yield();
  801161:	e8 a4 f9 ff ff       	call   800b0a <sys_yield>
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801166:	57                   	push   %edi
  801167:	53                   	push   %ebx
  801168:	56                   	push   %esi
  801169:	ff 75 08             	push   0x8(%ebp)
  80116c:	e8 73 fa ff ff       	call   800be4 <sys_ipc_try_send>
  801171:	83 c4 10             	add    $0x10,%esp
	while (r == -E_IPC_NOT_RECV) {
  801174:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801177:	74 e8                	je     801161 <ipc_send+0x2c>
	}

	if (r < 0)
  801179:	85 c0                	test   %eax,%eax
  80117b:	78 08                	js     801185 <ipc_send+0x50>
		panic("ipc_send: %e", r);
}
  80117d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801180:	5b                   	pop    %ebx
  801181:	5e                   	pop    %esi
  801182:	5f                   	pop    %edi
  801183:	5d                   	pop    %ebp
  801184:	c3                   	ret    
		panic("ipc_send: %e", r);
  801185:	50                   	push   %eax
  801186:	68 7b 19 80 00       	push   $0x80197b
  80118b:	6a 3b                	push   $0x3b
  80118d:	68 88 19 80 00       	push   $0x801988
  801192:	e8 3f 00 00 00       	call   8011d6 <_panic>

00801197 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801197:	55                   	push   %ebp
  801198:	89 e5                	mov    %esp,%ebp
  80119a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80119d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8011a2:	69 d0 88 00 00 00    	imul   $0x88,%eax,%edx
  8011a8:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8011ae:	8b 52 50             	mov    0x50(%edx),%edx
  8011b1:	39 ca                	cmp    %ecx,%edx
  8011b3:	74 11                	je     8011c6 <ipc_find_env+0x2f>
	for (i = 0; i < NENV; i++)
  8011b5:	83 c0 01             	add    $0x1,%eax
  8011b8:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011bd:	75 e3                	jne    8011a2 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  8011bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8011c4:	eb 0e                	jmp    8011d4 <ipc_find_env+0x3d>
			return envs[i].env_id;
  8011c6:	69 c0 88 00 00 00    	imul   $0x88,%eax,%eax
  8011cc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011d1:	8b 40 48             	mov    0x48(%eax),%eax
}
  8011d4:	5d                   	pop    %ebp
  8011d5:	c3                   	ret    

008011d6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8011d6:	55                   	push   %ebp
  8011d7:	89 e5                	mov    %esp,%ebp
  8011d9:	56                   	push   %esi
  8011da:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8011db:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8011de:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8011e4:	e8 fd f8 ff ff       	call   800ae6 <sys_getenvid>
  8011e9:	83 ec 0c             	sub    $0xc,%esp
  8011ec:	ff 75 0c             	push   0xc(%ebp)
  8011ef:	ff 75 08             	push   0x8(%ebp)
  8011f2:	56                   	push   %esi
  8011f3:	50                   	push   %eax
  8011f4:	68 94 19 80 00       	push   $0x801994
  8011f9:	e8 b6 ef ff ff       	call   8001b4 <cprintf>
	        sys_getenvid(),
	        binaryname,
	        file,
	        line);
	vcprintf(fmt, ap);
  8011fe:	83 c4 18             	add    $0x18,%esp
  801201:	53                   	push   %ebx
  801202:	ff 75 10             	push   0x10(%ebp)
  801205:	e8 59 ef ff ff       	call   800163 <vcprintf>
	cprintf("\n");
  80120a:	c7 04 24 07 15 80 00 	movl   $0x801507,(%esp)
  801211:	e8 9e ef ff ff       	call   8001b4 <cprintf>
  801216:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801219:	cc                   	int3   
  80121a:	eb fd                	jmp    801219 <_panic+0x43>

0080121c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80121c:	55                   	push   %ebp
  80121d:	89 e5                	mov    %esp,%ebp
  80121f:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801222:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  801229:	74 0a                	je     801235 <set_pgfault_handler+0x19>
		if (r < 0)
			return;
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80122b:	8b 45 08             	mov    0x8(%ebp),%eax
  80122e:	a3 08 20 80 00       	mov    %eax,0x802008
}
  801233:	c9                   	leave  
  801234:	c3                   	ret    
		r = sys_page_alloc(0, (void *) exstk, perm);
  801235:	83 ec 04             	sub    $0x4,%esp
  801238:	6a 07                	push   $0x7
  80123a:	68 00 f0 bf ee       	push   $0xeebff000
  80123f:	6a 00                	push   $0x0
  801241:	e8 eb f8 ff ff       	call   800b31 <sys_page_alloc>
		if (r < 0)
  801246:	83 c4 10             	add    $0x10,%esp
  801249:	85 c0                	test   %eax,%eax
  80124b:	78 e6                	js     801233 <set_pgfault_handler+0x17>
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  80124d:	83 ec 08             	sub    $0x8,%esp
  801250:	68 65 12 80 00       	push   $0x801265
  801255:	6a 00                	push   $0x0
  801257:	e8 65 f9 ff ff       	call   800bc1 <sys_env_set_pgfault_upcall>
		if (r < 0)
  80125c:	83 c4 10             	add    $0x10,%esp
  80125f:	85 c0                	test   %eax,%eax
  801261:	79 c8                	jns    80122b <set_pgfault_handler+0xf>
  801263:	eb ce                	jmp    801233 <set_pgfault_handler+0x17>

00801265 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801265:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801266:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  80126b:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80126d:	83 c4 04             	add    $0x4,%esp
	// Throughout the remaining code, think carefully about what
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	movl 40(%esp), %eax	// trap-time %epi -> %eax 
  801270:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %ebx	// trap-time %esp -> %ebx
  801274:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4, %ebx
  801278:	83 eb 04             	sub    $0x4,%ebx
	movl %eax, 0(%ebx)	// push %eip in trap-time stack
  80127b:	89 03                	mov    %eax,(%ebx)

	movl %ebx, 48(%esp)
  80127d:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	popl %eax
  801281:	58                   	pop    %eax
	popl %eax
  801282:	58                   	pop    %eax
	popal
  801283:	61                   	popa   
	

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	addl $4, %esp
  801284:	83 c4 04             	add    $0x4,%esp
	popfl
  801287:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	popl %esp
  801288:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	ret
  801289:	c3                   	ret    
  80128a:	66 90                	xchg   %ax,%ax
  80128c:	66 90                	xchg   %ax,%ax
  80128e:	66 90                	xchg   %ax,%ax

00801290 <__udivdi3>:
  801290:	f3 0f 1e fb          	endbr32 
  801294:	55                   	push   %ebp
  801295:	57                   	push   %edi
  801296:	56                   	push   %esi
  801297:	53                   	push   %ebx
  801298:	83 ec 1c             	sub    $0x1c,%esp
  80129b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80129f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8012a3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8012a7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8012ab:	85 c0                	test   %eax,%eax
  8012ad:	75 19                	jne    8012c8 <__udivdi3+0x38>
  8012af:	39 f3                	cmp    %esi,%ebx
  8012b1:	76 4d                	jbe    801300 <__udivdi3+0x70>
  8012b3:	31 ff                	xor    %edi,%edi
  8012b5:	89 e8                	mov    %ebp,%eax
  8012b7:	89 f2                	mov    %esi,%edx
  8012b9:	f7 f3                	div    %ebx
  8012bb:	89 fa                	mov    %edi,%edx
  8012bd:	83 c4 1c             	add    $0x1c,%esp
  8012c0:	5b                   	pop    %ebx
  8012c1:	5e                   	pop    %esi
  8012c2:	5f                   	pop    %edi
  8012c3:	5d                   	pop    %ebp
  8012c4:	c3                   	ret    
  8012c5:	8d 76 00             	lea    0x0(%esi),%esi
  8012c8:	39 f0                	cmp    %esi,%eax
  8012ca:	76 14                	jbe    8012e0 <__udivdi3+0x50>
  8012cc:	31 ff                	xor    %edi,%edi
  8012ce:	31 c0                	xor    %eax,%eax
  8012d0:	89 fa                	mov    %edi,%edx
  8012d2:	83 c4 1c             	add    $0x1c,%esp
  8012d5:	5b                   	pop    %ebx
  8012d6:	5e                   	pop    %esi
  8012d7:	5f                   	pop    %edi
  8012d8:	5d                   	pop    %ebp
  8012d9:	c3                   	ret    
  8012da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012e0:	0f bd f8             	bsr    %eax,%edi
  8012e3:	83 f7 1f             	xor    $0x1f,%edi
  8012e6:	75 48                	jne    801330 <__udivdi3+0xa0>
  8012e8:	39 f0                	cmp    %esi,%eax
  8012ea:	72 06                	jb     8012f2 <__udivdi3+0x62>
  8012ec:	31 c0                	xor    %eax,%eax
  8012ee:	39 eb                	cmp    %ebp,%ebx
  8012f0:	77 de                	ja     8012d0 <__udivdi3+0x40>
  8012f2:	b8 01 00 00 00       	mov    $0x1,%eax
  8012f7:	eb d7                	jmp    8012d0 <__udivdi3+0x40>
  8012f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801300:	89 d9                	mov    %ebx,%ecx
  801302:	85 db                	test   %ebx,%ebx
  801304:	75 0b                	jne    801311 <__udivdi3+0x81>
  801306:	b8 01 00 00 00       	mov    $0x1,%eax
  80130b:	31 d2                	xor    %edx,%edx
  80130d:	f7 f3                	div    %ebx
  80130f:	89 c1                	mov    %eax,%ecx
  801311:	31 d2                	xor    %edx,%edx
  801313:	89 f0                	mov    %esi,%eax
  801315:	f7 f1                	div    %ecx
  801317:	89 c6                	mov    %eax,%esi
  801319:	89 e8                	mov    %ebp,%eax
  80131b:	89 f7                	mov    %esi,%edi
  80131d:	f7 f1                	div    %ecx
  80131f:	89 fa                	mov    %edi,%edx
  801321:	83 c4 1c             	add    $0x1c,%esp
  801324:	5b                   	pop    %ebx
  801325:	5e                   	pop    %esi
  801326:	5f                   	pop    %edi
  801327:	5d                   	pop    %ebp
  801328:	c3                   	ret    
  801329:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801330:	89 f9                	mov    %edi,%ecx
  801332:	ba 20 00 00 00       	mov    $0x20,%edx
  801337:	29 fa                	sub    %edi,%edx
  801339:	d3 e0                	shl    %cl,%eax
  80133b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80133f:	89 d1                	mov    %edx,%ecx
  801341:	89 d8                	mov    %ebx,%eax
  801343:	d3 e8                	shr    %cl,%eax
  801345:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801349:	09 c1                	or     %eax,%ecx
  80134b:	89 f0                	mov    %esi,%eax
  80134d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801351:	89 f9                	mov    %edi,%ecx
  801353:	d3 e3                	shl    %cl,%ebx
  801355:	89 d1                	mov    %edx,%ecx
  801357:	d3 e8                	shr    %cl,%eax
  801359:	89 f9                	mov    %edi,%ecx
  80135b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80135f:	89 eb                	mov    %ebp,%ebx
  801361:	d3 e6                	shl    %cl,%esi
  801363:	89 d1                	mov    %edx,%ecx
  801365:	d3 eb                	shr    %cl,%ebx
  801367:	09 f3                	or     %esi,%ebx
  801369:	89 c6                	mov    %eax,%esi
  80136b:	89 f2                	mov    %esi,%edx
  80136d:	89 d8                	mov    %ebx,%eax
  80136f:	f7 74 24 08          	divl   0x8(%esp)
  801373:	89 d6                	mov    %edx,%esi
  801375:	89 c3                	mov    %eax,%ebx
  801377:	f7 64 24 0c          	mull   0xc(%esp)
  80137b:	39 d6                	cmp    %edx,%esi
  80137d:	72 19                	jb     801398 <__udivdi3+0x108>
  80137f:	89 f9                	mov    %edi,%ecx
  801381:	d3 e5                	shl    %cl,%ebp
  801383:	39 c5                	cmp    %eax,%ebp
  801385:	73 04                	jae    80138b <__udivdi3+0xfb>
  801387:	39 d6                	cmp    %edx,%esi
  801389:	74 0d                	je     801398 <__udivdi3+0x108>
  80138b:	89 d8                	mov    %ebx,%eax
  80138d:	31 ff                	xor    %edi,%edi
  80138f:	e9 3c ff ff ff       	jmp    8012d0 <__udivdi3+0x40>
  801394:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801398:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80139b:	31 ff                	xor    %edi,%edi
  80139d:	e9 2e ff ff ff       	jmp    8012d0 <__udivdi3+0x40>
  8013a2:	66 90                	xchg   %ax,%ax
  8013a4:	66 90                	xchg   %ax,%ax
  8013a6:	66 90                	xchg   %ax,%ax
  8013a8:	66 90                	xchg   %ax,%ax
  8013aa:	66 90                	xchg   %ax,%ax
  8013ac:	66 90                	xchg   %ax,%ax
  8013ae:	66 90                	xchg   %ax,%ax

008013b0 <__umoddi3>:
  8013b0:	f3 0f 1e fb          	endbr32 
  8013b4:	55                   	push   %ebp
  8013b5:	57                   	push   %edi
  8013b6:	56                   	push   %esi
  8013b7:	53                   	push   %ebx
  8013b8:	83 ec 1c             	sub    $0x1c,%esp
  8013bb:	8b 74 24 30          	mov    0x30(%esp),%esi
  8013bf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8013c3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  8013c7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  8013cb:	89 f0                	mov    %esi,%eax
  8013cd:	89 da                	mov    %ebx,%edx
  8013cf:	85 ff                	test   %edi,%edi
  8013d1:	75 15                	jne    8013e8 <__umoddi3+0x38>
  8013d3:	39 dd                	cmp    %ebx,%ebp
  8013d5:	76 39                	jbe    801410 <__umoddi3+0x60>
  8013d7:	f7 f5                	div    %ebp
  8013d9:	89 d0                	mov    %edx,%eax
  8013db:	31 d2                	xor    %edx,%edx
  8013dd:	83 c4 1c             	add    $0x1c,%esp
  8013e0:	5b                   	pop    %ebx
  8013e1:	5e                   	pop    %esi
  8013e2:	5f                   	pop    %edi
  8013e3:	5d                   	pop    %ebp
  8013e4:	c3                   	ret    
  8013e5:	8d 76 00             	lea    0x0(%esi),%esi
  8013e8:	39 df                	cmp    %ebx,%edi
  8013ea:	77 f1                	ja     8013dd <__umoddi3+0x2d>
  8013ec:	0f bd cf             	bsr    %edi,%ecx
  8013ef:	83 f1 1f             	xor    $0x1f,%ecx
  8013f2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8013f6:	75 40                	jne    801438 <__umoddi3+0x88>
  8013f8:	39 df                	cmp    %ebx,%edi
  8013fa:	72 04                	jb     801400 <__umoddi3+0x50>
  8013fc:	39 f5                	cmp    %esi,%ebp
  8013fe:	77 dd                	ja     8013dd <__umoddi3+0x2d>
  801400:	89 da                	mov    %ebx,%edx
  801402:	89 f0                	mov    %esi,%eax
  801404:	29 e8                	sub    %ebp,%eax
  801406:	19 fa                	sbb    %edi,%edx
  801408:	eb d3                	jmp    8013dd <__umoddi3+0x2d>
  80140a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801410:	89 e9                	mov    %ebp,%ecx
  801412:	85 ed                	test   %ebp,%ebp
  801414:	75 0b                	jne    801421 <__umoddi3+0x71>
  801416:	b8 01 00 00 00       	mov    $0x1,%eax
  80141b:	31 d2                	xor    %edx,%edx
  80141d:	f7 f5                	div    %ebp
  80141f:	89 c1                	mov    %eax,%ecx
  801421:	89 d8                	mov    %ebx,%eax
  801423:	31 d2                	xor    %edx,%edx
  801425:	f7 f1                	div    %ecx
  801427:	89 f0                	mov    %esi,%eax
  801429:	f7 f1                	div    %ecx
  80142b:	89 d0                	mov    %edx,%eax
  80142d:	31 d2                	xor    %edx,%edx
  80142f:	eb ac                	jmp    8013dd <__umoddi3+0x2d>
  801431:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801438:	8b 44 24 04          	mov    0x4(%esp),%eax
  80143c:	ba 20 00 00 00       	mov    $0x20,%edx
  801441:	29 c2                	sub    %eax,%edx
  801443:	89 c1                	mov    %eax,%ecx
  801445:	89 e8                	mov    %ebp,%eax
  801447:	d3 e7                	shl    %cl,%edi
  801449:	89 d1                	mov    %edx,%ecx
  80144b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80144f:	d3 e8                	shr    %cl,%eax
  801451:	89 c1                	mov    %eax,%ecx
  801453:	8b 44 24 04          	mov    0x4(%esp),%eax
  801457:	09 f9                	or     %edi,%ecx
  801459:	89 df                	mov    %ebx,%edi
  80145b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80145f:	89 c1                	mov    %eax,%ecx
  801461:	d3 e5                	shl    %cl,%ebp
  801463:	89 d1                	mov    %edx,%ecx
  801465:	d3 ef                	shr    %cl,%edi
  801467:	89 c1                	mov    %eax,%ecx
  801469:	89 f0                	mov    %esi,%eax
  80146b:	d3 e3                	shl    %cl,%ebx
  80146d:	89 d1                	mov    %edx,%ecx
  80146f:	89 fa                	mov    %edi,%edx
  801471:	d3 e8                	shr    %cl,%eax
  801473:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801478:	09 d8                	or     %ebx,%eax
  80147a:	f7 74 24 08          	divl   0x8(%esp)
  80147e:	89 d3                	mov    %edx,%ebx
  801480:	d3 e6                	shl    %cl,%esi
  801482:	f7 e5                	mul    %ebp
  801484:	89 c7                	mov    %eax,%edi
  801486:	89 d1                	mov    %edx,%ecx
  801488:	39 d3                	cmp    %edx,%ebx
  80148a:	72 06                	jb     801492 <__umoddi3+0xe2>
  80148c:	75 0e                	jne    80149c <__umoddi3+0xec>
  80148e:	39 c6                	cmp    %eax,%esi
  801490:	73 0a                	jae    80149c <__umoddi3+0xec>
  801492:	29 e8                	sub    %ebp,%eax
  801494:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801498:	89 d1                	mov    %edx,%ecx
  80149a:	89 c7                	mov    %eax,%edi
  80149c:	89 f5                	mov    %esi,%ebp
  80149e:	8b 74 24 04          	mov    0x4(%esp),%esi
  8014a2:	29 fd                	sub    %edi,%ebp
  8014a4:	19 cb                	sbb    %ecx,%ebx
  8014a6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8014ab:	89 d8                	mov    %ebx,%eax
  8014ad:	d3 e0                	shl    %cl,%eax
  8014af:	89 f1                	mov    %esi,%ecx
  8014b1:	d3 ed                	shr    %cl,%ebp
  8014b3:	d3 eb                	shr    %cl,%ebx
  8014b5:	09 e8                	or     %ebp,%eax
  8014b7:	89 da                	mov    %ebx,%edx
  8014b9:	83 c4 1c             	add    $0x1c,%esp
  8014bc:	5b                   	pop    %ebx
  8014bd:	5e                   	pop    %esi
  8014be:	5f                   	pop    %edi
  8014bf:	5d                   	pop    %ebp
  8014c0:	c3                   	ret    
