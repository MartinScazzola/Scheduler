
obj/user/sendpage:     formato del fichero elf32-i386


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
  80002c:	e8 7f 01 00 00       	call   8001b0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#define TEMP_ADDR ((char *) 0xa00000)
#define TEMP_ADDR_CHILD ((char *) 0xb00000)

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	envid_t who;

	if ((who = fork()) == 0) {
  800039:	e8 49 10 00 00       	call   801087 <fork>
  80003e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800041:	85 c0                	test   %eax,%eax
  800043:	0f 84 ab 00 00 00    	je     8000f4 <umain+0xc1>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
		return;
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800049:	a1 0c 20 80 00       	mov    0x80200c,%eax
  80004e:	8b 40 48             	mov    0x48(%eax),%eax
  800051:	83 ec 04             	sub    $0x4,%esp
  800054:	6a 07                	push   $0x7
  800056:	68 00 00 a0 00       	push   $0xa00000
  80005b:	50                   	push   %eax
  80005c:	e8 c0 0b 00 00       	call   800c21 <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  800061:	83 c4 04             	add    $0x4,%esp
  800064:	ff 35 04 20 80 00    	push   0x802004
  80006a:	e8 33 07 00 00       	call   8007a2 <strlen>
  80006f:	83 c4 0c             	add    $0xc,%esp
  800072:	83 c0 01             	add    $0x1,%eax
  800075:	50                   	push   %eax
  800076:	ff 35 04 20 80 00    	push   0x802004
  80007c:	68 00 00 a0 00       	push   $0xa00000
  800081:	e8 53 09 00 00       	call   8009d9 <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800086:	6a 07                	push   $0x7
  800088:	68 00 00 a0 00       	push   $0xa00000
  80008d:	6a 00                	push   $0x0
  80008f:	ff 75 f4             	push   -0xc(%ebp)
  800092:	e8 8e 11 00 00       	call   801225 <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  800097:	83 c4 1c             	add    $0x1c,%esp
  80009a:	6a 00                	push   $0x0
  80009c:	68 00 00 a0 00       	push   $0xa00000
  8000a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000a4:	50                   	push   %eax
  8000a5:	e8 19 11 00 00       	call   8011c3 <ipc_recv>
	cprintf("%x got message from %x: %s\n", thisenv->env_id, who, TEMP_ADDR);
  8000aa:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8000af:	8b 40 48             	mov    0x48(%eax),%eax
  8000b2:	68 00 00 a0 00       	push   $0xa00000
  8000b7:	ff 75 f4             	push   -0xc(%ebp)
  8000ba:	50                   	push   %eax
  8000bb:	68 c0 15 80 00       	push   $0x8015c0
  8000c0:	e8 df 01 00 00       	call   8002a4 <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  8000c5:	83 c4 14             	add    $0x14,%esp
  8000c8:	ff 35 00 20 80 00    	push   0x802000
  8000ce:	e8 cf 06 00 00       	call   8007a2 <strlen>
  8000d3:	83 c4 0c             	add    $0xc,%esp
  8000d6:	50                   	push   %eax
  8000d7:	ff 35 00 20 80 00    	push   0x802000
  8000dd:	68 00 00 a0 00       	push   $0xa00000
  8000e2:	e8 cd 07 00 00       	call   8008b4 <strncmp>
  8000e7:	83 c4 10             	add    $0x10,%esp
  8000ea:	85 c0                	test   %eax,%eax
  8000ec:	0f 84 a9 00 00 00    	je     80019b <umain+0x168>
		cprintf("parent received correct message\n");
	return;
}
  8000f2:	c9                   	leave  
  8000f3:	c3                   	ret    
		ipc_recv(&who, TEMP_ADDR_CHILD, 0);
  8000f4:	83 ec 04             	sub    $0x4,%esp
  8000f7:	6a 00                	push   $0x0
  8000f9:	68 00 00 b0 00       	push   $0xb00000
  8000fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800101:	50                   	push   %eax
  800102:	e8 bc 10 00 00       	call   8011c3 <ipc_recv>
		        thisenv->env_id,
  800107:	a1 0c 20 80 00       	mov    0x80200c,%eax
  80010c:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("%x got message from %x: %s\n",
  80010f:	68 00 00 b0 00       	push   $0xb00000
  800114:	ff 75 f4             	push   -0xc(%ebp)
  800117:	50                   	push   %eax
  800118:	68 c0 15 80 00       	push   $0x8015c0
  80011d:	e8 82 01 00 00       	call   8002a4 <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  800122:	83 c4 14             	add    $0x14,%esp
  800125:	ff 35 04 20 80 00    	push   0x802004
  80012b:	e8 72 06 00 00       	call   8007a2 <strlen>
  800130:	83 c4 0c             	add    $0xc,%esp
  800133:	50                   	push   %eax
  800134:	ff 35 04 20 80 00    	push   0x802004
  80013a:	68 00 00 b0 00       	push   $0xb00000
  80013f:	e8 70 07 00 00       	call   8008b4 <strncmp>
  800144:	83 c4 10             	add    $0x10,%esp
  800147:	85 c0                	test   %eax,%eax
  800149:	74 3e                	je     800189 <umain+0x156>
		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  80014b:	83 ec 0c             	sub    $0xc,%esp
  80014e:	ff 35 00 20 80 00    	push   0x802000
  800154:	e8 49 06 00 00       	call   8007a2 <strlen>
  800159:	83 c4 0c             	add    $0xc,%esp
  80015c:	83 c0 01             	add    $0x1,%eax
  80015f:	50                   	push   %eax
  800160:	ff 35 00 20 80 00    	push   0x802000
  800166:	68 00 00 b0 00       	push   $0xb00000
  80016b:	e8 69 08 00 00       	call   8009d9 <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  800170:	6a 07                	push   $0x7
  800172:	68 00 00 b0 00       	push   $0xb00000
  800177:	6a 00                	push   $0x0
  800179:	ff 75 f4             	push   -0xc(%ebp)
  80017c:	e8 a4 10 00 00       	call   801225 <ipc_send>
		return;
  800181:	83 c4 20             	add    $0x20,%esp
  800184:	e9 69 ff ff ff       	jmp    8000f2 <umain+0xbf>
			cprintf("child received correct message\n");
  800189:	83 ec 0c             	sub    $0xc,%esp
  80018c:	68 dc 15 80 00       	push   $0x8015dc
  800191:	e8 0e 01 00 00       	call   8002a4 <cprintf>
  800196:	83 c4 10             	add    $0x10,%esp
  800199:	eb b0                	jmp    80014b <umain+0x118>
		cprintf("parent received correct message\n");
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	68 fc 15 80 00       	push   $0x8015fc
  8001a3:	e8 fc 00 00 00       	call   8002a4 <cprintf>
  8001a8:	83 c4 10             	add    $0x10,%esp
  8001ab:	e9 42 ff ff ff       	jmp    8000f2 <umain+0xbf>

008001b0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	56                   	push   %esi
  8001b4:	53                   	push   %ebx
  8001b5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001b8:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	envid_t id = sys_getenvid();
  8001bb:	e8 16 0a 00 00       	call   800bd6 <sys_getenvid>
	if (id >= 0)
  8001c0:	85 c0                	test   %eax,%eax
  8001c2:	78 15                	js     8001d9 <libmain+0x29>
		thisenv = &envs[ENVX(id)];
  8001c4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001c9:	69 c0 88 00 00 00    	imul   $0x88,%eax,%eax
  8001cf:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001d4:	a3 0c 20 80 00       	mov    %eax,0x80200c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001d9:	85 db                	test   %ebx,%ebx
  8001db:	7e 07                	jle    8001e4 <libmain+0x34>
		binaryname = argv[0];
  8001dd:	8b 06                	mov    (%esi),%eax
  8001df:	a3 08 20 80 00       	mov    %eax,0x802008

	// call user main routine
	umain(argc, argv);
  8001e4:	83 ec 08             	sub    $0x8,%esp
  8001e7:	56                   	push   %esi
  8001e8:	53                   	push   %ebx
  8001e9:	e8 45 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8001ee:	e8 0a 00 00 00       	call   8001fd <exit>
}
  8001f3:	83 c4 10             	add    $0x10,%esp
  8001f6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001f9:	5b                   	pop    %ebx
  8001fa:	5e                   	pop    %esi
  8001fb:	5d                   	pop    %ebp
  8001fc:	c3                   	ret    

008001fd <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001fd:	55                   	push   %ebp
  8001fe:	89 e5                	mov    %esp,%ebp
  800200:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800203:	6a 00                	push   $0x0
  800205:	e8 aa 09 00 00       	call   800bb4 <sys_env_destroy>
}
  80020a:	83 c4 10             	add    $0x10,%esp
  80020d:	c9                   	leave  
  80020e:	c3                   	ret    

0080020f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80020f:	55                   	push   %ebp
  800210:	89 e5                	mov    %esp,%ebp
  800212:	53                   	push   %ebx
  800213:	83 ec 04             	sub    $0x4,%esp
  800216:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800219:	8b 13                	mov    (%ebx),%edx
  80021b:	8d 42 01             	lea    0x1(%edx),%eax
  80021e:	89 03                	mov    %eax,(%ebx)
  800220:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800223:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256 - 1) {
  800227:	3d ff 00 00 00       	cmp    $0xff,%eax
  80022c:	74 09                	je     800237 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80022e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800232:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800235:	c9                   	leave  
  800236:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800237:	83 ec 08             	sub    $0x8,%esp
  80023a:	68 ff 00 00 00       	push   $0xff
  80023f:	8d 43 08             	lea    0x8(%ebx),%eax
  800242:	50                   	push   %eax
  800243:	e8 22 09 00 00       	call   800b6a <sys_cputs>
		b->idx = 0;
  800248:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80024e:	83 c4 10             	add    $0x10,%esp
  800251:	eb db                	jmp    80022e <putch+0x1f>

00800253 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800253:	55                   	push   %ebp
  800254:	89 e5                	mov    %esp,%ebp
  800256:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80025c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800263:	00 00 00 
	b.cnt = 0;
  800266:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80026d:	00 00 00 
	vprintfmt((void *) putch, &b, fmt, ap);
  800270:	ff 75 0c             	push   0xc(%ebp)
  800273:	ff 75 08             	push   0x8(%ebp)
  800276:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80027c:	50                   	push   %eax
  80027d:	68 0f 02 80 00       	push   $0x80020f
  800282:	e8 74 01 00 00       	call   8003fb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800287:	83 c4 08             	add    $0x8,%esp
  80028a:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800290:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800296:	50                   	push   %eax
  800297:	e8 ce 08 00 00       	call   800b6a <sys_cputs>

	return b.cnt;
}
  80029c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002a2:	c9                   	leave  
  8002a3:	c3                   	ret    

008002a4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002a4:	55                   	push   %ebp
  8002a5:	89 e5                	mov    %esp,%ebp
  8002a7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002aa:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002ad:	50                   	push   %eax
  8002ae:	ff 75 08             	push   0x8(%ebp)
  8002b1:	e8 9d ff ff ff       	call   800253 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002b6:	c9                   	leave  
  8002b7:	c3                   	ret    

008002b8 <printnum>:
         void *putdat,
         unsigned long long num,
         unsigned base,
         int width,
         int padc)
{
  8002b8:	55                   	push   %ebp
  8002b9:	89 e5                	mov    %esp,%ebp
  8002bb:	57                   	push   %edi
  8002bc:	56                   	push   %esi
  8002bd:	53                   	push   %ebx
  8002be:	83 ec 1c             	sub    $0x1c,%esp
  8002c1:	89 c7                	mov    %eax,%edi
  8002c3:	89 d6                	mov    %edx,%esi
  8002c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002cb:	89 d1                	mov    %edx,%ecx
  8002cd:	89 c2                	mov    %eax,%edx
  8002cf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002d2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8002d5:	8b 45 10             	mov    0x10(%ebp),%eax
  8002d8:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002db:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002de:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002e5:	39 c2                	cmp    %eax,%edx
  8002e7:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8002ea:	72 3e                	jb     80032a <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002ec:	83 ec 0c             	sub    $0xc,%esp
  8002ef:	ff 75 18             	push   0x18(%ebp)
  8002f2:	83 eb 01             	sub    $0x1,%ebx
  8002f5:	53                   	push   %ebx
  8002f6:	50                   	push   %eax
  8002f7:	83 ec 08             	sub    $0x8,%esp
  8002fa:	ff 75 e4             	push   -0x1c(%ebp)
  8002fd:	ff 75 e0             	push   -0x20(%ebp)
  800300:	ff 75 dc             	push   -0x24(%ebp)
  800303:	ff 75 d8             	push   -0x28(%ebp)
  800306:	e8 75 10 00 00       	call   801380 <__udivdi3>
  80030b:	83 c4 18             	add    $0x18,%esp
  80030e:	52                   	push   %edx
  80030f:	50                   	push   %eax
  800310:	89 f2                	mov    %esi,%edx
  800312:	89 f8                	mov    %edi,%eax
  800314:	e8 9f ff ff ff       	call   8002b8 <printnum>
  800319:	83 c4 20             	add    $0x20,%esp
  80031c:	eb 13                	jmp    800331 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80031e:	83 ec 08             	sub    $0x8,%esp
  800321:	56                   	push   %esi
  800322:	ff 75 18             	push   0x18(%ebp)
  800325:	ff d7                	call   *%edi
  800327:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80032a:	83 eb 01             	sub    $0x1,%ebx
  80032d:	85 db                	test   %ebx,%ebx
  80032f:	7f ed                	jg     80031e <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800331:	83 ec 08             	sub    $0x8,%esp
  800334:	56                   	push   %esi
  800335:	83 ec 04             	sub    $0x4,%esp
  800338:	ff 75 e4             	push   -0x1c(%ebp)
  80033b:	ff 75 e0             	push   -0x20(%ebp)
  80033e:	ff 75 dc             	push   -0x24(%ebp)
  800341:	ff 75 d8             	push   -0x28(%ebp)
  800344:	e8 57 11 00 00       	call   8014a0 <__umoddi3>
  800349:	83 c4 14             	add    $0x14,%esp
  80034c:	0f be 80 74 16 80 00 	movsbl 0x801674(%eax),%eax
  800353:	50                   	push   %eax
  800354:	ff d7                	call   *%edi
}
  800356:	83 c4 10             	add    $0x10,%esp
  800359:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80035c:	5b                   	pop    %ebx
  80035d:	5e                   	pop    %esi
  80035e:	5f                   	pop    %edi
  80035f:	5d                   	pop    %ebp
  800360:	c3                   	ret    

00800361 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800361:	83 fa 01             	cmp    $0x1,%edx
  800364:	7f 13                	jg     800379 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800366:	85 d2                	test   %edx,%edx
  800368:	74 1c                	je     800386 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  80036a:	8b 10                	mov    (%eax),%edx
  80036c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80036f:	89 08                	mov    %ecx,(%eax)
  800371:	8b 02                	mov    (%edx),%eax
  800373:	ba 00 00 00 00       	mov    $0x0,%edx
  800378:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  800379:	8b 10                	mov    (%eax),%edx
  80037b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80037e:	89 08                	mov    %ecx,(%eax)
  800380:	8b 02                	mov    (%edx),%eax
  800382:	8b 52 04             	mov    0x4(%edx),%edx
  800385:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  800386:	8b 10                	mov    (%eax),%edx
  800388:	8d 4a 04             	lea    0x4(%edx),%ecx
  80038b:	89 08                	mov    %ecx,(%eax)
  80038d:	8b 02                	mov    (%edx),%eax
  80038f:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800394:	c3                   	ret    

00800395 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800395:	83 fa 01             	cmp    $0x1,%edx
  800398:	7f 0f                	jg     8003a9 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  80039a:	85 d2                	test   %edx,%edx
  80039c:	74 18                	je     8003b6 <getint+0x21>
		return va_arg(*ap, long);
  80039e:	8b 10                	mov    (%eax),%edx
  8003a0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a3:	89 08                	mov    %ecx,(%eax)
  8003a5:	8b 02                	mov    (%edx),%eax
  8003a7:	99                   	cltd   
  8003a8:	c3                   	ret    
		return va_arg(*ap, long long);
  8003a9:	8b 10                	mov    (%eax),%edx
  8003ab:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003ae:	89 08                	mov    %ecx,(%eax)
  8003b0:	8b 02                	mov    (%edx),%eax
  8003b2:	8b 52 04             	mov    0x4(%edx),%edx
  8003b5:	c3                   	ret    
	else
		return va_arg(*ap, int);
  8003b6:	8b 10                	mov    (%eax),%edx
  8003b8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003bb:	89 08                	mov    %ecx,(%eax)
  8003bd:	8b 02                	mov    (%edx),%eax
  8003bf:	99                   	cltd   
}
  8003c0:	c3                   	ret    

008003c1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003c1:	55                   	push   %ebp
  8003c2:	89 e5                	mov    %esp,%ebp
  8003c4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003c7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003cb:	8b 10                	mov    (%eax),%edx
  8003cd:	3b 50 04             	cmp    0x4(%eax),%edx
  8003d0:	73 0a                	jae    8003dc <sprintputch+0x1b>
		*b->buf++ = ch;
  8003d2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003d5:	89 08                	mov    %ecx,(%eax)
  8003d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003da:	88 02                	mov    %al,(%edx)
}
  8003dc:	5d                   	pop    %ebp
  8003dd:	c3                   	ret    

008003de <printfmt>:
{
  8003de:	55                   	push   %ebp
  8003df:	89 e5                	mov    %esp,%ebp
  8003e1:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8003e4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003e7:	50                   	push   %eax
  8003e8:	ff 75 10             	push   0x10(%ebp)
  8003eb:	ff 75 0c             	push   0xc(%ebp)
  8003ee:	ff 75 08             	push   0x8(%ebp)
  8003f1:	e8 05 00 00 00       	call   8003fb <vprintfmt>
}
  8003f6:	83 c4 10             	add    $0x10,%esp
  8003f9:	c9                   	leave  
  8003fa:	c3                   	ret    

008003fb <vprintfmt>:
{
  8003fb:	55                   	push   %ebp
  8003fc:	89 e5                	mov    %esp,%ebp
  8003fe:	57                   	push   %edi
  8003ff:	56                   	push   %esi
  800400:	53                   	push   %ebx
  800401:	83 ec 2c             	sub    $0x2c,%esp
  800404:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800407:	8b 75 0c             	mov    0xc(%ebp),%esi
  80040a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80040d:	eb 0a                	jmp    800419 <vprintfmt+0x1e>
			putch(ch, putdat);
  80040f:	83 ec 08             	sub    $0x8,%esp
  800412:	56                   	push   %esi
  800413:	50                   	push   %eax
  800414:	ff d3                	call   *%ebx
  800416:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800419:	83 c7 01             	add    $0x1,%edi
  80041c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800420:	83 f8 25             	cmp    $0x25,%eax
  800423:	74 0c                	je     800431 <vprintfmt+0x36>
			if (ch == '\0')
  800425:	85 c0                	test   %eax,%eax
  800427:	75 e6                	jne    80040f <vprintfmt+0x14>
}
  800429:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80042c:	5b                   	pop    %ebx
  80042d:	5e                   	pop    %esi
  80042e:	5f                   	pop    %edi
  80042f:	5d                   	pop    %ebp
  800430:	c3                   	ret    
		padc = ' ';
  800431:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
		altflag = 0;
  800435:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80043c:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800443:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80044a:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80044f:	8d 47 01             	lea    0x1(%edi),%eax
  800452:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800455:	0f b6 17             	movzbl (%edi),%edx
  800458:	8d 42 dd             	lea    -0x23(%edx),%eax
  80045b:	3c 55                	cmp    $0x55,%al
  80045d:	0f 87 b7 02 00 00    	ja     80071a <vprintfmt+0x31f>
  800463:	0f b6 c0             	movzbl %al,%eax
  800466:	ff 24 85 40 17 80 00 	jmp    *0x801740(,%eax,4)
  80046d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800470:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800474:	eb d9                	jmp    80044f <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800476:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800479:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  80047d:	eb d0                	jmp    80044f <vprintfmt+0x54>
  80047f:	0f b6 d2             	movzbl %dl,%edx
  800482:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0;; ++fmt) {
  800485:	b8 00 00 00 00       	mov    $0x0,%eax
  80048a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80048d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800490:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800494:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800497:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80049a:	83 f9 09             	cmp    $0x9,%ecx
  80049d:	77 52                	ja     8004f1 <vprintfmt+0xf6>
			for (precision = 0;; ++fmt) {
  80049f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8004a2:	eb e9                	jmp    80048d <vprintfmt+0x92>
			precision = va_arg(ap, int);
  8004a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a7:	8d 50 04             	lea    0x4(%eax),%edx
  8004aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ad:	8b 00                	mov    (%eax),%eax
  8004af:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8004b5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004b9:	79 94                	jns    80044f <vprintfmt+0x54>
				width = precision, precision = -1;
  8004bb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8004be:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c1:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8004c8:	eb 85                	jmp    80044f <vprintfmt+0x54>
  8004ca:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004cd:	85 d2                	test   %edx,%edx
  8004cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d4:	0f 49 c2             	cmovns %edx,%eax
  8004d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8004dd:	e9 6d ff ff ff       	jmp    80044f <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8004e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8004e5:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8004ec:	e9 5e ff ff ff       	jmp    80044f <vprintfmt+0x54>
  8004f1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004f4:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004f7:	eb bc                	jmp    8004b5 <vprintfmt+0xba>
			lflag++;
  8004f9:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8004fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8004ff:	e9 4b ff ff ff       	jmp    80044f <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800504:	8b 45 14             	mov    0x14(%ebp),%eax
  800507:	8d 50 04             	lea    0x4(%eax),%edx
  80050a:	89 55 14             	mov    %edx,0x14(%ebp)
  80050d:	83 ec 08             	sub    $0x8,%esp
  800510:	56                   	push   %esi
  800511:	ff 30                	push   (%eax)
  800513:	ff d3                	call   *%ebx
			break;
  800515:	83 c4 10             	add    $0x10,%esp
  800518:	e9 94 01 00 00       	jmp    8006b1 <vprintfmt+0x2b6>
			err = va_arg(ap, int);
  80051d:	8b 45 14             	mov    0x14(%ebp),%eax
  800520:	8d 50 04             	lea    0x4(%eax),%edx
  800523:	89 55 14             	mov    %edx,0x14(%ebp)
  800526:	8b 10                	mov    (%eax),%edx
  800528:	89 d0                	mov    %edx,%eax
  80052a:	f7 d8                	neg    %eax
  80052c:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80052f:	83 f8 08             	cmp    $0x8,%eax
  800532:	7f 20                	jg     800554 <vprintfmt+0x159>
  800534:	8b 14 85 a0 18 80 00 	mov    0x8018a0(,%eax,4),%edx
  80053b:	85 d2                	test   %edx,%edx
  80053d:	74 15                	je     800554 <vprintfmt+0x159>
				printfmt(putch, putdat, "%s", p);
  80053f:	52                   	push   %edx
  800540:	68 95 16 80 00       	push   $0x801695
  800545:	56                   	push   %esi
  800546:	53                   	push   %ebx
  800547:	e8 92 fe ff ff       	call   8003de <printfmt>
  80054c:	83 c4 10             	add    $0x10,%esp
  80054f:	e9 5d 01 00 00       	jmp    8006b1 <vprintfmt+0x2b6>
				printfmt(putch, putdat, "error %d", err);
  800554:	50                   	push   %eax
  800555:	68 8c 16 80 00       	push   $0x80168c
  80055a:	56                   	push   %esi
  80055b:	53                   	push   %ebx
  80055c:	e8 7d fe ff ff       	call   8003de <printfmt>
  800561:	83 c4 10             	add    $0x10,%esp
  800564:	e9 48 01 00 00       	jmp    8006b1 <vprintfmt+0x2b6>
			if ((p = va_arg(ap, char *)) == NULL)
  800569:	8b 45 14             	mov    0x14(%ebp),%eax
  80056c:	8d 50 04             	lea    0x4(%eax),%edx
  80056f:	89 55 14             	mov    %edx,0x14(%ebp)
  800572:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800574:	85 ff                	test   %edi,%edi
  800576:	b8 85 16 80 00       	mov    $0x801685,%eax
  80057b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80057e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800582:	7e 06                	jle    80058a <vprintfmt+0x18f>
  800584:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  800588:	75 0a                	jne    800594 <vprintfmt+0x199>
  80058a:	89 f8                	mov    %edi,%eax
  80058c:	03 45 e0             	add    -0x20(%ebp),%eax
  80058f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800592:	eb 59                	jmp    8005ed <vprintfmt+0x1f2>
				for (width -= strnlen(p, precision); width > 0;
  800594:	83 ec 08             	sub    $0x8,%esp
  800597:	ff 75 d8             	push   -0x28(%ebp)
  80059a:	57                   	push   %edi
  80059b:	e8 1a 02 00 00       	call   8007ba <strnlen>
  8005a0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005a3:	29 c1                	sub    %eax,%ecx
  8005a5:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005a8:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005ab:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  8005af:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005b2:	89 7d d0             	mov    %edi,-0x30(%ebp)
  8005b5:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0;
  8005b7:	eb 0f                	jmp    8005c8 <vprintfmt+0x1cd>
					putch(padc, putdat);
  8005b9:	83 ec 08             	sub    $0x8,%esp
  8005bc:	56                   	push   %esi
  8005bd:	ff 75 e0             	push   -0x20(%ebp)
  8005c0:	ff d3                	call   *%ebx
				     width--)
  8005c2:	83 ef 01             	sub    $0x1,%edi
  8005c5:	83 c4 10             	add    $0x10,%esp
				for (width -= strnlen(p, precision); width > 0;
  8005c8:	85 ff                	test   %edi,%edi
  8005ca:	7f ed                	jg     8005b9 <vprintfmt+0x1be>
  8005cc:	8b 7d d0             	mov    -0x30(%ebp),%edi
  8005cf:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005d2:	85 c9                	test   %ecx,%ecx
  8005d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8005d9:	0f 49 c1             	cmovns %ecx,%eax
  8005dc:	29 c1                	sub    %eax,%ecx
  8005de:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8005e1:	eb a7                	jmp    80058a <vprintfmt+0x18f>
					putch(ch, putdat);
  8005e3:	83 ec 08             	sub    $0x8,%esp
  8005e6:	56                   	push   %esi
  8005e7:	52                   	push   %edx
  8005e8:	ff d3                	call   *%ebx
  8005ea:	83 c4 10             	add    $0x10,%esp
  8005ed:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005f0:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' &&
  8005f2:	83 c7 01             	add    $0x1,%edi
  8005f5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005f9:	0f be d0             	movsbl %al,%edx
  8005fc:	85 d2                	test   %edx,%edx
  8005fe:	74 42                	je     800642 <vprintfmt+0x247>
  800600:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800604:	78 06                	js     80060c <vprintfmt+0x211>
			       (precision < 0 || --precision >= 0);
  800606:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80060a:	78 1e                	js     80062a <vprintfmt+0x22f>
				if (altflag && (ch < ' ' || ch > '~'))
  80060c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800610:	74 d1                	je     8005e3 <vprintfmt+0x1e8>
  800612:	0f be c0             	movsbl %al,%eax
  800615:	83 e8 20             	sub    $0x20,%eax
  800618:	83 f8 5e             	cmp    $0x5e,%eax
  80061b:	76 c6                	jbe    8005e3 <vprintfmt+0x1e8>
					putch('?', putdat);
  80061d:	83 ec 08             	sub    $0x8,%esp
  800620:	56                   	push   %esi
  800621:	6a 3f                	push   $0x3f
  800623:	ff d3                	call   *%ebx
  800625:	83 c4 10             	add    $0x10,%esp
  800628:	eb c3                	jmp    8005ed <vprintfmt+0x1f2>
  80062a:	89 cf                	mov    %ecx,%edi
  80062c:	eb 0e                	jmp    80063c <vprintfmt+0x241>
				putch(' ', putdat);
  80062e:	83 ec 08             	sub    $0x8,%esp
  800631:	56                   	push   %esi
  800632:	6a 20                	push   $0x20
  800634:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  800636:	83 ef 01             	sub    $0x1,%edi
  800639:	83 c4 10             	add    $0x10,%esp
  80063c:	85 ff                	test   %edi,%edi
  80063e:	7f ee                	jg     80062e <vprintfmt+0x233>
  800640:	eb 6f                	jmp    8006b1 <vprintfmt+0x2b6>
  800642:	89 cf                	mov    %ecx,%edi
  800644:	eb f6                	jmp    80063c <vprintfmt+0x241>
			num = getint(&ap, lflag);
  800646:	89 ca                	mov    %ecx,%edx
  800648:	8d 45 14             	lea    0x14(%ebp),%eax
  80064b:	e8 45 fd ff ff       	call   800395 <getint>
  800650:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800653:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800656:	85 d2                	test   %edx,%edx
  800658:	78 0b                	js     800665 <vprintfmt+0x26a>
			num = getint(&ap, lflag);
  80065a:	89 d1                	mov    %edx,%ecx
  80065c:	89 c2                	mov    %eax,%edx
			base = 10;
  80065e:	bf 0a 00 00 00       	mov    $0xa,%edi
  800663:	eb 32                	jmp    800697 <vprintfmt+0x29c>
				putch('-', putdat);
  800665:	83 ec 08             	sub    $0x8,%esp
  800668:	56                   	push   %esi
  800669:	6a 2d                	push   $0x2d
  80066b:	ff d3                	call   *%ebx
				num = -(long long) num;
  80066d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800670:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800673:	f7 da                	neg    %edx
  800675:	83 d1 00             	adc    $0x0,%ecx
  800678:	f7 d9                	neg    %ecx
  80067a:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80067d:	bf 0a 00 00 00       	mov    $0xa,%edi
  800682:	eb 13                	jmp    800697 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  800684:	89 ca                	mov    %ecx,%edx
  800686:	8d 45 14             	lea    0x14(%ebp),%eax
  800689:	e8 d3 fc ff ff       	call   800361 <getuint>
  80068e:	89 d1                	mov    %edx,%ecx
  800690:	89 c2                	mov    %eax,%edx
			base = 10;
  800692:	bf 0a 00 00 00       	mov    $0xa,%edi
			printnum(putch, putdat, num, base, width, padc);
  800697:	83 ec 0c             	sub    $0xc,%esp
  80069a:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  80069e:	50                   	push   %eax
  80069f:	ff 75 e0             	push   -0x20(%ebp)
  8006a2:	57                   	push   %edi
  8006a3:	51                   	push   %ecx
  8006a4:	52                   	push   %edx
  8006a5:	89 f2                	mov    %esi,%edx
  8006a7:	89 d8                	mov    %ebx,%eax
  8006a9:	e8 0a fc ff ff       	call   8002b8 <printnum>
			break;
  8006ae:	83 c4 20             	add    $0x20,%esp
{
  8006b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006b4:	e9 60 fd ff ff       	jmp    800419 <vprintfmt+0x1e>
			num = getuint(&ap, lflag);
  8006b9:	89 ca                	mov    %ecx,%edx
  8006bb:	8d 45 14             	lea    0x14(%ebp),%eax
  8006be:	e8 9e fc ff ff       	call   800361 <getuint>
  8006c3:	89 d1                	mov    %edx,%ecx
  8006c5:	89 c2                	mov    %eax,%edx
			base = 8;
  8006c7:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  8006cc:	eb c9                	jmp    800697 <vprintfmt+0x29c>
			putch('0', putdat);
  8006ce:	83 ec 08             	sub    $0x8,%esp
  8006d1:	56                   	push   %esi
  8006d2:	6a 30                	push   $0x30
  8006d4:	ff d3                	call   *%ebx
			putch('x', putdat);
  8006d6:	83 c4 08             	add    $0x8,%esp
  8006d9:	56                   	push   %esi
  8006da:	6a 78                	push   $0x78
  8006dc:	ff d3                	call   *%ebx
			num = (unsigned long long) (uintptr_t) va_arg(ap, void *);
  8006de:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e1:	8d 50 04             	lea    0x4(%eax),%edx
  8006e4:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e7:	8b 10                	mov    (%eax),%edx
  8006e9:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006ee:	83 c4 10             	add    $0x10,%esp
			base = 16;
  8006f1:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  8006f6:	eb 9f                	jmp    800697 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  8006f8:	89 ca                	mov    %ecx,%edx
  8006fa:	8d 45 14             	lea    0x14(%ebp),%eax
  8006fd:	e8 5f fc ff ff       	call   800361 <getuint>
  800702:	89 d1                	mov    %edx,%ecx
  800704:	89 c2                	mov    %eax,%edx
			base = 16;
  800706:	bf 10 00 00 00       	mov    $0x10,%edi
  80070b:	eb 8a                	jmp    800697 <vprintfmt+0x29c>
			putch(ch, putdat);
  80070d:	83 ec 08             	sub    $0x8,%esp
  800710:	56                   	push   %esi
  800711:	6a 25                	push   $0x25
  800713:	ff d3                	call   *%ebx
			break;
  800715:	83 c4 10             	add    $0x10,%esp
  800718:	eb 97                	jmp    8006b1 <vprintfmt+0x2b6>
			putch('%', putdat);
  80071a:	83 ec 08             	sub    $0x8,%esp
  80071d:	56                   	push   %esi
  80071e:	6a 25                	push   $0x25
  800720:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  800722:	83 c4 10             	add    $0x10,%esp
  800725:	89 f8                	mov    %edi,%eax
  800727:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80072b:	74 05                	je     800732 <vprintfmt+0x337>
  80072d:	83 e8 01             	sub    $0x1,%eax
  800730:	eb f5                	jmp    800727 <vprintfmt+0x32c>
  800732:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800735:	e9 77 ff ff ff       	jmp    8006b1 <vprintfmt+0x2b6>

0080073a <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80073a:	55                   	push   %ebp
  80073b:	89 e5                	mov    %esp,%ebp
  80073d:	83 ec 18             	sub    $0x18,%esp
  800740:	8b 45 08             	mov    0x8(%ebp),%eax
  800743:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = { buf, buf + n - 1, 0 };
  800746:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800749:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80074d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800750:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800757:	85 c0                	test   %eax,%eax
  800759:	74 26                	je     800781 <vsnprintf+0x47>
  80075b:	85 d2                	test   %edx,%edx
  80075d:	7e 22                	jle    800781 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *) sprintputch, &b, fmt, ap);
  80075f:	ff 75 14             	push   0x14(%ebp)
  800762:	ff 75 10             	push   0x10(%ebp)
  800765:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800768:	50                   	push   %eax
  800769:	68 c1 03 80 00       	push   $0x8003c1
  80076e:	e8 88 fc ff ff       	call   8003fb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800773:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800776:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800779:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80077c:	83 c4 10             	add    $0x10,%esp
}
  80077f:	c9                   	leave  
  800780:	c3                   	ret    
		return -E_INVAL;
  800781:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800786:	eb f7                	jmp    80077f <vsnprintf+0x45>

00800788 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
  80078b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80078e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800791:	50                   	push   %eax
  800792:	ff 75 10             	push   0x10(%ebp)
  800795:	ff 75 0c             	push   0xc(%ebp)
  800798:	ff 75 08             	push   0x8(%ebp)
  80079b:	e8 9a ff ff ff       	call   80073a <vsnprintf>
	va_end(ap);

	return rc;
}
  8007a0:	c9                   	leave  
  8007a1:	c3                   	ret    

008007a2 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007a2:	55                   	push   %ebp
  8007a3:	89 e5                	mov    %esp,%ebp
  8007a5:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ad:	eb 03                	jmp    8007b2 <strlen+0x10>
		n++;
  8007af:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007b2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007b6:	75 f7                	jne    8007af <strlen+0xd>
	return n;
}
  8007b8:	5d                   	pop    %ebp
  8007b9:	c3                   	ret    

008007ba <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007ba:	55                   	push   %ebp
  8007bb:	89 e5                	mov    %esp,%ebp
  8007bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c0:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c8:	eb 03                	jmp    8007cd <strnlen+0x13>
		n++;
  8007ca:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007cd:	39 d0                	cmp    %edx,%eax
  8007cf:	74 08                	je     8007d9 <strnlen+0x1f>
  8007d1:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007d5:	75 f3                	jne    8007ca <strnlen+0x10>
  8007d7:	89 c2                	mov    %eax,%edx
	return n;
}
  8007d9:	89 d0                	mov    %edx,%eax
  8007db:	5d                   	pop    %ebp
  8007dc:	c3                   	ret    

008007dd <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007dd:	55                   	push   %ebp
  8007de:	89 e5                	mov    %esp,%ebp
  8007e0:	53                   	push   %ebx
  8007e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ec:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007f0:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007f3:	83 c0 01             	add    $0x1,%eax
  8007f6:	84 d2                	test   %dl,%dl
  8007f8:	75 f2                	jne    8007ec <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007fa:	89 c8                	mov    %ecx,%eax
  8007fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007ff:	c9                   	leave  
  800800:	c3                   	ret    

00800801 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800801:	55                   	push   %ebp
  800802:	89 e5                	mov    %esp,%ebp
  800804:	53                   	push   %ebx
  800805:	83 ec 10             	sub    $0x10,%esp
  800808:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80080b:	53                   	push   %ebx
  80080c:	e8 91 ff ff ff       	call   8007a2 <strlen>
  800811:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800814:	ff 75 0c             	push   0xc(%ebp)
  800817:	01 d8                	add    %ebx,%eax
  800819:	50                   	push   %eax
  80081a:	e8 be ff ff ff       	call   8007dd <strcpy>
	return dst;
}
  80081f:	89 d8                	mov    %ebx,%eax
  800821:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800824:	c9                   	leave  
  800825:	c3                   	ret    

00800826 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size)
{
  800826:	55                   	push   %ebp
  800827:	89 e5                	mov    %esp,%ebp
  800829:	56                   	push   %esi
  80082a:	53                   	push   %ebx
  80082b:	8b 75 08             	mov    0x8(%ebp),%esi
  80082e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800831:	89 f3                	mov    %esi,%ebx
  800833:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800836:	89 f0                	mov    %esi,%eax
  800838:	eb 0f                	jmp    800849 <strncpy+0x23>
		*dst++ = *src;
  80083a:	83 c0 01             	add    $0x1,%eax
  80083d:	0f b6 0a             	movzbl (%edx),%ecx
  800840:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800843:	80 f9 01             	cmp    $0x1,%cl
  800846:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800849:	39 d8                	cmp    %ebx,%eax
  80084b:	75 ed                	jne    80083a <strncpy+0x14>
	}
	return ret;
}
  80084d:	89 f0                	mov    %esi,%eax
  80084f:	5b                   	pop    %ebx
  800850:	5e                   	pop    %esi
  800851:	5d                   	pop    %ebp
  800852:	c3                   	ret    

00800853 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800853:	55                   	push   %ebp
  800854:	89 e5                	mov    %esp,%ebp
  800856:	56                   	push   %esi
  800857:	53                   	push   %ebx
  800858:	8b 75 08             	mov    0x8(%ebp),%esi
  80085b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80085e:	8b 55 10             	mov    0x10(%ebp),%edx
  800861:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800863:	85 d2                	test   %edx,%edx
  800865:	74 21                	je     800888 <strlcpy+0x35>
  800867:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80086b:	89 f2                	mov    %esi,%edx
  80086d:	eb 09                	jmp    800878 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80086f:	83 c1 01             	add    $0x1,%ecx
  800872:	83 c2 01             	add    $0x1,%edx
  800875:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800878:	39 c2                	cmp    %eax,%edx
  80087a:	74 09                	je     800885 <strlcpy+0x32>
  80087c:	0f b6 19             	movzbl (%ecx),%ebx
  80087f:	84 db                	test   %bl,%bl
  800881:	75 ec                	jne    80086f <strlcpy+0x1c>
  800883:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800885:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800888:	29 f0                	sub    %esi,%eax
}
  80088a:	5b                   	pop    %ebx
  80088b:	5e                   	pop    %esi
  80088c:	5d                   	pop    %ebp
  80088d:	c3                   	ret    

0080088e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80088e:	55                   	push   %ebp
  80088f:	89 e5                	mov    %esp,%ebp
  800891:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800894:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800897:	eb 06                	jmp    80089f <strcmp+0x11>
		p++, q++;
  800899:	83 c1 01             	add    $0x1,%ecx
  80089c:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80089f:	0f b6 01             	movzbl (%ecx),%eax
  8008a2:	84 c0                	test   %al,%al
  8008a4:	74 04                	je     8008aa <strcmp+0x1c>
  8008a6:	3a 02                	cmp    (%edx),%al
  8008a8:	74 ef                	je     800899 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008aa:	0f b6 c0             	movzbl %al,%eax
  8008ad:	0f b6 12             	movzbl (%edx),%edx
  8008b0:	29 d0                	sub    %edx,%eax
}
  8008b2:	5d                   	pop    %ebp
  8008b3:	c3                   	ret    

008008b4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008b4:	55                   	push   %ebp
  8008b5:	89 e5                	mov    %esp,%ebp
  8008b7:	53                   	push   %ebx
  8008b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008be:	89 c3                	mov    %eax,%ebx
  8008c0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008c3:	eb 06                	jmp    8008cb <strncmp+0x17>
		n--, p++, q++;
  8008c5:	83 c0 01             	add    $0x1,%eax
  8008c8:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008cb:	39 d8                	cmp    %ebx,%eax
  8008cd:	74 18                	je     8008e7 <strncmp+0x33>
  8008cf:	0f b6 08             	movzbl (%eax),%ecx
  8008d2:	84 c9                	test   %cl,%cl
  8008d4:	74 04                	je     8008da <strncmp+0x26>
  8008d6:	3a 0a                	cmp    (%edx),%cl
  8008d8:	74 eb                	je     8008c5 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008da:	0f b6 00             	movzbl (%eax),%eax
  8008dd:	0f b6 12             	movzbl (%edx),%edx
  8008e0:	29 d0                	sub    %edx,%eax
}
  8008e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e5:	c9                   	leave  
  8008e6:	c3                   	ret    
		return 0;
  8008e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ec:	eb f4                	jmp    8008e2 <strncmp+0x2e>

008008ee <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008ee:	55                   	push   %ebp
  8008ef:	89 e5                	mov    %esp,%ebp
  8008f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008f8:	eb 03                	jmp    8008fd <strchr+0xf>
  8008fa:	83 c0 01             	add    $0x1,%eax
  8008fd:	0f b6 10             	movzbl (%eax),%edx
  800900:	84 d2                	test   %dl,%dl
  800902:	74 06                	je     80090a <strchr+0x1c>
		if (*s == c)
  800904:	38 ca                	cmp    %cl,%dl
  800906:	75 f2                	jne    8008fa <strchr+0xc>
  800908:	eb 05                	jmp    80090f <strchr+0x21>
			return (char *) s;
	return 0;
  80090a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80090f:	5d                   	pop    %ebp
  800910:	c3                   	ret    

00800911 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800911:	55                   	push   %ebp
  800912:	89 e5                	mov    %esp,%ebp
  800914:	8b 45 08             	mov    0x8(%ebp),%eax
  800917:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80091b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80091e:	38 ca                	cmp    %cl,%dl
  800920:	74 09                	je     80092b <strfind+0x1a>
  800922:	84 d2                	test   %dl,%dl
  800924:	74 05                	je     80092b <strfind+0x1a>
	for (; *s; s++)
  800926:	83 c0 01             	add    $0x1,%eax
  800929:	eb f0                	jmp    80091b <strfind+0xa>
			break;
	return (char *) s;
}
  80092b:	5d                   	pop    %ebp
  80092c:	c3                   	ret    

0080092d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80092d:	55                   	push   %ebp
  80092e:	89 e5                	mov    %esp,%ebp
  800930:	57                   	push   %edi
  800931:	56                   	push   %esi
  800932:	53                   	push   %ebx
  800933:	8b 55 08             	mov    0x8(%ebp),%edx
  800936:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  800939:	85 c9                	test   %ecx,%ecx
  80093b:	74 33                	je     800970 <memset+0x43>
		return v;
	if ((int) v % 4 == 0 && n % 4 == 0) {
  80093d:	89 d0                	mov    %edx,%eax
  80093f:	09 c8                	or     %ecx,%eax
  800941:	a8 03                	test   $0x3,%al
  800943:	75 23                	jne    800968 <memset+0x3b>
		c &= 0xFF;
  800945:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  800949:	89 d8                	mov    %ebx,%eax
  80094b:	c1 e0 08             	shl    $0x8,%eax
  80094e:	89 df                	mov    %ebx,%edi
  800950:	c1 e7 18             	shl    $0x18,%edi
  800953:	89 de                	mov    %ebx,%esi
  800955:	c1 e6 10             	shl    $0x10,%esi
  800958:	09 f7                	or     %esi,%edi
  80095a:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
		             : "=D"(p), "=c"(n)
		             : "D"(p), "a"(c), "c"(n / 4)
  80095c:	c1 e9 02             	shr    $0x2,%ecx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  80095f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800961:	89 d7                	mov    %edx,%edi
  800963:	fc                   	cld    
  800964:	f3 ab                	rep stos %eax,%es:(%edi)
  800966:	eb 08                	jmp    800970 <memset+0x43>
		             : "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800968:	89 d7                	mov    %edx,%edi
  80096a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80096d:	fc                   	cld    
  80096e:	f3 aa                	rep stos %al,%es:(%edi)
		             : "=D"(p), "=c"(n)
		             : "0"(p), "a"(c), "1"(n)
		             : "cc", "memory");
	return v;
}
  800970:	89 d0                	mov    %edx,%eax
  800972:	5b                   	pop    %ebx
  800973:	5e                   	pop    %esi
  800974:	5f                   	pop    %edi
  800975:	5d                   	pop    %ebp
  800976:	c3                   	ret    

00800977 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800977:	55                   	push   %ebp
  800978:	89 e5                	mov    %esp,%ebp
  80097a:	57                   	push   %edi
  80097b:	56                   	push   %esi
  80097c:	8b 45 08             	mov    0x8(%ebp),%eax
  80097f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800982:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800985:	39 c6                	cmp    %eax,%esi
  800987:	73 32                	jae    8009bb <memmove+0x44>
  800989:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80098c:	39 c2                	cmp    %eax,%edx
  80098e:	76 2b                	jbe    8009bb <memmove+0x44>
		s += n;
		d += n;
  800990:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  800993:	89 d6                	mov    %edx,%esi
  800995:	09 fe                	or     %edi,%esi
  800997:	09 ce                	or     %ecx,%esi
  800999:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80099f:	75 0e                	jne    8009af <memmove+0x38>
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  8009a1:	83 ef 04             	sub    $0x4,%edi
			             "S"(s - 4),
  8009a4:	8d 72 fc             	lea    -0x4(%edx),%esi
			             "c"(n / 4)
  8009a7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  8009aa:	fd                   	std    
  8009ab:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ad:	eb 09                	jmp    8009b8 <memmove+0x41>
			             : "cc", "memory");
		else
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  8009af:	83 ef 01             	sub    $0x1,%edi
			             "S"(s - 1),
  8009b2:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  8009b5:	fd                   	std    
  8009b6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             "c"(n)
			             : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009b8:	fc                   	cld    
  8009b9:	eb 1a                	jmp    8009d5 <memmove+0x5e>
	} else {
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  8009bb:	89 f2                	mov    %esi,%edx
  8009bd:	09 c2                	or     %eax,%edx
  8009bf:	09 ca                	or     %ecx,%edx
  8009c1:	f6 c2 03             	test   $0x3,%dl
  8009c4:	75 0a                	jne    8009d0 <memmove+0x59>
			asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  8009c6:	c1 e9 02             	shr    $0x2,%ecx
  8009c9:	89 c7                	mov    %eax,%edi
  8009cb:	fc                   	cld    
  8009cc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ce:	eb 05                	jmp    8009d5 <memmove+0x5e>
			             : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  8009d0:	89 c7                	mov    %eax,%edi
  8009d2:	fc                   	cld    
  8009d3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             : "cc", "memory");
	}
	return dst;
}
  8009d5:	5e                   	pop    %esi
  8009d6:	5f                   	pop    %edi
  8009d7:	5d                   	pop    %ebp
  8009d8:	c3                   	ret    

008009d9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009d9:	55                   	push   %ebp
  8009da:	89 e5                	mov    %esp,%ebp
  8009dc:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009df:	ff 75 10             	push   0x10(%ebp)
  8009e2:	ff 75 0c             	push   0xc(%ebp)
  8009e5:	ff 75 08             	push   0x8(%ebp)
  8009e8:	e8 8a ff ff ff       	call   800977 <memmove>
}
  8009ed:	c9                   	leave  
  8009ee:	c3                   	ret    

008009ef <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009ef:	55                   	push   %ebp
  8009f0:	89 e5                	mov    %esp,%ebp
  8009f2:	56                   	push   %esi
  8009f3:	53                   	push   %ebx
  8009f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009fa:	89 c6                	mov    %eax,%esi
  8009fc:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ff:	eb 06                	jmp    800a07 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a01:	83 c0 01             	add    $0x1,%eax
  800a04:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800a07:	39 f0                	cmp    %esi,%eax
  800a09:	74 14                	je     800a1f <memcmp+0x30>
		if (*s1 != *s2)
  800a0b:	0f b6 08             	movzbl (%eax),%ecx
  800a0e:	0f b6 1a             	movzbl (%edx),%ebx
  800a11:	38 d9                	cmp    %bl,%cl
  800a13:	74 ec                	je     800a01 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800a15:	0f b6 c1             	movzbl %cl,%eax
  800a18:	0f b6 db             	movzbl %bl,%ebx
  800a1b:	29 d8                	sub    %ebx,%eax
  800a1d:	eb 05                	jmp    800a24 <memcmp+0x35>
	}

	return 0;
  800a1f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a24:	5b                   	pop    %ebx
  800a25:	5e                   	pop    %esi
  800a26:	5d                   	pop    %ebp
  800a27:	c3                   	ret    

00800a28 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a28:	55                   	push   %ebp
  800a29:	89 e5                	mov    %esp,%ebp
  800a2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a31:	89 c2                	mov    %eax,%edx
  800a33:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a36:	eb 03                	jmp    800a3b <memfind+0x13>
  800a38:	83 c0 01             	add    $0x1,%eax
  800a3b:	39 d0                	cmp    %edx,%eax
  800a3d:	73 04                	jae    800a43 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a3f:	38 08                	cmp    %cl,(%eax)
  800a41:	75 f5                	jne    800a38 <memfind+0x10>
			break;
	return (void *) s;
}
  800a43:	5d                   	pop    %ebp
  800a44:	c3                   	ret    

00800a45 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a45:	55                   	push   %ebp
  800a46:	89 e5                	mov    %esp,%ebp
  800a48:	57                   	push   %edi
  800a49:	56                   	push   %esi
  800a4a:	53                   	push   %ebx
  800a4b:	8b 55 08             	mov    0x8(%ebp),%edx
  800a4e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a51:	eb 03                	jmp    800a56 <strtol+0x11>
		s++;
  800a53:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800a56:	0f b6 02             	movzbl (%edx),%eax
  800a59:	3c 20                	cmp    $0x20,%al
  800a5b:	74 f6                	je     800a53 <strtol+0xe>
  800a5d:	3c 09                	cmp    $0x9,%al
  800a5f:	74 f2                	je     800a53 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a61:	3c 2b                	cmp    $0x2b,%al
  800a63:	74 2a                	je     800a8f <strtol+0x4a>
	int neg = 0;
  800a65:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a6a:	3c 2d                	cmp    $0x2d,%al
  800a6c:	74 2b                	je     800a99 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a6e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a74:	75 0f                	jne    800a85 <strtol+0x40>
  800a76:	80 3a 30             	cmpb   $0x30,(%edx)
  800a79:	74 28                	je     800aa3 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a7b:	85 db                	test   %ebx,%ebx
  800a7d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a82:	0f 44 d8             	cmove  %eax,%ebx
  800a85:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a8a:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a8d:	eb 46                	jmp    800ad5 <strtol+0x90>
		s++;
  800a8f:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800a92:	bf 00 00 00 00       	mov    $0x0,%edi
  800a97:	eb d5                	jmp    800a6e <strtol+0x29>
		s++, neg = 1;
  800a99:	83 c2 01             	add    $0x1,%edx
  800a9c:	bf 01 00 00 00       	mov    $0x1,%edi
  800aa1:	eb cb                	jmp    800a6e <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aa3:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800aa7:	74 0e                	je     800ab7 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800aa9:	85 db                	test   %ebx,%ebx
  800aab:	75 d8                	jne    800a85 <strtol+0x40>
		s++, base = 8;
  800aad:	83 c2 01             	add    $0x1,%edx
  800ab0:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ab5:	eb ce                	jmp    800a85 <strtol+0x40>
		s += 2, base = 16;
  800ab7:	83 c2 02             	add    $0x2,%edx
  800aba:	bb 10 00 00 00       	mov    $0x10,%ebx
  800abf:	eb c4                	jmp    800a85 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800ac1:	0f be c0             	movsbl %al,%eax
  800ac4:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ac7:	3b 45 10             	cmp    0x10(%ebp),%eax
  800aca:	7d 3a                	jge    800b06 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800acc:	83 c2 01             	add    $0x1,%edx
  800acf:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800ad3:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800ad5:	0f b6 02             	movzbl (%edx),%eax
  800ad8:	8d 70 d0             	lea    -0x30(%eax),%esi
  800adb:	89 f3                	mov    %esi,%ebx
  800add:	80 fb 09             	cmp    $0x9,%bl
  800ae0:	76 df                	jbe    800ac1 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800ae2:	8d 70 9f             	lea    -0x61(%eax),%esi
  800ae5:	89 f3                	mov    %esi,%ebx
  800ae7:	80 fb 19             	cmp    $0x19,%bl
  800aea:	77 08                	ja     800af4 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800aec:	0f be c0             	movsbl %al,%eax
  800aef:	83 e8 57             	sub    $0x57,%eax
  800af2:	eb d3                	jmp    800ac7 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800af4:	8d 70 bf             	lea    -0x41(%eax),%esi
  800af7:	89 f3                	mov    %esi,%ebx
  800af9:	80 fb 19             	cmp    $0x19,%bl
  800afc:	77 08                	ja     800b06 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800afe:	0f be c0             	movsbl %al,%eax
  800b01:	83 e8 37             	sub    $0x37,%eax
  800b04:	eb c1                	jmp    800ac7 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b06:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b0a:	74 05                	je     800b11 <strtol+0xcc>
		*endptr = (char *) s;
  800b0c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b0f:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800b11:	89 c8                	mov    %ecx,%eax
  800b13:	f7 d8                	neg    %eax
  800b15:	85 ff                	test   %edi,%edi
  800b17:	0f 45 c8             	cmovne %eax,%ecx
}
  800b1a:	89 c8                	mov    %ecx,%eax
  800b1c:	5b                   	pop    %ebx
  800b1d:	5e                   	pop    %esi
  800b1e:	5f                   	pop    %edi
  800b1f:	5d                   	pop    %ebp
  800b20:	c3                   	ret    

00800b21 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b21:	55                   	push   %ebp
  800b22:	89 e5                	mov    %esp,%ebp
  800b24:	57                   	push   %edi
  800b25:	56                   	push   %esi
  800b26:	53                   	push   %ebx
  800b27:	83 ec 1c             	sub    $0x1c,%esp
  800b2a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b2d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800b30:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile(
  800b32:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b35:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b38:	8b 7d 10             	mov    0x10(%ebp),%edi
  800b3b:	8b 75 14             	mov    0x14(%ebp),%esi
  800b3e:	cd 30                	int    $0x30
	        "int %1\n"
	        : "=a"(ret)
	        : "i"(T_SYSCALL), "a"(num), "d"(a1), "c"(a2), "b"(a3), "D"(a4), "S"(a5)
	        : "cc", "memory");

	if (check && ret > 0)
  800b40:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800b44:	74 04                	je     800b4a <syscall+0x29>
  800b46:	85 c0                	test   %eax,%eax
  800b48:	7f 08                	jg     800b52 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800b4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b4d:	5b                   	pop    %ebx
  800b4e:	5e                   	pop    %esi
  800b4f:	5f                   	pop    %edi
  800b50:	5d                   	pop    %ebp
  800b51:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b52:	83 ec 0c             	sub    $0xc,%esp
  800b55:	50                   	push   %eax
  800b56:	ff 75 e0             	push   -0x20(%ebp)
  800b59:	68 c4 18 80 00       	push   $0x8018c4
  800b5e:	6a 1e                	push   $0x1e
  800b60:	68 e1 18 80 00       	push   $0x8018e1
  800b65:	e8 5c 07 00 00       	call   8012c6 <_panic>

00800b6a <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800b6a:	55                   	push   %ebp
  800b6b:	89 e5                	mov    %esp,%ebp
  800b6d:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t) s, len, 0, 0, 0);
  800b70:	6a 00                	push   $0x0
  800b72:	6a 00                	push   $0x0
  800b74:	6a 00                	push   $0x0
  800b76:	ff 75 0c             	push   0xc(%ebp)
  800b79:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b7c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b81:	b8 00 00 00 00       	mov    $0x0,%eax
  800b86:	e8 96 ff ff ff       	call   800b21 <syscall>
}
  800b8b:	83 c4 10             	add    $0x10,%esp
  800b8e:	c9                   	leave  
  800b8f:	c3                   	ret    

00800b90 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b90:	55                   	push   %ebp
  800b91:	89 e5                	mov    %esp,%ebp
  800b93:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800b96:	6a 00                	push   $0x0
  800b98:	6a 00                	push   $0x0
  800b9a:	6a 00                	push   $0x0
  800b9c:	6a 00                	push   $0x0
  800b9e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ba3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba8:	b8 01 00 00 00       	mov    $0x1,%eax
  800bad:	e8 6f ff ff ff       	call   800b21 <syscall>
}
  800bb2:	c9                   	leave  
  800bb3:	c3                   	ret    

00800bb4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bb4:	55                   	push   %ebp
  800bb5:	89 e5                	mov    %esp,%ebp
  800bb7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800bba:	6a 00                	push   $0x0
  800bbc:	6a 00                	push   $0x0
  800bbe:	6a 00                	push   $0x0
  800bc0:	6a 00                	push   $0x0
  800bc2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bc5:	ba 01 00 00 00       	mov    $0x1,%edx
  800bca:	b8 03 00 00 00       	mov    $0x3,%eax
  800bcf:	e8 4d ff ff ff       	call   800b21 <syscall>
}
  800bd4:	c9                   	leave  
  800bd5:	c3                   	ret    

00800bd6 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800bdc:	6a 00                	push   $0x0
  800bde:	6a 00                	push   $0x0
  800be0:	6a 00                	push   $0x0
  800be2:	6a 00                	push   $0x0
  800be4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800be9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bee:	b8 02 00 00 00       	mov    $0x2,%eax
  800bf3:	e8 29 ff ff ff       	call   800b21 <syscall>
}
  800bf8:	c9                   	leave  
  800bf9:	c3                   	ret    

00800bfa <sys_yield>:

void
sys_yield(void)
{
  800bfa:	55                   	push   %ebp
  800bfb:	89 e5                	mov    %esp,%ebp
  800bfd:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800c00:	6a 00                	push   $0x0
  800c02:	6a 00                	push   $0x0
  800c04:	6a 00                	push   $0x0
  800c06:	6a 00                	push   $0x0
  800c08:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c0d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c12:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c17:	e8 05 ff ff ff       	call   800b21 <syscall>
}
  800c1c:	83 c4 10             	add    $0x10,%esp
  800c1f:	c9                   	leave  
  800c20:	c3                   	ret    

00800c21 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c21:	55                   	push   %ebp
  800c22:	89 e5                	mov    %esp,%ebp
  800c24:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800c27:	6a 00                	push   $0x0
  800c29:	6a 00                	push   $0x0
  800c2b:	ff 75 10             	push   0x10(%ebp)
  800c2e:	ff 75 0c             	push   0xc(%ebp)
  800c31:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c34:	ba 01 00 00 00       	mov    $0x1,%edx
  800c39:	b8 04 00 00 00       	mov    $0x4,%eax
  800c3e:	e8 de fe ff ff       	call   800b21 <syscall>
}
  800c43:	c9                   	leave  
  800c44:	c3                   	ret    

00800c45 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map,
  800c4b:	ff 75 18             	push   0x18(%ebp)
  800c4e:	ff 75 14             	push   0x14(%ebp)
  800c51:	ff 75 10             	push   0x10(%ebp)
  800c54:	ff 75 0c             	push   0xc(%ebp)
  800c57:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c5a:	ba 01 00 00 00       	mov    $0x1,%edx
  800c5f:	b8 05 00 00 00       	mov    $0x5,%eax
  800c64:	e8 b8 fe ff ff       	call   800b21 <syscall>
	               srcenv,
	               (uint32_t) srcva,
	               dstenv,
	               (uint32_t) dstva,
	               perm);
}
  800c69:	c9                   	leave  
  800c6a:	c3                   	ret    

00800c6b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800c71:	6a 00                	push   $0x0
  800c73:	6a 00                	push   $0x0
  800c75:	6a 00                	push   $0x0
  800c77:	ff 75 0c             	push   0xc(%ebp)
  800c7a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c7d:	ba 01 00 00 00       	mov    $0x1,%edx
  800c82:	b8 06 00 00 00       	mov    $0x6,%eax
  800c87:	e8 95 fe ff ff       	call   800b21 <syscall>
}
  800c8c:	c9                   	leave  
  800c8d:	c3                   	ret    

00800c8e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c8e:	55                   	push   %ebp
  800c8f:	89 e5                	mov    %esp,%ebp
  800c91:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800c94:	6a 00                	push   $0x0
  800c96:	6a 00                	push   $0x0
  800c98:	6a 00                	push   $0x0
  800c9a:	ff 75 0c             	push   0xc(%ebp)
  800c9d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ca0:	ba 01 00 00 00       	mov    $0x1,%edx
  800ca5:	b8 08 00 00 00       	mov    $0x8,%eax
  800caa:	e8 72 fe ff ff       	call   800b21 <syscall>
}
  800caf:	c9                   	leave  
  800cb0:	c3                   	ret    

00800cb1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cb1:	55                   	push   %ebp
  800cb2:	89 e5                	mov    %esp,%ebp
  800cb4:	83 ec 08             	sub    $0x8,%esp
	return syscall(
  800cb7:	6a 00                	push   $0x0
  800cb9:	6a 00                	push   $0x0
  800cbb:	6a 00                	push   $0x0
  800cbd:	ff 75 0c             	push   0xc(%ebp)
  800cc0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cc3:	ba 01 00 00 00       	mov    $0x1,%edx
  800cc8:	b8 09 00 00 00       	mov    $0x9,%eax
  800ccd:	e8 4f fe ff ff       	call   800b21 <syscall>
	        SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cd2:	c9                   	leave  
  800cd3:	c3                   	ret    

00800cd4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cd4:	55                   	push   %ebp
  800cd5:	89 e5                	mov    %esp,%ebp
  800cd7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800cda:	6a 00                	push   $0x0
  800cdc:	ff 75 14             	push   0x14(%ebp)
  800cdf:	ff 75 10             	push   0x10(%ebp)
  800ce2:	ff 75 0c             	push   0xc(%ebp)
  800ce5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ce8:	ba 00 00 00 00       	mov    $0x0,%edx
  800ced:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cf2:	e8 2a fe ff ff       	call   800b21 <syscall>
}
  800cf7:	c9                   	leave  
  800cf8:	c3                   	ret    

00800cf9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cf9:	55                   	push   %ebp
  800cfa:	89 e5                	mov    %esp,%ebp
  800cfc:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t) dstva, 0, 0, 0, 0);
  800cff:	6a 00                	push   $0x0
  800d01:	6a 00                	push   $0x0
  800d03:	6a 00                	push   $0x0
  800d05:	6a 00                	push   $0x0
  800d07:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d0a:	ba 01 00 00 00       	mov    $0x1,%edx
  800d0f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d14:	e8 08 fe ff ff       	call   800b21 <syscall>
}
  800d19:	c9                   	leave  
  800d1a:	c3                   	ret    

00800d1b <sys_get_priority>:

// Get priority of the current process
int
sys_get_priority(void)
{
  800d1b:	55                   	push   %ebp
  800d1c:	89 e5                	mov    %esp,%ebp
  800d1e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_get_priority, 0, 0, 0, 0, 0, 0);
  800d21:	6a 00                	push   $0x0
  800d23:	6a 00                	push   $0x0
  800d25:	6a 00                	push   $0x0
  800d27:	6a 00                	push   $0x0
  800d29:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d2e:	ba 00 00 00 00       	mov    $0x0,%edx
  800d33:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d38:	e8 e4 fd ff ff       	call   800b21 <syscall>
}
  800d3d:	c9                   	leave  
  800d3e:	c3                   	ret    

00800d3f <sys_set_priority>:

// Get priority of the current process
int
sys_set_priority(unsigned int priority)
{
  800d3f:	55                   	push   %ebp
  800d40:	89 e5                	mov    %esp,%ebp
  800d42:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, (uint32_t) priority, 0, 0, 0, 0);
  800d45:	6a 00                	push   $0x0
  800d47:	6a 00                	push   $0x0
  800d49:	6a 00                	push   $0x0
  800d4b:	6a 00                	push   $0x0
  800d4d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d50:	ba 00 00 00 00       	mov    $0x0,%edx
  800d55:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d5a:	e8 c2 fd ff ff       	call   800b21 <syscall>
}
  800d5f:	c9                   	leave  
  800d60:	c3                   	ret    

00800d61 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800d61:	55                   	push   %ebp
  800d62:	89 e5                	mov    %esp,%ebp
  800d64:	56                   	push   %esi
  800d65:	53                   	push   %ebx
  800d66:	89 c1                	mov    %eax,%ecx
	int r;

	void *addr = (void *) (pn << PGSHIFT);
  800d68:	89 d6                	mov    %edx,%esi
  800d6a:	c1 e6 0c             	shl    $0xc,%esi

	pte_t pte = uvpt[pn];
  800d6d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx

	if (!(pte & PTE_P) || !(pte & PTE_U))
  800d74:	89 d0                	mov    %edx,%eax
  800d76:	83 e0 05             	and    $0x5,%eax
  800d79:	83 f8 05             	cmp    $0x5,%eax
  800d7c:	75 5a                	jne    800dd8 <duppage+0x77>
		panic("duppage: copy a non-present or non-user page");

	int perm = PTE_U | PTE_P;
	// Verifico permisos para páginas de IO
	if (pte & (PTE_PCD | PTE_PWT))
  800d7e:	89 d0                	mov    %edx,%eax
  800d80:	83 e0 18             	and    $0x18,%eax
		perm |= PTE_PCD | PTE_PWT;
  800d83:	83 f8 01             	cmp    $0x1,%eax
  800d86:	19 c0                	sbb    %eax,%eax
  800d88:	83 e0 e8             	and    $0xffffffe8,%eax
  800d8b:	83 c0 1d             	add    $0x1d,%eax


	// Si es de escritura o copy-on-write y NO es de IO
	if ((pte & PTE_W) || (pte & PTE_COW)) {
  800d8e:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800d94:	74 68                	je     800dfe <duppage+0x9d>
		// Mappeo en el hijo la página
		if ((r = sys_page_map(0, addr, envid, addr, perm | PTE_COW)) < 0)
  800d96:	80 cc 08             	or     $0x8,%ah
  800d99:	89 c3                	mov    %eax,%ebx
  800d9b:	83 ec 0c             	sub    $0xc,%esp
  800d9e:	50                   	push   %eax
  800d9f:	56                   	push   %esi
  800da0:	51                   	push   %ecx
  800da1:	56                   	push   %esi
  800da2:	6a 00                	push   $0x0
  800da4:	e8 9c fe ff ff       	call   800c45 <sys_page_map>
  800da9:	83 c4 20             	add    $0x20,%esp
  800dac:	85 c0                	test   %eax,%eax
  800dae:	78 3c                	js     800dec <duppage+0x8b>
			panic("duppage: sys_page_map on childern COW: %e", r);

		// Cambio los permisos del padre
		if ((r = sys_page_map(0, addr, 0, addr, perm | PTE_COW)) < 0)
  800db0:	83 ec 0c             	sub    $0xc,%esp
  800db3:	53                   	push   %ebx
  800db4:	56                   	push   %esi
  800db5:	6a 00                	push   $0x0
  800db7:	56                   	push   %esi
  800db8:	6a 00                	push   $0x0
  800dba:	e8 86 fe ff ff       	call   800c45 <sys_page_map>
  800dbf:	83 c4 20             	add    $0x20,%esp
  800dc2:	85 c0                	test   %eax,%eax
  800dc4:	79 4d                	jns    800e13 <duppage+0xb2>
			panic("duppage: sys_page_map on parent COW: %e", r);
  800dc6:	50                   	push   %eax
  800dc7:	68 4c 19 80 00       	push   $0x80194c
  800dcc:	6a 57                	push   $0x57
  800dce:	68 41 1a 80 00       	push   $0x801a41
  800dd3:	e8 ee 04 00 00       	call   8012c6 <_panic>
		panic("duppage: copy a non-present or non-user page");
  800dd8:	83 ec 04             	sub    $0x4,%esp
  800ddb:	68 f0 18 80 00       	push   $0x8018f0
  800de0:	6a 47                	push   $0x47
  800de2:	68 41 1a 80 00       	push   $0x801a41
  800de7:	e8 da 04 00 00       	call   8012c6 <_panic>
			panic("duppage: sys_page_map on childern COW: %e", r);
  800dec:	50                   	push   %eax
  800ded:	68 20 19 80 00       	push   $0x801920
  800df2:	6a 53                	push   $0x53
  800df4:	68 41 1a 80 00       	push   $0x801a41
  800df9:	e8 c8 04 00 00       	call   8012c6 <_panic>
	} else {
		// Solo mappeo la página de solo lectura
		if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  800dfe:	83 ec 0c             	sub    $0xc,%esp
  800e01:	50                   	push   %eax
  800e02:	56                   	push   %esi
  800e03:	51                   	push   %ecx
  800e04:	56                   	push   %esi
  800e05:	6a 00                	push   $0x0
  800e07:	e8 39 fe ff ff       	call   800c45 <sys_page_map>
  800e0c:	83 c4 20             	add    $0x20,%esp
  800e0f:	85 c0                	test   %eax,%eax
  800e11:	78 0c                	js     800e1f <duppage+0xbe>
			panic("duppage: sys_page_map on childern RO: %e", r);
	}

	// panic("duppage not implemented");
	return 0;
}
  800e13:	b8 00 00 00 00       	mov    $0x0,%eax
  800e18:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e1b:	5b                   	pop    %ebx
  800e1c:	5e                   	pop    %esi
  800e1d:	5d                   	pop    %ebp
  800e1e:	c3                   	ret    
			panic("duppage: sys_page_map on childern RO: %e", r);
  800e1f:	50                   	push   %eax
  800e20:	68 74 19 80 00       	push   $0x801974
  800e25:	6a 5b                	push   $0x5b
  800e27:	68 41 1a 80 00       	push   $0x801a41
  800e2c:	e8 95 04 00 00       	call   8012c6 <_panic>

00800e31 <dup_or_share>:
 *
 * Hace uso de uvpd y uvpt para chequear permisos.
 */
static void
dup_or_share(envid_t envid, uint32_t pnum, int perm)
{
  800e31:	55                   	push   %ebp
  800e32:	89 e5                	mov    %esp,%ebp
  800e34:	57                   	push   %edi
  800e35:	56                   	push   %esi
  800e36:	53                   	push   %ebx
  800e37:	83 ec 0c             	sub    $0xc,%esp
  800e3a:	89 c7                	mov    %eax,%edi
	int r;
	void *addr = (void *) (pnum << PGSHIFT);

	pte_t pte = uvpt[pnum];
  800e3c:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax

	if (!(pte & PTE_P))
  800e43:	a8 01                	test   $0x1,%al
  800e45:	74 33                	je     800e7a <dup_or_share+0x49>
  800e47:	89 d6                	mov    %edx,%esi
		return;

	// Filtro permisos
	perm &= (pte & PTE_W);
  800e49:	21 c1                	and    %eax,%ecx
  800e4b:	89 cb                	mov    %ecx,%ebx
  800e4d:	83 e3 02             	and    $0x2,%ebx
	perm &= PTE_SYSCALL;


	if (pte & (PTE_PCD | PTE_PWT))
		perm |= PTE_PCD | PTE_PWT;
  800e50:	89 da                	mov    %ebx,%edx
  800e52:	83 ca 18             	or     $0x18,%edx
  800e55:	a8 18                	test   $0x18,%al
  800e57:	0f 45 da             	cmovne %edx,%ebx
	void *addr = (void *) (pnum << PGSHIFT);
  800e5a:	c1 e6 0c             	shl    $0xc,%esi

	// Si tengo que copiar
	if (!(pte & PTE_W) || (pte & (PTE_PCD | PTE_PWT))) {
  800e5d:	83 e0 1a             	and    $0x1a,%eax
  800e60:	83 f8 02             	cmp    $0x2,%eax
  800e63:	74 32                	je     800e97 <dup_or_share+0x66>
		if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  800e65:	83 ec 0c             	sub    $0xc,%esp
  800e68:	53                   	push   %ebx
  800e69:	56                   	push   %esi
  800e6a:	57                   	push   %edi
  800e6b:	56                   	push   %esi
  800e6c:	6a 00                	push   $0x0
  800e6e:	e8 d2 fd ff ff       	call   800c45 <sys_page_map>
  800e73:	83 c4 20             	add    $0x20,%esp
  800e76:	85 c0                	test   %eax,%eax
  800e78:	78 08                	js     800e82 <dup_or_share+0x51>
			panic("dup_or_share: sys_page_map: %e", r);
		memmove(UTEMP, addr, PGSIZE);
		if ((r = sys_page_unmap(0, UTEMP)) < 0)
			panic("sys_page_unmap: %e", r);
	}
}
  800e7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e7d:	5b                   	pop    %ebx
  800e7e:	5e                   	pop    %esi
  800e7f:	5f                   	pop    %edi
  800e80:	5d                   	pop    %ebp
  800e81:	c3                   	ret    
			panic("dup_or_share: sys_page_map: %e", r);
  800e82:	50                   	push   %eax
  800e83:	68 a0 19 80 00       	push   $0x8019a0
  800e88:	68 84 00 00 00       	push   $0x84
  800e8d:	68 41 1a 80 00       	push   $0x801a41
  800e92:	e8 2f 04 00 00       	call   8012c6 <_panic>
		if ((r = sys_page_alloc(envid, addr, perm)) < 0)
  800e97:	83 ec 04             	sub    $0x4,%esp
  800e9a:	53                   	push   %ebx
  800e9b:	56                   	push   %esi
  800e9c:	57                   	push   %edi
  800e9d:	e8 7f fd ff ff       	call   800c21 <sys_page_alloc>
  800ea2:	83 c4 10             	add    $0x10,%esp
  800ea5:	85 c0                	test   %eax,%eax
  800ea7:	78 57                	js     800f00 <dup_or_share+0xcf>
		if ((r = sys_page_map(envid, addr, 0, UTEMP, perm)) < 0)
  800ea9:	83 ec 0c             	sub    $0xc,%esp
  800eac:	53                   	push   %ebx
  800ead:	68 00 00 40 00       	push   $0x400000
  800eb2:	6a 00                	push   $0x0
  800eb4:	56                   	push   %esi
  800eb5:	57                   	push   %edi
  800eb6:	e8 8a fd ff ff       	call   800c45 <sys_page_map>
  800ebb:	83 c4 20             	add    $0x20,%esp
  800ebe:	85 c0                	test   %eax,%eax
  800ec0:	78 53                	js     800f15 <dup_or_share+0xe4>
		memmove(UTEMP, addr, PGSIZE);
  800ec2:	83 ec 04             	sub    $0x4,%esp
  800ec5:	68 00 10 00 00       	push   $0x1000
  800eca:	56                   	push   %esi
  800ecb:	68 00 00 40 00       	push   $0x400000
  800ed0:	e8 a2 fa ff ff       	call   800977 <memmove>
		if ((r = sys_page_unmap(0, UTEMP)) < 0)
  800ed5:	83 c4 08             	add    $0x8,%esp
  800ed8:	68 00 00 40 00       	push   $0x400000
  800edd:	6a 00                	push   $0x0
  800edf:	e8 87 fd ff ff       	call   800c6b <sys_page_unmap>
  800ee4:	83 c4 10             	add    $0x10,%esp
  800ee7:	85 c0                	test   %eax,%eax
  800ee9:	79 8f                	jns    800e7a <dup_or_share+0x49>
			panic("sys_page_unmap: %e", r);
  800eeb:	50                   	push   %eax
  800eec:	68 8b 1a 80 00       	push   $0x801a8b
  800ef1:	68 8d 00 00 00       	push   $0x8d
  800ef6:	68 41 1a 80 00       	push   $0x801a41
  800efb:	e8 c6 03 00 00       	call   8012c6 <_panic>
			panic("dup_or_share: sys_page_alloc: %e", r);
  800f00:	50                   	push   %eax
  800f01:	68 c0 19 80 00       	push   $0x8019c0
  800f06:	68 88 00 00 00       	push   $0x88
  800f0b:	68 41 1a 80 00       	push   $0x801a41
  800f10:	e8 b1 03 00 00       	call   8012c6 <_panic>
			panic("dup_or_share: sys_page_map: %e", r);
  800f15:	50                   	push   %eax
  800f16:	68 a0 19 80 00       	push   $0x8019a0
  800f1b:	68 8a 00 00 00       	push   $0x8a
  800f20:	68 41 1a 80 00       	push   $0x801a41
  800f25:	e8 9c 03 00 00       	call   8012c6 <_panic>

00800f2a <pgfault>:
{
  800f2a:	55                   	push   %ebp
  800f2b:	89 e5                	mov    %esp,%ebp
  800f2d:	53                   	push   %ebx
  800f2e:	83 ec 08             	sub    $0x8,%esp
	void *addr = (void *) utf->utf_fault_va;
  800f31:	8b 45 08             	mov    0x8(%ebp),%eax
  800f34:	8b 18                	mov    (%eax),%ebx
	pte_t fault_pte = uvpt[((uint32_t) addr) >> PGSHIFT];
  800f36:	89 d8                	mov    %ebx,%eax
  800f38:	c1 e8 0c             	shr    $0xc,%eax
  800f3b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if ((r = sys_page_alloc(0, PFTEMP, perm)) < 0)
  800f42:	6a 07                	push   $0x7
  800f44:	68 00 f0 7f 00       	push   $0x7ff000
  800f49:	6a 00                	push   $0x0
  800f4b:	e8 d1 fc ff ff       	call   800c21 <sys_page_alloc>
  800f50:	83 c4 10             	add    $0x10,%esp
  800f53:	85 c0                	test   %eax,%eax
  800f55:	78 51                	js     800fa8 <pgfault+0x7e>
	addr = ROUNDDOWN(addr, PGSIZE);
  800f57:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr, PGSIZE);
  800f5d:	83 ec 04             	sub    $0x4,%esp
  800f60:	68 00 10 00 00       	push   $0x1000
  800f65:	53                   	push   %ebx
  800f66:	68 00 f0 7f 00       	push   $0x7ff000
  800f6b:	e8 07 fa ff ff       	call   800977 <memmove>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, perm)) < 0)
  800f70:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f77:	53                   	push   %ebx
  800f78:	6a 00                	push   $0x0
  800f7a:	68 00 f0 7f 00       	push   $0x7ff000
  800f7f:	6a 00                	push   $0x0
  800f81:	e8 bf fc ff ff       	call   800c45 <sys_page_map>
  800f86:	83 c4 20             	add    $0x20,%esp
  800f89:	85 c0                	test   %eax,%eax
  800f8b:	78 2d                	js     800fba <pgfault+0x90>
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800f8d:	83 ec 08             	sub    $0x8,%esp
  800f90:	68 00 f0 7f 00       	push   $0x7ff000
  800f95:	6a 00                	push   $0x0
  800f97:	e8 cf fc ff ff       	call   800c6b <sys_page_unmap>
  800f9c:	83 c4 10             	add    $0x10,%esp
  800f9f:	85 c0                	test   %eax,%eax
  800fa1:	78 29                	js     800fcc <pgfault+0xa2>
}
  800fa3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fa6:	c9                   	leave  
  800fa7:	c3                   	ret    
		panic("pgfault: sys_page_alloc: %e", r);
  800fa8:	50                   	push   %eax
  800fa9:	68 4c 1a 80 00       	push   $0x801a4c
  800fae:	6a 27                	push   $0x27
  800fb0:	68 41 1a 80 00       	push   $0x801a41
  800fb5:	e8 0c 03 00 00       	call   8012c6 <_panic>
		panic("pgfault: sys_page_map: %e", r);
  800fba:	50                   	push   %eax
  800fbb:	68 68 1a 80 00       	push   $0x801a68
  800fc0:	6a 2c                	push   $0x2c
  800fc2:	68 41 1a 80 00       	push   $0x801a41
  800fc7:	e8 fa 02 00 00       	call   8012c6 <_panic>
		panic("pgfault: sys_page_unmap: %e", r);
  800fcc:	50                   	push   %eax
  800fcd:	68 82 1a 80 00       	push   $0x801a82
  800fd2:	6a 2f                	push   $0x2f
  800fd4:	68 41 1a 80 00       	push   $0x801a41
  800fd9:	e8 e8 02 00 00       	call   8012c6 <_panic>

00800fde <fork_v0>:
 *  	-- Para ello se utiliza la funcion dup_or_share()
 *  	-- Se copian todas las paginas desde 0 hasta UTOP
 */
envid_t
fork_v0(void)
{
  800fde:	55                   	push   %ebp
  800fdf:	89 e5                	mov    %esp,%ebp
  800fe1:	56                   	push   %esi
  800fe2:	53                   	push   %ebx

// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline)) sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2" : "=a"(ret) : "a"(SYS_exofork), "i"(T_SYSCALL));
  800fe3:	b8 07 00 00 00       	mov    $0x7,%eax
  800fe8:	cd 30                	int    $0x30
  800fea:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();
	if (envid < 0)
  800fec:	85 c0                	test   %eax,%eax
  800fee:	78 23                	js     801013 <fork_v0+0x35>
	// Parent
	uint32_t pnum = 0;
	uint32_t pnum_end = (UTOP >> PGSHIFT);
	int perm = PTE_P | PTE_U | PTE_W;

	for (pnum = 0; pnum < pnum_end; pnum++) {
  800ff0:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid == 0) {
  800ff5:	75 3c                	jne    801033 <fork_v0+0x55>
		thisenv = &envs[ENVX(sys_getenvid())];
  800ff7:	e8 da fb ff ff       	call   800bd6 <sys_getenvid>
  800ffc:	25 ff 03 00 00       	and    $0x3ff,%eax
  801001:	69 c0 88 00 00 00    	imul   $0x88,%eax,%eax
  801007:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80100c:	a3 0c 20 80 00       	mov    %eax,0x80200c
		return 0;
  801011:	eb 56                	jmp    801069 <fork_v0+0x8b>
		panic("sys_exofork: %e", envid);
  801013:	50                   	push   %eax
  801014:	68 9e 1a 80 00       	push   $0x801a9e
  801019:	68 a2 00 00 00       	push   $0xa2
  80101e:	68 41 1a 80 00       	push   $0x801a41
  801023:	e8 9e 02 00 00       	call   8012c6 <_panic>
	for (pnum = 0; pnum < pnum_end; pnum++) {
  801028:	83 c3 01             	add    $0x1,%ebx
  80102b:	81 fb 00 ec 0e 00    	cmp    $0xeec00,%ebx
  801031:	74 24                	je     801057 <fork_v0+0x79>
		pde_t pde = uvpd[pnum >> 10];
  801033:	89 d8                	mov    %ebx,%eax
  801035:	c1 e8 0a             	shr    $0xa,%eax
  801038:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
		if (!(pde & PTE_P) || !(pde & PTE_U))
  80103f:	83 e0 05             	and    $0x5,%eax
  801042:	83 f8 05             	cmp    $0x5,%eax
  801045:	75 e1                	jne    801028 <fork_v0+0x4a>
			continue;
		dup_or_share(envid, pnum, perm);
  801047:	b9 07 00 00 00       	mov    $0x7,%ecx
  80104c:	89 da                	mov    %ebx,%edx
  80104e:	89 f0                	mov    %esi,%eax
  801050:	e8 dc fd ff ff       	call   800e31 <dup_or_share>
  801055:	eb d1                	jmp    801028 <fork_v0+0x4a>
	}


	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  801057:	83 ec 08             	sub    $0x8,%esp
  80105a:	6a 02                	push   $0x2
  80105c:	56                   	push   %esi
  80105d:	e8 2c fc ff ff       	call   800c8e <sys_env_set_status>
  801062:	83 c4 10             	add    $0x10,%esp
  801065:	85 c0                	test   %eax,%eax
  801067:	78 09                	js     801072 <fork_v0+0x94>
		panic("sys_env_set_status: %e", r);

	return envid;
}
  801069:	89 f0                	mov    %esi,%eax
  80106b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80106e:	5b                   	pop    %ebx
  80106f:	5e                   	pop    %esi
  801070:	5d                   	pop    %ebp
  801071:	c3                   	ret    
		panic("sys_env_set_status: %e", r);
  801072:	50                   	push   %eax
  801073:	68 ae 1a 80 00       	push   $0x801aae
  801078:	68 b8 00 00 00       	push   $0xb8
  80107d:	68 41 1a 80 00       	push   $0x801a41
  801082:	e8 3f 02 00 00       	call   8012c6 <_panic>

00801087 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801087:	55                   	push   %ebp
  801088:	89 e5                	mov    %esp,%ebp
  80108a:	56                   	push   %esi
  80108b:	53                   	push   %ebx
	set_pgfault_handler(pgfault);
  80108c:	83 ec 0c             	sub    $0xc,%esp
  80108f:	68 2a 0f 80 00       	push   $0x800f2a
  801094:	e8 73 02 00 00       	call   80130c <set_pgfault_handler>
  801099:	b8 07 00 00 00       	mov    $0x7,%eax
  80109e:	cd 30                	int    $0x30
  8010a0:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();

	if (envid < 0)
  8010a2:	83 c4 10             	add    $0x10,%esp
  8010a5:	85 c0                	test   %eax,%eax
  8010a7:	78 26                	js     8010cf <fork+0x48>
	// Parent
	uint32_t pnum = 0;
	uint32_t pnum_end = (UTOP >> PGSHIFT);

	// Handle all pages below UTOP
	for (pnum = 0; pnum < pnum_end; pnum++) {
  8010a9:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid == 0) {
  8010ae:	75 41                	jne    8010f1 <fork+0x6a>
		thisenv = &envs[ENVX(sys_getenvid())];
  8010b0:	e8 21 fb ff ff       	call   800bd6 <sys_getenvid>
  8010b5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010ba:	69 c0 88 00 00 00    	imul   $0x88,%eax,%eax
  8010c0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010c5:	a3 0c 20 80 00       	mov    %eax,0x80200c
		return 0;
  8010ca:	e9 92 00 00 00       	jmp    801161 <fork+0xda>
		panic("sys_exofork: %e", envid);
  8010cf:	50                   	push   %eax
  8010d0:	68 9e 1a 80 00       	push   $0x801a9e
  8010d5:	68 d5 00 00 00       	push   $0xd5
  8010da:	68 41 1a 80 00       	push   $0x801a41
  8010df:	e8 e2 01 00 00       	call   8012c6 <_panic>
	for (pnum = 0; pnum < pnum_end; pnum++) {
  8010e4:	83 c3 01             	add    $0x1,%ebx
  8010e7:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  8010ed:	77 30                	ja     80111f <fork+0x98>
		if (pnum == ((UXSTACKTOP >> PGSHIFT) - 1))
  8010ef:	74 f3                	je     8010e4 <fork+0x5d>
			continue;

		pde_t pde = uvpd[pnum >> 10];
  8010f1:	89 d8                	mov    %ebx,%eax
  8010f3:	c1 e8 0a             	shr    $0xa,%eax
  8010f6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
		if (!(pde & PTE_P) || !(pde & PTE_U))
  8010fd:	83 e0 05             	and    $0x5,%eax
  801100:	83 f8 05             	cmp    $0x5,%eax
  801103:	75 df                	jne    8010e4 <fork+0x5d>
			continue;

		pte_t pte = uvpt[pnum];
  801105:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
		if (!(pte & PTE_P) || !(pte & PTE_U))
  80110c:	83 e0 05             	and    $0x5,%eax
  80110f:	83 f8 05             	cmp    $0x5,%eax
  801112:	75 d0                	jne    8010e4 <fork+0x5d>
			continue;
		duppage(envid, pnum);
  801114:	89 da                	mov    %ebx,%edx
  801116:	89 f0                	mov    %esi,%eax
  801118:	e8 44 fc ff ff       	call   800d61 <duppage>
  80111d:	eb c5                	jmp    8010e4 <fork+0x5d>
	}

	uint32_t exstk = (UXSTACKTOP - PGSIZE);
	int r = sys_page_alloc(envid, (void *) exstk, PTE_U | PTE_P | PTE_W);
  80111f:	83 ec 04             	sub    $0x4,%esp
  801122:	6a 07                	push   $0x7
  801124:	68 00 f0 bf ee       	push   $0xeebff000
  801129:	56                   	push   %esi
  80112a:	e8 f2 fa ff ff       	call   800c21 <sys_page_alloc>
	if (r < 0)
  80112f:	83 c4 10             	add    $0x10,%esp
  801132:	85 c0                	test   %eax,%eax
  801134:	78 34                	js     80116a <fork+0xe3>
		panic("fork: sys_page_alloc of exception stk: %e", r);
	r = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801136:	a1 0c 20 80 00       	mov    0x80200c,%eax
  80113b:	8b 40 70             	mov    0x70(%eax),%eax
  80113e:	83 ec 08             	sub    $0x8,%esp
  801141:	50                   	push   %eax
  801142:	56                   	push   %esi
  801143:	e8 69 fb ff ff       	call   800cb1 <sys_env_set_pgfault_upcall>
	if (r < 0)
  801148:	83 c4 10             	add    $0x10,%esp
  80114b:	85 c0                	test   %eax,%eax
  80114d:	78 30                	js     80117f <fork+0xf8>
		panic("fork: sys_env_set_pgfault_upcall on childern: %e", r);

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  80114f:	83 ec 08             	sub    $0x8,%esp
  801152:	6a 02                	push   $0x2
  801154:	56                   	push   %esi
  801155:	e8 34 fb ff ff       	call   800c8e <sys_env_set_status>
  80115a:	83 c4 10             	add    $0x10,%esp
  80115d:	85 c0                	test   %eax,%eax
  80115f:	78 33                	js     801194 <fork+0x10d>
		panic("sys_env_set_status: %e", r);

	return envid;
}
  801161:	89 f0                	mov    %esi,%eax
  801163:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801166:	5b                   	pop    %ebx
  801167:	5e                   	pop    %esi
  801168:	5d                   	pop    %ebp
  801169:	c3                   	ret    
		panic("fork: sys_page_alloc of exception stk: %e", r);
  80116a:	50                   	push   %eax
  80116b:	68 e4 19 80 00       	push   $0x8019e4
  801170:	68 f2 00 00 00       	push   $0xf2
  801175:	68 41 1a 80 00       	push   $0x801a41
  80117a:	e8 47 01 00 00       	call   8012c6 <_panic>
		panic("fork: sys_env_set_pgfault_upcall on childern: %e", r);
  80117f:	50                   	push   %eax
  801180:	68 10 1a 80 00       	push   $0x801a10
  801185:	68 f5 00 00 00       	push   $0xf5
  80118a:	68 41 1a 80 00       	push   $0x801a41
  80118f:	e8 32 01 00 00       	call   8012c6 <_panic>
		panic("sys_env_set_status: %e", r);
  801194:	50                   	push   %eax
  801195:	68 ae 1a 80 00       	push   $0x801aae
  80119a:	68 f8 00 00 00       	push   $0xf8
  80119f:	68 41 1a 80 00       	push   $0x801a41
  8011a4:	e8 1d 01 00 00       	call   8012c6 <_panic>

008011a9 <sfork>:

// Challenge!
int
sfork(void)
{
  8011a9:	55                   	push   %ebp
  8011aa:	89 e5                	mov    %esp,%ebp
  8011ac:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011af:	68 c5 1a 80 00       	push   $0x801ac5
  8011b4:	68 01 01 00 00       	push   $0x101
  8011b9:	68 41 1a 80 00       	push   $0x801a41
  8011be:	e8 03 01 00 00       	call   8012c6 <_panic>

008011c3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8011c3:	55                   	push   %ebp
  8011c4:	89 e5                	mov    %esp,%ebp
  8011c6:	56                   	push   %esi
  8011c7:	53                   	push   %ebx
  8011c8:	8b 75 08             	mov    0x8(%ebp),%esi
  8011cb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int err = sys_ipc_recv(pg);
  8011ce:	83 ec 0c             	sub    $0xc,%esp
  8011d1:	ff 75 0c             	push   0xc(%ebp)
  8011d4:	e8 20 fb ff ff       	call   800cf9 <sys_ipc_recv>

	if (from_env_store)
  8011d9:	83 c4 10             	add    $0x10,%esp
  8011dc:	85 f6                	test   %esi,%esi
  8011de:	74 17                	je     8011f7 <ipc_recv+0x34>
		*from_env_store = (!err) ? thisenv->env_ipc_from : 0;
  8011e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8011e5:	85 c0                	test   %eax,%eax
  8011e7:	75 0c                	jne    8011f5 <ipc_recv+0x32>
  8011e9:	8b 15 0c 20 80 00    	mov    0x80200c,%edx
  8011ef:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
  8011f5:	89 16                	mov    %edx,(%esi)

	if (perm_store)
  8011f7:	85 db                	test   %ebx,%ebx
  8011f9:	74 17                	je     801212 <ipc_recv+0x4f>
		*perm_store = (!err) ? thisenv->env_ipc_perm : 0;
  8011fb:	ba 00 00 00 00       	mov    $0x0,%edx
  801200:	85 c0                	test   %eax,%eax
  801202:	75 0c                	jne    801210 <ipc_recv+0x4d>
  801204:	8b 15 0c 20 80 00    	mov    0x80200c,%edx
  80120a:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  801210:	89 13                	mov    %edx,(%ebx)

	if (!err)
  801212:	85 c0                	test   %eax,%eax
  801214:	75 08                	jne    80121e <ipc_recv+0x5b>
		err = thisenv->env_ipc_value;
  801216:	a1 0c 20 80 00       	mov    0x80200c,%eax
  80121b:	8b 40 7c             	mov    0x7c(%eax),%eax

	return err;
}
  80121e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801221:	5b                   	pop    %ebx
  801222:	5e                   	pop    %esi
  801223:	5d                   	pop    %ebp
  801224:	c3                   	ret    

00801225 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801225:	55                   	push   %ebp
  801226:	89 e5                	mov    %esp,%ebp
  801228:	57                   	push   %edi
  801229:	56                   	push   %esi
  80122a:	53                   	push   %ebx
  80122b:	83 ec 0c             	sub    $0xc,%esp
  80122e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801231:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801234:	8b 7d 14             	mov    0x14(%ebp),%edi
	if (!pg)
		pg = (void *) UTOP;
  801237:	85 db                	test   %ebx,%ebx
  801239:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80123e:	0f 44 d8             	cmove  %eax,%ebx
	int r = sys_ipc_try_send(to_env, val, pg, perm);
  801241:	57                   	push   %edi
  801242:	53                   	push   %ebx
  801243:	56                   	push   %esi
  801244:	ff 75 08             	push   0x8(%ebp)
  801247:	e8 88 fa ff ff       	call   800cd4 <sys_ipc_try_send>
	while (r == -E_IPC_NOT_RECV) {
  80124c:	83 c4 10             	add    $0x10,%esp
  80124f:	eb 13                	jmp    801264 <ipc_send+0x3f>
		sys_yield();
  801251:	e8 a4 f9 ff ff       	call   800bfa <sys_yield>
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801256:	57                   	push   %edi
  801257:	53                   	push   %ebx
  801258:	56                   	push   %esi
  801259:	ff 75 08             	push   0x8(%ebp)
  80125c:	e8 73 fa ff ff       	call   800cd4 <sys_ipc_try_send>
  801261:	83 c4 10             	add    $0x10,%esp
	while (r == -E_IPC_NOT_RECV) {
  801264:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801267:	74 e8                	je     801251 <ipc_send+0x2c>
	}

	if (r < 0)
  801269:	85 c0                	test   %eax,%eax
  80126b:	78 08                	js     801275 <ipc_send+0x50>
		panic("ipc_send: %e", r);
}
  80126d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801270:	5b                   	pop    %ebx
  801271:	5e                   	pop    %esi
  801272:	5f                   	pop    %edi
  801273:	5d                   	pop    %ebp
  801274:	c3                   	ret    
		panic("ipc_send: %e", r);
  801275:	50                   	push   %eax
  801276:	68 db 1a 80 00       	push   $0x801adb
  80127b:	6a 3b                	push   $0x3b
  80127d:	68 e8 1a 80 00       	push   $0x801ae8
  801282:	e8 3f 00 00 00       	call   8012c6 <_panic>

00801287 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801287:	55                   	push   %ebp
  801288:	89 e5                	mov    %esp,%ebp
  80128a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80128d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801292:	69 d0 88 00 00 00    	imul   $0x88,%eax,%edx
  801298:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80129e:	8b 52 50             	mov    0x50(%edx),%edx
  8012a1:	39 ca                	cmp    %ecx,%edx
  8012a3:	74 11                	je     8012b6 <ipc_find_env+0x2f>
	for (i = 0; i < NENV; i++)
  8012a5:	83 c0 01             	add    $0x1,%eax
  8012a8:	3d 00 04 00 00       	cmp    $0x400,%eax
  8012ad:	75 e3                	jne    801292 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  8012af:	b8 00 00 00 00       	mov    $0x0,%eax
  8012b4:	eb 0e                	jmp    8012c4 <ipc_find_env+0x3d>
			return envs[i].env_id;
  8012b6:	69 c0 88 00 00 00    	imul   $0x88,%eax,%eax
  8012bc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8012c1:	8b 40 48             	mov    0x48(%eax),%eax
}
  8012c4:	5d                   	pop    %ebp
  8012c5:	c3                   	ret    

008012c6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8012c6:	55                   	push   %ebp
  8012c7:	89 e5                	mov    %esp,%ebp
  8012c9:	56                   	push   %esi
  8012ca:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8012cb:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8012ce:	8b 35 08 20 80 00    	mov    0x802008,%esi
  8012d4:	e8 fd f8 ff ff       	call   800bd6 <sys_getenvid>
  8012d9:	83 ec 0c             	sub    $0xc,%esp
  8012dc:	ff 75 0c             	push   0xc(%ebp)
  8012df:	ff 75 08             	push   0x8(%ebp)
  8012e2:	56                   	push   %esi
  8012e3:	50                   	push   %eax
  8012e4:	68 f4 1a 80 00       	push   $0x801af4
  8012e9:	e8 b6 ef ff ff       	call   8002a4 <cprintf>
	        sys_getenvid(),
	        binaryname,
	        file,
	        line);
	vcprintf(fmt, ap);
  8012ee:	83 c4 18             	add    $0x18,%esp
  8012f1:	53                   	push   %ebx
  8012f2:	ff 75 10             	push   0x10(%ebp)
  8012f5:	e8 59 ef ff ff       	call   800253 <vcprintf>
	cprintf("\n");
  8012fa:	c7 04 24 da 15 80 00 	movl   $0x8015da,(%esp)
  801301:	e8 9e ef ff ff       	call   8002a4 <cprintf>
  801306:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801309:	cc                   	int3   
  80130a:	eb fd                	jmp    801309 <_panic+0x43>

0080130c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80130c:	55                   	push   %ebp
  80130d:	89 e5                	mov    %esp,%ebp
  80130f:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801312:	83 3d 10 20 80 00 00 	cmpl   $0x0,0x802010
  801319:	74 0a                	je     801325 <set_pgfault_handler+0x19>
		if (r < 0)
			return;
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80131b:	8b 45 08             	mov    0x8(%ebp),%eax
  80131e:	a3 10 20 80 00       	mov    %eax,0x802010
}
  801323:	c9                   	leave  
  801324:	c3                   	ret    
		r = sys_page_alloc(0, (void *) exstk, perm);
  801325:	83 ec 04             	sub    $0x4,%esp
  801328:	6a 07                	push   $0x7
  80132a:	68 00 f0 bf ee       	push   $0xeebff000
  80132f:	6a 00                	push   $0x0
  801331:	e8 eb f8 ff ff       	call   800c21 <sys_page_alloc>
		if (r < 0)
  801336:	83 c4 10             	add    $0x10,%esp
  801339:	85 c0                	test   %eax,%eax
  80133b:	78 e6                	js     801323 <set_pgfault_handler+0x17>
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  80133d:	83 ec 08             	sub    $0x8,%esp
  801340:	68 55 13 80 00       	push   $0x801355
  801345:	6a 00                	push   $0x0
  801347:	e8 65 f9 ff ff       	call   800cb1 <sys_env_set_pgfault_upcall>
		if (r < 0)
  80134c:	83 c4 10             	add    $0x10,%esp
  80134f:	85 c0                	test   %eax,%eax
  801351:	79 c8                	jns    80131b <set_pgfault_handler+0xf>
  801353:	eb ce                	jmp    801323 <set_pgfault_handler+0x17>

00801355 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801355:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801356:	a1 10 20 80 00       	mov    0x802010,%eax
	call *%eax
  80135b:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80135d:	83 c4 04             	add    $0x4,%esp
	// Throughout the remaining code, think carefully about what
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	movl 40(%esp), %eax	// trap-time %epi -> %eax 
  801360:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %ebx	// trap-time %esp -> %ebx
  801364:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4, %ebx
  801368:	83 eb 04             	sub    $0x4,%ebx
	movl %eax, 0(%ebx)	// push %eip in trap-time stack
  80136b:	89 03                	mov    %eax,(%ebx)

	movl %ebx, 48(%esp)
  80136d:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	popl %eax
  801371:	58                   	pop    %eax
	popl %eax
  801372:	58                   	pop    %eax
	popal
  801373:	61                   	popa   
	

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	addl $4, %esp
  801374:	83 c4 04             	add    $0x4,%esp
	popfl
  801377:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	popl %esp
  801378:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	ret
  801379:	c3                   	ret    
  80137a:	66 90                	xchg   %ax,%ax
  80137c:	66 90                	xchg   %ax,%ax
  80137e:	66 90                	xchg   %ax,%ax

00801380 <__udivdi3>:
  801380:	f3 0f 1e fb          	endbr32 
  801384:	55                   	push   %ebp
  801385:	57                   	push   %edi
  801386:	56                   	push   %esi
  801387:	53                   	push   %ebx
  801388:	83 ec 1c             	sub    $0x1c,%esp
  80138b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80138f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801393:	8b 74 24 34          	mov    0x34(%esp),%esi
  801397:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80139b:	85 c0                	test   %eax,%eax
  80139d:	75 19                	jne    8013b8 <__udivdi3+0x38>
  80139f:	39 f3                	cmp    %esi,%ebx
  8013a1:	76 4d                	jbe    8013f0 <__udivdi3+0x70>
  8013a3:	31 ff                	xor    %edi,%edi
  8013a5:	89 e8                	mov    %ebp,%eax
  8013a7:	89 f2                	mov    %esi,%edx
  8013a9:	f7 f3                	div    %ebx
  8013ab:	89 fa                	mov    %edi,%edx
  8013ad:	83 c4 1c             	add    $0x1c,%esp
  8013b0:	5b                   	pop    %ebx
  8013b1:	5e                   	pop    %esi
  8013b2:	5f                   	pop    %edi
  8013b3:	5d                   	pop    %ebp
  8013b4:	c3                   	ret    
  8013b5:	8d 76 00             	lea    0x0(%esi),%esi
  8013b8:	39 f0                	cmp    %esi,%eax
  8013ba:	76 14                	jbe    8013d0 <__udivdi3+0x50>
  8013bc:	31 ff                	xor    %edi,%edi
  8013be:	31 c0                	xor    %eax,%eax
  8013c0:	89 fa                	mov    %edi,%edx
  8013c2:	83 c4 1c             	add    $0x1c,%esp
  8013c5:	5b                   	pop    %ebx
  8013c6:	5e                   	pop    %esi
  8013c7:	5f                   	pop    %edi
  8013c8:	5d                   	pop    %ebp
  8013c9:	c3                   	ret    
  8013ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8013d0:	0f bd f8             	bsr    %eax,%edi
  8013d3:	83 f7 1f             	xor    $0x1f,%edi
  8013d6:	75 48                	jne    801420 <__udivdi3+0xa0>
  8013d8:	39 f0                	cmp    %esi,%eax
  8013da:	72 06                	jb     8013e2 <__udivdi3+0x62>
  8013dc:	31 c0                	xor    %eax,%eax
  8013de:	39 eb                	cmp    %ebp,%ebx
  8013e0:	77 de                	ja     8013c0 <__udivdi3+0x40>
  8013e2:	b8 01 00 00 00       	mov    $0x1,%eax
  8013e7:	eb d7                	jmp    8013c0 <__udivdi3+0x40>
  8013e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8013f0:	89 d9                	mov    %ebx,%ecx
  8013f2:	85 db                	test   %ebx,%ebx
  8013f4:	75 0b                	jne    801401 <__udivdi3+0x81>
  8013f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8013fb:	31 d2                	xor    %edx,%edx
  8013fd:	f7 f3                	div    %ebx
  8013ff:	89 c1                	mov    %eax,%ecx
  801401:	31 d2                	xor    %edx,%edx
  801403:	89 f0                	mov    %esi,%eax
  801405:	f7 f1                	div    %ecx
  801407:	89 c6                	mov    %eax,%esi
  801409:	89 e8                	mov    %ebp,%eax
  80140b:	89 f7                	mov    %esi,%edi
  80140d:	f7 f1                	div    %ecx
  80140f:	89 fa                	mov    %edi,%edx
  801411:	83 c4 1c             	add    $0x1c,%esp
  801414:	5b                   	pop    %ebx
  801415:	5e                   	pop    %esi
  801416:	5f                   	pop    %edi
  801417:	5d                   	pop    %ebp
  801418:	c3                   	ret    
  801419:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801420:	89 f9                	mov    %edi,%ecx
  801422:	ba 20 00 00 00       	mov    $0x20,%edx
  801427:	29 fa                	sub    %edi,%edx
  801429:	d3 e0                	shl    %cl,%eax
  80142b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80142f:	89 d1                	mov    %edx,%ecx
  801431:	89 d8                	mov    %ebx,%eax
  801433:	d3 e8                	shr    %cl,%eax
  801435:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801439:	09 c1                	or     %eax,%ecx
  80143b:	89 f0                	mov    %esi,%eax
  80143d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801441:	89 f9                	mov    %edi,%ecx
  801443:	d3 e3                	shl    %cl,%ebx
  801445:	89 d1                	mov    %edx,%ecx
  801447:	d3 e8                	shr    %cl,%eax
  801449:	89 f9                	mov    %edi,%ecx
  80144b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80144f:	89 eb                	mov    %ebp,%ebx
  801451:	d3 e6                	shl    %cl,%esi
  801453:	89 d1                	mov    %edx,%ecx
  801455:	d3 eb                	shr    %cl,%ebx
  801457:	09 f3                	or     %esi,%ebx
  801459:	89 c6                	mov    %eax,%esi
  80145b:	89 f2                	mov    %esi,%edx
  80145d:	89 d8                	mov    %ebx,%eax
  80145f:	f7 74 24 08          	divl   0x8(%esp)
  801463:	89 d6                	mov    %edx,%esi
  801465:	89 c3                	mov    %eax,%ebx
  801467:	f7 64 24 0c          	mull   0xc(%esp)
  80146b:	39 d6                	cmp    %edx,%esi
  80146d:	72 19                	jb     801488 <__udivdi3+0x108>
  80146f:	89 f9                	mov    %edi,%ecx
  801471:	d3 e5                	shl    %cl,%ebp
  801473:	39 c5                	cmp    %eax,%ebp
  801475:	73 04                	jae    80147b <__udivdi3+0xfb>
  801477:	39 d6                	cmp    %edx,%esi
  801479:	74 0d                	je     801488 <__udivdi3+0x108>
  80147b:	89 d8                	mov    %ebx,%eax
  80147d:	31 ff                	xor    %edi,%edi
  80147f:	e9 3c ff ff ff       	jmp    8013c0 <__udivdi3+0x40>
  801484:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801488:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80148b:	31 ff                	xor    %edi,%edi
  80148d:	e9 2e ff ff ff       	jmp    8013c0 <__udivdi3+0x40>
  801492:	66 90                	xchg   %ax,%ax
  801494:	66 90                	xchg   %ax,%ax
  801496:	66 90                	xchg   %ax,%ax
  801498:	66 90                	xchg   %ax,%ax
  80149a:	66 90                	xchg   %ax,%ax
  80149c:	66 90                	xchg   %ax,%ax
  80149e:	66 90                	xchg   %ax,%ax

008014a0 <__umoddi3>:
  8014a0:	f3 0f 1e fb          	endbr32 
  8014a4:	55                   	push   %ebp
  8014a5:	57                   	push   %edi
  8014a6:	56                   	push   %esi
  8014a7:	53                   	push   %ebx
  8014a8:	83 ec 1c             	sub    $0x1c,%esp
  8014ab:	8b 74 24 30          	mov    0x30(%esp),%esi
  8014af:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8014b3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  8014b7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  8014bb:	89 f0                	mov    %esi,%eax
  8014bd:	89 da                	mov    %ebx,%edx
  8014bf:	85 ff                	test   %edi,%edi
  8014c1:	75 15                	jne    8014d8 <__umoddi3+0x38>
  8014c3:	39 dd                	cmp    %ebx,%ebp
  8014c5:	76 39                	jbe    801500 <__umoddi3+0x60>
  8014c7:	f7 f5                	div    %ebp
  8014c9:	89 d0                	mov    %edx,%eax
  8014cb:	31 d2                	xor    %edx,%edx
  8014cd:	83 c4 1c             	add    $0x1c,%esp
  8014d0:	5b                   	pop    %ebx
  8014d1:	5e                   	pop    %esi
  8014d2:	5f                   	pop    %edi
  8014d3:	5d                   	pop    %ebp
  8014d4:	c3                   	ret    
  8014d5:	8d 76 00             	lea    0x0(%esi),%esi
  8014d8:	39 df                	cmp    %ebx,%edi
  8014da:	77 f1                	ja     8014cd <__umoddi3+0x2d>
  8014dc:	0f bd cf             	bsr    %edi,%ecx
  8014df:	83 f1 1f             	xor    $0x1f,%ecx
  8014e2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8014e6:	75 40                	jne    801528 <__umoddi3+0x88>
  8014e8:	39 df                	cmp    %ebx,%edi
  8014ea:	72 04                	jb     8014f0 <__umoddi3+0x50>
  8014ec:	39 f5                	cmp    %esi,%ebp
  8014ee:	77 dd                	ja     8014cd <__umoddi3+0x2d>
  8014f0:	89 da                	mov    %ebx,%edx
  8014f2:	89 f0                	mov    %esi,%eax
  8014f4:	29 e8                	sub    %ebp,%eax
  8014f6:	19 fa                	sbb    %edi,%edx
  8014f8:	eb d3                	jmp    8014cd <__umoddi3+0x2d>
  8014fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801500:	89 e9                	mov    %ebp,%ecx
  801502:	85 ed                	test   %ebp,%ebp
  801504:	75 0b                	jne    801511 <__umoddi3+0x71>
  801506:	b8 01 00 00 00       	mov    $0x1,%eax
  80150b:	31 d2                	xor    %edx,%edx
  80150d:	f7 f5                	div    %ebp
  80150f:	89 c1                	mov    %eax,%ecx
  801511:	89 d8                	mov    %ebx,%eax
  801513:	31 d2                	xor    %edx,%edx
  801515:	f7 f1                	div    %ecx
  801517:	89 f0                	mov    %esi,%eax
  801519:	f7 f1                	div    %ecx
  80151b:	89 d0                	mov    %edx,%eax
  80151d:	31 d2                	xor    %edx,%edx
  80151f:	eb ac                	jmp    8014cd <__umoddi3+0x2d>
  801521:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801528:	8b 44 24 04          	mov    0x4(%esp),%eax
  80152c:	ba 20 00 00 00       	mov    $0x20,%edx
  801531:	29 c2                	sub    %eax,%edx
  801533:	89 c1                	mov    %eax,%ecx
  801535:	89 e8                	mov    %ebp,%eax
  801537:	d3 e7                	shl    %cl,%edi
  801539:	89 d1                	mov    %edx,%ecx
  80153b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80153f:	d3 e8                	shr    %cl,%eax
  801541:	89 c1                	mov    %eax,%ecx
  801543:	8b 44 24 04          	mov    0x4(%esp),%eax
  801547:	09 f9                	or     %edi,%ecx
  801549:	89 df                	mov    %ebx,%edi
  80154b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80154f:	89 c1                	mov    %eax,%ecx
  801551:	d3 e5                	shl    %cl,%ebp
  801553:	89 d1                	mov    %edx,%ecx
  801555:	d3 ef                	shr    %cl,%edi
  801557:	89 c1                	mov    %eax,%ecx
  801559:	89 f0                	mov    %esi,%eax
  80155b:	d3 e3                	shl    %cl,%ebx
  80155d:	89 d1                	mov    %edx,%ecx
  80155f:	89 fa                	mov    %edi,%edx
  801561:	d3 e8                	shr    %cl,%eax
  801563:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801568:	09 d8                	or     %ebx,%eax
  80156a:	f7 74 24 08          	divl   0x8(%esp)
  80156e:	89 d3                	mov    %edx,%ebx
  801570:	d3 e6                	shl    %cl,%esi
  801572:	f7 e5                	mul    %ebp
  801574:	89 c7                	mov    %eax,%edi
  801576:	89 d1                	mov    %edx,%ecx
  801578:	39 d3                	cmp    %edx,%ebx
  80157a:	72 06                	jb     801582 <__umoddi3+0xe2>
  80157c:	75 0e                	jne    80158c <__umoddi3+0xec>
  80157e:	39 c6                	cmp    %eax,%esi
  801580:	73 0a                	jae    80158c <__umoddi3+0xec>
  801582:	29 e8                	sub    %ebp,%eax
  801584:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801588:	89 d1                	mov    %edx,%ecx
  80158a:	89 c7                	mov    %eax,%edi
  80158c:	89 f5                	mov    %esi,%ebp
  80158e:	8b 74 24 04          	mov    0x4(%esp),%esi
  801592:	29 fd                	sub    %edi,%ebp
  801594:	19 cb                	sbb    %ecx,%ebx
  801596:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80159b:	89 d8                	mov    %ebx,%eax
  80159d:	d3 e0                	shl    %cl,%eax
  80159f:	89 f1                	mov    %esi,%ecx
  8015a1:	d3 ed                	shr    %cl,%ebp
  8015a3:	d3 eb                	shr    %cl,%ebx
  8015a5:	09 e8                	or     %ebp,%eax
  8015a7:	89 da                	mov    %ebx,%edx
  8015a9:	83 c4 1c             	add    $0x1c,%esp
  8015ac:	5b                   	pop    %ebx
  8015ad:	5e                   	pop    %esi
  8015ae:	5f                   	pop    %edi
  8015af:	5d                   	pop    %ebp
  8015b0:	c3                   	ret    
