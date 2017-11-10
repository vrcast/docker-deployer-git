#!/bin/sh

GIT_SSH_KEY_FILE="/root/.ssh/git"

touch $GIT_SSH_KEY_FILE
chmod 0600 $GIT_SSH_KEY_FILE
echo -e $GIT_SSH_KEY > $GIT_SSH_KEY_FILE

exec $@