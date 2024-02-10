
obj/user/fairness:     formato del fichero elf32-i386


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
  80002c:	e8 70 00 00 00       	call   8000a1 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 10             	sub    $0x10,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003b:	e8 87 0a 00 00       	call   800ac7 <sys_getenvid>
  800040:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800042:	81 3d 04 20 80 00 88 	cmpl   $0xeec00088,0x802004
  800049:	00 c0 ee 
  80004c:	74 2d                	je     80007b <umain+0x48>
		while (1) {
			ipc_recv(&who, 0, 0);
			cprintf("%x recv from %x\n", id, who);
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  80004e:	a1 d0 00 c0 ee       	mov    0xeec000d0,%eax
  800053:	83 ec 04             	sub    $0x4,%esp
  800056:	50                   	push   %eax
  800057:	53                   	push   %ebx
  800058:	68 f1 0f 80 00       	push   $0x800ff1
  80005d:	e8 33 01 00 00       	call   800195 <cprintf>
  800062:	83 c4 10             	add    $0x10,%esp
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  800065:	a1 d0 00 c0 ee       	mov    0xeec000d0,%eax
  80006a:	6a 00                	push   $0x0
  80006c:	6a 00                	push   $0x0
  80006e:	6a 00                	push   $0x0
  800070:	50                   	push   %eax
  800071:	e8 3e 0c 00 00       	call   800cb4 <ipc_send>
  800076:	83 c4 10             	add    $0x10,%esp
  800079:	eb ea                	jmp    800065 <umain+0x32>
			ipc_recv(&who, 0, 0);
  80007b:	8d 75 f4             	lea    -0xc(%ebp),%esi
  80007e:	83 ec 04             	sub    $0x4,%esp
  800081:	6a 00                	push   $0x0
  800083:	6a 00                	push   $0x0
  800085:	56                   	push   %esi
  800086:	e8 c7 0b 00 00       	call   800c52 <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80008b:	83 c4 0c             	add    $0xc,%esp
  80008e:	ff 75 f4             	push   -0xc(%ebp)
  800091:	53                   	push   %ebx
  800092:	68 e0 0f 80 00       	push   $0x800fe0
  800097:	e8 f9 00 00 00       	call   800195 <cprintf>
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	eb dd                	jmp    80007e <umain+0x4b>

008000a1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	56                   	push   %esi
  8000a5:	53                   	push   %ebx
  8000a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	envid_t id = sys_getenvid();
  8000ac:	e8 16 0a 00 00       	call   800ac7 <sys_getenvid>
	if (id >= 0)
  8000b1:	85 c0                	test   %eax,%eax
  8000b3:	78 15                	js     8000ca <libmain+0x29>
		thisenv = &envs[ENVX(id)];
  8000b5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ba:	69 c0 88 00 00 00    	imul   $0x88,%eax,%eax
  8000c0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000c5:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ca:	85 db                	test   %ebx,%ebx
  8000cc:	7e 07                	jle    8000d5 <libmain+0x34>
		binaryname = argv[0];
  8000ce:	8b 06                	mov    (%esi),%eax
  8000d0:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000d5:	83 ec 08             	sub    $0x8,%esp
  8000d8:	56                   	push   %esi
  8000d9:	53                   	push   %ebx
  8000da:	e8 54 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000df:	e8 0a 00 00 00       	call   8000ee <exit>
}
  8000e4:	83 c4 10             	add    $0x10,%esp
  8000e7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000ea:	5b                   	pop    %ebx
  8000eb:	5e                   	pop    %esi
  8000ec:	5d                   	pop    %ebp
  8000ed:	c3                   	ret    

008000ee <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ee:	55                   	push   %ebp
  8000ef:	89 e5                	mov    %esp,%ebp
  8000f1:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000f4:	6a 00                	push   $0x0
  8000f6:	e8 aa 09 00 00       	call   800aa5 <sys_env_destroy>
}
  8000fb:	83 c4 10             	add    $0x10,%esp
  8000fe:	c9                   	leave  
  8000ff:	c3                   	ret    

00800100 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800100:	55                   	push   %ebp
  800101:	89 e5                	mov    %esp,%ebp
  800103:	53                   	push   %ebx
  800104:	83 ec 04             	sub    $0x4,%esp
  800107:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80010a:	8b 13                	mov    (%ebx),%edx
  80010c:	8d 42 01             	lea    0x1(%edx),%eax
  80010f:	89 03                	mov    %eax,(%ebx)
  800111:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800114:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256 - 1) {
  800118:	3d ff 00 00 00       	cmp    $0xff,%eax
  80011d:	74 09                	je     800128 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80011f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800123:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800126:	c9                   	leave  
  800127:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800128:	83 ec 08             	sub    $0x8,%esp
  80012b:	68 ff 00 00 00       	push   $0xff
  800130:	8d 43 08             	lea    0x8(%ebx),%eax
  800133:	50                   	push   %eax
  800134:	e8 22 09 00 00       	call   800a5b <sys_cputs>
		b->idx = 0;
  800139:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80013f:	83 c4 10             	add    $0x10,%esp
  800142:	eb db                	jmp    80011f <putch+0x1f>

00800144 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80014d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800154:	00 00 00 
	b.cnt = 0;
  800157:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80015e:	00 00 00 
	vprintfmt((void *) putch, &b, fmt, ap);
  800161:	ff 75 0c             	push   0xc(%ebp)
  800164:	ff 75 08             	push   0x8(%ebp)
  800167:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80016d:	50                   	push   %eax
  80016e:	68 00 01 80 00       	push   $0x800100
  800173:	e8 74 01 00 00       	call   8002ec <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800178:	83 c4 08             	add    $0x8,%esp
  80017b:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800181:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800187:	50                   	push   %eax
  800188:	e8 ce 08 00 00       	call   800a5b <sys_cputs>

	return b.cnt;
}
  80018d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800193:	c9                   	leave  
  800194:	c3                   	ret    

00800195 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800195:	55                   	push   %ebp
  800196:	89 e5                	mov    %esp,%ebp
  800198:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80019b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80019e:	50                   	push   %eax
  80019f:	ff 75 08             	push   0x8(%ebp)
  8001a2:	e8 9d ff ff ff       	call   800144 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a7:	c9                   	leave  
  8001a8:	c3                   	ret    

008001a9 <printnum>:
         void *putdat,
         unsigned long long num,
         unsigned base,
         int width,
         int padc)
{
  8001a9:	55                   	push   %ebp
  8001aa:	89 e5                	mov    %esp,%ebp
  8001ac:	57                   	push   %edi
  8001ad:	56                   	push   %esi
  8001ae:	53                   	push   %ebx
  8001af:	83 ec 1c             	sub    $0x1c,%esp
  8001b2:	89 c7                	mov    %eax,%edi
  8001b4:	89 d6                	mov    %edx,%esi
  8001b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001bc:	89 d1                	mov    %edx,%ecx
  8001be:	89 c2                	mov    %eax,%edx
  8001c0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001c3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001c6:	8b 45 10             	mov    0x10(%ebp),%eax
  8001c9:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001cc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001cf:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001d6:	39 c2                	cmp    %eax,%edx
  8001d8:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001db:	72 3e                	jb     80021b <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001dd:	83 ec 0c             	sub    $0xc,%esp
  8001e0:	ff 75 18             	push   0x18(%ebp)
  8001e3:	83 eb 01             	sub    $0x1,%ebx
  8001e6:	53                   	push   %ebx
  8001e7:	50                   	push   %eax
  8001e8:	83 ec 08             	sub    $0x8,%esp
  8001eb:	ff 75 e4             	push   -0x1c(%ebp)
  8001ee:	ff 75 e0             	push   -0x20(%ebp)
  8001f1:	ff 75 dc             	push   -0x24(%ebp)
  8001f4:	ff 75 d8             	push   -0x28(%ebp)
  8001f7:	e8 a4 0b 00 00       	call   800da0 <__udivdi3>
  8001fc:	83 c4 18             	add    $0x18,%esp
  8001ff:	52                   	push   %edx
  800200:	50                   	push   %eax
  800201:	89 f2                	mov    %esi,%edx
  800203:	89 f8                	mov    %edi,%eax
  800205:	e8 9f ff ff ff       	call   8001a9 <printnum>
  80020a:	83 c4 20             	add    $0x20,%esp
  80020d:	eb 13                	jmp    800222 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80020f:	83 ec 08             	sub    $0x8,%esp
  800212:	56                   	push   %esi
  800213:	ff 75 18             	push   0x18(%ebp)
  800216:	ff d7                	call   *%edi
  800218:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80021b:	83 eb 01             	sub    $0x1,%ebx
  80021e:	85 db                	test   %ebx,%ebx
  800220:	7f ed                	jg     80020f <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800222:	83 ec 08             	sub    $0x8,%esp
  800225:	56                   	push   %esi
  800226:	83 ec 04             	sub    $0x4,%esp
  800229:	ff 75 e4             	push   -0x1c(%ebp)
  80022c:	ff 75 e0             	push   -0x20(%ebp)
  80022f:	ff 75 dc             	push   -0x24(%ebp)
  800232:	ff 75 d8             	push   -0x28(%ebp)
  800235:	e8 86 0c 00 00       	call   800ec0 <__umoddi3>
  80023a:	83 c4 14             	add    $0x14,%esp
  80023d:	0f be 80 12 10 80 00 	movsbl 0x801012(%eax),%eax
  800244:	50                   	push   %eax
  800245:	ff d7                	call   *%edi
}
  800247:	83 c4 10             	add    $0x10,%esp
  80024a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024d:	5b                   	pop    %ebx
  80024e:	5e                   	pop    %esi
  80024f:	5f                   	pop    %edi
  800250:	5d                   	pop    %ebp
  800251:	c3                   	ret    

00800252 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800252:	83 fa 01             	cmp    $0x1,%edx
  800255:	7f 13                	jg     80026a <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800257:	85 d2                	test   %edx,%edx
  800259:	74 1c                	je     800277 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  80025b:	8b 10                	mov    (%eax),%edx
  80025d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800260:	89 08                	mov    %ecx,(%eax)
  800262:	8b 02                	mov    (%edx),%eax
  800264:	ba 00 00 00 00       	mov    $0x0,%edx
  800269:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  80026a:	8b 10                	mov    (%eax),%edx
  80026c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80026f:	89 08                	mov    %ecx,(%eax)
  800271:	8b 02                	mov    (%edx),%eax
  800273:	8b 52 04             	mov    0x4(%edx),%edx
  800276:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  800277:	8b 10                	mov    (%eax),%edx
  800279:	8d 4a 04             	lea    0x4(%edx),%ecx
  80027c:	89 08                	mov    %ecx,(%eax)
  80027e:	8b 02                	mov    (%edx),%eax
  800280:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800285:	c3                   	ret    

00800286 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800286:	83 fa 01             	cmp    $0x1,%edx
  800289:	7f 0f                	jg     80029a <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  80028b:	85 d2                	test   %edx,%edx
  80028d:	74 18                	je     8002a7 <getint+0x21>
		return va_arg(*ap, long);
  80028f:	8b 10                	mov    (%eax),%edx
  800291:	8d 4a 04             	lea    0x4(%edx),%ecx
  800294:	89 08                	mov    %ecx,(%eax)
  800296:	8b 02                	mov    (%edx),%eax
  800298:	99                   	cltd   
  800299:	c3                   	ret    
		return va_arg(*ap, long long);
  80029a:	8b 10                	mov    (%eax),%edx
  80029c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80029f:	89 08                	mov    %ecx,(%eax)
  8002a1:	8b 02                	mov    (%edx),%eax
  8002a3:	8b 52 04             	mov    0x4(%edx),%edx
  8002a6:	c3                   	ret    
	else
		return va_arg(*ap, int);
  8002a7:	8b 10                	mov    (%eax),%edx
  8002a9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ac:	89 08                	mov    %ecx,(%eax)
  8002ae:	8b 02                	mov    (%edx),%eax
  8002b0:	99                   	cltd   
}
  8002b1:	c3                   	ret    

008002b2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b2:	55                   	push   %ebp
  8002b3:	89 e5                	mov    %esp,%ebp
  8002b5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002bc:	8b 10                	mov    (%eax),%edx
  8002be:	3b 50 04             	cmp    0x4(%eax),%edx
  8002c1:	73 0a                	jae    8002cd <sprintputch+0x1b>
		*b->buf++ = ch;
  8002c3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002c6:	89 08                	mov    %ecx,(%eax)
  8002c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002cb:	88 02                	mov    %al,(%edx)
}
  8002cd:	5d                   	pop    %ebp
  8002ce:	c3                   	ret    

008002cf <printfmt>:
{
  8002cf:	55                   	push   %ebp
  8002d0:	89 e5                	mov    %esp,%ebp
  8002d2:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002d5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002d8:	50                   	push   %eax
  8002d9:	ff 75 10             	push   0x10(%ebp)
  8002dc:	ff 75 0c             	push   0xc(%ebp)
  8002df:	ff 75 08             	push   0x8(%ebp)
  8002e2:	e8 05 00 00 00       	call   8002ec <vprintfmt>
}
  8002e7:	83 c4 10             	add    $0x10,%esp
  8002ea:	c9                   	leave  
  8002eb:	c3                   	ret    

008002ec <vprintfmt>:
{
  8002ec:	55                   	push   %ebp
  8002ed:	89 e5                	mov    %esp,%ebp
  8002ef:	57                   	push   %edi
  8002f0:	56                   	push   %esi
  8002f1:	53                   	push   %ebx
  8002f2:	83 ec 2c             	sub    $0x2c,%esp
  8002f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002f8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8002fb:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002fe:	eb 0a                	jmp    80030a <vprintfmt+0x1e>
			putch(ch, putdat);
  800300:	83 ec 08             	sub    $0x8,%esp
  800303:	56                   	push   %esi
  800304:	50                   	push   %eax
  800305:	ff d3                	call   *%ebx
  800307:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80030a:	83 c7 01             	add    $0x1,%edi
  80030d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800311:	83 f8 25             	cmp    $0x25,%eax
  800314:	74 0c                	je     800322 <vprintfmt+0x36>
			if (ch == '\0')
  800316:	85 c0                	test   %eax,%eax
  800318:	75 e6                	jne    800300 <vprintfmt+0x14>
}
  80031a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80031d:	5b                   	pop    %ebx
  80031e:	5e                   	pop    %esi
  80031f:	5f                   	pop    %edi
  800320:	5d                   	pop    %ebp
  800321:	c3                   	ret    
		padc = ' ';
  800322:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
		altflag = 0;
  800326:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80032d:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800334:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80033b:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800340:	8d 47 01             	lea    0x1(%edi),%eax
  800343:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800346:	0f b6 17             	movzbl (%edi),%edx
  800349:	8d 42 dd             	lea    -0x23(%edx),%eax
  80034c:	3c 55                	cmp    $0x55,%al
  80034e:	0f 87 b7 02 00 00    	ja     80060b <vprintfmt+0x31f>
  800354:	0f b6 c0             	movzbl %al,%eax
  800357:	ff 24 85 e0 10 80 00 	jmp    *0x8010e0(,%eax,4)
  80035e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800361:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800365:	eb d9                	jmp    800340 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800367:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80036a:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  80036e:	eb d0                	jmp    800340 <vprintfmt+0x54>
  800370:	0f b6 d2             	movzbl %dl,%edx
  800373:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0;; ++fmt) {
  800376:	b8 00 00 00 00       	mov    $0x0,%eax
  80037b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80037e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800381:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800385:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800388:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80038b:	83 f9 09             	cmp    $0x9,%ecx
  80038e:	77 52                	ja     8003e2 <vprintfmt+0xf6>
			for (precision = 0;; ++fmt) {
  800390:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800393:	eb e9                	jmp    80037e <vprintfmt+0x92>
			precision = va_arg(ap, int);
  800395:	8b 45 14             	mov    0x14(%ebp),%eax
  800398:	8d 50 04             	lea    0x4(%eax),%edx
  80039b:	89 55 14             	mov    %edx,0x14(%ebp)
  80039e:	8b 00                	mov    (%eax),%eax
  8003a0:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003a6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003aa:	79 94                	jns    800340 <vprintfmt+0x54>
				width = precision, precision = -1;
  8003ac:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003af:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003b2:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003b9:	eb 85                	jmp    800340 <vprintfmt+0x54>
  8003bb:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003be:	85 d2                	test   %edx,%edx
  8003c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c5:	0f 49 c2             	cmovns %edx,%eax
  8003c8:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003ce:	e9 6d ff ff ff       	jmp    800340 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8003d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003d6:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003dd:	e9 5e ff ff ff       	jmp    800340 <vprintfmt+0x54>
  8003e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003e5:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003e8:	eb bc                	jmp    8003a6 <vprintfmt+0xba>
			lflag++;
  8003ea:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003f0:	e9 4b ff ff ff       	jmp    800340 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8003f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f8:	8d 50 04             	lea    0x4(%eax),%edx
  8003fb:	89 55 14             	mov    %edx,0x14(%ebp)
  8003fe:	83 ec 08             	sub    $0x8,%esp
  800401:	56                   	push   %esi
  800402:	ff 30                	push   (%eax)
  800404:	ff d3                	call   *%ebx
			break;
  800406:	83 c4 10             	add    $0x10,%esp
  800409:	e9 94 01 00 00       	jmp    8005a2 <vprintfmt+0x2b6>
			err = va_arg(ap, int);
  80040e:	8b 45 14             	mov    0x14(%ebp),%eax
  800411:	8d 50 04             	lea    0x4(%eax),%edx
  800414:	89 55 14             	mov    %edx,0x14(%ebp)
  800417:	8b 10                	mov    (%eax),%edx
  800419:	89 d0                	mov    %edx,%eax
  80041b:	f7 d8                	neg    %eax
  80041d:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800420:	83 f8 08             	cmp    $0x8,%eax
  800423:	7f 20                	jg     800445 <vprintfmt+0x159>
  800425:	8b 14 85 40 12 80 00 	mov    0x801240(,%eax,4),%edx
  80042c:	85 d2                	test   %edx,%edx
  80042e:	74 15                	je     800445 <vprintfmt+0x159>
				printfmt(putch, putdat, "%s", p);
  800430:	52                   	push   %edx
  800431:	68 33 10 80 00       	push   $0x801033
  800436:	56                   	push   %esi
  800437:	53                   	push   %ebx
  800438:	e8 92 fe ff ff       	call   8002cf <printfmt>
  80043d:	83 c4 10             	add    $0x10,%esp
  800440:	e9 5d 01 00 00       	jmp    8005a2 <vprintfmt+0x2b6>
				printfmt(putch, putdat, "error %d", err);
  800445:	50                   	push   %eax
  800446:	68 2a 10 80 00       	push   $0x80102a
  80044b:	56                   	push   %esi
  80044c:	53                   	push   %ebx
  80044d:	e8 7d fe ff ff       	call   8002cf <printfmt>
  800452:	83 c4 10             	add    $0x10,%esp
  800455:	e9 48 01 00 00       	jmp    8005a2 <vprintfmt+0x2b6>
			if ((p = va_arg(ap, char *)) == NULL)
  80045a:	8b 45 14             	mov    0x14(%ebp),%eax
  80045d:	8d 50 04             	lea    0x4(%eax),%edx
  800460:	89 55 14             	mov    %edx,0x14(%ebp)
  800463:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800465:	85 ff                	test   %edi,%edi
  800467:	b8 23 10 80 00       	mov    $0x801023,%eax
  80046c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80046f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800473:	7e 06                	jle    80047b <vprintfmt+0x18f>
  800475:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  800479:	75 0a                	jne    800485 <vprintfmt+0x199>
  80047b:	89 f8                	mov    %edi,%eax
  80047d:	03 45 e0             	add    -0x20(%ebp),%eax
  800480:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800483:	eb 59                	jmp    8004de <vprintfmt+0x1f2>
				for (width -= strnlen(p, precision); width > 0;
  800485:	83 ec 08             	sub    $0x8,%esp
  800488:	ff 75 d8             	push   -0x28(%ebp)
  80048b:	57                   	push   %edi
  80048c:	e8 1a 02 00 00       	call   8006ab <strnlen>
  800491:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800494:	29 c1                	sub    %eax,%ecx
  800496:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800499:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80049c:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  8004a0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a3:	89 7d d0             	mov    %edi,-0x30(%ebp)
  8004a6:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0;
  8004a8:	eb 0f                	jmp    8004b9 <vprintfmt+0x1cd>
					putch(padc, putdat);
  8004aa:	83 ec 08             	sub    $0x8,%esp
  8004ad:	56                   	push   %esi
  8004ae:	ff 75 e0             	push   -0x20(%ebp)
  8004b1:	ff d3                	call   *%ebx
				     width--)
  8004b3:	83 ef 01             	sub    $0x1,%edi
  8004b6:	83 c4 10             	add    $0x10,%esp
				for (width -= strnlen(p, precision); width > 0;
  8004b9:	85 ff                	test   %edi,%edi
  8004bb:	7f ed                	jg     8004aa <vprintfmt+0x1be>
  8004bd:	8b 7d d0             	mov    -0x30(%ebp),%edi
  8004c0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004c3:	85 c9                	test   %ecx,%ecx
  8004c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ca:	0f 49 c1             	cmovns %ecx,%eax
  8004cd:	29 c1                	sub    %eax,%ecx
  8004cf:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8004d2:	eb a7                	jmp    80047b <vprintfmt+0x18f>
					putch(ch, putdat);
  8004d4:	83 ec 08             	sub    $0x8,%esp
  8004d7:	56                   	push   %esi
  8004d8:	52                   	push   %edx
  8004d9:	ff d3                	call   *%ebx
  8004db:	83 c4 10             	add    $0x10,%esp
  8004de:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004e1:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' &&
  8004e3:	83 c7 01             	add    $0x1,%edi
  8004e6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004ea:	0f be d0             	movsbl %al,%edx
  8004ed:	85 d2                	test   %edx,%edx
  8004ef:	74 42                	je     800533 <vprintfmt+0x247>
  8004f1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004f5:	78 06                	js     8004fd <vprintfmt+0x211>
			       (precision < 0 || --precision >= 0);
  8004f7:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004fb:	78 1e                	js     80051b <vprintfmt+0x22f>
				if (altflag && (ch < ' ' || ch > '~'))
  8004fd:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800501:	74 d1                	je     8004d4 <vprintfmt+0x1e8>
  800503:	0f be c0             	movsbl %al,%eax
  800506:	83 e8 20             	sub    $0x20,%eax
  800509:	83 f8 5e             	cmp    $0x5e,%eax
  80050c:	76 c6                	jbe    8004d4 <vprintfmt+0x1e8>
					putch('?', putdat);
  80050e:	83 ec 08             	sub    $0x8,%esp
  800511:	56                   	push   %esi
  800512:	6a 3f                	push   $0x3f
  800514:	ff d3                	call   *%ebx
  800516:	83 c4 10             	add    $0x10,%esp
  800519:	eb c3                	jmp    8004de <vprintfmt+0x1f2>
  80051b:	89 cf                	mov    %ecx,%edi
  80051d:	eb 0e                	jmp    80052d <vprintfmt+0x241>
				putch(' ', putdat);
  80051f:	83 ec 08             	sub    $0x8,%esp
  800522:	56                   	push   %esi
  800523:	6a 20                	push   $0x20
  800525:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  800527:	83 ef 01             	sub    $0x1,%edi
  80052a:	83 c4 10             	add    $0x10,%esp
  80052d:	85 ff                	test   %edi,%edi
  80052f:	7f ee                	jg     80051f <vprintfmt+0x233>
  800531:	eb 6f                	jmp    8005a2 <vprintfmt+0x2b6>
  800533:	89 cf                	mov    %ecx,%edi
  800535:	eb f6                	jmp    80052d <vprintfmt+0x241>
			num = getint(&ap, lflag);
  800537:	89 ca                	mov    %ecx,%edx
  800539:	8d 45 14             	lea    0x14(%ebp),%eax
  80053c:	e8 45 fd ff ff       	call   800286 <getint>
  800541:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800544:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800547:	85 d2                	test   %edx,%edx
  800549:	78 0b                	js     800556 <vprintfmt+0x26a>
			num = getint(&ap, lflag);
  80054b:	89 d1                	mov    %edx,%ecx
  80054d:	89 c2                	mov    %eax,%edx
			base = 10;
  80054f:	bf 0a 00 00 00       	mov    $0xa,%edi
  800554:	eb 32                	jmp    800588 <vprintfmt+0x29c>
				putch('-', putdat);
  800556:	83 ec 08             	sub    $0x8,%esp
  800559:	56                   	push   %esi
  80055a:	6a 2d                	push   $0x2d
  80055c:	ff d3                	call   *%ebx
				num = -(long long) num;
  80055e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800561:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800564:	f7 da                	neg    %edx
  800566:	83 d1 00             	adc    $0x0,%ecx
  800569:	f7 d9                	neg    %ecx
  80056b:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80056e:	bf 0a 00 00 00       	mov    $0xa,%edi
  800573:	eb 13                	jmp    800588 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  800575:	89 ca                	mov    %ecx,%edx
  800577:	8d 45 14             	lea    0x14(%ebp),%eax
  80057a:	e8 d3 fc ff ff       	call   800252 <getuint>
  80057f:	89 d1                	mov    %edx,%ecx
  800581:	89 c2                	mov    %eax,%edx
			base = 10;
  800583:	bf 0a 00 00 00       	mov    $0xa,%edi
			printnum(putch, putdat, num, base, width, padc);
  800588:	83 ec 0c             	sub    $0xc,%esp
  80058b:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  80058f:	50                   	push   %eax
  800590:	ff 75 e0             	push   -0x20(%ebp)
  800593:	57                   	push   %edi
  800594:	51                   	push   %ecx
  800595:	52                   	push   %edx
  800596:	89 f2                	mov    %esi,%edx
  800598:	89 d8                	mov    %ebx,%eax
  80059a:	e8 0a fc ff ff       	call   8001a9 <printnum>
			break;
  80059f:	83 c4 20             	add    $0x20,%esp
{
  8005a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005a5:	e9 60 fd ff ff       	jmp    80030a <vprintfmt+0x1e>
			num = getuint(&ap, lflag);
  8005aa:	89 ca                	mov    %ecx,%edx
  8005ac:	8d 45 14             	lea    0x14(%ebp),%eax
  8005af:	e8 9e fc ff ff       	call   800252 <getuint>
  8005b4:	89 d1                	mov    %edx,%ecx
  8005b6:	89 c2                	mov    %eax,%edx
			base = 8;
  8005b8:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  8005bd:	eb c9                	jmp    800588 <vprintfmt+0x29c>
			putch('0', putdat);
  8005bf:	83 ec 08             	sub    $0x8,%esp
  8005c2:	56                   	push   %esi
  8005c3:	6a 30                	push   $0x30
  8005c5:	ff d3                	call   *%ebx
			putch('x', putdat);
  8005c7:	83 c4 08             	add    $0x8,%esp
  8005ca:	56                   	push   %esi
  8005cb:	6a 78                	push   $0x78
  8005cd:	ff d3                	call   *%ebx
			num = (unsigned long long) (uintptr_t) va_arg(ap, void *);
  8005cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d2:	8d 50 04             	lea    0x4(%eax),%edx
  8005d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d8:	8b 10                	mov    (%eax),%edx
  8005da:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8005df:	83 c4 10             	add    $0x10,%esp
			base = 16;
  8005e2:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  8005e7:	eb 9f                	jmp    800588 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  8005e9:	89 ca                	mov    %ecx,%edx
  8005eb:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ee:	e8 5f fc ff ff       	call   800252 <getuint>
  8005f3:	89 d1                	mov    %edx,%ecx
  8005f5:	89 c2                	mov    %eax,%edx
			base = 16;
  8005f7:	bf 10 00 00 00       	mov    $0x10,%edi
  8005fc:	eb 8a                	jmp    800588 <vprintfmt+0x29c>
			putch(ch, putdat);
  8005fe:	83 ec 08             	sub    $0x8,%esp
  800601:	56                   	push   %esi
  800602:	6a 25                	push   $0x25
  800604:	ff d3                	call   *%ebx
			break;
  800606:	83 c4 10             	add    $0x10,%esp
  800609:	eb 97                	jmp    8005a2 <vprintfmt+0x2b6>
			putch('%', putdat);
  80060b:	83 ec 08             	sub    $0x8,%esp
  80060e:	56                   	push   %esi
  80060f:	6a 25                	push   $0x25
  800611:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  800613:	83 c4 10             	add    $0x10,%esp
  800616:	89 f8                	mov    %edi,%eax
  800618:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80061c:	74 05                	je     800623 <vprintfmt+0x337>
  80061e:	83 e8 01             	sub    $0x1,%eax
  800621:	eb f5                	jmp    800618 <vprintfmt+0x32c>
  800623:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800626:	e9 77 ff ff ff       	jmp    8005a2 <vprintfmt+0x2b6>

0080062b <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80062b:	55                   	push   %ebp
  80062c:	89 e5                	mov    %esp,%ebp
  80062e:	83 ec 18             	sub    $0x18,%esp
  800631:	8b 45 08             	mov    0x8(%ebp),%eax
  800634:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = { buf, buf + n - 1, 0 };
  800637:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80063a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80063e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800641:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800648:	85 c0                	test   %eax,%eax
  80064a:	74 26                	je     800672 <vsnprintf+0x47>
  80064c:	85 d2                	test   %edx,%edx
  80064e:	7e 22                	jle    800672 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *) sprintputch, &b, fmt, ap);
  800650:	ff 75 14             	push   0x14(%ebp)
  800653:	ff 75 10             	push   0x10(%ebp)
  800656:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800659:	50                   	push   %eax
  80065a:	68 b2 02 80 00       	push   $0x8002b2
  80065f:	e8 88 fc ff ff       	call   8002ec <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800664:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800667:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80066a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80066d:	83 c4 10             	add    $0x10,%esp
}
  800670:	c9                   	leave  
  800671:	c3                   	ret    
		return -E_INVAL;
  800672:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800677:	eb f7                	jmp    800670 <vsnprintf+0x45>

00800679 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800679:	55                   	push   %ebp
  80067a:	89 e5                	mov    %esp,%ebp
  80067c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80067f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800682:	50                   	push   %eax
  800683:	ff 75 10             	push   0x10(%ebp)
  800686:	ff 75 0c             	push   0xc(%ebp)
  800689:	ff 75 08             	push   0x8(%ebp)
  80068c:	e8 9a ff ff ff       	call   80062b <vsnprintf>
	va_end(ap);

	return rc;
}
  800691:	c9                   	leave  
  800692:	c3                   	ret    

00800693 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800693:	55                   	push   %ebp
  800694:	89 e5                	mov    %esp,%ebp
  800696:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800699:	b8 00 00 00 00       	mov    $0x0,%eax
  80069e:	eb 03                	jmp    8006a3 <strlen+0x10>
		n++;
  8006a0:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8006a3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006a7:	75 f7                	jne    8006a0 <strlen+0xd>
	return n;
}
  8006a9:	5d                   	pop    %ebp
  8006aa:	c3                   	ret    

008006ab <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006ab:	55                   	push   %ebp
  8006ac:	89 e5                	mov    %esp,%ebp
  8006ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006b1:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8006b9:	eb 03                	jmp    8006be <strnlen+0x13>
		n++;
  8006bb:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006be:	39 d0                	cmp    %edx,%eax
  8006c0:	74 08                	je     8006ca <strnlen+0x1f>
  8006c2:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8006c6:	75 f3                	jne    8006bb <strnlen+0x10>
  8006c8:	89 c2                	mov    %eax,%edx
	return n;
}
  8006ca:	89 d0                	mov    %edx,%eax
  8006cc:	5d                   	pop    %ebp
  8006cd:	c3                   	ret    

008006ce <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006ce:	55                   	push   %ebp
  8006cf:	89 e5                	mov    %esp,%ebp
  8006d1:	53                   	push   %ebx
  8006d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8006dd:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8006e1:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8006e4:	83 c0 01             	add    $0x1,%eax
  8006e7:	84 d2                	test   %dl,%dl
  8006e9:	75 f2                	jne    8006dd <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8006eb:	89 c8                	mov    %ecx,%eax
  8006ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006f0:	c9                   	leave  
  8006f1:	c3                   	ret    

008006f2 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8006f2:	55                   	push   %ebp
  8006f3:	89 e5                	mov    %esp,%ebp
  8006f5:	53                   	push   %ebx
  8006f6:	83 ec 10             	sub    $0x10,%esp
  8006f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8006fc:	53                   	push   %ebx
  8006fd:	e8 91 ff ff ff       	call   800693 <strlen>
  800702:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800705:	ff 75 0c             	push   0xc(%ebp)
  800708:	01 d8                	add    %ebx,%eax
  80070a:	50                   	push   %eax
  80070b:	e8 be ff ff ff       	call   8006ce <strcpy>
	return dst;
}
  800710:	89 d8                	mov    %ebx,%eax
  800712:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800715:	c9                   	leave  
  800716:	c3                   	ret    

00800717 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size)
{
  800717:	55                   	push   %ebp
  800718:	89 e5                	mov    %esp,%ebp
  80071a:	56                   	push   %esi
  80071b:	53                   	push   %ebx
  80071c:	8b 75 08             	mov    0x8(%ebp),%esi
  80071f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800722:	89 f3                	mov    %esi,%ebx
  800724:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800727:	89 f0                	mov    %esi,%eax
  800729:	eb 0f                	jmp    80073a <strncpy+0x23>
		*dst++ = *src;
  80072b:	83 c0 01             	add    $0x1,%eax
  80072e:	0f b6 0a             	movzbl (%edx),%ecx
  800731:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800734:	80 f9 01             	cmp    $0x1,%cl
  800737:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  80073a:	39 d8                	cmp    %ebx,%eax
  80073c:	75 ed                	jne    80072b <strncpy+0x14>
	}
	return ret;
}
  80073e:	89 f0                	mov    %esi,%eax
  800740:	5b                   	pop    %ebx
  800741:	5e                   	pop    %esi
  800742:	5d                   	pop    %ebp
  800743:	c3                   	ret    

00800744 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800744:	55                   	push   %ebp
  800745:	89 e5                	mov    %esp,%ebp
  800747:	56                   	push   %esi
  800748:	53                   	push   %ebx
  800749:	8b 75 08             	mov    0x8(%ebp),%esi
  80074c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80074f:	8b 55 10             	mov    0x10(%ebp),%edx
  800752:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800754:	85 d2                	test   %edx,%edx
  800756:	74 21                	je     800779 <strlcpy+0x35>
  800758:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80075c:	89 f2                	mov    %esi,%edx
  80075e:	eb 09                	jmp    800769 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800760:	83 c1 01             	add    $0x1,%ecx
  800763:	83 c2 01             	add    $0x1,%edx
  800766:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800769:	39 c2                	cmp    %eax,%edx
  80076b:	74 09                	je     800776 <strlcpy+0x32>
  80076d:	0f b6 19             	movzbl (%ecx),%ebx
  800770:	84 db                	test   %bl,%bl
  800772:	75 ec                	jne    800760 <strlcpy+0x1c>
  800774:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800776:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800779:	29 f0                	sub    %esi,%eax
}
  80077b:	5b                   	pop    %ebx
  80077c:	5e                   	pop    %esi
  80077d:	5d                   	pop    %ebp
  80077e:	c3                   	ret    

0080077f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80077f:	55                   	push   %ebp
  800780:	89 e5                	mov    %esp,%ebp
  800782:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800785:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800788:	eb 06                	jmp    800790 <strcmp+0x11>
		p++, q++;
  80078a:	83 c1 01             	add    $0x1,%ecx
  80078d:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800790:	0f b6 01             	movzbl (%ecx),%eax
  800793:	84 c0                	test   %al,%al
  800795:	74 04                	je     80079b <strcmp+0x1c>
  800797:	3a 02                	cmp    (%edx),%al
  800799:	74 ef                	je     80078a <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80079b:	0f b6 c0             	movzbl %al,%eax
  80079e:	0f b6 12             	movzbl (%edx),%edx
  8007a1:	29 d0                	sub    %edx,%eax
}
  8007a3:	5d                   	pop    %ebp
  8007a4:	c3                   	ret    

008007a5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007a5:	55                   	push   %ebp
  8007a6:	89 e5                	mov    %esp,%ebp
  8007a8:	53                   	push   %ebx
  8007a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ac:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007af:	89 c3                	mov    %eax,%ebx
  8007b1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007b4:	eb 06                	jmp    8007bc <strncmp+0x17>
		n--, p++, q++;
  8007b6:	83 c0 01             	add    $0x1,%eax
  8007b9:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8007bc:	39 d8                	cmp    %ebx,%eax
  8007be:	74 18                	je     8007d8 <strncmp+0x33>
  8007c0:	0f b6 08             	movzbl (%eax),%ecx
  8007c3:	84 c9                	test   %cl,%cl
  8007c5:	74 04                	je     8007cb <strncmp+0x26>
  8007c7:	3a 0a                	cmp    (%edx),%cl
  8007c9:	74 eb                	je     8007b6 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007cb:	0f b6 00             	movzbl (%eax),%eax
  8007ce:	0f b6 12             	movzbl (%edx),%edx
  8007d1:	29 d0                	sub    %edx,%eax
}
  8007d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d6:	c9                   	leave  
  8007d7:	c3                   	ret    
		return 0;
  8007d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8007dd:	eb f4                	jmp    8007d3 <strncmp+0x2e>

008007df <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007df:	55                   	push   %ebp
  8007e0:	89 e5                	mov    %esp,%ebp
  8007e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007e9:	eb 03                	jmp    8007ee <strchr+0xf>
  8007eb:	83 c0 01             	add    $0x1,%eax
  8007ee:	0f b6 10             	movzbl (%eax),%edx
  8007f1:	84 d2                	test   %dl,%dl
  8007f3:	74 06                	je     8007fb <strchr+0x1c>
		if (*s == c)
  8007f5:	38 ca                	cmp    %cl,%dl
  8007f7:	75 f2                	jne    8007eb <strchr+0xc>
  8007f9:	eb 05                	jmp    800800 <strchr+0x21>
			return (char *) s;
	return 0;
  8007fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800800:	5d                   	pop    %ebp
  800801:	c3                   	ret    

00800802 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800802:	55                   	push   %ebp
  800803:	89 e5                	mov    %esp,%ebp
  800805:	8b 45 08             	mov    0x8(%ebp),%eax
  800808:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80080c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80080f:	38 ca                	cmp    %cl,%dl
  800811:	74 09                	je     80081c <strfind+0x1a>
  800813:	84 d2                	test   %dl,%dl
  800815:	74 05                	je     80081c <strfind+0x1a>
	for (; *s; s++)
  800817:	83 c0 01             	add    $0x1,%eax
  80081a:	eb f0                	jmp    80080c <strfind+0xa>
			break;
	return (char *) s;
}
  80081c:	5d                   	pop    %ebp
  80081d:	c3                   	ret    

0080081e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80081e:	55                   	push   %ebp
  80081f:	89 e5                	mov    %esp,%ebp
  800821:	57                   	push   %edi
  800822:	56                   	push   %esi
  800823:	53                   	push   %ebx
  800824:	8b 55 08             	mov    0x8(%ebp),%edx
  800827:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  80082a:	85 c9                	test   %ecx,%ecx
  80082c:	74 33                	je     800861 <memset+0x43>
		return v;
	if ((int) v % 4 == 0 && n % 4 == 0) {
  80082e:	89 d0                	mov    %edx,%eax
  800830:	09 c8                	or     %ecx,%eax
  800832:	a8 03                	test   $0x3,%al
  800834:	75 23                	jne    800859 <memset+0x3b>
		c &= 0xFF;
  800836:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  80083a:	89 d8                	mov    %ebx,%eax
  80083c:	c1 e0 08             	shl    $0x8,%eax
  80083f:	89 df                	mov    %ebx,%edi
  800841:	c1 e7 18             	shl    $0x18,%edi
  800844:	89 de                	mov    %ebx,%esi
  800846:	c1 e6 10             	shl    $0x10,%esi
  800849:	09 f7                	or     %esi,%edi
  80084b:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
		             : "=D"(p), "=c"(n)
		             : "D"(p), "a"(c), "c"(n / 4)
  80084d:	c1 e9 02             	shr    $0x2,%ecx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  800850:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800852:	89 d7                	mov    %edx,%edi
  800854:	fc                   	cld    
  800855:	f3 ab                	rep stos %eax,%es:(%edi)
  800857:	eb 08                	jmp    800861 <memset+0x43>
		             : "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800859:	89 d7                	mov    %edx,%edi
  80085b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80085e:	fc                   	cld    
  80085f:	f3 aa                	rep stos %al,%es:(%edi)
		             : "=D"(p), "=c"(n)
		             : "0"(p), "a"(c), "1"(n)
		             : "cc", "memory");
	return v;
}
  800861:	89 d0                	mov    %edx,%eax
  800863:	5b                   	pop    %ebx
  800864:	5e                   	pop    %esi
  800865:	5f                   	pop    %edi
  800866:	5d                   	pop    %ebp
  800867:	c3                   	ret    

00800868 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800868:	55                   	push   %ebp
  800869:	89 e5                	mov    %esp,%ebp
  80086b:	57                   	push   %edi
  80086c:	56                   	push   %esi
  80086d:	8b 45 08             	mov    0x8(%ebp),%eax
  800870:	8b 75 0c             	mov    0xc(%ebp),%esi
  800873:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800876:	39 c6                	cmp    %eax,%esi
  800878:	73 32                	jae    8008ac <memmove+0x44>
  80087a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80087d:	39 c2                	cmp    %eax,%edx
  80087f:	76 2b                	jbe    8008ac <memmove+0x44>
		s += n;
		d += n;
  800881:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  800884:	89 d6                	mov    %edx,%esi
  800886:	09 fe                	or     %edi,%esi
  800888:	09 ce                	or     %ecx,%esi
  80088a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800890:	75 0e                	jne    8008a0 <memmove+0x38>
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  800892:	83 ef 04             	sub    $0x4,%edi
			             "S"(s - 4),
  800895:	8d 72 fc             	lea    -0x4(%edx),%esi
			             "c"(n / 4)
  800898:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  80089b:	fd                   	std    
  80089c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80089e:	eb 09                	jmp    8008a9 <memmove+0x41>
			             : "cc", "memory");
		else
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  8008a0:	83 ef 01             	sub    $0x1,%edi
			             "S"(s - 1),
  8008a3:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  8008a6:	fd                   	std    
  8008a7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             "c"(n)
			             : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008a9:	fc                   	cld    
  8008aa:	eb 1a                	jmp    8008c6 <memmove+0x5e>
	} else {
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  8008ac:	89 f2                	mov    %esi,%edx
  8008ae:	09 c2                	or     %eax,%edx
  8008b0:	09 ca                	or     %ecx,%edx
  8008b2:	f6 c2 03             	test   $0x3,%dl
  8008b5:	75 0a                	jne    8008c1 <memmove+0x59>
			asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  8008b7:	c1 e9 02             	shr    $0x2,%ecx
  8008ba:	89 c7                	mov    %eax,%edi
  8008bc:	fc                   	cld    
  8008bd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008bf:	eb 05                	jmp    8008c6 <memmove+0x5e>
			             : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  8008c1:	89 c7                	mov    %eax,%edi
  8008c3:	fc                   	cld    
  8008c4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             : "cc", "memory");
	}
	return dst;
}
  8008c6:	5e                   	pop    %esi
  8008c7:	5f                   	pop    %edi
  8008c8:	5d                   	pop    %ebp
  8008c9:	c3                   	ret    

008008ca <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008ca:	55                   	push   %ebp
  8008cb:	89 e5                	mov    %esp,%ebp
  8008cd:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8008d0:	ff 75 10             	push   0x10(%ebp)
  8008d3:	ff 75 0c             	push   0xc(%ebp)
  8008d6:	ff 75 08             	push   0x8(%ebp)
  8008d9:	e8 8a ff ff ff       	call   800868 <memmove>
}
  8008de:	c9                   	leave  
  8008df:	c3                   	ret    

008008e0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	56                   	push   %esi
  8008e4:	53                   	push   %ebx
  8008e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008eb:	89 c6                	mov    %eax,%esi
  8008ed:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8008f0:	eb 06                	jmp    8008f8 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8008f2:	83 c0 01             	add    $0x1,%eax
  8008f5:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  8008f8:	39 f0                	cmp    %esi,%eax
  8008fa:	74 14                	je     800910 <memcmp+0x30>
		if (*s1 != *s2)
  8008fc:	0f b6 08             	movzbl (%eax),%ecx
  8008ff:	0f b6 1a             	movzbl (%edx),%ebx
  800902:	38 d9                	cmp    %bl,%cl
  800904:	74 ec                	je     8008f2 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800906:	0f b6 c1             	movzbl %cl,%eax
  800909:	0f b6 db             	movzbl %bl,%ebx
  80090c:	29 d8                	sub    %ebx,%eax
  80090e:	eb 05                	jmp    800915 <memcmp+0x35>
	}

	return 0;
  800910:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800915:	5b                   	pop    %ebx
  800916:	5e                   	pop    %esi
  800917:	5d                   	pop    %ebp
  800918:	c3                   	ret    

00800919 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800919:	55                   	push   %ebp
  80091a:	89 e5                	mov    %esp,%ebp
  80091c:	8b 45 08             	mov    0x8(%ebp),%eax
  80091f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800922:	89 c2                	mov    %eax,%edx
  800924:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800927:	eb 03                	jmp    80092c <memfind+0x13>
  800929:	83 c0 01             	add    $0x1,%eax
  80092c:	39 d0                	cmp    %edx,%eax
  80092e:	73 04                	jae    800934 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800930:	38 08                	cmp    %cl,(%eax)
  800932:	75 f5                	jne    800929 <memfind+0x10>
			break;
	return (void *) s;
}
  800934:	5d                   	pop    %ebp
  800935:	c3                   	ret    

00800936 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	57                   	push   %edi
  80093a:	56                   	push   %esi
  80093b:	53                   	push   %ebx
  80093c:	8b 55 08             	mov    0x8(%ebp),%edx
  80093f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800942:	eb 03                	jmp    800947 <strtol+0x11>
		s++;
  800944:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800947:	0f b6 02             	movzbl (%edx),%eax
  80094a:	3c 20                	cmp    $0x20,%al
  80094c:	74 f6                	je     800944 <strtol+0xe>
  80094e:	3c 09                	cmp    $0x9,%al
  800950:	74 f2                	je     800944 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800952:	3c 2b                	cmp    $0x2b,%al
  800954:	74 2a                	je     800980 <strtol+0x4a>
	int neg = 0;
  800956:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  80095b:	3c 2d                	cmp    $0x2d,%al
  80095d:	74 2b                	je     80098a <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80095f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800965:	75 0f                	jne    800976 <strtol+0x40>
  800967:	80 3a 30             	cmpb   $0x30,(%edx)
  80096a:	74 28                	je     800994 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80096c:	85 db                	test   %ebx,%ebx
  80096e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800973:	0f 44 d8             	cmove  %eax,%ebx
  800976:	b9 00 00 00 00       	mov    $0x0,%ecx
  80097b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80097e:	eb 46                	jmp    8009c6 <strtol+0x90>
		s++;
  800980:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800983:	bf 00 00 00 00       	mov    $0x0,%edi
  800988:	eb d5                	jmp    80095f <strtol+0x29>
		s++, neg = 1;
  80098a:	83 c2 01             	add    $0x1,%edx
  80098d:	bf 01 00 00 00       	mov    $0x1,%edi
  800992:	eb cb                	jmp    80095f <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800994:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800998:	74 0e                	je     8009a8 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  80099a:	85 db                	test   %ebx,%ebx
  80099c:	75 d8                	jne    800976 <strtol+0x40>
		s++, base = 8;
  80099e:	83 c2 01             	add    $0x1,%edx
  8009a1:	bb 08 00 00 00       	mov    $0x8,%ebx
  8009a6:	eb ce                	jmp    800976 <strtol+0x40>
		s += 2, base = 16;
  8009a8:	83 c2 02             	add    $0x2,%edx
  8009ab:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009b0:	eb c4                	jmp    800976 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  8009b2:	0f be c0             	movsbl %al,%eax
  8009b5:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8009b8:	3b 45 10             	cmp    0x10(%ebp),%eax
  8009bb:	7d 3a                	jge    8009f7 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  8009bd:	83 c2 01             	add    $0x1,%edx
  8009c0:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  8009c4:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  8009c6:	0f b6 02             	movzbl (%edx),%eax
  8009c9:	8d 70 d0             	lea    -0x30(%eax),%esi
  8009cc:	89 f3                	mov    %esi,%ebx
  8009ce:	80 fb 09             	cmp    $0x9,%bl
  8009d1:	76 df                	jbe    8009b2 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  8009d3:	8d 70 9f             	lea    -0x61(%eax),%esi
  8009d6:	89 f3                	mov    %esi,%ebx
  8009d8:	80 fb 19             	cmp    $0x19,%bl
  8009db:	77 08                	ja     8009e5 <strtol+0xaf>
			dig = *s - 'a' + 10;
  8009dd:	0f be c0             	movsbl %al,%eax
  8009e0:	83 e8 57             	sub    $0x57,%eax
  8009e3:	eb d3                	jmp    8009b8 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  8009e5:	8d 70 bf             	lea    -0x41(%eax),%esi
  8009e8:	89 f3                	mov    %esi,%ebx
  8009ea:	80 fb 19             	cmp    $0x19,%bl
  8009ed:	77 08                	ja     8009f7 <strtol+0xc1>
			dig = *s - 'A' + 10;
  8009ef:	0f be c0             	movsbl %al,%eax
  8009f2:	83 e8 37             	sub    $0x37,%eax
  8009f5:	eb c1                	jmp    8009b8 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  8009f7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8009fb:	74 05                	je     800a02 <strtol+0xcc>
		*endptr = (char *) s;
  8009fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a00:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800a02:	89 c8                	mov    %ecx,%eax
  800a04:	f7 d8                	neg    %eax
  800a06:	85 ff                	test   %edi,%edi
  800a08:	0f 45 c8             	cmovne %eax,%ecx
}
  800a0b:	89 c8                	mov    %ecx,%eax
  800a0d:	5b                   	pop    %ebx
  800a0e:	5e                   	pop    %esi
  800a0f:	5f                   	pop    %edi
  800a10:	5d                   	pop    %ebp
  800a11:	c3                   	ret    

00800a12 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a12:	55                   	push   %ebp
  800a13:	89 e5                	mov    %esp,%ebp
  800a15:	57                   	push   %edi
  800a16:	56                   	push   %esi
  800a17:	53                   	push   %ebx
  800a18:	83 ec 1c             	sub    $0x1c,%esp
  800a1b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a1e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800a21:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile(
  800a23:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a26:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a29:	8b 7d 10             	mov    0x10(%ebp),%edi
  800a2c:	8b 75 14             	mov    0x14(%ebp),%esi
  800a2f:	cd 30                	int    $0x30
	        "int %1\n"
	        : "=a"(ret)
	        : "i"(T_SYSCALL), "a"(num), "d"(a1), "c"(a2), "b"(a3), "D"(a4), "S"(a5)
	        : "cc", "memory");

	if (check && ret > 0)
  800a31:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a35:	74 04                	je     800a3b <syscall+0x29>
  800a37:	85 c0                	test   %eax,%eax
  800a39:	7f 08                	jg     800a43 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800a3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a3e:	5b                   	pop    %ebx
  800a3f:	5e                   	pop    %esi
  800a40:	5f                   	pop    %edi
  800a41:	5d                   	pop    %ebp
  800a42:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800a43:	83 ec 0c             	sub    $0xc,%esp
  800a46:	50                   	push   %eax
  800a47:	ff 75 e0             	push   -0x20(%ebp)
  800a4a:	68 64 12 80 00       	push   $0x801264
  800a4f:	6a 1e                	push   $0x1e
  800a51:	68 81 12 80 00       	push   $0x801281
  800a56:	e8 fa 02 00 00       	call   800d55 <_panic>

00800a5b <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t) s, len, 0, 0, 0);
  800a61:	6a 00                	push   $0x0
  800a63:	6a 00                	push   $0x0
  800a65:	6a 00                	push   $0x0
  800a67:	ff 75 0c             	push   0xc(%ebp)
  800a6a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a6d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a72:	b8 00 00 00 00       	mov    $0x0,%eax
  800a77:	e8 96 ff ff ff       	call   800a12 <syscall>
}
  800a7c:	83 c4 10             	add    $0x10,%esp
  800a7f:	c9                   	leave  
  800a80:	c3                   	ret    

00800a81 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a81:	55                   	push   %ebp
  800a82:	89 e5                	mov    %esp,%ebp
  800a84:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800a87:	6a 00                	push   $0x0
  800a89:	6a 00                	push   $0x0
  800a8b:	6a 00                	push   $0x0
  800a8d:	6a 00                	push   $0x0
  800a8f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a94:	ba 00 00 00 00       	mov    $0x0,%edx
  800a99:	b8 01 00 00 00       	mov    $0x1,%eax
  800a9e:	e8 6f ff ff ff       	call   800a12 <syscall>
}
  800aa3:	c9                   	leave  
  800aa4:	c3                   	ret    

00800aa5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aa5:	55                   	push   %ebp
  800aa6:	89 e5                	mov    %esp,%ebp
  800aa8:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800aab:	6a 00                	push   $0x0
  800aad:	6a 00                	push   $0x0
  800aaf:	6a 00                	push   $0x0
  800ab1:	6a 00                	push   $0x0
  800ab3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ab6:	ba 01 00 00 00       	mov    $0x1,%edx
  800abb:	b8 03 00 00 00       	mov    $0x3,%eax
  800ac0:	e8 4d ff ff ff       	call   800a12 <syscall>
}
  800ac5:	c9                   	leave  
  800ac6:	c3                   	ret    

00800ac7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ac7:	55                   	push   %ebp
  800ac8:	89 e5                	mov    %esp,%ebp
  800aca:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800acd:	6a 00                	push   $0x0
  800acf:	6a 00                	push   $0x0
  800ad1:	6a 00                	push   $0x0
  800ad3:	6a 00                	push   $0x0
  800ad5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ada:	ba 00 00 00 00       	mov    $0x0,%edx
  800adf:	b8 02 00 00 00       	mov    $0x2,%eax
  800ae4:	e8 29 ff ff ff       	call   800a12 <syscall>
}
  800ae9:	c9                   	leave  
  800aea:	c3                   	ret    

00800aeb <sys_yield>:

void
sys_yield(void)
{
  800aeb:	55                   	push   %ebp
  800aec:	89 e5                	mov    %esp,%ebp
  800aee:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800af1:	6a 00                	push   $0x0
  800af3:	6a 00                	push   $0x0
  800af5:	6a 00                	push   $0x0
  800af7:	6a 00                	push   $0x0
  800af9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800afe:	ba 00 00 00 00       	mov    $0x0,%edx
  800b03:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b08:	e8 05 ff ff ff       	call   800a12 <syscall>
}
  800b0d:	83 c4 10             	add    $0x10,%esp
  800b10:	c9                   	leave  
  800b11:	c3                   	ret    

00800b12 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b12:	55                   	push   %ebp
  800b13:	89 e5                	mov    %esp,%ebp
  800b15:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800b18:	6a 00                	push   $0x0
  800b1a:	6a 00                	push   $0x0
  800b1c:	ff 75 10             	push   0x10(%ebp)
  800b1f:	ff 75 0c             	push   0xc(%ebp)
  800b22:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b25:	ba 01 00 00 00       	mov    $0x1,%edx
  800b2a:	b8 04 00 00 00       	mov    $0x4,%eax
  800b2f:	e8 de fe ff ff       	call   800a12 <syscall>
}
  800b34:	c9                   	leave  
  800b35:	c3                   	ret    

00800b36 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b36:	55                   	push   %ebp
  800b37:	89 e5                	mov    %esp,%ebp
  800b39:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map,
  800b3c:	ff 75 18             	push   0x18(%ebp)
  800b3f:	ff 75 14             	push   0x14(%ebp)
  800b42:	ff 75 10             	push   0x10(%ebp)
  800b45:	ff 75 0c             	push   0xc(%ebp)
  800b48:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b4b:	ba 01 00 00 00       	mov    $0x1,%edx
  800b50:	b8 05 00 00 00       	mov    $0x5,%eax
  800b55:	e8 b8 fe ff ff       	call   800a12 <syscall>
	               srcenv,
	               (uint32_t) srcva,
	               dstenv,
	               (uint32_t) dstva,
	               perm);
}
  800b5a:	c9                   	leave  
  800b5b:	c3                   	ret    

00800b5c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800b62:	6a 00                	push   $0x0
  800b64:	6a 00                	push   $0x0
  800b66:	6a 00                	push   $0x0
  800b68:	ff 75 0c             	push   0xc(%ebp)
  800b6b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b6e:	ba 01 00 00 00       	mov    $0x1,%edx
  800b73:	b8 06 00 00 00       	mov    $0x6,%eax
  800b78:	e8 95 fe ff ff       	call   800a12 <syscall>
}
  800b7d:	c9                   	leave  
  800b7e:	c3                   	ret    

00800b7f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800b7f:	55                   	push   %ebp
  800b80:	89 e5                	mov    %esp,%ebp
  800b82:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800b85:	6a 00                	push   $0x0
  800b87:	6a 00                	push   $0x0
  800b89:	6a 00                	push   $0x0
  800b8b:	ff 75 0c             	push   0xc(%ebp)
  800b8e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b91:	ba 01 00 00 00       	mov    $0x1,%edx
  800b96:	b8 08 00 00 00       	mov    $0x8,%eax
  800b9b:	e8 72 fe ff ff       	call   800a12 <syscall>
}
  800ba0:	c9                   	leave  
  800ba1:	c3                   	ret    

00800ba2 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	83 ec 08             	sub    $0x8,%esp
	return syscall(
  800ba8:	6a 00                	push   $0x0
  800baa:	6a 00                	push   $0x0
  800bac:	6a 00                	push   $0x0
  800bae:	ff 75 0c             	push   0xc(%ebp)
  800bb1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bb4:	ba 01 00 00 00       	mov    $0x1,%edx
  800bb9:	b8 09 00 00 00       	mov    $0x9,%eax
  800bbe:	e8 4f fe ff ff       	call   800a12 <syscall>
	        SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800bc3:	c9                   	leave  
  800bc4:	c3                   	ret    

00800bc5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800bc5:	55                   	push   %ebp
  800bc6:	89 e5                	mov    %esp,%ebp
  800bc8:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800bcb:	6a 00                	push   $0x0
  800bcd:	ff 75 14             	push   0x14(%ebp)
  800bd0:	ff 75 10             	push   0x10(%ebp)
  800bd3:	ff 75 0c             	push   0xc(%ebp)
  800bd6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bd9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bde:	b8 0b 00 00 00       	mov    $0xb,%eax
  800be3:	e8 2a fe ff ff       	call   800a12 <syscall>
}
  800be8:	c9                   	leave  
  800be9:	c3                   	ret    

00800bea <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800bea:	55                   	push   %ebp
  800beb:	89 e5                	mov    %esp,%ebp
  800bed:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t) dstva, 0, 0, 0, 0);
  800bf0:	6a 00                	push   $0x0
  800bf2:	6a 00                	push   $0x0
  800bf4:	6a 00                	push   $0x0
  800bf6:	6a 00                	push   $0x0
  800bf8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bfb:	ba 01 00 00 00       	mov    $0x1,%edx
  800c00:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c05:	e8 08 fe ff ff       	call   800a12 <syscall>
}
  800c0a:	c9                   	leave  
  800c0b:	c3                   	ret    

00800c0c <sys_get_priority>:

// Get priority of the current process
int
sys_get_priority(void)
{
  800c0c:	55                   	push   %ebp
  800c0d:	89 e5                	mov    %esp,%ebp
  800c0f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_get_priority, 0, 0, 0, 0, 0, 0);
  800c12:	6a 00                	push   $0x0
  800c14:	6a 00                	push   $0x0
  800c16:	6a 00                	push   $0x0
  800c18:	6a 00                	push   $0x0
  800c1a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c1f:	ba 00 00 00 00       	mov    $0x0,%edx
  800c24:	b8 0d 00 00 00       	mov    $0xd,%eax
  800c29:	e8 e4 fd ff ff       	call   800a12 <syscall>
}
  800c2e:	c9                   	leave  
  800c2f:	c3                   	ret    

00800c30 <sys_set_priority>:

// Get priority of the current process
int
sys_set_priority(unsigned int priority)
{
  800c30:	55                   	push   %ebp
  800c31:	89 e5                	mov    %esp,%ebp
  800c33:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, (uint32_t) priority, 0, 0, 0, 0);
  800c36:	6a 00                	push   $0x0
  800c38:	6a 00                	push   $0x0
  800c3a:	6a 00                	push   $0x0
  800c3c:	6a 00                	push   $0x0
  800c3e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c41:	ba 00 00 00 00       	mov    $0x0,%edx
  800c46:	b8 0e 00 00 00       	mov    $0xe,%eax
  800c4b:	e8 c2 fd ff ff       	call   800a12 <syscall>
}
  800c50:	c9                   	leave  
  800c51:	c3                   	ret    

00800c52 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800c52:	55                   	push   %ebp
  800c53:	89 e5                	mov    %esp,%ebp
  800c55:	56                   	push   %esi
  800c56:	53                   	push   %ebx
  800c57:	8b 75 08             	mov    0x8(%ebp),%esi
  800c5a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int err = sys_ipc_recv(pg);
  800c5d:	83 ec 0c             	sub    $0xc,%esp
  800c60:	ff 75 0c             	push   0xc(%ebp)
  800c63:	e8 82 ff ff ff       	call   800bea <sys_ipc_recv>

	if (from_env_store)
  800c68:	83 c4 10             	add    $0x10,%esp
  800c6b:	85 f6                	test   %esi,%esi
  800c6d:	74 17                	je     800c86 <ipc_recv+0x34>
		*from_env_store = (!err) ? thisenv->env_ipc_from : 0;
  800c6f:	ba 00 00 00 00       	mov    $0x0,%edx
  800c74:	85 c0                	test   %eax,%eax
  800c76:	75 0c                	jne    800c84 <ipc_recv+0x32>
  800c78:	8b 15 04 20 80 00    	mov    0x802004,%edx
  800c7e:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
  800c84:	89 16                	mov    %edx,(%esi)

	if (perm_store)
  800c86:	85 db                	test   %ebx,%ebx
  800c88:	74 17                	je     800ca1 <ipc_recv+0x4f>
		*perm_store = (!err) ? thisenv->env_ipc_perm : 0;
  800c8a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c8f:	85 c0                	test   %eax,%eax
  800c91:	75 0c                	jne    800c9f <ipc_recv+0x4d>
  800c93:	8b 15 04 20 80 00    	mov    0x802004,%edx
  800c99:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  800c9f:	89 13                	mov    %edx,(%ebx)

	if (!err)
  800ca1:	85 c0                	test   %eax,%eax
  800ca3:	75 08                	jne    800cad <ipc_recv+0x5b>
		err = thisenv->env_ipc_value;
  800ca5:	a1 04 20 80 00       	mov    0x802004,%eax
  800caa:	8b 40 7c             	mov    0x7c(%eax),%eax

	return err;
}
  800cad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cb0:	5b                   	pop    %ebx
  800cb1:	5e                   	pop    %esi
  800cb2:	5d                   	pop    %ebp
  800cb3:	c3                   	ret    

00800cb4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800cb4:	55                   	push   %ebp
  800cb5:	89 e5                	mov    %esp,%ebp
  800cb7:	57                   	push   %edi
  800cb8:	56                   	push   %esi
  800cb9:	53                   	push   %ebx
  800cba:	83 ec 0c             	sub    $0xc,%esp
  800cbd:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cc0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc3:	8b 7d 14             	mov    0x14(%ebp),%edi
	if (!pg)
		pg = (void *) UTOP;
  800cc6:	85 db                	test   %ebx,%ebx
  800cc8:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  800ccd:	0f 44 d8             	cmove  %eax,%ebx
	int r = sys_ipc_try_send(to_env, val, pg, perm);
  800cd0:	57                   	push   %edi
  800cd1:	53                   	push   %ebx
  800cd2:	56                   	push   %esi
  800cd3:	ff 75 08             	push   0x8(%ebp)
  800cd6:	e8 ea fe ff ff       	call   800bc5 <sys_ipc_try_send>
	while (r == -E_IPC_NOT_RECV) {
  800cdb:	83 c4 10             	add    $0x10,%esp
  800cde:	eb 13                	jmp    800cf3 <ipc_send+0x3f>
		sys_yield();
  800ce0:	e8 06 fe ff ff       	call   800aeb <sys_yield>
		r = sys_ipc_try_send(to_env, val, pg, perm);
  800ce5:	57                   	push   %edi
  800ce6:	53                   	push   %ebx
  800ce7:	56                   	push   %esi
  800ce8:	ff 75 08             	push   0x8(%ebp)
  800ceb:	e8 d5 fe ff ff       	call   800bc5 <sys_ipc_try_send>
  800cf0:	83 c4 10             	add    $0x10,%esp
	while (r == -E_IPC_NOT_RECV) {
  800cf3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  800cf6:	74 e8                	je     800ce0 <ipc_send+0x2c>
	}

	if (r < 0)
  800cf8:	85 c0                	test   %eax,%eax
  800cfa:	78 08                	js     800d04 <ipc_send+0x50>
		panic("ipc_send: %e", r);
}
  800cfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cff:	5b                   	pop    %ebx
  800d00:	5e                   	pop    %esi
  800d01:	5f                   	pop    %edi
  800d02:	5d                   	pop    %ebp
  800d03:	c3                   	ret    
		panic("ipc_send: %e", r);
  800d04:	50                   	push   %eax
  800d05:	68 8f 12 80 00       	push   $0x80128f
  800d0a:	6a 3b                	push   $0x3b
  800d0c:	68 9c 12 80 00       	push   $0x80129c
  800d11:	e8 3f 00 00 00       	call   800d55 <_panic>

00800d16 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800d16:	55                   	push   %ebp
  800d17:	89 e5                	mov    %esp,%ebp
  800d19:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800d1c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800d21:	69 d0 88 00 00 00    	imul   $0x88,%eax,%edx
  800d27:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800d2d:	8b 52 50             	mov    0x50(%edx),%edx
  800d30:	39 ca                	cmp    %ecx,%edx
  800d32:	74 11                	je     800d45 <ipc_find_env+0x2f>
	for (i = 0; i < NENV; i++)
  800d34:	83 c0 01             	add    $0x1,%eax
  800d37:	3d 00 04 00 00       	cmp    $0x400,%eax
  800d3c:	75 e3                	jne    800d21 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  800d3e:	b8 00 00 00 00       	mov    $0x0,%eax
  800d43:	eb 0e                	jmp    800d53 <ipc_find_env+0x3d>
			return envs[i].env_id;
  800d45:	69 c0 88 00 00 00    	imul   $0x88,%eax,%eax
  800d4b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800d50:	8b 40 48             	mov    0x48(%eax),%eax
}
  800d53:	5d                   	pop    %ebp
  800d54:	c3                   	ret    

00800d55 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d55:	55                   	push   %ebp
  800d56:	89 e5                	mov    %esp,%ebp
  800d58:	56                   	push   %esi
  800d59:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800d5a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d5d:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800d63:	e8 5f fd ff ff       	call   800ac7 <sys_getenvid>
  800d68:	83 ec 0c             	sub    $0xc,%esp
  800d6b:	ff 75 0c             	push   0xc(%ebp)
  800d6e:	ff 75 08             	push   0x8(%ebp)
  800d71:	56                   	push   %esi
  800d72:	50                   	push   %eax
  800d73:	68 a8 12 80 00       	push   $0x8012a8
  800d78:	e8 18 f4 ff ff       	call   800195 <cprintf>
	        sys_getenvid(),
	        binaryname,
	        file,
	        line);
	vcprintf(fmt, ap);
  800d7d:	83 c4 18             	add    $0x18,%esp
  800d80:	53                   	push   %ebx
  800d81:	ff 75 10             	push   0x10(%ebp)
  800d84:	e8 bb f3 ff ff       	call   800144 <vcprintf>
	cprintf("\n");
  800d89:	c7 04 24 ef 0f 80 00 	movl   $0x800fef,(%esp)
  800d90:	e8 00 f4 ff ff       	call   800195 <cprintf>
  800d95:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d98:	cc                   	int3   
  800d99:	eb fd                	jmp    800d98 <_panic+0x43>
  800d9b:	66 90                	xchg   %ax,%ax
  800d9d:	66 90                	xchg   %ax,%ax
  800d9f:	90                   	nop

00800da0 <__udivdi3>:
  800da0:	f3 0f 1e fb          	endbr32 
  800da4:	55                   	push   %ebp
  800da5:	57                   	push   %edi
  800da6:	56                   	push   %esi
  800da7:	53                   	push   %ebx
  800da8:	83 ec 1c             	sub    $0x1c,%esp
  800dab:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800daf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800db3:	8b 74 24 34          	mov    0x34(%esp),%esi
  800db7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800dbb:	85 c0                	test   %eax,%eax
  800dbd:	75 19                	jne    800dd8 <__udivdi3+0x38>
  800dbf:	39 f3                	cmp    %esi,%ebx
  800dc1:	76 4d                	jbe    800e10 <__udivdi3+0x70>
  800dc3:	31 ff                	xor    %edi,%edi
  800dc5:	89 e8                	mov    %ebp,%eax
  800dc7:	89 f2                	mov    %esi,%edx
  800dc9:	f7 f3                	div    %ebx
  800dcb:	89 fa                	mov    %edi,%edx
  800dcd:	83 c4 1c             	add    $0x1c,%esp
  800dd0:	5b                   	pop    %ebx
  800dd1:	5e                   	pop    %esi
  800dd2:	5f                   	pop    %edi
  800dd3:	5d                   	pop    %ebp
  800dd4:	c3                   	ret    
  800dd5:	8d 76 00             	lea    0x0(%esi),%esi
  800dd8:	39 f0                	cmp    %esi,%eax
  800dda:	76 14                	jbe    800df0 <__udivdi3+0x50>
  800ddc:	31 ff                	xor    %edi,%edi
  800dde:	31 c0                	xor    %eax,%eax
  800de0:	89 fa                	mov    %edi,%edx
  800de2:	83 c4 1c             	add    $0x1c,%esp
  800de5:	5b                   	pop    %ebx
  800de6:	5e                   	pop    %esi
  800de7:	5f                   	pop    %edi
  800de8:	5d                   	pop    %ebp
  800de9:	c3                   	ret    
  800dea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800df0:	0f bd f8             	bsr    %eax,%edi
  800df3:	83 f7 1f             	xor    $0x1f,%edi
  800df6:	75 48                	jne    800e40 <__udivdi3+0xa0>
  800df8:	39 f0                	cmp    %esi,%eax
  800dfa:	72 06                	jb     800e02 <__udivdi3+0x62>
  800dfc:	31 c0                	xor    %eax,%eax
  800dfe:	39 eb                	cmp    %ebp,%ebx
  800e00:	77 de                	ja     800de0 <__udivdi3+0x40>
  800e02:	b8 01 00 00 00       	mov    $0x1,%eax
  800e07:	eb d7                	jmp    800de0 <__udivdi3+0x40>
  800e09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e10:	89 d9                	mov    %ebx,%ecx
  800e12:	85 db                	test   %ebx,%ebx
  800e14:	75 0b                	jne    800e21 <__udivdi3+0x81>
  800e16:	b8 01 00 00 00       	mov    $0x1,%eax
  800e1b:	31 d2                	xor    %edx,%edx
  800e1d:	f7 f3                	div    %ebx
  800e1f:	89 c1                	mov    %eax,%ecx
  800e21:	31 d2                	xor    %edx,%edx
  800e23:	89 f0                	mov    %esi,%eax
  800e25:	f7 f1                	div    %ecx
  800e27:	89 c6                	mov    %eax,%esi
  800e29:	89 e8                	mov    %ebp,%eax
  800e2b:	89 f7                	mov    %esi,%edi
  800e2d:	f7 f1                	div    %ecx
  800e2f:	89 fa                	mov    %edi,%edx
  800e31:	83 c4 1c             	add    $0x1c,%esp
  800e34:	5b                   	pop    %ebx
  800e35:	5e                   	pop    %esi
  800e36:	5f                   	pop    %edi
  800e37:	5d                   	pop    %ebp
  800e38:	c3                   	ret    
  800e39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e40:	89 f9                	mov    %edi,%ecx
  800e42:	ba 20 00 00 00       	mov    $0x20,%edx
  800e47:	29 fa                	sub    %edi,%edx
  800e49:	d3 e0                	shl    %cl,%eax
  800e4b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e4f:	89 d1                	mov    %edx,%ecx
  800e51:	89 d8                	mov    %ebx,%eax
  800e53:	d3 e8                	shr    %cl,%eax
  800e55:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800e59:	09 c1                	or     %eax,%ecx
  800e5b:	89 f0                	mov    %esi,%eax
  800e5d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e61:	89 f9                	mov    %edi,%ecx
  800e63:	d3 e3                	shl    %cl,%ebx
  800e65:	89 d1                	mov    %edx,%ecx
  800e67:	d3 e8                	shr    %cl,%eax
  800e69:	89 f9                	mov    %edi,%ecx
  800e6b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800e6f:	89 eb                	mov    %ebp,%ebx
  800e71:	d3 e6                	shl    %cl,%esi
  800e73:	89 d1                	mov    %edx,%ecx
  800e75:	d3 eb                	shr    %cl,%ebx
  800e77:	09 f3                	or     %esi,%ebx
  800e79:	89 c6                	mov    %eax,%esi
  800e7b:	89 f2                	mov    %esi,%edx
  800e7d:	89 d8                	mov    %ebx,%eax
  800e7f:	f7 74 24 08          	divl   0x8(%esp)
  800e83:	89 d6                	mov    %edx,%esi
  800e85:	89 c3                	mov    %eax,%ebx
  800e87:	f7 64 24 0c          	mull   0xc(%esp)
  800e8b:	39 d6                	cmp    %edx,%esi
  800e8d:	72 19                	jb     800ea8 <__udivdi3+0x108>
  800e8f:	89 f9                	mov    %edi,%ecx
  800e91:	d3 e5                	shl    %cl,%ebp
  800e93:	39 c5                	cmp    %eax,%ebp
  800e95:	73 04                	jae    800e9b <__udivdi3+0xfb>
  800e97:	39 d6                	cmp    %edx,%esi
  800e99:	74 0d                	je     800ea8 <__udivdi3+0x108>
  800e9b:	89 d8                	mov    %ebx,%eax
  800e9d:	31 ff                	xor    %edi,%edi
  800e9f:	e9 3c ff ff ff       	jmp    800de0 <__udivdi3+0x40>
  800ea4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ea8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800eab:	31 ff                	xor    %edi,%edi
  800ead:	e9 2e ff ff ff       	jmp    800de0 <__udivdi3+0x40>
  800eb2:	66 90                	xchg   %ax,%ax
  800eb4:	66 90                	xchg   %ax,%ax
  800eb6:	66 90                	xchg   %ax,%ax
  800eb8:	66 90                	xchg   %ax,%ax
  800eba:	66 90                	xchg   %ax,%ax
  800ebc:	66 90                	xchg   %ax,%ax
  800ebe:	66 90                	xchg   %ax,%ax

00800ec0 <__umoddi3>:
  800ec0:	f3 0f 1e fb          	endbr32 
  800ec4:	55                   	push   %ebp
  800ec5:	57                   	push   %edi
  800ec6:	56                   	push   %esi
  800ec7:	53                   	push   %ebx
  800ec8:	83 ec 1c             	sub    $0x1c,%esp
  800ecb:	8b 74 24 30          	mov    0x30(%esp),%esi
  800ecf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800ed3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  800ed7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  800edb:	89 f0                	mov    %esi,%eax
  800edd:	89 da                	mov    %ebx,%edx
  800edf:	85 ff                	test   %edi,%edi
  800ee1:	75 15                	jne    800ef8 <__umoddi3+0x38>
  800ee3:	39 dd                	cmp    %ebx,%ebp
  800ee5:	76 39                	jbe    800f20 <__umoddi3+0x60>
  800ee7:	f7 f5                	div    %ebp
  800ee9:	89 d0                	mov    %edx,%eax
  800eeb:	31 d2                	xor    %edx,%edx
  800eed:	83 c4 1c             	add    $0x1c,%esp
  800ef0:	5b                   	pop    %ebx
  800ef1:	5e                   	pop    %esi
  800ef2:	5f                   	pop    %edi
  800ef3:	5d                   	pop    %ebp
  800ef4:	c3                   	ret    
  800ef5:	8d 76 00             	lea    0x0(%esi),%esi
  800ef8:	39 df                	cmp    %ebx,%edi
  800efa:	77 f1                	ja     800eed <__umoddi3+0x2d>
  800efc:	0f bd cf             	bsr    %edi,%ecx
  800eff:	83 f1 1f             	xor    $0x1f,%ecx
  800f02:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800f06:	75 40                	jne    800f48 <__umoddi3+0x88>
  800f08:	39 df                	cmp    %ebx,%edi
  800f0a:	72 04                	jb     800f10 <__umoddi3+0x50>
  800f0c:	39 f5                	cmp    %esi,%ebp
  800f0e:	77 dd                	ja     800eed <__umoddi3+0x2d>
  800f10:	89 da                	mov    %ebx,%edx
  800f12:	89 f0                	mov    %esi,%eax
  800f14:	29 e8                	sub    %ebp,%eax
  800f16:	19 fa                	sbb    %edi,%edx
  800f18:	eb d3                	jmp    800eed <__umoddi3+0x2d>
  800f1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f20:	89 e9                	mov    %ebp,%ecx
  800f22:	85 ed                	test   %ebp,%ebp
  800f24:	75 0b                	jne    800f31 <__umoddi3+0x71>
  800f26:	b8 01 00 00 00       	mov    $0x1,%eax
  800f2b:	31 d2                	xor    %edx,%edx
  800f2d:	f7 f5                	div    %ebp
  800f2f:	89 c1                	mov    %eax,%ecx
  800f31:	89 d8                	mov    %ebx,%eax
  800f33:	31 d2                	xor    %edx,%edx
  800f35:	f7 f1                	div    %ecx
  800f37:	89 f0                	mov    %esi,%eax
  800f39:	f7 f1                	div    %ecx
  800f3b:	89 d0                	mov    %edx,%eax
  800f3d:	31 d2                	xor    %edx,%edx
  800f3f:	eb ac                	jmp    800eed <__umoddi3+0x2d>
  800f41:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f48:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f4c:	ba 20 00 00 00       	mov    $0x20,%edx
  800f51:	29 c2                	sub    %eax,%edx
  800f53:	89 c1                	mov    %eax,%ecx
  800f55:	89 e8                	mov    %ebp,%eax
  800f57:	d3 e7                	shl    %cl,%edi
  800f59:	89 d1                	mov    %edx,%ecx
  800f5b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f5f:	d3 e8                	shr    %cl,%eax
  800f61:	89 c1                	mov    %eax,%ecx
  800f63:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f67:	09 f9                	or     %edi,%ecx
  800f69:	89 df                	mov    %ebx,%edi
  800f6b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f6f:	89 c1                	mov    %eax,%ecx
  800f71:	d3 e5                	shl    %cl,%ebp
  800f73:	89 d1                	mov    %edx,%ecx
  800f75:	d3 ef                	shr    %cl,%edi
  800f77:	89 c1                	mov    %eax,%ecx
  800f79:	89 f0                	mov    %esi,%eax
  800f7b:	d3 e3                	shl    %cl,%ebx
  800f7d:	89 d1                	mov    %edx,%ecx
  800f7f:	89 fa                	mov    %edi,%edx
  800f81:	d3 e8                	shr    %cl,%eax
  800f83:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f88:	09 d8                	or     %ebx,%eax
  800f8a:	f7 74 24 08          	divl   0x8(%esp)
  800f8e:	89 d3                	mov    %edx,%ebx
  800f90:	d3 e6                	shl    %cl,%esi
  800f92:	f7 e5                	mul    %ebp
  800f94:	89 c7                	mov    %eax,%edi
  800f96:	89 d1                	mov    %edx,%ecx
  800f98:	39 d3                	cmp    %edx,%ebx
  800f9a:	72 06                	jb     800fa2 <__umoddi3+0xe2>
  800f9c:	75 0e                	jne    800fac <__umoddi3+0xec>
  800f9e:	39 c6                	cmp    %eax,%esi
  800fa0:	73 0a                	jae    800fac <__umoddi3+0xec>
  800fa2:	29 e8                	sub    %ebp,%eax
  800fa4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800fa8:	89 d1                	mov    %edx,%ecx
  800faa:	89 c7                	mov    %eax,%edi
  800fac:	89 f5                	mov    %esi,%ebp
  800fae:	8b 74 24 04          	mov    0x4(%esp),%esi
  800fb2:	29 fd                	sub    %edi,%ebp
  800fb4:	19 cb                	sbb    %ecx,%ebx
  800fb6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800fbb:	89 d8                	mov    %ebx,%eax
  800fbd:	d3 e0                	shl    %cl,%eax
  800fbf:	89 f1                	mov    %esi,%ecx
  800fc1:	d3 ed                	shr    %cl,%ebp
  800fc3:	d3 eb                	shr    %cl,%ebx
  800fc5:	09 e8                	or     %ebp,%eax
  800fc7:	89 da                	mov    %ebx,%edx
  800fc9:	83 c4 1c             	add    $0x1c,%esp
  800fcc:	5b                   	pop    %ebx
  800fcd:	5e                   	pop    %esi
  800fce:	5f                   	pop    %edi
  800fcf:	5d                   	pop    %ebp
  800fd0:	c3                   	ret    
