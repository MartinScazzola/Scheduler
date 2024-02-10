
obj/user/primes:     formato del fichero elf32-i386


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
  80002c:	e8 c3 00 00 00       	call   8000f4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003c:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80003f:	83 ec 04             	sub    $0x4,%esp
  800042:	6a 00                	push   $0x0
  800044:	6a 00                	push   $0x0
  800046:	56                   	push   %esi
  800047:	e8 01 11 00 00       	call   80114d <ipc_recv>
  80004c:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80004e:	a1 04 20 80 00       	mov    0x802004,%eax
  800053:	8b 40 5c             	mov    0x5c(%eax),%eax
  800056:	83 c4 0c             	add    $0xc,%esp
  800059:	53                   	push   %ebx
  80005a:	50                   	push   %eax
  80005b:	68 00 15 80 00       	push   $0x801500
  800060:	e8 c9 01 00 00       	call   80022e <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800065:	e8 a7 0f 00 00       	call   801011 <fork>
  80006a:	89 c7                	mov    %eax,%edi
  80006c:	83 c4 10             	add    $0x10,%esp
  80006f:	85 c0                	test   %eax,%eax
  800071:	78 2e                	js     8000a1 <primeproc+0x6e>
		panic("fork: %e", id);
	if (id == 0)
  800073:	74 ca                	je     80003f <primeproc+0xc>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  800075:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800078:	83 ec 04             	sub    $0x4,%esp
  80007b:	6a 00                	push   $0x0
  80007d:	6a 00                	push   $0x0
  80007f:	56                   	push   %esi
  800080:	e8 c8 10 00 00       	call   80114d <ipc_recv>
  800085:	89 c1                	mov    %eax,%ecx
		if (i % p)
  800087:	99                   	cltd   
  800088:	f7 fb                	idiv   %ebx
  80008a:	83 c4 10             	add    $0x10,%esp
  80008d:	85 d2                	test   %edx,%edx
  80008f:	74 e7                	je     800078 <primeproc+0x45>
			ipc_send(id, i, 0, 0);
  800091:	6a 00                	push   $0x0
  800093:	6a 00                	push   $0x0
  800095:	51                   	push   %ecx
  800096:	57                   	push   %edi
  800097:	e8 13 11 00 00       	call   8011af <ipc_send>
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	eb d7                	jmp    800078 <primeproc+0x45>
		panic("fork: %e", id);
  8000a1:	50                   	push   %eax
  8000a2:	68 65 19 80 00       	push   $0x801965
  8000a7:	6a 1a                	push   $0x1a
  8000a9:	68 0c 15 80 00       	push   $0x80150c
  8000ae:	e8 a0 00 00 00       	call   800153 <_panic>

008000b3 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000b3:	55                   	push   %ebp
  8000b4:	89 e5                	mov    %esp,%ebp
  8000b6:	56                   	push   %esi
  8000b7:	53                   	push   %ebx
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000b8:	e8 54 0f 00 00       	call   801011 <fork>
  8000bd:	89 c6                	mov    %eax,%esi
  8000bf:	85 c0                	test   %eax,%eax
  8000c1:	78 1a                	js     8000dd <umain+0x2a>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2;; i++)
  8000c3:	bb 02 00 00 00       	mov    $0x2,%ebx
	if (id == 0)
  8000c8:	74 25                	je     8000ef <umain+0x3c>
		ipc_send(id, i, 0, 0);
  8000ca:	6a 00                	push   $0x0
  8000cc:	6a 00                	push   $0x0
  8000ce:	53                   	push   %ebx
  8000cf:	56                   	push   %esi
  8000d0:	e8 da 10 00 00       	call   8011af <ipc_send>
	for (i = 2;; i++)
  8000d5:	83 c3 01             	add    $0x1,%ebx
  8000d8:	83 c4 10             	add    $0x10,%esp
  8000db:	eb ed                	jmp    8000ca <umain+0x17>
		panic("fork: %e", id);
  8000dd:	50                   	push   %eax
  8000de:	68 65 19 80 00       	push   $0x801965
  8000e3:	6a 2d                	push   $0x2d
  8000e5:	68 0c 15 80 00       	push   $0x80150c
  8000ea:	e8 64 00 00 00       	call   800153 <_panic>
		primeproc();
  8000ef:	e8 3f ff ff ff       	call   800033 <primeproc>

008000f4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f4:	55                   	push   %ebp
  8000f5:	89 e5                	mov    %esp,%ebp
  8000f7:	56                   	push   %esi
  8000f8:	53                   	push   %ebx
  8000f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000fc:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	envid_t id = sys_getenvid();
  8000ff:	e8 5c 0a 00 00       	call   800b60 <sys_getenvid>
	if (id >= 0)
  800104:	85 c0                	test   %eax,%eax
  800106:	78 15                	js     80011d <libmain+0x29>
		thisenv = &envs[ENVX(id)];
  800108:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010d:	69 c0 88 00 00 00    	imul   $0x88,%eax,%eax
  800113:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800118:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80011d:	85 db                	test   %ebx,%ebx
  80011f:	7e 07                	jle    800128 <libmain+0x34>
		binaryname = argv[0];
  800121:	8b 06                	mov    (%esi),%eax
  800123:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800128:	83 ec 08             	sub    $0x8,%esp
  80012b:	56                   	push   %esi
  80012c:	53                   	push   %ebx
  80012d:	e8 81 ff ff ff       	call   8000b3 <umain>

	// exit gracefully
	exit();
  800132:	e8 0a 00 00 00       	call   800141 <exit>
}
  800137:	83 c4 10             	add    $0x10,%esp
  80013a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80013d:	5b                   	pop    %ebx
  80013e:	5e                   	pop    %esi
  80013f:	5d                   	pop    %ebp
  800140:	c3                   	ret    

00800141 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800141:	55                   	push   %ebp
  800142:	89 e5                	mov    %esp,%ebp
  800144:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800147:	6a 00                	push   $0x0
  800149:	e8 f0 09 00 00       	call   800b3e <sys_env_destroy>
}
  80014e:	83 c4 10             	add    $0x10,%esp
  800151:	c9                   	leave  
  800152:	c3                   	ret    

00800153 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	56                   	push   %esi
  800157:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800158:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80015b:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800161:	e8 fa 09 00 00       	call   800b60 <sys_getenvid>
  800166:	83 ec 0c             	sub    $0xc,%esp
  800169:	ff 75 0c             	push   0xc(%ebp)
  80016c:	ff 75 08             	push   0x8(%ebp)
  80016f:	56                   	push   %esi
  800170:	50                   	push   %eax
  800171:	68 24 15 80 00       	push   $0x801524
  800176:	e8 b3 00 00 00       	call   80022e <cprintf>
	        sys_getenvid(),
	        binaryname,
	        file,
	        line);
	vcprintf(fmt, ap);
  80017b:	83 c4 18             	add    $0x18,%esp
  80017e:	53                   	push   %ebx
  80017f:	ff 75 10             	push   0x10(%ebp)
  800182:	e8 56 00 00 00       	call   8001dd <vcprintf>
	cprintf("\n");
  800187:	c7 04 24 47 15 80 00 	movl   $0x801547,(%esp)
  80018e:	e8 9b 00 00 00       	call   80022e <cprintf>
  800193:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800196:	cc                   	int3   
  800197:	eb fd                	jmp    800196 <_panic+0x43>

00800199 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	53                   	push   %ebx
  80019d:	83 ec 04             	sub    $0x4,%esp
  8001a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a3:	8b 13                	mov    (%ebx),%edx
  8001a5:	8d 42 01             	lea    0x1(%edx),%eax
  8001a8:	89 03                	mov    %eax,(%ebx)
  8001aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ad:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256 - 1) {
  8001b1:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001b6:	74 09                	je     8001c1 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001b8:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001bf:	c9                   	leave  
  8001c0:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001c1:	83 ec 08             	sub    $0x8,%esp
  8001c4:	68 ff 00 00 00       	push   $0xff
  8001c9:	8d 43 08             	lea    0x8(%ebx),%eax
  8001cc:	50                   	push   %eax
  8001cd:	e8 22 09 00 00       	call   800af4 <sys_cputs>
		b->idx = 0;
  8001d2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001d8:	83 c4 10             	add    $0x10,%esp
  8001db:	eb db                	jmp    8001b8 <putch+0x1f>

008001dd <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001dd:	55                   	push   %ebp
  8001de:	89 e5                	mov    %esp,%ebp
  8001e0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001e6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ed:	00 00 00 
	b.cnt = 0;
  8001f0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001f7:	00 00 00 
	vprintfmt((void *) putch, &b, fmt, ap);
  8001fa:	ff 75 0c             	push   0xc(%ebp)
  8001fd:	ff 75 08             	push   0x8(%ebp)
  800200:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800206:	50                   	push   %eax
  800207:	68 99 01 80 00       	push   $0x800199
  80020c:	e8 74 01 00 00       	call   800385 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800211:	83 c4 08             	add    $0x8,%esp
  800214:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  80021a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800220:	50                   	push   %eax
  800221:	e8 ce 08 00 00       	call   800af4 <sys_cputs>

	return b.cnt;
}
  800226:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80022c:	c9                   	leave  
  80022d:	c3                   	ret    

0080022e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80022e:	55                   	push   %ebp
  80022f:	89 e5                	mov    %esp,%ebp
  800231:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800234:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800237:	50                   	push   %eax
  800238:	ff 75 08             	push   0x8(%ebp)
  80023b:	e8 9d ff ff ff       	call   8001dd <vcprintf>
	va_end(ap);

	return cnt;
}
  800240:	c9                   	leave  
  800241:	c3                   	ret    

00800242 <printnum>:
         void *putdat,
         unsigned long long num,
         unsigned base,
         int width,
         int padc)
{
  800242:	55                   	push   %ebp
  800243:	89 e5                	mov    %esp,%ebp
  800245:	57                   	push   %edi
  800246:	56                   	push   %esi
  800247:	53                   	push   %ebx
  800248:	83 ec 1c             	sub    $0x1c,%esp
  80024b:	89 c7                	mov    %eax,%edi
  80024d:	89 d6                	mov    %edx,%esi
  80024f:	8b 45 08             	mov    0x8(%ebp),%eax
  800252:	8b 55 0c             	mov    0xc(%ebp),%edx
  800255:	89 d1                	mov    %edx,%ecx
  800257:	89 c2                	mov    %eax,%edx
  800259:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80025c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80025f:	8b 45 10             	mov    0x10(%ebp),%eax
  800262:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800265:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800268:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80026f:	39 c2                	cmp    %eax,%edx
  800271:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800274:	72 3e                	jb     8002b4 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800276:	83 ec 0c             	sub    $0xc,%esp
  800279:	ff 75 18             	push   0x18(%ebp)
  80027c:	83 eb 01             	sub    $0x1,%ebx
  80027f:	53                   	push   %ebx
  800280:	50                   	push   %eax
  800281:	83 ec 08             	sub    $0x8,%esp
  800284:	ff 75 e4             	push   -0x1c(%ebp)
  800287:	ff 75 e0             	push   -0x20(%ebp)
  80028a:	ff 75 dc             	push   -0x24(%ebp)
  80028d:	ff 75 d8             	push   -0x28(%ebp)
  800290:	e8 2b 10 00 00       	call   8012c0 <__udivdi3>
  800295:	83 c4 18             	add    $0x18,%esp
  800298:	52                   	push   %edx
  800299:	50                   	push   %eax
  80029a:	89 f2                	mov    %esi,%edx
  80029c:	89 f8                	mov    %edi,%eax
  80029e:	e8 9f ff ff ff       	call   800242 <printnum>
  8002a3:	83 c4 20             	add    $0x20,%esp
  8002a6:	eb 13                	jmp    8002bb <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002a8:	83 ec 08             	sub    $0x8,%esp
  8002ab:	56                   	push   %esi
  8002ac:	ff 75 18             	push   0x18(%ebp)
  8002af:	ff d7                	call   *%edi
  8002b1:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002b4:	83 eb 01             	sub    $0x1,%ebx
  8002b7:	85 db                	test   %ebx,%ebx
  8002b9:	7f ed                	jg     8002a8 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002bb:	83 ec 08             	sub    $0x8,%esp
  8002be:	56                   	push   %esi
  8002bf:	83 ec 04             	sub    $0x4,%esp
  8002c2:	ff 75 e4             	push   -0x1c(%ebp)
  8002c5:	ff 75 e0             	push   -0x20(%ebp)
  8002c8:	ff 75 dc             	push   -0x24(%ebp)
  8002cb:	ff 75 d8             	push   -0x28(%ebp)
  8002ce:	e8 0d 11 00 00       	call   8013e0 <__umoddi3>
  8002d3:	83 c4 14             	add    $0x14,%esp
  8002d6:	0f be 80 49 15 80 00 	movsbl 0x801549(%eax),%eax
  8002dd:	50                   	push   %eax
  8002de:	ff d7                	call   *%edi
}
  8002e0:	83 c4 10             	add    $0x10,%esp
  8002e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e6:	5b                   	pop    %ebx
  8002e7:	5e                   	pop    %esi
  8002e8:	5f                   	pop    %edi
  8002e9:	5d                   	pop    %ebp
  8002ea:	c3                   	ret    

008002eb <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8002eb:	83 fa 01             	cmp    $0x1,%edx
  8002ee:	7f 13                	jg     800303 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8002f0:	85 d2                	test   %edx,%edx
  8002f2:	74 1c                	je     800310 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  8002f4:	8b 10                	mov    (%eax),%edx
  8002f6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f9:	89 08                	mov    %ecx,(%eax)
  8002fb:	8b 02                	mov    (%edx),%eax
  8002fd:	ba 00 00 00 00       	mov    $0x0,%edx
  800302:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  800303:	8b 10                	mov    (%eax),%edx
  800305:	8d 4a 08             	lea    0x8(%edx),%ecx
  800308:	89 08                	mov    %ecx,(%eax)
  80030a:	8b 02                	mov    (%edx),%eax
  80030c:	8b 52 04             	mov    0x4(%edx),%edx
  80030f:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  800310:	8b 10                	mov    (%eax),%edx
  800312:	8d 4a 04             	lea    0x4(%edx),%ecx
  800315:	89 08                	mov    %ecx,(%eax)
  800317:	8b 02                	mov    (%edx),%eax
  800319:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80031e:	c3                   	ret    

0080031f <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80031f:	83 fa 01             	cmp    $0x1,%edx
  800322:	7f 0f                	jg     800333 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  800324:	85 d2                	test   %edx,%edx
  800326:	74 18                	je     800340 <getint+0x21>
		return va_arg(*ap, long);
  800328:	8b 10                	mov    (%eax),%edx
  80032a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80032d:	89 08                	mov    %ecx,(%eax)
  80032f:	8b 02                	mov    (%edx),%eax
  800331:	99                   	cltd   
  800332:	c3                   	ret    
		return va_arg(*ap, long long);
  800333:	8b 10                	mov    (%eax),%edx
  800335:	8d 4a 08             	lea    0x8(%edx),%ecx
  800338:	89 08                	mov    %ecx,(%eax)
  80033a:	8b 02                	mov    (%edx),%eax
  80033c:	8b 52 04             	mov    0x4(%edx),%edx
  80033f:	c3                   	ret    
	else
		return va_arg(*ap, int);
  800340:	8b 10                	mov    (%eax),%edx
  800342:	8d 4a 04             	lea    0x4(%edx),%ecx
  800345:	89 08                	mov    %ecx,(%eax)
  800347:	8b 02                	mov    (%edx),%eax
  800349:	99                   	cltd   
}
  80034a:	c3                   	ret    

0080034b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80034b:	55                   	push   %ebp
  80034c:	89 e5                	mov    %esp,%ebp
  80034e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800351:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800355:	8b 10                	mov    (%eax),%edx
  800357:	3b 50 04             	cmp    0x4(%eax),%edx
  80035a:	73 0a                	jae    800366 <sprintputch+0x1b>
		*b->buf++ = ch;
  80035c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80035f:	89 08                	mov    %ecx,(%eax)
  800361:	8b 45 08             	mov    0x8(%ebp),%eax
  800364:	88 02                	mov    %al,(%edx)
}
  800366:	5d                   	pop    %ebp
  800367:	c3                   	ret    

00800368 <printfmt>:
{
  800368:	55                   	push   %ebp
  800369:	89 e5                	mov    %esp,%ebp
  80036b:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80036e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800371:	50                   	push   %eax
  800372:	ff 75 10             	push   0x10(%ebp)
  800375:	ff 75 0c             	push   0xc(%ebp)
  800378:	ff 75 08             	push   0x8(%ebp)
  80037b:	e8 05 00 00 00       	call   800385 <vprintfmt>
}
  800380:	83 c4 10             	add    $0x10,%esp
  800383:	c9                   	leave  
  800384:	c3                   	ret    

00800385 <vprintfmt>:
{
  800385:	55                   	push   %ebp
  800386:	89 e5                	mov    %esp,%ebp
  800388:	57                   	push   %edi
  800389:	56                   	push   %esi
  80038a:	53                   	push   %ebx
  80038b:	83 ec 2c             	sub    $0x2c,%esp
  80038e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800391:	8b 75 0c             	mov    0xc(%ebp),%esi
  800394:	8b 7d 10             	mov    0x10(%ebp),%edi
  800397:	eb 0a                	jmp    8003a3 <vprintfmt+0x1e>
			putch(ch, putdat);
  800399:	83 ec 08             	sub    $0x8,%esp
  80039c:	56                   	push   %esi
  80039d:	50                   	push   %eax
  80039e:	ff d3                	call   *%ebx
  8003a0:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003a3:	83 c7 01             	add    $0x1,%edi
  8003a6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003aa:	83 f8 25             	cmp    $0x25,%eax
  8003ad:	74 0c                	je     8003bb <vprintfmt+0x36>
			if (ch == '\0')
  8003af:	85 c0                	test   %eax,%eax
  8003b1:	75 e6                	jne    800399 <vprintfmt+0x14>
}
  8003b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003b6:	5b                   	pop    %ebx
  8003b7:	5e                   	pop    %esi
  8003b8:	5f                   	pop    %edi
  8003b9:	5d                   	pop    %ebp
  8003ba:	c3                   	ret    
		padc = ' ';
  8003bb:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
		altflag = 0;
  8003bf:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8003c6:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8003cd:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003d4:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003d9:	8d 47 01             	lea    0x1(%edi),%eax
  8003dc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003df:	0f b6 17             	movzbl (%edi),%edx
  8003e2:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003e5:	3c 55                	cmp    $0x55,%al
  8003e7:	0f 87 b7 02 00 00    	ja     8006a4 <vprintfmt+0x31f>
  8003ed:	0f b6 c0             	movzbl %al,%eax
  8003f0:	ff 24 85 00 16 80 00 	jmp    *0x801600(,%eax,4)
  8003f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8003fa:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  8003fe:	eb d9                	jmp    8003d9 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800400:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800403:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800407:	eb d0                	jmp    8003d9 <vprintfmt+0x54>
  800409:	0f b6 d2             	movzbl %dl,%edx
  80040c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0;; ++fmt) {
  80040f:	b8 00 00 00 00       	mov    $0x0,%eax
  800414:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800417:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80041a:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80041e:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800421:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800424:	83 f9 09             	cmp    $0x9,%ecx
  800427:	77 52                	ja     80047b <vprintfmt+0xf6>
			for (precision = 0;; ++fmt) {
  800429:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80042c:	eb e9                	jmp    800417 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  80042e:	8b 45 14             	mov    0x14(%ebp),%eax
  800431:	8d 50 04             	lea    0x4(%eax),%edx
  800434:	89 55 14             	mov    %edx,0x14(%ebp)
  800437:	8b 00                	mov    (%eax),%eax
  800439:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80043c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80043f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800443:	79 94                	jns    8003d9 <vprintfmt+0x54>
				width = precision, precision = -1;
  800445:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800448:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80044b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800452:	eb 85                	jmp    8003d9 <vprintfmt+0x54>
  800454:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800457:	85 d2                	test   %edx,%edx
  800459:	b8 00 00 00 00       	mov    $0x0,%eax
  80045e:	0f 49 c2             	cmovns %edx,%eax
  800461:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800464:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800467:	e9 6d ff ff ff       	jmp    8003d9 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80046c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80046f:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800476:	e9 5e ff ff ff       	jmp    8003d9 <vprintfmt+0x54>
  80047b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80047e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800481:	eb bc                	jmp    80043f <vprintfmt+0xba>
			lflag++;
  800483:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800486:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800489:	e9 4b ff ff ff       	jmp    8003d9 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  80048e:	8b 45 14             	mov    0x14(%ebp),%eax
  800491:	8d 50 04             	lea    0x4(%eax),%edx
  800494:	89 55 14             	mov    %edx,0x14(%ebp)
  800497:	83 ec 08             	sub    $0x8,%esp
  80049a:	56                   	push   %esi
  80049b:	ff 30                	push   (%eax)
  80049d:	ff d3                	call   *%ebx
			break;
  80049f:	83 c4 10             	add    $0x10,%esp
  8004a2:	e9 94 01 00 00       	jmp    80063b <vprintfmt+0x2b6>
			err = va_arg(ap, int);
  8004a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004aa:	8d 50 04             	lea    0x4(%eax),%edx
  8004ad:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b0:	8b 10                	mov    (%eax),%edx
  8004b2:	89 d0                	mov    %edx,%eax
  8004b4:	f7 d8                	neg    %eax
  8004b6:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004b9:	83 f8 08             	cmp    $0x8,%eax
  8004bc:	7f 20                	jg     8004de <vprintfmt+0x159>
  8004be:	8b 14 85 60 17 80 00 	mov    0x801760(,%eax,4),%edx
  8004c5:	85 d2                	test   %edx,%edx
  8004c7:	74 15                	je     8004de <vprintfmt+0x159>
				printfmt(putch, putdat, "%s", p);
  8004c9:	52                   	push   %edx
  8004ca:	68 6a 15 80 00       	push   $0x80156a
  8004cf:	56                   	push   %esi
  8004d0:	53                   	push   %ebx
  8004d1:	e8 92 fe ff ff       	call   800368 <printfmt>
  8004d6:	83 c4 10             	add    $0x10,%esp
  8004d9:	e9 5d 01 00 00       	jmp    80063b <vprintfmt+0x2b6>
				printfmt(putch, putdat, "error %d", err);
  8004de:	50                   	push   %eax
  8004df:	68 61 15 80 00       	push   $0x801561
  8004e4:	56                   	push   %esi
  8004e5:	53                   	push   %ebx
  8004e6:	e8 7d fe ff ff       	call   800368 <printfmt>
  8004eb:	83 c4 10             	add    $0x10,%esp
  8004ee:	e9 48 01 00 00       	jmp    80063b <vprintfmt+0x2b6>
			if ((p = va_arg(ap, char *)) == NULL)
  8004f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f6:	8d 50 04             	lea    0x4(%eax),%edx
  8004f9:	89 55 14             	mov    %edx,0x14(%ebp)
  8004fc:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004fe:	85 ff                	test   %edi,%edi
  800500:	b8 5a 15 80 00       	mov    $0x80155a,%eax
  800505:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800508:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80050c:	7e 06                	jle    800514 <vprintfmt+0x18f>
  80050e:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  800512:	75 0a                	jne    80051e <vprintfmt+0x199>
  800514:	89 f8                	mov    %edi,%eax
  800516:	03 45 e0             	add    -0x20(%ebp),%eax
  800519:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80051c:	eb 59                	jmp    800577 <vprintfmt+0x1f2>
				for (width -= strnlen(p, precision); width > 0;
  80051e:	83 ec 08             	sub    $0x8,%esp
  800521:	ff 75 d8             	push   -0x28(%ebp)
  800524:	57                   	push   %edi
  800525:	e8 1a 02 00 00       	call   800744 <strnlen>
  80052a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80052d:	29 c1                	sub    %eax,%ecx
  80052f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800532:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800535:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  800539:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80053c:	89 7d d0             	mov    %edi,-0x30(%ebp)
  80053f:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0;
  800541:	eb 0f                	jmp    800552 <vprintfmt+0x1cd>
					putch(padc, putdat);
  800543:	83 ec 08             	sub    $0x8,%esp
  800546:	56                   	push   %esi
  800547:	ff 75 e0             	push   -0x20(%ebp)
  80054a:	ff d3                	call   *%ebx
				     width--)
  80054c:	83 ef 01             	sub    $0x1,%edi
  80054f:	83 c4 10             	add    $0x10,%esp
				for (width -= strnlen(p, precision); width > 0;
  800552:	85 ff                	test   %edi,%edi
  800554:	7f ed                	jg     800543 <vprintfmt+0x1be>
  800556:	8b 7d d0             	mov    -0x30(%ebp),%edi
  800559:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80055c:	85 c9                	test   %ecx,%ecx
  80055e:	b8 00 00 00 00       	mov    $0x0,%eax
  800563:	0f 49 c1             	cmovns %ecx,%eax
  800566:	29 c1                	sub    %eax,%ecx
  800568:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80056b:	eb a7                	jmp    800514 <vprintfmt+0x18f>
					putch(ch, putdat);
  80056d:	83 ec 08             	sub    $0x8,%esp
  800570:	56                   	push   %esi
  800571:	52                   	push   %edx
  800572:	ff d3                	call   *%ebx
  800574:	83 c4 10             	add    $0x10,%esp
  800577:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80057a:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' &&
  80057c:	83 c7 01             	add    $0x1,%edi
  80057f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800583:	0f be d0             	movsbl %al,%edx
  800586:	85 d2                	test   %edx,%edx
  800588:	74 42                	je     8005cc <vprintfmt+0x247>
  80058a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80058e:	78 06                	js     800596 <vprintfmt+0x211>
			       (precision < 0 || --precision >= 0);
  800590:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800594:	78 1e                	js     8005b4 <vprintfmt+0x22f>
				if (altflag && (ch < ' ' || ch > '~'))
  800596:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80059a:	74 d1                	je     80056d <vprintfmt+0x1e8>
  80059c:	0f be c0             	movsbl %al,%eax
  80059f:	83 e8 20             	sub    $0x20,%eax
  8005a2:	83 f8 5e             	cmp    $0x5e,%eax
  8005a5:	76 c6                	jbe    80056d <vprintfmt+0x1e8>
					putch('?', putdat);
  8005a7:	83 ec 08             	sub    $0x8,%esp
  8005aa:	56                   	push   %esi
  8005ab:	6a 3f                	push   $0x3f
  8005ad:	ff d3                	call   *%ebx
  8005af:	83 c4 10             	add    $0x10,%esp
  8005b2:	eb c3                	jmp    800577 <vprintfmt+0x1f2>
  8005b4:	89 cf                	mov    %ecx,%edi
  8005b6:	eb 0e                	jmp    8005c6 <vprintfmt+0x241>
				putch(' ', putdat);
  8005b8:	83 ec 08             	sub    $0x8,%esp
  8005bb:	56                   	push   %esi
  8005bc:	6a 20                	push   $0x20
  8005be:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  8005c0:	83 ef 01             	sub    $0x1,%edi
  8005c3:	83 c4 10             	add    $0x10,%esp
  8005c6:	85 ff                	test   %edi,%edi
  8005c8:	7f ee                	jg     8005b8 <vprintfmt+0x233>
  8005ca:	eb 6f                	jmp    80063b <vprintfmt+0x2b6>
  8005cc:	89 cf                	mov    %ecx,%edi
  8005ce:	eb f6                	jmp    8005c6 <vprintfmt+0x241>
			num = getint(&ap, lflag);
  8005d0:	89 ca                	mov    %ecx,%edx
  8005d2:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d5:	e8 45 fd ff ff       	call   80031f <getint>
  8005da:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005dd:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  8005e0:	85 d2                	test   %edx,%edx
  8005e2:	78 0b                	js     8005ef <vprintfmt+0x26a>
			num = getint(&ap, lflag);
  8005e4:	89 d1                	mov    %edx,%ecx
  8005e6:	89 c2                	mov    %eax,%edx
			base = 10;
  8005e8:	bf 0a 00 00 00       	mov    $0xa,%edi
  8005ed:	eb 32                	jmp    800621 <vprintfmt+0x29c>
				putch('-', putdat);
  8005ef:	83 ec 08             	sub    $0x8,%esp
  8005f2:	56                   	push   %esi
  8005f3:	6a 2d                	push   $0x2d
  8005f5:	ff d3                	call   *%ebx
				num = -(long long) num;
  8005f7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005fa:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005fd:	f7 da                	neg    %edx
  8005ff:	83 d1 00             	adc    $0x0,%ecx
  800602:	f7 d9                	neg    %ecx
  800604:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800607:	bf 0a 00 00 00       	mov    $0xa,%edi
  80060c:	eb 13                	jmp    800621 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  80060e:	89 ca                	mov    %ecx,%edx
  800610:	8d 45 14             	lea    0x14(%ebp),%eax
  800613:	e8 d3 fc ff ff       	call   8002eb <getuint>
  800618:	89 d1                	mov    %edx,%ecx
  80061a:	89 c2                	mov    %eax,%edx
			base = 10;
  80061c:	bf 0a 00 00 00       	mov    $0xa,%edi
			printnum(putch, putdat, num, base, width, padc);
  800621:	83 ec 0c             	sub    $0xc,%esp
  800624:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  800628:	50                   	push   %eax
  800629:	ff 75 e0             	push   -0x20(%ebp)
  80062c:	57                   	push   %edi
  80062d:	51                   	push   %ecx
  80062e:	52                   	push   %edx
  80062f:	89 f2                	mov    %esi,%edx
  800631:	89 d8                	mov    %ebx,%eax
  800633:	e8 0a fc ff ff       	call   800242 <printnum>
			break;
  800638:	83 c4 20             	add    $0x20,%esp
{
  80063b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80063e:	e9 60 fd ff ff       	jmp    8003a3 <vprintfmt+0x1e>
			num = getuint(&ap, lflag);
  800643:	89 ca                	mov    %ecx,%edx
  800645:	8d 45 14             	lea    0x14(%ebp),%eax
  800648:	e8 9e fc ff ff       	call   8002eb <getuint>
  80064d:	89 d1                	mov    %edx,%ecx
  80064f:	89 c2                	mov    %eax,%edx
			base = 8;
  800651:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  800656:	eb c9                	jmp    800621 <vprintfmt+0x29c>
			putch('0', putdat);
  800658:	83 ec 08             	sub    $0x8,%esp
  80065b:	56                   	push   %esi
  80065c:	6a 30                	push   $0x30
  80065e:	ff d3                	call   *%ebx
			putch('x', putdat);
  800660:	83 c4 08             	add    $0x8,%esp
  800663:	56                   	push   %esi
  800664:	6a 78                	push   $0x78
  800666:	ff d3                	call   *%ebx
			num = (unsigned long long) (uintptr_t) va_arg(ap, void *);
  800668:	8b 45 14             	mov    0x14(%ebp),%eax
  80066b:	8d 50 04             	lea    0x4(%eax),%edx
  80066e:	89 55 14             	mov    %edx,0x14(%ebp)
  800671:	8b 10                	mov    (%eax),%edx
  800673:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800678:	83 c4 10             	add    $0x10,%esp
			base = 16;
  80067b:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  800680:	eb 9f                	jmp    800621 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  800682:	89 ca                	mov    %ecx,%edx
  800684:	8d 45 14             	lea    0x14(%ebp),%eax
  800687:	e8 5f fc ff ff       	call   8002eb <getuint>
  80068c:	89 d1                	mov    %edx,%ecx
  80068e:	89 c2                	mov    %eax,%edx
			base = 16;
  800690:	bf 10 00 00 00       	mov    $0x10,%edi
  800695:	eb 8a                	jmp    800621 <vprintfmt+0x29c>
			putch(ch, putdat);
  800697:	83 ec 08             	sub    $0x8,%esp
  80069a:	56                   	push   %esi
  80069b:	6a 25                	push   $0x25
  80069d:	ff d3                	call   *%ebx
			break;
  80069f:	83 c4 10             	add    $0x10,%esp
  8006a2:	eb 97                	jmp    80063b <vprintfmt+0x2b6>
			putch('%', putdat);
  8006a4:	83 ec 08             	sub    $0x8,%esp
  8006a7:	56                   	push   %esi
  8006a8:	6a 25                	push   $0x25
  8006aa:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006ac:	83 c4 10             	add    $0x10,%esp
  8006af:	89 f8                	mov    %edi,%eax
  8006b1:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006b5:	74 05                	je     8006bc <vprintfmt+0x337>
  8006b7:	83 e8 01             	sub    $0x1,%eax
  8006ba:	eb f5                	jmp    8006b1 <vprintfmt+0x32c>
  8006bc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006bf:	e9 77 ff ff ff       	jmp    80063b <vprintfmt+0x2b6>

008006c4 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006c4:	55                   	push   %ebp
  8006c5:	89 e5                	mov    %esp,%ebp
  8006c7:	83 ec 18             	sub    $0x18,%esp
  8006ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8006cd:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = { buf, buf + n - 1, 0 };
  8006d0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006d3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006d7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006e1:	85 c0                	test   %eax,%eax
  8006e3:	74 26                	je     80070b <vsnprintf+0x47>
  8006e5:	85 d2                	test   %edx,%edx
  8006e7:	7e 22                	jle    80070b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *) sprintputch, &b, fmt, ap);
  8006e9:	ff 75 14             	push   0x14(%ebp)
  8006ec:	ff 75 10             	push   0x10(%ebp)
  8006ef:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006f2:	50                   	push   %eax
  8006f3:	68 4b 03 80 00       	push   $0x80034b
  8006f8:	e8 88 fc ff ff       	call   800385 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800700:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800703:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800706:	83 c4 10             	add    $0x10,%esp
}
  800709:	c9                   	leave  
  80070a:	c3                   	ret    
		return -E_INVAL;
  80070b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800710:	eb f7                	jmp    800709 <vsnprintf+0x45>

00800712 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800712:	55                   	push   %ebp
  800713:	89 e5                	mov    %esp,%ebp
  800715:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800718:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80071b:	50                   	push   %eax
  80071c:	ff 75 10             	push   0x10(%ebp)
  80071f:	ff 75 0c             	push   0xc(%ebp)
  800722:	ff 75 08             	push   0x8(%ebp)
  800725:	e8 9a ff ff ff       	call   8006c4 <vsnprintf>
	va_end(ap);

	return rc;
}
  80072a:	c9                   	leave  
  80072b:	c3                   	ret    

0080072c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80072c:	55                   	push   %ebp
  80072d:	89 e5                	mov    %esp,%ebp
  80072f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800732:	b8 00 00 00 00       	mov    $0x0,%eax
  800737:	eb 03                	jmp    80073c <strlen+0x10>
		n++;
  800739:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80073c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800740:	75 f7                	jne    800739 <strlen+0xd>
	return n;
}
  800742:	5d                   	pop    %ebp
  800743:	c3                   	ret    

00800744 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800744:	55                   	push   %ebp
  800745:	89 e5                	mov    %esp,%ebp
  800747:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80074a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80074d:	b8 00 00 00 00       	mov    $0x0,%eax
  800752:	eb 03                	jmp    800757 <strnlen+0x13>
		n++;
  800754:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800757:	39 d0                	cmp    %edx,%eax
  800759:	74 08                	je     800763 <strnlen+0x1f>
  80075b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80075f:	75 f3                	jne    800754 <strnlen+0x10>
  800761:	89 c2                	mov    %eax,%edx
	return n;
}
  800763:	89 d0                	mov    %edx,%eax
  800765:	5d                   	pop    %ebp
  800766:	c3                   	ret    

00800767 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800767:	55                   	push   %ebp
  800768:	89 e5                	mov    %esp,%ebp
  80076a:	53                   	push   %ebx
  80076b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80076e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800771:	b8 00 00 00 00       	mov    $0x0,%eax
  800776:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80077a:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  80077d:	83 c0 01             	add    $0x1,%eax
  800780:	84 d2                	test   %dl,%dl
  800782:	75 f2                	jne    800776 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800784:	89 c8                	mov    %ecx,%eax
  800786:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800789:	c9                   	leave  
  80078a:	c3                   	ret    

0080078b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80078b:	55                   	push   %ebp
  80078c:	89 e5                	mov    %esp,%ebp
  80078e:	53                   	push   %ebx
  80078f:	83 ec 10             	sub    $0x10,%esp
  800792:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800795:	53                   	push   %ebx
  800796:	e8 91 ff ff ff       	call   80072c <strlen>
  80079b:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80079e:	ff 75 0c             	push   0xc(%ebp)
  8007a1:	01 d8                	add    %ebx,%eax
  8007a3:	50                   	push   %eax
  8007a4:	e8 be ff ff ff       	call   800767 <strcpy>
	return dst;
}
  8007a9:	89 d8                	mov    %ebx,%eax
  8007ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007ae:	c9                   	leave  
  8007af:	c3                   	ret    

008007b0 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size)
{
  8007b0:	55                   	push   %ebp
  8007b1:	89 e5                	mov    %esp,%ebp
  8007b3:	56                   	push   %esi
  8007b4:	53                   	push   %ebx
  8007b5:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007bb:	89 f3                	mov    %esi,%ebx
  8007bd:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c0:	89 f0                	mov    %esi,%eax
  8007c2:	eb 0f                	jmp    8007d3 <strncpy+0x23>
		*dst++ = *src;
  8007c4:	83 c0 01             	add    $0x1,%eax
  8007c7:	0f b6 0a             	movzbl (%edx),%ecx
  8007ca:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007cd:	80 f9 01             	cmp    $0x1,%cl
  8007d0:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  8007d3:	39 d8                	cmp    %ebx,%eax
  8007d5:	75 ed                	jne    8007c4 <strncpy+0x14>
	}
	return ret;
}
  8007d7:	89 f0                	mov    %esi,%eax
  8007d9:	5b                   	pop    %ebx
  8007da:	5e                   	pop    %esi
  8007db:	5d                   	pop    %ebp
  8007dc:	c3                   	ret    

008007dd <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007dd:	55                   	push   %ebp
  8007de:	89 e5                	mov    %esp,%ebp
  8007e0:	56                   	push   %esi
  8007e1:	53                   	push   %ebx
  8007e2:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e8:	8b 55 10             	mov    0x10(%ebp),%edx
  8007eb:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007ed:	85 d2                	test   %edx,%edx
  8007ef:	74 21                	je     800812 <strlcpy+0x35>
  8007f1:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007f5:	89 f2                	mov    %esi,%edx
  8007f7:	eb 09                	jmp    800802 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007f9:	83 c1 01             	add    $0x1,%ecx
  8007fc:	83 c2 01             	add    $0x1,%edx
  8007ff:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800802:	39 c2                	cmp    %eax,%edx
  800804:	74 09                	je     80080f <strlcpy+0x32>
  800806:	0f b6 19             	movzbl (%ecx),%ebx
  800809:	84 db                	test   %bl,%bl
  80080b:	75 ec                	jne    8007f9 <strlcpy+0x1c>
  80080d:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80080f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800812:	29 f0                	sub    %esi,%eax
}
  800814:	5b                   	pop    %ebx
  800815:	5e                   	pop    %esi
  800816:	5d                   	pop    %ebp
  800817:	c3                   	ret    

00800818 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800818:	55                   	push   %ebp
  800819:	89 e5                	mov    %esp,%ebp
  80081b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80081e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800821:	eb 06                	jmp    800829 <strcmp+0x11>
		p++, q++;
  800823:	83 c1 01             	add    $0x1,%ecx
  800826:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800829:	0f b6 01             	movzbl (%ecx),%eax
  80082c:	84 c0                	test   %al,%al
  80082e:	74 04                	je     800834 <strcmp+0x1c>
  800830:	3a 02                	cmp    (%edx),%al
  800832:	74 ef                	je     800823 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800834:	0f b6 c0             	movzbl %al,%eax
  800837:	0f b6 12             	movzbl (%edx),%edx
  80083a:	29 d0                	sub    %edx,%eax
}
  80083c:	5d                   	pop    %ebp
  80083d:	c3                   	ret    

0080083e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80083e:	55                   	push   %ebp
  80083f:	89 e5                	mov    %esp,%ebp
  800841:	53                   	push   %ebx
  800842:	8b 45 08             	mov    0x8(%ebp),%eax
  800845:	8b 55 0c             	mov    0xc(%ebp),%edx
  800848:	89 c3                	mov    %eax,%ebx
  80084a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80084d:	eb 06                	jmp    800855 <strncmp+0x17>
		n--, p++, q++;
  80084f:	83 c0 01             	add    $0x1,%eax
  800852:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800855:	39 d8                	cmp    %ebx,%eax
  800857:	74 18                	je     800871 <strncmp+0x33>
  800859:	0f b6 08             	movzbl (%eax),%ecx
  80085c:	84 c9                	test   %cl,%cl
  80085e:	74 04                	je     800864 <strncmp+0x26>
  800860:	3a 0a                	cmp    (%edx),%cl
  800862:	74 eb                	je     80084f <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800864:	0f b6 00             	movzbl (%eax),%eax
  800867:	0f b6 12             	movzbl (%edx),%edx
  80086a:	29 d0                	sub    %edx,%eax
}
  80086c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80086f:	c9                   	leave  
  800870:	c3                   	ret    
		return 0;
  800871:	b8 00 00 00 00       	mov    $0x0,%eax
  800876:	eb f4                	jmp    80086c <strncmp+0x2e>

00800878 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800878:	55                   	push   %ebp
  800879:	89 e5                	mov    %esp,%ebp
  80087b:	8b 45 08             	mov    0x8(%ebp),%eax
  80087e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800882:	eb 03                	jmp    800887 <strchr+0xf>
  800884:	83 c0 01             	add    $0x1,%eax
  800887:	0f b6 10             	movzbl (%eax),%edx
  80088a:	84 d2                	test   %dl,%dl
  80088c:	74 06                	je     800894 <strchr+0x1c>
		if (*s == c)
  80088e:	38 ca                	cmp    %cl,%dl
  800890:	75 f2                	jne    800884 <strchr+0xc>
  800892:	eb 05                	jmp    800899 <strchr+0x21>
			return (char *) s;
	return 0;
  800894:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800899:	5d                   	pop    %ebp
  80089a:	c3                   	ret    

0080089b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80089b:	55                   	push   %ebp
  80089c:	89 e5                	mov    %esp,%ebp
  80089e:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a5:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008a8:	38 ca                	cmp    %cl,%dl
  8008aa:	74 09                	je     8008b5 <strfind+0x1a>
  8008ac:	84 d2                	test   %dl,%dl
  8008ae:	74 05                	je     8008b5 <strfind+0x1a>
	for (; *s; s++)
  8008b0:	83 c0 01             	add    $0x1,%eax
  8008b3:	eb f0                	jmp    8008a5 <strfind+0xa>
			break;
	return (char *) s;
}
  8008b5:	5d                   	pop    %ebp
  8008b6:	c3                   	ret    

008008b7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008b7:	55                   	push   %ebp
  8008b8:	89 e5                	mov    %esp,%ebp
  8008ba:	57                   	push   %edi
  8008bb:	56                   	push   %esi
  8008bc:	53                   	push   %ebx
  8008bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8008c0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  8008c3:	85 c9                	test   %ecx,%ecx
  8008c5:	74 33                	je     8008fa <memset+0x43>
		return v;
	if ((int) v % 4 == 0 && n % 4 == 0) {
  8008c7:	89 d0                	mov    %edx,%eax
  8008c9:	09 c8                	or     %ecx,%eax
  8008cb:	a8 03                	test   $0x3,%al
  8008cd:	75 23                	jne    8008f2 <memset+0x3b>
		c &= 0xFF;
  8008cf:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  8008d3:	89 d8                	mov    %ebx,%eax
  8008d5:	c1 e0 08             	shl    $0x8,%eax
  8008d8:	89 df                	mov    %ebx,%edi
  8008da:	c1 e7 18             	shl    $0x18,%edi
  8008dd:	89 de                	mov    %ebx,%esi
  8008df:	c1 e6 10             	shl    $0x10,%esi
  8008e2:	09 f7                	or     %esi,%edi
  8008e4:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
		             : "=D"(p), "=c"(n)
		             : "D"(p), "a"(c), "c"(n / 4)
  8008e6:	c1 e9 02             	shr    $0x2,%ecx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  8008e9:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  8008eb:	89 d7                	mov    %edx,%edi
  8008ed:	fc                   	cld    
  8008ee:	f3 ab                	rep stos %eax,%es:(%edi)
  8008f0:	eb 08                	jmp    8008fa <memset+0x43>
		             : "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008f2:	89 d7                	mov    %edx,%edi
  8008f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008f7:	fc                   	cld    
  8008f8:	f3 aa                	rep stos %al,%es:(%edi)
		             : "=D"(p), "=c"(n)
		             : "0"(p), "a"(c), "1"(n)
		             : "cc", "memory");
	return v;
}
  8008fa:	89 d0                	mov    %edx,%eax
  8008fc:	5b                   	pop    %ebx
  8008fd:	5e                   	pop    %esi
  8008fe:	5f                   	pop    %edi
  8008ff:	5d                   	pop    %ebp
  800900:	c3                   	ret    

00800901 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800901:	55                   	push   %ebp
  800902:	89 e5                	mov    %esp,%ebp
  800904:	57                   	push   %edi
  800905:	56                   	push   %esi
  800906:	8b 45 08             	mov    0x8(%ebp),%eax
  800909:	8b 75 0c             	mov    0xc(%ebp),%esi
  80090c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80090f:	39 c6                	cmp    %eax,%esi
  800911:	73 32                	jae    800945 <memmove+0x44>
  800913:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800916:	39 c2                	cmp    %eax,%edx
  800918:	76 2b                	jbe    800945 <memmove+0x44>
		s += n;
		d += n;
  80091a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  80091d:	89 d6                	mov    %edx,%esi
  80091f:	09 fe                	or     %edi,%esi
  800921:	09 ce                	or     %ecx,%esi
  800923:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800929:	75 0e                	jne    800939 <memmove+0x38>
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  80092b:	83 ef 04             	sub    $0x4,%edi
			             "S"(s - 4),
  80092e:	8d 72 fc             	lea    -0x4(%edx),%esi
			             "c"(n / 4)
  800931:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  800934:	fd                   	std    
  800935:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800937:	eb 09                	jmp    800942 <memmove+0x41>
			             : "cc", "memory");
		else
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  800939:	83 ef 01             	sub    $0x1,%edi
			             "S"(s - 1),
  80093c:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  80093f:	fd                   	std    
  800940:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             "c"(n)
			             : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800942:	fc                   	cld    
  800943:	eb 1a                	jmp    80095f <memmove+0x5e>
	} else {
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  800945:	89 f2                	mov    %esi,%edx
  800947:	09 c2                	or     %eax,%edx
  800949:	09 ca                	or     %ecx,%edx
  80094b:	f6 c2 03             	test   $0x3,%dl
  80094e:	75 0a                	jne    80095a <memmove+0x59>
			asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800950:	c1 e9 02             	shr    $0x2,%ecx
  800953:	89 c7                	mov    %eax,%edi
  800955:	fc                   	cld    
  800956:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800958:	eb 05                	jmp    80095f <memmove+0x5e>
			             : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  80095a:	89 c7                	mov    %eax,%edi
  80095c:	fc                   	cld    
  80095d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             : "cc", "memory");
	}
	return dst;
}
  80095f:	5e                   	pop    %esi
  800960:	5f                   	pop    %edi
  800961:	5d                   	pop    %ebp
  800962:	c3                   	ret    

00800963 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800963:	55                   	push   %ebp
  800964:	89 e5                	mov    %esp,%ebp
  800966:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800969:	ff 75 10             	push   0x10(%ebp)
  80096c:	ff 75 0c             	push   0xc(%ebp)
  80096f:	ff 75 08             	push   0x8(%ebp)
  800972:	e8 8a ff ff ff       	call   800901 <memmove>
}
  800977:	c9                   	leave  
  800978:	c3                   	ret    

00800979 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800979:	55                   	push   %ebp
  80097a:	89 e5                	mov    %esp,%ebp
  80097c:	56                   	push   %esi
  80097d:	53                   	push   %ebx
  80097e:	8b 45 08             	mov    0x8(%ebp),%eax
  800981:	8b 55 0c             	mov    0xc(%ebp),%edx
  800984:	89 c6                	mov    %eax,%esi
  800986:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800989:	eb 06                	jmp    800991 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  80098b:	83 c0 01             	add    $0x1,%eax
  80098e:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800991:	39 f0                	cmp    %esi,%eax
  800993:	74 14                	je     8009a9 <memcmp+0x30>
		if (*s1 != *s2)
  800995:	0f b6 08             	movzbl (%eax),%ecx
  800998:	0f b6 1a             	movzbl (%edx),%ebx
  80099b:	38 d9                	cmp    %bl,%cl
  80099d:	74 ec                	je     80098b <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  80099f:	0f b6 c1             	movzbl %cl,%eax
  8009a2:	0f b6 db             	movzbl %bl,%ebx
  8009a5:	29 d8                	sub    %ebx,%eax
  8009a7:	eb 05                	jmp    8009ae <memcmp+0x35>
	}

	return 0;
  8009a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ae:	5b                   	pop    %ebx
  8009af:	5e                   	pop    %esi
  8009b0:	5d                   	pop    %ebp
  8009b1:	c3                   	ret    

008009b2 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009b2:	55                   	push   %ebp
  8009b3:	89 e5                	mov    %esp,%ebp
  8009b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009bb:	89 c2                	mov    %eax,%edx
  8009bd:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009c0:	eb 03                	jmp    8009c5 <memfind+0x13>
  8009c2:	83 c0 01             	add    $0x1,%eax
  8009c5:	39 d0                	cmp    %edx,%eax
  8009c7:	73 04                	jae    8009cd <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009c9:	38 08                	cmp    %cl,(%eax)
  8009cb:	75 f5                	jne    8009c2 <memfind+0x10>
			break;
	return (void *) s;
}
  8009cd:	5d                   	pop    %ebp
  8009ce:	c3                   	ret    

008009cf <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009cf:	55                   	push   %ebp
  8009d0:	89 e5                	mov    %esp,%ebp
  8009d2:	57                   	push   %edi
  8009d3:	56                   	push   %esi
  8009d4:	53                   	push   %ebx
  8009d5:	8b 55 08             	mov    0x8(%ebp),%edx
  8009d8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009db:	eb 03                	jmp    8009e0 <strtol+0x11>
		s++;
  8009dd:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  8009e0:	0f b6 02             	movzbl (%edx),%eax
  8009e3:	3c 20                	cmp    $0x20,%al
  8009e5:	74 f6                	je     8009dd <strtol+0xe>
  8009e7:	3c 09                	cmp    $0x9,%al
  8009e9:	74 f2                	je     8009dd <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8009eb:	3c 2b                	cmp    $0x2b,%al
  8009ed:	74 2a                	je     800a19 <strtol+0x4a>
	int neg = 0;
  8009ef:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8009f4:	3c 2d                	cmp    $0x2d,%al
  8009f6:	74 2b                	je     800a23 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009f8:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009fe:	75 0f                	jne    800a0f <strtol+0x40>
  800a00:	80 3a 30             	cmpb   $0x30,(%edx)
  800a03:	74 28                	je     800a2d <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a05:	85 db                	test   %ebx,%ebx
  800a07:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a0c:	0f 44 d8             	cmove  %eax,%ebx
  800a0f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a14:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a17:	eb 46                	jmp    800a5f <strtol+0x90>
		s++;
  800a19:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800a1c:	bf 00 00 00 00       	mov    $0x0,%edi
  800a21:	eb d5                	jmp    8009f8 <strtol+0x29>
		s++, neg = 1;
  800a23:	83 c2 01             	add    $0x1,%edx
  800a26:	bf 01 00 00 00       	mov    $0x1,%edi
  800a2b:	eb cb                	jmp    8009f8 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a2d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a31:	74 0e                	je     800a41 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800a33:	85 db                	test   %ebx,%ebx
  800a35:	75 d8                	jne    800a0f <strtol+0x40>
		s++, base = 8;
  800a37:	83 c2 01             	add    $0x1,%edx
  800a3a:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a3f:	eb ce                	jmp    800a0f <strtol+0x40>
		s += 2, base = 16;
  800a41:	83 c2 02             	add    $0x2,%edx
  800a44:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a49:	eb c4                	jmp    800a0f <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a4b:	0f be c0             	movsbl %al,%eax
  800a4e:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a51:	3b 45 10             	cmp    0x10(%ebp),%eax
  800a54:	7d 3a                	jge    800a90 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800a56:	83 c2 01             	add    $0x1,%edx
  800a59:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800a5d:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800a5f:	0f b6 02             	movzbl (%edx),%eax
  800a62:	8d 70 d0             	lea    -0x30(%eax),%esi
  800a65:	89 f3                	mov    %esi,%ebx
  800a67:	80 fb 09             	cmp    $0x9,%bl
  800a6a:	76 df                	jbe    800a4b <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800a6c:	8d 70 9f             	lea    -0x61(%eax),%esi
  800a6f:	89 f3                	mov    %esi,%ebx
  800a71:	80 fb 19             	cmp    $0x19,%bl
  800a74:	77 08                	ja     800a7e <strtol+0xaf>
			dig = *s - 'a' + 10;
  800a76:	0f be c0             	movsbl %al,%eax
  800a79:	83 e8 57             	sub    $0x57,%eax
  800a7c:	eb d3                	jmp    800a51 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800a7e:	8d 70 bf             	lea    -0x41(%eax),%esi
  800a81:	89 f3                	mov    %esi,%ebx
  800a83:	80 fb 19             	cmp    $0x19,%bl
  800a86:	77 08                	ja     800a90 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800a88:	0f be c0             	movsbl %al,%eax
  800a8b:	83 e8 37             	sub    $0x37,%eax
  800a8e:	eb c1                	jmp    800a51 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a90:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a94:	74 05                	je     800a9b <strtol+0xcc>
		*endptr = (char *) s;
  800a96:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a99:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800a9b:	89 c8                	mov    %ecx,%eax
  800a9d:	f7 d8                	neg    %eax
  800a9f:	85 ff                	test   %edi,%edi
  800aa1:	0f 45 c8             	cmovne %eax,%ecx
}
  800aa4:	89 c8                	mov    %ecx,%eax
  800aa6:	5b                   	pop    %ebx
  800aa7:	5e                   	pop    %esi
  800aa8:	5f                   	pop    %edi
  800aa9:	5d                   	pop    %ebp
  800aaa:	c3                   	ret    

00800aab <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800aab:	55                   	push   %ebp
  800aac:	89 e5                	mov    %esp,%ebp
  800aae:	57                   	push   %edi
  800aaf:	56                   	push   %esi
  800ab0:	53                   	push   %ebx
  800ab1:	83 ec 1c             	sub    $0x1c,%esp
  800ab4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800ab7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800aba:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile(
  800abc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800abf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ac2:	8b 7d 10             	mov    0x10(%ebp),%edi
  800ac5:	8b 75 14             	mov    0x14(%ebp),%esi
  800ac8:	cd 30                	int    $0x30
	        "int %1\n"
	        : "=a"(ret)
	        : "i"(T_SYSCALL), "a"(num), "d"(a1), "c"(a2), "b"(a3), "D"(a4), "S"(a5)
	        : "cc", "memory");

	if (check && ret > 0)
  800aca:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ace:	74 04                	je     800ad4 <syscall+0x29>
  800ad0:	85 c0                	test   %eax,%eax
  800ad2:	7f 08                	jg     800adc <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800ad4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ad7:	5b                   	pop    %ebx
  800ad8:	5e                   	pop    %esi
  800ad9:	5f                   	pop    %edi
  800ada:	5d                   	pop    %ebp
  800adb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800adc:	83 ec 0c             	sub    $0xc,%esp
  800adf:	50                   	push   %eax
  800ae0:	ff 75 e0             	push   -0x20(%ebp)
  800ae3:	68 84 17 80 00       	push   $0x801784
  800ae8:	6a 1e                	push   $0x1e
  800aea:	68 a1 17 80 00       	push   $0x8017a1
  800aef:	e8 5f f6 ff ff       	call   800153 <_panic>

00800af4 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800af4:	55                   	push   %ebp
  800af5:	89 e5                	mov    %esp,%ebp
  800af7:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t) s, len, 0, 0, 0);
  800afa:	6a 00                	push   $0x0
  800afc:	6a 00                	push   $0x0
  800afe:	6a 00                	push   $0x0
  800b00:	ff 75 0c             	push   0xc(%ebp)
  800b03:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b06:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b10:	e8 96 ff ff ff       	call   800aab <syscall>
}
  800b15:	83 c4 10             	add    $0x10,%esp
  800b18:	c9                   	leave  
  800b19:	c3                   	ret    

00800b1a <sys_cgetc>:

int
sys_cgetc(void)
{
  800b1a:	55                   	push   %ebp
  800b1b:	89 e5                	mov    %esp,%ebp
  800b1d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800b20:	6a 00                	push   $0x0
  800b22:	6a 00                	push   $0x0
  800b24:	6a 00                	push   $0x0
  800b26:	6a 00                	push   $0x0
  800b28:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b2d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b32:	b8 01 00 00 00       	mov    $0x1,%eax
  800b37:	e8 6f ff ff ff       	call   800aab <syscall>
}
  800b3c:	c9                   	leave  
  800b3d:	c3                   	ret    

00800b3e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b3e:	55                   	push   %ebp
  800b3f:	89 e5                	mov    %esp,%ebp
  800b41:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800b44:	6a 00                	push   $0x0
  800b46:	6a 00                	push   $0x0
  800b48:	6a 00                	push   $0x0
  800b4a:	6a 00                	push   $0x0
  800b4c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b4f:	ba 01 00 00 00       	mov    $0x1,%edx
  800b54:	b8 03 00 00 00       	mov    $0x3,%eax
  800b59:	e8 4d ff ff ff       	call   800aab <syscall>
}
  800b5e:	c9                   	leave  
  800b5f:	c3                   	ret    

00800b60 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b60:	55                   	push   %ebp
  800b61:	89 e5                	mov    %esp,%ebp
  800b63:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800b66:	6a 00                	push   $0x0
  800b68:	6a 00                	push   $0x0
  800b6a:	6a 00                	push   $0x0
  800b6c:	6a 00                	push   $0x0
  800b6e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b73:	ba 00 00 00 00       	mov    $0x0,%edx
  800b78:	b8 02 00 00 00       	mov    $0x2,%eax
  800b7d:	e8 29 ff ff ff       	call   800aab <syscall>
}
  800b82:	c9                   	leave  
  800b83:	c3                   	ret    

00800b84 <sys_yield>:

void
sys_yield(void)
{
  800b84:	55                   	push   %ebp
  800b85:	89 e5                	mov    %esp,%ebp
  800b87:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800b8a:	6a 00                	push   $0x0
  800b8c:	6a 00                	push   $0x0
  800b8e:	6a 00                	push   $0x0
  800b90:	6a 00                	push   $0x0
  800b92:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b97:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ba1:	e8 05 ff ff ff       	call   800aab <syscall>
}
  800ba6:	83 c4 10             	add    $0x10,%esp
  800ba9:	c9                   	leave  
  800baa:	c3                   	ret    

00800bab <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bab:	55                   	push   %ebp
  800bac:	89 e5                	mov    %esp,%ebp
  800bae:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800bb1:	6a 00                	push   $0x0
  800bb3:	6a 00                	push   $0x0
  800bb5:	ff 75 10             	push   0x10(%ebp)
  800bb8:	ff 75 0c             	push   0xc(%ebp)
  800bbb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bbe:	ba 01 00 00 00       	mov    $0x1,%edx
  800bc3:	b8 04 00 00 00       	mov    $0x4,%eax
  800bc8:	e8 de fe ff ff       	call   800aab <syscall>
}
  800bcd:	c9                   	leave  
  800bce:	c3                   	ret    

00800bcf <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bcf:	55                   	push   %ebp
  800bd0:	89 e5                	mov    %esp,%ebp
  800bd2:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map,
  800bd5:	ff 75 18             	push   0x18(%ebp)
  800bd8:	ff 75 14             	push   0x14(%ebp)
  800bdb:	ff 75 10             	push   0x10(%ebp)
  800bde:	ff 75 0c             	push   0xc(%ebp)
  800be1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800be4:	ba 01 00 00 00       	mov    $0x1,%edx
  800be9:	b8 05 00 00 00       	mov    $0x5,%eax
  800bee:	e8 b8 fe ff ff       	call   800aab <syscall>
	               srcenv,
	               (uint32_t) srcva,
	               dstenv,
	               (uint32_t) dstva,
	               perm);
}
  800bf3:	c9                   	leave  
  800bf4:	c3                   	ret    

00800bf5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800bfb:	6a 00                	push   $0x0
  800bfd:	6a 00                	push   $0x0
  800bff:	6a 00                	push   $0x0
  800c01:	ff 75 0c             	push   0xc(%ebp)
  800c04:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c07:	ba 01 00 00 00       	mov    $0x1,%edx
  800c0c:	b8 06 00 00 00       	mov    $0x6,%eax
  800c11:	e8 95 fe ff ff       	call   800aab <syscall>
}
  800c16:	c9                   	leave  
  800c17:	c3                   	ret    

00800c18 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c18:	55                   	push   %ebp
  800c19:	89 e5                	mov    %esp,%ebp
  800c1b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800c1e:	6a 00                	push   $0x0
  800c20:	6a 00                	push   $0x0
  800c22:	6a 00                	push   $0x0
  800c24:	ff 75 0c             	push   0xc(%ebp)
  800c27:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c2a:	ba 01 00 00 00       	mov    $0x1,%edx
  800c2f:	b8 08 00 00 00       	mov    $0x8,%eax
  800c34:	e8 72 fe ff ff       	call   800aab <syscall>
}
  800c39:	c9                   	leave  
  800c3a:	c3                   	ret    

00800c3b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c3b:	55                   	push   %ebp
  800c3c:	89 e5                	mov    %esp,%ebp
  800c3e:	83 ec 08             	sub    $0x8,%esp
	return syscall(
  800c41:	6a 00                	push   $0x0
  800c43:	6a 00                	push   $0x0
  800c45:	6a 00                	push   $0x0
  800c47:	ff 75 0c             	push   0xc(%ebp)
  800c4a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c4d:	ba 01 00 00 00       	mov    $0x1,%edx
  800c52:	b8 09 00 00 00       	mov    $0x9,%eax
  800c57:	e8 4f fe ff ff       	call   800aab <syscall>
	        SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c5c:	c9                   	leave  
  800c5d:	c3                   	ret    

00800c5e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c5e:	55                   	push   %ebp
  800c5f:	89 e5                	mov    %esp,%ebp
  800c61:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800c64:	6a 00                	push   $0x0
  800c66:	ff 75 14             	push   0x14(%ebp)
  800c69:	ff 75 10             	push   0x10(%ebp)
  800c6c:	ff 75 0c             	push   0xc(%ebp)
  800c6f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c72:	ba 00 00 00 00       	mov    $0x0,%edx
  800c77:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c7c:	e8 2a fe ff ff       	call   800aab <syscall>
}
  800c81:	c9                   	leave  
  800c82:	c3                   	ret    

00800c83 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c83:	55                   	push   %ebp
  800c84:	89 e5                	mov    %esp,%ebp
  800c86:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t) dstva, 0, 0, 0, 0);
  800c89:	6a 00                	push   $0x0
  800c8b:	6a 00                	push   $0x0
  800c8d:	6a 00                	push   $0x0
  800c8f:	6a 00                	push   $0x0
  800c91:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c94:	ba 01 00 00 00       	mov    $0x1,%edx
  800c99:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c9e:	e8 08 fe ff ff       	call   800aab <syscall>
}
  800ca3:	c9                   	leave  
  800ca4:	c3                   	ret    

00800ca5 <sys_get_priority>:

// Get priority of the current process
int
sys_get_priority(void)
{
  800ca5:	55                   	push   %ebp
  800ca6:	89 e5                	mov    %esp,%ebp
  800ca8:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_get_priority, 0, 0, 0, 0, 0, 0);
  800cab:	6a 00                	push   $0x0
  800cad:	6a 00                	push   $0x0
  800caf:	6a 00                	push   $0x0
  800cb1:	6a 00                	push   $0x0
  800cb3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cb8:	ba 00 00 00 00       	mov    $0x0,%edx
  800cbd:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cc2:	e8 e4 fd ff ff       	call   800aab <syscall>
}
  800cc7:	c9                   	leave  
  800cc8:	c3                   	ret    

00800cc9 <sys_set_priority>:

// Get priority of the current process
int
sys_set_priority(unsigned int priority)
{
  800cc9:	55                   	push   %ebp
  800cca:	89 e5                	mov    %esp,%ebp
  800ccc:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, (uint32_t) priority, 0, 0, 0, 0);
  800ccf:	6a 00                	push   $0x0
  800cd1:	6a 00                	push   $0x0
  800cd3:	6a 00                	push   $0x0
  800cd5:	6a 00                	push   $0x0
  800cd7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cda:	ba 00 00 00 00       	mov    $0x0,%edx
  800cdf:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ce4:	e8 c2 fd ff ff       	call   800aab <syscall>
}
  800ce9:	c9                   	leave  
  800cea:	c3                   	ret    

00800ceb <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800ceb:	55                   	push   %ebp
  800cec:	89 e5                	mov    %esp,%ebp
  800cee:	56                   	push   %esi
  800cef:	53                   	push   %ebx
  800cf0:	89 c1                	mov    %eax,%ecx
	int r;

	void *addr = (void *) (pn << PGSHIFT);
  800cf2:	89 d6                	mov    %edx,%esi
  800cf4:	c1 e6 0c             	shl    $0xc,%esi

	pte_t pte = uvpt[pn];
  800cf7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx

	if (!(pte & PTE_P) || !(pte & PTE_U))
  800cfe:	89 d0                	mov    %edx,%eax
  800d00:	83 e0 05             	and    $0x5,%eax
  800d03:	83 f8 05             	cmp    $0x5,%eax
  800d06:	75 5a                	jne    800d62 <duppage+0x77>
		panic("duppage: copy a non-present or non-user page");

	int perm = PTE_U | PTE_P;
	// Verifico permisos para páginas de IO
	if (pte & (PTE_PCD | PTE_PWT))
  800d08:	89 d0                	mov    %edx,%eax
  800d0a:	83 e0 18             	and    $0x18,%eax
		perm |= PTE_PCD | PTE_PWT;
  800d0d:	83 f8 01             	cmp    $0x1,%eax
  800d10:	19 c0                	sbb    %eax,%eax
  800d12:	83 e0 e8             	and    $0xffffffe8,%eax
  800d15:	83 c0 1d             	add    $0x1d,%eax


	// Si es de escritura o copy-on-write y NO es de IO
	if ((pte & PTE_W) || (pte & PTE_COW)) {
  800d18:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800d1e:	74 68                	je     800d88 <duppage+0x9d>
		// Mappeo en el hijo la página
		if ((r = sys_page_map(0, addr, envid, addr, perm | PTE_COW)) < 0)
  800d20:	80 cc 08             	or     $0x8,%ah
  800d23:	89 c3                	mov    %eax,%ebx
  800d25:	83 ec 0c             	sub    $0xc,%esp
  800d28:	50                   	push   %eax
  800d29:	56                   	push   %esi
  800d2a:	51                   	push   %ecx
  800d2b:	56                   	push   %esi
  800d2c:	6a 00                	push   $0x0
  800d2e:	e8 9c fe ff ff       	call   800bcf <sys_page_map>
  800d33:	83 c4 20             	add    $0x20,%esp
  800d36:	85 c0                	test   %eax,%eax
  800d38:	78 3c                	js     800d76 <duppage+0x8b>
			panic("duppage: sys_page_map on childern COW: %e", r);

		// Cambio los permisos del padre
		if ((r = sys_page_map(0, addr, 0, addr, perm | PTE_COW)) < 0)
  800d3a:	83 ec 0c             	sub    $0xc,%esp
  800d3d:	53                   	push   %ebx
  800d3e:	56                   	push   %esi
  800d3f:	6a 00                	push   $0x0
  800d41:	56                   	push   %esi
  800d42:	6a 00                	push   $0x0
  800d44:	e8 86 fe ff ff       	call   800bcf <sys_page_map>
  800d49:	83 c4 20             	add    $0x20,%esp
  800d4c:	85 c0                	test   %eax,%eax
  800d4e:	79 4d                	jns    800d9d <duppage+0xb2>
			panic("duppage: sys_page_map on parent COW: %e", r);
  800d50:	50                   	push   %eax
  800d51:	68 0c 18 80 00       	push   $0x80180c
  800d56:	6a 57                	push   $0x57
  800d58:	68 01 19 80 00       	push   $0x801901
  800d5d:	e8 f1 f3 ff ff       	call   800153 <_panic>
		panic("duppage: copy a non-present or non-user page");
  800d62:	83 ec 04             	sub    $0x4,%esp
  800d65:	68 b0 17 80 00       	push   $0x8017b0
  800d6a:	6a 47                	push   $0x47
  800d6c:	68 01 19 80 00       	push   $0x801901
  800d71:	e8 dd f3 ff ff       	call   800153 <_panic>
			panic("duppage: sys_page_map on childern COW: %e", r);
  800d76:	50                   	push   %eax
  800d77:	68 e0 17 80 00       	push   $0x8017e0
  800d7c:	6a 53                	push   $0x53
  800d7e:	68 01 19 80 00       	push   $0x801901
  800d83:	e8 cb f3 ff ff       	call   800153 <_panic>
	} else {
		// Solo mappeo la página de solo lectura
		if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  800d88:	83 ec 0c             	sub    $0xc,%esp
  800d8b:	50                   	push   %eax
  800d8c:	56                   	push   %esi
  800d8d:	51                   	push   %ecx
  800d8e:	56                   	push   %esi
  800d8f:	6a 00                	push   $0x0
  800d91:	e8 39 fe ff ff       	call   800bcf <sys_page_map>
  800d96:	83 c4 20             	add    $0x20,%esp
  800d99:	85 c0                	test   %eax,%eax
  800d9b:	78 0c                	js     800da9 <duppage+0xbe>
			panic("duppage: sys_page_map on childern RO: %e", r);
	}

	// panic("duppage not implemented");
	return 0;
}
  800d9d:	b8 00 00 00 00       	mov    $0x0,%eax
  800da2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800da5:	5b                   	pop    %ebx
  800da6:	5e                   	pop    %esi
  800da7:	5d                   	pop    %ebp
  800da8:	c3                   	ret    
			panic("duppage: sys_page_map on childern RO: %e", r);
  800da9:	50                   	push   %eax
  800daa:	68 34 18 80 00       	push   $0x801834
  800daf:	6a 5b                	push   $0x5b
  800db1:	68 01 19 80 00       	push   $0x801901
  800db6:	e8 98 f3 ff ff       	call   800153 <_panic>

00800dbb <dup_or_share>:
 *
 * Hace uso de uvpd y uvpt para chequear permisos.
 */
static void
dup_or_share(envid_t envid, uint32_t pnum, int perm)
{
  800dbb:	55                   	push   %ebp
  800dbc:	89 e5                	mov    %esp,%ebp
  800dbe:	57                   	push   %edi
  800dbf:	56                   	push   %esi
  800dc0:	53                   	push   %ebx
  800dc1:	83 ec 0c             	sub    $0xc,%esp
  800dc4:	89 c7                	mov    %eax,%edi
	int r;
	void *addr = (void *) (pnum << PGSHIFT);

	pte_t pte = uvpt[pnum];
  800dc6:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax

	if (!(pte & PTE_P))
  800dcd:	a8 01                	test   $0x1,%al
  800dcf:	74 33                	je     800e04 <dup_or_share+0x49>
  800dd1:	89 d6                	mov    %edx,%esi
		return;

	// Filtro permisos
	perm &= (pte & PTE_W);
  800dd3:	21 c1                	and    %eax,%ecx
  800dd5:	89 cb                	mov    %ecx,%ebx
  800dd7:	83 e3 02             	and    $0x2,%ebx
	perm &= PTE_SYSCALL;


	if (pte & (PTE_PCD | PTE_PWT))
		perm |= PTE_PCD | PTE_PWT;
  800dda:	89 da                	mov    %ebx,%edx
  800ddc:	83 ca 18             	or     $0x18,%edx
  800ddf:	a8 18                	test   $0x18,%al
  800de1:	0f 45 da             	cmovne %edx,%ebx
	void *addr = (void *) (pnum << PGSHIFT);
  800de4:	c1 e6 0c             	shl    $0xc,%esi

	// Si tengo que copiar
	if (!(pte & PTE_W) || (pte & (PTE_PCD | PTE_PWT))) {
  800de7:	83 e0 1a             	and    $0x1a,%eax
  800dea:	83 f8 02             	cmp    $0x2,%eax
  800ded:	74 32                	je     800e21 <dup_or_share+0x66>
		if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  800def:	83 ec 0c             	sub    $0xc,%esp
  800df2:	53                   	push   %ebx
  800df3:	56                   	push   %esi
  800df4:	57                   	push   %edi
  800df5:	56                   	push   %esi
  800df6:	6a 00                	push   $0x0
  800df8:	e8 d2 fd ff ff       	call   800bcf <sys_page_map>
  800dfd:	83 c4 20             	add    $0x20,%esp
  800e00:	85 c0                	test   %eax,%eax
  800e02:	78 08                	js     800e0c <dup_or_share+0x51>
			panic("dup_or_share: sys_page_map: %e", r);
		memmove(UTEMP, addr, PGSIZE);
		if ((r = sys_page_unmap(0, UTEMP)) < 0)
			panic("sys_page_unmap: %e", r);
	}
}
  800e04:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e07:	5b                   	pop    %ebx
  800e08:	5e                   	pop    %esi
  800e09:	5f                   	pop    %edi
  800e0a:	5d                   	pop    %ebp
  800e0b:	c3                   	ret    
			panic("dup_or_share: sys_page_map: %e", r);
  800e0c:	50                   	push   %eax
  800e0d:	68 60 18 80 00       	push   $0x801860
  800e12:	68 84 00 00 00       	push   $0x84
  800e17:	68 01 19 80 00       	push   $0x801901
  800e1c:	e8 32 f3 ff ff       	call   800153 <_panic>
		if ((r = sys_page_alloc(envid, addr, perm)) < 0)
  800e21:	83 ec 04             	sub    $0x4,%esp
  800e24:	53                   	push   %ebx
  800e25:	56                   	push   %esi
  800e26:	57                   	push   %edi
  800e27:	e8 7f fd ff ff       	call   800bab <sys_page_alloc>
  800e2c:	83 c4 10             	add    $0x10,%esp
  800e2f:	85 c0                	test   %eax,%eax
  800e31:	78 57                	js     800e8a <dup_or_share+0xcf>
		if ((r = sys_page_map(envid, addr, 0, UTEMP, perm)) < 0)
  800e33:	83 ec 0c             	sub    $0xc,%esp
  800e36:	53                   	push   %ebx
  800e37:	68 00 00 40 00       	push   $0x400000
  800e3c:	6a 00                	push   $0x0
  800e3e:	56                   	push   %esi
  800e3f:	57                   	push   %edi
  800e40:	e8 8a fd ff ff       	call   800bcf <sys_page_map>
  800e45:	83 c4 20             	add    $0x20,%esp
  800e48:	85 c0                	test   %eax,%eax
  800e4a:	78 53                	js     800e9f <dup_or_share+0xe4>
		memmove(UTEMP, addr, PGSIZE);
  800e4c:	83 ec 04             	sub    $0x4,%esp
  800e4f:	68 00 10 00 00       	push   $0x1000
  800e54:	56                   	push   %esi
  800e55:	68 00 00 40 00       	push   $0x400000
  800e5a:	e8 a2 fa ff ff       	call   800901 <memmove>
		if ((r = sys_page_unmap(0, UTEMP)) < 0)
  800e5f:	83 c4 08             	add    $0x8,%esp
  800e62:	68 00 00 40 00       	push   $0x400000
  800e67:	6a 00                	push   $0x0
  800e69:	e8 87 fd ff ff       	call   800bf5 <sys_page_unmap>
  800e6e:	83 c4 10             	add    $0x10,%esp
  800e71:	85 c0                	test   %eax,%eax
  800e73:	79 8f                	jns    800e04 <dup_or_share+0x49>
			panic("sys_page_unmap: %e", r);
  800e75:	50                   	push   %eax
  800e76:	68 4b 19 80 00       	push   $0x80194b
  800e7b:	68 8d 00 00 00       	push   $0x8d
  800e80:	68 01 19 80 00       	push   $0x801901
  800e85:	e8 c9 f2 ff ff       	call   800153 <_panic>
			panic("dup_or_share: sys_page_alloc: %e", r);
  800e8a:	50                   	push   %eax
  800e8b:	68 80 18 80 00       	push   $0x801880
  800e90:	68 88 00 00 00       	push   $0x88
  800e95:	68 01 19 80 00       	push   $0x801901
  800e9a:	e8 b4 f2 ff ff       	call   800153 <_panic>
			panic("dup_or_share: sys_page_map: %e", r);
  800e9f:	50                   	push   %eax
  800ea0:	68 60 18 80 00       	push   $0x801860
  800ea5:	68 8a 00 00 00       	push   $0x8a
  800eaa:	68 01 19 80 00       	push   $0x801901
  800eaf:	e8 9f f2 ff ff       	call   800153 <_panic>

00800eb4 <pgfault>:
{
  800eb4:	55                   	push   %ebp
  800eb5:	89 e5                	mov    %esp,%ebp
  800eb7:	53                   	push   %ebx
  800eb8:	83 ec 08             	sub    $0x8,%esp
	void *addr = (void *) utf->utf_fault_va;
  800ebb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ebe:	8b 18                	mov    (%eax),%ebx
	pte_t fault_pte = uvpt[((uint32_t) addr) >> PGSHIFT];
  800ec0:	89 d8                	mov    %ebx,%eax
  800ec2:	c1 e8 0c             	shr    $0xc,%eax
  800ec5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if ((r = sys_page_alloc(0, PFTEMP, perm)) < 0)
  800ecc:	6a 07                	push   $0x7
  800ece:	68 00 f0 7f 00       	push   $0x7ff000
  800ed3:	6a 00                	push   $0x0
  800ed5:	e8 d1 fc ff ff       	call   800bab <sys_page_alloc>
  800eda:	83 c4 10             	add    $0x10,%esp
  800edd:	85 c0                	test   %eax,%eax
  800edf:	78 51                	js     800f32 <pgfault+0x7e>
	addr = ROUNDDOWN(addr, PGSIZE);
  800ee1:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr, PGSIZE);
  800ee7:	83 ec 04             	sub    $0x4,%esp
  800eea:	68 00 10 00 00       	push   $0x1000
  800eef:	53                   	push   %ebx
  800ef0:	68 00 f0 7f 00       	push   $0x7ff000
  800ef5:	e8 07 fa ff ff       	call   800901 <memmove>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, perm)) < 0)
  800efa:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f01:	53                   	push   %ebx
  800f02:	6a 00                	push   $0x0
  800f04:	68 00 f0 7f 00       	push   $0x7ff000
  800f09:	6a 00                	push   $0x0
  800f0b:	e8 bf fc ff ff       	call   800bcf <sys_page_map>
  800f10:	83 c4 20             	add    $0x20,%esp
  800f13:	85 c0                	test   %eax,%eax
  800f15:	78 2d                	js     800f44 <pgfault+0x90>
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800f17:	83 ec 08             	sub    $0x8,%esp
  800f1a:	68 00 f0 7f 00       	push   $0x7ff000
  800f1f:	6a 00                	push   $0x0
  800f21:	e8 cf fc ff ff       	call   800bf5 <sys_page_unmap>
  800f26:	83 c4 10             	add    $0x10,%esp
  800f29:	85 c0                	test   %eax,%eax
  800f2b:	78 29                	js     800f56 <pgfault+0xa2>
}
  800f2d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f30:	c9                   	leave  
  800f31:	c3                   	ret    
		panic("pgfault: sys_page_alloc: %e", r);
  800f32:	50                   	push   %eax
  800f33:	68 0c 19 80 00       	push   $0x80190c
  800f38:	6a 27                	push   $0x27
  800f3a:	68 01 19 80 00       	push   $0x801901
  800f3f:	e8 0f f2 ff ff       	call   800153 <_panic>
		panic("pgfault: sys_page_map: %e", r);
  800f44:	50                   	push   %eax
  800f45:	68 28 19 80 00       	push   $0x801928
  800f4a:	6a 2c                	push   $0x2c
  800f4c:	68 01 19 80 00       	push   $0x801901
  800f51:	e8 fd f1 ff ff       	call   800153 <_panic>
		panic("pgfault: sys_page_unmap: %e", r);
  800f56:	50                   	push   %eax
  800f57:	68 42 19 80 00       	push   $0x801942
  800f5c:	6a 2f                	push   $0x2f
  800f5e:	68 01 19 80 00       	push   $0x801901
  800f63:	e8 eb f1 ff ff       	call   800153 <_panic>

00800f68 <fork_v0>:
 *  	-- Para ello se utiliza la funcion dup_or_share()
 *  	-- Se copian todas las paginas desde 0 hasta UTOP
 */
envid_t
fork_v0(void)
{
  800f68:	55                   	push   %ebp
  800f69:	89 e5                	mov    %esp,%ebp
  800f6b:	56                   	push   %esi
  800f6c:	53                   	push   %ebx

// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline)) sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2" : "=a"(ret) : "a"(SYS_exofork), "i"(T_SYSCALL));
  800f6d:	b8 07 00 00 00       	mov    $0x7,%eax
  800f72:	cd 30                	int    $0x30
  800f74:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();
	if (envid < 0)
  800f76:	85 c0                	test   %eax,%eax
  800f78:	78 23                	js     800f9d <fork_v0+0x35>
	// Parent
	uint32_t pnum = 0;
	uint32_t pnum_end = (UTOP >> PGSHIFT);
	int perm = PTE_P | PTE_U | PTE_W;

	for (pnum = 0; pnum < pnum_end; pnum++) {
  800f7a:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid == 0) {
  800f7f:	75 3c                	jne    800fbd <fork_v0+0x55>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f81:	e8 da fb ff ff       	call   800b60 <sys_getenvid>
  800f86:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f8b:	69 c0 88 00 00 00    	imul   $0x88,%eax,%eax
  800f91:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f96:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800f9b:	eb 56                	jmp    800ff3 <fork_v0+0x8b>
		panic("sys_exofork: %e", envid);
  800f9d:	50                   	push   %eax
  800f9e:	68 5e 19 80 00       	push   $0x80195e
  800fa3:	68 a2 00 00 00       	push   $0xa2
  800fa8:	68 01 19 80 00       	push   $0x801901
  800fad:	e8 a1 f1 ff ff       	call   800153 <_panic>
	for (pnum = 0; pnum < pnum_end; pnum++) {
  800fb2:	83 c3 01             	add    $0x1,%ebx
  800fb5:	81 fb 00 ec 0e 00    	cmp    $0xeec00,%ebx
  800fbb:	74 24                	je     800fe1 <fork_v0+0x79>
		pde_t pde = uvpd[pnum >> 10];
  800fbd:	89 d8                	mov    %ebx,%eax
  800fbf:	c1 e8 0a             	shr    $0xa,%eax
  800fc2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
		if (!(pde & PTE_P) || !(pde & PTE_U))
  800fc9:	83 e0 05             	and    $0x5,%eax
  800fcc:	83 f8 05             	cmp    $0x5,%eax
  800fcf:	75 e1                	jne    800fb2 <fork_v0+0x4a>
			continue;
		dup_or_share(envid, pnum, perm);
  800fd1:	b9 07 00 00 00       	mov    $0x7,%ecx
  800fd6:	89 da                	mov    %ebx,%edx
  800fd8:	89 f0                	mov    %esi,%eax
  800fda:	e8 dc fd ff ff       	call   800dbb <dup_or_share>
  800fdf:	eb d1                	jmp    800fb2 <fork_v0+0x4a>
	}


	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800fe1:	83 ec 08             	sub    $0x8,%esp
  800fe4:	6a 02                	push   $0x2
  800fe6:	56                   	push   %esi
  800fe7:	e8 2c fc ff ff       	call   800c18 <sys_env_set_status>
  800fec:	83 c4 10             	add    $0x10,%esp
  800fef:	85 c0                	test   %eax,%eax
  800ff1:	78 09                	js     800ffc <fork_v0+0x94>
		panic("sys_env_set_status: %e", r);

	return envid;
}
  800ff3:	89 f0                	mov    %esi,%eax
  800ff5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ff8:	5b                   	pop    %ebx
  800ff9:	5e                   	pop    %esi
  800ffa:	5d                   	pop    %ebp
  800ffb:	c3                   	ret    
		panic("sys_env_set_status: %e", r);
  800ffc:	50                   	push   %eax
  800ffd:	68 6e 19 80 00       	push   $0x80196e
  801002:	68 b8 00 00 00       	push   $0xb8
  801007:	68 01 19 80 00       	push   $0x801901
  80100c:	e8 42 f1 ff ff       	call   800153 <_panic>

00801011 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801011:	55                   	push   %ebp
  801012:	89 e5                	mov    %esp,%ebp
  801014:	56                   	push   %esi
  801015:	53                   	push   %ebx
	set_pgfault_handler(pgfault);
  801016:	83 ec 0c             	sub    $0xc,%esp
  801019:	68 b4 0e 80 00       	push   $0x800eb4
  80101e:	e8 2d 02 00 00       	call   801250 <set_pgfault_handler>
  801023:	b8 07 00 00 00       	mov    $0x7,%eax
  801028:	cd 30                	int    $0x30
  80102a:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();

	if (envid < 0)
  80102c:	83 c4 10             	add    $0x10,%esp
  80102f:	85 c0                	test   %eax,%eax
  801031:	78 26                	js     801059 <fork+0x48>
	// Parent
	uint32_t pnum = 0;
	uint32_t pnum_end = (UTOP >> PGSHIFT);

	// Handle all pages below UTOP
	for (pnum = 0; pnum < pnum_end; pnum++) {
  801033:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid == 0) {
  801038:	75 41                	jne    80107b <fork+0x6a>
		thisenv = &envs[ENVX(sys_getenvid())];
  80103a:	e8 21 fb ff ff       	call   800b60 <sys_getenvid>
  80103f:	25 ff 03 00 00       	and    $0x3ff,%eax
  801044:	69 c0 88 00 00 00    	imul   $0x88,%eax,%eax
  80104a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80104f:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  801054:	e9 92 00 00 00       	jmp    8010eb <fork+0xda>
		panic("sys_exofork: %e", envid);
  801059:	50                   	push   %eax
  80105a:	68 5e 19 80 00       	push   $0x80195e
  80105f:	68 d5 00 00 00       	push   $0xd5
  801064:	68 01 19 80 00       	push   $0x801901
  801069:	e8 e5 f0 ff ff       	call   800153 <_panic>
	for (pnum = 0; pnum < pnum_end; pnum++) {
  80106e:	83 c3 01             	add    $0x1,%ebx
  801071:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  801077:	77 30                	ja     8010a9 <fork+0x98>
		if (pnum == ((UXSTACKTOP >> PGSHIFT) - 1))
  801079:	74 f3                	je     80106e <fork+0x5d>
			continue;

		pde_t pde = uvpd[pnum >> 10];
  80107b:	89 d8                	mov    %ebx,%eax
  80107d:	c1 e8 0a             	shr    $0xa,%eax
  801080:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
		if (!(pde & PTE_P) || !(pde & PTE_U))
  801087:	83 e0 05             	and    $0x5,%eax
  80108a:	83 f8 05             	cmp    $0x5,%eax
  80108d:	75 df                	jne    80106e <fork+0x5d>
			continue;

		pte_t pte = uvpt[pnum];
  80108f:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
		if (!(pte & PTE_P) || !(pte & PTE_U))
  801096:	83 e0 05             	and    $0x5,%eax
  801099:	83 f8 05             	cmp    $0x5,%eax
  80109c:	75 d0                	jne    80106e <fork+0x5d>
			continue;
		duppage(envid, pnum);
  80109e:	89 da                	mov    %ebx,%edx
  8010a0:	89 f0                	mov    %esi,%eax
  8010a2:	e8 44 fc ff ff       	call   800ceb <duppage>
  8010a7:	eb c5                	jmp    80106e <fork+0x5d>
	}

	uint32_t exstk = (UXSTACKTOP - PGSIZE);
	int r = sys_page_alloc(envid, (void *) exstk, PTE_U | PTE_P | PTE_W);
  8010a9:	83 ec 04             	sub    $0x4,%esp
  8010ac:	6a 07                	push   $0x7
  8010ae:	68 00 f0 bf ee       	push   $0xeebff000
  8010b3:	56                   	push   %esi
  8010b4:	e8 f2 fa ff ff       	call   800bab <sys_page_alloc>
	if (r < 0)
  8010b9:	83 c4 10             	add    $0x10,%esp
  8010bc:	85 c0                	test   %eax,%eax
  8010be:	78 34                	js     8010f4 <fork+0xe3>
		panic("fork: sys_page_alloc of exception stk: %e", r);
	r = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  8010c0:	a1 04 20 80 00       	mov    0x802004,%eax
  8010c5:	8b 40 70             	mov    0x70(%eax),%eax
  8010c8:	83 ec 08             	sub    $0x8,%esp
  8010cb:	50                   	push   %eax
  8010cc:	56                   	push   %esi
  8010cd:	e8 69 fb ff ff       	call   800c3b <sys_env_set_pgfault_upcall>
	if (r < 0)
  8010d2:	83 c4 10             	add    $0x10,%esp
  8010d5:	85 c0                	test   %eax,%eax
  8010d7:	78 30                	js     801109 <fork+0xf8>
		panic("fork: sys_env_set_pgfault_upcall on childern: %e", r);

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8010d9:	83 ec 08             	sub    $0x8,%esp
  8010dc:	6a 02                	push   $0x2
  8010de:	56                   	push   %esi
  8010df:	e8 34 fb ff ff       	call   800c18 <sys_env_set_status>
  8010e4:	83 c4 10             	add    $0x10,%esp
  8010e7:	85 c0                	test   %eax,%eax
  8010e9:	78 33                	js     80111e <fork+0x10d>
		panic("sys_env_set_status: %e", r);

	return envid;
}
  8010eb:	89 f0                	mov    %esi,%eax
  8010ed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010f0:	5b                   	pop    %ebx
  8010f1:	5e                   	pop    %esi
  8010f2:	5d                   	pop    %ebp
  8010f3:	c3                   	ret    
		panic("fork: sys_page_alloc of exception stk: %e", r);
  8010f4:	50                   	push   %eax
  8010f5:	68 a4 18 80 00       	push   $0x8018a4
  8010fa:	68 f2 00 00 00       	push   $0xf2
  8010ff:	68 01 19 80 00       	push   $0x801901
  801104:	e8 4a f0 ff ff       	call   800153 <_panic>
		panic("fork: sys_env_set_pgfault_upcall on childern: %e", r);
  801109:	50                   	push   %eax
  80110a:	68 d0 18 80 00       	push   $0x8018d0
  80110f:	68 f5 00 00 00       	push   $0xf5
  801114:	68 01 19 80 00       	push   $0x801901
  801119:	e8 35 f0 ff ff       	call   800153 <_panic>
		panic("sys_env_set_status: %e", r);
  80111e:	50                   	push   %eax
  80111f:	68 6e 19 80 00       	push   $0x80196e
  801124:	68 f8 00 00 00       	push   $0xf8
  801129:	68 01 19 80 00       	push   $0x801901
  80112e:	e8 20 f0 ff ff       	call   800153 <_panic>

00801133 <sfork>:

// Challenge!
int
sfork(void)
{
  801133:	55                   	push   %ebp
  801134:	89 e5                	mov    %esp,%ebp
  801136:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801139:	68 85 19 80 00       	push   $0x801985
  80113e:	68 01 01 00 00       	push   $0x101
  801143:	68 01 19 80 00       	push   $0x801901
  801148:	e8 06 f0 ff ff       	call   800153 <_panic>

0080114d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80114d:	55                   	push   %ebp
  80114e:	89 e5                	mov    %esp,%ebp
  801150:	56                   	push   %esi
  801151:	53                   	push   %ebx
  801152:	8b 75 08             	mov    0x8(%ebp),%esi
  801155:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int err = sys_ipc_recv(pg);
  801158:	83 ec 0c             	sub    $0xc,%esp
  80115b:	ff 75 0c             	push   0xc(%ebp)
  80115e:	e8 20 fb ff ff       	call   800c83 <sys_ipc_recv>

	if (from_env_store)
  801163:	83 c4 10             	add    $0x10,%esp
  801166:	85 f6                	test   %esi,%esi
  801168:	74 17                	je     801181 <ipc_recv+0x34>
		*from_env_store = (!err) ? thisenv->env_ipc_from : 0;
  80116a:	ba 00 00 00 00       	mov    $0x0,%edx
  80116f:	85 c0                	test   %eax,%eax
  801171:	75 0c                	jne    80117f <ipc_recv+0x32>
  801173:	8b 15 04 20 80 00    	mov    0x802004,%edx
  801179:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
  80117f:	89 16                	mov    %edx,(%esi)

	if (perm_store)
  801181:	85 db                	test   %ebx,%ebx
  801183:	74 17                	je     80119c <ipc_recv+0x4f>
		*perm_store = (!err) ? thisenv->env_ipc_perm : 0;
  801185:	ba 00 00 00 00       	mov    $0x0,%edx
  80118a:	85 c0                	test   %eax,%eax
  80118c:	75 0c                	jne    80119a <ipc_recv+0x4d>
  80118e:	8b 15 04 20 80 00    	mov    0x802004,%edx
  801194:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  80119a:	89 13                	mov    %edx,(%ebx)

	if (!err)
  80119c:	85 c0                	test   %eax,%eax
  80119e:	75 08                	jne    8011a8 <ipc_recv+0x5b>
		err = thisenv->env_ipc_value;
  8011a0:	a1 04 20 80 00       	mov    0x802004,%eax
  8011a5:	8b 40 7c             	mov    0x7c(%eax),%eax

	return err;
}
  8011a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011ab:	5b                   	pop    %ebx
  8011ac:	5e                   	pop    %esi
  8011ad:	5d                   	pop    %ebp
  8011ae:	c3                   	ret    

008011af <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8011af:	55                   	push   %ebp
  8011b0:	89 e5                	mov    %esp,%ebp
  8011b2:	57                   	push   %edi
  8011b3:	56                   	push   %esi
  8011b4:	53                   	push   %ebx
  8011b5:	83 ec 0c             	sub    $0xc,%esp
  8011b8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8011bb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011be:	8b 7d 14             	mov    0x14(%ebp),%edi
	if (!pg)
		pg = (void *) UTOP;
  8011c1:	85 db                	test   %ebx,%ebx
  8011c3:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8011c8:	0f 44 d8             	cmove  %eax,%ebx
	int r = sys_ipc_try_send(to_env, val, pg, perm);
  8011cb:	57                   	push   %edi
  8011cc:	53                   	push   %ebx
  8011cd:	56                   	push   %esi
  8011ce:	ff 75 08             	push   0x8(%ebp)
  8011d1:	e8 88 fa ff ff       	call   800c5e <sys_ipc_try_send>
	while (r == -E_IPC_NOT_RECV) {
  8011d6:	83 c4 10             	add    $0x10,%esp
  8011d9:	eb 13                	jmp    8011ee <ipc_send+0x3f>
		sys_yield();
  8011db:	e8 a4 f9 ff ff       	call   800b84 <sys_yield>
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8011e0:	57                   	push   %edi
  8011e1:	53                   	push   %ebx
  8011e2:	56                   	push   %esi
  8011e3:	ff 75 08             	push   0x8(%ebp)
  8011e6:	e8 73 fa ff ff       	call   800c5e <sys_ipc_try_send>
  8011eb:	83 c4 10             	add    $0x10,%esp
	while (r == -E_IPC_NOT_RECV) {
  8011ee:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8011f1:	74 e8                	je     8011db <ipc_send+0x2c>
	}

	if (r < 0)
  8011f3:	85 c0                	test   %eax,%eax
  8011f5:	78 08                	js     8011ff <ipc_send+0x50>
		panic("ipc_send: %e", r);
}
  8011f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011fa:	5b                   	pop    %ebx
  8011fb:	5e                   	pop    %esi
  8011fc:	5f                   	pop    %edi
  8011fd:	5d                   	pop    %ebp
  8011fe:	c3                   	ret    
		panic("ipc_send: %e", r);
  8011ff:	50                   	push   %eax
  801200:	68 9b 19 80 00       	push   $0x80199b
  801205:	6a 3b                	push   $0x3b
  801207:	68 a8 19 80 00       	push   $0x8019a8
  80120c:	e8 42 ef ff ff       	call   800153 <_panic>

00801211 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801211:	55                   	push   %ebp
  801212:	89 e5                	mov    %esp,%ebp
  801214:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801217:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80121c:	69 d0 88 00 00 00    	imul   $0x88,%eax,%edx
  801222:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801228:	8b 52 50             	mov    0x50(%edx),%edx
  80122b:	39 ca                	cmp    %ecx,%edx
  80122d:	74 11                	je     801240 <ipc_find_env+0x2f>
	for (i = 0; i < NENV; i++)
  80122f:	83 c0 01             	add    $0x1,%eax
  801232:	3d 00 04 00 00       	cmp    $0x400,%eax
  801237:	75 e3                	jne    80121c <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801239:	b8 00 00 00 00       	mov    $0x0,%eax
  80123e:	eb 0e                	jmp    80124e <ipc_find_env+0x3d>
			return envs[i].env_id;
  801240:	69 c0 88 00 00 00    	imul   $0x88,%eax,%eax
  801246:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80124b:	8b 40 48             	mov    0x48(%eax),%eax
}
  80124e:	5d                   	pop    %ebp
  80124f:	c3                   	ret    

00801250 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801250:	55                   	push   %ebp
  801251:	89 e5                	mov    %esp,%ebp
  801253:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801256:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  80125d:	74 0a                	je     801269 <set_pgfault_handler+0x19>
		if (r < 0)
			return;
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80125f:	8b 45 08             	mov    0x8(%ebp),%eax
  801262:	a3 08 20 80 00       	mov    %eax,0x802008
}
  801267:	c9                   	leave  
  801268:	c3                   	ret    
		r = sys_page_alloc(0, (void *) exstk, perm);
  801269:	83 ec 04             	sub    $0x4,%esp
  80126c:	6a 07                	push   $0x7
  80126e:	68 00 f0 bf ee       	push   $0xeebff000
  801273:	6a 00                	push   $0x0
  801275:	e8 31 f9 ff ff       	call   800bab <sys_page_alloc>
		if (r < 0)
  80127a:	83 c4 10             	add    $0x10,%esp
  80127d:	85 c0                	test   %eax,%eax
  80127f:	78 e6                	js     801267 <set_pgfault_handler+0x17>
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801281:	83 ec 08             	sub    $0x8,%esp
  801284:	68 99 12 80 00       	push   $0x801299
  801289:	6a 00                	push   $0x0
  80128b:	e8 ab f9 ff ff       	call   800c3b <sys_env_set_pgfault_upcall>
		if (r < 0)
  801290:	83 c4 10             	add    $0x10,%esp
  801293:	85 c0                	test   %eax,%eax
  801295:	79 c8                	jns    80125f <set_pgfault_handler+0xf>
  801297:	eb ce                	jmp    801267 <set_pgfault_handler+0x17>

00801299 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801299:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80129a:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  80129f:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8012a1:	83 c4 04             	add    $0x4,%esp
	// Throughout the remaining code, think carefully about what
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	movl 40(%esp), %eax	// trap-time %epi -> %eax 
  8012a4:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %ebx	// trap-time %esp -> %ebx
  8012a8:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4, %ebx
  8012ac:	83 eb 04             	sub    $0x4,%ebx
	movl %eax, 0(%ebx)	// push %eip in trap-time stack
  8012af:	89 03                	mov    %eax,(%ebx)

	movl %ebx, 48(%esp)
  8012b1:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	popl %eax
  8012b5:	58                   	pop    %eax
	popl %eax
  8012b6:	58                   	pop    %eax
	popal
  8012b7:	61                   	popa   
	

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	addl $4, %esp
  8012b8:	83 c4 04             	add    $0x4,%esp
	popfl
  8012bb:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	popl %esp
  8012bc:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	ret
  8012bd:	c3                   	ret    
  8012be:	66 90                	xchg   %ax,%ax

008012c0 <__udivdi3>:
  8012c0:	f3 0f 1e fb          	endbr32 
  8012c4:	55                   	push   %ebp
  8012c5:	57                   	push   %edi
  8012c6:	56                   	push   %esi
  8012c7:	53                   	push   %ebx
  8012c8:	83 ec 1c             	sub    $0x1c,%esp
  8012cb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8012cf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8012d3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8012d7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8012db:	85 c0                	test   %eax,%eax
  8012dd:	75 19                	jne    8012f8 <__udivdi3+0x38>
  8012df:	39 f3                	cmp    %esi,%ebx
  8012e1:	76 4d                	jbe    801330 <__udivdi3+0x70>
  8012e3:	31 ff                	xor    %edi,%edi
  8012e5:	89 e8                	mov    %ebp,%eax
  8012e7:	89 f2                	mov    %esi,%edx
  8012e9:	f7 f3                	div    %ebx
  8012eb:	89 fa                	mov    %edi,%edx
  8012ed:	83 c4 1c             	add    $0x1c,%esp
  8012f0:	5b                   	pop    %ebx
  8012f1:	5e                   	pop    %esi
  8012f2:	5f                   	pop    %edi
  8012f3:	5d                   	pop    %ebp
  8012f4:	c3                   	ret    
  8012f5:	8d 76 00             	lea    0x0(%esi),%esi
  8012f8:	39 f0                	cmp    %esi,%eax
  8012fa:	76 14                	jbe    801310 <__udivdi3+0x50>
  8012fc:	31 ff                	xor    %edi,%edi
  8012fe:	31 c0                	xor    %eax,%eax
  801300:	89 fa                	mov    %edi,%edx
  801302:	83 c4 1c             	add    $0x1c,%esp
  801305:	5b                   	pop    %ebx
  801306:	5e                   	pop    %esi
  801307:	5f                   	pop    %edi
  801308:	5d                   	pop    %ebp
  801309:	c3                   	ret    
  80130a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801310:	0f bd f8             	bsr    %eax,%edi
  801313:	83 f7 1f             	xor    $0x1f,%edi
  801316:	75 48                	jne    801360 <__udivdi3+0xa0>
  801318:	39 f0                	cmp    %esi,%eax
  80131a:	72 06                	jb     801322 <__udivdi3+0x62>
  80131c:	31 c0                	xor    %eax,%eax
  80131e:	39 eb                	cmp    %ebp,%ebx
  801320:	77 de                	ja     801300 <__udivdi3+0x40>
  801322:	b8 01 00 00 00       	mov    $0x1,%eax
  801327:	eb d7                	jmp    801300 <__udivdi3+0x40>
  801329:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801330:	89 d9                	mov    %ebx,%ecx
  801332:	85 db                	test   %ebx,%ebx
  801334:	75 0b                	jne    801341 <__udivdi3+0x81>
  801336:	b8 01 00 00 00       	mov    $0x1,%eax
  80133b:	31 d2                	xor    %edx,%edx
  80133d:	f7 f3                	div    %ebx
  80133f:	89 c1                	mov    %eax,%ecx
  801341:	31 d2                	xor    %edx,%edx
  801343:	89 f0                	mov    %esi,%eax
  801345:	f7 f1                	div    %ecx
  801347:	89 c6                	mov    %eax,%esi
  801349:	89 e8                	mov    %ebp,%eax
  80134b:	89 f7                	mov    %esi,%edi
  80134d:	f7 f1                	div    %ecx
  80134f:	89 fa                	mov    %edi,%edx
  801351:	83 c4 1c             	add    $0x1c,%esp
  801354:	5b                   	pop    %ebx
  801355:	5e                   	pop    %esi
  801356:	5f                   	pop    %edi
  801357:	5d                   	pop    %ebp
  801358:	c3                   	ret    
  801359:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801360:	89 f9                	mov    %edi,%ecx
  801362:	ba 20 00 00 00       	mov    $0x20,%edx
  801367:	29 fa                	sub    %edi,%edx
  801369:	d3 e0                	shl    %cl,%eax
  80136b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80136f:	89 d1                	mov    %edx,%ecx
  801371:	89 d8                	mov    %ebx,%eax
  801373:	d3 e8                	shr    %cl,%eax
  801375:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801379:	09 c1                	or     %eax,%ecx
  80137b:	89 f0                	mov    %esi,%eax
  80137d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801381:	89 f9                	mov    %edi,%ecx
  801383:	d3 e3                	shl    %cl,%ebx
  801385:	89 d1                	mov    %edx,%ecx
  801387:	d3 e8                	shr    %cl,%eax
  801389:	89 f9                	mov    %edi,%ecx
  80138b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80138f:	89 eb                	mov    %ebp,%ebx
  801391:	d3 e6                	shl    %cl,%esi
  801393:	89 d1                	mov    %edx,%ecx
  801395:	d3 eb                	shr    %cl,%ebx
  801397:	09 f3                	or     %esi,%ebx
  801399:	89 c6                	mov    %eax,%esi
  80139b:	89 f2                	mov    %esi,%edx
  80139d:	89 d8                	mov    %ebx,%eax
  80139f:	f7 74 24 08          	divl   0x8(%esp)
  8013a3:	89 d6                	mov    %edx,%esi
  8013a5:	89 c3                	mov    %eax,%ebx
  8013a7:	f7 64 24 0c          	mull   0xc(%esp)
  8013ab:	39 d6                	cmp    %edx,%esi
  8013ad:	72 19                	jb     8013c8 <__udivdi3+0x108>
  8013af:	89 f9                	mov    %edi,%ecx
  8013b1:	d3 e5                	shl    %cl,%ebp
  8013b3:	39 c5                	cmp    %eax,%ebp
  8013b5:	73 04                	jae    8013bb <__udivdi3+0xfb>
  8013b7:	39 d6                	cmp    %edx,%esi
  8013b9:	74 0d                	je     8013c8 <__udivdi3+0x108>
  8013bb:	89 d8                	mov    %ebx,%eax
  8013bd:	31 ff                	xor    %edi,%edi
  8013bf:	e9 3c ff ff ff       	jmp    801300 <__udivdi3+0x40>
  8013c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013c8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8013cb:	31 ff                	xor    %edi,%edi
  8013cd:	e9 2e ff ff ff       	jmp    801300 <__udivdi3+0x40>
  8013d2:	66 90                	xchg   %ax,%ax
  8013d4:	66 90                	xchg   %ax,%ax
  8013d6:	66 90                	xchg   %ax,%ax
  8013d8:	66 90                	xchg   %ax,%ax
  8013da:	66 90                	xchg   %ax,%ax
  8013dc:	66 90                	xchg   %ax,%ax
  8013de:	66 90                	xchg   %ax,%ax

008013e0 <__umoddi3>:
  8013e0:	f3 0f 1e fb          	endbr32 
  8013e4:	55                   	push   %ebp
  8013e5:	57                   	push   %edi
  8013e6:	56                   	push   %esi
  8013e7:	53                   	push   %ebx
  8013e8:	83 ec 1c             	sub    $0x1c,%esp
  8013eb:	8b 74 24 30          	mov    0x30(%esp),%esi
  8013ef:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8013f3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  8013f7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  8013fb:	89 f0                	mov    %esi,%eax
  8013fd:	89 da                	mov    %ebx,%edx
  8013ff:	85 ff                	test   %edi,%edi
  801401:	75 15                	jne    801418 <__umoddi3+0x38>
  801403:	39 dd                	cmp    %ebx,%ebp
  801405:	76 39                	jbe    801440 <__umoddi3+0x60>
  801407:	f7 f5                	div    %ebp
  801409:	89 d0                	mov    %edx,%eax
  80140b:	31 d2                	xor    %edx,%edx
  80140d:	83 c4 1c             	add    $0x1c,%esp
  801410:	5b                   	pop    %ebx
  801411:	5e                   	pop    %esi
  801412:	5f                   	pop    %edi
  801413:	5d                   	pop    %ebp
  801414:	c3                   	ret    
  801415:	8d 76 00             	lea    0x0(%esi),%esi
  801418:	39 df                	cmp    %ebx,%edi
  80141a:	77 f1                	ja     80140d <__umoddi3+0x2d>
  80141c:	0f bd cf             	bsr    %edi,%ecx
  80141f:	83 f1 1f             	xor    $0x1f,%ecx
  801422:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801426:	75 40                	jne    801468 <__umoddi3+0x88>
  801428:	39 df                	cmp    %ebx,%edi
  80142a:	72 04                	jb     801430 <__umoddi3+0x50>
  80142c:	39 f5                	cmp    %esi,%ebp
  80142e:	77 dd                	ja     80140d <__umoddi3+0x2d>
  801430:	89 da                	mov    %ebx,%edx
  801432:	89 f0                	mov    %esi,%eax
  801434:	29 e8                	sub    %ebp,%eax
  801436:	19 fa                	sbb    %edi,%edx
  801438:	eb d3                	jmp    80140d <__umoddi3+0x2d>
  80143a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801440:	89 e9                	mov    %ebp,%ecx
  801442:	85 ed                	test   %ebp,%ebp
  801444:	75 0b                	jne    801451 <__umoddi3+0x71>
  801446:	b8 01 00 00 00       	mov    $0x1,%eax
  80144b:	31 d2                	xor    %edx,%edx
  80144d:	f7 f5                	div    %ebp
  80144f:	89 c1                	mov    %eax,%ecx
  801451:	89 d8                	mov    %ebx,%eax
  801453:	31 d2                	xor    %edx,%edx
  801455:	f7 f1                	div    %ecx
  801457:	89 f0                	mov    %esi,%eax
  801459:	f7 f1                	div    %ecx
  80145b:	89 d0                	mov    %edx,%eax
  80145d:	31 d2                	xor    %edx,%edx
  80145f:	eb ac                	jmp    80140d <__umoddi3+0x2d>
  801461:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801468:	8b 44 24 04          	mov    0x4(%esp),%eax
  80146c:	ba 20 00 00 00       	mov    $0x20,%edx
  801471:	29 c2                	sub    %eax,%edx
  801473:	89 c1                	mov    %eax,%ecx
  801475:	89 e8                	mov    %ebp,%eax
  801477:	d3 e7                	shl    %cl,%edi
  801479:	89 d1                	mov    %edx,%ecx
  80147b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80147f:	d3 e8                	shr    %cl,%eax
  801481:	89 c1                	mov    %eax,%ecx
  801483:	8b 44 24 04          	mov    0x4(%esp),%eax
  801487:	09 f9                	or     %edi,%ecx
  801489:	89 df                	mov    %ebx,%edi
  80148b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80148f:	89 c1                	mov    %eax,%ecx
  801491:	d3 e5                	shl    %cl,%ebp
  801493:	89 d1                	mov    %edx,%ecx
  801495:	d3 ef                	shr    %cl,%edi
  801497:	89 c1                	mov    %eax,%ecx
  801499:	89 f0                	mov    %esi,%eax
  80149b:	d3 e3                	shl    %cl,%ebx
  80149d:	89 d1                	mov    %edx,%ecx
  80149f:	89 fa                	mov    %edi,%edx
  8014a1:	d3 e8                	shr    %cl,%eax
  8014a3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8014a8:	09 d8                	or     %ebx,%eax
  8014aa:	f7 74 24 08          	divl   0x8(%esp)
  8014ae:	89 d3                	mov    %edx,%ebx
  8014b0:	d3 e6                	shl    %cl,%esi
  8014b2:	f7 e5                	mul    %ebp
  8014b4:	89 c7                	mov    %eax,%edi
  8014b6:	89 d1                	mov    %edx,%ecx
  8014b8:	39 d3                	cmp    %edx,%ebx
  8014ba:	72 06                	jb     8014c2 <__umoddi3+0xe2>
  8014bc:	75 0e                	jne    8014cc <__umoddi3+0xec>
  8014be:	39 c6                	cmp    %eax,%esi
  8014c0:	73 0a                	jae    8014cc <__umoddi3+0xec>
  8014c2:	29 e8                	sub    %ebp,%eax
  8014c4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8014c8:	89 d1                	mov    %edx,%ecx
  8014ca:	89 c7                	mov    %eax,%edi
  8014cc:	89 f5                	mov    %esi,%ebp
  8014ce:	8b 74 24 04          	mov    0x4(%esp),%esi
  8014d2:	29 fd                	sub    %edi,%ebp
  8014d4:	19 cb                	sbb    %ecx,%ebx
  8014d6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8014db:	89 d8                	mov    %ebx,%eax
  8014dd:	d3 e0                	shl    %cl,%eax
  8014df:	89 f1                	mov    %esi,%ecx
  8014e1:	d3 ed                	shr    %cl,%ebp
  8014e3:	d3 eb                	shr    %cl,%ebx
  8014e5:	09 e8                	or     %ebp,%eax
  8014e7:	89 da                	mov    %ebx,%edx
  8014e9:	83 c4 1c             	add    $0x1c,%esp
  8014ec:	5b                   	pop    %ebx
  8014ed:	5e                   	pop    %esi
  8014ee:	5f                   	pop    %edi
  8014ef:	5d                   	pop    %ebp
  8014f0:	c3                   	ret    
