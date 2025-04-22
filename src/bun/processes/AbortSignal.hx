package bun.processes;

/**
 * Unix/Linux process signal codes
 **/
enum abstract AbortSignal(String) from String to String {
	final SIGABRT = "SIGABRT";
	final SIGALRM = "SIGALRM";
	final SIGBUS = "SIGBUS";
	final SIGCHLD = "SIGCHLD";
	final SIGCONT = "SIGCONT";
	final SIGFPE = "SIGFPE";
	final SIGHUP = "SIGHUP";
	final SIGILL = "SIGILL";
	final SIGINT = "SIGINT";
	final SIGIO = "SIGIO";
	final SIGIOT = "SIGIOT";
	final SIGKILL = "SIGKILL";
	final SIGPIPE = "SIGPIPE";
	final SIGPOLL = "SIGPOLL";
	final SIGPROF = "SIGPROF";
	final SIGPWR = "SIGPWR";
	final SIGQUIT = "SIGQUIT";
	final SIGSEGV = "SIGSEGV";
	final SIGSTKFLT = "SIGSTKFLT";
	final SIGSTOP = "SIGSTOP";
	final SIGSYS = "SIGSYS";
	final SIGTERM = "SIGTERM";
	final SIGTRAP = "SIGTRAP";
	final SIGTSTP = "SIGTSTP";
	final SIGTTIN = "SIGTTIN";
	final SIGTTOU = "SIGTTOU";
	final SIGUNUSED = "SIGUNUSED";
	final SIGURG = "SIGURG";
	final SIGUSR1 = "SIGUSR1";
	final SIGUSR2 = "SIGUSR2";
	final SIGVTALRM = "SIGVTALRM";
	final SIGWINCH = "SIGWINCH";
	final SIGXCPU = "SIGXCPU";
	final SIGXFSZ = "SIGXFSZ";
	final SIGBREAK = "SIGBREAK";
	final SIGLOST = "SIGLOST";
	final SIGINFO = "SIGINFO";
}