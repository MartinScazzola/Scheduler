
obj/user/stresssched:     formato del fichero elf32-i386


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
  80002c:	e8 b5 00 00 00       	call   8000e6 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  800038:	e8 15 0b 00 00       	call   800b52 <sys_getenvid>
  80003d:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  80003f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800044:	e8 ba 0f 00 00       	call   801003 <fork>
  800049:	85 c0                	test   %eax,%eax
  80004b:	74 0f                	je     80005c <umain+0x29>
	for (i = 0; i < 20; i++)
  80004d:	83 c3 01             	add    $0x1,%ebx
  800050:	83 fb 14             	cmp    $0x14,%ebx
  800053:	75 ef                	jne    800044 <umain+0x11>
			break;
	if (i == 20) {
		sys_yield();
  800055:	e8 1c 0b 00 00       	call   800b76 <sys_yield>
		return;
  80005a:	eb 6c                	jmp    8000c8 <umain+0x95>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80005c:	89 f0                	mov    %esi,%eax
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	69 c0 88 00 00 00    	imul   $0x88,%eax,%eax
  800069:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006e:	eb 02                	jmp    800072 <umain+0x3f>
		asm volatile("pause");
  800070:	f3 90                	pause  
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  800072:	8b 50 54             	mov    0x54(%eax),%edx
  800075:	85 d2                	test   %edx,%edx
  800077:	75 f7                	jne    800070 <umain+0x3d>
  800079:	bb 0a 00 00 00       	mov    $0xa,%ebx

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  80007e:	e8 f3 0a 00 00       	call   800b76 <sys_yield>
  800083:	ba 10 27 00 00       	mov    $0x2710,%edx
		for (j = 0; j < 10000; j++)
			counter++;
  800088:	a1 04 20 80 00       	mov    0x802004,%eax
  80008d:	83 c0 01             	add    $0x1,%eax
  800090:	a3 04 20 80 00       	mov    %eax,0x802004
		for (j = 0; j < 10000; j++)
  800095:	83 ea 01             	sub    $0x1,%edx
  800098:	75 ee                	jne    800088 <umain+0x55>
	for (i = 0; i < 10; i++) {
  80009a:	83 eb 01             	sub    $0x1,%ebx
  80009d:	75 df                	jne    80007e <umain+0x4b>
	}

	if (counter != 10 * 10000)
  80009f:	a1 04 20 80 00       	mov    0x802004,%eax
  8000a4:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000a9:	75 24                	jne    8000cf <umain+0x9c>
		panic("ran on two CPUs at once (counter is %d)", counter);

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n",
	        thisenv->env_id,
	        thisenv->env_cpunum);
  8000ab:	a1 08 20 80 00       	mov    0x802008,%eax
  8000b0:	8b 50 5c             	mov    0x5c(%eax),%edx
	        thisenv->env_id,
  8000b3:	8b 40 48             	mov    0x48(%eax),%eax
	cprintf("[%08x] stresssched on CPU %d\n",
  8000b6:	83 ec 04             	sub    $0x4,%esp
  8000b9:	52                   	push   %edx
  8000ba:	50                   	push   %eax
  8000bb:	68 3b 14 80 00       	push   $0x80143b
  8000c0:	e8 5b 01 00 00       	call   800220 <cprintf>
  8000c5:	83 c4 10             	add    $0x10,%esp
}
  8000c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000cb:	5b                   	pop    %ebx
  8000cc:	5e                   	pop    %esi
  8000cd:	5d                   	pop    %ebp
  8000ce:	c3                   	ret    
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000cf:	a1 04 20 80 00       	mov    0x802004,%eax
  8000d4:	50                   	push   %eax
  8000d5:	68 00 14 80 00       	push   $0x801400
  8000da:	6a 21                	push   $0x21
  8000dc:	68 28 14 80 00       	push   $0x801428
  8000e1:	e8 5f 00 00 00       	call   800145 <_panic>

008000e6 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e6:	55                   	push   %ebp
  8000e7:	89 e5                	mov    %esp,%ebp
  8000e9:	56                   	push   %esi
  8000ea:	53                   	push   %ebx
  8000eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000ee:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	envid_t id = sys_getenvid();
  8000f1:	e8 5c 0a 00 00       	call   800b52 <sys_getenvid>
	if (id >= 0)
  8000f6:	85 c0                	test   %eax,%eax
  8000f8:	78 15                	js     80010f <libmain+0x29>
		thisenv = &envs[ENVX(id)];
  8000fa:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ff:	69 c0 88 00 00 00    	imul   $0x88,%eax,%eax
  800105:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80010a:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80010f:	85 db                	test   %ebx,%ebx
  800111:	7e 07                	jle    80011a <libmain+0x34>
		binaryname = argv[0];
  800113:	8b 06                	mov    (%esi),%eax
  800115:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80011a:	83 ec 08             	sub    $0x8,%esp
  80011d:	56                   	push   %esi
  80011e:	53                   	push   %ebx
  80011f:	e8 0f ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800124:	e8 0a 00 00 00       	call   800133 <exit>
}
  800129:	83 c4 10             	add    $0x10,%esp
  80012c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80012f:	5b                   	pop    %ebx
  800130:	5e                   	pop    %esi
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    

00800133 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800139:	6a 00                	push   $0x0
  80013b:	e8 f0 09 00 00       	call   800b30 <sys_env_destroy>
}
  800140:	83 c4 10             	add    $0x10,%esp
  800143:	c9                   	leave  
  800144:	c3                   	ret    

00800145 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800145:	55                   	push   %ebp
  800146:	89 e5                	mov    %esp,%ebp
  800148:	56                   	push   %esi
  800149:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80014a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80014d:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800153:	e8 fa 09 00 00       	call   800b52 <sys_getenvid>
  800158:	83 ec 0c             	sub    $0xc,%esp
  80015b:	ff 75 0c             	push   0xc(%ebp)
  80015e:	ff 75 08             	push   0x8(%ebp)
  800161:	56                   	push   %esi
  800162:	50                   	push   %eax
  800163:	68 64 14 80 00       	push   $0x801464
  800168:	e8 b3 00 00 00       	call   800220 <cprintf>
	        sys_getenvid(),
	        binaryname,
	        file,
	        line);
	vcprintf(fmt, ap);
  80016d:	83 c4 18             	add    $0x18,%esp
  800170:	53                   	push   %ebx
  800171:	ff 75 10             	push   0x10(%ebp)
  800174:	e8 56 00 00 00       	call   8001cf <vcprintf>
	cprintf("\n");
  800179:	c7 04 24 57 14 80 00 	movl   $0x801457,(%esp)
  800180:	e8 9b 00 00 00       	call   800220 <cprintf>
  800185:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800188:	cc                   	int3   
  800189:	eb fd                	jmp    800188 <_panic+0x43>

0080018b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80018b:	55                   	push   %ebp
  80018c:	89 e5                	mov    %esp,%ebp
  80018e:	53                   	push   %ebx
  80018f:	83 ec 04             	sub    $0x4,%esp
  800192:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800195:	8b 13                	mov    (%ebx),%edx
  800197:	8d 42 01             	lea    0x1(%edx),%eax
  80019a:	89 03                	mov    %eax,(%ebx)
  80019c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80019f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256 - 1) {
  8001a3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001a8:	74 09                	je     8001b3 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001aa:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b1:	c9                   	leave  
  8001b2:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001b3:	83 ec 08             	sub    $0x8,%esp
  8001b6:	68 ff 00 00 00       	push   $0xff
  8001bb:	8d 43 08             	lea    0x8(%ebx),%eax
  8001be:	50                   	push   %eax
  8001bf:	e8 22 09 00 00       	call   800ae6 <sys_cputs>
		b->idx = 0;
  8001c4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001ca:	83 c4 10             	add    $0x10,%esp
  8001cd:	eb db                	jmp    8001aa <putch+0x1f>

008001cf <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001cf:	55                   	push   %ebp
  8001d0:	89 e5                	mov    %esp,%ebp
  8001d2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001d8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001df:	00 00 00 
	b.cnt = 0;
  8001e2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001e9:	00 00 00 
	vprintfmt((void *) putch, &b, fmt, ap);
  8001ec:	ff 75 0c             	push   0xc(%ebp)
  8001ef:	ff 75 08             	push   0x8(%ebp)
  8001f2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001f8:	50                   	push   %eax
  8001f9:	68 8b 01 80 00       	push   $0x80018b
  8001fe:	e8 74 01 00 00       	call   800377 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800203:	83 c4 08             	add    $0x8,%esp
  800206:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  80020c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800212:	50                   	push   %eax
  800213:	e8 ce 08 00 00       	call   800ae6 <sys_cputs>

	return b.cnt;
}
  800218:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80021e:	c9                   	leave  
  80021f:	c3                   	ret    

00800220 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800220:	55                   	push   %ebp
  800221:	89 e5                	mov    %esp,%ebp
  800223:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800226:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800229:	50                   	push   %eax
  80022a:	ff 75 08             	push   0x8(%ebp)
  80022d:	e8 9d ff ff ff       	call   8001cf <vcprintf>
	va_end(ap);

	return cnt;
}
  800232:	c9                   	leave  
  800233:	c3                   	ret    

00800234 <printnum>:
         void *putdat,
         unsigned long long num,
         unsigned base,
         int width,
         int padc)
{
  800234:	55                   	push   %ebp
  800235:	89 e5                	mov    %esp,%ebp
  800237:	57                   	push   %edi
  800238:	56                   	push   %esi
  800239:	53                   	push   %ebx
  80023a:	83 ec 1c             	sub    $0x1c,%esp
  80023d:	89 c7                	mov    %eax,%edi
  80023f:	89 d6                	mov    %edx,%esi
  800241:	8b 45 08             	mov    0x8(%ebp),%eax
  800244:	8b 55 0c             	mov    0xc(%ebp),%edx
  800247:	89 d1                	mov    %edx,%ecx
  800249:	89 c2                	mov    %eax,%edx
  80024b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80024e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800251:	8b 45 10             	mov    0x10(%ebp),%eax
  800254:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800257:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80025a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800261:	39 c2                	cmp    %eax,%edx
  800263:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800266:	72 3e                	jb     8002a6 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800268:	83 ec 0c             	sub    $0xc,%esp
  80026b:	ff 75 18             	push   0x18(%ebp)
  80026e:	83 eb 01             	sub    $0x1,%ebx
  800271:	53                   	push   %ebx
  800272:	50                   	push   %eax
  800273:	83 ec 08             	sub    $0x8,%esp
  800276:	ff 75 e4             	push   -0x1c(%ebp)
  800279:	ff 75 e0             	push   -0x20(%ebp)
  80027c:	ff 75 dc             	push   -0x24(%ebp)
  80027f:	ff 75 d8             	push   -0x28(%ebp)
  800282:	e8 29 0f 00 00       	call   8011b0 <__udivdi3>
  800287:	83 c4 18             	add    $0x18,%esp
  80028a:	52                   	push   %edx
  80028b:	50                   	push   %eax
  80028c:	89 f2                	mov    %esi,%edx
  80028e:	89 f8                	mov    %edi,%eax
  800290:	e8 9f ff ff ff       	call   800234 <printnum>
  800295:	83 c4 20             	add    $0x20,%esp
  800298:	eb 13                	jmp    8002ad <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80029a:	83 ec 08             	sub    $0x8,%esp
  80029d:	56                   	push   %esi
  80029e:	ff 75 18             	push   0x18(%ebp)
  8002a1:	ff d7                	call   *%edi
  8002a3:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002a6:	83 eb 01             	sub    $0x1,%ebx
  8002a9:	85 db                	test   %ebx,%ebx
  8002ab:	7f ed                	jg     80029a <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002ad:	83 ec 08             	sub    $0x8,%esp
  8002b0:	56                   	push   %esi
  8002b1:	83 ec 04             	sub    $0x4,%esp
  8002b4:	ff 75 e4             	push   -0x1c(%ebp)
  8002b7:	ff 75 e0             	push   -0x20(%ebp)
  8002ba:	ff 75 dc             	push   -0x24(%ebp)
  8002bd:	ff 75 d8             	push   -0x28(%ebp)
  8002c0:	e8 0b 10 00 00       	call   8012d0 <__umoddi3>
  8002c5:	83 c4 14             	add    $0x14,%esp
  8002c8:	0f be 80 87 14 80 00 	movsbl 0x801487(%eax),%eax
  8002cf:	50                   	push   %eax
  8002d0:	ff d7                	call   *%edi
}
  8002d2:	83 c4 10             	add    $0x10,%esp
  8002d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d8:	5b                   	pop    %ebx
  8002d9:	5e                   	pop    %esi
  8002da:	5f                   	pop    %edi
  8002db:	5d                   	pop    %ebp
  8002dc:	c3                   	ret    

008002dd <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8002dd:	83 fa 01             	cmp    $0x1,%edx
  8002e0:	7f 13                	jg     8002f5 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8002e2:	85 d2                	test   %edx,%edx
  8002e4:	74 1c                	je     800302 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  8002e6:	8b 10                	mov    (%eax),%edx
  8002e8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002eb:	89 08                	mov    %ecx,(%eax)
  8002ed:	8b 02                	mov    (%edx),%eax
  8002ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8002f4:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  8002f5:	8b 10                	mov    (%eax),%edx
  8002f7:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002fa:	89 08                	mov    %ecx,(%eax)
  8002fc:	8b 02                	mov    (%edx),%eax
  8002fe:	8b 52 04             	mov    0x4(%edx),%edx
  800301:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  800302:	8b 10                	mov    (%eax),%edx
  800304:	8d 4a 04             	lea    0x4(%edx),%ecx
  800307:	89 08                	mov    %ecx,(%eax)
  800309:	8b 02                	mov    (%edx),%eax
  80030b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800310:	c3                   	ret    

00800311 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800311:	83 fa 01             	cmp    $0x1,%edx
  800314:	7f 0f                	jg     800325 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  800316:	85 d2                	test   %edx,%edx
  800318:	74 18                	je     800332 <getint+0x21>
		return va_arg(*ap, long);
  80031a:	8b 10                	mov    (%eax),%edx
  80031c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80031f:	89 08                	mov    %ecx,(%eax)
  800321:	8b 02                	mov    (%edx),%eax
  800323:	99                   	cltd   
  800324:	c3                   	ret    
		return va_arg(*ap, long long);
  800325:	8b 10                	mov    (%eax),%edx
  800327:	8d 4a 08             	lea    0x8(%edx),%ecx
  80032a:	89 08                	mov    %ecx,(%eax)
  80032c:	8b 02                	mov    (%edx),%eax
  80032e:	8b 52 04             	mov    0x4(%edx),%edx
  800331:	c3                   	ret    
	else
		return va_arg(*ap, int);
  800332:	8b 10                	mov    (%eax),%edx
  800334:	8d 4a 04             	lea    0x4(%edx),%ecx
  800337:	89 08                	mov    %ecx,(%eax)
  800339:	8b 02                	mov    (%edx),%eax
  80033b:	99                   	cltd   
}
  80033c:	c3                   	ret    

0080033d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80033d:	55                   	push   %ebp
  80033e:	89 e5                	mov    %esp,%ebp
  800340:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800343:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800347:	8b 10                	mov    (%eax),%edx
  800349:	3b 50 04             	cmp    0x4(%eax),%edx
  80034c:	73 0a                	jae    800358 <sprintputch+0x1b>
		*b->buf++ = ch;
  80034e:	8d 4a 01             	lea    0x1(%edx),%ecx
  800351:	89 08                	mov    %ecx,(%eax)
  800353:	8b 45 08             	mov    0x8(%ebp),%eax
  800356:	88 02                	mov    %al,(%edx)
}
  800358:	5d                   	pop    %ebp
  800359:	c3                   	ret    

0080035a <printfmt>:
{
  80035a:	55                   	push   %ebp
  80035b:	89 e5                	mov    %esp,%ebp
  80035d:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800360:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800363:	50                   	push   %eax
  800364:	ff 75 10             	push   0x10(%ebp)
  800367:	ff 75 0c             	push   0xc(%ebp)
  80036a:	ff 75 08             	push   0x8(%ebp)
  80036d:	e8 05 00 00 00       	call   800377 <vprintfmt>
}
  800372:	83 c4 10             	add    $0x10,%esp
  800375:	c9                   	leave  
  800376:	c3                   	ret    

00800377 <vprintfmt>:
{
  800377:	55                   	push   %ebp
  800378:	89 e5                	mov    %esp,%ebp
  80037a:	57                   	push   %edi
  80037b:	56                   	push   %esi
  80037c:	53                   	push   %ebx
  80037d:	83 ec 2c             	sub    $0x2c,%esp
  800380:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800383:	8b 75 0c             	mov    0xc(%ebp),%esi
  800386:	8b 7d 10             	mov    0x10(%ebp),%edi
  800389:	eb 0a                	jmp    800395 <vprintfmt+0x1e>
			putch(ch, putdat);
  80038b:	83 ec 08             	sub    $0x8,%esp
  80038e:	56                   	push   %esi
  80038f:	50                   	push   %eax
  800390:	ff d3                	call   *%ebx
  800392:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800395:	83 c7 01             	add    $0x1,%edi
  800398:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80039c:	83 f8 25             	cmp    $0x25,%eax
  80039f:	74 0c                	je     8003ad <vprintfmt+0x36>
			if (ch == '\0')
  8003a1:	85 c0                	test   %eax,%eax
  8003a3:	75 e6                	jne    80038b <vprintfmt+0x14>
}
  8003a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003a8:	5b                   	pop    %ebx
  8003a9:	5e                   	pop    %esi
  8003aa:	5f                   	pop    %edi
  8003ab:	5d                   	pop    %ebp
  8003ac:	c3                   	ret    
		padc = ' ';
  8003ad:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
		altflag = 0;
  8003b1:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8003b8:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8003bf:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003c6:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003cb:	8d 47 01             	lea    0x1(%edi),%eax
  8003ce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003d1:	0f b6 17             	movzbl (%edi),%edx
  8003d4:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003d7:	3c 55                	cmp    $0x55,%al
  8003d9:	0f 87 b7 02 00 00    	ja     800696 <vprintfmt+0x31f>
  8003df:	0f b6 c0             	movzbl %al,%eax
  8003e2:	ff 24 85 40 15 80 00 	jmp    *0x801540(,%eax,4)
  8003e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8003ec:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  8003f0:	eb d9                	jmp    8003cb <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8003f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f5:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  8003f9:	eb d0                	jmp    8003cb <vprintfmt+0x54>
  8003fb:	0f b6 d2             	movzbl %dl,%edx
  8003fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0;; ++fmt) {
  800401:	b8 00 00 00 00       	mov    $0x0,%eax
  800406:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800409:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80040c:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800410:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800413:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800416:	83 f9 09             	cmp    $0x9,%ecx
  800419:	77 52                	ja     80046d <vprintfmt+0xf6>
			for (precision = 0;; ++fmt) {
  80041b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80041e:	eb e9                	jmp    800409 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  800420:	8b 45 14             	mov    0x14(%ebp),%eax
  800423:	8d 50 04             	lea    0x4(%eax),%edx
  800426:	89 55 14             	mov    %edx,0x14(%ebp)
  800429:	8b 00                	mov    (%eax),%eax
  80042b:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80042e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800431:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800435:	79 94                	jns    8003cb <vprintfmt+0x54>
				width = precision, precision = -1;
  800437:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80043a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80043d:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800444:	eb 85                	jmp    8003cb <vprintfmt+0x54>
  800446:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800449:	85 d2                	test   %edx,%edx
  80044b:	b8 00 00 00 00       	mov    $0x0,%eax
  800450:	0f 49 c2             	cmovns %edx,%eax
  800453:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800456:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800459:	e9 6d ff ff ff       	jmp    8003cb <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80045e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800461:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800468:	e9 5e ff ff ff       	jmp    8003cb <vprintfmt+0x54>
  80046d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800470:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800473:	eb bc                	jmp    800431 <vprintfmt+0xba>
			lflag++;
  800475:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800478:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80047b:	e9 4b ff ff ff       	jmp    8003cb <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800480:	8b 45 14             	mov    0x14(%ebp),%eax
  800483:	8d 50 04             	lea    0x4(%eax),%edx
  800486:	89 55 14             	mov    %edx,0x14(%ebp)
  800489:	83 ec 08             	sub    $0x8,%esp
  80048c:	56                   	push   %esi
  80048d:	ff 30                	push   (%eax)
  80048f:	ff d3                	call   *%ebx
			break;
  800491:	83 c4 10             	add    $0x10,%esp
  800494:	e9 94 01 00 00       	jmp    80062d <vprintfmt+0x2b6>
			err = va_arg(ap, int);
  800499:	8b 45 14             	mov    0x14(%ebp),%eax
  80049c:	8d 50 04             	lea    0x4(%eax),%edx
  80049f:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a2:	8b 10                	mov    (%eax),%edx
  8004a4:	89 d0                	mov    %edx,%eax
  8004a6:	f7 d8                	neg    %eax
  8004a8:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004ab:	83 f8 08             	cmp    $0x8,%eax
  8004ae:	7f 20                	jg     8004d0 <vprintfmt+0x159>
  8004b0:	8b 14 85 a0 16 80 00 	mov    0x8016a0(,%eax,4),%edx
  8004b7:	85 d2                	test   %edx,%edx
  8004b9:	74 15                	je     8004d0 <vprintfmt+0x159>
				printfmt(putch, putdat, "%s", p);
  8004bb:	52                   	push   %edx
  8004bc:	68 a8 14 80 00       	push   $0x8014a8
  8004c1:	56                   	push   %esi
  8004c2:	53                   	push   %ebx
  8004c3:	e8 92 fe ff ff       	call   80035a <printfmt>
  8004c8:	83 c4 10             	add    $0x10,%esp
  8004cb:	e9 5d 01 00 00       	jmp    80062d <vprintfmt+0x2b6>
				printfmt(putch, putdat, "error %d", err);
  8004d0:	50                   	push   %eax
  8004d1:	68 9f 14 80 00       	push   $0x80149f
  8004d6:	56                   	push   %esi
  8004d7:	53                   	push   %ebx
  8004d8:	e8 7d fe ff ff       	call   80035a <printfmt>
  8004dd:	83 c4 10             	add    $0x10,%esp
  8004e0:	e9 48 01 00 00       	jmp    80062d <vprintfmt+0x2b6>
			if ((p = va_arg(ap, char *)) == NULL)
  8004e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e8:	8d 50 04             	lea    0x4(%eax),%edx
  8004eb:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ee:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004f0:	85 ff                	test   %edi,%edi
  8004f2:	b8 98 14 80 00       	mov    $0x801498,%eax
  8004f7:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004fa:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004fe:	7e 06                	jle    800506 <vprintfmt+0x18f>
  800500:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  800504:	75 0a                	jne    800510 <vprintfmt+0x199>
  800506:	89 f8                	mov    %edi,%eax
  800508:	03 45 e0             	add    -0x20(%ebp),%eax
  80050b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80050e:	eb 59                	jmp    800569 <vprintfmt+0x1f2>
				for (width -= strnlen(p, precision); width > 0;
  800510:	83 ec 08             	sub    $0x8,%esp
  800513:	ff 75 d8             	push   -0x28(%ebp)
  800516:	57                   	push   %edi
  800517:	e8 1a 02 00 00       	call   800736 <strnlen>
  80051c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80051f:	29 c1                	sub    %eax,%ecx
  800521:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800524:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800527:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  80052b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80052e:	89 7d d0             	mov    %edi,-0x30(%ebp)
  800531:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0;
  800533:	eb 0f                	jmp    800544 <vprintfmt+0x1cd>
					putch(padc, putdat);
  800535:	83 ec 08             	sub    $0x8,%esp
  800538:	56                   	push   %esi
  800539:	ff 75 e0             	push   -0x20(%ebp)
  80053c:	ff d3                	call   *%ebx
				     width--)
  80053e:	83 ef 01             	sub    $0x1,%edi
  800541:	83 c4 10             	add    $0x10,%esp
				for (width -= strnlen(p, precision); width > 0;
  800544:	85 ff                	test   %edi,%edi
  800546:	7f ed                	jg     800535 <vprintfmt+0x1be>
  800548:	8b 7d d0             	mov    -0x30(%ebp),%edi
  80054b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80054e:	85 c9                	test   %ecx,%ecx
  800550:	b8 00 00 00 00       	mov    $0x0,%eax
  800555:	0f 49 c1             	cmovns %ecx,%eax
  800558:	29 c1                	sub    %eax,%ecx
  80055a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80055d:	eb a7                	jmp    800506 <vprintfmt+0x18f>
					putch(ch, putdat);
  80055f:	83 ec 08             	sub    $0x8,%esp
  800562:	56                   	push   %esi
  800563:	52                   	push   %edx
  800564:	ff d3                	call   *%ebx
  800566:	83 c4 10             	add    $0x10,%esp
  800569:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80056c:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' &&
  80056e:	83 c7 01             	add    $0x1,%edi
  800571:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800575:	0f be d0             	movsbl %al,%edx
  800578:	85 d2                	test   %edx,%edx
  80057a:	74 42                	je     8005be <vprintfmt+0x247>
  80057c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800580:	78 06                	js     800588 <vprintfmt+0x211>
			       (precision < 0 || --precision >= 0);
  800582:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800586:	78 1e                	js     8005a6 <vprintfmt+0x22f>
				if (altflag && (ch < ' ' || ch > '~'))
  800588:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80058c:	74 d1                	je     80055f <vprintfmt+0x1e8>
  80058e:	0f be c0             	movsbl %al,%eax
  800591:	83 e8 20             	sub    $0x20,%eax
  800594:	83 f8 5e             	cmp    $0x5e,%eax
  800597:	76 c6                	jbe    80055f <vprintfmt+0x1e8>
					putch('?', putdat);
  800599:	83 ec 08             	sub    $0x8,%esp
  80059c:	56                   	push   %esi
  80059d:	6a 3f                	push   $0x3f
  80059f:	ff d3                	call   *%ebx
  8005a1:	83 c4 10             	add    $0x10,%esp
  8005a4:	eb c3                	jmp    800569 <vprintfmt+0x1f2>
  8005a6:	89 cf                	mov    %ecx,%edi
  8005a8:	eb 0e                	jmp    8005b8 <vprintfmt+0x241>
				putch(' ', putdat);
  8005aa:	83 ec 08             	sub    $0x8,%esp
  8005ad:	56                   	push   %esi
  8005ae:	6a 20                	push   $0x20
  8005b0:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  8005b2:	83 ef 01             	sub    $0x1,%edi
  8005b5:	83 c4 10             	add    $0x10,%esp
  8005b8:	85 ff                	test   %edi,%edi
  8005ba:	7f ee                	jg     8005aa <vprintfmt+0x233>
  8005bc:	eb 6f                	jmp    80062d <vprintfmt+0x2b6>
  8005be:	89 cf                	mov    %ecx,%edi
  8005c0:	eb f6                	jmp    8005b8 <vprintfmt+0x241>
			num = getint(&ap, lflag);
  8005c2:	89 ca                	mov    %ecx,%edx
  8005c4:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c7:	e8 45 fd ff ff       	call   800311 <getint>
  8005cc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005cf:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  8005d2:	85 d2                	test   %edx,%edx
  8005d4:	78 0b                	js     8005e1 <vprintfmt+0x26a>
			num = getint(&ap, lflag);
  8005d6:	89 d1                	mov    %edx,%ecx
  8005d8:	89 c2                	mov    %eax,%edx
			base = 10;
  8005da:	bf 0a 00 00 00       	mov    $0xa,%edi
  8005df:	eb 32                	jmp    800613 <vprintfmt+0x29c>
				putch('-', putdat);
  8005e1:	83 ec 08             	sub    $0x8,%esp
  8005e4:	56                   	push   %esi
  8005e5:	6a 2d                	push   $0x2d
  8005e7:	ff d3                	call   *%ebx
				num = -(long long) num;
  8005e9:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005ec:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005ef:	f7 da                	neg    %edx
  8005f1:	83 d1 00             	adc    $0x0,%ecx
  8005f4:	f7 d9                	neg    %ecx
  8005f6:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005f9:	bf 0a 00 00 00       	mov    $0xa,%edi
  8005fe:	eb 13                	jmp    800613 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  800600:	89 ca                	mov    %ecx,%edx
  800602:	8d 45 14             	lea    0x14(%ebp),%eax
  800605:	e8 d3 fc ff ff       	call   8002dd <getuint>
  80060a:	89 d1                	mov    %edx,%ecx
  80060c:	89 c2                	mov    %eax,%edx
			base = 10;
  80060e:	bf 0a 00 00 00       	mov    $0xa,%edi
			printnum(putch, putdat, num, base, width, padc);
  800613:	83 ec 0c             	sub    $0xc,%esp
  800616:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  80061a:	50                   	push   %eax
  80061b:	ff 75 e0             	push   -0x20(%ebp)
  80061e:	57                   	push   %edi
  80061f:	51                   	push   %ecx
  800620:	52                   	push   %edx
  800621:	89 f2                	mov    %esi,%edx
  800623:	89 d8                	mov    %ebx,%eax
  800625:	e8 0a fc ff ff       	call   800234 <printnum>
			break;
  80062a:	83 c4 20             	add    $0x20,%esp
{
  80062d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800630:	e9 60 fd ff ff       	jmp    800395 <vprintfmt+0x1e>
			num = getuint(&ap, lflag);
  800635:	89 ca                	mov    %ecx,%edx
  800637:	8d 45 14             	lea    0x14(%ebp),%eax
  80063a:	e8 9e fc ff ff       	call   8002dd <getuint>
  80063f:	89 d1                	mov    %edx,%ecx
  800641:	89 c2                	mov    %eax,%edx
			base = 8;
  800643:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  800648:	eb c9                	jmp    800613 <vprintfmt+0x29c>
			putch('0', putdat);
  80064a:	83 ec 08             	sub    $0x8,%esp
  80064d:	56                   	push   %esi
  80064e:	6a 30                	push   $0x30
  800650:	ff d3                	call   *%ebx
			putch('x', putdat);
  800652:	83 c4 08             	add    $0x8,%esp
  800655:	56                   	push   %esi
  800656:	6a 78                	push   $0x78
  800658:	ff d3                	call   *%ebx
			num = (unsigned long long) (uintptr_t) va_arg(ap, void *);
  80065a:	8b 45 14             	mov    0x14(%ebp),%eax
  80065d:	8d 50 04             	lea    0x4(%eax),%edx
  800660:	89 55 14             	mov    %edx,0x14(%ebp)
  800663:	8b 10                	mov    (%eax),%edx
  800665:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80066a:	83 c4 10             	add    $0x10,%esp
			base = 16;
  80066d:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  800672:	eb 9f                	jmp    800613 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  800674:	89 ca                	mov    %ecx,%edx
  800676:	8d 45 14             	lea    0x14(%ebp),%eax
  800679:	e8 5f fc ff ff       	call   8002dd <getuint>
  80067e:	89 d1                	mov    %edx,%ecx
  800680:	89 c2                	mov    %eax,%edx
			base = 16;
  800682:	bf 10 00 00 00       	mov    $0x10,%edi
  800687:	eb 8a                	jmp    800613 <vprintfmt+0x29c>
			putch(ch, putdat);
  800689:	83 ec 08             	sub    $0x8,%esp
  80068c:	56                   	push   %esi
  80068d:	6a 25                	push   $0x25
  80068f:	ff d3                	call   *%ebx
			break;
  800691:	83 c4 10             	add    $0x10,%esp
  800694:	eb 97                	jmp    80062d <vprintfmt+0x2b6>
			putch('%', putdat);
  800696:	83 ec 08             	sub    $0x8,%esp
  800699:	56                   	push   %esi
  80069a:	6a 25                	push   $0x25
  80069c:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  80069e:	83 c4 10             	add    $0x10,%esp
  8006a1:	89 f8                	mov    %edi,%eax
  8006a3:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006a7:	74 05                	je     8006ae <vprintfmt+0x337>
  8006a9:	83 e8 01             	sub    $0x1,%eax
  8006ac:	eb f5                	jmp    8006a3 <vprintfmt+0x32c>
  8006ae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006b1:	e9 77 ff ff ff       	jmp    80062d <vprintfmt+0x2b6>

008006b6 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006b6:	55                   	push   %ebp
  8006b7:	89 e5                	mov    %esp,%ebp
  8006b9:	83 ec 18             	sub    $0x18,%esp
  8006bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006bf:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = { buf, buf + n - 1, 0 };
  8006c2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006c5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006c9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006cc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006d3:	85 c0                	test   %eax,%eax
  8006d5:	74 26                	je     8006fd <vsnprintf+0x47>
  8006d7:	85 d2                	test   %edx,%edx
  8006d9:	7e 22                	jle    8006fd <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *) sprintputch, &b, fmt, ap);
  8006db:	ff 75 14             	push   0x14(%ebp)
  8006de:	ff 75 10             	push   0x10(%ebp)
  8006e1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006e4:	50                   	push   %eax
  8006e5:	68 3d 03 80 00       	push   $0x80033d
  8006ea:	e8 88 fc ff ff       	call   800377 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006f2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006f8:	83 c4 10             	add    $0x10,%esp
}
  8006fb:	c9                   	leave  
  8006fc:	c3                   	ret    
		return -E_INVAL;
  8006fd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800702:	eb f7                	jmp    8006fb <vsnprintf+0x45>

00800704 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800704:	55                   	push   %ebp
  800705:	89 e5                	mov    %esp,%ebp
  800707:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80070a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80070d:	50                   	push   %eax
  80070e:	ff 75 10             	push   0x10(%ebp)
  800711:	ff 75 0c             	push   0xc(%ebp)
  800714:	ff 75 08             	push   0x8(%ebp)
  800717:	e8 9a ff ff ff       	call   8006b6 <vsnprintf>
	va_end(ap);

	return rc;
}
  80071c:	c9                   	leave  
  80071d:	c3                   	ret    

0080071e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80071e:	55                   	push   %ebp
  80071f:	89 e5                	mov    %esp,%ebp
  800721:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800724:	b8 00 00 00 00       	mov    $0x0,%eax
  800729:	eb 03                	jmp    80072e <strlen+0x10>
		n++;
  80072b:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80072e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800732:	75 f7                	jne    80072b <strlen+0xd>
	return n;
}
  800734:	5d                   	pop    %ebp
  800735:	c3                   	ret    

00800736 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800736:	55                   	push   %ebp
  800737:	89 e5                	mov    %esp,%ebp
  800739:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80073c:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80073f:	b8 00 00 00 00       	mov    $0x0,%eax
  800744:	eb 03                	jmp    800749 <strnlen+0x13>
		n++;
  800746:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800749:	39 d0                	cmp    %edx,%eax
  80074b:	74 08                	je     800755 <strnlen+0x1f>
  80074d:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800751:	75 f3                	jne    800746 <strnlen+0x10>
  800753:	89 c2                	mov    %eax,%edx
	return n;
}
  800755:	89 d0                	mov    %edx,%eax
  800757:	5d                   	pop    %ebp
  800758:	c3                   	ret    

00800759 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800759:	55                   	push   %ebp
  80075a:	89 e5                	mov    %esp,%ebp
  80075c:	53                   	push   %ebx
  80075d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800760:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800763:	b8 00 00 00 00       	mov    $0x0,%eax
  800768:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80076c:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  80076f:	83 c0 01             	add    $0x1,%eax
  800772:	84 d2                	test   %dl,%dl
  800774:	75 f2                	jne    800768 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800776:	89 c8                	mov    %ecx,%eax
  800778:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80077b:	c9                   	leave  
  80077c:	c3                   	ret    

0080077d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80077d:	55                   	push   %ebp
  80077e:	89 e5                	mov    %esp,%ebp
  800780:	53                   	push   %ebx
  800781:	83 ec 10             	sub    $0x10,%esp
  800784:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800787:	53                   	push   %ebx
  800788:	e8 91 ff ff ff       	call   80071e <strlen>
  80078d:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800790:	ff 75 0c             	push   0xc(%ebp)
  800793:	01 d8                	add    %ebx,%eax
  800795:	50                   	push   %eax
  800796:	e8 be ff ff ff       	call   800759 <strcpy>
	return dst;
}
  80079b:	89 d8                	mov    %ebx,%eax
  80079d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007a0:	c9                   	leave  
  8007a1:	c3                   	ret    

008007a2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size)
{
  8007a2:	55                   	push   %ebp
  8007a3:	89 e5                	mov    %esp,%ebp
  8007a5:	56                   	push   %esi
  8007a6:	53                   	push   %ebx
  8007a7:	8b 75 08             	mov    0x8(%ebp),%esi
  8007aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ad:	89 f3                	mov    %esi,%ebx
  8007af:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007b2:	89 f0                	mov    %esi,%eax
  8007b4:	eb 0f                	jmp    8007c5 <strncpy+0x23>
		*dst++ = *src;
  8007b6:	83 c0 01             	add    $0x1,%eax
  8007b9:	0f b6 0a             	movzbl (%edx),%ecx
  8007bc:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007bf:	80 f9 01             	cmp    $0x1,%cl
  8007c2:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  8007c5:	39 d8                	cmp    %ebx,%eax
  8007c7:	75 ed                	jne    8007b6 <strncpy+0x14>
	}
	return ret;
}
  8007c9:	89 f0                	mov    %esi,%eax
  8007cb:	5b                   	pop    %ebx
  8007cc:	5e                   	pop    %esi
  8007cd:	5d                   	pop    %ebp
  8007ce:	c3                   	ret    

008007cf <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007cf:	55                   	push   %ebp
  8007d0:	89 e5                	mov    %esp,%ebp
  8007d2:	56                   	push   %esi
  8007d3:	53                   	push   %ebx
  8007d4:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007da:	8b 55 10             	mov    0x10(%ebp),%edx
  8007dd:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007df:	85 d2                	test   %edx,%edx
  8007e1:	74 21                	je     800804 <strlcpy+0x35>
  8007e3:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007e7:	89 f2                	mov    %esi,%edx
  8007e9:	eb 09                	jmp    8007f4 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007eb:	83 c1 01             	add    $0x1,%ecx
  8007ee:	83 c2 01             	add    $0x1,%edx
  8007f1:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  8007f4:	39 c2                	cmp    %eax,%edx
  8007f6:	74 09                	je     800801 <strlcpy+0x32>
  8007f8:	0f b6 19             	movzbl (%ecx),%ebx
  8007fb:	84 db                	test   %bl,%bl
  8007fd:	75 ec                	jne    8007eb <strlcpy+0x1c>
  8007ff:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800801:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800804:	29 f0                	sub    %esi,%eax
}
  800806:	5b                   	pop    %ebx
  800807:	5e                   	pop    %esi
  800808:	5d                   	pop    %ebp
  800809:	c3                   	ret    

0080080a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80080a:	55                   	push   %ebp
  80080b:	89 e5                	mov    %esp,%ebp
  80080d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800810:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800813:	eb 06                	jmp    80081b <strcmp+0x11>
		p++, q++;
  800815:	83 c1 01             	add    $0x1,%ecx
  800818:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80081b:	0f b6 01             	movzbl (%ecx),%eax
  80081e:	84 c0                	test   %al,%al
  800820:	74 04                	je     800826 <strcmp+0x1c>
  800822:	3a 02                	cmp    (%edx),%al
  800824:	74 ef                	je     800815 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800826:	0f b6 c0             	movzbl %al,%eax
  800829:	0f b6 12             	movzbl (%edx),%edx
  80082c:	29 d0                	sub    %edx,%eax
}
  80082e:	5d                   	pop    %ebp
  80082f:	c3                   	ret    

00800830 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800830:	55                   	push   %ebp
  800831:	89 e5                	mov    %esp,%ebp
  800833:	53                   	push   %ebx
  800834:	8b 45 08             	mov    0x8(%ebp),%eax
  800837:	8b 55 0c             	mov    0xc(%ebp),%edx
  80083a:	89 c3                	mov    %eax,%ebx
  80083c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80083f:	eb 06                	jmp    800847 <strncmp+0x17>
		n--, p++, q++;
  800841:	83 c0 01             	add    $0x1,%eax
  800844:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800847:	39 d8                	cmp    %ebx,%eax
  800849:	74 18                	je     800863 <strncmp+0x33>
  80084b:	0f b6 08             	movzbl (%eax),%ecx
  80084e:	84 c9                	test   %cl,%cl
  800850:	74 04                	je     800856 <strncmp+0x26>
  800852:	3a 0a                	cmp    (%edx),%cl
  800854:	74 eb                	je     800841 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800856:	0f b6 00             	movzbl (%eax),%eax
  800859:	0f b6 12             	movzbl (%edx),%edx
  80085c:	29 d0                	sub    %edx,%eax
}
  80085e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800861:	c9                   	leave  
  800862:	c3                   	ret    
		return 0;
  800863:	b8 00 00 00 00       	mov    $0x0,%eax
  800868:	eb f4                	jmp    80085e <strncmp+0x2e>

0080086a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80086a:	55                   	push   %ebp
  80086b:	89 e5                	mov    %esp,%ebp
  80086d:	8b 45 08             	mov    0x8(%ebp),%eax
  800870:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800874:	eb 03                	jmp    800879 <strchr+0xf>
  800876:	83 c0 01             	add    $0x1,%eax
  800879:	0f b6 10             	movzbl (%eax),%edx
  80087c:	84 d2                	test   %dl,%dl
  80087e:	74 06                	je     800886 <strchr+0x1c>
		if (*s == c)
  800880:	38 ca                	cmp    %cl,%dl
  800882:	75 f2                	jne    800876 <strchr+0xc>
  800884:	eb 05                	jmp    80088b <strchr+0x21>
			return (char *) s;
	return 0;
  800886:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80088b:	5d                   	pop    %ebp
  80088c:	c3                   	ret    

0080088d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80088d:	55                   	push   %ebp
  80088e:	89 e5                	mov    %esp,%ebp
  800890:	8b 45 08             	mov    0x8(%ebp),%eax
  800893:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800897:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80089a:	38 ca                	cmp    %cl,%dl
  80089c:	74 09                	je     8008a7 <strfind+0x1a>
  80089e:	84 d2                	test   %dl,%dl
  8008a0:	74 05                	je     8008a7 <strfind+0x1a>
	for (; *s; s++)
  8008a2:	83 c0 01             	add    $0x1,%eax
  8008a5:	eb f0                	jmp    800897 <strfind+0xa>
			break;
	return (char *) s;
}
  8008a7:	5d                   	pop    %ebp
  8008a8:	c3                   	ret    

008008a9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008a9:	55                   	push   %ebp
  8008aa:	89 e5                	mov    %esp,%ebp
  8008ac:	57                   	push   %edi
  8008ad:	56                   	push   %esi
  8008ae:	53                   	push   %ebx
  8008af:	8b 55 08             	mov    0x8(%ebp),%edx
  8008b2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  8008b5:	85 c9                	test   %ecx,%ecx
  8008b7:	74 33                	je     8008ec <memset+0x43>
		return v;
	if ((int) v % 4 == 0 && n % 4 == 0) {
  8008b9:	89 d0                	mov    %edx,%eax
  8008bb:	09 c8                	or     %ecx,%eax
  8008bd:	a8 03                	test   $0x3,%al
  8008bf:	75 23                	jne    8008e4 <memset+0x3b>
		c &= 0xFF;
  8008c1:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  8008c5:	89 d8                	mov    %ebx,%eax
  8008c7:	c1 e0 08             	shl    $0x8,%eax
  8008ca:	89 df                	mov    %ebx,%edi
  8008cc:	c1 e7 18             	shl    $0x18,%edi
  8008cf:	89 de                	mov    %ebx,%esi
  8008d1:	c1 e6 10             	shl    $0x10,%esi
  8008d4:	09 f7                	or     %esi,%edi
  8008d6:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
		             : "=D"(p), "=c"(n)
		             : "D"(p), "a"(c), "c"(n / 4)
  8008d8:	c1 e9 02             	shr    $0x2,%ecx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  8008db:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  8008dd:	89 d7                	mov    %edx,%edi
  8008df:	fc                   	cld    
  8008e0:	f3 ab                	rep stos %eax,%es:(%edi)
  8008e2:	eb 08                	jmp    8008ec <memset+0x43>
		             : "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008e4:	89 d7                	mov    %edx,%edi
  8008e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e9:	fc                   	cld    
  8008ea:	f3 aa                	rep stos %al,%es:(%edi)
		             : "=D"(p), "=c"(n)
		             : "0"(p), "a"(c), "1"(n)
		             : "cc", "memory");
	return v;
}
  8008ec:	89 d0                	mov    %edx,%eax
  8008ee:	5b                   	pop    %ebx
  8008ef:	5e                   	pop    %esi
  8008f0:	5f                   	pop    %edi
  8008f1:	5d                   	pop    %ebp
  8008f2:	c3                   	ret    

008008f3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008f3:	55                   	push   %ebp
  8008f4:	89 e5                	mov    %esp,%ebp
  8008f6:	57                   	push   %edi
  8008f7:	56                   	push   %esi
  8008f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008fe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800901:	39 c6                	cmp    %eax,%esi
  800903:	73 32                	jae    800937 <memmove+0x44>
  800905:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800908:	39 c2                	cmp    %eax,%edx
  80090a:	76 2b                	jbe    800937 <memmove+0x44>
		s += n;
		d += n;
  80090c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  80090f:	89 d6                	mov    %edx,%esi
  800911:	09 fe                	or     %edi,%esi
  800913:	09 ce                	or     %ecx,%esi
  800915:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80091b:	75 0e                	jne    80092b <memmove+0x38>
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  80091d:	83 ef 04             	sub    $0x4,%edi
			             "S"(s - 4),
  800920:	8d 72 fc             	lea    -0x4(%edx),%esi
			             "c"(n / 4)
  800923:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  800926:	fd                   	std    
  800927:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800929:	eb 09                	jmp    800934 <memmove+0x41>
			             : "cc", "memory");
		else
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  80092b:	83 ef 01             	sub    $0x1,%edi
			             "S"(s - 1),
  80092e:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  800931:	fd                   	std    
  800932:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             "c"(n)
			             : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800934:	fc                   	cld    
  800935:	eb 1a                	jmp    800951 <memmove+0x5e>
	} else {
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  800937:	89 f2                	mov    %esi,%edx
  800939:	09 c2                	or     %eax,%edx
  80093b:	09 ca                	or     %ecx,%edx
  80093d:	f6 c2 03             	test   $0x3,%dl
  800940:	75 0a                	jne    80094c <memmove+0x59>
			asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800942:	c1 e9 02             	shr    $0x2,%ecx
  800945:	89 c7                	mov    %eax,%edi
  800947:	fc                   	cld    
  800948:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80094a:	eb 05                	jmp    800951 <memmove+0x5e>
			             : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  80094c:	89 c7                	mov    %eax,%edi
  80094e:	fc                   	cld    
  80094f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             : "cc", "memory");
	}
	return dst;
}
  800951:	5e                   	pop    %esi
  800952:	5f                   	pop    %edi
  800953:	5d                   	pop    %ebp
  800954:	c3                   	ret    

00800955 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800955:	55                   	push   %ebp
  800956:	89 e5                	mov    %esp,%ebp
  800958:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80095b:	ff 75 10             	push   0x10(%ebp)
  80095e:	ff 75 0c             	push   0xc(%ebp)
  800961:	ff 75 08             	push   0x8(%ebp)
  800964:	e8 8a ff ff ff       	call   8008f3 <memmove>
}
  800969:	c9                   	leave  
  80096a:	c3                   	ret    

0080096b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	56                   	push   %esi
  80096f:	53                   	push   %ebx
  800970:	8b 45 08             	mov    0x8(%ebp),%eax
  800973:	8b 55 0c             	mov    0xc(%ebp),%edx
  800976:	89 c6                	mov    %eax,%esi
  800978:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80097b:	eb 06                	jmp    800983 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  80097d:	83 c0 01             	add    $0x1,%eax
  800980:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800983:	39 f0                	cmp    %esi,%eax
  800985:	74 14                	je     80099b <memcmp+0x30>
		if (*s1 != *s2)
  800987:	0f b6 08             	movzbl (%eax),%ecx
  80098a:	0f b6 1a             	movzbl (%edx),%ebx
  80098d:	38 d9                	cmp    %bl,%cl
  80098f:	74 ec                	je     80097d <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800991:	0f b6 c1             	movzbl %cl,%eax
  800994:	0f b6 db             	movzbl %bl,%ebx
  800997:	29 d8                	sub    %ebx,%eax
  800999:	eb 05                	jmp    8009a0 <memcmp+0x35>
	}

	return 0;
  80099b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009a0:	5b                   	pop    %ebx
  8009a1:	5e                   	pop    %esi
  8009a2:	5d                   	pop    %ebp
  8009a3:	c3                   	ret    

008009a4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009a4:	55                   	push   %ebp
  8009a5:	89 e5                	mov    %esp,%ebp
  8009a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009ad:	89 c2                	mov    %eax,%edx
  8009af:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009b2:	eb 03                	jmp    8009b7 <memfind+0x13>
  8009b4:	83 c0 01             	add    $0x1,%eax
  8009b7:	39 d0                	cmp    %edx,%eax
  8009b9:	73 04                	jae    8009bf <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009bb:	38 08                	cmp    %cl,(%eax)
  8009bd:	75 f5                	jne    8009b4 <memfind+0x10>
			break;
	return (void *) s;
}
  8009bf:	5d                   	pop    %ebp
  8009c0:	c3                   	ret    

008009c1 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009c1:	55                   	push   %ebp
  8009c2:	89 e5                	mov    %esp,%ebp
  8009c4:	57                   	push   %edi
  8009c5:	56                   	push   %esi
  8009c6:	53                   	push   %ebx
  8009c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8009ca:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009cd:	eb 03                	jmp    8009d2 <strtol+0x11>
		s++;
  8009cf:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  8009d2:	0f b6 02             	movzbl (%edx),%eax
  8009d5:	3c 20                	cmp    $0x20,%al
  8009d7:	74 f6                	je     8009cf <strtol+0xe>
  8009d9:	3c 09                	cmp    $0x9,%al
  8009db:	74 f2                	je     8009cf <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8009dd:	3c 2b                	cmp    $0x2b,%al
  8009df:	74 2a                	je     800a0b <strtol+0x4a>
	int neg = 0;
  8009e1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8009e6:	3c 2d                	cmp    $0x2d,%al
  8009e8:	74 2b                	je     800a15 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009ea:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009f0:	75 0f                	jne    800a01 <strtol+0x40>
  8009f2:	80 3a 30             	cmpb   $0x30,(%edx)
  8009f5:	74 28                	je     800a1f <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009f7:	85 db                	test   %ebx,%ebx
  8009f9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009fe:	0f 44 d8             	cmove  %eax,%ebx
  800a01:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a06:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a09:	eb 46                	jmp    800a51 <strtol+0x90>
		s++;
  800a0b:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800a0e:	bf 00 00 00 00       	mov    $0x0,%edi
  800a13:	eb d5                	jmp    8009ea <strtol+0x29>
		s++, neg = 1;
  800a15:	83 c2 01             	add    $0x1,%edx
  800a18:	bf 01 00 00 00       	mov    $0x1,%edi
  800a1d:	eb cb                	jmp    8009ea <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a1f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a23:	74 0e                	je     800a33 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800a25:	85 db                	test   %ebx,%ebx
  800a27:	75 d8                	jne    800a01 <strtol+0x40>
		s++, base = 8;
  800a29:	83 c2 01             	add    $0x1,%edx
  800a2c:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a31:	eb ce                	jmp    800a01 <strtol+0x40>
		s += 2, base = 16;
  800a33:	83 c2 02             	add    $0x2,%edx
  800a36:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a3b:	eb c4                	jmp    800a01 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a3d:	0f be c0             	movsbl %al,%eax
  800a40:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a43:	3b 45 10             	cmp    0x10(%ebp),%eax
  800a46:	7d 3a                	jge    800a82 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800a48:	83 c2 01             	add    $0x1,%edx
  800a4b:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800a4f:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800a51:	0f b6 02             	movzbl (%edx),%eax
  800a54:	8d 70 d0             	lea    -0x30(%eax),%esi
  800a57:	89 f3                	mov    %esi,%ebx
  800a59:	80 fb 09             	cmp    $0x9,%bl
  800a5c:	76 df                	jbe    800a3d <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800a5e:	8d 70 9f             	lea    -0x61(%eax),%esi
  800a61:	89 f3                	mov    %esi,%ebx
  800a63:	80 fb 19             	cmp    $0x19,%bl
  800a66:	77 08                	ja     800a70 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800a68:	0f be c0             	movsbl %al,%eax
  800a6b:	83 e8 57             	sub    $0x57,%eax
  800a6e:	eb d3                	jmp    800a43 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800a70:	8d 70 bf             	lea    -0x41(%eax),%esi
  800a73:	89 f3                	mov    %esi,%ebx
  800a75:	80 fb 19             	cmp    $0x19,%bl
  800a78:	77 08                	ja     800a82 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800a7a:	0f be c0             	movsbl %al,%eax
  800a7d:	83 e8 37             	sub    $0x37,%eax
  800a80:	eb c1                	jmp    800a43 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a82:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a86:	74 05                	je     800a8d <strtol+0xcc>
		*endptr = (char *) s;
  800a88:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a8b:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800a8d:	89 c8                	mov    %ecx,%eax
  800a8f:	f7 d8                	neg    %eax
  800a91:	85 ff                	test   %edi,%edi
  800a93:	0f 45 c8             	cmovne %eax,%ecx
}
  800a96:	89 c8                	mov    %ecx,%eax
  800a98:	5b                   	pop    %ebx
  800a99:	5e                   	pop    %esi
  800a9a:	5f                   	pop    %edi
  800a9b:	5d                   	pop    %ebp
  800a9c:	c3                   	ret    

00800a9d <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a9d:	55                   	push   %ebp
  800a9e:	89 e5                	mov    %esp,%ebp
  800aa0:	57                   	push   %edi
  800aa1:	56                   	push   %esi
  800aa2:	53                   	push   %ebx
  800aa3:	83 ec 1c             	sub    $0x1c,%esp
  800aa6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800aa9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800aac:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile(
  800aae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ab1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ab4:	8b 7d 10             	mov    0x10(%ebp),%edi
  800ab7:	8b 75 14             	mov    0x14(%ebp),%esi
  800aba:	cd 30                	int    $0x30
	        "int %1\n"
	        : "=a"(ret)
	        : "i"(T_SYSCALL), "a"(num), "d"(a1), "c"(a2), "b"(a3), "D"(a4), "S"(a5)
	        : "cc", "memory");

	if (check && ret > 0)
  800abc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ac0:	74 04                	je     800ac6 <syscall+0x29>
  800ac2:	85 c0                	test   %eax,%eax
  800ac4:	7f 08                	jg     800ace <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800ac6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ac9:	5b                   	pop    %ebx
  800aca:	5e                   	pop    %esi
  800acb:	5f                   	pop    %edi
  800acc:	5d                   	pop    %ebp
  800acd:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ace:	83 ec 0c             	sub    $0xc,%esp
  800ad1:	50                   	push   %eax
  800ad2:	ff 75 e0             	push   -0x20(%ebp)
  800ad5:	68 c4 16 80 00       	push   $0x8016c4
  800ada:	6a 1e                	push   $0x1e
  800adc:	68 e1 16 80 00       	push   $0x8016e1
  800ae1:	e8 5f f6 ff ff       	call   800145 <_panic>

00800ae6 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800ae6:	55                   	push   %ebp
  800ae7:	89 e5                	mov    %esp,%ebp
  800ae9:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t) s, len, 0, 0, 0);
  800aec:	6a 00                	push   $0x0
  800aee:	6a 00                	push   $0x0
  800af0:	6a 00                	push   $0x0
  800af2:	ff 75 0c             	push   0xc(%ebp)
  800af5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800af8:	ba 00 00 00 00       	mov    $0x0,%edx
  800afd:	b8 00 00 00 00       	mov    $0x0,%eax
  800b02:	e8 96 ff ff ff       	call   800a9d <syscall>
}
  800b07:	83 c4 10             	add    $0x10,%esp
  800b0a:	c9                   	leave  
  800b0b:	c3                   	ret    

00800b0c <sys_cgetc>:

int
sys_cgetc(void)
{
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800b12:	6a 00                	push   $0x0
  800b14:	6a 00                	push   $0x0
  800b16:	6a 00                	push   $0x0
  800b18:	6a 00                	push   $0x0
  800b1a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b1f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b24:	b8 01 00 00 00       	mov    $0x1,%eax
  800b29:	e8 6f ff ff ff       	call   800a9d <syscall>
}
  800b2e:	c9                   	leave  
  800b2f:	c3                   	ret    

00800b30 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b30:	55                   	push   %ebp
  800b31:	89 e5                	mov    %esp,%ebp
  800b33:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800b36:	6a 00                	push   $0x0
  800b38:	6a 00                	push   $0x0
  800b3a:	6a 00                	push   $0x0
  800b3c:	6a 00                	push   $0x0
  800b3e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b41:	ba 01 00 00 00       	mov    $0x1,%edx
  800b46:	b8 03 00 00 00       	mov    $0x3,%eax
  800b4b:	e8 4d ff ff ff       	call   800a9d <syscall>
}
  800b50:	c9                   	leave  
  800b51:	c3                   	ret    

00800b52 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b52:	55                   	push   %ebp
  800b53:	89 e5                	mov    %esp,%ebp
  800b55:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800b58:	6a 00                	push   $0x0
  800b5a:	6a 00                	push   $0x0
  800b5c:	6a 00                	push   $0x0
  800b5e:	6a 00                	push   $0x0
  800b60:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b65:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6a:	b8 02 00 00 00       	mov    $0x2,%eax
  800b6f:	e8 29 ff ff ff       	call   800a9d <syscall>
}
  800b74:	c9                   	leave  
  800b75:	c3                   	ret    

00800b76 <sys_yield>:

void
sys_yield(void)
{
  800b76:	55                   	push   %ebp
  800b77:	89 e5                	mov    %esp,%ebp
  800b79:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800b7c:	6a 00                	push   $0x0
  800b7e:	6a 00                	push   $0x0
  800b80:	6a 00                	push   $0x0
  800b82:	6a 00                	push   $0x0
  800b84:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b89:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b93:	e8 05 ff ff ff       	call   800a9d <syscall>
}
  800b98:	83 c4 10             	add    $0x10,%esp
  800b9b:	c9                   	leave  
  800b9c:	c3                   	ret    

00800b9d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b9d:	55                   	push   %ebp
  800b9e:	89 e5                	mov    %esp,%ebp
  800ba0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800ba3:	6a 00                	push   $0x0
  800ba5:	6a 00                	push   $0x0
  800ba7:	ff 75 10             	push   0x10(%ebp)
  800baa:	ff 75 0c             	push   0xc(%ebp)
  800bad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bb0:	ba 01 00 00 00       	mov    $0x1,%edx
  800bb5:	b8 04 00 00 00       	mov    $0x4,%eax
  800bba:	e8 de fe ff ff       	call   800a9d <syscall>
}
  800bbf:	c9                   	leave  
  800bc0:	c3                   	ret    

00800bc1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bc1:	55                   	push   %ebp
  800bc2:	89 e5                	mov    %esp,%ebp
  800bc4:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map,
  800bc7:	ff 75 18             	push   0x18(%ebp)
  800bca:	ff 75 14             	push   0x14(%ebp)
  800bcd:	ff 75 10             	push   0x10(%ebp)
  800bd0:	ff 75 0c             	push   0xc(%ebp)
  800bd3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bd6:	ba 01 00 00 00       	mov    $0x1,%edx
  800bdb:	b8 05 00 00 00       	mov    $0x5,%eax
  800be0:	e8 b8 fe ff ff       	call   800a9d <syscall>
	               srcenv,
	               (uint32_t) srcva,
	               dstenv,
	               (uint32_t) dstva,
	               perm);
}
  800be5:	c9                   	leave  
  800be6:	c3                   	ret    

00800be7 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800be7:	55                   	push   %ebp
  800be8:	89 e5                	mov    %esp,%ebp
  800bea:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800bed:	6a 00                	push   $0x0
  800bef:	6a 00                	push   $0x0
  800bf1:	6a 00                	push   $0x0
  800bf3:	ff 75 0c             	push   0xc(%ebp)
  800bf6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bf9:	ba 01 00 00 00       	mov    $0x1,%edx
  800bfe:	b8 06 00 00 00       	mov    $0x6,%eax
  800c03:	e8 95 fe ff ff       	call   800a9d <syscall>
}
  800c08:	c9                   	leave  
  800c09:	c3                   	ret    

00800c0a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c0a:	55                   	push   %ebp
  800c0b:	89 e5                	mov    %esp,%ebp
  800c0d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800c10:	6a 00                	push   $0x0
  800c12:	6a 00                	push   $0x0
  800c14:	6a 00                	push   $0x0
  800c16:	ff 75 0c             	push   0xc(%ebp)
  800c19:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c1c:	ba 01 00 00 00       	mov    $0x1,%edx
  800c21:	b8 08 00 00 00       	mov    $0x8,%eax
  800c26:	e8 72 fe ff ff       	call   800a9d <syscall>
}
  800c2b:	c9                   	leave  
  800c2c:	c3                   	ret    

00800c2d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c2d:	55                   	push   %ebp
  800c2e:	89 e5                	mov    %esp,%ebp
  800c30:	83 ec 08             	sub    $0x8,%esp
	return syscall(
  800c33:	6a 00                	push   $0x0
  800c35:	6a 00                	push   $0x0
  800c37:	6a 00                	push   $0x0
  800c39:	ff 75 0c             	push   0xc(%ebp)
  800c3c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c3f:	ba 01 00 00 00       	mov    $0x1,%edx
  800c44:	b8 09 00 00 00       	mov    $0x9,%eax
  800c49:	e8 4f fe ff ff       	call   800a9d <syscall>
	        SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c4e:	c9                   	leave  
  800c4f:	c3                   	ret    

00800c50 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c50:	55                   	push   %ebp
  800c51:	89 e5                	mov    %esp,%ebp
  800c53:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800c56:	6a 00                	push   $0x0
  800c58:	ff 75 14             	push   0x14(%ebp)
  800c5b:	ff 75 10             	push   0x10(%ebp)
  800c5e:	ff 75 0c             	push   0xc(%ebp)
  800c61:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c64:	ba 00 00 00 00       	mov    $0x0,%edx
  800c69:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c6e:	e8 2a fe ff ff       	call   800a9d <syscall>
}
  800c73:	c9                   	leave  
  800c74:	c3                   	ret    

00800c75 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c75:	55                   	push   %ebp
  800c76:	89 e5                	mov    %esp,%ebp
  800c78:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t) dstva, 0, 0, 0, 0);
  800c7b:	6a 00                	push   $0x0
  800c7d:	6a 00                	push   $0x0
  800c7f:	6a 00                	push   $0x0
  800c81:	6a 00                	push   $0x0
  800c83:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c86:	ba 01 00 00 00       	mov    $0x1,%edx
  800c8b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c90:	e8 08 fe ff ff       	call   800a9d <syscall>
}
  800c95:	c9                   	leave  
  800c96:	c3                   	ret    

00800c97 <sys_get_priority>:

// Get priority of the current process
int
sys_get_priority(void)
{
  800c97:	55                   	push   %ebp
  800c98:	89 e5                	mov    %esp,%ebp
  800c9a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_get_priority, 0, 0, 0, 0, 0, 0);
  800c9d:	6a 00                	push   $0x0
  800c9f:	6a 00                	push   $0x0
  800ca1:	6a 00                	push   $0x0
  800ca3:	6a 00                	push   $0x0
  800ca5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800caa:	ba 00 00 00 00       	mov    $0x0,%edx
  800caf:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cb4:	e8 e4 fd ff ff       	call   800a9d <syscall>
}
  800cb9:	c9                   	leave  
  800cba:	c3                   	ret    

00800cbb <sys_set_priority>:

// Get priority of the current process
int
sys_set_priority(unsigned int priority)
{
  800cbb:	55                   	push   %ebp
  800cbc:	89 e5                	mov    %esp,%ebp
  800cbe:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, (uint32_t) priority, 0, 0, 0, 0);
  800cc1:	6a 00                	push   $0x0
  800cc3:	6a 00                	push   $0x0
  800cc5:	6a 00                	push   $0x0
  800cc7:	6a 00                	push   $0x0
  800cc9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ccc:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd1:	b8 0e 00 00 00       	mov    $0xe,%eax
  800cd6:	e8 c2 fd ff ff       	call   800a9d <syscall>
}
  800cdb:	c9                   	leave  
  800cdc:	c3                   	ret    

00800cdd <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800cdd:	55                   	push   %ebp
  800cde:	89 e5                	mov    %esp,%ebp
  800ce0:	56                   	push   %esi
  800ce1:	53                   	push   %ebx
  800ce2:	89 c1                	mov    %eax,%ecx
	int r;

	void *addr = (void *) (pn << PGSHIFT);
  800ce4:	89 d6                	mov    %edx,%esi
  800ce6:	c1 e6 0c             	shl    $0xc,%esi

	pte_t pte = uvpt[pn];
  800ce9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx

	if (!(pte & PTE_P) || !(pte & PTE_U))
  800cf0:	89 d0                	mov    %edx,%eax
  800cf2:	83 e0 05             	and    $0x5,%eax
  800cf5:	83 f8 05             	cmp    $0x5,%eax
  800cf8:	75 5a                	jne    800d54 <duppage+0x77>
		panic("duppage: copy a non-present or non-user page");

	int perm = PTE_U | PTE_P;
	// Verifico permisos para páginas de IO
	if (pte & (PTE_PCD | PTE_PWT))
  800cfa:	89 d0                	mov    %edx,%eax
  800cfc:	83 e0 18             	and    $0x18,%eax
		perm |= PTE_PCD | PTE_PWT;
  800cff:	83 f8 01             	cmp    $0x1,%eax
  800d02:	19 c0                	sbb    %eax,%eax
  800d04:	83 e0 e8             	and    $0xffffffe8,%eax
  800d07:	83 c0 1d             	add    $0x1d,%eax


	// Si es de escritura o copy-on-write y NO es de IO
	if ((pte & PTE_W) || (pte & PTE_COW)) {
  800d0a:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800d10:	74 68                	je     800d7a <duppage+0x9d>
		// Mappeo en el hijo la página
		if ((r = sys_page_map(0, addr, envid, addr, perm | PTE_COW)) < 0)
  800d12:	80 cc 08             	or     $0x8,%ah
  800d15:	89 c3                	mov    %eax,%ebx
  800d17:	83 ec 0c             	sub    $0xc,%esp
  800d1a:	50                   	push   %eax
  800d1b:	56                   	push   %esi
  800d1c:	51                   	push   %ecx
  800d1d:	56                   	push   %esi
  800d1e:	6a 00                	push   $0x0
  800d20:	e8 9c fe ff ff       	call   800bc1 <sys_page_map>
  800d25:	83 c4 20             	add    $0x20,%esp
  800d28:	85 c0                	test   %eax,%eax
  800d2a:	78 3c                	js     800d68 <duppage+0x8b>
			panic("duppage: sys_page_map on childern COW: %e", r);

		// Cambio los permisos del padre
		if ((r = sys_page_map(0, addr, 0, addr, perm | PTE_COW)) < 0)
  800d2c:	83 ec 0c             	sub    $0xc,%esp
  800d2f:	53                   	push   %ebx
  800d30:	56                   	push   %esi
  800d31:	6a 00                	push   $0x0
  800d33:	56                   	push   %esi
  800d34:	6a 00                	push   $0x0
  800d36:	e8 86 fe ff ff       	call   800bc1 <sys_page_map>
  800d3b:	83 c4 20             	add    $0x20,%esp
  800d3e:	85 c0                	test   %eax,%eax
  800d40:	79 4d                	jns    800d8f <duppage+0xb2>
			panic("duppage: sys_page_map on parent COW: %e", r);
  800d42:	50                   	push   %eax
  800d43:	68 4c 17 80 00       	push   $0x80174c
  800d48:	6a 57                	push   $0x57
  800d4a:	68 41 18 80 00       	push   $0x801841
  800d4f:	e8 f1 f3 ff ff       	call   800145 <_panic>
		panic("duppage: copy a non-present or non-user page");
  800d54:	83 ec 04             	sub    $0x4,%esp
  800d57:	68 f0 16 80 00       	push   $0x8016f0
  800d5c:	6a 47                	push   $0x47
  800d5e:	68 41 18 80 00       	push   $0x801841
  800d63:	e8 dd f3 ff ff       	call   800145 <_panic>
			panic("duppage: sys_page_map on childern COW: %e", r);
  800d68:	50                   	push   %eax
  800d69:	68 20 17 80 00       	push   $0x801720
  800d6e:	6a 53                	push   $0x53
  800d70:	68 41 18 80 00       	push   $0x801841
  800d75:	e8 cb f3 ff ff       	call   800145 <_panic>
	} else {
		// Solo mappeo la página de solo lectura
		if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  800d7a:	83 ec 0c             	sub    $0xc,%esp
  800d7d:	50                   	push   %eax
  800d7e:	56                   	push   %esi
  800d7f:	51                   	push   %ecx
  800d80:	56                   	push   %esi
  800d81:	6a 00                	push   $0x0
  800d83:	e8 39 fe ff ff       	call   800bc1 <sys_page_map>
  800d88:	83 c4 20             	add    $0x20,%esp
  800d8b:	85 c0                	test   %eax,%eax
  800d8d:	78 0c                	js     800d9b <duppage+0xbe>
			panic("duppage: sys_page_map on childern RO: %e", r);
	}

	// panic("duppage not implemented");
	return 0;
}
  800d8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800d94:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d97:	5b                   	pop    %ebx
  800d98:	5e                   	pop    %esi
  800d99:	5d                   	pop    %ebp
  800d9a:	c3                   	ret    
			panic("duppage: sys_page_map on childern RO: %e", r);
  800d9b:	50                   	push   %eax
  800d9c:	68 74 17 80 00       	push   $0x801774
  800da1:	6a 5b                	push   $0x5b
  800da3:	68 41 18 80 00       	push   $0x801841
  800da8:	e8 98 f3 ff ff       	call   800145 <_panic>

00800dad <dup_or_share>:
 *
 * Hace uso de uvpd y uvpt para chequear permisos.
 */
static void
dup_or_share(envid_t envid, uint32_t pnum, int perm)
{
  800dad:	55                   	push   %ebp
  800dae:	89 e5                	mov    %esp,%ebp
  800db0:	57                   	push   %edi
  800db1:	56                   	push   %esi
  800db2:	53                   	push   %ebx
  800db3:	83 ec 0c             	sub    $0xc,%esp
  800db6:	89 c7                	mov    %eax,%edi
	int r;
	void *addr = (void *) (pnum << PGSHIFT);

	pte_t pte = uvpt[pnum];
  800db8:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax

	if (!(pte & PTE_P))
  800dbf:	a8 01                	test   $0x1,%al
  800dc1:	74 33                	je     800df6 <dup_or_share+0x49>
  800dc3:	89 d6                	mov    %edx,%esi
		return;

	// Filtro permisos
	perm &= (pte & PTE_W);
  800dc5:	21 c1                	and    %eax,%ecx
  800dc7:	89 cb                	mov    %ecx,%ebx
  800dc9:	83 e3 02             	and    $0x2,%ebx
	perm &= PTE_SYSCALL;


	if (pte & (PTE_PCD | PTE_PWT))
		perm |= PTE_PCD | PTE_PWT;
  800dcc:	89 da                	mov    %ebx,%edx
  800dce:	83 ca 18             	or     $0x18,%edx
  800dd1:	a8 18                	test   $0x18,%al
  800dd3:	0f 45 da             	cmovne %edx,%ebx
	void *addr = (void *) (pnum << PGSHIFT);
  800dd6:	c1 e6 0c             	shl    $0xc,%esi

	// Si tengo que copiar
	if (!(pte & PTE_W) || (pte & (PTE_PCD | PTE_PWT))) {
  800dd9:	83 e0 1a             	and    $0x1a,%eax
  800ddc:	83 f8 02             	cmp    $0x2,%eax
  800ddf:	74 32                	je     800e13 <dup_or_share+0x66>
		if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  800de1:	83 ec 0c             	sub    $0xc,%esp
  800de4:	53                   	push   %ebx
  800de5:	56                   	push   %esi
  800de6:	57                   	push   %edi
  800de7:	56                   	push   %esi
  800de8:	6a 00                	push   $0x0
  800dea:	e8 d2 fd ff ff       	call   800bc1 <sys_page_map>
  800def:	83 c4 20             	add    $0x20,%esp
  800df2:	85 c0                	test   %eax,%eax
  800df4:	78 08                	js     800dfe <dup_or_share+0x51>
			panic("dup_or_share: sys_page_map: %e", r);
		memmove(UTEMP, addr, PGSIZE);
		if ((r = sys_page_unmap(0, UTEMP)) < 0)
			panic("sys_page_unmap: %e", r);
	}
}
  800df6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800df9:	5b                   	pop    %ebx
  800dfa:	5e                   	pop    %esi
  800dfb:	5f                   	pop    %edi
  800dfc:	5d                   	pop    %ebp
  800dfd:	c3                   	ret    
			panic("dup_or_share: sys_page_map: %e", r);
  800dfe:	50                   	push   %eax
  800dff:	68 a0 17 80 00       	push   $0x8017a0
  800e04:	68 84 00 00 00       	push   $0x84
  800e09:	68 41 18 80 00       	push   $0x801841
  800e0e:	e8 32 f3 ff ff       	call   800145 <_panic>
		if ((r = sys_page_alloc(envid, addr, perm)) < 0)
  800e13:	83 ec 04             	sub    $0x4,%esp
  800e16:	53                   	push   %ebx
  800e17:	56                   	push   %esi
  800e18:	57                   	push   %edi
  800e19:	e8 7f fd ff ff       	call   800b9d <sys_page_alloc>
  800e1e:	83 c4 10             	add    $0x10,%esp
  800e21:	85 c0                	test   %eax,%eax
  800e23:	78 57                	js     800e7c <dup_or_share+0xcf>
		if ((r = sys_page_map(envid, addr, 0, UTEMP, perm)) < 0)
  800e25:	83 ec 0c             	sub    $0xc,%esp
  800e28:	53                   	push   %ebx
  800e29:	68 00 00 40 00       	push   $0x400000
  800e2e:	6a 00                	push   $0x0
  800e30:	56                   	push   %esi
  800e31:	57                   	push   %edi
  800e32:	e8 8a fd ff ff       	call   800bc1 <sys_page_map>
  800e37:	83 c4 20             	add    $0x20,%esp
  800e3a:	85 c0                	test   %eax,%eax
  800e3c:	78 53                	js     800e91 <dup_or_share+0xe4>
		memmove(UTEMP, addr, PGSIZE);
  800e3e:	83 ec 04             	sub    $0x4,%esp
  800e41:	68 00 10 00 00       	push   $0x1000
  800e46:	56                   	push   %esi
  800e47:	68 00 00 40 00       	push   $0x400000
  800e4c:	e8 a2 fa ff ff       	call   8008f3 <memmove>
		if ((r = sys_page_unmap(0, UTEMP)) < 0)
  800e51:	83 c4 08             	add    $0x8,%esp
  800e54:	68 00 00 40 00       	push   $0x400000
  800e59:	6a 00                	push   $0x0
  800e5b:	e8 87 fd ff ff       	call   800be7 <sys_page_unmap>
  800e60:	83 c4 10             	add    $0x10,%esp
  800e63:	85 c0                	test   %eax,%eax
  800e65:	79 8f                	jns    800df6 <dup_or_share+0x49>
			panic("sys_page_unmap: %e", r);
  800e67:	50                   	push   %eax
  800e68:	68 8b 18 80 00       	push   $0x80188b
  800e6d:	68 8d 00 00 00       	push   $0x8d
  800e72:	68 41 18 80 00       	push   $0x801841
  800e77:	e8 c9 f2 ff ff       	call   800145 <_panic>
			panic("dup_or_share: sys_page_alloc: %e", r);
  800e7c:	50                   	push   %eax
  800e7d:	68 c0 17 80 00       	push   $0x8017c0
  800e82:	68 88 00 00 00       	push   $0x88
  800e87:	68 41 18 80 00       	push   $0x801841
  800e8c:	e8 b4 f2 ff ff       	call   800145 <_panic>
			panic("dup_or_share: sys_page_map: %e", r);
  800e91:	50                   	push   %eax
  800e92:	68 a0 17 80 00       	push   $0x8017a0
  800e97:	68 8a 00 00 00       	push   $0x8a
  800e9c:	68 41 18 80 00       	push   $0x801841
  800ea1:	e8 9f f2 ff ff       	call   800145 <_panic>

00800ea6 <pgfault>:
{
  800ea6:	55                   	push   %ebp
  800ea7:	89 e5                	mov    %esp,%ebp
  800ea9:	53                   	push   %ebx
  800eaa:	83 ec 08             	sub    $0x8,%esp
	void *addr = (void *) utf->utf_fault_va;
  800ead:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb0:	8b 18                	mov    (%eax),%ebx
	pte_t fault_pte = uvpt[((uint32_t) addr) >> PGSHIFT];
  800eb2:	89 d8                	mov    %ebx,%eax
  800eb4:	c1 e8 0c             	shr    $0xc,%eax
  800eb7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if ((r = sys_page_alloc(0, PFTEMP, perm)) < 0)
  800ebe:	6a 07                	push   $0x7
  800ec0:	68 00 f0 7f 00       	push   $0x7ff000
  800ec5:	6a 00                	push   $0x0
  800ec7:	e8 d1 fc ff ff       	call   800b9d <sys_page_alloc>
  800ecc:	83 c4 10             	add    $0x10,%esp
  800ecf:	85 c0                	test   %eax,%eax
  800ed1:	78 51                	js     800f24 <pgfault+0x7e>
	addr = ROUNDDOWN(addr, PGSIZE);
  800ed3:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr, PGSIZE);
  800ed9:	83 ec 04             	sub    $0x4,%esp
  800edc:	68 00 10 00 00       	push   $0x1000
  800ee1:	53                   	push   %ebx
  800ee2:	68 00 f0 7f 00       	push   $0x7ff000
  800ee7:	e8 07 fa ff ff       	call   8008f3 <memmove>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, perm)) < 0)
  800eec:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ef3:	53                   	push   %ebx
  800ef4:	6a 00                	push   $0x0
  800ef6:	68 00 f0 7f 00       	push   $0x7ff000
  800efb:	6a 00                	push   $0x0
  800efd:	e8 bf fc ff ff       	call   800bc1 <sys_page_map>
  800f02:	83 c4 20             	add    $0x20,%esp
  800f05:	85 c0                	test   %eax,%eax
  800f07:	78 2d                	js     800f36 <pgfault+0x90>
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800f09:	83 ec 08             	sub    $0x8,%esp
  800f0c:	68 00 f0 7f 00       	push   $0x7ff000
  800f11:	6a 00                	push   $0x0
  800f13:	e8 cf fc ff ff       	call   800be7 <sys_page_unmap>
  800f18:	83 c4 10             	add    $0x10,%esp
  800f1b:	85 c0                	test   %eax,%eax
  800f1d:	78 29                	js     800f48 <pgfault+0xa2>
}
  800f1f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f22:	c9                   	leave  
  800f23:	c3                   	ret    
		panic("pgfault: sys_page_alloc: %e", r);
  800f24:	50                   	push   %eax
  800f25:	68 4c 18 80 00       	push   $0x80184c
  800f2a:	6a 27                	push   $0x27
  800f2c:	68 41 18 80 00       	push   $0x801841
  800f31:	e8 0f f2 ff ff       	call   800145 <_panic>
		panic("pgfault: sys_page_map: %e", r);
  800f36:	50                   	push   %eax
  800f37:	68 68 18 80 00       	push   $0x801868
  800f3c:	6a 2c                	push   $0x2c
  800f3e:	68 41 18 80 00       	push   $0x801841
  800f43:	e8 fd f1 ff ff       	call   800145 <_panic>
		panic("pgfault: sys_page_unmap: %e", r);
  800f48:	50                   	push   %eax
  800f49:	68 82 18 80 00       	push   $0x801882
  800f4e:	6a 2f                	push   $0x2f
  800f50:	68 41 18 80 00       	push   $0x801841
  800f55:	e8 eb f1 ff ff       	call   800145 <_panic>

00800f5a <fork_v0>:
 *  	-- Para ello se utiliza la funcion dup_or_share()
 *  	-- Se copian todas las paginas desde 0 hasta UTOP
 */
envid_t
fork_v0(void)
{
  800f5a:	55                   	push   %ebp
  800f5b:	89 e5                	mov    %esp,%ebp
  800f5d:	56                   	push   %esi
  800f5e:	53                   	push   %ebx

// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline)) sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2" : "=a"(ret) : "a"(SYS_exofork), "i"(T_SYSCALL));
  800f5f:	b8 07 00 00 00       	mov    $0x7,%eax
  800f64:	cd 30                	int    $0x30
  800f66:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();
	if (envid < 0)
  800f68:	85 c0                	test   %eax,%eax
  800f6a:	78 23                	js     800f8f <fork_v0+0x35>
	// Parent
	uint32_t pnum = 0;
	uint32_t pnum_end = (UTOP >> PGSHIFT);
	int perm = PTE_P | PTE_U | PTE_W;

	for (pnum = 0; pnum < pnum_end; pnum++) {
  800f6c:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid == 0) {
  800f71:	75 3c                	jne    800faf <fork_v0+0x55>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f73:	e8 da fb ff ff       	call   800b52 <sys_getenvid>
  800f78:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f7d:	69 c0 88 00 00 00    	imul   $0x88,%eax,%eax
  800f83:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f88:	a3 08 20 80 00       	mov    %eax,0x802008
		return 0;
  800f8d:	eb 56                	jmp    800fe5 <fork_v0+0x8b>
		panic("sys_exofork: %e", envid);
  800f8f:	50                   	push   %eax
  800f90:	68 9e 18 80 00       	push   $0x80189e
  800f95:	68 a2 00 00 00       	push   $0xa2
  800f9a:	68 41 18 80 00       	push   $0x801841
  800f9f:	e8 a1 f1 ff ff       	call   800145 <_panic>
	for (pnum = 0; pnum < pnum_end; pnum++) {
  800fa4:	83 c3 01             	add    $0x1,%ebx
  800fa7:	81 fb 00 ec 0e 00    	cmp    $0xeec00,%ebx
  800fad:	74 24                	je     800fd3 <fork_v0+0x79>
		pde_t pde = uvpd[pnum >> 10];
  800faf:	89 d8                	mov    %ebx,%eax
  800fb1:	c1 e8 0a             	shr    $0xa,%eax
  800fb4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
		if (!(pde & PTE_P) || !(pde & PTE_U))
  800fbb:	83 e0 05             	and    $0x5,%eax
  800fbe:	83 f8 05             	cmp    $0x5,%eax
  800fc1:	75 e1                	jne    800fa4 <fork_v0+0x4a>
			continue;
		dup_or_share(envid, pnum, perm);
  800fc3:	b9 07 00 00 00       	mov    $0x7,%ecx
  800fc8:	89 da                	mov    %ebx,%edx
  800fca:	89 f0                	mov    %esi,%eax
  800fcc:	e8 dc fd ff ff       	call   800dad <dup_or_share>
  800fd1:	eb d1                	jmp    800fa4 <fork_v0+0x4a>
	}


	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800fd3:	83 ec 08             	sub    $0x8,%esp
  800fd6:	6a 02                	push   $0x2
  800fd8:	56                   	push   %esi
  800fd9:	e8 2c fc ff ff       	call   800c0a <sys_env_set_status>
  800fde:	83 c4 10             	add    $0x10,%esp
  800fe1:	85 c0                	test   %eax,%eax
  800fe3:	78 09                	js     800fee <fork_v0+0x94>
		panic("sys_env_set_status: %e", r);

	return envid;
}
  800fe5:	89 f0                	mov    %esi,%eax
  800fe7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fea:	5b                   	pop    %ebx
  800feb:	5e                   	pop    %esi
  800fec:	5d                   	pop    %ebp
  800fed:	c3                   	ret    
		panic("sys_env_set_status: %e", r);
  800fee:	50                   	push   %eax
  800fef:	68 ae 18 80 00       	push   $0x8018ae
  800ff4:	68 b8 00 00 00       	push   $0xb8
  800ff9:	68 41 18 80 00       	push   $0x801841
  800ffe:	e8 42 f1 ff ff       	call   800145 <_panic>

00801003 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801003:	55                   	push   %ebp
  801004:	89 e5                	mov    %esp,%ebp
  801006:	56                   	push   %esi
  801007:	53                   	push   %ebx
	set_pgfault_handler(pgfault);
  801008:	83 ec 0c             	sub    $0xc,%esp
  80100b:	68 a6 0e 80 00       	push   $0x800ea6
  801010:	e8 2a 01 00 00       	call   80113f <set_pgfault_handler>
  801015:	b8 07 00 00 00       	mov    $0x7,%eax
  80101a:	cd 30                	int    $0x30
  80101c:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();

	if (envid < 0)
  80101e:	83 c4 10             	add    $0x10,%esp
  801021:	85 c0                	test   %eax,%eax
  801023:	78 26                	js     80104b <fork+0x48>
	// Parent
	uint32_t pnum = 0;
	uint32_t pnum_end = (UTOP >> PGSHIFT);

	// Handle all pages below UTOP
	for (pnum = 0; pnum < pnum_end; pnum++) {
  801025:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid == 0) {
  80102a:	75 41                	jne    80106d <fork+0x6a>
		thisenv = &envs[ENVX(sys_getenvid())];
  80102c:	e8 21 fb ff ff       	call   800b52 <sys_getenvid>
  801031:	25 ff 03 00 00       	and    $0x3ff,%eax
  801036:	69 c0 88 00 00 00    	imul   $0x88,%eax,%eax
  80103c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801041:	a3 08 20 80 00       	mov    %eax,0x802008
		return 0;
  801046:	e9 92 00 00 00       	jmp    8010dd <fork+0xda>
		panic("sys_exofork: %e", envid);
  80104b:	50                   	push   %eax
  80104c:	68 9e 18 80 00       	push   $0x80189e
  801051:	68 d5 00 00 00       	push   $0xd5
  801056:	68 41 18 80 00       	push   $0x801841
  80105b:	e8 e5 f0 ff ff       	call   800145 <_panic>
	for (pnum = 0; pnum < pnum_end; pnum++) {
  801060:	83 c3 01             	add    $0x1,%ebx
  801063:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  801069:	77 30                	ja     80109b <fork+0x98>
		if (pnum == ((UXSTACKTOP >> PGSHIFT) - 1))
  80106b:	74 f3                	je     801060 <fork+0x5d>
			continue;

		pde_t pde = uvpd[pnum >> 10];
  80106d:	89 d8                	mov    %ebx,%eax
  80106f:	c1 e8 0a             	shr    $0xa,%eax
  801072:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
		if (!(pde & PTE_P) || !(pde & PTE_U))
  801079:	83 e0 05             	and    $0x5,%eax
  80107c:	83 f8 05             	cmp    $0x5,%eax
  80107f:	75 df                	jne    801060 <fork+0x5d>
			continue;

		pte_t pte = uvpt[pnum];
  801081:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
		if (!(pte & PTE_P) || !(pte & PTE_U))
  801088:	83 e0 05             	and    $0x5,%eax
  80108b:	83 f8 05             	cmp    $0x5,%eax
  80108e:	75 d0                	jne    801060 <fork+0x5d>
			continue;
		duppage(envid, pnum);
  801090:	89 da                	mov    %ebx,%edx
  801092:	89 f0                	mov    %esi,%eax
  801094:	e8 44 fc ff ff       	call   800cdd <duppage>
  801099:	eb c5                	jmp    801060 <fork+0x5d>
	}

	uint32_t exstk = (UXSTACKTOP - PGSIZE);
	int r = sys_page_alloc(envid, (void *) exstk, PTE_U | PTE_P | PTE_W);
  80109b:	83 ec 04             	sub    $0x4,%esp
  80109e:	6a 07                	push   $0x7
  8010a0:	68 00 f0 bf ee       	push   $0xeebff000
  8010a5:	56                   	push   %esi
  8010a6:	e8 f2 fa ff ff       	call   800b9d <sys_page_alloc>
	if (r < 0)
  8010ab:	83 c4 10             	add    $0x10,%esp
  8010ae:	85 c0                	test   %eax,%eax
  8010b0:	78 34                	js     8010e6 <fork+0xe3>
		panic("fork: sys_page_alloc of exception stk: %e", r);
	r = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  8010b2:	a1 08 20 80 00       	mov    0x802008,%eax
  8010b7:	8b 40 70             	mov    0x70(%eax),%eax
  8010ba:	83 ec 08             	sub    $0x8,%esp
  8010bd:	50                   	push   %eax
  8010be:	56                   	push   %esi
  8010bf:	e8 69 fb ff ff       	call   800c2d <sys_env_set_pgfault_upcall>
	if (r < 0)
  8010c4:	83 c4 10             	add    $0x10,%esp
  8010c7:	85 c0                	test   %eax,%eax
  8010c9:	78 30                	js     8010fb <fork+0xf8>
		panic("fork: sys_env_set_pgfault_upcall on childern: %e", r);

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8010cb:	83 ec 08             	sub    $0x8,%esp
  8010ce:	6a 02                	push   $0x2
  8010d0:	56                   	push   %esi
  8010d1:	e8 34 fb ff ff       	call   800c0a <sys_env_set_status>
  8010d6:	83 c4 10             	add    $0x10,%esp
  8010d9:	85 c0                	test   %eax,%eax
  8010db:	78 33                	js     801110 <fork+0x10d>
		panic("sys_env_set_status: %e", r);

	return envid;
}
  8010dd:	89 f0                	mov    %esi,%eax
  8010df:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010e2:	5b                   	pop    %ebx
  8010e3:	5e                   	pop    %esi
  8010e4:	5d                   	pop    %ebp
  8010e5:	c3                   	ret    
		panic("fork: sys_page_alloc of exception stk: %e", r);
  8010e6:	50                   	push   %eax
  8010e7:	68 e4 17 80 00       	push   $0x8017e4
  8010ec:	68 f2 00 00 00       	push   $0xf2
  8010f1:	68 41 18 80 00       	push   $0x801841
  8010f6:	e8 4a f0 ff ff       	call   800145 <_panic>
		panic("fork: sys_env_set_pgfault_upcall on childern: %e", r);
  8010fb:	50                   	push   %eax
  8010fc:	68 10 18 80 00       	push   $0x801810
  801101:	68 f5 00 00 00       	push   $0xf5
  801106:	68 41 18 80 00       	push   $0x801841
  80110b:	e8 35 f0 ff ff       	call   800145 <_panic>
		panic("sys_env_set_status: %e", r);
  801110:	50                   	push   %eax
  801111:	68 ae 18 80 00       	push   $0x8018ae
  801116:	68 f8 00 00 00       	push   $0xf8
  80111b:	68 41 18 80 00       	push   $0x801841
  801120:	e8 20 f0 ff ff       	call   800145 <_panic>

00801125 <sfork>:

// Challenge!
int
sfork(void)
{
  801125:	55                   	push   %ebp
  801126:	89 e5                	mov    %esp,%ebp
  801128:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80112b:	68 c5 18 80 00       	push   $0x8018c5
  801130:	68 01 01 00 00       	push   $0x101
  801135:	68 41 18 80 00       	push   $0x801841
  80113a:	e8 06 f0 ff ff       	call   800145 <_panic>

0080113f <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80113f:	55                   	push   %ebp
  801140:	89 e5                	mov    %esp,%ebp
  801142:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801145:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  80114c:	74 0a                	je     801158 <set_pgfault_handler+0x19>
		if (r < 0)
			return;
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80114e:	8b 45 08             	mov    0x8(%ebp),%eax
  801151:	a3 0c 20 80 00       	mov    %eax,0x80200c
}
  801156:	c9                   	leave  
  801157:	c3                   	ret    
		r = sys_page_alloc(0, (void *) exstk, perm);
  801158:	83 ec 04             	sub    $0x4,%esp
  80115b:	6a 07                	push   $0x7
  80115d:	68 00 f0 bf ee       	push   $0xeebff000
  801162:	6a 00                	push   $0x0
  801164:	e8 34 fa ff ff       	call   800b9d <sys_page_alloc>
		if (r < 0)
  801169:	83 c4 10             	add    $0x10,%esp
  80116c:	85 c0                	test   %eax,%eax
  80116e:	78 e6                	js     801156 <set_pgfault_handler+0x17>
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801170:	83 ec 08             	sub    $0x8,%esp
  801173:	68 88 11 80 00       	push   $0x801188
  801178:	6a 00                	push   $0x0
  80117a:	e8 ae fa ff ff       	call   800c2d <sys_env_set_pgfault_upcall>
		if (r < 0)
  80117f:	83 c4 10             	add    $0x10,%esp
  801182:	85 c0                	test   %eax,%eax
  801184:	79 c8                	jns    80114e <set_pgfault_handler+0xf>
  801186:	eb ce                	jmp    801156 <set_pgfault_handler+0x17>

00801188 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801188:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801189:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  80118e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801190:	83 c4 04             	add    $0x4,%esp
	// Throughout the remaining code, think carefully about what
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	movl 40(%esp), %eax	// trap-time %epi -> %eax 
  801193:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %ebx	// trap-time %esp -> %ebx
  801197:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4, %ebx
  80119b:	83 eb 04             	sub    $0x4,%ebx
	movl %eax, 0(%ebx)	// push %eip in trap-time stack
  80119e:	89 03                	mov    %eax,(%ebx)

	movl %ebx, 48(%esp)
  8011a0:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	popl %eax
  8011a4:	58                   	pop    %eax
	popl %eax
  8011a5:	58                   	pop    %eax
	popal
  8011a6:	61                   	popa   
	

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	addl $4, %esp
  8011a7:	83 c4 04             	add    $0x4,%esp
	popfl
  8011aa:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	popl %esp
  8011ab:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	ret
  8011ac:	c3                   	ret    
  8011ad:	66 90                	xchg   %ax,%ax
  8011af:	90                   	nop

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
