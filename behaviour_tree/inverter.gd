tool
extends Decorator

# a node that returns the opposite result

class_name Inverter

func child_success():
	fail()

func child_fail():
	success()
