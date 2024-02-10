
obj/user/testbss:     formato del fichero elf32-i386


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
  80002c:	e8 ab 00 00 00       	call   8000dc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  800039:	68 20 0f 80 00       	push   $0x800f20
  80003e:	e8 d3 01 00 00       	call   800216 <cprintf>
  800043:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < ARRAYSIZE; i++)
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  80004b:	83 3c 85 20 20 80 00 	cmpl   $0x0,0x802020(,%eax,4)
  800052:	00 
  800053:	75 63                	jne    8000b8 <umain+0x85>
	for (i = 0; i < ARRAYSIZE; i++)
  800055:	83 c0 01             	add    $0x1,%eax
  800058:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80005d:	75 ec                	jne    80004b <umain+0x18>
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  80005f:	b8 00 00 00 00       	mov    $0x0,%eax
		bigarray[i] = i;
  800064:	89 04 85 20 20 80 00 	mov    %eax,0x802020(,%eax,4)
	for (i = 0; i < ARRAYSIZE; i++)
  80006b:	83 c0 01             	add    $0x1,%eax
  80006e:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800073:	75 ef                	jne    800064 <umain+0x31>
	for (i = 0; i < ARRAYSIZE; i++)
  800075:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != i)
  80007a:	39 04 85 20 20 80 00 	cmp    %eax,0x802020(,%eax,4)
  800081:	75 47                	jne    8000ca <umain+0x97>
	for (i = 0; i < ARRAYSIZE; i++)
  800083:	83 c0 01             	add    $0x1,%eax
  800086:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80008b:	75 ed                	jne    80007a <umain+0x47>
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  80008d:	83 ec 0c             	sub    $0xc,%esp
  800090:	68 68 0f 80 00       	push   $0x800f68
  800095:	e8 7c 01 00 00       	call   800216 <cprintf>
	bigarray[ARRAYSIZE + 1024] = 0;
  80009a:	c7 05 20 30 c0 00 00 	movl   $0x0,0xc03020
  8000a1:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000a4:	83 c4 0c             	add    $0xc,%esp
  8000a7:	68 c7 0f 80 00       	push   $0x800fc7
  8000ac:	6a 1a                	push   $0x1a
  8000ae:	68 b8 0f 80 00       	push   $0x800fb8
  8000b3:	e8 83 00 00 00       	call   80013b <_panic>
			panic("bigarray[%d] isn't cleared!\n", i);
  8000b8:	50                   	push   %eax
  8000b9:	68 9b 0f 80 00       	push   $0x800f9b
  8000be:	6a 11                	push   $0x11
  8000c0:	68 b8 0f 80 00       	push   $0x800fb8
  8000c5:	e8 71 00 00 00       	call   80013b <_panic>
			panic("bigarray[%d] didn't hold its value!\n", i);
  8000ca:	50                   	push   %eax
  8000cb:	68 40 0f 80 00       	push   $0x800f40
  8000d0:	6a 16                	push   $0x16
  8000d2:	68 b8 0f 80 00       	push   $0x800fb8
  8000d7:	e8 5f 00 00 00       	call   80013b <_panic>

008000dc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
  8000e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000e4:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	envid_t id = sys_getenvid();
  8000e7:	e8 5c 0a 00 00       	call   800b48 <sys_getenvid>
	if (id >= 0)
  8000ec:	85 c0                	test   %eax,%eax
  8000ee:	78 15                	js     800105 <libmain+0x29>
		thisenv = &envs[ENVX(id)];
  8000f0:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f5:	69 c0 88 00 00 00    	imul   $0x88,%eax,%eax
  8000fb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800100:	a3 20 20 c0 00       	mov    %eax,0xc02020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800105:	85 db                	test   %ebx,%ebx
  800107:	7e 07                	jle    800110 <libmain+0x34>
		binaryname = argv[0];
  800109:	8b 06                	mov    (%esi),%eax
  80010b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800110:	83 ec 08             	sub    $0x8,%esp
  800113:	56                   	push   %esi
  800114:	53                   	push   %ebx
  800115:	e8 19 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80011a:	e8 0a 00 00 00       	call   800129 <exit>
}
  80011f:	83 c4 10             	add    $0x10,%esp
  800122:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800125:	5b                   	pop    %ebx
  800126:	5e                   	pop    %esi
  800127:	5d                   	pop    %ebp
  800128:	c3                   	ret    

00800129 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800129:	55                   	push   %ebp
  80012a:	89 e5                	mov    %esp,%ebp
  80012c:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80012f:	6a 00                	push   $0x0
  800131:	e8 f0 09 00 00       	call   800b26 <sys_env_destroy>
}
  800136:	83 c4 10             	add    $0x10,%esp
  800139:	c9                   	leave  
  80013a:	c3                   	ret    

0080013b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	56                   	push   %esi
  80013f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800140:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800143:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800149:	e8 fa 09 00 00       	call   800b48 <sys_getenvid>
  80014e:	83 ec 0c             	sub    $0xc,%esp
  800151:	ff 75 0c             	push   0xc(%ebp)
  800154:	ff 75 08             	push   0x8(%ebp)
  800157:	56                   	push   %esi
  800158:	50                   	push   %eax
  800159:	68 e8 0f 80 00       	push   $0x800fe8
  80015e:	e8 b3 00 00 00       	call   800216 <cprintf>
	        sys_getenvid(),
	        binaryname,
	        file,
	        line);
	vcprintf(fmt, ap);
  800163:	83 c4 18             	add    $0x18,%esp
  800166:	53                   	push   %ebx
  800167:	ff 75 10             	push   0x10(%ebp)
  80016a:	e8 56 00 00 00       	call   8001c5 <vcprintf>
	cprintf("\n");
  80016f:	c7 04 24 b6 0f 80 00 	movl   $0x800fb6,(%esp)
  800176:	e8 9b 00 00 00       	call   800216 <cprintf>
  80017b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80017e:	cc                   	int3   
  80017f:	eb fd                	jmp    80017e <_panic+0x43>

00800181 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800181:	55                   	push   %ebp
  800182:	89 e5                	mov    %esp,%ebp
  800184:	53                   	push   %ebx
  800185:	83 ec 04             	sub    $0x4,%esp
  800188:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80018b:	8b 13                	mov    (%ebx),%edx
  80018d:	8d 42 01             	lea    0x1(%edx),%eax
  800190:	89 03                	mov    %eax,(%ebx)
  800192:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800195:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256 - 1) {
  800199:	3d ff 00 00 00       	cmp    $0xff,%eax
  80019e:	74 09                	je     8001a9 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001a0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001a7:	c9                   	leave  
  8001a8:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001a9:	83 ec 08             	sub    $0x8,%esp
  8001ac:	68 ff 00 00 00       	push   $0xff
  8001b1:	8d 43 08             	lea    0x8(%ebx),%eax
  8001b4:	50                   	push   %eax
  8001b5:	e8 22 09 00 00       	call   800adc <sys_cputs>
		b->idx = 0;
  8001ba:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001c0:	83 c4 10             	add    $0x10,%esp
  8001c3:	eb db                	jmp    8001a0 <putch+0x1f>

008001c5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001c5:	55                   	push   %ebp
  8001c6:	89 e5                	mov    %esp,%ebp
  8001c8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001ce:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001d5:	00 00 00 
	b.cnt = 0;
  8001d8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001df:	00 00 00 
	vprintfmt((void *) putch, &b, fmt, ap);
  8001e2:	ff 75 0c             	push   0xc(%ebp)
  8001e5:	ff 75 08             	push   0x8(%ebp)
  8001e8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001ee:	50                   	push   %eax
  8001ef:	68 81 01 80 00       	push   $0x800181
  8001f4:	e8 74 01 00 00       	call   80036d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f9:	83 c4 08             	add    $0x8,%esp
  8001fc:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800202:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800208:	50                   	push   %eax
  800209:	e8 ce 08 00 00       	call   800adc <sys_cputs>

	return b.cnt;
}
  80020e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800214:	c9                   	leave  
  800215:	c3                   	ret    

00800216 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800216:	55                   	push   %ebp
  800217:	89 e5                	mov    %esp,%ebp
  800219:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80021c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80021f:	50                   	push   %eax
  800220:	ff 75 08             	push   0x8(%ebp)
  800223:	e8 9d ff ff ff       	call   8001c5 <vcprintf>
	va_end(ap);

	return cnt;
}
  800228:	c9                   	leave  
  800229:	c3                   	ret    

0080022a <printnum>:
         void *putdat,
         unsigned long long num,
         unsigned base,
         int width,
         int padc)
{
  80022a:	55                   	push   %ebp
  80022b:	89 e5                	mov    %esp,%ebp
  80022d:	57                   	push   %edi
  80022e:	56                   	push   %esi
  80022f:	53                   	push   %ebx
  800230:	83 ec 1c             	sub    $0x1c,%esp
  800233:	89 c7                	mov    %eax,%edi
  800235:	89 d6                	mov    %edx,%esi
  800237:	8b 45 08             	mov    0x8(%ebp),%eax
  80023a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80023d:	89 d1                	mov    %edx,%ecx
  80023f:	89 c2                	mov    %eax,%edx
  800241:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800244:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800247:	8b 45 10             	mov    0x10(%ebp),%eax
  80024a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80024d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800250:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800257:	39 c2                	cmp    %eax,%edx
  800259:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80025c:	72 3e                	jb     80029c <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80025e:	83 ec 0c             	sub    $0xc,%esp
  800261:	ff 75 18             	push   0x18(%ebp)
  800264:	83 eb 01             	sub    $0x1,%ebx
  800267:	53                   	push   %ebx
  800268:	50                   	push   %eax
  800269:	83 ec 08             	sub    $0x8,%esp
  80026c:	ff 75 e4             	push   -0x1c(%ebp)
  80026f:	ff 75 e0             	push   -0x20(%ebp)
  800272:	ff 75 dc             	push   -0x24(%ebp)
  800275:	ff 75 d8             	push   -0x28(%ebp)
  800278:	e8 63 0a 00 00       	call   800ce0 <__udivdi3>
  80027d:	83 c4 18             	add    $0x18,%esp
  800280:	52                   	push   %edx
  800281:	50                   	push   %eax
  800282:	89 f2                	mov    %esi,%edx
  800284:	89 f8                	mov    %edi,%eax
  800286:	e8 9f ff ff ff       	call   80022a <printnum>
  80028b:	83 c4 20             	add    $0x20,%esp
  80028e:	eb 13                	jmp    8002a3 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800290:	83 ec 08             	sub    $0x8,%esp
  800293:	56                   	push   %esi
  800294:	ff 75 18             	push   0x18(%ebp)
  800297:	ff d7                	call   *%edi
  800299:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80029c:	83 eb 01             	sub    $0x1,%ebx
  80029f:	85 db                	test   %ebx,%ebx
  8002a1:	7f ed                	jg     800290 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a3:	83 ec 08             	sub    $0x8,%esp
  8002a6:	56                   	push   %esi
  8002a7:	83 ec 04             	sub    $0x4,%esp
  8002aa:	ff 75 e4             	push   -0x1c(%ebp)
  8002ad:	ff 75 e0             	push   -0x20(%ebp)
  8002b0:	ff 75 dc             	push   -0x24(%ebp)
  8002b3:	ff 75 d8             	push   -0x28(%ebp)
  8002b6:	e8 45 0b 00 00       	call   800e00 <__umoddi3>
  8002bb:	83 c4 14             	add    $0x14,%esp
  8002be:	0f be 80 0b 10 80 00 	movsbl 0x80100b(%eax),%eax
  8002c5:	50                   	push   %eax
  8002c6:	ff d7                	call   *%edi
}
  8002c8:	83 c4 10             	add    $0x10,%esp
  8002cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ce:	5b                   	pop    %ebx
  8002cf:	5e                   	pop    %esi
  8002d0:	5f                   	pop    %edi
  8002d1:	5d                   	pop    %ebp
  8002d2:	c3                   	ret    

008002d3 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8002d3:	83 fa 01             	cmp    $0x1,%edx
  8002d6:	7f 13                	jg     8002eb <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8002d8:	85 d2                	test   %edx,%edx
  8002da:	74 1c                	je     8002f8 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  8002dc:	8b 10                	mov    (%eax),%edx
  8002de:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e1:	89 08                	mov    %ecx,(%eax)
  8002e3:	8b 02                	mov    (%edx),%eax
  8002e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ea:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  8002eb:	8b 10                	mov    (%eax),%edx
  8002ed:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002f0:	89 08                	mov    %ecx,(%eax)
  8002f2:	8b 02                	mov    (%edx),%eax
  8002f4:	8b 52 04             	mov    0x4(%edx),%edx
  8002f7:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  8002f8:	8b 10                	mov    (%eax),%edx
  8002fa:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002fd:	89 08                	mov    %ecx,(%eax)
  8002ff:	8b 02                	mov    (%edx),%eax
  800301:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800306:	c3                   	ret    

00800307 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800307:	83 fa 01             	cmp    $0x1,%edx
  80030a:	7f 0f                	jg     80031b <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  80030c:	85 d2                	test   %edx,%edx
  80030e:	74 18                	je     800328 <getint+0x21>
		return va_arg(*ap, long);
  800310:	8b 10                	mov    (%eax),%edx
  800312:	8d 4a 04             	lea    0x4(%edx),%ecx
  800315:	89 08                	mov    %ecx,(%eax)
  800317:	8b 02                	mov    (%edx),%eax
  800319:	99                   	cltd   
  80031a:	c3                   	ret    
		return va_arg(*ap, long long);
  80031b:	8b 10                	mov    (%eax),%edx
  80031d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800320:	89 08                	mov    %ecx,(%eax)
  800322:	8b 02                	mov    (%edx),%eax
  800324:	8b 52 04             	mov    0x4(%edx),%edx
  800327:	c3                   	ret    
	else
		return va_arg(*ap, int);
  800328:	8b 10                	mov    (%eax),%edx
  80032a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80032d:	89 08                	mov    %ecx,(%eax)
  80032f:	8b 02                	mov    (%edx),%eax
  800331:	99                   	cltd   
}
  800332:	c3                   	ret    

00800333 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800333:	55                   	push   %ebp
  800334:	89 e5                	mov    %esp,%ebp
  800336:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800339:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80033d:	8b 10                	mov    (%eax),%edx
  80033f:	3b 50 04             	cmp    0x4(%eax),%edx
  800342:	73 0a                	jae    80034e <sprintputch+0x1b>
		*b->buf++ = ch;
  800344:	8d 4a 01             	lea    0x1(%edx),%ecx
  800347:	89 08                	mov    %ecx,(%eax)
  800349:	8b 45 08             	mov    0x8(%ebp),%eax
  80034c:	88 02                	mov    %al,(%edx)
}
  80034e:	5d                   	pop    %ebp
  80034f:	c3                   	ret    

00800350 <printfmt>:
{
  800350:	55                   	push   %ebp
  800351:	89 e5                	mov    %esp,%ebp
  800353:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800356:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800359:	50                   	push   %eax
  80035a:	ff 75 10             	push   0x10(%ebp)
  80035d:	ff 75 0c             	push   0xc(%ebp)
  800360:	ff 75 08             	push   0x8(%ebp)
  800363:	e8 05 00 00 00       	call   80036d <vprintfmt>
}
  800368:	83 c4 10             	add    $0x10,%esp
  80036b:	c9                   	leave  
  80036c:	c3                   	ret    

0080036d <vprintfmt>:
{
  80036d:	55                   	push   %ebp
  80036e:	89 e5                	mov    %esp,%ebp
  800370:	57                   	push   %edi
  800371:	56                   	push   %esi
  800372:	53                   	push   %ebx
  800373:	83 ec 2c             	sub    $0x2c,%esp
  800376:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800379:	8b 75 0c             	mov    0xc(%ebp),%esi
  80037c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80037f:	eb 0a                	jmp    80038b <vprintfmt+0x1e>
			putch(ch, putdat);
  800381:	83 ec 08             	sub    $0x8,%esp
  800384:	56                   	push   %esi
  800385:	50                   	push   %eax
  800386:	ff d3                	call   *%ebx
  800388:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80038b:	83 c7 01             	add    $0x1,%edi
  80038e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800392:	83 f8 25             	cmp    $0x25,%eax
  800395:	74 0c                	je     8003a3 <vprintfmt+0x36>
			if (ch == '\0')
  800397:	85 c0                	test   %eax,%eax
  800399:	75 e6                	jne    800381 <vprintfmt+0x14>
}
  80039b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80039e:	5b                   	pop    %ebx
  80039f:	5e                   	pop    %esi
  8003a0:	5f                   	pop    %edi
  8003a1:	5d                   	pop    %ebp
  8003a2:	c3                   	ret    
		padc = ' ';
  8003a3:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
		altflag = 0;
  8003a7:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8003ae:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8003b5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003bc:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003c1:	8d 47 01             	lea    0x1(%edi),%eax
  8003c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003c7:	0f b6 17             	movzbl (%edi),%edx
  8003ca:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003cd:	3c 55                	cmp    $0x55,%al
  8003cf:	0f 87 b7 02 00 00    	ja     80068c <vprintfmt+0x31f>
  8003d5:	0f b6 c0             	movzbl %al,%eax
  8003d8:	ff 24 85 e0 10 80 00 	jmp    *0x8010e0(,%eax,4)
  8003df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8003e2:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  8003e6:	eb d9                	jmp    8003c1 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8003e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003eb:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  8003ef:	eb d0                	jmp    8003c1 <vprintfmt+0x54>
  8003f1:	0f b6 d2             	movzbl %dl,%edx
  8003f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0;; ++fmt) {
  8003f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8003fc:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003ff:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800402:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800406:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800409:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80040c:	83 f9 09             	cmp    $0x9,%ecx
  80040f:	77 52                	ja     800463 <vprintfmt+0xf6>
			for (precision = 0;; ++fmt) {
  800411:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800414:	eb e9                	jmp    8003ff <vprintfmt+0x92>
			precision = va_arg(ap, int);
  800416:	8b 45 14             	mov    0x14(%ebp),%eax
  800419:	8d 50 04             	lea    0x4(%eax),%edx
  80041c:	89 55 14             	mov    %edx,0x14(%ebp)
  80041f:	8b 00                	mov    (%eax),%eax
  800421:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800424:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800427:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80042b:	79 94                	jns    8003c1 <vprintfmt+0x54>
				width = precision, precision = -1;
  80042d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800430:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800433:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80043a:	eb 85                	jmp    8003c1 <vprintfmt+0x54>
  80043c:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80043f:	85 d2                	test   %edx,%edx
  800441:	b8 00 00 00 00       	mov    $0x0,%eax
  800446:	0f 49 c2             	cmovns %edx,%eax
  800449:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80044c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80044f:	e9 6d ff ff ff       	jmp    8003c1 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800454:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800457:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80045e:	e9 5e ff ff ff       	jmp    8003c1 <vprintfmt+0x54>
  800463:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800466:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800469:	eb bc                	jmp    800427 <vprintfmt+0xba>
			lflag++;
  80046b:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80046e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800471:	e9 4b ff ff ff       	jmp    8003c1 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800476:	8b 45 14             	mov    0x14(%ebp),%eax
  800479:	8d 50 04             	lea    0x4(%eax),%edx
  80047c:	89 55 14             	mov    %edx,0x14(%ebp)
  80047f:	83 ec 08             	sub    $0x8,%esp
  800482:	56                   	push   %esi
  800483:	ff 30                	push   (%eax)
  800485:	ff d3                	call   *%ebx
			break;
  800487:	83 c4 10             	add    $0x10,%esp
  80048a:	e9 94 01 00 00       	jmp    800623 <vprintfmt+0x2b6>
			err = va_arg(ap, int);
  80048f:	8b 45 14             	mov    0x14(%ebp),%eax
  800492:	8d 50 04             	lea    0x4(%eax),%edx
  800495:	89 55 14             	mov    %edx,0x14(%ebp)
  800498:	8b 10                	mov    (%eax),%edx
  80049a:	89 d0                	mov    %edx,%eax
  80049c:	f7 d8                	neg    %eax
  80049e:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004a1:	83 f8 08             	cmp    $0x8,%eax
  8004a4:	7f 20                	jg     8004c6 <vprintfmt+0x159>
  8004a6:	8b 14 85 40 12 80 00 	mov    0x801240(,%eax,4),%edx
  8004ad:	85 d2                	test   %edx,%edx
  8004af:	74 15                	je     8004c6 <vprintfmt+0x159>
				printfmt(putch, putdat, "%s", p);
  8004b1:	52                   	push   %edx
  8004b2:	68 2c 10 80 00       	push   $0x80102c
  8004b7:	56                   	push   %esi
  8004b8:	53                   	push   %ebx
  8004b9:	e8 92 fe ff ff       	call   800350 <printfmt>
  8004be:	83 c4 10             	add    $0x10,%esp
  8004c1:	e9 5d 01 00 00       	jmp    800623 <vprintfmt+0x2b6>
				printfmt(putch, putdat, "error %d", err);
  8004c6:	50                   	push   %eax
  8004c7:	68 23 10 80 00       	push   $0x801023
  8004cc:	56                   	push   %esi
  8004cd:	53                   	push   %ebx
  8004ce:	e8 7d fe ff ff       	call   800350 <printfmt>
  8004d3:	83 c4 10             	add    $0x10,%esp
  8004d6:	e9 48 01 00 00       	jmp    800623 <vprintfmt+0x2b6>
			if ((p = va_arg(ap, char *)) == NULL)
  8004db:	8b 45 14             	mov    0x14(%ebp),%eax
  8004de:	8d 50 04             	lea    0x4(%eax),%edx
  8004e1:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e4:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004e6:	85 ff                	test   %edi,%edi
  8004e8:	b8 1c 10 80 00       	mov    $0x80101c,%eax
  8004ed:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004f0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004f4:	7e 06                	jle    8004fc <vprintfmt+0x18f>
  8004f6:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8004fa:	75 0a                	jne    800506 <vprintfmt+0x199>
  8004fc:	89 f8                	mov    %edi,%eax
  8004fe:	03 45 e0             	add    -0x20(%ebp),%eax
  800501:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800504:	eb 59                	jmp    80055f <vprintfmt+0x1f2>
				for (width -= strnlen(p, precision); width > 0;
  800506:	83 ec 08             	sub    $0x8,%esp
  800509:	ff 75 d8             	push   -0x28(%ebp)
  80050c:	57                   	push   %edi
  80050d:	e8 1a 02 00 00       	call   80072c <strnlen>
  800512:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800515:	29 c1                	sub    %eax,%ecx
  800517:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80051a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80051d:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  800521:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800524:	89 7d d0             	mov    %edi,-0x30(%ebp)
  800527:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0;
  800529:	eb 0f                	jmp    80053a <vprintfmt+0x1cd>
					putch(padc, putdat);
  80052b:	83 ec 08             	sub    $0x8,%esp
  80052e:	56                   	push   %esi
  80052f:	ff 75 e0             	push   -0x20(%ebp)
  800532:	ff d3                	call   *%ebx
				     width--)
  800534:	83 ef 01             	sub    $0x1,%edi
  800537:	83 c4 10             	add    $0x10,%esp
				for (width -= strnlen(p, precision); width > 0;
  80053a:	85 ff                	test   %edi,%edi
  80053c:	7f ed                	jg     80052b <vprintfmt+0x1be>
  80053e:	8b 7d d0             	mov    -0x30(%ebp),%edi
  800541:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800544:	85 c9                	test   %ecx,%ecx
  800546:	b8 00 00 00 00       	mov    $0x0,%eax
  80054b:	0f 49 c1             	cmovns %ecx,%eax
  80054e:	29 c1                	sub    %eax,%ecx
  800550:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800553:	eb a7                	jmp    8004fc <vprintfmt+0x18f>
					putch(ch, putdat);
  800555:	83 ec 08             	sub    $0x8,%esp
  800558:	56                   	push   %esi
  800559:	52                   	push   %edx
  80055a:	ff d3                	call   *%ebx
  80055c:	83 c4 10             	add    $0x10,%esp
  80055f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800562:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' &&
  800564:	83 c7 01             	add    $0x1,%edi
  800567:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80056b:	0f be d0             	movsbl %al,%edx
  80056e:	85 d2                	test   %edx,%edx
  800570:	74 42                	je     8005b4 <vprintfmt+0x247>
  800572:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800576:	78 06                	js     80057e <vprintfmt+0x211>
			       (precision < 0 || --precision >= 0);
  800578:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80057c:	78 1e                	js     80059c <vprintfmt+0x22f>
				if (altflag && (ch < ' ' || ch > '~'))
  80057e:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800582:	74 d1                	je     800555 <vprintfmt+0x1e8>
  800584:	0f be c0             	movsbl %al,%eax
  800587:	83 e8 20             	sub    $0x20,%eax
  80058a:	83 f8 5e             	cmp    $0x5e,%eax
  80058d:	76 c6                	jbe    800555 <vprintfmt+0x1e8>
					putch('?', putdat);
  80058f:	83 ec 08             	sub    $0x8,%esp
  800592:	56                   	push   %esi
  800593:	6a 3f                	push   $0x3f
  800595:	ff d3                	call   *%ebx
  800597:	83 c4 10             	add    $0x10,%esp
  80059a:	eb c3                	jmp    80055f <vprintfmt+0x1f2>
  80059c:	89 cf                	mov    %ecx,%edi
  80059e:	eb 0e                	jmp    8005ae <vprintfmt+0x241>
				putch(' ', putdat);
  8005a0:	83 ec 08             	sub    $0x8,%esp
  8005a3:	56                   	push   %esi
  8005a4:	6a 20                	push   $0x20
  8005a6:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  8005a8:	83 ef 01             	sub    $0x1,%edi
  8005ab:	83 c4 10             	add    $0x10,%esp
  8005ae:	85 ff                	test   %edi,%edi
  8005b0:	7f ee                	jg     8005a0 <vprintfmt+0x233>
  8005b2:	eb 6f                	jmp    800623 <vprintfmt+0x2b6>
  8005b4:	89 cf                	mov    %ecx,%edi
  8005b6:	eb f6                	jmp    8005ae <vprintfmt+0x241>
			num = getint(&ap, lflag);
  8005b8:	89 ca                	mov    %ecx,%edx
  8005ba:	8d 45 14             	lea    0x14(%ebp),%eax
  8005bd:	e8 45 fd ff ff       	call   800307 <getint>
  8005c2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c5:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  8005c8:	85 d2                	test   %edx,%edx
  8005ca:	78 0b                	js     8005d7 <vprintfmt+0x26a>
			num = getint(&ap, lflag);
  8005cc:	89 d1                	mov    %edx,%ecx
  8005ce:	89 c2                	mov    %eax,%edx
			base = 10;
  8005d0:	bf 0a 00 00 00       	mov    $0xa,%edi
  8005d5:	eb 32                	jmp    800609 <vprintfmt+0x29c>
				putch('-', putdat);
  8005d7:	83 ec 08             	sub    $0x8,%esp
  8005da:	56                   	push   %esi
  8005db:	6a 2d                	push   $0x2d
  8005dd:	ff d3                	call   *%ebx
				num = -(long long) num;
  8005df:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005e2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005e5:	f7 da                	neg    %edx
  8005e7:	83 d1 00             	adc    $0x0,%ecx
  8005ea:	f7 d9                	neg    %ecx
  8005ec:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005ef:	bf 0a 00 00 00       	mov    $0xa,%edi
  8005f4:	eb 13                	jmp    800609 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  8005f6:	89 ca                	mov    %ecx,%edx
  8005f8:	8d 45 14             	lea    0x14(%ebp),%eax
  8005fb:	e8 d3 fc ff ff       	call   8002d3 <getuint>
  800600:	89 d1                	mov    %edx,%ecx
  800602:	89 c2                	mov    %eax,%edx
			base = 10;
  800604:	bf 0a 00 00 00       	mov    $0xa,%edi
			printnum(putch, putdat, num, base, width, padc);
  800609:	83 ec 0c             	sub    $0xc,%esp
  80060c:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  800610:	50                   	push   %eax
  800611:	ff 75 e0             	push   -0x20(%ebp)
  800614:	57                   	push   %edi
  800615:	51                   	push   %ecx
  800616:	52                   	push   %edx
  800617:	89 f2                	mov    %esi,%edx
  800619:	89 d8                	mov    %ebx,%eax
  80061b:	e8 0a fc ff ff       	call   80022a <printnum>
			break;
  800620:	83 c4 20             	add    $0x20,%esp
{
  800623:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800626:	e9 60 fd ff ff       	jmp    80038b <vprintfmt+0x1e>
			num = getuint(&ap, lflag);
  80062b:	89 ca                	mov    %ecx,%edx
  80062d:	8d 45 14             	lea    0x14(%ebp),%eax
  800630:	e8 9e fc ff ff       	call   8002d3 <getuint>
  800635:	89 d1                	mov    %edx,%ecx
  800637:	89 c2                	mov    %eax,%edx
			base = 8;
  800639:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  80063e:	eb c9                	jmp    800609 <vprintfmt+0x29c>
			putch('0', putdat);
  800640:	83 ec 08             	sub    $0x8,%esp
  800643:	56                   	push   %esi
  800644:	6a 30                	push   $0x30
  800646:	ff d3                	call   *%ebx
			putch('x', putdat);
  800648:	83 c4 08             	add    $0x8,%esp
  80064b:	56                   	push   %esi
  80064c:	6a 78                	push   $0x78
  80064e:	ff d3                	call   *%ebx
			num = (unsigned long long) (uintptr_t) va_arg(ap, void *);
  800650:	8b 45 14             	mov    0x14(%ebp),%eax
  800653:	8d 50 04             	lea    0x4(%eax),%edx
  800656:	89 55 14             	mov    %edx,0x14(%ebp)
  800659:	8b 10                	mov    (%eax),%edx
  80065b:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800660:	83 c4 10             	add    $0x10,%esp
			base = 16;
  800663:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  800668:	eb 9f                	jmp    800609 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  80066a:	89 ca                	mov    %ecx,%edx
  80066c:	8d 45 14             	lea    0x14(%ebp),%eax
  80066f:	e8 5f fc ff ff       	call   8002d3 <getuint>
  800674:	89 d1                	mov    %edx,%ecx
  800676:	89 c2                	mov    %eax,%edx
			base = 16;
  800678:	bf 10 00 00 00       	mov    $0x10,%edi
  80067d:	eb 8a                	jmp    800609 <vprintfmt+0x29c>
			putch(ch, putdat);
  80067f:	83 ec 08             	sub    $0x8,%esp
  800682:	56                   	push   %esi
  800683:	6a 25                	push   $0x25
  800685:	ff d3                	call   *%ebx
			break;
  800687:	83 c4 10             	add    $0x10,%esp
  80068a:	eb 97                	jmp    800623 <vprintfmt+0x2b6>
			putch('%', putdat);
  80068c:	83 ec 08             	sub    $0x8,%esp
  80068f:	56                   	push   %esi
  800690:	6a 25                	push   $0x25
  800692:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  800694:	83 c4 10             	add    $0x10,%esp
  800697:	89 f8                	mov    %edi,%eax
  800699:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80069d:	74 05                	je     8006a4 <vprintfmt+0x337>
  80069f:	83 e8 01             	sub    $0x1,%eax
  8006a2:	eb f5                	jmp    800699 <vprintfmt+0x32c>
  8006a4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006a7:	e9 77 ff ff ff       	jmp    800623 <vprintfmt+0x2b6>

008006ac <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006ac:	55                   	push   %ebp
  8006ad:	89 e5                	mov    %esp,%ebp
  8006af:	83 ec 18             	sub    $0x18,%esp
  8006b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = { buf, buf + n - 1, 0 };
  8006b8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006bb:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006bf:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006c2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006c9:	85 c0                	test   %eax,%eax
  8006cb:	74 26                	je     8006f3 <vsnprintf+0x47>
  8006cd:	85 d2                	test   %edx,%edx
  8006cf:	7e 22                	jle    8006f3 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *) sprintputch, &b, fmt, ap);
  8006d1:	ff 75 14             	push   0x14(%ebp)
  8006d4:	ff 75 10             	push   0x10(%ebp)
  8006d7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006da:	50                   	push   %eax
  8006db:	68 33 03 80 00       	push   $0x800333
  8006e0:	e8 88 fc ff ff       	call   80036d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006e8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006ee:	83 c4 10             	add    $0x10,%esp
}
  8006f1:	c9                   	leave  
  8006f2:	c3                   	ret    
		return -E_INVAL;
  8006f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006f8:	eb f7                	jmp    8006f1 <vsnprintf+0x45>

008006fa <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006fa:	55                   	push   %ebp
  8006fb:	89 e5                	mov    %esp,%ebp
  8006fd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800700:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800703:	50                   	push   %eax
  800704:	ff 75 10             	push   0x10(%ebp)
  800707:	ff 75 0c             	push   0xc(%ebp)
  80070a:	ff 75 08             	push   0x8(%ebp)
  80070d:	e8 9a ff ff ff       	call   8006ac <vsnprintf>
	va_end(ap);

	return rc;
}
  800712:	c9                   	leave  
  800713:	c3                   	ret    

00800714 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800714:	55                   	push   %ebp
  800715:	89 e5                	mov    %esp,%ebp
  800717:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80071a:	b8 00 00 00 00       	mov    $0x0,%eax
  80071f:	eb 03                	jmp    800724 <strlen+0x10>
		n++;
  800721:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800724:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800728:	75 f7                	jne    800721 <strlen+0xd>
	return n;
}
  80072a:	5d                   	pop    %ebp
  80072b:	c3                   	ret    

0080072c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80072c:	55                   	push   %ebp
  80072d:	89 e5                	mov    %esp,%ebp
  80072f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800732:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800735:	b8 00 00 00 00       	mov    $0x0,%eax
  80073a:	eb 03                	jmp    80073f <strnlen+0x13>
		n++;
  80073c:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80073f:	39 d0                	cmp    %edx,%eax
  800741:	74 08                	je     80074b <strnlen+0x1f>
  800743:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800747:	75 f3                	jne    80073c <strnlen+0x10>
  800749:	89 c2                	mov    %eax,%edx
	return n;
}
  80074b:	89 d0                	mov    %edx,%eax
  80074d:	5d                   	pop    %ebp
  80074e:	c3                   	ret    

0080074f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80074f:	55                   	push   %ebp
  800750:	89 e5                	mov    %esp,%ebp
  800752:	53                   	push   %ebx
  800753:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800756:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800759:	b8 00 00 00 00       	mov    $0x0,%eax
  80075e:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800762:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800765:	83 c0 01             	add    $0x1,%eax
  800768:	84 d2                	test   %dl,%dl
  80076a:	75 f2                	jne    80075e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80076c:	89 c8                	mov    %ecx,%eax
  80076e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800771:	c9                   	leave  
  800772:	c3                   	ret    

00800773 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800773:	55                   	push   %ebp
  800774:	89 e5                	mov    %esp,%ebp
  800776:	53                   	push   %ebx
  800777:	83 ec 10             	sub    $0x10,%esp
  80077a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80077d:	53                   	push   %ebx
  80077e:	e8 91 ff ff ff       	call   800714 <strlen>
  800783:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800786:	ff 75 0c             	push   0xc(%ebp)
  800789:	01 d8                	add    %ebx,%eax
  80078b:	50                   	push   %eax
  80078c:	e8 be ff ff ff       	call   80074f <strcpy>
	return dst;
}
  800791:	89 d8                	mov    %ebx,%eax
  800793:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800796:	c9                   	leave  
  800797:	c3                   	ret    

00800798 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size)
{
  800798:	55                   	push   %ebp
  800799:	89 e5                	mov    %esp,%ebp
  80079b:	56                   	push   %esi
  80079c:	53                   	push   %ebx
  80079d:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a3:	89 f3                	mov    %esi,%ebx
  8007a5:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007a8:	89 f0                	mov    %esi,%eax
  8007aa:	eb 0f                	jmp    8007bb <strncpy+0x23>
		*dst++ = *src;
  8007ac:	83 c0 01             	add    $0x1,%eax
  8007af:	0f b6 0a             	movzbl (%edx),%ecx
  8007b2:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007b5:	80 f9 01             	cmp    $0x1,%cl
  8007b8:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  8007bb:	39 d8                	cmp    %ebx,%eax
  8007bd:	75 ed                	jne    8007ac <strncpy+0x14>
	}
	return ret;
}
  8007bf:	89 f0                	mov    %esi,%eax
  8007c1:	5b                   	pop    %ebx
  8007c2:	5e                   	pop    %esi
  8007c3:	5d                   	pop    %ebp
  8007c4:	c3                   	ret    

008007c5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007c5:	55                   	push   %ebp
  8007c6:	89 e5                	mov    %esp,%ebp
  8007c8:	56                   	push   %esi
  8007c9:	53                   	push   %ebx
  8007ca:	8b 75 08             	mov    0x8(%ebp),%esi
  8007cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007d0:	8b 55 10             	mov    0x10(%ebp),%edx
  8007d3:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007d5:	85 d2                	test   %edx,%edx
  8007d7:	74 21                	je     8007fa <strlcpy+0x35>
  8007d9:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007dd:	89 f2                	mov    %esi,%edx
  8007df:	eb 09                	jmp    8007ea <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007e1:	83 c1 01             	add    $0x1,%ecx
  8007e4:	83 c2 01             	add    $0x1,%edx
  8007e7:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  8007ea:	39 c2                	cmp    %eax,%edx
  8007ec:	74 09                	je     8007f7 <strlcpy+0x32>
  8007ee:	0f b6 19             	movzbl (%ecx),%ebx
  8007f1:	84 db                	test   %bl,%bl
  8007f3:	75 ec                	jne    8007e1 <strlcpy+0x1c>
  8007f5:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8007f7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007fa:	29 f0                	sub    %esi,%eax
}
  8007fc:	5b                   	pop    %ebx
  8007fd:	5e                   	pop    %esi
  8007fe:	5d                   	pop    %ebp
  8007ff:	c3                   	ret    

00800800 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800806:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800809:	eb 06                	jmp    800811 <strcmp+0x11>
		p++, q++;
  80080b:	83 c1 01             	add    $0x1,%ecx
  80080e:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800811:	0f b6 01             	movzbl (%ecx),%eax
  800814:	84 c0                	test   %al,%al
  800816:	74 04                	je     80081c <strcmp+0x1c>
  800818:	3a 02                	cmp    (%edx),%al
  80081a:	74 ef                	je     80080b <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80081c:	0f b6 c0             	movzbl %al,%eax
  80081f:	0f b6 12             	movzbl (%edx),%edx
  800822:	29 d0                	sub    %edx,%eax
}
  800824:	5d                   	pop    %ebp
  800825:	c3                   	ret    

00800826 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800826:	55                   	push   %ebp
  800827:	89 e5                	mov    %esp,%ebp
  800829:	53                   	push   %ebx
  80082a:	8b 45 08             	mov    0x8(%ebp),%eax
  80082d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800830:	89 c3                	mov    %eax,%ebx
  800832:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800835:	eb 06                	jmp    80083d <strncmp+0x17>
		n--, p++, q++;
  800837:	83 c0 01             	add    $0x1,%eax
  80083a:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80083d:	39 d8                	cmp    %ebx,%eax
  80083f:	74 18                	je     800859 <strncmp+0x33>
  800841:	0f b6 08             	movzbl (%eax),%ecx
  800844:	84 c9                	test   %cl,%cl
  800846:	74 04                	je     80084c <strncmp+0x26>
  800848:	3a 0a                	cmp    (%edx),%cl
  80084a:	74 eb                	je     800837 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80084c:	0f b6 00             	movzbl (%eax),%eax
  80084f:	0f b6 12             	movzbl (%edx),%edx
  800852:	29 d0                	sub    %edx,%eax
}
  800854:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800857:	c9                   	leave  
  800858:	c3                   	ret    
		return 0;
  800859:	b8 00 00 00 00       	mov    $0x0,%eax
  80085e:	eb f4                	jmp    800854 <strncmp+0x2e>

00800860 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	8b 45 08             	mov    0x8(%ebp),%eax
  800866:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80086a:	eb 03                	jmp    80086f <strchr+0xf>
  80086c:	83 c0 01             	add    $0x1,%eax
  80086f:	0f b6 10             	movzbl (%eax),%edx
  800872:	84 d2                	test   %dl,%dl
  800874:	74 06                	je     80087c <strchr+0x1c>
		if (*s == c)
  800876:	38 ca                	cmp    %cl,%dl
  800878:	75 f2                	jne    80086c <strchr+0xc>
  80087a:	eb 05                	jmp    800881 <strchr+0x21>
			return (char *) s;
	return 0;
  80087c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800881:	5d                   	pop    %ebp
  800882:	c3                   	ret    

00800883 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800883:	55                   	push   %ebp
  800884:	89 e5                	mov    %esp,%ebp
  800886:	8b 45 08             	mov    0x8(%ebp),%eax
  800889:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80088d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800890:	38 ca                	cmp    %cl,%dl
  800892:	74 09                	je     80089d <strfind+0x1a>
  800894:	84 d2                	test   %dl,%dl
  800896:	74 05                	je     80089d <strfind+0x1a>
	for (; *s; s++)
  800898:	83 c0 01             	add    $0x1,%eax
  80089b:	eb f0                	jmp    80088d <strfind+0xa>
			break;
	return (char *) s;
}
  80089d:	5d                   	pop    %ebp
  80089e:	c3                   	ret    

0080089f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80089f:	55                   	push   %ebp
  8008a0:	89 e5                	mov    %esp,%ebp
  8008a2:	57                   	push   %edi
  8008a3:	56                   	push   %esi
  8008a4:	53                   	push   %ebx
  8008a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8008a8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  8008ab:	85 c9                	test   %ecx,%ecx
  8008ad:	74 33                	je     8008e2 <memset+0x43>
		return v;
	if ((int) v % 4 == 0 && n % 4 == 0) {
  8008af:	89 d0                	mov    %edx,%eax
  8008b1:	09 c8                	or     %ecx,%eax
  8008b3:	a8 03                	test   $0x3,%al
  8008b5:	75 23                	jne    8008da <memset+0x3b>
		c &= 0xFF;
  8008b7:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  8008bb:	89 d8                	mov    %ebx,%eax
  8008bd:	c1 e0 08             	shl    $0x8,%eax
  8008c0:	89 df                	mov    %ebx,%edi
  8008c2:	c1 e7 18             	shl    $0x18,%edi
  8008c5:	89 de                	mov    %ebx,%esi
  8008c7:	c1 e6 10             	shl    $0x10,%esi
  8008ca:	09 f7                	or     %esi,%edi
  8008cc:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
		             : "=D"(p), "=c"(n)
		             : "D"(p), "a"(c), "c"(n / 4)
  8008ce:	c1 e9 02             	shr    $0x2,%ecx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  8008d1:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  8008d3:	89 d7                	mov    %edx,%edi
  8008d5:	fc                   	cld    
  8008d6:	f3 ab                	rep stos %eax,%es:(%edi)
  8008d8:	eb 08                	jmp    8008e2 <memset+0x43>
		             : "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008da:	89 d7                	mov    %edx,%edi
  8008dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008df:	fc                   	cld    
  8008e0:	f3 aa                	rep stos %al,%es:(%edi)
		             : "=D"(p), "=c"(n)
		             : "0"(p), "a"(c), "1"(n)
		             : "cc", "memory");
	return v;
}
  8008e2:	89 d0                	mov    %edx,%eax
  8008e4:	5b                   	pop    %ebx
  8008e5:	5e                   	pop    %esi
  8008e6:	5f                   	pop    %edi
  8008e7:	5d                   	pop    %ebp
  8008e8:	c3                   	ret    

008008e9 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008e9:	55                   	push   %ebp
  8008ea:	89 e5                	mov    %esp,%ebp
  8008ec:	57                   	push   %edi
  8008ed:	56                   	push   %esi
  8008ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008f4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008f7:	39 c6                	cmp    %eax,%esi
  8008f9:	73 32                	jae    80092d <memmove+0x44>
  8008fb:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008fe:	39 c2                	cmp    %eax,%edx
  800900:	76 2b                	jbe    80092d <memmove+0x44>
		s += n;
		d += n;
  800902:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  800905:	89 d6                	mov    %edx,%esi
  800907:	09 fe                	or     %edi,%esi
  800909:	09 ce                	or     %ecx,%esi
  80090b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800911:	75 0e                	jne    800921 <memmove+0x38>
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  800913:	83 ef 04             	sub    $0x4,%edi
			             "S"(s - 4),
  800916:	8d 72 fc             	lea    -0x4(%edx),%esi
			             "c"(n / 4)
  800919:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  80091c:	fd                   	std    
  80091d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80091f:	eb 09                	jmp    80092a <memmove+0x41>
			             : "cc", "memory");
		else
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  800921:	83 ef 01             	sub    $0x1,%edi
			             "S"(s - 1),
  800924:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  800927:	fd                   	std    
  800928:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             "c"(n)
			             : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80092a:	fc                   	cld    
  80092b:	eb 1a                	jmp    800947 <memmove+0x5e>
	} else {
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  80092d:	89 f2                	mov    %esi,%edx
  80092f:	09 c2                	or     %eax,%edx
  800931:	09 ca                	or     %ecx,%edx
  800933:	f6 c2 03             	test   $0x3,%dl
  800936:	75 0a                	jne    800942 <memmove+0x59>
			asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800938:	c1 e9 02             	shr    $0x2,%ecx
  80093b:	89 c7                	mov    %eax,%edi
  80093d:	fc                   	cld    
  80093e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800940:	eb 05                	jmp    800947 <memmove+0x5e>
			             : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800942:	89 c7                	mov    %eax,%edi
  800944:	fc                   	cld    
  800945:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             : "cc", "memory");
	}
	return dst;
}
  800947:	5e                   	pop    %esi
  800948:	5f                   	pop    %edi
  800949:	5d                   	pop    %ebp
  80094a:	c3                   	ret    

0080094b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80094b:	55                   	push   %ebp
  80094c:	89 e5                	mov    %esp,%ebp
  80094e:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800951:	ff 75 10             	push   0x10(%ebp)
  800954:	ff 75 0c             	push   0xc(%ebp)
  800957:	ff 75 08             	push   0x8(%ebp)
  80095a:	e8 8a ff ff ff       	call   8008e9 <memmove>
}
  80095f:	c9                   	leave  
  800960:	c3                   	ret    

00800961 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	56                   	push   %esi
  800965:	53                   	push   %ebx
  800966:	8b 45 08             	mov    0x8(%ebp),%eax
  800969:	8b 55 0c             	mov    0xc(%ebp),%edx
  80096c:	89 c6                	mov    %eax,%esi
  80096e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800971:	eb 06                	jmp    800979 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800973:	83 c0 01             	add    $0x1,%eax
  800976:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800979:	39 f0                	cmp    %esi,%eax
  80097b:	74 14                	je     800991 <memcmp+0x30>
		if (*s1 != *s2)
  80097d:	0f b6 08             	movzbl (%eax),%ecx
  800980:	0f b6 1a             	movzbl (%edx),%ebx
  800983:	38 d9                	cmp    %bl,%cl
  800985:	74 ec                	je     800973 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800987:	0f b6 c1             	movzbl %cl,%eax
  80098a:	0f b6 db             	movzbl %bl,%ebx
  80098d:	29 d8                	sub    %ebx,%eax
  80098f:	eb 05                	jmp    800996 <memcmp+0x35>
	}

	return 0;
  800991:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800996:	5b                   	pop    %ebx
  800997:	5e                   	pop    %esi
  800998:	5d                   	pop    %ebp
  800999:	c3                   	ret    

0080099a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80099a:	55                   	push   %ebp
  80099b:	89 e5                	mov    %esp,%ebp
  80099d:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009a3:	89 c2                	mov    %eax,%edx
  8009a5:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009a8:	eb 03                	jmp    8009ad <memfind+0x13>
  8009aa:	83 c0 01             	add    $0x1,%eax
  8009ad:	39 d0                	cmp    %edx,%eax
  8009af:	73 04                	jae    8009b5 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009b1:	38 08                	cmp    %cl,(%eax)
  8009b3:	75 f5                	jne    8009aa <memfind+0x10>
			break;
	return (void *) s;
}
  8009b5:	5d                   	pop    %ebp
  8009b6:	c3                   	ret    

008009b7 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009b7:	55                   	push   %ebp
  8009b8:	89 e5                	mov    %esp,%ebp
  8009ba:	57                   	push   %edi
  8009bb:	56                   	push   %esi
  8009bc:	53                   	push   %ebx
  8009bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8009c0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009c3:	eb 03                	jmp    8009c8 <strtol+0x11>
		s++;
  8009c5:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  8009c8:	0f b6 02             	movzbl (%edx),%eax
  8009cb:	3c 20                	cmp    $0x20,%al
  8009cd:	74 f6                	je     8009c5 <strtol+0xe>
  8009cf:	3c 09                	cmp    $0x9,%al
  8009d1:	74 f2                	je     8009c5 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8009d3:	3c 2b                	cmp    $0x2b,%al
  8009d5:	74 2a                	je     800a01 <strtol+0x4a>
	int neg = 0;
  8009d7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8009dc:	3c 2d                	cmp    $0x2d,%al
  8009de:	74 2b                	je     800a0b <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009e0:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009e6:	75 0f                	jne    8009f7 <strtol+0x40>
  8009e8:	80 3a 30             	cmpb   $0x30,(%edx)
  8009eb:	74 28                	je     800a15 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009ed:	85 db                	test   %ebx,%ebx
  8009ef:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009f4:	0f 44 d8             	cmove  %eax,%ebx
  8009f7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009fc:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8009ff:	eb 46                	jmp    800a47 <strtol+0x90>
		s++;
  800a01:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800a04:	bf 00 00 00 00       	mov    $0x0,%edi
  800a09:	eb d5                	jmp    8009e0 <strtol+0x29>
		s++, neg = 1;
  800a0b:	83 c2 01             	add    $0x1,%edx
  800a0e:	bf 01 00 00 00       	mov    $0x1,%edi
  800a13:	eb cb                	jmp    8009e0 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a15:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a19:	74 0e                	je     800a29 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800a1b:	85 db                	test   %ebx,%ebx
  800a1d:	75 d8                	jne    8009f7 <strtol+0x40>
		s++, base = 8;
  800a1f:	83 c2 01             	add    $0x1,%edx
  800a22:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a27:	eb ce                	jmp    8009f7 <strtol+0x40>
		s += 2, base = 16;
  800a29:	83 c2 02             	add    $0x2,%edx
  800a2c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a31:	eb c4                	jmp    8009f7 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a33:	0f be c0             	movsbl %al,%eax
  800a36:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a39:	3b 45 10             	cmp    0x10(%ebp),%eax
  800a3c:	7d 3a                	jge    800a78 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800a3e:	83 c2 01             	add    $0x1,%edx
  800a41:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800a45:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800a47:	0f b6 02             	movzbl (%edx),%eax
  800a4a:	8d 70 d0             	lea    -0x30(%eax),%esi
  800a4d:	89 f3                	mov    %esi,%ebx
  800a4f:	80 fb 09             	cmp    $0x9,%bl
  800a52:	76 df                	jbe    800a33 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800a54:	8d 70 9f             	lea    -0x61(%eax),%esi
  800a57:	89 f3                	mov    %esi,%ebx
  800a59:	80 fb 19             	cmp    $0x19,%bl
  800a5c:	77 08                	ja     800a66 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800a5e:	0f be c0             	movsbl %al,%eax
  800a61:	83 e8 57             	sub    $0x57,%eax
  800a64:	eb d3                	jmp    800a39 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800a66:	8d 70 bf             	lea    -0x41(%eax),%esi
  800a69:	89 f3                	mov    %esi,%ebx
  800a6b:	80 fb 19             	cmp    $0x19,%bl
  800a6e:	77 08                	ja     800a78 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800a70:	0f be c0             	movsbl %al,%eax
  800a73:	83 e8 37             	sub    $0x37,%eax
  800a76:	eb c1                	jmp    800a39 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a78:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a7c:	74 05                	je     800a83 <strtol+0xcc>
		*endptr = (char *) s;
  800a7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a81:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800a83:	89 c8                	mov    %ecx,%eax
  800a85:	f7 d8                	neg    %eax
  800a87:	85 ff                	test   %edi,%edi
  800a89:	0f 45 c8             	cmovne %eax,%ecx
}
  800a8c:	89 c8                	mov    %ecx,%eax
  800a8e:	5b                   	pop    %ebx
  800a8f:	5e                   	pop    %esi
  800a90:	5f                   	pop    %edi
  800a91:	5d                   	pop    %ebp
  800a92:	c3                   	ret    

00800a93 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a93:	55                   	push   %ebp
  800a94:	89 e5                	mov    %esp,%ebp
  800a96:	57                   	push   %edi
  800a97:	56                   	push   %esi
  800a98:	53                   	push   %ebx
  800a99:	83 ec 1c             	sub    $0x1c,%esp
  800a9c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a9f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800aa2:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile(
  800aa4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aa7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800aaa:	8b 7d 10             	mov    0x10(%ebp),%edi
  800aad:	8b 75 14             	mov    0x14(%ebp),%esi
  800ab0:	cd 30                	int    $0x30
	        "int %1\n"
	        : "=a"(ret)
	        : "i"(T_SYSCALL), "a"(num), "d"(a1), "c"(a2), "b"(a3), "D"(a4), "S"(a5)
	        : "cc", "memory");

	if (check && ret > 0)
  800ab2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ab6:	74 04                	je     800abc <syscall+0x29>
  800ab8:	85 c0                	test   %eax,%eax
  800aba:	7f 08                	jg     800ac4 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800abc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800abf:	5b                   	pop    %ebx
  800ac0:	5e                   	pop    %esi
  800ac1:	5f                   	pop    %edi
  800ac2:	5d                   	pop    %ebp
  800ac3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ac4:	83 ec 0c             	sub    $0xc,%esp
  800ac7:	50                   	push   %eax
  800ac8:	ff 75 e0             	push   -0x20(%ebp)
  800acb:	68 64 12 80 00       	push   $0x801264
  800ad0:	6a 1e                	push   $0x1e
  800ad2:	68 81 12 80 00       	push   $0x801281
  800ad7:	e8 5f f6 ff ff       	call   80013b <_panic>

00800adc <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800adc:	55                   	push   %ebp
  800add:	89 e5                	mov    %esp,%ebp
  800adf:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t) s, len, 0, 0, 0);
  800ae2:	6a 00                	push   $0x0
  800ae4:	6a 00                	push   $0x0
  800ae6:	6a 00                	push   $0x0
  800ae8:	ff 75 0c             	push   0xc(%ebp)
  800aeb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aee:	ba 00 00 00 00       	mov    $0x0,%edx
  800af3:	b8 00 00 00 00       	mov    $0x0,%eax
  800af8:	e8 96 ff ff ff       	call   800a93 <syscall>
}
  800afd:	83 c4 10             	add    $0x10,%esp
  800b00:	c9                   	leave  
  800b01:	c3                   	ret    

00800b02 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b02:	55                   	push   %ebp
  800b03:	89 e5                	mov    %esp,%ebp
  800b05:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800b08:	6a 00                	push   $0x0
  800b0a:	6a 00                	push   $0x0
  800b0c:	6a 00                	push   $0x0
  800b0e:	6a 00                	push   $0x0
  800b10:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b15:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1a:	b8 01 00 00 00       	mov    $0x1,%eax
  800b1f:	e8 6f ff ff ff       	call   800a93 <syscall>
}
  800b24:	c9                   	leave  
  800b25:	c3                   	ret    

00800b26 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b26:	55                   	push   %ebp
  800b27:	89 e5                	mov    %esp,%ebp
  800b29:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800b2c:	6a 00                	push   $0x0
  800b2e:	6a 00                	push   $0x0
  800b30:	6a 00                	push   $0x0
  800b32:	6a 00                	push   $0x0
  800b34:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b37:	ba 01 00 00 00       	mov    $0x1,%edx
  800b3c:	b8 03 00 00 00       	mov    $0x3,%eax
  800b41:	e8 4d ff ff ff       	call   800a93 <syscall>
}
  800b46:	c9                   	leave  
  800b47:	c3                   	ret    

00800b48 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b48:	55                   	push   %ebp
  800b49:	89 e5                	mov    %esp,%ebp
  800b4b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800b4e:	6a 00                	push   $0x0
  800b50:	6a 00                	push   $0x0
  800b52:	6a 00                	push   $0x0
  800b54:	6a 00                	push   $0x0
  800b56:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b5b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b60:	b8 02 00 00 00       	mov    $0x2,%eax
  800b65:	e8 29 ff ff ff       	call   800a93 <syscall>
}
  800b6a:	c9                   	leave  
  800b6b:	c3                   	ret    

00800b6c <sys_yield>:

void
sys_yield(void)
{
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800b72:	6a 00                	push   $0x0
  800b74:	6a 00                	push   $0x0
  800b76:	6a 00                	push   $0x0
  800b78:	6a 00                	push   $0x0
  800b7a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b7f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b84:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b89:	e8 05 ff ff ff       	call   800a93 <syscall>
}
  800b8e:	83 c4 10             	add    $0x10,%esp
  800b91:	c9                   	leave  
  800b92:	c3                   	ret    

00800b93 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b93:	55                   	push   %ebp
  800b94:	89 e5                	mov    %esp,%ebp
  800b96:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800b99:	6a 00                	push   $0x0
  800b9b:	6a 00                	push   $0x0
  800b9d:	ff 75 10             	push   0x10(%ebp)
  800ba0:	ff 75 0c             	push   0xc(%ebp)
  800ba3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ba6:	ba 01 00 00 00       	mov    $0x1,%edx
  800bab:	b8 04 00 00 00       	mov    $0x4,%eax
  800bb0:	e8 de fe ff ff       	call   800a93 <syscall>
}
  800bb5:	c9                   	leave  
  800bb6:	c3                   	ret    

00800bb7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bb7:	55                   	push   %ebp
  800bb8:	89 e5                	mov    %esp,%ebp
  800bba:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map,
  800bbd:	ff 75 18             	push   0x18(%ebp)
  800bc0:	ff 75 14             	push   0x14(%ebp)
  800bc3:	ff 75 10             	push   0x10(%ebp)
  800bc6:	ff 75 0c             	push   0xc(%ebp)
  800bc9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bcc:	ba 01 00 00 00       	mov    $0x1,%edx
  800bd1:	b8 05 00 00 00       	mov    $0x5,%eax
  800bd6:	e8 b8 fe ff ff       	call   800a93 <syscall>
	               srcenv,
	               (uint32_t) srcva,
	               dstenv,
	               (uint32_t) dstva,
	               perm);
}
  800bdb:	c9                   	leave  
  800bdc:	c3                   	ret    

00800bdd <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bdd:	55                   	push   %ebp
  800bde:	89 e5                	mov    %esp,%ebp
  800be0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800be3:	6a 00                	push   $0x0
  800be5:	6a 00                	push   $0x0
  800be7:	6a 00                	push   $0x0
  800be9:	ff 75 0c             	push   0xc(%ebp)
  800bec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bef:	ba 01 00 00 00       	mov    $0x1,%edx
  800bf4:	b8 06 00 00 00       	mov    $0x6,%eax
  800bf9:	e8 95 fe ff ff       	call   800a93 <syscall>
}
  800bfe:	c9                   	leave  
  800bff:	c3                   	ret    

00800c00 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c00:	55                   	push   %ebp
  800c01:	89 e5                	mov    %esp,%ebp
  800c03:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800c06:	6a 00                	push   $0x0
  800c08:	6a 00                	push   $0x0
  800c0a:	6a 00                	push   $0x0
  800c0c:	ff 75 0c             	push   0xc(%ebp)
  800c0f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c12:	ba 01 00 00 00       	mov    $0x1,%edx
  800c17:	b8 08 00 00 00       	mov    $0x8,%eax
  800c1c:	e8 72 fe ff ff       	call   800a93 <syscall>
}
  800c21:	c9                   	leave  
  800c22:	c3                   	ret    

00800c23 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c23:	55                   	push   %ebp
  800c24:	89 e5                	mov    %esp,%ebp
  800c26:	83 ec 08             	sub    $0x8,%esp
	return syscall(
  800c29:	6a 00                	push   $0x0
  800c2b:	6a 00                	push   $0x0
  800c2d:	6a 00                	push   $0x0
  800c2f:	ff 75 0c             	push   0xc(%ebp)
  800c32:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c35:	ba 01 00 00 00       	mov    $0x1,%edx
  800c3a:	b8 09 00 00 00       	mov    $0x9,%eax
  800c3f:	e8 4f fe ff ff       	call   800a93 <syscall>
	        SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c44:	c9                   	leave  
  800c45:	c3                   	ret    

00800c46 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c46:	55                   	push   %ebp
  800c47:	89 e5                	mov    %esp,%ebp
  800c49:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800c4c:	6a 00                	push   $0x0
  800c4e:	ff 75 14             	push   0x14(%ebp)
  800c51:	ff 75 10             	push   0x10(%ebp)
  800c54:	ff 75 0c             	push   0xc(%ebp)
  800c57:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c5a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c5f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c64:	e8 2a fe ff ff       	call   800a93 <syscall>
}
  800c69:	c9                   	leave  
  800c6a:	c3                   	ret    

00800c6b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t) dstva, 0, 0, 0, 0);
  800c71:	6a 00                	push   $0x0
  800c73:	6a 00                	push   $0x0
  800c75:	6a 00                	push   $0x0
  800c77:	6a 00                	push   $0x0
  800c79:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c7c:	ba 01 00 00 00       	mov    $0x1,%edx
  800c81:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c86:	e8 08 fe ff ff       	call   800a93 <syscall>
}
  800c8b:	c9                   	leave  
  800c8c:	c3                   	ret    

00800c8d <sys_get_priority>:

// Get priority of the current process
int
sys_get_priority(void)
{
  800c8d:	55                   	push   %ebp
  800c8e:	89 e5                	mov    %esp,%ebp
  800c90:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_get_priority, 0, 0, 0, 0, 0, 0);
  800c93:	6a 00                	push   $0x0
  800c95:	6a 00                	push   $0x0
  800c97:	6a 00                	push   $0x0
  800c99:	6a 00                	push   $0x0
  800c9b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ca0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca5:	b8 0d 00 00 00       	mov    $0xd,%eax
  800caa:	e8 e4 fd ff ff       	call   800a93 <syscall>
}
  800caf:	c9                   	leave  
  800cb0:	c3                   	ret    

00800cb1 <sys_set_priority>:

// Get priority of the current process
int
sys_set_priority(unsigned int priority)
{
  800cb1:	55                   	push   %ebp
  800cb2:	89 e5                	mov    %esp,%ebp
  800cb4:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, (uint32_t) priority, 0, 0, 0, 0);
  800cb7:	6a 00                	push   $0x0
  800cb9:	6a 00                	push   $0x0
  800cbb:	6a 00                	push   $0x0
  800cbd:	6a 00                	push   $0x0
  800cbf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cc2:	ba 00 00 00 00       	mov    $0x0,%edx
  800cc7:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ccc:	e8 c2 fd ff ff       	call   800a93 <syscall>
}
  800cd1:	c9                   	leave  
  800cd2:	c3                   	ret    
  800cd3:	66 90                	xchg   %ax,%ax
  800cd5:	66 90                	xchg   %ax,%ax
  800cd7:	66 90                	xchg   %ax,%ax
  800cd9:	66 90                	xchg   %ax,%ax
  800cdb:	66 90                	xchg   %ax,%ax
  800cdd:	66 90                	xchg   %ax,%ax
  800cdf:	90                   	nop

00800ce0 <__udivdi3>:
  800ce0:	f3 0f 1e fb          	endbr32 
  800ce4:	55                   	push   %ebp
  800ce5:	57                   	push   %edi
  800ce6:	56                   	push   %esi
  800ce7:	53                   	push   %ebx
  800ce8:	83 ec 1c             	sub    $0x1c,%esp
  800ceb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800cef:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800cf3:	8b 74 24 34          	mov    0x34(%esp),%esi
  800cf7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800cfb:	85 c0                	test   %eax,%eax
  800cfd:	75 19                	jne    800d18 <__udivdi3+0x38>
  800cff:	39 f3                	cmp    %esi,%ebx
  800d01:	76 4d                	jbe    800d50 <__udivdi3+0x70>
  800d03:	31 ff                	xor    %edi,%edi
  800d05:	89 e8                	mov    %ebp,%eax
  800d07:	89 f2                	mov    %esi,%edx
  800d09:	f7 f3                	div    %ebx
  800d0b:	89 fa                	mov    %edi,%edx
  800d0d:	83 c4 1c             	add    $0x1c,%esp
  800d10:	5b                   	pop    %ebx
  800d11:	5e                   	pop    %esi
  800d12:	5f                   	pop    %edi
  800d13:	5d                   	pop    %ebp
  800d14:	c3                   	ret    
  800d15:	8d 76 00             	lea    0x0(%esi),%esi
  800d18:	39 f0                	cmp    %esi,%eax
  800d1a:	76 14                	jbe    800d30 <__udivdi3+0x50>
  800d1c:	31 ff                	xor    %edi,%edi
  800d1e:	31 c0                	xor    %eax,%eax
  800d20:	89 fa                	mov    %edi,%edx
  800d22:	83 c4 1c             	add    $0x1c,%esp
  800d25:	5b                   	pop    %ebx
  800d26:	5e                   	pop    %esi
  800d27:	5f                   	pop    %edi
  800d28:	5d                   	pop    %ebp
  800d29:	c3                   	ret    
  800d2a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d30:	0f bd f8             	bsr    %eax,%edi
  800d33:	83 f7 1f             	xor    $0x1f,%edi
  800d36:	75 48                	jne    800d80 <__udivdi3+0xa0>
  800d38:	39 f0                	cmp    %esi,%eax
  800d3a:	72 06                	jb     800d42 <__udivdi3+0x62>
  800d3c:	31 c0                	xor    %eax,%eax
  800d3e:	39 eb                	cmp    %ebp,%ebx
  800d40:	77 de                	ja     800d20 <__udivdi3+0x40>
  800d42:	b8 01 00 00 00       	mov    $0x1,%eax
  800d47:	eb d7                	jmp    800d20 <__udivdi3+0x40>
  800d49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d50:	89 d9                	mov    %ebx,%ecx
  800d52:	85 db                	test   %ebx,%ebx
  800d54:	75 0b                	jne    800d61 <__udivdi3+0x81>
  800d56:	b8 01 00 00 00       	mov    $0x1,%eax
  800d5b:	31 d2                	xor    %edx,%edx
  800d5d:	f7 f3                	div    %ebx
  800d5f:	89 c1                	mov    %eax,%ecx
  800d61:	31 d2                	xor    %edx,%edx
  800d63:	89 f0                	mov    %esi,%eax
  800d65:	f7 f1                	div    %ecx
  800d67:	89 c6                	mov    %eax,%esi
  800d69:	89 e8                	mov    %ebp,%eax
  800d6b:	89 f7                	mov    %esi,%edi
  800d6d:	f7 f1                	div    %ecx
  800d6f:	89 fa                	mov    %edi,%edx
  800d71:	83 c4 1c             	add    $0x1c,%esp
  800d74:	5b                   	pop    %ebx
  800d75:	5e                   	pop    %esi
  800d76:	5f                   	pop    %edi
  800d77:	5d                   	pop    %ebp
  800d78:	c3                   	ret    
  800d79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d80:	89 f9                	mov    %edi,%ecx
  800d82:	ba 20 00 00 00       	mov    $0x20,%edx
  800d87:	29 fa                	sub    %edi,%edx
  800d89:	d3 e0                	shl    %cl,%eax
  800d8b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d8f:	89 d1                	mov    %edx,%ecx
  800d91:	89 d8                	mov    %ebx,%eax
  800d93:	d3 e8                	shr    %cl,%eax
  800d95:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800d99:	09 c1                	or     %eax,%ecx
  800d9b:	89 f0                	mov    %esi,%eax
  800d9d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800da1:	89 f9                	mov    %edi,%ecx
  800da3:	d3 e3                	shl    %cl,%ebx
  800da5:	89 d1                	mov    %edx,%ecx
  800da7:	d3 e8                	shr    %cl,%eax
  800da9:	89 f9                	mov    %edi,%ecx
  800dab:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800daf:	89 eb                	mov    %ebp,%ebx
  800db1:	d3 e6                	shl    %cl,%esi
  800db3:	89 d1                	mov    %edx,%ecx
  800db5:	d3 eb                	shr    %cl,%ebx
  800db7:	09 f3                	or     %esi,%ebx
  800db9:	89 c6                	mov    %eax,%esi
  800dbb:	89 f2                	mov    %esi,%edx
  800dbd:	89 d8                	mov    %ebx,%eax
  800dbf:	f7 74 24 08          	divl   0x8(%esp)
  800dc3:	89 d6                	mov    %edx,%esi
  800dc5:	89 c3                	mov    %eax,%ebx
  800dc7:	f7 64 24 0c          	mull   0xc(%esp)
  800dcb:	39 d6                	cmp    %edx,%esi
  800dcd:	72 19                	jb     800de8 <__udivdi3+0x108>
  800dcf:	89 f9                	mov    %edi,%ecx
  800dd1:	d3 e5                	shl    %cl,%ebp
  800dd3:	39 c5                	cmp    %eax,%ebp
  800dd5:	73 04                	jae    800ddb <__udivdi3+0xfb>
  800dd7:	39 d6                	cmp    %edx,%esi
  800dd9:	74 0d                	je     800de8 <__udivdi3+0x108>
  800ddb:	89 d8                	mov    %ebx,%eax
  800ddd:	31 ff                	xor    %edi,%edi
  800ddf:	e9 3c ff ff ff       	jmp    800d20 <__udivdi3+0x40>
  800de4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800de8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800deb:	31 ff                	xor    %edi,%edi
  800ded:	e9 2e ff ff ff       	jmp    800d20 <__udivdi3+0x40>
  800df2:	66 90                	xchg   %ax,%ax
  800df4:	66 90                	xchg   %ax,%ax
  800df6:	66 90                	xchg   %ax,%ax
  800df8:	66 90                	xchg   %ax,%ax
  800dfa:	66 90                	xchg   %ax,%ax
  800dfc:	66 90                	xchg   %ax,%ax
  800dfe:	66 90                	xchg   %ax,%ax

00800e00 <__umoddi3>:
  800e00:	f3 0f 1e fb          	endbr32 
  800e04:	55                   	push   %ebp
  800e05:	57                   	push   %edi
  800e06:	56                   	push   %esi
  800e07:	53                   	push   %ebx
  800e08:	83 ec 1c             	sub    $0x1c,%esp
  800e0b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800e0f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800e13:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  800e17:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  800e1b:	89 f0                	mov    %esi,%eax
  800e1d:	89 da                	mov    %ebx,%edx
  800e1f:	85 ff                	test   %edi,%edi
  800e21:	75 15                	jne    800e38 <__umoddi3+0x38>
  800e23:	39 dd                	cmp    %ebx,%ebp
  800e25:	76 39                	jbe    800e60 <__umoddi3+0x60>
  800e27:	f7 f5                	div    %ebp
  800e29:	89 d0                	mov    %edx,%eax
  800e2b:	31 d2                	xor    %edx,%edx
  800e2d:	83 c4 1c             	add    $0x1c,%esp
  800e30:	5b                   	pop    %ebx
  800e31:	5e                   	pop    %esi
  800e32:	5f                   	pop    %edi
  800e33:	5d                   	pop    %ebp
  800e34:	c3                   	ret    
  800e35:	8d 76 00             	lea    0x0(%esi),%esi
  800e38:	39 df                	cmp    %ebx,%edi
  800e3a:	77 f1                	ja     800e2d <__umoddi3+0x2d>
  800e3c:	0f bd cf             	bsr    %edi,%ecx
  800e3f:	83 f1 1f             	xor    $0x1f,%ecx
  800e42:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800e46:	75 40                	jne    800e88 <__umoddi3+0x88>
  800e48:	39 df                	cmp    %ebx,%edi
  800e4a:	72 04                	jb     800e50 <__umoddi3+0x50>
  800e4c:	39 f5                	cmp    %esi,%ebp
  800e4e:	77 dd                	ja     800e2d <__umoddi3+0x2d>
  800e50:	89 da                	mov    %ebx,%edx
  800e52:	89 f0                	mov    %esi,%eax
  800e54:	29 e8                	sub    %ebp,%eax
  800e56:	19 fa                	sbb    %edi,%edx
  800e58:	eb d3                	jmp    800e2d <__umoddi3+0x2d>
  800e5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e60:	89 e9                	mov    %ebp,%ecx
  800e62:	85 ed                	test   %ebp,%ebp
  800e64:	75 0b                	jne    800e71 <__umoddi3+0x71>
  800e66:	b8 01 00 00 00       	mov    $0x1,%eax
  800e6b:	31 d2                	xor    %edx,%edx
  800e6d:	f7 f5                	div    %ebp
  800e6f:	89 c1                	mov    %eax,%ecx
  800e71:	89 d8                	mov    %ebx,%eax
  800e73:	31 d2                	xor    %edx,%edx
  800e75:	f7 f1                	div    %ecx
  800e77:	89 f0                	mov    %esi,%eax
  800e79:	f7 f1                	div    %ecx
  800e7b:	89 d0                	mov    %edx,%eax
  800e7d:	31 d2                	xor    %edx,%edx
  800e7f:	eb ac                	jmp    800e2d <__umoddi3+0x2d>
  800e81:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e88:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e8c:	ba 20 00 00 00       	mov    $0x20,%edx
  800e91:	29 c2                	sub    %eax,%edx
  800e93:	89 c1                	mov    %eax,%ecx
  800e95:	89 e8                	mov    %ebp,%eax
  800e97:	d3 e7                	shl    %cl,%edi
  800e99:	89 d1                	mov    %edx,%ecx
  800e9b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e9f:	d3 e8                	shr    %cl,%eax
  800ea1:	89 c1                	mov    %eax,%ecx
  800ea3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800ea7:	09 f9                	or     %edi,%ecx
  800ea9:	89 df                	mov    %ebx,%edi
  800eab:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800eaf:	89 c1                	mov    %eax,%ecx
  800eb1:	d3 e5                	shl    %cl,%ebp
  800eb3:	89 d1                	mov    %edx,%ecx
  800eb5:	d3 ef                	shr    %cl,%edi
  800eb7:	89 c1                	mov    %eax,%ecx
  800eb9:	89 f0                	mov    %esi,%eax
  800ebb:	d3 e3                	shl    %cl,%ebx
  800ebd:	89 d1                	mov    %edx,%ecx
  800ebf:	89 fa                	mov    %edi,%edx
  800ec1:	d3 e8                	shr    %cl,%eax
  800ec3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800ec8:	09 d8                	or     %ebx,%eax
  800eca:	f7 74 24 08          	divl   0x8(%esp)
  800ece:	89 d3                	mov    %edx,%ebx
  800ed0:	d3 e6                	shl    %cl,%esi
  800ed2:	f7 e5                	mul    %ebp
  800ed4:	89 c7                	mov    %eax,%edi
  800ed6:	89 d1                	mov    %edx,%ecx
  800ed8:	39 d3                	cmp    %edx,%ebx
  800eda:	72 06                	jb     800ee2 <__umoddi3+0xe2>
  800edc:	75 0e                	jne    800eec <__umoddi3+0xec>
  800ede:	39 c6                	cmp    %eax,%esi
  800ee0:	73 0a                	jae    800eec <__umoddi3+0xec>
  800ee2:	29 e8                	sub    %ebp,%eax
  800ee4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800ee8:	89 d1                	mov    %edx,%ecx
  800eea:	89 c7                	mov    %eax,%edi
  800eec:	89 f5                	mov    %esi,%ebp
  800eee:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ef2:	29 fd                	sub    %edi,%ebp
  800ef4:	19 cb                	sbb    %ecx,%ebx
  800ef6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800efb:	89 d8                	mov    %ebx,%eax
  800efd:	d3 e0                	shl    %cl,%eax
  800eff:	89 f1                	mov    %esi,%ecx
  800f01:	d3 ed                	shr    %cl,%ebp
  800f03:	d3 eb                	shr    %cl,%ebx
  800f05:	09 e8                	or     %ebp,%eax
  800f07:	89 da                	mov    %ebx,%edx
  800f09:	83 c4 1c             	add    $0x1c,%esp
  800f0c:	5b                   	pop    %ebx
  800f0d:	5e                   	pop    %esi
  800f0e:	5f                   	pop    %edi
  800f0f:	5d                   	pop    %ebp
  800f10:	c3                   	ret    
