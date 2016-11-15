#!/bin/sh

CLONE_TEMP_DIR="/tmp/clone"
GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no -i /root/.ssh/git"
TARGET_WWW="/var/www/$VERSION/"
TARGET_CRON="/var/cron/$VERSION/"
TARGET_MAINTENANCE="/maintenance/$VERSION/"                                                                                           

clone_git () {
	export GIT_SSH_COMMAND
	rm -r ${CLONE_TEMP_DIR}
	git clone --depth=1 ${GIT_SSH_TARGET} ${CLONE_TEMP_DIR}
	cd ${CLONE_TEMP_DIR}
	VERSION=`git rev-parse --short HEAD`
	sed -i "s/'');/'${VERSION}');/" ${CLONE_TEMP_DIR}/www/version.php
}

deploy_www () { 
	echo
	echo "Deploying www code"
	stat "$TARGET_WWW" >/dev/null 2>&1 && echo "Already deployed" && echo "Exiting ..." && return
	cp -a ${CLONE_TEMP_DIR}/www/ "$TARGET_WWW" && echo "Done" || echo "Failed"
	echo "Relinking $TARGET_WWW to /var/www/html"
	rm /var/www/html
	ln -s "$TARGET_WWW" /var/www/html && echo "Done" || echo "Failed"
}

deploy_cron () { 
	echo
	echo "Deploying cron code"
	stat "$TARGET_CRON" >/dev/null 2>&1 && echo "Already deployed" && echo "Exiting ..." && return
	cp -a ${CLONE_TEMP_DIR}/cron/ "$TARGET_CRON" && echo "Done" || echo "Failed"
	echo "Relinking $TARGET_CRON to /var/cron/current"
	rm /var/cron/current
	ln -s "$TARGET_CRON" /var/cron/current && echo "Done" || echo "Failed"
}

deploy_maintenance () { 
	echo
	echo "Deploying maintenance code"
	stat "$TARGET_MAINTENANCE" >/dev/null 2>&1 && echo "Already deployed" && echo "Exiting ..." && return
	cp -a ${CLONE_TEMP_DIR}/maintenance/ "$TARGET_MAINTENANCE" && echo "Done" || echo "Failed"
	echo "Relinking $TARGET_MAINTENANCE to /maintenance/current"
	rm /maintenance/current
	ln -s "$TARGET_MAINTENANCE" /maintenance/current && echo "Done" || echo "Failed"
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

print_footer () {
	echo "Finished"
	echo
}

case "$1" in
	all)
		clone_git
		deploy_www
		deploy_cron
		deploy_maintenance
		print_footer
		;;
	www)
		deploy_www
		print_footer
		;;
	cron)
		deploy_cron
		print_footer
		;;
	maintenance)
		deploy_maintenance
		print_footer
		;;
	rotate)
		rotate $TARGET_WWW
		rotate $TARGET_CRON
		rotate $TARGET_MAINTENANCE
	clone)
		clone_git
		;;
	*)
		echo "Usage: all|clone|www|cron|maintenance"
		exit 1
esac