// Check that the priority

#include <inc/lib.h>

#define PRIORITY 79

void
umain(int argc, char **argv)
{
	sys_set_priority(PRIORITY);

	cprintf("La prioridad deberia ser 79 y es: %d\n", sys_get_priority());
}