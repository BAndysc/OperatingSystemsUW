#include "pm.h"
#include "mproc.h"
#include <sys/types.h>
#include <stdio.h>
#include "glo.h"

/*===========================================================================*
 *				do_myps					     *
 *===========================================================================*/
int do_myps()
{
	uid_t uid = m_in.m1_i1;
	if (uid == 0)
		uid = mp->mp_realuid;
	printf("%6s %6s %6s\r\n", "PID", "PPID", "UID");
	for (int i = 0; i < NR_PROCS; ++i) 
	{
		pid_t pid = mproc[i].mp_pid;
		if ((mproc[i].mp_flags & IN_USE) == 0)
			continue;
		uid_t puid = mproc[i].mp_realuid;
		if (puid != uid)
 			continue;
		int ppid_id = mproc[i].mp_parent;
		pid_t ppid = mproc[ppid_id].mp_pid;
		printf("%6d %6d %6d\r\n", pid, ppid, puid);		
	}
	return 0;
}
