# Script to help track tasks locally

# Any line is a task
# indentation means relantionship with above task
# "x" at start of line means task is done
# "-" marks task as "incomplete"
# "#" makes line a coment

# Variable that defines where files will be stores
export TODO=~/todo

# Regular expressions that define:
# Tasks TODO
REG_NEXT="^ *[^-#x ]"
# All tasks
REG_TASKS="^ *[^# ]"
# Tasks DONE
REG_DONE="^ *x"
# Incompleted tasks
REG_INCOMPLETE="^ *-"

# Setup folders and files needed
[[ ! -d $TODO ]] && mkdir $TODO
[[ ! -d $TODO/files ]] && mkdir $TODO/files
[[ ! -d $TODO/files/projects ]] && mkdir $TODO/files/projects

todo () {
  CMD=$1
  shift
  case $CMD in
    "add") todo_add $@;;
    "edit") todo_edit $@;;
    "list") todo_list $@;;
    "count") todo_count $@;;
    "done") todo_done $@;;
    "what") todo_what $@;;
    *) echo "todo - local task manager

- Add task: 'todo add [project] [New task]'
- Edit tasks: 'todo edit [project]'
- List tasks: 'todo list [project]'
- Counts tasks: 'todo count [project]'
- Task is done: 'todo done [project]'
- What is the current task: 'todo what [project]'";;
  esac
}

todo_add () {
  local FILE
  if [ "$1" == "." ]; then
    local DAY=$(date +%F)
    FILE="$TODO/files/$DAY.todo"
  else
    FILE="$TODO/files/projects/$1.todo"
  fi
  shift

  echo $@ >> $FILE
}

todo_edit () {
  if [[ ! -z $1 ]]; then
    vim "$TODO/files/projects/$1.todo"
  else
    local DAY=$(date +%F)
    local FILE="$TODO/files/$DAY.todo"
    vim $FILE
  fi
}

todo_list () {
  if [[ ! -z $1 ]]; then
    FILES="$TODO/files/projects/$1.todo"
  else
    FILES="$TODO/files/**/*.todo"
  fi

  NOT_DONE=$(grep -H "$REG_NEXT" $FILES | sed -En -e "s/\.todo:/: /" -e "s/^${TODO//\//\\/}\/files\/(projects\/)?(.*)/\2/p")

  echo "$NOT_DONE"
}

todo_count () {
  if [[ ! -z $1 ]]; then
    FILES="$TODO/files/projects/$1.todo"
  else
    FILES="$TODO/files/**/*.todo"
  fi

  NUM_TASKS=$(cat $FILES | grep "$REG_TASKS" | wc -l)
  NUM_DONE=$(cat $FILES | grep "$REG_DONE" | wc -l)

  echo "$NUM_DONE/$NUM_TASKS"
}

todo_done () {
  local FILE
  if [[ ! -z $1 ]]; then
    FILE="$TODO/files/projects/$1.todo"
  else
    local DAY=$(date +%F)
    FILE="$TODO/files/$DAY.todo"
  fi

  TASK=$(grep "$REG_NEXT" $FILE | head -n 1)

  sed -Ei -e "s/^(${TASK//\//\\/})$/x \1/" $FILE
}

todo_what () {
  local FILE
  if [[ ! -z $1 ]]; then
    FILE="$TODO/files/projects/$1.todo"
  else
    local DAY=$(date +%F)
    FILE="$TODO/files/$DAY.todo"
  fi

  grep "$REG_NEXT" $FILE | head -n 1
}

