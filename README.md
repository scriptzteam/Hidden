<H1 align="center">Privacy for your command line options</H2>
<H3 align="center">A Linux tool to hide from "ps"</H2>

Example: Show only 'nmap', but without the command options:
```sh
./hidden nmap -sCV -F -Pn scanme.nmap.org
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^
                     will not show
```

Example: Replace the current shell with a hidden tmux/shell. Hide all sub processes (`-f`), take on the name of some kernel process (`-a`) and hide all command line options:
```sh
exec ./hidden -f -a'[kworker/1:2-cgroup_destroy]' tmux
```

---
1. Does not require *root*
2. Works also on static binaries (e.g. GoLang binaries)
3. Zaps the environment (*/proc/&lt;PID&gt;/environ*) as well
1. Does not rely on *LD_PRELOAD=* or libc.
2. Uses ptrace() to manipulate the Elf Auxiliary Table
5. Only 00.1% overhead.
6. Stops the admin from seeing or spying on your processes.
7. Starts a process under _any_ process id (`-n <pid>`)

---
Compile:
```sh
git clone https://github.com/scriptzteam/Hidden.git
cd hidden
make
```

---
How it works:
* It uses ptrace() to manipulates the stack's Elf-Aux-Table.
* Hidden intercepts when the Kernel passes the command-options to the program (during SYS_execve()): It moves the orignal command-options to a new memory location and then destroyes the old memory location. From the perspective of the Kernel (and procps), the command-options cease to exist. Finally, hidden fixes the pointers in the progam's Aux-Table and hands execution back to the program (PTRACE_CONTINUE). Thereafter, the program is tracked for any further calls to fork() or execve() [to do the same all over again].
* Almost zero performance impact by using some neat ptrace-features: Tracing only execve() and fork() events (but not any other syscall).
* The `-n <pid>` trick (to start a program under _any_ pid) is a gimmick: Linux assigns a new pid to every new _thread_ in sequential order, up until the largest possible pid of 4,194,304 (2^22). Thereafter, it starts again at pid 300 (or 1, depending on the environment). Hidden iterates over all 2^22 possible pids (within a few seconds) until the target pid-1 is encountered: Hidden forks 8+ processes, each calling `clone((int (*)(void *))exit, ..)`. Directly jumping into `exit()` and setting `CLONE_VM` is the fastest way to iterate through all available PIDs.
