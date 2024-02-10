// Checks that the priority decrease on each call of the scheduler.

#include <inc/lib.h>

#define PRIORITY 80

void
umain(int argc, char **argv)
{
	sys_set_priority(PRIORITY);

	for (int i = 0; i < 20; i++) {
		cprintf("La prioridad es: %d\n", sys_get_priority());
		sys_yield();
	}
	sys_env_destroy(sys_getenvid());
}