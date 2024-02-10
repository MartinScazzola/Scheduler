
obj/kern/kernel:     formato del fichero elf32-i386


Desensamblado de la sección .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 40 12 00       	mov    $0x124000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3

	# Enable large pages
	movl 	%cr4, %eax
f010001d:	0f 20 e0             	mov    %cr4,%eax
	orl 	$(CR4_PSE), %eax
f0100020:	83 c8 10             	or     $0x10,%eax
	movl 	%eax, %cr4
f0100023:	0f 22 e0             	mov    %eax,%cr4

	# Turn on paging.
	movl	%cr0, %eax
f0100026:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100029:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f010002e:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100031:	b8 38 00 10 f0       	mov    $0xf0100038,%eax
	jmp	*%eax
f0100036:	ff e0                	jmp    *%eax

f0100038 <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f0100038:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f010003d:	bc 00 40 12 f0       	mov    $0xf0124000,%esp

	# now to C code
	call	i386_init
f0100042:	e8 82 01 00 00       	call   f01001c9 <i386_init>

f0100047 <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f0100047:	eb fe                	jmp    f0100047 <spin>

f0100049 <lcr3>:
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r"(val));
f0100049:	0f 22 d8             	mov    %eax,%cr3
}
f010004c:	c3                   	ret    

f010004d <xchg>:
	return tsc;
}

static inline uint32_t
xchg(volatile uint32_t *addr, uint32_t newval)
{
f010004d:	89 c1                	mov    %eax,%ecx
f010004f:	89 d0                	mov    %edx,%eax
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0100051:	f0 87 01             	lock xchg %eax,(%ecx)
	             : "+m"(*addr), "=a"(result)
	             : "1"(newval)
	             : "cc");
	return result;
}
f0100054:	c3                   	ret    

f0100055 <lock_kernel>:

extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
f0100055:	55                   	push   %ebp
f0100056:	89 e5                	mov    %esp,%ebp
f0100058:	83 ec 14             	sub    $0x14,%esp
	spin_lock(&kernel_lock);
f010005b:	68 c0 53 12 f0       	push   $0xf01253c0
f0100060:	e8 d7 61 00 00       	call   f010623c <spin_lock>
}
f0100065:	83 c4 10             	add    $0x10,%esp
f0100068:	c9                   	leave  
f0100069:	c3                   	ret    

f010006a <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
f010006a:	55                   	push   %ebp
f010006b:	89 e5                	mov    %esp,%ebp
f010006d:	53                   	push   %ebx
f010006e:	83 ec 04             	sub    $0x4,%esp
	va_list ap;

	if (panicstr)
f0100071:	83 3d 00 80 24 f0 00 	cmpl   $0x0,0xf0248000
f0100078:	74 0f                	je     f0100089 <_panic+0x1f>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010007a:	83 ec 0c             	sub    $0xc,%esp
f010007d:	6a 00                	push   $0x0
f010007f:	e8 72 0a 00 00       	call   f0100af6 <monitor>
f0100084:	83 c4 10             	add    $0x10,%esp
f0100087:	eb f1                	jmp    f010007a <_panic+0x10>
	panicstr = fmt;
f0100089:	8b 45 10             	mov    0x10(%ebp),%eax
f010008c:	a3 00 80 24 f0       	mov    %eax,0xf0248000
	asm volatile("cli; cld");
f0100091:	fa                   	cli    
f0100092:	fc                   	cld    
	va_start(ap, fmt);
f0100093:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf(">>>\n>>> kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f0100096:	e8 cd 5e 00 00       	call   f0105f68 <cpunum>
f010009b:	ff 75 0c             	push   0xc(%ebp)
f010009e:	ff 75 08             	push   0x8(%ebp)
f01000a1:	50                   	push   %eax
f01000a2:	68 e0 65 10 f0       	push   $0xf01065e0
f01000a7:	e8 0e 37 00 00       	call   f01037ba <cprintf>
	vcprintf(fmt, ap);
f01000ac:	83 c4 08             	add    $0x8,%esp
f01000af:	53                   	push   %ebx
f01000b0:	ff 75 10             	push   0x10(%ebp)
f01000b3:	e8 dc 36 00 00       	call   f0103794 <vcprintf>
	cprintf("\n>>>\n");
f01000b8:	c7 04 24 54 66 10 f0 	movl   $0xf0106654,(%esp)
f01000bf:	e8 f6 36 00 00       	call   f01037ba <cprintf>
f01000c4:	83 c4 10             	add    $0x10,%esp
f01000c7:	eb b1                	jmp    f010007a <_panic+0x10>

f01000c9 <_kaddr>:
 * virtual address.  It panics if you pass an invalid physical address. */
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void *
_kaddr(const char *file, int line, physaddr_t pa)
{
f01000c9:	55                   	push   %ebp
f01000ca:	89 e5                	mov    %esp,%ebp
f01000cc:	53                   	push   %ebx
f01000cd:	83 ec 04             	sub    $0x4,%esp
	if (PGNUM(pa) >= npages)
f01000d0:	89 cb                	mov    %ecx,%ebx
f01000d2:	c1 eb 0c             	shr    $0xc,%ebx
f01000d5:	3b 1d 60 82 24 f0    	cmp    0xf0248260,%ebx
f01000db:	73 0b                	jae    f01000e8 <_kaddr+0x1f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
	return (void *) (pa + KERNBASE);
f01000dd:	8d 81 00 00 00 f0    	lea    -0x10000000(%ecx),%eax
}
f01000e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01000e6:	c9                   	leave  
f01000e7:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01000e8:	51                   	push   %ecx
f01000e9:	68 0c 66 10 f0       	push   $0xf010660c
f01000ee:	52                   	push   %edx
f01000ef:	50                   	push   %eax
f01000f0:	e8 75 ff ff ff       	call   f010006a <_panic>

f01000f5 <_paddr>:
	if ((uint32_t) kva < KERNBASE)
f01000f5:	81 f9 ff ff ff ef    	cmp    $0xefffffff,%ecx
f01000fb:	76 07                	jbe    f0100104 <_paddr+0xf>
	return (physaddr_t) kva - KERNBASE;
f01000fd:	8d 81 00 00 00 10    	lea    0x10000000(%ecx),%eax
}
f0100103:	c3                   	ret    
{
f0100104:	55                   	push   %ebp
f0100105:	89 e5                	mov    %esp,%ebp
f0100107:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010010a:	51                   	push   %ecx
f010010b:	68 30 66 10 f0       	push   $0xf0106630
f0100110:	52                   	push   %edx
f0100111:	50                   	push   %eax
f0100112:	e8 53 ff ff ff       	call   f010006a <_panic>

f0100117 <boot_aps>:
{
f0100117:	55                   	push   %ebp
f0100118:	89 e5                	mov    %esp,%ebp
f010011a:	56                   	push   %esi
f010011b:	53                   	push   %ebx
	code = KADDR(MPENTRY_PADDR);
f010011c:	b9 00 70 00 00       	mov    $0x7000,%ecx
f0100121:	ba 65 00 00 00       	mov    $0x65,%edx
f0100126:	b8 5a 66 10 f0       	mov    $0xf010665a,%eax
f010012b:	e8 99 ff ff ff       	call   f01000c9 <_kaddr>
f0100130:	89 c6                	mov    %eax,%esi
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f0100132:	83 ec 04             	sub    $0x4,%esp
f0100135:	b8 6a 5b 10 f0       	mov    $0xf0105b6a,%eax
f010013a:	2d e8 5a 10 f0       	sub    $0xf0105ae8,%eax
f010013f:	50                   	push   %eax
f0100140:	68 e8 5a 10 f0       	push   $0xf0105ae8
f0100145:	56                   	push   %esi
f0100146:	e8 f1 57 00 00       	call   f010593c <memmove>
	for (c = cpus; c < cpus + ncpu; c++) {
f010014b:	83 c4 10             	add    $0x10,%esp
f010014e:	bb 20 a0 28 f0       	mov    $0xf028a020,%ebx
f0100153:	eb 03                	jmp    f0100158 <boot_aps+0x41>
f0100155:	83 c3 74             	add    $0x74,%ebx
f0100158:	6b 05 00 a0 28 f0 74 	imul   $0x74,0xf028a000,%eax
f010015f:	05 20 a0 28 f0       	add    $0xf028a020,%eax
f0100164:	39 c3                	cmp    %eax,%ebx
f0100166:	73 5a                	jae    f01001c2 <boot_aps+0xab>
		if (c == cpus + cpunum())  // We've started already.
f0100168:	e8 fb 5d 00 00       	call   f0105f68 <cpunum>
f010016d:	6b c0 74             	imul   $0x74,%eax,%eax
f0100170:	05 20 a0 28 f0       	add    $0xf028a020,%eax
f0100175:	39 c3                	cmp    %eax,%ebx
f0100177:	74 dc                	je     f0100155 <boot_aps+0x3e>
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100179:	89 d8                	mov    %ebx,%eax
f010017b:	2d 20 a0 28 f0       	sub    $0xf028a020,%eax
f0100180:	c1 f8 02             	sar    $0x2,%eax
f0100183:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100189:	c1 e0 0f             	shl    $0xf,%eax
f010018c:	8d 80 00 20 25 f0    	lea    -0xfdae000(%eax),%eax
f0100192:	a3 04 80 24 f0       	mov    %eax,0xf0248004
		lapic_startap(c->cpu_id, PADDR(code));
f0100197:	89 f1                	mov    %esi,%ecx
f0100199:	ba 70 00 00 00       	mov    $0x70,%edx
f010019e:	b8 5a 66 10 f0       	mov    $0xf010665a,%eax
f01001a3:	e8 4d ff ff ff       	call   f01000f5 <_paddr>
f01001a8:	83 ec 08             	sub    $0x8,%esp
f01001ab:	50                   	push   %eax
f01001ac:	0f b6 03             	movzbl (%ebx),%eax
f01001af:	50                   	push   %eax
f01001b0:	e8 1b 5f 00 00       	call   f01060d0 <lapic_startap>
		while (c->cpu_status != CPU_STARTED)
f01001b5:	83 c4 10             	add    $0x10,%esp
f01001b8:	8b 43 04             	mov    0x4(%ebx),%eax
f01001bb:	83 f8 01             	cmp    $0x1,%eax
f01001be:	75 f8                	jne    f01001b8 <boot_aps+0xa1>
f01001c0:	eb 93                	jmp    f0100155 <boot_aps+0x3e>
}
f01001c2:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01001c5:	5b                   	pop    %ebx
f01001c6:	5e                   	pop    %esi
f01001c7:	5d                   	pop    %ebp
f01001c8:	c3                   	ret    

f01001c9 <i386_init>:
{
f01001c9:	55                   	push   %ebp
f01001ca:	89 e5                	mov    %esp,%ebp
f01001cc:	83 ec 0c             	sub    $0xc,%esp
	memset(__bss_start, 0, end - __bss_start);
f01001cf:	b8 c8 a3 28 f0       	mov    $0xf028a3c8,%eax
f01001d4:	2d 00 80 24 f0       	sub    $0xf0248000,%eax
f01001d9:	50                   	push   %eax
f01001da:	6a 00                	push   $0x0
f01001dc:	68 00 80 24 f0       	push   $0xf0248000
f01001e1:	e8 0c 57 00 00       	call   f01058f2 <memset>
	cons_init();
f01001e6:	e8 be 06 00 00       	call   f01008a9 <cons_init>
	cprintf("6828 decimal is %o octal!\n", 6828);
f01001eb:	83 c4 08             	add    $0x8,%esp
f01001ee:	68 ac 1a 00 00       	push   $0x1aac
f01001f3:	68 66 66 10 f0       	push   $0xf0106666
f01001f8:	e8 bd 35 00 00       	call   f01037ba <cprintf>
	mem_init();
f01001fd:	e8 86 29 00 00       	call   f0102b88 <mem_init>
	env_init();
f0100202:	e8 61 2f 00 00       	call   f0103168 <env_init>
	trap_init();
f0100207:	e8 c5 36 00 00       	call   f01038d1 <trap_init>
	mp_init();
f010020c:	e8 9e 5b 00 00       	call   f0105daf <mp_init>
	lapic_init();
f0100211:	e8 68 5d 00 00       	call   f0105f7e <lapic_init>
	pic_init();
f0100216:	e8 5d 34 00 00       	call   f0103678 <pic_init>
	lock_kernel();
f010021b:	e8 35 fe ff ff       	call   f0100055 <lock_kernel>
	boot_aps();
f0100220:	e8 f2 fe ff ff       	call   f0100117 <boot_aps>
	ENV_CREATE(TEST, ENV_TYPE_USER);
f0100225:	83 c4 08             	add    $0x8,%esp
f0100228:	6a 00                	push   $0x0
f010022a:	68 a0 e7 23 f0       	push   $0xf023e7a0
f010022f:	e8 8d 30 00 00       	call   f01032c1 <env_create>
	sched_yield();
f0100234:	e8 f5 42 00 00       	call   f010452e <sched_yield>

f0100239 <mp_main>:
{
f0100239:	55                   	push   %ebp
f010023a:	89 e5                	mov    %esp,%ebp
f010023c:	83 ec 08             	sub    $0x8,%esp
	lcr3(PADDR(kern_pgdir));
f010023f:	8b 0d 5c 82 24 f0    	mov    0xf024825c,%ecx
f0100245:	ba 7c 00 00 00       	mov    $0x7c,%edx
f010024a:	b8 5a 66 10 f0       	mov    $0xf010665a,%eax
f010024f:	e8 a1 fe ff ff       	call   f01000f5 <_paddr>
f0100254:	e8 f0 fd ff ff       	call   f0100049 <lcr3>
	cprintf("SMP: CPU %d starting\n", cpunum());
f0100259:	e8 0a 5d 00 00       	call   f0105f68 <cpunum>
f010025e:	83 ec 08             	sub    $0x8,%esp
f0100261:	50                   	push   %eax
f0100262:	68 81 66 10 f0       	push   $0xf0106681
f0100267:	e8 4e 35 00 00       	call   f01037ba <cprintf>
	lapic_init();
f010026c:	e8 0d 5d 00 00       	call   f0105f7e <lapic_init>
	env_init_percpu();
f0100271:	e8 bb 2e 00 00       	call   f0103131 <env_init_percpu>
	trap_init_percpu();
f0100276:	e8 ad 35 00 00       	call   f0103828 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED);  // tell boot_aps() we're up
f010027b:	e8 e8 5c 00 00       	call   f0105f68 <cpunum>
f0100280:	6b c0 74             	imul   $0x74,%eax,%eax
f0100283:	05 24 a0 28 f0       	add    $0xf028a024,%eax
f0100288:	ba 01 00 00 00       	mov    $0x1,%edx
f010028d:	e8 bb fd ff ff       	call   f010004d <xchg>
	lock_kernel();
f0100292:	e8 be fd ff ff       	call   f0100055 <lock_kernel>
	sched_yield();
f0100297:	e8 92 42 00 00       	call   f010452e <sched_yield>

f010029c <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt, ...)
{
f010029c:	55                   	push   %ebp
f010029d:	89 e5                	mov    %esp,%ebp
f010029f:	53                   	push   %ebx
f01002a0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01002a3:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f01002a6:	ff 75 0c             	push   0xc(%ebp)
f01002a9:	ff 75 08             	push   0x8(%ebp)
f01002ac:	68 97 66 10 f0       	push   $0xf0106697
f01002b1:	e8 04 35 00 00       	call   f01037ba <cprintf>
	vcprintf(fmt, ap);
f01002b6:	83 c4 08             	add    $0x8,%esp
f01002b9:	53                   	push   %ebx
f01002ba:	ff 75 10             	push   0x10(%ebp)
f01002bd:	e8 d2 34 00 00       	call   f0103794 <vcprintf>
	cprintf("\n");
f01002c2:	c7 04 24 c8 77 10 f0 	movl   $0xf01077c8,(%esp)
f01002c9:	e8 ec 34 00 00       	call   f01037ba <cprintf>
	va_end(ap);
}
f01002ce:	83 c4 10             	add    $0x10,%esp
f01002d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01002d4:	c9                   	leave  
f01002d5:	c3                   	ret    

f01002d6 <inb>:
	asm volatile("inb %w1,%0" : "=a"(data) : "d"(port));
f01002d6:	89 c2                	mov    %eax,%edx
f01002d8:	ec                   	in     (%dx),%al
}
f01002d9:	c3                   	ret    

f01002da <outb>:
{
f01002da:	89 c1                	mov    %eax,%ecx
f01002dc:	89 d0                	mov    %edx,%eax
	asm volatile("outb %0,%w1" : : "a"(data), "d"(port));
f01002de:	89 ca                	mov    %ecx,%edx
f01002e0:	ee                   	out    %al,(%dx)
}
f01002e1:	c3                   	ret    

f01002e2 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f01002e2:	55                   	push   %ebp
f01002e3:	89 e5                	mov    %esp,%ebp
f01002e5:	83 ec 08             	sub    $0x8,%esp
	inb(0x84);
f01002e8:	b8 84 00 00 00       	mov    $0x84,%eax
f01002ed:	e8 e4 ff ff ff       	call   f01002d6 <inb>
	inb(0x84);
f01002f2:	b8 84 00 00 00       	mov    $0x84,%eax
f01002f7:	e8 da ff ff ff       	call   f01002d6 <inb>
	inb(0x84);
f01002fc:	b8 84 00 00 00       	mov    $0x84,%eax
f0100301:	e8 d0 ff ff ff       	call   f01002d6 <inb>
	inb(0x84);
f0100306:	b8 84 00 00 00       	mov    $0x84,%eax
f010030b:	e8 c6 ff ff ff       	call   f01002d6 <inb>
}
f0100310:	c9                   	leave  
f0100311:	c3                   	ret    

f0100312 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100312:	55                   	push   %ebp
f0100313:	89 e5                	mov    %esp,%ebp
f0100315:	83 ec 08             	sub    $0x8,%esp
	if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA))
f0100318:	b8 fd 03 00 00       	mov    $0x3fd,%eax
f010031d:	e8 b4 ff ff ff       	call   f01002d6 <inb>
f0100322:	a8 01                	test   $0x1,%al
f0100324:	74 0f                	je     f0100335 <serial_proc_data+0x23>
		return -1;
	return inb(COM1 + COM_RX);
f0100326:	b8 f8 03 00 00       	mov    $0x3f8,%eax
f010032b:	e8 a6 ff ff ff       	call   f01002d6 <inb>
f0100330:	0f b6 c0             	movzbl %al,%eax
}
f0100333:	c9                   	leave  
f0100334:	c3                   	ret    
		return -1;
f0100335:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010033a:	eb f7                	jmp    f0100333 <serial_proc_data+0x21>

f010033c <serial_putc>:
		cons_intr(serial_proc_data);
}

static void
serial_putc(int c)
{
f010033c:	55                   	push   %ebp
f010033d:	89 e5                	mov    %esp,%ebp
f010033f:	56                   	push   %esi
f0100340:	53                   	push   %ebx
f0100341:	89 c6                	mov    %eax,%esi
	int i;

	for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i++)
f0100343:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100348:	b8 fd 03 00 00       	mov    $0x3fd,%eax
f010034d:	e8 84 ff ff ff       	call   f01002d6 <inb>
f0100352:	a8 20                	test   $0x20,%al
f0100354:	75 12                	jne    f0100368 <serial_putc+0x2c>
f0100356:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f010035c:	7f 0a                	jg     f0100368 <serial_putc+0x2c>
		delay();
f010035e:	e8 7f ff ff ff       	call   f01002e2 <delay>
	for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i++)
f0100363:	83 c3 01             	add    $0x1,%ebx
f0100366:	eb e0                	jmp    f0100348 <serial_putc+0xc>

	outb(COM1 + COM_TX, c);
f0100368:	89 f0                	mov    %esi,%eax
f010036a:	0f b6 d0             	movzbl %al,%edx
f010036d:	b8 f8 03 00 00       	mov    $0x3f8,%eax
f0100372:	e8 63 ff ff ff       	call   f01002da <outb>
}
f0100377:	5b                   	pop    %ebx
f0100378:	5e                   	pop    %esi
f0100379:	5d                   	pop    %ebp
f010037a:	c3                   	ret    

f010037b <serial_init>:

static void
serial_init(void)
{
f010037b:	55                   	push   %ebp
f010037c:	89 e5                	mov    %esp,%ebp
f010037e:	83 ec 08             	sub    $0x8,%esp
	// Turn off the FIFO
	outb(COM1 + COM_FCR, 0);
f0100381:	ba 00 00 00 00       	mov    $0x0,%edx
f0100386:	b8 fa 03 00 00       	mov    $0x3fa,%eax
f010038b:	e8 4a ff ff ff       	call   f01002da <outb>

	// Set speed; requires DLAB latch
	outb(COM1 + COM_LCR, COM_LCR_DLAB);
f0100390:	ba 80 00 00 00       	mov    $0x80,%edx
f0100395:	b8 fb 03 00 00       	mov    $0x3fb,%eax
f010039a:	e8 3b ff ff ff       	call   f01002da <outb>
	outb(COM1 + COM_DLL, (uint8_t)(115200 / 9600));
f010039f:	ba 0c 00 00 00       	mov    $0xc,%edx
f01003a4:	b8 f8 03 00 00       	mov    $0x3f8,%eax
f01003a9:	e8 2c ff ff ff       	call   f01002da <outb>
	outb(COM1 + COM_DLM, 0);
f01003ae:	ba 00 00 00 00       	mov    $0x0,%edx
f01003b3:	b8 f9 03 00 00       	mov    $0x3f9,%eax
f01003b8:	e8 1d ff ff ff       	call   f01002da <outb>

	// 8 data bits, 1 stop bit, parity off; turn off DLAB latch
	outb(COM1 + COM_LCR, COM_LCR_WLEN8 & ~COM_LCR_DLAB);
f01003bd:	ba 03 00 00 00       	mov    $0x3,%edx
f01003c2:	b8 fb 03 00 00       	mov    $0x3fb,%eax
f01003c7:	e8 0e ff ff ff       	call   f01002da <outb>

	// No modem controls
	outb(COM1 + COM_MCR, 0);
f01003cc:	ba 00 00 00 00       	mov    $0x0,%edx
f01003d1:	b8 fc 03 00 00       	mov    $0x3fc,%eax
f01003d6:	e8 ff fe ff ff       	call   f01002da <outb>
	// Enable rcv interrupts
	outb(COM1 + COM_IER, COM_IER_RDI);
f01003db:	ba 01 00 00 00       	mov    $0x1,%edx
f01003e0:	b8 f9 03 00 00       	mov    $0x3f9,%eax
f01003e5:	e8 f0 fe ff ff       	call   f01002da <outb>

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
f01003ea:	b8 fd 03 00 00       	mov    $0x3fd,%eax
f01003ef:	e8 e2 fe ff ff       	call   f01002d6 <inb>
f01003f4:	3c ff                	cmp    $0xff,%al
f01003f6:	0f 95 05 54 82 24 f0 	setne  0xf0248254
	(void) inb(COM1 + COM_IIR);
f01003fd:	b8 fa 03 00 00       	mov    $0x3fa,%eax
f0100402:	e8 cf fe ff ff       	call   f01002d6 <inb>
	(void) inb(COM1 + COM_RX);
f0100407:	b8 f8 03 00 00       	mov    $0x3f8,%eax
f010040c:	e8 c5 fe ff ff       	call   f01002d6 <inb>
}
f0100411:	c9                   	leave  
f0100412:	c3                   	ret    

f0100413 <lpt_putc>:
// For information on PC parallel port programming, see the class References
// page.

static void
lpt_putc(int c)
{
f0100413:	55                   	push   %ebp
f0100414:	89 e5                	mov    %esp,%ebp
f0100416:	56                   	push   %esi
f0100417:	53                   	push   %ebx
f0100418:	89 c6                	mov    %eax,%esi
	int i;

	for (i = 0; !(inb(0x378 + 1) & 0x80) && i < 12800; i++)
f010041a:	bb 00 00 00 00       	mov    $0x0,%ebx
f010041f:	b8 79 03 00 00       	mov    $0x379,%eax
f0100424:	e8 ad fe ff ff       	call   f01002d6 <inb>
f0100429:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f010042f:	7f 0e                	jg     f010043f <lpt_putc+0x2c>
f0100431:	84 c0                	test   %al,%al
f0100433:	78 0a                	js     f010043f <lpt_putc+0x2c>
		delay();
f0100435:	e8 a8 fe ff ff       	call   f01002e2 <delay>
	for (i = 0; !(inb(0x378 + 1) & 0x80) && i < 12800; i++)
f010043a:	83 c3 01             	add    $0x1,%ebx
f010043d:	eb e0                	jmp    f010041f <lpt_putc+0xc>
	outb(0x378 + 0, c);
f010043f:	89 f0                	mov    %esi,%eax
f0100441:	0f b6 d0             	movzbl %al,%edx
f0100444:	b8 78 03 00 00       	mov    $0x378,%eax
f0100449:	e8 8c fe ff ff       	call   f01002da <outb>
	outb(0x378 + 2, 0x08 | 0x04 | 0x01);
f010044e:	ba 0d 00 00 00       	mov    $0xd,%edx
f0100453:	b8 7a 03 00 00       	mov    $0x37a,%eax
f0100458:	e8 7d fe ff ff       	call   f01002da <outb>
	outb(0x378 + 2, 0x08);
f010045d:	ba 08 00 00 00       	mov    $0x8,%edx
f0100462:	b8 7a 03 00 00       	mov    $0x37a,%eax
f0100467:	e8 6e fe ff ff       	call   f01002da <outb>
}
f010046c:	5b                   	pop    %ebx
f010046d:	5e                   	pop    %esi
f010046e:	5d                   	pop    %ebp
f010046f:	c3                   	ret    

f0100470 <cga_init>:
static uint16_t *crt_buf;
static uint16_t crt_pos;

static void
cga_init(void)
{
f0100470:	55                   	push   %ebp
f0100471:	89 e5                	mov    %esp,%ebp
f0100473:	57                   	push   %edi
f0100474:	56                   	push   %esi
f0100475:	53                   	push   %ebx
f0100476:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t *) (KERNBASE + CGA_BUF);
	was = *cp;
f0100479:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100480:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100487:	5a a5 
	if (*cp != 0xA55A) {
f0100489:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100490:	bb b4 03 00 00       	mov    $0x3b4,%ebx
		cp = (uint16_t *) (KERNBASE + MONO_BUF);
f0100495:	bf 00 00 0b f0       	mov    $0xf00b0000,%edi
	if (*cp != 0xA55A) {
f010049a:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010049e:	74 52                	je     f01004f2 <cga_init+0x82>
		addr_6845 = MONO_BASE;
f01004a0:	89 1d 50 82 24 f0    	mov    %ebx,0xf0248250
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01004a6:	ba 0e 00 00 00       	mov    $0xe,%edx
f01004ab:	89 d8                	mov    %ebx,%eax
f01004ad:	e8 28 fe ff ff       	call   f01002da <outb>
	pos = inb(addr_6845 + 1) << 8;
f01004b2:	8d 73 01             	lea    0x1(%ebx),%esi
f01004b5:	89 f0                	mov    %esi,%eax
f01004b7:	e8 1a fe ff ff       	call   f01002d6 <inb>
f01004bc:	0f b6 c0             	movzbl %al,%eax
f01004bf:	c1 e0 08             	shl    $0x8,%eax
f01004c2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	outb(addr_6845, 15);
f01004c5:	ba 0f 00 00 00       	mov    $0xf,%edx
f01004ca:	89 d8                	mov    %ebx,%eax
f01004cc:	e8 09 fe ff ff       	call   f01002da <outb>
	pos |= inb(addr_6845 + 1);
f01004d1:	89 f0                	mov    %esi,%eax
f01004d3:	e8 fe fd ff ff       	call   f01002d6 <inb>

	crt_buf = (uint16_t *) cp;
f01004d8:	89 3d 4c 82 24 f0    	mov    %edi,0xf024824c
	pos |= inb(addr_6845 + 1);
f01004de:	0f b6 c0             	movzbl %al,%eax
f01004e1:	0b 45 e4             	or     -0x1c(%ebp),%eax
	crt_pos = pos;
f01004e4:	66 a3 48 82 24 f0    	mov    %ax,0xf0248248
}
f01004ea:	83 c4 1c             	add    $0x1c,%esp
f01004ed:	5b                   	pop    %ebx
f01004ee:	5e                   	pop    %esi
f01004ef:	5f                   	pop    %edi
f01004f0:	5d                   	pop    %ebp
f01004f1:	c3                   	ret    
		*cp = was;
f01004f2:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
f01004f9:	bb d4 03 00 00       	mov    $0x3d4,%ebx
	cp = (uint16_t *) (KERNBASE + CGA_BUF);
f01004fe:	bf 00 80 0b f0       	mov    $0xf00b8000,%edi
f0100503:	eb 9b                	jmp    f01004a0 <cga_init+0x30>

f0100505 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100505:	55                   	push   %ebp
f0100506:	89 e5                	mov    %esp,%ebp
f0100508:	53                   	push   %ebx
f0100509:	83 ec 04             	sub    $0x4,%esp
f010050c:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f010050e:	eb 23                	jmp    f0100533 <cons_intr+0x2e>
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f0100510:	8b 0d 44 82 24 f0    	mov    0xf0248244,%ecx
f0100516:	8d 51 01             	lea    0x1(%ecx),%edx
f0100519:	88 81 40 80 24 f0    	mov    %al,-0xfdb7fc0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f010051f:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f0100525:	b8 00 00 00 00       	mov    $0x0,%eax
f010052a:	0f 44 d0             	cmove  %eax,%edx
f010052d:	89 15 44 82 24 f0    	mov    %edx,0xf0248244
	while ((c = (*proc)()) != -1) {
f0100533:	ff d3                	call   *%ebx
f0100535:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100538:	74 06                	je     f0100540 <cons_intr+0x3b>
		if (c == 0)
f010053a:	85 c0                	test   %eax,%eax
f010053c:	75 d2                	jne    f0100510 <cons_intr+0xb>
f010053e:	eb f3                	jmp    f0100533 <cons_intr+0x2e>
	}
}
f0100540:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100543:	c9                   	leave  
f0100544:	c3                   	ret    

f0100545 <kbd_proc_data>:
{
f0100545:	55                   	push   %ebp
f0100546:	89 e5                	mov    %esp,%ebp
f0100548:	53                   	push   %ebx
f0100549:	83 ec 04             	sub    $0x4,%esp
	stat = inb(KBSTATP);
f010054c:	b8 64 00 00 00       	mov    $0x64,%eax
f0100551:	e8 80 fd ff ff       	call   f01002d6 <inb>
	if ((stat & KBS_DIB) == 0)
f0100556:	a8 01                	test   $0x1,%al
f0100558:	0f 84 f7 00 00 00    	je     f0100655 <kbd_proc_data+0x110>
	if (stat & KBS_TERR)
f010055e:	a8 20                	test   $0x20,%al
f0100560:	0f 85 f6 00 00 00    	jne    f010065c <kbd_proc_data+0x117>
	data = inb(KBDATAP);
f0100566:	b8 60 00 00 00       	mov    $0x60,%eax
f010056b:	e8 66 fd ff ff       	call   f01002d6 <inb>
	if (data == 0xE0) {
f0100570:	3c e0                	cmp    $0xe0,%al
f0100572:	74 61                	je     f01005d5 <kbd_proc_data+0x90>
	} else if (data & 0x80) {
f0100574:	84 c0                	test   %al,%al
f0100576:	78 70                	js     f01005e8 <kbd_proc_data+0xa3>
	} else if (shift & E0ESC) {
f0100578:	8b 15 20 80 24 f0    	mov    0xf0248020,%edx
f010057e:	f6 c2 40             	test   $0x40,%dl
f0100581:	74 0c                	je     f010058f <kbd_proc_data+0x4a>
		data |= 0x80;
f0100583:	83 c8 80             	or     $0xffffff80,%eax
		shift &= ~E0ESC;
f0100586:	83 e2 bf             	and    $0xffffffbf,%edx
f0100589:	89 15 20 80 24 f0    	mov    %edx,0xf0248020
	shift |= shiftcode[data];
f010058f:	0f b6 c0             	movzbl %al,%eax
f0100592:	0f b6 90 00 68 10 f0 	movzbl -0xfef9800(%eax),%edx
f0100599:	0b 15 20 80 24 f0    	or     0xf0248020,%edx
	shift ^= togglecode[data];
f010059f:	0f b6 88 00 67 10 f0 	movzbl -0xfef9900(%eax),%ecx
f01005a6:	31 ca                	xor    %ecx,%edx
f01005a8:	89 15 20 80 24 f0    	mov    %edx,0xf0248020
	c = charcode[shift & (CTL | SHIFT)][data];
f01005ae:	89 d1                	mov    %edx,%ecx
f01005b0:	83 e1 03             	and    $0x3,%ecx
f01005b3:	8b 0c 8d e0 66 10 f0 	mov    -0xfef9920(,%ecx,4),%ecx
f01005ba:	0f b6 04 01          	movzbl (%ecx,%eax,1),%eax
f01005be:	0f b6 d8             	movzbl %al,%ebx
	if (shift & CAPSLOCK) {
f01005c1:	f6 c2 08             	test   $0x8,%dl
f01005c4:	74 5f                	je     f0100625 <kbd_proc_data+0xe0>
		if ('a' <= c && c <= 'z')
f01005c6:	89 d8                	mov    %ebx,%eax
f01005c8:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f01005cb:	83 f9 19             	cmp    $0x19,%ecx
f01005ce:	77 49                	ja     f0100619 <kbd_proc_data+0xd4>
			c += 'A' - 'a';
f01005d0:	83 eb 20             	sub    $0x20,%ebx
f01005d3:	eb 0c                	jmp    f01005e1 <kbd_proc_data+0x9c>
		shift |= E0ESC;
f01005d5:	83 0d 20 80 24 f0 40 	orl    $0x40,0xf0248020
		return 0;
f01005dc:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f01005e1:	89 d8                	mov    %ebx,%eax
f01005e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01005e6:	c9                   	leave  
f01005e7:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f01005e8:	8b 15 20 80 24 f0    	mov    0xf0248020,%edx
f01005ee:	89 c1                	mov    %eax,%ecx
f01005f0:	83 e1 7f             	and    $0x7f,%ecx
f01005f3:	f6 c2 40             	test   $0x40,%dl
f01005f6:	0f 44 c1             	cmove  %ecx,%eax
		shift &= ~(shiftcode[data] | E0ESC);
f01005f9:	0f b6 c0             	movzbl %al,%eax
f01005fc:	0f b6 80 00 68 10 f0 	movzbl -0xfef9800(%eax),%eax
f0100603:	83 c8 40             	or     $0x40,%eax
f0100606:	0f b6 c0             	movzbl %al,%eax
f0100609:	f7 d0                	not    %eax
f010060b:	21 d0                	and    %edx,%eax
f010060d:	a3 20 80 24 f0       	mov    %eax,0xf0248020
		return 0;
f0100612:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100617:	eb c8                	jmp    f01005e1 <kbd_proc_data+0x9c>
		else if ('A' <= c && c <= 'Z')
f0100619:	83 e8 41             	sub    $0x41,%eax
			c += 'a' - 'A';
f010061c:	8d 4b 20             	lea    0x20(%ebx),%ecx
f010061f:	83 f8 1a             	cmp    $0x1a,%eax
f0100622:	0f 42 d9             	cmovb  %ecx,%ebx
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100625:	f7 d2                	not    %edx
f0100627:	f6 c2 06             	test   $0x6,%dl
f010062a:	75 b5                	jne    f01005e1 <kbd_proc_data+0x9c>
f010062c:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100632:	75 ad                	jne    f01005e1 <kbd_proc_data+0x9c>
		cprintf("Rebooting!\n");
f0100634:	83 ec 0c             	sub    $0xc,%esp
f0100637:	68 b1 66 10 f0       	push   $0xf01066b1
f010063c:	e8 79 31 00 00       	call   f01037ba <cprintf>
		outb(0x92, 0x3);  // courtesy of Chris Frost
f0100641:	ba 03 00 00 00       	mov    $0x3,%edx
f0100646:	b8 92 00 00 00       	mov    $0x92,%eax
f010064b:	e8 8a fc ff ff       	call   f01002da <outb>
f0100650:	83 c4 10             	add    $0x10,%esp
f0100653:	eb 8c                	jmp    f01005e1 <kbd_proc_data+0x9c>
		return -1;
f0100655:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f010065a:	eb 85                	jmp    f01005e1 <kbd_proc_data+0x9c>
		return -1;
f010065c:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f0100661:	e9 7b ff ff ff       	jmp    f01005e1 <kbd_proc_data+0x9c>

f0100666 <cga_putc>:
{
f0100666:	55                   	push   %ebp
f0100667:	89 e5                	mov    %esp,%ebp
f0100669:	57                   	push   %edi
f010066a:	56                   	push   %esi
f010066b:	53                   	push   %ebx
f010066c:	83 ec 0c             	sub    $0xc,%esp
		c |= 0x0700;
f010066f:	89 c2                	mov    %eax,%edx
f0100671:	80 ce 07             	or     $0x7,%dh
f0100674:	a9 00 ff ff ff       	test   $0xffffff00,%eax
f0100679:	0f 44 c2             	cmove  %edx,%eax
	switch (c & 0xff) {
f010067c:	3c 0a                	cmp    $0xa,%al
f010067e:	0f 84 f7 00 00 00    	je     f010077b <cga_putc+0x115>
f0100684:	0f b6 d0             	movzbl %al,%edx
f0100687:	83 fa 0a             	cmp    $0xa,%edx
f010068a:	7f 46                	jg     f01006d2 <cga_putc+0x6c>
f010068c:	83 fa 08             	cmp    $0x8,%edx
f010068f:	0f 84 b9 00 00 00    	je     f010074e <cga_putc+0xe8>
f0100695:	83 fa 09             	cmp    $0x9,%edx
f0100698:	0f 85 ea 00 00 00    	jne    f0100788 <cga_putc+0x122>
		cons_putc(' ');
f010069e:	b8 20 00 00 00       	mov    $0x20,%eax
f01006a3:	e8 4b 01 00 00       	call   f01007f3 <cons_putc>
		cons_putc(' ');
f01006a8:	b8 20 00 00 00       	mov    $0x20,%eax
f01006ad:	e8 41 01 00 00       	call   f01007f3 <cons_putc>
		cons_putc(' ');
f01006b2:	b8 20 00 00 00       	mov    $0x20,%eax
f01006b7:	e8 37 01 00 00       	call   f01007f3 <cons_putc>
		cons_putc(' ');
f01006bc:	b8 20 00 00 00       	mov    $0x20,%eax
f01006c1:	e8 2d 01 00 00       	call   f01007f3 <cons_putc>
		cons_putc(' ');
f01006c6:	b8 20 00 00 00       	mov    $0x20,%eax
f01006cb:	e8 23 01 00 00       	call   f01007f3 <cons_putc>
		break;
f01006d0:	eb 25                	jmp    f01006f7 <cga_putc+0x91>
	switch (c & 0xff) {
f01006d2:	83 fa 0d             	cmp    $0xd,%edx
f01006d5:	0f 85 ad 00 00 00    	jne    f0100788 <cga_putc+0x122>
		crt_pos -= (crt_pos % CRT_COLS);
f01006db:	0f b7 05 48 82 24 f0 	movzwl 0xf0248248,%eax
f01006e2:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01006e8:	c1 e8 16             	shr    $0x16,%eax
f01006eb:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01006ee:	c1 e0 04             	shl    $0x4,%eax
f01006f1:	66 a3 48 82 24 f0    	mov    %ax,0xf0248248
	if (crt_pos >= CRT_SIZE) {
f01006f7:	66 81 3d 48 82 24 f0 	cmpw   $0x7cf,0xf0248248
f01006fe:	cf 07 
f0100700:	0f 87 a5 00 00 00    	ja     f01007ab <cga_putc+0x145>
	outb(addr_6845, 14);
f0100706:	8b 3d 50 82 24 f0    	mov    0xf0248250,%edi
f010070c:	ba 0e 00 00 00       	mov    $0xe,%edx
f0100711:	89 f8                	mov    %edi,%eax
f0100713:	e8 c2 fb ff ff       	call   f01002da <outb>
	outb(addr_6845 + 1, crt_pos >> 8);
f0100718:	8d 77 01             	lea    0x1(%edi),%esi
f010071b:	0f b7 1d 48 82 24 f0 	movzwl 0xf0248248,%ebx
f0100722:	0f b6 15 49 82 24 f0 	movzbl 0xf0248249,%edx
f0100729:	89 f0                	mov    %esi,%eax
f010072b:	e8 aa fb ff ff       	call   f01002da <outb>
	outb(addr_6845, 15);
f0100730:	ba 0f 00 00 00       	mov    $0xf,%edx
f0100735:	89 f8                	mov    %edi,%eax
f0100737:	e8 9e fb ff ff       	call   f01002da <outb>
	outb(addr_6845 + 1, crt_pos);
f010073c:	0f b6 d3             	movzbl %bl,%edx
f010073f:	89 f0                	mov    %esi,%eax
f0100741:	e8 94 fb ff ff       	call   f01002da <outb>
}
f0100746:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100749:	5b                   	pop    %ebx
f010074a:	5e                   	pop    %esi
f010074b:	5f                   	pop    %edi
f010074c:	5d                   	pop    %ebp
f010074d:	c3                   	ret    
		if (crt_pos > 0) {
f010074e:	0f b7 15 48 82 24 f0 	movzwl 0xf0248248,%edx
f0100755:	66 85 d2             	test   %dx,%dx
f0100758:	74 ac                	je     f0100706 <cga_putc+0xa0>
			crt_pos--;
f010075a:	83 ea 01             	sub    $0x1,%edx
f010075d:	66 89 15 48 82 24 f0 	mov    %dx,0xf0248248
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100764:	0f b7 d2             	movzwl %dx,%edx
f0100767:	b0 00                	mov    $0x0,%al
f0100769:	83 c8 20             	or     $0x20,%eax
f010076c:	8b 0d 4c 82 24 f0    	mov    0xf024824c,%ecx
f0100772:	66 89 04 51          	mov    %ax,(%ecx,%edx,2)
f0100776:	e9 7c ff ff ff       	jmp    f01006f7 <cga_putc+0x91>
		crt_pos += CRT_COLS;
f010077b:	66 83 05 48 82 24 f0 	addw   $0x50,0xf0248248
f0100782:	50 
f0100783:	e9 53 ff ff ff       	jmp    f01006db <cga_putc+0x75>
		crt_buf[crt_pos++] = c; /* write the character */
f0100788:	0f b7 15 48 82 24 f0 	movzwl 0xf0248248,%edx
f010078f:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100792:	66 89 0d 48 82 24 f0 	mov    %cx,0xf0248248
f0100799:	0f b7 d2             	movzwl %dx,%edx
f010079c:	8b 0d 4c 82 24 f0    	mov    0xf024824c,%ecx
f01007a2:	66 89 04 51          	mov    %ax,(%ecx,%edx,2)
		break;
f01007a6:	e9 4c ff ff ff       	jmp    f01006f7 <cga_putc+0x91>
		memmove(crt_buf,
f01007ab:	a1 4c 82 24 f0       	mov    0xf024824c,%eax
f01007b0:	83 ec 04             	sub    $0x4,%esp
f01007b3:	68 00 0f 00 00       	push   $0xf00
		        crt_buf + CRT_COLS,
f01007b8:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
		memmove(crt_buf,
f01007be:	52                   	push   %edx
f01007bf:	50                   	push   %eax
f01007c0:	e8 77 51 00 00       	call   f010593c <memmove>
			crt_buf[i] = 0x0700 | ' ';
f01007c5:	8b 15 4c 82 24 f0    	mov    0xf024824c,%edx
f01007cb:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f01007d1:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f01007d7:	83 c4 10             	add    $0x10,%esp
f01007da:	66 c7 00 20 07       	movw   $0x720,(%eax)
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01007df:	83 c0 02             	add    $0x2,%eax
f01007e2:	39 d0                	cmp    %edx,%eax
f01007e4:	75 f4                	jne    f01007da <cga_putc+0x174>
		crt_pos -= CRT_COLS;
f01007e6:	66 83 2d 48 82 24 f0 	subw   $0x50,0xf0248248
f01007ed:	50 
f01007ee:	e9 13 ff ff ff       	jmp    f0100706 <cga_putc+0xa0>

f01007f3 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01007f3:	55                   	push   %ebp
f01007f4:	89 e5                	mov    %esp,%ebp
f01007f6:	53                   	push   %ebx
f01007f7:	83 ec 04             	sub    $0x4,%esp
f01007fa:	89 c3                	mov    %eax,%ebx
	serial_putc(c);
f01007fc:	e8 3b fb ff ff       	call   f010033c <serial_putc>
	lpt_putc(c);
f0100801:	89 d8                	mov    %ebx,%eax
f0100803:	e8 0b fc ff ff       	call   f0100413 <lpt_putc>
	cga_putc(c);
f0100808:	89 d8                	mov    %ebx,%eax
f010080a:	e8 57 fe ff ff       	call   f0100666 <cga_putc>
}
f010080f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100812:	c9                   	leave  
f0100813:	c3                   	ret    

f0100814 <serial_intr>:
	if (serial_exists)
f0100814:	80 3d 54 82 24 f0 00 	cmpb   $0x0,0xf0248254
f010081b:	75 01                	jne    f010081e <serial_intr+0xa>
f010081d:	c3                   	ret    
{
f010081e:	55                   	push   %ebp
f010081f:	89 e5                	mov    %esp,%ebp
f0100821:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f0100824:	b8 12 03 10 f0       	mov    $0xf0100312,%eax
f0100829:	e8 d7 fc ff ff       	call   f0100505 <cons_intr>
}
f010082e:	c9                   	leave  
f010082f:	c3                   	ret    

f0100830 <kbd_intr>:
{
f0100830:	55                   	push   %ebp
f0100831:	89 e5                	mov    %esp,%ebp
f0100833:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100836:	b8 45 05 10 f0       	mov    $0xf0100545,%eax
f010083b:	e8 c5 fc ff ff       	call   f0100505 <cons_intr>
}
f0100840:	c9                   	leave  
f0100841:	c3                   	ret    

f0100842 <kbd_init>:
{
f0100842:	55                   	push   %ebp
f0100843:	89 e5                	mov    %esp,%ebp
f0100845:	83 ec 08             	sub    $0x8,%esp
	kbd_intr();
f0100848:	e8 e3 ff ff ff       	call   f0100830 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1 << IRQ_KBD));
f010084d:	83 ec 0c             	sub    $0xc,%esp
f0100850:	0f b7 05 a8 53 12 f0 	movzwl 0xf01253a8,%eax
f0100857:	25 fd ff 00 00       	and    $0xfffd,%eax
f010085c:	50                   	push   %eax
f010085d:	e8 8d 2d 00 00       	call   f01035ef <irq_setmask_8259A>
}
f0100862:	83 c4 10             	add    $0x10,%esp
f0100865:	c9                   	leave  
f0100866:	c3                   	ret    

f0100867 <cons_getc>:
{
f0100867:	55                   	push   %ebp
f0100868:	89 e5                	mov    %esp,%ebp
f010086a:	83 ec 08             	sub    $0x8,%esp
	serial_intr();
f010086d:	e8 a2 ff ff ff       	call   f0100814 <serial_intr>
	kbd_intr();
f0100872:	e8 b9 ff ff ff       	call   f0100830 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f0100877:	a1 40 82 24 f0       	mov    0xf0248240,%eax
	return 0;
f010087c:	ba 00 00 00 00       	mov    $0x0,%edx
	if (cons.rpos != cons.wpos) {
f0100881:	3b 05 44 82 24 f0    	cmp    0xf0248244,%eax
f0100887:	74 1c                	je     f01008a5 <cons_getc+0x3e>
		c = cons.buf[cons.rpos++];
f0100889:	8d 48 01             	lea    0x1(%eax),%ecx
f010088c:	0f b6 90 40 80 24 f0 	movzbl -0xfdb7fc0(%eax),%edx
			cons.rpos = 0;
f0100893:	3d ff 01 00 00       	cmp    $0x1ff,%eax
f0100898:	b8 00 00 00 00       	mov    $0x0,%eax
f010089d:	0f 45 c1             	cmovne %ecx,%eax
f01008a0:	a3 40 82 24 f0       	mov    %eax,0xf0248240
}
f01008a5:	89 d0                	mov    %edx,%eax
f01008a7:	c9                   	leave  
f01008a8:	c3                   	ret    

f01008a9 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f01008a9:	55                   	push   %ebp
f01008aa:	89 e5                	mov    %esp,%ebp
f01008ac:	83 ec 08             	sub    $0x8,%esp
	cga_init();
f01008af:	e8 bc fb ff ff       	call   f0100470 <cga_init>
	kbd_init();
f01008b4:	e8 89 ff ff ff       	call   f0100842 <kbd_init>
	serial_init();
f01008b9:	e8 bd fa ff ff       	call   f010037b <serial_init>

	if (!serial_exists)
f01008be:	80 3d 54 82 24 f0 00 	cmpb   $0x0,0xf0248254
f01008c5:	74 02                	je     f01008c9 <cons_init+0x20>
		cprintf("Serial port does not exist!\n");
}
f01008c7:	c9                   	leave  
f01008c8:	c3                   	ret    
		cprintf("Serial port does not exist!\n");
f01008c9:	83 ec 0c             	sub    $0xc,%esp
f01008cc:	68 bd 66 10 f0       	push   $0xf01066bd
f01008d1:	e8 e4 2e 00 00       	call   f01037ba <cprintf>
f01008d6:	83 c4 10             	add    $0x10,%esp
}
f01008d9:	eb ec                	jmp    f01008c7 <cons_init+0x1e>

f01008db <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01008db:	55                   	push   %ebp
f01008dc:	89 e5                	mov    %esp,%ebp
f01008de:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01008e1:	8b 45 08             	mov    0x8(%ebp),%eax
f01008e4:	e8 0a ff ff ff       	call   f01007f3 <cons_putc>
}
f01008e9:	c9                   	leave  
f01008ea:	c3                   	ret    

f01008eb <getchar>:

int
getchar(void)
{
f01008eb:	55                   	push   %ebp
f01008ec:	89 e5                	mov    %esp,%ebp
f01008ee:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01008f1:	e8 71 ff ff ff       	call   f0100867 <cons_getc>
f01008f6:	85 c0                	test   %eax,%eax
f01008f8:	74 f7                	je     f01008f1 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01008fa:	c9                   	leave  
f01008fb:	c3                   	ret    

f01008fc <iscons>:
int
iscons(int fdnum)
{
	// used by readline
	return 1;
}
f01008fc:	b8 01 00 00 00       	mov    $0x1,%eax
f0100901:	c3                   	ret    

f0100902 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100902:	55                   	push   %ebp
f0100903:	89 e5                	mov    %esp,%ebp
f0100905:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100908:	68 00 69 10 f0       	push   $0xf0106900
f010090d:	68 1e 69 10 f0       	push   $0xf010691e
f0100912:	68 23 69 10 f0       	push   $0xf0106923
f0100917:	e8 9e 2e 00 00       	call   f01037ba <cprintf>
f010091c:	83 c4 0c             	add    $0xc,%esp
f010091f:	68 8c 69 10 f0       	push   $0xf010698c
f0100924:	68 2c 69 10 f0       	push   $0xf010692c
f0100929:	68 23 69 10 f0       	push   $0xf0106923
f010092e:	e8 87 2e 00 00       	call   f01037ba <cprintf>
	return 0;
}
f0100933:	b8 00 00 00 00       	mov    $0x0,%eax
f0100938:	c9                   	leave  
f0100939:	c3                   	ret    

f010093a <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f010093a:	55                   	push   %ebp
f010093b:	89 e5                	mov    %esp,%ebp
f010093d:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100940:	68 35 69 10 f0       	push   $0xf0106935
f0100945:	e8 70 2e 00 00       	call   f01037ba <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010094a:	83 c4 08             	add    $0x8,%esp
f010094d:	68 0c 00 10 00       	push   $0x10000c
f0100952:	68 b4 69 10 f0       	push   $0xf01069b4
f0100957:	e8 5e 2e 00 00       	call   f01037ba <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010095c:	83 c4 0c             	add    $0xc,%esp
f010095f:	68 0c 00 10 00       	push   $0x10000c
f0100964:	68 0c 00 10 f0       	push   $0xf010000c
f0100969:	68 dc 69 10 f0       	push   $0xf01069dc
f010096e:	e8 47 2e 00 00       	call   f01037ba <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100973:	83 c4 0c             	add    $0xc,%esp
f0100976:	68 c1 65 10 00       	push   $0x1065c1
f010097b:	68 c1 65 10 f0       	push   $0xf01065c1
f0100980:	68 00 6a 10 f0       	push   $0xf0106a00
f0100985:	e8 30 2e 00 00       	call   f01037ba <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010098a:	83 c4 0c             	add    $0xc,%esp
f010098d:	68 2c 72 24 00       	push   $0x24722c
f0100992:	68 2c 72 24 f0       	push   $0xf024722c
f0100997:	68 24 6a 10 f0       	push   $0xf0106a24
f010099c:	e8 19 2e 00 00       	call   f01037ba <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01009a1:	83 c4 0c             	add    $0xc,%esp
f01009a4:	68 c8 a3 28 00       	push   $0x28a3c8
f01009a9:	68 c8 a3 28 f0       	push   $0xf028a3c8
f01009ae:	68 48 6a 10 f0       	push   $0xf0106a48
f01009b3:	e8 02 2e 00 00       	call   f01037ba <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f01009b8:	83 c4 08             	add    $0x8,%esp
	        ROUNDUP(end - entry, 1024) / 1024);
f01009bb:	b8 c8 a3 28 f0       	mov    $0xf028a3c8,%eax
f01009c0:	2d 0d fc 0f f0       	sub    $0xf00ffc0d,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f01009c5:	c1 f8 0a             	sar    $0xa,%eax
f01009c8:	50                   	push   %eax
f01009c9:	68 6c 6a 10 f0       	push   $0xf0106a6c
f01009ce:	e8 e7 2d 00 00       	call   f01037ba <cprintf>
	return 0;
}
f01009d3:	b8 00 00 00 00       	mov    $0x0,%eax
f01009d8:	c9                   	leave  
f01009d9:	c3                   	ret    

f01009da <runcmd>:
#define WHITESPACE "\t\r\n "
#define MAXARGS 16

static int
runcmd(char *buf, struct Trapframe *tf)
{
f01009da:	55                   	push   %ebp
f01009db:	89 e5                	mov    %esp,%ebp
f01009dd:	57                   	push   %edi
f01009de:	56                   	push   %esi
f01009df:	53                   	push   %ebx
f01009e0:	83 ec 5c             	sub    $0x5c,%esp
f01009e3:	89 c3                	mov    %eax,%ebx
f01009e5:	89 55 a4             	mov    %edx,-0x5c(%ebp)
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01009e8:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f01009ef:	be 00 00 00 00       	mov    $0x0,%esi
f01009f4:	eb 5d                	jmp    f0100a53 <runcmd+0x79>
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01009f6:	83 ec 08             	sub    $0x8,%esp
f01009f9:	0f be c0             	movsbl %al,%eax
f01009fc:	50                   	push   %eax
f01009fd:	68 4e 69 10 f0       	push   $0xf010694e
f0100a02:	e8 ac 4e 00 00       	call   f01058b3 <strchr>
f0100a07:	83 c4 10             	add    $0x10,%esp
f0100a0a:	85 c0                	test   %eax,%eax
f0100a0c:	74 0a                	je     f0100a18 <runcmd+0x3e>
			*buf++ = 0;
f0100a0e:	c6 03 00             	movb   $0x0,(%ebx)
f0100a11:	89 f7                	mov    %esi,%edi
f0100a13:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100a16:	eb 39                	jmp    f0100a51 <runcmd+0x77>
		if (*buf == 0)
f0100a18:	0f b6 03             	movzbl (%ebx),%eax
f0100a1b:	84 c0                	test   %al,%al
f0100a1d:	74 3b                	je     f0100a5a <runcmd+0x80>
			break;

		// save and scan past next arg
		if (argc == MAXARGS - 1) {
f0100a1f:	83 fe 0f             	cmp    $0xf,%esi
f0100a22:	0f 84 86 00 00 00    	je     f0100aae <runcmd+0xd4>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
f0100a28:	8d 7e 01             	lea    0x1(%esi),%edi
f0100a2b:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a2f:	83 ec 08             	sub    $0x8,%esp
f0100a32:	0f be c0             	movsbl %al,%eax
f0100a35:	50                   	push   %eax
f0100a36:	68 4e 69 10 f0       	push   $0xf010694e
f0100a3b:	e8 73 4e 00 00       	call   f01058b3 <strchr>
f0100a40:	83 c4 10             	add    $0x10,%esp
f0100a43:	85 c0                	test   %eax,%eax
f0100a45:	75 0a                	jne    f0100a51 <runcmd+0x77>
			buf++;
f0100a47:	83 c3 01             	add    $0x1,%ebx
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a4a:	0f b6 03             	movzbl (%ebx),%eax
f0100a4d:	84 c0                	test   %al,%al
f0100a4f:	75 de                	jne    f0100a2f <runcmd+0x55>
			*buf++ = 0;
f0100a51:	89 fe                	mov    %edi,%esi
		while (*buf && strchr(WHITESPACE, *buf))
f0100a53:	0f b6 03             	movzbl (%ebx),%eax
f0100a56:	84 c0                	test   %al,%al
f0100a58:	75 9c                	jne    f01009f6 <runcmd+0x1c>
	}
	argv[argc] = 0;
f0100a5a:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100a61:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100a62:	85 f6                	test   %esi,%esi
f0100a64:	74 5f                	je     f0100ac5 <runcmd+0xeb>
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a66:	83 ec 08             	sub    $0x8,%esp
f0100a69:	68 1e 69 10 f0       	push   $0xf010691e
f0100a6e:	ff 75 a8             	push   -0x58(%ebp)
f0100a71:	e8 dd 4d 00 00       	call   f0105853 <strcmp>
f0100a76:	83 c4 10             	add    $0x10,%esp
f0100a79:	85 c0                	test   %eax,%eax
f0100a7b:	74 57                	je     f0100ad4 <runcmd+0xfa>
f0100a7d:	83 ec 08             	sub    $0x8,%esp
f0100a80:	68 2c 69 10 f0       	push   $0xf010692c
f0100a85:	ff 75 a8             	push   -0x58(%ebp)
f0100a88:	e8 c6 4d 00 00       	call   f0105853 <strcmp>
f0100a8d:	83 c4 10             	add    $0x10,%esp
f0100a90:	85 c0                	test   %eax,%eax
f0100a92:	74 3b                	je     f0100acf <runcmd+0xf5>
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a94:	83 ec 08             	sub    $0x8,%esp
f0100a97:	ff 75 a8             	push   -0x58(%ebp)
f0100a9a:	68 70 69 10 f0       	push   $0xf0106970
f0100a9f:	e8 16 2d 00 00       	call   f01037ba <cprintf>
	return 0;
f0100aa4:	83 c4 10             	add    $0x10,%esp
f0100aa7:	be 00 00 00 00       	mov    $0x0,%esi
f0100aac:	eb 17                	jmp    f0100ac5 <runcmd+0xeb>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100aae:	83 ec 08             	sub    $0x8,%esp
f0100ab1:	6a 10                	push   $0x10
f0100ab3:	68 53 69 10 f0       	push   $0xf0106953
f0100ab8:	e8 fd 2c 00 00       	call   f01037ba <cprintf>
			return 0;
f0100abd:	83 c4 10             	add    $0x10,%esp
f0100ac0:	be 00 00 00 00       	mov    $0x0,%esi
}
f0100ac5:	89 f0                	mov    %esi,%eax
f0100ac7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100aca:	5b                   	pop    %ebx
f0100acb:	5e                   	pop    %esi
f0100acc:	5f                   	pop    %edi
f0100acd:	5d                   	pop    %ebp
f0100ace:	c3                   	ret    
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100acf:	b8 01 00 00 00       	mov    $0x1,%eax
			return commands[i].func(argc, argv, tf);
f0100ad4:	83 ec 04             	sub    $0x4,%esp
f0100ad7:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100ada:	ff 75 a4             	push   -0x5c(%ebp)
f0100add:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100ae0:	52                   	push   %edx
f0100ae1:	56                   	push   %esi
f0100ae2:	ff 14 85 ec 6a 10 f0 	call   *-0xfef9514(,%eax,4)
f0100ae9:	89 c6                	mov    %eax,%esi
f0100aeb:	83 c4 10             	add    $0x10,%esp
f0100aee:	eb d5                	jmp    f0100ac5 <runcmd+0xeb>

f0100af0 <mon_backtrace>:
}
f0100af0:	b8 00 00 00 00       	mov    $0x0,%eax
f0100af5:	c3                   	ret    

f0100af6 <monitor>:

void
monitor(struct Trapframe *tf)
{
f0100af6:	55                   	push   %ebp
f0100af7:	89 e5                	mov    %esp,%ebp
f0100af9:	53                   	push   %ebx
f0100afa:	83 ec 10             	sub    $0x10,%esp
f0100afd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100b00:	68 98 6a 10 f0       	push   $0xf0106a98
f0100b05:	e8 b0 2c 00 00       	call   f01037ba <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100b0a:	c7 04 24 bc 6a 10 f0 	movl   $0xf0106abc,(%esp)
f0100b11:	e8 a4 2c 00 00       	call   f01037ba <cprintf>

	if (tf != NULL)
f0100b16:	83 c4 10             	add    $0x10,%esp
f0100b19:	85 db                	test   %ebx,%ebx
f0100b1b:	74 0c                	je     f0100b29 <monitor+0x33>
		print_trapframe(tf);
f0100b1d:	83 ec 0c             	sub    $0xc,%esp
f0100b20:	53                   	push   %ebx
f0100b21:	e8 a2 31 00 00       	call   f0103cc8 <print_trapframe>
f0100b26:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100b29:	83 ec 0c             	sub    $0xc,%esp
f0100b2c:	68 86 69 10 f0       	push   $0xf0106986
f0100b31:	e8 4f 4b 00 00       	call   f0105685 <readline>
		if (buf != NULL)
f0100b36:	83 c4 10             	add    $0x10,%esp
f0100b39:	85 c0                	test   %eax,%eax
f0100b3b:	74 ec                	je     f0100b29 <monitor+0x33>
			if (runcmd(buf, tf) < 0)
f0100b3d:	89 da                	mov    %ebx,%edx
f0100b3f:	e8 96 fe ff ff       	call   f01009da <runcmd>
f0100b44:	85 c0                	test   %eax,%eax
f0100b46:	79 e1                	jns    f0100b29 <monitor+0x33>
				break;
	}
}
f0100b48:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100b4b:	c9                   	leave  
f0100b4c:	c3                   	ret    

f0100b4d <invlpg>:
	asm volatile("invlpg (%0)" : : "r"(addr) : "memory");
f0100b4d:	0f 01 38             	invlpg (%eax)
}
f0100b50:	c3                   	ret    

f0100b51 <lcr0>:
	asm volatile("movl %0,%%cr0" : : "r"(val));
f0100b51:	0f 22 c0             	mov    %eax,%cr0
}
f0100b54:	c3                   	ret    

f0100b55 <rcr0>:
	asm volatile("movl %%cr0,%0" : "=r"(val));
f0100b55:	0f 20 c0             	mov    %cr0,%eax
}
f0100b58:	c3                   	ret    

f0100b59 <lcr3>:
	asm volatile("movl %0,%%cr3" : : "r"(val));
f0100b59:	0f 22 d8             	mov    %eax,%cr3
}
f0100b5c:	c3                   	ret    

f0100b5d <page2pa>:
void user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b5d:	2b 05 58 82 24 f0    	sub    0xf0248258,%eax
f0100b63:	c1 f8 03             	sar    $0x3,%eax
f0100b66:	c1 e0 0c             	shl    $0xc,%eax
}
f0100b69:	c3                   	ret    

f0100b6a <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100b6a:	55                   	push   %ebp
f0100b6b:	89 e5                	mov    %esp,%ebp
f0100b6d:	56                   	push   %esi
f0100b6e:	53                   	push   %ebx
f0100b6f:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100b71:	83 ec 0c             	sub    $0xc,%esp
f0100b74:	50                   	push   %eax
f0100b75:	e8 26 2a 00 00       	call   f01035a0 <mc146818_read>
f0100b7a:	89 c6                	mov    %eax,%esi
f0100b7c:	83 c3 01             	add    $0x1,%ebx
f0100b7f:	89 1c 24             	mov    %ebx,(%esp)
f0100b82:	e8 19 2a 00 00       	call   f01035a0 <mc146818_read>
f0100b87:	c1 e0 08             	shl    $0x8,%eax
f0100b8a:	09 f0                	or     %esi,%eax
}
f0100b8c:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100b8f:	5b                   	pop    %ebx
f0100b90:	5e                   	pop    %esi
f0100b91:	5d                   	pop    %ebp
f0100b92:	c3                   	ret    

f0100b93 <i386_detect_memory>:

static void
i386_detect_memory(void)
{
f0100b93:	55                   	push   %ebp
f0100b94:	89 e5                	mov    %esp,%ebp
f0100b96:	56                   	push   %esi
f0100b97:	53                   	push   %ebx
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f0100b98:	b8 15 00 00 00       	mov    $0x15,%eax
f0100b9d:	e8 c8 ff ff ff       	call   f0100b6a <nvram_read>
f0100ba2:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0100ba4:	b8 17 00 00 00       	mov    $0x17,%eax
f0100ba9:	e8 bc ff ff ff       	call   f0100b6a <nvram_read>
f0100bae:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0100bb0:	b8 34 00 00 00       	mov    $0x34,%eax
f0100bb5:	e8 b0 ff ff ff       	call   f0100b6a <nvram_read>

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f0100bba:	c1 e0 06             	shl    $0x6,%eax
f0100bbd:	74 2b                	je     f0100bea <i386_detect_memory+0x57>
		totalmem = 16 * 1024 + ext16mem;
f0100bbf:	05 00 40 00 00       	add    $0x4000,%eax
	else if (extmem)
		totalmem = 1 * 1024 + extmem;
	else
		totalmem = basemem;

	npages = totalmem / (PGSIZE / 1024);
f0100bc4:	89 c2                	mov    %eax,%edx
f0100bc6:	c1 ea 02             	shr    $0x2,%edx
f0100bc9:	89 15 60 82 24 f0    	mov    %edx,0xf0248260
	npages_basemem = basemem / (PGSIZE / 1024);

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0100bcf:	89 c2                	mov    %eax,%edx
f0100bd1:	29 da                	sub    %ebx,%edx
f0100bd3:	52                   	push   %edx
f0100bd4:	53                   	push   %ebx
f0100bd5:	50                   	push   %eax
f0100bd6:	68 fc 6a 10 f0       	push   $0xf0106afc
f0100bdb:	e8 da 2b 00 00       	call   f01037ba <cprintf>
	        totalmem,
	        basemem,
	        totalmem - basemem);
}
f0100be0:	83 c4 10             	add    $0x10,%esp
f0100be3:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100be6:	5b                   	pop    %ebx
f0100be7:	5e                   	pop    %esi
f0100be8:	5d                   	pop    %ebp
f0100be9:	c3                   	ret    
		totalmem = 1 * 1024 + extmem;
f0100bea:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f0100bf0:	85 f6                	test   %esi,%esi
f0100bf2:	0f 44 c3             	cmove  %ebx,%eax
f0100bf5:	eb cd                	jmp    f0100bc4 <i386_detect_memory+0x31>

f0100bf7 <_kaddr>:
{
f0100bf7:	55                   	push   %ebp
f0100bf8:	89 e5                	mov    %esp,%ebp
f0100bfa:	53                   	push   %ebx
f0100bfb:	83 ec 04             	sub    $0x4,%esp
	if (PGNUM(pa) >= npages)
f0100bfe:	89 cb                	mov    %ecx,%ebx
f0100c00:	c1 eb 0c             	shr    $0xc,%ebx
f0100c03:	3b 1d 60 82 24 f0    	cmp    0xf0248260,%ebx
f0100c09:	73 0b                	jae    f0100c16 <_kaddr+0x1f>
	return (void *) (pa + KERNBASE);
f0100c0b:	8d 81 00 00 00 f0    	lea    -0x10000000(%ecx),%eax
}
f0100c11:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100c14:	c9                   	leave  
f0100c15:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c16:	51                   	push   %ecx
f0100c17:	68 0c 66 10 f0       	push   $0xf010660c
f0100c1c:	52                   	push   %edx
f0100c1d:	50                   	push   %eax
f0100c1e:	e8 47 f4 ff ff       	call   f010006a <_panic>

f0100c23 <page2kva>:
	return &pages[PGNUM(pa)];
}

static inline void *
page2kva(struct PageInfo *pp)
{
f0100c23:	55                   	push   %ebp
f0100c24:	89 e5                	mov    %esp,%ebp
f0100c26:	83 ec 08             	sub    $0x8,%esp
	return KADDR(page2pa(pp));
f0100c29:	e8 2f ff ff ff       	call   f0100b5d <page2pa>
f0100c2e:	89 c1                	mov    %eax,%ecx
f0100c30:	ba 58 00 00 00       	mov    $0x58,%edx
f0100c35:	b8 f1 74 10 f0       	mov    $0xf01074f1,%eax
f0100c3a:	e8 b8 ff ff ff       	call   f0100bf7 <_kaddr>
}
f0100c3f:	c9                   	leave  
f0100c40:	c3                   	ret    

f0100c41 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100c41:	55                   	push   %ebp
f0100c42:	89 e5                	mov    %esp,%ebp
f0100c44:	53                   	push   %ebx
f0100c45:	83 ec 04             	sub    $0x4,%esp
f0100c48:	89 d3                	mov    %edx,%ebx
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100c4a:	c1 ea 16             	shr    $0x16,%edx
	if (!(*pgdir & PTE_P))
f0100c4d:	8b 0c 90             	mov    (%eax,%edx,4),%ecx
		return ~0;
f0100c50:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	if (!(*pgdir & PTE_P))
f0100c55:	f6 c1 01             	test   $0x1,%cl
f0100c58:	74 15                	je     f0100c6f <check_va2pa+0x2e>
	if (*pgdir & PTE_PS)
f0100c5a:	f6 c1 80             	test   $0x80,%cl
f0100c5d:	74 15                	je     f0100c74 <check_va2pa+0x33>
		return (physaddr_t) PGADDR(PDX(*pgdir), PTX(va), PGOFF(va));
f0100c5f:	81 e1 00 00 c0 ff    	and    $0xffc00000,%ecx
f0100c65:	81 e3 ff ff 3f 00    	and    $0x3fffff,%ebx
f0100c6b:	89 c8                	mov    %ecx,%eax
f0100c6d:	09 d8                	or     %ebx,%eax
	p = (pte_t *) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100c6f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100c72:	c9                   	leave  
f0100c73:	c3                   	ret    
	p = (pte_t *) KADDR(PTE_ADDR(*pgdir));
f0100c74:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0100c7a:	ba 97 03 00 00       	mov    $0x397,%edx
f0100c7f:	b8 ff 74 10 f0       	mov    $0xf01074ff,%eax
f0100c84:	e8 6e ff ff ff       	call   f0100bf7 <_kaddr>
	if (!(p[PTX(va)] & PTE_P))
f0100c89:	c1 eb 0c             	shr    $0xc,%ebx
f0100c8c:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0100c92:	8b 14 98             	mov    (%eax,%ebx,4),%edx
	return PTE_ADDR(p[PTX(va)]);
f0100c95:	89 d0                	mov    %edx,%eax
f0100c97:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100c9c:	f6 c2 01             	test   $0x1,%dl
f0100c9f:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100ca4:	0f 44 c2             	cmove  %edx,%eax
f0100ca7:	eb c6                	jmp    f0100c6f <check_va2pa+0x2e>

f0100ca9 <_paddr>:
	if ((uint32_t) kva < KERNBASE)
f0100ca9:	81 f9 ff ff ff ef    	cmp    $0xefffffff,%ecx
f0100caf:	76 07                	jbe    f0100cb8 <_paddr+0xf>
	return (physaddr_t) kva - KERNBASE;
f0100cb1:	8d 81 00 00 00 10    	lea    0x10000000(%ecx),%eax
}
f0100cb7:	c3                   	ret    
{
f0100cb8:	55                   	push   %ebp
f0100cb9:	89 e5                	mov    %esp,%ebp
f0100cbb:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100cbe:	51                   	push   %ecx
f0100cbf:	68 30 66 10 f0       	push   $0xf0106630
f0100cc4:	52                   	push   %edx
f0100cc5:	50                   	push   %eax
f0100cc6:	e8 9f f3 ff ff       	call   f010006a <_panic>

f0100ccb <boot_alloc>:
{
f0100ccb:	55                   	push   %ebp
f0100ccc:	89 e5                	mov    %esp,%ebp
f0100cce:	53                   	push   %ebx
f0100ccf:	83 ec 04             	sub    $0x4,%esp
	if (!nextfree) {
f0100cd2:	83 3d 64 82 24 f0 00 	cmpl   $0x0,0xf0248264
f0100cd9:	74 4b                	je     f0100d26 <boot_alloc+0x5b>
	uint32_t last = PADDR(nextfree + n);
f0100cdb:	8b 1d 64 82 24 f0    	mov    0xf0248264,%ebx
f0100ce1:	8d 0c 03             	lea    (%ebx,%eax,1),%ecx
f0100ce4:	ba 6d 00 00 00       	mov    $0x6d,%edx
f0100ce9:	b8 ff 74 10 f0       	mov    $0xf01074ff,%eax
f0100cee:	e8 b6 ff ff ff       	call   f0100ca9 <_paddr>
f0100cf3:	89 c1                	mov    %eax,%ecx
	if (last >= PGSIZE * npages) {
f0100cf5:	a1 60 82 24 f0       	mov    0xf0248260,%eax
f0100cfa:	c1 e0 0c             	shl    $0xc,%eax
f0100cfd:	39 c8                	cmp    %ecx,%eax
f0100cff:	76 38                	jbe    f0100d39 <boot_alloc+0x6e>
	nextfree = ROUNDUP(KADDR(last), PGSIZE);
f0100d01:	ba 73 00 00 00       	mov    $0x73,%edx
f0100d06:	b8 ff 74 10 f0       	mov    $0xf01074ff,%eax
f0100d0b:	e8 e7 fe ff ff       	call   f0100bf7 <_kaddr>
f0100d10:	05 ff 0f 00 00       	add    $0xfff,%eax
f0100d15:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100d1a:	a3 64 82 24 f0       	mov    %eax,0xf0248264
}
f0100d1f:	89 d8                	mov    %ebx,%eax
f0100d21:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100d24:	c9                   	leave  
f0100d25:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100d26:	ba c7 b3 28 f0       	mov    $0xf028b3c7,%edx
f0100d2b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100d31:	89 15 64 82 24 f0    	mov    %edx,0xf0248264
f0100d37:	eb a2                	jmp    f0100cdb <boot_alloc+0x10>
		panic("boot_alloc: Not enough memory\n");
f0100d39:	83 ec 04             	sub    $0x4,%esp
f0100d3c:	68 38 6b 10 f0       	push   $0xf0106b38
f0100d41:	6a 6f                	push   $0x6f
f0100d43:	68 ff 74 10 f0       	push   $0xf01074ff
f0100d48:	e8 1d f3 ff ff       	call   f010006a <_panic>

f0100d4d <check_kern_pgdir>:
{
f0100d4d:	55                   	push   %ebp
f0100d4e:	89 e5                	mov    %esp,%ebp
f0100d50:	57                   	push   %edi
f0100d51:	56                   	push   %esi
f0100d52:	53                   	push   %ebx
f0100d53:	83 ec 1c             	sub    $0x1c,%esp
	pgdir = kern_pgdir;
f0100d56:	8b 3d 5c 82 24 f0    	mov    0xf024825c,%edi
	n = ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE);
f0100d5c:	a1 60 82 24 f0       	mov    0xf0248260,%eax
f0100d61:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0100d64:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0100d6b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0100d70:	8b 0d 58 82 24 f0    	mov    0xf0248258,%ecx
f0100d76:	89 4d e0             	mov    %ecx,-0x20(%ebp)
	for (i = 0; i < n; i += PGSIZE)
f0100d79:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100d7e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f0100d81:	89 c7                	mov    %eax,%edi
f0100d83:	39 fb                	cmp    %edi,%ebx
f0100d85:	73 49                	jae    f0100dd0 <check_kern_pgdir+0x83>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0100d87:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0100d8d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100d90:	e8 ac fe ff ff       	call   f0100c41 <check_va2pa>
f0100d95:	89 c6                	mov    %eax,%esi
f0100d97:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100d9a:	ba 53 03 00 00       	mov    $0x353,%edx
f0100d9f:	b8 ff 74 10 f0       	mov    $0xf01074ff,%eax
f0100da4:	e8 00 ff ff ff       	call   f0100ca9 <_paddr>
f0100da9:	01 d8                	add    %ebx,%eax
f0100dab:	39 c6                	cmp    %eax,%esi
f0100dad:	75 08                	jne    f0100db7 <check_kern_pgdir+0x6a>
	for (i = 0; i < n; i += PGSIZE)
f0100daf:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0100db5:	eb cc                	jmp    f0100d83 <check_kern_pgdir+0x36>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0100db7:	68 58 6b 10 f0       	push   $0xf0106b58
f0100dbc:	68 0b 75 10 f0       	push   $0xf010750b
f0100dc1:	68 53 03 00 00       	push   $0x353
f0100dc6:	68 ff 74 10 f0       	push   $0xf01074ff
f0100dcb:	e8 9a f2 ff ff       	call   f010006a <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0100dd0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100dd3:	a1 70 82 24 f0       	mov    0xf0248270,%eax
f0100dd8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
f0100ddb:	bb 00 00 00 00       	mov    $0x0,%ebx
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0100de0:	8d 93 00 00 c0 ee    	lea    -0x11400000(%ebx),%edx
f0100de6:	89 f8                	mov    %edi,%eax
f0100de8:	e8 54 fe ff ff       	call   f0100c41 <check_va2pa>
f0100ded:	89 c6                	mov    %eax,%esi
f0100def:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0100df2:	ba 58 03 00 00       	mov    $0x358,%edx
f0100df7:	b8 ff 74 10 f0       	mov    $0xf01074ff,%eax
f0100dfc:	e8 a8 fe ff ff       	call   f0100ca9 <_paddr>
f0100e01:	01 d8                	add    %ebx,%eax
f0100e03:	39 c6                	cmp    %eax,%esi
f0100e05:	75 36                	jne    f0100e3d <check_kern_pgdir+0xf0>
	for (i = 0; i < n; i += PGSIZE)
f0100e07:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0100e0d:	81 fb 00 20 02 00    	cmp    $0x22000,%ebx
f0100e13:	75 cb                	jne    f0100de0 <check_kern_pgdir+0x93>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0100e15:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0100e18:	c1 e6 0c             	shl    $0xc,%esi
f0100e1b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100e20:	39 de                	cmp    %ebx,%esi
f0100e22:	76 4b                	jbe    f0100e6f <check_kern_pgdir+0x122>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0100e24:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0100e2a:	89 f8                	mov    %edi,%eax
f0100e2c:	e8 10 fe ff ff       	call   f0100c41 <check_va2pa>
f0100e31:	39 d8                	cmp    %ebx,%eax
f0100e33:	75 21                	jne    f0100e56 <check_kern_pgdir+0x109>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0100e35:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0100e3b:	eb e3                	jmp    f0100e20 <check_kern_pgdir+0xd3>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0100e3d:	68 8c 6b 10 f0       	push   $0xf0106b8c
f0100e42:	68 0b 75 10 f0       	push   $0xf010750b
f0100e47:	68 58 03 00 00       	push   $0x358
f0100e4c:	68 ff 74 10 f0       	push   $0xf01074ff
f0100e51:	e8 14 f2 ff ff       	call   f010006a <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0100e56:	68 c0 6b 10 f0       	push   $0xf0106bc0
f0100e5b:	68 0b 75 10 f0       	push   $0xf010750b
f0100e60:	68 5c 03 00 00       	push   $0x35c
f0100e65:	68 ff 74 10 f0       	push   $0xf01074ff
f0100e6a:	e8 fb f1 ff ff       	call   f010006a <_panic>
f0100e6f:	c7 45 dc 00 a0 24 f0 	movl   $0xf024a000,-0x24(%ebp)
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0100e76:	b8 00 80 ff ef       	mov    $0xefff8000,%eax
f0100e7b:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f0100e7e:	89 c7                	mov    %eax,%edi
f0100e80:	8d b7 00 80 ff ff    	lea    -0x8000(%edi),%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i) ==
f0100e86:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100e89:	89 45 e0             	mov    %eax,-0x20(%ebp)
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0100e8c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100e91:	89 75 d8             	mov    %esi,-0x28(%ebp)
			assert(check_va2pa(pgdir, base + KSTKGAP + i) ==
f0100e94:	8d 14 3b             	lea    (%ebx,%edi,1),%edx
f0100e97:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100e9a:	e8 a2 fd ff ff       	call   f0100c41 <check_va2pa>
f0100e9f:	89 c6                	mov    %eax,%esi
f0100ea1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100ea4:	ba 64 03 00 00       	mov    $0x364,%edx
f0100ea9:	b8 ff 74 10 f0       	mov    $0xf01074ff,%eax
f0100eae:	e8 f6 fd ff ff       	call   f0100ca9 <_paddr>
f0100eb3:	01 d8                	add    %ebx,%eax
f0100eb5:	39 c6                	cmp    %eax,%esi
f0100eb7:	75 4d                	jne    f0100f06 <check_kern_pgdir+0x1b9>
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0100eb9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0100ebf:	81 fb 00 80 00 00    	cmp    $0x8000,%ebx
f0100ec5:	75 cd                	jne    f0100e94 <check_kern_pgdir+0x147>
f0100ec7:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0100eca:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			assert(check_va2pa(pgdir, base + i) == ~0);
f0100ecd:	89 f2                	mov    %esi,%edx
f0100ecf:	89 d8                	mov    %ebx,%eax
f0100ed1:	e8 6b fd ff ff       	call   f0100c41 <check_va2pa>
f0100ed6:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100ed9:	75 44                	jne    f0100f1f <check_kern_pgdir+0x1d2>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0100edb:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0100ee1:	39 fe                	cmp    %edi,%esi
f0100ee3:	75 e8                	jne    f0100ecd <check_kern_pgdir+0x180>
	for (n = 0; n < NCPU; n++) {
f0100ee5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0100ee8:	81 ef 00 00 01 00    	sub    $0x10000,%edi
f0100eee:	81 45 dc 00 80 00 00 	addl   $0x8000,-0x24(%ebp)
f0100ef5:	81 ff 00 80 f7 ef    	cmp    $0xeff78000,%edi
f0100efb:	75 83                	jne    f0100e80 <check_kern_pgdir+0x133>
	for (i = 0; i < NPDENTRIES; i++) {
f0100efd:	89 df                	mov    %ebx,%edi
f0100eff:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f04:	eb 68                	jmp    f0100f6e <check_kern_pgdir+0x221>
			assert(check_va2pa(pgdir, base + KSTKGAP + i) ==
f0100f06:	68 e8 6b 10 f0       	push   $0xf0106be8
f0100f0b:	68 0b 75 10 f0       	push   $0xf010750b
f0100f10:	68 63 03 00 00       	push   $0x363
f0100f15:	68 ff 74 10 f0       	push   $0xf01074ff
f0100f1a:	e8 4b f1 ff ff       	call   f010006a <_panic>
			assert(check_va2pa(pgdir, base + i) == ~0);
f0100f1f:	68 30 6c 10 f0       	push   $0xf0106c30
f0100f24:	68 0b 75 10 f0       	push   $0xf010750b
f0100f29:	68 66 03 00 00       	push   $0x366
f0100f2e:	68 ff 74 10 f0       	push   $0xf01074ff
f0100f33:	e8 32 f1 ff ff       	call   f010006a <_panic>
			assert(pgdir[i] & PTE_P);
f0100f38:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0100f3c:	75 48                	jne    f0100f86 <check_kern_pgdir+0x239>
f0100f3e:	68 20 75 10 f0       	push   $0xf0107520
f0100f43:	68 0b 75 10 f0       	push   $0xf010750b
f0100f48:	68 71 03 00 00       	push   $0x371
f0100f4d:	68 ff 74 10 f0       	push   $0xf01074ff
f0100f52:	e8 13 f1 ff ff       	call   f010006a <_panic>
				assert(pgdir[i] & PTE_P);
f0100f57:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0100f5a:	f6 c2 01             	test   $0x1,%dl
f0100f5d:	74 2c                	je     f0100f8b <check_kern_pgdir+0x23e>
				assert(pgdir[i] & PTE_W);
f0100f5f:	f6 c2 02             	test   $0x2,%dl
f0100f62:	74 40                	je     f0100fa4 <check_kern_pgdir+0x257>
	for (i = 0; i < NPDENTRIES; i++) {
f0100f64:	83 c0 01             	add    $0x1,%eax
f0100f67:	3d 00 04 00 00       	cmp    $0x400,%eax
f0100f6c:	74 68                	je     f0100fd6 <check_kern_pgdir+0x289>
		switch (i) {
f0100f6e:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0100f74:	83 fa 04             	cmp    $0x4,%edx
f0100f77:	76 bf                	jbe    f0100f38 <check_kern_pgdir+0x1eb>
			if (i >= PDX(KERNBASE)) {
f0100f79:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0100f7e:	77 d7                	ja     f0100f57 <check_kern_pgdir+0x20a>
				assert(pgdir[i] == 0);
f0100f80:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0100f84:	75 37                	jne    f0100fbd <check_kern_pgdir+0x270>
	for (i = 0; i < NPDENTRIES; i++) {
f0100f86:	83 c0 01             	add    $0x1,%eax
f0100f89:	eb e3                	jmp    f0100f6e <check_kern_pgdir+0x221>
				assert(pgdir[i] & PTE_P);
f0100f8b:	68 20 75 10 f0       	push   $0xf0107520
f0100f90:	68 0b 75 10 f0       	push   $0xf010750b
f0100f95:	68 75 03 00 00       	push   $0x375
f0100f9a:	68 ff 74 10 f0       	push   $0xf01074ff
f0100f9f:	e8 c6 f0 ff ff       	call   f010006a <_panic>
				assert(pgdir[i] & PTE_W);
f0100fa4:	68 31 75 10 f0       	push   $0xf0107531
f0100fa9:	68 0b 75 10 f0       	push   $0xf010750b
f0100fae:	68 76 03 00 00       	push   $0x376
f0100fb3:	68 ff 74 10 f0       	push   $0xf01074ff
f0100fb8:	e8 ad f0 ff ff       	call   f010006a <_panic>
				assert(pgdir[i] == 0);
f0100fbd:	68 42 75 10 f0       	push   $0xf0107542
f0100fc2:	68 0b 75 10 f0       	push   $0xf010750b
f0100fc7:	68 78 03 00 00       	push   $0x378
f0100fcc:	68 ff 74 10 f0       	push   $0xf01074ff
f0100fd1:	e8 94 f0 ff ff       	call   f010006a <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0100fd6:	83 ec 0c             	sub    $0xc,%esp
f0100fd9:	68 54 6c 10 f0       	push   $0xf0106c54
f0100fde:	e8 d7 27 00 00       	call   f01037ba <cprintf>
}
f0100fe3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100fe6:	5b                   	pop    %ebx
f0100fe7:	5e                   	pop    %esi
f0100fe8:	5f                   	pop    %edi
f0100fe9:	5d                   	pop    %ebp
f0100fea:	c3                   	ret    

f0100feb <check_page_free_list>:
{
f0100feb:	55                   	push   %ebp
f0100fec:	89 e5                	mov    %esp,%ebp
f0100fee:	57                   	push   %edi
f0100fef:	56                   	push   %esi
f0100ff0:	53                   	push   %ebx
f0100ff1:	83 ec 2c             	sub    $0x2c,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100ff4:	84 c0                	test   %al,%al
f0100ff6:	0f 85 3b 02 00 00    	jne    f0101237 <check_page_free_list+0x24c>
	if (!page_free_list)
f0100ffc:	83 3d 6c 82 24 f0 00 	cmpl   $0x0,0xf024826c
f0101003:	74 0a                	je     f010100f <check_page_free_list+0x24>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0101005:	be 00 04 00 00       	mov    $0x400,%esi
f010100a:	e9 80 02 00 00       	jmp    f010128f <check_page_free_list+0x2a4>
		panic("'page_free_list' is a null pointer!");
f010100f:	83 ec 04             	sub    $0x4,%esp
f0101012:	68 74 6c 10 f0       	push   $0xf0106c74
f0101017:	68 be 02 00 00       	push   $0x2be
f010101c:	68 ff 74 10 f0       	push   $0xf01074ff
f0101021:	e8 44 f0 ff ff       	call   f010006a <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101026:	8b 1b                	mov    (%ebx),%ebx
f0101028:	85 db                	test   %ebx,%ebx
f010102a:	74 2d                	je     f0101059 <check_page_free_list+0x6e>
		if (PDX(page2pa(pp)) < pdx_limit)
f010102c:	89 d8                	mov    %ebx,%eax
f010102e:	e8 2a fb ff ff       	call   f0100b5d <page2pa>
f0101033:	c1 e8 16             	shr    $0x16,%eax
f0101036:	39 f0                	cmp    %esi,%eax
f0101038:	73 ec                	jae    f0101026 <check_page_free_list+0x3b>
			memset(page2kva(pp), 0x97, 128);
f010103a:	89 d8                	mov    %ebx,%eax
f010103c:	e8 e2 fb ff ff       	call   f0100c23 <page2kva>
f0101041:	83 ec 04             	sub    $0x4,%esp
f0101044:	68 80 00 00 00       	push   $0x80
f0101049:	68 97 00 00 00       	push   $0x97
f010104e:	50                   	push   %eax
f010104f:	e8 9e 48 00 00       	call   f01058f2 <memset>
f0101054:	83 c4 10             	add    $0x10,%esp
f0101057:	eb cd                	jmp    f0101026 <check_page_free_list+0x3b>
	first_free_page = (char *) boot_alloc(0);
f0101059:	b8 00 00 00 00       	mov    $0x0,%eax
f010105e:	e8 68 fc ff ff       	call   f0100ccb <boot_alloc>
f0101063:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101066:	8b 1d 6c 82 24 f0    	mov    0xf024826c,%ebx
		assert(pp >= pages);
f010106c:	8b 35 58 82 24 f0    	mov    0xf0248258,%esi
		assert(pp < pages + npages);
f0101072:	a1 60 82 24 f0       	mov    0xf0248260,%eax
f0101077:	8d 3c c6             	lea    (%esi,%eax,8),%edi
	int nfree_basemem = 0, nfree_extmem = 0;
f010107a:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
f0101081:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101088:	e9 c1 00 00 00       	jmp    f010114e <check_page_free_list+0x163>
		assert(pp >= pages);
f010108d:	68 50 75 10 f0       	push   $0xf0107550
f0101092:	68 0b 75 10 f0       	push   $0xf010750b
f0101097:	68 d8 02 00 00       	push   $0x2d8
f010109c:	68 ff 74 10 f0       	push   $0xf01074ff
f01010a1:	e8 c4 ef ff ff       	call   f010006a <_panic>
		assert(pp < pages + npages);
f01010a6:	68 5c 75 10 f0       	push   $0xf010755c
f01010ab:	68 0b 75 10 f0       	push   $0xf010750b
f01010b0:	68 d9 02 00 00       	push   $0x2d9
f01010b5:	68 ff 74 10 f0       	push   $0xf01074ff
f01010ba:	e8 ab ef ff ff       	call   f010006a <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f01010bf:	68 98 6c 10 f0       	push   $0xf0106c98
f01010c4:	68 0b 75 10 f0       	push   $0xf010750b
f01010c9:	68 da 02 00 00       	push   $0x2da
f01010ce:	68 ff 74 10 f0       	push   $0xf01074ff
f01010d3:	e8 92 ef ff ff       	call   f010006a <_panic>
		assert(page2pa(pp) != 0);
f01010d8:	68 70 75 10 f0       	push   $0xf0107570
f01010dd:	68 0b 75 10 f0       	push   $0xf010750b
f01010e2:	68 dd 02 00 00       	push   $0x2dd
f01010e7:	68 ff 74 10 f0       	push   $0xf01074ff
f01010ec:	e8 79 ef ff ff       	call   f010006a <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f01010f1:	68 81 75 10 f0       	push   $0xf0107581
f01010f6:	68 0b 75 10 f0       	push   $0xf010750b
f01010fb:	68 de 02 00 00       	push   $0x2de
f0101100:	68 ff 74 10 f0       	push   $0xf01074ff
f0101105:	e8 60 ef ff ff       	call   f010006a <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f010110a:	68 cc 6c 10 f0       	push   $0xf0106ccc
f010110f:	68 0b 75 10 f0       	push   $0xf010750b
f0101114:	68 df 02 00 00       	push   $0x2df
f0101119:	68 ff 74 10 f0       	push   $0xf01074ff
f010111e:	e8 47 ef ff ff       	call   f010006a <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0101123:	68 9a 75 10 f0       	push   $0xf010759a
f0101128:	68 0b 75 10 f0       	push   $0xf010750b
f010112d:	68 e0 02 00 00       	push   $0x2e0
f0101132:	68 ff 74 10 f0       	push   $0xf01074ff
f0101137:	e8 2e ef ff ff       	call   f010006a <_panic>
		assert(page2pa(pp) < EXTPHYSMEM ||
f010113c:	89 d8                	mov    %ebx,%eax
f010113e:	e8 e0 fa ff ff       	call   f0100c23 <page2kva>
f0101143:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101146:	77 6a                	ja     f01011b2 <check_page_free_list+0x1c7>
			++nfree_extmem;
f0101148:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f010114c:	8b 1b                	mov    (%ebx),%ebx
f010114e:	85 db                	test   %ebx,%ebx
f0101150:	0f 84 8e 00 00 00    	je     f01011e4 <check_page_free_list+0x1f9>
		assert(pp >= pages);
f0101156:	39 de                	cmp    %ebx,%esi
f0101158:	0f 87 2f ff ff ff    	ja     f010108d <check_page_free_list+0xa2>
		assert(pp < pages + npages);
f010115e:	39 df                	cmp    %ebx,%edi
f0101160:	0f 86 40 ff ff ff    	jbe    f01010a6 <check_page_free_list+0xbb>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101166:	89 d8                	mov    %ebx,%eax
f0101168:	29 f0                	sub    %esi,%eax
f010116a:	a8 07                	test   $0x7,%al
f010116c:	0f 85 4d ff ff ff    	jne    f01010bf <check_page_free_list+0xd4>
		assert(page2pa(pp) != 0);
f0101172:	89 d8                	mov    %ebx,%eax
f0101174:	e8 e4 f9 ff ff       	call   f0100b5d <page2pa>
f0101179:	85 c0                	test   %eax,%eax
f010117b:	0f 84 57 ff ff ff    	je     f01010d8 <check_page_free_list+0xed>
		assert(page2pa(pp) != IOPHYSMEM);
f0101181:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0101186:	0f 84 65 ff ff ff    	je     f01010f1 <check_page_free_list+0x106>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f010118c:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0101191:	0f 84 73 ff ff ff    	je     f010110a <check_page_free_list+0x11f>
		assert(page2pa(pp) != EXTPHYSMEM);
f0101197:	3d 00 00 10 00       	cmp    $0x100000,%eax
f010119c:	74 85                	je     f0101123 <check_page_free_list+0x138>
		assert(page2pa(pp) < EXTPHYSMEM ||
f010119e:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f01011a3:	77 97                	ja     f010113c <check_page_free_list+0x151>
		assert(page2pa(pp) != MPENTRY_PADDR);
f01011a5:	3d 00 70 00 00       	cmp    $0x7000,%eax
f01011aa:	74 1f                	je     f01011cb <check_page_free_list+0x1e0>
			++nfree_basemem;
f01011ac:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
f01011b0:	eb 9a                	jmp    f010114c <check_page_free_list+0x161>
		assert(page2pa(pp) < EXTPHYSMEM ||
f01011b2:	68 f0 6c 10 f0       	push   $0xf0106cf0
f01011b7:	68 0b 75 10 f0       	push   $0xf010750b
f01011bc:	68 e1 02 00 00       	push   $0x2e1
f01011c1:	68 ff 74 10 f0       	push   $0xf01074ff
f01011c6:	e8 9f ee ff ff       	call   f010006a <_panic>
		assert(page2pa(pp) != MPENTRY_PADDR);
f01011cb:	68 b4 75 10 f0       	push   $0xf01075b4
f01011d0:	68 0b 75 10 f0       	push   $0xf010750b
f01011d5:	68 e4 02 00 00       	push   $0x2e4
f01011da:	68 ff 74 10 f0       	push   $0xf01074ff
f01011df:	e8 86 ee ff ff       	call   f010006a <_panic>
	assert(nfree_basemem > 0);
f01011e4:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01011e8:	7e 1b                	jle    f0101205 <check_page_free_list+0x21a>
	assert(nfree_extmem > 0);
f01011ea:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f01011ee:	7e 2e                	jle    f010121e <check_page_free_list+0x233>
	cprintf("check_page_free_list() succeeded!\n");
f01011f0:	83 ec 0c             	sub    $0xc,%esp
f01011f3:	68 38 6d 10 f0       	push   $0xf0106d38
f01011f8:	e8 bd 25 00 00       	call   f01037ba <cprintf>
}
f01011fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101200:	5b                   	pop    %ebx
f0101201:	5e                   	pop    %esi
f0101202:	5f                   	pop    %edi
f0101203:	5d                   	pop    %ebp
f0101204:	c3                   	ret    
	assert(nfree_basemem > 0);
f0101205:	68 d1 75 10 f0       	push   $0xf01075d1
f010120a:	68 0b 75 10 f0       	push   $0xf010750b
f010120f:	68 ec 02 00 00       	push   $0x2ec
f0101214:	68 ff 74 10 f0       	push   $0xf01074ff
f0101219:	e8 4c ee ff ff       	call   f010006a <_panic>
	assert(nfree_extmem > 0);
f010121e:	68 e3 75 10 f0       	push   $0xf01075e3
f0101223:	68 0b 75 10 f0       	push   $0xf010750b
f0101228:	68 ed 02 00 00       	push   $0x2ed
f010122d:	68 ff 74 10 f0       	push   $0xf01074ff
f0101232:	e8 33 ee ff ff       	call   f010006a <_panic>
	if (!page_free_list)
f0101237:	8b 1d 6c 82 24 f0    	mov    0xf024826c,%ebx
f010123d:	85 db                	test   %ebx,%ebx
f010123f:	0f 84 ca fd ff ff    	je     f010100f <check_page_free_list+0x24>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0101245:	8d 45 d8             	lea    -0x28(%ebp),%eax
f0101248:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010124b:	8d 45 dc             	lea    -0x24(%ebp),%eax
f010124e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0101251:	89 d8                	mov    %ebx,%eax
f0101253:	e8 05 f9 ff ff       	call   f0100b5d <page2pa>
f0101258:	c1 e8 16             	shr    $0x16,%eax
f010125b:	0f 95 c0             	setne  %al
f010125e:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f0101261:	8b 54 85 e0          	mov    -0x20(%ebp,%eax,4),%edx
f0101265:	89 1a                	mov    %ebx,(%edx)
			tp[pagetype] = &pp->pp_link;
f0101267:	89 5c 85 e0          	mov    %ebx,-0x20(%ebp,%eax,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f010126b:	8b 1b                	mov    (%ebx),%ebx
f010126d:	85 db                	test   %ebx,%ebx
f010126f:	75 e0                	jne    f0101251 <check_page_free_list+0x266>
		*tp[1] = 0;
f0101271:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101274:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f010127a:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010127d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101280:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0101282:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101285:	a3 6c 82 24 f0       	mov    %eax,0xf024826c
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f010128a:	be 01 00 00 00       	mov    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010128f:	8b 1d 6c 82 24 f0    	mov    0xf024826c,%ebx
f0101295:	e9 8e fd ff ff       	jmp    f0101028 <check_page_free_list+0x3d>

f010129a <pa2page>:
	if (PGNUM(pa) >= npages)
f010129a:	c1 e8 0c             	shr    $0xc,%eax
f010129d:	3b 05 60 82 24 f0    	cmp    0xf0248260,%eax
f01012a3:	73 0a                	jae    f01012af <pa2page+0x15>
	return &pages[PGNUM(pa)];
f01012a5:	8b 15 58 82 24 f0    	mov    0xf0248258,%edx
f01012ab:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f01012ae:	c3                   	ret    
{
f01012af:	55                   	push   %ebp
f01012b0:	89 e5                	mov    %esp,%ebp
f01012b2:	83 ec 0c             	sub    $0xc,%esp
		panic("pa2page called with invalid pa");
f01012b5:	68 5c 6d 10 f0       	push   $0xf0106d5c
f01012ba:	6a 51                	push   $0x51
f01012bc:	68 f1 74 10 f0       	push   $0xf01074f1
f01012c1:	e8 a4 ed ff ff       	call   f010006a <_panic>

f01012c6 <page_init>:
{
f01012c6:	55                   	push   %ebp
f01012c7:	89 e5                	mov    %esp,%ebp
f01012c9:	56                   	push   %esi
f01012ca:	53                   	push   %ebx
	for (i = 0; i < npages; i++) {
f01012cb:	bb 00 00 00 00       	mov    $0x0,%ebx
f01012d0:	eb 23                	jmp    f01012f5 <page_init+0x2f>
		pages[i].pp_link = page_free_list;
f01012d2:	a1 58 82 24 f0       	mov    0xf0248258,%eax
f01012d7:	8b 15 6c 82 24 f0    	mov    0xf024826c,%edx
f01012dd:	89 14 30             	mov    %edx,(%eax,%esi,1)
		pages[i].pp_ref = 0;
f01012e0:	03 35 58 82 24 f0    	add    0xf0248258,%esi
f01012e6:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
		page_free_list = &pages[i];
f01012ec:	89 35 6c 82 24 f0    	mov    %esi,0xf024826c
	for (i = 0; i < npages; i++) {
f01012f2:	83 c3 01             	add    $0x1,%ebx
f01012f5:	39 1d 60 82 24 f0    	cmp    %ebx,0xf0248260
f01012fb:	76 53                	jbe    f0101350 <page_init+0x8a>
f01012fd:	8d 34 dd 00 00 00 00 	lea    0x0(,%ebx,8),%esi
		pages[i].pp_link = NULL;
f0101304:	a1 58 82 24 f0       	mov    0xf0248258,%eax
f0101309:	c7 04 d8 00 00 00 00 	movl   $0x0,(%eax,%ebx,8)
		if ((PGNUM(MPENTRY_PADDR)) == i)
f0101310:	83 fb 07             	cmp    $0x7,%ebx
f0101313:	74 dd                	je     f01012f2 <page_init+0x2c>
f0101315:	85 db                	test   %ebx,%ebx
f0101317:	74 d9                	je     f01012f2 <page_init+0x2c>
		if (i >= PGNUM(IOPHYSMEM) && i < PGNUM(EXTPHYSMEM))
f0101319:	8d 83 60 ff ff ff    	lea    -0xa0(%ebx),%eax
f010131f:	83 f8 5f             	cmp    $0x5f,%eax
f0101322:	76 ce                	jbe    f01012f2 <page_init+0x2c>
		if (i >= PGNUM(EXTPHYSMEM) && i < PGNUM(PADDR(boot_alloc(0))))
f0101324:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
f010132a:	76 a6                	jbe    f01012d2 <page_init+0xc>
f010132c:	b8 00 00 00 00       	mov    $0x0,%eax
f0101331:	e8 95 f9 ff ff       	call   f0100ccb <boot_alloc>
f0101336:	89 c1                	mov    %eax,%ecx
f0101338:	ba 45 01 00 00       	mov    $0x145,%edx
f010133d:	b8 ff 74 10 f0       	mov    $0xf01074ff,%eax
f0101342:	e8 62 f9 ff ff       	call   f0100ca9 <_paddr>
f0101347:	c1 e8 0c             	shr    $0xc,%eax
f010134a:	39 d8                	cmp    %ebx,%eax
f010134c:	76 84                	jbe    f01012d2 <page_init+0xc>
f010134e:	eb a2                	jmp    f01012f2 <page_init+0x2c>
}
f0101350:	5b                   	pop    %ebx
f0101351:	5e                   	pop    %esi
f0101352:	5d                   	pop    %ebp
f0101353:	c3                   	ret    

f0101354 <page_alloc>:
{
f0101354:	55                   	push   %ebp
f0101355:	89 e5                	mov    %esp,%ebp
f0101357:	53                   	push   %ebx
f0101358:	83 ec 04             	sub    $0x4,%esp
	if (!page_free_list)
f010135b:	8b 1d 6c 82 24 f0    	mov    0xf024826c,%ebx
f0101361:	85 db                	test   %ebx,%ebx
f0101363:	74 13                	je     f0101378 <page_alloc+0x24>
	page_free_list = free_page->pp_link;
f0101365:	8b 03                	mov    (%ebx),%eax
f0101367:	a3 6c 82 24 f0       	mov    %eax,0xf024826c
	free_page->pp_link = NULL;
f010136c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (alloc_flags & ALLOC_ZERO) {
f0101372:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0101376:	75 07                	jne    f010137f <page_alloc+0x2b>
}
f0101378:	89 d8                	mov    %ebx,%eax
f010137a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010137d:	c9                   	leave  
f010137e:	c3                   	ret    
		memset(page2kva(free_page), 0, PGSIZE);
f010137f:	89 d8                	mov    %ebx,%eax
f0101381:	e8 9d f8 ff ff       	call   f0100c23 <page2kva>
f0101386:	83 ec 04             	sub    $0x4,%esp
f0101389:	68 00 10 00 00       	push   $0x1000
f010138e:	6a 00                	push   $0x0
f0101390:	50                   	push   %eax
f0101391:	e8 5c 45 00 00       	call   f01058f2 <memset>
f0101396:	83 c4 10             	add    $0x10,%esp
f0101399:	eb dd                	jmp    f0101378 <page_alloc+0x24>

f010139b <page_free>:
{
f010139b:	55                   	push   %ebp
f010139c:	89 e5                	mov    %esp,%ebp
f010139e:	83 ec 08             	sub    $0x8,%esp
f01013a1:	8b 45 08             	mov    0x8(%ebp),%eax
	if (pp->pp_ref)
f01013a4:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f01013a9:	75 14                	jne    f01013bf <page_free+0x24>
	if (pp->pp_link)
f01013ab:	83 38 00             	cmpl   $0x0,(%eax)
f01013ae:	75 26                	jne    f01013d6 <page_free+0x3b>
	pp->pp_link = page_free_list;
f01013b0:	8b 15 6c 82 24 f0    	mov    0xf024826c,%edx
f01013b6:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f01013b8:	a3 6c 82 24 f0       	mov    %eax,0xf024826c
}
f01013bd:	c9                   	leave  
f01013be:	c3                   	ret    
		panic("page_free: pp_ref is nonzero\n");
f01013bf:	83 ec 04             	sub    $0x4,%esp
f01013c2:	68 f4 75 10 f0       	push   $0xf01075f4
f01013c7:	68 74 01 00 00       	push   $0x174
f01013cc:	68 ff 74 10 f0       	push   $0xf01074ff
f01013d1:	e8 94 ec ff ff       	call   f010006a <_panic>
		panic("page_free: pp_link is not NULL\n");
f01013d6:	83 ec 04             	sub    $0x4,%esp
f01013d9:	68 7c 6d 10 f0       	push   $0xf0106d7c
f01013de:	68 76 01 00 00       	push   $0x176
f01013e3:	68 ff 74 10 f0       	push   $0xf01074ff
f01013e8:	e8 7d ec ff ff       	call   f010006a <_panic>

f01013ed <check_page_alloc>:
{
f01013ed:	55                   	push   %ebp
f01013ee:	89 e5                	mov    %esp,%ebp
f01013f0:	57                   	push   %edi
f01013f1:	56                   	push   %esi
f01013f2:	53                   	push   %ebx
f01013f3:	83 ec 1c             	sub    $0x1c,%esp
	if (!pages)
f01013f6:	83 3d 58 82 24 f0 00 	cmpl   $0x0,0xf0248258
f01013fd:	74 0c                	je     f010140b <check_page_alloc+0x1e>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01013ff:	a1 6c 82 24 f0       	mov    0xf024826c,%eax
f0101404:	be 00 00 00 00       	mov    $0x0,%esi
f0101409:	eb 1c                	jmp    f0101427 <check_page_alloc+0x3a>
		panic("'pages' is a null pointer!");
f010140b:	83 ec 04             	sub    $0x4,%esp
f010140e:	68 12 76 10 f0       	push   $0xf0107612
f0101413:	68 00 03 00 00       	push   $0x300
f0101418:	68 ff 74 10 f0       	push   $0xf01074ff
f010141d:	e8 48 ec ff ff       	call   f010006a <_panic>
		++nfree;
f0101422:	83 c6 01             	add    $0x1,%esi
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101425:	8b 00                	mov    (%eax),%eax
f0101427:	85 c0                	test   %eax,%eax
f0101429:	75 f7                	jne    f0101422 <check_page_alloc+0x35>
	assert((pp0 = page_alloc(0)));
f010142b:	83 ec 0c             	sub    $0xc,%esp
f010142e:	6a 00                	push   $0x0
f0101430:	e8 1f ff ff ff       	call   f0101354 <page_alloc>
f0101435:	89 c7                	mov    %eax,%edi
f0101437:	83 c4 10             	add    $0x10,%esp
f010143a:	85 c0                	test   %eax,%eax
f010143c:	0f 84 c9 01 00 00    	je     f010160b <check_page_alloc+0x21e>
	assert((pp1 = page_alloc(0)));
f0101442:	83 ec 0c             	sub    $0xc,%esp
f0101445:	6a 00                	push   $0x0
f0101447:	e8 08 ff ff ff       	call   f0101354 <page_alloc>
f010144c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010144f:	83 c4 10             	add    $0x10,%esp
f0101452:	85 c0                	test   %eax,%eax
f0101454:	0f 84 ca 01 00 00    	je     f0101624 <check_page_alloc+0x237>
	assert((pp2 = page_alloc(0)));
f010145a:	83 ec 0c             	sub    $0xc,%esp
f010145d:	6a 00                	push   $0x0
f010145f:	e8 f0 fe ff ff       	call   f0101354 <page_alloc>
f0101464:	89 c3                	mov    %eax,%ebx
f0101466:	83 c4 10             	add    $0x10,%esp
f0101469:	85 c0                	test   %eax,%eax
f010146b:	0f 84 cc 01 00 00    	je     f010163d <check_page_alloc+0x250>
	assert(pp1 && pp1 != pp0);
f0101471:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
f0101474:	0f 84 dc 01 00 00    	je     f0101656 <check_page_alloc+0x269>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010147a:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
f010147d:	0f 84 ec 01 00 00    	je     f010166f <check_page_alloc+0x282>
f0101483:	39 c7                	cmp    %eax,%edi
f0101485:	0f 84 e4 01 00 00    	je     f010166f <check_page_alloc+0x282>
	assert(page2pa(pp0) < npages * PGSIZE);
f010148b:	89 f8                	mov    %edi,%eax
f010148d:	e8 cb f6 ff ff       	call   f0100b5d <page2pa>
f0101492:	8b 0d 60 82 24 f0    	mov    0xf0248260,%ecx
f0101498:	c1 e1 0c             	shl    $0xc,%ecx
f010149b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010149e:	39 c8                	cmp    %ecx,%eax
f01014a0:	0f 83 e2 01 00 00    	jae    f0101688 <check_page_alloc+0x29b>
	assert(page2pa(pp1) < npages * PGSIZE);
f01014a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01014a9:	e8 af f6 ff ff       	call   f0100b5d <page2pa>
f01014ae:	39 45 e0             	cmp    %eax,-0x20(%ebp)
f01014b1:	0f 86 ea 01 00 00    	jbe    f01016a1 <check_page_alloc+0x2b4>
	assert(page2pa(pp2) < npages * PGSIZE);
f01014b7:	89 d8                	mov    %ebx,%eax
f01014b9:	e8 9f f6 ff ff       	call   f0100b5d <page2pa>
f01014be:	39 45 e0             	cmp    %eax,-0x20(%ebp)
f01014c1:	0f 86 f3 01 00 00    	jbe    f01016ba <check_page_alloc+0x2cd>
	fl = page_free_list;
f01014c7:	a1 6c 82 24 f0       	mov    0xf024826c,%eax
f01014cc:	89 45 e0             	mov    %eax,-0x20(%ebp)
	page_free_list = 0;
f01014cf:	c7 05 6c 82 24 f0 00 	movl   $0x0,0xf024826c
f01014d6:	00 00 00 
	assert(!page_alloc(0));
f01014d9:	83 ec 0c             	sub    $0xc,%esp
f01014dc:	6a 00                	push   $0x0
f01014de:	e8 71 fe ff ff       	call   f0101354 <page_alloc>
f01014e3:	83 c4 10             	add    $0x10,%esp
f01014e6:	85 c0                	test   %eax,%eax
f01014e8:	0f 85 e5 01 00 00    	jne    f01016d3 <check_page_alloc+0x2e6>
	page_free(pp0);
f01014ee:	83 ec 0c             	sub    $0xc,%esp
f01014f1:	57                   	push   %edi
f01014f2:	e8 a4 fe ff ff       	call   f010139b <page_free>
	page_free(pp1);
f01014f7:	83 c4 04             	add    $0x4,%esp
f01014fa:	ff 75 e4             	push   -0x1c(%ebp)
f01014fd:	e8 99 fe ff ff       	call   f010139b <page_free>
	page_free(pp2);
f0101502:	89 1c 24             	mov    %ebx,(%esp)
f0101505:	e8 91 fe ff ff       	call   f010139b <page_free>
	assert((pp0 = page_alloc(0)));
f010150a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101511:	e8 3e fe ff ff       	call   f0101354 <page_alloc>
f0101516:	89 c3                	mov    %eax,%ebx
f0101518:	83 c4 10             	add    $0x10,%esp
f010151b:	85 c0                	test   %eax,%eax
f010151d:	0f 84 c9 01 00 00    	je     f01016ec <check_page_alloc+0x2ff>
	assert((pp1 = page_alloc(0)));
f0101523:	83 ec 0c             	sub    $0xc,%esp
f0101526:	6a 00                	push   $0x0
f0101528:	e8 27 fe ff ff       	call   f0101354 <page_alloc>
f010152d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101530:	83 c4 10             	add    $0x10,%esp
f0101533:	85 c0                	test   %eax,%eax
f0101535:	0f 84 ca 01 00 00    	je     f0101705 <check_page_alloc+0x318>
	assert((pp2 = page_alloc(0)));
f010153b:	83 ec 0c             	sub    $0xc,%esp
f010153e:	6a 00                	push   $0x0
f0101540:	e8 0f fe ff ff       	call   f0101354 <page_alloc>
f0101545:	89 c7                	mov    %eax,%edi
f0101547:	83 c4 10             	add    $0x10,%esp
f010154a:	85 c0                	test   %eax,%eax
f010154c:	0f 84 cc 01 00 00    	je     f010171e <check_page_alloc+0x331>
	assert(pp1 && pp1 != pp0);
f0101552:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0101555:	0f 84 dc 01 00 00    	je     f0101737 <check_page_alloc+0x34a>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010155b:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
f010155e:	0f 84 ec 01 00 00    	je     f0101750 <check_page_alloc+0x363>
f0101564:	39 c3                	cmp    %eax,%ebx
f0101566:	0f 84 e4 01 00 00    	je     f0101750 <check_page_alloc+0x363>
	assert(!page_alloc(0));
f010156c:	83 ec 0c             	sub    $0xc,%esp
f010156f:	6a 00                	push   $0x0
f0101571:	e8 de fd ff ff       	call   f0101354 <page_alloc>
f0101576:	83 c4 10             	add    $0x10,%esp
f0101579:	85 c0                	test   %eax,%eax
f010157b:	0f 85 e8 01 00 00    	jne    f0101769 <check_page_alloc+0x37c>
	memset(page2kva(pp0), 1, PGSIZE);
f0101581:	89 d8                	mov    %ebx,%eax
f0101583:	e8 9b f6 ff ff       	call   f0100c23 <page2kva>
f0101588:	83 ec 04             	sub    $0x4,%esp
f010158b:	68 00 10 00 00       	push   $0x1000
f0101590:	6a 01                	push   $0x1
f0101592:	50                   	push   %eax
f0101593:	e8 5a 43 00 00       	call   f01058f2 <memset>
	page_free(pp0);
f0101598:	89 1c 24             	mov    %ebx,(%esp)
f010159b:	e8 fb fd ff ff       	call   f010139b <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01015a0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01015a7:	e8 a8 fd ff ff       	call   f0101354 <page_alloc>
f01015ac:	83 c4 10             	add    $0x10,%esp
f01015af:	85 c0                	test   %eax,%eax
f01015b1:	0f 84 cb 01 00 00    	je     f0101782 <check_page_alloc+0x395>
	assert(pp && pp0 == pp);
f01015b7:	39 c3                	cmp    %eax,%ebx
f01015b9:	0f 85 dc 01 00 00    	jne    f010179b <check_page_alloc+0x3ae>
	c = page2kva(pp);
f01015bf:	e8 5f f6 ff ff       	call   f0100c23 <page2kva>
f01015c4:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
		assert(c[i] == 0);
f01015ca:	80 38 00             	cmpb   $0x0,(%eax)
f01015cd:	0f 85 e1 01 00 00    	jne    f01017b4 <check_page_alloc+0x3c7>
	for (i = 0; i < PGSIZE; i++)
f01015d3:	83 c0 01             	add    $0x1,%eax
f01015d6:	39 d0                	cmp    %edx,%eax
f01015d8:	75 f0                	jne    f01015ca <check_page_alloc+0x1dd>
	page_free_list = fl;
f01015da:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01015dd:	a3 6c 82 24 f0       	mov    %eax,0xf024826c
	page_free(pp0);
f01015e2:	83 ec 0c             	sub    $0xc,%esp
f01015e5:	53                   	push   %ebx
f01015e6:	e8 b0 fd ff ff       	call   f010139b <page_free>
	page_free(pp1);
f01015eb:	83 c4 04             	add    $0x4,%esp
f01015ee:	ff 75 e4             	push   -0x1c(%ebp)
f01015f1:	e8 a5 fd ff ff       	call   f010139b <page_free>
	page_free(pp2);
f01015f6:	89 3c 24             	mov    %edi,(%esp)
f01015f9:	e8 9d fd ff ff       	call   f010139b <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01015fe:	a1 6c 82 24 f0       	mov    0xf024826c,%eax
f0101603:	83 c4 10             	add    $0x10,%esp
f0101606:	e9 c7 01 00 00       	jmp    f01017d2 <check_page_alloc+0x3e5>
	assert((pp0 = page_alloc(0)));
f010160b:	68 2d 76 10 f0       	push   $0xf010762d
f0101610:	68 0b 75 10 f0       	push   $0xf010750b
f0101615:	68 08 03 00 00       	push   $0x308
f010161a:	68 ff 74 10 f0       	push   $0xf01074ff
f010161f:	e8 46 ea ff ff       	call   f010006a <_panic>
	assert((pp1 = page_alloc(0)));
f0101624:	68 43 76 10 f0       	push   $0xf0107643
f0101629:	68 0b 75 10 f0       	push   $0xf010750b
f010162e:	68 09 03 00 00       	push   $0x309
f0101633:	68 ff 74 10 f0       	push   $0xf01074ff
f0101638:	e8 2d ea ff ff       	call   f010006a <_panic>
	assert((pp2 = page_alloc(0)));
f010163d:	68 59 76 10 f0       	push   $0xf0107659
f0101642:	68 0b 75 10 f0       	push   $0xf010750b
f0101647:	68 0a 03 00 00       	push   $0x30a
f010164c:	68 ff 74 10 f0       	push   $0xf01074ff
f0101651:	e8 14 ea ff ff       	call   f010006a <_panic>
	assert(pp1 && pp1 != pp0);
f0101656:	68 6f 76 10 f0       	push   $0xf010766f
f010165b:	68 0b 75 10 f0       	push   $0xf010750b
f0101660:	68 0d 03 00 00       	push   $0x30d
f0101665:	68 ff 74 10 f0       	push   $0xf01074ff
f010166a:	e8 fb e9 ff ff       	call   f010006a <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010166f:	68 9c 6d 10 f0       	push   $0xf0106d9c
f0101674:	68 0b 75 10 f0       	push   $0xf010750b
f0101679:	68 0e 03 00 00       	push   $0x30e
f010167e:	68 ff 74 10 f0       	push   $0xf01074ff
f0101683:	e8 e2 e9 ff ff       	call   f010006a <_panic>
	assert(page2pa(pp0) < npages * PGSIZE);
f0101688:	68 bc 6d 10 f0       	push   $0xf0106dbc
f010168d:	68 0b 75 10 f0       	push   $0xf010750b
f0101692:	68 0f 03 00 00       	push   $0x30f
f0101697:	68 ff 74 10 f0       	push   $0xf01074ff
f010169c:	e8 c9 e9 ff ff       	call   f010006a <_panic>
	assert(page2pa(pp1) < npages * PGSIZE);
f01016a1:	68 dc 6d 10 f0       	push   $0xf0106ddc
f01016a6:	68 0b 75 10 f0       	push   $0xf010750b
f01016ab:	68 10 03 00 00       	push   $0x310
f01016b0:	68 ff 74 10 f0       	push   $0xf01074ff
f01016b5:	e8 b0 e9 ff ff       	call   f010006a <_panic>
	assert(page2pa(pp2) < npages * PGSIZE);
f01016ba:	68 fc 6d 10 f0       	push   $0xf0106dfc
f01016bf:	68 0b 75 10 f0       	push   $0xf010750b
f01016c4:	68 11 03 00 00       	push   $0x311
f01016c9:	68 ff 74 10 f0       	push   $0xf01074ff
f01016ce:	e8 97 e9 ff ff       	call   f010006a <_panic>
	assert(!page_alloc(0));
f01016d3:	68 81 76 10 f0       	push   $0xf0107681
f01016d8:	68 0b 75 10 f0       	push   $0xf010750b
f01016dd:	68 18 03 00 00       	push   $0x318
f01016e2:	68 ff 74 10 f0       	push   $0xf01074ff
f01016e7:	e8 7e e9 ff ff       	call   f010006a <_panic>
	assert((pp0 = page_alloc(0)));
f01016ec:	68 2d 76 10 f0       	push   $0xf010762d
f01016f1:	68 0b 75 10 f0       	push   $0xf010750b
f01016f6:	68 1f 03 00 00       	push   $0x31f
f01016fb:	68 ff 74 10 f0       	push   $0xf01074ff
f0101700:	e8 65 e9 ff ff       	call   f010006a <_panic>
	assert((pp1 = page_alloc(0)));
f0101705:	68 43 76 10 f0       	push   $0xf0107643
f010170a:	68 0b 75 10 f0       	push   $0xf010750b
f010170f:	68 20 03 00 00       	push   $0x320
f0101714:	68 ff 74 10 f0       	push   $0xf01074ff
f0101719:	e8 4c e9 ff ff       	call   f010006a <_panic>
	assert((pp2 = page_alloc(0)));
f010171e:	68 59 76 10 f0       	push   $0xf0107659
f0101723:	68 0b 75 10 f0       	push   $0xf010750b
f0101728:	68 21 03 00 00       	push   $0x321
f010172d:	68 ff 74 10 f0       	push   $0xf01074ff
f0101732:	e8 33 e9 ff ff       	call   f010006a <_panic>
	assert(pp1 && pp1 != pp0);
f0101737:	68 6f 76 10 f0       	push   $0xf010766f
f010173c:	68 0b 75 10 f0       	push   $0xf010750b
f0101741:	68 23 03 00 00       	push   $0x323
f0101746:	68 ff 74 10 f0       	push   $0xf01074ff
f010174b:	e8 1a e9 ff ff       	call   f010006a <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101750:	68 9c 6d 10 f0       	push   $0xf0106d9c
f0101755:	68 0b 75 10 f0       	push   $0xf010750b
f010175a:	68 24 03 00 00       	push   $0x324
f010175f:	68 ff 74 10 f0       	push   $0xf01074ff
f0101764:	e8 01 e9 ff ff       	call   f010006a <_panic>
	assert(!page_alloc(0));
f0101769:	68 81 76 10 f0       	push   $0xf0107681
f010176e:	68 0b 75 10 f0       	push   $0xf010750b
f0101773:	68 25 03 00 00       	push   $0x325
f0101778:	68 ff 74 10 f0       	push   $0xf01074ff
f010177d:	e8 e8 e8 ff ff       	call   f010006a <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101782:	68 90 76 10 f0       	push   $0xf0107690
f0101787:	68 0b 75 10 f0       	push   $0xf010750b
f010178c:	68 2a 03 00 00       	push   $0x32a
f0101791:	68 ff 74 10 f0       	push   $0xf01074ff
f0101796:	e8 cf e8 ff ff       	call   f010006a <_panic>
	assert(pp && pp0 == pp);
f010179b:	68 ae 76 10 f0       	push   $0xf01076ae
f01017a0:	68 0b 75 10 f0       	push   $0xf010750b
f01017a5:	68 2b 03 00 00       	push   $0x32b
f01017aa:	68 ff 74 10 f0       	push   $0xf01074ff
f01017af:	e8 b6 e8 ff ff       	call   f010006a <_panic>
		assert(c[i] == 0);
f01017b4:	68 be 76 10 f0       	push   $0xf01076be
f01017b9:	68 0b 75 10 f0       	push   $0xf010750b
f01017be:	68 2e 03 00 00       	push   $0x32e
f01017c3:	68 ff 74 10 f0       	push   $0xf01074ff
f01017c8:	e8 9d e8 ff ff       	call   f010006a <_panic>
		--nfree;
f01017cd:	83 ee 01             	sub    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01017d0:	8b 00                	mov    (%eax),%eax
f01017d2:	85 c0                	test   %eax,%eax
f01017d4:	75 f7                	jne    f01017cd <check_page_alloc+0x3e0>
	assert(nfree == 0);
f01017d6:	85 f6                	test   %esi,%esi
f01017d8:	75 18                	jne    f01017f2 <check_page_alloc+0x405>
	cprintf("check_page_alloc() succeeded!\n");
f01017da:	83 ec 0c             	sub    $0xc,%esp
f01017dd:	68 1c 6e 10 f0       	push   $0xf0106e1c
f01017e2:	e8 d3 1f 00 00       	call   f01037ba <cprintf>
}
f01017e7:	83 c4 10             	add    $0x10,%esp
f01017ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01017ed:	5b                   	pop    %ebx
f01017ee:	5e                   	pop    %esi
f01017ef:	5f                   	pop    %edi
f01017f0:	5d                   	pop    %ebp
f01017f1:	c3                   	ret    
	assert(nfree == 0);
f01017f2:	68 c8 76 10 f0       	push   $0xf01076c8
f01017f7:	68 0b 75 10 f0       	push   $0xf010750b
f01017fc:	68 3b 03 00 00       	push   $0x33b
f0101801:	68 ff 74 10 f0       	push   $0xf01074ff
f0101806:	e8 5f e8 ff ff       	call   f010006a <_panic>

f010180b <page_decref>:
{
f010180b:	55                   	push   %ebp
f010180c:	89 e5                	mov    %esp,%ebp
f010180e:	83 ec 08             	sub    $0x8,%esp
f0101811:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0101814:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0101818:	83 e8 01             	sub    $0x1,%eax
f010181b:	66 89 42 04          	mov    %ax,0x4(%edx)
f010181f:	66 85 c0             	test   %ax,%ax
f0101822:	74 02                	je     f0101826 <page_decref+0x1b>
}
f0101824:	c9                   	leave  
f0101825:	c3                   	ret    
		page_free(pp);
f0101826:	83 ec 0c             	sub    $0xc,%esp
f0101829:	52                   	push   %edx
f010182a:	e8 6c fb ff ff       	call   f010139b <page_free>
f010182f:	83 c4 10             	add    $0x10,%esp
}
f0101832:	eb f0                	jmp    f0101824 <page_decref+0x19>

f0101834 <pgdir_walk>:
{
f0101834:	55                   	push   %ebp
f0101835:	89 e5                	mov    %esp,%ebp
f0101837:	56                   	push   %esi
f0101838:	53                   	push   %ebx
f0101839:	8b 75 0c             	mov    0xc(%ebp),%esi
	uintptr_t pdx = PDX(va);
f010183c:	89 f3                	mov    %esi,%ebx
f010183e:	c1 eb 16             	shr    $0x16,%ebx
	if (!pgdir[pdx] && create && (page = page_alloc(ALLOC_ZERO))) {
f0101841:	c1 e3 02             	shl    $0x2,%ebx
f0101844:	03 5d 08             	add    0x8(%ebp),%ebx
f0101847:	83 3b 00             	cmpl   $0x0,(%ebx)
f010184a:	75 06                	jne    f0101852 <pgdir_walk+0x1e>
f010184c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101850:	75 12                	jne    f0101864 <pgdir_walk+0x30>
	if (pgdir[pdx]) {
f0101852:	8b 0b                	mov    (%ebx),%ecx
	return NULL;
f0101854:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pgdir[pdx]) {
f0101859:	85 c9                	test   %ecx,%ecx
f010185b:	75 29                	jne    f0101886 <pgdir_walk+0x52>
}
f010185d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101860:	5b                   	pop    %ebx
f0101861:	5e                   	pop    %esi
f0101862:	5d                   	pop    %ebp
f0101863:	c3                   	ret    
	if (!pgdir[pdx] && create && (page = page_alloc(ALLOC_ZERO))) {
f0101864:	83 ec 0c             	sub    $0xc,%esp
f0101867:	6a 01                	push   $0x1
f0101869:	e8 e6 fa ff ff       	call   f0101354 <page_alloc>
f010186e:	83 c4 10             	add    $0x10,%esp
f0101871:	85 c0                	test   %eax,%eax
f0101873:	74 dd                	je     f0101852 <pgdir_walk+0x1e>
		page->pp_ref++;
f0101875:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
		pgdir[pdx] = page2pa(page) | PTE_P | PTE_W | PTE_U;
f010187a:	e8 de f2 ff ff       	call   f0100b5d <page2pa>
f010187f:	83 c8 07             	or     $0x7,%eax
f0101882:	89 c1                	mov    %eax,%ecx
f0101884:	89 03                	mov    %eax,(%ebx)
		pte_t *pte = (pte_t *) KADDR(PTE_ADDR(pgdir[pdx]));
f0101886:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f010188c:	ba a8 01 00 00       	mov    $0x1a8,%edx
f0101891:	b8 ff 74 10 f0       	mov    $0xf01074ff,%eax
f0101896:	e8 5c f3 ff ff       	call   f0100bf7 <_kaddr>
		return pte + PTX(va);
f010189b:	c1 ee 0a             	shr    $0xa,%esi
f010189e:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f01018a4:	01 f0                	add    %esi,%eax
f01018a6:	eb b5                	jmp    f010185d <pgdir_walk+0x29>

f01018a8 <page_lookup>:
{
f01018a8:	55                   	push   %ebp
f01018a9:	89 e5                	mov    %esp,%ebp
f01018ab:	53                   	push   %ebx
f01018ac:	83 ec 08             	sub    $0x8,%esp
f01018af:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t *pte = pgdir_walk(pgdir, va, 0);
f01018b2:	6a 00                	push   $0x0
f01018b4:	ff 75 0c             	push   0xc(%ebp)
f01018b7:	ff 75 08             	push   0x8(%ebp)
f01018ba:	e8 75 ff ff ff       	call   f0101834 <pgdir_walk>
	if (!pte || !(*pte && PTE_P))
f01018bf:	83 c4 10             	add    $0x10,%esp
f01018c2:	85 c0                	test   %eax,%eax
f01018c4:	74 17                	je     f01018dd <page_lookup+0x35>
f01018c6:	83 38 00             	cmpl   $0x0,(%eax)
f01018c9:	74 17                	je     f01018e2 <page_lookup+0x3a>
	if (pte_store) {
f01018cb:	85 db                	test   %ebx,%ebx
f01018cd:	74 02                	je     f01018d1 <page_lookup+0x29>
		*pte_store = pte;
f01018cf:	89 03                	mov    %eax,(%ebx)
	uint32_t pte_ptr = PTE_ADDR(*pte);
f01018d1:	8b 00                	mov    (%eax),%eax
f01018d3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	return pa2page(pte_ptr);
f01018d8:	e8 bd f9 ff ff       	call   f010129a <pa2page>
}
f01018dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01018e0:	c9                   	leave  
f01018e1:	c3                   	ret    
		return NULL;
f01018e2:	b8 00 00 00 00       	mov    $0x0,%eax
f01018e7:	eb f4                	jmp    f01018dd <page_lookup+0x35>

f01018e9 <tlb_invalidate>:
{
f01018e9:	55                   	push   %ebp
f01018ea:	89 e5                	mov    %esp,%ebp
f01018ec:	83 ec 08             	sub    $0x8,%esp
	if (!curenv || curenv->env_pgdir == pgdir)
f01018ef:	e8 74 46 00 00       	call   f0105f68 <cpunum>
f01018f4:	6b c0 74             	imul   $0x74,%eax,%eax
f01018f7:	83 b8 28 a0 28 f0 00 	cmpl   $0x0,-0xfd75fd8(%eax)
f01018fe:	74 16                	je     f0101916 <tlb_invalidate+0x2d>
f0101900:	e8 63 46 00 00       	call   f0105f68 <cpunum>
f0101905:	6b c0 74             	imul   $0x74,%eax,%eax
f0101908:	8b 80 28 a0 28 f0    	mov    -0xfd75fd8(%eax),%eax
f010190e:	8b 55 08             	mov    0x8(%ebp),%edx
f0101911:	39 50 6c             	cmp    %edx,0x6c(%eax)
f0101914:	75 08                	jne    f010191e <tlb_invalidate+0x35>
		invlpg(va);
f0101916:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101919:	e8 2f f2 ff ff       	call   f0100b4d <invlpg>
}
f010191e:	c9                   	leave  
f010191f:	c3                   	ret    

f0101920 <page_remove>:
{
f0101920:	55                   	push   %ebp
f0101921:	89 e5                	mov    %esp,%ebp
f0101923:	56                   	push   %esi
f0101924:	53                   	push   %ebx
f0101925:	83 ec 14             	sub    $0x14,%esp
f0101928:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010192b:	8b 75 0c             	mov    0xc(%ebp),%esi
	uint32_t *pte = pgdir_walk(pgdir, va, 0);
f010192e:	6a 00                	push   $0x0
f0101930:	56                   	push   %esi
f0101931:	53                   	push   %ebx
f0101932:	e8 fd fe ff ff       	call   f0101834 <pgdir_walk>
f0101937:	89 45 f4             	mov    %eax,-0xc(%ebp)
	struct PageInfo *page_rmv = page_lookup(pgdir, va, &pte);
f010193a:	83 c4 0c             	add    $0xc,%esp
f010193d:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101940:	50                   	push   %eax
f0101941:	56                   	push   %esi
f0101942:	53                   	push   %ebx
f0101943:	e8 60 ff ff ff       	call   f01018a8 <page_lookup>
	if (!pte || !(*pte && PTE_P))
f0101948:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010194b:	83 c4 10             	add    $0x10,%esp
f010194e:	85 d2                	test   %edx,%edx
f0101950:	74 05                	je     f0101957 <page_remove+0x37>
f0101952:	83 3a 00             	cmpl   $0x0,(%edx)
f0101955:	75 07                	jne    f010195e <page_remove+0x3e>
}
f0101957:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010195a:	5b                   	pop    %ebx
f010195b:	5e                   	pop    %esi
f010195c:	5d                   	pop    %ebp
f010195d:	c3                   	ret    
	page_decref(page_rmv);
f010195e:	83 ec 0c             	sub    $0xc,%esp
f0101961:	50                   	push   %eax
f0101962:	e8 a4 fe ff ff       	call   f010180b <page_decref>
	*pte = 0;
f0101967:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010196a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	tlb_invalidate(pgdir, va);
f0101970:	83 c4 08             	add    $0x8,%esp
f0101973:	56                   	push   %esi
f0101974:	53                   	push   %ebx
f0101975:	e8 6f ff ff ff       	call   f01018e9 <tlb_invalidate>
f010197a:	83 c4 10             	add    $0x10,%esp
f010197d:	eb d8                	jmp    f0101957 <page_remove+0x37>

f010197f <boot_map_region>:
{
f010197f:	55                   	push   %ebp
f0101980:	89 e5                	mov    %esp,%ebp
f0101982:	57                   	push   %edi
f0101983:	56                   	push   %esi
f0101984:	53                   	push   %ebx
f0101985:	83 ec 1c             	sub    $0x1c,%esp
f0101988:	89 c6                	mov    %eax,%esi
f010198a:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010198d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
	for (size_t i = 0; i < size; i += PGSIZE) {
f0101990:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101995:	eb 38                	jmp    f01019cf <boot_map_region+0x50>
f0101997:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010199a:	8d 3c 03             	lea    (%ebx,%eax,1),%edi
		pte_t *pte = pgdir_walk(pgdir, (void *) (va + i), 1);
f010199d:	83 ec 04             	sub    $0x4,%esp
f01019a0:	6a 01                	push   $0x1
f01019a2:	57                   	push   %edi
f01019a3:	56                   	push   %esi
f01019a4:	e8 8b fe ff ff       	call   f0101834 <pgdir_walk>
f01019a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		page_remove(pgdir, (void *) (va + i));
f01019ac:	83 c4 08             	add    $0x8,%esp
f01019af:	57                   	push   %edi
f01019b0:	56                   	push   %esi
f01019b1:	e8 6a ff ff ff       	call   f0101920 <page_remove>
		*pte = (pa + i) | perm | PTE_P;
f01019b6:	89 d8                	mov    %ebx,%eax
f01019b8:	03 45 08             	add    0x8(%ebp),%eax
f01019bb:	0b 45 0c             	or     0xc(%ebp),%eax
f01019be:	83 c8 01             	or     $0x1,%eax
f01019c1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01019c4:	89 02                	mov    %eax,(%edx)
	for (size_t i = 0; i < size; i += PGSIZE) {
f01019c6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01019cc:	83 c4 10             	add    $0x10,%esp
f01019cf:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
f01019d2:	72 c3                	jb     f0101997 <boot_map_region+0x18>
}
f01019d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01019d7:	5b                   	pop    %ebx
f01019d8:	5e                   	pop    %esi
f01019d9:	5f                   	pop    %edi
f01019da:	5d                   	pop    %ebp
f01019db:	c3                   	ret    

f01019dc <mem_init_mp>:
{
f01019dc:	55                   	push   %ebp
f01019dd:	89 e5                	mov    %esp,%ebp
f01019df:	57                   	push   %edi
f01019e0:	56                   	push   %esi
f01019e1:	53                   	push   %ebx
f01019e2:	83 ec 0c             	sub    $0xc,%esp
f01019e5:	bb 00 a0 24 f0       	mov    $0xf024a000,%ebx
f01019ea:	bf 00 a0 28 f0       	mov    $0xf028a000,%edi
f01019ef:	be 00 80 ff ef       	mov    $0xefff8000,%esi
		boot_map_region(kern_pgdir,
f01019f4:	89 d9                	mov    %ebx,%ecx
f01019f6:	ba 12 01 00 00       	mov    $0x112,%edx
f01019fb:	b8 ff 74 10 f0       	mov    $0xf01074ff,%eax
f0101a00:	e8 a4 f2 ff ff       	call   f0100ca9 <_paddr>
f0101a05:	83 ec 08             	sub    $0x8,%esp
f0101a08:	6a 03                	push   $0x3
f0101a0a:	50                   	push   %eax
f0101a0b:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0101a10:	89 f2                	mov    %esi,%edx
f0101a12:	a1 5c 82 24 f0       	mov    0xf024825c,%eax
f0101a17:	e8 63 ff ff ff       	call   f010197f <boot_map_region>
	for (int i = 0; i < NCPU; i++) {
f0101a1c:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0101a22:	81 ee 00 00 01 00    	sub    $0x10000,%esi
f0101a28:	83 c4 10             	add    $0x10,%esp
f0101a2b:	39 fb                	cmp    %edi,%ebx
f0101a2d:	75 c5                	jne    f01019f4 <mem_init_mp+0x18>
}
f0101a2f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101a32:	5b                   	pop    %ebx
f0101a33:	5e                   	pop    %esi
f0101a34:	5f                   	pop    %edi
f0101a35:	5d                   	pop    %ebp
f0101a36:	c3                   	ret    

f0101a37 <page_insert>:
{
f0101a37:	55                   	push   %ebp
f0101a38:	89 e5                	mov    %esp,%ebp
f0101a3a:	57                   	push   %edi
f0101a3b:	56                   	push   %esi
f0101a3c:	53                   	push   %ebx
f0101a3d:	83 ec 10             	sub    $0x10,%esp
f0101a40:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101a43:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t *page_table = pgdir_walk(pgdir, va, 1);
f0101a46:	6a 01                	push   $0x1
f0101a48:	57                   	push   %edi
f0101a49:	ff 75 08             	push   0x8(%ebp)
f0101a4c:	e8 e3 fd ff ff       	call   f0101834 <pgdir_walk>
	if (!page_table)
f0101a51:	83 c4 10             	add    $0x10,%esp
f0101a54:	85 c0                	test   %eax,%eax
f0101a56:	74 32                	je     f0101a8a <page_insert+0x53>
f0101a58:	89 c3                	mov    %eax,%ebx
	pp->pp_ref++;
f0101a5a:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
	page_remove(pgdir, va);
f0101a5f:	83 ec 08             	sub    $0x8,%esp
f0101a62:	57                   	push   %edi
f0101a63:	ff 75 08             	push   0x8(%ebp)
f0101a66:	e8 b5 fe ff ff       	call   f0101920 <page_remove>
	uint32_t new_pte = page2pa(pp) | perm | PTE_P;
f0101a6b:	89 f0                	mov    %esi,%eax
f0101a6d:	e8 eb f0 ff ff       	call   f0100b5d <page2pa>
f0101a72:	0b 45 14             	or     0x14(%ebp),%eax
f0101a75:	83 c8 01             	or     $0x1,%eax
f0101a78:	89 03                	mov    %eax,(%ebx)
	return 0;
f0101a7a:	83 c4 10             	add    $0x10,%esp
f0101a7d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101a82:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101a85:	5b                   	pop    %ebx
f0101a86:	5e                   	pop    %esi
f0101a87:	5f                   	pop    %edi
f0101a88:	5d                   	pop    %ebp
f0101a89:	c3                   	ret    
		return -E_NO_MEM;
f0101a8a:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0101a8f:	eb f1                	jmp    f0101a82 <page_insert+0x4b>

f0101a91 <check_page_installed_pgdir>:
}

// check page_insert, page_remove, &c, with an installed kern_pgdir
static void
check_page_installed_pgdir(void)
{
f0101a91:	55                   	push   %ebp
f0101a92:	89 e5                	mov    %esp,%ebp
f0101a94:	57                   	push   %edi
f0101a95:	56                   	push   %esi
f0101a96:	53                   	push   %ebx
f0101a97:	83 ec 18             	sub    $0x18,%esp
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101a9a:	6a 00                	push   $0x0
f0101a9c:	e8 b3 f8 ff ff       	call   f0101354 <page_alloc>
f0101aa1:	83 c4 10             	add    $0x10,%esp
f0101aa4:	85 c0                	test   %eax,%eax
f0101aa6:	0f 84 67 01 00 00    	je     f0101c13 <check_page_installed_pgdir+0x182>
f0101aac:	89 c6                	mov    %eax,%esi
	assert((pp1 = page_alloc(0)));
f0101aae:	83 ec 0c             	sub    $0xc,%esp
f0101ab1:	6a 00                	push   $0x0
f0101ab3:	e8 9c f8 ff ff       	call   f0101354 <page_alloc>
f0101ab8:	89 c7                	mov    %eax,%edi
f0101aba:	83 c4 10             	add    $0x10,%esp
f0101abd:	85 c0                	test   %eax,%eax
f0101abf:	0f 84 67 01 00 00    	je     f0101c2c <check_page_installed_pgdir+0x19b>
	assert((pp2 = page_alloc(0)));
f0101ac5:	83 ec 0c             	sub    $0xc,%esp
f0101ac8:	6a 00                	push   $0x0
f0101aca:	e8 85 f8 ff ff       	call   f0101354 <page_alloc>
f0101acf:	89 c3                	mov    %eax,%ebx
f0101ad1:	83 c4 10             	add    $0x10,%esp
f0101ad4:	85 c0                	test   %eax,%eax
f0101ad6:	0f 84 69 01 00 00    	je     f0101c45 <check_page_installed_pgdir+0x1b4>
	page_free(pp0);
f0101adc:	83 ec 0c             	sub    $0xc,%esp
f0101adf:	56                   	push   %esi
f0101ae0:	e8 b6 f8 ff ff       	call   f010139b <page_free>
	memset(page2kva(pp1), 1, PGSIZE);
f0101ae5:	89 f8                	mov    %edi,%eax
f0101ae7:	e8 37 f1 ff ff       	call   f0100c23 <page2kva>
f0101aec:	83 c4 0c             	add    $0xc,%esp
f0101aef:	68 00 10 00 00       	push   $0x1000
f0101af4:	6a 01                	push   $0x1
f0101af6:	50                   	push   %eax
f0101af7:	e8 f6 3d 00 00       	call   f01058f2 <memset>
	memset(page2kva(pp2), 2, PGSIZE);
f0101afc:	89 d8                	mov    %ebx,%eax
f0101afe:	e8 20 f1 ff ff       	call   f0100c23 <page2kva>
f0101b03:	83 c4 0c             	add    $0xc,%esp
f0101b06:	68 00 10 00 00       	push   $0x1000
f0101b0b:	6a 02                	push   $0x2
f0101b0d:	50                   	push   %eax
f0101b0e:	e8 df 3d 00 00       	call   f01058f2 <memset>
	page_insert(kern_pgdir, pp1, (void *) PGSIZE, PTE_W);
f0101b13:	6a 02                	push   $0x2
f0101b15:	68 00 10 00 00       	push   $0x1000
f0101b1a:	57                   	push   %edi
f0101b1b:	ff 35 5c 82 24 f0    	push   0xf024825c
f0101b21:	e8 11 ff ff ff       	call   f0101a37 <page_insert>
	assert(pp1->pp_ref == 1);
f0101b26:	83 c4 20             	add    $0x20,%esp
f0101b29:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101b2e:	0f 85 2a 01 00 00    	jne    f0101c5e <check_page_installed_pgdir+0x1cd>
	assert(*(uint32_t *) PGSIZE == 0x01010101U);
f0101b34:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0101b3b:	01 01 01 
f0101b3e:	0f 85 33 01 00 00    	jne    f0101c77 <check_page_installed_pgdir+0x1e6>
	page_insert(kern_pgdir, pp2, (void *) PGSIZE, PTE_W);
f0101b44:	6a 02                	push   $0x2
f0101b46:	68 00 10 00 00       	push   $0x1000
f0101b4b:	53                   	push   %ebx
f0101b4c:	ff 35 5c 82 24 f0    	push   0xf024825c
f0101b52:	e8 e0 fe ff ff       	call   f0101a37 <page_insert>
	assert(*(uint32_t *) PGSIZE == 0x02020202U);
f0101b57:	83 c4 10             	add    $0x10,%esp
f0101b5a:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0101b61:	02 02 02 
f0101b64:	0f 85 26 01 00 00    	jne    f0101c90 <check_page_installed_pgdir+0x1ff>
	assert(pp2->pp_ref == 1);
f0101b6a:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101b6f:	0f 85 34 01 00 00    	jne    f0101ca9 <check_page_installed_pgdir+0x218>
	assert(pp1->pp_ref == 0);
f0101b75:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101b7a:	0f 85 42 01 00 00    	jne    f0101cc2 <check_page_installed_pgdir+0x231>
	*(uint32_t *) PGSIZE = 0x03030303U;
f0101b80:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0101b87:	03 03 03 
	assert(*(uint32_t *) page2kva(pp2) == 0x03030303U);
f0101b8a:	89 d8                	mov    %ebx,%eax
f0101b8c:	e8 92 f0 ff ff       	call   f0100c23 <page2kva>
f0101b91:	81 38 03 03 03 03    	cmpl   $0x3030303,(%eax)
f0101b97:	0f 85 3e 01 00 00    	jne    f0101cdb <check_page_installed_pgdir+0x24a>
	page_remove(kern_pgdir, (void *) PGSIZE);
f0101b9d:	83 ec 08             	sub    $0x8,%esp
f0101ba0:	68 00 10 00 00       	push   $0x1000
f0101ba5:	ff 35 5c 82 24 f0    	push   0xf024825c
f0101bab:	e8 70 fd ff ff       	call   f0101920 <page_remove>
	assert(pp2->pp_ref == 0);
f0101bb0:	83 c4 10             	add    $0x10,%esp
f0101bb3:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101bb8:	0f 85 36 01 00 00    	jne    f0101cf4 <check_page_installed_pgdir+0x263>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101bbe:	8b 1d 5c 82 24 f0    	mov    0xf024825c,%ebx
f0101bc4:	89 f0                	mov    %esi,%eax
f0101bc6:	e8 92 ef ff ff       	call   f0100b5d <page2pa>
f0101bcb:	89 c2                	mov    %eax,%edx
f0101bcd:	8b 03                	mov    (%ebx),%eax
f0101bcf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101bd4:	39 d0                	cmp    %edx,%eax
f0101bd6:	0f 85 31 01 00 00    	jne    f0101d0d <check_page_installed_pgdir+0x27c>
	kern_pgdir[0] = 0;
f0101bdc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	assert(pp0->pp_ref == 1);
f0101be2:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101be7:	0f 85 39 01 00 00    	jne    f0101d26 <check_page_installed_pgdir+0x295>
	pp0->pp_ref = 0;
f0101bed:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0101bf3:	83 ec 0c             	sub    $0xc,%esp
f0101bf6:	56                   	push   %esi
f0101bf7:	e8 9f f7 ff ff       	call   f010139b <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0101bfc:	c7 04 24 d8 6e 10 f0 	movl   $0xf0106ed8,(%esp)
f0101c03:	e8 b2 1b 00 00       	call   f01037ba <cprintf>
}
f0101c08:	83 c4 10             	add    $0x10,%esp
f0101c0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101c0e:	5b                   	pop    %ebx
f0101c0f:	5e                   	pop    %esi
f0101c10:	5f                   	pop    %edi
f0101c11:	5d                   	pop    %ebp
f0101c12:	c3                   	ret    
	assert((pp0 = page_alloc(0)));
f0101c13:	68 2d 76 10 f0       	push   $0xf010762d
f0101c18:	68 0b 75 10 f0       	push   $0xf010750b
f0101c1d:	68 5e 04 00 00       	push   $0x45e
f0101c22:	68 ff 74 10 f0       	push   $0xf01074ff
f0101c27:	e8 3e e4 ff ff       	call   f010006a <_panic>
	assert((pp1 = page_alloc(0)));
f0101c2c:	68 43 76 10 f0       	push   $0xf0107643
f0101c31:	68 0b 75 10 f0       	push   $0xf010750b
f0101c36:	68 5f 04 00 00       	push   $0x45f
f0101c3b:	68 ff 74 10 f0       	push   $0xf01074ff
f0101c40:	e8 25 e4 ff ff       	call   f010006a <_panic>
	assert((pp2 = page_alloc(0)));
f0101c45:	68 59 76 10 f0       	push   $0xf0107659
f0101c4a:	68 0b 75 10 f0       	push   $0xf010750b
f0101c4f:	68 60 04 00 00       	push   $0x460
f0101c54:	68 ff 74 10 f0       	push   $0xf01074ff
f0101c59:	e8 0c e4 ff ff       	call   f010006a <_panic>
	assert(pp1->pp_ref == 1);
f0101c5e:	68 d3 76 10 f0       	push   $0xf01076d3
f0101c63:	68 0b 75 10 f0       	push   $0xf010750b
f0101c68:	68 65 04 00 00       	push   $0x465
f0101c6d:	68 ff 74 10 f0       	push   $0xf01074ff
f0101c72:	e8 f3 e3 ff ff       	call   f010006a <_panic>
	assert(*(uint32_t *) PGSIZE == 0x01010101U);
f0101c77:	68 3c 6e 10 f0       	push   $0xf0106e3c
f0101c7c:	68 0b 75 10 f0       	push   $0xf010750b
f0101c81:	68 66 04 00 00       	push   $0x466
f0101c86:	68 ff 74 10 f0       	push   $0xf01074ff
f0101c8b:	e8 da e3 ff ff       	call   f010006a <_panic>
	assert(*(uint32_t *) PGSIZE == 0x02020202U);
f0101c90:	68 60 6e 10 f0       	push   $0xf0106e60
f0101c95:	68 0b 75 10 f0       	push   $0xf010750b
f0101c9a:	68 68 04 00 00       	push   $0x468
f0101c9f:	68 ff 74 10 f0       	push   $0xf01074ff
f0101ca4:	e8 c1 e3 ff ff       	call   f010006a <_panic>
	assert(pp2->pp_ref == 1);
f0101ca9:	68 e4 76 10 f0       	push   $0xf01076e4
f0101cae:	68 0b 75 10 f0       	push   $0xf010750b
f0101cb3:	68 69 04 00 00       	push   $0x469
f0101cb8:	68 ff 74 10 f0       	push   $0xf01074ff
f0101cbd:	e8 a8 e3 ff ff       	call   f010006a <_panic>
	assert(pp1->pp_ref == 0);
f0101cc2:	68 f5 76 10 f0       	push   $0xf01076f5
f0101cc7:	68 0b 75 10 f0       	push   $0xf010750b
f0101ccc:	68 6a 04 00 00       	push   $0x46a
f0101cd1:	68 ff 74 10 f0       	push   $0xf01074ff
f0101cd6:	e8 8f e3 ff ff       	call   f010006a <_panic>
	assert(*(uint32_t *) page2kva(pp2) == 0x03030303U);
f0101cdb:	68 84 6e 10 f0       	push   $0xf0106e84
f0101ce0:	68 0b 75 10 f0       	push   $0xf010750b
f0101ce5:	68 6c 04 00 00       	push   $0x46c
f0101cea:	68 ff 74 10 f0       	push   $0xf01074ff
f0101cef:	e8 76 e3 ff ff       	call   f010006a <_panic>
	assert(pp2->pp_ref == 0);
f0101cf4:	68 06 77 10 f0       	push   $0xf0107706
f0101cf9:	68 0b 75 10 f0       	push   $0xf010750b
f0101cfe:	68 6e 04 00 00       	push   $0x46e
f0101d03:	68 ff 74 10 f0       	push   $0xf01074ff
f0101d08:	e8 5d e3 ff ff       	call   f010006a <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101d0d:	68 b0 6e 10 f0       	push   $0xf0106eb0
f0101d12:	68 0b 75 10 f0       	push   $0xf010750b
f0101d17:	68 71 04 00 00       	push   $0x471
f0101d1c:	68 ff 74 10 f0       	push   $0xf01074ff
f0101d21:	e8 44 e3 ff ff       	call   f010006a <_panic>
	assert(pp0->pp_ref == 1);
f0101d26:	68 17 77 10 f0       	push   $0xf0107717
f0101d2b:	68 0b 75 10 f0       	push   $0xf010750b
f0101d30:	68 73 04 00 00       	push   $0x473
f0101d35:	68 ff 74 10 f0       	push   $0xf01074ff
f0101d3a:	e8 2b e3 ff ff       	call   f010006a <_panic>

f0101d3f <mmio_map_region>:
{
f0101d3f:	55                   	push   %ebp
f0101d40:	89 e5                	mov    %esp,%ebp
f0101d42:	53                   	push   %ebx
f0101d43:	83 ec 04             	sub    $0x4,%esp
	pa = ROUNDDOWN(pa, PGSIZE);
f0101d46:	8b 45 08             	mov    0x8(%ebp),%eax
f0101d49:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	size = ROUNDUP(size, PGSIZE);
f0101d4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101d51:	8d 99 ff 0f 00 00    	lea    0xfff(%ecx),%ebx
f0101d57:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if (base + size >= MMIOLIM)
f0101d5d:	8b 15 00 53 12 f0    	mov    0xf0125300,%edx
f0101d63:	8d 0c 1a             	lea    (%edx,%ebx,1),%ecx
f0101d66:	81 f9 ff ff bf ef    	cmp    $0xefbfffff,%ecx
f0101d6c:	77 24                	ja     f0101d92 <mmio_map_region+0x53>
	boot_map_region(kern_pgdir, base, size, pa, perm);
f0101d6e:	83 ec 08             	sub    $0x8,%esp
f0101d71:	6a 1b                	push   $0x1b
f0101d73:	50                   	push   %eax
f0101d74:	89 d9                	mov    %ebx,%ecx
f0101d76:	a1 5c 82 24 f0       	mov    0xf024825c,%eax
f0101d7b:	e8 ff fb ff ff       	call   f010197f <boot_map_region>
	base += size;
f0101d80:	a1 00 53 12 f0       	mov    0xf0125300,%eax
f0101d85:	01 c3                	add    %eax,%ebx
f0101d87:	89 1d 00 53 12 f0    	mov    %ebx,0xf0125300
}
f0101d8d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101d90:	c9                   	leave  
f0101d91:	c3                   	ret    
		panic("mmio_map_region: MMIOLIMIT overflow");
f0101d92:	83 ec 04             	sub    $0x4,%esp
f0101d95:	68 04 6f 10 f0       	push   $0xf0106f04
f0101d9a:	68 69 02 00 00       	push   $0x269
f0101d9f:	68 ff 74 10 f0       	push   $0xf01074ff
f0101da4:	e8 c1 e2 ff ff       	call   f010006a <_panic>

f0101da9 <check_page>:
{
f0101da9:	55                   	push   %ebp
f0101daa:	89 e5                	mov    %esp,%ebp
f0101dac:	57                   	push   %edi
f0101dad:	56                   	push   %esi
f0101dae:	53                   	push   %ebx
f0101daf:	83 ec 38             	sub    $0x38,%esp
	assert((pp0 = page_alloc(0)));
f0101db2:	6a 00                	push   $0x0
f0101db4:	e8 9b f5 ff ff       	call   f0101354 <page_alloc>
f0101db9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101dbc:	83 c4 10             	add    $0x10,%esp
f0101dbf:	85 c0                	test   %eax,%eax
f0101dc1:	0f 84 68 07 00 00    	je     f010252f <check_page+0x786>
	assert((pp1 = page_alloc(0)));
f0101dc7:	83 ec 0c             	sub    $0xc,%esp
f0101dca:	6a 00                	push   $0x0
f0101dcc:	e8 83 f5 ff ff       	call   f0101354 <page_alloc>
f0101dd1:	89 c3                	mov    %eax,%ebx
f0101dd3:	83 c4 10             	add    $0x10,%esp
f0101dd6:	85 c0                	test   %eax,%eax
f0101dd8:	0f 84 6a 07 00 00    	je     f0102548 <check_page+0x79f>
	assert((pp2 = page_alloc(0)));
f0101dde:	83 ec 0c             	sub    $0xc,%esp
f0101de1:	6a 00                	push   $0x0
f0101de3:	e8 6c f5 ff ff       	call   f0101354 <page_alloc>
f0101de8:	89 c7                	mov    %eax,%edi
f0101dea:	83 c4 10             	add    $0x10,%esp
f0101ded:	85 c0                	test   %eax,%eax
f0101def:	0f 84 6c 07 00 00    	je     f0102561 <check_page+0x7b8>
	assert(pp1 && pp1 != pp0);
f0101df5:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101df8:	0f 84 7c 07 00 00    	je     f010257a <check_page+0x7d1>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101dfe:	39 c3                	cmp    %eax,%ebx
f0101e00:	0f 84 8d 07 00 00    	je     f0102593 <check_page+0x7ea>
f0101e06:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101e09:	0f 84 84 07 00 00    	je     f0102593 <check_page+0x7ea>
	fl = page_free_list;
f0101e0f:	a1 6c 82 24 f0       	mov    0xf024826c,%eax
f0101e14:	89 45 c8             	mov    %eax,-0x38(%ebp)
	page_free_list = 0;
f0101e17:	c7 05 6c 82 24 f0 00 	movl   $0x0,0xf024826c
f0101e1e:	00 00 00 
	assert(!page_alloc(0));
f0101e21:	83 ec 0c             	sub    $0xc,%esp
f0101e24:	6a 00                	push   $0x0
f0101e26:	e8 29 f5 ff ff       	call   f0101354 <page_alloc>
f0101e2b:	83 c4 10             	add    $0x10,%esp
f0101e2e:	85 c0                	test   %eax,%eax
f0101e30:	0f 85 76 07 00 00    	jne    f01025ac <check_page+0x803>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101e36:	83 ec 04             	sub    $0x4,%esp
f0101e39:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101e3c:	50                   	push   %eax
f0101e3d:	6a 00                	push   $0x0
f0101e3f:	ff 35 5c 82 24 f0    	push   0xf024825c
f0101e45:	e8 5e fa ff ff       	call   f01018a8 <page_lookup>
f0101e4a:	83 c4 10             	add    $0x10,%esp
f0101e4d:	85 c0                	test   %eax,%eax
f0101e4f:	0f 85 70 07 00 00    	jne    f01025c5 <check_page+0x81c>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101e55:	6a 02                	push   $0x2
f0101e57:	6a 00                	push   $0x0
f0101e59:	53                   	push   %ebx
f0101e5a:	ff 35 5c 82 24 f0    	push   0xf024825c
f0101e60:	e8 d2 fb ff ff       	call   f0101a37 <page_insert>
f0101e65:	83 c4 10             	add    $0x10,%esp
f0101e68:	85 c0                	test   %eax,%eax
f0101e6a:	0f 89 6e 07 00 00    	jns    f01025de <check_page+0x835>
	page_free(pp0);
f0101e70:	83 ec 0c             	sub    $0xc,%esp
f0101e73:	ff 75 d4             	push   -0x2c(%ebp)
f0101e76:	e8 20 f5 ff ff       	call   f010139b <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101e7b:	6a 02                	push   $0x2
f0101e7d:	6a 00                	push   $0x0
f0101e7f:	53                   	push   %ebx
f0101e80:	ff 35 5c 82 24 f0    	push   0xf024825c
f0101e86:	e8 ac fb ff ff       	call   f0101a37 <page_insert>
f0101e8b:	83 c4 20             	add    $0x20,%esp
f0101e8e:	85 c0                	test   %eax,%eax
f0101e90:	0f 85 61 07 00 00    	jne    f01025f7 <check_page+0x84e>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101e96:	8b 35 5c 82 24 f0    	mov    0xf024825c,%esi
f0101e9c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e9f:	e8 b9 ec ff ff       	call   f0100b5d <page2pa>
f0101ea4:	89 c2                	mov    %eax,%edx
f0101ea6:	8b 06                	mov    (%esi),%eax
f0101ea8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101ead:	39 d0                	cmp    %edx,%eax
f0101eaf:	0f 85 5b 07 00 00    	jne    f0102610 <check_page+0x867>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101eb5:	ba 00 00 00 00       	mov    $0x0,%edx
f0101eba:	89 f0                	mov    %esi,%eax
f0101ebc:	e8 80 ed ff ff       	call   f0100c41 <check_va2pa>
f0101ec1:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101ec4:	89 d8                	mov    %ebx,%eax
f0101ec6:	e8 92 ec ff ff       	call   f0100b5d <page2pa>
f0101ecb:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101ece:	0f 85 55 07 00 00    	jne    f0102629 <check_page+0x880>
	assert(pp1->pp_ref == 1);
f0101ed4:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101ed9:	0f 85 63 07 00 00    	jne    f0102642 <check_page+0x899>
	assert(pp0->pp_ref == 1);
f0101edf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ee2:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101ee7:	0f 85 6e 07 00 00    	jne    f010265b <check_page+0x8b2>
	assert(page_insert(kern_pgdir, pp2, (void *) PGSIZE, PTE_W) == 0);
f0101eed:	6a 02                	push   $0x2
f0101eef:	68 00 10 00 00       	push   $0x1000
f0101ef4:	57                   	push   %edi
f0101ef5:	56                   	push   %esi
f0101ef6:	e8 3c fb ff ff       	call   f0101a37 <page_insert>
f0101efb:	83 c4 10             	add    $0x10,%esp
f0101efe:	85 c0                	test   %eax,%eax
f0101f00:	0f 85 6e 07 00 00    	jne    f0102674 <check_page+0x8cb>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101f06:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f0b:	a1 5c 82 24 f0       	mov    0xf024825c,%eax
f0101f10:	e8 2c ed ff ff       	call   f0100c41 <check_va2pa>
f0101f15:	89 c6                	mov    %eax,%esi
f0101f17:	89 f8                	mov    %edi,%eax
f0101f19:	e8 3f ec ff ff       	call   f0100b5d <page2pa>
f0101f1e:	39 c6                	cmp    %eax,%esi
f0101f20:	0f 85 67 07 00 00    	jne    f010268d <check_page+0x8e4>
	assert(pp2->pp_ref == 1);
f0101f26:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101f2b:	0f 85 75 07 00 00    	jne    f01026a6 <check_page+0x8fd>
	assert(!page_alloc(0));
f0101f31:	83 ec 0c             	sub    $0xc,%esp
f0101f34:	6a 00                	push   $0x0
f0101f36:	e8 19 f4 ff ff       	call   f0101354 <page_alloc>
f0101f3b:	83 c4 10             	add    $0x10,%esp
f0101f3e:	85 c0                	test   %eax,%eax
f0101f40:	0f 85 79 07 00 00    	jne    f01026bf <check_page+0x916>
	assert(page_insert(kern_pgdir, pp2, (void *) PGSIZE, PTE_W) == 0);
f0101f46:	6a 02                	push   $0x2
f0101f48:	68 00 10 00 00       	push   $0x1000
f0101f4d:	57                   	push   %edi
f0101f4e:	ff 35 5c 82 24 f0    	push   0xf024825c
f0101f54:	e8 de fa ff ff       	call   f0101a37 <page_insert>
f0101f59:	83 c4 10             	add    $0x10,%esp
f0101f5c:	85 c0                	test   %eax,%eax
f0101f5e:	0f 85 74 07 00 00    	jne    f01026d8 <check_page+0x92f>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101f64:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f69:	a1 5c 82 24 f0       	mov    0xf024825c,%eax
f0101f6e:	e8 ce ec ff ff       	call   f0100c41 <check_va2pa>
f0101f73:	89 c6                	mov    %eax,%esi
f0101f75:	89 f8                	mov    %edi,%eax
f0101f77:	e8 e1 eb ff ff       	call   f0100b5d <page2pa>
f0101f7c:	39 c6                	cmp    %eax,%esi
f0101f7e:	0f 85 6d 07 00 00    	jne    f01026f1 <check_page+0x948>
	assert(pp2->pp_ref == 1);
f0101f84:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101f89:	0f 85 7b 07 00 00    	jne    f010270a <check_page+0x961>
	assert(!page_alloc(0));
f0101f8f:	83 ec 0c             	sub    $0xc,%esp
f0101f92:	6a 00                	push   $0x0
f0101f94:	e8 bb f3 ff ff       	call   f0101354 <page_alloc>
f0101f99:	83 c4 10             	add    $0x10,%esp
f0101f9c:	85 c0                	test   %eax,%eax
f0101f9e:	0f 85 7f 07 00 00    	jne    f0102723 <check_page+0x97a>
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101fa4:	8b 35 5c 82 24 f0    	mov    0xf024825c,%esi
f0101faa:	8b 0e                	mov    (%esi),%ecx
f0101fac:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0101fb2:	ba dc 03 00 00       	mov    $0x3dc,%edx
f0101fb7:	b8 ff 74 10 f0       	mov    $0xf01074ff,%eax
f0101fbc:	e8 36 ec ff ff       	call   f0100bf7 <_kaddr>
f0101fc1:	89 45 d0             	mov    %eax,-0x30(%ebp)
	assert(pgdir_walk(kern_pgdir, (void *) PGSIZE, 0) == ptep + PTX(PGSIZE));
f0101fc4:	83 ec 04             	sub    $0x4,%esp
f0101fc7:	6a 00                	push   $0x0
f0101fc9:	68 00 10 00 00       	push   $0x1000
f0101fce:	56                   	push   %esi
f0101fcf:	e8 60 f8 ff ff       	call   f0101834 <pgdir_walk>
f0101fd4:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0101fd7:	83 c6 04             	add    $0x4,%esi
f0101fda:	83 c4 10             	add    $0x10,%esp
f0101fdd:	39 c6                	cmp    %eax,%esi
f0101fdf:	0f 85 57 07 00 00    	jne    f010273c <check_page+0x993>
	assert(page_insert(kern_pgdir, pp2, (void *) PGSIZE, PTE_W | PTE_U) == 0);
f0101fe5:	6a 06                	push   $0x6
f0101fe7:	68 00 10 00 00       	push   $0x1000
f0101fec:	57                   	push   %edi
f0101fed:	ff 35 5c 82 24 f0    	push   0xf024825c
f0101ff3:	e8 3f fa ff ff       	call   f0101a37 <page_insert>
f0101ff8:	83 c4 10             	add    $0x10,%esp
f0101ffb:	85 c0                	test   %eax,%eax
f0101ffd:	0f 85 52 07 00 00    	jne    f0102755 <check_page+0x9ac>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102003:	8b 35 5c 82 24 f0    	mov    0xf024825c,%esi
f0102009:	ba 00 10 00 00       	mov    $0x1000,%edx
f010200e:	89 f0                	mov    %esi,%eax
f0102010:	e8 2c ec ff ff       	call   f0100c41 <check_va2pa>
f0102015:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102018:	89 f8                	mov    %edi,%eax
f010201a:	e8 3e eb ff ff       	call   f0100b5d <page2pa>
f010201f:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0102022:	0f 85 46 07 00 00    	jne    f010276e <check_page+0x9c5>
	assert(pp2->pp_ref == 1);
f0102028:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f010202d:	0f 85 54 07 00 00    	jne    f0102787 <check_page+0x9de>
	assert(*pgdir_walk(kern_pgdir, (void *) PGSIZE, 0) & PTE_U);
f0102033:	83 ec 04             	sub    $0x4,%esp
f0102036:	6a 00                	push   $0x0
f0102038:	68 00 10 00 00       	push   $0x1000
f010203d:	56                   	push   %esi
f010203e:	e8 f1 f7 ff ff       	call   f0101834 <pgdir_walk>
f0102043:	83 c4 10             	add    $0x10,%esp
f0102046:	f6 00 04             	testb  $0x4,(%eax)
f0102049:	0f 84 51 07 00 00    	je     f01027a0 <check_page+0x9f7>
	assert(kern_pgdir[0] & PTE_U);
f010204f:	a1 5c 82 24 f0       	mov    0xf024825c,%eax
f0102054:	f6 00 04             	testb  $0x4,(%eax)
f0102057:	0f 84 5c 07 00 00    	je     f01027b9 <check_page+0xa10>
	assert(page_insert(kern_pgdir, pp2, (void *) PGSIZE, PTE_W) == 0);
f010205d:	6a 02                	push   $0x2
f010205f:	68 00 10 00 00       	push   $0x1000
f0102064:	57                   	push   %edi
f0102065:	50                   	push   %eax
f0102066:	e8 cc f9 ff ff       	call   f0101a37 <page_insert>
f010206b:	83 c4 10             	add    $0x10,%esp
f010206e:	85 c0                	test   %eax,%eax
f0102070:	0f 85 5c 07 00 00    	jne    f01027d2 <check_page+0xa29>
	assert(*pgdir_walk(kern_pgdir, (void *) PGSIZE, 0) & PTE_W);
f0102076:	83 ec 04             	sub    $0x4,%esp
f0102079:	6a 00                	push   $0x0
f010207b:	68 00 10 00 00       	push   $0x1000
f0102080:	ff 35 5c 82 24 f0    	push   0xf024825c
f0102086:	e8 a9 f7 ff ff       	call   f0101834 <pgdir_walk>
f010208b:	83 c4 10             	add    $0x10,%esp
f010208e:	f6 00 02             	testb  $0x2,(%eax)
f0102091:	0f 84 54 07 00 00    	je     f01027eb <check_page+0xa42>
	assert(!(*pgdir_walk(kern_pgdir, (void *) PGSIZE, 0) & PTE_U));
f0102097:	83 ec 04             	sub    $0x4,%esp
f010209a:	6a 00                	push   $0x0
f010209c:	68 00 10 00 00       	push   $0x1000
f01020a1:	ff 35 5c 82 24 f0    	push   0xf024825c
f01020a7:	e8 88 f7 ff ff       	call   f0101834 <pgdir_walk>
f01020ac:	83 c4 10             	add    $0x10,%esp
f01020af:	f6 00 04             	testb  $0x4,(%eax)
f01020b2:	0f 85 4c 07 00 00    	jne    f0102804 <check_page+0xa5b>
	assert(page_insert(kern_pgdir, pp0, (void *) PTSIZE, PTE_W) < 0);
f01020b8:	6a 02                	push   $0x2
f01020ba:	68 00 00 40 00       	push   $0x400000
f01020bf:	ff 75 d4             	push   -0x2c(%ebp)
f01020c2:	ff 35 5c 82 24 f0    	push   0xf024825c
f01020c8:	e8 6a f9 ff ff       	call   f0101a37 <page_insert>
f01020cd:	83 c4 10             	add    $0x10,%esp
f01020d0:	85 c0                	test   %eax,%eax
f01020d2:	0f 89 45 07 00 00    	jns    f010281d <check_page+0xa74>
	assert(page_insert(kern_pgdir, pp1, (void *) PGSIZE, PTE_W) == 0);
f01020d8:	6a 02                	push   $0x2
f01020da:	68 00 10 00 00       	push   $0x1000
f01020df:	53                   	push   %ebx
f01020e0:	ff 35 5c 82 24 f0    	push   0xf024825c
f01020e6:	e8 4c f9 ff ff       	call   f0101a37 <page_insert>
f01020eb:	83 c4 10             	add    $0x10,%esp
f01020ee:	85 c0                	test   %eax,%eax
f01020f0:	0f 85 40 07 00 00    	jne    f0102836 <check_page+0xa8d>
	assert(!(*pgdir_walk(kern_pgdir, (void *) PGSIZE, 0) & PTE_U));
f01020f6:	83 ec 04             	sub    $0x4,%esp
f01020f9:	6a 00                	push   $0x0
f01020fb:	68 00 10 00 00       	push   $0x1000
f0102100:	ff 35 5c 82 24 f0    	push   0xf024825c
f0102106:	e8 29 f7 ff ff       	call   f0101834 <pgdir_walk>
f010210b:	83 c4 10             	add    $0x10,%esp
f010210e:	f6 00 04             	testb  $0x4,(%eax)
f0102111:	0f 85 38 07 00 00    	jne    f010284f <check_page+0xaa6>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102117:	8b 35 5c 82 24 f0    	mov    0xf024825c,%esi
f010211d:	ba 00 00 00 00       	mov    $0x0,%edx
f0102122:	89 f0                	mov    %esi,%eax
f0102124:	e8 18 eb ff ff       	call   f0100c41 <check_va2pa>
f0102129:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010212c:	89 d8                	mov    %ebx,%eax
f010212e:	e8 2a ea ff ff       	call   f0100b5d <page2pa>
f0102133:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102136:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0102139:	0f 85 29 07 00 00    	jne    f0102868 <check_page+0xabf>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010213f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102144:	89 f0                	mov    %esi,%eax
f0102146:	e8 f6 ea ff ff       	call   f0100c41 <check_va2pa>
f010214b:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f010214e:	0f 85 2d 07 00 00    	jne    f0102881 <check_page+0xad8>
	assert(pp1->pp_ref == 2);
f0102154:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0102159:	0f 85 3b 07 00 00    	jne    f010289a <check_page+0xaf1>
	assert(pp2->pp_ref == 0);
f010215f:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102164:	0f 85 49 07 00 00    	jne    f01028b3 <check_page+0xb0a>
	assert((pp = page_alloc(0)) && pp == pp2);
f010216a:	83 ec 0c             	sub    $0xc,%esp
f010216d:	6a 00                	push   $0x0
f010216f:	e8 e0 f1 ff ff       	call   f0101354 <page_alloc>
f0102174:	83 c4 10             	add    $0x10,%esp
f0102177:	39 c7                	cmp    %eax,%edi
f0102179:	0f 85 4d 07 00 00    	jne    f01028cc <check_page+0xb23>
f010217f:	85 c0                	test   %eax,%eax
f0102181:	0f 84 45 07 00 00    	je     f01028cc <check_page+0xb23>
	page_remove(kern_pgdir, 0x0);
f0102187:	83 ec 08             	sub    $0x8,%esp
f010218a:	6a 00                	push   $0x0
f010218c:	ff 35 5c 82 24 f0    	push   0xf024825c
f0102192:	e8 89 f7 ff ff       	call   f0101920 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102197:	8b 35 5c 82 24 f0    	mov    0xf024825c,%esi
f010219d:	ba 00 00 00 00       	mov    $0x0,%edx
f01021a2:	89 f0                	mov    %esi,%eax
f01021a4:	e8 98 ea ff ff       	call   f0100c41 <check_va2pa>
f01021a9:	83 c4 10             	add    $0x10,%esp
f01021ac:	83 f8 ff             	cmp    $0xffffffff,%eax
f01021af:	0f 85 30 07 00 00    	jne    f01028e5 <check_page+0xb3c>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01021b5:	ba 00 10 00 00       	mov    $0x1000,%edx
f01021ba:	89 f0                	mov    %esi,%eax
f01021bc:	e8 80 ea ff ff       	call   f0100c41 <check_va2pa>
f01021c1:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01021c4:	89 d8                	mov    %ebx,%eax
f01021c6:	e8 92 e9 ff ff       	call   f0100b5d <page2pa>
f01021cb:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f01021ce:	0f 85 2a 07 00 00    	jne    f01028fe <check_page+0xb55>
	assert(pp1->pp_ref == 1);
f01021d4:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01021d9:	0f 85 38 07 00 00    	jne    f0102917 <check_page+0xb6e>
	assert(pp2->pp_ref == 0);
f01021df:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01021e4:	0f 85 46 07 00 00    	jne    f0102930 <check_page+0xb87>
	assert(page_insert(kern_pgdir, pp1, (void *) PGSIZE, 0) == 0);
f01021ea:	6a 00                	push   $0x0
f01021ec:	68 00 10 00 00       	push   $0x1000
f01021f1:	53                   	push   %ebx
f01021f2:	56                   	push   %esi
f01021f3:	e8 3f f8 ff ff       	call   f0101a37 <page_insert>
f01021f8:	83 c4 10             	add    $0x10,%esp
f01021fb:	85 c0                	test   %eax,%eax
f01021fd:	0f 85 46 07 00 00    	jne    f0102949 <check_page+0xba0>
	assert(pp1->pp_ref);
f0102203:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102208:	0f 84 54 07 00 00    	je     f0102962 <check_page+0xbb9>
	assert(pp1->pp_link == NULL);
f010220e:	83 3b 00             	cmpl   $0x0,(%ebx)
f0102211:	0f 85 64 07 00 00    	jne    f010297b <check_page+0xbd2>
	page_remove(kern_pgdir, (void *) PGSIZE);
f0102217:	83 ec 08             	sub    $0x8,%esp
f010221a:	68 00 10 00 00       	push   $0x1000
f010221f:	ff 35 5c 82 24 f0    	push   0xf024825c
f0102225:	e8 f6 f6 ff ff       	call   f0101920 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010222a:	8b 35 5c 82 24 f0    	mov    0xf024825c,%esi
f0102230:	ba 00 00 00 00       	mov    $0x0,%edx
f0102235:	89 f0                	mov    %esi,%eax
f0102237:	e8 05 ea ff ff       	call   f0100c41 <check_va2pa>
f010223c:	83 c4 10             	add    $0x10,%esp
f010223f:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102242:	0f 85 4c 07 00 00    	jne    f0102994 <check_page+0xbeb>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102248:	ba 00 10 00 00       	mov    $0x1000,%edx
f010224d:	89 f0                	mov    %esi,%eax
f010224f:	e8 ed e9 ff ff       	call   f0100c41 <check_va2pa>
f0102254:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102257:	0f 85 50 07 00 00    	jne    f01029ad <check_page+0xc04>
	assert(pp1->pp_ref == 0);
f010225d:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102262:	0f 85 5e 07 00 00    	jne    f01029c6 <check_page+0xc1d>
	assert(pp2->pp_ref == 0);
f0102268:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f010226d:	0f 85 6c 07 00 00    	jne    f01029df <check_page+0xc36>
	assert((pp = page_alloc(0)) && pp == pp1);
f0102273:	83 ec 0c             	sub    $0xc,%esp
f0102276:	6a 00                	push   $0x0
f0102278:	e8 d7 f0 ff ff       	call   f0101354 <page_alloc>
f010227d:	83 c4 10             	add    $0x10,%esp
f0102280:	39 c3                	cmp    %eax,%ebx
f0102282:	0f 85 70 07 00 00    	jne    f01029f8 <check_page+0xc4f>
f0102288:	85 c0                	test   %eax,%eax
f010228a:	0f 84 68 07 00 00    	je     f01029f8 <check_page+0xc4f>
	assert(!page_alloc(0));
f0102290:	83 ec 0c             	sub    $0xc,%esp
f0102293:	6a 00                	push   $0x0
f0102295:	e8 ba f0 ff ff       	call   f0101354 <page_alloc>
f010229a:	83 c4 10             	add    $0x10,%esp
f010229d:	85 c0                	test   %eax,%eax
f010229f:	0f 85 6c 07 00 00    	jne    f0102a11 <check_page+0xc68>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01022a5:	8b 35 5c 82 24 f0    	mov    0xf024825c,%esi
f01022ab:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01022ae:	e8 aa e8 ff ff       	call   f0100b5d <page2pa>
f01022b3:	89 c2                	mov    %eax,%edx
f01022b5:	8b 06                	mov    (%esi),%eax
f01022b7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01022bc:	39 d0                	cmp    %edx,%eax
f01022be:	0f 85 66 07 00 00    	jne    f0102a2a <check_page+0xc81>
	kern_pgdir[0] = 0;
f01022c4:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	assert(pp0->pp_ref == 1);
f01022ca:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01022cd:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01022d2:	0f 85 6b 07 00 00    	jne    f0102a43 <check_page+0xc9a>
	pp0->pp_ref = 0;
f01022d8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01022db:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	page_free(pp0);
f01022e1:	83 ec 0c             	sub    $0xc,%esp
f01022e4:	50                   	push   %eax
f01022e5:	e8 b1 f0 ff ff       	call   f010139b <page_free>
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01022ea:	83 c4 0c             	add    $0xc,%esp
f01022ed:	6a 01                	push   $0x1
f01022ef:	68 00 10 40 00       	push   $0x401000
f01022f4:	ff 35 5c 82 24 f0    	push   0xf024825c
f01022fa:	e8 35 f5 ff ff       	call   f0101834 <pgdir_walk>
f01022ff:	89 45 d0             	mov    %eax,-0x30(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102302:	8b 35 5c 82 24 f0    	mov    0xf024825c,%esi
f0102308:	8b 4e 04             	mov    0x4(%esi),%ecx
f010230b:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102311:	ba 20 04 00 00       	mov    $0x420,%edx
f0102316:	b8 ff 74 10 f0       	mov    $0xf01074ff,%eax
f010231b:	e8 d7 e8 ff ff       	call   f0100bf7 <_kaddr>
	assert(ptep == ptep1 + PTX(va));
f0102320:	83 c0 04             	add    $0x4,%eax
f0102323:	83 c4 10             	add    $0x10,%esp
f0102326:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0102329:	0f 85 2d 07 00 00    	jne    f0102a5c <check_page+0xcb3>
	kern_pgdir[PDX(va)] = 0;
f010232f:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	pp0->pp_ref = 0;
f0102336:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0102339:	89 f0                	mov    %esi,%eax
f010233b:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102341:	e8 dd e8 ff ff       	call   f0100c23 <page2kva>
f0102346:	83 ec 04             	sub    $0x4,%esp
f0102349:	68 00 10 00 00       	push   $0x1000
f010234e:	68 ff 00 00 00       	push   $0xff
f0102353:	50                   	push   %eax
f0102354:	e8 99 35 00 00       	call   f01058f2 <memset>
	page_free(pp0);
f0102359:	89 34 24             	mov    %esi,(%esp)
f010235c:	e8 3a f0 ff ff       	call   f010139b <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102361:	83 c4 0c             	add    $0xc,%esp
f0102364:	6a 01                	push   $0x1
f0102366:	6a 00                	push   $0x0
f0102368:	ff 35 5c 82 24 f0    	push   0xf024825c
f010236e:	e8 c1 f4 ff ff       	call   f0101834 <pgdir_walk>
	ptep = (pte_t *) page2kva(pp0);
f0102373:	89 f0                	mov    %esi,%eax
f0102375:	e8 a9 e8 ff ff       	call   f0100c23 <page2kva>
f010237a:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
f0102380:	83 c4 10             	add    $0x10,%esp
		assert((ptep[i] & PTE_P) == 0);
f0102383:	f6 00 01             	testb  $0x1,(%eax)
f0102386:	0f 85 e9 06 00 00    	jne    f0102a75 <check_page+0xccc>
	for (i = 0; i < NPTENTRIES; i++)
f010238c:	83 c0 04             	add    $0x4,%eax
f010238f:	39 d0                	cmp    %edx,%eax
f0102391:	75 f0                	jne    f0102383 <check_page+0x5da>
	kern_pgdir[0] = 0;
f0102393:	a1 5c 82 24 f0       	mov    0xf024825c,%eax
f0102398:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f010239e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01023a1:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	page_free_list = fl;
f01023a7:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01023aa:	89 0d 6c 82 24 f0    	mov    %ecx,0xf024826c
	page_free(pp0);
f01023b0:	83 ec 0c             	sub    $0xc,%esp
f01023b3:	50                   	push   %eax
f01023b4:	e8 e2 ef ff ff       	call   f010139b <page_free>
	page_free(pp1);
f01023b9:	89 1c 24             	mov    %ebx,(%esp)
f01023bc:	e8 da ef ff ff       	call   f010139b <page_free>
	page_free(pp2);
f01023c1:	89 3c 24             	mov    %edi,(%esp)
f01023c4:	e8 d2 ef ff ff       	call   f010139b <page_free>
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f01023c9:	83 c4 08             	add    $0x8,%esp
f01023cc:	68 01 10 00 00       	push   $0x1001
f01023d1:	6a 00                	push   $0x0
f01023d3:	e8 67 f9 ff ff       	call   f0101d3f <mmio_map_region>
f01023d8:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f01023da:	83 c4 08             	add    $0x8,%esp
f01023dd:	68 00 10 00 00       	push   $0x1000
f01023e2:	6a 00                	push   $0x0
f01023e4:	e8 56 f9 ff ff       	call   f0101d3f <mmio_map_region>
f01023e9:	89 c6                	mov    %eax,%esi
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f01023eb:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f01023f1:	83 c4 10             	add    $0x10,%esp
f01023f4:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f01023fa:	0f 86 8e 06 00 00    	jbe    f0102a8e <check_page+0xce5>
f0102400:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0102405:	0f 87 83 06 00 00    	ja     f0102a8e <check_page+0xce5>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f010240b:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f0102411:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0102417:	0f 87 8a 06 00 00    	ja     f0102aa7 <check_page+0xcfe>
f010241d:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102423:	0f 86 7e 06 00 00    	jbe    f0102aa7 <check_page+0xcfe>
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102429:	89 da                	mov    %ebx,%edx
f010242b:	09 f2                	or     %esi,%edx
f010242d:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0102433:	0f 85 87 06 00 00    	jne    f0102ac0 <check_page+0xd17>
	assert(mm1 + 8096 <= mm2);
f0102439:	39 f0                	cmp    %esi,%eax
f010243b:	0f 87 98 06 00 00    	ja     f0102ad9 <check_page+0xd30>
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102441:	8b 3d 5c 82 24 f0    	mov    0xf024825c,%edi
f0102447:	89 da                	mov    %ebx,%edx
f0102449:	89 f8                	mov    %edi,%eax
f010244b:	e8 f1 e7 ff ff       	call   f0100c41 <check_va2pa>
f0102450:	85 c0                	test   %eax,%eax
f0102452:	0f 85 9a 06 00 00    	jne    f0102af2 <check_page+0xd49>
	assert(check_va2pa(kern_pgdir, mm1 + PGSIZE) == PGSIZE);
f0102458:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f010245e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102461:	89 c2                	mov    %eax,%edx
f0102463:	89 f8                	mov    %edi,%eax
f0102465:	e8 d7 e7 ff ff       	call   f0100c41 <check_va2pa>
f010246a:	3d 00 10 00 00       	cmp    $0x1000,%eax
f010246f:	0f 85 96 06 00 00    	jne    f0102b0b <check_page+0xd62>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102475:	89 f2                	mov    %esi,%edx
f0102477:	89 f8                	mov    %edi,%eax
f0102479:	e8 c3 e7 ff ff       	call   f0100c41 <check_va2pa>
f010247e:	85 c0                	test   %eax,%eax
f0102480:	0f 85 9e 06 00 00    	jne    f0102b24 <check_page+0xd7b>
	assert(check_va2pa(kern_pgdir, mm2 + PGSIZE) == ~0);
f0102486:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f010248c:	89 f8                	mov    %edi,%eax
f010248e:	e8 ae e7 ff ff       	call   f0100c41 <check_va2pa>
f0102493:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102496:	0f 85 a1 06 00 00    	jne    f0102b3d <check_page+0xd94>
	assert(*pgdir_walk(kern_pgdir, (void *) mm1, 0) &
f010249c:	83 ec 04             	sub    $0x4,%esp
f010249f:	6a 00                	push   $0x0
f01024a1:	53                   	push   %ebx
f01024a2:	57                   	push   %edi
f01024a3:	e8 8c f3 ff ff       	call   f0101834 <pgdir_walk>
f01024a8:	83 c4 10             	add    $0x10,%esp
f01024ab:	f6 00 1a             	testb  $0x1a,(%eax)
f01024ae:	0f 84 a2 06 00 00    	je     f0102b56 <check_page+0xdad>
	assert(!(*pgdir_walk(kern_pgdir, (void *) mm1, 0) & PTE_U));
f01024b4:	83 ec 04             	sub    $0x4,%esp
f01024b7:	6a 00                	push   $0x0
f01024b9:	53                   	push   %ebx
f01024ba:	ff 35 5c 82 24 f0    	push   0xf024825c
f01024c0:	e8 6f f3 ff ff       	call   f0101834 <pgdir_walk>
f01024c5:	83 c4 10             	add    $0x10,%esp
f01024c8:	f6 00 04             	testb  $0x4,(%eax)
f01024cb:	0f 85 9e 06 00 00    	jne    f0102b6f <check_page+0xdc6>
	*pgdir_walk(kern_pgdir, (void *) mm1, 0) = 0;
f01024d1:	83 ec 04             	sub    $0x4,%esp
f01024d4:	6a 00                	push   $0x0
f01024d6:	53                   	push   %ebx
f01024d7:	ff 35 5c 82 24 f0    	push   0xf024825c
f01024dd:	e8 52 f3 ff ff       	call   f0101834 <pgdir_walk>
f01024e2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void *) mm1 + PGSIZE, 0) = 0;
f01024e8:	83 c4 0c             	add    $0xc,%esp
f01024eb:	6a 00                	push   $0x0
f01024ed:	ff 75 d4             	push   -0x2c(%ebp)
f01024f0:	ff 35 5c 82 24 f0    	push   0xf024825c
f01024f6:	e8 39 f3 ff ff       	call   f0101834 <pgdir_walk>
f01024fb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void *) mm2, 0) = 0;
f0102501:	83 c4 0c             	add    $0xc,%esp
f0102504:	6a 00                	push   $0x0
f0102506:	56                   	push   %esi
f0102507:	ff 35 5c 82 24 f0    	push   0xf024825c
f010250d:	e8 22 f3 ff ff       	call   f0101834 <pgdir_walk>
f0102512:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	cprintf("check_page() succeeded!\n");
f0102518:	c7 04 24 b1 77 10 f0 	movl   $0xf01077b1,(%esp)
f010251f:	e8 96 12 00 00       	call   f01037ba <cprintf>
}
f0102524:	83 c4 10             	add    $0x10,%esp
f0102527:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010252a:	5b                   	pop    %ebx
f010252b:	5e                   	pop    %esi
f010252c:	5f                   	pop    %edi
f010252d:	5d                   	pop    %ebp
f010252e:	c3                   	ret    
	assert((pp0 = page_alloc(0)));
f010252f:	68 2d 76 10 f0       	push   $0xf010762d
f0102534:	68 0b 75 10 f0       	push   $0xf010750b
f0102539:	68 ac 03 00 00       	push   $0x3ac
f010253e:	68 ff 74 10 f0       	push   $0xf01074ff
f0102543:	e8 22 db ff ff       	call   f010006a <_panic>
	assert((pp1 = page_alloc(0)));
f0102548:	68 43 76 10 f0       	push   $0xf0107643
f010254d:	68 0b 75 10 f0       	push   $0xf010750b
f0102552:	68 ad 03 00 00       	push   $0x3ad
f0102557:	68 ff 74 10 f0       	push   $0xf01074ff
f010255c:	e8 09 db ff ff       	call   f010006a <_panic>
	assert((pp2 = page_alloc(0)));
f0102561:	68 59 76 10 f0       	push   $0xf0107659
f0102566:	68 0b 75 10 f0       	push   $0xf010750b
f010256b:	68 ae 03 00 00       	push   $0x3ae
f0102570:	68 ff 74 10 f0       	push   $0xf01074ff
f0102575:	e8 f0 da ff ff       	call   f010006a <_panic>
	assert(pp1 && pp1 != pp0);
f010257a:	68 6f 76 10 f0       	push   $0xf010766f
f010257f:	68 0b 75 10 f0       	push   $0xf010750b
f0102584:	68 b1 03 00 00       	push   $0x3b1
f0102589:	68 ff 74 10 f0       	push   $0xf01074ff
f010258e:	e8 d7 da ff ff       	call   f010006a <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102593:	68 9c 6d 10 f0       	push   $0xf0106d9c
f0102598:	68 0b 75 10 f0       	push   $0xf010750b
f010259d:	68 b2 03 00 00       	push   $0x3b2
f01025a2:	68 ff 74 10 f0       	push   $0xf01074ff
f01025a7:	e8 be da ff ff       	call   f010006a <_panic>
	assert(!page_alloc(0));
f01025ac:	68 81 76 10 f0       	push   $0xf0107681
f01025b1:	68 0b 75 10 f0       	push   $0xf010750b
f01025b6:	68 b9 03 00 00       	push   $0x3b9
f01025bb:	68 ff 74 10 f0       	push   $0xf01074ff
f01025c0:	e8 a5 da ff ff       	call   f010006a <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01025c5:	68 28 6f 10 f0       	push   $0xf0106f28
f01025ca:	68 0b 75 10 f0       	push   $0xf010750b
f01025cf:	68 bc 03 00 00       	push   $0x3bc
f01025d4:	68 ff 74 10 f0       	push   $0xf01074ff
f01025d9:	e8 8c da ff ff       	call   f010006a <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01025de:	68 60 6f 10 f0       	push   $0xf0106f60
f01025e3:	68 0b 75 10 f0       	push   $0xf010750b
f01025e8:	68 bf 03 00 00       	push   $0x3bf
f01025ed:	68 ff 74 10 f0       	push   $0xf01074ff
f01025f2:	e8 73 da ff ff       	call   f010006a <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01025f7:	68 90 6f 10 f0       	push   $0xf0106f90
f01025fc:	68 0b 75 10 f0       	push   $0xf010750b
f0102601:	68 c3 03 00 00       	push   $0x3c3
f0102606:	68 ff 74 10 f0       	push   $0xf01074ff
f010260b:	e8 5a da ff ff       	call   f010006a <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102610:	68 b0 6e 10 f0       	push   $0xf0106eb0
f0102615:	68 0b 75 10 f0       	push   $0xf010750b
f010261a:	68 c4 03 00 00       	push   $0x3c4
f010261f:	68 ff 74 10 f0       	push   $0xf01074ff
f0102624:	e8 41 da ff ff       	call   f010006a <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0102629:	68 c0 6f 10 f0       	push   $0xf0106fc0
f010262e:	68 0b 75 10 f0       	push   $0xf010750b
f0102633:	68 c5 03 00 00       	push   $0x3c5
f0102638:	68 ff 74 10 f0       	push   $0xf01074ff
f010263d:	e8 28 da ff ff       	call   f010006a <_panic>
	assert(pp1->pp_ref == 1);
f0102642:	68 d3 76 10 f0       	push   $0xf01076d3
f0102647:	68 0b 75 10 f0       	push   $0xf010750b
f010264c:	68 c6 03 00 00       	push   $0x3c6
f0102651:	68 ff 74 10 f0       	push   $0xf01074ff
f0102656:	e8 0f da ff ff       	call   f010006a <_panic>
	assert(pp0->pp_ref == 1);
f010265b:	68 17 77 10 f0       	push   $0xf0107717
f0102660:	68 0b 75 10 f0       	push   $0xf010750b
f0102665:	68 c7 03 00 00       	push   $0x3c7
f010266a:	68 ff 74 10 f0       	push   $0xf01074ff
f010266f:	e8 f6 d9 ff ff       	call   f010006a <_panic>
	assert(page_insert(kern_pgdir, pp2, (void *) PGSIZE, PTE_W) == 0);
f0102674:	68 f0 6f 10 f0       	push   $0xf0106ff0
f0102679:	68 0b 75 10 f0       	push   $0xf010750b
f010267e:	68 cb 03 00 00       	push   $0x3cb
f0102683:	68 ff 74 10 f0       	push   $0xf01074ff
f0102688:	e8 dd d9 ff ff       	call   f010006a <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010268d:	68 2c 70 10 f0       	push   $0xf010702c
f0102692:	68 0b 75 10 f0       	push   $0xf010750b
f0102697:	68 cc 03 00 00       	push   $0x3cc
f010269c:	68 ff 74 10 f0       	push   $0xf01074ff
f01026a1:	e8 c4 d9 ff ff       	call   f010006a <_panic>
	assert(pp2->pp_ref == 1);
f01026a6:	68 e4 76 10 f0       	push   $0xf01076e4
f01026ab:	68 0b 75 10 f0       	push   $0xf010750b
f01026b0:	68 cd 03 00 00       	push   $0x3cd
f01026b5:	68 ff 74 10 f0       	push   $0xf01074ff
f01026ba:	e8 ab d9 ff ff       	call   f010006a <_panic>
	assert(!page_alloc(0));
f01026bf:	68 81 76 10 f0       	push   $0xf0107681
f01026c4:	68 0b 75 10 f0       	push   $0xf010750b
f01026c9:	68 d0 03 00 00       	push   $0x3d0
f01026ce:	68 ff 74 10 f0       	push   $0xf01074ff
f01026d3:	e8 92 d9 ff ff       	call   f010006a <_panic>
	assert(page_insert(kern_pgdir, pp2, (void *) PGSIZE, PTE_W) == 0);
f01026d8:	68 f0 6f 10 f0       	push   $0xf0106ff0
f01026dd:	68 0b 75 10 f0       	push   $0xf010750b
f01026e2:	68 d3 03 00 00       	push   $0x3d3
f01026e7:	68 ff 74 10 f0       	push   $0xf01074ff
f01026ec:	e8 79 d9 ff ff       	call   f010006a <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01026f1:	68 2c 70 10 f0       	push   $0xf010702c
f01026f6:	68 0b 75 10 f0       	push   $0xf010750b
f01026fb:	68 d4 03 00 00       	push   $0x3d4
f0102700:	68 ff 74 10 f0       	push   $0xf01074ff
f0102705:	e8 60 d9 ff ff       	call   f010006a <_panic>
	assert(pp2->pp_ref == 1);
f010270a:	68 e4 76 10 f0       	push   $0xf01076e4
f010270f:	68 0b 75 10 f0       	push   $0xf010750b
f0102714:	68 d5 03 00 00       	push   $0x3d5
f0102719:	68 ff 74 10 f0       	push   $0xf01074ff
f010271e:	e8 47 d9 ff ff       	call   f010006a <_panic>
	assert(!page_alloc(0));
f0102723:	68 81 76 10 f0       	push   $0xf0107681
f0102728:	68 0b 75 10 f0       	push   $0xf010750b
f010272d:	68 d9 03 00 00       	push   $0x3d9
f0102732:	68 ff 74 10 f0       	push   $0xf01074ff
f0102737:	e8 2e d9 ff ff       	call   f010006a <_panic>
	assert(pgdir_walk(kern_pgdir, (void *) PGSIZE, 0) == ptep + PTX(PGSIZE));
f010273c:	68 5c 70 10 f0       	push   $0xf010705c
f0102741:	68 0b 75 10 f0       	push   $0xf010750b
f0102746:	68 dd 03 00 00       	push   $0x3dd
f010274b:	68 ff 74 10 f0       	push   $0xf01074ff
f0102750:	e8 15 d9 ff ff       	call   f010006a <_panic>
	assert(page_insert(kern_pgdir, pp2, (void *) PGSIZE, PTE_W | PTE_U) == 0);
f0102755:	68 a0 70 10 f0       	push   $0xf01070a0
f010275a:	68 0b 75 10 f0       	push   $0xf010750b
f010275f:	68 e0 03 00 00       	push   $0x3e0
f0102764:	68 ff 74 10 f0       	push   $0xf01074ff
f0102769:	e8 fc d8 ff ff       	call   f010006a <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010276e:	68 2c 70 10 f0       	push   $0xf010702c
f0102773:	68 0b 75 10 f0       	push   $0xf010750b
f0102778:	68 e1 03 00 00       	push   $0x3e1
f010277d:	68 ff 74 10 f0       	push   $0xf01074ff
f0102782:	e8 e3 d8 ff ff       	call   f010006a <_panic>
	assert(pp2->pp_ref == 1);
f0102787:	68 e4 76 10 f0       	push   $0xf01076e4
f010278c:	68 0b 75 10 f0       	push   $0xf010750b
f0102791:	68 e2 03 00 00       	push   $0x3e2
f0102796:	68 ff 74 10 f0       	push   $0xf01074ff
f010279b:	e8 ca d8 ff ff       	call   f010006a <_panic>
	assert(*pgdir_walk(kern_pgdir, (void *) PGSIZE, 0) & PTE_U);
f01027a0:	68 e4 70 10 f0       	push   $0xf01070e4
f01027a5:	68 0b 75 10 f0       	push   $0xf010750b
f01027aa:	68 e3 03 00 00       	push   $0x3e3
f01027af:	68 ff 74 10 f0       	push   $0xf01074ff
f01027b4:	e8 b1 d8 ff ff       	call   f010006a <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01027b9:	68 28 77 10 f0       	push   $0xf0107728
f01027be:	68 0b 75 10 f0       	push   $0xf010750b
f01027c3:	68 e4 03 00 00       	push   $0x3e4
f01027c8:	68 ff 74 10 f0       	push   $0xf01074ff
f01027cd:	e8 98 d8 ff ff       	call   f010006a <_panic>
	assert(page_insert(kern_pgdir, pp2, (void *) PGSIZE, PTE_W) == 0);
f01027d2:	68 f0 6f 10 f0       	push   $0xf0106ff0
f01027d7:	68 0b 75 10 f0       	push   $0xf010750b
f01027dc:	68 e7 03 00 00       	push   $0x3e7
f01027e1:	68 ff 74 10 f0       	push   $0xf01074ff
f01027e6:	e8 7f d8 ff ff       	call   f010006a <_panic>
	assert(*pgdir_walk(kern_pgdir, (void *) PGSIZE, 0) & PTE_W);
f01027eb:	68 18 71 10 f0       	push   $0xf0107118
f01027f0:	68 0b 75 10 f0       	push   $0xf010750b
f01027f5:	68 e8 03 00 00       	push   $0x3e8
f01027fa:	68 ff 74 10 f0       	push   $0xf01074ff
f01027ff:	e8 66 d8 ff ff       	call   f010006a <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void *) PGSIZE, 0) & PTE_U));
f0102804:	68 4c 71 10 f0       	push   $0xf010714c
f0102809:	68 0b 75 10 f0       	push   $0xf010750b
f010280e:	68 e9 03 00 00       	push   $0x3e9
f0102813:	68 ff 74 10 f0       	push   $0xf01074ff
f0102818:	e8 4d d8 ff ff       	call   f010006a <_panic>
	assert(page_insert(kern_pgdir, pp0, (void *) PTSIZE, PTE_W) < 0);
f010281d:	68 84 71 10 f0       	push   $0xf0107184
f0102822:	68 0b 75 10 f0       	push   $0xf010750b
f0102827:	68 ed 03 00 00       	push   $0x3ed
f010282c:	68 ff 74 10 f0       	push   $0xf01074ff
f0102831:	e8 34 d8 ff ff       	call   f010006a <_panic>
	assert(page_insert(kern_pgdir, pp1, (void *) PGSIZE, PTE_W) == 0);
f0102836:	68 c0 71 10 f0       	push   $0xf01071c0
f010283b:	68 0b 75 10 f0       	push   $0xf010750b
f0102840:	68 f0 03 00 00       	push   $0x3f0
f0102845:	68 ff 74 10 f0       	push   $0xf01074ff
f010284a:	e8 1b d8 ff ff       	call   f010006a <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void *) PGSIZE, 0) & PTE_U));
f010284f:	68 4c 71 10 f0       	push   $0xf010714c
f0102854:	68 0b 75 10 f0       	push   $0xf010750b
f0102859:	68 f1 03 00 00       	push   $0x3f1
f010285e:	68 ff 74 10 f0       	push   $0xf01074ff
f0102863:	e8 02 d8 ff ff       	call   f010006a <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102868:	68 fc 71 10 f0       	push   $0xf01071fc
f010286d:	68 0b 75 10 f0       	push   $0xf010750b
f0102872:	68 f4 03 00 00       	push   $0x3f4
f0102877:	68 ff 74 10 f0       	push   $0xf01074ff
f010287c:	e8 e9 d7 ff ff       	call   f010006a <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102881:	68 28 72 10 f0       	push   $0xf0107228
f0102886:	68 0b 75 10 f0       	push   $0xf010750b
f010288b:	68 f5 03 00 00       	push   $0x3f5
f0102890:	68 ff 74 10 f0       	push   $0xf01074ff
f0102895:	e8 d0 d7 ff ff       	call   f010006a <_panic>
	assert(pp1->pp_ref == 2);
f010289a:	68 3e 77 10 f0       	push   $0xf010773e
f010289f:	68 0b 75 10 f0       	push   $0xf010750b
f01028a4:	68 f7 03 00 00       	push   $0x3f7
f01028a9:	68 ff 74 10 f0       	push   $0xf01074ff
f01028ae:	e8 b7 d7 ff ff       	call   f010006a <_panic>
	assert(pp2->pp_ref == 0);
f01028b3:	68 06 77 10 f0       	push   $0xf0107706
f01028b8:	68 0b 75 10 f0       	push   $0xf010750b
f01028bd:	68 f8 03 00 00       	push   $0x3f8
f01028c2:	68 ff 74 10 f0       	push   $0xf01074ff
f01028c7:	e8 9e d7 ff ff       	call   f010006a <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f01028cc:	68 58 72 10 f0       	push   $0xf0107258
f01028d1:	68 0b 75 10 f0       	push   $0xf010750b
f01028d6:	68 fb 03 00 00       	push   $0x3fb
f01028db:	68 ff 74 10 f0       	push   $0xf01074ff
f01028e0:	e8 85 d7 ff ff       	call   f010006a <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01028e5:	68 7c 72 10 f0       	push   $0xf010727c
f01028ea:	68 0b 75 10 f0       	push   $0xf010750b
f01028ef:	68 ff 03 00 00       	push   $0x3ff
f01028f4:	68 ff 74 10 f0       	push   $0xf01074ff
f01028f9:	e8 6c d7 ff ff       	call   f010006a <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01028fe:	68 28 72 10 f0       	push   $0xf0107228
f0102903:	68 0b 75 10 f0       	push   $0xf010750b
f0102908:	68 00 04 00 00       	push   $0x400
f010290d:	68 ff 74 10 f0       	push   $0xf01074ff
f0102912:	e8 53 d7 ff ff       	call   f010006a <_panic>
	assert(pp1->pp_ref == 1);
f0102917:	68 d3 76 10 f0       	push   $0xf01076d3
f010291c:	68 0b 75 10 f0       	push   $0xf010750b
f0102921:	68 01 04 00 00       	push   $0x401
f0102926:	68 ff 74 10 f0       	push   $0xf01074ff
f010292b:	e8 3a d7 ff ff       	call   f010006a <_panic>
	assert(pp2->pp_ref == 0);
f0102930:	68 06 77 10 f0       	push   $0xf0107706
f0102935:	68 0b 75 10 f0       	push   $0xf010750b
f010293a:	68 02 04 00 00       	push   $0x402
f010293f:	68 ff 74 10 f0       	push   $0xf01074ff
f0102944:	e8 21 d7 ff ff       	call   f010006a <_panic>
	assert(page_insert(kern_pgdir, pp1, (void *) PGSIZE, 0) == 0);
f0102949:	68 a0 72 10 f0       	push   $0xf01072a0
f010294e:	68 0b 75 10 f0       	push   $0xf010750b
f0102953:	68 05 04 00 00       	push   $0x405
f0102958:	68 ff 74 10 f0       	push   $0xf01074ff
f010295d:	e8 08 d7 ff ff       	call   f010006a <_panic>
	assert(pp1->pp_ref);
f0102962:	68 4f 77 10 f0       	push   $0xf010774f
f0102967:	68 0b 75 10 f0       	push   $0xf010750b
f010296c:	68 06 04 00 00       	push   $0x406
f0102971:	68 ff 74 10 f0       	push   $0xf01074ff
f0102976:	e8 ef d6 ff ff       	call   f010006a <_panic>
	assert(pp1->pp_link == NULL);
f010297b:	68 5b 77 10 f0       	push   $0xf010775b
f0102980:	68 0b 75 10 f0       	push   $0xf010750b
f0102985:	68 07 04 00 00       	push   $0x407
f010298a:	68 ff 74 10 f0       	push   $0xf01074ff
f010298f:	e8 d6 d6 ff ff       	call   f010006a <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102994:	68 7c 72 10 f0       	push   $0xf010727c
f0102999:	68 0b 75 10 f0       	push   $0xf010750b
f010299e:	68 0b 04 00 00       	push   $0x40b
f01029a3:	68 ff 74 10 f0       	push   $0xf01074ff
f01029a8:	e8 bd d6 ff ff       	call   f010006a <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01029ad:	68 d8 72 10 f0       	push   $0xf01072d8
f01029b2:	68 0b 75 10 f0       	push   $0xf010750b
f01029b7:	68 0c 04 00 00       	push   $0x40c
f01029bc:	68 ff 74 10 f0       	push   $0xf01074ff
f01029c1:	e8 a4 d6 ff ff       	call   f010006a <_panic>
	assert(pp1->pp_ref == 0);
f01029c6:	68 f5 76 10 f0       	push   $0xf01076f5
f01029cb:	68 0b 75 10 f0       	push   $0xf010750b
f01029d0:	68 0d 04 00 00       	push   $0x40d
f01029d5:	68 ff 74 10 f0       	push   $0xf01074ff
f01029da:	e8 8b d6 ff ff       	call   f010006a <_panic>
	assert(pp2->pp_ref == 0);
f01029df:	68 06 77 10 f0       	push   $0xf0107706
f01029e4:	68 0b 75 10 f0       	push   $0xf010750b
f01029e9:	68 0e 04 00 00       	push   $0x40e
f01029ee:	68 ff 74 10 f0       	push   $0xf01074ff
f01029f3:	e8 72 d6 ff ff       	call   f010006a <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f01029f8:	68 00 73 10 f0       	push   $0xf0107300
f01029fd:	68 0b 75 10 f0       	push   $0xf010750b
f0102a02:	68 11 04 00 00       	push   $0x411
f0102a07:	68 ff 74 10 f0       	push   $0xf01074ff
f0102a0c:	e8 59 d6 ff ff       	call   f010006a <_panic>
	assert(!page_alloc(0));
f0102a11:	68 81 76 10 f0       	push   $0xf0107681
f0102a16:	68 0b 75 10 f0       	push   $0xf010750b
f0102a1b:	68 14 04 00 00       	push   $0x414
f0102a20:	68 ff 74 10 f0       	push   $0xf01074ff
f0102a25:	e8 40 d6 ff ff       	call   f010006a <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102a2a:	68 b0 6e 10 f0       	push   $0xf0106eb0
f0102a2f:	68 0b 75 10 f0       	push   $0xf010750b
f0102a34:	68 17 04 00 00       	push   $0x417
f0102a39:	68 ff 74 10 f0       	push   $0xf01074ff
f0102a3e:	e8 27 d6 ff ff       	call   f010006a <_panic>
	assert(pp0->pp_ref == 1);
f0102a43:	68 17 77 10 f0       	push   $0xf0107717
f0102a48:	68 0b 75 10 f0       	push   $0xf010750b
f0102a4d:	68 19 04 00 00       	push   $0x419
f0102a52:	68 ff 74 10 f0       	push   $0xf01074ff
f0102a57:	e8 0e d6 ff ff       	call   f010006a <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102a5c:	68 70 77 10 f0       	push   $0xf0107770
f0102a61:	68 0b 75 10 f0       	push   $0xf010750b
f0102a66:	68 21 04 00 00       	push   $0x421
f0102a6b:	68 ff 74 10 f0       	push   $0xf01074ff
f0102a70:	e8 f5 d5 ff ff       	call   f010006a <_panic>
		assert((ptep[i] & PTE_P) == 0);
f0102a75:	68 88 77 10 f0       	push   $0xf0107788
f0102a7a:	68 0b 75 10 f0       	push   $0xf010750b
f0102a7f:	68 2b 04 00 00       	push   $0x42b
f0102a84:	68 ff 74 10 f0       	push   $0xf01074ff
f0102a89:	e8 dc d5 ff ff       	call   f010006a <_panic>
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f0102a8e:	68 24 73 10 f0       	push   $0xf0107324
f0102a93:	68 0b 75 10 f0       	push   $0xf010750b
f0102a98:	68 3b 04 00 00       	push   $0x43b
f0102a9d:	68 ff 74 10 f0       	push   $0xf01074ff
f0102aa2:	e8 c3 d5 ff ff       	call   f010006a <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0102aa7:	68 4c 73 10 f0       	push   $0xf010734c
f0102aac:	68 0b 75 10 f0       	push   $0xf010750b
f0102ab1:	68 3c 04 00 00       	push   $0x43c
f0102ab6:	68 ff 74 10 f0       	push   $0xf01074ff
f0102abb:	e8 aa d5 ff ff       	call   f010006a <_panic>
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102ac0:	68 74 73 10 f0       	push   $0xf0107374
f0102ac5:	68 0b 75 10 f0       	push   $0xf010750b
f0102aca:	68 3e 04 00 00       	push   $0x43e
f0102acf:	68 ff 74 10 f0       	push   $0xf01074ff
f0102ad4:	e8 91 d5 ff ff       	call   f010006a <_panic>
	assert(mm1 + 8096 <= mm2);
f0102ad9:	68 9f 77 10 f0       	push   $0xf010779f
f0102ade:	68 0b 75 10 f0       	push   $0xf010750b
f0102ae3:	68 40 04 00 00       	push   $0x440
f0102ae8:	68 ff 74 10 f0       	push   $0xf01074ff
f0102aed:	e8 78 d5 ff ff       	call   f010006a <_panic>
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102af2:	68 9c 73 10 f0       	push   $0xf010739c
f0102af7:	68 0b 75 10 f0       	push   $0xf010750b
f0102afc:	68 42 04 00 00       	push   $0x442
f0102b01:	68 ff 74 10 f0       	push   $0xf01074ff
f0102b06:	e8 5f d5 ff ff       	call   f010006a <_panic>
	assert(check_va2pa(kern_pgdir, mm1 + PGSIZE) == PGSIZE);
f0102b0b:	68 c0 73 10 f0       	push   $0xf01073c0
f0102b10:	68 0b 75 10 f0       	push   $0xf010750b
f0102b15:	68 43 04 00 00       	push   $0x443
f0102b1a:	68 ff 74 10 f0       	push   $0xf01074ff
f0102b1f:	e8 46 d5 ff ff       	call   f010006a <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102b24:	68 f0 73 10 f0       	push   $0xf01073f0
f0102b29:	68 0b 75 10 f0       	push   $0xf010750b
f0102b2e:	68 44 04 00 00       	push   $0x444
f0102b33:	68 ff 74 10 f0       	push   $0xf01074ff
f0102b38:	e8 2d d5 ff ff       	call   f010006a <_panic>
	assert(check_va2pa(kern_pgdir, mm2 + PGSIZE) == ~0);
f0102b3d:	68 14 74 10 f0       	push   $0xf0107414
f0102b42:	68 0b 75 10 f0       	push   $0xf010750b
f0102b47:	68 45 04 00 00       	push   $0x445
f0102b4c:	68 ff 74 10 f0       	push   $0xf01074ff
f0102b51:	e8 14 d5 ff ff       	call   f010006a <_panic>
	assert(*pgdir_walk(kern_pgdir, (void *) mm1, 0) &
f0102b56:	68 40 74 10 f0       	push   $0xf0107440
f0102b5b:	68 0b 75 10 f0       	push   $0xf010750b
f0102b60:	68 47 04 00 00       	push   $0x447
f0102b65:	68 ff 74 10 f0       	push   $0xf01074ff
f0102b6a:	e8 fb d4 ff ff       	call   f010006a <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void *) mm1, 0) & PTE_U));
f0102b6f:	68 88 74 10 f0       	push   $0xf0107488
f0102b74:	68 0b 75 10 f0       	push   $0xf010750b
f0102b79:	68 49 04 00 00       	push   $0x449
f0102b7e:	68 ff 74 10 f0       	push   $0xf01074ff
f0102b83:	e8 e2 d4 ff ff       	call   f010006a <_panic>

f0102b88 <mem_init>:
{
f0102b88:	55                   	push   %ebp
f0102b89:	89 e5                	mov    %esp,%ebp
f0102b8b:	53                   	push   %ebx
f0102b8c:	83 ec 04             	sub    $0x4,%esp
	i386_detect_memory();
f0102b8f:	e8 ff df ff ff       	call   f0100b93 <i386_detect_memory>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0102b94:	b8 00 10 00 00       	mov    $0x1000,%eax
f0102b99:	e8 2d e1 ff ff       	call   f0100ccb <boot_alloc>
f0102b9e:	a3 5c 82 24 f0       	mov    %eax,0xf024825c
	memset(kern_pgdir, 0, PGSIZE);
f0102ba3:	83 ec 04             	sub    $0x4,%esp
f0102ba6:	68 00 10 00 00       	push   $0x1000
f0102bab:	6a 00                	push   $0x0
f0102bad:	50                   	push   %eax
f0102bae:	e8 3f 2d 00 00       	call   f01058f2 <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0102bb3:	8b 1d 5c 82 24 f0    	mov    0xf024825c,%ebx
f0102bb9:	89 d9                	mov    %ebx,%ecx
f0102bbb:	ba 95 00 00 00       	mov    $0x95,%edx
f0102bc0:	b8 ff 74 10 f0       	mov    $0xf01074ff,%eax
f0102bc5:	e8 df e0 ff ff       	call   f0100ca9 <_paddr>
f0102bca:	83 c8 05             	or     $0x5,%eax
f0102bcd:	89 83 f4 0e 00 00    	mov    %eax,0xef4(%ebx)
	uint32_t pages_size = npages * sizeof(struct PageInfo);
f0102bd3:	a1 60 82 24 f0       	mov    0xf0248260,%eax
f0102bd8:	8d 1c c5 00 00 00 00 	lea    0x0(,%eax,8),%ebx
	pages = (struct PageInfo *) boot_alloc(pages_size);
f0102bdf:	89 d8                	mov    %ebx,%eax
f0102be1:	e8 e5 e0 ff ff       	call   f0100ccb <boot_alloc>
f0102be6:	a3 58 82 24 f0       	mov    %eax,0xf0248258
	memset(pages, 0, pages_size);
f0102beb:	83 c4 0c             	add    $0xc,%esp
f0102bee:	53                   	push   %ebx
f0102bef:	6a 00                	push   $0x0
f0102bf1:	50                   	push   %eax
f0102bf2:	e8 fb 2c 00 00       	call   f01058f2 <memset>
	envs = (struct Env *) boot_alloc(envs_size);
f0102bf7:	b8 00 20 02 00       	mov    $0x22000,%eax
f0102bfc:	e8 ca e0 ff ff       	call   f0100ccb <boot_alloc>
f0102c01:	a3 70 82 24 f0       	mov    %eax,0xf0248270
	memset(envs, 0, envs_size);
f0102c06:	83 c4 0c             	add    $0xc,%esp
f0102c09:	68 00 20 02 00       	push   $0x22000
f0102c0e:	6a 00                	push   $0x0
f0102c10:	50                   	push   %eax
f0102c11:	e8 dc 2c 00 00       	call   f01058f2 <memset>
	page_init();
f0102c16:	e8 ab e6 ff ff       	call   f01012c6 <page_init>
	check_page_free_list(1);
f0102c1b:	b8 01 00 00 00       	mov    $0x1,%eax
f0102c20:	e8 c6 e3 ff ff       	call   f0100feb <check_page_free_list>
	check_page_alloc();
f0102c25:	e8 c3 e7 ff ff       	call   f01013ed <check_page_alloc>
	check_page();
f0102c2a:	e8 7a f1 ff ff       	call   f0101da9 <check_page>
	boot_map_region(kern_pgdir,
f0102c2f:	8b 0d 58 82 24 f0    	mov    0xf0248258,%ecx
f0102c35:	ba bf 00 00 00       	mov    $0xbf,%edx
f0102c3a:	b8 ff 74 10 f0       	mov    $0xf01074ff,%eax
f0102c3f:	e8 65 e0 ff ff       	call   f0100ca9 <_paddr>
	                ROUNDUP(pages_size, PGSIZE),
f0102c44:	8d 8b ff 0f 00 00    	lea    0xfff(%ebx),%ecx
	boot_map_region(kern_pgdir,
f0102c4a:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102c50:	83 c4 08             	add    $0x8,%esp
f0102c53:	6a 05                	push   $0x5
f0102c55:	50                   	push   %eax
f0102c56:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102c5b:	a1 5c 82 24 f0       	mov    0xf024825c,%eax
f0102c60:	e8 1a ed ff ff       	call   f010197f <boot_map_region>
	boot_map_region(kern_pgdir,
f0102c65:	8b 0d 70 82 24 f0    	mov    0xf0248270,%ecx
f0102c6b:	ba cb 00 00 00       	mov    $0xcb,%edx
f0102c70:	b8 ff 74 10 f0       	mov    $0xf01074ff,%eax
f0102c75:	e8 2f e0 ff ff       	call   f0100ca9 <_paddr>
f0102c7a:	83 c4 08             	add    $0x8,%esp
f0102c7d:	6a 05                	push   $0x5
f0102c7f:	50                   	push   %eax
f0102c80:	b9 00 20 02 00       	mov    $0x22000,%ecx
f0102c85:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102c8a:	a1 5c 82 24 f0       	mov    0xf024825c,%eax
f0102c8f:	e8 eb ec ff ff       	call   f010197f <boot_map_region>
	boot_map_region(kern_pgdir,
f0102c94:	83 c4 08             	add    $0x8,%esp
f0102c97:	6a 03                	push   $0x3
f0102c99:	6a 00                	push   $0x0
f0102c9b:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102ca0:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102ca5:	a1 5c 82 24 f0       	mov    0xf024825c,%eax
f0102caa:	e8 d0 ec ff ff       	call   f010197f <boot_map_region>
	mem_init_mp();
f0102caf:	e8 28 ed ff ff       	call   f01019dc <mem_init_mp>
	check_kern_pgdir();
f0102cb4:	e8 94 e0 ff ff       	call   f0100d4d <check_kern_pgdir>
	lcr3(PADDR(kern_pgdir));
f0102cb9:	8b 0d 5c 82 24 f0    	mov    0xf024825c,%ecx
f0102cbf:	ba e8 00 00 00       	mov    $0xe8,%edx
f0102cc4:	b8 ff 74 10 f0       	mov    $0xf01074ff,%eax
f0102cc9:	e8 db df ff ff       	call   f0100ca9 <_paddr>
f0102cce:	e8 86 de ff ff       	call   f0100b59 <lcr3>
	check_page_free_list(0);
f0102cd3:	b8 00 00 00 00       	mov    $0x0,%eax
f0102cd8:	e8 0e e3 ff ff       	call   f0100feb <check_page_free_list>
	cr0 = rcr0();
f0102cdd:	e8 73 de ff ff       	call   f0100b55 <rcr0>
f0102ce2:	83 e0 f3             	and    $0xfffffff3,%eax
	cr0 &= ~(CR0_TS | CR0_EM);
f0102ce5:	0d 23 00 05 80       	or     $0x80050023,%eax
	lcr0(cr0);
f0102cea:	e8 62 de ff ff       	call   f0100b51 <lcr0>
	check_page_installed_pgdir();
f0102cef:	e8 9d ed ff ff       	call   f0101a91 <check_page_installed_pgdir>
}
f0102cf4:	83 c4 10             	add    $0x10,%esp
f0102cf7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102cfa:	c9                   	leave  
f0102cfb:	c3                   	ret    

f0102cfc <user_mem_check>:
{
f0102cfc:	55                   	push   %ebp
f0102cfd:	89 e5                	mov    %esp,%ebp
f0102cff:	57                   	push   %edi
f0102d00:	56                   	push   %esi
f0102d01:	53                   	push   %ebx
f0102d02:	83 ec 0c             	sub    $0xc,%esp
	uint32_t va_hi = ROUNDUP((uint32_t) va + len, PGSIZE);
f0102d05:	8b 45 10             	mov    0x10(%ebp),%eax
f0102d08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102d0b:	8d bc 01 ff 0f 00 00 	lea    0xfff(%ecx,%eax,1),%edi
f0102d12:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	if (va_hi > UTOP) {
f0102d18:	81 ff 00 00 c0 ee    	cmp    $0xeec00000,%edi
f0102d1e:	77 3b                	ja     f0102d5b <user_mem_check+0x5f>
	for (uint32_t va_act = ROUNDDOWN(va_lo, PGSIZE); va_act < va_hi;
f0102d20:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102d23:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
		if ((!pte) || ((*pte) & (perm | PTE_P)) != (perm | PTE_P)) {
f0102d29:	8b 75 14             	mov    0x14(%ebp),%esi
f0102d2c:	83 ce 01             	or     $0x1,%esi
	for (uint32_t va_act = ROUNDDOWN(va_lo, PGSIZE); va_act < va_hi;
f0102d2f:	39 fb                	cmp    %edi,%ebx
f0102d31:	73 50                	jae    f0102d83 <user_mem_check+0x87>
		pte = pgdir_walk(env->env_pgdir, (void *) va_act, 0);
f0102d33:	83 ec 04             	sub    $0x4,%esp
f0102d36:	6a 00                	push   $0x0
f0102d38:	53                   	push   %ebx
f0102d39:	8b 45 08             	mov    0x8(%ebp),%eax
f0102d3c:	ff 70 6c             	push   0x6c(%eax)
f0102d3f:	e8 f0 ea ff ff       	call   f0101834 <pgdir_walk>
		if ((!pte) || ((*pte) & (perm | PTE_P)) != (perm | PTE_P)) {
f0102d44:	83 c4 10             	add    $0x10,%esp
f0102d47:	85 c0                	test   %eax,%eax
f0102d49:	74 1d                	je     f0102d68 <user_mem_check+0x6c>
f0102d4b:	89 f2                	mov    %esi,%edx
f0102d4d:	23 10                	and    (%eax),%edx
f0102d4f:	39 d6                	cmp    %edx,%esi
f0102d51:	75 15                	jne    f0102d68 <user_mem_check+0x6c>
	     va_act += PGSIZE) {
f0102d53:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102d59:	eb d4                	jmp    f0102d2f <user_mem_check+0x33>
		user_mem_check_addr = va_lo;
f0102d5b:	89 0d 68 82 24 f0    	mov    %ecx,0xf0248268
		return -E_FAULT;
f0102d61:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102d66:	eb 13                	jmp    f0102d7b <user_mem_check+0x7f>
			user_mem_check_addr = (va_act > va_lo) ? va_act : va_lo;
f0102d68:	39 5d 0c             	cmp    %ebx,0xc(%ebp)
f0102d6b:	89 d8                	mov    %ebx,%eax
f0102d6d:	0f 43 45 0c          	cmovae 0xc(%ebp),%eax
f0102d71:	a3 68 82 24 f0       	mov    %eax,0xf0248268
			return -E_FAULT;
f0102d76:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
}
f0102d7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102d7e:	5b                   	pop    %ebx
f0102d7f:	5e                   	pop    %esi
f0102d80:	5f                   	pop    %edi
f0102d81:	5d                   	pop    %ebp
f0102d82:	c3                   	ret    
	return 0;
f0102d83:	b8 00 00 00 00       	mov    $0x0,%eax
f0102d88:	eb f1                	jmp    f0102d7b <user_mem_check+0x7f>

f0102d8a <user_mem_assert>:
{
f0102d8a:	55                   	push   %ebp
f0102d8b:	89 e5                	mov    %esp,%ebp
f0102d8d:	53                   	push   %ebx
f0102d8e:	83 ec 04             	sub    $0x4,%esp
f0102d91:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102d94:	8b 45 14             	mov    0x14(%ebp),%eax
f0102d97:	83 c8 04             	or     $0x4,%eax
f0102d9a:	50                   	push   %eax
f0102d9b:	ff 75 10             	push   0x10(%ebp)
f0102d9e:	ff 75 0c             	push   0xc(%ebp)
f0102da1:	53                   	push   %ebx
f0102da2:	e8 55 ff ff ff       	call   f0102cfc <user_mem_check>
f0102da7:	83 c4 10             	add    $0x10,%esp
f0102daa:	85 c0                	test   %eax,%eax
f0102dac:	78 05                	js     f0102db3 <user_mem_assert+0x29>
}
f0102dae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102db1:	c9                   	leave  
f0102db2:	c3                   	ret    
		cprintf("[%08x] user_mem_check assertion failure for "
f0102db3:	83 ec 04             	sub    $0x4,%esp
f0102db6:	ff 35 68 82 24 f0    	push   0xf0248268
f0102dbc:	ff 73 48             	push   0x48(%ebx)
f0102dbf:	68 bc 74 10 f0       	push   $0xf01074bc
f0102dc4:	e8 f1 09 00 00       	call   f01037ba <cprintf>
		env_destroy(env);  // may not return
f0102dc9:	89 1c 24             	mov    %ebx,(%esp)
f0102dcc:	e8 8b 06 00 00       	call   f010345c <env_destroy>
f0102dd1:	83 c4 10             	add    $0x10,%esp
}
f0102dd4:	eb d8                	jmp    f0102dae <user_mem_assert+0x24>

f0102dd6 <lgdt>:
	asm volatile("lgdt (%0)" : : "r"(p));
f0102dd6:	0f 01 10             	lgdtl  (%eax)
}
f0102dd9:	c3                   	ret    

f0102dda <lldt>:
	asm volatile("lldt %0" : : "r"(sel));
f0102dda:	0f 00 d0             	lldt   %ax
}
f0102ddd:	c3                   	ret    

f0102dde <lcr3>:
	asm volatile("movl %0,%%cr3" : : "r"(val));
f0102dde:	0f 22 d8             	mov    %eax,%cr3
}
f0102de1:	c3                   	ret    

f0102de2 <page2pa>:
	return (pp - pages) << PGSHIFT;
f0102de2:	2b 05 58 82 24 f0    	sub    0xf0248258,%eax
f0102de8:	c1 f8 03             	sar    $0x3,%eax
f0102deb:	c1 e0 0c             	shl    $0xc,%eax
}
f0102dee:	c3                   	ret    

f0102def <_kaddr>:
{
f0102def:	55                   	push   %ebp
f0102df0:	89 e5                	mov    %esp,%ebp
f0102df2:	53                   	push   %ebx
f0102df3:	83 ec 04             	sub    $0x4,%esp
	if (PGNUM(pa) >= npages)
f0102df6:	89 cb                	mov    %ecx,%ebx
f0102df8:	c1 eb 0c             	shr    $0xc,%ebx
f0102dfb:	3b 1d 60 82 24 f0    	cmp    0xf0248260,%ebx
f0102e01:	73 0b                	jae    f0102e0e <_kaddr+0x1f>
	return (void *) (pa + KERNBASE);
f0102e03:	8d 81 00 00 00 f0    	lea    -0x10000000(%ecx),%eax
}
f0102e09:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102e0c:	c9                   	leave  
f0102e0d:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102e0e:	51                   	push   %ecx
f0102e0f:	68 0c 66 10 f0       	push   $0xf010660c
f0102e14:	52                   	push   %edx
f0102e15:	50                   	push   %eax
f0102e16:	e8 4f d2 ff ff       	call   f010006a <_panic>

f0102e1b <page2kva>:
{
f0102e1b:	55                   	push   %ebp
f0102e1c:	89 e5                	mov    %esp,%ebp
f0102e1e:	83 ec 08             	sub    $0x8,%esp
	return KADDR(page2pa(pp));
f0102e21:	e8 bc ff ff ff       	call   f0102de2 <page2pa>
f0102e26:	89 c1                	mov    %eax,%ecx
f0102e28:	ba 58 00 00 00       	mov    $0x58,%edx
f0102e2d:	b8 f1 74 10 f0       	mov    $0xf01074f1,%eax
f0102e32:	e8 b8 ff ff ff       	call   f0102def <_kaddr>
}
f0102e37:	c9                   	leave  
f0102e38:	c3                   	ret    

f0102e39 <_paddr>:
	if ((uint32_t) kva < KERNBASE)
f0102e39:	81 f9 ff ff ff ef    	cmp    $0xefffffff,%ecx
f0102e3f:	76 07                	jbe    f0102e48 <_paddr+0xf>
	return (physaddr_t) kva - KERNBASE;
f0102e41:	8d 81 00 00 00 10    	lea    0x10000000(%ecx),%eax
}
f0102e47:	c3                   	ret    
{
f0102e48:	55                   	push   %ebp
f0102e49:	89 e5                	mov    %esp,%ebp
f0102e4b:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e4e:	51                   	push   %ecx
f0102e4f:	68 30 66 10 f0       	push   $0xf0106630
f0102e54:	52                   	push   %edx
f0102e55:	50                   	push   %eax
f0102e56:	e8 0f d2 ff ff       	call   f010006a <_panic>

f0102e5b <env_setup_vm>:
// Returns 0 on success, < 0 on error.  Errors include:
//	-E_NO_MEM if page directory or table could not be allocated.
//
static int
env_setup_vm(struct Env *e)
{
f0102e5b:	55                   	push   %ebp
f0102e5c:	89 e5                	mov    %esp,%ebp
f0102e5e:	56                   	push   %esi
f0102e5f:	53                   	push   %ebx
f0102e60:	89 c6                	mov    %eax,%esi
	int r;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0102e62:	83 ec 0c             	sub    $0xc,%esp
f0102e65:	6a 01                	push   $0x1
f0102e67:	e8 e8 e4 ff ff       	call   f0101354 <page_alloc>
f0102e6c:	83 c4 10             	add    $0x10,%esp
f0102e6f:	85 c0                	test   %eax,%eax
f0102e71:	74 4f                	je     f0102ec2 <env_setup_vm+0x67>
f0102e73:	89 c3                	mov    %eax,%ebx
	//    - Note: In general, pp_ref is not maintained for
	//	physical pages mapped only above UTOP, but env_pgdir
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.
	e->env_pgdir = (uint32_t *) page2kva(p);
f0102e75:	e8 a1 ff ff ff       	call   f0102e1b <page2kva>
f0102e7a:	89 46 6c             	mov    %eax,0x6c(%esi)
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f0102e7d:	83 ec 04             	sub    $0x4,%esp
f0102e80:	68 00 10 00 00       	push   $0x1000
f0102e85:	ff 35 5c 82 24 f0    	push   0xf024825c
f0102e8b:	50                   	push   %eax
f0102e8c:	e8 0d 2b 00 00       	call   f010599e <memcpy>
	p->pp_ref++;
f0102e91:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)


	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0102e96:	8b 5e 6c             	mov    0x6c(%esi),%ebx
f0102e99:	89 d9                	mov    %ebx,%ecx
f0102e9b:	ba c1 00 00 00       	mov    $0xc1,%edx
f0102ea0:	b8 3a 78 10 f0       	mov    $0xf010783a,%eax
f0102ea5:	e8 8f ff ff ff       	call   f0102e39 <_paddr>
f0102eaa:	83 c8 05             	or     $0x5,%eax
f0102ead:	89 83 f4 0e 00 00    	mov    %eax,0xef4(%ebx)
	return 0;
f0102eb3:	83 c4 10             	add    $0x10,%esp
f0102eb6:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102ebb:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0102ebe:	5b                   	pop    %ebx
f0102ebf:	5e                   	pop    %esi
f0102ec0:	5d                   	pop    %ebp
f0102ec1:	c3                   	ret    
		return -E_NO_MEM;
f0102ec2:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0102ec7:	eb f2                	jmp    f0102ebb <env_setup_vm+0x60>

f0102ec9 <pa2page>:
	if (PGNUM(pa) >= npages)
f0102ec9:	c1 e8 0c             	shr    $0xc,%eax
f0102ecc:	3b 05 60 82 24 f0    	cmp    0xf0248260,%eax
f0102ed2:	73 0a                	jae    f0102ede <pa2page+0x15>
	return &pages[PGNUM(pa)];
f0102ed4:	8b 15 58 82 24 f0    	mov    0xf0248258,%edx
f0102eda:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f0102edd:	c3                   	ret    
{
f0102ede:	55                   	push   %ebp
f0102edf:	89 e5                	mov    %esp,%ebp
f0102ee1:	83 ec 0c             	sub    $0xc,%esp
		panic("pa2page called with invalid pa");
f0102ee4:	68 5c 6d 10 f0       	push   $0xf0106d5c
f0102ee9:	6a 51                	push   $0x51
f0102eeb:	68 f1 74 10 f0       	push   $0xf01074f1
f0102ef0:	e8 75 d1 ff ff       	call   f010006a <_panic>

f0102ef5 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102ef5:	55                   	push   %ebp
f0102ef6:	89 e5                	mov    %esp,%ebp
f0102ef8:	57                   	push   %edi
f0102ef9:	56                   	push   %esi
f0102efa:	53                   	push   %ebx
f0102efb:	83 ec 0c             	sub    $0xc,%esp
f0102efe:	89 c7                	mov    %eax,%edi
	uint32_t va_lo = ROUNDDOWN((uint32_t) va, PGSIZE);
f0102f00:	89 d3                	mov    %edx,%ebx
f0102f02:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t va_hi = ROUNDUP((uint32_t) va + len, PGSIZE);
f0102f08:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f0102f0f:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	if (va_hi > UTOP)
f0102f15:	81 fe 00 00 c0 ee    	cmp    $0xeec00000,%esi
f0102f1b:	77 30                	ja     f0102f4d <region_alloc+0x58>
		panic("region_alloc: cannot map in high va\n");

	struct PageInfo *p;
	for (uint32_t va_act = va_lo; va_act < va_hi; va_act += PGSIZE) {
f0102f1d:	39 f3                	cmp    %esi,%ebx
f0102f1f:	73 71                	jae    f0102f92 <region_alloc+0x9d>
		if (!(p = page_alloc(!ALLOC_ZERO)))
f0102f21:	83 ec 0c             	sub    $0xc,%esp
f0102f24:	6a 00                	push   $0x0
f0102f26:	e8 29 e4 ff ff       	call   f0101354 <page_alloc>
f0102f2b:	83 c4 10             	add    $0x10,%esp
f0102f2e:	85 c0                	test   %eax,%eax
f0102f30:	74 32                	je     f0102f64 <region_alloc+0x6f>
			panic("region_alloc: could not alloc page\n");
		if (page_insert(e->env_pgdir, p, (uint32_t *) va_act, PTE_U | PTE_W))
f0102f32:	6a 06                	push   $0x6
f0102f34:	53                   	push   %ebx
f0102f35:	50                   	push   %eax
f0102f36:	ff 77 6c             	push   0x6c(%edi)
f0102f39:	e8 f9 ea ff ff       	call   f0101a37 <page_insert>
f0102f3e:	83 c4 10             	add    $0x10,%esp
f0102f41:	85 c0                	test   %eax,%eax
f0102f43:	75 36                	jne    f0102f7b <region_alloc+0x86>
	for (uint32_t va_act = va_lo; va_act < va_hi; va_act += PGSIZE) {
f0102f45:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102f4b:	eb d0                	jmp    f0102f1d <region_alloc+0x28>
		panic("region_alloc: cannot map in high va\n");
f0102f4d:	83 ec 04             	sub    $0x4,%esp
f0102f50:	68 cc 77 10 f0       	push   $0xf01077cc
f0102f55:	68 1c 01 00 00       	push   $0x11c
f0102f5a:	68 3a 78 10 f0       	push   $0xf010783a
f0102f5f:	e8 06 d1 ff ff       	call   f010006a <_panic>
			panic("region_alloc: could not alloc page\n");
f0102f64:	83 ec 04             	sub    $0x4,%esp
f0102f67:	68 f4 77 10 f0       	push   $0xf01077f4
f0102f6c:	68 21 01 00 00       	push   $0x121
f0102f71:	68 3a 78 10 f0       	push   $0xf010783a
f0102f76:	e8 ef d0 ff ff       	call   f010006a <_panic>
			panic("region_alloc: page_insert falied\n");
f0102f7b:	83 ec 04             	sub    $0x4,%esp
f0102f7e:	68 18 78 10 f0       	push   $0xf0107818
f0102f83:	68 23 01 00 00       	push   $0x123
f0102f88:	68 3a 78 10 f0       	push   $0xf010783a
f0102f8d:	e8 d8 d0 ff ff       	call   f010006a <_panic>

	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
}
f0102f92:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102f95:	5b                   	pop    %ebx
f0102f96:	5e                   	pop    %esi
f0102f97:	5f                   	pop    %edi
f0102f98:	5d                   	pop    %ebp
f0102f99:	c3                   	ret    

f0102f9a <load_icode>:
// load_icode panics if it encounters problems.
//  - How might load_icode fail?  What might be wrong with the given input?
//
static void
load_icode(struct Env *e, uint8_t *binary)
{
f0102f9a:	55                   	push   %ebp
f0102f9b:	89 e5                	mov    %esp,%ebp
f0102f9d:	57                   	push   %edi
f0102f9e:	56                   	push   %esi
f0102f9f:	53                   	push   %ebx
f0102fa0:	83 ec 24             	sub    $0x24,%esp
f0102fa3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102fa6:	89 d7                	mov    %edx,%edi
	//  You must also do something with the program's entry point,
	//  to make sure that the environment starts executing there.

	// Get elf file header
	struct Elf *elf = (struct Elf *) binary;
	cprintf("%p\n", elf);
f0102fa8:	52                   	push   %edx
f0102fa9:	68 45 78 10 f0       	push   $0xf0107845
f0102fae:	e8 07 08 00 00       	call   f01037ba <cprintf>
	if (elf->e_magic != ELF_MAGIC)
f0102fb3:	83 c4 10             	add    $0x10,%esp
f0102fb6:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0102fbc:	75 2a                	jne    f0102fe8 <load_icode+0x4e>
		panic("load_icode: not an elf file\n");

	lcr3(PADDR(e->env_pgdir));
f0102fbe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102fc1:	8b 48 6c             	mov    0x6c(%eax),%ecx
f0102fc4:	ba 66 01 00 00       	mov    $0x166,%edx
f0102fc9:	b8 3a 78 10 f0       	mov    $0xf010783a,%eax
f0102fce:	e8 66 fe ff ff       	call   f0102e39 <_paddr>
f0102fd3:	e8 06 fe ff ff       	call   f0102dde <lcr3>

	struct Proghdr *ph, *ph_last;

	ph = (struct Proghdr *) ((char *) (binary) + elf->e_phoff);
f0102fd8:	89 fb                	mov    %edi,%ebx
f0102fda:	03 5f 1c             	add    0x1c(%edi),%ebx
	ph_last = ph + elf->e_phnum;
f0102fdd:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f0102fe1:	c1 e6 05             	shl    $0x5,%esi
f0102fe4:	01 de                	add    %ebx,%esi

	for (; ph < ph_last; ph++) {
f0102fe6:	eb 1a                	jmp    f0103002 <load_icode+0x68>
		panic("load_icode: not an elf file\n");
f0102fe8:	83 ec 04             	sub    $0x4,%esp
f0102feb:	68 49 78 10 f0       	push   $0xf0107849
f0102ff0:	68 64 01 00 00       	push   $0x164
f0102ff5:	68 3a 78 10 f0       	push   $0xf010783a
f0102ffa:	e8 6b d0 ff ff       	call   f010006a <_panic>
	for (; ph < ph_last; ph++) {
f0102fff:	83 c3 20             	add    $0x20,%ebx
f0103002:	39 f3                	cmp    %esi,%ebx
f0103004:	73 3c                	jae    f0103042 <load_icode+0xa8>
		if (ph->p_type != ELF_PROG_LOAD)
f0103006:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103009:	75 f4                	jne    f0102fff <load_icode+0x65>
			continue;

		region_alloc(e, (void *) ph->p_va, ph->p_memsz);
f010300b:	8b 4b 14             	mov    0x14(%ebx),%ecx
f010300e:	8b 53 08             	mov    0x8(%ebx),%edx
f0103011:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103014:	e8 dc fe ff ff       	call   f0102ef5 <region_alloc>
		memset((uint32_t *) ph->p_va, 0x0, ph->p_memsz);
f0103019:	83 ec 04             	sub    $0x4,%esp
f010301c:	ff 73 14             	push   0x14(%ebx)
f010301f:	6a 00                	push   $0x0
f0103021:	ff 73 08             	push   0x8(%ebx)
f0103024:	e8 c9 28 00 00       	call   f01058f2 <memset>
		memcpy((uint32_t *) ph->p_va,
f0103029:	83 c4 0c             	add    $0xc,%esp
f010302c:	ff 73 10             	push   0x10(%ebx)
f010302f:	89 f8                	mov    %edi,%eax
f0103031:	03 43 04             	add    0x4(%ebx),%eax
f0103034:	50                   	push   %eax
f0103035:	ff 73 08             	push   0x8(%ebx)
f0103038:	e8 61 29 00 00       	call   f010599e <memcpy>
f010303d:	83 c4 10             	add    $0x10,%esp
f0103040:	eb bd                	jmp    f0102fff <load_icode+0x65>
	}


	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
	region_alloc(e, (void *) (USTACKTOP - PGSIZE), PGSIZE);
f0103042:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103047:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f010304c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010304f:	89 f0                	mov    %esi,%eax
f0103051:	e8 9f fe ff ff       	call   f0102ef5 <region_alloc>

	// Setting entry point
	e->env_tf.tf_eip = elf->e_entry;
f0103056:	8b 47 18             	mov    0x18(%edi),%eax
f0103059:	89 46 30             	mov    %eax,0x30(%esi)

	lcr3(PADDR(kern_pgdir));
f010305c:	8b 0d 5c 82 24 f0    	mov    0xf024825c,%ecx
f0103062:	ba 80 01 00 00       	mov    $0x180,%edx
f0103067:	b8 3a 78 10 f0       	mov    $0xf010783a,%eax
f010306c:	e8 c8 fd ff ff       	call   f0102e39 <_paddr>
f0103071:	e8 68 fd ff ff       	call   f0102dde <lcr3>
}
f0103076:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103079:	5b                   	pop    %ebx
f010307a:	5e                   	pop    %esi
f010307b:	5f                   	pop    %edi
f010307c:	5d                   	pop    %ebp
f010307d:	c3                   	ret    

f010307e <unlock_kernel>:

static inline void
unlock_kernel(void)
{
f010307e:	55                   	push   %ebp
f010307f:	89 e5                	mov    %esp,%ebp
f0103081:	83 ec 14             	sub    $0x14,%esp
	spin_unlock(&kernel_lock);
f0103084:	68 c0 53 12 f0       	push   $0xf01253c0
f0103089:	e8 17 32 00 00       	call   f01062a5 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f010308e:	f3 90                	pause  
}
f0103090:	83 c4 10             	add    $0x10,%esp
f0103093:	c9                   	leave  
f0103094:	c3                   	ret    

f0103095 <envid2env>:
{
f0103095:	55                   	push   %ebp
f0103096:	89 e5                	mov    %esp,%ebp
f0103098:	56                   	push   %esi
f0103099:	53                   	push   %ebx
f010309a:	8b 75 08             	mov    0x8(%ebp),%esi
f010309d:	8b 45 10             	mov    0x10(%ebp),%eax
	if (envid == 0) {
f01030a0:	85 f6                	test   %esi,%esi
f01030a2:	74 31                	je     f01030d5 <envid2env+0x40>
	e = &envs[ENVX(envid)];
f01030a4:	89 f3                	mov    %esi,%ebx
f01030a6:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f01030ac:	69 db 88 00 00 00    	imul   $0x88,%ebx,%ebx
f01030b2:	03 1d 70 82 24 f0    	add    0xf0248270,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f01030b8:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f01030bc:	74 5b                	je     f0103119 <envid2env+0x84>
f01030be:	39 73 48             	cmp    %esi,0x48(%ebx)
f01030c1:	75 62                	jne    f0103125 <envid2env+0x90>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01030c3:	84 c0                	test   %al,%al
f01030c5:	75 20                	jne    f01030e7 <envid2env+0x52>
	return 0;
f01030c7:	b8 00 00 00 00       	mov    $0x0,%eax
		*env_store = curenv;
f01030cc:	8b 55 0c             	mov    0xc(%ebp),%edx
f01030cf:	89 1a                	mov    %ebx,(%edx)
}
f01030d1:	5b                   	pop    %ebx
f01030d2:	5e                   	pop    %esi
f01030d3:	5d                   	pop    %ebp
f01030d4:	c3                   	ret    
		*env_store = curenv;
f01030d5:	e8 8e 2e 00 00       	call   f0105f68 <cpunum>
f01030da:	6b c0 74             	imul   $0x74,%eax,%eax
f01030dd:	8b 98 28 a0 28 f0    	mov    -0xfd75fd8(%eax),%ebx
		return 0;
f01030e3:	89 f0                	mov    %esi,%eax
f01030e5:	eb e5                	jmp    f01030cc <envid2env+0x37>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01030e7:	e8 7c 2e 00 00       	call   f0105f68 <cpunum>
f01030ec:	6b c0 74             	imul   $0x74,%eax,%eax
f01030ef:	39 98 28 a0 28 f0    	cmp    %ebx,-0xfd75fd8(%eax)
f01030f5:	74 d0                	je     f01030c7 <envid2env+0x32>
f01030f7:	8b 73 4c             	mov    0x4c(%ebx),%esi
f01030fa:	e8 69 2e 00 00       	call   f0105f68 <cpunum>
f01030ff:	6b c0 74             	imul   $0x74,%eax,%eax
f0103102:	8b 80 28 a0 28 f0    	mov    -0xfd75fd8(%eax),%eax
f0103108:	3b 70 48             	cmp    0x48(%eax),%esi
f010310b:	74 ba                	je     f01030c7 <envid2env+0x32>
f010310d:	bb 00 00 00 00       	mov    $0x0,%ebx
		return -E_BAD_ENV;
f0103112:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103117:	eb b3                	jmp    f01030cc <envid2env+0x37>
f0103119:	bb 00 00 00 00       	mov    $0x0,%ebx
		return -E_BAD_ENV;
f010311e:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103123:	eb a7                	jmp    f01030cc <envid2env+0x37>
f0103125:	bb 00 00 00 00       	mov    $0x0,%ebx
f010312a:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010312f:	eb 9b                	jmp    f01030cc <envid2env+0x37>

f0103131 <env_init_percpu>:
{
f0103131:	55                   	push   %ebp
f0103132:	89 e5                	mov    %esp,%ebp
f0103134:	83 ec 08             	sub    $0x8,%esp
	lgdt(&gdt_pd);
f0103137:	b8 20 53 12 f0       	mov    $0xf0125320,%eax
f010313c:	e8 95 fc ff ff       	call   f0102dd6 <lgdt>
	asm volatile("movw %%ax,%%gs" : : "a"(GD_UD | 3));
f0103141:	b8 23 00 00 00       	mov    $0x23,%eax
f0103146:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a"(GD_UD | 3));
f0103148:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" : : "a"(GD_KD));
f010314a:	b8 10 00 00 00       	mov    $0x10,%eax
f010314f:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a"(GD_KD));
f0103151:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a"(GD_KD));
f0103153:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i"(GD_KT));
f0103155:	ea 5c 31 10 f0 08 00 	ljmp   $0x8,$0xf010315c
	lldt(0);
f010315c:	b8 00 00 00 00       	mov    $0x0,%eax
f0103161:	e8 74 fc ff ff       	call   f0102dda <lldt>
}
f0103166:	c9                   	leave  
f0103167:	c3                   	ret    

f0103168 <env_init>:
{
f0103168:	55                   	push   %ebp
f0103169:	89 e5                	mov    %esp,%ebp
f010316b:	83 ec 08             	sub    $0x8,%esp
		envs[i].env_id = 0;
f010316e:	8b 15 70 82 24 f0    	mov    0xf0248270,%edx
f0103174:	8d 82 88 00 00 00    	lea    0x88(%edx),%eax
f010317a:	81 c2 88 20 02 00    	add    $0x22088,%edx
f0103180:	c7 40 c0 00 00 00 00 	movl   $0x0,-0x40(%eax)
		envs[i].env_status = ENV_FREE;
f0103187:	c7 40 cc 00 00 00 00 	movl   $0x0,-0x34(%eax)
		envs[i].env_link = (envs + i + 1);
f010318e:	89 40 bc             	mov    %eax,-0x44(%eax)
	for (int i = 0; i < NENV; i++) {
f0103191:	05 88 00 00 00       	add    $0x88,%eax
f0103196:	39 d0                	cmp    %edx,%eax
f0103198:	75 e6                	jne    f0103180 <env_init+0x18>
	envs[NENV - 1].env_link = NULL;
f010319a:	a1 70 82 24 f0       	mov    0xf0248270,%eax
f010319f:	c7 80 bc 1f 02 00 00 	movl   $0x0,0x21fbc(%eax)
f01031a6:	00 00 00 
	env_free_list = envs;
f01031a9:	a3 74 82 24 f0       	mov    %eax,0xf0248274
	env_init_percpu();
f01031ae:	e8 7e ff ff ff       	call   f0103131 <env_init_percpu>
}
f01031b3:	c9                   	leave  
f01031b4:	c3                   	ret    

f01031b5 <env_alloc>:
{
f01031b5:	55                   	push   %ebp
f01031b6:	89 e5                	mov    %esp,%ebp
f01031b8:	53                   	push   %ebx
f01031b9:	83 ec 04             	sub    $0x4,%esp
	if (!(e = env_free_list))
f01031bc:	8b 1d 74 82 24 f0    	mov    0xf0248274,%ebx
f01031c2:	85 db                	test   %ebx,%ebx
f01031c4:	0f 84 f0 00 00 00    	je     f01032ba <env_alloc+0x105>
	if ((r = env_setup_vm(e)) < 0)
f01031ca:	89 d8                	mov    %ebx,%eax
f01031cc:	e8 8a fc ff ff       	call   f0102e5b <env_setup_vm>
f01031d1:	85 c0                	test   %eax,%eax
f01031d3:	0f 88 dc 00 00 00    	js     f01032b5 <env_alloc+0x100>
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01031d9:	8b 43 48             	mov    0x48(%ebx),%eax
f01031dc:	05 00 10 00 00       	add    $0x1000,%eax
		generation = 1 << ENVGENSHIFT;
f01031e1:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f01031e6:	ba 00 10 00 00       	mov    $0x1000,%edx
f01031eb:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f01031ee:	89 da                	mov    %ebx,%edx
f01031f0:	2b 15 70 82 24 f0    	sub    0xf0248270,%edx
f01031f6:	c1 fa 03             	sar    $0x3,%edx
f01031f9:	69 d2 f1 f0 f0 f0    	imul   $0xf0f0f0f1,%edx,%edx
f01031ff:	09 d0                	or     %edx,%eax
f0103201:	89 43 48             	mov    %eax,0x48(%ebx)
	e->env_parent_id = parent_id;
f0103204:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103207:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f010320a:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103211:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103218:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
	e->priority = MAX_TICKETS;
f010321f:	c7 43 60 64 00 00 00 	movl   $0x64,0x60(%ebx)
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103226:	83 ec 04             	sub    $0x4,%esp
f0103229:	6a 44                	push   $0x44
f010322b:	6a 00                	push   $0x0
f010322d:	53                   	push   %ebx
f010322e:	e8 bf 26 00 00       	call   f01058f2 <memset>
	e->env_tf.tf_ds = GD_UD | 3;
f0103233:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103239:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f010323f:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103245:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f010324c:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	e->env_tf.tf_eflags |= FL_IF;
f0103252:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	e->env_pgfault_upcall = 0;
f0103259:	c7 43 70 00 00 00 00 	movl   $0x0,0x70(%ebx)
	e->env_ipc_recving = 0;
f0103260:	c6 43 74 00          	movb   $0x0,0x74(%ebx)
	env_free_list = e->env_link;
f0103264:	8b 43 44             	mov    0x44(%ebx),%eax
f0103267:	a3 74 82 24 f0       	mov    %eax,0xf0248274
	*newenv_store = e;
f010326c:	8b 45 08             	mov    0x8(%ebp),%eax
f010326f:	89 18                	mov    %ebx,(%eax)
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103271:	8b 5b 48             	mov    0x48(%ebx),%ebx
f0103274:	e8 ef 2c 00 00       	call   f0105f68 <cpunum>
f0103279:	6b c0 74             	imul   $0x74,%eax,%eax
f010327c:	83 c4 10             	add    $0x10,%esp
f010327f:	ba 00 00 00 00       	mov    $0x0,%edx
f0103284:	83 b8 28 a0 28 f0 00 	cmpl   $0x0,-0xfd75fd8(%eax)
f010328b:	74 11                	je     f010329e <env_alloc+0xe9>
f010328d:	e8 d6 2c 00 00       	call   f0105f68 <cpunum>
f0103292:	6b c0 74             	imul   $0x74,%eax,%eax
f0103295:	8b 80 28 a0 28 f0    	mov    -0xfd75fd8(%eax),%eax
f010329b:	8b 50 48             	mov    0x48(%eax),%edx
f010329e:	83 ec 04             	sub    $0x4,%esp
f01032a1:	53                   	push   %ebx
f01032a2:	52                   	push   %edx
f01032a3:	68 66 78 10 f0       	push   $0xf0107866
f01032a8:	e8 0d 05 00 00       	call   f01037ba <cprintf>
	return 0;
f01032ad:	83 c4 10             	add    $0x10,%esp
f01032b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01032b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01032b8:	c9                   	leave  
f01032b9:	c3                   	ret    
		return -E_NO_FREE_ENV;
f01032ba:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01032bf:	eb f4                	jmp    f01032b5 <env_alloc+0x100>

f01032c1 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f01032c1:	55                   	push   %ebp
f01032c2:	89 e5                	mov    %esp,%ebp
f01032c4:	83 ec 20             	sub    $0x20,%esp
	struct Env *env;
	int err = env_alloc(&env, 0x0);
f01032c7:	6a 00                	push   $0x0
f01032c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01032cc:	50                   	push   %eax
f01032cd:	e8 e3 fe ff ff       	call   f01031b5 <env_alloc>
	if (err < 0)
f01032d2:	83 c4 10             	add    $0x10,%esp
f01032d5:	85 c0                	test   %eax,%eax
f01032d7:	78 16                	js     f01032ef <env_create+0x2e>
		panic("env_create: %e\n", err);

	load_icode(env, binary);
f01032d9:	8b 55 08             	mov    0x8(%ebp),%edx
f01032dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01032df:	e8 b6 fc ff ff       	call   f0102f9a <load_icode>
	env->env_type = type;
f01032e4:	8b 55 0c             	mov    0xc(%ebp),%edx
f01032e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01032ea:	89 50 50             	mov    %edx,0x50(%eax)
}
f01032ed:	c9                   	leave  
f01032ee:	c3                   	ret    
		panic("env_create: %e\n", err);
f01032ef:	50                   	push   %eax
f01032f0:	68 7b 78 10 f0       	push   $0xf010787b
f01032f5:	68 90 01 00 00       	push   $0x190
f01032fa:	68 3a 78 10 f0       	push   $0xf010783a
f01032ff:	e8 66 cd ff ff       	call   f010006a <_panic>

f0103304 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103304:	55                   	push   %ebp
f0103305:	89 e5                	mov    %esp,%ebp
f0103307:	57                   	push   %edi
f0103308:	56                   	push   %esi
f0103309:	53                   	push   %ebx
f010330a:	83 ec 1c             	sub    $0x1c,%esp
f010330d:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103310:	e8 53 2c 00 00       	call   f0105f68 <cpunum>
f0103315:	6b c0 74             	imul   $0x74,%eax,%eax
f0103318:	39 b8 28 a0 28 f0    	cmp    %edi,-0xfd75fd8(%eax)
f010331e:	74 45                	je     f0103365 <env_free+0x61>
		lcr3(PADDR(kern_pgdir));

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103320:	8b 5f 48             	mov    0x48(%edi),%ebx
f0103323:	e8 40 2c 00 00       	call   f0105f68 <cpunum>
f0103328:	6b c0 74             	imul   $0x74,%eax,%eax
f010332b:	ba 00 00 00 00       	mov    $0x0,%edx
f0103330:	83 b8 28 a0 28 f0 00 	cmpl   $0x0,-0xfd75fd8(%eax)
f0103337:	74 11                	je     f010334a <env_free+0x46>
f0103339:	e8 2a 2c 00 00       	call   f0105f68 <cpunum>
f010333e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103341:	8b 80 28 a0 28 f0    	mov    -0xfd75fd8(%eax),%eax
f0103347:	8b 50 48             	mov    0x48(%eax),%edx
f010334a:	83 ec 04             	sub    $0x4,%esp
f010334d:	53                   	push   %ebx
f010334e:	52                   	push   %edx
f010334f:	68 8b 78 10 f0       	push   $0xf010788b
f0103354:	e8 61 04 00 00       	call   f01037ba <cprintf>
f0103359:	83 c4 10             	add    $0x10,%esp
f010335c:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103363:	eb 75                	jmp    f01033da <env_free+0xd6>
		lcr3(PADDR(kern_pgdir));
f0103365:	8b 0d 5c 82 24 f0    	mov    0xf024825c,%ecx
f010336b:	ba a4 01 00 00       	mov    $0x1a4,%edx
f0103370:	b8 3a 78 10 f0       	mov    $0xf010783a,%eax
f0103375:	e8 bf fa ff ff       	call   f0102e39 <_paddr>
f010337a:	e8 5f fa ff ff       	call   f0102dde <lcr3>
f010337f:	eb 9f                	jmp    f0103320 <env_free+0x1c>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t *) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103381:	83 c3 01             	add    $0x1,%ebx
f0103384:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f010338a:	74 1f                	je     f01033ab <env_free+0xa7>
			if (pt[pteno] & PTE_P)
f010338c:	f6 04 9e 01          	testb  $0x1,(%esi,%ebx,4)
f0103390:	74 ef                	je     f0103381 <env_free+0x7d>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103392:	83 ec 08             	sub    $0x8,%esp
f0103395:	89 d8                	mov    %ebx,%eax
f0103397:	c1 e0 0c             	shl    $0xc,%eax
f010339a:	0b 45 e4             	or     -0x1c(%ebp),%eax
f010339d:	50                   	push   %eax
f010339e:	ff 77 6c             	push   0x6c(%edi)
f01033a1:	e8 7a e5 ff ff       	call   f0101920 <page_remove>
f01033a6:	83 c4 10             	add    $0x10,%esp
f01033a9:	eb d6                	jmp    f0103381 <env_free+0x7d>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01033ab:	8b 47 6c             	mov    0x6c(%edi),%eax
f01033ae:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01033b1:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
		page_decref(pa2page(pa));
f01033b8:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01033bb:	e8 09 fb ff ff       	call   f0102ec9 <pa2page>
f01033c0:	83 ec 0c             	sub    $0xc,%esp
f01033c3:	50                   	push   %eax
f01033c4:	e8 42 e4 ff ff       	call   f010180b <page_decref>
f01033c9:	83 c4 10             	add    $0x10,%esp
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01033cc:	83 45 e0 04          	addl   $0x4,-0x20(%ebp)
f01033d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01033d3:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f01033d8:	74 3b                	je     f0103415 <env_free+0x111>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01033da:	8b 47 6c             	mov    0x6c(%edi),%eax
f01033dd:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01033e0:	8b 04 08             	mov    (%eax,%ecx,1),%eax
f01033e3:	a8 01                	test   $0x1,%al
f01033e5:	74 e5                	je     f01033cc <env_free+0xc8>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01033e7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01033ec:	89 45 dc             	mov    %eax,-0x24(%ebp)
		pt = (pte_t *) KADDR(pa);
f01033ef:	89 c1                	mov    %eax,%ecx
f01033f1:	ba b2 01 00 00       	mov    $0x1b2,%edx
f01033f6:	b8 3a 78 10 f0       	mov    $0xf010783a,%eax
f01033fb:	e8 ef f9 ff ff       	call   f0102def <_kaddr>
f0103400:	89 c6                	mov    %eax,%esi
f0103402:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103405:	c1 e0 14             	shl    $0x14,%eax
f0103408:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010340b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103410:	e9 77 ff ff ff       	jmp    f010338c <env_free+0x88>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103415:	8b 4f 6c             	mov    0x6c(%edi),%ecx
f0103418:	ba c0 01 00 00       	mov    $0x1c0,%edx
f010341d:	b8 3a 78 10 f0       	mov    $0xf010783a,%eax
f0103422:	e8 12 fa ff ff       	call   f0102e39 <_paddr>
	e->env_pgdir = 0;
f0103427:	c7 47 6c 00 00 00 00 	movl   $0x0,0x6c(%edi)
	page_decref(pa2page(pa));
f010342e:	e8 96 fa ff ff       	call   f0102ec9 <pa2page>
f0103433:	83 ec 0c             	sub    $0xc,%esp
f0103436:	50                   	push   %eax
f0103437:	e8 cf e3 ff ff       	call   f010180b <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f010343c:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103443:	a1 74 82 24 f0       	mov    0xf0248274,%eax
f0103448:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f010344b:	89 3d 74 82 24 f0    	mov    %edi,0xf0248274
}
f0103451:	83 c4 10             	add    $0x10,%esp
f0103454:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103457:	5b                   	pop    %ebx
f0103458:	5e                   	pop    %esi
f0103459:	5f                   	pop    %edi
f010345a:	5d                   	pop    %ebp
f010345b:	c3                   	ret    

f010345c <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f010345c:	55                   	push   %ebp
f010345d:	89 e5                	mov    %esp,%ebp
f010345f:	53                   	push   %ebx
f0103460:	83 ec 04             	sub    $0x4,%esp
f0103463:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103466:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f010346a:	74 21                	je     f010348d <env_destroy+0x31>
		e->env_status = ENV_DYING;
		return;
	}

	env_free(e);
f010346c:	83 ec 0c             	sub    $0xc,%esp
f010346f:	53                   	push   %ebx
f0103470:	e8 8f fe ff ff       	call   f0103304 <env_free>

	if (curenv == e) {
f0103475:	e8 ee 2a 00 00       	call   f0105f68 <cpunum>
f010347a:	6b c0 74             	imul   $0x74,%eax,%eax
f010347d:	83 c4 10             	add    $0x10,%esp
f0103480:	39 98 28 a0 28 f0    	cmp    %ebx,-0xfd75fd8(%eax)
f0103486:	74 1e                	je     f01034a6 <env_destroy+0x4a>
		// cprintf("[%08x] env_destroy %08x\n", curenv ? curenv->env_id : 0, e->env_id);
		curenv = NULL;
		// cprintf("[%08x] env_destroy %08x\n", curenv ? curenv->env_id : 0, e->env_id);
		sched_yield();
	}
}
f0103488:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010348b:	c9                   	leave  
f010348c:	c3                   	ret    
	if (e->env_status == ENV_RUNNING && curenv != e) {
f010348d:	e8 d6 2a 00 00       	call   f0105f68 <cpunum>
f0103492:	6b c0 74             	imul   $0x74,%eax,%eax
f0103495:	39 98 28 a0 28 f0    	cmp    %ebx,-0xfd75fd8(%eax)
f010349b:	74 cf                	je     f010346c <env_destroy+0x10>
		e->env_status = ENV_DYING;
f010349d:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f01034a4:	eb e2                	jmp    f0103488 <env_destroy+0x2c>
		curenv = NULL;
f01034a6:	e8 bd 2a 00 00       	call   f0105f68 <cpunum>
f01034ab:	6b c0 74             	imul   $0x74,%eax,%eax
f01034ae:	c7 80 28 a0 28 f0 00 	movl   $0x0,-0xfd75fd8(%eax)
f01034b5:	00 00 00 
		sched_yield();
f01034b8:	e8 71 10 00 00       	call   f010452e <sched_yield>

f01034bd <env_load_pgdir>:
//
// Loads environment page directory as a preparation for context_switch.
//
void
env_load_pgdir(struct Env *e)
{
f01034bd:	55                   	push   %ebp
f01034be:	89 e5                	mov    %esp,%ebp
f01034c0:	83 ec 08             	sub    $0x8,%esp
	lcr3(PADDR(e->env_pgdir));
f01034c3:	8b 45 08             	mov    0x8(%ebp),%eax
f01034c6:	8b 48 6c             	mov    0x6c(%eax),%ecx
f01034c9:	ba ea 01 00 00       	mov    $0x1ea,%edx
f01034ce:	b8 3a 78 10 f0       	mov    $0xf010783a,%eax
f01034d3:	e8 61 f9 ff ff       	call   f0102e39 <_paddr>
f01034d8:	e8 01 f9 ff ff       	call   f0102dde <lcr3>
}
f01034dd:	c9                   	leave  
f01034de:	c3                   	ret    

f01034df <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f01034df:	55                   	push   %ebp
f01034e0:	89 e5                	mov    %esp,%ebp
f01034e2:	56                   	push   %esi
f01034e3:	53                   	push   %ebx
f01034e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// Hint: This function loads the new environment's state from
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	if (curenv && curenv->env_status == ENV_RUNNING) {
f01034e7:	e8 7c 2a 00 00       	call   f0105f68 <cpunum>
f01034ec:	6b c0 74             	imul   $0x74,%eax,%eax
f01034ef:	83 b8 28 a0 28 f0 00 	cmpl   $0x0,-0xfd75fd8(%eax)
f01034f6:	74 14                	je     f010350c <env_run+0x2d>
f01034f8:	e8 6b 2a 00 00       	call   f0105f68 <cpunum>
f01034fd:	6b c0 74             	imul   $0x74,%eax,%eax
f0103500:	8b 80 28 a0 28 f0    	mov    -0xfd75fd8(%eax),%eax
f0103506:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010350a:	74 6e                	je     f010357a <env_run+0x9b>
		curenv->env_status = ENV_RUNNABLE;
	}
	curenv = e;
f010350c:	e8 57 2a 00 00       	call   f0105f68 <cpunum>
f0103511:	6b c0 74             	imul   $0x74,%eax,%eax
f0103514:	89 98 28 a0 28 f0    	mov    %ebx,-0xfd75fd8(%eax)
	curenv->env_status = ENV_RUNNING;
f010351a:	e8 49 2a 00 00       	call   f0105f68 <cpunum>
f010351f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103522:	8b 80 28 a0 28 f0    	mov    -0xfd75fd8(%eax),%eax
f0103528:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;
f010352f:	e8 34 2a 00 00       	call   f0105f68 <cpunum>
f0103534:	6b c0 74             	imul   $0x74,%eax,%eax
f0103537:	8b 80 28 a0 28 f0    	mov    -0xfd75fd8(%eax),%eax
f010353d:	83 40 58 01          	addl   $0x1,0x58(%eax)

	env_load_pgdir(curenv);
f0103541:	e8 22 2a 00 00       	call   f0105f68 <cpunum>
f0103546:	83 ec 0c             	sub    $0xc,%esp
f0103549:	6b c0 74             	imul   $0x74,%eax,%eax
f010354c:	ff b0 28 a0 28 f0    	push   -0xfd75fd8(%eax)
f0103552:	e8 66 ff ff ff       	call   f01034bd <env_load_pgdir>

	// Needed if we run with multiple procesors
	// Record the CPU we are running on for user-space debugging
	unlock_kernel();
f0103557:	e8 22 fb ff ff       	call   f010307e <unlock_kernel>
	curenv->env_cpunum = cpunum();
f010355c:	e8 07 2a 00 00       	call   f0105f68 <cpunum>
f0103561:	6b c0 74             	imul   $0x74,%eax,%eax
f0103564:	8b b0 28 a0 28 f0    	mov    -0xfd75fd8(%eax),%esi
f010356a:	e8 f9 29 00 00       	call   f0105f68 <cpunum>
f010356f:	89 46 5c             	mov    %eax,0x5c(%esi)

	// Step 2: Use context_switch() to restore the environment's
	//	   registers and drop into user mode in the
	//	   environment.
	context_switch(&e->env_tf);
f0103572:	89 1c 24             	mov    %ebx,(%esp)
f0103575:	e8 69 0d 00 00       	call   f01042e3 <context_switch>
		curenv->env_status = ENV_RUNNABLE;
f010357a:	e8 e9 29 00 00       	call   f0105f68 <cpunum>
f010357f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103582:	8b 80 28 a0 28 f0    	mov    -0xfd75fd8(%eax),%eax
f0103588:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
f010358f:	e9 78 ff ff ff       	jmp    f010350c <env_run+0x2d>

f0103594 <inb>:
	asm volatile("inb %w1,%0" : "=a"(data) : "d"(port));
f0103594:	89 c2                	mov    %eax,%edx
f0103596:	ec                   	in     (%dx),%al
}
f0103597:	c3                   	ret    

f0103598 <outb>:
{
f0103598:	89 c1                	mov    %eax,%ecx
f010359a:	89 d0                	mov    %edx,%eax
	asm volatile("outb %0,%w1" : : "a"(data), "d"(port));
f010359c:	89 ca                	mov    %ecx,%edx
f010359e:	ee                   	out    %al,(%dx)
}
f010359f:	c3                   	ret    

f01035a0 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01035a0:	55                   	push   %ebp
f01035a1:	89 e5                	mov    %esp,%ebp
f01035a3:	83 ec 08             	sub    $0x8,%esp
	outb(IO_RTC, reg);
f01035a6:	0f b6 55 08          	movzbl 0x8(%ebp),%edx
f01035aa:	b8 70 00 00 00       	mov    $0x70,%eax
f01035af:	e8 e4 ff ff ff       	call   f0103598 <outb>
	return inb(IO_RTC + 1);
f01035b4:	b8 71 00 00 00       	mov    $0x71,%eax
f01035b9:	e8 d6 ff ff ff       	call   f0103594 <inb>
f01035be:	0f b6 c0             	movzbl %al,%eax
}
f01035c1:	c9                   	leave  
f01035c2:	c3                   	ret    

f01035c3 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01035c3:	55                   	push   %ebp
f01035c4:	89 e5                	mov    %esp,%ebp
f01035c6:	83 ec 08             	sub    $0x8,%esp
	outb(IO_RTC, reg);
f01035c9:	0f b6 55 08          	movzbl 0x8(%ebp),%edx
f01035cd:	b8 70 00 00 00       	mov    $0x70,%eax
f01035d2:	e8 c1 ff ff ff       	call   f0103598 <outb>
	outb(IO_RTC + 1, datum);
f01035d7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
f01035db:	b8 71 00 00 00       	mov    $0x71,%eax
f01035e0:	e8 b3 ff ff ff       	call   f0103598 <outb>
}
f01035e5:	c9                   	leave  
f01035e6:	c3                   	ret    

f01035e7 <outb>:
{
f01035e7:	89 c1                	mov    %eax,%ecx
f01035e9:	89 d0                	mov    %edx,%eax
	asm volatile("outb %0,%w1" : : "a"(data), "d"(port));
f01035eb:	89 ca                	mov    %ecx,%edx
f01035ed:	ee                   	out    %al,(%dx)
}
f01035ee:	c3                   	ret    

f01035ef <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f01035ef:	55                   	push   %ebp
f01035f0:	89 e5                	mov    %esp,%ebp
f01035f2:	56                   	push   %esi
f01035f3:	53                   	push   %ebx
f01035f4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	irq_mask_8259A = mask;
f01035f7:	66 89 1d a8 53 12 f0 	mov    %bx,0xf01253a8
	if (!didinit)
f01035fe:	80 3d 78 82 24 f0 00 	cmpb   $0x0,0xf0248278
f0103605:	75 07                	jne    f010360e <irq_setmask_8259A+0x1f>
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
		if (~mask & (1 << i))
			cprintf(" %d", i);
	cprintf("\n");
}
f0103607:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010360a:	5b                   	pop    %ebx
f010360b:	5e                   	pop    %esi
f010360c:	5d                   	pop    %ebp
f010360d:	c3                   	ret    
f010360e:	89 de                	mov    %ebx,%esi
	outb(IO_PIC1 + 1, (char) mask);
f0103610:	0f b6 d3             	movzbl %bl,%edx
f0103613:	b8 21 00 00 00       	mov    $0x21,%eax
f0103618:	e8 ca ff ff ff       	call   f01035e7 <outb>
	outb(IO_PIC2 + 1, (char) (mask >> 8));
f010361d:	0f b6 d7             	movzbl %bh,%edx
f0103620:	b8 a1 00 00 00       	mov    $0xa1,%eax
f0103625:	e8 bd ff ff ff       	call   f01035e7 <outb>
	cprintf("enabled interrupts:");
f010362a:	83 ec 0c             	sub    $0xc,%esp
f010362d:	68 a1 78 10 f0       	push   $0xf01078a1
f0103632:	e8 83 01 00 00       	call   f01037ba <cprintf>
f0103637:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f010363a:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1 << i))
f010363f:	0f b7 f6             	movzwl %si,%esi
f0103642:	f7 d6                	not    %esi
f0103644:	eb 08                	jmp    f010364e <irq_setmask_8259A+0x5f>
	for (i = 0; i < 16; i++)
f0103646:	83 c3 01             	add    $0x1,%ebx
f0103649:	83 fb 10             	cmp    $0x10,%ebx
f010364c:	74 18                	je     f0103666 <irq_setmask_8259A+0x77>
		if (~mask & (1 << i))
f010364e:	0f a3 de             	bt     %ebx,%esi
f0103651:	73 f3                	jae    f0103646 <irq_setmask_8259A+0x57>
			cprintf(" %d", i);
f0103653:	83 ec 08             	sub    $0x8,%esp
f0103656:	53                   	push   %ebx
f0103657:	68 43 7e 10 f0       	push   $0xf0107e43
f010365c:	e8 59 01 00 00       	call   f01037ba <cprintf>
f0103661:	83 c4 10             	add    $0x10,%esp
f0103664:	eb e0                	jmp    f0103646 <irq_setmask_8259A+0x57>
	cprintf("\n");
f0103666:	83 ec 0c             	sub    $0xc,%esp
f0103669:	68 c8 77 10 f0       	push   $0xf01077c8
f010366e:	e8 47 01 00 00       	call   f01037ba <cprintf>
f0103673:	83 c4 10             	add    $0x10,%esp
f0103676:	eb 8f                	jmp    f0103607 <irq_setmask_8259A+0x18>

f0103678 <pic_init>:
{
f0103678:	55                   	push   %ebp
f0103679:	89 e5                	mov    %esp,%ebp
f010367b:	83 ec 08             	sub    $0x8,%esp
	didinit = 1;
f010367e:	c6 05 78 82 24 f0 01 	movb   $0x1,0xf0248278
	outb(IO_PIC1 + 1, 0xFF);
f0103685:	ba ff 00 00 00       	mov    $0xff,%edx
f010368a:	b8 21 00 00 00       	mov    $0x21,%eax
f010368f:	e8 53 ff ff ff       	call   f01035e7 <outb>
	outb(IO_PIC2 + 1, 0xFF);
f0103694:	ba ff 00 00 00       	mov    $0xff,%edx
f0103699:	b8 a1 00 00 00       	mov    $0xa1,%eax
f010369e:	e8 44 ff ff ff       	call   f01035e7 <outb>
	outb(IO_PIC1, 0x11);
f01036a3:	ba 11 00 00 00       	mov    $0x11,%edx
f01036a8:	b8 20 00 00 00       	mov    $0x20,%eax
f01036ad:	e8 35 ff ff ff       	call   f01035e7 <outb>
	outb(IO_PIC1 + 1, IRQ_OFFSET);
f01036b2:	ba 20 00 00 00       	mov    $0x20,%edx
f01036b7:	b8 21 00 00 00       	mov    $0x21,%eax
f01036bc:	e8 26 ff ff ff       	call   f01035e7 <outb>
	outb(IO_PIC1 + 1, 1 << IRQ_SLAVE);
f01036c1:	ba 04 00 00 00       	mov    $0x4,%edx
f01036c6:	b8 21 00 00 00       	mov    $0x21,%eax
f01036cb:	e8 17 ff ff ff       	call   f01035e7 <outb>
	outb(IO_PIC1 + 1, 0x3);
f01036d0:	ba 03 00 00 00       	mov    $0x3,%edx
f01036d5:	b8 21 00 00 00       	mov    $0x21,%eax
f01036da:	e8 08 ff ff ff       	call   f01035e7 <outb>
	outb(IO_PIC2, 0x11);                // ICW1
f01036df:	ba 11 00 00 00       	mov    $0x11,%edx
f01036e4:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01036e9:	e8 f9 fe ff ff       	call   f01035e7 <outb>
	outb(IO_PIC2 + 1, IRQ_OFFSET + 8);  // ICW2
f01036ee:	ba 28 00 00 00       	mov    $0x28,%edx
f01036f3:	b8 a1 00 00 00       	mov    $0xa1,%eax
f01036f8:	e8 ea fe ff ff       	call   f01035e7 <outb>
	outb(IO_PIC2 + 1, IRQ_SLAVE);       // ICW3
f01036fd:	ba 02 00 00 00       	mov    $0x2,%edx
f0103702:	b8 a1 00 00 00       	mov    $0xa1,%eax
f0103707:	e8 db fe ff ff       	call   f01035e7 <outb>
	outb(IO_PIC2 + 1, 0x01);  // ICW4
f010370c:	ba 01 00 00 00       	mov    $0x1,%edx
f0103711:	b8 a1 00 00 00       	mov    $0xa1,%eax
f0103716:	e8 cc fe ff ff       	call   f01035e7 <outb>
	outb(IO_PIC1, 0x68); /* clear specific mask */
f010371b:	ba 68 00 00 00       	mov    $0x68,%edx
f0103720:	b8 20 00 00 00       	mov    $0x20,%eax
f0103725:	e8 bd fe ff ff       	call   f01035e7 <outb>
	outb(IO_PIC1, 0x0a); /* read IRR by default */
f010372a:	ba 0a 00 00 00       	mov    $0xa,%edx
f010372f:	b8 20 00 00 00       	mov    $0x20,%eax
f0103734:	e8 ae fe ff ff       	call   f01035e7 <outb>
	outb(IO_PIC2, 0x68); /* OCW3 */
f0103739:	ba 68 00 00 00       	mov    $0x68,%edx
f010373e:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0103743:	e8 9f fe ff ff       	call   f01035e7 <outb>
	outb(IO_PIC2, 0x0a); /* OCW3 */
f0103748:	ba 0a 00 00 00       	mov    $0xa,%edx
f010374d:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0103752:	e8 90 fe ff ff       	call   f01035e7 <outb>
	if (irq_mask_8259A != 0xFFFF)
f0103757:	0f b7 05 a8 53 12 f0 	movzwl 0xf01253a8,%eax
f010375e:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103762:	75 02                	jne    f0103766 <pic_init+0xee>
}
f0103764:	c9                   	leave  
f0103765:	c3                   	ret    
		irq_setmask_8259A(irq_mask_8259A);
f0103766:	83 ec 0c             	sub    $0xc,%esp
f0103769:	0f b7 c0             	movzwl %ax,%eax
f010376c:	50                   	push   %eax
f010376d:	e8 7d fe ff ff       	call   f01035ef <irq_setmask_8259A>
f0103772:	83 c4 10             	add    $0x10,%esp
}
f0103775:	eb ed                	jmp    f0103764 <pic_init+0xec>

f0103777 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103777:	55                   	push   %ebp
f0103778:	89 e5                	mov    %esp,%ebp
f010377a:	53                   	push   %ebx
f010377b:	83 ec 10             	sub    $0x10,%esp
f010377e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	cputchar(ch);
f0103781:	ff 75 08             	push   0x8(%ebp)
f0103784:	e8 52 d1 ff ff       	call   f01008db <cputchar>
	(*cnt)++;
f0103789:	83 03 01             	addl   $0x1,(%ebx)
}
f010378c:	83 c4 10             	add    $0x10,%esp
f010378f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103792:	c9                   	leave  
f0103793:	c3                   	ret    

f0103794 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103794:	55                   	push   %ebp
f0103795:	89 e5                	mov    %esp,%ebp
f0103797:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f010379a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void *) putch, &cnt, fmt, ap);
f01037a1:	ff 75 0c             	push   0xc(%ebp)
f01037a4:	ff 75 08             	push   0x8(%ebp)
f01037a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01037aa:	50                   	push   %eax
f01037ab:	68 77 37 10 f0       	push   $0xf0103777
f01037b0:	e8 29 1b 00 00       	call   f01052de <vprintfmt>
	return cnt;
}
f01037b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01037b8:	c9                   	leave  
f01037b9:	c3                   	ret    

f01037ba <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01037ba:	55                   	push   %ebp
f01037bb:	89 e5                	mov    %esp,%ebp
f01037bd:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01037c0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01037c3:	50                   	push   %eax
f01037c4:	ff 75 08             	push   0x8(%ebp)
f01037c7:	e8 c8 ff ff ff       	call   f0103794 <vcprintf>
	va_end(ap);

	return cnt;
}
f01037cc:	c9                   	leave  
f01037cd:	c3                   	ret    

f01037ce <lidt>:
	asm volatile("lidt (%0)" : : "r"(p));
f01037ce:	0f 01 18             	lidtl  (%eax)
}
f01037d1:	c3                   	ret    

f01037d2 <ltr>:
	asm volatile("ltr %0" : : "r"(sel));
f01037d2:	0f 00 d8             	ltr    %ax
}
f01037d5:	c3                   	ret    

f01037d6 <rcr2>:
	asm volatile("movl %%cr2,%0" : "=r"(val));
f01037d6:	0f 20 d0             	mov    %cr2,%eax
}
f01037d9:	c3                   	ret    

f01037da <read_eflags>:
	asm volatile("pushfl; popl %0" : "=r"(eflags));
f01037da:	9c                   	pushf  
f01037db:	58                   	pop    %eax
}
f01037dc:	c3                   	ret    

f01037dd <xchg>:
{
f01037dd:	89 c1                	mov    %eax,%ecx
f01037df:	89 d0                	mov    %edx,%eax
	asm volatile("lock; xchgl %0, %1"
f01037e1:	f0 87 01             	lock xchg %eax,(%ecx)
}
f01037e4:	c3                   	ret    

f01037e5 <trapname>:
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < ARRAY_SIZE(excnames))
f01037e5:	83 f8 13             	cmp    $0x13,%eax
f01037e8:	76 20                	jbe    f010380a <trapname+0x25>
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f01037ea:	ba b5 78 10 f0       	mov    $0xf01078b5,%edx
	if (trapno == T_SYSCALL)
f01037ef:	83 f8 30             	cmp    $0x30,%eax
f01037f2:	74 13                	je     f0103807 <trapname+0x22>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f01037f4:	83 e8 20             	sub    $0x20,%eax
		return "Hardware Interrupt";
f01037f7:	83 f8 0f             	cmp    $0xf,%eax
f01037fa:	ba d4 78 10 f0       	mov    $0xf01078d4,%edx
f01037ff:	b8 c1 78 10 f0       	mov    $0xf01078c1,%eax
f0103804:	0f 46 d0             	cmovbe %eax,%edx
	return "(unknown trap)";
}
f0103807:	89 d0                	mov    %edx,%eax
f0103809:	c3                   	ret    
		return excnames[trapno];
f010380a:	8b 14 85 80 7c 10 f0 	mov    -0xfef8380(,%eax,4),%edx
f0103811:	eb f4                	jmp    f0103807 <trapname+0x22>

f0103813 <lock_kernel>:
{
f0103813:	55                   	push   %ebp
f0103814:	89 e5                	mov    %esp,%ebp
f0103816:	83 ec 14             	sub    $0x14,%esp
	spin_lock(&kernel_lock);
f0103819:	68 c0 53 12 f0       	push   $0xf01253c0
f010381e:	e8 19 2a 00 00       	call   f010623c <spin_lock>
}
f0103823:	83 c4 10             	add    $0x10,%esp
f0103826:	c9                   	leave  
f0103827:	c3                   	ret    

f0103828 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103828:	55                   	push   %ebp
f0103829:	89 e5                	mov    %esp,%ebp
f010382b:	57                   	push   %edi
f010382c:	56                   	push   %esi
f010382d:	53                   	push   %ebx
f010382e:	83 ec 0c             	sub    $0xc,%esp
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	struct Taskstate *thists = &(thiscpu->cpu_ts);
f0103831:	e8 32 27 00 00       	call   f0105f68 <cpunum>
f0103836:	6b f0 74             	imul   $0x74,%eax,%esi
f0103839:	8d 9e 2c a0 28 f0    	lea    -0xfd75fd4(%esi),%ebx
	uint8_t thisid = thiscpu->cpu_id;
f010383f:	e8 24 27 00 00       	call   f0105f68 <cpunum>
f0103844:	6b c0 74             	imul   $0x74,%eax,%eax
f0103847:	0f b6 90 20 a0 28 f0 	movzbl -0xfd75fe0(%eax),%edx

	thists->ts_esp0 = KSTACKTOP - thisid * (KSTKGAP + KSTKSIZE);
f010384e:	0f b6 c2             	movzbl %dl,%eax
f0103851:	89 c7                	mov    %eax,%edi
f0103853:	c1 e7 10             	shl    $0x10,%edi
f0103856:	b9 00 00 00 f0       	mov    $0xf0000000,%ecx
f010385b:	29 f9                	sub    %edi,%ecx
f010385d:	89 8e 30 a0 28 f0    	mov    %ecx,-0xfd75fd0(%esi)
	thists->ts_ss0 = GD_KD;
f0103863:	66 c7 86 34 a0 28 f0 	movw   $0x10,-0xfd75fcc(%esi)
f010386a:	10 00 
	thists->ts_iomb = sizeof(struct Taskstate);
f010386c:	66 c7 86 92 a0 28 f0 	movw   $0x68,-0xfd75f6e(%esi)
f0103873:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + thisid] = SEG16(
f0103875:	83 c0 05             	add    $0x5,%eax
f0103878:	66 c7 04 c5 40 53 12 	movw   $0x67,-0xfedacc0(,%eax,8)
f010387f:	f0 67 00 
f0103882:	66 89 1c c5 42 53 12 	mov    %bx,-0xfedacbe(,%eax,8)
f0103889:	f0 
f010388a:	89 d9                	mov    %ebx,%ecx
f010388c:	c1 e9 10             	shr    $0x10,%ecx
f010388f:	88 0c c5 44 53 12 f0 	mov    %cl,-0xfedacbc(,%eax,8)
f0103896:	c6 04 c5 46 53 12 f0 	movb   $0x40,-0xfedacba(,%eax,8)
f010389d:	40 
f010389e:	c1 eb 18             	shr    $0x18,%ebx
f01038a1:	88 1c c5 47 53 12 f0 	mov    %bl,-0xfedacb9(,%eax,8)
	        STS_T32A, (uint32_t)(thists), sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + thisid].sd_s = 0;
f01038a8:	c6 04 c5 45 53 12 f0 	movb   $0x89,-0xfedacbb(,%eax,8)
f01038af:	89 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + (thisid << 3));
f01038b0:	0f b6 d2             	movzbl %dl,%edx
f01038b3:	8d 04 d5 28 00 00 00 	lea    0x28(,%edx,8),%eax
f01038ba:	e8 13 ff ff ff       	call   f01037d2 <ltr>

	// Load the IDT
	lidt(&idt_pd);
f01038bf:	b8 ac 53 12 f0       	mov    $0xf01253ac,%eax
f01038c4:	e8 05 ff ff ff       	call   f01037ce <lidt>
}
f01038c9:	83 c4 0c             	add    $0xc,%esp
f01038cc:	5b                   	pop    %ebx
f01038cd:	5e                   	pop    %esi
f01038ce:	5f                   	pop    %edi
f01038cf:	5d                   	pop    %ebp
f01038d0:	c3                   	ret    

f01038d1 <trap_init>:
{
f01038d1:	55                   	push   %ebp
f01038d2:	89 e5                	mov    %esp,%ebp
f01038d4:	83 ec 08             	sub    $0x8,%esp
	SETGATE(idt[T_DIVIDE], 0, GD_KT, &trap0, 0);
f01038d7:	b8 64 42 10 f0       	mov    $0xf0104264,%eax
f01038dc:	66 a3 80 82 24 f0    	mov    %ax,0xf0248280
f01038e2:	66 c7 05 82 82 24 f0 	movw   $0x8,0xf0248282
f01038e9:	08 00 
f01038eb:	c6 05 84 82 24 f0 00 	movb   $0x0,0xf0248284
f01038f2:	c6 05 85 82 24 f0 8e 	movb   $0x8e,0xf0248285
f01038f9:	c1 e8 10             	shr    $0x10,%eax
f01038fc:	66 a3 86 82 24 f0    	mov    %ax,0xf0248286
	SETGATE(idt[T_DEBUG], 0, GD_KT, &trap1, 0);
f0103902:	b8 6a 42 10 f0       	mov    $0xf010426a,%eax
f0103907:	66 a3 88 82 24 f0    	mov    %ax,0xf0248288
f010390d:	66 c7 05 8a 82 24 f0 	movw   $0x8,0xf024828a
f0103914:	08 00 
f0103916:	c6 05 8c 82 24 f0 00 	movb   $0x0,0xf024828c
f010391d:	c6 05 8d 82 24 f0 8e 	movb   $0x8e,0xf024828d
f0103924:	c1 e8 10             	shr    $0x10,%eax
f0103927:	66 a3 8e 82 24 f0    	mov    %ax,0xf024828e
	SETGATE(idt[T_NMI], 0, GD_KT, &trap2, 0);
f010392d:	b8 70 42 10 f0       	mov    $0xf0104270,%eax
f0103932:	66 a3 90 82 24 f0    	mov    %ax,0xf0248290
f0103938:	66 c7 05 92 82 24 f0 	movw   $0x8,0xf0248292
f010393f:	08 00 
f0103941:	c6 05 94 82 24 f0 00 	movb   $0x0,0xf0248294
f0103948:	c6 05 95 82 24 f0 8e 	movb   $0x8e,0xf0248295
f010394f:	c1 e8 10             	shr    $0x10,%eax
f0103952:	66 a3 96 82 24 f0    	mov    %ax,0xf0248296
	SETGATE(idt[T_BRKPT], 0, GD_KT, &trap3, 3);
f0103958:	b8 76 42 10 f0       	mov    $0xf0104276,%eax
f010395d:	66 a3 98 82 24 f0    	mov    %ax,0xf0248298
f0103963:	66 c7 05 9a 82 24 f0 	movw   $0x8,0xf024829a
f010396a:	08 00 
f010396c:	c6 05 9c 82 24 f0 00 	movb   $0x0,0xf024829c
f0103973:	c6 05 9d 82 24 f0 ee 	movb   $0xee,0xf024829d
f010397a:	c1 e8 10             	shr    $0x10,%eax
f010397d:	66 a3 9e 82 24 f0    	mov    %ax,0xf024829e
	SETGATE(idt[T_OFLOW], 0, GD_KT, &trap4, 0);
f0103983:	b8 7c 42 10 f0       	mov    $0xf010427c,%eax
f0103988:	66 a3 a0 82 24 f0    	mov    %ax,0xf02482a0
f010398e:	66 c7 05 a2 82 24 f0 	movw   $0x8,0xf02482a2
f0103995:	08 00 
f0103997:	c6 05 a4 82 24 f0 00 	movb   $0x0,0xf02482a4
f010399e:	c6 05 a5 82 24 f0 8e 	movb   $0x8e,0xf02482a5
f01039a5:	c1 e8 10             	shr    $0x10,%eax
f01039a8:	66 a3 a6 82 24 f0    	mov    %ax,0xf02482a6
	SETGATE(idt[T_BOUND], 0, GD_KT, &trap5, 0);
f01039ae:	b8 82 42 10 f0       	mov    $0xf0104282,%eax
f01039b3:	66 a3 a8 82 24 f0    	mov    %ax,0xf02482a8
f01039b9:	66 c7 05 aa 82 24 f0 	movw   $0x8,0xf02482aa
f01039c0:	08 00 
f01039c2:	c6 05 ac 82 24 f0 00 	movb   $0x0,0xf02482ac
f01039c9:	c6 05 ad 82 24 f0 8e 	movb   $0x8e,0xf02482ad
f01039d0:	c1 e8 10             	shr    $0x10,%eax
f01039d3:	66 a3 ae 82 24 f0    	mov    %ax,0xf02482ae
	SETGATE(idt[T_ILLOP], 0, GD_KT, &trap6, 0);
f01039d9:	b8 88 42 10 f0       	mov    $0xf0104288,%eax
f01039de:	66 a3 b0 82 24 f0    	mov    %ax,0xf02482b0
f01039e4:	66 c7 05 b2 82 24 f0 	movw   $0x8,0xf02482b2
f01039eb:	08 00 
f01039ed:	c6 05 b4 82 24 f0 00 	movb   $0x0,0xf02482b4
f01039f4:	c6 05 b5 82 24 f0 8e 	movb   $0x8e,0xf02482b5
f01039fb:	c1 e8 10             	shr    $0x10,%eax
f01039fe:	66 a3 b6 82 24 f0    	mov    %ax,0xf02482b6
	SETGATE(idt[T_DEVICE], 0, GD_KT, &trap7, 0);
f0103a04:	b8 8e 42 10 f0       	mov    $0xf010428e,%eax
f0103a09:	66 a3 b8 82 24 f0    	mov    %ax,0xf02482b8
f0103a0f:	66 c7 05 ba 82 24 f0 	movw   $0x8,0xf02482ba
f0103a16:	08 00 
f0103a18:	c6 05 bc 82 24 f0 00 	movb   $0x0,0xf02482bc
f0103a1f:	c6 05 bd 82 24 f0 8e 	movb   $0x8e,0xf02482bd
f0103a26:	c1 e8 10             	shr    $0x10,%eax
f0103a29:	66 a3 be 82 24 f0    	mov    %ax,0xf02482be
	SETGATE(idt[T_DBLFLT], 0, GD_KT, &trap8, 0);
f0103a2f:	b8 94 42 10 f0       	mov    $0xf0104294,%eax
f0103a34:	66 a3 c0 82 24 f0    	mov    %ax,0xf02482c0
f0103a3a:	66 c7 05 c2 82 24 f0 	movw   $0x8,0xf02482c2
f0103a41:	08 00 
f0103a43:	c6 05 c4 82 24 f0 00 	movb   $0x0,0xf02482c4
f0103a4a:	c6 05 c5 82 24 f0 8e 	movb   $0x8e,0xf02482c5
f0103a51:	c1 e8 10             	shr    $0x10,%eax
f0103a54:	66 a3 c6 82 24 f0    	mov    %ax,0xf02482c6
	SETGATE(idt[T_TSS], 0, GD_KT, &trap10, 0);
f0103a5a:	b8 9e 42 10 f0       	mov    $0xf010429e,%eax
f0103a5f:	66 a3 d0 82 24 f0    	mov    %ax,0xf02482d0
f0103a65:	66 c7 05 d2 82 24 f0 	movw   $0x8,0xf02482d2
f0103a6c:	08 00 
f0103a6e:	c6 05 d4 82 24 f0 00 	movb   $0x0,0xf02482d4
f0103a75:	c6 05 d5 82 24 f0 8e 	movb   $0x8e,0xf02482d5
f0103a7c:	c1 e8 10             	shr    $0x10,%eax
f0103a7f:	66 a3 d6 82 24 f0    	mov    %ax,0xf02482d6
	SETGATE(idt[T_SEGNP], 0, GD_KT, &trap11, 0);
f0103a85:	b8 a2 42 10 f0       	mov    $0xf01042a2,%eax
f0103a8a:	66 a3 d8 82 24 f0    	mov    %ax,0xf02482d8
f0103a90:	66 c7 05 da 82 24 f0 	movw   $0x8,0xf02482da
f0103a97:	08 00 
f0103a99:	c6 05 dc 82 24 f0 00 	movb   $0x0,0xf02482dc
f0103aa0:	c6 05 dd 82 24 f0 8e 	movb   $0x8e,0xf02482dd
f0103aa7:	c1 e8 10             	shr    $0x10,%eax
f0103aaa:	66 a3 de 82 24 f0    	mov    %ax,0xf02482de
	SETGATE(idt[T_STACK], 0, GD_KT, &trap12, 0);
f0103ab0:	b8 a6 42 10 f0       	mov    $0xf01042a6,%eax
f0103ab5:	66 a3 e0 82 24 f0    	mov    %ax,0xf02482e0
f0103abb:	66 c7 05 e2 82 24 f0 	movw   $0x8,0xf02482e2
f0103ac2:	08 00 
f0103ac4:	c6 05 e4 82 24 f0 00 	movb   $0x0,0xf02482e4
f0103acb:	c6 05 e5 82 24 f0 8e 	movb   $0x8e,0xf02482e5
f0103ad2:	c1 e8 10             	shr    $0x10,%eax
f0103ad5:	66 a3 e6 82 24 f0    	mov    %ax,0xf02482e6
	SETGATE(idt[T_GPFLT], 0, GD_KT, &trap13, 0);
f0103adb:	b8 aa 42 10 f0       	mov    $0xf01042aa,%eax
f0103ae0:	66 a3 e8 82 24 f0    	mov    %ax,0xf02482e8
f0103ae6:	66 c7 05 ea 82 24 f0 	movw   $0x8,0xf02482ea
f0103aed:	08 00 
f0103aef:	c6 05 ec 82 24 f0 00 	movb   $0x0,0xf02482ec
f0103af6:	c6 05 ed 82 24 f0 8e 	movb   $0x8e,0xf02482ed
f0103afd:	c1 e8 10             	shr    $0x10,%eax
f0103b00:	66 a3 ee 82 24 f0    	mov    %ax,0xf02482ee
	SETGATE(idt[T_PGFLT], 0, GD_KT, &trap14, 0);
f0103b06:	b8 ae 42 10 f0       	mov    $0xf01042ae,%eax
f0103b0b:	66 a3 f0 82 24 f0    	mov    %ax,0xf02482f0
f0103b11:	66 c7 05 f2 82 24 f0 	movw   $0x8,0xf02482f2
f0103b18:	08 00 
f0103b1a:	c6 05 f4 82 24 f0 00 	movb   $0x0,0xf02482f4
f0103b21:	c6 05 f5 82 24 f0 8e 	movb   $0x8e,0xf02482f5
f0103b28:	c1 e8 10             	shr    $0x10,%eax
f0103b2b:	66 a3 f6 82 24 f0    	mov    %ax,0xf02482f6
	SETGATE(idt[T_FPERR], 0, GD_KT, &trap16, 0);
f0103b31:	b8 b8 42 10 f0       	mov    $0xf01042b8,%eax
f0103b36:	66 a3 00 83 24 f0    	mov    %ax,0xf0248300
f0103b3c:	66 c7 05 02 83 24 f0 	movw   $0x8,0xf0248302
f0103b43:	08 00 
f0103b45:	c6 05 04 83 24 f0 00 	movb   $0x0,0xf0248304
f0103b4c:	c6 05 05 83 24 f0 8e 	movb   $0x8e,0xf0248305
f0103b53:	c1 e8 10             	shr    $0x10,%eax
f0103b56:	66 a3 06 83 24 f0    	mov    %ax,0xf0248306
	SETGATE(idt[T_ALIGN], 0, GD_KT, &trap17, 0);
f0103b5c:	b8 be 42 10 f0       	mov    $0xf01042be,%eax
f0103b61:	66 a3 08 83 24 f0    	mov    %ax,0xf0248308
f0103b67:	66 c7 05 0a 83 24 f0 	movw   $0x8,0xf024830a
f0103b6e:	08 00 
f0103b70:	c6 05 0c 83 24 f0 00 	movb   $0x0,0xf024830c
f0103b77:	c6 05 0d 83 24 f0 8e 	movb   $0x8e,0xf024830d
f0103b7e:	c1 e8 10             	shr    $0x10,%eax
f0103b81:	66 a3 0e 83 24 f0    	mov    %ax,0xf024830e
	SETGATE(idt[T_MCHK], 0, GD_KT, &trap18, 0);
f0103b87:	b8 c2 42 10 f0       	mov    $0xf01042c2,%eax
f0103b8c:	66 a3 10 83 24 f0    	mov    %ax,0xf0248310
f0103b92:	66 c7 05 12 83 24 f0 	movw   $0x8,0xf0248312
f0103b99:	08 00 
f0103b9b:	c6 05 14 83 24 f0 00 	movb   $0x0,0xf0248314
f0103ba2:	c6 05 15 83 24 f0 8e 	movb   $0x8e,0xf0248315
f0103ba9:	c1 e8 10             	shr    $0x10,%eax
f0103bac:	66 a3 16 83 24 f0    	mov    %ax,0xf0248316
	SETGATE(idt[T_SIMDERR], 0, GD_KT, &trap19, 0);
f0103bb2:	b8 c8 42 10 f0       	mov    $0xf01042c8,%eax
f0103bb7:	66 a3 18 83 24 f0    	mov    %ax,0xf0248318
f0103bbd:	66 c7 05 1a 83 24 f0 	movw   $0x8,0xf024831a
f0103bc4:	08 00 
f0103bc6:	c6 05 1c 83 24 f0 00 	movb   $0x0,0xf024831c
f0103bcd:	c6 05 1d 83 24 f0 8e 	movb   $0x8e,0xf024831d
f0103bd4:	c1 e8 10             	shr    $0x10,%eax
f0103bd7:	66 a3 1e 83 24 f0    	mov    %ax,0xf024831e
	SETGATE(idt[T_SYSCALL], 0, GD_KT, &trap48, 3);
f0103bdd:	b8 d4 42 10 f0       	mov    $0xf01042d4,%eax
f0103be2:	66 a3 00 84 24 f0    	mov    %ax,0xf0248400
f0103be8:	66 c7 05 02 84 24 f0 	movw   $0x8,0xf0248402
f0103bef:	08 00 
f0103bf1:	c6 05 04 84 24 f0 00 	movb   $0x0,0xf0248404
f0103bf8:	c6 05 05 84 24 f0 ee 	movb   $0xee,0xf0248405
f0103bff:	c1 e8 10             	shr    $0x10,%eax
f0103c02:	66 a3 06 84 24 f0    	mov    %ax,0xf0248406
	SETGATE(idt[IRQ_OFFSET + IRQ_TIMER], 0, GD_KT, &trap32, 0);
f0103c08:	b8 ce 42 10 f0       	mov    $0xf01042ce,%eax
f0103c0d:	66 a3 80 83 24 f0    	mov    %ax,0xf0248380
f0103c13:	66 c7 05 82 83 24 f0 	movw   $0x8,0xf0248382
f0103c1a:	08 00 
f0103c1c:	c6 05 84 83 24 f0 00 	movb   $0x0,0xf0248384
f0103c23:	c6 05 85 83 24 f0 8e 	movb   $0x8e,0xf0248385
f0103c2a:	c1 e8 10             	shr    $0x10,%eax
f0103c2d:	66 a3 86 83 24 f0    	mov    %ax,0xf0248386
	trap_init_percpu();
f0103c33:	e8 f0 fb ff ff       	call   f0103828 <trap_init_percpu>
}
f0103c38:	c9                   	leave  
f0103c39:	c3                   	ret    

f0103c3a <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103c3a:	55                   	push   %ebp
f0103c3b:	89 e5                	mov    %esp,%ebp
f0103c3d:	53                   	push   %ebx
f0103c3e:	83 ec 0c             	sub    $0xc,%esp
f0103c41:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103c44:	ff 33                	push   (%ebx)
f0103c46:	68 e3 78 10 f0       	push   $0xf01078e3
f0103c4b:	e8 6a fb ff ff       	call   f01037ba <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103c50:	83 c4 08             	add    $0x8,%esp
f0103c53:	ff 73 04             	push   0x4(%ebx)
f0103c56:	68 f2 78 10 f0       	push   $0xf01078f2
f0103c5b:	e8 5a fb ff ff       	call   f01037ba <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103c60:	83 c4 08             	add    $0x8,%esp
f0103c63:	ff 73 08             	push   0x8(%ebx)
f0103c66:	68 01 79 10 f0       	push   $0xf0107901
f0103c6b:	e8 4a fb ff ff       	call   f01037ba <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103c70:	83 c4 08             	add    $0x8,%esp
f0103c73:	ff 73 0c             	push   0xc(%ebx)
f0103c76:	68 10 79 10 f0       	push   $0xf0107910
f0103c7b:	e8 3a fb ff ff       	call   f01037ba <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103c80:	83 c4 08             	add    $0x8,%esp
f0103c83:	ff 73 10             	push   0x10(%ebx)
f0103c86:	68 1f 79 10 f0       	push   $0xf010791f
f0103c8b:	e8 2a fb ff ff       	call   f01037ba <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103c90:	83 c4 08             	add    $0x8,%esp
f0103c93:	ff 73 14             	push   0x14(%ebx)
f0103c96:	68 2e 79 10 f0       	push   $0xf010792e
f0103c9b:	e8 1a fb ff ff       	call   f01037ba <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103ca0:	83 c4 08             	add    $0x8,%esp
f0103ca3:	ff 73 18             	push   0x18(%ebx)
f0103ca6:	68 3d 79 10 f0       	push   $0xf010793d
f0103cab:	e8 0a fb ff ff       	call   f01037ba <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103cb0:	83 c4 08             	add    $0x8,%esp
f0103cb3:	ff 73 1c             	push   0x1c(%ebx)
f0103cb6:	68 4c 79 10 f0       	push   $0xf010794c
f0103cbb:	e8 fa fa ff ff       	call   f01037ba <cprintf>
}
f0103cc0:	83 c4 10             	add    $0x10,%esp
f0103cc3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103cc6:	c9                   	leave  
f0103cc7:	c3                   	ret    

f0103cc8 <print_trapframe>:
{
f0103cc8:	55                   	push   %ebp
f0103cc9:	89 e5                	mov    %esp,%ebp
f0103ccb:	56                   	push   %esi
f0103ccc:	53                   	push   %ebx
f0103ccd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103cd0:	e8 93 22 00 00       	call   f0105f68 <cpunum>
f0103cd5:	83 ec 04             	sub    $0x4,%esp
f0103cd8:	50                   	push   %eax
f0103cd9:	53                   	push   %ebx
f0103cda:	68 82 79 10 f0       	push   $0xf0107982
f0103cdf:	e8 d6 fa ff ff       	call   f01037ba <cprintf>
	print_regs(&tf->tf_regs);
f0103ce4:	89 1c 24             	mov    %ebx,(%esp)
f0103ce7:	e8 4e ff ff ff       	call   f0103c3a <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103cec:	83 c4 08             	add    $0x8,%esp
f0103cef:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103cf3:	50                   	push   %eax
f0103cf4:	68 a0 79 10 f0       	push   $0xf01079a0
f0103cf9:	e8 bc fa ff ff       	call   f01037ba <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103cfe:	83 c4 08             	add    $0x8,%esp
f0103d01:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103d05:	50                   	push   %eax
f0103d06:	68 b3 79 10 f0       	push   $0xf01079b3
f0103d0b:	e8 aa fa ff ff       	call   f01037ba <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103d10:	8b 73 28             	mov    0x28(%ebx),%esi
f0103d13:	89 f0                	mov    %esi,%eax
f0103d15:	e8 cb fa ff ff       	call   f01037e5 <trapname>
f0103d1a:	83 c4 0c             	add    $0xc,%esp
f0103d1d:	50                   	push   %eax
f0103d1e:	56                   	push   %esi
f0103d1f:	68 c6 79 10 f0       	push   $0xf01079c6
f0103d24:	e8 91 fa ff ff       	call   f01037ba <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103d29:	83 c4 10             	add    $0x10,%esp
f0103d2c:	39 1d 80 8a 24 f0    	cmp    %ebx,0xf0248a80
f0103d32:	0f 84 9f 00 00 00    	je     f0103dd7 <print_trapframe+0x10f>
	cprintf("  err  0x%08x", tf->tf_err);
f0103d38:	83 ec 08             	sub    $0x8,%esp
f0103d3b:	ff 73 2c             	push   0x2c(%ebx)
f0103d3e:	68 e7 79 10 f0       	push   $0xf01079e7
f0103d43:	e8 72 fa ff ff       	call   f01037ba <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f0103d48:	83 c4 10             	add    $0x10,%esp
f0103d4b:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103d4f:	0f 85 a7 00 00 00    	jne    f0103dfc <print_trapframe+0x134>
		        tf->tf_err & 1 ? "protection" : "not-present");
f0103d55:	8b 43 2c             	mov    0x2c(%ebx),%eax
		cprintf(" [%s, %s, %s]\n",
f0103d58:	a8 01                	test   $0x1,%al
f0103d5a:	b9 5b 79 10 f0       	mov    $0xf010795b,%ecx
f0103d5f:	ba 66 79 10 f0       	mov    $0xf0107966,%edx
f0103d64:	0f 44 ca             	cmove  %edx,%ecx
f0103d67:	a8 02                	test   $0x2,%al
f0103d69:	ba 72 79 10 f0       	mov    $0xf0107972,%edx
f0103d6e:	be 78 79 10 f0       	mov    $0xf0107978,%esi
f0103d73:	0f 44 d6             	cmove  %esi,%edx
f0103d76:	a8 04                	test   $0x4,%al
f0103d78:	b8 7d 79 10 f0       	mov    $0xf010797d,%eax
f0103d7d:	be ad 7a 10 f0       	mov    $0xf0107aad,%esi
f0103d82:	0f 44 c6             	cmove  %esi,%eax
f0103d85:	51                   	push   %ecx
f0103d86:	52                   	push   %edx
f0103d87:	50                   	push   %eax
f0103d88:	68 f5 79 10 f0       	push   $0xf01079f5
f0103d8d:	e8 28 fa ff ff       	call   f01037ba <cprintf>
f0103d92:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103d95:	83 ec 08             	sub    $0x8,%esp
f0103d98:	ff 73 30             	push   0x30(%ebx)
f0103d9b:	68 04 7a 10 f0       	push   $0xf0107a04
f0103da0:	e8 15 fa ff ff       	call   f01037ba <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103da5:	83 c4 08             	add    $0x8,%esp
f0103da8:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103dac:	50                   	push   %eax
f0103dad:	68 13 7a 10 f0       	push   $0xf0107a13
f0103db2:	e8 03 fa ff ff       	call   f01037ba <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103db7:	83 c4 08             	add    $0x8,%esp
f0103dba:	ff 73 38             	push   0x38(%ebx)
f0103dbd:	68 26 7a 10 f0       	push   $0xf0107a26
f0103dc2:	e8 f3 f9 ff ff       	call   f01037ba <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103dc7:	83 c4 10             	add    $0x10,%esp
f0103dca:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103dce:	75 3e                	jne    f0103e0e <print_trapframe+0x146>
}
f0103dd0:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103dd3:	5b                   	pop    %ebx
f0103dd4:	5e                   	pop    %esi
f0103dd5:	5d                   	pop    %ebp
f0103dd6:	c3                   	ret    
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103dd7:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103ddb:	0f 85 57 ff ff ff    	jne    f0103d38 <print_trapframe+0x70>
		cprintf("  cr2  0x%08x\n", rcr2());
f0103de1:	e8 f0 f9 ff ff       	call   f01037d6 <rcr2>
f0103de6:	83 ec 08             	sub    $0x8,%esp
f0103de9:	50                   	push   %eax
f0103dea:	68 d8 79 10 f0       	push   $0xf01079d8
f0103def:	e8 c6 f9 ff ff       	call   f01037ba <cprintf>
f0103df4:	83 c4 10             	add    $0x10,%esp
f0103df7:	e9 3c ff ff ff       	jmp    f0103d38 <print_trapframe+0x70>
		cprintf("\n");
f0103dfc:	83 ec 0c             	sub    $0xc,%esp
f0103dff:	68 c8 77 10 f0       	push   $0xf01077c8
f0103e04:	e8 b1 f9 ff ff       	call   f01037ba <cprintf>
f0103e09:	83 c4 10             	add    $0x10,%esp
f0103e0c:	eb 87                	jmp    f0103d95 <print_trapframe+0xcd>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103e0e:	83 ec 08             	sub    $0x8,%esp
f0103e11:	ff 73 3c             	push   0x3c(%ebx)
f0103e14:	68 35 7a 10 f0       	push   $0xf0107a35
f0103e19:	e8 9c f9 ff ff       	call   f01037ba <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103e1e:	83 c4 08             	add    $0x8,%esp
f0103e21:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103e25:	50                   	push   %eax
f0103e26:	68 44 7a 10 f0       	push   $0xf0107a44
f0103e2b:	e8 8a f9 ff ff       	call   f01037ba <cprintf>
f0103e30:	83 c4 10             	add    $0x10,%esp
}
f0103e33:	eb 9b                	jmp    f0103dd0 <print_trapframe+0x108>

f0103e35 <page_fault_handler>:
		sched_yield();
}

void
page_fault_handler(struct Trapframe *tf)
{
f0103e35:	55                   	push   %ebp
f0103e36:	89 e5                	mov    %esp,%ebp
f0103e38:	57                   	push   %edi
f0103e39:	56                   	push   %esi
f0103e3a:	53                   	push   %ebx
f0103e3b:	83 ec 3c             	sub    $0x3c,%esp
f0103e3e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint32_t fault_va;

	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();
f0103e41:	e8 90 f9 ff ff       	call   f01037d6 <rcr2>
f0103e46:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// Handle kernel-mode page faults.
	// If page fault happens in kernel-mode, panic
	if (!(tf->tf_cs & 0x3))
f0103e49:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103e4d:	0f 84 1d 01 00 00    	je     f0103f70 <page_fault_handler+0x13b>
	//
	// Hints:
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').
	if (curenv->env_pgfault_upcall) {
f0103e53:	e8 10 21 00 00       	call   f0105f68 <cpunum>
f0103e58:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e5b:	8b 80 28 a0 28 f0    	mov    -0xfd75fd8(%eax),%eax
f0103e61:	83 78 70 00          	cmpl   $0x0,0x70(%eax)
f0103e65:	0f 84 8d 01 00 00    	je     f0103ff8 <page_fault_handler+0x1c3>
		uint32_t exstk = (UXSTACKTOP - PGSIZE);
		uint32_t exstk_top = (UXSTACKTOP - 1);
		struct UTrapframe utf;

		user_mem_assert(curenv, (void *) exstk, PGSIZE, PTE_U | PTE_W);
f0103e6b:	e8 f8 20 00 00       	call   f0105f68 <cpunum>
f0103e70:	6a 06                	push   $0x6
f0103e72:	68 00 10 00 00       	push   $0x1000
f0103e77:	68 00 f0 bf ee       	push   $0xeebff000
f0103e7c:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e7f:	ff b0 28 a0 28 f0    	push   -0xfd75fd8(%eax)
f0103e85:	e8 00 ef ff ff       	call   f0102d8a <user_mem_assert>

		utf.utf_fault_va = fault_va;
		utf.utf_err = tf->tf_err;
f0103e8a:	8b 7b 2c             	mov    0x2c(%ebx),%edi

		utf.utf_regs = tf->tf_regs;
f0103e8d:	8b 03                	mov    (%ebx),%eax
f0103e8f:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0103e92:	8b 43 04             	mov    0x4(%ebx),%eax
f0103e95:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103e98:	8b 43 08             	mov    0x8(%ebx),%eax
f0103e9b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103e9e:	8b 43 0c             	mov    0xc(%ebx),%eax
f0103ea1:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103ea4:	8b 43 10             	mov    0x10(%ebx),%eax
f0103ea7:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0103eaa:	8b 43 14             	mov    0x14(%ebx),%eax
f0103ead:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0103eb0:	8b 43 18             	mov    0x18(%ebx),%eax
f0103eb3:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0103eb6:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0103eb9:	89 45 c0             	mov    %eax,-0x40(%ebp)
		utf.utf_eip = tf->tf_eip;
f0103ebc:	8b 43 30             	mov    0x30(%ebx),%eax
f0103ebf:	89 45 e0             	mov    %eax,-0x20(%ebp)
		utf.utf_eflags = tf->tf_eflags;
f0103ec2:	8b 73 38             	mov    0x38(%ebx),%esi
		utf.utf_esp = tf->tf_esp;
f0103ec5:	8b 53 3c             	mov    0x3c(%ebx),%edx

		uint32_t tmp = utf.utf_esp;

		if (utf.utf_esp < exstk || utf.utf_esp > exstk_top) {
f0103ec8:	8d 82 00 10 40 11    	lea    0x11401000(%edx),%eax
f0103ece:	83 c4 10             	add    $0x10,%esp
f0103ed1:	3d ff 0f 00 00       	cmp    $0xfff,%eax
f0103ed6:	0f 86 ab 00 00 00    	jbe    f0103f87 <page_fault_handler+0x152>
		} else {
			tmp -= sizeof(uint32_t);
			*(uint32_t *) (tmp) = 0;
			tmp -= sizeof(struct UTrapframe);
		}
		*(struct UTrapframe *) (tmp) = utf;
f0103edc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103edf:	a3 cb ff bf ee       	mov    %eax,0xeebfffcb
f0103ee4:	89 3d cf ff bf ee    	mov    %edi,0xeebfffcf
f0103eea:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103eed:	a3 d3 ff bf ee       	mov    %eax,0xeebfffd3
f0103ef2:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103ef5:	a3 d7 ff bf ee       	mov    %eax,0xeebfffd7
f0103efa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103efd:	a3 db ff bf ee       	mov    %eax,0xeebfffdb
f0103f02:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103f05:	a3 df ff bf ee       	mov    %eax,0xeebfffdf
f0103f0a:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0103f0d:	a3 e3 ff bf ee       	mov    %eax,0xeebfffe3
f0103f12:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0103f15:	a3 e7 ff bf ee       	mov    %eax,0xeebfffe7
f0103f1a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0103f1d:	a3 eb ff bf ee       	mov    %eax,0xeebfffeb
f0103f22:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0103f25:	a3 ef ff bf ee       	mov    %eax,0xeebfffef
f0103f2a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103f2d:	a3 f3 ff bf ee       	mov    %eax,0xeebffff3
f0103f32:	89 35 f7 ff bf ee    	mov    %esi,0xeebffff7
f0103f38:	89 15 fb ff bf ee    	mov    %edx,0xeebffffb
			tmp = exstk_top - sizeof(struct UTrapframe);
f0103f3e:	b8 cb ff bf ee       	mov    $0xeebfffcb,%eax

		if (tmp < exstk || tmp > exstk_top)
			panic("page_fault_handler: exception stack overflow");

		tf->tf_esp = tmp;
f0103f43:	89 43 3c             	mov    %eax,0x3c(%ebx)
		tf->tf_eip = (uint32_t) curenv->env_pgfault_upcall;
f0103f46:	e8 1d 20 00 00       	call   f0105f68 <cpunum>
f0103f4b:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f4e:	8b 80 28 a0 28 f0    	mov    -0xfd75fd8(%eax),%eax
f0103f54:	8b 40 70             	mov    0x70(%eax),%eax
f0103f57:	89 43 30             	mov    %eax,0x30(%ebx)
		env_run(curenv);
f0103f5a:	e8 09 20 00 00       	call   f0105f68 <cpunum>
f0103f5f:	83 ec 0c             	sub    $0xc,%esp
f0103f62:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f65:	ff b0 28 a0 28 f0    	push   -0xfd75fd8(%eax)
f0103f6b:	e8 6f f5 ff ff       	call   f01034df <env_run>
		panic("page fault in kernel mode\n");
f0103f70:	83 ec 04             	sub    $0x4,%esp
f0103f73:	68 57 7a 10 f0       	push   $0xf0107a57
f0103f78:	68 3d 01 00 00       	push   $0x13d
f0103f7d:	68 72 7a 10 f0       	push   $0xf0107a72
f0103f82:	e8 e3 c0 ff ff       	call   f010006a <_panic>
			*(uint32_t *) (tmp) = 0;
f0103f87:	c7 42 fc 00 00 00 00 	movl   $0x0,-0x4(%edx)
			tmp -= sizeof(struct UTrapframe);
f0103f8e:	8d 42 c8             	lea    -0x38(%edx),%eax
		*(struct UTrapframe *) (tmp) = utf;
f0103f91:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0103f94:	89 4a c8             	mov    %ecx,-0x38(%edx)
f0103f97:	89 78 04             	mov    %edi,0x4(%eax)
f0103f9a:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0103f9d:	89 78 08             	mov    %edi,0x8(%eax)
f0103fa0:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0103fa3:	89 48 0c             	mov    %ecx,0xc(%eax)
f0103fa6:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0103fa9:	89 48 10             	mov    %ecx,0x10(%eax)
f0103fac:	8b 7d d0             	mov    -0x30(%ebp),%edi
f0103faf:	89 78 14             	mov    %edi,0x14(%eax)
f0103fb2:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0103fb5:	89 48 18             	mov    %ecx,0x18(%eax)
f0103fb8:	8b 7d c8             	mov    -0x38(%ebp),%edi
f0103fbb:	89 78 1c             	mov    %edi,0x1c(%eax)
f0103fbe:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0103fc1:	89 48 20             	mov    %ecx,0x20(%eax)
f0103fc4:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0103fc7:	89 78 24             	mov    %edi,0x24(%eax)
f0103fca:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103fcd:	89 48 28             	mov    %ecx,0x28(%eax)
f0103fd0:	89 70 2c             	mov    %esi,0x2c(%eax)
f0103fd3:	89 50 30             	mov    %edx,0x30(%eax)
		if (tmp < exstk || tmp > exstk_top)
f0103fd6:	3d ff ef bf ee       	cmp    $0xeebfefff,%eax
f0103fdb:	0f 87 62 ff ff ff    	ja     f0103f43 <page_fault_handler+0x10e>
			panic("page_fault_handler: exception stack overflow");
f0103fe1:	83 ec 04             	sub    $0x4,%esp
f0103fe4:	68 18 7c 10 f0       	push   $0xf0107c18
f0103fe9:	68 78 01 00 00       	push   $0x178
f0103fee:	68 72 7a 10 f0       	push   $0xf0107a72
f0103ff3:	e8 72 c0 ff ff       	call   f010006a <_panic>
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103ff8:	8b 7b 30             	mov    0x30(%ebx),%edi
	        curenv->env_id,
f0103ffb:	e8 68 1f 00 00       	call   f0105f68 <cpunum>
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104000:	57                   	push   %edi
f0104001:	ff 75 e4             	push   -0x1c(%ebp)
	        curenv->env_id,
f0104004:	6b c0 74             	imul   $0x74,%eax,%eax
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104007:	8b 80 28 a0 28 f0    	mov    -0xfd75fd8(%eax),%eax
f010400d:	ff 70 48             	push   0x48(%eax)
f0104010:	68 48 7c 10 f0       	push   $0xf0107c48
f0104015:	e8 a0 f7 ff ff       	call   f01037ba <cprintf>
	        fault_va,
	        tf->tf_eip);
	print_trapframe(tf);
f010401a:	89 1c 24             	mov    %ebx,(%esp)
f010401d:	e8 a6 fc ff ff       	call   f0103cc8 <print_trapframe>
	env_destroy(curenv);
f0104022:	e8 41 1f 00 00       	call   f0105f68 <cpunum>
f0104027:	83 c4 04             	add    $0x4,%esp
f010402a:	6b c0 74             	imul   $0x74,%eax,%eax
f010402d:	ff b0 28 a0 28 f0    	push   -0xfd75fd8(%eax)
f0104033:	e8 24 f4 ff ff       	call   f010345c <env_destroy>
}
f0104038:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010403b:	5b                   	pop    %ebx
f010403c:	5e                   	pop    %esi
f010403d:	5f                   	pop    %edi
f010403e:	5d                   	pop    %ebp
f010403f:	c3                   	ret    

f0104040 <trap_dispatch>:
{
f0104040:	55                   	push   %ebp
f0104041:	89 e5                	mov    %esp,%ebp
f0104043:	53                   	push   %ebx
f0104044:	83 ec 04             	sub    $0x4,%esp
f0104047:	89 c3                	mov    %eax,%ebx
	switch (tf->tf_trapno) {
f0104049:	8b 40 28             	mov    0x28(%eax),%eax
f010404c:	83 f8 0e             	cmp    $0xe,%eax
f010404f:	74 57                	je     f01040a8 <trap_dispatch+0x68>
f0104051:	83 f8 30             	cmp    $0x30,%eax
f0104054:	74 60                	je     f01040b6 <trap_dispatch+0x76>
f0104056:	83 f8 03             	cmp    $0x3,%eax
f0104059:	74 3c                	je     f0104097 <trap_dispatch+0x57>
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f010405b:	83 f8 27             	cmp    $0x27,%eax
f010405e:	74 77                	je     f01040d7 <trap_dispatch+0x97>
	switch (tf->tf_trapno - IRQ_OFFSET) {
f0104060:	83 f8 20             	cmp    $0x20,%eax
f0104063:	0f 84 88 00 00 00    	je     f01040f1 <trap_dispatch+0xb1>
	print_trapframe(tf);
f0104069:	83 ec 0c             	sub    $0xc,%esp
f010406c:	53                   	push   %ebx
f010406d:	e8 56 fc ff ff       	call   f0103cc8 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104072:	83 c4 10             	add    $0x10,%esp
f0104075:	66 83 7b 34 08       	cmpw   $0x8,0x34(%ebx)
f010407a:	74 7f                	je     f01040fb <trap_dispatch+0xbb>
		env_destroy(curenv);
f010407c:	e8 e7 1e 00 00       	call   f0105f68 <cpunum>
f0104081:	83 ec 0c             	sub    $0xc,%esp
f0104084:	6b c0 74             	imul   $0x74,%eax,%eax
f0104087:	ff b0 28 a0 28 f0    	push   -0xfd75fd8(%eax)
f010408d:	e8 ca f3 ff ff       	call   f010345c <env_destroy>
		return;
f0104092:	83 c4 10             	add    $0x10,%esp
f0104095:	eb 0c                	jmp    f01040a3 <trap_dispatch+0x63>
		monitor(tf);
f0104097:	83 ec 0c             	sub    $0xc,%esp
f010409a:	53                   	push   %ebx
f010409b:	e8 56 ca ff ff       	call   f0100af6 <monitor>
		return;
f01040a0:	83 c4 10             	add    $0x10,%esp
}
f01040a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01040a6:	c9                   	leave  
f01040a7:	c3                   	ret    
		page_fault_handler(tf);
f01040a8:	83 ec 0c             	sub    $0xc,%esp
f01040ab:	53                   	push   %ebx
f01040ac:	e8 84 fd ff ff       	call   f0103e35 <page_fault_handler>
		return;
f01040b1:	83 c4 10             	add    $0x10,%esp
f01040b4:	eb ed                	jmp    f01040a3 <trap_dispatch+0x63>
		tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax,
f01040b6:	83 ec 08             	sub    $0x8,%esp
f01040b9:	ff 73 04             	push   0x4(%ebx)
f01040bc:	ff 33                	push   (%ebx)
f01040be:	ff 73 10             	push   0x10(%ebx)
f01040c1:	ff 73 18             	push   0x18(%ebx)
f01040c4:	ff 73 14             	push   0x14(%ebx)
f01040c7:	ff 73 1c             	push   0x1c(%ebx)
f01040ca:	e8 23 0c 00 00       	call   f0104cf2 <syscall>
f01040cf:	89 43 1c             	mov    %eax,0x1c(%ebx)
		return;
f01040d2:	83 c4 20             	add    $0x20,%esp
f01040d5:	eb cc                	jmp    f01040a3 <trap_dispatch+0x63>
		cprintf("Spurious interrupt on irq 7\n");
f01040d7:	83 ec 0c             	sub    $0xc,%esp
f01040da:	68 7e 7a 10 f0       	push   $0xf0107a7e
f01040df:	e8 d6 f6 ff ff       	call   f01037ba <cprintf>
		print_trapframe(tf);
f01040e4:	89 1c 24             	mov    %ebx,(%esp)
f01040e7:	e8 dc fb ff ff       	call   f0103cc8 <print_trapframe>
		return;
f01040ec:	83 c4 10             	add    $0x10,%esp
f01040ef:	eb b2                	jmp    f01040a3 <trap_dispatch+0x63>
		lapic_eoi();
f01040f1:	e8 b9 1f 00 00       	call   f01060af <lapic_eoi>
		sched_yield();
f01040f6:	e8 33 04 00 00       	call   f010452e <sched_yield>
		panic("unhandled trap in kernel");
f01040fb:	83 ec 04             	sub    $0x4,%esp
f01040fe:	68 9b 7a 10 f0       	push   $0xf0107a9b
f0104103:	68 f0 00 00 00       	push   $0xf0
f0104108:	68 72 7a 10 f0       	push   $0xf0107a72
f010410d:	e8 58 bf ff ff       	call   f010006a <_panic>

f0104112 <trap>:
{
f0104112:	55                   	push   %ebp
f0104113:	89 e5                	mov    %esp,%ebp
f0104115:	57                   	push   %edi
f0104116:	56                   	push   %esi
f0104117:	8b 75 08             	mov    0x8(%ebp),%esi
	asm volatile("cld" ::: "cc");
f010411a:	fc                   	cld    
	if (panicstr)
f010411b:	83 3d 00 80 24 f0 00 	cmpl   $0x0,0xf0248000
f0104122:	74 01                	je     f0104125 <trap+0x13>
		asm volatile("hlt");
f0104124:	f4                   	hlt    
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0104125:	e8 3e 1e 00 00       	call   f0105f68 <cpunum>
f010412a:	6b c0 74             	imul   $0x74,%eax,%eax
f010412d:	05 24 a0 28 f0       	add    $0xf028a024,%eax
f0104132:	ba 01 00 00 00       	mov    $0x1,%edx
f0104137:	e8 a1 f6 ff ff       	call   f01037dd <xchg>
f010413c:	83 f8 02             	cmp    $0x2,%eax
f010413f:	74 52                	je     f0104193 <trap+0x81>
	assert(!(read_eflags() & FL_IF));
f0104141:	e8 94 f6 ff ff       	call   f01037da <read_eflags>
f0104146:	f6 c4 02             	test   $0x2,%ah
f0104149:	75 4f                	jne    f010419a <trap+0x88>
	if ((tf->tf_cs & 3) == 3) {
f010414b:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f010414f:	83 e0 03             	and    $0x3,%eax
f0104152:	66 83 f8 03          	cmp    $0x3,%ax
f0104156:	74 5b                	je     f01041b3 <trap+0xa1>
	last_tf = tf;
f0104158:	89 35 80 8a 24 f0    	mov    %esi,0xf0248a80
	trap_dispatch(tf);
f010415e:	89 f0                	mov    %esi,%eax
f0104160:	e8 db fe ff ff       	call   f0104040 <trap_dispatch>
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104165:	e8 fe 1d 00 00       	call   f0105f68 <cpunum>
f010416a:	6b c0 74             	imul   $0x74,%eax,%eax
f010416d:	83 b8 28 a0 28 f0 00 	cmpl   $0x0,-0xfd75fd8(%eax)
f0104174:	74 18                	je     f010418e <trap+0x7c>
f0104176:	e8 ed 1d 00 00       	call   f0105f68 <cpunum>
f010417b:	6b c0 74             	imul   $0x74,%eax,%eax
f010417e:	8b 80 28 a0 28 f0    	mov    -0xfd75fd8(%eax),%eax
f0104184:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104188:	0f 84 bf 00 00 00    	je     f010424d <trap+0x13b>
		sched_yield();
f010418e:	e8 9b 03 00 00       	call   f010452e <sched_yield>
		lock_kernel();
f0104193:	e8 7b f6 ff ff       	call   f0103813 <lock_kernel>
f0104198:	eb a7                	jmp    f0104141 <trap+0x2f>
	assert(!(read_eflags() & FL_IF));
f010419a:	68 b4 7a 10 f0       	push   $0xf0107ab4
f010419f:	68 0b 75 10 f0       	push   $0xf010750b
f01041a4:	68 0a 01 00 00       	push   $0x10a
f01041a9:	68 72 7a 10 f0       	push   $0xf0107a72
f01041ae:	e8 b7 be ff ff       	call   f010006a <_panic>
		lock_kernel();
f01041b3:	e8 5b f6 ff ff       	call   f0103813 <lock_kernel>
		assert(curenv);
f01041b8:	e8 ab 1d 00 00       	call   f0105f68 <cpunum>
f01041bd:	6b c0 74             	imul   $0x74,%eax,%eax
f01041c0:	83 b8 28 a0 28 f0 00 	cmpl   $0x0,-0xfd75fd8(%eax)
f01041c7:	74 3e                	je     f0104207 <trap+0xf5>
		if (curenv->env_status == ENV_DYING) {
f01041c9:	e8 9a 1d 00 00       	call   f0105f68 <cpunum>
f01041ce:	6b c0 74             	imul   $0x74,%eax,%eax
f01041d1:	8b 80 28 a0 28 f0    	mov    -0xfd75fd8(%eax),%eax
f01041d7:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f01041db:	74 43                	je     f0104220 <trap+0x10e>
		curenv->env_tf = *tf;
f01041dd:	e8 86 1d 00 00       	call   f0105f68 <cpunum>
f01041e2:	6b c0 74             	imul   $0x74,%eax,%eax
f01041e5:	8b 80 28 a0 28 f0    	mov    -0xfd75fd8(%eax),%eax
f01041eb:	b9 11 00 00 00       	mov    $0x11,%ecx
f01041f0:	89 c7                	mov    %eax,%edi
f01041f2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf = &curenv->env_tf;
f01041f4:	e8 6f 1d 00 00       	call   f0105f68 <cpunum>
f01041f9:	6b c0 74             	imul   $0x74,%eax,%eax
f01041fc:	8b b0 28 a0 28 f0    	mov    -0xfd75fd8(%eax),%esi
f0104202:	e9 51 ff ff ff       	jmp    f0104158 <trap+0x46>
		assert(curenv);
f0104207:	68 cd 7a 10 f0       	push   $0xf0107acd
f010420c:	68 0b 75 10 f0       	push   $0xf010750b
f0104211:	68 11 01 00 00       	push   $0x111
f0104216:	68 72 7a 10 f0       	push   $0xf0107a72
f010421b:	e8 4a be ff ff       	call   f010006a <_panic>
			env_free(curenv);
f0104220:	e8 43 1d 00 00       	call   f0105f68 <cpunum>
f0104225:	83 ec 0c             	sub    $0xc,%esp
f0104228:	6b c0 74             	imul   $0x74,%eax,%eax
f010422b:	ff b0 28 a0 28 f0    	push   -0xfd75fd8(%eax)
f0104231:	e8 ce f0 ff ff       	call   f0103304 <env_free>
			curenv = NULL;
f0104236:	e8 2d 1d 00 00       	call   f0105f68 <cpunum>
f010423b:	6b c0 74             	imul   $0x74,%eax,%eax
f010423e:	c7 80 28 a0 28 f0 00 	movl   $0x0,-0xfd75fd8(%eax)
f0104245:	00 00 00 
			sched_yield();
f0104248:	e8 e1 02 00 00       	call   f010452e <sched_yield>
		env_run(curenv);
f010424d:	e8 16 1d 00 00       	call   f0105f68 <cpunum>
f0104252:	83 ec 0c             	sub    $0xc,%esp
f0104255:	6b c0 74             	imul   $0x74,%eax,%eax
f0104258:	ff b0 28 a0 28 f0    	push   -0xfd75fd8(%eax)
f010425e:	e8 7c f2 ff ff       	call   f01034df <env_run>
f0104263:	90                   	nop

f0104264 <trap0>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

TRAPHANDLER_NOEC(trap0, T_DIVIDE)
f0104264:	6a 00                	push   $0x0
f0104266:	6a 00                	push   $0x0
f0104268:	eb 70                	jmp    f01042da <_alltraps>

f010426a <trap1>:
TRAPHANDLER_NOEC(trap1, T_DEBUG)
f010426a:	6a 00                	push   $0x0
f010426c:	6a 01                	push   $0x1
f010426e:	eb 6a                	jmp    f01042da <_alltraps>

f0104270 <trap2>:
TRAPHANDLER_NOEC(trap2, T_NMI)
f0104270:	6a 00                	push   $0x0
f0104272:	6a 02                	push   $0x2
f0104274:	eb 64                	jmp    f01042da <_alltraps>

f0104276 <trap3>:
TRAPHANDLER_NOEC(trap3, T_BRKPT)
f0104276:	6a 00                	push   $0x0
f0104278:	6a 03                	push   $0x3
f010427a:	eb 5e                	jmp    f01042da <_alltraps>

f010427c <trap4>:
TRAPHANDLER_NOEC(trap4, T_OFLOW)
f010427c:	6a 00                	push   $0x0
f010427e:	6a 04                	push   $0x4
f0104280:	eb 58                	jmp    f01042da <_alltraps>

f0104282 <trap5>:
TRAPHANDLER_NOEC(trap5, T_BOUND)
f0104282:	6a 00                	push   $0x0
f0104284:	6a 05                	push   $0x5
f0104286:	eb 52                	jmp    f01042da <_alltraps>

f0104288 <trap6>:
TRAPHANDLER_NOEC(trap6, T_ILLOP)
f0104288:	6a 00                	push   $0x0
f010428a:	6a 06                	push   $0x6
f010428c:	eb 4c                	jmp    f01042da <_alltraps>

f010428e <trap7>:
TRAPHANDLER_NOEC(trap7, T_DEVICE)
f010428e:	6a 00                	push   $0x0
f0104290:	6a 07                	push   $0x7
f0104292:	eb 46                	jmp    f01042da <_alltraps>

f0104294 <trap8>:
TRAPHANDLER(trap8, T_DBLFLT)
f0104294:	6a 08                	push   $0x8
f0104296:	eb 42                	jmp    f01042da <_alltraps>

f0104298 <trap9>:
TRAPHANDLER_NOEC(trap9, 9)
f0104298:	6a 00                	push   $0x0
f010429a:	6a 09                	push   $0x9
f010429c:	eb 3c                	jmp    f01042da <_alltraps>

f010429e <trap10>:
TRAPHANDLER(trap10, T_TSS)
f010429e:	6a 0a                	push   $0xa
f01042a0:	eb 38                	jmp    f01042da <_alltraps>

f01042a2 <trap11>:
TRAPHANDLER(trap11, T_SEGNP)
f01042a2:	6a 0b                	push   $0xb
f01042a4:	eb 34                	jmp    f01042da <_alltraps>

f01042a6 <trap12>:
TRAPHANDLER(trap12, T_STACK)
f01042a6:	6a 0c                	push   $0xc
f01042a8:	eb 30                	jmp    f01042da <_alltraps>

f01042aa <trap13>:
TRAPHANDLER(trap13, T_GPFLT)
f01042aa:	6a 0d                	push   $0xd
f01042ac:	eb 2c                	jmp    f01042da <_alltraps>

f01042ae <trap14>:
TRAPHANDLER(trap14, T_PGFLT)
f01042ae:	6a 0e                	push   $0xe
f01042b0:	eb 28                	jmp    f01042da <_alltraps>

f01042b2 <trap15>:
TRAPHANDLER_NOEC(trap15, 15)
f01042b2:	6a 00                	push   $0x0
f01042b4:	6a 0f                	push   $0xf
f01042b6:	eb 22                	jmp    f01042da <_alltraps>

f01042b8 <trap16>:
TRAPHANDLER_NOEC(trap16, T_FPERR)
f01042b8:	6a 00                	push   $0x0
f01042ba:	6a 10                	push   $0x10
f01042bc:	eb 1c                	jmp    f01042da <_alltraps>

f01042be <trap17>:
TRAPHANDLER(trap17, T_ALIGN)
f01042be:	6a 11                	push   $0x11
f01042c0:	eb 18                	jmp    f01042da <_alltraps>

f01042c2 <trap18>:
TRAPHANDLER_NOEC(trap18, T_MCHK)
f01042c2:	6a 00                	push   $0x0
f01042c4:	6a 12                	push   $0x12
f01042c6:	eb 12                	jmp    f01042da <_alltraps>

f01042c8 <trap19>:
TRAPHANDLER_NOEC(trap19, T_SIMDERR)
f01042c8:	6a 00                	push   $0x0
f01042ca:	6a 13                	push   $0x13
f01042cc:	eb 0c                	jmp    f01042da <_alltraps>

f01042ce <trap32>:

TRAPHANDLER_NOEC(trap32, IRQ_OFFSET + IRQ_TIMER)
f01042ce:	6a 00                	push   $0x0
f01042d0:	6a 20                	push   $0x20
f01042d2:	eb 06                	jmp    f01042da <_alltraps>

f01042d4 <trap48>:

TRAPHANDLER_NOEC(trap48, T_SYSCALL)
f01042d4:	6a 00                	push   $0x0
f01042d6:	6a 30                	push   $0x30
f01042d8:	eb 00                	jmp    f01042da <_alltraps>

f01042da <_alltraps>:

.globl _alltraps
_alltraps:
	
	pushl %ds
f01042da:	1e                   	push   %ds
	pushl %es
f01042db:	06                   	push   %es
	pushal
f01042dc:	60                   	pusha  

	pushl %esp
f01042dd:	54                   	push   %esp

	call trap
f01042de:	e8 2f fe ff ff       	call   f0104112 <trap>

f01042e3 <context_switch>:
 * This function does not return.
 */

.globl context_switch;
context_switch:
	movl 4(%esp), %esp
f01042e3:	8b 64 24 04          	mov    0x4(%esp),%esp
	movl $2, %eax
f01042e7:	b8 02 00 00 00       	mov    $0x2,%eax

	popal
f01042ec:	61                   	popa   
	pop %es 
f01042ed:	07                   	pop    %es

	pop %ds 
f01042ee:	1f                   	pop    %ds
	add $8, %esp
f01042ef:	83 c4 08             	add    $0x8,%esp
	iret
f01042f2:	cf                   	iret   

f01042f3 <spin>:

spin:
	jmp spin
f01042f3:	eb fe                	jmp    f01042f3 <spin>

f01042f5 <lcr3>:
	asm volatile("movl %0,%%cr3" : : "r"(val));
f01042f5:	0f 22 d8             	mov    %eax,%cr3
}
f01042f8:	c3                   	ret    

f01042f9 <read_tsc>:
	asm volatile("rdtsc" : "=A"(tsc));
f01042f9:	0f 31                	rdtsc  
}
f01042fb:	c3                   	ret    

f01042fc <xchg>:
{
f01042fc:	89 c1                	mov    %eax,%ecx
f01042fe:	89 d0                	mov    %edx,%eax
	asm volatile("lock; xchgl %0, %1"
f0104300:	f0 87 01             	lock xchg %eax,(%ecx)
}
f0104303:	c3                   	ret    

f0104304 <_paddr>:
	if ((uint32_t) kva < KERNBASE)
f0104304:	81 f9 ff ff ff ef    	cmp    $0xefffffff,%ecx
f010430a:	76 07                	jbe    f0104313 <_paddr+0xf>
	return (physaddr_t) kva - KERNBASE;
f010430c:	8d 81 00 00 00 10    	lea    0x10000000(%ecx),%eax
}
f0104312:	c3                   	ret    
{
f0104313:	55                   	push   %ebp
f0104314:	89 e5                	mov    %esp,%ebp
f0104316:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104319:	51                   	push   %ecx
f010431a:	68 30 66 10 f0       	push   $0xf0106630
f010431f:	52                   	push   %edx
f0104320:	50                   	push   %eax
f0104321:	e8 44 bd ff ff       	call   f010006a <_panic>

f0104326 <unlock_kernel>:
{
f0104326:	55                   	push   %ebp
f0104327:	89 e5                	mov    %esp,%ebp
f0104329:	83 ec 14             	sub    $0x14,%esp
	spin_unlock(&kernel_lock);
f010432c:	68 c0 53 12 f0       	push   $0xf01253c0
f0104331:	e8 6f 1f 00 00       	call   f01062a5 <spin_unlock>
	asm volatile("pause");
f0104336:	f3 90                	pause  
}
f0104338:	83 c4 10             	add    $0x10,%esp
f010433b:	c9                   	leave  
f010433c:	c3                   	ret    

f010433d <get_total_tickets>:
void sched_halt(void);


unsigned int
get_total_tickets()
{
f010433d:	55                   	push   %ebp
f010433e:	89 e5                	mov    %esp,%ebp
f0104340:	53                   	push   %ebx
	unsigned int accumulator = 0;
	for (int i = 0; i < NENV; i++) {
		if (envs[i].env_status == ENV_RUNNABLE ||
f0104341:	8b 0d 70 82 24 f0    	mov    0xf0248270,%ecx
f0104347:	8d 41 54             	lea    0x54(%ecx),%eax
f010434a:	81 c1 54 20 02 00    	add    $0x22054,%ecx
	unsigned int accumulator = 0;
f0104350:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104355:	eb 09                	jmp    f0104360 <get_total_tickets+0x23>
	for (int i = 0; i < NENV; i++) {
f0104357:	05 88 00 00 00       	add    $0x88,%eax
f010435c:	39 c8                	cmp    %ecx,%eax
f010435e:	74 0f                	je     f010436f <get_total_tickets+0x32>
		if (envs[i].env_status == ENV_RUNNABLE ||
f0104360:	8b 10                	mov    (%eax),%edx
f0104362:	83 ea 02             	sub    $0x2,%edx
f0104365:	83 fa 01             	cmp    $0x1,%edx
f0104368:	77 ed                	ja     f0104357 <get_total_tickets+0x1a>
		    envs[i].env_status == ENV_RUNNING) {
			accumulator += envs[i].priority;
f010436a:	03 58 0c             	add    0xc(%eax),%ebx
f010436d:	eb e8                	jmp    f0104357 <get_total_tickets+0x1a>
		}
	}
	return accumulator;
}
f010436f:	89 d8                	mov    %ebx,%eax
f0104371:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104374:	c9                   	leave  
f0104375:	c3                   	ret    

f0104376 <generate_seed>:

// Genera una semilla usando el valor del contador de ciclos del procesador
uint32_t
generate_seed(void)
{
f0104376:	55                   	push   %ebp
f0104377:	89 e5                	mov    %esp,%ebp
f0104379:	83 ec 08             	sub    $0x8,%esp
	uint64_t tsc = read_tsc();
f010437c:	e8 78 ff ff ff       	call   f01042f9 <read_tsc>
	uint32_t seed = (uint32_t)(tsc & 0xFFFFFFFF);
	return seed;
}
f0104381:	c9                   	leave  
f0104382:	c3                   	ret    

f0104383 <lcg_parkmiller>:

// Genera números pseudoaleatorios usando el generador LCG de Park-Miller
uint32_t
lcg_parkmiller(uint32_t state)
{
f0104383:	55                   	push   %ebp
f0104384:	89 e5                	mov    %esp,%ebp
	uint64_t product = (uint64_t) state * 48271;
f0104386:	b8 8f bc 00 00       	mov    $0xbc8f,%eax
f010438b:	f7 65 08             	mull   0x8(%ebp)
	uint32_t x = (product & 0x7fffffff) + (product >> 31);
f010438e:	89 c1                	mov    %eax,%ecx
f0104390:	81 e1 ff ff ff 7f    	and    $0x7fffffff,%ecx
f0104396:	0f ac d0 1f          	shrd   $0x1f,%edx,%eax
f010439a:	c1 ea 1f             	shr    $0x1f,%edx
f010439d:	8d 14 01             	lea    (%ecx,%eax,1),%edx

	x = (x & 0x7fffffff) + (x >> 31);
f01043a0:	89 d0                	mov    %edx,%eax
f01043a2:	25 ff ff ff 7f       	and    $0x7fffffff,%eax
f01043a7:	c1 ea 1f             	shr    $0x1f,%edx
f01043aa:	01 d0                	add    %edx,%eax

	return state = x;
}
f01043ac:	5d                   	pop    %ebp
f01043ad:	c3                   	ret    

f01043ae <reset_priorities>:

void
reset_priorities(void)
{
	timeslice_count++;
f01043ae:	a1 a4 9a 24 f0       	mov    0xf0249aa4,%eax
f01043b3:	83 c0 01             	add    $0x1,%eax
	if (timeslice_count < BOOST_TIME) {
f01043b6:	3d c7 00 00 00       	cmp    $0xc7,%eax
f01043bb:	7e 38                	jle    f01043f5 <reset_priorities+0x47>
		return;
	}

	timeslice_count = 0;
f01043bd:	c7 05 a4 9a 24 f0 00 	movl   $0x0,0xf0249aa4
f01043c4:	00 00 00 
	for (int i = 0; i < NENV; i++) {
		if (envs[i].env_status == ENV_RUNNABLE ||
f01043c7:	8b 0d 70 82 24 f0    	mov    0xf0248270,%ecx
f01043cd:	8d 41 54             	lea    0x54(%ecx),%eax
f01043d0:	81 c1 54 20 02 00    	add    $0x22054,%ecx
f01043d6:	eb 09                	jmp    f01043e1 <reset_priorities+0x33>
	for (int i = 0; i < NENV; i++) {
f01043d8:	05 88 00 00 00       	add    $0x88,%eax
f01043dd:	39 c8                	cmp    %ecx,%eax
f01043df:	74 13                	je     f01043f4 <reset_priorities+0x46>
		if (envs[i].env_status == ENV_RUNNABLE ||
f01043e1:	8b 10                	mov    (%eax),%edx
f01043e3:	83 ea 02             	sub    $0x2,%edx
f01043e6:	83 fa 01             	cmp    $0x1,%edx
f01043e9:	77 ed                	ja     f01043d8 <reset_priorities+0x2a>
		    envs[i].env_status == ENV_RUNNING) {
			envs[i].priority = MAX_TICKETS;
f01043eb:	c7 40 0c 64 00 00 00 	movl   $0x64,0xc(%eax)
f01043f2:	eb e4                	jmp    f01043d8 <reset_priorities+0x2a>
f01043f4:	c3                   	ret    
	timeslice_count++;
f01043f5:	a3 a4 9a 24 f0       	mov    %eax,0xf0249aa4
		}
	}
}
f01043fa:	c3                   	ret    

f01043fb <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f01043fb:	55                   	push   %ebp
f01043fc:	89 e5                	mov    %esp,%ebp
f01043fe:	56                   	push   %esi
f01043ff:	53                   	push   %ebx
f0104400:	a1 70 82 24 f0       	mov    0xf0248270,%eax
f0104405:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104408:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f010440d:	8b 02                	mov    (%edx),%eax
f010440f:	83 e8 01             	sub    $0x1,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104412:	83 f8 02             	cmp    $0x2,%eax
f0104415:	0f 86 a7 00 00 00    	jbe    f01044c2 <sched_halt+0xc7>
	for (i = 0; i < NENV; i++) {
f010441b:	83 c1 01             	add    $0x1,%ecx
f010441e:	81 c2 88 00 00 00    	add    $0x88,%edx
f0104424:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f010442a:	75 e1                	jne    f010440d <sched_halt+0x12>
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
		cprintf("No runnable environments in the system!\n");
f010442c:	83 ec 0c             	sub    $0xc,%esp
f010442f:	68 d0 7c 10 f0       	push   $0xf0107cd0
f0104434:	e8 81 f3 ff ff       	call   f01037ba <cprintf>
		cprintf("Scheduler Statistics:\n");
f0104439:	c7 04 24 82 7d 10 f0 	movl   $0xf0107d82,(%esp)
f0104440:	e8 75 f3 ff ff       	call   f01037ba <cprintf>
		cprintf("Number of scheduler calls: %d\n",
f0104445:	83 c4 08             	add    $0x8,%esp
f0104448:	ff 35 a0 8a 24 f0    	push   0xf0248aa0
f010444e:	68 fc 7c 10 f0       	push   $0xf0107cfc
f0104453:	e8 62 f3 ff ff       	call   f01037ba <cprintf>
		        scheduler_stats.num_sched_calls);
		cprintf("Execution statistics per process:\n");
f0104458:	c7 04 24 1c 7d 10 f0 	movl   $0xf0107d1c,(%esp)
f010445f:	e8 56 f3 ff ff       	call   f01037ba <cprintf>
f0104464:	83 c4 10             	add    $0x10,%esp
f0104467:	be 00 00 00 00       	mov    $0x0,%esi

		for (int i = 0; i < NENV; i++) {
f010446c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104471:	eb 11                	jmp    f0104484 <sched_halt+0x89>
f0104473:	83 c3 01             	add    $0x1,%ebx
f0104476:	81 c6 88 00 00 00    	add    $0x88,%esi
f010447c:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0104482:	74 2f                	je     f01044b3 <sched_halt+0xb8>
			if (scheduler_stats.num_executions[i] > 0) {
f0104484:	8b 04 9d a4 8a 24 f0 	mov    -0xfdb755c(,%ebx,4),%eax
f010448b:	85 c0                	test   %eax,%eax
f010448d:	7e e4                	jle    f0104473 <sched_halt+0x78>
				cprintf("Process id: %d: Executions: %d, Start "
				        "Time: %llu, End Time %llu\n ",
				        envs[i].env_id,
				        scheduler_stats.num_executions[i],
				        envs[i].start_time,
				        envs[i].end_time);
f010448f:	89 f2                	mov    %esi,%edx
f0104491:	03 15 70 82 24 f0    	add    0xf0248270,%edx
				cprintf("Process id: %d: Executions: %d, Start "
f0104497:	83 ec 0c             	sub    $0xc,%esp
f010449a:	ff 72 68             	push   0x68(%edx)
f010449d:	ff 72 64             	push   0x64(%edx)
f01044a0:	50                   	push   %eax
f01044a1:	ff 72 48             	push   0x48(%edx)
f01044a4:	68 40 7d 10 f0       	push   $0xf0107d40
f01044a9:	e8 0c f3 ff ff       	call   f01037ba <cprintf>
f01044ae:	83 c4 20             	add    $0x20,%esp
f01044b1:	eb c0                	jmp    f0104473 <sched_halt+0x78>
			}
		}
		while (1)
			monitor(NULL);
f01044b3:	83 ec 0c             	sub    $0xc,%esp
f01044b6:	6a 00                	push   $0x0
f01044b8:	e8 39 c6 ff ff       	call   f0100af6 <monitor>
f01044bd:	83 c4 10             	add    $0x10,%esp
f01044c0:	eb f1                	jmp    f01044b3 <sched_halt+0xb8>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f01044c2:	e8 a1 1a 00 00       	call   f0105f68 <cpunum>
f01044c7:	6b c0 74             	imul   $0x74,%eax,%eax
f01044ca:	c7 80 28 a0 28 f0 00 	movl   $0x0,-0xfd75fd8(%eax)
f01044d1:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f01044d4:	8b 0d 5c 82 24 f0    	mov    0xf024825c,%ecx
f01044da:	ba c9 00 00 00       	mov    $0xc9,%edx
f01044df:	b8 99 7d 10 f0       	mov    $0xf0107d99,%eax
f01044e4:	e8 1b fe ff ff       	call   f0104304 <_paddr>
f01044e9:	e8 07 fe ff ff       	call   f01042f5 <lcr3>

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f01044ee:	e8 75 1a 00 00       	call   f0105f68 <cpunum>
f01044f3:	6b c0 74             	imul   $0x74,%eax,%eax
f01044f6:	05 24 a0 28 f0       	add    $0xf028a024,%eax
f01044fb:	ba 02 00 00 00       	mov    $0x2,%edx
f0104500:	e8 f7 fd ff ff       	call   f01042fc <xchg>

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();
f0104505:	e8 1c fe ff ff       	call   f0104326 <unlock_kernel>
	             "sti\n"
	             "1:\n"
	             "hlt\n"
	             "jmp 1b\n"
	             :
	             : "a"(thiscpu->cpu_ts.ts_esp0));
f010450a:	e8 59 1a 00 00       	call   f0105f68 <cpunum>
f010450f:	6b c0 74             	imul   $0x74,%eax,%eax
	asm volatile("movl $0, %%ebp\n"
f0104512:	8b 80 30 a0 28 f0    	mov    -0xfd75fd0(%eax),%eax
f0104518:	bd 00 00 00 00       	mov    $0x0,%ebp
f010451d:	89 c4                	mov    %eax,%esp
f010451f:	6a 00                	push   $0x0
f0104521:	6a 00                	push   $0x0
f0104523:	fb                   	sti    
f0104524:	f4                   	hlt    
f0104525:	eb fd                	jmp    f0104524 <sched_halt+0x129>
}
f0104527:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010452a:	5b                   	pop    %ebx
f010452b:	5e                   	pop    %esi
f010452c:	5d                   	pop    %ebp
f010452d:	c3                   	ret    

f010452e <sched_yield>:
{
f010452e:	55                   	push   %ebp
f010452f:	89 e5                	mov    %esp,%ebp
f0104531:	57                   	push   %edi
f0104532:	56                   	push   %esi
f0104533:	53                   	push   %ebx
f0104534:	83 ec 1c             	sub    $0x1c,%esp
	scheduler_stats.num_sched_calls++;
f0104537:	83 05 a0 8a 24 f0 01 	addl   $0x1,0xf0248aa0
	int total_tickets = get_total_tickets();
f010453e:	e8 fa fd ff ff       	call   f010433d <get_total_tickets>
f0104543:	89 c3                	mov    %eax,%ebx
	uint32_t seed = generate_seed();
f0104545:	e8 2c fe ff ff       	call   f0104376 <generate_seed>
	uint32_t winner = lcg_parkmiller(seed) % total_tickets;
f010454a:	83 ec 0c             	sub    $0xc,%esp
f010454d:	50                   	push   %eax
f010454e:	e8 30 fe ff ff       	call   f0104383 <lcg_parkmiller>
f0104553:	83 c4 10             	add    $0x10,%esp
f0104556:	ba 00 00 00 00       	mov    $0x0,%edx
f010455b:	f7 f3                	div    %ebx
f010455d:	89 55 e0             	mov    %edx,-0x20(%ebp)
	int start = curenv ? ENVX(curenv->env_id) + 1 : 0;
f0104560:	e8 03 1a 00 00       	call   f0105f68 <cpunum>
f0104565:	6b c0 74             	imul   $0x74,%eax,%eax
f0104568:	ba 00 00 00 00       	mov    $0x0,%edx
f010456d:	83 b8 28 a0 28 f0 00 	cmpl   $0x0,-0xfd75fd8(%eax)
f0104574:	74 1a                	je     f0104590 <sched_yield+0x62>
f0104576:	e8 ed 19 00 00       	call   f0105f68 <cpunum>
f010457b:	6b c0 74             	imul   $0x74,%eax,%eax
f010457e:	8b 80 28 a0 28 f0    	mov    -0xfd75fd8(%eax),%eax
f0104584:	8b 50 48             	mov    0x48(%eax),%edx
f0104587:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f010458d:	83 c2 01             	add    $0x1,%edx
		if (envs[i].env_status == ENV_RUNNABLE) {
f0104590:	8b 3d 70 82 24 f0    	mov    0xf0248270,%edi
f0104596:	89 d0                	mov    %edx,%eax
f0104598:	81 c2 00 04 00 00    	add    $0x400,%edx
	int accumulator = 0;
f010459e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f01045a5:	eb 07                	jmp    f01045ae <sched_yield+0x80>
	for (int j = 0; j < NENV; j++) {
f01045a7:	83 c0 01             	add    $0x1,%eax
f01045aa:	39 d0                	cmp    %edx,%eax
f01045ac:	74 6a                	je     f0104618 <sched_yield+0xea>
		int i = (start + j) % NENV;
f01045ae:	89 c1                	mov    %eax,%ecx
f01045b0:	c1 f9 1f             	sar    $0x1f,%ecx
f01045b3:	c1 e9 16             	shr    $0x16,%ecx
f01045b6:	8d 1c 08             	lea    (%eax,%ecx,1),%ebx
f01045b9:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f01045bf:	29 cb                	sub    %ecx,%ebx
		if (envs[i].env_status == ENV_RUNNABLE) {
f01045c1:	69 db 88 00 00 00    	imul   $0x88,%ebx,%ebx
f01045c7:	8d 34 1f             	lea    (%edi,%ebx,1),%esi
f01045ca:	83 7e 54 02          	cmpl   $0x2,0x54(%esi)
f01045ce:	75 d7                	jne    f01045a7 <sched_yield+0x79>
			accumulator += envs[i].priority;
f01045d0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01045d3:	03 4e 60             	add    0x60(%esi),%ecx
f01045d6:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
			if (accumulator > winner) {
f01045d9:	3b 4d e0             	cmp    -0x20(%ebp),%ecx
f01045dc:	76 c9                	jbe    f01045a7 <sched_yield+0x79>
				scheduler_stats.num_executions[ENVX(envs[i].env_id)]++;
f01045de:	8b 46 48             	mov    0x48(%esi),%eax
f01045e1:	25 ff 03 00 00       	and    $0x3ff,%eax
f01045e6:	83 04 85 a4 8a 24 f0 	addl   $0x1,-0xfdb755c(,%eax,4)
f01045ed:	01 
				envs[i].start_time = read_tsc();
f01045ee:	e8 06 fd ff ff       	call   f01042f9 <read_tsc>
f01045f3:	89 46 64             	mov    %eax,0x64(%esi)
				if (envs[i].priority > MIN_TICKETS) {
f01045f6:	8b 46 60             	mov    0x60(%esi),%eax
f01045f9:	83 f8 04             	cmp    $0x4,%eax
f01045fc:	76 06                	jbe    f0104604 <sched_yield+0xd6>
					envs[i].priority -= MIN_TICKETS;
f01045fe:	83 e8 04             	sub    $0x4,%eax
f0104601:	89 46 60             	mov    %eax,0x60(%esi)
				reset_priorities();
f0104604:	e8 a5 fd ff ff       	call   f01043ae <reset_priorities>
				env_run(&envs[i]);
f0104609:	83 ec 0c             	sub    $0xc,%esp
f010460c:	03 1d 70 82 24 f0    	add    0xf0248270,%ebx
f0104612:	53                   	push   %ebx
f0104613:	e8 c7 ee ff ff       	call   f01034df <env_run>
	if (curenv && curenv->env_status == ENV_RUNNING) {
f0104618:	e8 4b 19 00 00       	call   f0105f68 <cpunum>
f010461d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104620:	83 b8 28 a0 28 f0 00 	cmpl   $0x0,-0xfd75fd8(%eax)
f0104627:	74 14                	je     f010463d <sched_yield+0x10f>
f0104629:	e8 3a 19 00 00       	call   f0105f68 <cpunum>
f010462e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104631:	8b 80 28 a0 28 f0    	mov    -0xfd75fd8(%eax),%eax
f0104637:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010463b:	74 0d                	je     f010464a <sched_yield+0x11c>
	sched_halt();
f010463d:	e8 b9 fd ff ff       	call   f01043fb <sched_halt>
}
f0104642:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104645:	5b                   	pop    %ebx
f0104646:	5e                   	pop    %esi
f0104647:	5f                   	pop    %edi
f0104648:	5d                   	pop    %ebp
f0104649:	c3                   	ret    
		if (curenv->priority > MIN_TICKETS) {
f010464a:	e8 19 19 00 00       	call   f0105f68 <cpunum>
f010464f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104652:	8b 80 28 a0 28 f0    	mov    -0xfd75fd8(%eax),%eax
f0104658:	83 78 60 04          	cmpl   $0x4,0x60(%eax)
f010465c:	77 1b                	ja     f0104679 <sched_yield+0x14b>
		reset_priorities();
f010465e:	e8 4b fd ff ff       	call   f01043ae <reset_priorities>
		env_run(curenv);  // If no runnable environments, continue running
f0104663:	e8 00 19 00 00       	call   f0105f68 <cpunum>
f0104668:	83 ec 0c             	sub    $0xc,%esp
f010466b:	6b c0 74             	imul   $0x74,%eax,%eax
f010466e:	ff b0 28 a0 28 f0    	push   -0xfd75fd8(%eax)
f0104674:	e8 66 ee ff ff       	call   f01034df <env_run>
			curenv->priority -= MIN_TICKETS;
f0104679:	e8 ea 18 00 00       	call   f0105f68 <cpunum>
f010467e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104681:	8b 80 28 a0 28 f0    	mov    -0xfd75fd8(%eax),%eax
f0104687:	83 68 60 04          	subl   $0x4,0x60(%eax)
f010468b:	eb d1                	jmp    f010465e <sched_yield+0x130>

f010468d <read_tsc>:
	asm volatile("rdtsc" : "=A"(tsc));
f010468d:	0f 31                	rdtsc  
}
f010468f:	c3                   	ret    

f0104690 <check_perm>:


static int
check_perm(int perm, pte_t *pte)
{
	if (perm & (~PTE_SYSCALL))
f0104690:	89 c1                	mov    %eax,%ecx
f0104692:	81 e1 f8 f1 ff ff    	and    $0xfffff1f8,%ecx
f0104698:	75 2f                	jne    f01046c9 <check_perm+0x39>
{
f010469a:	55                   	push   %ebp
f010469b:	89 e5                	mov    %esp,%ebp
f010469d:	53                   	push   %ebx
		return -E_INVAL;

	if (!(perm & PTE_P) || !(perm & PTE_U))
f010469e:	89 c3                	mov    %eax,%ebx
f01046a0:	83 e3 05             	and    $0x5,%ebx
f01046a3:	83 fb 05             	cmp    $0x5,%ebx
f01046a6:	75 29                	jne    f01046d1 <check_perm+0x41>
		return -E_INVAL;

	if (pte) {
f01046a8:	85 d2                	test   %edx,%edx
f01046aa:	74 35                	je     f01046e1 <check_perm+0x51>
		if (*pte && !(*pte & PTE_P))
f01046ac:	8b 12                	mov    (%edx),%edx
f01046ae:	85 d2                	test   %edx,%edx
f01046b0:	74 05                	je     f01046b7 <check_perm+0x27>
f01046b2:	f6 c2 01             	test   $0x1,%dl
f01046b5:	74 21                	je     f01046d8 <check_perm+0x48>
			return -E_INVAL;

		if ((perm & PTE_W) && !(*pte & PTE_W))
f01046b7:	83 e0 02             	and    $0x2,%eax
f01046ba:	74 23                	je     f01046df <check_perm+0x4f>
			return -E_INVAL;
f01046bc:	f6 c2 02             	test   $0x2,%dl
f01046bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01046c4:	0f 44 c8             	cmove  %eax,%ecx
f01046c7:	eb 18                	jmp    f01046e1 <check_perm+0x51>
		return -E_INVAL;
f01046c9:	b9 fd ff ff ff       	mov    $0xfffffffd,%ecx
	}
	return 0;
}
f01046ce:	89 c8                	mov    %ecx,%eax
f01046d0:	c3                   	ret    
		return -E_INVAL;
f01046d1:	b9 fd ff ff ff       	mov    $0xfffffffd,%ecx
f01046d6:	eb 09                	jmp    f01046e1 <check_perm+0x51>
			return -E_INVAL;
f01046d8:	b9 fd ff ff ff       	mov    $0xfffffffd,%ecx
f01046dd:	eb 02                	jmp    f01046e1 <check_perm+0x51>
	return 0;
f01046df:	89 c1                	mov    %eax,%ecx
}
f01046e1:	89 c8                	mov    %ecx,%eax
f01046e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01046e6:	c9                   	leave  
f01046e7:	c3                   	ret    

f01046e8 <sys_getenvid>:
}

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
f01046e8:	55                   	push   %ebp
f01046e9:	89 e5                	mov    %esp,%ebp
f01046eb:	83 ec 08             	sub    $0x8,%esp
	return curenv->env_id;
f01046ee:	e8 75 18 00 00       	call   f0105f68 <cpunum>
f01046f3:	6b c0 74             	imul   $0x74,%eax,%eax
f01046f6:	8b 80 28 a0 28 f0    	mov    -0xfd75fd8(%eax),%eax
f01046fc:	8b 40 48             	mov    0x48(%eax),%eax
}
f01046ff:	c9                   	leave  
f0104700:	c3                   	ret    

f0104701 <sys_get_priority>:
}

// Get priority of the current process
static int
sys_get_priority(void)
{
f0104701:	55                   	push   %ebp
f0104702:	89 e5                	mov    %esp,%ebp
f0104704:	83 ec 08             	sub    $0x8,%esp
	return curenv->priority;
f0104707:	e8 5c 18 00 00       	call   f0105f68 <cpunum>
f010470c:	6b c0 74             	imul   $0x74,%eax,%eax
f010470f:	8b 80 28 a0 28 f0    	mov    -0xfd75fd8(%eax),%eax
f0104715:	8b 40 60             	mov    0x60(%eax),%eax
}
f0104718:	c9                   	leave  
f0104719:	c3                   	ret    

f010471a <sys_set_priority>:

// Get priority of the current process
static int
sys_set_priority(unsigned int priority)
{
f010471a:	55                   	push   %ebp
f010471b:	89 e5                	mov    %esp,%ebp
f010471d:	53                   	push   %ebx
f010471e:	83 ec 04             	sub    $0x4,%esp
f0104721:	89 c3                	mov    %eax,%ebx
	if (priority > curenv->priority) {
f0104723:	e8 40 18 00 00       	call   f0105f68 <cpunum>
f0104728:	6b c0 74             	imul   $0x74,%eax,%eax
f010472b:	8b 80 28 a0 28 f0    	mov    -0xfd75fd8(%eax),%eax
f0104731:	39 58 60             	cmp    %ebx,0x60(%eax)
f0104734:	72 1b                	jb     f0104751 <sys_set_priority+0x37>
		return -E_INVAL;
	}
	curenv->priority = priority;
f0104736:	e8 2d 18 00 00       	call   f0105f68 <cpunum>
f010473b:	6b c0 74             	imul   $0x74,%eax,%eax
f010473e:	8b 80 28 a0 28 f0    	mov    -0xfd75fd8(%eax),%eax
f0104744:	89 58 60             	mov    %ebx,0x60(%eax)
	return 0;
f0104747:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010474c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010474f:	c9                   	leave  
f0104750:	c3                   	ret    
		return -E_INVAL;
f0104751:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104756:	eb f4                	jmp    f010474c <sys_set_priority+0x32>

f0104758 <sys_cputs>:
{
f0104758:	55                   	push   %ebp
f0104759:	89 e5                	mov    %esp,%ebp
f010475b:	56                   	push   %esi
f010475c:	53                   	push   %ebx
f010475d:	89 c6                	mov    %eax,%esi
f010475f:	89 d3                	mov    %edx,%ebx
	user_mem_assert(curenv, s, len, PTE_P | PTE_W | PTE_U);
f0104761:	e8 02 18 00 00       	call   f0105f68 <cpunum>
f0104766:	6a 07                	push   $0x7
f0104768:	53                   	push   %ebx
f0104769:	56                   	push   %esi
f010476a:	6b c0 74             	imul   $0x74,%eax,%eax
f010476d:	ff b0 28 a0 28 f0    	push   -0xfd75fd8(%eax)
f0104773:	e8 12 e6 ff ff       	call   f0102d8a <user_mem_assert>
	cprintf("%.*s", len, s);
f0104778:	83 c4 0c             	add    $0xc,%esp
f010477b:	56                   	push   %esi
f010477c:	53                   	push   %ebx
f010477d:	68 a6 7d 10 f0       	push   $0xf0107da6
f0104782:	e8 33 f0 ff ff       	call   f01037ba <cprintf>
}
f0104787:	83 c4 10             	add    $0x10,%esp
f010478a:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010478d:	5b                   	pop    %ebx
f010478e:	5e                   	pop    %esi
f010478f:	5d                   	pop    %ebp
f0104790:	c3                   	ret    

f0104791 <sys_env_set_status>:
{
f0104791:	55                   	push   %ebp
f0104792:	89 e5                	mov    %esp,%ebp
f0104794:	53                   	push   %ebx
f0104795:	83 ec 14             	sub    $0x14,%esp
f0104798:	89 d3                	mov    %edx,%ebx
	if ((status != ENV_RUNNABLE) && (status != ENV_NOT_RUNNABLE))
f010479a:	8d 52 fe             	lea    -0x2(%edx),%edx
f010479d:	f7 c2 fd ff ff ff    	test   $0xfffffffd,%edx
f01047a3:	75 21                	jne    f01047c6 <sys_env_set_status+0x35>
	if ((r = envid2env(envid, &env, 1)))
f01047a5:	83 ec 04             	sub    $0x4,%esp
f01047a8:	6a 01                	push   $0x1
f01047aa:	8d 55 f4             	lea    -0xc(%ebp),%edx
f01047ad:	52                   	push   %edx
f01047ae:	50                   	push   %eax
f01047af:	e8 e1 e8 ff ff       	call   f0103095 <envid2env>
f01047b4:	83 c4 10             	add    $0x10,%esp
f01047b7:	85 c0                	test   %eax,%eax
f01047b9:	75 06                	jne    f01047c1 <sys_env_set_status+0x30>
	env->env_status = status;
f01047bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01047be:	89 5a 54             	mov    %ebx,0x54(%edx)
}
f01047c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01047c4:	c9                   	leave  
f01047c5:	c3                   	ret    
		return -E_INVAL;
f01047c6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01047cb:	eb f4                	jmp    f01047c1 <sys_env_set_status+0x30>

f01047cd <sys_env_set_pgfault_upcall>:
{
f01047cd:	55                   	push   %ebp
f01047ce:	89 e5                	mov    %esp,%ebp
f01047d0:	56                   	push   %esi
f01047d1:	53                   	push   %ebx
f01047d2:	83 ec 14             	sub    $0x14,%esp
f01047d5:	89 d6                	mov    %edx,%esi
	if ((r = envid2env(envid, &env, 1)))
f01047d7:	6a 01                	push   $0x1
f01047d9:	8d 55 f4             	lea    -0xc(%ebp),%edx
f01047dc:	52                   	push   %edx
f01047dd:	50                   	push   %eax
f01047de:	e8 b2 e8 ff ff       	call   f0103095 <envid2env>
f01047e3:	89 c3                	mov    %eax,%ebx
f01047e5:	83 c4 10             	add    $0x10,%esp
f01047e8:	85 c0                	test   %eax,%eax
f01047ea:	74 09                	je     f01047f5 <sys_env_set_pgfault_upcall+0x28>
}
f01047ec:	89 d8                	mov    %ebx,%eax
f01047ee:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01047f1:	5b                   	pop    %ebx
f01047f2:	5e                   	pop    %esi
f01047f3:	5d                   	pop    %ebp
f01047f4:	c3                   	ret    
	user_mem_assert(env, func, PGSIZE, PTE_P | PTE_U);
f01047f5:	6a 05                	push   $0x5
f01047f7:	68 00 10 00 00       	push   $0x1000
f01047fc:	56                   	push   %esi
f01047fd:	ff 75 f4             	push   -0xc(%ebp)
f0104800:	e8 85 e5 ff ff       	call   f0102d8a <user_mem_assert>
	env->env_pgfault_upcall = func;
f0104805:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104808:	89 70 70             	mov    %esi,0x70(%eax)
	return 0;
f010480b:	83 c4 10             	add    $0x10,%esp
f010480e:	eb dc                	jmp    f01047ec <sys_env_set_pgfault_upcall+0x1f>

f0104810 <sys_env_destroy>:
{
f0104810:	55                   	push   %ebp
f0104811:	89 e5                	mov    %esp,%ebp
f0104813:	53                   	push   %ebx
f0104814:	83 ec 18             	sub    $0x18,%esp
	if ((r = envid2env(envid, &e, 1)) < 0)
f0104817:	6a 01                	push   $0x1
f0104819:	8d 55 f4             	lea    -0xc(%ebp),%edx
f010481c:	52                   	push   %edx
f010481d:	50                   	push   %eax
f010481e:	e8 72 e8 ff ff       	call   f0103095 <envid2env>
f0104823:	83 c4 10             	add    $0x10,%esp
f0104826:	85 c0                	test   %eax,%eax
f0104828:	78 63                	js     f010488d <sys_env_destroy+0x7d>
	curenv->end_time = read_tsc();
f010482a:	e8 5e fe ff ff       	call   f010468d <read_tsc>
f010482f:	89 c3                	mov    %eax,%ebx
f0104831:	e8 32 17 00 00       	call   f0105f68 <cpunum>
f0104836:	6b c0 74             	imul   $0x74,%eax,%eax
f0104839:	8b 80 28 a0 28 f0    	mov    -0xfd75fd8(%eax),%eax
f010483f:	89 58 68             	mov    %ebx,0x68(%eax)
	if (e == curenv)
f0104842:	e8 21 17 00 00       	call   f0105f68 <cpunum>
f0104847:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010484a:	6b c0 74             	imul   $0x74,%eax,%eax
f010484d:	39 90 28 a0 28 f0    	cmp    %edx,-0xfd75fd8(%eax)
f0104853:	74 3d                	je     f0104892 <sys_env_destroy+0x82>
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0104855:	8b 5a 48             	mov    0x48(%edx),%ebx
f0104858:	e8 0b 17 00 00       	call   f0105f68 <cpunum>
f010485d:	83 ec 04             	sub    $0x4,%esp
f0104860:	53                   	push   %ebx
f0104861:	6b c0 74             	imul   $0x74,%eax,%eax
f0104864:	8b 80 28 a0 28 f0    	mov    -0xfd75fd8(%eax),%eax
f010486a:	ff 70 48             	push   0x48(%eax)
f010486d:	68 c6 7d 10 f0       	push   $0xf0107dc6
f0104872:	e8 43 ef ff ff       	call   f01037ba <cprintf>
f0104877:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f010487a:	83 ec 0c             	sub    $0xc,%esp
f010487d:	ff 75 f4             	push   -0xc(%ebp)
f0104880:	e8 d7 eb ff ff       	call   f010345c <env_destroy>
	return 0;
f0104885:	83 c4 10             	add    $0x10,%esp
f0104888:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010488d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104890:	c9                   	leave  
f0104891:	c3                   	ret    
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104892:	e8 d1 16 00 00       	call   f0105f68 <cpunum>
f0104897:	83 ec 08             	sub    $0x8,%esp
f010489a:	6b c0 74             	imul   $0x74,%eax,%eax
f010489d:	8b 80 28 a0 28 f0    	mov    -0xfd75fd8(%eax),%eax
f01048a3:	ff 70 48             	push   0x48(%eax)
f01048a6:	68 ab 7d 10 f0       	push   $0xf0107dab
f01048ab:	e8 0a ef ff ff       	call   f01037ba <cprintf>
f01048b0:	83 c4 10             	add    $0x10,%esp
f01048b3:	eb c5                	jmp    f010487a <sys_env_destroy+0x6a>

f01048b5 <sys_cgetc>:
{
f01048b5:	55                   	push   %ebp
f01048b6:	89 e5                	mov    %esp,%ebp
f01048b8:	83 ec 08             	sub    $0x8,%esp
	return cons_getc();
f01048bb:	e8 a7 bf ff ff       	call   f0100867 <cons_getc>
}
f01048c0:	c9                   	leave  
f01048c1:	c3                   	ret    

f01048c2 <sys_exofork>:
{
f01048c2:	55                   	push   %ebp
f01048c3:	89 e5                	mov    %esp,%ebp
f01048c5:	57                   	push   %edi
f01048c6:	56                   	push   %esi
f01048c7:	83 ec 10             	sub    $0x10,%esp
	if ((r = env_alloc(&newenv, curenv->env_id)))
f01048ca:	e8 99 16 00 00       	call   f0105f68 <cpunum>
f01048cf:	83 ec 08             	sub    $0x8,%esp
f01048d2:	6b c0 74             	imul   $0x74,%eax,%eax
f01048d5:	8b 80 28 a0 28 f0    	mov    -0xfd75fd8(%eax),%eax
f01048db:	ff 70 48             	push   0x48(%eax)
f01048de:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01048e1:	50                   	push   %eax
f01048e2:	e8 ce e8 ff ff       	call   f01031b5 <env_alloc>
f01048e7:	83 c4 10             	add    $0x10,%esp
f01048ea:	85 c0                	test   %eax,%eax
f01048ec:	74 07                	je     f01048f5 <sys_exofork+0x33>
}
f01048ee:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01048f1:	5e                   	pop    %esi
f01048f2:	5f                   	pop    %edi
f01048f3:	5d                   	pop    %ebp
f01048f4:	c3                   	ret    
	newenv->env_status = ENV_NOT_RUNNABLE;
f01048f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01048f8:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	newenv->env_tf = curenv->env_tf;
f01048ff:	e8 64 16 00 00       	call   f0105f68 <cpunum>
f0104904:	6b c0 74             	imul   $0x74,%eax,%eax
f0104907:	8b b0 28 a0 28 f0    	mov    -0xfd75fd8(%eax),%esi
f010490d:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104912:	8b 7d f4             	mov    -0xc(%ebp),%edi
f0104915:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	newenv->env_tf.tf_regs.reg_eax = 0;
f0104917:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010491a:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	newenv->priority = curenv->priority;
f0104921:	e8 42 16 00 00       	call   f0105f68 <cpunum>
f0104926:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104929:	6b c0 74             	imul   $0x74,%eax,%eax
f010492c:	8b 80 28 a0 28 f0    	mov    -0xfd75fd8(%eax),%eax
f0104932:	8b 40 60             	mov    0x60(%eax),%eax
f0104935:	89 42 60             	mov    %eax,0x60(%edx)
	return newenv->env_id;
f0104938:	8b 42 48             	mov    0x48(%edx),%eax
f010493b:	eb b1                	jmp    f01048ee <sys_exofork+0x2c>

f010493d <env_page_alloc>:
{
f010493d:	55                   	push   %ebp
f010493e:	89 e5                	mov    %esp,%ebp
f0104940:	57                   	push   %edi
f0104941:	56                   	push   %esi
f0104942:	53                   	push   %ebx
f0104943:	83 ec 0c             	sub    $0xc,%esp
f0104946:	89 c6                	mov    %eax,%esi
f0104948:	89 d7                	mov    %edx,%edi
f010494a:	89 cb                	mov    %ecx,%ebx
	int err = check_perm(perm, NULL);
f010494c:	ba 00 00 00 00       	mov    $0x0,%edx
f0104951:	89 c8                	mov    %ecx,%eax
f0104953:	e8 38 fd ff ff       	call   f0104690 <check_perm>
	if (err < 0)
f0104958:	85 c0                	test   %eax,%eax
f010495a:	78 1f                	js     f010497b <env_page_alloc+0x3e>
	struct PageInfo *p = page_alloc(ALLOC_ZERO);
f010495c:	83 ec 0c             	sub    $0xc,%esp
f010495f:	6a 01                	push   $0x1
f0104961:	e8 ee c9 ff ff       	call   f0101354 <page_alloc>
	if (!p)
f0104966:	83 c4 10             	add    $0x10,%esp
f0104969:	85 c0                	test   %eax,%eax
f010496b:	74 16                	je     f0104983 <env_page_alloc+0x46>
	return page_insert(env->env_pgdir, p, va, perm);
f010496d:	53                   	push   %ebx
f010496e:	57                   	push   %edi
f010496f:	50                   	push   %eax
f0104970:	ff 76 6c             	push   0x6c(%esi)
f0104973:	e8 bf d0 ff ff       	call   f0101a37 <page_insert>
f0104978:	83 c4 10             	add    $0x10,%esp
}
f010497b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010497e:	5b                   	pop    %ebx
f010497f:	5e                   	pop    %esi
f0104980:	5f                   	pop    %edi
f0104981:	5d                   	pop    %ebp
f0104982:	c3                   	ret    
		return -E_NO_MEM;
f0104983:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0104988:	eb f1                	jmp    f010497b <env_page_alloc+0x3e>

f010498a <sys_page_alloc>:
	if (((uint32_t) va >= UTOP) || ((uint32_t) va % PGSIZE))
f010498a:	81 fa ff ff bf ee    	cmp    $0xeebfffff,%edx
f0104990:	77 42                	ja     f01049d4 <sys_page_alloc+0x4a>
{
f0104992:	55                   	push   %ebp
f0104993:	89 e5                	mov    %esp,%ebp
f0104995:	56                   	push   %esi
f0104996:	53                   	push   %ebx
f0104997:	83 ec 10             	sub    $0x10,%esp
f010499a:	89 d3                	mov    %edx,%ebx
f010499c:	89 ce                	mov    %ecx,%esi
	if (((uint32_t) va >= UTOP) || ((uint32_t) va % PGSIZE))
f010499e:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f01049a4:	75 34                	jne    f01049da <sys_page_alloc+0x50>
	if ((r = envid2env(envid, &env, 1)))
f01049a6:	83 ec 04             	sub    $0x4,%esp
f01049a9:	6a 01                	push   $0x1
f01049ab:	8d 55 f4             	lea    -0xc(%ebp),%edx
f01049ae:	52                   	push   %edx
f01049af:	50                   	push   %eax
f01049b0:	e8 e0 e6 ff ff       	call   f0103095 <envid2env>
f01049b5:	83 c4 10             	add    $0x10,%esp
f01049b8:	85 c0                	test   %eax,%eax
f01049ba:	74 07                	je     f01049c3 <sys_page_alloc+0x39>
}
f01049bc:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01049bf:	5b                   	pop    %ebx
f01049c0:	5e                   	pop    %esi
f01049c1:	5d                   	pop    %ebp
f01049c2:	c3                   	ret    
	return env_page_alloc(env, va, perm | PTE_U | PTE_P);
f01049c3:	83 ce 05             	or     $0x5,%esi
f01049c6:	89 f1                	mov    %esi,%ecx
f01049c8:	89 da                	mov    %ebx,%edx
f01049ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01049cd:	e8 6b ff ff ff       	call   f010493d <env_page_alloc>
f01049d2:	eb e8                	jmp    f01049bc <sys_page_alloc+0x32>
		return -E_INVAL;
f01049d4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
f01049d9:	c3                   	ret    
		return -E_INVAL;
f01049da:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01049df:	eb db                	jmp    f01049bc <sys_page_alloc+0x32>

f01049e1 <env_page_map>:
{
f01049e1:	55                   	push   %ebp
f01049e2:	89 e5                	mov    %esp,%ebp
f01049e4:	56                   	push   %esi
f01049e5:	53                   	push   %ebx
f01049e6:	83 ec 14             	sub    $0x14,%esp
f01049e9:	89 cb                	mov    %ecx,%ebx
f01049eb:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct PageInfo *page = page_lookup(srcenv->env_pgdir, srcva, &srcpte);
f01049ee:	8d 4d f4             	lea    -0xc(%ebp),%ecx
f01049f1:	51                   	push   %ecx
f01049f2:	52                   	push   %edx
f01049f3:	ff 70 6c             	push   0x6c(%eax)
f01049f6:	e8 ad ce ff ff       	call   f01018a8 <page_lookup>
	if (!page)
f01049fb:	83 c4 10             	add    $0x10,%esp
f01049fe:	85 c0                	test   %eax,%eax
f0104a00:	74 29                	je     f0104a2b <env_page_map+0x4a>
f0104a02:	89 c2                	mov    %eax,%edx
	if ((perm & PTE_W) & ~(PTE_W & *srcpte))
f0104a04:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104a07:	8b 00                	mov    (%eax),%eax
f0104a09:	83 e0 02             	and    $0x2,%eax
f0104a0c:	f7 d0                	not    %eax
f0104a0e:	21 f0                	and    %esi,%eax
f0104a10:	a8 02                	test   $0x2,%al
f0104a12:	75 1e                	jne    f0104a32 <env_page_map+0x51>
	return page_insert(dstenv->env_pgdir, page, dstva, perm);
f0104a14:	56                   	push   %esi
f0104a15:	ff 75 08             	push   0x8(%ebp)
f0104a18:	52                   	push   %edx
f0104a19:	ff 73 6c             	push   0x6c(%ebx)
f0104a1c:	e8 16 d0 ff ff       	call   f0101a37 <page_insert>
f0104a21:	83 c4 10             	add    $0x10,%esp
}
f0104a24:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0104a27:	5b                   	pop    %ebx
f0104a28:	5e                   	pop    %esi
f0104a29:	5d                   	pop    %ebp
f0104a2a:	c3                   	ret    
		return -E_INVAL;
f0104a2b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104a30:	eb f2                	jmp    f0104a24 <env_page_map+0x43>
		return -E_INVAL;
f0104a32:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104a37:	eb eb                	jmp    f0104a24 <env_page_map+0x43>

f0104a39 <sys_page_map>:
{
f0104a39:	55                   	push   %ebp
f0104a3a:	89 e5                	mov    %esp,%ebp
f0104a3c:	57                   	push   %edi
f0104a3d:	56                   	push   %esi
f0104a3e:	53                   	push   %ebx
f0104a3f:	83 ec 1c             	sub    $0x1c,%esp
f0104a42:	8b 7d 08             	mov    0x8(%ebp),%edi
	if (((uint32_t) srcva >= UTOP) || ((uint32_t) srcva % PGSIZE))
f0104a45:	81 fa ff ff bf ee    	cmp    $0xeebfffff,%edx
f0104a4b:	77 6d                	ja     f0104aba <sys_page_map+0x81>
f0104a4d:	89 d3                	mov    %edx,%ebx
f0104a4f:	89 ce                	mov    %ecx,%esi
f0104a51:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0104a57:	75 68                	jne    f0104ac1 <sys_page_map+0x88>
	if (((uint32_t) dstva >= UTOP) || ((uint32_t) dstva % PGSIZE))
f0104a59:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f0104a5f:	77 67                	ja     f0104ac8 <sys_page_map+0x8f>
f0104a61:	f7 c7 ff 0f 00 00    	test   $0xfff,%edi
f0104a67:	75 66                	jne    f0104acf <sys_page_map+0x96>
	if ((r = envid2env(srcenvid, &srcenv, 1)))
f0104a69:	83 ec 04             	sub    $0x4,%esp
f0104a6c:	6a 01                	push   $0x1
f0104a6e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104a71:	52                   	push   %edx
f0104a72:	50                   	push   %eax
f0104a73:	e8 1d e6 ff ff       	call   f0103095 <envid2env>
f0104a78:	83 c4 10             	add    $0x10,%esp
f0104a7b:	85 c0                	test   %eax,%eax
f0104a7d:	74 08                	je     f0104a87 <sys_page_map+0x4e>
}
f0104a7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104a82:	5b                   	pop    %ebx
f0104a83:	5e                   	pop    %esi
f0104a84:	5f                   	pop    %edi
f0104a85:	5d                   	pop    %ebp
f0104a86:	c3                   	ret    
	if ((r = envid2env(dstenvid, &dstenv, 1)))
f0104a87:	83 ec 04             	sub    $0x4,%esp
f0104a8a:	6a 01                	push   $0x1
f0104a8c:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104a8f:	50                   	push   %eax
f0104a90:	56                   	push   %esi
f0104a91:	e8 ff e5 ff ff       	call   f0103095 <envid2env>
f0104a96:	83 c4 10             	add    $0x10,%esp
f0104a99:	85 c0                	test   %eax,%eax
f0104a9b:	75 e2                	jne    f0104a7f <sys_page_map+0x46>
	return env_page_map(srcenv, srcva, dstenv, dstva, PTE_P | PTE_U | perm);
f0104a9d:	83 ec 08             	sub    $0x8,%esp
f0104aa0:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104aa3:	83 c8 05             	or     $0x5,%eax
f0104aa6:	50                   	push   %eax
f0104aa7:	57                   	push   %edi
f0104aa8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104aab:	89 da                	mov    %ebx,%edx
f0104aad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104ab0:	e8 2c ff ff ff       	call   f01049e1 <env_page_map>
f0104ab5:	83 c4 10             	add    $0x10,%esp
f0104ab8:	eb c5                	jmp    f0104a7f <sys_page_map+0x46>
		return -E_INVAL;
f0104aba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104abf:	eb be                	jmp    f0104a7f <sys_page_map+0x46>
f0104ac1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104ac6:	eb b7                	jmp    f0104a7f <sys_page_map+0x46>
		return -E_INVAL;
f0104ac8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104acd:	eb b0                	jmp    f0104a7f <sys_page_map+0x46>
f0104acf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104ad4:	eb a9                	jmp    f0104a7f <sys_page_map+0x46>

f0104ad6 <sys_ipc_try_send>:
{
f0104ad6:	55                   	push   %ebp
f0104ad7:	89 e5                	mov    %esp,%ebp
f0104ad9:	57                   	push   %edi
f0104ada:	56                   	push   %esi
f0104adb:	53                   	push   %ebx
f0104adc:	83 ec 30             	sub    $0x30,%esp
f0104adf:	89 d7                	mov    %edx,%edi
f0104ae1:	89 ce                	mov    %ecx,%esi
	if ((r = envid2env(envid, &dstenv, 0)))
f0104ae3:	6a 00                	push   $0x0
f0104ae5:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104ae8:	52                   	push   %edx
f0104ae9:	50                   	push   %eax
f0104aea:	e8 a6 e5 ff ff       	call   f0103095 <envid2env>
f0104aef:	89 c3                	mov    %eax,%ebx
f0104af1:	83 c4 10             	add    $0x10,%esp
f0104af4:	85 c0                	test   %eax,%eax
f0104af6:	0f 85 99 00 00 00    	jne    f0104b95 <sys_ipc_try_send+0xbf>
	if (!dstenv->env_ipc_recving)
f0104afc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104aff:	80 78 74 00          	cmpb   $0x0,0x74(%eax)
f0104b03:	0f 84 96 00 00 00    	je     f0104b9f <sys_ipc_try_send+0xc9>
	if (((uint32_t) srcva >= UTOP)) {
f0104b09:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0104b0f:	77 4b                	ja     f0104b5c <sys_ipc_try_send+0x86>
	if ((uint32_t) srcva % PGSIZE)
f0104b11:	f7 c6 ff 0f 00 00    	test   $0xfff,%esi
f0104b17:	0f 85 89 00 00 00    	jne    f0104ba6 <sys_ipc_try_send+0xd0>
	page_lookup(curenv->env_pgdir, srcva, &srcpte);
f0104b1d:	e8 46 14 00 00       	call   f0105f68 <cpunum>
f0104b22:	83 ec 04             	sub    $0x4,%esp
f0104b25:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0104b28:	52                   	push   %edx
f0104b29:	56                   	push   %esi
f0104b2a:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b2d:	8b 80 28 a0 28 f0    	mov    -0xfd75fd8(%eax),%eax
f0104b33:	ff 70 6c             	push   0x6c(%eax)
f0104b36:	e8 6d cd ff ff       	call   f01018a8 <page_lookup>
	if (*srcpte && !(*srcpte & PTE_P))
f0104b3b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104b3e:	8b 00                	mov    (%eax),%eax
f0104b40:	83 c4 10             	add    $0x10,%esp
f0104b43:	85 c0                	test   %eax,%eax
f0104b45:	74 7c                	je     f0104bc3 <sys_ipc_try_send+0xed>
f0104b47:	a8 01                	test   $0x1,%al
f0104b49:	74 62                	je     f0104bad <sys_ipc_try_send+0xd7>
	if ((perm & PTE_W) && !(*srcpte & PTE_W))
f0104b4b:	f6 45 08 02          	testb  $0x2,0x8(%ebp)
f0104b4f:	74 78                	je     f0104bc9 <sys_ipc_try_send+0xf3>
f0104b51:	a8 02                	test   $0x2,%al
f0104b53:	75 74                	jne    f0104bc9 <sys_ipc_try_send+0xf3>
		return -E_INVAL;
f0104b55:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104b5a:	eb 39                	jmp    f0104b95 <sys_ipc_try_send+0xbf>
		dstenv->env_ipc_perm = 0;
f0104b5c:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
f0104b63:	00 00 00 
	dstenv->env_ipc_from = (envid_t) curenv->env_id;
f0104b66:	e8 fd 13 00 00       	call   f0105f68 <cpunum>
f0104b6b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104b6e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b71:	8b 80 28 a0 28 f0    	mov    -0xfd75fd8(%eax),%eax
f0104b77:	8b 40 48             	mov    0x48(%eax),%eax
f0104b7a:	89 82 80 00 00 00    	mov    %eax,0x80(%edx)
	dstenv->env_ipc_recving = false;
f0104b80:	c6 42 74 00          	movb   $0x0,0x74(%edx)
	dstenv->env_ipc_value = value;
f0104b84:	89 7a 7c             	mov    %edi,0x7c(%edx)
	dstenv->env_tf.tf_regs.reg_eax = 0;
f0104b87:	c7 42 1c 00 00 00 00 	movl   $0x0,0x1c(%edx)
	dstenv->env_status = ENV_RUNNABLE;
f0104b8e:	c7 42 54 02 00 00 00 	movl   $0x2,0x54(%edx)
}
f0104b95:	89 d8                	mov    %ebx,%eax
f0104b97:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104b9a:	5b                   	pop    %ebx
f0104b9b:	5e                   	pop    %esi
f0104b9c:	5f                   	pop    %edi
f0104b9d:	5d                   	pop    %ebp
f0104b9e:	c3                   	ret    
		return -E_IPC_NOT_RECV;
f0104b9f:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
f0104ba4:	eb ef                	jmp    f0104b95 <sys_ipc_try_send+0xbf>
		return -E_INVAL;
f0104ba6:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104bab:	eb e8                	jmp    f0104b95 <sys_ipc_try_send+0xbf>
		return -E_INVAL;
f0104bad:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104bb2:	eb e1                	jmp    f0104b95 <sys_ipc_try_send+0xbf>
			return r;
f0104bb4:	89 c3                	mov    %eax,%ebx
f0104bb6:	eb dd                	jmp    f0104b95 <sys_ipc_try_send+0xbf>
			return r;
f0104bb8:	89 c3                	mov    %eax,%ebx
f0104bba:	eb d9                	jmp    f0104b95 <sys_ipc_try_send+0xbf>
		return -E_INVAL;
f0104bbc:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104bc1:	eb d2                	jmp    f0104b95 <sys_ipc_try_send+0xbf>
	if ((perm & PTE_W) && !(*srcpte & PTE_W))
f0104bc3:	f6 45 08 02          	testb  $0x2,0x8(%ebp)
f0104bc7:	75 f3                	jne    f0104bbc <sys_ipc_try_send+0xe6>
	if (dstenv->env_ipc_dstva) {
f0104bc9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104bcc:	8b 50 78             	mov    0x78(%eax),%edx
f0104bcf:	85 d2                	test   %edx,%edx
f0104bd1:	74 93                	je     f0104b66 <sys_ipc_try_send+0x90>
	perm |= PTE_U | PTE_P;
f0104bd3:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104bd6:	83 c9 05             	or     $0x5,%ecx
		if ((r = env_page_alloc(dstenv, dstenv->env_ipc_dstva, perm)) < 0)
f0104bd9:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0104bdc:	e8 5c fd ff ff       	call   f010493d <env_page_alloc>
f0104be1:	85 c0                	test   %eax,%eax
f0104be3:	78 cf                	js     f0104bb4 <sys_ipc_try_send+0xde>
		             curenv, srcva, dstenv, dstenv->env_ipc_dstva, perm)) <
f0104be5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
		if ((r = env_page_map(
f0104be8:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104beb:	8b 50 78             	mov    0x78(%eax),%edx
f0104bee:	89 55 cc             	mov    %edx,-0x34(%ebp)
		             curenv, srcva, dstenv, dstenv->env_ipc_dstva, perm)) <
f0104bf1:	e8 72 13 00 00       	call   f0105f68 <cpunum>
		if ((r = env_page_map(
f0104bf6:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bf9:	83 ec 08             	sub    $0x8,%esp
f0104bfc:	ff 75 d4             	push   -0x2c(%ebp)
f0104bff:	ff 75 cc             	push   -0x34(%ebp)
f0104c02:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0104c05:	89 f2                	mov    %esi,%edx
f0104c07:	8b 80 28 a0 28 f0    	mov    -0xfd75fd8(%eax),%eax
f0104c0d:	e8 cf fd ff ff       	call   f01049e1 <env_page_map>
f0104c12:	83 c4 10             	add    $0x10,%esp
f0104c15:	85 c0                	test   %eax,%eax
f0104c17:	78 9f                	js     f0104bb8 <sys_ipc_try_send+0xe2>
		dstenv->env_ipc_perm = perm;
f0104c19:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104c1c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0104c1f:	89 88 84 00 00 00    	mov    %ecx,0x84(%eax)
f0104c25:	e9 3c ff ff ff       	jmp    f0104b66 <sys_ipc_try_send+0x90>

f0104c2a <sys_page_unmap>:
{
f0104c2a:	55                   	push   %ebp
f0104c2b:	89 e5                	mov    %esp,%ebp
f0104c2d:	56                   	push   %esi
f0104c2e:	53                   	push   %ebx
f0104c2f:	83 ec 10             	sub    $0x10,%esp
	if (((uint32_t) va >= UTOP) || ((uint32_t) va % PGSIZE))
f0104c32:	81 fa ff ff bf ee    	cmp    $0xeebfffff,%edx
f0104c38:	77 3f                	ja     f0104c79 <sys_page_unmap+0x4f>
f0104c3a:	89 d3                	mov    %edx,%ebx
f0104c3c:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0104c42:	75 3c                	jne    f0104c80 <sys_page_unmap+0x56>
	if ((r = envid2env(envid, &env, 1)))
f0104c44:	83 ec 04             	sub    $0x4,%esp
f0104c47:	6a 01                	push   $0x1
f0104c49:	8d 55 f4             	lea    -0xc(%ebp),%edx
f0104c4c:	52                   	push   %edx
f0104c4d:	50                   	push   %eax
f0104c4e:	e8 42 e4 ff ff       	call   f0103095 <envid2env>
f0104c53:	89 c6                	mov    %eax,%esi
f0104c55:	83 c4 10             	add    $0x10,%esp
f0104c58:	85 c0                	test   %eax,%eax
f0104c5a:	74 09                	je     f0104c65 <sys_page_unmap+0x3b>
}
f0104c5c:	89 f0                	mov    %esi,%eax
f0104c5e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0104c61:	5b                   	pop    %ebx
f0104c62:	5e                   	pop    %esi
f0104c63:	5d                   	pop    %ebp
f0104c64:	c3                   	ret    
	page_remove(env->env_pgdir, va);
f0104c65:	83 ec 08             	sub    $0x8,%esp
f0104c68:	53                   	push   %ebx
f0104c69:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104c6c:	ff 70 6c             	push   0x6c(%eax)
f0104c6f:	e8 ac cc ff ff       	call   f0101920 <page_remove>
	return 0;
f0104c74:	83 c4 10             	add    $0x10,%esp
f0104c77:	eb e3                	jmp    f0104c5c <sys_page_unmap+0x32>
		return -E_INVAL;
f0104c79:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0104c7e:	eb dc                	jmp    f0104c5c <sys_page_unmap+0x32>
f0104c80:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0104c85:	eb d5                	jmp    f0104c5c <sys_page_unmap+0x32>

f0104c87 <sys_yield>:
{
f0104c87:	55                   	push   %ebp
f0104c88:	89 e5                	mov    %esp,%ebp
f0104c8a:	83 ec 08             	sub    $0x8,%esp
	sched_yield();
f0104c8d:	e8 9c f8 ff ff       	call   f010452e <sched_yield>

f0104c92 <sys_ipc_recv>:
{
f0104c92:	55                   	push   %ebp
f0104c93:	89 e5                	mov    %esp,%ebp
f0104c95:	53                   	push   %ebx
f0104c96:	83 ec 04             	sub    $0x4,%esp
f0104c99:	89 c3                	mov    %eax,%ebx
	curenv->env_ipc_recving = true;
f0104c9b:	e8 c8 12 00 00       	call   f0105f68 <cpunum>
f0104ca0:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ca3:	8b 80 28 a0 28 f0    	mov    -0xfd75fd8(%eax),%eax
f0104ca9:	c6 40 74 01          	movb   $0x1,0x74(%eax)
	if (((uint32_t) dstva >= UTOP) || ((uint32_t) dstva % PGSIZE))
f0104cad:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f0104cb3:	77 08                	ja     f0104cbd <sys_ipc_recv+0x2b>
f0104cb5:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
f0104cbb:	74 0a                	je     f0104cc7 <sys_ipc_recv+0x35>
}
f0104cbd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104cc2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104cc5:	c9                   	leave  
f0104cc6:	c3                   	ret    
	curenv->env_ipc_dstva = dstva;
f0104cc7:	e8 9c 12 00 00       	call   f0105f68 <cpunum>
f0104ccc:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ccf:	8b 80 28 a0 28 f0    	mov    -0xfd75fd8(%eax),%eax
f0104cd5:	89 58 78             	mov    %ebx,0x78(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f0104cd8:	e8 8b 12 00 00       	call   f0105f68 <cpunum>
f0104cdd:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ce0:	8b 80 28 a0 28 f0    	mov    -0xfd75fd8(%eax),%eax
f0104ce6:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	sys_yield();
f0104ced:	e8 95 ff ff ff       	call   f0104c87 <sys_yield>

f0104cf2 <syscall>:


// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104cf2:	55                   	push   %ebp
f0104cf3:	89 e5                	mov    %esp,%ebp
f0104cf5:	83 ec 08             	sub    $0x8,%esp
f0104cf8:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.

	switch (syscallno) {
f0104cfb:	83 f8 0e             	cmp    $0xe,%eax
f0104cfe:	0f 87 d0 00 00 00    	ja     f0104dd4 <syscall+0xe2>
f0104d04:	ff 24 85 e0 7d 10 f0 	jmp    *-0xfef8220(,%eax,4)
	case SYS_cputs:
		sys_cputs((char *) a1, a2);
f0104d0b:	8b 55 10             	mov    0x10(%ebp),%edx
f0104d0e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104d11:	e8 42 fa ff ff       	call   f0104758 <sys_cputs>
		return 0;
f0104d16:	b8 00 00 00 00       	mov    $0x0,%eax
	case SYS_yield:
		sys_yield();  // No return
	default:
		return -E_INVAL;
	}
}
f0104d1b:	c9                   	leave  
f0104d1c:	c3                   	ret    
		return sys_getenvid();
f0104d1d:	e8 c6 f9 ff ff       	call   f01046e8 <sys_getenvid>
f0104d22:	eb f7                	jmp    f0104d1b <syscall+0x29>
		return sys_env_destroy(a1);
f0104d24:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104d27:	e8 e4 fa ff ff       	call   f0104810 <sys_env_destroy>
f0104d2c:	eb ed                	jmp    f0104d1b <syscall+0x29>
		return sys_cgetc();
f0104d2e:	e8 82 fb ff ff       	call   f01048b5 <sys_cgetc>
f0104d33:	eb e6                	jmp    f0104d1b <syscall+0x29>
		return sys_exofork();
f0104d35:	e8 88 fb ff ff       	call   f01048c2 <sys_exofork>
f0104d3a:	eb df                	jmp    f0104d1b <syscall+0x29>
		return sys_env_set_status(a1, a2);
f0104d3c:	8b 55 10             	mov    0x10(%ebp),%edx
f0104d3f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104d42:	e8 4a fa ff ff       	call   f0104791 <sys_env_set_status>
f0104d47:	eb d2                	jmp    f0104d1b <syscall+0x29>
		return sys_page_alloc(a1, (void *) a2, a3);
f0104d49:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0104d4c:	8b 55 10             	mov    0x10(%ebp),%edx
f0104d4f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104d52:	e8 33 fc ff ff       	call   f010498a <sys_page_alloc>
f0104d57:	eb c2                	jmp    f0104d1b <syscall+0x29>
		return sys_page_map(a1, (void *) a2, a3, (void *) a4, a5);
f0104d59:	83 ec 08             	sub    $0x8,%esp
f0104d5c:	ff 75 1c             	push   0x1c(%ebp)
f0104d5f:	ff 75 18             	push   0x18(%ebp)
f0104d62:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0104d65:	8b 55 10             	mov    0x10(%ebp),%edx
f0104d68:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104d6b:	e8 c9 fc ff ff       	call   f0104a39 <sys_page_map>
f0104d70:	83 c4 10             	add    $0x10,%esp
f0104d73:	eb a6                	jmp    f0104d1b <syscall+0x29>
		return sys_page_unmap(a1, (void *) a2);
f0104d75:	8b 55 10             	mov    0x10(%ebp),%edx
f0104d78:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104d7b:	e8 aa fe ff ff       	call   f0104c2a <sys_page_unmap>
f0104d80:	eb 99                	jmp    f0104d1b <syscall+0x29>
		return sys_ipc_recv((void *) a1);
f0104d82:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104d85:	e8 08 ff ff ff       	call   f0104c92 <sys_ipc_recv>
f0104d8a:	eb 8f                	jmp    f0104d1b <syscall+0x29>
		return sys_ipc_try_send(a1, a2, (void *) a3, a4);
f0104d8c:	83 ec 0c             	sub    $0xc,%esp
f0104d8f:	ff 75 18             	push   0x18(%ebp)
f0104d92:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0104d95:	8b 55 10             	mov    0x10(%ebp),%edx
f0104d98:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104d9b:	e8 36 fd ff ff       	call   f0104ad6 <sys_ipc_try_send>
f0104da0:	83 c4 10             	add    $0x10,%esp
f0104da3:	e9 73 ff ff ff       	jmp    f0104d1b <syscall+0x29>
		return sys_env_set_pgfault_upcall(a1, (void *) a2);
f0104da8:	8b 55 10             	mov    0x10(%ebp),%edx
f0104dab:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104dae:	e8 1a fa ff ff       	call   f01047cd <sys_env_set_pgfault_upcall>
f0104db3:	e9 63 ff ff ff       	jmp    f0104d1b <syscall+0x29>
		return sys_get_priority();
f0104db8:	e8 44 f9 ff ff       	call   f0104701 <sys_get_priority>
f0104dbd:	e9 59 ff ff ff       	jmp    f0104d1b <syscall+0x29>
		return sys_set_priority(a1);
f0104dc2:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104dc5:	e8 50 f9 ff ff       	call   f010471a <sys_set_priority>
f0104dca:	e9 4c ff ff ff       	jmp    f0104d1b <syscall+0x29>
		sys_yield();  // No return
f0104dcf:	e8 b3 fe ff ff       	call   f0104c87 <sys_yield>
	switch (syscallno) {
f0104dd4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104dd9:	e9 3d ff ff ff       	jmp    f0104d1b <syscall+0x29>

f0104dde <stab_binsearch>:
stab_binsearch(const struct Stab *stabs,
               int *region_left,
               int *region_right,
               int type,
               uintptr_t addr)
{
f0104dde:	55                   	push   %ebp
f0104ddf:	89 e5                	mov    %esp,%ebp
f0104de1:	57                   	push   %edi
f0104de2:	56                   	push   %esi
f0104de3:	53                   	push   %ebx
f0104de4:	83 ec 14             	sub    $0x14,%esp
f0104de7:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104dea:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104ded:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104df0:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104df3:	8b 1a                	mov    (%edx),%ebx
f0104df5:	8b 01                	mov    (%ecx),%eax
f0104df7:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104dfa:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104e01:	eb 2f                	jmp    f0104e32 <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0104e03:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f0104e06:	39 c3                	cmp    %eax,%ebx
f0104e08:	7f 4e                	jg     f0104e58 <stab_binsearch+0x7a>
f0104e0a:	0f b6 0a             	movzbl (%edx),%ecx
f0104e0d:	83 ea 0c             	sub    $0xc,%edx
f0104e10:	39 f1                	cmp    %esi,%ecx
f0104e12:	75 ef                	jne    f0104e03 <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104e14:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104e17:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104e1a:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104e1e:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104e21:	73 3a                	jae    f0104e5d <stab_binsearch+0x7f>
			*region_left = m;
f0104e23:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104e26:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104e28:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f0104e2b:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0104e32:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0104e35:	7f 53                	jg     f0104e8a <stab_binsearch+0xac>
		int true_m = (l + r) / 2, m = true_m;
f0104e37:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104e3a:	8d 14 03             	lea    (%ebx,%eax,1),%edx
f0104e3d:	89 d0                	mov    %edx,%eax
f0104e3f:	c1 e8 1f             	shr    $0x1f,%eax
f0104e42:	01 d0                	add    %edx,%eax
f0104e44:	89 c7                	mov    %eax,%edi
f0104e46:	d1 ff                	sar    %edi
f0104e48:	83 e0 fe             	and    $0xfffffffe,%eax
f0104e4b:	01 f8                	add    %edi,%eax
f0104e4d:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104e50:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0104e54:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f0104e56:	eb ae                	jmp    f0104e06 <stab_binsearch+0x28>
			l = true_m + 1;
f0104e58:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0104e5b:	eb d5                	jmp    f0104e32 <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0104e5d:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104e60:	76 14                	jbe    f0104e76 <stab_binsearch+0x98>
			*region_right = m - 1;
f0104e62:	83 e8 01             	sub    $0x1,%eax
f0104e65:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104e68:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104e6b:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0104e6d:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104e74:	eb bc                	jmp    f0104e32 <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104e76:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104e79:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f0104e7b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104e7f:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f0104e81:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104e88:	eb a8                	jmp    f0104e32 <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0104e8a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104e8e:	75 15                	jne    f0104ea5 <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f0104e90:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104e93:	8b 00                	mov    (%eax),%eax
f0104e95:	83 e8 01             	sub    $0x1,%eax
f0104e98:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104e9b:	89 07                	mov    %eax,(%edi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0104e9d:	83 c4 14             	add    $0x14,%esp
f0104ea0:	5b                   	pop    %ebx
f0104ea1:	5e                   	pop    %esi
f0104ea2:	5f                   	pop    %edi
f0104ea3:	5d                   	pop    %ebp
f0104ea4:	c3                   	ret    
		for (l = *region_right;
f0104ea5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104ea8:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104eaa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104ead:	8b 0f                	mov    (%edi),%ecx
f0104eaf:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104eb2:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0104eb5:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f0104eb9:	39 c1                	cmp    %eax,%ecx
f0104ebb:	7d 0f                	jge    f0104ecc <stab_binsearch+0xee>
f0104ebd:	0f b6 1a             	movzbl (%edx),%ebx
f0104ec0:	83 ea 0c             	sub    $0xc,%edx
f0104ec3:	39 f3                	cmp    %esi,%ebx
f0104ec5:	74 05                	je     f0104ecc <stab_binsearch+0xee>
		     l--)
f0104ec7:	83 e8 01             	sub    $0x1,%eax
f0104eca:	eb ed                	jmp    f0104eb9 <stab_binsearch+0xdb>
		*region_left = l;
f0104ecc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104ecf:	89 07                	mov    %eax,(%edi)
}
f0104ed1:	eb ca                	jmp    f0104e9d <stab_binsearch+0xbf>

f0104ed3 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104ed3:	55                   	push   %ebp
f0104ed4:	89 e5                	mov    %esp,%ebp
f0104ed6:	57                   	push   %edi
f0104ed7:	56                   	push   %esi
f0104ed8:	53                   	push   %ebx
f0104ed9:	83 ec 4c             	sub    $0x4c,%esp
f0104edc:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104edf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104ee2:	c7 03 1c 7e 10 f0    	movl   $0xf0107e1c,(%ebx)
	info->eip_line = 0;
f0104ee8:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0104eef:	c7 43 08 1c 7e 10 f0 	movl   $0xf0107e1c,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0104ef6:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0104efd:	89 7b 10             	mov    %edi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0104f00:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104f07:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0104f0d:	0f 86 2b 01 00 00    	jbe    f010503e <debuginfo_eip+0x16b>
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0104f13:	c7 45 c0 10 b4 11 f0 	movl   $0xf011b410,-0x40(%ebp)
		stabstr = __STABSTR_BEGIN__;
f0104f1a:	c7 45 bc ed 3b 11 f0 	movl   $0xf0113bed,-0x44(%ebp)
		stab_end = __STAB_END__;
f0104f21:	be ec 3b 11 f0       	mov    $0xf0113bec,%esi
		stabs = __STAB_BEGIN__;
f0104f26:	c7 45 c4 f4 82 10 f0 	movl   $0xf01082f4,-0x3c(%ebp)
		    user_mem_check(curenv, stabstr, stabstr_end - stabstr, 0))
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104f2d:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0104f30:	39 4d bc             	cmp    %ecx,-0x44(%ebp)
f0104f33:	0f 83 40 02 00 00    	jae    f0105179 <debuginfo_eip+0x2a6>
f0104f39:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f0104f3d:	0f 85 3d 02 00 00    	jne    f0105180 <debuginfo_eip+0x2ad>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104f43:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104f4a:	2b 75 c4             	sub    -0x3c(%ebp),%esi
f0104f4d:	c1 fe 02             	sar    $0x2,%esi
f0104f50:	69 c6 ab aa aa aa    	imul   $0xaaaaaaab,%esi,%eax
f0104f56:	83 e8 01             	sub    $0x1,%eax
f0104f59:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104f5c:	83 ec 08             	sub    $0x8,%esp
f0104f5f:	57                   	push   %edi
f0104f60:	6a 64                	push   $0x64
f0104f62:	8d 75 e0             	lea    -0x20(%ebp),%esi
f0104f65:	89 f1                	mov    %esi,%ecx
f0104f67:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104f6a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0104f6d:	e8 6c fe ff ff       	call   f0104dde <stab_binsearch>
	if (lfile == 0)
f0104f72:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104f75:	83 c4 10             	add    $0x10,%esp
f0104f78:	85 f6                	test   %esi,%esi
f0104f7a:	0f 84 07 02 00 00    	je     f0105187 <debuginfo_eip+0x2b4>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104f80:	89 75 dc             	mov    %esi,-0x24(%ebp)
	rfun = rfile;
f0104f83:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104f86:	89 55 b8             	mov    %edx,-0x48(%ebp)
f0104f89:	89 55 d8             	mov    %edx,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104f8c:	83 ec 08             	sub    $0x8,%esp
f0104f8f:	57                   	push   %edi
f0104f90:	6a 24                	push   $0x24
f0104f92:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0104f95:	89 d1                	mov    %edx,%ecx
f0104f97:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104f9a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0104f9d:	e8 3c fe ff ff       	call   f0104dde <stab_binsearch>

	if (lfun <= rfun) {
f0104fa2:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104fa5:	89 55 b4             	mov    %edx,-0x4c(%ebp)
f0104fa8:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104fab:	89 45 b0             	mov    %eax,-0x50(%ebp)
f0104fae:	83 c4 10             	add    $0x10,%esp
f0104fb1:	39 c2                	cmp    %eax,%edx
f0104fb3:	0f 8f 34 01 00 00    	jg     f01050ed <debuginfo_eip+0x21a>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104fb9:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0104fbc:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0104fbf:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0104fc2:	8b 02                	mov    (%edx),%eax
f0104fc4:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0104fc7:	2b 4d bc             	sub    -0x44(%ebp),%ecx
f0104fca:	39 c8                	cmp    %ecx,%eax
f0104fcc:	73 06                	jae    f0104fd4 <debuginfo_eip+0x101>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104fce:	03 45 bc             	add    -0x44(%ebp),%eax
f0104fd1:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104fd4:	8b 42 08             	mov    0x8(%edx),%eax
		addr -= info->eip_fn_addr;
f0104fd7:	29 c7                	sub    %eax,%edi
f0104fd9:	8b 55 b4             	mov    -0x4c(%ebp),%edx
f0104fdc:	8b 4d b0             	mov    -0x50(%ebp),%ecx
f0104fdf:	89 4d b8             	mov    %ecx,-0x48(%ebp)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104fe2:	89 43 10             	mov    %eax,0x10(%ebx)
		// Search within the function definition for the line number.
		lline = lfun;
f0104fe5:	89 55 d4             	mov    %edx,-0x2c(%ebp)
		rline = rfun;
f0104fe8:	8b 45 b8             	mov    -0x48(%ebp),%eax
f0104feb:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104fee:	83 ec 08             	sub    $0x8,%esp
f0104ff1:	6a 3a                	push   $0x3a
f0104ff3:	ff 73 08             	push   0x8(%ebx)
f0104ff6:	e8 db 08 00 00       	call   f01058d6 <strfind>
f0104ffb:	2b 43 08             	sub    0x8(%ebx),%eax
f0104ffe:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.

	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0105001:	83 c4 08             	add    $0x8,%esp
f0105004:	57                   	push   %edi
f0105005:	6a 44                	push   $0x44
f0105007:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f010500a:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f010500d:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0105010:	89 f8                	mov    %edi,%eax
f0105012:	e8 c7 fd ff ff       	call   f0104dde <stab_binsearch>
	if (lline <= rline) {
f0105017:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010501a:	83 c4 10             	add    $0x10,%esp
f010501d:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0105020:	7f 0b                	jg     f010502d <debuginfo_eip+0x15a>
		info->eip_line = stabs[lline].n_desc;
f0105022:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105025:	0f b7 54 97 06       	movzwl 0x6(%edi,%edx,4),%edx
f010502a:	89 53 04             	mov    %edx,0x4(%ebx)
f010502d:	89 c2                	mov    %eax,%edx
f010502f:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0105032:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0105035:	8d 44 87 04          	lea    0x4(%edi,%eax,4),%eax
f0105039:	e9 be 00 00 00       	jmp    f01050fc <debuginfo_eip+0x229>
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), 0))
f010503e:	e8 25 0f 00 00       	call   f0105f68 <cpunum>
f0105043:	6a 00                	push   $0x0
f0105045:	6a 10                	push   $0x10
f0105047:	68 00 00 20 00       	push   $0x200000
f010504c:	6b c0 74             	imul   $0x74,%eax,%eax
f010504f:	ff b0 28 a0 28 f0    	push   -0xfd75fd8(%eax)
f0105055:	e8 a2 dc ff ff       	call   f0102cfc <user_mem_check>
f010505a:	83 c4 10             	add    $0x10,%esp
f010505d:	85 c0                	test   %eax,%eax
f010505f:	0f 85 06 01 00 00    	jne    f010516b <debuginfo_eip+0x298>
		stabs = usd->stabs;
f0105065:	8b 0d 00 00 20 00    	mov    0x200000,%ecx
f010506b:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
		stab_end = usd->stab_end;
f010506e:	8b 35 04 00 20 00    	mov    0x200004,%esi
		stabstr = usd->stabstr;
f0105074:	a1 08 00 20 00       	mov    0x200008,%eax
f0105079:	89 45 bc             	mov    %eax,-0x44(%ebp)
		stabstr_end = usd->stabstr_end;
f010507c:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f0105082:	89 55 c0             	mov    %edx,-0x40(%ebp)
		if (user_mem_check(curenv, stabs, stab_end - stabs, 0) ||
f0105085:	e8 de 0e 00 00       	call   f0105f68 <cpunum>
f010508a:	89 c2                	mov    %eax,%edx
f010508c:	6a 00                	push   $0x0
f010508e:	89 f0                	mov    %esi,%eax
f0105090:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0105093:	29 c8                	sub    %ecx,%eax
f0105095:	c1 f8 02             	sar    $0x2,%eax
f0105098:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f010509e:	50                   	push   %eax
f010509f:	51                   	push   %ecx
f01050a0:	6b d2 74             	imul   $0x74,%edx,%edx
f01050a3:	ff b2 28 a0 28 f0    	push   -0xfd75fd8(%edx)
f01050a9:	e8 4e dc ff ff       	call   f0102cfc <user_mem_check>
f01050ae:	83 c4 10             	add    $0x10,%esp
f01050b1:	85 c0                	test   %eax,%eax
f01050b3:	0f 85 b9 00 00 00    	jne    f0105172 <debuginfo_eip+0x29f>
		    user_mem_check(curenv, stabstr, stabstr_end - stabstr, 0))
f01050b9:	e8 aa 0e 00 00       	call   f0105f68 <cpunum>
f01050be:	6a 00                	push   $0x0
f01050c0:	8b 55 c0             	mov    -0x40(%ebp),%edx
f01050c3:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f01050c6:	29 ca                	sub    %ecx,%edx
f01050c8:	52                   	push   %edx
f01050c9:	51                   	push   %ecx
f01050ca:	6b c0 74             	imul   $0x74,%eax,%eax
f01050cd:	ff b0 28 a0 28 f0    	push   -0xfd75fd8(%eax)
f01050d3:	e8 24 dc ff ff       	call   f0102cfc <user_mem_check>
		if (user_mem_check(curenv, stabs, stab_end - stabs, 0) ||
f01050d8:	83 c4 10             	add    $0x10,%esp
f01050db:	85 c0                	test   %eax,%eax
f01050dd:	0f 84 4a fe ff ff    	je     f0104f2d <debuginfo_eip+0x5a>
			return -1;
f01050e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01050e8:	e9 a6 00 00 00       	jmp    f0105193 <debuginfo_eip+0x2c0>
f01050ed:	89 f8                	mov    %edi,%eax
f01050ef:	89 f2                	mov    %esi,%edx
f01050f1:	e9 ec fe ff ff       	jmp    f0104fe2 <debuginfo_eip+0x10f>
f01050f6:	83 ea 01             	sub    $0x1,%edx
f01050f9:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile && stabs[lline].n_type != N_SOL &&
f01050fc:	39 d6                	cmp    %edx,%esi
f01050fe:	7f 2e                	jg     f010512e <debuginfo_eip+0x25b>
f0105100:	0f b6 08             	movzbl (%eax),%ecx
f0105103:	80 f9 84             	cmp    $0x84,%cl
f0105106:	74 0b                	je     f0105113 <debuginfo_eip+0x240>
f0105108:	80 f9 64             	cmp    $0x64,%cl
f010510b:	75 e9                	jne    f01050f6 <debuginfo_eip+0x223>
	       (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f010510d:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f0105111:	74 e3                	je     f01050f6 <debuginfo_eip+0x223>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0105113:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0105116:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0105119:	8b 14 87             	mov    (%edi,%eax,4),%edx
f010511c:	8b 45 c0             	mov    -0x40(%ebp),%eax
f010511f:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0105122:	29 f8                	sub    %edi,%eax
f0105124:	39 c2                	cmp    %eax,%edx
f0105126:	73 06                	jae    f010512e <debuginfo_eip+0x25b>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0105128:	89 f8                	mov    %edi,%eax
f010512a:	01 d0                	add    %edx,%eax
f010512c:	89 03                	mov    %eax,(%ebx)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010512e:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0105133:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f0105136:	8b 75 b0             	mov    -0x50(%ebp),%esi
f0105139:	39 f7                	cmp    %esi,%edi
f010513b:	7d 56                	jge    f0105193 <debuginfo_eip+0x2c0>
		for (lline = lfun + 1;
f010513d:	83 c7 01             	add    $0x1,%edi
f0105140:	89 f8                	mov    %edi,%eax
f0105142:	8d 14 7f             	lea    (%edi,%edi,2),%edx
f0105145:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0105148:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f010514c:	eb 04                	jmp    f0105152 <debuginfo_eip+0x27f>
			info->eip_fn_narg++;
f010514e:	83 43 14 01          	addl   $0x1,0x14(%ebx)
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105152:	39 c6                	cmp    %eax,%esi
f0105154:	7e 38                	jle    f010518e <debuginfo_eip+0x2bb>
f0105156:	0f b6 0a             	movzbl (%edx),%ecx
f0105159:	83 c0 01             	add    $0x1,%eax
f010515c:	83 c2 0c             	add    $0xc,%edx
f010515f:	80 f9 a0             	cmp    $0xa0,%cl
f0105162:	74 ea                	je     f010514e <debuginfo_eip+0x27b>
	return 0;
f0105164:	b8 00 00 00 00       	mov    $0x0,%eax
f0105169:	eb 28                	jmp    f0105193 <debuginfo_eip+0x2c0>
			return -1;
f010516b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105170:	eb 21                	jmp    f0105193 <debuginfo_eip+0x2c0>
			return -1;
f0105172:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105177:	eb 1a                	jmp    f0105193 <debuginfo_eip+0x2c0>
		return -1;
f0105179:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010517e:	eb 13                	jmp    f0105193 <debuginfo_eip+0x2c0>
f0105180:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105185:	eb 0c                	jmp    f0105193 <debuginfo_eip+0x2c0>
		return -1;
f0105187:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010518c:	eb 05                	jmp    f0105193 <debuginfo_eip+0x2c0>
	return 0;
f010518e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105193:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105196:	5b                   	pop    %ebx
f0105197:	5e                   	pop    %esi
f0105198:	5f                   	pop    %edi
f0105199:	5d                   	pop    %ebp
f010519a:	c3                   	ret    

f010519b <printnum>:
         void *putdat,
         unsigned long long num,
         unsigned base,
         int width,
         int padc)
{
f010519b:	55                   	push   %ebp
f010519c:	89 e5                	mov    %esp,%ebp
f010519e:	57                   	push   %edi
f010519f:	56                   	push   %esi
f01051a0:	53                   	push   %ebx
f01051a1:	83 ec 1c             	sub    $0x1c,%esp
f01051a4:	89 c7                	mov    %eax,%edi
f01051a6:	89 d6                	mov    %edx,%esi
f01051a8:	8b 45 08             	mov    0x8(%ebp),%eax
f01051ab:	8b 55 0c             	mov    0xc(%ebp),%edx
f01051ae:	89 d1                	mov    %edx,%ecx
f01051b0:	89 c2                	mov    %eax,%edx
f01051b2:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01051b5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01051b8:	8b 45 10             	mov    0x10(%ebp),%eax
f01051bb:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01051be:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01051c1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f01051c8:	39 c2                	cmp    %eax,%edx
f01051ca:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f01051cd:	72 3e                	jb     f010520d <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01051cf:	83 ec 0c             	sub    $0xc,%esp
f01051d2:	ff 75 18             	push   0x18(%ebp)
f01051d5:	83 eb 01             	sub    $0x1,%ebx
f01051d8:	53                   	push   %ebx
f01051d9:	50                   	push   %eax
f01051da:	83 ec 08             	sub    $0x8,%esp
f01051dd:	ff 75 e4             	push   -0x1c(%ebp)
f01051e0:	ff 75 e0             	push   -0x20(%ebp)
f01051e3:	ff 75 dc             	push   -0x24(%ebp)
f01051e6:	ff 75 d8             	push   -0x28(%ebp)
f01051e9:	e8 a2 11 00 00       	call   f0106390 <__udivdi3>
f01051ee:	83 c4 18             	add    $0x18,%esp
f01051f1:	52                   	push   %edx
f01051f2:	50                   	push   %eax
f01051f3:	89 f2                	mov    %esi,%edx
f01051f5:	89 f8                	mov    %edi,%eax
f01051f7:	e8 9f ff ff ff       	call   f010519b <printnum>
f01051fc:	83 c4 20             	add    $0x20,%esp
f01051ff:	eb 13                	jmp    f0105214 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0105201:	83 ec 08             	sub    $0x8,%esp
f0105204:	56                   	push   %esi
f0105205:	ff 75 18             	push   0x18(%ebp)
f0105208:	ff d7                	call   *%edi
f010520a:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f010520d:	83 eb 01             	sub    $0x1,%ebx
f0105210:	85 db                	test   %ebx,%ebx
f0105212:	7f ed                	jg     f0105201 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0105214:	83 ec 08             	sub    $0x8,%esp
f0105217:	56                   	push   %esi
f0105218:	83 ec 04             	sub    $0x4,%esp
f010521b:	ff 75 e4             	push   -0x1c(%ebp)
f010521e:	ff 75 e0             	push   -0x20(%ebp)
f0105221:	ff 75 dc             	push   -0x24(%ebp)
f0105224:	ff 75 d8             	push   -0x28(%ebp)
f0105227:	e8 84 12 00 00       	call   f01064b0 <__umoddi3>
f010522c:	83 c4 14             	add    $0x14,%esp
f010522f:	0f be 80 26 7e 10 f0 	movsbl -0xfef81da(%eax),%eax
f0105236:	50                   	push   %eax
f0105237:	ff d7                	call   *%edi
}
f0105239:	83 c4 10             	add    $0x10,%esp
f010523c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010523f:	5b                   	pop    %ebx
f0105240:	5e                   	pop    %esi
f0105241:	5f                   	pop    %edi
f0105242:	5d                   	pop    %ebp
f0105243:	c3                   	ret    

f0105244 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0105244:	83 fa 01             	cmp    $0x1,%edx
f0105247:	7f 13                	jg     f010525c <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
f0105249:	85 d2                	test   %edx,%edx
f010524b:	74 1c                	je     f0105269 <getuint+0x25>
		return va_arg(*ap, unsigned long);
f010524d:	8b 10                	mov    (%eax),%edx
f010524f:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105252:	89 08                	mov    %ecx,(%eax)
f0105254:	8b 02                	mov    (%edx),%eax
f0105256:	ba 00 00 00 00       	mov    $0x0,%edx
f010525b:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
f010525c:	8b 10                	mov    (%eax),%edx
f010525e:	8d 4a 08             	lea    0x8(%edx),%ecx
f0105261:	89 08                	mov    %ecx,(%eax)
f0105263:	8b 02                	mov    (%edx),%eax
f0105265:	8b 52 04             	mov    0x4(%edx),%edx
f0105268:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
f0105269:	8b 10                	mov    (%eax),%edx
f010526b:	8d 4a 04             	lea    0x4(%edx),%ecx
f010526e:	89 08                	mov    %ecx,(%eax)
f0105270:	8b 02                	mov    (%edx),%eax
f0105272:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0105277:	c3                   	ret    

f0105278 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0105278:	83 fa 01             	cmp    $0x1,%edx
f010527b:	7f 0f                	jg     f010528c <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
f010527d:	85 d2                	test   %edx,%edx
f010527f:	74 18                	je     f0105299 <getint+0x21>
		return va_arg(*ap, long);
f0105281:	8b 10                	mov    (%eax),%edx
f0105283:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105286:	89 08                	mov    %ecx,(%eax)
f0105288:	8b 02                	mov    (%edx),%eax
f010528a:	99                   	cltd   
f010528b:	c3                   	ret    
		return va_arg(*ap, long long);
f010528c:	8b 10                	mov    (%eax),%edx
f010528e:	8d 4a 08             	lea    0x8(%edx),%ecx
f0105291:	89 08                	mov    %ecx,(%eax)
f0105293:	8b 02                	mov    (%edx),%eax
f0105295:	8b 52 04             	mov    0x4(%edx),%edx
f0105298:	c3                   	ret    
	else
		return va_arg(*ap, int);
f0105299:	8b 10                	mov    (%eax),%edx
f010529b:	8d 4a 04             	lea    0x4(%edx),%ecx
f010529e:	89 08                	mov    %ecx,(%eax)
f01052a0:	8b 02                	mov    (%edx),%eax
f01052a2:	99                   	cltd   
}
f01052a3:	c3                   	ret    

f01052a4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01052a4:	55                   	push   %ebp
f01052a5:	89 e5                	mov    %esp,%ebp
f01052a7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01052aa:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f01052ae:	8b 10                	mov    (%eax),%edx
f01052b0:	3b 50 04             	cmp    0x4(%eax),%edx
f01052b3:	73 0a                	jae    f01052bf <sprintputch+0x1b>
		*b->buf++ = ch;
f01052b5:	8d 4a 01             	lea    0x1(%edx),%ecx
f01052b8:	89 08                	mov    %ecx,(%eax)
f01052ba:	8b 45 08             	mov    0x8(%ebp),%eax
f01052bd:	88 02                	mov    %al,(%edx)
}
f01052bf:	5d                   	pop    %ebp
f01052c0:	c3                   	ret    

f01052c1 <printfmt>:
{
f01052c1:	55                   	push   %ebp
f01052c2:	89 e5                	mov    %esp,%ebp
f01052c4:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f01052c7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01052ca:	50                   	push   %eax
f01052cb:	ff 75 10             	push   0x10(%ebp)
f01052ce:	ff 75 0c             	push   0xc(%ebp)
f01052d1:	ff 75 08             	push   0x8(%ebp)
f01052d4:	e8 05 00 00 00       	call   f01052de <vprintfmt>
}
f01052d9:	83 c4 10             	add    $0x10,%esp
f01052dc:	c9                   	leave  
f01052dd:	c3                   	ret    

f01052de <vprintfmt>:
{
f01052de:	55                   	push   %ebp
f01052df:	89 e5                	mov    %esp,%ebp
f01052e1:	57                   	push   %edi
f01052e2:	56                   	push   %esi
f01052e3:	53                   	push   %ebx
f01052e4:	83 ec 2c             	sub    $0x2c,%esp
f01052e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01052ea:	8b 75 0c             	mov    0xc(%ebp),%esi
f01052ed:	8b 7d 10             	mov    0x10(%ebp),%edi
f01052f0:	eb 0a                	jmp    f01052fc <vprintfmt+0x1e>
			putch(ch, putdat);
f01052f2:	83 ec 08             	sub    $0x8,%esp
f01052f5:	56                   	push   %esi
f01052f6:	50                   	push   %eax
f01052f7:	ff d3                	call   *%ebx
f01052f9:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01052fc:	83 c7 01             	add    $0x1,%edi
f01052ff:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0105303:	83 f8 25             	cmp    $0x25,%eax
f0105306:	74 0c                	je     f0105314 <vprintfmt+0x36>
			if (ch == '\0')
f0105308:	85 c0                	test   %eax,%eax
f010530a:	75 e6                	jne    f01052f2 <vprintfmt+0x14>
}
f010530c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010530f:	5b                   	pop    %ebx
f0105310:	5e                   	pop    %esi
f0105311:	5f                   	pop    %edi
f0105312:	5d                   	pop    %ebp
f0105313:	c3                   	ret    
		padc = ' ';
f0105314:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
		altflag = 0;
f0105318:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
f010531f:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f0105326:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f010532d:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0105332:	8d 47 01             	lea    0x1(%edi),%eax
f0105335:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105338:	0f b6 17             	movzbl (%edi),%edx
f010533b:	8d 42 dd             	lea    -0x23(%edx),%eax
f010533e:	3c 55                	cmp    $0x55,%al
f0105340:	0f 87 b7 02 00 00    	ja     f01055fd <vprintfmt+0x31f>
f0105346:	0f b6 c0             	movzbl %al,%eax
f0105349:	ff 24 85 e0 7e 10 f0 	jmp    *-0xfef8120(,%eax,4)
f0105350:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0105353:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
f0105357:	eb d9                	jmp    f0105332 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
f0105359:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010535c:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
f0105360:	eb d0                	jmp    f0105332 <vprintfmt+0x54>
f0105362:	0f b6 d2             	movzbl %dl,%edx
f0105365:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0;; ++fmt) {
f0105368:	b8 00 00 00 00       	mov    $0x0,%eax
f010536d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f0105370:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0105373:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0105377:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f010537a:	8d 4a d0             	lea    -0x30(%edx),%ecx
f010537d:	83 f9 09             	cmp    $0x9,%ecx
f0105380:	77 52                	ja     f01053d4 <vprintfmt+0xf6>
			for (precision = 0;; ++fmt) {
f0105382:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f0105385:	eb e9                	jmp    f0105370 <vprintfmt+0x92>
			precision = va_arg(ap, int);
f0105387:	8b 45 14             	mov    0x14(%ebp),%eax
f010538a:	8d 50 04             	lea    0x4(%eax),%edx
f010538d:	89 55 14             	mov    %edx,0x14(%ebp)
f0105390:	8b 00                	mov    (%eax),%eax
f0105392:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0105395:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0105398:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010539c:	79 94                	jns    f0105332 <vprintfmt+0x54>
				width = precision, precision = -1;
f010539e:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01053a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01053a4:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f01053ab:	eb 85                	jmp    f0105332 <vprintfmt+0x54>
f01053ad:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01053b0:	85 d2                	test   %edx,%edx
f01053b2:	b8 00 00 00 00       	mov    $0x0,%eax
f01053b7:	0f 49 c2             	cmovns %edx,%eax
f01053ba:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01053bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f01053c0:	e9 6d ff ff ff       	jmp    f0105332 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
f01053c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f01053c8:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
f01053cf:	e9 5e ff ff ff       	jmp    f0105332 <vprintfmt+0x54>
f01053d4:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01053d7:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01053da:	eb bc                	jmp    f0105398 <vprintfmt+0xba>
			lflag++;
f01053dc:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f01053df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f01053e2:	e9 4b ff ff ff       	jmp    f0105332 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
f01053e7:	8b 45 14             	mov    0x14(%ebp),%eax
f01053ea:	8d 50 04             	lea    0x4(%eax),%edx
f01053ed:	89 55 14             	mov    %edx,0x14(%ebp)
f01053f0:	83 ec 08             	sub    $0x8,%esp
f01053f3:	56                   	push   %esi
f01053f4:	ff 30                	push   (%eax)
f01053f6:	ff d3                	call   *%ebx
			break;
f01053f8:	83 c4 10             	add    $0x10,%esp
f01053fb:	e9 94 01 00 00       	jmp    f0105594 <vprintfmt+0x2b6>
			err = va_arg(ap, int);
f0105400:	8b 45 14             	mov    0x14(%ebp),%eax
f0105403:	8d 50 04             	lea    0x4(%eax),%edx
f0105406:	89 55 14             	mov    %edx,0x14(%ebp)
f0105409:	8b 10                	mov    (%eax),%edx
f010540b:	89 d0                	mov    %edx,%eax
f010540d:	f7 d8                	neg    %eax
f010540f:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105412:	83 f8 08             	cmp    $0x8,%eax
f0105415:	7f 20                	jg     f0105437 <vprintfmt+0x159>
f0105417:	8b 14 85 40 80 10 f0 	mov    -0xfef7fc0(,%eax,4),%edx
f010541e:	85 d2                	test   %edx,%edx
f0105420:	74 15                	je     f0105437 <vprintfmt+0x159>
				printfmt(putch, putdat, "%s", p);
f0105422:	52                   	push   %edx
f0105423:	68 1d 75 10 f0       	push   $0xf010751d
f0105428:	56                   	push   %esi
f0105429:	53                   	push   %ebx
f010542a:	e8 92 fe ff ff       	call   f01052c1 <printfmt>
f010542f:	83 c4 10             	add    $0x10,%esp
f0105432:	e9 5d 01 00 00       	jmp    f0105594 <vprintfmt+0x2b6>
				printfmt(putch, putdat, "error %d", err);
f0105437:	50                   	push   %eax
f0105438:	68 3e 7e 10 f0       	push   $0xf0107e3e
f010543d:	56                   	push   %esi
f010543e:	53                   	push   %ebx
f010543f:	e8 7d fe ff ff       	call   f01052c1 <printfmt>
f0105444:	83 c4 10             	add    $0x10,%esp
f0105447:	e9 48 01 00 00       	jmp    f0105594 <vprintfmt+0x2b6>
			if ((p = va_arg(ap, char *)) == NULL)
f010544c:	8b 45 14             	mov    0x14(%ebp),%eax
f010544f:	8d 50 04             	lea    0x4(%eax),%edx
f0105452:	89 55 14             	mov    %edx,0x14(%ebp)
f0105455:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0105457:	85 ff                	test   %edi,%edi
f0105459:	b8 37 7e 10 f0       	mov    $0xf0107e37,%eax
f010545e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0105461:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105465:	7e 06                	jle    f010546d <vprintfmt+0x18f>
f0105467:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
f010546b:	75 0a                	jne    f0105477 <vprintfmt+0x199>
f010546d:	89 f8                	mov    %edi,%eax
f010546f:	03 45 e0             	add    -0x20(%ebp),%eax
f0105472:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105475:	eb 59                	jmp    f01054d0 <vprintfmt+0x1f2>
				for (width -= strnlen(p, precision); width > 0;
f0105477:	83 ec 08             	sub    $0x8,%esp
f010547a:	ff 75 d8             	push   -0x28(%ebp)
f010547d:	57                   	push   %edi
f010547e:	e8 fc 02 00 00       	call   f010577f <strnlen>
f0105483:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105486:	29 c1                	sub    %eax,%ecx
f0105488:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f010548b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f010548e:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
f0105492:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105495:	89 7d d0             	mov    %edi,-0x30(%ebp)
f0105498:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0;
f010549a:	eb 0f                	jmp    f01054ab <vprintfmt+0x1cd>
					putch(padc, putdat);
f010549c:	83 ec 08             	sub    $0x8,%esp
f010549f:	56                   	push   %esi
f01054a0:	ff 75 e0             	push   -0x20(%ebp)
f01054a3:	ff d3                	call   *%ebx
				     width--)
f01054a5:	83 ef 01             	sub    $0x1,%edi
f01054a8:	83 c4 10             	add    $0x10,%esp
				for (width -= strnlen(p, precision); width > 0;
f01054ab:	85 ff                	test   %edi,%edi
f01054ad:	7f ed                	jg     f010549c <vprintfmt+0x1be>
f01054af:	8b 7d d0             	mov    -0x30(%ebp),%edi
f01054b2:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01054b5:	85 c9                	test   %ecx,%ecx
f01054b7:	b8 00 00 00 00       	mov    $0x0,%eax
f01054bc:	0f 49 c1             	cmovns %ecx,%eax
f01054bf:	29 c1                	sub    %eax,%ecx
f01054c1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01054c4:	eb a7                	jmp    f010546d <vprintfmt+0x18f>
					putch(ch, putdat);
f01054c6:	83 ec 08             	sub    $0x8,%esp
f01054c9:	56                   	push   %esi
f01054ca:	52                   	push   %edx
f01054cb:	ff d3                	call   *%ebx
f01054cd:	83 c4 10             	add    $0x10,%esp
f01054d0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01054d3:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' &&
f01054d5:	83 c7 01             	add    $0x1,%edi
f01054d8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01054dc:	0f be d0             	movsbl %al,%edx
f01054df:	85 d2                	test   %edx,%edx
f01054e1:	74 42                	je     f0105525 <vprintfmt+0x247>
f01054e3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01054e7:	78 06                	js     f01054ef <vprintfmt+0x211>
			       (precision < 0 || --precision >= 0);
f01054e9:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f01054ed:	78 1e                	js     f010550d <vprintfmt+0x22f>
				if (altflag && (ch < ' ' || ch > '~'))
f01054ef:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01054f3:	74 d1                	je     f01054c6 <vprintfmt+0x1e8>
f01054f5:	0f be c0             	movsbl %al,%eax
f01054f8:	83 e8 20             	sub    $0x20,%eax
f01054fb:	83 f8 5e             	cmp    $0x5e,%eax
f01054fe:	76 c6                	jbe    f01054c6 <vprintfmt+0x1e8>
					putch('?', putdat);
f0105500:	83 ec 08             	sub    $0x8,%esp
f0105503:	56                   	push   %esi
f0105504:	6a 3f                	push   $0x3f
f0105506:	ff d3                	call   *%ebx
f0105508:	83 c4 10             	add    $0x10,%esp
f010550b:	eb c3                	jmp    f01054d0 <vprintfmt+0x1f2>
f010550d:	89 cf                	mov    %ecx,%edi
f010550f:	eb 0e                	jmp    f010551f <vprintfmt+0x241>
				putch(' ', putdat);
f0105511:	83 ec 08             	sub    $0x8,%esp
f0105514:	56                   	push   %esi
f0105515:	6a 20                	push   $0x20
f0105517:	ff d3                	call   *%ebx
			for (; width > 0; width--)
f0105519:	83 ef 01             	sub    $0x1,%edi
f010551c:	83 c4 10             	add    $0x10,%esp
f010551f:	85 ff                	test   %edi,%edi
f0105521:	7f ee                	jg     f0105511 <vprintfmt+0x233>
f0105523:	eb 6f                	jmp    f0105594 <vprintfmt+0x2b6>
f0105525:	89 cf                	mov    %ecx,%edi
f0105527:	eb f6                	jmp    f010551f <vprintfmt+0x241>
			num = getint(&ap, lflag);
f0105529:	89 ca                	mov    %ecx,%edx
f010552b:	8d 45 14             	lea    0x14(%ebp),%eax
f010552e:	e8 45 fd ff ff       	call   f0105278 <getint>
f0105533:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105536:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
f0105539:	85 d2                	test   %edx,%edx
f010553b:	78 0b                	js     f0105548 <vprintfmt+0x26a>
			num = getint(&ap, lflag);
f010553d:	89 d1                	mov    %edx,%ecx
f010553f:	89 c2                	mov    %eax,%edx
			base = 10;
f0105541:	bf 0a 00 00 00       	mov    $0xa,%edi
f0105546:	eb 32                	jmp    f010557a <vprintfmt+0x29c>
				putch('-', putdat);
f0105548:	83 ec 08             	sub    $0x8,%esp
f010554b:	56                   	push   %esi
f010554c:	6a 2d                	push   $0x2d
f010554e:	ff d3                	call   *%ebx
				num = -(long long) num;
f0105550:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105553:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0105556:	f7 da                	neg    %edx
f0105558:	83 d1 00             	adc    $0x0,%ecx
f010555b:	f7 d9                	neg    %ecx
f010555d:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0105560:	bf 0a 00 00 00       	mov    $0xa,%edi
f0105565:	eb 13                	jmp    f010557a <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
f0105567:	89 ca                	mov    %ecx,%edx
f0105569:	8d 45 14             	lea    0x14(%ebp),%eax
f010556c:	e8 d3 fc ff ff       	call   f0105244 <getuint>
f0105571:	89 d1                	mov    %edx,%ecx
f0105573:	89 c2                	mov    %eax,%edx
			base = 10;
f0105575:	bf 0a 00 00 00       	mov    $0xa,%edi
			printnum(putch, putdat, num, base, width, padc);
f010557a:	83 ec 0c             	sub    $0xc,%esp
f010557d:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
f0105581:	50                   	push   %eax
f0105582:	ff 75 e0             	push   -0x20(%ebp)
f0105585:	57                   	push   %edi
f0105586:	51                   	push   %ecx
f0105587:	52                   	push   %edx
f0105588:	89 f2                	mov    %esi,%edx
f010558a:	89 d8                	mov    %ebx,%eax
f010558c:	e8 0a fc ff ff       	call   f010519b <printnum>
			break;
f0105591:	83 c4 20             	add    $0x20,%esp
{
f0105594:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105597:	e9 60 fd ff ff       	jmp    f01052fc <vprintfmt+0x1e>
			num = getuint(&ap, lflag);
f010559c:	89 ca                	mov    %ecx,%edx
f010559e:	8d 45 14             	lea    0x14(%ebp),%eax
f01055a1:	e8 9e fc ff ff       	call   f0105244 <getuint>
f01055a6:	89 d1                	mov    %edx,%ecx
f01055a8:	89 c2                	mov    %eax,%edx
			base = 8;
f01055aa:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
f01055af:	eb c9                	jmp    f010557a <vprintfmt+0x29c>
			putch('0', putdat);
f01055b1:	83 ec 08             	sub    $0x8,%esp
f01055b4:	56                   	push   %esi
f01055b5:	6a 30                	push   $0x30
f01055b7:	ff d3                	call   *%ebx
			putch('x', putdat);
f01055b9:	83 c4 08             	add    $0x8,%esp
f01055bc:	56                   	push   %esi
f01055bd:	6a 78                	push   $0x78
f01055bf:	ff d3                	call   *%ebx
			num = (unsigned long long) (uintptr_t) va_arg(ap, void *);
f01055c1:	8b 45 14             	mov    0x14(%ebp),%eax
f01055c4:	8d 50 04             	lea    0x4(%eax),%edx
f01055c7:	89 55 14             	mov    %edx,0x14(%ebp)
f01055ca:	8b 10                	mov    (%eax),%edx
f01055cc:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f01055d1:	83 c4 10             	add    $0x10,%esp
			base = 16;
f01055d4:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
f01055d9:	eb 9f                	jmp    f010557a <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
f01055db:	89 ca                	mov    %ecx,%edx
f01055dd:	8d 45 14             	lea    0x14(%ebp),%eax
f01055e0:	e8 5f fc ff ff       	call   f0105244 <getuint>
f01055e5:	89 d1                	mov    %edx,%ecx
f01055e7:	89 c2                	mov    %eax,%edx
			base = 16;
f01055e9:	bf 10 00 00 00       	mov    $0x10,%edi
f01055ee:	eb 8a                	jmp    f010557a <vprintfmt+0x29c>
			putch(ch, putdat);
f01055f0:	83 ec 08             	sub    $0x8,%esp
f01055f3:	56                   	push   %esi
f01055f4:	6a 25                	push   $0x25
f01055f6:	ff d3                	call   *%ebx
			break;
f01055f8:	83 c4 10             	add    $0x10,%esp
f01055fb:	eb 97                	jmp    f0105594 <vprintfmt+0x2b6>
			putch('%', putdat);
f01055fd:	83 ec 08             	sub    $0x8,%esp
f0105600:	56                   	push   %esi
f0105601:	6a 25                	push   $0x25
f0105603:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105605:	83 c4 10             	add    $0x10,%esp
f0105608:	89 f8                	mov    %edi,%eax
f010560a:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f010560e:	74 05                	je     f0105615 <vprintfmt+0x337>
f0105610:	83 e8 01             	sub    $0x1,%eax
f0105613:	eb f5                	jmp    f010560a <vprintfmt+0x32c>
f0105615:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105618:	e9 77 ff ff ff       	jmp    f0105594 <vprintfmt+0x2b6>

f010561d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010561d:	55                   	push   %ebp
f010561e:	89 e5                	mov    %esp,%ebp
f0105620:	83 ec 18             	sub    $0x18,%esp
f0105623:	8b 45 08             	mov    0x8(%ebp),%eax
f0105626:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = { buf, buf + n - 1, 0 };
f0105629:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010562c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105630:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105633:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010563a:	85 c0                	test   %eax,%eax
f010563c:	74 26                	je     f0105664 <vsnprintf+0x47>
f010563e:	85 d2                	test   %edx,%edx
f0105640:	7e 22                	jle    f0105664 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *) sprintputch, &b, fmt, ap);
f0105642:	ff 75 14             	push   0x14(%ebp)
f0105645:	ff 75 10             	push   0x10(%ebp)
f0105648:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010564b:	50                   	push   %eax
f010564c:	68 a4 52 10 f0       	push   $0xf01052a4
f0105651:	e8 88 fc ff ff       	call   f01052de <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105656:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105659:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010565c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010565f:	83 c4 10             	add    $0x10,%esp
}
f0105662:	c9                   	leave  
f0105663:	c3                   	ret    
		return -E_INVAL;
f0105664:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105669:	eb f7                	jmp    f0105662 <vsnprintf+0x45>

f010566b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010566b:	55                   	push   %ebp
f010566c:	89 e5                	mov    %esp,%ebp
f010566e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105671:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105674:	50                   	push   %eax
f0105675:	ff 75 10             	push   0x10(%ebp)
f0105678:	ff 75 0c             	push   0xc(%ebp)
f010567b:	ff 75 08             	push   0x8(%ebp)
f010567e:	e8 9a ff ff ff       	call   f010561d <vsnprintf>
	va_end(ap);

	return rc;
}
f0105683:	c9                   	leave  
f0105684:	c3                   	ret    

f0105685 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105685:	55                   	push   %ebp
f0105686:	89 e5                	mov    %esp,%ebp
f0105688:	57                   	push   %edi
f0105689:	56                   	push   %esi
f010568a:	53                   	push   %ebx
f010568b:	83 ec 0c             	sub    $0xc,%esp
f010568e:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0105691:	85 c0                	test   %eax,%eax
f0105693:	74 11                	je     f01056a6 <readline+0x21>
		cprintf("%s", prompt);
f0105695:	83 ec 08             	sub    $0x8,%esp
f0105698:	50                   	push   %eax
f0105699:	68 1d 75 10 f0       	push   $0xf010751d
f010569e:	e8 17 e1 ff ff       	call   f01037ba <cprintf>
f01056a3:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01056a6:	83 ec 0c             	sub    $0xc,%esp
f01056a9:	6a 00                	push   $0x0
f01056ab:	e8 4c b2 ff ff       	call   f01008fc <iscons>
f01056b0:	89 c7                	mov    %eax,%edi
f01056b2:	83 c4 10             	add    $0x10,%esp
	i = 0;
f01056b5:	be 00 00 00 00       	mov    $0x0,%esi
f01056ba:	eb 3f                	jmp    f01056fb <readline+0x76>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f01056bc:	83 ec 08             	sub    $0x8,%esp
f01056bf:	50                   	push   %eax
f01056c0:	68 64 80 10 f0       	push   $0xf0108064
f01056c5:	e8 f0 e0 ff ff       	call   f01037ba <cprintf>
			return NULL;
f01056ca:	83 c4 10             	add    $0x10,%esp
f01056cd:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f01056d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01056d5:	5b                   	pop    %ebx
f01056d6:	5e                   	pop    %esi
f01056d7:	5f                   	pop    %edi
f01056d8:	5d                   	pop    %ebp
f01056d9:	c3                   	ret    
			if (echoing)
f01056da:	85 ff                	test   %edi,%edi
f01056dc:	75 05                	jne    f01056e3 <readline+0x5e>
			i--;
f01056de:	83 ee 01             	sub    $0x1,%esi
f01056e1:	eb 18                	jmp    f01056fb <readline+0x76>
				cputchar('\b');
f01056e3:	83 ec 0c             	sub    $0xc,%esp
f01056e6:	6a 08                	push   $0x8
f01056e8:	e8 ee b1 ff ff       	call   f01008db <cputchar>
f01056ed:	83 c4 10             	add    $0x10,%esp
f01056f0:	eb ec                	jmp    f01056de <readline+0x59>
			buf[i++] = c;
f01056f2:	88 9e c0 9a 24 f0    	mov    %bl,-0xfdb6540(%esi)
f01056f8:	8d 76 01             	lea    0x1(%esi),%esi
		c = getchar();
f01056fb:	e8 eb b1 ff ff       	call   f01008eb <getchar>
f0105700:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105702:	85 c0                	test   %eax,%eax
f0105704:	78 b6                	js     f01056bc <readline+0x37>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105706:	83 f8 08             	cmp    $0x8,%eax
f0105709:	0f 94 c0             	sete   %al
f010570c:	83 fb 7f             	cmp    $0x7f,%ebx
f010570f:	0f 94 c2             	sete   %dl
f0105712:	08 d0                	or     %dl,%al
f0105714:	74 04                	je     f010571a <readline+0x95>
f0105716:	85 f6                	test   %esi,%esi
f0105718:	7f c0                	jg     f01056da <readline+0x55>
		} else if (c >= ' ' && i < BUFLEN - 1) {
f010571a:	83 fb 1f             	cmp    $0x1f,%ebx
f010571d:	7e 1a                	jle    f0105739 <readline+0xb4>
f010571f:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105725:	7f 12                	jg     f0105739 <readline+0xb4>
			if (echoing)
f0105727:	85 ff                	test   %edi,%edi
f0105729:	74 c7                	je     f01056f2 <readline+0x6d>
				cputchar(c);
f010572b:	83 ec 0c             	sub    $0xc,%esp
f010572e:	53                   	push   %ebx
f010572f:	e8 a7 b1 ff ff       	call   f01008db <cputchar>
f0105734:	83 c4 10             	add    $0x10,%esp
f0105737:	eb b9                	jmp    f01056f2 <readline+0x6d>
		} else if (c == '\n' || c == '\r') {
f0105739:	83 fb 0a             	cmp    $0xa,%ebx
f010573c:	74 05                	je     f0105743 <readline+0xbe>
f010573e:	83 fb 0d             	cmp    $0xd,%ebx
f0105741:	75 b8                	jne    f01056fb <readline+0x76>
			if (echoing)
f0105743:	85 ff                	test   %edi,%edi
f0105745:	75 11                	jne    f0105758 <readline+0xd3>
			buf[i] = 0;
f0105747:	c6 86 c0 9a 24 f0 00 	movb   $0x0,-0xfdb6540(%esi)
			return buf;
f010574e:	b8 c0 9a 24 f0       	mov    $0xf0249ac0,%eax
f0105753:	e9 7a ff ff ff       	jmp    f01056d2 <readline+0x4d>
				cputchar('\n');
f0105758:	83 ec 0c             	sub    $0xc,%esp
f010575b:	6a 0a                	push   $0xa
f010575d:	e8 79 b1 ff ff       	call   f01008db <cputchar>
f0105762:	83 c4 10             	add    $0x10,%esp
f0105765:	eb e0                	jmp    f0105747 <readline+0xc2>

f0105767 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105767:	55                   	push   %ebp
f0105768:	89 e5                	mov    %esp,%ebp
f010576a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f010576d:	b8 00 00 00 00       	mov    $0x0,%eax
f0105772:	eb 03                	jmp    f0105777 <strlen+0x10>
		n++;
f0105774:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f0105777:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010577b:	75 f7                	jne    f0105774 <strlen+0xd>
	return n;
}
f010577d:	5d                   	pop    %ebp
f010577e:	c3                   	ret    

f010577f <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010577f:	55                   	push   %ebp
f0105780:	89 e5                	mov    %esp,%ebp
f0105782:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105785:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105788:	b8 00 00 00 00       	mov    $0x0,%eax
f010578d:	eb 03                	jmp    f0105792 <strnlen+0x13>
		n++;
f010578f:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105792:	39 d0                	cmp    %edx,%eax
f0105794:	74 08                	je     f010579e <strnlen+0x1f>
f0105796:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f010579a:	75 f3                	jne    f010578f <strnlen+0x10>
f010579c:	89 c2                	mov    %eax,%edx
	return n;
}
f010579e:	89 d0                	mov    %edx,%eax
f01057a0:	5d                   	pop    %ebp
f01057a1:	c3                   	ret    

f01057a2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01057a2:	55                   	push   %ebp
f01057a3:	89 e5                	mov    %esp,%ebp
f01057a5:	53                   	push   %ebx
f01057a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01057a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01057ac:	b8 00 00 00 00       	mov    $0x0,%eax
f01057b1:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
f01057b5:	88 14 01             	mov    %dl,(%ecx,%eax,1)
f01057b8:	83 c0 01             	add    $0x1,%eax
f01057bb:	84 d2                	test   %dl,%dl
f01057bd:	75 f2                	jne    f01057b1 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f01057bf:	89 c8                	mov    %ecx,%eax
f01057c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01057c4:	c9                   	leave  
f01057c5:	c3                   	ret    

f01057c6 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01057c6:	55                   	push   %ebp
f01057c7:	89 e5                	mov    %esp,%ebp
f01057c9:	53                   	push   %ebx
f01057ca:	83 ec 10             	sub    $0x10,%esp
f01057cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01057d0:	53                   	push   %ebx
f01057d1:	e8 91 ff ff ff       	call   f0105767 <strlen>
f01057d6:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f01057d9:	ff 75 0c             	push   0xc(%ebp)
f01057dc:	01 d8                	add    %ebx,%eax
f01057de:	50                   	push   %eax
f01057df:	e8 be ff ff ff       	call   f01057a2 <strcpy>
	return dst;
}
f01057e4:	89 d8                	mov    %ebx,%eax
f01057e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01057e9:	c9                   	leave  
f01057ea:	c3                   	ret    

f01057eb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size)
{
f01057eb:	55                   	push   %ebp
f01057ec:	89 e5                	mov    %esp,%ebp
f01057ee:	56                   	push   %esi
f01057ef:	53                   	push   %ebx
f01057f0:	8b 75 08             	mov    0x8(%ebp),%esi
f01057f3:	8b 55 0c             	mov    0xc(%ebp),%edx
f01057f6:	89 f3                	mov    %esi,%ebx
f01057f8:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01057fb:	89 f0                	mov    %esi,%eax
f01057fd:	eb 0f                	jmp    f010580e <strncpy+0x23>
		*dst++ = *src;
f01057ff:	83 c0 01             	add    $0x1,%eax
f0105802:	0f b6 0a             	movzbl (%edx),%ecx
f0105805:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105808:	80 f9 01             	cmp    $0x1,%cl
f010580b:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
f010580e:	39 d8                	cmp    %ebx,%eax
f0105810:	75 ed                	jne    f01057ff <strncpy+0x14>
	}
	return ret;
}
f0105812:	89 f0                	mov    %esi,%eax
f0105814:	5b                   	pop    %ebx
f0105815:	5e                   	pop    %esi
f0105816:	5d                   	pop    %ebp
f0105817:	c3                   	ret    

f0105818 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105818:	55                   	push   %ebp
f0105819:	89 e5                	mov    %esp,%ebp
f010581b:	56                   	push   %esi
f010581c:	53                   	push   %ebx
f010581d:	8b 75 08             	mov    0x8(%ebp),%esi
f0105820:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105823:	8b 55 10             	mov    0x10(%ebp),%edx
f0105826:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105828:	85 d2                	test   %edx,%edx
f010582a:	74 21                	je     f010584d <strlcpy+0x35>
f010582c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0105830:	89 f2                	mov    %esi,%edx
f0105832:	eb 09                	jmp    f010583d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105834:	83 c1 01             	add    $0x1,%ecx
f0105837:	83 c2 01             	add    $0x1,%edx
f010583a:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
f010583d:	39 c2                	cmp    %eax,%edx
f010583f:	74 09                	je     f010584a <strlcpy+0x32>
f0105841:	0f b6 19             	movzbl (%ecx),%ebx
f0105844:	84 db                	test   %bl,%bl
f0105846:	75 ec                	jne    f0105834 <strlcpy+0x1c>
f0105848:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f010584a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f010584d:	29 f0                	sub    %esi,%eax
}
f010584f:	5b                   	pop    %ebx
f0105850:	5e                   	pop    %esi
f0105851:	5d                   	pop    %ebp
f0105852:	c3                   	ret    

f0105853 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105853:	55                   	push   %ebp
f0105854:	89 e5                	mov    %esp,%ebp
f0105856:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105859:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010585c:	eb 06                	jmp    f0105864 <strcmp+0x11>
		p++, q++;
f010585e:	83 c1 01             	add    $0x1,%ecx
f0105861:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f0105864:	0f b6 01             	movzbl (%ecx),%eax
f0105867:	84 c0                	test   %al,%al
f0105869:	74 04                	je     f010586f <strcmp+0x1c>
f010586b:	3a 02                	cmp    (%edx),%al
f010586d:	74 ef                	je     f010585e <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010586f:	0f b6 c0             	movzbl %al,%eax
f0105872:	0f b6 12             	movzbl (%edx),%edx
f0105875:	29 d0                	sub    %edx,%eax
}
f0105877:	5d                   	pop    %ebp
f0105878:	c3                   	ret    

f0105879 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105879:	55                   	push   %ebp
f010587a:	89 e5                	mov    %esp,%ebp
f010587c:	53                   	push   %ebx
f010587d:	8b 45 08             	mov    0x8(%ebp),%eax
f0105880:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105883:	89 c3                	mov    %eax,%ebx
f0105885:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105888:	eb 06                	jmp    f0105890 <strncmp+0x17>
		n--, p++, q++;
f010588a:	83 c0 01             	add    $0x1,%eax
f010588d:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0105890:	39 d8                	cmp    %ebx,%eax
f0105892:	74 18                	je     f01058ac <strncmp+0x33>
f0105894:	0f b6 08             	movzbl (%eax),%ecx
f0105897:	84 c9                	test   %cl,%cl
f0105899:	74 04                	je     f010589f <strncmp+0x26>
f010589b:	3a 0a                	cmp    (%edx),%cl
f010589d:	74 eb                	je     f010588a <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010589f:	0f b6 00             	movzbl (%eax),%eax
f01058a2:	0f b6 12             	movzbl (%edx),%edx
f01058a5:	29 d0                	sub    %edx,%eax
}
f01058a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01058aa:	c9                   	leave  
f01058ab:	c3                   	ret    
		return 0;
f01058ac:	b8 00 00 00 00       	mov    $0x0,%eax
f01058b1:	eb f4                	jmp    f01058a7 <strncmp+0x2e>

f01058b3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01058b3:	55                   	push   %ebp
f01058b4:	89 e5                	mov    %esp,%ebp
f01058b6:	8b 45 08             	mov    0x8(%ebp),%eax
f01058b9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01058bd:	eb 03                	jmp    f01058c2 <strchr+0xf>
f01058bf:	83 c0 01             	add    $0x1,%eax
f01058c2:	0f b6 10             	movzbl (%eax),%edx
f01058c5:	84 d2                	test   %dl,%dl
f01058c7:	74 06                	je     f01058cf <strchr+0x1c>
		if (*s == c)
f01058c9:	38 ca                	cmp    %cl,%dl
f01058cb:	75 f2                	jne    f01058bf <strchr+0xc>
f01058cd:	eb 05                	jmp    f01058d4 <strchr+0x21>
			return (char *) s;
	return 0;
f01058cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01058d4:	5d                   	pop    %ebp
f01058d5:	c3                   	ret    

f01058d6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01058d6:	55                   	push   %ebp
f01058d7:	89 e5                	mov    %esp,%ebp
f01058d9:	8b 45 08             	mov    0x8(%ebp),%eax
f01058dc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01058e0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01058e3:	38 ca                	cmp    %cl,%dl
f01058e5:	74 09                	je     f01058f0 <strfind+0x1a>
f01058e7:	84 d2                	test   %dl,%dl
f01058e9:	74 05                	je     f01058f0 <strfind+0x1a>
	for (; *s; s++)
f01058eb:	83 c0 01             	add    $0x1,%eax
f01058ee:	eb f0                	jmp    f01058e0 <strfind+0xa>
			break;
	return (char *) s;
}
f01058f0:	5d                   	pop    %ebp
f01058f1:	c3                   	ret    

f01058f2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01058f2:	55                   	push   %ebp
f01058f3:	89 e5                	mov    %esp,%ebp
f01058f5:	57                   	push   %edi
f01058f6:	56                   	push   %esi
f01058f7:	53                   	push   %ebx
f01058f8:	8b 55 08             	mov    0x8(%ebp),%edx
f01058fb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
f01058fe:	85 c9                	test   %ecx,%ecx
f0105900:	74 33                	je     f0105935 <memset+0x43>
		return v;
	if ((int) v % 4 == 0 && n % 4 == 0) {
f0105902:	89 d0                	mov    %edx,%eax
f0105904:	09 c8                	or     %ecx,%eax
f0105906:	a8 03                	test   $0x3,%al
f0105908:	75 23                	jne    f010592d <memset+0x3b>
		c &= 0xFF;
f010590a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c << 24) | (c << 16) | (c << 8) | c;
f010590e:	89 d8                	mov    %ebx,%eax
f0105910:	c1 e0 08             	shl    $0x8,%eax
f0105913:	89 df                	mov    %ebx,%edi
f0105915:	c1 e7 18             	shl    $0x18,%edi
f0105918:	89 de                	mov    %ebx,%esi
f010591a:	c1 e6 10             	shl    $0x10,%esi
f010591d:	09 f7                	or     %esi,%edi
f010591f:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
		             : "=D"(p), "=c"(n)
		             : "D"(p), "a"(c), "c"(n / 4)
f0105921:	c1 e9 02             	shr    $0x2,%ecx
		c = (c << 24) | (c << 16) | (c << 8) | c;
f0105924:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
f0105926:	89 d7                	mov    %edx,%edi
f0105928:	fc                   	cld    
f0105929:	f3 ab                	rep stos %eax,%es:(%edi)
f010592b:	eb 08                	jmp    f0105935 <memset+0x43>
		             : "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010592d:	89 d7                	mov    %edx,%edi
f010592f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105932:	fc                   	cld    
f0105933:	f3 aa                	rep stos %al,%es:(%edi)
		             : "=D"(p), "=c"(n)
		             : "0"(p), "a"(c), "1"(n)
		             : "cc", "memory");
	return v;
}
f0105935:	89 d0                	mov    %edx,%eax
f0105937:	5b                   	pop    %ebx
f0105938:	5e                   	pop    %esi
f0105939:	5f                   	pop    %edi
f010593a:	5d                   	pop    %ebp
f010593b:	c3                   	ret    

f010593c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010593c:	55                   	push   %ebp
f010593d:	89 e5                	mov    %esp,%ebp
f010593f:	57                   	push   %edi
f0105940:	56                   	push   %esi
f0105941:	8b 45 08             	mov    0x8(%ebp),%eax
f0105944:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105947:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010594a:	39 c6                	cmp    %eax,%esi
f010594c:	73 32                	jae    f0105980 <memmove+0x44>
f010594e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105951:	39 c2                	cmp    %eax,%edx
f0105953:	76 2b                	jbe    f0105980 <memmove+0x44>
		s += n;
		d += n;
f0105955:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
f0105958:	89 d6                	mov    %edx,%esi
f010595a:	09 fe                	or     %edi,%esi
f010595c:	09 ce                	or     %ecx,%esi
f010595e:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105964:	75 0e                	jne    f0105974 <memmove+0x38>
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
f0105966:	83 ef 04             	sub    $0x4,%edi
			             "S"(s - 4),
f0105969:	8d 72 fc             	lea    -0x4(%edx),%esi
			             "c"(n / 4)
f010596c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n" ::"D"(d - 4),
f010596f:	fd                   	std    
f0105970:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105972:	eb 09                	jmp    f010597d <memmove+0x41>
			             : "cc", "memory");
		else
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
f0105974:	83 ef 01             	sub    $0x1,%edi
			             "S"(s - 1),
f0105977:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n" ::"D"(d - 1),
f010597a:	fd                   	std    
f010597b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             "c"(n)
			             : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010597d:	fc                   	cld    
f010597e:	eb 1a                	jmp    f010599a <memmove+0x5e>
	} else {
		if ((int) s % 4 == 0 && (int) d % 4 == 0 && n % 4 == 0)
f0105980:	89 f2                	mov    %esi,%edx
f0105982:	09 c2                	or     %eax,%edx
f0105984:	09 ca                	or     %ecx,%edx
f0105986:	f6 c2 03             	test   $0x3,%dl
f0105989:	75 0a                	jne    f0105995 <memmove+0x59>
			asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
f010598b:	c1 e9 02             	shr    $0x2,%ecx
f010598e:	89 c7                	mov    %eax,%edi
f0105990:	fc                   	cld    
f0105991:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105993:	eb 05                	jmp    f010599a <memmove+0x5e>
			             : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
f0105995:	89 c7                	mov    %eax,%edi
f0105997:	fc                   	cld    
f0105998:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
			             : "cc", "memory");
	}
	return dst;
}
f010599a:	5e                   	pop    %esi
f010599b:	5f                   	pop    %edi
f010599c:	5d                   	pop    %ebp
f010599d:	c3                   	ret    

f010599e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010599e:	55                   	push   %ebp
f010599f:	89 e5                	mov    %esp,%ebp
f01059a1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f01059a4:	ff 75 10             	push   0x10(%ebp)
f01059a7:	ff 75 0c             	push   0xc(%ebp)
f01059aa:	ff 75 08             	push   0x8(%ebp)
f01059ad:	e8 8a ff ff ff       	call   f010593c <memmove>
}
f01059b2:	c9                   	leave  
f01059b3:	c3                   	ret    

f01059b4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01059b4:	55                   	push   %ebp
f01059b5:	89 e5                	mov    %esp,%ebp
f01059b7:	56                   	push   %esi
f01059b8:	53                   	push   %ebx
f01059b9:	8b 45 08             	mov    0x8(%ebp),%eax
f01059bc:	8b 55 0c             	mov    0xc(%ebp),%edx
f01059bf:	89 c6                	mov    %eax,%esi
f01059c1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01059c4:	eb 06                	jmp    f01059cc <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f01059c6:	83 c0 01             	add    $0x1,%eax
f01059c9:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
f01059cc:	39 f0                	cmp    %esi,%eax
f01059ce:	74 14                	je     f01059e4 <memcmp+0x30>
		if (*s1 != *s2)
f01059d0:	0f b6 08             	movzbl (%eax),%ecx
f01059d3:	0f b6 1a             	movzbl (%edx),%ebx
f01059d6:	38 d9                	cmp    %bl,%cl
f01059d8:	74 ec                	je     f01059c6 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
f01059da:	0f b6 c1             	movzbl %cl,%eax
f01059dd:	0f b6 db             	movzbl %bl,%ebx
f01059e0:	29 d8                	sub    %ebx,%eax
f01059e2:	eb 05                	jmp    f01059e9 <memcmp+0x35>
	}

	return 0;
f01059e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01059e9:	5b                   	pop    %ebx
f01059ea:	5e                   	pop    %esi
f01059eb:	5d                   	pop    %ebp
f01059ec:	c3                   	ret    

f01059ed <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01059ed:	55                   	push   %ebp
f01059ee:	89 e5                	mov    %esp,%ebp
f01059f0:	8b 45 08             	mov    0x8(%ebp),%eax
f01059f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f01059f6:	89 c2                	mov    %eax,%edx
f01059f8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01059fb:	eb 03                	jmp    f0105a00 <memfind+0x13>
f01059fd:	83 c0 01             	add    $0x1,%eax
f0105a00:	39 d0                	cmp    %edx,%eax
f0105a02:	73 04                	jae    f0105a08 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105a04:	38 08                	cmp    %cl,(%eax)
f0105a06:	75 f5                	jne    f01059fd <memfind+0x10>
			break;
	return (void *) s;
}
f0105a08:	5d                   	pop    %ebp
f0105a09:	c3                   	ret    

f0105a0a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105a0a:	55                   	push   %ebp
f0105a0b:	89 e5                	mov    %esp,%ebp
f0105a0d:	57                   	push   %edi
f0105a0e:	56                   	push   %esi
f0105a0f:	53                   	push   %ebx
f0105a10:	8b 55 08             	mov    0x8(%ebp),%edx
f0105a13:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105a16:	eb 03                	jmp    f0105a1b <strtol+0x11>
		s++;
f0105a18:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
f0105a1b:	0f b6 02             	movzbl (%edx),%eax
f0105a1e:	3c 20                	cmp    $0x20,%al
f0105a20:	74 f6                	je     f0105a18 <strtol+0xe>
f0105a22:	3c 09                	cmp    $0x9,%al
f0105a24:	74 f2                	je     f0105a18 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f0105a26:	3c 2b                	cmp    $0x2b,%al
f0105a28:	74 2a                	je     f0105a54 <strtol+0x4a>
	int neg = 0;
f0105a2a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0105a2f:	3c 2d                	cmp    $0x2d,%al
f0105a31:	74 2b                	je     f0105a5e <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105a33:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0105a39:	75 0f                	jne    f0105a4a <strtol+0x40>
f0105a3b:	80 3a 30             	cmpb   $0x30,(%edx)
f0105a3e:	74 28                	je     f0105a68 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105a40:	85 db                	test   %ebx,%ebx
f0105a42:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105a47:	0f 44 d8             	cmove  %eax,%ebx
f0105a4a:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105a4f:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0105a52:	eb 46                	jmp    f0105a9a <strtol+0x90>
		s++;
f0105a54:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
f0105a57:	bf 00 00 00 00       	mov    $0x0,%edi
f0105a5c:	eb d5                	jmp    f0105a33 <strtol+0x29>
		s++, neg = 1;
f0105a5e:	83 c2 01             	add    $0x1,%edx
f0105a61:	bf 01 00 00 00       	mov    $0x1,%edi
f0105a66:	eb cb                	jmp    f0105a33 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105a68:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0105a6c:	74 0e                	je     f0105a7c <strtol+0x72>
	else if (base == 0 && s[0] == '0')
f0105a6e:	85 db                	test   %ebx,%ebx
f0105a70:	75 d8                	jne    f0105a4a <strtol+0x40>
		s++, base = 8;
f0105a72:	83 c2 01             	add    $0x1,%edx
f0105a75:	bb 08 00 00 00       	mov    $0x8,%ebx
f0105a7a:	eb ce                	jmp    f0105a4a <strtol+0x40>
		s += 2, base = 16;
f0105a7c:	83 c2 02             	add    $0x2,%edx
f0105a7f:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105a84:	eb c4                	jmp    f0105a4a <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
f0105a86:	0f be c0             	movsbl %al,%eax
f0105a89:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0105a8c:	3b 45 10             	cmp    0x10(%ebp),%eax
f0105a8f:	7d 3a                	jge    f0105acb <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f0105a91:	83 c2 01             	add    $0x1,%edx
f0105a94:	0f af 4d 10          	imul   0x10(%ebp),%ecx
f0105a98:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
f0105a9a:	0f b6 02             	movzbl (%edx),%eax
f0105a9d:	8d 70 d0             	lea    -0x30(%eax),%esi
f0105aa0:	89 f3                	mov    %esi,%ebx
f0105aa2:	80 fb 09             	cmp    $0x9,%bl
f0105aa5:	76 df                	jbe    f0105a86 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
f0105aa7:	8d 70 9f             	lea    -0x61(%eax),%esi
f0105aaa:	89 f3                	mov    %esi,%ebx
f0105aac:	80 fb 19             	cmp    $0x19,%bl
f0105aaf:	77 08                	ja     f0105ab9 <strtol+0xaf>
			dig = *s - 'a' + 10;
f0105ab1:	0f be c0             	movsbl %al,%eax
f0105ab4:	83 e8 57             	sub    $0x57,%eax
f0105ab7:	eb d3                	jmp    f0105a8c <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
f0105ab9:	8d 70 bf             	lea    -0x41(%eax),%esi
f0105abc:	89 f3                	mov    %esi,%ebx
f0105abe:	80 fb 19             	cmp    $0x19,%bl
f0105ac1:	77 08                	ja     f0105acb <strtol+0xc1>
			dig = *s - 'A' + 10;
f0105ac3:	0f be c0             	movsbl %al,%eax
f0105ac6:	83 e8 37             	sub    $0x37,%eax
f0105ac9:	eb c1                	jmp    f0105a8c <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
f0105acb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105acf:	74 05                	je     f0105ad6 <strtol+0xcc>
		*endptr = (char *) s;
f0105ad1:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105ad4:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
f0105ad6:	89 c8                	mov    %ecx,%eax
f0105ad8:	f7 d8                	neg    %eax
f0105ada:	85 ff                	test   %edi,%edi
f0105adc:	0f 45 c8             	cmovne %eax,%ecx
}
f0105adf:	89 c8                	mov    %ecx,%eax
f0105ae1:	5b                   	pop    %ebx
f0105ae2:	5e                   	pop    %esi
f0105ae3:	5f                   	pop    %edi
f0105ae4:	5d                   	pop    %ebp
f0105ae5:	c3                   	ret    
f0105ae6:	66 90                	xchg   %ax,%ax

f0105ae8 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105ae8:	fa                   	cli    

	xorw    %ax, %ax
f0105ae9:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0105aeb:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105aed:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105aef:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105af1:	0f 01 16             	lgdtl  (%esi)
f0105af4:	7c 70                	jl     f0105b66 <gdtdesc+0x2>
	movl    %cr0, %eax
f0105af6:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105af9:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105afd:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105b00:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105b06:	08 00                	or     %al,(%eax)

f0105b08 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105b08:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105b0c:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105b0e:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105b10:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105b12:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105b16:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105b18:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105b1a:	b8 00 40 12 00       	mov    $0x124000,%eax
	movl    %eax, %cr3
f0105b1f:	0f 22 d8             	mov    %eax,%cr3

	# Enable large pages
	movl %cr4, %eax
f0105b22:	0f 20 e0             	mov    %cr4,%eax
	orl $(CR4_PSE), %eax
f0105b25:	83 c8 10             	or     $0x10,%eax
	movl %eax, %cr4
f0105b28:	0f 22 e0             	mov    %eax,%cr4

	# Turn on paging.
	movl    %cr0, %eax
f0105b2b:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105b2e:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0105b33:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105b36:	8b 25 04 80 24 f0    	mov    0xf0248004,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105b3c:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105b41:	b8 39 02 10 f0       	mov    $0xf0100239,%eax
	call    *%eax
f0105b46:	ff d0                	call   *%eax

f0105b48 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0105b48:	eb fe                	jmp    f0105b48 <spin>
f0105b4a:	66 90                	xchg   %ax,%ax

f0105b4c <gdt>:
	...
f0105b54:	ff                   	(bad)  
f0105b55:	ff 00                	incl   (%eax)
f0105b57:	00 00                	add    %al,(%eax)
f0105b59:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105b60:	00                   	.byte 0x0
f0105b61:	92                   	xchg   %eax,%edx
f0105b62:	cf                   	iret   
	...

f0105b64 <gdtdesc>:
f0105b64:	17                   	pop    %ss
f0105b65:	00 64 70 00          	add    %ah,0x0(%eax,%esi,2)
	...

f0105b6a <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105b6a:	90                   	nop

f0105b6b <inb>:
	asm volatile("inb %w1,%0" : "=a"(data) : "d"(port));
f0105b6b:	89 c2                	mov    %eax,%edx
f0105b6d:	ec                   	in     (%dx),%al
}
f0105b6e:	c3                   	ret    

f0105b6f <outb>:
{
f0105b6f:	89 c1                	mov    %eax,%ecx
f0105b71:	89 d0                	mov    %edx,%eax
	asm volatile("outb %0,%w1" : : "a"(data), "d"(port));
f0105b73:	89 ca                	mov    %ecx,%edx
f0105b75:	ee                   	out    %al,(%dx)
}
f0105b76:	c3                   	ret    

f0105b77 <sum>:
#define MPIOINTR 0x03  // One per bus interrupt source
#define MPLINTR 0x04   // One per system interrupt source

static uint8_t
sum(void *addr, int len)
{
f0105b77:	55                   	push   %ebp
f0105b78:	89 e5                	mov    %esp,%ebp
f0105b7a:	56                   	push   %esi
f0105b7b:	53                   	push   %ebx
f0105b7c:	89 c6                	mov    %eax,%esi
	int i, sum;

	sum = 0;
f0105b7e:	b8 00 00 00 00       	mov    $0x0,%eax
	for (i = 0; i < len; i++)
f0105b83:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105b88:	eb 09                	jmp    f0105b93 <sum+0x1c>
		sum += ((uint8_t *) addr)[i];
f0105b8a:	0f b6 1c 0e          	movzbl (%esi,%ecx,1),%ebx
f0105b8e:	01 d8                	add    %ebx,%eax
	for (i = 0; i < len; i++)
f0105b90:	83 c1 01             	add    $0x1,%ecx
f0105b93:	39 d1                	cmp    %edx,%ecx
f0105b95:	7c f3                	jl     f0105b8a <sum+0x13>
	return sum;
}
f0105b97:	5b                   	pop    %ebx
f0105b98:	5e                   	pop    %esi
f0105b99:	5d                   	pop    %ebp
f0105b9a:	c3                   	ret    

f0105b9b <_kaddr>:
{
f0105b9b:	55                   	push   %ebp
f0105b9c:	89 e5                	mov    %esp,%ebp
f0105b9e:	53                   	push   %ebx
f0105b9f:	83 ec 04             	sub    $0x4,%esp
	if (PGNUM(pa) >= npages)
f0105ba2:	89 cb                	mov    %ecx,%ebx
f0105ba4:	c1 eb 0c             	shr    $0xc,%ebx
f0105ba7:	3b 1d 60 82 24 f0    	cmp    0xf0248260,%ebx
f0105bad:	73 0b                	jae    f0105bba <_kaddr+0x1f>
	return (void *) (pa + KERNBASE);
f0105baf:	8d 81 00 00 00 f0    	lea    -0x10000000(%ecx),%eax
}
f0105bb5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105bb8:	c9                   	leave  
f0105bb9:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105bba:	51                   	push   %ecx
f0105bbb:	68 0c 66 10 f0       	push   $0xf010660c
f0105bc0:	52                   	push   %edx
f0105bc1:	50                   	push   %eax
f0105bc2:	e8 a3 a4 ff ff       	call   f010006a <_panic>

f0105bc7 <mpsearch1>:

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105bc7:	55                   	push   %ebp
f0105bc8:	89 e5                	mov    %esp,%ebp
f0105bca:	57                   	push   %edi
f0105bcb:	56                   	push   %esi
f0105bcc:	53                   	push   %ebx
f0105bcd:	83 ec 0c             	sub    $0xc,%esp
f0105bd0:	89 c7                	mov    %eax,%edi
f0105bd2:	89 d6                	mov    %edx,%esi
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105bd4:	89 c1                	mov    %eax,%ecx
f0105bd6:	ba 56 00 00 00       	mov    $0x56,%edx
f0105bdb:	b8 01 82 10 f0       	mov    $0xf0108201,%eax
f0105be0:	e8 b6 ff ff ff       	call   f0105b9b <_kaddr>
f0105be5:	89 c3                	mov    %eax,%ebx
f0105be7:	8d 0c 3e             	lea    (%esi,%edi,1),%ecx
f0105bea:	ba 56 00 00 00       	mov    $0x56,%edx
f0105bef:	b8 01 82 10 f0       	mov    $0xf0108201,%eax
f0105bf4:	e8 a2 ff ff ff       	call   f0105b9b <_kaddr>
f0105bf9:	89 c6                	mov    %eax,%esi

	for (; mp < end; mp++)
f0105bfb:	eb 03                	jmp    f0105c00 <mpsearch1+0x39>
f0105bfd:	83 c3 10             	add    $0x10,%ebx
f0105c00:	39 f3                	cmp    %esi,%ebx
f0105c02:	73 29                	jae    f0105c2d <mpsearch1+0x66>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105c04:	83 ec 04             	sub    $0x4,%esp
f0105c07:	6a 04                	push   $0x4
f0105c09:	68 11 82 10 f0       	push   $0xf0108211
f0105c0e:	53                   	push   %ebx
f0105c0f:	e8 a0 fd ff ff       	call   f01059b4 <memcmp>
f0105c14:	83 c4 10             	add    $0x10,%esp
f0105c17:	85 c0                	test   %eax,%eax
f0105c19:	75 e2                	jne    f0105bfd <mpsearch1+0x36>
		    sum(mp, sizeof(*mp)) == 0)
f0105c1b:	ba 10 00 00 00       	mov    $0x10,%edx
f0105c20:	89 d8                	mov    %ebx,%eax
f0105c22:	e8 50 ff ff ff       	call   f0105b77 <sum>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105c27:	84 c0                	test   %al,%al
f0105c29:	75 d2                	jne    f0105bfd <mpsearch1+0x36>
f0105c2b:	eb 05                	jmp    f0105c32 <mpsearch1+0x6b>
			return mp;
	return NULL;
f0105c2d:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0105c32:	89 d8                	mov    %ebx,%eax
f0105c34:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105c37:	5b                   	pop    %ebx
f0105c38:	5e                   	pop    %esi
f0105c39:	5f                   	pop    %edi
f0105c3a:	5d                   	pop    %ebp
f0105c3b:	c3                   	ret    

f0105c3c <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) if there is no EBDA, in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp *
mpsearch(void)
{
f0105c3c:	55                   	push   %ebp
f0105c3d:	89 e5                	mov    %esp,%ebp
f0105c3f:	83 ec 08             	sub    $0x8,%esp
	struct mp *mp;

	static_assert(sizeof(*mp) == 16);

	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);
f0105c42:	b9 00 04 00 00       	mov    $0x400,%ecx
f0105c47:	ba 6e 00 00 00       	mov    $0x6e,%edx
f0105c4c:	b8 01 82 10 f0       	mov    $0xf0108201,%eax
f0105c51:	e8 45 ff ff ff       	call   f0105b9b <_kaddr>

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0105c56:	0f b7 50 0e          	movzwl 0xe(%eax),%edx
f0105c5a:	85 d2                	test   %edx,%edx
f0105c5c:	74 24                	je     f0105c82 <mpsearch+0x46>
		p <<= 4;  // Translate from segment to PA
f0105c5e:	89 d0                	mov    %edx,%eax
f0105c60:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0105c63:	ba 00 04 00 00       	mov    $0x400,%edx
f0105c68:	e8 5a ff ff ff       	call   f0105bc7 <mpsearch1>
f0105c6d:	85 c0                	test   %eax,%eax
f0105c6f:	75 0f                	jne    f0105c80 <mpsearch+0x44>
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0105c71:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105c76:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105c7b:	e8 47 ff ff ff       	call   f0105bc7 <mpsearch1>
}
f0105c80:	c9                   	leave  
f0105c81:	c3                   	ret    
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0105c82:	0f b7 40 13          	movzwl 0x13(%eax),%eax
f0105c86:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f0105c89:	2d 00 04 00 00       	sub    $0x400,%eax
f0105c8e:	ba 00 04 00 00       	mov    $0x400,%edx
f0105c93:	e8 2f ff ff ff       	call   f0105bc7 <mpsearch1>
f0105c98:	85 c0                	test   %eax,%eax
f0105c9a:	75 e4                	jne    f0105c80 <mpsearch+0x44>
f0105c9c:	eb d3                	jmp    f0105c71 <mpsearch+0x35>

f0105c9e <mpconfig>:
// Search for an MP configuration table.  For now, don't accept the
// default configurations (physaddr == 0).
// Check for the correct signature, checksum, and version.
static struct mpconf *
mpconfig(struct mp **pmp)
{
f0105c9e:	55                   	push   %ebp
f0105c9f:	89 e5                	mov    %esp,%ebp
f0105ca1:	57                   	push   %edi
f0105ca2:	56                   	push   %esi
f0105ca3:	53                   	push   %ebx
f0105ca4:	83 ec 1c             	sub    $0x1c,%esp
f0105ca7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0105caa:	e8 8d ff ff ff       	call   f0105c3c <mpsearch>
f0105caf:	89 c6                	mov    %eax,%esi
f0105cb1:	85 c0                	test   %eax,%eax
f0105cb3:	0f 84 ef 00 00 00    	je     f0105da8 <mpconfig+0x10a>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0105cb9:	8b 48 04             	mov    0x4(%eax),%ecx
f0105cbc:	85 c9                	test   %ecx,%ecx
f0105cbe:	74 6e                	je     f0105d2e <mpconfig+0x90>
f0105cc0:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0105cc4:	75 68                	jne    f0105d2e <mpconfig+0x90>
		cprintf("SMP: Default configurations not implemented\n");
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
f0105cc6:	ba 8f 00 00 00       	mov    $0x8f,%edx
f0105ccb:	b8 01 82 10 f0       	mov    $0xf0108201,%eax
f0105cd0:	e8 c6 fe ff ff       	call   f0105b9b <_kaddr>
f0105cd5:	89 c3                	mov    %eax,%ebx
	if (memcmp(conf, "PCMP", 4) != 0) {
f0105cd7:	83 ec 04             	sub    $0x4,%esp
f0105cda:	6a 04                	push   $0x4
f0105cdc:	68 16 82 10 f0       	push   $0xf0108216
f0105ce1:	50                   	push   %eax
f0105ce2:	e8 cd fc ff ff       	call   f01059b4 <memcmp>
f0105ce7:	83 c4 10             	add    $0x10,%esp
f0105cea:	85 c0                	test   %eax,%eax
f0105cec:	75 57                	jne    f0105d45 <mpconfig+0xa7>
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105cee:	0f b7 7b 04          	movzwl 0x4(%ebx),%edi
f0105cf2:	0f b7 d7             	movzwl %di,%edx
f0105cf5:	89 d8                	mov    %ebx,%eax
f0105cf7:	e8 7b fe ff ff       	call   f0105b77 <sum>
f0105cfc:	84 c0                	test   %al,%al
f0105cfe:	75 5c                	jne    f0105d5c <mpconfig+0xbe>
		cprintf("SMP: Bad MP configuration checksum\n");
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0105d00:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f0105d04:	3c 01                	cmp    $0x1,%al
f0105d06:	74 04                	je     f0105d0c <mpconfig+0x6e>
f0105d08:	3c 04                	cmp    $0x4,%al
f0105d0a:	75 67                	jne    f0105d73 <mpconfig+0xd5>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *) conf + conf->length, conf->xlength) + conf->xchecksum) &
f0105d0c:	0f b7 53 28          	movzwl 0x28(%ebx),%edx
f0105d10:	0f b7 c7             	movzwl %di,%eax
f0105d13:	01 d8                	add    %ebx,%eax
f0105d15:	e8 5d fe ff ff       	call   f0105b77 <sum>
f0105d1a:	02 43 2a             	add    0x2a(%ebx),%al
f0105d1d:	75 6f                	jne    f0105d8e <mpconfig+0xf0>
	    0xff) {
		cprintf("SMP: Bad MP configuration extended checksum\n");
		return NULL;
	}
	*pmp = mp;
f0105d1f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105d22:	89 30                	mov    %esi,(%eax)
	return conf;
}
f0105d24:	89 d8                	mov    %ebx,%eax
f0105d26:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105d29:	5b                   	pop    %ebx
f0105d2a:	5e                   	pop    %esi
f0105d2b:	5f                   	pop    %edi
f0105d2c:	5d                   	pop    %ebp
f0105d2d:	c3                   	ret    
		cprintf("SMP: Default configurations not implemented\n");
f0105d2e:	83 ec 0c             	sub    $0xc,%esp
f0105d31:	68 74 80 10 f0       	push   $0xf0108074
f0105d36:	e8 7f da ff ff       	call   f01037ba <cprintf>
		return NULL;
f0105d3b:	83 c4 10             	add    $0x10,%esp
f0105d3e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105d43:	eb df                	jmp    f0105d24 <mpconfig+0x86>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105d45:	83 ec 0c             	sub    $0xc,%esp
f0105d48:	68 a4 80 10 f0       	push   $0xf01080a4
f0105d4d:	e8 68 da ff ff       	call   f01037ba <cprintf>
		return NULL;
f0105d52:	83 c4 10             	add    $0x10,%esp
f0105d55:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105d5a:	eb c8                	jmp    f0105d24 <mpconfig+0x86>
		cprintf("SMP: Bad MP configuration checksum\n");
f0105d5c:	83 ec 0c             	sub    $0xc,%esp
f0105d5f:	68 d8 80 10 f0       	push   $0xf01080d8
f0105d64:	e8 51 da ff ff       	call   f01037ba <cprintf>
		return NULL;
f0105d69:	83 c4 10             	add    $0x10,%esp
f0105d6c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105d71:	eb b1                	jmp    f0105d24 <mpconfig+0x86>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0105d73:	83 ec 08             	sub    $0x8,%esp
f0105d76:	0f b6 c0             	movzbl %al,%eax
f0105d79:	50                   	push   %eax
f0105d7a:	68 fc 80 10 f0       	push   $0xf01080fc
f0105d7f:	e8 36 da ff ff       	call   f01037ba <cprintf>
		return NULL;
f0105d84:	83 c4 10             	add    $0x10,%esp
f0105d87:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105d8c:	eb 96                	jmp    f0105d24 <mpconfig+0x86>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105d8e:	83 ec 0c             	sub    $0xc,%esp
f0105d91:	68 1c 81 10 f0       	push   $0xf010811c
f0105d96:	e8 1f da ff ff       	call   f01037ba <cprintf>
		return NULL;
f0105d9b:	83 c4 10             	add    $0x10,%esp
f0105d9e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105da3:	e9 7c ff ff ff       	jmp    f0105d24 <mpconfig+0x86>
		return NULL;
f0105da8:	89 c3                	mov    %eax,%ebx
f0105daa:	e9 75 ff ff ff       	jmp    f0105d24 <mpconfig+0x86>

f0105daf <mp_init>:

void
mp_init(void)
{
f0105daf:	55                   	push   %ebp
f0105db0:	89 e5                	mov    %esp,%ebp
f0105db2:	57                   	push   %edi
f0105db3:	56                   	push   %esi
f0105db4:	53                   	push   %ebx
f0105db5:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105db8:	c7 05 08 a0 28 f0 20 	movl   $0xf028a020,0xf028a008
f0105dbf:	a0 28 f0 
	if ((conf = mpconfig(&mp)) == 0)
f0105dc2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105dc5:	e8 d4 fe ff ff       	call   f0105c9e <mpconfig>
f0105dca:	85 c0                	test   %eax,%eax
f0105dcc:	0f 84 e5 00 00 00    	je     f0105eb7 <mp_init+0x108>
f0105dd2:	89 c7                	mov    %eax,%edi
		return;
	ismp = 1;
f0105dd4:	c7 05 04 a0 28 f0 01 	movl   $0x1,0xf028a004
f0105ddb:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105dde:	8b 40 24             	mov    0x24(%eax),%eax
f0105de1:	a3 c4 a3 28 f0       	mov    %eax,0xf028a3c4

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105de6:	8d 77 2c             	lea    0x2c(%edi),%esi
f0105de9:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105dee:	eb 38                	jmp    f0105e28 <mp_init+0x79>
		switch (*p) {
		case MPPROC:
			proc = (struct mpproc *) p;
			if (proc->flags & MPPROC_BOOT)
f0105df0:	f6 46 03 02          	testb  $0x2,0x3(%esi)
f0105df4:	74 11                	je     f0105e07 <mp_init+0x58>
				bootcpu = &cpus[ncpu];
f0105df6:	6b 05 00 a0 28 f0 74 	imul   $0x74,0xf028a000,%eax
f0105dfd:	05 20 a0 28 f0       	add    $0xf028a020,%eax
f0105e02:	a3 08 a0 28 f0       	mov    %eax,0xf028a008
			if (ncpu < NCPU) {
f0105e07:	a1 00 a0 28 f0       	mov    0xf028a000,%eax
f0105e0c:	83 f8 07             	cmp    $0x7,%eax
f0105e0f:	7f 33                	jg     f0105e44 <mp_init+0x95>
				cpus[ncpu].cpu_id = ncpu;
f0105e11:	6b d0 74             	imul   $0x74,%eax,%edx
f0105e14:	88 82 20 a0 28 f0    	mov    %al,-0xfd75fe0(%edx)
				ncpu++;
f0105e1a:	83 c0 01             	add    $0x1,%eax
f0105e1d:	a3 00 a0 28 f0       	mov    %eax,0xf028a000
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
				        proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105e22:	83 c6 14             	add    $0x14,%esi
	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105e25:	83 c3 01             	add    $0x1,%ebx
f0105e28:	0f b7 47 22          	movzwl 0x22(%edi),%eax
f0105e2c:	39 d8                	cmp    %ebx,%eax
f0105e2e:	76 4f                	jbe    f0105e7f <mp_init+0xd0>
		switch (*p) {
f0105e30:	0f b6 06             	movzbl (%esi),%eax
f0105e33:	84 c0                	test   %al,%al
f0105e35:	74 b9                	je     f0105df0 <mp_init+0x41>
f0105e37:	8d 50 ff             	lea    -0x1(%eax),%edx
f0105e3a:	80 fa 03             	cmp    $0x3,%dl
f0105e3d:	77 1c                	ja     f0105e5b <mp_init+0xac>
			continue;
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105e3f:	83 c6 08             	add    $0x8,%esi
			continue;
f0105e42:	eb e1                	jmp    f0105e25 <mp_init+0x76>
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0105e44:	83 ec 08             	sub    $0x8,%esp
f0105e47:	0f b6 46 01          	movzbl 0x1(%esi),%eax
f0105e4b:	50                   	push   %eax
f0105e4c:	68 4c 81 10 f0       	push   $0xf010814c
f0105e51:	e8 64 d9 ff ff       	call   f01037ba <cprintf>
f0105e56:	83 c4 10             	add    $0x10,%esp
f0105e59:	eb c7                	jmp    f0105e22 <mp_init+0x73>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0105e5b:	83 ec 08             	sub    $0x8,%esp
		switch (*p) {
f0105e5e:	0f b6 c0             	movzbl %al,%eax
			cprintf("mpinit: unknown config type %x\n", *p);
f0105e61:	50                   	push   %eax
f0105e62:	68 74 81 10 f0       	push   $0xf0108174
f0105e67:	e8 4e d9 ff ff       	call   f01037ba <cprintf>
			ismp = 0;
f0105e6c:	c7 05 04 a0 28 f0 00 	movl   $0x0,0xf028a004
f0105e73:	00 00 00 
			i = conf->entry;
f0105e76:	0f b7 5f 22          	movzwl 0x22(%edi),%ebx
f0105e7a:	83 c4 10             	add    $0x10,%esp
f0105e7d:	eb a6                	jmp    f0105e25 <mp_init+0x76>
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105e7f:	a1 08 a0 28 f0       	mov    0xf028a008,%eax
f0105e84:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105e8b:	83 3d 04 a0 28 f0 00 	cmpl   $0x0,0xf028a004
f0105e92:	74 2b                	je     f0105ebf <mp_init+0x110>
		ncpu = 1;
		lapicaddr = 0;
		cprintf("SMP: configuration not found, SMP disabled\n");
		return;
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id, ncpu);
f0105e94:	83 ec 04             	sub    $0x4,%esp
f0105e97:	ff 35 00 a0 28 f0    	push   0xf028a000
f0105e9d:	0f b6 00             	movzbl (%eax),%eax
f0105ea0:	50                   	push   %eax
f0105ea1:	68 1b 82 10 f0       	push   $0xf010821b
f0105ea6:	e8 0f d9 ff ff       	call   f01037ba <cprintf>

	if (mp->imcrp) {
f0105eab:	83 c4 10             	add    $0x10,%esp
f0105eae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105eb1:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0105eb5:	75 2e                	jne    f0105ee5 <mp_init+0x136>
		cprintf("SMP: Setting IMCR to switch from PIC mode to "
		        "symmetric I/O mode\n");
		outb(0x22, 0x70);           // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0105eb7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105eba:	5b                   	pop    %ebx
f0105ebb:	5e                   	pop    %esi
f0105ebc:	5f                   	pop    %edi
f0105ebd:	5d                   	pop    %ebp
f0105ebe:	c3                   	ret    
		ncpu = 1;
f0105ebf:	c7 05 00 a0 28 f0 01 	movl   $0x1,0xf028a000
f0105ec6:	00 00 00 
		lapicaddr = 0;
f0105ec9:	c7 05 c4 a3 28 f0 00 	movl   $0x0,0xf028a3c4
f0105ed0:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105ed3:	83 ec 0c             	sub    $0xc,%esp
f0105ed6:	68 94 81 10 f0       	push   $0xf0108194
f0105edb:	e8 da d8 ff ff       	call   f01037ba <cprintf>
		return;
f0105ee0:	83 c4 10             	add    $0x10,%esp
f0105ee3:	eb d2                	jmp    f0105eb7 <mp_init+0x108>
		cprintf("SMP: Setting IMCR to switch from PIC mode to "
f0105ee5:	83 ec 0c             	sub    $0xc,%esp
f0105ee8:	68 c0 81 10 f0       	push   $0xf01081c0
f0105eed:	e8 c8 d8 ff ff       	call   f01037ba <cprintf>
		outb(0x22, 0x70);           // Select IMCR
f0105ef2:	ba 70 00 00 00       	mov    $0x70,%edx
f0105ef7:	b8 22 00 00 00       	mov    $0x22,%eax
f0105efc:	e8 6e fc ff ff       	call   f0105b6f <outb>
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f0105f01:	b8 23 00 00 00       	mov    $0x23,%eax
f0105f06:	e8 60 fc ff ff       	call   f0105b6b <inb>
f0105f0b:	83 c8 01             	or     $0x1,%eax
f0105f0e:	0f b6 d0             	movzbl %al,%edx
f0105f11:	b8 23 00 00 00       	mov    $0x23,%eax
f0105f16:	e8 54 fc ff ff       	call   f0105b6f <outb>
f0105f1b:	83 c4 10             	add    $0x10,%esp
f0105f1e:	eb 97                	jmp    f0105eb7 <mp_init+0x108>

f0105f20 <outb>:
{
f0105f20:	89 c1                	mov    %eax,%ecx
f0105f22:	89 d0                	mov    %edx,%eax
	asm volatile("outb %0,%w1" : : "a"(data), "d"(port));
f0105f24:	89 ca                	mov    %ecx,%edx
f0105f26:	ee                   	out    %al,(%dx)
}
f0105f27:	c3                   	ret    

f0105f28 <lapicw>:
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
	lapic[index] = value;
f0105f28:	8b 0d c0 a3 28 f0    	mov    0xf028a3c0,%ecx
f0105f2e:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0105f31:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105f33:	a1 c0 a3 28 f0       	mov    0xf028a3c0,%eax
f0105f38:	8b 40 20             	mov    0x20(%eax),%eax
}
f0105f3b:	c3                   	ret    

f0105f3c <_kaddr>:
{
f0105f3c:	55                   	push   %ebp
f0105f3d:	89 e5                	mov    %esp,%ebp
f0105f3f:	53                   	push   %ebx
f0105f40:	83 ec 04             	sub    $0x4,%esp
	if (PGNUM(pa) >= npages)
f0105f43:	89 cb                	mov    %ecx,%ebx
f0105f45:	c1 eb 0c             	shr    $0xc,%ebx
f0105f48:	3b 1d 60 82 24 f0    	cmp    0xf0248260,%ebx
f0105f4e:	73 0b                	jae    f0105f5b <_kaddr+0x1f>
	return (void *) (pa + KERNBASE);
f0105f50:	8d 81 00 00 00 f0    	lea    -0x10000000(%ecx),%eax
}
f0105f56:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105f59:	c9                   	leave  
f0105f5a:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105f5b:	51                   	push   %ecx
f0105f5c:	68 0c 66 10 f0       	push   $0xf010660c
f0105f61:	52                   	push   %edx
f0105f62:	50                   	push   %eax
f0105f63:	e8 02 a1 ff ff       	call   f010006a <_panic>

f0105f68 <cpunum>:
}

int
cpunum(void)
{
	if (lapic)
f0105f68:	8b 15 c0 a3 28 f0    	mov    0xf028a3c0,%edx
		return lapic[ID] >> 24;
	return 0;
f0105f6e:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lapic)
f0105f73:	85 d2                	test   %edx,%edx
f0105f75:	74 06                	je     f0105f7d <cpunum+0x15>
		return lapic[ID] >> 24;
f0105f77:	8b 42 20             	mov    0x20(%edx),%eax
f0105f7a:	c1 e8 18             	shr    $0x18,%eax
}
f0105f7d:	c3                   	ret    

f0105f7e <lapic_init>:
	if (!lapicaddr)
f0105f7e:	a1 c4 a3 28 f0       	mov    0xf028a3c4,%eax
f0105f83:	85 c0                	test   %eax,%eax
f0105f85:	75 01                	jne    f0105f88 <lapic_init+0xa>
f0105f87:	c3                   	ret    
{
f0105f88:	55                   	push   %ebp
f0105f89:	89 e5                	mov    %esp,%ebp
f0105f8b:	83 ec 10             	sub    $0x10,%esp
	lapic = mmio_map_region(lapicaddr, 4096);
f0105f8e:	68 00 10 00 00       	push   $0x1000
f0105f93:	50                   	push   %eax
f0105f94:	e8 a6 bd ff ff       	call   f0101d3f <mmio_map_region>
f0105f99:	a3 c0 a3 28 f0       	mov    %eax,0xf028a3c0
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105f9e:	ba 27 01 00 00       	mov    $0x127,%edx
f0105fa3:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0105fa8:	e8 7b ff ff ff       	call   f0105f28 <lapicw>
	lapicw(TDCR, X1);
f0105fad:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105fb2:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105fb7:	e8 6c ff ff ff       	call   f0105f28 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105fbc:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105fc1:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105fc6:	e8 5d ff ff ff       	call   f0105f28 <lapicw>
	lapicw(TICR, 10000000);
f0105fcb:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105fd0:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105fd5:	e8 4e ff ff ff       	call   f0105f28 <lapicw>
	if (thiscpu != bootcpu)
f0105fda:	e8 89 ff ff ff       	call   f0105f68 <cpunum>
f0105fdf:	6b c0 74             	imul   $0x74,%eax,%eax
f0105fe2:	05 20 a0 28 f0       	add    $0xf028a020,%eax
f0105fe7:	83 c4 10             	add    $0x10,%esp
f0105fea:	39 05 08 a0 28 f0    	cmp    %eax,0xf028a008
f0105ff0:	74 0f                	je     f0106001 <lapic_init+0x83>
		lapicw(LINT0, MASKED);
f0105ff2:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105ff7:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0105ffc:	e8 27 ff ff ff       	call   f0105f28 <lapicw>
	lapicw(LINT1, MASKED);
f0106001:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106006:	b8 d8 00 00 00       	mov    $0xd8,%eax
f010600b:	e8 18 ff ff ff       	call   f0105f28 <lapicw>
	if (((lapic[VER] >> 16) & 0xFF) >= 4)
f0106010:	a1 c0 a3 28 f0       	mov    0xf028a3c0,%eax
f0106015:	8b 40 30             	mov    0x30(%eax),%eax
f0106018:	c1 e8 10             	shr    $0x10,%eax
f010601b:	a8 fc                	test   $0xfc,%al
f010601d:	75 7c                	jne    f010609b <lapic_init+0x11d>
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f010601f:	ba 33 00 00 00       	mov    $0x33,%edx
f0106024:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0106029:	e8 fa fe ff ff       	call   f0105f28 <lapicw>
	lapicw(ESR, 0);
f010602e:	ba 00 00 00 00       	mov    $0x0,%edx
f0106033:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106038:	e8 eb fe ff ff       	call   f0105f28 <lapicw>
	lapicw(ESR, 0);
f010603d:	ba 00 00 00 00       	mov    $0x0,%edx
f0106042:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106047:	e8 dc fe ff ff       	call   f0105f28 <lapicw>
	lapicw(EOI, 0);
f010604c:	ba 00 00 00 00       	mov    $0x0,%edx
f0106051:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106056:	e8 cd fe ff ff       	call   f0105f28 <lapicw>
	lapicw(ICRHI, 0);
f010605b:	ba 00 00 00 00       	mov    $0x0,%edx
f0106060:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106065:	e8 be fe ff ff       	call   f0105f28 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f010606a:	ba 00 85 08 00       	mov    $0x88500,%edx
f010606f:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106074:	e8 af fe ff ff       	call   f0105f28 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0106079:	8b 15 c0 a3 28 f0    	mov    0xf028a3c0,%edx
f010607f:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106085:	f6 c4 10             	test   $0x10,%ah
f0106088:	75 f5                	jne    f010607f <lapic_init+0x101>
	lapicw(TPR, 0);
f010608a:	ba 00 00 00 00       	mov    $0x0,%edx
f010608f:	b8 20 00 00 00       	mov    $0x20,%eax
f0106094:	e8 8f fe ff ff       	call   f0105f28 <lapicw>
}
f0106099:	c9                   	leave  
f010609a:	c3                   	ret    
		lapicw(PCINT, MASKED);
f010609b:	ba 00 00 01 00       	mov    $0x10000,%edx
f01060a0:	b8 d0 00 00 00       	mov    $0xd0,%eax
f01060a5:	e8 7e fe ff ff       	call   f0105f28 <lapicw>
f01060aa:	e9 70 ff ff ff       	jmp    f010601f <lapic_init+0xa1>

f01060af <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f01060af:	83 3d c0 a3 28 f0 00 	cmpl   $0x0,0xf028a3c0
f01060b6:	74 17                	je     f01060cf <lapic_eoi+0x20>
{
f01060b8:	55                   	push   %ebp
f01060b9:	89 e5                	mov    %esp,%ebp
f01060bb:	83 ec 08             	sub    $0x8,%esp
		lapicw(EOI, 0);
f01060be:	ba 00 00 00 00       	mov    $0x0,%edx
f01060c3:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01060c8:	e8 5b fe ff ff       	call   f0105f28 <lapicw>
}
f01060cd:	c9                   	leave  
f01060ce:	c3                   	ret    
f01060cf:	c3                   	ret    

f01060d0 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f01060d0:	55                   	push   %ebp
f01060d1:	89 e5                	mov    %esp,%ebp
f01060d3:	56                   	push   %esi
f01060d4:	53                   	push   %ebx
f01060d5:	8b 75 08             	mov    0x8(%ebp),%esi
f01060d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	uint16_t *wrv;

	// "The BSP must initialize CMOS shutdown code to 0AH
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
f01060db:	ba 0f 00 00 00       	mov    $0xf,%edx
f01060e0:	b8 70 00 00 00       	mov    $0x70,%eax
f01060e5:	e8 36 fe ff ff       	call   f0105f20 <outb>
	outb(IO_RTC + 1, 0x0A);
f01060ea:	ba 0a 00 00 00       	mov    $0xa,%edx
f01060ef:	b8 71 00 00 00       	mov    $0x71,%eax
f01060f4:	e8 27 fe ff ff       	call   f0105f20 <outb>
	wrv = (uint16_t *) KADDR((0x40 << 4 | 0x67));  // Warm reset vector
f01060f9:	b9 67 04 00 00       	mov    $0x467,%ecx
f01060fe:	ba 98 00 00 00       	mov    $0x98,%edx
f0106103:	b8 38 82 10 f0       	mov    $0xf0108238,%eax
f0106108:	e8 2f fe ff ff       	call   f0105f3c <_kaddr>
	wrv[0] = 0;
f010610d:	66 c7 00 00 00       	movw   $0x0,(%eax)
	wrv[1] = addr >> 4;
f0106112:	89 da                	mov    %ebx,%edx
f0106114:	c1 ea 04             	shr    $0x4,%edx
f0106117:	66 89 50 02          	mov    %dx,0x2(%eax)

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f010611b:	c1 e6 18             	shl    $0x18,%esi
f010611e:	89 f2                	mov    %esi,%edx
f0106120:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106125:	e8 fe fd ff ff       	call   f0105f28 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f010612a:	ba 00 c5 00 00       	mov    $0xc500,%edx
f010612f:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106134:	e8 ef fd ff ff       	call   f0105f28 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0106139:	ba 00 85 00 00       	mov    $0x8500,%edx
f010613e:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106143:	e8 e0 fd ff ff       	call   f0105f28 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106148:	c1 eb 0c             	shr    $0xc,%ebx
f010614b:	80 cf 06             	or     $0x6,%bh
		lapicw(ICRHI, apicid << 24);
f010614e:	89 f2                	mov    %esi,%edx
f0106150:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106155:	e8 ce fd ff ff       	call   f0105f28 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010615a:	89 da                	mov    %ebx,%edx
f010615c:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106161:	e8 c2 fd ff ff       	call   f0105f28 <lapicw>
		lapicw(ICRHI, apicid << 24);
f0106166:	89 f2                	mov    %esi,%edx
f0106168:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010616d:	e8 b6 fd ff ff       	call   f0105f28 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106172:	89 da                	mov    %ebx,%edx
f0106174:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106179:	e8 aa fd ff ff       	call   f0105f28 <lapicw>
		microdelay(200);
	}
}
f010617e:	5b                   	pop    %ebx
f010617f:	5e                   	pop    %esi
f0106180:	5d                   	pop    %ebp
f0106181:	c3                   	ret    

f0106182 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0106182:	55                   	push   %ebp
f0106183:	89 e5                	mov    %esp,%ebp
f0106185:	83 ec 08             	sub    $0x8,%esp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0106188:	8b 55 08             	mov    0x8(%ebp),%edx
f010618b:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0106191:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106196:	e8 8d fd ff ff       	call   f0105f28 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f010619b:	8b 15 c0 a3 28 f0    	mov    0xf028a3c0,%edx
f01061a1:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01061a7:	f6 c4 10             	test   $0x10,%ah
f01061aa:	75 f5                	jne    f01061a1 <lapic_ipi+0x1f>
		;
}
f01061ac:	c9                   	leave  
f01061ad:	c3                   	ret    

f01061ae <xchg>:
{
f01061ae:	89 c1                	mov    %eax,%ecx
f01061b0:	89 d0                	mov    %edx,%eax
	asm volatile("lock; xchgl %0, %1"
f01061b2:	f0 87 01             	lock xchg %eax,(%ecx)
}
f01061b5:	c3                   	ret    

f01061b6 <get_caller_pcs>:

#ifdef DEBUG_SPINLOCK
// Record the current call stack in pcs[] by following the %ebp chain.
static void
get_caller_pcs(uint32_t pcs[])
{
f01061b6:	55                   	push   %ebp
f01061b7:	89 e5                	mov    %esp,%ebp
f01061b9:	53                   	push   %ebx
f01061ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
	asm volatile("movl %%ebp,%0" : "=r"(ebp));
f01061bd:	89 ea                	mov    %ebp,%edx
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *) read_ebp();
	for (i = 0; i < 10; i++) {
f01061bf:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *) ULIM)
f01061c4:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f01061ca:	76 1c                	jbe    f01061e8 <get_caller_pcs+0x32>
f01061cc:	83 f8 09             	cmp    $0x9,%eax
f01061cf:	7f 17                	jg     f01061e8 <get_caller_pcs+0x32>
			break;
		pcs[i] = ebp[1];            // saved %eip
f01061d1:	8b 5a 04             	mov    0x4(%edx),%ebx
f01061d4:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
		ebp = (uint32_t *) ebp[0];  // saved %ebp
f01061d7:	8b 12                	mov    (%edx),%edx
	for (i = 0; i < 10; i++) {
f01061d9:	83 c0 01             	add    $0x1,%eax
f01061dc:	eb e6                	jmp    f01061c4 <get_caller_pcs+0xe>
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f01061de:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
	for (; i < 10; i++)
f01061e5:	83 c0 01             	add    $0x1,%eax
f01061e8:	83 f8 09             	cmp    $0x9,%eax
f01061eb:	7e f1                	jle    f01061de <get_caller_pcs+0x28>
}
f01061ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01061f0:	c9                   	leave  
f01061f1:	c3                   	ret    

f01061f2 <holding>:

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f01061f2:	83 38 00             	cmpl   $0x0,(%eax)
f01061f5:	75 06                	jne    f01061fd <holding+0xb>
f01061f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01061fc:	c3                   	ret    
{
f01061fd:	55                   	push   %ebp
f01061fe:	89 e5                	mov    %esp,%ebp
f0106200:	53                   	push   %ebx
f0106201:	83 ec 04             	sub    $0x4,%esp
	return lock->locked && lock->cpu == thiscpu;
f0106204:	8b 58 08             	mov    0x8(%eax),%ebx
f0106207:	e8 5c fd ff ff       	call   f0105f68 <cpunum>
f010620c:	6b c0 74             	imul   $0x74,%eax,%eax
f010620f:	05 20 a0 28 f0       	add    $0xf028a020,%eax
f0106214:	39 c3                	cmp    %eax,%ebx
f0106216:	0f 94 c0             	sete   %al
f0106219:	0f b6 c0             	movzbl %al,%eax
}
f010621c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010621f:	c9                   	leave  
f0106220:	c3                   	ret    

f0106221 <__spin_initlock>:
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0106221:	55                   	push   %ebp
f0106222:	89 e5                	mov    %esp,%ebp
f0106224:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0106227:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f010622d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106230:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0106233:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f010623a:	5d                   	pop    %ebp
f010623b:	c3                   	ret    

f010623c <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f010623c:	55                   	push   %ebp
f010623d:	89 e5                	mov    %esp,%ebp
f010623f:	53                   	push   %ebx
f0106240:	83 ec 04             	sub    $0x4,%esp
f0106243:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0106246:	89 d8                	mov    %ebx,%eax
f0106248:	e8 a5 ff ff ff       	call   f01061f2 <holding>
f010624d:	85 c0                	test   %eax,%eax
f010624f:	74 20                	je     f0106271 <spin_lock+0x35>
		panic("CPU %d cannot acquire %s: already holding",
f0106251:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106254:	e8 0f fd ff ff       	call   f0105f68 <cpunum>
f0106259:	83 ec 0c             	sub    $0xc,%esp
f010625c:	53                   	push   %ebx
f010625d:	50                   	push   %eax
f010625e:	68 48 82 10 f0       	push   $0xf0108248
f0106263:	6a 41                	push   $0x41
f0106265:	68 aa 82 10 f0       	push   $0xf01082aa
f010626a:	e8 fb 9d ff ff       	call   f010006a <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it.
	while (xchg(&lk->locked, 1) != 0)
		asm volatile("pause");
f010626f:	f3 90                	pause  
	while (xchg(&lk->locked, 1) != 0)
f0106271:	ba 01 00 00 00       	mov    $0x1,%edx
f0106276:	89 d8                	mov    %ebx,%eax
f0106278:	e8 31 ff ff ff       	call   f01061ae <xchg>
f010627d:	85 c0                	test   %eax,%eax
f010627f:	75 ee                	jne    f010626f <spin_lock+0x33>

		// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0106281:	e8 e2 fc ff ff       	call   f0105f68 <cpunum>
f0106286:	6b c0 74             	imul   $0x74,%eax,%eax
f0106289:	05 20 a0 28 f0       	add    $0xf028a020,%eax
f010628e:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0106291:	83 ec 0c             	sub    $0xc,%esp
f0106294:	83 c3 0c             	add    $0xc,%ebx
f0106297:	53                   	push   %ebx
f0106298:	e8 19 ff ff ff       	call   f01061b6 <get_caller_pcs>
#endif
}
f010629d:	83 c4 10             	add    $0x10,%esp
f01062a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01062a3:	c9                   	leave  
f01062a4:	c3                   	ret    

f01062a5 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f01062a5:	55                   	push   %ebp
f01062a6:	89 e5                	mov    %esp,%ebp
f01062a8:	57                   	push   %edi
f01062a9:	56                   	push   %esi
f01062aa:	53                   	push   %ebx
f01062ab:	83 ec 4c             	sub    $0x4c,%esp
f01062ae:	8b 75 08             	mov    0x8(%ebp),%esi
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f01062b1:	89 f0                	mov    %esi,%eax
f01062b3:	e8 3a ff ff ff       	call   f01061f2 <holding>
f01062b8:	85 c0                	test   %eax,%eax
f01062ba:	74 22                	je     f01062de <spin_unlock+0x39>
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
	}

	lk->pcs[0] = 0;
f01062bc:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f01062c3:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
	// The xchg instruction is atomic (i.e. uses the "lock" prefix) with
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
f01062ca:	ba 00 00 00 00       	mov    $0x0,%edx
f01062cf:	89 f0                	mov    %esi,%eax
f01062d1:	e8 d8 fe ff ff       	call   f01061ae <xchg>
}
f01062d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01062d9:	5b                   	pop    %ebx
f01062da:	5e                   	pop    %esi
f01062db:	5f                   	pop    %edi
f01062dc:	5d                   	pop    %ebp
f01062dd:	c3                   	ret    
		memmove(pcs, lk->pcs, sizeof pcs);
f01062de:	83 ec 04             	sub    $0x4,%esp
f01062e1:	6a 28                	push   $0x28
f01062e3:	8d 46 0c             	lea    0xc(%esi),%eax
f01062e6:	50                   	push   %eax
f01062e7:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f01062ea:	53                   	push   %ebx
f01062eb:	e8 4c f6 ff ff       	call   f010593c <memmove>
		        lk->cpu->cpu_id);
f01062f0:	8b 46 08             	mov    0x8(%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired "
f01062f3:	0f b6 38             	movzbl (%eax),%edi
f01062f6:	8b 76 04             	mov    0x4(%esi),%esi
f01062f9:	e8 6a fc ff ff       	call   f0105f68 <cpunum>
f01062fe:	57                   	push   %edi
f01062ff:	56                   	push   %esi
f0106300:	50                   	push   %eax
f0106301:	68 74 82 10 f0       	push   $0xf0108274
f0106306:	e8 af d4 ff ff       	call   f01037ba <cprintf>
f010630b:	83 c4 20             	add    $0x20,%esp
			if (debuginfo_eip(pcs[i], &info) >= 0)
f010630e:	8d 7d a8             	lea    -0x58(%ebp),%edi
f0106311:	eb 1c                	jmp    f010632f <spin_unlock+0x8a>
				cprintf("  %08x\n", pcs[i]);
f0106313:	83 ec 08             	sub    $0x8,%esp
f0106316:	ff 36                	push   (%esi)
f0106318:	68 d1 82 10 f0       	push   $0xf01082d1
f010631d:	e8 98 d4 ff ff       	call   f01037ba <cprintf>
f0106322:	83 c4 10             	add    $0x10,%esp
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106325:	83 c3 04             	add    $0x4,%ebx
f0106328:	8d 45 e8             	lea    -0x18(%ebp),%eax
f010632b:	39 c3                	cmp    %eax,%ebx
f010632d:	74 40                	je     f010636f <spin_unlock+0xca>
f010632f:	89 de                	mov    %ebx,%esi
f0106331:	8b 03                	mov    (%ebx),%eax
f0106333:	85 c0                	test   %eax,%eax
f0106335:	74 38                	je     f010636f <spin_unlock+0xca>
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0106337:	83 ec 08             	sub    $0x8,%esp
f010633a:	57                   	push   %edi
f010633b:	50                   	push   %eax
f010633c:	e8 92 eb ff ff       	call   f0104ed3 <debuginfo_eip>
f0106341:	83 c4 10             	add    $0x10,%esp
f0106344:	85 c0                	test   %eax,%eax
f0106346:	78 cb                	js     f0106313 <spin_unlock+0x6e>
				        pcs[i] - info.eip_fn_addr);
f0106348:	8b 06                	mov    (%esi),%eax
				cprintf("  %08x %s:%d: %.*s+%x\n",
f010634a:	83 ec 04             	sub    $0x4,%esp
f010634d:	89 c2                	mov    %eax,%edx
f010634f:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0106352:	52                   	push   %edx
f0106353:	ff 75 b0             	push   -0x50(%ebp)
f0106356:	ff 75 b4             	push   -0x4c(%ebp)
f0106359:	ff 75 ac             	push   -0x54(%ebp)
f010635c:	ff 75 a8             	push   -0x58(%ebp)
f010635f:	50                   	push   %eax
f0106360:	68 ba 82 10 f0       	push   $0xf01082ba
f0106365:	e8 50 d4 ff ff       	call   f01037ba <cprintf>
f010636a:	83 c4 20             	add    $0x20,%esp
f010636d:	eb b6                	jmp    f0106325 <spin_unlock+0x80>
		panic("spin_unlock");
f010636f:	83 ec 04             	sub    $0x4,%esp
f0106372:	68 d9 82 10 f0       	push   $0xf01082d9
f0106377:	6a 6f                	push   $0x6f
f0106379:	68 aa 82 10 f0       	push   $0xf01082aa
f010637e:	e8 e7 9c ff ff       	call   f010006a <_panic>
f0106383:	66 90                	xchg   %ax,%ax
f0106385:	66 90                	xchg   %ax,%ax
f0106387:	66 90                	xchg   %ax,%ax
f0106389:	66 90                	xchg   %ax,%ax
f010638b:	66 90                	xchg   %ax,%ax
f010638d:	66 90                	xchg   %ax,%ax
f010638f:	90                   	nop

f0106390 <__udivdi3>:
f0106390:	f3 0f 1e fb          	endbr32 
f0106394:	55                   	push   %ebp
f0106395:	57                   	push   %edi
f0106396:	56                   	push   %esi
f0106397:	53                   	push   %ebx
f0106398:	83 ec 1c             	sub    $0x1c,%esp
f010639b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f010639f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f01063a3:	8b 74 24 34          	mov    0x34(%esp),%esi
f01063a7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f01063ab:	85 c0                	test   %eax,%eax
f01063ad:	75 19                	jne    f01063c8 <__udivdi3+0x38>
f01063af:	39 f3                	cmp    %esi,%ebx
f01063b1:	76 4d                	jbe    f0106400 <__udivdi3+0x70>
f01063b3:	31 ff                	xor    %edi,%edi
f01063b5:	89 e8                	mov    %ebp,%eax
f01063b7:	89 f2                	mov    %esi,%edx
f01063b9:	f7 f3                	div    %ebx
f01063bb:	89 fa                	mov    %edi,%edx
f01063bd:	83 c4 1c             	add    $0x1c,%esp
f01063c0:	5b                   	pop    %ebx
f01063c1:	5e                   	pop    %esi
f01063c2:	5f                   	pop    %edi
f01063c3:	5d                   	pop    %ebp
f01063c4:	c3                   	ret    
f01063c5:	8d 76 00             	lea    0x0(%esi),%esi
f01063c8:	39 f0                	cmp    %esi,%eax
f01063ca:	76 14                	jbe    f01063e0 <__udivdi3+0x50>
f01063cc:	31 ff                	xor    %edi,%edi
f01063ce:	31 c0                	xor    %eax,%eax
f01063d0:	89 fa                	mov    %edi,%edx
f01063d2:	83 c4 1c             	add    $0x1c,%esp
f01063d5:	5b                   	pop    %ebx
f01063d6:	5e                   	pop    %esi
f01063d7:	5f                   	pop    %edi
f01063d8:	5d                   	pop    %ebp
f01063d9:	c3                   	ret    
f01063da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01063e0:	0f bd f8             	bsr    %eax,%edi
f01063e3:	83 f7 1f             	xor    $0x1f,%edi
f01063e6:	75 48                	jne    f0106430 <__udivdi3+0xa0>
f01063e8:	39 f0                	cmp    %esi,%eax
f01063ea:	72 06                	jb     f01063f2 <__udivdi3+0x62>
f01063ec:	31 c0                	xor    %eax,%eax
f01063ee:	39 eb                	cmp    %ebp,%ebx
f01063f0:	77 de                	ja     f01063d0 <__udivdi3+0x40>
f01063f2:	b8 01 00 00 00       	mov    $0x1,%eax
f01063f7:	eb d7                	jmp    f01063d0 <__udivdi3+0x40>
f01063f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106400:	89 d9                	mov    %ebx,%ecx
f0106402:	85 db                	test   %ebx,%ebx
f0106404:	75 0b                	jne    f0106411 <__udivdi3+0x81>
f0106406:	b8 01 00 00 00       	mov    $0x1,%eax
f010640b:	31 d2                	xor    %edx,%edx
f010640d:	f7 f3                	div    %ebx
f010640f:	89 c1                	mov    %eax,%ecx
f0106411:	31 d2                	xor    %edx,%edx
f0106413:	89 f0                	mov    %esi,%eax
f0106415:	f7 f1                	div    %ecx
f0106417:	89 c6                	mov    %eax,%esi
f0106419:	89 e8                	mov    %ebp,%eax
f010641b:	89 f7                	mov    %esi,%edi
f010641d:	f7 f1                	div    %ecx
f010641f:	89 fa                	mov    %edi,%edx
f0106421:	83 c4 1c             	add    $0x1c,%esp
f0106424:	5b                   	pop    %ebx
f0106425:	5e                   	pop    %esi
f0106426:	5f                   	pop    %edi
f0106427:	5d                   	pop    %ebp
f0106428:	c3                   	ret    
f0106429:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106430:	89 f9                	mov    %edi,%ecx
f0106432:	ba 20 00 00 00       	mov    $0x20,%edx
f0106437:	29 fa                	sub    %edi,%edx
f0106439:	d3 e0                	shl    %cl,%eax
f010643b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010643f:	89 d1                	mov    %edx,%ecx
f0106441:	89 d8                	mov    %ebx,%eax
f0106443:	d3 e8                	shr    %cl,%eax
f0106445:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0106449:	09 c1                	or     %eax,%ecx
f010644b:	89 f0                	mov    %esi,%eax
f010644d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106451:	89 f9                	mov    %edi,%ecx
f0106453:	d3 e3                	shl    %cl,%ebx
f0106455:	89 d1                	mov    %edx,%ecx
f0106457:	d3 e8                	shr    %cl,%eax
f0106459:	89 f9                	mov    %edi,%ecx
f010645b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010645f:	89 eb                	mov    %ebp,%ebx
f0106461:	d3 e6                	shl    %cl,%esi
f0106463:	89 d1                	mov    %edx,%ecx
f0106465:	d3 eb                	shr    %cl,%ebx
f0106467:	09 f3                	or     %esi,%ebx
f0106469:	89 c6                	mov    %eax,%esi
f010646b:	89 f2                	mov    %esi,%edx
f010646d:	89 d8                	mov    %ebx,%eax
f010646f:	f7 74 24 08          	divl   0x8(%esp)
f0106473:	89 d6                	mov    %edx,%esi
f0106475:	89 c3                	mov    %eax,%ebx
f0106477:	f7 64 24 0c          	mull   0xc(%esp)
f010647b:	39 d6                	cmp    %edx,%esi
f010647d:	72 19                	jb     f0106498 <__udivdi3+0x108>
f010647f:	89 f9                	mov    %edi,%ecx
f0106481:	d3 e5                	shl    %cl,%ebp
f0106483:	39 c5                	cmp    %eax,%ebp
f0106485:	73 04                	jae    f010648b <__udivdi3+0xfb>
f0106487:	39 d6                	cmp    %edx,%esi
f0106489:	74 0d                	je     f0106498 <__udivdi3+0x108>
f010648b:	89 d8                	mov    %ebx,%eax
f010648d:	31 ff                	xor    %edi,%edi
f010648f:	e9 3c ff ff ff       	jmp    f01063d0 <__udivdi3+0x40>
f0106494:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106498:	8d 43 ff             	lea    -0x1(%ebx),%eax
f010649b:	31 ff                	xor    %edi,%edi
f010649d:	e9 2e ff ff ff       	jmp    f01063d0 <__udivdi3+0x40>
f01064a2:	66 90                	xchg   %ax,%ax
f01064a4:	66 90                	xchg   %ax,%ax
f01064a6:	66 90                	xchg   %ax,%ax
f01064a8:	66 90                	xchg   %ax,%ax
f01064aa:	66 90                	xchg   %ax,%ax
f01064ac:	66 90                	xchg   %ax,%ax
f01064ae:	66 90                	xchg   %ax,%ax

f01064b0 <__umoddi3>:
f01064b0:	f3 0f 1e fb          	endbr32 
f01064b4:	55                   	push   %ebp
f01064b5:	57                   	push   %edi
f01064b6:	56                   	push   %esi
f01064b7:	53                   	push   %ebx
f01064b8:	83 ec 1c             	sub    $0x1c,%esp
f01064bb:	8b 74 24 30          	mov    0x30(%esp),%esi
f01064bf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f01064c3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
f01064c7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
f01064cb:	89 f0                	mov    %esi,%eax
f01064cd:	89 da                	mov    %ebx,%edx
f01064cf:	85 ff                	test   %edi,%edi
f01064d1:	75 15                	jne    f01064e8 <__umoddi3+0x38>
f01064d3:	39 dd                	cmp    %ebx,%ebp
f01064d5:	76 39                	jbe    f0106510 <__umoddi3+0x60>
f01064d7:	f7 f5                	div    %ebp
f01064d9:	89 d0                	mov    %edx,%eax
f01064db:	31 d2                	xor    %edx,%edx
f01064dd:	83 c4 1c             	add    $0x1c,%esp
f01064e0:	5b                   	pop    %ebx
f01064e1:	5e                   	pop    %esi
f01064e2:	5f                   	pop    %edi
f01064e3:	5d                   	pop    %ebp
f01064e4:	c3                   	ret    
f01064e5:	8d 76 00             	lea    0x0(%esi),%esi
f01064e8:	39 df                	cmp    %ebx,%edi
f01064ea:	77 f1                	ja     f01064dd <__umoddi3+0x2d>
f01064ec:	0f bd cf             	bsr    %edi,%ecx
f01064ef:	83 f1 1f             	xor    $0x1f,%ecx
f01064f2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01064f6:	75 40                	jne    f0106538 <__umoddi3+0x88>
f01064f8:	39 df                	cmp    %ebx,%edi
f01064fa:	72 04                	jb     f0106500 <__umoddi3+0x50>
f01064fc:	39 f5                	cmp    %esi,%ebp
f01064fe:	77 dd                	ja     f01064dd <__umoddi3+0x2d>
f0106500:	89 da                	mov    %ebx,%edx
f0106502:	89 f0                	mov    %esi,%eax
f0106504:	29 e8                	sub    %ebp,%eax
f0106506:	19 fa                	sbb    %edi,%edx
f0106508:	eb d3                	jmp    f01064dd <__umoddi3+0x2d>
f010650a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106510:	89 e9                	mov    %ebp,%ecx
f0106512:	85 ed                	test   %ebp,%ebp
f0106514:	75 0b                	jne    f0106521 <__umoddi3+0x71>
f0106516:	b8 01 00 00 00       	mov    $0x1,%eax
f010651b:	31 d2                	xor    %edx,%edx
f010651d:	f7 f5                	div    %ebp
f010651f:	89 c1                	mov    %eax,%ecx
f0106521:	89 d8                	mov    %ebx,%eax
f0106523:	31 d2                	xor    %edx,%edx
f0106525:	f7 f1                	div    %ecx
f0106527:	89 f0                	mov    %esi,%eax
f0106529:	f7 f1                	div    %ecx
f010652b:	89 d0                	mov    %edx,%eax
f010652d:	31 d2                	xor    %edx,%edx
f010652f:	eb ac                	jmp    f01064dd <__umoddi3+0x2d>
f0106531:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106538:	8b 44 24 04          	mov    0x4(%esp),%eax
f010653c:	ba 20 00 00 00       	mov    $0x20,%edx
f0106541:	29 c2                	sub    %eax,%edx
f0106543:	89 c1                	mov    %eax,%ecx
f0106545:	89 e8                	mov    %ebp,%eax
f0106547:	d3 e7                	shl    %cl,%edi
f0106549:	89 d1                	mov    %edx,%ecx
f010654b:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010654f:	d3 e8                	shr    %cl,%eax
f0106551:	89 c1                	mov    %eax,%ecx
f0106553:	8b 44 24 04          	mov    0x4(%esp),%eax
f0106557:	09 f9                	or     %edi,%ecx
f0106559:	89 df                	mov    %ebx,%edi
f010655b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010655f:	89 c1                	mov    %eax,%ecx
f0106561:	d3 e5                	shl    %cl,%ebp
f0106563:	89 d1                	mov    %edx,%ecx
f0106565:	d3 ef                	shr    %cl,%edi
f0106567:	89 c1                	mov    %eax,%ecx
f0106569:	89 f0                	mov    %esi,%eax
f010656b:	d3 e3                	shl    %cl,%ebx
f010656d:	89 d1                	mov    %edx,%ecx
f010656f:	89 fa                	mov    %edi,%edx
f0106571:	d3 e8                	shr    %cl,%eax
f0106573:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0106578:	09 d8                	or     %ebx,%eax
f010657a:	f7 74 24 08          	divl   0x8(%esp)
f010657e:	89 d3                	mov    %edx,%ebx
f0106580:	d3 e6                	shl    %cl,%esi
f0106582:	f7 e5                	mul    %ebp
f0106584:	89 c7                	mov    %eax,%edi
f0106586:	89 d1                	mov    %edx,%ecx
f0106588:	39 d3                	cmp    %edx,%ebx
f010658a:	72 06                	jb     f0106592 <__umoddi3+0xe2>
f010658c:	75 0e                	jne    f010659c <__umoddi3+0xec>
f010658e:	39 c6                	cmp    %eax,%esi
f0106590:	73 0a                	jae    f010659c <__umoddi3+0xec>
f0106592:	29 e8                	sub    %ebp,%eax
f0106594:	1b 54 24 08          	sbb    0x8(%esp),%edx
f0106598:	89 d1                	mov    %edx,%ecx
f010659a:	89 c7                	mov    %eax,%edi
f010659c:	89 f5                	mov    %esi,%ebp
f010659e:	8b 74 24 04          	mov    0x4(%esp),%esi
f01065a2:	29 fd                	sub    %edi,%ebp
f01065a4:	19 cb                	sbb    %ecx,%ebx
f01065a6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f01065ab:	89 d8                	mov    %ebx,%eax
f01065ad:	d3 e0                	shl    %cl,%eax
f01065af:	89 f1                	mov    %esi,%ecx
f01065b1:	d3 ed                	shr    %cl,%ebp
f01065b3:	d3 eb                	shr    %cl,%ebx
f01065b5:	09 e8                	or     %ebp,%eax
f01065b7:	89 da                	mov    %ebx,%edx
f01065b9:	83 c4 1c             	add    $0x1c,%esp
f01065bc:	5b                   	pop    %ebx
f01065bd:	5e                   	pop    %esi
f01065be:	5f                   	pop    %edi
f01065bf:	5d                   	pop    %ebp
f01065c0:	c3                   	ret    
