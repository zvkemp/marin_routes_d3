#/!bin/bash

SESSION=routes
tmux -2 new-session -A -d -s $SESSION

tmux new-window -t $SESSION:1 -n 'aux'
tmux split-window -h
tmux select-pane -t 0
tmux send-keys "python -m SimpleHTTPServer 8002" C-m
tmux select-pane -t 1
tmux send-keys "coffee -o js/ -cw coffee/" C-m

tmux new-window -t $SESSION:2 -n 'vim'

tmux split-window -h 
tmux select-pane -t 0
tmux send-keys "vim" C-m
tmux select-pane -t 1
tmux send-keys "vim coffee/routes.coffee" C-m

open http://0.0.0.0:8002

tmux -2 attach-session -t $SESSION
