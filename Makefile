
GET=incus query --wait --raw -X GET
POST=incus query --wait --raw -X POST
PUT=incus query --wait --raw -X PUT
DELETE=incus query --wait --raw -X DELETE

TYPE?=container
NAME=mytest-$(TYPE)
WAIT=30


all: create start state stop delete
	@echo "Done"

images:
	$(GET) /1.0/images

instances:
	$(GET) /1.0/instances

.PHONY: create
create:
	@echo "Creating instance $(NAME) as $(TYPE)"
	$(POST) '/1.0/instances?project=default' --data '{"name": "$(NAME)", "source": {"type": "image", "alias": "debian/12/cloud", "server": "https://images.linuxcontainers.org", "protocol": "simplestreams", "mode": "pull"}, "type": "$(TYPE)"}'

.PHONY: state
state:
	@echo "Getting state of $(NAME)"
	$(GET) '/1.0/instances/$(NAME)/state'

.PHONY: start
start:
	@echo "Starting $(NAME)"
	$(PUT) '/1.0/instances/$(NAME)/state' --data '{"action": "start", "timeout": 30}'
	$(GET) '/1.0/instances/$(NAME)/state'
	sleep $(WAIT)
	$(GET) '/1.0/instances/$(NAME)/state'

.PHONY: stop
stop:
	@echo "Stopping $(NAME)"
	$(PUT) '/1.0/instances/$(NAME)/state'  --verbose --data '{"action": "stop", "timeout": 60}'

.PHONY: delete
delete:
	@echo "Deleting $(NAME)"
	$(DELETE) '/1.0/instances/$(NAME)'
