package bun.processes;

/**
 * Resource usage information for a subprocess.
 **/
typedef ResourceUsage = {
	contextSwitches:{
		voluntary:Int,
		involuntary:Int
	},
	cpuTime:{
		user:Float,
		system:Float,
		total:Float
	},
	maxRSS:Int,
	messages:{
		sent:Int,
		received:Int
	},
	ops:{
		in_:Int,
		out:Int
	},
	shmSize:Int,
	signalCount:Int,
	swapCount:Int
}