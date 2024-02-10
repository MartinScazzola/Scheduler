// Check that the priority

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
	int i = fork();

	if (i < 0) {
		cprintf("Error in fork\n");
		return;
	}

	if (i == 0) {
		// Child
		cprintf("Child priority: %d\n", sys_get_priority());
	} else {
		// Parent
		cprintf("Parent priority: %d\n", sys_get_priority());
	}
}