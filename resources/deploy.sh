#!/bin/bash
set -eo pipefail

CLONE_TEMP_DIR="/tmp/clone"
GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no -i /root/.ssh/git"

clone_git () {
	export GIT_SSH_COMMAND
	rm -r ${CLONE_TEMP_DIR} || true
	git clone -b ${GIT_BRANCH} --depth=1 ${GIT_SSH_TARGET} ${CLONE_TEMP_DIR}
	CODE_VERSION=`sed -n -E "s/.*CODE_VERSION\s*=\s*'([^']+)'.*/\1/p" ${CLONE_TEMP_DIR}/${VERSION_FILE}`
	echo "Version: ${CODE_VERSION}"
	export CODE_VERSION
}

deploy () {
	echo
	echo "Deploying $2 code"
	mkdir -p "$3" 2>&1 || true
	stat "$3/$1" >/dev/null 2>&1 && echo "Already deployed" && echo "Exiting ..." && return
	cp -a ${CLONE_TEMP_DIR}/$2/ "$3/$1" && echo "Done" || echo "Failed"
	echo "Relinking $3/$1 to $3/$4"
	stat "$3/$4" >/dev/null 2>&1 && rm $3/$4
	ln -s "$3/$1" $3/$4 && echo "Done" || echo "Failed"
}

rotate () {
	TRASH=$1/trash
	echo
	echo "Rotating $1 $ROTATE_MAX_DAYS days old releases"
	mkdir $TRASH 2> /dev/null || touch $TRASH
	echo "Deleting ..."
	find $TRASH -type d -mindepth 1 -maxdepth 1 -print -exec rm -r {} \;
	echo "Moving to trash ..."
	find $1 -type d -mtime +$ROTATE_MAX_DAYS -mindepth 1 -maxdepth 1 -print -exec mv {} $TRASH \;
}

print_footer () {
	echo "Finished"
	echo
}

case "$1" in
	all)
		clone_git
		deploy $CODE_VERSION www /var/www html
		deploy $CODE_VERSION src /var/src current
		deploy $CODE_VERSION cron /var/cron current
		deploy $CODE_VERSION maintenance /maintenance current
		rotate /var/www
		rotate /var/src
		rotate /var/cron
		rotate /maintenance
		print_footer
		;;
	laravel)
		clone_git
		deploy $CODE_VERSION laravel /repo/laravel current
		rotate /repo/laravel
		print_footer
		;;
	www)
		clone_git
		deploy $CODE_VERSION www /var/www html
		rotate /var/www
		print_footer
		;;
	src)
		clone_git
		deploy $CODE_VERSION src /var/src current
		rotate /var/src
		print_footer
		;;
	cron)
		clone_git
		deploy $CODE_VERSION cron /var/cron current
		rotate /var/cron
		print_footer
		;;
	maintenance)
		clone_git
		deploy $CODE_VERSION maintenance /maintenance current
		rotate /maintenance
		print_footer
		;;
	rotate)
		rotate /var/www
		rotate /var/src
		rotate /var/cron
		rotate /maintenance
		;;
	clone)
		clone_git
		;;
	*)
		echo "Usage: all|clone|www|src|cron|maintenance"
		exit 1
esac