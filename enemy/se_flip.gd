tool
extends Leaf

# leaf that flips enemy sprite
func execute():
	agent.flip()
	return statuses.SUCCESS
