#!/bin/sh

CLONE_TEMP_DIR="/tmp/clone"
GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no -i /root/.ssh/git"

clone_git () {
	export GIT_SSH_COMMAND
	rm -r ${CLONE_TEMP_DIR}
	git clone --depth=1 ${GIT_SSH_TARGET} ${CLONE_TEMP_DIR}
	cd ${CLONE_TEMP_DIR}
	VERSION=`git rev-parse --short HEAD`
	sed -i "s/'');/'${VERSION}');/" ${CLONE_TEMP_DIR}/www/version.php
	export $VERSION
}

deploy () {
	echo
	echo "Deploying $2 code"
	stat "$3/$1" >/dev/null 2>&1 && echo "Already deployed" && echo "Exiting ..." && return
	cp -a ${CLONE_TEMP_DIR}/$2/ "$3/$1" && echo "Done" || echo "Failed"
	echo "Relinking $3/$1 to $3/$4"
	rm $3/$4
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
		deploy $VERSION www /var/www html
		deploy $VERSION cron /var/www current
		deploy $VERSION maintenance /maintenance current
		rotate /var/www
		rotate /var/cron
		rotate /maintenance
		print_footer
		;;
	www)
		clone_git
		deploy $VERSION www /var/www html
		rotate /var/www
		print_footer
		;;
	cron)
		clone_git
		deploy $VERSION cron /var/www current
		rotate /var/cron
		print_footer
		;;
	maintenance)
		clone_git
		deploy $VERSION maintenance /maintenance current
		rotate /maintenance
		print_footer
		;;
	rotate)
		rotate /var/www
		rotate /var/cron
		rotate /maintenance
		;;
	clone)
		clone_git
		;;
	*)
		echo "Usage: all|clone|www|cron|maintenance"
		exit 1
esac