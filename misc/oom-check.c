#include <signal.h>
#include <assert.h>
#include <stdlib.h>
#include <stdio.h>

static void
trap(int sig)
{
    exit(0);
}

int
main()
{
    assert(signal(SIGTERM, trap) != SIG_ERR);
 a:
    (void) !malloc(sizeof(long long));
    goto a;
}
