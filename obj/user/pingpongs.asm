
obj/user/pingpongs:     formato del fichero elf32-i386


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
  80002c:	e8 d2 00 00 00       	call   800103 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  80003c:	e8 bb 10 00 00       	call   8010fc <sfork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	75 74                	jne    8000bc <umain+0x89>
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
		ipc_send(who, 0, 0, 0);
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  800048:	83 ec 04             	sub    $0x4,%esp
  80004b:	6a 00                	push   $0x0
  80004d:	6a 00                	push   $0x0
  80004f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800052:	50                   	push   %eax
  800053:	e8 be 10 00 00       	call   801116 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n",
		        sys_getenvid(),
		        val,
		        who,
		        thisenv,
		        thisenv->env_id);
  800058:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  80005e:	8b 7b 48             	mov    0x48(%ebx),%edi
		cprintf("%x got %d from %x (thisenv is %p %x)\n",
  800061:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800064:	a1 04 20 80 00       	mov    0x802004,%eax
  800069:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80006c:	e8 b8 0a 00 00       	call   800b29 <sys_getenvid>
  800071:	83 c4 08             	add    $0x8,%esp
  800074:	57                   	push   %edi
  800075:	53                   	push   %ebx
  800076:	56                   	push   %esi
  800077:	ff 75 d4             	push   -0x2c(%ebp)
  80007a:	50                   	push   %eax
  80007b:	68 50 15 80 00       	push   $0x801550
  800080:	e8 72 01 00 00       	call   8001f7 <cprintf>
		if (val == 10)
  800085:	a1 04 20 80 00       	mov    0x802004,%eax
  80008a:	83 c4 20             	add    $0x20,%esp
  80008d:	83 f8 0a             	cmp    $0xa,%eax
  800090:	74 22                	je     8000b4 <umain+0x81>
			return;
		++val;
  800092:	83 c0 01             	add    $0x1,%eax
  800095:	a3 04 20 80 00       	mov    %eax,0x802004
		ipc_send(who, 0, 0, 0);
  80009a:	6a 00                	push   $0x0
  80009c:	6a 00                	push   $0x0
  80009e:	6a 00                	push   $0x0
  8000a0:	ff 75 e4             	push   -0x1c(%ebp)
  8000a3:	e8 d0 10 00 00       	call   801178 <ipc_send>
		if (val == 10)
  8000a8:	83 c4 10             	add    $0x10,%esp
  8000ab:	83 3d 04 20 80 00 0a 	cmpl   $0xa,0x802004
  8000b2:	75 94                	jne    800048 <umain+0x15>
			return;
	}
}
  8000b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000b7:	5b                   	pop    %ebx
  8000b8:	5e                   	pop    %esi
  8000b9:	5f                   	pop    %edi
  8000ba:	5d                   	pop    %ebp
  8000bb:	c3                   	ret    
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  8000bc:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  8000c2:	e8 62 0a 00 00       	call   800b29 <sys_getenvid>
  8000c7:	83 ec 04             	sub    $0x4,%esp
  8000ca:	53                   	push   %ebx
  8000cb:	50                   	push   %eax
  8000cc:	68 20 15 80 00       	push   $0x801520
  8000d1:	e8 21 01 00 00       	call   8001f7 <cprintf>
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  8000d6:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8000d9:	e8 4b 0a 00 00       	call   800b29 <sys_getenvid>
  8000de:	83 c4 0c             	add    $0xc,%esp
  8000e1:	53                   	push   %ebx
  8000e2:	50                   	push   %eax
  8000e3:	68 3a 15 80 00       	push   $0x80153a
  8000e8:	e8 0a 01 00 00       	call   8001f7 <cprintf>
		ipc_send(who, 0, 0, 0);
  8000ed:	6a 00                	push   $0x0
  8000ef:	6a 00                	push   $0x0
  8000f1:	6a 00                	push   $0x0
  8000f3:	ff 75 e4             	push   -0x1c(%ebp)
  8000f6:	e8 7d 10 00 00       	call   801178 <ipc_send>
  8000fb:	83 c4 20             	add    $0x20,%esp
  8000fe:	e9 45 ff ff ff       	jmp    800048 <umain+0x15>

00800103 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800103:	55                   	push   %ebp
  800104:	89 e5                	mov    %esp,%ebp
  800106:	56                   	push   %esi
  800107:	53                   	push   %ebx
  800108:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80010b:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	envid_t id = sys_getenvid();
  80010e:	e8 16 0a 00 00       	call   800b29 <sys_getenvid>
	if (id >= 0)
  800113:	85 c0                	test   %eax,%eax
  800115:	78 15                	js     80012c <libmain+0x29>
		thisenv = &envs[ENVX(id)];
  800117:	25 ff 03 00 00       	and    $0x3ff,%eax
  80011c:	69 c0 88 00 00 00    	imul   $0x88,%eax,%eax
  800122:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800127:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80012c:	85 db                	test   %ebx,%ebx
  80012e:	7e 07                	jle    800137 <libmain+0x34>
		binaryname = argv[0];
  800130:	8b 06                	mov    (%esi),%eax
  800132:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800137:	83 ec 08             	sub    $0x8,%esp
  80013a:	56                   	push   %esi
  80013b:	53                   	push   %ebx
  80013c:	e8 f2 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800141:	e8 0a 00 00 00       	call   800150 <exit>
}
  800146:	83 c4 10             	add    $0x10,%esp
  800149:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80014c:	5b                   	pop    %ebx
  80014d:	5e                   	pop    %esi
  80014e:	5d                   	pop    %ebp
  80014f:	c3                   	ret    

00800150 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800156:	6a 00                	push   $0x0
  800158:	e8 aa 09 00 00       	call   800b07 <sys_env_destroy>
}
  80015d:	83 c4 10             	add    $0x10,%esp
  800160:	c9                   	leave  
  800161:	c3                   	ret    

00800162 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	53                   	push   %ebx
  800166:	83 ec 04             	sub    $0x4,%esp
  800169:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80016c:	8b 13                	mov    (%ebx),%edx
  80016e:	8d 42 01             	lea    0x1(%edx),%eax
  800171:	89 03                	mov    %eax,(%ebx)
  800173:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800176:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256 - 1) {
  80017a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80017f:	74 09                	je     80018a <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800181:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800185:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800188:	c9                   	leave  
  800189:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80018a:	83 ec 08             	sub    $0x8,%esp
  80018d:	68 ff 00 00 00       	push   $0xff
  800192:	8d 43 08             	lea    0x8(%ebx),%eax
  800195:	50                   	push   %eax
  800196:	e8 22 09 00 00       	call   800abd <sys_cputs>
		b->idx = 0;
  80019b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001a1:	83 c4 10             	add    $0x10,%esp
  8001a4:	eb db                	jmp    800181 <putch+0x1f>

008001a6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001af:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b6:	00 00 00 
	b.cnt = 0;
  8001b9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c0:	00 00 00 
	vprintfmt((void *) putch, &b, fmt, ap);
  8001c3:	ff 75 0c             	push   0xc(%ebp)
  8001c6:	ff 75 08             	push   0x8(%ebp)
  8001c9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001cf:	50                   	push   %eax
  8001d0:	68 62 01 80 00       	push   $0x800162
  8001d5:	e8 74 01 00 00       	call   80034e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001da:	83 c4 08             	add    $0x8,%esp
  8001dd:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8001e3:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e9:	50                   	push   %eax
  8001ea:	e8 ce 08 00 00       	call   800abd <sys_cputs>

	return b.cnt;
}
  8001ef:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001f5:	c9                   	leave  
  8001f6:	c3                   	ret    

008001f7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f7:	55                   	push   %ebp
  8001f8:	89 e5                	mov    %esp,%ebp
  8001fa:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001fd:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800200:	50                   	push   %eax
  800201:	ff 75 08             	push   0x8(%ebp)
  800204:	e8 9d ff ff ff       	call   8001a6 <vcprintf>
	va_end(ap);

	return cnt;
}
  800209:	c9                   	leave  
  80020a:	c3                   	ret    

0080020b <printnum>:
         void *putdat,
         unsigned long long num,
         unsigned base,
         int width,
         int padc)
{
  80020b:	55                   	push   %ebp
  80020c:	89 e5                	mov    %esp,%ebp
  80020e:	57                   	push   %edi
  80020f:	56                   	push   %esi
  800210:	53                   	push   %ebx
  800211:	83 ec 1c             	sub    $0x1c,%esp
  800214:	89 c7                	mov    %eax,%edi
  800216:	89 d6                	mov    %edx,%esi
  800218:	8b 45 08             	mov    0x8(%ebp),%eax
  80021b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80021e:	89 d1                	mov    %edx,%ecx
  800220:	89 c2                	mov    %eax,%edx
  800222:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800225:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800228:	8b 45 10             	mov    0x10(%ebp),%eax
  80022b:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80022e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800231:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800238:	39 c2                	cmp    %eax,%edx
  80023a:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80023d:	72 3e                	jb     80027d <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80023f:	83 ec 0c             	sub    $0xc,%esp
  800242:	ff 75 18             	push   0x18(%ebp)
  800245:	83 eb 01             	sub    $0x1,%ebx
  800248:	53                   	push   %ebx
  800249:	50                   	push   %eax
  80024a:	83 ec 08             	sub    $0x8,%esp
  80024d:	ff 75 e4             	push   -0x1c(%ebp)
  800250:	ff 75 e0             	push   -0x20(%ebp)
  800253:	ff 75 dc             	push   -0x24(%ebp)
  800256:	ff 75 d8             	push   -0x28(%ebp)
  800259:	e8 72 10 00 00       	call   8012d0 <__udivdi3>
  80025e:	83 c4 18             	add    $0x18,%esp
  800261:	52                   	push   %edx
  800262:	50                   	push   %eax
  800263:	89 f2                	mov    %esi,%edx
  800265:	89 f8                	mov    %edi,%eax
  800267:	e8 9f ff ff ff       	call   80020b <printnum>
  80026c:	83 c4 20             	add    $0x20,%esp
  80026f:	eb 13                	jmp    800284 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800271:	83 ec 08             	sub    $0x8,%esp
  800274:	56                   	push   %esi
  800275:	ff 75 18             	push   0x18(%ebp)
  800278:	ff d7                	call   *%edi
  80027a:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80027d:	83 eb 01             	sub    $0x1,%ebx
  800280:	85 db                	test   %ebx,%ebx
  800282:	7f ed                	jg     800271 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800284:	83 ec 08             	sub    $0x8,%esp
  800287:	56                   	push   %esi
  800288:	83 ec 04             	sub    $0x4,%esp
  80028b:	ff 75 e4             	push   -0x1c(%ebp)
  80028e:	ff 75 e0             	push   -0x20(%ebp)
  800291:	ff 75 dc             	push   -0x24(%ebp)
  800294:	ff 75 d8             	push   -0x28(%ebp)
  800297:	e8 54 11 00 00       	call   8013f0 <__umoddi3>
  80029c:	83 c4 14             	add    $0x14,%esp
  80029f:	0f be 80 80 15 80 00 	movsbl 0x801580(%eax),%eax
  8002a6:	50                   	push   %eax
  8002a7:	ff d7                	call   *%edi
}
  8002a9:	83 c4 10             	add    $0x10,%esp
  8002ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002af:	5b                   	pop    %ebx
  8002b0:	5e                   	pop    %esi
  8002b1:	5f                   	pop    %edi
  8002b2:	5d                   	pop    %ebp
  8002b3:	c3                   	ret    

008002b4 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8002b4:	83 fa 01             	cmp    $0x1,%edx
  8002b7:	7f 13                	jg     8002cc <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8002b9:	85 d2                	test   %edx,%edx
  8002bb:	74 1c                	je     8002d9 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  8002bd:	8b 10                	mov    (%eax),%edx
  8002bf:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c2:	89 08                	mov    %ecx,(%eax)
  8002c4:	8b 02                	mov    (%edx),%eax
  8002c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8002cb:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  8002cc:	8b 10                	mov    (%eax),%edx
  8002ce:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002d1:	89 08                	mov    %ecx,(%eax)
  8002d3:	8b 02                	mov    (%edx),%eax
  8002d5:	8b 52 04             	mov    0x4(%edx),%edx
  8002d8:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  8002d9:	8b 10                	mov    (%eax),%edx
  8002db:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002de:	89 08                	mov    %ecx,(%eax)
  8002e0:	8b 02                	mov    (%edx),%eax
  8002e2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002e7:	c3                   	ret    

008002e8 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8002e8:	83 fa 01             	cmp    $0x1,%edx
  8002eb:	7f 0f                	jg     8002fc <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  8002ed:	85 d2                	test   %edx,%edx
  8002ef:	74 18                	je     800309 <getint+0x21>
		return va_arg(*ap, long);
  8002f1:	8b 10                	mov    (%eax),%edx
  8002f3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f6:	89 08                	mov    %ecx,(%eax)
  8002f8:	8b 02                	mov    (%edx),%eax
  8002fa:	99                   	cltd   
  8002fb:	c3                   	ret    
		return va_arg(*ap, long long);
  8002fc:	8b 10                	mov    (%eax),%edx
  8002fe:	8d 4a 08             	lea    0x8(%edx),%ecx
  800301:	89 08                	mov    %ecx,(%eax)
  800303:	8b 02                	mov    (%edx),%eax
  800305:	8b 52 04             	mov    0x4(%edx),%edx
  800308:	c3                   	ret    
	else
		return va_arg(*ap, int);
  800309:	8b 10                	mov    (%eax),%edx
  80030b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80030e:	89 08                	mov    %ecx,(%eax)
  800310:	8b 02                	mov    (%edx),%eax
  800312:	99                   	cltd   
}
  800313:	c3                   	ret    

00800314 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800314:	55                   	push   %ebp
  800315:	89 e5                	mov    %esp,%ebp
  800317:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80031a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80031e:	8b 10                	mov    (%eax),%edx
  800320:	3b 50 04             	cmp    0x4(%eax),%edx
  800323:	73 0a                	jae    80032f <sprintputch+0x1b>
		*b->buf++ = ch;
  800325:	8d 4a 01             	lea    0x1(%edx),%ecx
  800328:	89 08                	mov    %ecx,(%eax)
  80032a:	8b 45 08             	mov    0x8(%ebp),%eax
  80032d:	88 02                	mov    %al,(%edx)
}
  80032f:	5d                   	pop    %ebp
  800330:	c3                   	ret    

00800331 <printfmt>:
{
  800331:	55                   	push   %ebp
  800332:	89 e5                	mov    %esp,%ebp
  800334:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800337:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80033a:	50                   	push   %eax
  80033b:	ff 75 10             	push   0x10(%ebp)
  80033e:	ff 75 0c             	push   0xc(%ebp)
  800341:	ff 75 08             	push   0x8(%ebp)
  800344:	e8 05 00 00 00       	call   80034e <vprintfmt>
}
  800349:	83 c4 10             	add    $0x10,%esp
  80034c:	c9                   	leave  
  80034d:	c3                   	ret    

0080034e <vprintfmt>:
{
  80034e:	55                   	push   %ebp
  80034f:	89 e5                	mov    %esp,%ebp
  800351:	57                   	push   %edi
  800352:	56                   	push   %esi
  800353:	53                   	push   %ebx
  800354:	83 ec 2c             	sub    $0x2c,%esp
  800357:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80035a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80035d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800360:	eb 0a                	jmp    80036c <vprintfmt+0x1e>
			putch(ch, putdat);
  800362:	83 ec 08             	sub    $0x8,%esp
  800365:	56                   	push   %esi
  800366:	50                   	push   %eax
  800367:	ff d3                	call   *%ebx
  800369:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80036c:	83 c7 01             	add    $0x1,%edi
  80036f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800373:	83 f8 25             	cmp    $0x25,%eax
  800376:	74 0c                	je     800384 <vprintfmt+0x36>
			if (ch == '\0')
  800378:	85 c0                	test   %eax,%eax
  80037a:	75 e6                	jne    800362 <vprintfmt+0x14>
}
  80037c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80037f:	5b                   	pop    %ebx
  800380:	5e                   	pop    %esi
  800381:	5f                   	pop    %edi
  800382:	5d                   	pop    %ebp
  800383:	c3                   	ret    
		padc = ' ';
  800384:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
		altflag = 0;
  800388:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80038f:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800396:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80039d:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003a2:	8d 47 01             	lea    0x1(%edi),%eax
  8003a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003a8:	0f b6 17             	movzbl (%edi),%edx
  8003ab:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003ae:	3c 55                	cmp    $0x55,%al
  8003b0:	0f 87 b7 02 00 00    	ja     80066d <vprintfmt+0x31f>
  8003b6:	0f b6 c0             	movzbl %al,%eax
  8003b9:	ff 24 85 40 16 80 00 	jmp    *0x801640(,%eax,4)
  8003c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8003c3:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  8003c7:	eb d9                	jmp    8003a2 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8003c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003cc:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  8003d0:	eb d0                	jmp    8003a2 <vprintfmt+0x54>
  8003d2:	0f b6 d2             	movzbl %dl,%edx
  8003d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0;; ++fmt) {
  8003d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8003dd:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003e0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003e3:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003e7:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003ea:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003ed:	83 f9 09             	cmp    $0x9,%ecx
  8003f0:	77 52                	ja     800444 <vprintfmt+0xf6>
			for (precision = 0;; ++fmt) {
  8003f2:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003f5:	eb e9                	jmp    8003e0 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  8003f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fa:	8d 50 04             	lea    0x4(%eax),%edx
  8003fd:	89 55 14             	mov    %edx,0x14(%ebp)
  800400:	8b 00                	mov    (%eax),%eax
  800402:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800405:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800408:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80040c:	79 94                	jns    8003a2 <vprintfmt+0x54>
				width = precision, precision = -1;
  80040e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800411:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800414:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80041b:	eb 85                	jmp    8003a2 <vprintfmt+0x54>
  80041d:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800420:	85 d2                	test   %edx,%edx
  800422:	b8 00 00 00 00       	mov    $0x0,%eax
  800427:	0f 49 c2             	cmovns %edx,%eax
  80042a:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80042d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800430:	e9 6d ff ff ff       	jmp    8003a2 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800435:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800438:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80043f:	e9 5e ff ff ff       	jmp    8003a2 <vprintfmt+0x54>
  800444:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800447:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80044a:	eb bc                	jmp    800408 <vprintfmt+0xba>
			lflag++;
  80044c:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80044f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800452:	e9 4b ff ff ff       	jmp    8003a2 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800457:	8b 45 14             	mov    0x14(%ebp),%eax
  80045a:	8d 50 04             	lea    0x4(%eax),%edx
  80045d:	89 55 14             	mov    %edx,0x14(%ebp)
  800460:	83 ec 08             	sub    $0x8,%esp
  800463:	56                   	push   %esi
  800464:	ff 30                	push   (%eax)
  800466:	ff d3                	call   *%ebx
			break;
  800468:	83 c4 10             	add    $0x10,%esp
  80046b:	e9 94 01 00 00       	jmp    800604 <vprintfmt+0x2b6>
			err = va_arg(ap, int);
  800470:	8b 45 14             	mov    0x14(%ebp),%eax
  800473:	8d 50 04             	lea    0x4(%eax),%edx
  800476:	89 55 14             	mov    %edx,0x14(%ebp)
  800479:	8b 10                	mov    (%eax),%edx
  80047b:	89 d0                	mov    %edx,%eax
  80047d:	f7 d8                	neg    %eax
  80047f:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800482:	83 f8 08             	cmp    $0x8,%eax
  800485:	7f 20                	jg     8004a7 <vprintfmt+0x159>
  800487:	8b 14 85 a0 17 80 00 	mov    0x8017a0(,%eax,4),%edx
  80048e:	85 d2                	test   %edx,%edx
  800490:	74 15                	je     8004a7 <vprintfmt+0x159>
				printfmt(putch, putdat, "%s", p);
  800492:	52                   	push   %edx
  800493:	68 a1 15 80 00       	push   $0x8015a1
  800498:	56                   	push   %esi
  800499:	53                   	push   %ebx
  80049a:	e8 92 fe ff ff       	call   800331 <printfmt>
  80049f:	83 c4 10             	add    $0x10,%esp
  8004a2:	e9 5d 01 00 00       	jmp    800604 <vprintfmt+0x2b6>
				printfmt(putch, putdat, "error %d", err);
  8004a7:	50                   	push   %eax
  8004a8:	68 98 15 80 00       	push   $0x801598
  8004ad:	56                   	push   %esi
  8004ae:	53                   	push   %ebx
  8004af:	e8 7d fe ff ff       	call   800331 <printfmt>
  8004b4:	83 c4 10             	add    $0x10,%esp
  8004b7:	e9 48 01 00 00       	jmp    800604 <vprintfmt+0x2b6>
			if ((p = va_arg(ap, char *)) == NULL)
  8004bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bf:	8d 50 04             	lea    0x4(%eax),%edx
  8004c2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c5:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004c7:	85 ff                	test   %edi,%edi
  8004c9:	b8 91 15 80 00       	mov    $0x801591,%eax
  8004ce:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004d1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004d5:	7e 06                	jle    8004dd <vprintfmt+0x18f>
  8004d7:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8004db:	75 0a                	jne    8004e7 <vprintfmt+0x199>
  8004dd:	89 f8                	mov    %edi,%eax
  8004df:	03 45 e0             	add    -0x20(%ebp),%eax
  8004e2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004e5:	eb 59                	jmp    800540 <vprintfmt+0x1f2>
				for (width -= strnlen(p, precision); width > 0;
  8004e7:	83 ec 08             	sub    $0x8,%esp
  8004ea:	ff 75 d8             	push   -0x28(%ebp)
  8004ed:	57                   	push   %edi
  8004ee:	e8 1a 02 00 00       	call   80070d <strnlen>
  8004f3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004f6:	29 c1                	sub    %eax,%ecx
  8004f8:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004fb:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004fe:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  800502:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800505:	89 7d d0             	mov    %edi,-0x30(%ebp)
  800508:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0;
  80050a:	eb 0f                	jmp    80051b <vprintfmt+0x1cd>
					putch(padc, putdat);
  80050c:	83 ec 08             	sub    $0x8,%esp
  80050f:	56                   	push   %esi
  800510:	ff 75 e0             	push   -0x20(%ebp)
  800513:	ff d3                	call   *%ebx
				     width--)
  800515:	83 ef 01             	sub    $0x1,%edi
  800518:	83 c4 10             	add    $0x10,%esp
				for (width -= strnlen(p, precision); width > 0;
  80051b:	85 ff                	test   %edi,%edi
  80051d:	7f ed                	jg     80050c <vprintfmt+0x1be>
  80051f:	8b 7d d0             	mov    -0x30(%ebp),%edi
  800522:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800525:	85 c9                	test   %ecx,%ecx
  800527:	b8 00 00 00 00       	mov    $0x0,%eax
  80052c:	0f 49 c1             	cmovns %ecx,%eax
  80052f:	29 c1                	sub    %eax,%ecx
  800531:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800534:	eb a7                	jmp    8004dd <vprintfmt+0x18f>
					putch(ch, putdat);
  800536:	83 ec 08             	sub    $0x8,%esp
  800539:	56                   	push   %esi
  80053a:	52                   	push   %edx
  80053b:	ff d3                	call   *%ebx
  80053d:	83 c4 10             	add    $0x10,%esp
  800540:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800543:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' &&
  800545:	83 c7 01             	add    $0x1,%edi
  800548:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80054c:	0f be d0             	movsbl %al,%edx
  80054f:	85 d2                	test   %edx,%edx
  800551:	74 42                	je     800595 <vprintfmt+0x247>
  800553:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800557:	78 06                	js     80055f <vprintfmt+0x211>
			       (precision < 0 || --precision >= 0);
  800559:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80055d:	78 1e                	js     80057d <vprintfmt+0x22f>
				if (altflag && (ch < ' ' || ch > '~'))
  80055f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800563:	74 d1                	je     800536 <vprintfmt+0x1e8>
  800565:	0f be c0             	movsbl %al,%eax
  800568:	83 e8 20             	sub    $0x20,%eax
  80056b:	83 f8 5e             	cmp    $0x5e,%eax
  80056e:	76 c6                	jbe    800536 <vprintfmt+0x1e8>
					putch('?', putdat);
  800570:	83 ec 08             	sub    $0x8,%esp
  800573:	56                   	push   %esi
  800574:	6a 3f                	push   $0x3f
  800576:	ff d3                	call   *%ebx
  800578:	83 c4 10             	add    $0x10,%esp
  80057b:	eb c3                	jmp    800540 <vprintfmt+0x1f2>
  80057d:	89 cf                	mov    %ecx,%edi
  80057f:	eb 0e                	jmp    80058f <vprintfmt+0x241>
				putch(' ', putdat);
  800581:	83 ec 08             	sub    $0x8,%esp
  800584:	56                   	push   %esi
  800585:	6a 20                	push   $0x20
  800587:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  800589:	83 ef 01             	sub    $0x1,%edi
  80058c:	83 c4 10             	add    $0x10,%esp
  80058f:	85 ff                	test   %edi,%edi
  800591:	7f ee                	jg     800581 <vprintfmt+0x233>
  800593:	eb 6f                	jmp    800604 <vprintfmt+0x2b6>
  800595:	89 cf                	mov    %ecx,%edi
  800597:	eb f6                	jmp    80058f <vprintfmt+0x241>
			num = getint(&ap, lflag);
  800599:	89 ca                	mov    %ecx,%edx
  80059b:	8d 45 14             	lea    0x14(%ebp),%eax
  80059e:	e8 45 fd ff ff       	call   8002e8 <getint>
  8005a3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a6:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  8005a9:	85 d2                	test   %edx,%edx
  8005ab:	78 0b                	js     8005b8 <vprintfmt+0x26a>
			num = getint(&ap, lflag);
  8005ad:	89 d1                	mov    %edx,%ecx
  8005af:	89 c2                	mov    %eax,%edx
			base = 10;
  8005b1:	bf 0a 00 00 00       	mov    $0xa,%edi
  8005b6:	eb 32                	jmp    8005ea <vprintfmt+0x29c>
				putch('-', putdat);
  8005b8:	83 ec 08             	sub    $0x8,%esp
  8005bb:	56                   	push   %esi
  8005bc:	6a 2d                	push   $0x2d
  8005be:	ff d3                	call   *%ebx
				num = -(long long) num;
  8005c0:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005c3:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005c6:	f7 da                	neg    %edx
  8005c8:	83 d1 00             	adc    $0x0,%ecx
  8005cb:	f7 d9                	neg    %ecx
  8005cd:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005d0:	bf 0a 00 00 00       	mov    $0xa,%edi
  8005d5:	eb 13                	jmp    8005ea <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  8005d7:	89 ca                	mov    %ecx,%edx
  8005d9:	8d 45 14             	lea    0x14(%ebp),%eax
  8005dc:	e8 d3 fc ff ff       	call   8002b4 <getuint>
  8005e1:	89 d1                	mov    %edx,%ecx
  8005e3:	89 c2                	mov    %eax,%edx
			base = 10;
  8005e5:	bf 0a 00 00 00       	mov    $0xa,%edi
			printnum(putch, putdat, num, base, width, padc);
  8005ea:	83 ec 0c             	sub    $0xc,%esp
  8005ed:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  8005f1:	50                   	push   %eax
  8005f2:	ff 75 e0             	push   -0x20(%ebp)
  8005f5:	57                   	push   %edi
  8005f6:	51                   	push   %ecx
  8005f7:	52                   	push   %edx
  8005f8:	89 f2                	mov    %esi,%edx
  8005fa:	89 d8                	mov    %ebx,%eax
  8005fc:	e8 0a fc ff ff       	call   80020b <printnum>
			break;
  800601:	83 c4 20             	add    $0x20,%esp
{
  800604:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800607:	e9 60 fd ff ff       	jmp    80036c <vprintfmt+0x1e>
			num = getuint(&ap, lflag);
  80060c:	89 ca                	mov    %ecx,%edx
  80060e:	8d 45 14             	lea    0x14(%ebp),%eax
  800611:	e8 9e fc ff ff       	call   8002b4 <getuint>
  800616:	89 d1                	mov    %edx,%ecx
  800618:	89 c2                	mov    %eax,%edx
			base = 8;
  80061a:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  80061f:	eb c9                	jmp    8005ea <vprintfmt+0x29c>
			putch('0', putdat);
  800621:	83 ec 08             	sub    $0x8,%esp
  800624:	56                   	push   %esi
  800625:	6a 30                	push   $0x30
  800627:	ff d3                	call   *%ebx
			putch('x', putdat);
  800629:	83 c4 08             	add    $0x8,%esp
  80062c:	56                   	push   %esi
  80062d:	6a 78                	push   $0x78
  80062f:	ff d3                	call   *%ebx
			num = (unsigned long long) (uintptr_t) va_arg(ap, void *);
  800631:	8b 45 14             	mov    0x14(%ebp),%eax
  800634:	8d 50 04             	lea    0x4(%eax),%edx
  800637:	89 55 14             	mov    %edx,0x14(%ebp)
  80063a:	8b 10                	mov    (%eax),%edx
  80063c:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800641:	83 c4 10             	add    $0x10,%esp
			base = 16;
  800644:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  800649:	eb 9f                	jmp    8005ea <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  80064b:	89 ca                	mov    %ecx,%edx
  80064d:	8d 45 14             	lea    0x14(%ebp),%eax
  800650:	e8 5f fc ff ff       	call   8002b4 <getuint>
  800655:	89 d1                	mov    %edx,%ecx
  800657:	89 c2                	mov    %eax,%edx
			base = 16;
  800659:	bf 10 00 00 00       	mov    $0x10,%edi
  80065e:	eb 8a                	jmp    8005ea <vprintfmt+0x29c>
			putch(ch, putdat);
  800660:	83 ec 08             	sub    $0x8,%esp
  800663:	56                   	push   %esi
  800664:	6a 25                	push   $0x25
  800666:	ff d3                	call   *%ebx
			break;
  800668:	83 c4 10             	add    $0x10,%esp
  80066b:	eb 97                	jmp    800604 <vprintfmt+0x2b6>
			putch('%', putdat);
  80066d:	83 ec 08             	sub    $0x8,%esp
  800670:	56                   	push   %esi
  800671:	6a 25                	push   $0x25
  800673:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  800675:	83 c4 10             	add    $0x10,%esp
  800678:	89 f8                	mov    %edi,%eax
  80067a:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80067e:	74 05                	je     800685 <vprintfmt+0x337>
  800680:	83 e8 01             	sub    $0x1,%eax
  800683:	eb f5                	jmp    80067a <vprintfmt+0x32c>
  800685:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800688:	e9 77 ff ff ff       	jmp    800604 <vprintfmt+0x2b6>

0080068d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80068d:	55                   	push   %ebp
  80068e:	89 e5                	mov    %esp,%ebp
  800690:	83 ec 18             	sub    $0x18,%esp
  800693:	8b 45 08             	mov    0x8(%ebp),%eax
  800696:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = { buf, buf + n - 1, 0 };
  800699:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80069c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006a0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006a3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006aa:	85 c0                	test   %eax,%eax
  8006ac:	74 26                	je     8006d4 <vsnprintf+0x47>
  8006ae:	85 d2                	test   %edx,%edx
  8006b0:	7e 22                	jle    8006d4 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *) sprintputch, &b, fmt, ap);
  8006b2:	ff 75 14             	push   0x14(%ebp)
  8006b5:	ff 75 10             	push   0x10(%ebp)
  8006b8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006bb:	50                   	push   %eax
  8006bc:	68 14 03 80 00       	push   $0x800314
  8006c1:	e8 88 fc ff ff       	call   80034e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006c9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006cf:	83 c4 10             	add    $0x10,%esp
}
  8006d2:	c9                   	leave  
  8006d3:	c3                   	ret    
		return -E_INVAL;
  8006d4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006d9:	eb f7                	jmp    8006d2 <vsnprintf+0x45>

008006db <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006db:	55                   	push   %ebp
  8006dc:	89 e5                	mov    %esp,%ebp
  8006de:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006e1:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006e4:	50                   	push   %eax
  8006e5:	ff 75 10             	push   0x10(%ebp)
  8006e8:	ff 75 0c             	push   0xc(%ebp)
  8006eb:	ff 75 08             	push   0x8(%ebp)
  8006ee:	e8 9a ff ff ff       	call   80068d <vsnprintf>
	va_end(ap);

	return rc;
}
  8006f3:	c9                   	leave  
  8006f4:	c3                   	ret    

008006f5 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006f5:	55                   	push   %ebp
  8006f6:	89 e5                	mov    %esp,%ebp
  8006f8:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800700:	eb 03                	jmp    800705 <strlen+0x10>
		n++;
  800702:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800705:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800709:	75 f7                	jne    800702 <strlen+0xd>
	return n;
}
  80070b:	5d                   	pop    %ebp
  80070c:	c3                   	ret    

0080070d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80070d:	55                   	push   %ebp
  80070e:	89 e5                	mov    %esp,%ebp
  800710:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800713:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800716:	b8 00 00 00 00       	mov    $0x0,%eax
  80071b:	eb 03                	jmp    800720 <strnlen+0x13>
		n++;
  80071d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800720:	39 d0                	cmp    %edx,%eax
  800722:	74 08                	je     80072c <strnlen+0x1f>
  800724:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800728:	75 f3                	jne    80071d <strnlen+0x10>
  80072a:	89 c2                	mov    %eax,%edx
	return n;
}
  80072c:	89 d0                	mov    %edx,%eax
  80072e:	5d                   	pop    %ebp
  80072f:	c3                   	ret    

00800730 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800730:	55                   	push   %ebp
  800731:	89 e5                	mov    %esp,%ebp
  800733:	53                   	push   %ebx
  800734:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800737:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80073a:	b8 00 00 00 00       	mov    $0x0,%eax
  80073f:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800743:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800746:	83 c0 01             	add    $0x1,%eax
  800749:	84 d2                	test   %dl,%dl
  80074b:	75 f2                	jne    80073f <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80074d:	89 c8                	mov    %ecx,%eax
  80074f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800752:	c9                   	leave  
  800753:	c3                   	ret    

00800754 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800754:	55                   	push   %ebp
  800755:	89 e5                	mov    %esp,%ebp
  800757:	53                   	push   %ebx
  800758:	83 ec 10             	sub    $0x10,%esp
  80075b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80075e:	53                   	push   %ebx
  80075f:	e8 91 ff ff ff       	call   8006f5 <strlen>
  800764:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800767:	ff 75 0c             	push   0xc(%ebp)
  80076a:	01 d8                	add    %ebx,%eax
  80076c:	50                   	push   %eax
  80076d:	e8 be ff ff ff       	call   800730 <strcpy>
	return dst;
}
  800772:	89 d8                	mov    %ebx,%eax
  800774:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800777:	c9                   	leave  
  800778:	c3                   	ret    

00800779 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size)
{
  800779:	55                   	push   %ebp
  80077a:	89 e5                	mov    %esp,%ebp
  80077c:	56                   	push   %esi
  80077d:	53                   	push   %ebx
  80077e:	8b 75 08             	mov    0x8(%ebp),%esi
  800781:	8b 55 0c             	mov    0xc(%ebp),%edx
  800784:	89 f3                	mov    %esi,%ebx
  800786:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800789:	89 f0                	mov    %esi,%eax
  80078b:	eb 0f                	jmp    80079c <strncpy+0x23>
		*dst++ = *src;
  80078d:	83 c0 01             	add    $0x1,%eax
  800790:	0f b6 0a             	movzbl (%edx),%ecx
  800793:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800796:	80 f9 01             	cmp    $0x1,%cl
  800799:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  80079c:	39 d8                	cmp    %ebx,%eax
  80079e:	75 ed                	jne    80078d <strncpy+0x14>
	}
	return ret;
}
  8007a0:	89 f0                	mov    %esi,%eax
  8007a2:	5b                   	pop    %ebx
  8007a3:	5e                   	pop    %esi
  8007a4:	5d                   	pop    %ebp
  8007a5:	c3                   	ret    

008007a6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007a6:	55                   	push   %ebp
  8007a7:	89 e5                	mov    %esp,%ebp
  8007a9:	56                   	push   %esi
  8007aa:	53                   	push   %ebx
  8007ab:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007b1:	8b 55 10             	mov    0x10(%ebp),%edx
  8007b4:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007b6:	85 d2                	test   %edx,%edx
  8007b8:	74 21                	je     8007db <strlcpy+0x35>
  8007ba:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007be:	89 f2                	mov    %esi,%edx
  8007c0:	eb 09                	jmp    8007cb <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007c2:	83 c1 01             	add    $0x1,%ecx
  8007c5:	83 c2 01             	add    $0x1,%edx
  8007c8:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  8007cb:	39 c2                	cmp    %eax,%edx
  8007cd:	74 09                	je     8007d8 <strlcpy+0x32>
  8007cf:	0f b6 19             	movzbl (%ecx),%ebx
  8007d2:	84 db                	test   %bl,%bl
  8007d4:	75 ec                	jne    8007c2 <strlcpy+0x1c>
  8007d6:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8007d8:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007db:	29 f0                	sub    %esi,%eax
}
  8007dd:	5b                   	pop    %ebx
  8007de:	5e                   	pop    %esi
  8007df:	5d                   	pop    %ebp
  8007e0:	c3                   	ret    

008007e1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007e1:	55                   	push   %ebp
  8007e2:	89 e5                	mov    %esp,%ebp
  8007e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007ea:	eb 06                	jmp    8007f2 <strcmp+0x11>
		p++, q++;
  8007ec:	83 c1 01             	add    $0x1,%ecx
  8007ef:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8007f2:	0f b6 01             	movzbl (%ecx),%eax
  8007f5:	84 c0                	test   %al,%al
  8007f7:	74 04                	je     8007fd <strcmp+0x1c>
  8007f9:	3a 02                	cmp    (%edx),%al
  8007fb:	74 ef                	je     8007ec <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007fd:	0f b6 c0             	movzbl %al,%eax
  800800:	0f b6 12             	movzbl (%edx),%edx
  800803:	29 d0                	sub    %edx,%eax
}
  800805:	5d                   	pop    %ebp
  800806:	c3                   	ret    

00800807 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800807:	55                   	push   %ebp
  800808:	89 e5                	mov    %esp,%ebp
  80080a:	53                   	push   %ebx
  80080b:	8b 45 08             	mov    0x8(%ebp),%eax
  80080e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800811:	89 c3                	mov    %eax,%ebx
  800813:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800816:	eb 06                	jmp    80081e <strncmp+0x17>
		n--, p++, q++;
  800818:	83 c0 01             	add    $0x1,%eax
  80081b:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80081e:	39 d8                	cmp    %ebx,%eax
  800820:	74 18                	je     80083a <strncmp+0x33>
  800822:	0f b6 08             	movzbl (%eax),%ecx
  800825:	84 c9                	test   %cl,%cl
  800827:	74 04                	je     80082d <strncmp+0x26>
  800829:	3a 0a                	cmp    (%edx),%cl
  80082b:	74 eb                	je     800818 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80082d:	0f b6 00             	movzbl (%eax),%eax
  800830:	0f b6 12             	movzbl (%edx),%edx
  800833:	29 d0                	sub    %edx,%eax
}
  800835:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800838:	c9                   	leave  
  800839:	c3                   	ret    
		return 0;
  80083a:	b8 00 00 00 00       	mov    $0x0,%eax
  80083f:	eb f4                	jmp    800835 <strncmp+0x2e>

00800841 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800841:	55                   	push   %ebp
  800842:	89 e5                	mov    %esp,%ebp
  800844:	8b 45 08             	mov    0x8(%ebp),%eax
  800847:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80084b:	eb 03                	jmp    800850 <strchr+0xf>
  80084d:	83 c0 01             	add    $0x1,%eax
  800850:	0f b6 10             	movzbl (%eax),%edx
  800853:	84 d2                	test   %dl,%dl
  800855:	74 06                	je     80085d <strchr+0x1c>
		if (*s == c)
  800857:	38 ca                	cmp    %cl,%dl
  800859:	75 f2                	jne    80084d <strchr+0xc>
  80085b:	eb 05                	jmp    800862 <strchr+0x21>
			return (char *) s;
	return 0;
  80085d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800862:	5d                   	pop    %ebp
  800863:	c3                   	ret    

00800864 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800864:	55                   	push   %ebp
  800865:	89 e5                	mov    %esp,%ebp
  800867:	8b 45 08             	mov    0x8(%ebp),%eax
  80086a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80086e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800871:	38 ca                	cmp    %cl,%dl
  800873:	74 09                	je     80087e <strfind+0x1a>
  800875:	84 d2                	test   %dl,%dl
  800877:	74 05                	je     80087e <strfind+0x1a>
	for (; *s; s++)
  800879:	83 c0 01             	add    $0x1,%eax
  80087c:	eb f0                	jmp    80086e <strfind+0xa>
			break;
	return (char *) s;
}
  80087e:	5d                   	pop    %ebp
  80087f:	c3                   	ret    

00800880 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	57                   	push   %edi
  800884:	56                   	push   %esi
  800885:	53                   	push   %ebx
  800886:	8b 55 08             	mov    0x8(%ebp),%edx
  800889:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  80088c:	85 c9                	test   %ecx,%ecx
  80088e:	74 33                	je     8008c3 <memset+0x43>
		return v;
	if ((int) v % 4 == 0 && n % 4 == 0) {
  800890:	89 d0                	mov    %edx,%eax
  800892:	09 c8                	or     %ecx,%eax
  800894:	a8 03                	test   $0x3,%al
  800896:	75 23                	jne    8008bb <memset+0x3b>
		c &= 0xFF;
  800898:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  80089c:	89 d8                	mov    %ebx,%eax
  80089e:	c1 e0 08             	shl    $0x8,%eax
  8008a1:	89 df                	mov    %ebx,%edi
  8008a3:	c1 e7 18             	shl    $0x18,%edi
  8008a6:	89 de                	mov    %ebx,%esi
  8008a8:	c1 e6 10             	shl    $0x10,%esi
  8008ab:	09 f7                	or     %esi,%edi
  8008ad:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
		             : "=D"(p), "=c"(n)
		             : "D"(p), "a"(c), "c"(n / 4)
  8008af:	c1 e9 02             	shr    $0x2,%ecx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  8008b2:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  8008b4:	89 d7                	mov    %edx,%edi
  8008b6:	fc                   	cld    
  8008b7:	f3 ab                	rep stos %eax,%es:(%edi)
  8008b9:	eb 08                	jmp    8008c3 <memset+0x43>
		             : "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008bb:	89 d7                	mov    %edx,%edi
  8008bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c0:	fc                   	cld    
  8008c1:	f3 aa                	rep stos %al,%es:(%edi)
		             : "=D"(p), "=c"(n)
		             : "0"(p), "a"(c), "1"(n)
		             : "cc", "memory");
	return v;
}
  8008c3:	89 d0                	mov    %edx,%eax
  8008c5:	5b                   	pop    %ebx
  8008c6:	5e                   	pop    %esi
  8008c7:	5f                   	pop    %edi
  8008c8:	5d                   	pop    %ebp
  8008c9:	c3                   	ret    

008008ca <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008ca:	55                   	push   %ebp
  8008cb:	89 e5                	mov    %esp,%ebp
  8008cd:	57                   	push   %edi
  8008ce:	56                   	push   %esi
  8008cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008d5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008d8:	39 c6                	cmp    %eax,%esi
  8008da:	73 32                	jae    80090e <memmove+0x44>
  8008dc:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008df:	39 c2                	cmp    %eax,%edx
  8008e1:	76 2b                	jbe    80090e <memmove+0x44>
		s += n;
		d += n;
  8008e3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  8008e6:	89 d6                	mov    %edx,%esi
  8008e8:	09 fe                	or     %edi,%esi
  8008ea:	09 ce                	or     %ecx,%esi
  8008ec:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008f2:	75 0e                	jne    800902 <memmove+0x38>
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  8008f4:	83 ef 04             	sub    $0x4,%edi
			             "S"(s - 4),
  8008f7:	8d 72 fc             	lea    -0x4(%edx),%esi
			             "c"(n / 4)
  8008fa:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  8008fd:	fd                   	std    
  8008fe:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800900:	eb 09                	jmp    80090b <memmove+0x41>
			             : "cc", "memory");
		else
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  800902:	83 ef 01             	sub    $0x1,%edi
			             "S"(s - 1),
  800905:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  800908:	fd                   	std    
  800909:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             "c"(n)
			             : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80090b:	fc                   	cld    
  80090c:	eb 1a                	jmp    800928 <memmove+0x5e>
	} else {
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  80090e:	89 f2                	mov    %esi,%edx
  800910:	09 c2                	or     %eax,%edx
  800912:	09 ca                	or     %ecx,%edx
  800914:	f6 c2 03             	test   $0x3,%dl
  800917:	75 0a                	jne    800923 <memmove+0x59>
			asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800919:	c1 e9 02             	shr    $0x2,%ecx
  80091c:	89 c7                	mov    %eax,%edi
  80091e:	fc                   	cld    
  80091f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800921:	eb 05                	jmp    800928 <memmove+0x5e>
			             : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800923:	89 c7                	mov    %eax,%edi
  800925:	fc                   	cld    
  800926:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             : "cc", "memory");
	}
	return dst;
}
  800928:	5e                   	pop    %esi
  800929:	5f                   	pop    %edi
  80092a:	5d                   	pop    %ebp
  80092b:	c3                   	ret    

0080092c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80092c:	55                   	push   %ebp
  80092d:	89 e5                	mov    %esp,%ebp
  80092f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800932:	ff 75 10             	push   0x10(%ebp)
  800935:	ff 75 0c             	push   0xc(%ebp)
  800938:	ff 75 08             	push   0x8(%ebp)
  80093b:	e8 8a ff ff ff       	call   8008ca <memmove>
}
  800940:	c9                   	leave  
  800941:	c3                   	ret    

00800942 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800942:	55                   	push   %ebp
  800943:	89 e5                	mov    %esp,%ebp
  800945:	56                   	push   %esi
  800946:	53                   	push   %ebx
  800947:	8b 45 08             	mov    0x8(%ebp),%eax
  80094a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80094d:	89 c6                	mov    %eax,%esi
  80094f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800952:	eb 06                	jmp    80095a <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800954:	83 c0 01             	add    $0x1,%eax
  800957:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  80095a:	39 f0                	cmp    %esi,%eax
  80095c:	74 14                	je     800972 <memcmp+0x30>
		if (*s1 != *s2)
  80095e:	0f b6 08             	movzbl (%eax),%ecx
  800961:	0f b6 1a             	movzbl (%edx),%ebx
  800964:	38 d9                	cmp    %bl,%cl
  800966:	74 ec                	je     800954 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800968:	0f b6 c1             	movzbl %cl,%eax
  80096b:	0f b6 db             	movzbl %bl,%ebx
  80096e:	29 d8                	sub    %ebx,%eax
  800970:	eb 05                	jmp    800977 <memcmp+0x35>
	}

	return 0;
  800972:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800977:	5b                   	pop    %ebx
  800978:	5e                   	pop    %esi
  800979:	5d                   	pop    %ebp
  80097a:	c3                   	ret    

0080097b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	8b 45 08             	mov    0x8(%ebp),%eax
  800981:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800984:	89 c2                	mov    %eax,%edx
  800986:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800989:	eb 03                	jmp    80098e <memfind+0x13>
  80098b:	83 c0 01             	add    $0x1,%eax
  80098e:	39 d0                	cmp    %edx,%eax
  800990:	73 04                	jae    800996 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800992:	38 08                	cmp    %cl,(%eax)
  800994:	75 f5                	jne    80098b <memfind+0x10>
			break;
	return (void *) s;
}
  800996:	5d                   	pop    %ebp
  800997:	c3                   	ret    

00800998 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800998:	55                   	push   %ebp
  800999:	89 e5                	mov    %esp,%ebp
  80099b:	57                   	push   %edi
  80099c:	56                   	push   %esi
  80099d:	53                   	push   %ebx
  80099e:	8b 55 08             	mov    0x8(%ebp),%edx
  8009a1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009a4:	eb 03                	jmp    8009a9 <strtol+0x11>
		s++;
  8009a6:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  8009a9:	0f b6 02             	movzbl (%edx),%eax
  8009ac:	3c 20                	cmp    $0x20,%al
  8009ae:	74 f6                	je     8009a6 <strtol+0xe>
  8009b0:	3c 09                	cmp    $0x9,%al
  8009b2:	74 f2                	je     8009a6 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8009b4:	3c 2b                	cmp    $0x2b,%al
  8009b6:	74 2a                	je     8009e2 <strtol+0x4a>
	int neg = 0;
  8009b8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8009bd:	3c 2d                	cmp    $0x2d,%al
  8009bf:	74 2b                	je     8009ec <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009c1:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009c7:	75 0f                	jne    8009d8 <strtol+0x40>
  8009c9:	80 3a 30             	cmpb   $0x30,(%edx)
  8009cc:	74 28                	je     8009f6 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009ce:	85 db                	test   %ebx,%ebx
  8009d0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009d5:	0f 44 d8             	cmove  %eax,%ebx
  8009d8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009dd:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8009e0:	eb 46                	jmp    800a28 <strtol+0x90>
		s++;
  8009e2:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  8009e5:	bf 00 00 00 00       	mov    $0x0,%edi
  8009ea:	eb d5                	jmp    8009c1 <strtol+0x29>
		s++, neg = 1;
  8009ec:	83 c2 01             	add    $0x1,%edx
  8009ef:	bf 01 00 00 00       	mov    $0x1,%edi
  8009f4:	eb cb                	jmp    8009c1 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009f6:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009fa:	74 0e                	je     800a0a <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  8009fc:	85 db                	test   %ebx,%ebx
  8009fe:	75 d8                	jne    8009d8 <strtol+0x40>
		s++, base = 8;
  800a00:	83 c2 01             	add    $0x1,%edx
  800a03:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a08:	eb ce                	jmp    8009d8 <strtol+0x40>
		s += 2, base = 16;
  800a0a:	83 c2 02             	add    $0x2,%edx
  800a0d:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a12:	eb c4                	jmp    8009d8 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a14:	0f be c0             	movsbl %al,%eax
  800a17:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a1a:	3b 45 10             	cmp    0x10(%ebp),%eax
  800a1d:	7d 3a                	jge    800a59 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800a1f:	83 c2 01             	add    $0x1,%edx
  800a22:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800a26:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800a28:	0f b6 02             	movzbl (%edx),%eax
  800a2b:	8d 70 d0             	lea    -0x30(%eax),%esi
  800a2e:	89 f3                	mov    %esi,%ebx
  800a30:	80 fb 09             	cmp    $0x9,%bl
  800a33:	76 df                	jbe    800a14 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800a35:	8d 70 9f             	lea    -0x61(%eax),%esi
  800a38:	89 f3                	mov    %esi,%ebx
  800a3a:	80 fb 19             	cmp    $0x19,%bl
  800a3d:	77 08                	ja     800a47 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800a3f:	0f be c0             	movsbl %al,%eax
  800a42:	83 e8 57             	sub    $0x57,%eax
  800a45:	eb d3                	jmp    800a1a <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800a47:	8d 70 bf             	lea    -0x41(%eax),%esi
  800a4a:	89 f3                	mov    %esi,%ebx
  800a4c:	80 fb 19             	cmp    $0x19,%bl
  800a4f:	77 08                	ja     800a59 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800a51:	0f be c0             	movsbl %al,%eax
  800a54:	83 e8 37             	sub    $0x37,%eax
  800a57:	eb c1                	jmp    800a1a <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a59:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a5d:	74 05                	je     800a64 <strtol+0xcc>
		*endptr = (char *) s;
  800a5f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a62:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800a64:	89 c8                	mov    %ecx,%eax
  800a66:	f7 d8                	neg    %eax
  800a68:	85 ff                	test   %edi,%edi
  800a6a:	0f 45 c8             	cmovne %eax,%ecx
}
  800a6d:	89 c8                	mov    %ecx,%eax
  800a6f:	5b                   	pop    %ebx
  800a70:	5e                   	pop    %esi
  800a71:	5f                   	pop    %edi
  800a72:	5d                   	pop    %ebp
  800a73:	c3                   	ret    

00800a74 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a74:	55                   	push   %ebp
  800a75:	89 e5                	mov    %esp,%ebp
  800a77:	57                   	push   %edi
  800a78:	56                   	push   %esi
  800a79:	53                   	push   %ebx
  800a7a:	83 ec 1c             	sub    $0x1c,%esp
  800a7d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a80:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800a83:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile(
  800a85:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a88:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a8b:	8b 7d 10             	mov    0x10(%ebp),%edi
  800a8e:	8b 75 14             	mov    0x14(%ebp),%esi
  800a91:	cd 30                	int    $0x30
	        "int %1\n"
	        : "=a"(ret)
	        : "i"(T_SYSCALL), "a"(num), "d"(a1), "c"(a2), "b"(a3), "D"(a4), "S"(a5)
	        : "cc", "memory");

	if (check && ret > 0)
  800a93:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a97:	74 04                	je     800a9d <syscall+0x29>
  800a99:	85 c0                	test   %eax,%eax
  800a9b:	7f 08                	jg     800aa5 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800a9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800aa0:	5b                   	pop    %ebx
  800aa1:	5e                   	pop    %esi
  800aa2:	5f                   	pop    %edi
  800aa3:	5d                   	pop    %ebp
  800aa4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800aa5:	83 ec 0c             	sub    $0xc,%esp
  800aa8:	50                   	push   %eax
  800aa9:	ff 75 e0             	push   -0x20(%ebp)
  800aac:	68 c4 17 80 00       	push   $0x8017c4
  800ab1:	6a 1e                	push   $0x1e
  800ab3:	68 e1 17 80 00       	push   $0x8017e1
  800ab8:	e8 5c 07 00 00       	call   801219 <_panic>

00800abd <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800abd:	55                   	push   %ebp
  800abe:	89 e5                	mov    %esp,%ebp
  800ac0:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t) s, len, 0, 0, 0);
  800ac3:	6a 00                	push   $0x0
  800ac5:	6a 00                	push   $0x0
  800ac7:	6a 00                	push   $0x0
  800ac9:	ff 75 0c             	push   0xc(%ebp)
  800acc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800acf:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad9:	e8 96 ff ff ff       	call   800a74 <syscall>
}
  800ade:	83 c4 10             	add    $0x10,%esp
  800ae1:	c9                   	leave  
  800ae2:	c3                   	ret    

00800ae3 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ae3:	55                   	push   %ebp
  800ae4:	89 e5                	mov    %esp,%ebp
  800ae6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800ae9:	6a 00                	push   $0x0
  800aeb:	6a 00                	push   $0x0
  800aed:	6a 00                	push   $0x0
  800aef:	6a 00                	push   $0x0
  800af1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800af6:	ba 00 00 00 00       	mov    $0x0,%edx
  800afb:	b8 01 00 00 00       	mov    $0x1,%eax
  800b00:	e8 6f ff ff ff       	call   800a74 <syscall>
}
  800b05:	c9                   	leave  
  800b06:	c3                   	ret    

00800b07 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b07:	55                   	push   %ebp
  800b08:	89 e5                	mov    %esp,%ebp
  800b0a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800b0d:	6a 00                	push   $0x0
  800b0f:	6a 00                	push   $0x0
  800b11:	6a 00                	push   $0x0
  800b13:	6a 00                	push   $0x0
  800b15:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b18:	ba 01 00 00 00       	mov    $0x1,%edx
  800b1d:	b8 03 00 00 00       	mov    $0x3,%eax
  800b22:	e8 4d ff ff ff       	call   800a74 <syscall>
}
  800b27:	c9                   	leave  
  800b28:	c3                   	ret    

00800b29 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b29:	55                   	push   %ebp
  800b2a:	89 e5                	mov    %esp,%ebp
  800b2c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800b2f:	6a 00                	push   $0x0
  800b31:	6a 00                	push   $0x0
  800b33:	6a 00                	push   $0x0
  800b35:	6a 00                	push   $0x0
  800b37:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b3c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b41:	b8 02 00 00 00       	mov    $0x2,%eax
  800b46:	e8 29 ff ff ff       	call   800a74 <syscall>
}
  800b4b:	c9                   	leave  
  800b4c:	c3                   	ret    

00800b4d <sys_yield>:

void
sys_yield(void)
{
  800b4d:	55                   	push   %ebp
  800b4e:	89 e5                	mov    %esp,%ebp
  800b50:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800b53:	6a 00                	push   $0x0
  800b55:	6a 00                	push   $0x0
  800b57:	6a 00                	push   $0x0
  800b59:	6a 00                	push   $0x0
  800b5b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b60:	ba 00 00 00 00       	mov    $0x0,%edx
  800b65:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b6a:	e8 05 ff ff ff       	call   800a74 <syscall>
}
  800b6f:	83 c4 10             	add    $0x10,%esp
  800b72:	c9                   	leave  
  800b73:	c3                   	ret    

00800b74 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b74:	55                   	push   %ebp
  800b75:	89 e5                	mov    %esp,%ebp
  800b77:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800b7a:	6a 00                	push   $0x0
  800b7c:	6a 00                	push   $0x0
  800b7e:	ff 75 10             	push   0x10(%ebp)
  800b81:	ff 75 0c             	push   0xc(%ebp)
  800b84:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b87:	ba 01 00 00 00       	mov    $0x1,%edx
  800b8c:	b8 04 00 00 00       	mov    $0x4,%eax
  800b91:	e8 de fe ff ff       	call   800a74 <syscall>
}
  800b96:	c9                   	leave  
  800b97:	c3                   	ret    

00800b98 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b98:	55                   	push   %ebp
  800b99:	89 e5                	mov    %esp,%ebp
  800b9b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map,
  800b9e:	ff 75 18             	push   0x18(%ebp)
  800ba1:	ff 75 14             	push   0x14(%ebp)
  800ba4:	ff 75 10             	push   0x10(%ebp)
  800ba7:	ff 75 0c             	push   0xc(%ebp)
  800baa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bad:	ba 01 00 00 00       	mov    $0x1,%edx
  800bb2:	b8 05 00 00 00       	mov    $0x5,%eax
  800bb7:	e8 b8 fe ff ff       	call   800a74 <syscall>
	               srcenv,
	               (uint32_t) srcva,
	               dstenv,
	               (uint32_t) dstva,
	               perm);
}
  800bbc:	c9                   	leave  
  800bbd:	c3                   	ret    

00800bbe <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bbe:	55                   	push   %ebp
  800bbf:	89 e5                	mov    %esp,%ebp
  800bc1:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800bc4:	6a 00                	push   $0x0
  800bc6:	6a 00                	push   $0x0
  800bc8:	6a 00                	push   $0x0
  800bca:	ff 75 0c             	push   0xc(%ebp)
  800bcd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bd0:	ba 01 00 00 00       	mov    $0x1,%edx
  800bd5:	b8 06 00 00 00       	mov    $0x6,%eax
  800bda:	e8 95 fe ff ff       	call   800a74 <syscall>
}
  800bdf:	c9                   	leave  
  800be0:	c3                   	ret    

00800be1 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800be1:	55                   	push   %ebp
  800be2:	89 e5                	mov    %esp,%ebp
  800be4:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800be7:	6a 00                	push   $0x0
  800be9:	6a 00                	push   $0x0
  800beb:	6a 00                	push   $0x0
  800bed:	ff 75 0c             	push   0xc(%ebp)
  800bf0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bf3:	ba 01 00 00 00       	mov    $0x1,%edx
  800bf8:	b8 08 00 00 00       	mov    $0x8,%eax
  800bfd:	e8 72 fe ff ff       	call   800a74 <syscall>
}
  800c02:	c9                   	leave  
  800c03:	c3                   	ret    

00800c04 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c04:	55                   	push   %ebp
  800c05:	89 e5                	mov    %esp,%ebp
  800c07:	83 ec 08             	sub    $0x8,%esp
	return syscall(
  800c0a:	6a 00                	push   $0x0
  800c0c:	6a 00                	push   $0x0
  800c0e:	6a 00                	push   $0x0
  800c10:	ff 75 0c             	push   0xc(%ebp)
  800c13:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c16:	ba 01 00 00 00       	mov    $0x1,%edx
  800c1b:	b8 09 00 00 00       	mov    $0x9,%eax
  800c20:	e8 4f fe ff ff       	call   800a74 <syscall>
	        SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c25:	c9                   	leave  
  800c26:	c3                   	ret    

00800c27 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c27:	55                   	push   %ebp
  800c28:	89 e5                	mov    %esp,%ebp
  800c2a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800c2d:	6a 00                	push   $0x0
  800c2f:	ff 75 14             	push   0x14(%ebp)
  800c32:	ff 75 10             	push   0x10(%ebp)
  800c35:	ff 75 0c             	push   0xc(%ebp)
  800c38:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c3b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c40:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c45:	e8 2a fe ff ff       	call   800a74 <syscall>
}
  800c4a:	c9                   	leave  
  800c4b:	c3                   	ret    

00800c4c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c4c:	55                   	push   %ebp
  800c4d:	89 e5                	mov    %esp,%ebp
  800c4f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t) dstva, 0, 0, 0, 0);
  800c52:	6a 00                	push   $0x0
  800c54:	6a 00                	push   $0x0
  800c56:	6a 00                	push   $0x0
  800c58:	6a 00                	push   $0x0
  800c5a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c5d:	ba 01 00 00 00       	mov    $0x1,%edx
  800c62:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c67:	e8 08 fe ff ff       	call   800a74 <syscall>
}
  800c6c:	c9                   	leave  
  800c6d:	c3                   	ret    

00800c6e <sys_get_priority>:

// Get priority of the current process
int
sys_get_priority(void)
{
  800c6e:	55                   	push   %ebp
  800c6f:	89 e5                	mov    %esp,%ebp
  800c71:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_get_priority, 0, 0, 0, 0, 0, 0);
  800c74:	6a 00                	push   $0x0
  800c76:	6a 00                	push   $0x0
  800c78:	6a 00                	push   $0x0
  800c7a:	6a 00                	push   $0x0
  800c7c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c81:	ba 00 00 00 00       	mov    $0x0,%edx
  800c86:	b8 0d 00 00 00       	mov    $0xd,%eax
  800c8b:	e8 e4 fd ff ff       	call   800a74 <syscall>
}
  800c90:	c9                   	leave  
  800c91:	c3                   	ret    

00800c92 <sys_set_priority>:

// Get priority of the current process
int
sys_set_priority(unsigned int priority)
{
  800c92:	55                   	push   %ebp
  800c93:	89 e5                	mov    %esp,%ebp
  800c95:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, (uint32_t) priority, 0, 0, 0, 0);
  800c98:	6a 00                	push   $0x0
  800c9a:	6a 00                	push   $0x0
  800c9c:	6a 00                	push   $0x0
  800c9e:	6a 00                	push   $0x0
  800ca0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ca3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca8:	b8 0e 00 00 00       	mov    $0xe,%eax
  800cad:	e8 c2 fd ff ff       	call   800a74 <syscall>
}
  800cb2:	c9                   	leave  
  800cb3:	c3                   	ret    

00800cb4 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800cb4:	55                   	push   %ebp
  800cb5:	89 e5                	mov    %esp,%ebp
  800cb7:	56                   	push   %esi
  800cb8:	53                   	push   %ebx
  800cb9:	89 c1                	mov    %eax,%ecx
	int r;

	void *addr = (void *) (pn << PGSHIFT);
  800cbb:	89 d6                	mov    %edx,%esi
  800cbd:	c1 e6 0c             	shl    $0xc,%esi

	pte_t pte = uvpt[pn];
  800cc0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx

	if (!(pte & PTE_P) || !(pte & PTE_U))
  800cc7:	89 d0                	mov    %edx,%eax
  800cc9:	83 e0 05             	and    $0x5,%eax
  800ccc:	83 f8 05             	cmp    $0x5,%eax
  800ccf:	75 5a                	jne    800d2b <duppage+0x77>
		panic("duppage: copy a non-present or non-user page");

	int perm = PTE_U | PTE_P;
	// Verifico permisos para páginas de IO
	if (pte & (PTE_PCD | PTE_PWT))
  800cd1:	89 d0                	mov    %edx,%eax
  800cd3:	83 e0 18             	and    $0x18,%eax
		perm |= PTE_PCD | PTE_PWT;
  800cd6:	83 f8 01             	cmp    $0x1,%eax
  800cd9:	19 c0                	sbb    %eax,%eax
  800cdb:	83 e0 e8             	and    $0xffffffe8,%eax
  800cde:	83 c0 1d             	add    $0x1d,%eax


	// Si es de escritura o copy-on-write y NO es de IO
	if ((pte & PTE_W) || (pte & PTE_COW)) {
  800ce1:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800ce7:	74 68                	je     800d51 <duppage+0x9d>
		// Mappeo en el hijo la página
		if ((r = sys_page_map(0, addr, envid, addr, perm | PTE_COW)) < 0)
  800ce9:	80 cc 08             	or     $0x8,%ah
  800cec:	89 c3                	mov    %eax,%ebx
  800cee:	83 ec 0c             	sub    $0xc,%esp
  800cf1:	50                   	push   %eax
  800cf2:	56                   	push   %esi
  800cf3:	51                   	push   %ecx
  800cf4:	56                   	push   %esi
  800cf5:	6a 00                	push   $0x0
  800cf7:	e8 9c fe ff ff       	call   800b98 <sys_page_map>
  800cfc:	83 c4 20             	add    $0x20,%esp
  800cff:	85 c0                	test   %eax,%eax
  800d01:	78 3c                	js     800d3f <duppage+0x8b>
			panic("duppage: sys_page_map on childern COW: %e", r);

		// Cambio los permisos del padre
		if ((r = sys_page_map(0, addr, 0, addr, perm | PTE_COW)) < 0)
  800d03:	83 ec 0c             	sub    $0xc,%esp
  800d06:	53                   	push   %ebx
  800d07:	56                   	push   %esi
  800d08:	6a 00                	push   $0x0
  800d0a:	56                   	push   %esi
  800d0b:	6a 00                	push   $0x0
  800d0d:	e8 86 fe ff ff       	call   800b98 <sys_page_map>
  800d12:	83 c4 20             	add    $0x20,%esp
  800d15:	85 c0                	test   %eax,%eax
  800d17:	79 4d                	jns    800d66 <duppage+0xb2>
			panic("duppage: sys_page_map on parent COW: %e", r);
  800d19:	50                   	push   %eax
  800d1a:	68 4c 18 80 00       	push   $0x80184c
  800d1f:	6a 57                	push   $0x57
  800d21:	68 41 19 80 00       	push   $0x801941
  800d26:	e8 ee 04 00 00       	call   801219 <_panic>
		panic("duppage: copy a non-present or non-user page");
  800d2b:	83 ec 04             	sub    $0x4,%esp
  800d2e:	68 f0 17 80 00       	push   $0x8017f0
  800d33:	6a 47                	push   $0x47
  800d35:	68 41 19 80 00       	push   $0x801941
  800d3a:	e8 da 04 00 00       	call   801219 <_panic>
			panic("duppage: sys_page_map on childern COW: %e", r);
  800d3f:	50                   	push   %eax
  800d40:	68 20 18 80 00       	push   $0x801820
  800d45:	6a 53                	push   $0x53
  800d47:	68 41 19 80 00       	push   $0x801941
  800d4c:	e8 c8 04 00 00       	call   801219 <_panic>
	} else {
		// Solo mappeo la página de solo lectura
		if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  800d51:	83 ec 0c             	sub    $0xc,%esp
  800d54:	50                   	push   %eax
  800d55:	56                   	push   %esi
  800d56:	51                   	push   %ecx
  800d57:	56                   	push   %esi
  800d58:	6a 00                	push   $0x0
  800d5a:	e8 39 fe ff ff       	call   800b98 <sys_page_map>
  800d5f:	83 c4 20             	add    $0x20,%esp
  800d62:	85 c0                	test   %eax,%eax
  800d64:	78 0c                	js     800d72 <duppage+0xbe>
			panic("duppage: sys_page_map on childern RO: %e", r);
	}

	// panic("duppage not implemented");
	return 0;
}
  800d66:	b8 00 00 00 00       	mov    $0x0,%eax
  800d6b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d6e:	5b                   	pop    %ebx
  800d6f:	5e                   	pop    %esi
  800d70:	5d                   	pop    %ebp
  800d71:	c3                   	ret    
			panic("duppage: sys_page_map on childern RO: %e", r);
  800d72:	50                   	push   %eax
  800d73:	68 74 18 80 00       	push   $0x801874
  800d78:	6a 5b                	push   $0x5b
  800d7a:	68 41 19 80 00       	push   $0x801941
  800d7f:	e8 95 04 00 00       	call   801219 <_panic>

00800d84 <dup_or_share>:
 *
 * Hace uso de uvpd y uvpt para chequear permisos.
 */
static void
dup_or_share(envid_t envid, uint32_t pnum, int perm)
{
  800d84:	55                   	push   %ebp
  800d85:	89 e5                	mov    %esp,%ebp
  800d87:	57                   	push   %edi
  800d88:	56                   	push   %esi
  800d89:	53                   	push   %ebx
  800d8a:	83 ec 0c             	sub    $0xc,%esp
  800d8d:	89 c7                	mov    %eax,%edi
	int r;
	void *addr = (void *) (pnum << PGSHIFT);

	pte_t pte = uvpt[pnum];
  800d8f:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax

	if (!(pte & PTE_P))
  800d96:	a8 01                	test   $0x1,%al
  800d98:	74 33                	je     800dcd <dup_or_share+0x49>
  800d9a:	89 d6                	mov    %edx,%esi
		return;

	// Filtro permisos
	perm &= (pte & PTE_W);
  800d9c:	21 c1                	and    %eax,%ecx
  800d9e:	89 cb                	mov    %ecx,%ebx
  800da0:	83 e3 02             	and    $0x2,%ebx
	perm &= PTE_SYSCALL;


	if (pte & (PTE_PCD | PTE_PWT))
		perm |= PTE_PCD | PTE_PWT;
  800da3:	89 da                	mov    %ebx,%edx
  800da5:	83 ca 18             	or     $0x18,%edx
  800da8:	a8 18                	test   $0x18,%al
  800daa:	0f 45 da             	cmovne %edx,%ebx
	void *addr = (void *) (pnum << PGSHIFT);
  800dad:	c1 e6 0c             	shl    $0xc,%esi

	// Si tengo que copiar
	if (!(pte & PTE_W) || (pte & (PTE_PCD | PTE_PWT))) {
  800db0:	83 e0 1a             	and    $0x1a,%eax
  800db3:	83 f8 02             	cmp    $0x2,%eax
  800db6:	74 32                	je     800dea <dup_or_share+0x66>
		if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  800db8:	83 ec 0c             	sub    $0xc,%esp
  800dbb:	53                   	push   %ebx
  800dbc:	56                   	push   %esi
  800dbd:	57                   	push   %edi
  800dbe:	56                   	push   %esi
  800dbf:	6a 00                	push   $0x0
  800dc1:	e8 d2 fd ff ff       	call   800b98 <sys_page_map>
  800dc6:	83 c4 20             	add    $0x20,%esp
  800dc9:	85 c0                	test   %eax,%eax
  800dcb:	78 08                	js     800dd5 <dup_or_share+0x51>
			panic("dup_or_share: sys_page_map: %e", r);
		memmove(UTEMP, addr, PGSIZE);
		if ((r = sys_page_unmap(0, UTEMP)) < 0)
			panic("sys_page_unmap: %e", r);
	}
}
  800dcd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd0:	5b                   	pop    %ebx
  800dd1:	5e                   	pop    %esi
  800dd2:	5f                   	pop    %edi
  800dd3:	5d                   	pop    %ebp
  800dd4:	c3                   	ret    
			panic("dup_or_share: sys_page_map: %e", r);
  800dd5:	50                   	push   %eax
  800dd6:	68 a0 18 80 00       	push   $0x8018a0
  800ddb:	68 84 00 00 00       	push   $0x84
  800de0:	68 41 19 80 00       	push   $0x801941
  800de5:	e8 2f 04 00 00       	call   801219 <_panic>
		if ((r = sys_page_alloc(envid, addr, perm)) < 0)
  800dea:	83 ec 04             	sub    $0x4,%esp
  800ded:	53                   	push   %ebx
  800dee:	56                   	push   %esi
  800def:	57                   	push   %edi
  800df0:	e8 7f fd ff ff       	call   800b74 <sys_page_alloc>
  800df5:	83 c4 10             	add    $0x10,%esp
  800df8:	85 c0                	test   %eax,%eax
  800dfa:	78 57                	js     800e53 <dup_or_share+0xcf>
		if ((r = sys_page_map(envid, addr, 0, UTEMP, perm)) < 0)
  800dfc:	83 ec 0c             	sub    $0xc,%esp
  800dff:	53                   	push   %ebx
  800e00:	68 00 00 40 00       	push   $0x400000
  800e05:	6a 00                	push   $0x0
  800e07:	56                   	push   %esi
  800e08:	57                   	push   %edi
  800e09:	e8 8a fd ff ff       	call   800b98 <sys_page_map>
  800e0e:	83 c4 20             	add    $0x20,%esp
  800e11:	85 c0                	test   %eax,%eax
  800e13:	78 53                	js     800e68 <dup_or_share+0xe4>
		memmove(UTEMP, addr, PGSIZE);
  800e15:	83 ec 04             	sub    $0x4,%esp
  800e18:	68 00 10 00 00       	push   $0x1000
  800e1d:	56                   	push   %esi
  800e1e:	68 00 00 40 00       	push   $0x400000
  800e23:	e8 a2 fa ff ff       	call   8008ca <memmove>
		if ((r = sys_page_unmap(0, UTEMP)) < 0)
  800e28:	83 c4 08             	add    $0x8,%esp
  800e2b:	68 00 00 40 00       	push   $0x400000
  800e30:	6a 00                	push   $0x0
  800e32:	e8 87 fd ff ff       	call   800bbe <sys_page_unmap>
  800e37:	83 c4 10             	add    $0x10,%esp
  800e3a:	85 c0                	test   %eax,%eax
  800e3c:	79 8f                	jns    800dcd <dup_or_share+0x49>
			panic("sys_page_unmap: %e", r);
  800e3e:	50                   	push   %eax
  800e3f:	68 8b 19 80 00       	push   $0x80198b
  800e44:	68 8d 00 00 00       	push   $0x8d
  800e49:	68 41 19 80 00       	push   $0x801941
  800e4e:	e8 c6 03 00 00       	call   801219 <_panic>
			panic("dup_or_share: sys_page_alloc: %e", r);
  800e53:	50                   	push   %eax
  800e54:	68 c0 18 80 00       	push   $0x8018c0
  800e59:	68 88 00 00 00       	push   $0x88
  800e5e:	68 41 19 80 00       	push   $0x801941
  800e63:	e8 b1 03 00 00       	call   801219 <_panic>
			panic("dup_or_share: sys_page_map: %e", r);
  800e68:	50                   	push   %eax
  800e69:	68 a0 18 80 00       	push   $0x8018a0
  800e6e:	68 8a 00 00 00       	push   $0x8a
  800e73:	68 41 19 80 00       	push   $0x801941
  800e78:	e8 9c 03 00 00       	call   801219 <_panic>

00800e7d <pgfault>:
{
  800e7d:	55                   	push   %ebp
  800e7e:	89 e5                	mov    %esp,%ebp
  800e80:	53                   	push   %ebx
  800e81:	83 ec 08             	sub    $0x8,%esp
	void *addr = (void *) utf->utf_fault_va;
  800e84:	8b 45 08             	mov    0x8(%ebp),%eax
  800e87:	8b 18                	mov    (%eax),%ebx
	pte_t fault_pte = uvpt[((uint32_t) addr) >> PGSHIFT];
  800e89:	89 d8                	mov    %ebx,%eax
  800e8b:	c1 e8 0c             	shr    $0xc,%eax
  800e8e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if ((r = sys_page_alloc(0, PFTEMP, perm)) < 0)
  800e95:	6a 07                	push   $0x7
  800e97:	68 00 f0 7f 00       	push   $0x7ff000
  800e9c:	6a 00                	push   $0x0
  800e9e:	e8 d1 fc ff ff       	call   800b74 <sys_page_alloc>
  800ea3:	83 c4 10             	add    $0x10,%esp
  800ea6:	85 c0                	test   %eax,%eax
  800ea8:	78 51                	js     800efb <pgfault+0x7e>
	addr = ROUNDDOWN(addr, PGSIZE);
  800eaa:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr, PGSIZE);
  800eb0:	83 ec 04             	sub    $0x4,%esp
  800eb3:	68 00 10 00 00       	push   $0x1000
  800eb8:	53                   	push   %ebx
  800eb9:	68 00 f0 7f 00       	push   $0x7ff000
  800ebe:	e8 07 fa ff ff       	call   8008ca <memmove>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, perm)) < 0)
  800ec3:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800eca:	53                   	push   %ebx
  800ecb:	6a 00                	push   $0x0
  800ecd:	68 00 f0 7f 00       	push   $0x7ff000
  800ed2:	6a 00                	push   $0x0
  800ed4:	e8 bf fc ff ff       	call   800b98 <sys_page_map>
  800ed9:	83 c4 20             	add    $0x20,%esp
  800edc:	85 c0                	test   %eax,%eax
  800ede:	78 2d                	js     800f0d <pgfault+0x90>
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800ee0:	83 ec 08             	sub    $0x8,%esp
  800ee3:	68 00 f0 7f 00       	push   $0x7ff000
  800ee8:	6a 00                	push   $0x0
  800eea:	e8 cf fc ff ff       	call   800bbe <sys_page_unmap>
  800eef:	83 c4 10             	add    $0x10,%esp
  800ef2:	85 c0                	test   %eax,%eax
  800ef4:	78 29                	js     800f1f <pgfault+0xa2>
}
  800ef6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ef9:	c9                   	leave  
  800efa:	c3                   	ret    
		panic("pgfault: sys_page_alloc: %e", r);
  800efb:	50                   	push   %eax
  800efc:	68 4c 19 80 00       	push   $0x80194c
  800f01:	6a 27                	push   $0x27
  800f03:	68 41 19 80 00       	push   $0x801941
  800f08:	e8 0c 03 00 00       	call   801219 <_panic>
		panic("pgfault: sys_page_map: %e", r);
  800f0d:	50                   	push   %eax
  800f0e:	68 68 19 80 00       	push   $0x801968
  800f13:	6a 2c                	push   $0x2c
  800f15:	68 41 19 80 00       	push   $0x801941
  800f1a:	e8 fa 02 00 00       	call   801219 <_panic>
		panic("pgfault: sys_page_unmap: %e", r);
  800f1f:	50                   	push   %eax
  800f20:	68 82 19 80 00       	push   $0x801982
  800f25:	6a 2f                	push   $0x2f
  800f27:	68 41 19 80 00       	push   $0x801941
  800f2c:	e8 e8 02 00 00       	call   801219 <_panic>

00800f31 <fork_v0>:
 *  	-- Para ello se utiliza la funcion dup_or_share()
 *  	-- Se copian todas las paginas desde 0 hasta UTOP
 */
envid_t
fork_v0(void)
{
  800f31:	55                   	push   %ebp
  800f32:	89 e5                	mov    %esp,%ebp
  800f34:	56                   	push   %esi
  800f35:	53                   	push   %ebx

// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline)) sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2" : "=a"(ret) : "a"(SYS_exofork), "i"(T_SYSCALL));
  800f36:	b8 07 00 00 00       	mov    $0x7,%eax
  800f3b:	cd 30                	int    $0x30
  800f3d:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();
	if (envid < 0)
  800f3f:	85 c0                	test   %eax,%eax
  800f41:	78 23                	js     800f66 <fork_v0+0x35>
	// Parent
	uint32_t pnum = 0;
	uint32_t pnum_end = (UTOP >> PGSHIFT);
	int perm = PTE_P | PTE_U | PTE_W;

	for (pnum = 0; pnum < pnum_end; pnum++) {
  800f43:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid == 0) {
  800f48:	75 3c                	jne    800f86 <fork_v0+0x55>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f4a:	e8 da fb ff ff       	call   800b29 <sys_getenvid>
  800f4f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f54:	69 c0 88 00 00 00    	imul   $0x88,%eax,%eax
  800f5a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f5f:	a3 08 20 80 00       	mov    %eax,0x802008
		return 0;
  800f64:	eb 56                	jmp    800fbc <fork_v0+0x8b>
		panic("sys_exofork: %e", envid);
  800f66:	50                   	push   %eax
  800f67:	68 9e 19 80 00       	push   $0x80199e
  800f6c:	68 a2 00 00 00       	push   $0xa2
  800f71:	68 41 19 80 00       	push   $0x801941
  800f76:	e8 9e 02 00 00       	call   801219 <_panic>
	for (pnum = 0; pnum < pnum_end; pnum++) {
  800f7b:	83 c3 01             	add    $0x1,%ebx
  800f7e:	81 fb 00 ec 0e 00    	cmp    $0xeec00,%ebx
  800f84:	74 24                	je     800faa <fork_v0+0x79>
		pde_t pde = uvpd[pnum >> 10];
  800f86:	89 d8                	mov    %ebx,%eax
  800f88:	c1 e8 0a             	shr    $0xa,%eax
  800f8b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
		if (!(pde & PTE_P) || !(pde & PTE_U))
  800f92:	83 e0 05             	and    $0x5,%eax
  800f95:	83 f8 05             	cmp    $0x5,%eax
  800f98:	75 e1                	jne    800f7b <fork_v0+0x4a>
			continue;
		dup_or_share(envid, pnum, perm);
  800f9a:	b9 07 00 00 00       	mov    $0x7,%ecx
  800f9f:	89 da                	mov    %ebx,%edx
  800fa1:	89 f0                	mov    %esi,%eax
  800fa3:	e8 dc fd ff ff       	call   800d84 <dup_or_share>
  800fa8:	eb d1                	jmp    800f7b <fork_v0+0x4a>
	}


	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800faa:	83 ec 08             	sub    $0x8,%esp
  800fad:	6a 02                	push   $0x2
  800faf:	56                   	push   %esi
  800fb0:	e8 2c fc ff ff       	call   800be1 <sys_env_set_status>
  800fb5:	83 c4 10             	add    $0x10,%esp
  800fb8:	85 c0                	test   %eax,%eax
  800fba:	78 09                	js     800fc5 <fork_v0+0x94>
		panic("sys_env_set_status: %e", r);

	return envid;
}
  800fbc:	89 f0                	mov    %esi,%eax
  800fbe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fc1:	5b                   	pop    %ebx
  800fc2:	5e                   	pop    %esi
  800fc3:	5d                   	pop    %ebp
  800fc4:	c3                   	ret    
		panic("sys_env_set_status: %e", r);
  800fc5:	50                   	push   %eax
  800fc6:	68 ae 19 80 00       	push   $0x8019ae
  800fcb:	68 b8 00 00 00       	push   $0xb8
  800fd0:	68 41 19 80 00       	push   $0x801941
  800fd5:	e8 3f 02 00 00       	call   801219 <_panic>

00800fda <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fda:	55                   	push   %ebp
  800fdb:	89 e5                	mov    %esp,%ebp
  800fdd:	56                   	push   %esi
  800fde:	53                   	push   %ebx
	set_pgfault_handler(pgfault);
  800fdf:	83 ec 0c             	sub    $0xc,%esp
  800fe2:	68 7d 0e 80 00       	push   $0x800e7d
  800fe7:	e8 73 02 00 00       	call   80125f <set_pgfault_handler>
  800fec:	b8 07 00 00 00       	mov    $0x7,%eax
  800ff1:	cd 30                	int    $0x30
  800ff3:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();

	if (envid < 0)
  800ff5:	83 c4 10             	add    $0x10,%esp
  800ff8:	85 c0                	test   %eax,%eax
  800ffa:	78 26                	js     801022 <fork+0x48>
	// Parent
	uint32_t pnum = 0;
	uint32_t pnum_end = (UTOP >> PGSHIFT);

	// Handle all pages below UTOP
	for (pnum = 0; pnum < pnum_end; pnum++) {
  800ffc:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid == 0) {
  801001:	75 41                	jne    801044 <fork+0x6a>
		thisenv = &envs[ENVX(sys_getenvid())];
  801003:	e8 21 fb ff ff       	call   800b29 <sys_getenvid>
  801008:	25 ff 03 00 00       	and    $0x3ff,%eax
  80100d:	69 c0 88 00 00 00    	imul   $0x88,%eax,%eax
  801013:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801018:	a3 08 20 80 00       	mov    %eax,0x802008
		return 0;
  80101d:	e9 92 00 00 00       	jmp    8010b4 <fork+0xda>
		panic("sys_exofork: %e", envid);
  801022:	50                   	push   %eax
  801023:	68 9e 19 80 00       	push   $0x80199e
  801028:	68 d5 00 00 00       	push   $0xd5
  80102d:	68 41 19 80 00       	push   $0x801941
  801032:	e8 e2 01 00 00       	call   801219 <_panic>
	for (pnum = 0; pnum < pnum_end; pnum++) {
  801037:	83 c3 01             	add    $0x1,%ebx
  80103a:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  801040:	77 30                	ja     801072 <fork+0x98>
		if (pnum == ((UXSTACKTOP >> PGSHIFT) - 1))
  801042:	74 f3                	je     801037 <fork+0x5d>
			continue;

		pde_t pde = uvpd[pnum >> 10];
  801044:	89 d8                	mov    %ebx,%eax
  801046:	c1 e8 0a             	shr    $0xa,%eax
  801049:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
		if (!(pde & PTE_P) || !(pde & PTE_U))
  801050:	83 e0 05             	and    $0x5,%eax
  801053:	83 f8 05             	cmp    $0x5,%eax
  801056:	75 df                	jne    801037 <fork+0x5d>
			continue;

		pte_t pte = uvpt[pnum];
  801058:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
		if (!(pte & PTE_P) || !(pte & PTE_U))
  80105f:	83 e0 05             	and    $0x5,%eax
  801062:	83 f8 05             	cmp    $0x5,%eax
  801065:	75 d0                	jne    801037 <fork+0x5d>
			continue;
		duppage(envid, pnum);
  801067:	89 da                	mov    %ebx,%edx
  801069:	89 f0                	mov    %esi,%eax
  80106b:	e8 44 fc ff ff       	call   800cb4 <duppage>
  801070:	eb c5                	jmp    801037 <fork+0x5d>
	}

	uint32_t exstk = (UXSTACKTOP - PGSIZE);
	int r = sys_page_alloc(envid, (void *) exstk, PTE_U | PTE_P | PTE_W);
  801072:	83 ec 04             	sub    $0x4,%esp
  801075:	6a 07                	push   $0x7
  801077:	68 00 f0 bf ee       	push   $0xeebff000
  80107c:	56                   	push   %esi
  80107d:	e8 f2 fa ff ff       	call   800b74 <sys_page_alloc>
	if (r < 0)
  801082:	83 c4 10             	add    $0x10,%esp
  801085:	85 c0                	test   %eax,%eax
  801087:	78 34                	js     8010bd <fork+0xe3>
		panic("fork: sys_page_alloc of exception stk: %e", r);
	r = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801089:	a1 08 20 80 00       	mov    0x802008,%eax
  80108e:	8b 40 70             	mov    0x70(%eax),%eax
  801091:	83 ec 08             	sub    $0x8,%esp
  801094:	50                   	push   %eax
  801095:	56                   	push   %esi
  801096:	e8 69 fb ff ff       	call   800c04 <sys_env_set_pgfault_upcall>
	if (r < 0)
  80109b:	83 c4 10             	add    $0x10,%esp
  80109e:	85 c0                	test   %eax,%eax
  8010a0:	78 30                	js     8010d2 <fork+0xf8>
		panic("fork: sys_env_set_pgfault_upcall on childern: %e", r);

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8010a2:	83 ec 08             	sub    $0x8,%esp
  8010a5:	6a 02                	push   $0x2
  8010a7:	56                   	push   %esi
  8010a8:	e8 34 fb ff ff       	call   800be1 <sys_env_set_status>
  8010ad:	83 c4 10             	add    $0x10,%esp
  8010b0:	85 c0                	test   %eax,%eax
  8010b2:	78 33                	js     8010e7 <fork+0x10d>
		panic("sys_env_set_status: %e", r);

	return envid;
}
  8010b4:	89 f0                	mov    %esi,%eax
  8010b6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010b9:	5b                   	pop    %ebx
  8010ba:	5e                   	pop    %esi
  8010bb:	5d                   	pop    %ebp
  8010bc:	c3                   	ret    
		panic("fork: sys_page_alloc of exception stk: %e", r);
  8010bd:	50                   	push   %eax
  8010be:	68 e4 18 80 00       	push   $0x8018e4
  8010c3:	68 f2 00 00 00       	push   $0xf2
  8010c8:	68 41 19 80 00       	push   $0x801941
  8010cd:	e8 47 01 00 00       	call   801219 <_panic>
		panic("fork: sys_env_set_pgfault_upcall on childern: %e", r);
  8010d2:	50                   	push   %eax
  8010d3:	68 10 19 80 00       	push   $0x801910
  8010d8:	68 f5 00 00 00       	push   $0xf5
  8010dd:	68 41 19 80 00       	push   $0x801941
  8010e2:	e8 32 01 00 00       	call   801219 <_panic>
		panic("sys_env_set_status: %e", r);
  8010e7:	50                   	push   %eax
  8010e8:	68 ae 19 80 00       	push   $0x8019ae
  8010ed:	68 f8 00 00 00       	push   $0xf8
  8010f2:	68 41 19 80 00       	push   $0x801941
  8010f7:	e8 1d 01 00 00       	call   801219 <_panic>

008010fc <sfork>:

// Challenge!
int
sfork(void)
{
  8010fc:	55                   	push   %ebp
  8010fd:	89 e5                	mov    %esp,%ebp
  8010ff:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801102:	68 c5 19 80 00       	push   $0x8019c5
  801107:	68 01 01 00 00       	push   $0x101
  80110c:	68 41 19 80 00       	push   $0x801941
  801111:	e8 03 01 00 00       	call   801219 <_panic>

00801116 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801116:	55                   	push   %ebp
  801117:	89 e5                	mov    %esp,%ebp
  801119:	56                   	push   %esi
  80111a:	53                   	push   %ebx
  80111b:	8b 75 08             	mov    0x8(%ebp),%esi
  80111e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int err = sys_ipc_recv(pg);
  801121:	83 ec 0c             	sub    $0xc,%esp
  801124:	ff 75 0c             	push   0xc(%ebp)
  801127:	e8 20 fb ff ff       	call   800c4c <sys_ipc_recv>

	if (from_env_store)
  80112c:	83 c4 10             	add    $0x10,%esp
  80112f:	85 f6                	test   %esi,%esi
  801131:	74 17                	je     80114a <ipc_recv+0x34>
		*from_env_store = (!err) ? thisenv->env_ipc_from : 0;
  801133:	ba 00 00 00 00       	mov    $0x0,%edx
  801138:	85 c0                	test   %eax,%eax
  80113a:	75 0c                	jne    801148 <ipc_recv+0x32>
  80113c:	8b 15 08 20 80 00    	mov    0x802008,%edx
  801142:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
  801148:	89 16                	mov    %edx,(%esi)

	if (perm_store)
  80114a:	85 db                	test   %ebx,%ebx
  80114c:	74 17                	je     801165 <ipc_recv+0x4f>
		*perm_store = (!err) ? thisenv->env_ipc_perm : 0;
  80114e:	ba 00 00 00 00       	mov    $0x0,%edx
  801153:	85 c0                	test   %eax,%eax
  801155:	75 0c                	jne    801163 <ipc_recv+0x4d>
  801157:	8b 15 08 20 80 00    	mov    0x802008,%edx
  80115d:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  801163:	89 13                	mov    %edx,(%ebx)

	if (!err)
  801165:	85 c0                	test   %eax,%eax
  801167:	75 08                	jne    801171 <ipc_recv+0x5b>
		err = thisenv->env_ipc_value;
  801169:	a1 08 20 80 00       	mov    0x802008,%eax
  80116e:	8b 40 7c             	mov    0x7c(%eax),%eax

	return err;
}
  801171:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801174:	5b                   	pop    %ebx
  801175:	5e                   	pop    %esi
  801176:	5d                   	pop    %ebp
  801177:	c3                   	ret    

00801178 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801178:	55                   	push   %ebp
  801179:	89 e5                	mov    %esp,%ebp
  80117b:	57                   	push   %edi
  80117c:	56                   	push   %esi
  80117d:	53                   	push   %ebx
  80117e:	83 ec 0c             	sub    $0xc,%esp
  801181:	8b 75 0c             	mov    0xc(%ebp),%esi
  801184:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801187:	8b 7d 14             	mov    0x14(%ebp),%edi
	if (!pg)
		pg = (void *) UTOP;
  80118a:	85 db                	test   %ebx,%ebx
  80118c:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801191:	0f 44 d8             	cmove  %eax,%ebx
	int r = sys_ipc_try_send(to_env, val, pg, perm);
  801194:	57                   	push   %edi
  801195:	53                   	push   %ebx
  801196:	56                   	push   %esi
  801197:	ff 75 08             	push   0x8(%ebp)
  80119a:	e8 88 fa ff ff       	call   800c27 <sys_ipc_try_send>
	while (r == -E_IPC_NOT_RECV) {
  80119f:	83 c4 10             	add    $0x10,%esp
  8011a2:	eb 13                	jmp    8011b7 <ipc_send+0x3f>
		sys_yield();
  8011a4:	e8 a4 f9 ff ff       	call   800b4d <sys_yield>
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8011a9:	57                   	push   %edi
  8011aa:	53                   	push   %ebx
  8011ab:	56                   	push   %esi
  8011ac:	ff 75 08             	push   0x8(%ebp)
  8011af:	e8 73 fa ff ff       	call   800c27 <sys_ipc_try_send>
  8011b4:	83 c4 10             	add    $0x10,%esp
	while (r == -E_IPC_NOT_RECV) {
  8011b7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8011ba:	74 e8                	je     8011a4 <ipc_send+0x2c>
	}

	if (r < 0)
  8011bc:	85 c0                	test   %eax,%eax
  8011be:	78 08                	js     8011c8 <ipc_send+0x50>
		panic("ipc_send: %e", r);
}
  8011c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011c3:	5b                   	pop    %ebx
  8011c4:	5e                   	pop    %esi
  8011c5:	5f                   	pop    %edi
  8011c6:	5d                   	pop    %ebp
  8011c7:	c3                   	ret    
		panic("ipc_send: %e", r);
  8011c8:	50                   	push   %eax
  8011c9:	68 db 19 80 00       	push   $0x8019db
  8011ce:	6a 3b                	push   $0x3b
  8011d0:	68 e8 19 80 00       	push   $0x8019e8
  8011d5:	e8 3f 00 00 00       	call   801219 <_panic>

008011da <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8011da:	55                   	push   %ebp
  8011db:	89 e5                	mov    %esp,%ebp
  8011dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8011e0:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8011e5:	69 d0 88 00 00 00    	imul   $0x88,%eax,%edx
  8011eb:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8011f1:	8b 52 50             	mov    0x50(%edx),%edx
  8011f4:	39 ca                	cmp    %ecx,%edx
  8011f6:	74 11                	je     801209 <ipc_find_env+0x2f>
	for (i = 0; i < NENV; i++)
  8011f8:	83 c0 01             	add    $0x1,%eax
  8011fb:	3d 00 04 00 00       	cmp    $0x400,%eax
  801200:	75 e3                	jne    8011e5 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801202:	b8 00 00 00 00       	mov    $0x0,%eax
  801207:	eb 0e                	jmp    801217 <ipc_find_env+0x3d>
			return envs[i].env_id;
  801209:	69 c0 88 00 00 00    	imul   $0x88,%eax,%eax
  80120f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801214:	8b 40 48             	mov    0x48(%eax),%eax
}
  801217:	5d                   	pop    %ebp
  801218:	c3                   	ret    

00801219 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801219:	55                   	push   %ebp
  80121a:	89 e5                	mov    %esp,%ebp
  80121c:	56                   	push   %esi
  80121d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80121e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801221:	8b 35 00 20 80 00    	mov    0x802000,%esi
  801227:	e8 fd f8 ff ff       	call   800b29 <sys_getenvid>
  80122c:	83 ec 0c             	sub    $0xc,%esp
  80122f:	ff 75 0c             	push   0xc(%ebp)
  801232:	ff 75 08             	push   0x8(%ebp)
  801235:	56                   	push   %esi
  801236:	50                   	push   %eax
  801237:	68 f4 19 80 00       	push   $0x8019f4
  80123c:	e8 b6 ef ff ff       	call   8001f7 <cprintf>
	        sys_getenvid(),
	        binaryname,
	        file,
	        line);
	vcprintf(fmt, ap);
  801241:	83 c4 18             	add    $0x18,%esp
  801244:	53                   	push   %ebx
  801245:	ff 75 10             	push   0x10(%ebp)
  801248:	e8 59 ef ff ff       	call   8001a6 <vcprintf>
	cprintf("\n");
  80124d:	c7 04 24 38 15 80 00 	movl   $0x801538,(%esp)
  801254:	e8 9e ef ff ff       	call   8001f7 <cprintf>
  801259:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80125c:	cc                   	int3   
  80125d:	eb fd                	jmp    80125c <_panic+0x43>

0080125f <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80125f:	55                   	push   %ebp
  801260:	89 e5                	mov    %esp,%ebp
  801262:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801265:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  80126c:	74 0a                	je     801278 <set_pgfault_handler+0x19>
		if (r < 0)
			return;
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80126e:	8b 45 08             	mov    0x8(%ebp),%eax
  801271:	a3 0c 20 80 00       	mov    %eax,0x80200c
}
  801276:	c9                   	leave  
  801277:	c3                   	ret    
		r = sys_page_alloc(0, (void *) exstk, perm);
  801278:	83 ec 04             	sub    $0x4,%esp
  80127b:	6a 07                	push   $0x7
  80127d:	68 00 f0 bf ee       	push   $0xeebff000
  801282:	6a 00                	push   $0x0
  801284:	e8 eb f8 ff ff       	call   800b74 <sys_page_alloc>
		if (r < 0)
  801289:	83 c4 10             	add    $0x10,%esp
  80128c:	85 c0                	test   %eax,%eax
  80128e:	78 e6                	js     801276 <set_pgfault_handler+0x17>
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801290:	83 ec 08             	sub    $0x8,%esp
  801293:	68 a8 12 80 00       	push   $0x8012a8
  801298:	6a 00                	push   $0x0
  80129a:	e8 65 f9 ff ff       	call   800c04 <sys_env_set_pgfault_upcall>
		if (r < 0)
  80129f:	83 c4 10             	add    $0x10,%esp
  8012a2:	85 c0                	test   %eax,%eax
  8012a4:	79 c8                	jns    80126e <set_pgfault_handler+0xf>
  8012a6:	eb ce                	jmp    801276 <set_pgfault_handler+0x17>

008012a8 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8012a8:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8012a9:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  8012ae:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8012b0:	83 c4 04             	add    $0x4,%esp
	// Throughout the remaining code, think carefully about what
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	movl 40(%esp), %eax	// trap-time %epi -> %eax 
  8012b3:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %ebx	// trap-time %esp -> %ebx
  8012b7:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4, %ebx
  8012bb:	83 eb 04             	sub    $0x4,%ebx
	movl %eax, 0(%ebx)	// push %eip in trap-time stack
  8012be:	89 03                	mov    %eax,(%ebx)

	movl %ebx, 48(%esp)
  8012c0:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	popl %eax
  8012c4:	58                   	pop    %eax
	popl %eax
  8012c5:	58                   	pop    %eax
	popal
  8012c6:	61                   	popa   
	

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	addl $4, %esp
  8012c7:	83 c4 04             	add    $0x4,%esp
	popfl
  8012ca:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	popl %esp
  8012cb:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	ret
  8012cc:	c3                   	ret    
  8012cd:	66 90                	xchg   %ax,%ax
  8012cf:	90                   	nop

008012d0 <__udivdi3>:
  8012d0:	f3 0f 1e fb          	endbr32 
  8012d4:	55                   	push   %ebp
  8012d5:	57                   	push   %edi
  8012d6:	56                   	push   %esi
  8012d7:	53                   	push   %ebx
  8012d8:	83 ec 1c             	sub    $0x1c,%esp
  8012db:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8012df:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8012e3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8012e7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8012eb:	85 c0                	test   %eax,%eax
  8012ed:	75 19                	jne    801308 <__udivdi3+0x38>
  8012ef:	39 f3                	cmp    %esi,%ebx
  8012f1:	76 4d                	jbe    801340 <__udivdi3+0x70>
  8012f3:	31 ff                	xor    %edi,%edi
  8012f5:	89 e8                	mov    %ebp,%eax
  8012f7:	89 f2                	mov    %esi,%edx
  8012f9:	f7 f3                	div    %ebx
  8012fb:	89 fa                	mov    %edi,%edx
  8012fd:	83 c4 1c             	add    $0x1c,%esp
  801300:	5b                   	pop    %ebx
  801301:	5e                   	pop    %esi
  801302:	5f                   	pop    %edi
  801303:	5d                   	pop    %ebp
  801304:	c3                   	ret    
  801305:	8d 76 00             	lea    0x0(%esi),%esi
  801308:	39 f0                	cmp    %esi,%eax
  80130a:	76 14                	jbe    801320 <__udivdi3+0x50>
  80130c:	31 ff                	xor    %edi,%edi
  80130e:	31 c0                	xor    %eax,%eax
  801310:	89 fa                	mov    %edi,%edx
  801312:	83 c4 1c             	add    $0x1c,%esp
  801315:	5b                   	pop    %ebx
  801316:	5e                   	pop    %esi
  801317:	5f                   	pop    %edi
  801318:	5d                   	pop    %ebp
  801319:	c3                   	ret    
  80131a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801320:	0f bd f8             	bsr    %eax,%edi
  801323:	83 f7 1f             	xor    $0x1f,%edi
  801326:	75 48                	jne    801370 <__udivdi3+0xa0>
  801328:	39 f0                	cmp    %esi,%eax
  80132a:	72 06                	jb     801332 <__udivdi3+0x62>
  80132c:	31 c0                	xor    %eax,%eax
  80132e:	39 eb                	cmp    %ebp,%ebx
  801330:	77 de                	ja     801310 <__udivdi3+0x40>
  801332:	b8 01 00 00 00       	mov    $0x1,%eax
  801337:	eb d7                	jmp    801310 <__udivdi3+0x40>
  801339:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801340:	89 d9                	mov    %ebx,%ecx
  801342:	85 db                	test   %ebx,%ebx
  801344:	75 0b                	jne    801351 <__udivdi3+0x81>
  801346:	b8 01 00 00 00       	mov    $0x1,%eax
  80134b:	31 d2                	xor    %edx,%edx
  80134d:	f7 f3                	div    %ebx
  80134f:	89 c1                	mov    %eax,%ecx
  801351:	31 d2                	xor    %edx,%edx
  801353:	89 f0                	mov    %esi,%eax
  801355:	f7 f1                	div    %ecx
  801357:	89 c6                	mov    %eax,%esi
  801359:	89 e8                	mov    %ebp,%eax
  80135b:	89 f7                	mov    %esi,%edi
  80135d:	f7 f1                	div    %ecx
  80135f:	89 fa                	mov    %edi,%edx
  801361:	83 c4 1c             	add    $0x1c,%esp
  801364:	5b                   	pop    %ebx
  801365:	5e                   	pop    %esi
  801366:	5f                   	pop    %edi
  801367:	5d                   	pop    %ebp
  801368:	c3                   	ret    
  801369:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801370:	89 f9                	mov    %edi,%ecx
  801372:	ba 20 00 00 00       	mov    $0x20,%edx
  801377:	29 fa                	sub    %edi,%edx
  801379:	d3 e0                	shl    %cl,%eax
  80137b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80137f:	89 d1                	mov    %edx,%ecx
  801381:	89 d8                	mov    %ebx,%eax
  801383:	d3 e8                	shr    %cl,%eax
  801385:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801389:	09 c1                	or     %eax,%ecx
  80138b:	89 f0                	mov    %esi,%eax
  80138d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801391:	89 f9                	mov    %edi,%ecx
  801393:	d3 e3                	shl    %cl,%ebx
  801395:	89 d1                	mov    %edx,%ecx
  801397:	d3 e8                	shr    %cl,%eax
  801399:	89 f9                	mov    %edi,%ecx
  80139b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80139f:	89 eb                	mov    %ebp,%ebx
  8013a1:	d3 e6                	shl    %cl,%esi
  8013a3:	89 d1                	mov    %edx,%ecx
  8013a5:	d3 eb                	shr    %cl,%ebx
  8013a7:	09 f3                	or     %esi,%ebx
  8013a9:	89 c6                	mov    %eax,%esi
  8013ab:	89 f2                	mov    %esi,%edx
  8013ad:	89 d8                	mov    %ebx,%eax
  8013af:	f7 74 24 08          	divl   0x8(%esp)
  8013b3:	89 d6                	mov    %edx,%esi
  8013b5:	89 c3                	mov    %eax,%ebx
  8013b7:	f7 64 24 0c          	mull   0xc(%esp)
  8013bb:	39 d6                	cmp    %edx,%esi
  8013bd:	72 19                	jb     8013d8 <__udivdi3+0x108>
  8013bf:	89 f9                	mov    %edi,%ecx
  8013c1:	d3 e5                	shl    %cl,%ebp
  8013c3:	39 c5                	cmp    %eax,%ebp
  8013c5:	73 04                	jae    8013cb <__udivdi3+0xfb>
  8013c7:	39 d6                	cmp    %edx,%esi
  8013c9:	74 0d                	je     8013d8 <__udivdi3+0x108>
  8013cb:	89 d8                	mov    %ebx,%eax
  8013cd:	31 ff                	xor    %edi,%edi
  8013cf:	e9 3c ff ff ff       	jmp    801310 <__udivdi3+0x40>
  8013d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013d8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8013db:	31 ff                	xor    %edi,%edi
  8013dd:	e9 2e ff ff ff       	jmp    801310 <__udivdi3+0x40>
  8013e2:	66 90                	xchg   %ax,%ax
  8013e4:	66 90                	xchg   %ax,%ax
  8013e6:	66 90                	xchg   %ax,%ax
  8013e8:	66 90                	xchg   %ax,%ax
  8013ea:	66 90                	xchg   %ax,%ax
  8013ec:	66 90                	xchg   %ax,%ax
  8013ee:	66 90                	xchg   %ax,%ax

008013f0 <__umoddi3>:
  8013f0:	f3 0f 1e fb          	endbr32 
  8013f4:	55                   	push   %ebp
  8013f5:	57                   	push   %edi
  8013f6:	56                   	push   %esi
  8013f7:	53                   	push   %ebx
  8013f8:	83 ec 1c             	sub    $0x1c,%esp
  8013fb:	8b 74 24 30          	mov    0x30(%esp),%esi
  8013ff:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801403:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  801407:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80140b:	89 f0                	mov    %esi,%eax
  80140d:	89 da                	mov    %ebx,%edx
  80140f:	85 ff                	test   %edi,%edi
  801411:	75 15                	jne    801428 <__umoddi3+0x38>
  801413:	39 dd                	cmp    %ebx,%ebp
  801415:	76 39                	jbe    801450 <__umoddi3+0x60>
  801417:	f7 f5                	div    %ebp
  801419:	89 d0                	mov    %edx,%eax
  80141b:	31 d2                	xor    %edx,%edx
  80141d:	83 c4 1c             	add    $0x1c,%esp
  801420:	5b                   	pop    %ebx
  801421:	5e                   	pop    %esi
  801422:	5f                   	pop    %edi
  801423:	5d                   	pop    %ebp
  801424:	c3                   	ret    
  801425:	8d 76 00             	lea    0x0(%esi),%esi
  801428:	39 df                	cmp    %ebx,%edi
  80142a:	77 f1                	ja     80141d <__umoddi3+0x2d>
  80142c:	0f bd cf             	bsr    %edi,%ecx
  80142f:	83 f1 1f             	xor    $0x1f,%ecx
  801432:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801436:	75 40                	jne    801478 <__umoddi3+0x88>
  801438:	39 df                	cmp    %ebx,%edi
  80143a:	72 04                	jb     801440 <__umoddi3+0x50>
  80143c:	39 f5                	cmp    %esi,%ebp
  80143e:	77 dd                	ja     80141d <__umoddi3+0x2d>
  801440:	89 da                	mov    %ebx,%edx
  801442:	89 f0                	mov    %esi,%eax
  801444:	29 e8                	sub    %ebp,%eax
  801446:	19 fa                	sbb    %edi,%edx
  801448:	eb d3                	jmp    80141d <__umoddi3+0x2d>
  80144a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801450:	89 e9                	mov    %ebp,%ecx
  801452:	85 ed                	test   %ebp,%ebp
  801454:	75 0b                	jne    801461 <__umoddi3+0x71>
  801456:	b8 01 00 00 00       	mov    $0x1,%eax
  80145b:	31 d2                	xor    %edx,%edx
  80145d:	f7 f5                	div    %ebp
  80145f:	89 c1                	mov    %eax,%ecx
  801461:	89 d8                	mov    %ebx,%eax
  801463:	31 d2                	xor    %edx,%edx
  801465:	f7 f1                	div    %ecx
  801467:	89 f0                	mov    %esi,%eax
  801469:	f7 f1                	div    %ecx
  80146b:	89 d0                	mov    %edx,%eax
  80146d:	31 d2                	xor    %edx,%edx
  80146f:	eb ac                	jmp    80141d <__umoddi3+0x2d>
  801471:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801478:	8b 44 24 04          	mov    0x4(%esp),%eax
  80147c:	ba 20 00 00 00       	mov    $0x20,%edx
  801481:	29 c2                	sub    %eax,%edx
  801483:	89 c1                	mov    %eax,%ecx
  801485:	89 e8                	mov    %ebp,%eax
  801487:	d3 e7                	shl    %cl,%edi
  801489:	89 d1                	mov    %edx,%ecx
  80148b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80148f:	d3 e8                	shr    %cl,%eax
  801491:	89 c1                	mov    %eax,%ecx
  801493:	8b 44 24 04          	mov    0x4(%esp),%eax
  801497:	09 f9                	or     %edi,%ecx
  801499:	89 df                	mov    %ebx,%edi
  80149b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80149f:	89 c1                	mov    %eax,%ecx
  8014a1:	d3 e5                	shl    %cl,%ebp
  8014a3:	89 d1                	mov    %edx,%ecx
  8014a5:	d3 ef                	shr    %cl,%edi
  8014a7:	89 c1                	mov    %eax,%ecx
  8014a9:	89 f0                	mov    %esi,%eax
  8014ab:	d3 e3                	shl    %cl,%ebx
  8014ad:	89 d1                	mov    %edx,%ecx
  8014af:	89 fa                	mov    %edi,%edx
  8014b1:	d3 e8                	shr    %cl,%eax
  8014b3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8014b8:	09 d8                	or     %ebx,%eax
  8014ba:	f7 74 24 08          	divl   0x8(%esp)
  8014be:	89 d3                	mov    %edx,%ebx
  8014c0:	d3 e6                	shl    %cl,%esi
  8014c2:	f7 e5                	mul    %ebp
  8014c4:	89 c7                	mov    %eax,%edi
  8014c6:	89 d1                	mov    %edx,%ecx
  8014c8:	39 d3                	cmp    %edx,%ebx
  8014ca:	72 06                	jb     8014d2 <__umoddi3+0xe2>
  8014cc:	75 0e                	jne    8014dc <__umoddi3+0xec>
  8014ce:	39 c6                	cmp    %eax,%esi
  8014d0:	73 0a                	jae    8014dc <__umoddi3+0xec>
  8014d2:	29 e8                	sub    %ebp,%eax
  8014d4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8014d8:	89 d1                	mov    %edx,%ecx
  8014da:	89 c7                	mov    %eax,%edi
  8014dc:	89 f5                	mov    %esi,%ebp
  8014de:	8b 74 24 04          	mov    0x4(%esp),%esi
  8014e2:	29 fd                	sub    %edi,%ebp
  8014e4:	19 cb                	sbb    %ecx,%ebx
  8014e6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8014eb:	89 d8                	mov    %ebx,%eax
  8014ed:	d3 e0                	shl    %cl,%eax
  8014ef:	89 f1                	mov    %esi,%ecx
  8014f1:	d3 ed                	shr    %cl,%ebp
  8014f3:	d3 eb                	shr    %cl,%ebx
  8014f5:	09 e8                	or     %ebp,%eax
  8014f7:	89 da                	mov    %ebx,%edx
  8014f9:	83 c4 1c             	add    $0x1c,%esp
  8014fc:	5b                   	pop    %ebx
  8014fd:	5e                   	pop    %esi
  8014fe:	5f                   	pop    %edi
  8014ff:	5d                   	pop    %ebp
  801500:	c3                   	ret    
