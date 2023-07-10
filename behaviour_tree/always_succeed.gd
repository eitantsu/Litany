tool
extends Decorator

# this node always returns success

class_name AlwaysSucceed

func child_fail():
	success()
