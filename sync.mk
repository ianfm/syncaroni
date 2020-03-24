# From Darden 281 Makefile found on gitlab
# https://gitlab.eecs.umich.edu/eecs281/makefile/commit/710a34af3bfba481a09dffb1e12cfa086b16a937

# This makefile syncs the contents of your current directory recursively
# to the specified remote path on your CAEN account.

# Sync to CAEN support
#     A) Requires an .ssh/config file with a login.engin.umich.edu host
#        defined, SSH Multiplexing enabled, and an open SSH connection.
# 		-- See example .ssh/config. Needs ControlMaster and ControlPath
#     B) Edit the REMOTE_BASEDIR variable if default is not preferred.
# 	  C) Edit REPO variable to be your project repository name 
#     D) Usage:
#            $$ make sync2caen
# 	  

# This is the path from the CAEN home folder to where projects will be
# uploaded. (eg. /home/mmdarden/eecs281/project1)
REMOTE_BASEDIR := Private/470-project
# TODO: CHANGE THIS if you prefer a different path.
# e.g. pwd returns project0, then
# REMOTE_BASEDIR := w18/eecs281    # copies files to /home/mmdarden/w18/eecs281/project0

REPO := groupXw20
LOCAL_DIR := ./
HOST := login.engin.umich.edu

sync2caen:  REMOTE_PATH := ${REMOTE_BASEDIR}
sync2caen:
	# Make target directory on CAEN
	ssh ${HOST} "mkdir -p ${REMOTE_PATH}"
	# Synchronize local files into target directory on CAEN
	rsync \
		-av \
		--delete \
		--exclude '${REPO}/.git*' \
		--filter=":- ${REPO}/.gitignore" \
		${LOCAL_DIR} \
		"${HOST}:${REMOTE_PATH}/"

.PHONY: sync2caen
