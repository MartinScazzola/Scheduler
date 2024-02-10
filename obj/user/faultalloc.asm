
obj/user/faultalloc:     formato del fichero elf32-i386


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
  80002c:	e8 99 00 00 00       	call   8000ca <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int r;
	void *addr = (void *) utf->utf_fault_va;
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
  80003d:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  80003f:	53                   	push   %ebx
  800040:	68 80 0f 80 00       	push   $0x800f80
  800045:	e8 ba 01 00 00       	call   800204 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE), PTE_P | PTE_U | PTE_W)) <
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 23 0b 00 00       	call   800b81 <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	78 16                	js     80007b <handler+0x48>
	    0)
		panic("allocating at %x in page fault handler: %e", addr, r);
	snprintf((char *) addr, 100, "this string was faulted in at %x", addr);
  800065:	53                   	push   %ebx
  800066:	68 cc 0f 80 00       	push   $0x800fcc
  80006b:	6a 64                	push   $0x64
  80006d:	53                   	push   %ebx
  80006e:	e8 75 06 00 00       	call   8006e8 <snprintf>
}
  800073:	83 c4 10             	add    $0x10,%esp
  800076:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800079:	c9                   	leave  
  80007a:	c3                   	ret    
		panic("allocating at %x in page fault handler: %e", addr, r);
  80007b:	83 ec 0c             	sub    $0xc,%esp
  80007e:	50                   	push   %eax
  80007f:	53                   	push   %ebx
  800080:	68 a0 0f 80 00       	push   $0x800fa0
  800085:	6a 0e                	push   $0xe
  800087:	68 8a 0f 80 00       	push   $0x800f8a
  80008c:	e8 98 00 00 00       	call   800129 <_panic>

00800091 <umain>:

void
umain(int argc, char **argv)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800097:	68 33 00 80 00       	push   $0x800033
  80009c:	e8 20 0c 00 00       	call   800cc1 <set_pgfault_handler>
	cprintf("%s\n", (char *) 0xDeadBeef);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	68 ef be ad de       	push   $0xdeadbeef
  8000a9:	68 9c 0f 80 00       	push   $0x800f9c
  8000ae:	e8 51 01 00 00       	call   800204 <cprintf>
	cprintf("%s\n", (char *) 0xCafeBffe);
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	68 fe bf fe ca       	push   $0xcafebffe
  8000bb:	68 9c 0f 80 00       	push   $0x800f9c
  8000c0:	e8 3f 01 00 00       	call   800204 <cprintf>
}
  8000c5:	83 c4 10             	add    $0x10,%esp
  8000c8:	c9                   	leave  
  8000c9:	c3                   	ret    

008000ca <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	56                   	push   %esi
  8000ce:	53                   	push   %ebx
  8000cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000d2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	envid_t id = sys_getenvid();
  8000d5:	e8 5c 0a 00 00       	call   800b36 <sys_getenvid>
	if (id >= 0)
  8000da:	85 c0                	test   %eax,%eax
  8000dc:	78 15                	js     8000f3 <libmain+0x29>
		thisenv = &envs[ENVX(id)];
  8000de:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000e3:	69 c0 88 00 00 00    	imul   $0x88,%eax,%eax
  8000e9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000ee:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000f3:	85 db                	test   %ebx,%ebx
  8000f5:	7e 07                	jle    8000fe <libmain+0x34>
		binaryname = argv[0];
  8000f7:	8b 06                	mov    (%esi),%eax
  8000f9:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000fe:	83 ec 08             	sub    $0x8,%esp
  800101:	56                   	push   %esi
  800102:	53                   	push   %ebx
  800103:	e8 89 ff ff ff       	call   800091 <umain>

	// exit gracefully
	exit();
  800108:	e8 0a 00 00 00       	call   800117 <exit>
}
  80010d:	83 c4 10             	add    $0x10,%esp
  800110:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800113:	5b                   	pop    %ebx
  800114:	5e                   	pop    %esi
  800115:	5d                   	pop    %ebp
  800116:	c3                   	ret    

00800117 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800117:	55                   	push   %ebp
  800118:	89 e5                	mov    %esp,%ebp
  80011a:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80011d:	6a 00                	push   $0x0
  80011f:	e8 f0 09 00 00       	call   800b14 <sys_env_destroy>
}
  800124:	83 c4 10             	add    $0x10,%esp
  800127:	c9                   	leave  
  800128:	c3                   	ret    

00800129 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800129:	55                   	push   %ebp
  80012a:	89 e5                	mov    %esp,%ebp
  80012c:	56                   	push   %esi
  80012d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80012e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800131:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800137:	e8 fa 09 00 00       	call   800b36 <sys_getenvid>
  80013c:	83 ec 0c             	sub    $0xc,%esp
  80013f:	ff 75 0c             	push   0xc(%ebp)
  800142:	ff 75 08             	push   0x8(%ebp)
  800145:	56                   	push   %esi
  800146:	50                   	push   %eax
  800147:	68 f8 0f 80 00       	push   $0x800ff8
  80014c:	e8 b3 00 00 00       	call   800204 <cprintf>
	        sys_getenvid(),
	        binaryname,
	        file,
	        line);
	vcprintf(fmt, ap);
  800151:	83 c4 18             	add    $0x18,%esp
  800154:	53                   	push   %ebx
  800155:	ff 75 10             	push   0x10(%ebp)
  800158:	e8 56 00 00 00       	call   8001b3 <vcprintf>
	cprintf("\n");
  80015d:	c7 04 24 9e 0f 80 00 	movl   $0x800f9e,(%esp)
  800164:	e8 9b 00 00 00       	call   800204 <cprintf>
  800169:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80016c:	cc                   	int3   
  80016d:	eb fd                	jmp    80016c <_panic+0x43>

0080016f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80016f:	55                   	push   %ebp
  800170:	89 e5                	mov    %esp,%ebp
  800172:	53                   	push   %ebx
  800173:	83 ec 04             	sub    $0x4,%esp
  800176:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800179:	8b 13                	mov    (%ebx),%edx
  80017b:	8d 42 01             	lea    0x1(%edx),%eax
  80017e:	89 03                	mov    %eax,(%ebx)
  800180:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800183:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256 - 1) {
  800187:	3d ff 00 00 00       	cmp    $0xff,%eax
  80018c:	74 09                	je     800197 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80018e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800192:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800195:	c9                   	leave  
  800196:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800197:	83 ec 08             	sub    $0x8,%esp
  80019a:	68 ff 00 00 00       	push   $0xff
  80019f:	8d 43 08             	lea    0x8(%ebx),%eax
  8001a2:	50                   	push   %eax
  8001a3:	e8 22 09 00 00       	call   800aca <sys_cputs>
		b->idx = 0;
  8001a8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001ae:	83 c4 10             	add    $0x10,%esp
  8001b1:	eb db                	jmp    80018e <putch+0x1f>

008001b3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001b3:	55                   	push   %ebp
  8001b4:	89 e5                	mov    %esp,%ebp
  8001b6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001bc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001c3:	00 00 00 
	b.cnt = 0;
  8001c6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001cd:	00 00 00 
	vprintfmt((void *) putch, &b, fmt, ap);
  8001d0:	ff 75 0c             	push   0xc(%ebp)
  8001d3:	ff 75 08             	push   0x8(%ebp)
  8001d6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001dc:	50                   	push   %eax
  8001dd:	68 6f 01 80 00       	push   $0x80016f
  8001e2:	e8 74 01 00 00       	call   80035b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e7:	83 c4 08             	add    $0x8,%esp
  8001ea:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8001f0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f6:	50                   	push   %eax
  8001f7:	e8 ce 08 00 00       	call   800aca <sys_cputs>

	return b.cnt;
}
  8001fc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800202:	c9                   	leave  
  800203:	c3                   	ret    

00800204 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800204:	55                   	push   %ebp
  800205:	89 e5                	mov    %esp,%ebp
  800207:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80020a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80020d:	50                   	push   %eax
  80020e:	ff 75 08             	push   0x8(%ebp)
  800211:	e8 9d ff ff ff       	call   8001b3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800216:	c9                   	leave  
  800217:	c3                   	ret    

00800218 <printnum>:
         void *putdat,
         unsigned long long num,
         unsigned base,
         int width,
         int padc)
{
  800218:	55                   	push   %ebp
  800219:	89 e5                	mov    %esp,%ebp
  80021b:	57                   	push   %edi
  80021c:	56                   	push   %esi
  80021d:	53                   	push   %ebx
  80021e:	83 ec 1c             	sub    $0x1c,%esp
  800221:	89 c7                	mov    %eax,%edi
  800223:	89 d6                	mov    %edx,%esi
  800225:	8b 45 08             	mov    0x8(%ebp),%eax
  800228:	8b 55 0c             	mov    0xc(%ebp),%edx
  80022b:	89 d1                	mov    %edx,%ecx
  80022d:	89 c2                	mov    %eax,%edx
  80022f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800232:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800235:	8b 45 10             	mov    0x10(%ebp),%eax
  800238:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80023b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80023e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800245:	39 c2                	cmp    %eax,%edx
  800247:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80024a:	72 3e                	jb     80028a <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80024c:	83 ec 0c             	sub    $0xc,%esp
  80024f:	ff 75 18             	push   0x18(%ebp)
  800252:	83 eb 01             	sub    $0x1,%ebx
  800255:	53                   	push   %ebx
  800256:	50                   	push   %eax
  800257:	83 ec 08             	sub    $0x8,%esp
  80025a:	ff 75 e4             	push   -0x1c(%ebp)
  80025d:	ff 75 e0             	push   -0x20(%ebp)
  800260:	ff 75 dc             	push   -0x24(%ebp)
  800263:	ff 75 d8             	push   -0x28(%ebp)
  800266:	e8 c5 0a 00 00       	call   800d30 <__udivdi3>
  80026b:	83 c4 18             	add    $0x18,%esp
  80026e:	52                   	push   %edx
  80026f:	50                   	push   %eax
  800270:	89 f2                	mov    %esi,%edx
  800272:	89 f8                	mov    %edi,%eax
  800274:	e8 9f ff ff ff       	call   800218 <printnum>
  800279:	83 c4 20             	add    $0x20,%esp
  80027c:	eb 13                	jmp    800291 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80027e:	83 ec 08             	sub    $0x8,%esp
  800281:	56                   	push   %esi
  800282:	ff 75 18             	push   0x18(%ebp)
  800285:	ff d7                	call   *%edi
  800287:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80028a:	83 eb 01             	sub    $0x1,%ebx
  80028d:	85 db                	test   %ebx,%ebx
  80028f:	7f ed                	jg     80027e <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800291:	83 ec 08             	sub    $0x8,%esp
  800294:	56                   	push   %esi
  800295:	83 ec 04             	sub    $0x4,%esp
  800298:	ff 75 e4             	push   -0x1c(%ebp)
  80029b:	ff 75 e0             	push   -0x20(%ebp)
  80029e:	ff 75 dc             	push   -0x24(%ebp)
  8002a1:	ff 75 d8             	push   -0x28(%ebp)
  8002a4:	e8 a7 0b 00 00       	call   800e50 <__umoddi3>
  8002a9:	83 c4 14             	add    $0x14,%esp
  8002ac:	0f be 80 1b 10 80 00 	movsbl 0x80101b(%eax),%eax
  8002b3:	50                   	push   %eax
  8002b4:	ff d7                	call   *%edi
}
  8002b6:	83 c4 10             	add    $0x10,%esp
  8002b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002bc:	5b                   	pop    %ebx
  8002bd:	5e                   	pop    %esi
  8002be:	5f                   	pop    %edi
  8002bf:	5d                   	pop    %ebp
  8002c0:	c3                   	ret    

008002c1 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8002c1:	83 fa 01             	cmp    $0x1,%edx
  8002c4:	7f 13                	jg     8002d9 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8002c6:	85 d2                	test   %edx,%edx
  8002c8:	74 1c                	je     8002e6 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  8002ca:	8b 10                	mov    (%eax),%edx
  8002cc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002cf:	89 08                	mov    %ecx,(%eax)
  8002d1:	8b 02                	mov    (%edx),%eax
  8002d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d8:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  8002d9:	8b 10                	mov    (%eax),%edx
  8002db:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002de:	89 08                	mov    %ecx,(%eax)
  8002e0:	8b 02                	mov    (%edx),%eax
  8002e2:	8b 52 04             	mov    0x4(%edx),%edx
  8002e5:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  8002e6:	8b 10                	mov    (%eax),%edx
  8002e8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002eb:	89 08                	mov    %ecx,(%eax)
  8002ed:	8b 02                	mov    (%edx),%eax
  8002ef:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002f4:	c3                   	ret    

008002f5 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8002f5:	83 fa 01             	cmp    $0x1,%edx
  8002f8:	7f 0f                	jg     800309 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  8002fa:	85 d2                	test   %edx,%edx
  8002fc:	74 18                	je     800316 <getint+0x21>
		return va_arg(*ap, long);
  8002fe:	8b 10                	mov    (%eax),%edx
  800300:	8d 4a 04             	lea    0x4(%edx),%ecx
  800303:	89 08                	mov    %ecx,(%eax)
  800305:	8b 02                	mov    (%edx),%eax
  800307:	99                   	cltd   
  800308:	c3                   	ret    
		return va_arg(*ap, long long);
  800309:	8b 10                	mov    (%eax),%edx
  80030b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80030e:	89 08                	mov    %ecx,(%eax)
  800310:	8b 02                	mov    (%edx),%eax
  800312:	8b 52 04             	mov    0x4(%edx),%edx
  800315:	c3                   	ret    
	else
		return va_arg(*ap, int);
  800316:	8b 10                	mov    (%eax),%edx
  800318:	8d 4a 04             	lea    0x4(%edx),%ecx
  80031b:	89 08                	mov    %ecx,(%eax)
  80031d:	8b 02                	mov    (%edx),%eax
  80031f:	99                   	cltd   
}
  800320:	c3                   	ret    

00800321 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800321:	55                   	push   %ebp
  800322:	89 e5                	mov    %esp,%ebp
  800324:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800327:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80032b:	8b 10                	mov    (%eax),%edx
  80032d:	3b 50 04             	cmp    0x4(%eax),%edx
  800330:	73 0a                	jae    80033c <sprintputch+0x1b>
		*b->buf++ = ch;
  800332:	8d 4a 01             	lea    0x1(%edx),%ecx
  800335:	89 08                	mov    %ecx,(%eax)
  800337:	8b 45 08             	mov    0x8(%ebp),%eax
  80033a:	88 02                	mov    %al,(%edx)
}
  80033c:	5d                   	pop    %ebp
  80033d:	c3                   	ret    

0080033e <printfmt>:
{
  80033e:	55                   	push   %ebp
  80033f:	89 e5                	mov    %esp,%ebp
  800341:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800344:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800347:	50                   	push   %eax
  800348:	ff 75 10             	push   0x10(%ebp)
  80034b:	ff 75 0c             	push   0xc(%ebp)
  80034e:	ff 75 08             	push   0x8(%ebp)
  800351:	e8 05 00 00 00       	call   80035b <vprintfmt>
}
  800356:	83 c4 10             	add    $0x10,%esp
  800359:	c9                   	leave  
  80035a:	c3                   	ret    

0080035b <vprintfmt>:
{
  80035b:	55                   	push   %ebp
  80035c:	89 e5                	mov    %esp,%ebp
  80035e:	57                   	push   %edi
  80035f:	56                   	push   %esi
  800360:	53                   	push   %ebx
  800361:	83 ec 2c             	sub    $0x2c,%esp
  800364:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800367:	8b 75 0c             	mov    0xc(%ebp),%esi
  80036a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80036d:	eb 0a                	jmp    800379 <vprintfmt+0x1e>
			putch(ch, putdat);
  80036f:	83 ec 08             	sub    $0x8,%esp
  800372:	56                   	push   %esi
  800373:	50                   	push   %eax
  800374:	ff d3                	call   *%ebx
  800376:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800379:	83 c7 01             	add    $0x1,%edi
  80037c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800380:	83 f8 25             	cmp    $0x25,%eax
  800383:	74 0c                	je     800391 <vprintfmt+0x36>
			if (ch == '\0')
  800385:	85 c0                	test   %eax,%eax
  800387:	75 e6                	jne    80036f <vprintfmt+0x14>
}
  800389:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80038c:	5b                   	pop    %ebx
  80038d:	5e                   	pop    %esi
  80038e:	5f                   	pop    %edi
  80038f:	5d                   	pop    %ebp
  800390:	c3                   	ret    
		padc = ' ';
  800391:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
		altflag = 0;
  800395:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80039c:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8003a3:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003aa:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003af:	8d 47 01             	lea    0x1(%edi),%eax
  8003b2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003b5:	0f b6 17             	movzbl (%edi),%edx
  8003b8:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003bb:	3c 55                	cmp    $0x55,%al
  8003bd:	0f 87 b7 02 00 00    	ja     80067a <vprintfmt+0x31f>
  8003c3:	0f b6 c0             	movzbl %al,%eax
  8003c6:	ff 24 85 e0 10 80 00 	jmp    *0x8010e0(,%eax,4)
  8003cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8003d0:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  8003d4:	eb d9                	jmp    8003af <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8003d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003d9:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  8003dd:	eb d0                	jmp    8003af <vprintfmt+0x54>
  8003df:	0f b6 d2             	movzbl %dl,%edx
  8003e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0;; ++fmt) {
  8003e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ea:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003ed:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003f0:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003f4:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003f7:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003fa:	83 f9 09             	cmp    $0x9,%ecx
  8003fd:	77 52                	ja     800451 <vprintfmt+0xf6>
			for (precision = 0;; ++fmt) {
  8003ff:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800402:	eb e9                	jmp    8003ed <vprintfmt+0x92>
			precision = va_arg(ap, int);
  800404:	8b 45 14             	mov    0x14(%ebp),%eax
  800407:	8d 50 04             	lea    0x4(%eax),%edx
  80040a:	89 55 14             	mov    %edx,0x14(%ebp)
  80040d:	8b 00                	mov    (%eax),%eax
  80040f:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800412:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800415:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800419:	79 94                	jns    8003af <vprintfmt+0x54>
				width = precision, precision = -1;
  80041b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80041e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800421:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800428:	eb 85                	jmp    8003af <vprintfmt+0x54>
  80042a:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80042d:	85 d2                	test   %edx,%edx
  80042f:	b8 00 00 00 00       	mov    $0x0,%eax
  800434:	0f 49 c2             	cmovns %edx,%eax
  800437:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80043a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80043d:	e9 6d ff ff ff       	jmp    8003af <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800442:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800445:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80044c:	e9 5e ff ff ff       	jmp    8003af <vprintfmt+0x54>
  800451:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800454:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800457:	eb bc                	jmp    800415 <vprintfmt+0xba>
			lflag++;
  800459:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80045c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80045f:	e9 4b ff ff ff       	jmp    8003af <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800464:	8b 45 14             	mov    0x14(%ebp),%eax
  800467:	8d 50 04             	lea    0x4(%eax),%edx
  80046a:	89 55 14             	mov    %edx,0x14(%ebp)
  80046d:	83 ec 08             	sub    $0x8,%esp
  800470:	56                   	push   %esi
  800471:	ff 30                	push   (%eax)
  800473:	ff d3                	call   *%ebx
			break;
  800475:	83 c4 10             	add    $0x10,%esp
  800478:	e9 94 01 00 00       	jmp    800611 <vprintfmt+0x2b6>
			err = va_arg(ap, int);
  80047d:	8b 45 14             	mov    0x14(%ebp),%eax
  800480:	8d 50 04             	lea    0x4(%eax),%edx
  800483:	89 55 14             	mov    %edx,0x14(%ebp)
  800486:	8b 10                	mov    (%eax),%edx
  800488:	89 d0                	mov    %edx,%eax
  80048a:	f7 d8                	neg    %eax
  80048c:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80048f:	83 f8 08             	cmp    $0x8,%eax
  800492:	7f 20                	jg     8004b4 <vprintfmt+0x159>
  800494:	8b 14 85 40 12 80 00 	mov    0x801240(,%eax,4),%edx
  80049b:	85 d2                	test   %edx,%edx
  80049d:	74 15                	je     8004b4 <vprintfmt+0x159>
				printfmt(putch, putdat, "%s", p);
  80049f:	52                   	push   %edx
  8004a0:	68 3c 10 80 00       	push   $0x80103c
  8004a5:	56                   	push   %esi
  8004a6:	53                   	push   %ebx
  8004a7:	e8 92 fe ff ff       	call   80033e <printfmt>
  8004ac:	83 c4 10             	add    $0x10,%esp
  8004af:	e9 5d 01 00 00       	jmp    800611 <vprintfmt+0x2b6>
				printfmt(putch, putdat, "error %d", err);
  8004b4:	50                   	push   %eax
  8004b5:	68 33 10 80 00       	push   $0x801033
  8004ba:	56                   	push   %esi
  8004bb:	53                   	push   %ebx
  8004bc:	e8 7d fe ff ff       	call   80033e <printfmt>
  8004c1:	83 c4 10             	add    $0x10,%esp
  8004c4:	e9 48 01 00 00       	jmp    800611 <vprintfmt+0x2b6>
			if ((p = va_arg(ap, char *)) == NULL)
  8004c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cc:	8d 50 04             	lea    0x4(%eax),%edx
  8004cf:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d2:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004d4:	85 ff                	test   %edi,%edi
  8004d6:	b8 2c 10 80 00       	mov    $0x80102c,%eax
  8004db:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004de:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004e2:	7e 06                	jle    8004ea <vprintfmt+0x18f>
  8004e4:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8004e8:	75 0a                	jne    8004f4 <vprintfmt+0x199>
  8004ea:	89 f8                	mov    %edi,%eax
  8004ec:	03 45 e0             	add    -0x20(%ebp),%eax
  8004ef:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004f2:	eb 59                	jmp    80054d <vprintfmt+0x1f2>
				for (width -= strnlen(p, precision); width > 0;
  8004f4:	83 ec 08             	sub    $0x8,%esp
  8004f7:	ff 75 d8             	push   -0x28(%ebp)
  8004fa:	57                   	push   %edi
  8004fb:	e8 1a 02 00 00       	call   80071a <strnlen>
  800500:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800503:	29 c1                	sub    %eax,%ecx
  800505:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800508:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80050b:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  80050f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800512:	89 7d d0             	mov    %edi,-0x30(%ebp)
  800515:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0;
  800517:	eb 0f                	jmp    800528 <vprintfmt+0x1cd>
					putch(padc, putdat);
  800519:	83 ec 08             	sub    $0x8,%esp
  80051c:	56                   	push   %esi
  80051d:	ff 75 e0             	push   -0x20(%ebp)
  800520:	ff d3                	call   *%ebx
				     width--)
  800522:	83 ef 01             	sub    $0x1,%edi
  800525:	83 c4 10             	add    $0x10,%esp
				for (width -= strnlen(p, precision); width > 0;
  800528:	85 ff                	test   %edi,%edi
  80052a:	7f ed                	jg     800519 <vprintfmt+0x1be>
  80052c:	8b 7d d0             	mov    -0x30(%ebp),%edi
  80052f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800532:	85 c9                	test   %ecx,%ecx
  800534:	b8 00 00 00 00       	mov    $0x0,%eax
  800539:	0f 49 c1             	cmovns %ecx,%eax
  80053c:	29 c1                	sub    %eax,%ecx
  80053e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800541:	eb a7                	jmp    8004ea <vprintfmt+0x18f>
					putch(ch, putdat);
  800543:	83 ec 08             	sub    $0x8,%esp
  800546:	56                   	push   %esi
  800547:	52                   	push   %edx
  800548:	ff d3                	call   *%ebx
  80054a:	83 c4 10             	add    $0x10,%esp
  80054d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800550:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' &&
  800552:	83 c7 01             	add    $0x1,%edi
  800555:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800559:	0f be d0             	movsbl %al,%edx
  80055c:	85 d2                	test   %edx,%edx
  80055e:	74 42                	je     8005a2 <vprintfmt+0x247>
  800560:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800564:	78 06                	js     80056c <vprintfmt+0x211>
			       (precision < 0 || --precision >= 0);
  800566:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80056a:	78 1e                	js     80058a <vprintfmt+0x22f>
				if (altflag && (ch < ' ' || ch > '~'))
  80056c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800570:	74 d1                	je     800543 <vprintfmt+0x1e8>
  800572:	0f be c0             	movsbl %al,%eax
  800575:	83 e8 20             	sub    $0x20,%eax
  800578:	83 f8 5e             	cmp    $0x5e,%eax
  80057b:	76 c6                	jbe    800543 <vprintfmt+0x1e8>
					putch('?', putdat);
  80057d:	83 ec 08             	sub    $0x8,%esp
  800580:	56                   	push   %esi
  800581:	6a 3f                	push   $0x3f
  800583:	ff d3                	call   *%ebx
  800585:	83 c4 10             	add    $0x10,%esp
  800588:	eb c3                	jmp    80054d <vprintfmt+0x1f2>
  80058a:	89 cf                	mov    %ecx,%edi
  80058c:	eb 0e                	jmp    80059c <vprintfmt+0x241>
				putch(' ', putdat);
  80058e:	83 ec 08             	sub    $0x8,%esp
  800591:	56                   	push   %esi
  800592:	6a 20                	push   $0x20
  800594:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  800596:	83 ef 01             	sub    $0x1,%edi
  800599:	83 c4 10             	add    $0x10,%esp
  80059c:	85 ff                	test   %edi,%edi
  80059e:	7f ee                	jg     80058e <vprintfmt+0x233>
  8005a0:	eb 6f                	jmp    800611 <vprintfmt+0x2b6>
  8005a2:	89 cf                	mov    %ecx,%edi
  8005a4:	eb f6                	jmp    80059c <vprintfmt+0x241>
			num = getint(&ap, lflag);
  8005a6:	89 ca                	mov    %ecx,%edx
  8005a8:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ab:	e8 45 fd ff ff       	call   8002f5 <getint>
  8005b0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b3:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  8005b6:	85 d2                	test   %edx,%edx
  8005b8:	78 0b                	js     8005c5 <vprintfmt+0x26a>
			num = getint(&ap, lflag);
  8005ba:	89 d1                	mov    %edx,%ecx
  8005bc:	89 c2                	mov    %eax,%edx
			base = 10;
  8005be:	bf 0a 00 00 00       	mov    $0xa,%edi
  8005c3:	eb 32                	jmp    8005f7 <vprintfmt+0x29c>
				putch('-', putdat);
  8005c5:	83 ec 08             	sub    $0x8,%esp
  8005c8:	56                   	push   %esi
  8005c9:	6a 2d                	push   $0x2d
  8005cb:	ff d3                	call   *%ebx
				num = -(long long) num;
  8005cd:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005d0:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005d3:	f7 da                	neg    %edx
  8005d5:	83 d1 00             	adc    $0x0,%ecx
  8005d8:	f7 d9                	neg    %ecx
  8005da:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005dd:	bf 0a 00 00 00       	mov    $0xa,%edi
  8005e2:	eb 13                	jmp    8005f7 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  8005e4:	89 ca                	mov    %ecx,%edx
  8005e6:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e9:	e8 d3 fc ff ff       	call   8002c1 <getuint>
  8005ee:	89 d1                	mov    %edx,%ecx
  8005f0:	89 c2                	mov    %eax,%edx
			base = 10;
  8005f2:	bf 0a 00 00 00       	mov    $0xa,%edi
			printnum(putch, putdat, num, base, width, padc);
  8005f7:	83 ec 0c             	sub    $0xc,%esp
  8005fa:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  8005fe:	50                   	push   %eax
  8005ff:	ff 75 e0             	push   -0x20(%ebp)
  800602:	57                   	push   %edi
  800603:	51                   	push   %ecx
  800604:	52                   	push   %edx
  800605:	89 f2                	mov    %esi,%edx
  800607:	89 d8                	mov    %ebx,%eax
  800609:	e8 0a fc ff ff       	call   800218 <printnum>
			break;
  80060e:	83 c4 20             	add    $0x20,%esp
{
  800611:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800614:	e9 60 fd ff ff       	jmp    800379 <vprintfmt+0x1e>
			num = getuint(&ap, lflag);
  800619:	89 ca                	mov    %ecx,%edx
  80061b:	8d 45 14             	lea    0x14(%ebp),%eax
  80061e:	e8 9e fc ff ff       	call   8002c1 <getuint>
  800623:	89 d1                	mov    %edx,%ecx
  800625:	89 c2                	mov    %eax,%edx
			base = 8;
  800627:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  80062c:	eb c9                	jmp    8005f7 <vprintfmt+0x29c>
			putch('0', putdat);
  80062e:	83 ec 08             	sub    $0x8,%esp
  800631:	56                   	push   %esi
  800632:	6a 30                	push   $0x30
  800634:	ff d3                	call   *%ebx
			putch('x', putdat);
  800636:	83 c4 08             	add    $0x8,%esp
  800639:	56                   	push   %esi
  80063a:	6a 78                	push   $0x78
  80063c:	ff d3                	call   *%ebx
			num = (unsigned long long) (uintptr_t) va_arg(ap, void *);
  80063e:	8b 45 14             	mov    0x14(%ebp),%eax
  800641:	8d 50 04             	lea    0x4(%eax),%edx
  800644:	89 55 14             	mov    %edx,0x14(%ebp)
  800647:	8b 10                	mov    (%eax),%edx
  800649:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80064e:	83 c4 10             	add    $0x10,%esp
			base = 16;
  800651:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  800656:	eb 9f                	jmp    8005f7 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  800658:	89 ca                	mov    %ecx,%edx
  80065a:	8d 45 14             	lea    0x14(%ebp),%eax
  80065d:	e8 5f fc ff ff       	call   8002c1 <getuint>
  800662:	89 d1                	mov    %edx,%ecx
  800664:	89 c2                	mov    %eax,%edx
			base = 16;
  800666:	bf 10 00 00 00       	mov    $0x10,%edi
  80066b:	eb 8a                	jmp    8005f7 <vprintfmt+0x29c>
			putch(ch, putdat);
  80066d:	83 ec 08             	sub    $0x8,%esp
  800670:	56                   	push   %esi
  800671:	6a 25                	push   $0x25
  800673:	ff d3                	call   *%ebx
			break;
  800675:	83 c4 10             	add    $0x10,%esp
  800678:	eb 97                	jmp    800611 <vprintfmt+0x2b6>
			putch('%', putdat);
  80067a:	83 ec 08             	sub    $0x8,%esp
  80067d:	56                   	push   %esi
  80067e:	6a 25                	push   $0x25
  800680:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  800682:	83 c4 10             	add    $0x10,%esp
  800685:	89 f8                	mov    %edi,%eax
  800687:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80068b:	74 05                	je     800692 <vprintfmt+0x337>
  80068d:	83 e8 01             	sub    $0x1,%eax
  800690:	eb f5                	jmp    800687 <vprintfmt+0x32c>
  800692:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800695:	e9 77 ff ff ff       	jmp    800611 <vprintfmt+0x2b6>

0080069a <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80069a:	55                   	push   %ebp
  80069b:	89 e5                	mov    %esp,%ebp
  80069d:	83 ec 18             	sub    $0x18,%esp
  8006a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = { buf, buf + n - 1, 0 };
  8006a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006a9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006ad:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006b0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006b7:	85 c0                	test   %eax,%eax
  8006b9:	74 26                	je     8006e1 <vsnprintf+0x47>
  8006bb:	85 d2                	test   %edx,%edx
  8006bd:	7e 22                	jle    8006e1 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *) sprintputch, &b, fmt, ap);
  8006bf:	ff 75 14             	push   0x14(%ebp)
  8006c2:	ff 75 10             	push   0x10(%ebp)
  8006c5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006c8:	50                   	push   %eax
  8006c9:	68 21 03 80 00       	push   $0x800321
  8006ce:	e8 88 fc ff ff       	call   80035b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006d6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006dc:	83 c4 10             	add    $0x10,%esp
}
  8006df:	c9                   	leave  
  8006e0:	c3                   	ret    
		return -E_INVAL;
  8006e1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006e6:	eb f7                	jmp    8006df <vsnprintf+0x45>

008006e8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006e8:	55                   	push   %ebp
  8006e9:	89 e5                	mov    %esp,%ebp
  8006eb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006ee:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006f1:	50                   	push   %eax
  8006f2:	ff 75 10             	push   0x10(%ebp)
  8006f5:	ff 75 0c             	push   0xc(%ebp)
  8006f8:	ff 75 08             	push   0x8(%ebp)
  8006fb:	e8 9a ff ff ff       	call   80069a <vsnprintf>
	va_end(ap);

	return rc;
}
  800700:	c9                   	leave  
  800701:	c3                   	ret    

00800702 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800702:	55                   	push   %ebp
  800703:	89 e5                	mov    %esp,%ebp
  800705:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800708:	b8 00 00 00 00       	mov    $0x0,%eax
  80070d:	eb 03                	jmp    800712 <strlen+0x10>
		n++;
  80070f:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800712:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800716:	75 f7                	jne    80070f <strlen+0xd>
	return n;
}
  800718:	5d                   	pop    %ebp
  800719:	c3                   	ret    

0080071a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80071a:	55                   	push   %ebp
  80071b:	89 e5                	mov    %esp,%ebp
  80071d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800720:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800723:	b8 00 00 00 00       	mov    $0x0,%eax
  800728:	eb 03                	jmp    80072d <strnlen+0x13>
		n++;
  80072a:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80072d:	39 d0                	cmp    %edx,%eax
  80072f:	74 08                	je     800739 <strnlen+0x1f>
  800731:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800735:	75 f3                	jne    80072a <strnlen+0x10>
  800737:	89 c2                	mov    %eax,%edx
	return n;
}
  800739:	89 d0                	mov    %edx,%eax
  80073b:	5d                   	pop    %ebp
  80073c:	c3                   	ret    

0080073d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80073d:	55                   	push   %ebp
  80073e:	89 e5                	mov    %esp,%ebp
  800740:	53                   	push   %ebx
  800741:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800744:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800747:	b8 00 00 00 00       	mov    $0x0,%eax
  80074c:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800750:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800753:	83 c0 01             	add    $0x1,%eax
  800756:	84 d2                	test   %dl,%dl
  800758:	75 f2                	jne    80074c <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80075a:	89 c8                	mov    %ecx,%eax
  80075c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80075f:	c9                   	leave  
  800760:	c3                   	ret    

00800761 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800761:	55                   	push   %ebp
  800762:	89 e5                	mov    %esp,%ebp
  800764:	53                   	push   %ebx
  800765:	83 ec 10             	sub    $0x10,%esp
  800768:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80076b:	53                   	push   %ebx
  80076c:	e8 91 ff ff ff       	call   800702 <strlen>
  800771:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800774:	ff 75 0c             	push   0xc(%ebp)
  800777:	01 d8                	add    %ebx,%eax
  800779:	50                   	push   %eax
  80077a:	e8 be ff ff ff       	call   80073d <strcpy>
	return dst;
}
  80077f:	89 d8                	mov    %ebx,%eax
  800781:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800784:	c9                   	leave  
  800785:	c3                   	ret    

00800786 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size)
{
  800786:	55                   	push   %ebp
  800787:	89 e5                	mov    %esp,%ebp
  800789:	56                   	push   %esi
  80078a:	53                   	push   %ebx
  80078b:	8b 75 08             	mov    0x8(%ebp),%esi
  80078e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800791:	89 f3                	mov    %esi,%ebx
  800793:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800796:	89 f0                	mov    %esi,%eax
  800798:	eb 0f                	jmp    8007a9 <strncpy+0x23>
		*dst++ = *src;
  80079a:	83 c0 01             	add    $0x1,%eax
  80079d:	0f b6 0a             	movzbl (%edx),%ecx
  8007a0:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007a3:	80 f9 01             	cmp    $0x1,%cl
  8007a6:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  8007a9:	39 d8                	cmp    %ebx,%eax
  8007ab:	75 ed                	jne    80079a <strncpy+0x14>
	}
	return ret;
}
  8007ad:	89 f0                	mov    %esi,%eax
  8007af:	5b                   	pop    %ebx
  8007b0:	5e                   	pop    %esi
  8007b1:	5d                   	pop    %ebp
  8007b2:	c3                   	ret    

008007b3 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007b3:	55                   	push   %ebp
  8007b4:	89 e5                	mov    %esp,%ebp
  8007b6:	56                   	push   %esi
  8007b7:	53                   	push   %ebx
  8007b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8007bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007be:	8b 55 10             	mov    0x10(%ebp),%edx
  8007c1:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007c3:	85 d2                	test   %edx,%edx
  8007c5:	74 21                	je     8007e8 <strlcpy+0x35>
  8007c7:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007cb:	89 f2                	mov    %esi,%edx
  8007cd:	eb 09                	jmp    8007d8 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007cf:	83 c1 01             	add    $0x1,%ecx
  8007d2:	83 c2 01             	add    $0x1,%edx
  8007d5:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  8007d8:	39 c2                	cmp    %eax,%edx
  8007da:	74 09                	je     8007e5 <strlcpy+0x32>
  8007dc:	0f b6 19             	movzbl (%ecx),%ebx
  8007df:	84 db                	test   %bl,%bl
  8007e1:	75 ec                	jne    8007cf <strlcpy+0x1c>
  8007e3:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8007e5:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007e8:	29 f0                	sub    %esi,%eax
}
  8007ea:	5b                   	pop    %ebx
  8007eb:	5e                   	pop    %esi
  8007ec:	5d                   	pop    %ebp
  8007ed:	c3                   	ret    

008007ee <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007ee:	55                   	push   %ebp
  8007ef:	89 e5                	mov    %esp,%ebp
  8007f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007f7:	eb 06                	jmp    8007ff <strcmp+0x11>
		p++, q++;
  8007f9:	83 c1 01             	add    $0x1,%ecx
  8007fc:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8007ff:	0f b6 01             	movzbl (%ecx),%eax
  800802:	84 c0                	test   %al,%al
  800804:	74 04                	je     80080a <strcmp+0x1c>
  800806:	3a 02                	cmp    (%edx),%al
  800808:	74 ef                	je     8007f9 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80080a:	0f b6 c0             	movzbl %al,%eax
  80080d:	0f b6 12             	movzbl (%edx),%edx
  800810:	29 d0                	sub    %edx,%eax
}
  800812:	5d                   	pop    %ebp
  800813:	c3                   	ret    

00800814 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800814:	55                   	push   %ebp
  800815:	89 e5                	mov    %esp,%ebp
  800817:	53                   	push   %ebx
  800818:	8b 45 08             	mov    0x8(%ebp),%eax
  80081b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80081e:	89 c3                	mov    %eax,%ebx
  800820:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800823:	eb 06                	jmp    80082b <strncmp+0x17>
		n--, p++, q++;
  800825:	83 c0 01             	add    $0x1,%eax
  800828:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80082b:	39 d8                	cmp    %ebx,%eax
  80082d:	74 18                	je     800847 <strncmp+0x33>
  80082f:	0f b6 08             	movzbl (%eax),%ecx
  800832:	84 c9                	test   %cl,%cl
  800834:	74 04                	je     80083a <strncmp+0x26>
  800836:	3a 0a                	cmp    (%edx),%cl
  800838:	74 eb                	je     800825 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80083a:	0f b6 00             	movzbl (%eax),%eax
  80083d:	0f b6 12             	movzbl (%edx),%edx
  800840:	29 d0                	sub    %edx,%eax
}
  800842:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800845:	c9                   	leave  
  800846:	c3                   	ret    
		return 0;
  800847:	b8 00 00 00 00       	mov    $0x0,%eax
  80084c:	eb f4                	jmp    800842 <strncmp+0x2e>

0080084e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80084e:	55                   	push   %ebp
  80084f:	89 e5                	mov    %esp,%ebp
  800851:	8b 45 08             	mov    0x8(%ebp),%eax
  800854:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800858:	eb 03                	jmp    80085d <strchr+0xf>
  80085a:	83 c0 01             	add    $0x1,%eax
  80085d:	0f b6 10             	movzbl (%eax),%edx
  800860:	84 d2                	test   %dl,%dl
  800862:	74 06                	je     80086a <strchr+0x1c>
		if (*s == c)
  800864:	38 ca                	cmp    %cl,%dl
  800866:	75 f2                	jne    80085a <strchr+0xc>
  800868:	eb 05                	jmp    80086f <strchr+0x21>
			return (char *) s;
	return 0;
  80086a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80086f:	5d                   	pop    %ebp
  800870:	c3                   	ret    

00800871 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800871:	55                   	push   %ebp
  800872:	89 e5                	mov    %esp,%ebp
  800874:	8b 45 08             	mov    0x8(%ebp),%eax
  800877:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80087b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80087e:	38 ca                	cmp    %cl,%dl
  800880:	74 09                	je     80088b <strfind+0x1a>
  800882:	84 d2                	test   %dl,%dl
  800884:	74 05                	je     80088b <strfind+0x1a>
	for (; *s; s++)
  800886:	83 c0 01             	add    $0x1,%eax
  800889:	eb f0                	jmp    80087b <strfind+0xa>
			break;
	return (char *) s;
}
  80088b:	5d                   	pop    %ebp
  80088c:	c3                   	ret    

0080088d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80088d:	55                   	push   %ebp
  80088e:	89 e5                	mov    %esp,%ebp
  800890:	57                   	push   %edi
  800891:	56                   	push   %esi
  800892:	53                   	push   %ebx
  800893:	8b 55 08             	mov    0x8(%ebp),%edx
  800896:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  800899:	85 c9                	test   %ecx,%ecx
  80089b:	74 33                	je     8008d0 <memset+0x43>
		return v;
	if ((int) v % 4 == 0 && n % 4 == 0) {
  80089d:	89 d0                	mov    %edx,%eax
  80089f:	09 c8                	or     %ecx,%eax
  8008a1:	a8 03                	test   $0x3,%al
  8008a3:	75 23                	jne    8008c8 <memset+0x3b>
		c &= 0xFF;
  8008a5:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  8008a9:	89 d8                	mov    %ebx,%eax
  8008ab:	c1 e0 08             	shl    $0x8,%eax
  8008ae:	89 df                	mov    %ebx,%edi
  8008b0:	c1 e7 18             	shl    $0x18,%edi
  8008b3:	89 de                	mov    %ebx,%esi
  8008b5:	c1 e6 10             	shl    $0x10,%esi
  8008b8:	09 f7                	or     %esi,%edi
  8008ba:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
		             : "=D"(p), "=c"(n)
		             : "D"(p), "a"(c), "c"(n / 4)
  8008bc:	c1 e9 02             	shr    $0x2,%ecx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  8008bf:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  8008c1:	89 d7                	mov    %edx,%edi
  8008c3:	fc                   	cld    
  8008c4:	f3 ab                	rep stos %eax,%es:(%edi)
  8008c6:	eb 08                	jmp    8008d0 <memset+0x43>
		             : "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008c8:	89 d7                	mov    %edx,%edi
  8008ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008cd:	fc                   	cld    
  8008ce:	f3 aa                	rep stos %al,%es:(%edi)
		             : "=D"(p), "=c"(n)
		             : "0"(p), "a"(c), "1"(n)
		             : "cc", "memory");
	return v;
}
  8008d0:	89 d0                	mov    %edx,%eax
  8008d2:	5b                   	pop    %ebx
  8008d3:	5e                   	pop    %esi
  8008d4:	5f                   	pop    %edi
  8008d5:	5d                   	pop    %ebp
  8008d6:	c3                   	ret    

008008d7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	57                   	push   %edi
  8008db:	56                   	push   %esi
  8008dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008df:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008e2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008e5:	39 c6                	cmp    %eax,%esi
  8008e7:	73 32                	jae    80091b <memmove+0x44>
  8008e9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008ec:	39 c2                	cmp    %eax,%edx
  8008ee:	76 2b                	jbe    80091b <memmove+0x44>
		s += n;
		d += n;
  8008f0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  8008f3:	89 d6                	mov    %edx,%esi
  8008f5:	09 fe                	or     %edi,%esi
  8008f7:	09 ce                	or     %ecx,%esi
  8008f9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008ff:	75 0e                	jne    80090f <memmove+0x38>
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  800901:	83 ef 04             	sub    $0x4,%edi
			             "S"(s - 4),
  800904:	8d 72 fc             	lea    -0x4(%edx),%esi
			             "c"(n / 4)
  800907:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  80090a:	fd                   	std    
  80090b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80090d:	eb 09                	jmp    800918 <memmove+0x41>
			             : "cc", "memory");
		else
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  80090f:	83 ef 01             	sub    $0x1,%edi
			             "S"(s - 1),
  800912:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  800915:	fd                   	std    
  800916:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             "c"(n)
			             : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800918:	fc                   	cld    
  800919:	eb 1a                	jmp    800935 <memmove+0x5e>
	} else {
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  80091b:	89 f2                	mov    %esi,%edx
  80091d:	09 c2                	or     %eax,%edx
  80091f:	09 ca                	or     %ecx,%edx
  800921:	f6 c2 03             	test   $0x3,%dl
  800924:	75 0a                	jne    800930 <memmove+0x59>
			asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800926:	c1 e9 02             	shr    $0x2,%ecx
  800929:	89 c7                	mov    %eax,%edi
  80092b:	fc                   	cld    
  80092c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80092e:	eb 05                	jmp    800935 <memmove+0x5e>
			             : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800930:	89 c7                	mov    %eax,%edi
  800932:	fc                   	cld    
  800933:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             : "cc", "memory");
	}
	return dst;
}
  800935:	5e                   	pop    %esi
  800936:	5f                   	pop    %edi
  800937:	5d                   	pop    %ebp
  800938:	c3                   	ret    

00800939 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800939:	55                   	push   %ebp
  80093a:	89 e5                	mov    %esp,%ebp
  80093c:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80093f:	ff 75 10             	push   0x10(%ebp)
  800942:	ff 75 0c             	push   0xc(%ebp)
  800945:	ff 75 08             	push   0x8(%ebp)
  800948:	e8 8a ff ff ff       	call   8008d7 <memmove>
}
  80094d:	c9                   	leave  
  80094e:	c3                   	ret    

0080094f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80094f:	55                   	push   %ebp
  800950:	89 e5                	mov    %esp,%ebp
  800952:	56                   	push   %esi
  800953:	53                   	push   %ebx
  800954:	8b 45 08             	mov    0x8(%ebp),%eax
  800957:	8b 55 0c             	mov    0xc(%ebp),%edx
  80095a:	89 c6                	mov    %eax,%esi
  80095c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80095f:	eb 06                	jmp    800967 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800961:	83 c0 01             	add    $0x1,%eax
  800964:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800967:	39 f0                	cmp    %esi,%eax
  800969:	74 14                	je     80097f <memcmp+0x30>
		if (*s1 != *s2)
  80096b:	0f b6 08             	movzbl (%eax),%ecx
  80096e:	0f b6 1a             	movzbl (%edx),%ebx
  800971:	38 d9                	cmp    %bl,%cl
  800973:	74 ec                	je     800961 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800975:	0f b6 c1             	movzbl %cl,%eax
  800978:	0f b6 db             	movzbl %bl,%ebx
  80097b:	29 d8                	sub    %ebx,%eax
  80097d:	eb 05                	jmp    800984 <memcmp+0x35>
	}

	return 0;
  80097f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800984:	5b                   	pop    %ebx
  800985:	5e                   	pop    %esi
  800986:	5d                   	pop    %ebp
  800987:	c3                   	ret    

00800988 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	8b 45 08             	mov    0x8(%ebp),%eax
  80098e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800991:	89 c2                	mov    %eax,%edx
  800993:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800996:	eb 03                	jmp    80099b <memfind+0x13>
  800998:	83 c0 01             	add    $0x1,%eax
  80099b:	39 d0                	cmp    %edx,%eax
  80099d:	73 04                	jae    8009a3 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  80099f:	38 08                	cmp    %cl,(%eax)
  8009a1:	75 f5                	jne    800998 <memfind+0x10>
			break;
	return (void *) s;
}
  8009a3:	5d                   	pop    %ebp
  8009a4:	c3                   	ret    

008009a5 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009a5:	55                   	push   %ebp
  8009a6:	89 e5                	mov    %esp,%ebp
  8009a8:	57                   	push   %edi
  8009a9:	56                   	push   %esi
  8009aa:	53                   	push   %ebx
  8009ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8009ae:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009b1:	eb 03                	jmp    8009b6 <strtol+0x11>
		s++;
  8009b3:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  8009b6:	0f b6 02             	movzbl (%edx),%eax
  8009b9:	3c 20                	cmp    $0x20,%al
  8009bb:	74 f6                	je     8009b3 <strtol+0xe>
  8009bd:	3c 09                	cmp    $0x9,%al
  8009bf:	74 f2                	je     8009b3 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8009c1:	3c 2b                	cmp    $0x2b,%al
  8009c3:	74 2a                	je     8009ef <strtol+0x4a>
	int neg = 0;
  8009c5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8009ca:	3c 2d                	cmp    $0x2d,%al
  8009cc:	74 2b                	je     8009f9 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009ce:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009d4:	75 0f                	jne    8009e5 <strtol+0x40>
  8009d6:	80 3a 30             	cmpb   $0x30,(%edx)
  8009d9:	74 28                	je     800a03 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009db:	85 db                	test   %ebx,%ebx
  8009dd:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009e2:	0f 44 d8             	cmove  %eax,%ebx
  8009e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009ea:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8009ed:	eb 46                	jmp    800a35 <strtol+0x90>
		s++;
  8009ef:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  8009f2:	bf 00 00 00 00       	mov    $0x0,%edi
  8009f7:	eb d5                	jmp    8009ce <strtol+0x29>
		s++, neg = 1;
  8009f9:	83 c2 01             	add    $0x1,%edx
  8009fc:	bf 01 00 00 00       	mov    $0x1,%edi
  800a01:	eb cb                	jmp    8009ce <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a03:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a07:	74 0e                	je     800a17 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800a09:	85 db                	test   %ebx,%ebx
  800a0b:	75 d8                	jne    8009e5 <strtol+0x40>
		s++, base = 8;
  800a0d:	83 c2 01             	add    $0x1,%edx
  800a10:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a15:	eb ce                	jmp    8009e5 <strtol+0x40>
		s += 2, base = 16;
  800a17:	83 c2 02             	add    $0x2,%edx
  800a1a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a1f:	eb c4                	jmp    8009e5 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a21:	0f be c0             	movsbl %al,%eax
  800a24:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a27:	3b 45 10             	cmp    0x10(%ebp),%eax
  800a2a:	7d 3a                	jge    800a66 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800a2c:	83 c2 01             	add    $0x1,%edx
  800a2f:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800a33:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800a35:	0f b6 02             	movzbl (%edx),%eax
  800a38:	8d 70 d0             	lea    -0x30(%eax),%esi
  800a3b:	89 f3                	mov    %esi,%ebx
  800a3d:	80 fb 09             	cmp    $0x9,%bl
  800a40:	76 df                	jbe    800a21 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800a42:	8d 70 9f             	lea    -0x61(%eax),%esi
  800a45:	89 f3                	mov    %esi,%ebx
  800a47:	80 fb 19             	cmp    $0x19,%bl
  800a4a:	77 08                	ja     800a54 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800a4c:	0f be c0             	movsbl %al,%eax
  800a4f:	83 e8 57             	sub    $0x57,%eax
  800a52:	eb d3                	jmp    800a27 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800a54:	8d 70 bf             	lea    -0x41(%eax),%esi
  800a57:	89 f3                	mov    %esi,%ebx
  800a59:	80 fb 19             	cmp    $0x19,%bl
  800a5c:	77 08                	ja     800a66 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800a5e:	0f be c0             	movsbl %al,%eax
  800a61:	83 e8 37             	sub    $0x37,%eax
  800a64:	eb c1                	jmp    800a27 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a66:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a6a:	74 05                	je     800a71 <strtol+0xcc>
		*endptr = (char *) s;
  800a6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a6f:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800a71:	89 c8                	mov    %ecx,%eax
  800a73:	f7 d8                	neg    %eax
  800a75:	85 ff                	test   %edi,%edi
  800a77:	0f 45 c8             	cmovne %eax,%ecx
}
  800a7a:	89 c8                	mov    %ecx,%eax
  800a7c:	5b                   	pop    %ebx
  800a7d:	5e                   	pop    %esi
  800a7e:	5f                   	pop    %edi
  800a7f:	5d                   	pop    %ebp
  800a80:	c3                   	ret    

00800a81 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a81:	55                   	push   %ebp
  800a82:	89 e5                	mov    %esp,%ebp
  800a84:	57                   	push   %edi
  800a85:	56                   	push   %esi
  800a86:	53                   	push   %ebx
  800a87:	83 ec 1c             	sub    $0x1c,%esp
  800a8a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a8d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800a90:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile(
  800a92:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a95:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a98:	8b 7d 10             	mov    0x10(%ebp),%edi
  800a9b:	8b 75 14             	mov    0x14(%ebp),%esi
  800a9e:	cd 30                	int    $0x30
	        "int %1\n"
	        : "=a"(ret)
	        : "i"(T_SYSCALL), "a"(num), "d"(a1), "c"(a2), "b"(a3), "D"(a4), "S"(a5)
	        : "cc", "memory");

	if (check && ret > 0)
  800aa0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800aa4:	74 04                	je     800aaa <syscall+0x29>
  800aa6:	85 c0                	test   %eax,%eax
  800aa8:	7f 08                	jg     800ab2 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800aaa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800aad:	5b                   	pop    %ebx
  800aae:	5e                   	pop    %esi
  800aaf:	5f                   	pop    %edi
  800ab0:	5d                   	pop    %ebp
  800ab1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ab2:	83 ec 0c             	sub    $0xc,%esp
  800ab5:	50                   	push   %eax
  800ab6:	ff 75 e0             	push   -0x20(%ebp)
  800ab9:	68 64 12 80 00       	push   $0x801264
  800abe:	6a 1e                	push   $0x1e
  800ac0:	68 81 12 80 00       	push   $0x801281
  800ac5:	e8 5f f6 ff ff       	call   800129 <_panic>

00800aca <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800aca:	55                   	push   %ebp
  800acb:	89 e5                	mov    %esp,%ebp
  800acd:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t) s, len, 0, 0, 0);
  800ad0:	6a 00                	push   $0x0
  800ad2:	6a 00                	push   $0x0
  800ad4:	6a 00                	push   $0x0
  800ad6:	ff 75 0c             	push   0xc(%ebp)
  800ad9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800adc:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae6:	e8 96 ff ff ff       	call   800a81 <syscall>
}
  800aeb:	83 c4 10             	add    $0x10,%esp
  800aee:	c9                   	leave  
  800aef:	c3                   	ret    

00800af0 <sys_cgetc>:

int
sys_cgetc(void)
{
  800af0:	55                   	push   %ebp
  800af1:	89 e5                	mov    %esp,%ebp
  800af3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800af6:	6a 00                	push   $0x0
  800af8:	6a 00                	push   $0x0
  800afa:	6a 00                	push   $0x0
  800afc:	6a 00                	push   $0x0
  800afe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b03:	ba 00 00 00 00       	mov    $0x0,%edx
  800b08:	b8 01 00 00 00       	mov    $0x1,%eax
  800b0d:	e8 6f ff ff ff       	call   800a81 <syscall>
}
  800b12:	c9                   	leave  
  800b13:	c3                   	ret    

00800b14 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b14:	55                   	push   %ebp
  800b15:	89 e5                	mov    %esp,%ebp
  800b17:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800b1a:	6a 00                	push   $0x0
  800b1c:	6a 00                	push   $0x0
  800b1e:	6a 00                	push   $0x0
  800b20:	6a 00                	push   $0x0
  800b22:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b25:	ba 01 00 00 00       	mov    $0x1,%edx
  800b2a:	b8 03 00 00 00       	mov    $0x3,%eax
  800b2f:	e8 4d ff ff ff       	call   800a81 <syscall>
}
  800b34:	c9                   	leave  
  800b35:	c3                   	ret    

00800b36 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b36:	55                   	push   %ebp
  800b37:	89 e5                	mov    %esp,%ebp
  800b39:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800b3c:	6a 00                	push   $0x0
  800b3e:	6a 00                	push   $0x0
  800b40:	6a 00                	push   $0x0
  800b42:	6a 00                	push   $0x0
  800b44:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b49:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4e:	b8 02 00 00 00       	mov    $0x2,%eax
  800b53:	e8 29 ff ff ff       	call   800a81 <syscall>
}
  800b58:	c9                   	leave  
  800b59:	c3                   	ret    

00800b5a <sys_yield>:

void
sys_yield(void)
{
  800b5a:	55                   	push   %ebp
  800b5b:	89 e5                	mov    %esp,%ebp
  800b5d:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800b60:	6a 00                	push   $0x0
  800b62:	6a 00                	push   $0x0
  800b64:	6a 00                	push   $0x0
  800b66:	6a 00                	push   $0x0
  800b68:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b6d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b72:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b77:	e8 05 ff ff ff       	call   800a81 <syscall>
}
  800b7c:	83 c4 10             	add    $0x10,%esp
  800b7f:	c9                   	leave  
  800b80:	c3                   	ret    

00800b81 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800b87:	6a 00                	push   $0x0
  800b89:	6a 00                	push   $0x0
  800b8b:	ff 75 10             	push   0x10(%ebp)
  800b8e:	ff 75 0c             	push   0xc(%ebp)
  800b91:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b94:	ba 01 00 00 00       	mov    $0x1,%edx
  800b99:	b8 04 00 00 00       	mov    $0x4,%eax
  800b9e:	e8 de fe ff ff       	call   800a81 <syscall>
}
  800ba3:	c9                   	leave  
  800ba4:	c3                   	ret    

00800ba5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ba5:	55                   	push   %ebp
  800ba6:	89 e5                	mov    %esp,%ebp
  800ba8:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map,
  800bab:	ff 75 18             	push   0x18(%ebp)
  800bae:	ff 75 14             	push   0x14(%ebp)
  800bb1:	ff 75 10             	push   0x10(%ebp)
  800bb4:	ff 75 0c             	push   0xc(%ebp)
  800bb7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bba:	ba 01 00 00 00       	mov    $0x1,%edx
  800bbf:	b8 05 00 00 00       	mov    $0x5,%eax
  800bc4:	e8 b8 fe ff ff       	call   800a81 <syscall>
	               srcenv,
	               (uint32_t) srcva,
	               dstenv,
	               (uint32_t) dstva,
	               perm);
}
  800bc9:	c9                   	leave  
  800bca:	c3                   	ret    

00800bcb <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800bd1:	6a 00                	push   $0x0
  800bd3:	6a 00                	push   $0x0
  800bd5:	6a 00                	push   $0x0
  800bd7:	ff 75 0c             	push   0xc(%ebp)
  800bda:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bdd:	ba 01 00 00 00       	mov    $0x1,%edx
  800be2:	b8 06 00 00 00       	mov    $0x6,%eax
  800be7:	e8 95 fe ff ff       	call   800a81 <syscall>
}
  800bec:	c9                   	leave  
  800bed:	c3                   	ret    

00800bee <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bee:	55                   	push   %ebp
  800bef:	89 e5                	mov    %esp,%ebp
  800bf1:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800bf4:	6a 00                	push   $0x0
  800bf6:	6a 00                	push   $0x0
  800bf8:	6a 00                	push   $0x0
  800bfa:	ff 75 0c             	push   0xc(%ebp)
  800bfd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c00:	ba 01 00 00 00       	mov    $0x1,%edx
  800c05:	b8 08 00 00 00       	mov    $0x8,%eax
  800c0a:	e8 72 fe ff ff       	call   800a81 <syscall>
}
  800c0f:	c9                   	leave  
  800c10:	c3                   	ret    

00800c11 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c11:	55                   	push   %ebp
  800c12:	89 e5                	mov    %esp,%ebp
  800c14:	83 ec 08             	sub    $0x8,%esp
	return syscall(
  800c17:	6a 00                	push   $0x0
  800c19:	6a 00                	push   $0x0
  800c1b:	6a 00                	push   $0x0
  800c1d:	ff 75 0c             	push   0xc(%ebp)
  800c20:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c23:	ba 01 00 00 00       	mov    $0x1,%edx
  800c28:	b8 09 00 00 00       	mov    $0x9,%eax
  800c2d:	e8 4f fe ff ff       	call   800a81 <syscall>
	        SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c32:	c9                   	leave  
  800c33:	c3                   	ret    

00800c34 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c34:	55                   	push   %ebp
  800c35:	89 e5                	mov    %esp,%ebp
  800c37:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800c3a:	6a 00                	push   $0x0
  800c3c:	ff 75 14             	push   0x14(%ebp)
  800c3f:	ff 75 10             	push   0x10(%ebp)
  800c42:	ff 75 0c             	push   0xc(%ebp)
  800c45:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c48:	ba 00 00 00 00       	mov    $0x0,%edx
  800c4d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c52:	e8 2a fe ff ff       	call   800a81 <syscall>
}
  800c57:	c9                   	leave  
  800c58:	c3                   	ret    

00800c59 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c59:	55                   	push   %ebp
  800c5a:	89 e5                	mov    %esp,%ebp
  800c5c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t) dstva, 0, 0, 0, 0);
  800c5f:	6a 00                	push   $0x0
  800c61:	6a 00                	push   $0x0
  800c63:	6a 00                	push   $0x0
  800c65:	6a 00                	push   $0x0
  800c67:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c6a:	ba 01 00 00 00       	mov    $0x1,%edx
  800c6f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c74:	e8 08 fe ff ff       	call   800a81 <syscall>
}
  800c79:	c9                   	leave  
  800c7a:	c3                   	ret    

00800c7b <sys_get_priority>:

// Get priority of the current process
int
sys_get_priority(void)
{
  800c7b:	55                   	push   %ebp
  800c7c:	89 e5                	mov    %esp,%ebp
  800c7e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_get_priority, 0, 0, 0, 0, 0, 0);
  800c81:	6a 00                	push   $0x0
  800c83:	6a 00                	push   $0x0
  800c85:	6a 00                	push   $0x0
  800c87:	6a 00                	push   $0x0
  800c89:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c8e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c93:	b8 0d 00 00 00       	mov    $0xd,%eax
  800c98:	e8 e4 fd ff ff       	call   800a81 <syscall>
}
  800c9d:	c9                   	leave  
  800c9e:	c3                   	ret    

00800c9f <sys_set_priority>:

// Get priority of the current process
int
sys_set_priority(unsigned int priority)
{
  800c9f:	55                   	push   %ebp
  800ca0:	89 e5                	mov    %esp,%ebp
  800ca2:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, (uint32_t) priority, 0, 0, 0, 0);
  800ca5:	6a 00                	push   $0x0
  800ca7:	6a 00                	push   $0x0
  800ca9:	6a 00                	push   $0x0
  800cab:	6a 00                	push   $0x0
  800cad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cb0:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb5:	b8 0e 00 00 00       	mov    $0xe,%eax
  800cba:	e8 c2 fd ff ff       	call   800a81 <syscall>
}
  800cbf:	c9                   	leave  
  800cc0:	c3                   	ret    

00800cc1 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800cc7:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800cce:	74 0a                	je     800cda <set_pgfault_handler+0x19>
		if (r < 0)
			return;
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800cd0:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd3:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800cd8:	c9                   	leave  
  800cd9:	c3                   	ret    
		r = sys_page_alloc(0, (void *) exstk, perm);
  800cda:	83 ec 04             	sub    $0x4,%esp
  800cdd:	6a 07                	push   $0x7
  800cdf:	68 00 f0 bf ee       	push   $0xeebff000
  800ce4:	6a 00                	push   $0x0
  800ce6:	e8 96 fe ff ff       	call   800b81 <sys_page_alloc>
		if (r < 0)
  800ceb:	83 c4 10             	add    $0x10,%esp
  800cee:	85 c0                	test   %eax,%eax
  800cf0:	78 e6                	js     800cd8 <set_pgfault_handler+0x17>
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  800cf2:	83 ec 08             	sub    $0x8,%esp
  800cf5:	68 0a 0d 80 00       	push   $0x800d0a
  800cfa:	6a 00                	push   $0x0
  800cfc:	e8 10 ff ff ff       	call   800c11 <sys_env_set_pgfault_upcall>
		if (r < 0)
  800d01:	83 c4 10             	add    $0x10,%esp
  800d04:	85 c0                	test   %eax,%eax
  800d06:	79 c8                	jns    800cd0 <set_pgfault_handler+0xf>
  800d08:	eb ce                	jmp    800cd8 <set_pgfault_handler+0x17>

00800d0a <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800d0a:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800d0b:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800d10:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800d12:	83 c4 04             	add    $0x4,%esp
	// Throughout the remaining code, think carefully about what
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	movl 40(%esp), %eax	// trap-time %epi -> %eax 
  800d15:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %ebx	// trap-time %esp -> %ebx
  800d19:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4, %ebx
  800d1d:	83 eb 04             	sub    $0x4,%ebx
	movl %eax, 0(%ebx)	// push %eip in trap-time stack
  800d20:	89 03                	mov    %eax,(%ebx)

	movl %ebx, 48(%esp)
  800d22:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	popl %eax
  800d26:	58                   	pop    %eax
	popl %eax
  800d27:	58                   	pop    %eax
	popal
  800d28:	61                   	popa   
	

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	addl $4, %esp
  800d29:	83 c4 04             	add    $0x4,%esp
	popfl
  800d2c:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	popl %esp
  800d2d:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	ret
  800d2e:	c3                   	ret    
  800d2f:	90                   	nop

00800d30 <__udivdi3>:
  800d30:	f3 0f 1e fb          	endbr32 
  800d34:	55                   	push   %ebp
  800d35:	57                   	push   %edi
  800d36:	56                   	push   %esi
  800d37:	53                   	push   %ebx
  800d38:	83 ec 1c             	sub    $0x1c,%esp
  800d3b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800d3f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800d43:	8b 74 24 34          	mov    0x34(%esp),%esi
  800d47:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800d4b:	85 c0                	test   %eax,%eax
  800d4d:	75 19                	jne    800d68 <__udivdi3+0x38>
  800d4f:	39 f3                	cmp    %esi,%ebx
  800d51:	76 4d                	jbe    800da0 <__udivdi3+0x70>
  800d53:	31 ff                	xor    %edi,%edi
  800d55:	89 e8                	mov    %ebp,%eax
  800d57:	89 f2                	mov    %esi,%edx
  800d59:	f7 f3                	div    %ebx
  800d5b:	89 fa                	mov    %edi,%edx
  800d5d:	83 c4 1c             	add    $0x1c,%esp
  800d60:	5b                   	pop    %ebx
  800d61:	5e                   	pop    %esi
  800d62:	5f                   	pop    %edi
  800d63:	5d                   	pop    %ebp
  800d64:	c3                   	ret    
  800d65:	8d 76 00             	lea    0x0(%esi),%esi
  800d68:	39 f0                	cmp    %esi,%eax
  800d6a:	76 14                	jbe    800d80 <__udivdi3+0x50>
  800d6c:	31 ff                	xor    %edi,%edi
  800d6e:	31 c0                	xor    %eax,%eax
  800d70:	89 fa                	mov    %edi,%edx
  800d72:	83 c4 1c             	add    $0x1c,%esp
  800d75:	5b                   	pop    %ebx
  800d76:	5e                   	pop    %esi
  800d77:	5f                   	pop    %edi
  800d78:	5d                   	pop    %ebp
  800d79:	c3                   	ret    
  800d7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d80:	0f bd f8             	bsr    %eax,%edi
  800d83:	83 f7 1f             	xor    $0x1f,%edi
  800d86:	75 48                	jne    800dd0 <__udivdi3+0xa0>
  800d88:	39 f0                	cmp    %esi,%eax
  800d8a:	72 06                	jb     800d92 <__udivdi3+0x62>
  800d8c:	31 c0                	xor    %eax,%eax
  800d8e:	39 eb                	cmp    %ebp,%ebx
  800d90:	77 de                	ja     800d70 <__udivdi3+0x40>
  800d92:	b8 01 00 00 00       	mov    $0x1,%eax
  800d97:	eb d7                	jmp    800d70 <__udivdi3+0x40>
  800d99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800da0:	89 d9                	mov    %ebx,%ecx
  800da2:	85 db                	test   %ebx,%ebx
  800da4:	75 0b                	jne    800db1 <__udivdi3+0x81>
  800da6:	b8 01 00 00 00       	mov    $0x1,%eax
  800dab:	31 d2                	xor    %edx,%edx
  800dad:	f7 f3                	div    %ebx
  800daf:	89 c1                	mov    %eax,%ecx
  800db1:	31 d2                	xor    %edx,%edx
  800db3:	89 f0                	mov    %esi,%eax
  800db5:	f7 f1                	div    %ecx
  800db7:	89 c6                	mov    %eax,%esi
  800db9:	89 e8                	mov    %ebp,%eax
  800dbb:	89 f7                	mov    %esi,%edi
  800dbd:	f7 f1                	div    %ecx
  800dbf:	89 fa                	mov    %edi,%edx
  800dc1:	83 c4 1c             	add    $0x1c,%esp
  800dc4:	5b                   	pop    %ebx
  800dc5:	5e                   	pop    %esi
  800dc6:	5f                   	pop    %edi
  800dc7:	5d                   	pop    %ebp
  800dc8:	c3                   	ret    
  800dc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800dd0:	89 f9                	mov    %edi,%ecx
  800dd2:	ba 20 00 00 00       	mov    $0x20,%edx
  800dd7:	29 fa                	sub    %edi,%edx
  800dd9:	d3 e0                	shl    %cl,%eax
  800ddb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ddf:	89 d1                	mov    %edx,%ecx
  800de1:	89 d8                	mov    %ebx,%eax
  800de3:	d3 e8                	shr    %cl,%eax
  800de5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800de9:	09 c1                	or     %eax,%ecx
  800deb:	89 f0                	mov    %esi,%eax
  800ded:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800df1:	89 f9                	mov    %edi,%ecx
  800df3:	d3 e3                	shl    %cl,%ebx
  800df5:	89 d1                	mov    %edx,%ecx
  800df7:	d3 e8                	shr    %cl,%eax
  800df9:	89 f9                	mov    %edi,%ecx
  800dfb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800dff:	89 eb                	mov    %ebp,%ebx
  800e01:	d3 e6                	shl    %cl,%esi
  800e03:	89 d1                	mov    %edx,%ecx
  800e05:	d3 eb                	shr    %cl,%ebx
  800e07:	09 f3                	or     %esi,%ebx
  800e09:	89 c6                	mov    %eax,%esi
  800e0b:	89 f2                	mov    %esi,%edx
  800e0d:	89 d8                	mov    %ebx,%eax
  800e0f:	f7 74 24 08          	divl   0x8(%esp)
  800e13:	89 d6                	mov    %edx,%esi
  800e15:	89 c3                	mov    %eax,%ebx
  800e17:	f7 64 24 0c          	mull   0xc(%esp)
  800e1b:	39 d6                	cmp    %edx,%esi
  800e1d:	72 19                	jb     800e38 <__udivdi3+0x108>
  800e1f:	89 f9                	mov    %edi,%ecx
  800e21:	d3 e5                	shl    %cl,%ebp
  800e23:	39 c5                	cmp    %eax,%ebp
  800e25:	73 04                	jae    800e2b <__udivdi3+0xfb>
  800e27:	39 d6                	cmp    %edx,%esi
  800e29:	74 0d                	je     800e38 <__udivdi3+0x108>
  800e2b:	89 d8                	mov    %ebx,%eax
  800e2d:	31 ff                	xor    %edi,%edi
  800e2f:	e9 3c ff ff ff       	jmp    800d70 <__udivdi3+0x40>
  800e34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e38:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800e3b:	31 ff                	xor    %edi,%edi
  800e3d:	e9 2e ff ff ff       	jmp    800d70 <__udivdi3+0x40>
  800e42:	66 90                	xchg   %ax,%ax
  800e44:	66 90                	xchg   %ax,%ax
  800e46:	66 90                	xchg   %ax,%ax
  800e48:	66 90                	xchg   %ax,%ax
  800e4a:	66 90                	xchg   %ax,%ax
  800e4c:	66 90                	xchg   %ax,%ax
  800e4e:	66 90                	xchg   %ax,%ax

00800e50 <__umoddi3>:
  800e50:	f3 0f 1e fb          	endbr32 
  800e54:	55                   	push   %ebp
  800e55:	57                   	push   %edi
  800e56:	56                   	push   %esi
  800e57:	53                   	push   %ebx
  800e58:	83 ec 1c             	sub    $0x1c,%esp
  800e5b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800e5f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800e63:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  800e67:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  800e6b:	89 f0                	mov    %esi,%eax
  800e6d:	89 da                	mov    %ebx,%edx
  800e6f:	85 ff                	test   %edi,%edi
  800e71:	75 15                	jne    800e88 <__umoddi3+0x38>
  800e73:	39 dd                	cmp    %ebx,%ebp
  800e75:	76 39                	jbe    800eb0 <__umoddi3+0x60>
  800e77:	f7 f5                	div    %ebp
  800e79:	89 d0                	mov    %edx,%eax
  800e7b:	31 d2                	xor    %edx,%edx
  800e7d:	83 c4 1c             	add    $0x1c,%esp
  800e80:	5b                   	pop    %ebx
  800e81:	5e                   	pop    %esi
  800e82:	5f                   	pop    %edi
  800e83:	5d                   	pop    %ebp
  800e84:	c3                   	ret    
  800e85:	8d 76 00             	lea    0x0(%esi),%esi
  800e88:	39 df                	cmp    %ebx,%edi
  800e8a:	77 f1                	ja     800e7d <__umoddi3+0x2d>
  800e8c:	0f bd cf             	bsr    %edi,%ecx
  800e8f:	83 f1 1f             	xor    $0x1f,%ecx
  800e92:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800e96:	75 40                	jne    800ed8 <__umoddi3+0x88>
  800e98:	39 df                	cmp    %ebx,%edi
  800e9a:	72 04                	jb     800ea0 <__umoddi3+0x50>
  800e9c:	39 f5                	cmp    %esi,%ebp
  800e9e:	77 dd                	ja     800e7d <__umoddi3+0x2d>
  800ea0:	89 da                	mov    %ebx,%edx
  800ea2:	89 f0                	mov    %esi,%eax
  800ea4:	29 e8                	sub    %ebp,%eax
  800ea6:	19 fa                	sbb    %edi,%edx
  800ea8:	eb d3                	jmp    800e7d <__umoddi3+0x2d>
  800eaa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800eb0:	89 e9                	mov    %ebp,%ecx
  800eb2:	85 ed                	test   %ebp,%ebp
  800eb4:	75 0b                	jne    800ec1 <__umoddi3+0x71>
  800eb6:	b8 01 00 00 00       	mov    $0x1,%eax
  800ebb:	31 d2                	xor    %edx,%edx
  800ebd:	f7 f5                	div    %ebp
  800ebf:	89 c1                	mov    %eax,%ecx
  800ec1:	89 d8                	mov    %ebx,%eax
  800ec3:	31 d2                	xor    %edx,%edx
  800ec5:	f7 f1                	div    %ecx
  800ec7:	89 f0                	mov    %esi,%eax
  800ec9:	f7 f1                	div    %ecx
  800ecb:	89 d0                	mov    %edx,%eax
  800ecd:	31 d2                	xor    %edx,%edx
  800ecf:	eb ac                	jmp    800e7d <__umoddi3+0x2d>
  800ed1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ed8:	8b 44 24 04          	mov    0x4(%esp),%eax
  800edc:	ba 20 00 00 00       	mov    $0x20,%edx
  800ee1:	29 c2                	sub    %eax,%edx
  800ee3:	89 c1                	mov    %eax,%ecx
  800ee5:	89 e8                	mov    %ebp,%eax
  800ee7:	d3 e7                	shl    %cl,%edi
  800ee9:	89 d1                	mov    %edx,%ecx
  800eeb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800eef:	d3 e8                	shr    %cl,%eax
  800ef1:	89 c1                	mov    %eax,%ecx
  800ef3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800ef7:	09 f9                	or     %edi,%ecx
  800ef9:	89 df                	mov    %ebx,%edi
  800efb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800eff:	89 c1                	mov    %eax,%ecx
  800f01:	d3 e5                	shl    %cl,%ebp
  800f03:	89 d1                	mov    %edx,%ecx
  800f05:	d3 ef                	shr    %cl,%edi
  800f07:	89 c1                	mov    %eax,%ecx
  800f09:	89 f0                	mov    %esi,%eax
  800f0b:	d3 e3                	shl    %cl,%ebx
  800f0d:	89 d1                	mov    %edx,%ecx
  800f0f:	89 fa                	mov    %edi,%edx
  800f11:	d3 e8                	shr    %cl,%eax
  800f13:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f18:	09 d8                	or     %ebx,%eax
  800f1a:	f7 74 24 08          	divl   0x8(%esp)
  800f1e:	89 d3                	mov    %edx,%ebx
  800f20:	d3 e6                	shl    %cl,%esi
  800f22:	f7 e5                	mul    %ebp
  800f24:	89 c7                	mov    %eax,%edi
  800f26:	89 d1                	mov    %edx,%ecx
  800f28:	39 d3                	cmp    %edx,%ebx
  800f2a:	72 06                	jb     800f32 <__umoddi3+0xe2>
  800f2c:	75 0e                	jne    800f3c <__umoddi3+0xec>
  800f2e:	39 c6                	cmp    %eax,%esi
  800f30:	73 0a                	jae    800f3c <__umoddi3+0xec>
  800f32:	29 e8                	sub    %ebp,%eax
  800f34:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800f38:	89 d1                	mov    %edx,%ecx
  800f3a:	89 c7                	mov    %eax,%edi
  800f3c:	89 f5                	mov    %esi,%ebp
  800f3e:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f42:	29 fd                	sub    %edi,%ebp
  800f44:	19 cb                	sbb    %ecx,%ebx
  800f46:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800f4b:	89 d8                	mov    %ebx,%eax
  800f4d:	d3 e0                	shl    %cl,%eax
  800f4f:	89 f1                	mov    %esi,%ecx
  800f51:	d3 ed                	shr    %cl,%ebp
  800f53:	d3 eb                	shr    %cl,%ebx
  800f55:	09 e8                	or     %ebp,%eax
  800f57:	89 da                	mov    %ebx,%edx
  800f59:	83 c4 1c             	add    $0x1c,%esp
  800f5c:	5b                   	pop    %ebx
  800f5d:	5e                   	pop    %esi
  800f5e:	5f                   	pop    %edi
  800f5f:	5d                   	pop    %ebp
  800f60:	c3                   	ret    
