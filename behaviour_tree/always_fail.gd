tool
extends Decorator


# this node always returns fail

class_name AlwaysFail

func child_success():
	fail()
