#include <inc/assert.h>
#include <inc/x86.h>
#include <kern/spinlock.h>
#include <kern/env.h>
#include <kern/pmap.h>
#include <kern/monitor.h>
#include <inc/types.h>
#include <inc/stdio.h>

// Lottery constant
#define BOOST_TIME 200
static int timeslice_count = 0;

struct SchedulerStats {
	int num_sched_calls;       // Número de llamadas al scheduler
	int num_executions[NENV];  // Número de ejecuciones por cada proceso
};

struct SchedulerStats scheduler_stats;

void sched_halt(void);


unsigned int
get_total_tickets()
{
	unsigned int accumulator = 0;
	for (int i = 0; i < NENV; i++) {
		if (envs[i].env_status == ENV_RUNNABLE ||
		    envs[i].env_status == ENV_RUNNING) {
			accumulator += envs[i].priority;
		}
	}
	return accumulator;
}

// Genera una semilla usando el valor del contador de ciclos del procesador
uint32_t
generate_seed(void)
{
	uint64_t tsc = read_tsc();
	uint32_t seed = (uint32_t)(tsc & 0xFFFFFFFF);
	return seed;
}

// Genera números pseudoaleatorios usando el generador LCG de Park-Miller
uint32_t
lcg_parkmiller(uint32_t state)
{
	uint64_t product = (uint64_t) state * 48271;
	uint32_t x = (product & 0x7fffffff) + (product >> 31);

	x = (x & 0x7fffffff) + (x >> 31);

	return state = x;
}

void
reset_priorities(void)
{
	timeslice_count++;
	if (timeslice_count < BOOST_TIME) {
		return;
	}

	timeslice_count = 0;
	for (int i = 0; i < NENV; i++) {
		if (envs[i].env_status == ENV_RUNNABLE ||
		    envs[i].env_status == ENV_RUNNING) {
			envs[i].priority = MAX_TICKETS;
		}
	}
}


// Choose a user environment to run and run it.
void
sched_yield(void)
{
	scheduler_stats.num_sched_calls++;
	// cprintf("Entré a sched_yield por %d vez\n",scheduler_stats.num_sched_calls);
	// Implement simple round-robin scheduling.
	//
	// Search through 'envs' for an ENV_RUNNABLE environment in
	// circular fashion starting just after the env this CPU was
	// last running.  Switch to the first such environment found.
	//
	// If no envs are runnable, but the environment previously
	// running on this CPU is still ENV_RUNNING, it's okay to
	// choose that environment.
	//
	// Never choose an environment that's currently running on
	// another CPU (env_status == ENV_RUNNING). If there are
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

#ifdef ROUND_ROBIN
	int start = curenv ? ENVX(curenv->env_id) + 1 : 0;

	for (int j = 0; j < NENV; j++) {
		int i = (start + j) % NENV;

		if (envs[i].env_status == ENV_RUNNABLE) {
			// Antes de ejecutar un proceso, actualiza las estadísticas
			scheduler_stats.num_executions[ENVX(envs[i].env_id)]++;
			envs[i].start_time = read_tsc();
			env_run(&envs[i]);
			return;
		}
	}

	if (curenv && curenv->env_status == ENV_RUNNING) {
		env_run(curenv);  // If no runnable environments, continue running
		                  // the current environment if it's still ENV_RUNNING
		return;
	}

	// sched_halt never returns
#endif

#ifdef SCHED_PRIORIDADES

	int total_tickets = get_total_tickets();

	uint32_t seed = generate_seed();

	uint32_t winner = lcg_parkmiller(seed) % total_tickets;

	int start = curenv ? ENVX(curenv->env_id) + 1 : 0;

	// accumulator: used to track if we’ve found the winner yet
	int accumulator = 0;

	// loop until the sum of ticket values is > the winner
	for (int j = 0; j < NENV; j++) {
		int i = (start + j) % NENV;
		if (envs[i].env_status == ENV_RUNNABLE) {
			accumulator += envs[i].priority;
			if (accumulator > winner) {
				scheduler_stats.num_executions[ENVX(envs[i].env_id)]++;
				envs[i].start_time = read_tsc();
				if (envs[i].priority > MIN_TICKETS) {
					envs[i].priority -= MIN_TICKETS;
				}
				reset_priorities();
				env_run(&envs[i]);
			}
		}
	}
	if (curenv && curenv->env_status == ENV_RUNNING) {
		if (curenv->priority > MIN_TICKETS) {
			curenv->priority -= MIN_TICKETS;
		}
		reset_priorities();
		env_run(curenv);  // If no runnable environments, continue running
		                  // the current environment if it's still ENV_RUNNING
	}
#endif
	sched_halt();
}

// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
		cprintf("No runnable environments in the system!\n");
		cprintf("Scheduler Statistics:\n");
		cprintf("Number of scheduler calls: %d\n",
		        scheduler_stats.num_sched_calls);
		cprintf("Execution statistics per process:\n");

		for (int i = 0; i < NENV; i++) {
			if (scheduler_stats.num_executions[i] > 0) {
				cprintf("Process id: %d: Executions: %d, Start "
				        "Time: %llu, End Time %llu\n ",
				        envs[i].env_id,
				        scheduler_stats.num_executions[i],
				        envs[i].start_time,
				        envs[i].end_time);
			}
		}
		while (1)
			monitor(NULL);
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
	lcr3(PADDR(kern_pgdir));

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Once the scheduler has finishied it's work, print statistics on
	// performance.

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile("movl $0, %%ebp\n"
	             "movl %0, %%esp\n"
	             "pushl $0\n"
	             "pushl $0\n"
	             "sti\n"
	             "1:\n"
	             "hlt\n"
	             "jmp 1b\n"
	             :
	             : "a"(thiscpu->cpu_ts.ts_esp0));
}
