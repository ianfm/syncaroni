# From Darden 281 Makefile found on gitlab
# https://gitlab.eecs.umich.edu/eecs281/makefile/commit/710a34af3bfba481a09dffb1e12cfa086b16a937

# This makefile syncs the contents of your current directory recursively
# to the specified remote path on your CAEN account.

# Sync to CAEN support
#     A) Requires an .ssh/config file with a login.engin.umich.edu host
#        defined, SSH Multiplexing enabled, and an open SSH connection.
# 		-- See example .ssh/config. Needs ControlMaster and ControlPath
#     B) Edit the REMOTE_BASEDIR variable if default is not preferred.
#     C) Usage:
#            $$ make sync2caen
# Above is from Darden... sounds like multiplexing works for him. Maybe need a jump server.
# Leaving it for context in hope that someone gets it to work!

# This is the path from the CAEN home folder to where projects will be
# uploaded. (eg. /home/mmdarden/eecs281/project1)
REMOTE_BASEDIR := Private/470-project
# TODO: CHANGE THIS if you prefer a different path.
# e.g. pwd returns project0, then
# REMOTE_BASEDIR := w18/eecs281    # copies files to /home/mmdarden/w18/eecs281/project0

REPO := group3w20
LOCAL_DIR := ~/code/

# If you want to check the paths being used / dir syncing options
# echopath:
# 	echo "REMOTE_PATH := ${REMOTE_BASEDIR}/$(notdir $(shell pwd))"
# 	echo "$(notdir $(shell pwd))"

# If you want your local top-level dir (LOCAL_DIR from README) to be a part of your remote path, leave this as is:
# sync2caen:  REMOTE_PATH := ${REMOTE_BASEDIR}/$(notdir $(shell pwd))
# and if you DON'T, the make it like so:
sync2caen:  REMOTE_PATH := ${REMOTE_BASEDIR}
sync2caen:
	# Make target directory on CAEN
	ssh login.engin.umich.edu "mkdir -p ${REMOTE_PATH}"
	# Doesn't appear to work with ControlMaster
	# Synchronize local files into target directory on CAEN
	rsync \
		-av \
		--delete \
		--exclude '${REPO}/.git*' \
		--filter=":- ${REPO}/.gitignore" \
		${LOCAL_DIR} \
		-e "ssh login.engin.umich.edu" \
		"login.engin.umich.edu:${REMOTE_PATH}/"

.PHONY: sync2caen
