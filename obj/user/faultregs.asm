
obj/user/faultregs:     formato del fichero elf32-i386


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
  80002c:	e8 b0 05 00 00       	call   8005e1 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <check_regs>:
check_regs(struct regs *a,
           const char *an,
           struct regs *b,
           const char *bn,
           const char *testname)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 0c             	sub    $0xc,%esp
  80003c:	89 c6                	mov    %eax,%esi
  80003e:	89 cb                	mov    %ecx,%ebx
	int mismatch = 0;

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  800040:	ff 75 08             	push   0x8(%ebp)
  800043:	52                   	push   %edx
  800044:	68 d1 14 80 00       	push   $0x8014d1
  800049:	68 a0 14 80 00       	push   $0x8014a0
  80004e:	e8 c8 06 00 00       	call   80071b <cprintf>
			cprintf("MISMATCH\n");                                 \
			mismatch = 1;                                          \
		}                                                              \
	} while (0)

	CHECK(edi, regs.reg_edi);
  800053:	ff 33                	push   (%ebx)
  800055:	ff 36                	push   (%esi)
  800057:	68 b0 14 80 00       	push   $0x8014b0
  80005c:	68 b4 14 80 00       	push   $0x8014b4
  800061:	e8 b5 06 00 00       	call   80071b <cprintf>
  800066:	83 c4 20             	add    $0x20,%esp
  800069:	8b 03                	mov    (%ebx),%eax
  80006b:	39 06                	cmp    %eax,(%esi)
  80006d:	0f 84 2e 02 00 00    	je     8002a1 <check_regs+0x26e>
  800073:	83 ec 0c             	sub    $0xc,%esp
  800076:	68 c8 14 80 00       	push   $0x8014c8
  80007b:	e8 9b 06 00 00       	call   80071b <cprintf>
  800080:	83 c4 10             	add    $0x10,%esp
  800083:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  800088:	ff 73 04             	push   0x4(%ebx)
  80008b:	ff 76 04             	push   0x4(%esi)
  80008e:	68 d2 14 80 00       	push   $0x8014d2
  800093:	68 b4 14 80 00       	push   $0x8014b4
  800098:	e8 7e 06 00 00       	call   80071b <cprintf>
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	8b 43 04             	mov    0x4(%ebx),%eax
  8000a3:	39 46 04             	cmp    %eax,0x4(%esi)
  8000a6:	0f 84 0f 02 00 00    	je     8002bb <check_regs+0x288>
  8000ac:	83 ec 0c             	sub    $0xc,%esp
  8000af:	68 c8 14 80 00       	push   $0x8014c8
  8000b4:	e8 62 06 00 00       	call   80071b <cprintf>
  8000b9:	83 c4 10             	add    $0x10,%esp
  8000bc:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000c1:	ff 73 08             	push   0x8(%ebx)
  8000c4:	ff 76 08             	push   0x8(%esi)
  8000c7:	68 d6 14 80 00       	push   $0x8014d6
  8000cc:	68 b4 14 80 00       	push   $0x8014b4
  8000d1:	e8 45 06 00 00       	call   80071b <cprintf>
  8000d6:	83 c4 10             	add    $0x10,%esp
  8000d9:	8b 43 08             	mov    0x8(%ebx),%eax
  8000dc:	39 46 08             	cmp    %eax,0x8(%esi)
  8000df:	0f 84 eb 01 00 00    	je     8002d0 <check_regs+0x29d>
  8000e5:	83 ec 0c             	sub    $0xc,%esp
  8000e8:	68 c8 14 80 00       	push   $0x8014c8
  8000ed:	e8 29 06 00 00       	call   80071b <cprintf>
  8000f2:	83 c4 10             	add    $0x10,%esp
  8000f5:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  8000fa:	ff 73 10             	push   0x10(%ebx)
  8000fd:	ff 76 10             	push   0x10(%esi)
  800100:	68 da 14 80 00       	push   $0x8014da
  800105:	68 b4 14 80 00       	push   $0x8014b4
  80010a:	e8 0c 06 00 00       	call   80071b <cprintf>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	8b 43 10             	mov    0x10(%ebx),%eax
  800115:	39 46 10             	cmp    %eax,0x10(%esi)
  800118:	0f 84 c7 01 00 00    	je     8002e5 <check_regs+0x2b2>
  80011e:	83 ec 0c             	sub    $0xc,%esp
  800121:	68 c8 14 80 00       	push   $0x8014c8
  800126:	e8 f0 05 00 00       	call   80071b <cprintf>
  80012b:	83 c4 10             	add    $0x10,%esp
  80012e:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800133:	ff 73 14             	push   0x14(%ebx)
  800136:	ff 76 14             	push   0x14(%esi)
  800139:	68 de 14 80 00       	push   $0x8014de
  80013e:	68 b4 14 80 00       	push   $0x8014b4
  800143:	e8 d3 05 00 00       	call   80071b <cprintf>
  800148:	83 c4 10             	add    $0x10,%esp
  80014b:	8b 43 14             	mov    0x14(%ebx),%eax
  80014e:	39 46 14             	cmp    %eax,0x14(%esi)
  800151:	0f 84 a3 01 00 00    	je     8002fa <check_regs+0x2c7>
  800157:	83 ec 0c             	sub    $0xc,%esp
  80015a:	68 c8 14 80 00       	push   $0x8014c8
  80015f:	e8 b7 05 00 00       	call   80071b <cprintf>
  800164:	83 c4 10             	add    $0x10,%esp
  800167:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  80016c:	ff 73 18             	push   0x18(%ebx)
  80016f:	ff 76 18             	push   0x18(%esi)
  800172:	68 e2 14 80 00       	push   $0x8014e2
  800177:	68 b4 14 80 00       	push   $0x8014b4
  80017c:	e8 9a 05 00 00       	call   80071b <cprintf>
  800181:	83 c4 10             	add    $0x10,%esp
  800184:	8b 43 18             	mov    0x18(%ebx),%eax
  800187:	39 46 18             	cmp    %eax,0x18(%esi)
  80018a:	0f 84 7f 01 00 00    	je     80030f <check_regs+0x2dc>
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	68 c8 14 80 00       	push   $0x8014c8
  800198:	e8 7e 05 00 00       	call   80071b <cprintf>
  80019d:	83 c4 10             	add    $0x10,%esp
  8001a0:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  8001a5:	ff 73 1c             	push   0x1c(%ebx)
  8001a8:	ff 76 1c             	push   0x1c(%esi)
  8001ab:	68 e6 14 80 00       	push   $0x8014e6
  8001b0:	68 b4 14 80 00       	push   $0x8014b4
  8001b5:	e8 61 05 00 00       	call   80071b <cprintf>
  8001ba:	83 c4 10             	add    $0x10,%esp
  8001bd:	8b 43 1c             	mov    0x1c(%ebx),%eax
  8001c0:	39 46 1c             	cmp    %eax,0x1c(%esi)
  8001c3:	0f 84 5b 01 00 00    	je     800324 <check_regs+0x2f1>
  8001c9:	83 ec 0c             	sub    $0xc,%esp
  8001cc:	68 c8 14 80 00       	push   $0x8014c8
  8001d1:	e8 45 05 00 00       	call   80071b <cprintf>
  8001d6:	83 c4 10             	add    $0x10,%esp
  8001d9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  8001de:	ff 73 20             	push   0x20(%ebx)
  8001e1:	ff 76 20             	push   0x20(%esi)
  8001e4:	68 ea 14 80 00       	push   $0x8014ea
  8001e9:	68 b4 14 80 00       	push   $0x8014b4
  8001ee:	e8 28 05 00 00       	call   80071b <cprintf>
  8001f3:	83 c4 10             	add    $0x10,%esp
  8001f6:	8b 43 20             	mov    0x20(%ebx),%eax
  8001f9:	39 46 20             	cmp    %eax,0x20(%esi)
  8001fc:	0f 84 37 01 00 00    	je     800339 <check_regs+0x306>
  800202:	83 ec 0c             	sub    $0xc,%esp
  800205:	68 c8 14 80 00       	push   $0x8014c8
  80020a:	e8 0c 05 00 00       	call   80071b <cprintf>
  80020f:	83 c4 10             	add    $0x10,%esp
  800212:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  800217:	ff 73 24             	push   0x24(%ebx)
  80021a:	ff 76 24             	push   0x24(%esi)
  80021d:	68 ee 14 80 00       	push   $0x8014ee
  800222:	68 b4 14 80 00       	push   $0x8014b4
  800227:	e8 ef 04 00 00       	call   80071b <cprintf>
  80022c:	83 c4 10             	add    $0x10,%esp
  80022f:	8b 43 24             	mov    0x24(%ebx),%eax
  800232:	39 46 24             	cmp    %eax,0x24(%esi)
  800235:	0f 84 13 01 00 00    	je     80034e <check_regs+0x31b>
  80023b:	83 ec 0c             	sub    $0xc,%esp
  80023e:	68 c8 14 80 00       	push   $0x8014c8
  800243:	e8 d3 04 00 00       	call   80071b <cprintf>
	CHECK(esp, esp);
  800248:	ff 73 28             	push   0x28(%ebx)
  80024b:	ff 76 28             	push   0x28(%esi)
  80024e:	68 f5 14 80 00       	push   $0x8014f5
  800253:	68 b4 14 80 00       	push   $0x8014b4
  800258:	e8 be 04 00 00       	call   80071b <cprintf>
  80025d:	83 c4 20             	add    $0x20,%esp
  800260:	8b 43 28             	mov    0x28(%ebx),%eax
  800263:	39 46 28             	cmp    %eax,0x28(%esi)
  800266:	0f 84 53 01 00 00    	je     8003bf <check_regs+0x38c>
  80026c:	83 ec 0c             	sub    $0xc,%esp
  80026f:	68 c8 14 80 00       	push   $0x8014c8
  800274:	e8 a2 04 00 00       	call   80071b <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800279:	83 c4 08             	add    $0x8,%esp
  80027c:	ff 75 0c             	push   0xc(%ebp)
  80027f:	68 f9 14 80 00       	push   $0x8014f9
  800284:	e8 92 04 00 00       	call   80071b <cprintf>
  800289:	83 c4 10             	add    $0x10,%esp
	if (!mismatch)
		cprintf("OK\n");
	else
		cprintf("MISMATCH\n");
  80028c:	83 ec 0c             	sub    $0xc,%esp
  80028f:	68 c8 14 80 00       	push   $0x8014c8
  800294:	e8 82 04 00 00       	call   80071b <cprintf>
  800299:	83 c4 10             	add    $0x10,%esp
}
  80029c:	e9 16 01 00 00       	jmp    8003b7 <check_regs+0x384>
	CHECK(edi, regs.reg_edi);
  8002a1:	83 ec 0c             	sub    $0xc,%esp
  8002a4:	68 c4 14 80 00       	push   $0x8014c4
  8002a9:	e8 6d 04 00 00       	call   80071b <cprintf>
  8002ae:	83 c4 10             	add    $0x10,%esp
	int mismatch = 0;
  8002b1:	bf 00 00 00 00       	mov    $0x0,%edi
  8002b6:	e9 cd fd ff ff       	jmp    800088 <check_regs+0x55>
	CHECK(esi, regs.reg_esi);
  8002bb:	83 ec 0c             	sub    $0xc,%esp
  8002be:	68 c4 14 80 00       	push   $0x8014c4
  8002c3:	e8 53 04 00 00       	call   80071b <cprintf>
  8002c8:	83 c4 10             	add    $0x10,%esp
  8002cb:	e9 f1 fd ff ff       	jmp    8000c1 <check_regs+0x8e>
	CHECK(ebp, regs.reg_ebp);
  8002d0:	83 ec 0c             	sub    $0xc,%esp
  8002d3:	68 c4 14 80 00       	push   $0x8014c4
  8002d8:	e8 3e 04 00 00       	call   80071b <cprintf>
  8002dd:	83 c4 10             	add    $0x10,%esp
  8002e0:	e9 15 fe ff ff       	jmp    8000fa <check_regs+0xc7>
	CHECK(ebx, regs.reg_ebx);
  8002e5:	83 ec 0c             	sub    $0xc,%esp
  8002e8:	68 c4 14 80 00       	push   $0x8014c4
  8002ed:	e8 29 04 00 00       	call   80071b <cprintf>
  8002f2:	83 c4 10             	add    $0x10,%esp
  8002f5:	e9 39 fe ff ff       	jmp    800133 <check_regs+0x100>
	CHECK(edx, regs.reg_edx);
  8002fa:	83 ec 0c             	sub    $0xc,%esp
  8002fd:	68 c4 14 80 00       	push   $0x8014c4
  800302:	e8 14 04 00 00       	call   80071b <cprintf>
  800307:	83 c4 10             	add    $0x10,%esp
  80030a:	e9 5d fe ff ff       	jmp    80016c <check_regs+0x139>
	CHECK(ecx, regs.reg_ecx);
  80030f:	83 ec 0c             	sub    $0xc,%esp
  800312:	68 c4 14 80 00       	push   $0x8014c4
  800317:	e8 ff 03 00 00       	call   80071b <cprintf>
  80031c:	83 c4 10             	add    $0x10,%esp
  80031f:	e9 81 fe ff ff       	jmp    8001a5 <check_regs+0x172>
	CHECK(eax, regs.reg_eax);
  800324:	83 ec 0c             	sub    $0xc,%esp
  800327:	68 c4 14 80 00       	push   $0x8014c4
  80032c:	e8 ea 03 00 00       	call   80071b <cprintf>
  800331:	83 c4 10             	add    $0x10,%esp
  800334:	e9 a5 fe ff ff       	jmp    8001de <check_regs+0x1ab>
	CHECK(eip, eip);
  800339:	83 ec 0c             	sub    $0xc,%esp
  80033c:	68 c4 14 80 00       	push   $0x8014c4
  800341:	e8 d5 03 00 00       	call   80071b <cprintf>
  800346:	83 c4 10             	add    $0x10,%esp
  800349:	e9 c9 fe ff ff       	jmp    800217 <check_regs+0x1e4>
	CHECK(eflags, eflags);
  80034e:	83 ec 0c             	sub    $0xc,%esp
  800351:	68 c4 14 80 00       	push   $0x8014c4
  800356:	e8 c0 03 00 00       	call   80071b <cprintf>
	CHECK(esp, esp);
  80035b:	ff 73 28             	push   0x28(%ebx)
  80035e:	ff 76 28             	push   0x28(%esi)
  800361:	68 f5 14 80 00       	push   $0x8014f5
  800366:	68 b4 14 80 00       	push   $0x8014b4
  80036b:	e8 ab 03 00 00       	call   80071b <cprintf>
  800370:	83 c4 20             	add    $0x20,%esp
  800373:	8b 43 28             	mov    0x28(%ebx),%eax
  800376:	39 46 28             	cmp    %eax,0x28(%esi)
  800379:	0f 85 ed fe ff ff    	jne    80026c <check_regs+0x239>
  80037f:	83 ec 0c             	sub    $0xc,%esp
  800382:	68 c4 14 80 00       	push   $0x8014c4
  800387:	e8 8f 03 00 00       	call   80071b <cprintf>
	cprintf("Registers %s ", testname);
  80038c:	83 c4 08             	add    $0x8,%esp
  80038f:	ff 75 0c             	push   0xc(%ebp)
  800392:	68 f9 14 80 00       	push   $0x8014f9
  800397:	e8 7f 03 00 00       	call   80071b <cprintf>
	if (!mismatch)
  80039c:	83 c4 10             	add    $0x10,%esp
  80039f:	85 ff                	test   %edi,%edi
  8003a1:	0f 85 e5 fe ff ff    	jne    80028c <check_regs+0x259>
		cprintf("OK\n");
  8003a7:	83 ec 0c             	sub    $0xc,%esp
  8003aa:	68 c4 14 80 00       	push   $0x8014c4
  8003af:	e8 67 03 00 00       	call   80071b <cprintf>
  8003b4:	83 c4 10             	add    $0x10,%esp
}
  8003b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003ba:	5b                   	pop    %ebx
  8003bb:	5e                   	pop    %esi
  8003bc:	5f                   	pop    %edi
  8003bd:	5d                   	pop    %ebp
  8003be:	c3                   	ret    
	CHECK(esp, esp);
  8003bf:	83 ec 0c             	sub    $0xc,%esp
  8003c2:	68 c4 14 80 00       	push   $0x8014c4
  8003c7:	e8 4f 03 00 00       	call   80071b <cprintf>
	cprintf("Registers %s ", testname);
  8003cc:	83 c4 08             	add    $0x8,%esp
  8003cf:	ff 75 0c             	push   0xc(%ebp)
  8003d2:	68 f9 14 80 00       	push   $0x8014f9
  8003d7:	e8 3f 03 00 00       	call   80071b <cprintf>
  8003dc:	83 c4 10             	add    $0x10,%esp
  8003df:	e9 a8 fe ff ff       	jmp    80028c <check_regs+0x259>

008003e4 <pgfault>:

static void
pgfault(struct UTrapframe *utf)
{
  8003e4:	55                   	push   %ebp
  8003e5:	89 e5                	mov    %esp,%ebp
  8003e7:	83 ec 08             	sub    $0x8,%esp
  8003ea:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	if (utf->utf_fault_va != (uint32_t) UTEMP)
  8003ed:	8b 10                	mov    (%eax),%edx
  8003ef:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  8003f5:	0f 85 a3 00 00 00    	jne    80049e <pgfault+0xba>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
		      utf->utf_fault_va,
		      utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003fb:	8b 50 08             	mov    0x8(%eax),%edx
  8003fe:	89 15 60 20 80 00    	mov    %edx,0x802060
  800404:	8b 50 0c             	mov    0xc(%eax),%edx
  800407:	89 15 64 20 80 00    	mov    %edx,0x802064
  80040d:	8b 50 10             	mov    0x10(%eax),%edx
  800410:	89 15 68 20 80 00    	mov    %edx,0x802068
  800416:	8b 50 14             	mov    0x14(%eax),%edx
  800419:	89 15 6c 20 80 00    	mov    %edx,0x80206c
  80041f:	8b 50 18             	mov    0x18(%eax),%edx
  800422:	89 15 70 20 80 00    	mov    %edx,0x802070
  800428:	8b 50 1c             	mov    0x1c(%eax),%edx
  80042b:	89 15 74 20 80 00    	mov    %edx,0x802074
  800431:	8b 50 20             	mov    0x20(%eax),%edx
  800434:	89 15 78 20 80 00    	mov    %edx,0x802078
  80043a:	8b 50 24             	mov    0x24(%eax),%edx
  80043d:	89 15 7c 20 80 00    	mov    %edx,0x80207c
	during.eip = utf->utf_eip;
  800443:	8b 50 28             	mov    0x28(%eax),%edx
  800446:	89 15 80 20 80 00    	mov    %edx,0x802080
	during.eflags = utf->utf_eflags & ~FL_RF;
  80044c:	8b 50 2c             	mov    0x2c(%eax),%edx
  80044f:	81 e2 ff ff fe ff    	and    $0xfffeffff,%edx
  800455:	89 15 84 20 80 00    	mov    %edx,0x802084
	during.esp = utf->utf_esp;
  80045b:	8b 40 30             	mov    0x30(%eax),%eax
  80045e:	a3 88 20 80 00       	mov    %eax,0x802088
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  800463:	83 ec 08             	sub    $0x8,%esp
  800466:	68 1f 15 80 00       	push   $0x80151f
  80046b:	68 2d 15 80 00       	push   $0x80152d
  800470:	b9 60 20 80 00       	mov    $0x802060,%ecx
  800475:	ba 18 15 80 00       	mov    $0x801518,%edx
  80047a:	b8 a0 20 80 00       	mov    $0x8020a0,%eax
  80047f:	e8 af fb ff ff       	call   800033 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U | PTE_P | PTE_W)) < 0)
  800484:	83 c4 0c             	add    $0xc,%esp
  800487:	6a 07                	push   $0x7
  800489:	68 00 00 40 00       	push   $0x400000
  80048e:	6a 00                	push   $0x0
  800490:	e8 03 0c 00 00       	call   801098 <sys_page_alloc>
  800495:	83 c4 10             	add    $0x10,%esp
  800498:	85 c0                	test   %eax,%eax
  80049a:	78 1a                	js     8004b6 <pgfault+0xd2>
		panic("sys_page_alloc: %e", r);
}
  80049c:	c9                   	leave  
  80049d:	c3                   	ret    
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  80049e:	83 ec 0c             	sub    $0xc,%esp
  8004a1:	ff 70 28             	push   0x28(%eax)
  8004a4:	52                   	push   %edx
  8004a5:	68 60 15 80 00       	push   $0x801560
  8004aa:	6a 52                	push   $0x52
  8004ac:	68 07 15 80 00       	push   $0x801507
  8004b1:	e8 8a 01 00 00       	call   800640 <_panic>
		panic("sys_page_alloc: %e", r);
  8004b6:	50                   	push   %eax
  8004b7:	68 34 15 80 00       	push   $0x801534
  8004bc:	6a 5f                	push   $0x5f
  8004be:	68 07 15 80 00       	push   $0x801507
  8004c3:	e8 78 01 00 00       	call   800640 <_panic>

008004c8 <umain>:

void
umain(int argc, char **argv)
{
  8004c8:	55                   	push   %ebp
  8004c9:	89 e5                	mov    %esp,%ebp
  8004cb:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(pgfault);
  8004ce:	68 e4 03 80 00       	push   $0x8003e4
  8004d3:	e8 00 0d 00 00       	call   8011d8 <set_pgfault_handler>

	asm volatile(
  8004d8:	50                   	push   %eax
  8004d9:	9c                   	pushf  
  8004da:	58                   	pop    %eax
  8004db:	0d d5 08 00 00       	or     $0x8d5,%eax
  8004e0:	50                   	push   %eax
  8004e1:	9d                   	popf   
  8004e2:	a3 c4 20 80 00       	mov    %eax,0x8020c4
  8004e7:	8d 05 22 05 80 00    	lea    0x800522,%eax
  8004ed:	a3 c0 20 80 00       	mov    %eax,0x8020c0
  8004f2:	58                   	pop    %eax
  8004f3:	89 3d a0 20 80 00    	mov    %edi,0x8020a0
  8004f9:	89 35 a4 20 80 00    	mov    %esi,0x8020a4
  8004ff:	89 2d a8 20 80 00    	mov    %ebp,0x8020a8
  800505:	89 1d b0 20 80 00    	mov    %ebx,0x8020b0
  80050b:	89 15 b4 20 80 00    	mov    %edx,0x8020b4
  800511:	89 0d b8 20 80 00    	mov    %ecx,0x8020b8
  800517:	a3 bc 20 80 00       	mov    %eax,0x8020bc
  80051c:	89 25 c8 20 80 00    	mov    %esp,0x8020c8
  800522:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  800529:	00 00 00 
  80052c:	89 3d 20 20 80 00    	mov    %edi,0x802020
  800532:	89 35 24 20 80 00    	mov    %esi,0x802024
  800538:	89 2d 28 20 80 00    	mov    %ebp,0x802028
  80053e:	89 1d 30 20 80 00    	mov    %ebx,0x802030
  800544:	89 15 34 20 80 00    	mov    %edx,0x802034
  80054a:	89 0d 38 20 80 00    	mov    %ecx,0x802038
  800550:	a3 3c 20 80 00       	mov    %eax,0x80203c
  800555:	89 25 48 20 80 00    	mov    %esp,0x802048
  80055b:	8b 3d a0 20 80 00    	mov    0x8020a0,%edi
  800561:	8b 35 a4 20 80 00    	mov    0x8020a4,%esi
  800567:	8b 2d a8 20 80 00    	mov    0x8020a8,%ebp
  80056d:	8b 1d b0 20 80 00    	mov    0x8020b0,%ebx
  800573:	8b 15 b4 20 80 00    	mov    0x8020b4,%edx
  800579:	8b 0d b8 20 80 00    	mov    0x8020b8,%ecx
  80057f:	a1 bc 20 80 00       	mov    0x8020bc,%eax
  800584:	8b 25 c8 20 80 00    	mov    0x8020c8,%esp
  80058a:	50                   	push   %eax
  80058b:	9c                   	pushf  
  80058c:	58                   	pop    %eax
  80058d:	a3 44 20 80 00       	mov    %eax,0x802044
  800592:	58                   	pop    %eax
	        : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int *) UTEMP != 42)
  800593:	83 c4 10             	add    $0x10,%esp
  800596:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  80059d:	75 30                	jne    8005cf <umain+0x107>
		cprintf("EIP after page-fault MISMATCH\n");
	after.eip = before.eip;
  80059f:	a1 c0 20 80 00       	mov    0x8020c0,%eax
  8005a4:	a3 40 20 80 00       	mov    %eax,0x802040

	check_regs(&before, "before", &after, "after", "after page-fault");
  8005a9:	83 ec 08             	sub    $0x8,%esp
  8005ac:	68 47 15 80 00       	push   $0x801547
  8005b1:	68 58 15 80 00       	push   $0x801558
  8005b6:	b9 20 20 80 00       	mov    $0x802020,%ecx
  8005bb:	ba 18 15 80 00       	mov    $0x801518,%edx
  8005c0:	b8 a0 20 80 00       	mov    $0x8020a0,%eax
  8005c5:	e8 69 fa ff ff       	call   800033 <check_regs>
}
  8005ca:	83 c4 10             	add    $0x10,%esp
  8005cd:	c9                   	leave  
  8005ce:	c3                   	ret    
		cprintf("EIP after page-fault MISMATCH\n");
  8005cf:	83 ec 0c             	sub    $0xc,%esp
  8005d2:	68 94 15 80 00       	push   $0x801594
  8005d7:	e8 3f 01 00 00       	call   80071b <cprintf>
  8005dc:	83 c4 10             	add    $0x10,%esp
  8005df:	eb be                	jmp    80059f <umain+0xd7>

008005e1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8005e1:	55                   	push   %ebp
  8005e2:	89 e5                	mov    %esp,%ebp
  8005e4:	56                   	push   %esi
  8005e5:	53                   	push   %ebx
  8005e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8005e9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	envid_t id = sys_getenvid();
  8005ec:	e8 5c 0a 00 00       	call   80104d <sys_getenvid>
	if (id >= 0)
  8005f1:	85 c0                	test   %eax,%eax
  8005f3:	78 15                	js     80060a <libmain+0x29>
		thisenv = &envs[ENVX(id)];
  8005f5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8005fa:	69 c0 88 00 00 00    	imul   $0x88,%eax,%eax
  800600:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800605:	a3 cc 20 80 00       	mov    %eax,0x8020cc

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80060a:	85 db                	test   %ebx,%ebx
  80060c:	7e 07                	jle    800615 <libmain+0x34>
		binaryname = argv[0];
  80060e:	8b 06                	mov    (%esi),%eax
  800610:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800615:	83 ec 08             	sub    $0x8,%esp
  800618:	56                   	push   %esi
  800619:	53                   	push   %ebx
  80061a:	e8 a9 fe ff ff       	call   8004c8 <umain>

	// exit gracefully
	exit();
  80061f:	e8 0a 00 00 00       	call   80062e <exit>
}
  800624:	83 c4 10             	add    $0x10,%esp
  800627:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80062a:	5b                   	pop    %ebx
  80062b:	5e                   	pop    %esi
  80062c:	5d                   	pop    %ebp
  80062d:	c3                   	ret    

0080062e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80062e:	55                   	push   %ebp
  80062f:	89 e5                	mov    %esp,%ebp
  800631:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800634:	6a 00                	push   $0x0
  800636:	e8 f0 09 00 00       	call   80102b <sys_env_destroy>
}
  80063b:	83 c4 10             	add    $0x10,%esp
  80063e:	c9                   	leave  
  80063f:	c3                   	ret    

00800640 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800640:	55                   	push   %ebp
  800641:	89 e5                	mov    %esp,%ebp
  800643:	56                   	push   %esi
  800644:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800645:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800648:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80064e:	e8 fa 09 00 00       	call   80104d <sys_getenvid>
  800653:	83 ec 0c             	sub    $0xc,%esp
  800656:	ff 75 0c             	push   0xc(%ebp)
  800659:	ff 75 08             	push   0x8(%ebp)
  80065c:	56                   	push   %esi
  80065d:	50                   	push   %eax
  80065e:	68 c0 15 80 00       	push   $0x8015c0
  800663:	e8 b3 00 00 00       	call   80071b <cprintf>
	        sys_getenvid(),
	        binaryname,
	        file,
	        line);
	vcprintf(fmt, ap);
  800668:	83 c4 18             	add    $0x18,%esp
  80066b:	53                   	push   %ebx
  80066c:	ff 75 10             	push   0x10(%ebp)
  80066f:	e8 56 00 00 00       	call   8006ca <vcprintf>
	cprintf("\n");
  800674:	c7 04 24 d0 14 80 00 	movl   $0x8014d0,(%esp)
  80067b:	e8 9b 00 00 00       	call   80071b <cprintf>
  800680:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800683:	cc                   	int3   
  800684:	eb fd                	jmp    800683 <_panic+0x43>

00800686 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800686:	55                   	push   %ebp
  800687:	89 e5                	mov    %esp,%ebp
  800689:	53                   	push   %ebx
  80068a:	83 ec 04             	sub    $0x4,%esp
  80068d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800690:	8b 13                	mov    (%ebx),%edx
  800692:	8d 42 01             	lea    0x1(%edx),%eax
  800695:	89 03                	mov    %eax,(%ebx)
  800697:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80069a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256 - 1) {
  80069e:	3d ff 00 00 00       	cmp    $0xff,%eax
  8006a3:	74 09                	je     8006ae <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8006a5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8006a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006ac:	c9                   	leave  
  8006ad:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8006ae:	83 ec 08             	sub    $0x8,%esp
  8006b1:	68 ff 00 00 00       	push   $0xff
  8006b6:	8d 43 08             	lea    0x8(%ebx),%eax
  8006b9:	50                   	push   %eax
  8006ba:	e8 22 09 00 00       	call   800fe1 <sys_cputs>
		b->idx = 0;
  8006bf:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8006c5:	83 c4 10             	add    $0x10,%esp
  8006c8:	eb db                	jmp    8006a5 <putch+0x1f>

008006ca <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8006ca:	55                   	push   %ebp
  8006cb:	89 e5                	mov    %esp,%ebp
  8006cd:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8006d3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8006da:	00 00 00 
	b.cnt = 0;
  8006dd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8006e4:	00 00 00 
	vprintfmt((void *) putch, &b, fmt, ap);
  8006e7:	ff 75 0c             	push   0xc(%ebp)
  8006ea:	ff 75 08             	push   0x8(%ebp)
  8006ed:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8006f3:	50                   	push   %eax
  8006f4:	68 86 06 80 00       	push   $0x800686
  8006f9:	e8 74 01 00 00       	call   800872 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006fe:	83 c4 08             	add    $0x8,%esp
  800701:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800707:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80070d:	50                   	push   %eax
  80070e:	e8 ce 08 00 00       	call   800fe1 <sys_cputs>

	return b.cnt;
}
  800713:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800719:	c9                   	leave  
  80071a:	c3                   	ret    

0080071b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80071b:	55                   	push   %ebp
  80071c:	89 e5                	mov    %esp,%ebp
  80071e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800721:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800724:	50                   	push   %eax
  800725:	ff 75 08             	push   0x8(%ebp)
  800728:	e8 9d ff ff ff       	call   8006ca <vcprintf>
	va_end(ap);

	return cnt;
}
  80072d:	c9                   	leave  
  80072e:	c3                   	ret    

0080072f <printnum>:
         void *putdat,
         unsigned long long num,
         unsigned base,
         int width,
         int padc)
{
  80072f:	55                   	push   %ebp
  800730:	89 e5                	mov    %esp,%ebp
  800732:	57                   	push   %edi
  800733:	56                   	push   %esi
  800734:	53                   	push   %ebx
  800735:	83 ec 1c             	sub    $0x1c,%esp
  800738:	89 c7                	mov    %eax,%edi
  80073a:	89 d6                	mov    %edx,%esi
  80073c:	8b 45 08             	mov    0x8(%ebp),%eax
  80073f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800742:	89 d1                	mov    %edx,%ecx
  800744:	89 c2                	mov    %eax,%edx
  800746:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800749:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80074c:	8b 45 10             	mov    0x10(%ebp),%eax
  80074f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800752:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800755:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80075c:	39 c2                	cmp    %eax,%edx
  80075e:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800761:	72 3e                	jb     8007a1 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800763:	83 ec 0c             	sub    $0xc,%esp
  800766:	ff 75 18             	push   0x18(%ebp)
  800769:	83 eb 01             	sub    $0x1,%ebx
  80076c:	53                   	push   %ebx
  80076d:	50                   	push   %eax
  80076e:	83 ec 08             	sub    $0x8,%esp
  800771:	ff 75 e4             	push   -0x1c(%ebp)
  800774:	ff 75 e0             	push   -0x20(%ebp)
  800777:	ff 75 dc             	push   -0x24(%ebp)
  80077a:	ff 75 d8             	push   -0x28(%ebp)
  80077d:	e8 ce 0a 00 00       	call   801250 <__udivdi3>
  800782:	83 c4 18             	add    $0x18,%esp
  800785:	52                   	push   %edx
  800786:	50                   	push   %eax
  800787:	89 f2                	mov    %esi,%edx
  800789:	89 f8                	mov    %edi,%eax
  80078b:	e8 9f ff ff ff       	call   80072f <printnum>
  800790:	83 c4 20             	add    $0x20,%esp
  800793:	eb 13                	jmp    8007a8 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800795:	83 ec 08             	sub    $0x8,%esp
  800798:	56                   	push   %esi
  800799:	ff 75 18             	push   0x18(%ebp)
  80079c:	ff d7                	call   *%edi
  80079e:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8007a1:	83 eb 01             	sub    $0x1,%ebx
  8007a4:	85 db                	test   %ebx,%ebx
  8007a6:	7f ed                	jg     800795 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007a8:	83 ec 08             	sub    $0x8,%esp
  8007ab:	56                   	push   %esi
  8007ac:	83 ec 04             	sub    $0x4,%esp
  8007af:	ff 75 e4             	push   -0x1c(%ebp)
  8007b2:	ff 75 e0             	push   -0x20(%ebp)
  8007b5:	ff 75 dc             	push   -0x24(%ebp)
  8007b8:	ff 75 d8             	push   -0x28(%ebp)
  8007bb:	e8 b0 0b 00 00       	call   801370 <__umoddi3>
  8007c0:	83 c4 14             	add    $0x14,%esp
  8007c3:	0f be 80 e3 15 80 00 	movsbl 0x8015e3(%eax),%eax
  8007ca:	50                   	push   %eax
  8007cb:	ff d7                	call   *%edi
}
  8007cd:	83 c4 10             	add    $0x10,%esp
  8007d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007d3:	5b                   	pop    %ebx
  8007d4:	5e                   	pop    %esi
  8007d5:	5f                   	pop    %edi
  8007d6:	5d                   	pop    %ebp
  8007d7:	c3                   	ret    

008007d8 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007d8:	83 fa 01             	cmp    $0x1,%edx
  8007db:	7f 13                	jg     8007f0 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8007dd:	85 d2                	test   %edx,%edx
  8007df:	74 1c                	je     8007fd <getuint+0x25>
		return va_arg(*ap, unsigned long);
  8007e1:	8b 10                	mov    (%eax),%edx
  8007e3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007e6:	89 08                	mov    %ecx,(%eax)
  8007e8:	8b 02                	mov    (%edx),%eax
  8007ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8007ef:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  8007f0:	8b 10                	mov    (%eax),%edx
  8007f2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8007f5:	89 08                	mov    %ecx,(%eax)
  8007f7:	8b 02                	mov    (%edx),%eax
  8007f9:	8b 52 04             	mov    0x4(%edx),%edx
  8007fc:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  8007fd:	8b 10                	mov    (%eax),%edx
  8007ff:	8d 4a 04             	lea    0x4(%edx),%ecx
  800802:	89 08                	mov    %ecx,(%eax)
  800804:	8b 02                	mov    (%edx),%eax
  800806:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80080b:	c3                   	ret    

0080080c <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80080c:	83 fa 01             	cmp    $0x1,%edx
  80080f:	7f 0f                	jg     800820 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  800811:	85 d2                	test   %edx,%edx
  800813:	74 18                	je     80082d <getint+0x21>
		return va_arg(*ap, long);
  800815:	8b 10                	mov    (%eax),%edx
  800817:	8d 4a 04             	lea    0x4(%edx),%ecx
  80081a:	89 08                	mov    %ecx,(%eax)
  80081c:	8b 02                	mov    (%edx),%eax
  80081e:	99                   	cltd   
  80081f:	c3                   	ret    
		return va_arg(*ap, long long);
  800820:	8b 10                	mov    (%eax),%edx
  800822:	8d 4a 08             	lea    0x8(%edx),%ecx
  800825:	89 08                	mov    %ecx,(%eax)
  800827:	8b 02                	mov    (%edx),%eax
  800829:	8b 52 04             	mov    0x4(%edx),%edx
  80082c:	c3                   	ret    
	else
		return va_arg(*ap, int);
  80082d:	8b 10                	mov    (%eax),%edx
  80082f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800832:	89 08                	mov    %ecx,(%eax)
  800834:	8b 02                	mov    (%edx),%eax
  800836:	99                   	cltd   
}
  800837:	c3                   	ret    

00800838 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800838:	55                   	push   %ebp
  800839:	89 e5                	mov    %esp,%ebp
  80083b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80083e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800842:	8b 10                	mov    (%eax),%edx
  800844:	3b 50 04             	cmp    0x4(%eax),%edx
  800847:	73 0a                	jae    800853 <sprintputch+0x1b>
		*b->buf++ = ch;
  800849:	8d 4a 01             	lea    0x1(%edx),%ecx
  80084c:	89 08                	mov    %ecx,(%eax)
  80084e:	8b 45 08             	mov    0x8(%ebp),%eax
  800851:	88 02                	mov    %al,(%edx)
}
  800853:	5d                   	pop    %ebp
  800854:	c3                   	ret    

00800855 <printfmt>:
{
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80085b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80085e:	50                   	push   %eax
  80085f:	ff 75 10             	push   0x10(%ebp)
  800862:	ff 75 0c             	push   0xc(%ebp)
  800865:	ff 75 08             	push   0x8(%ebp)
  800868:	e8 05 00 00 00       	call   800872 <vprintfmt>
}
  80086d:	83 c4 10             	add    $0x10,%esp
  800870:	c9                   	leave  
  800871:	c3                   	ret    

00800872 <vprintfmt>:
{
  800872:	55                   	push   %ebp
  800873:	89 e5                	mov    %esp,%ebp
  800875:	57                   	push   %edi
  800876:	56                   	push   %esi
  800877:	53                   	push   %ebx
  800878:	83 ec 2c             	sub    $0x2c,%esp
  80087b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80087e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800881:	8b 7d 10             	mov    0x10(%ebp),%edi
  800884:	eb 0a                	jmp    800890 <vprintfmt+0x1e>
			putch(ch, putdat);
  800886:	83 ec 08             	sub    $0x8,%esp
  800889:	56                   	push   %esi
  80088a:	50                   	push   %eax
  80088b:	ff d3                	call   *%ebx
  80088d:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800890:	83 c7 01             	add    $0x1,%edi
  800893:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800897:	83 f8 25             	cmp    $0x25,%eax
  80089a:	74 0c                	je     8008a8 <vprintfmt+0x36>
			if (ch == '\0')
  80089c:	85 c0                	test   %eax,%eax
  80089e:	75 e6                	jne    800886 <vprintfmt+0x14>
}
  8008a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008a3:	5b                   	pop    %ebx
  8008a4:	5e                   	pop    %esi
  8008a5:	5f                   	pop    %edi
  8008a6:	5d                   	pop    %ebp
  8008a7:	c3                   	ret    
		padc = ' ';
  8008a8:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
		altflag = 0;
  8008ac:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8008b3:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8008ba:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8008c1:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8008c6:	8d 47 01             	lea    0x1(%edi),%eax
  8008c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008cc:	0f b6 17             	movzbl (%edi),%edx
  8008cf:	8d 42 dd             	lea    -0x23(%edx),%eax
  8008d2:	3c 55                	cmp    $0x55,%al
  8008d4:	0f 87 b7 02 00 00    	ja     800b91 <vprintfmt+0x31f>
  8008da:	0f b6 c0             	movzbl %al,%eax
  8008dd:	ff 24 85 a0 16 80 00 	jmp    *0x8016a0(,%eax,4)
  8008e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8008e7:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  8008eb:	eb d9                	jmp    8008c6 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8008ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008f0:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  8008f4:	eb d0                	jmp    8008c6 <vprintfmt+0x54>
  8008f6:	0f b6 d2             	movzbl %dl,%edx
  8008f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0;; ++fmt) {
  8008fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800901:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800904:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800907:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80090b:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80090e:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800911:	83 f9 09             	cmp    $0x9,%ecx
  800914:	77 52                	ja     800968 <vprintfmt+0xf6>
			for (precision = 0;; ++fmt) {
  800916:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800919:	eb e9                	jmp    800904 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  80091b:	8b 45 14             	mov    0x14(%ebp),%eax
  80091e:	8d 50 04             	lea    0x4(%eax),%edx
  800921:	89 55 14             	mov    %edx,0x14(%ebp)
  800924:	8b 00                	mov    (%eax),%eax
  800926:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800929:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80092c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800930:	79 94                	jns    8008c6 <vprintfmt+0x54>
				width = precision, precision = -1;
  800932:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800935:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800938:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80093f:	eb 85                	jmp    8008c6 <vprintfmt+0x54>
  800941:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800944:	85 d2                	test   %edx,%edx
  800946:	b8 00 00 00 00       	mov    $0x0,%eax
  80094b:	0f 49 c2             	cmovns %edx,%eax
  80094e:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800951:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800954:	e9 6d ff ff ff       	jmp    8008c6 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800959:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80095c:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800963:	e9 5e ff ff ff       	jmp    8008c6 <vprintfmt+0x54>
  800968:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80096b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80096e:	eb bc                	jmp    80092c <vprintfmt+0xba>
			lflag++;
  800970:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800973:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800976:	e9 4b ff ff ff       	jmp    8008c6 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  80097b:	8b 45 14             	mov    0x14(%ebp),%eax
  80097e:	8d 50 04             	lea    0x4(%eax),%edx
  800981:	89 55 14             	mov    %edx,0x14(%ebp)
  800984:	83 ec 08             	sub    $0x8,%esp
  800987:	56                   	push   %esi
  800988:	ff 30                	push   (%eax)
  80098a:	ff d3                	call   *%ebx
			break;
  80098c:	83 c4 10             	add    $0x10,%esp
  80098f:	e9 94 01 00 00       	jmp    800b28 <vprintfmt+0x2b6>
			err = va_arg(ap, int);
  800994:	8b 45 14             	mov    0x14(%ebp),%eax
  800997:	8d 50 04             	lea    0x4(%eax),%edx
  80099a:	89 55 14             	mov    %edx,0x14(%ebp)
  80099d:	8b 10                	mov    (%eax),%edx
  80099f:	89 d0                	mov    %edx,%eax
  8009a1:	f7 d8                	neg    %eax
  8009a3:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8009a6:	83 f8 08             	cmp    $0x8,%eax
  8009a9:	7f 20                	jg     8009cb <vprintfmt+0x159>
  8009ab:	8b 14 85 00 18 80 00 	mov    0x801800(,%eax,4),%edx
  8009b2:	85 d2                	test   %edx,%edx
  8009b4:	74 15                	je     8009cb <vprintfmt+0x159>
				printfmt(putch, putdat, "%s", p);
  8009b6:	52                   	push   %edx
  8009b7:	68 04 16 80 00       	push   $0x801604
  8009bc:	56                   	push   %esi
  8009bd:	53                   	push   %ebx
  8009be:	e8 92 fe ff ff       	call   800855 <printfmt>
  8009c3:	83 c4 10             	add    $0x10,%esp
  8009c6:	e9 5d 01 00 00       	jmp    800b28 <vprintfmt+0x2b6>
				printfmt(putch, putdat, "error %d", err);
  8009cb:	50                   	push   %eax
  8009cc:	68 fb 15 80 00       	push   $0x8015fb
  8009d1:	56                   	push   %esi
  8009d2:	53                   	push   %ebx
  8009d3:	e8 7d fe ff ff       	call   800855 <printfmt>
  8009d8:	83 c4 10             	add    $0x10,%esp
  8009db:	e9 48 01 00 00       	jmp    800b28 <vprintfmt+0x2b6>
			if ((p = va_arg(ap, char *)) == NULL)
  8009e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8009e3:	8d 50 04             	lea    0x4(%eax),%edx
  8009e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8009e9:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8009eb:	85 ff                	test   %edi,%edi
  8009ed:	b8 f4 15 80 00       	mov    $0x8015f4,%eax
  8009f2:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8009f5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8009f9:	7e 06                	jle    800a01 <vprintfmt+0x18f>
  8009fb:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8009ff:	75 0a                	jne    800a0b <vprintfmt+0x199>
  800a01:	89 f8                	mov    %edi,%eax
  800a03:	03 45 e0             	add    -0x20(%ebp),%eax
  800a06:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a09:	eb 59                	jmp    800a64 <vprintfmt+0x1f2>
				for (width -= strnlen(p, precision); width > 0;
  800a0b:	83 ec 08             	sub    $0x8,%esp
  800a0e:	ff 75 d8             	push   -0x28(%ebp)
  800a11:	57                   	push   %edi
  800a12:	e8 1a 02 00 00       	call   800c31 <strnlen>
  800a17:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800a1a:	29 c1                	sub    %eax,%ecx
  800a1c:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800a1f:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800a22:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  800a26:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a29:	89 7d d0             	mov    %edi,-0x30(%ebp)
  800a2c:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0;
  800a2e:	eb 0f                	jmp    800a3f <vprintfmt+0x1cd>
					putch(padc, putdat);
  800a30:	83 ec 08             	sub    $0x8,%esp
  800a33:	56                   	push   %esi
  800a34:	ff 75 e0             	push   -0x20(%ebp)
  800a37:	ff d3                	call   *%ebx
				     width--)
  800a39:	83 ef 01             	sub    $0x1,%edi
  800a3c:	83 c4 10             	add    $0x10,%esp
				for (width -= strnlen(p, precision); width > 0;
  800a3f:	85 ff                	test   %edi,%edi
  800a41:	7f ed                	jg     800a30 <vprintfmt+0x1be>
  800a43:	8b 7d d0             	mov    -0x30(%ebp),%edi
  800a46:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800a49:	85 c9                	test   %ecx,%ecx
  800a4b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a50:	0f 49 c1             	cmovns %ecx,%eax
  800a53:	29 c1                	sub    %eax,%ecx
  800a55:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800a58:	eb a7                	jmp    800a01 <vprintfmt+0x18f>
					putch(ch, putdat);
  800a5a:	83 ec 08             	sub    $0x8,%esp
  800a5d:	56                   	push   %esi
  800a5e:	52                   	push   %edx
  800a5f:	ff d3                	call   *%ebx
  800a61:	83 c4 10             	add    $0x10,%esp
  800a64:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800a67:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' &&
  800a69:	83 c7 01             	add    $0x1,%edi
  800a6c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800a70:	0f be d0             	movsbl %al,%edx
  800a73:	85 d2                	test   %edx,%edx
  800a75:	74 42                	je     800ab9 <vprintfmt+0x247>
  800a77:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800a7b:	78 06                	js     800a83 <vprintfmt+0x211>
			       (precision < 0 || --precision >= 0);
  800a7d:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800a81:	78 1e                	js     800aa1 <vprintfmt+0x22f>
				if (altflag && (ch < ' ' || ch > '~'))
  800a83:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800a87:	74 d1                	je     800a5a <vprintfmt+0x1e8>
  800a89:	0f be c0             	movsbl %al,%eax
  800a8c:	83 e8 20             	sub    $0x20,%eax
  800a8f:	83 f8 5e             	cmp    $0x5e,%eax
  800a92:	76 c6                	jbe    800a5a <vprintfmt+0x1e8>
					putch('?', putdat);
  800a94:	83 ec 08             	sub    $0x8,%esp
  800a97:	56                   	push   %esi
  800a98:	6a 3f                	push   $0x3f
  800a9a:	ff d3                	call   *%ebx
  800a9c:	83 c4 10             	add    $0x10,%esp
  800a9f:	eb c3                	jmp    800a64 <vprintfmt+0x1f2>
  800aa1:	89 cf                	mov    %ecx,%edi
  800aa3:	eb 0e                	jmp    800ab3 <vprintfmt+0x241>
				putch(' ', putdat);
  800aa5:	83 ec 08             	sub    $0x8,%esp
  800aa8:	56                   	push   %esi
  800aa9:	6a 20                	push   $0x20
  800aab:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  800aad:	83 ef 01             	sub    $0x1,%edi
  800ab0:	83 c4 10             	add    $0x10,%esp
  800ab3:	85 ff                	test   %edi,%edi
  800ab5:	7f ee                	jg     800aa5 <vprintfmt+0x233>
  800ab7:	eb 6f                	jmp    800b28 <vprintfmt+0x2b6>
  800ab9:	89 cf                	mov    %ecx,%edi
  800abb:	eb f6                	jmp    800ab3 <vprintfmt+0x241>
			num = getint(&ap, lflag);
  800abd:	89 ca                	mov    %ecx,%edx
  800abf:	8d 45 14             	lea    0x14(%ebp),%eax
  800ac2:	e8 45 fd ff ff       	call   80080c <getint>
  800ac7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800aca:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800acd:	85 d2                	test   %edx,%edx
  800acf:	78 0b                	js     800adc <vprintfmt+0x26a>
			num = getint(&ap, lflag);
  800ad1:	89 d1                	mov    %edx,%ecx
  800ad3:	89 c2                	mov    %eax,%edx
			base = 10;
  800ad5:	bf 0a 00 00 00       	mov    $0xa,%edi
  800ada:	eb 32                	jmp    800b0e <vprintfmt+0x29c>
				putch('-', putdat);
  800adc:	83 ec 08             	sub    $0x8,%esp
  800adf:	56                   	push   %esi
  800ae0:	6a 2d                	push   $0x2d
  800ae2:	ff d3                	call   *%ebx
				num = -(long long) num;
  800ae4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800ae7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800aea:	f7 da                	neg    %edx
  800aec:	83 d1 00             	adc    $0x0,%ecx
  800aef:	f7 d9                	neg    %ecx
  800af1:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800af4:	bf 0a 00 00 00       	mov    $0xa,%edi
  800af9:	eb 13                	jmp    800b0e <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  800afb:	89 ca                	mov    %ecx,%edx
  800afd:	8d 45 14             	lea    0x14(%ebp),%eax
  800b00:	e8 d3 fc ff ff       	call   8007d8 <getuint>
  800b05:	89 d1                	mov    %edx,%ecx
  800b07:	89 c2                	mov    %eax,%edx
			base = 10;
  800b09:	bf 0a 00 00 00       	mov    $0xa,%edi
			printnum(putch, putdat, num, base, width, padc);
  800b0e:	83 ec 0c             	sub    $0xc,%esp
  800b11:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  800b15:	50                   	push   %eax
  800b16:	ff 75 e0             	push   -0x20(%ebp)
  800b19:	57                   	push   %edi
  800b1a:	51                   	push   %ecx
  800b1b:	52                   	push   %edx
  800b1c:	89 f2                	mov    %esi,%edx
  800b1e:	89 d8                	mov    %ebx,%eax
  800b20:	e8 0a fc ff ff       	call   80072f <printnum>
			break;
  800b25:	83 c4 20             	add    $0x20,%esp
{
  800b28:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800b2b:	e9 60 fd ff ff       	jmp    800890 <vprintfmt+0x1e>
			num = getuint(&ap, lflag);
  800b30:	89 ca                	mov    %ecx,%edx
  800b32:	8d 45 14             	lea    0x14(%ebp),%eax
  800b35:	e8 9e fc ff ff       	call   8007d8 <getuint>
  800b3a:	89 d1                	mov    %edx,%ecx
  800b3c:	89 c2                	mov    %eax,%edx
			base = 8;
  800b3e:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  800b43:	eb c9                	jmp    800b0e <vprintfmt+0x29c>
			putch('0', putdat);
  800b45:	83 ec 08             	sub    $0x8,%esp
  800b48:	56                   	push   %esi
  800b49:	6a 30                	push   $0x30
  800b4b:	ff d3                	call   *%ebx
			putch('x', putdat);
  800b4d:	83 c4 08             	add    $0x8,%esp
  800b50:	56                   	push   %esi
  800b51:	6a 78                	push   $0x78
  800b53:	ff d3                	call   *%ebx
			num = (unsigned long long) (uintptr_t) va_arg(ap, void *);
  800b55:	8b 45 14             	mov    0x14(%ebp),%eax
  800b58:	8d 50 04             	lea    0x4(%eax),%edx
  800b5b:	89 55 14             	mov    %edx,0x14(%ebp)
  800b5e:	8b 10                	mov    (%eax),%edx
  800b60:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800b65:	83 c4 10             	add    $0x10,%esp
			base = 16;
  800b68:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  800b6d:	eb 9f                	jmp    800b0e <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  800b6f:	89 ca                	mov    %ecx,%edx
  800b71:	8d 45 14             	lea    0x14(%ebp),%eax
  800b74:	e8 5f fc ff ff       	call   8007d8 <getuint>
  800b79:	89 d1                	mov    %edx,%ecx
  800b7b:	89 c2                	mov    %eax,%edx
			base = 16;
  800b7d:	bf 10 00 00 00       	mov    $0x10,%edi
  800b82:	eb 8a                	jmp    800b0e <vprintfmt+0x29c>
			putch(ch, putdat);
  800b84:	83 ec 08             	sub    $0x8,%esp
  800b87:	56                   	push   %esi
  800b88:	6a 25                	push   $0x25
  800b8a:	ff d3                	call   *%ebx
			break;
  800b8c:	83 c4 10             	add    $0x10,%esp
  800b8f:	eb 97                	jmp    800b28 <vprintfmt+0x2b6>
			putch('%', putdat);
  800b91:	83 ec 08             	sub    $0x8,%esp
  800b94:	56                   	push   %esi
  800b95:	6a 25                	push   $0x25
  800b97:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b99:	83 c4 10             	add    $0x10,%esp
  800b9c:	89 f8                	mov    %edi,%eax
  800b9e:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800ba2:	74 05                	je     800ba9 <vprintfmt+0x337>
  800ba4:	83 e8 01             	sub    $0x1,%eax
  800ba7:	eb f5                	jmp    800b9e <vprintfmt+0x32c>
  800ba9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800bac:	e9 77 ff ff ff       	jmp    800b28 <vprintfmt+0x2b6>

00800bb1 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800bb1:	55                   	push   %ebp
  800bb2:	89 e5                	mov    %esp,%ebp
  800bb4:	83 ec 18             	sub    $0x18,%esp
  800bb7:	8b 45 08             	mov    0x8(%ebp),%eax
  800bba:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = { buf, buf + n - 1, 0 };
  800bbd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800bc0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800bc4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800bc7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800bce:	85 c0                	test   %eax,%eax
  800bd0:	74 26                	je     800bf8 <vsnprintf+0x47>
  800bd2:	85 d2                	test   %edx,%edx
  800bd4:	7e 22                	jle    800bf8 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *) sprintputch, &b, fmt, ap);
  800bd6:	ff 75 14             	push   0x14(%ebp)
  800bd9:	ff 75 10             	push   0x10(%ebp)
  800bdc:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800bdf:	50                   	push   %eax
  800be0:	68 38 08 80 00       	push   $0x800838
  800be5:	e8 88 fc ff ff       	call   800872 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800bea:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bed:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800bf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bf3:	83 c4 10             	add    $0x10,%esp
}
  800bf6:	c9                   	leave  
  800bf7:	c3                   	ret    
		return -E_INVAL;
  800bf8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800bfd:	eb f7                	jmp    800bf6 <vsnprintf+0x45>

00800bff <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800bff:	55                   	push   %ebp
  800c00:	89 e5                	mov    %esp,%ebp
  800c02:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c05:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c08:	50                   	push   %eax
  800c09:	ff 75 10             	push   0x10(%ebp)
  800c0c:	ff 75 0c             	push   0xc(%ebp)
  800c0f:	ff 75 08             	push   0x8(%ebp)
  800c12:	e8 9a ff ff ff       	call   800bb1 <vsnprintf>
	va_end(ap);

	return rc;
}
  800c17:	c9                   	leave  
  800c18:	c3                   	ret    

00800c19 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c19:	55                   	push   %ebp
  800c1a:	89 e5                	mov    %esp,%ebp
  800c1c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c1f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c24:	eb 03                	jmp    800c29 <strlen+0x10>
		n++;
  800c26:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800c29:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800c2d:	75 f7                	jne    800c26 <strlen+0xd>
	return n;
}
  800c2f:	5d                   	pop    %ebp
  800c30:	c3                   	ret    

00800c31 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c31:	55                   	push   %ebp
  800c32:	89 e5                	mov    %esp,%ebp
  800c34:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c37:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c3a:	b8 00 00 00 00       	mov    $0x0,%eax
  800c3f:	eb 03                	jmp    800c44 <strnlen+0x13>
		n++;
  800c41:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c44:	39 d0                	cmp    %edx,%eax
  800c46:	74 08                	je     800c50 <strnlen+0x1f>
  800c48:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800c4c:	75 f3                	jne    800c41 <strnlen+0x10>
  800c4e:	89 c2                	mov    %eax,%edx
	return n;
}
  800c50:	89 d0                	mov    %edx,%eax
  800c52:	5d                   	pop    %ebp
  800c53:	c3                   	ret    

00800c54 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c54:	55                   	push   %ebp
  800c55:	89 e5                	mov    %esp,%ebp
  800c57:	53                   	push   %ebx
  800c58:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c5b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800c5e:	b8 00 00 00 00       	mov    $0x0,%eax
  800c63:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800c67:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800c6a:	83 c0 01             	add    $0x1,%eax
  800c6d:	84 d2                	test   %dl,%dl
  800c6f:	75 f2                	jne    800c63 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800c71:	89 c8                	mov    %ecx,%eax
  800c73:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c76:	c9                   	leave  
  800c77:	c3                   	ret    

00800c78 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c78:	55                   	push   %ebp
  800c79:	89 e5                	mov    %esp,%ebp
  800c7b:	53                   	push   %ebx
  800c7c:	83 ec 10             	sub    $0x10,%esp
  800c7f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800c82:	53                   	push   %ebx
  800c83:	e8 91 ff ff ff       	call   800c19 <strlen>
  800c88:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800c8b:	ff 75 0c             	push   0xc(%ebp)
  800c8e:	01 d8                	add    %ebx,%eax
  800c90:	50                   	push   %eax
  800c91:	e8 be ff ff ff       	call   800c54 <strcpy>
	return dst;
}
  800c96:	89 d8                	mov    %ebx,%eax
  800c98:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c9b:	c9                   	leave  
  800c9c:	c3                   	ret    

00800c9d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size)
{
  800c9d:	55                   	push   %ebp
  800c9e:	89 e5                	mov    %esp,%ebp
  800ca0:	56                   	push   %esi
  800ca1:	53                   	push   %ebx
  800ca2:	8b 75 08             	mov    0x8(%ebp),%esi
  800ca5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ca8:	89 f3                	mov    %esi,%ebx
  800caa:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cad:	89 f0                	mov    %esi,%eax
  800caf:	eb 0f                	jmp    800cc0 <strncpy+0x23>
		*dst++ = *src;
  800cb1:	83 c0 01             	add    $0x1,%eax
  800cb4:	0f b6 0a             	movzbl (%edx),%ecx
  800cb7:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800cba:	80 f9 01             	cmp    $0x1,%cl
  800cbd:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800cc0:	39 d8                	cmp    %ebx,%eax
  800cc2:	75 ed                	jne    800cb1 <strncpy+0x14>
	}
	return ret;
}
  800cc4:	89 f0                	mov    %esi,%eax
  800cc6:	5b                   	pop    %ebx
  800cc7:	5e                   	pop    %esi
  800cc8:	5d                   	pop    %ebp
  800cc9:	c3                   	ret    

00800cca <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800cca:	55                   	push   %ebp
  800ccb:	89 e5                	mov    %esp,%ebp
  800ccd:	56                   	push   %esi
  800cce:	53                   	push   %ebx
  800ccf:	8b 75 08             	mov    0x8(%ebp),%esi
  800cd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd5:	8b 55 10             	mov    0x10(%ebp),%edx
  800cd8:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800cda:	85 d2                	test   %edx,%edx
  800cdc:	74 21                	je     800cff <strlcpy+0x35>
  800cde:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800ce2:	89 f2                	mov    %esi,%edx
  800ce4:	eb 09                	jmp    800cef <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800ce6:	83 c1 01             	add    $0x1,%ecx
  800ce9:	83 c2 01             	add    $0x1,%edx
  800cec:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800cef:	39 c2                	cmp    %eax,%edx
  800cf1:	74 09                	je     800cfc <strlcpy+0x32>
  800cf3:	0f b6 19             	movzbl (%ecx),%ebx
  800cf6:	84 db                	test   %bl,%bl
  800cf8:	75 ec                	jne    800ce6 <strlcpy+0x1c>
  800cfa:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800cfc:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800cff:	29 f0                	sub    %esi,%eax
}
  800d01:	5b                   	pop    %ebx
  800d02:	5e                   	pop    %esi
  800d03:	5d                   	pop    %ebp
  800d04:	c3                   	ret    

00800d05 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d05:	55                   	push   %ebp
  800d06:	89 e5                	mov    %esp,%ebp
  800d08:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d0b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d0e:	eb 06                	jmp    800d16 <strcmp+0x11>
		p++, q++;
  800d10:	83 c1 01             	add    $0x1,%ecx
  800d13:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800d16:	0f b6 01             	movzbl (%ecx),%eax
  800d19:	84 c0                	test   %al,%al
  800d1b:	74 04                	je     800d21 <strcmp+0x1c>
  800d1d:	3a 02                	cmp    (%edx),%al
  800d1f:	74 ef                	je     800d10 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d21:	0f b6 c0             	movzbl %al,%eax
  800d24:	0f b6 12             	movzbl (%edx),%edx
  800d27:	29 d0                	sub    %edx,%eax
}
  800d29:	5d                   	pop    %ebp
  800d2a:	c3                   	ret    

00800d2b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d2b:	55                   	push   %ebp
  800d2c:	89 e5                	mov    %esp,%ebp
  800d2e:	53                   	push   %ebx
  800d2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d32:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d35:	89 c3                	mov    %eax,%ebx
  800d37:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800d3a:	eb 06                	jmp    800d42 <strncmp+0x17>
		n--, p++, q++;
  800d3c:	83 c0 01             	add    $0x1,%eax
  800d3f:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800d42:	39 d8                	cmp    %ebx,%eax
  800d44:	74 18                	je     800d5e <strncmp+0x33>
  800d46:	0f b6 08             	movzbl (%eax),%ecx
  800d49:	84 c9                	test   %cl,%cl
  800d4b:	74 04                	je     800d51 <strncmp+0x26>
  800d4d:	3a 0a                	cmp    (%edx),%cl
  800d4f:	74 eb                	je     800d3c <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d51:	0f b6 00             	movzbl (%eax),%eax
  800d54:	0f b6 12             	movzbl (%edx),%edx
  800d57:	29 d0                	sub    %edx,%eax
}
  800d59:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d5c:	c9                   	leave  
  800d5d:	c3                   	ret    
		return 0;
  800d5e:	b8 00 00 00 00       	mov    $0x0,%eax
  800d63:	eb f4                	jmp    800d59 <strncmp+0x2e>

00800d65 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d65:	55                   	push   %ebp
  800d66:	89 e5                	mov    %esp,%ebp
  800d68:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d6f:	eb 03                	jmp    800d74 <strchr+0xf>
  800d71:	83 c0 01             	add    $0x1,%eax
  800d74:	0f b6 10             	movzbl (%eax),%edx
  800d77:	84 d2                	test   %dl,%dl
  800d79:	74 06                	je     800d81 <strchr+0x1c>
		if (*s == c)
  800d7b:	38 ca                	cmp    %cl,%dl
  800d7d:	75 f2                	jne    800d71 <strchr+0xc>
  800d7f:	eb 05                	jmp    800d86 <strchr+0x21>
			return (char *) s;
	return 0;
  800d81:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d86:	5d                   	pop    %ebp
  800d87:	c3                   	ret    

00800d88 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
  800d8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d92:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800d95:	38 ca                	cmp    %cl,%dl
  800d97:	74 09                	je     800da2 <strfind+0x1a>
  800d99:	84 d2                	test   %dl,%dl
  800d9b:	74 05                	je     800da2 <strfind+0x1a>
	for (; *s; s++)
  800d9d:	83 c0 01             	add    $0x1,%eax
  800da0:	eb f0                	jmp    800d92 <strfind+0xa>
			break;
	return (char *) s;
}
  800da2:	5d                   	pop    %ebp
  800da3:	c3                   	ret    

00800da4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800da4:	55                   	push   %ebp
  800da5:	89 e5                	mov    %esp,%ebp
  800da7:	57                   	push   %edi
  800da8:	56                   	push   %esi
  800da9:	53                   	push   %ebx
  800daa:	8b 55 08             	mov    0x8(%ebp),%edx
  800dad:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  800db0:	85 c9                	test   %ecx,%ecx
  800db2:	74 33                	je     800de7 <memset+0x43>
		return v;
	if ((int) v % 4 == 0 && n % 4 == 0) {
  800db4:	89 d0                	mov    %edx,%eax
  800db6:	09 c8                	or     %ecx,%eax
  800db8:	a8 03                	test   $0x3,%al
  800dba:	75 23                	jne    800ddf <memset+0x3b>
		c &= 0xFF;
  800dbc:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  800dc0:	89 d8                	mov    %ebx,%eax
  800dc2:	c1 e0 08             	shl    $0x8,%eax
  800dc5:	89 df                	mov    %ebx,%edi
  800dc7:	c1 e7 18             	shl    $0x18,%edi
  800dca:	89 de                	mov    %ebx,%esi
  800dcc:	c1 e6 10             	shl    $0x10,%esi
  800dcf:	09 f7                	or     %esi,%edi
  800dd1:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
		             : "=D"(p), "=c"(n)
		             : "D"(p), "a"(c), "c"(n / 4)
  800dd3:	c1 e9 02             	shr    $0x2,%ecx
		c = (c << 24) | (c << 16) | (c << 8) | c;
  800dd6:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800dd8:	89 d7                	mov    %edx,%edi
  800dda:	fc                   	cld    
  800ddb:	f3 ab                	rep stos %eax,%es:(%edi)
  800ddd:	eb 08                	jmp    800de7 <memset+0x43>
		             : "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ddf:	89 d7                	mov    %edx,%edi
  800de1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800de4:	fc                   	cld    
  800de5:	f3 aa                	rep stos %al,%es:(%edi)
		             : "=D"(p), "=c"(n)
		             : "0"(p), "a"(c), "1"(n)
		             : "cc", "memory");
	return v;
}
  800de7:	89 d0                	mov    %edx,%eax
  800de9:	5b                   	pop    %ebx
  800dea:	5e                   	pop    %esi
  800deb:	5f                   	pop    %edi
  800dec:	5d                   	pop    %ebp
  800ded:	c3                   	ret    

00800dee <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800dee:	55                   	push   %ebp
  800def:	89 e5                	mov    %esp,%ebp
  800df1:	57                   	push   %edi
  800df2:	56                   	push   %esi
  800df3:	8b 45 08             	mov    0x8(%ebp),%eax
  800df6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800df9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800dfc:	39 c6                	cmp    %eax,%esi
  800dfe:	73 32                	jae    800e32 <memmove+0x44>
  800e00:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800e03:	39 c2                	cmp    %eax,%edx
  800e05:	76 2b                	jbe    800e32 <memmove+0x44>
		s += n;
		d += n;
  800e07:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  800e0a:	89 d6                	mov    %edx,%esi
  800e0c:	09 fe                	or     %edi,%esi
  800e0e:	09 ce                	or     %ecx,%esi
  800e10:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e16:	75 0e                	jne    800e26 <memmove+0x38>
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  800e18:	83 ef 04             	sub    $0x4,%edi
			             "S"(s - 4),
  800e1b:	8d 72 fc             	lea    -0x4(%edx),%esi
			             "c"(n / 4)
  800e1e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
  800e21:	fd                   	std    
  800e22:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e24:	eb 09                	jmp    800e2f <memmove+0x41>
			             : "cc", "memory");
		else
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  800e26:	83 ef 01             	sub    $0x1,%edi
			             "S"(s - 1),
  800e29:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
  800e2c:	fd                   	std    
  800e2d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             "c"(n)
			             : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e2f:	fc                   	cld    
  800e30:	eb 1a                	jmp    800e4c <memmove+0x5e>
	} else {
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
  800e32:	89 f2                	mov    %esi,%edx
  800e34:	09 c2                	or     %eax,%edx
  800e36:	09 ca                	or     %ecx,%edx
  800e38:	f6 c2 03             	test   $0x3,%dl
  800e3b:	75 0a                	jne    800e47 <memmove+0x59>
			asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800e3d:	c1 e9 02             	shr    $0x2,%ecx
  800e40:	89 c7                	mov    %eax,%edi
  800e42:	fc                   	cld    
  800e43:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e45:	eb 05                	jmp    800e4c <memmove+0x5e>
			             : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800e47:	89 c7                	mov    %eax,%edi
  800e49:	fc                   	cld    
  800e4a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             : "cc", "memory");
	}
	return dst;
}
  800e4c:	5e                   	pop    %esi
  800e4d:	5f                   	pop    %edi
  800e4e:	5d                   	pop    %ebp
  800e4f:	c3                   	ret    

00800e50 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e50:	55                   	push   %ebp
  800e51:	89 e5                	mov    %esp,%ebp
  800e53:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800e56:	ff 75 10             	push   0x10(%ebp)
  800e59:	ff 75 0c             	push   0xc(%ebp)
  800e5c:	ff 75 08             	push   0x8(%ebp)
  800e5f:	e8 8a ff ff ff       	call   800dee <memmove>
}
  800e64:	c9                   	leave  
  800e65:	c3                   	ret    

00800e66 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e66:	55                   	push   %ebp
  800e67:	89 e5                	mov    %esp,%ebp
  800e69:	56                   	push   %esi
  800e6a:	53                   	push   %ebx
  800e6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e71:	89 c6                	mov    %eax,%esi
  800e73:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e76:	eb 06                	jmp    800e7e <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800e78:	83 c0 01             	add    $0x1,%eax
  800e7b:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800e7e:	39 f0                	cmp    %esi,%eax
  800e80:	74 14                	je     800e96 <memcmp+0x30>
		if (*s1 != *s2)
  800e82:	0f b6 08             	movzbl (%eax),%ecx
  800e85:	0f b6 1a             	movzbl (%edx),%ebx
  800e88:	38 d9                	cmp    %bl,%cl
  800e8a:	74 ec                	je     800e78 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800e8c:	0f b6 c1             	movzbl %cl,%eax
  800e8f:	0f b6 db             	movzbl %bl,%ebx
  800e92:	29 d8                	sub    %ebx,%eax
  800e94:	eb 05                	jmp    800e9b <memcmp+0x35>
	}

	return 0;
  800e96:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e9b:	5b                   	pop    %ebx
  800e9c:	5e                   	pop    %esi
  800e9d:	5d                   	pop    %ebp
  800e9e:	c3                   	ret    

00800e9f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e9f:	55                   	push   %ebp
  800ea0:	89 e5                	mov    %esp,%ebp
  800ea2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ea8:	89 c2                	mov    %eax,%edx
  800eaa:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ead:	eb 03                	jmp    800eb2 <memfind+0x13>
  800eaf:	83 c0 01             	add    $0x1,%eax
  800eb2:	39 d0                	cmp    %edx,%eax
  800eb4:	73 04                	jae    800eba <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800eb6:	38 08                	cmp    %cl,(%eax)
  800eb8:	75 f5                	jne    800eaf <memfind+0x10>
			break;
	return (void *) s;
}
  800eba:	5d                   	pop    %ebp
  800ebb:	c3                   	ret    

00800ebc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ebc:	55                   	push   %ebp
  800ebd:	89 e5                	mov    %esp,%ebp
  800ebf:	57                   	push   %edi
  800ec0:	56                   	push   %esi
  800ec1:	53                   	push   %ebx
  800ec2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ec8:	eb 03                	jmp    800ecd <strtol+0x11>
		s++;
  800eca:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800ecd:	0f b6 02             	movzbl (%edx),%eax
  800ed0:	3c 20                	cmp    $0x20,%al
  800ed2:	74 f6                	je     800eca <strtol+0xe>
  800ed4:	3c 09                	cmp    $0x9,%al
  800ed6:	74 f2                	je     800eca <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800ed8:	3c 2b                	cmp    $0x2b,%al
  800eda:	74 2a                	je     800f06 <strtol+0x4a>
	int neg = 0;
  800edc:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800ee1:	3c 2d                	cmp    $0x2d,%al
  800ee3:	74 2b                	je     800f10 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ee5:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800eeb:	75 0f                	jne    800efc <strtol+0x40>
  800eed:	80 3a 30             	cmpb   $0x30,(%edx)
  800ef0:	74 28                	je     800f1a <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ef2:	85 db                	test   %ebx,%ebx
  800ef4:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ef9:	0f 44 d8             	cmove  %eax,%ebx
  800efc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f01:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800f04:	eb 46                	jmp    800f4c <strtol+0x90>
		s++;
  800f06:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800f09:	bf 00 00 00 00       	mov    $0x0,%edi
  800f0e:	eb d5                	jmp    800ee5 <strtol+0x29>
		s++, neg = 1;
  800f10:	83 c2 01             	add    $0x1,%edx
  800f13:	bf 01 00 00 00       	mov    $0x1,%edi
  800f18:	eb cb                	jmp    800ee5 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f1a:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800f1e:	74 0e                	je     800f2e <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800f20:	85 db                	test   %ebx,%ebx
  800f22:	75 d8                	jne    800efc <strtol+0x40>
		s++, base = 8;
  800f24:	83 c2 01             	add    $0x1,%edx
  800f27:	bb 08 00 00 00       	mov    $0x8,%ebx
  800f2c:	eb ce                	jmp    800efc <strtol+0x40>
		s += 2, base = 16;
  800f2e:	83 c2 02             	add    $0x2,%edx
  800f31:	bb 10 00 00 00       	mov    $0x10,%ebx
  800f36:	eb c4                	jmp    800efc <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800f38:	0f be c0             	movsbl %al,%eax
  800f3b:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800f3e:	3b 45 10             	cmp    0x10(%ebp),%eax
  800f41:	7d 3a                	jge    800f7d <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800f43:	83 c2 01             	add    $0x1,%edx
  800f46:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800f4a:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800f4c:	0f b6 02             	movzbl (%edx),%eax
  800f4f:	8d 70 d0             	lea    -0x30(%eax),%esi
  800f52:	89 f3                	mov    %esi,%ebx
  800f54:	80 fb 09             	cmp    $0x9,%bl
  800f57:	76 df                	jbe    800f38 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800f59:	8d 70 9f             	lea    -0x61(%eax),%esi
  800f5c:	89 f3                	mov    %esi,%ebx
  800f5e:	80 fb 19             	cmp    $0x19,%bl
  800f61:	77 08                	ja     800f6b <strtol+0xaf>
			dig = *s - 'a' + 10;
  800f63:	0f be c0             	movsbl %al,%eax
  800f66:	83 e8 57             	sub    $0x57,%eax
  800f69:	eb d3                	jmp    800f3e <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800f6b:	8d 70 bf             	lea    -0x41(%eax),%esi
  800f6e:	89 f3                	mov    %esi,%ebx
  800f70:	80 fb 19             	cmp    $0x19,%bl
  800f73:	77 08                	ja     800f7d <strtol+0xc1>
			dig = *s - 'A' + 10;
  800f75:	0f be c0             	movsbl %al,%eax
  800f78:	83 e8 37             	sub    $0x37,%eax
  800f7b:	eb c1                	jmp    800f3e <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800f7d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f81:	74 05                	je     800f88 <strtol+0xcc>
		*endptr = (char *) s;
  800f83:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f86:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800f88:	89 c8                	mov    %ecx,%eax
  800f8a:	f7 d8                	neg    %eax
  800f8c:	85 ff                	test   %edi,%edi
  800f8e:	0f 45 c8             	cmovne %eax,%ecx
}
  800f91:	89 c8                	mov    %ecx,%eax
  800f93:	5b                   	pop    %ebx
  800f94:	5e                   	pop    %esi
  800f95:	5f                   	pop    %edi
  800f96:	5d                   	pop    %ebp
  800f97:	c3                   	ret    

00800f98 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800f98:	55                   	push   %ebp
  800f99:	89 e5                	mov    %esp,%ebp
  800f9b:	57                   	push   %edi
  800f9c:	56                   	push   %esi
  800f9d:	53                   	push   %ebx
  800f9e:	83 ec 1c             	sub    $0x1c,%esp
  800fa1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800fa4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800fa7:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile(
  800fa9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800faf:	8b 7d 10             	mov    0x10(%ebp),%edi
  800fb2:	8b 75 14             	mov    0x14(%ebp),%esi
  800fb5:	cd 30                	int    $0x30
	        "int %1\n"
	        : "=a"(ret)
	        : "i"(T_SYSCALL), "a"(num), "d"(a1), "c"(a2), "b"(a3), "D"(a4), "S"(a5)
	        : "cc", "memory");

	if (check && ret > 0)
  800fb7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800fbb:	74 04                	je     800fc1 <syscall+0x29>
  800fbd:	85 c0                	test   %eax,%eax
  800fbf:	7f 08                	jg     800fc9 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800fc1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fc4:	5b                   	pop    %ebx
  800fc5:	5e                   	pop    %esi
  800fc6:	5f                   	pop    %edi
  800fc7:	5d                   	pop    %ebp
  800fc8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800fc9:	83 ec 0c             	sub    $0xc,%esp
  800fcc:	50                   	push   %eax
  800fcd:	ff 75 e0             	push   -0x20(%ebp)
  800fd0:	68 24 18 80 00       	push   $0x801824
  800fd5:	6a 1e                	push   $0x1e
  800fd7:	68 41 18 80 00       	push   $0x801841
  800fdc:	e8 5f f6 ff ff       	call   800640 <_panic>

00800fe1 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800fe1:	55                   	push   %ebp
  800fe2:	89 e5                	mov    %esp,%ebp
  800fe4:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t) s, len, 0, 0, 0);
  800fe7:	6a 00                	push   $0x0
  800fe9:	6a 00                	push   $0x0
  800feb:	6a 00                	push   $0x0
  800fed:	ff 75 0c             	push   0xc(%ebp)
  800ff0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ff3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ff8:	b8 00 00 00 00       	mov    $0x0,%eax
  800ffd:	e8 96 ff ff ff       	call   800f98 <syscall>
}
  801002:	83 c4 10             	add    $0x10,%esp
  801005:	c9                   	leave  
  801006:	c3                   	ret    

00801007 <sys_cgetc>:

int
sys_cgetc(void)
{
  801007:	55                   	push   %ebp
  801008:	89 e5                	mov    %esp,%ebp
  80100a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  80100d:	6a 00                	push   $0x0
  80100f:	6a 00                	push   $0x0
  801011:	6a 00                	push   $0x0
  801013:	6a 00                	push   $0x0
  801015:	b9 00 00 00 00       	mov    $0x0,%ecx
  80101a:	ba 00 00 00 00       	mov    $0x0,%edx
  80101f:	b8 01 00 00 00       	mov    $0x1,%eax
  801024:	e8 6f ff ff ff       	call   800f98 <syscall>
}
  801029:	c9                   	leave  
  80102a:	c3                   	ret    

0080102b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80102b:	55                   	push   %ebp
  80102c:	89 e5                	mov    %esp,%ebp
  80102e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  801031:	6a 00                	push   $0x0
  801033:	6a 00                	push   $0x0
  801035:	6a 00                	push   $0x0
  801037:	6a 00                	push   $0x0
  801039:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80103c:	ba 01 00 00 00       	mov    $0x1,%edx
  801041:	b8 03 00 00 00       	mov    $0x3,%eax
  801046:	e8 4d ff ff ff       	call   800f98 <syscall>
}
  80104b:	c9                   	leave  
  80104c:	c3                   	ret    

0080104d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80104d:	55                   	push   %ebp
  80104e:	89 e5                	mov    %esp,%ebp
  801050:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  801053:	6a 00                	push   $0x0
  801055:	6a 00                	push   $0x0
  801057:	6a 00                	push   $0x0
  801059:	6a 00                	push   $0x0
  80105b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801060:	ba 00 00 00 00       	mov    $0x0,%edx
  801065:	b8 02 00 00 00       	mov    $0x2,%eax
  80106a:	e8 29 ff ff ff       	call   800f98 <syscall>
}
  80106f:	c9                   	leave  
  801070:	c3                   	ret    

00801071 <sys_yield>:

void
sys_yield(void)
{
  801071:	55                   	push   %ebp
  801072:	89 e5                	mov    %esp,%ebp
  801074:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  801077:	6a 00                	push   $0x0
  801079:	6a 00                	push   $0x0
  80107b:	6a 00                	push   $0x0
  80107d:	6a 00                	push   $0x0
  80107f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801084:	ba 00 00 00 00       	mov    $0x0,%edx
  801089:	b8 0a 00 00 00       	mov    $0xa,%eax
  80108e:	e8 05 ff ff ff       	call   800f98 <syscall>
}
  801093:	83 c4 10             	add    $0x10,%esp
  801096:	c9                   	leave  
  801097:	c3                   	ret    

00801098 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801098:	55                   	push   %ebp
  801099:	89 e5                	mov    %esp,%ebp
  80109b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  80109e:	6a 00                	push   $0x0
  8010a0:	6a 00                	push   $0x0
  8010a2:	ff 75 10             	push   0x10(%ebp)
  8010a5:	ff 75 0c             	push   0xc(%ebp)
  8010a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010ab:	ba 01 00 00 00       	mov    $0x1,%edx
  8010b0:	b8 04 00 00 00       	mov    $0x4,%eax
  8010b5:	e8 de fe ff ff       	call   800f98 <syscall>
}
  8010ba:	c9                   	leave  
  8010bb:	c3                   	ret    

008010bc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8010bc:	55                   	push   %ebp
  8010bd:	89 e5                	mov    %esp,%ebp
  8010bf:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map,
  8010c2:	ff 75 18             	push   0x18(%ebp)
  8010c5:	ff 75 14             	push   0x14(%ebp)
  8010c8:	ff 75 10             	push   0x10(%ebp)
  8010cb:	ff 75 0c             	push   0xc(%ebp)
  8010ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010d1:	ba 01 00 00 00       	mov    $0x1,%edx
  8010d6:	b8 05 00 00 00       	mov    $0x5,%eax
  8010db:	e8 b8 fe ff ff       	call   800f98 <syscall>
	               srcenv,
	               (uint32_t) srcva,
	               dstenv,
	               (uint32_t) dstva,
	               perm);
}
  8010e0:	c9                   	leave  
  8010e1:	c3                   	ret    

008010e2 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8010e2:	55                   	push   %ebp
  8010e3:	89 e5                	mov    %esp,%ebp
  8010e5:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8010e8:	6a 00                	push   $0x0
  8010ea:	6a 00                	push   $0x0
  8010ec:	6a 00                	push   $0x0
  8010ee:	ff 75 0c             	push   0xc(%ebp)
  8010f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010f4:	ba 01 00 00 00       	mov    $0x1,%edx
  8010f9:	b8 06 00 00 00       	mov    $0x6,%eax
  8010fe:	e8 95 fe ff ff       	call   800f98 <syscall>
}
  801103:	c9                   	leave  
  801104:	c3                   	ret    

00801105 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801105:	55                   	push   %ebp
  801106:	89 e5                	mov    %esp,%ebp
  801108:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80110b:	6a 00                	push   $0x0
  80110d:	6a 00                	push   $0x0
  80110f:	6a 00                	push   $0x0
  801111:	ff 75 0c             	push   0xc(%ebp)
  801114:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801117:	ba 01 00 00 00       	mov    $0x1,%edx
  80111c:	b8 08 00 00 00       	mov    $0x8,%eax
  801121:	e8 72 fe ff ff       	call   800f98 <syscall>
}
  801126:	c9                   	leave  
  801127:	c3                   	ret    

00801128 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801128:	55                   	push   %ebp
  801129:	89 e5                	mov    %esp,%ebp
  80112b:	83 ec 08             	sub    $0x8,%esp
	return syscall(
  80112e:	6a 00                	push   $0x0
  801130:	6a 00                	push   $0x0
  801132:	6a 00                	push   $0x0
  801134:	ff 75 0c             	push   0xc(%ebp)
  801137:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80113a:	ba 01 00 00 00       	mov    $0x1,%edx
  80113f:	b8 09 00 00 00       	mov    $0x9,%eax
  801144:	e8 4f fe ff ff       	call   800f98 <syscall>
	        SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801149:	c9                   	leave  
  80114a:	c3                   	ret    

0080114b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80114b:	55                   	push   %ebp
  80114c:	89 e5                	mov    %esp,%ebp
  80114e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  801151:	6a 00                	push   $0x0
  801153:	ff 75 14             	push   0x14(%ebp)
  801156:	ff 75 10             	push   0x10(%ebp)
  801159:	ff 75 0c             	push   0xc(%ebp)
  80115c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80115f:	ba 00 00 00 00       	mov    $0x0,%edx
  801164:	b8 0b 00 00 00       	mov    $0xb,%eax
  801169:	e8 2a fe ff ff       	call   800f98 <syscall>
}
  80116e:	c9                   	leave  
  80116f:	c3                   	ret    

00801170 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801170:	55                   	push   %ebp
  801171:	89 e5                	mov    %esp,%ebp
  801173:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t) dstva, 0, 0, 0, 0);
  801176:	6a 00                	push   $0x0
  801178:	6a 00                	push   $0x0
  80117a:	6a 00                	push   $0x0
  80117c:	6a 00                	push   $0x0
  80117e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801181:	ba 01 00 00 00       	mov    $0x1,%edx
  801186:	b8 0c 00 00 00       	mov    $0xc,%eax
  80118b:	e8 08 fe ff ff       	call   800f98 <syscall>
}
  801190:	c9                   	leave  
  801191:	c3                   	ret    

00801192 <sys_get_priority>:

// Get priority of the current process
int
sys_get_priority(void)
{
  801192:	55                   	push   %ebp
  801193:	89 e5                	mov    %esp,%ebp
  801195:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_get_priority, 0, 0, 0, 0, 0, 0);
  801198:	6a 00                	push   $0x0
  80119a:	6a 00                	push   $0x0
  80119c:	6a 00                	push   $0x0
  80119e:	6a 00                	push   $0x0
  8011a0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8011aa:	b8 0d 00 00 00       	mov    $0xd,%eax
  8011af:	e8 e4 fd ff ff       	call   800f98 <syscall>
}
  8011b4:	c9                   	leave  
  8011b5:	c3                   	ret    

008011b6 <sys_set_priority>:

// Get priority of the current process
int
sys_set_priority(unsigned int priority)
{
  8011b6:	55                   	push   %ebp
  8011b7:	89 e5                	mov    %esp,%ebp
  8011b9:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, (uint32_t) priority, 0, 0, 0, 0);
  8011bc:	6a 00                	push   $0x0
  8011be:	6a 00                	push   $0x0
  8011c0:	6a 00                	push   $0x0
  8011c2:	6a 00                	push   $0x0
  8011c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8011cc:	b8 0e 00 00 00       	mov    $0xe,%eax
  8011d1:	e8 c2 fd ff ff       	call   800f98 <syscall>
}
  8011d6:	c9                   	leave  
  8011d7:	c3                   	ret    

008011d8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8011d8:	55                   	push   %ebp
  8011d9:	89 e5                	mov    %esp,%ebp
  8011db:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8011de:	83 3d d0 20 80 00 00 	cmpl   $0x0,0x8020d0
  8011e5:	74 0a                	je     8011f1 <set_pgfault_handler+0x19>
		if (r < 0)
			return;
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8011e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ea:	a3 d0 20 80 00       	mov    %eax,0x8020d0
}
  8011ef:	c9                   	leave  
  8011f0:	c3                   	ret    
		r = sys_page_alloc(0, (void *) exstk, perm);
  8011f1:	83 ec 04             	sub    $0x4,%esp
  8011f4:	6a 07                	push   $0x7
  8011f6:	68 00 f0 bf ee       	push   $0xeebff000
  8011fb:	6a 00                	push   $0x0
  8011fd:	e8 96 fe ff ff       	call   801098 <sys_page_alloc>
		if (r < 0)
  801202:	83 c4 10             	add    $0x10,%esp
  801205:	85 c0                	test   %eax,%eax
  801207:	78 e6                	js     8011ef <set_pgfault_handler+0x17>
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801209:	83 ec 08             	sub    $0x8,%esp
  80120c:	68 21 12 80 00       	push   $0x801221
  801211:	6a 00                	push   $0x0
  801213:	e8 10 ff ff ff       	call   801128 <sys_env_set_pgfault_upcall>
		if (r < 0)
  801218:	83 c4 10             	add    $0x10,%esp
  80121b:	85 c0                	test   %eax,%eax
  80121d:	79 c8                	jns    8011e7 <set_pgfault_handler+0xf>
  80121f:	eb ce                	jmp    8011ef <set_pgfault_handler+0x17>

00801221 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801221:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801222:	a1 d0 20 80 00       	mov    0x8020d0,%eax
	call *%eax
  801227:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801229:	83 c4 04             	add    $0x4,%esp
	// Throughout the remaining code, think carefully about what
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	movl 40(%esp), %eax	// trap-time %epi -> %eax 
  80122c:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %ebx	// trap-time %esp -> %ebx
  801230:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4, %ebx
  801234:	83 eb 04             	sub    $0x4,%ebx
	movl %eax, 0(%ebx)	// push %eip in trap-time stack
  801237:	89 03                	mov    %eax,(%ebx)

	movl %ebx, 48(%esp)
  801239:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	popl %eax
  80123d:	58                   	pop    %eax
	popl %eax
  80123e:	58                   	pop    %eax
	popal
  80123f:	61                   	popa   
	

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	addl $4, %esp
  801240:	83 c4 04             	add    $0x4,%esp
	popfl
  801243:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	popl %esp
  801244:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	ret
  801245:	c3                   	ret    
  801246:	66 90                	xchg   %ax,%ax
  801248:	66 90                	xchg   %ax,%ax
  80124a:	66 90                	xchg   %ax,%ax
  80124c:	66 90                	xchg   %ax,%ax
  80124e:	66 90                	xchg   %ax,%ax

00801250 <__udivdi3>:
  801250:	f3 0f 1e fb          	endbr32 
  801254:	55                   	push   %ebp
  801255:	57                   	push   %edi
  801256:	56                   	push   %esi
  801257:	53                   	push   %ebx
  801258:	83 ec 1c             	sub    $0x1c,%esp
  80125b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80125f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801263:	8b 74 24 34          	mov    0x34(%esp),%esi
  801267:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80126b:	85 c0                	test   %eax,%eax
  80126d:	75 19                	jne    801288 <__udivdi3+0x38>
  80126f:	39 f3                	cmp    %esi,%ebx
  801271:	76 4d                	jbe    8012c0 <__udivdi3+0x70>
  801273:	31 ff                	xor    %edi,%edi
  801275:	89 e8                	mov    %ebp,%eax
  801277:	89 f2                	mov    %esi,%edx
  801279:	f7 f3                	div    %ebx
  80127b:	89 fa                	mov    %edi,%edx
  80127d:	83 c4 1c             	add    $0x1c,%esp
  801280:	5b                   	pop    %ebx
  801281:	5e                   	pop    %esi
  801282:	5f                   	pop    %edi
  801283:	5d                   	pop    %ebp
  801284:	c3                   	ret    
  801285:	8d 76 00             	lea    0x0(%esi),%esi
  801288:	39 f0                	cmp    %esi,%eax
  80128a:	76 14                	jbe    8012a0 <__udivdi3+0x50>
  80128c:	31 ff                	xor    %edi,%edi
  80128e:	31 c0                	xor    %eax,%eax
  801290:	89 fa                	mov    %edi,%edx
  801292:	83 c4 1c             	add    $0x1c,%esp
  801295:	5b                   	pop    %ebx
  801296:	5e                   	pop    %esi
  801297:	5f                   	pop    %edi
  801298:	5d                   	pop    %ebp
  801299:	c3                   	ret    
  80129a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012a0:	0f bd f8             	bsr    %eax,%edi
  8012a3:	83 f7 1f             	xor    $0x1f,%edi
  8012a6:	75 48                	jne    8012f0 <__udivdi3+0xa0>
  8012a8:	39 f0                	cmp    %esi,%eax
  8012aa:	72 06                	jb     8012b2 <__udivdi3+0x62>
  8012ac:	31 c0                	xor    %eax,%eax
  8012ae:	39 eb                	cmp    %ebp,%ebx
  8012b0:	77 de                	ja     801290 <__udivdi3+0x40>
  8012b2:	b8 01 00 00 00       	mov    $0x1,%eax
  8012b7:	eb d7                	jmp    801290 <__udivdi3+0x40>
  8012b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012c0:	89 d9                	mov    %ebx,%ecx
  8012c2:	85 db                	test   %ebx,%ebx
  8012c4:	75 0b                	jne    8012d1 <__udivdi3+0x81>
  8012c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8012cb:	31 d2                	xor    %edx,%edx
  8012cd:	f7 f3                	div    %ebx
  8012cf:	89 c1                	mov    %eax,%ecx
  8012d1:	31 d2                	xor    %edx,%edx
  8012d3:	89 f0                	mov    %esi,%eax
  8012d5:	f7 f1                	div    %ecx
  8012d7:	89 c6                	mov    %eax,%esi
  8012d9:	89 e8                	mov    %ebp,%eax
  8012db:	89 f7                	mov    %esi,%edi
  8012dd:	f7 f1                	div    %ecx
  8012df:	89 fa                	mov    %edi,%edx
  8012e1:	83 c4 1c             	add    $0x1c,%esp
  8012e4:	5b                   	pop    %ebx
  8012e5:	5e                   	pop    %esi
  8012e6:	5f                   	pop    %edi
  8012e7:	5d                   	pop    %ebp
  8012e8:	c3                   	ret    
  8012e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012f0:	89 f9                	mov    %edi,%ecx
  8012f2:	ba 20 00 00 00       	mov    $0x20,%edx
  8012f7:	29 fa                	sub    %edi,%edx
  8012f9:	d3 e0                	shl    %cl,%eax
  8012fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012ff:	89 d1                	mov    %edx,%ecx
  801301:	89 d8                	mov    %ebx,%eax
  801303:	d3 e8                	shr    %cl,%eax
  801305:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801309:	09 c1                	or     %eax,%ecx
  80130b:	89 f0                	mov    %esi,%eax
  80130d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801311:	89 f9                	mov    %edi,%ecx
  801313:	d3 e3                	shl    %cl,%ebx
  801315:	89 d1                	mov    %edx,%ecx
  801317:	d3 e8                	shr    %cl,%eax
  801319:	89 f9                	mov    %edi,%ecx
  80131b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80131f:	89 eb                	mov    %ebp,%ebx
  801321:	d3 e6                	shl    %cl,%esi
  801323:	89 d1                	mov    %edx,%ecx
  801325:	d3 eb                	shr    %cl,%ebx
  801327:	09 f3                	or     %esi,%ebx
  801329:	89 c6                	mov    %eax,%esi
  80132b:	89 f2                	mov    %esi,%edx
  80132d:	89 d8                	mov    %ebx,%eax
  80132f:	f7 74 24 08          	divl   0x8(%esp)
  801333:	89 d6                	mov    %edx,%esi
  801335:	89 c3                	mov    %eax,%ebx
  801337:	f7 64 24 0c          	mull   0xc(%esp)
  80133b:	39 d6                	cmp    %edx,%esi
  80133d:	72 19                	jb     801358 <__udivdi3+0x108>
  80133f:	89 f9                	mov    %edi,%ecx
  801341:	d3 e5                	shl    %cl,%ebp
  801343:	39 c5                	cmp    %eax,%ebp
  801345:	73 04                	jae    80134b <__udivdi3+0xfb>
  801347:	39 d6                	cmp    %edx,%esi
  801349:	74 0d                	je     801358 <__udivdi3+0x108>
  80134b:	89 d8                	mov    %ebx,%eax
  80134d:	31 ff                	xor    %edi,%edi
  80134f:	e9 3c ff ff ff       	jmp    801290 <__udivdi3+0x40>
  801354:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801358:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80135b:	31 ff                	xor    %edi,%edi
  80135d:	e9 2e ff ff ff       	jmp    801290 <__udivdi3+0x40>
  801362:	66 90                	xchg   %ax,%ax
  801364:	66 90                	xchg   %ax,%ax
  801366:	66 90                	xchg   %ax,%ax
  801368:	66 90                	xchg   %ax,%ax
  80136a:	66 90                	xchg   %ax,%ax
  80136c:	66 90                	xchg   %ax,%ax
  80136e:	66 90                	xchg   %ax,%ax

00801370 <__umoddi3>:
  801370:	f3 0f 1e fb          	endbr32 
  801374:	55                   	push   %ebp
  801375:	57                   	push   %edi
  801376:	56                   	push   %esi
  801377:	53                   	push   %ebx
  801378:	83 ec 1c             	sub    $0x1c,%esp
  80137b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80137f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801383:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  801387:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80138b:	89 f0                	mov    %esi,%eax
  80138d:	89 da                	mov    %ebx,%edx
  80138f:	85 ff                	test   %edi,%edi
  801391:	75 15                	jne    8013a8 <__umoddi3+0x38>
  801393:	39 dd                	cmp    %ebx,%ebp
  801395:	76 39                	jbe    8013d0 <__umoddi3+0x60>
  801397:	f7 f5                	div    %ebp
  801399:	89 d0                	mov    %edx,%eax
  80139b:	31 d2                	xor    %edx,%edx
  80139d:	83 c4 1c             	add    $0x1c,%esp
  8013a0:	5b                   	pop    %ebx
  8013a1:	5e                   	pop    %esi
  8013a2:	5f                   	pop    %edi
  8013a3:	5d                   	pop    %ebp
  8013a4:	c3                   	ret    
  8013a5:	8d 76 00             	lea    0x0(%esi),%esi
  8013a8:	39 df                	cmp    %ebx,%edi
  8013aa:	77 f1                	ja     80139d <__umoddi3+0x2d>
  8013ac:	0f bd cf             	bsr    %edi,%ecx
  8013af:	83 f1 1f             	xor    $0x1f,%ecx
  8013b2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8013b6:	75 40                	jne    8013f8 <__umoddi3+0x88>
  8013b8:	39 df                	cmp    %ebx,%edi
  8013ba:	72 04                	jb     8013c0 <__umoddi3+0x50>
  8013bc:	39 f5                	cmp    %esi,%ebp
  8013be:	77 dd                	ja     80139d <__umoddi3+0x2d>
  8013c0:	89 da                	mov    %ebx,%edx
  8013c2:	89 f0                	mov    %esi,%eax
  8013c4:	29 e8                	sub    %ebp,%eax
  8013c6:	19 fa                	sbb    %edi,%edx
  8013c8:	eb d3                	jmp    80139d <__umoddi3+0x2d>
  8013ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8013d0:	89 e9                	mov    %ebp,%ecx
  8013d2:	85 ed                	test   %ebp,%ebp
  8013d4:	75 0b                	jne    8013e1 <__umoddi3+0x71>
  8013d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8013db:	31 d2                	xor    %edx,%edx
  8013dd:	f7 f5                	div    %ebp
  8013df:	89 c1                	mov    %eax,%ecx
  8013e1:	89 d8                	mov    %ebx,%eax
  8013e3:	31 d2                	xor    %edx,%edx
  8013e5:	f7 f1                	div    %ecx
  8013e7:	89 f0                	mov    %esi,%eax
  8013e9:	f7 f1                	div    %ecx
  8013eb:	89 d0                	mov    %edx,%eax
  8013ed:	31 d2                	xor    %edx,%edx
  8013ef:	eb ac                	jmp    80139d <__umoddi3+0x2d>
  8013f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8013f8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8013fc:	ba 20 00 00 00       	mov    $0x20,%edx
  801401:	29 c2                	sub    %eax,%edx
  801403:	89 c1                	mov    %eax,%ecx
  801405:	89 e8                	mov    %ebp,%eax
  801407:	d3 e7                	shl    %cl,%edi
  801409:	89 d1                	mov    %edx,%ecx
  80140b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80140f:	d3 e8                	shr    %cl,%eax
  801411:	89 c1                	mov    %eax,%ecx
  801413:	8b 44 24 04          	mov    0x4(%esp),%eax
  801417:	09 f9                	or     %edi,%ecx
  801419:	89 df                	mov    %ebx,%edi
  80141b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80141f:	89 c1                	mov    %eax,%ecx
  801421:	d3 e5                	shl    %cl,%ebp
  801423:	89 d1                	mov    %edx,%ecx
  801425:	d3 ef                	shr    %cl,%edi
  801427:	89 c1                	mov    %eax,%ecx
  801429:	89 f0                	mov    %esi,%eax
  80142b:	d3 e3                	shl    %cl,%ebx
  80142d:	89 d1                	mov    %edx,%ecx
  80142f:	89 fa                	mov    %edi,%edx
  801431:	d3 e8                	shr    %cl,%eax
  801433:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801438:	09 d8                	or     %ebx,%eax
  80143a:	f7 74 24 08          	divl   0x8(%esp)
  80143e:	89 d3                	mov    %edx,%ebx
  801440:	d3 e6                	shl    %cl,%esi
  801442:	f7 e5                	mul    %ebp
  801444:	89 c7                	mov    %eax,%edi
  801446:	89 d1                	mov    %edx,%ecx
  801448:	39 d3                	cmp    %edx,%ebx
  80144a:	72 06                	jb     801452 <__umoddi3+0xe2>
  80144c:	75 0e                	jne    80145c <__umoddi3+0xec>
  80144e:	39 c6                	cmp    %eax,%esi
  801450:	73 0a                	jae    80145c <__umoddi3+0xec>
  801452:	29 e8                	sub    %ebp,%eax
  801454:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801458:	89 d1                	mov    %edx,%ecx
  80145a:	89 c7                	mov    %eax,%edi
  80145c:	89 f5                	mov    %esi,%ebp
  80145e:	8b 74 24 04          	mov    0x4(%esp),%esi
  801462:	29 fd                	sub    %edi,%ebp
  801464:	19 cb                	sbb    %ecx,%ebx
  801466:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80146b:	89 d8                	mov    %ebx,%eax
  80146d:	d3 e0                	shl    %cl,%eax
  80146f:	89 f1                	mov    %esi,%ecx
  801471:	d3 ed                	shr    %cl,%ebp
  801473:	d3 eb                	shr    %cl,%ebx
  801475:	09 e8                	or     %ebp,%eax
  801477:	89 da                	mov    %ebx,%edx
  801479:	83 c4 1c             	add    $0x1c,%esp
  80147c:	5b                   	pop    %ebx
  80147d:	5e                   	pop    %esi
  80147e:	5f                   	pop    %edi
  80147f:	5d                   	pop    %ebp
  801480:	c3                   	ret    
