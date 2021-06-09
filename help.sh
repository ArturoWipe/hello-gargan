#!/bin/bash

# Bash params
ACTION=$1
ARGS1=$2

# Style params
STYLE_RESET="\033[0m"
COLOR_WHITE="\033[0;37m"
COLOR_GREEN="\033[0;32m"
COLOR_YELLOW="\033[0;33m"
COLOR_BACKGROUND_GREY="\033[100m"
COLOR_BACKGROUND_PURPLE="\033[105m"
COLOR_BACKGROUND_RED="\033[101m"
TAB="\t"
TABS="\t\t\t"
LINE_BREAK="\r"

# Helpers
function echo_line_break {
	echo -e $LINE_BREAK
}
function echo_list_header {
	echo -e $STYLE_RESET"  "$COLOR_GREEN""$1""$STYLE_RESET
}
function echo_list_point {
	firstLineLength=$(echo -n $1 | wc -m)

	if [ $firstLineLength -lt 12 ]; then
		secondCell="\t"$2
	else
		secondCell=$2
	fi

	echo -e $STYLE_RESET"    "$COLOR_YELLOW""$1""$STYLE_RESET""$TABS""$STYLE_RESET""$COLOR_WHITE""$secondCell""$STYLE_RESET
}
function echo_label {
	echo -e  $STYLE_RESET""$TAB""$COLOR_WHITE""$1""$STYLE_RESET""$TABS""$COLOR_BACKGROUND_GREY" "$2" "$STYLE_RESET
}

# Actions
if [ $ACTION ]; then

	if [ $ACTION = "stack:reset" ]; then
		files="--file docker-compose.yml"
		docker-compose $files stop && \
		docker-compose $files rm -f && \
		CURRENT_USER=$(id -u):$(id -g) docker-compose $files build && \
		CURRENT_USER=$(id -u):$(id -g) docker-compose $files up -d
	fi
	if [ $ACTION = "stack:stop" ]; then
		CURRENT_USER=$(id -u):$(id -g) docker-compose down
	fi
	if [ $ACTION = "stack:stats" ]; then
		docker stats --format "table {{.Name}}\t{{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"
	fi

	# Frontend
	if [ $ACTION = "frontend:logs" ]; then
		docker logs --follow --tail=200 frontend
	fi
	if [ $ACTION = "frontend:console" ]; then
		docker exec -it frontend bash -c "TERM=$TERM exec bash"
	fi
	if [ $ACTION = "frontend:build" ]; then
		docker exec -it frontend yarn build
	fi
	if [ $ACTION = "frontend:compile" ]; then
		docker exec -it frontend yarn compile
	fi
	if [ $ACTION = "frontend:serve" ]; then
		docker exec -it frontend yarn server
	fi
	if [ $ACTION = "frontend:styles" ]; then
		docker exec -it frontend yarn styles
	fi
	if [ $ACTION = "frontend:repl" ]; then
		docker exec -it frontend yarn repl
	fi

# Manual
else

	# Features list
	echo_line_break

	echo_list_header "stack"
	echo_list_point "stack:reset" "stop, remove, build and up all containers"
	echo_list_point "stack:stop" "stop all running containers"
	echo_list_point "stack:stats" "monitoring all containers"

	echo_line_break

	echo_list_header "frontend"
	echo_list_point "frontend:build" "generate a new browser bundle to test"
	echo_list_point "frontend:compile" "type checking the code"
	echo_list_point "frontend:serve" "local development webserver"
	echo_list_point "frontend:styles" "generate all styles (main, bootstrap)"
	echo_list_point "frontend:repl" "access a purescript repl"
	echo_list_point "frontend:logs" "tails logs"
	echo_list_point "frontend:console" "enters the container"

	echo_line_break
fi
