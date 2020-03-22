# 470 Remote Collaboration Setup
VS Code Live Share for editing + Shared Read/Write SSH terminal for build & test  
This is definitely not optimal, nor is it probably all that well designed, but it works, which is what we needed.  
If you make improvements, please share them!

Written by:  
Ian McMurray | <a href = "mailto: ianfm@umich.edu">ianfm@umich.edu </a>


# Initial Host Setup

These are instructions to be able to effectively **host** a live-share session with quick code-sync/run capability. **Joining** is as simple as installing the Live Share extension and joining a session set up by the host.

## Install Windows Subsystem for Linux (WSL)
I recommend Ubuntu for simplicity and widely available help resources, but any distro should work if you have the experience.

Complete instructions for installing WSL available here, I highly recommend reading:  
https://docs.microsoft.com/en-us/windows/wsl/install-win10#install-your-linux-distribution-of-choice   
Followed by:  
https://docs.microsoft.com/en-us/windows/wsl/initialize-distro  
to get the whole picture (literally, since there are pictures 👌)


### Abbreviated Steps if you aren't feeling the link:

1. Open PowerShell as administrator and run:  
`Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux`
2. Restart when prompted   
3. Choose your favorite distro (I recommend Ubuntu) and install from Microsoft Store [Ubuntu in MS Store](https://www.microsoft.com/store/apps/9N9TNGVNDL3Q)
4. Click ‘Install’ and wait until it completes  
5. Click ‘Launch’ to bring up the installation shell  
6. When the shell installation completes, set a username and password (you will need this later!!!)  
7. Run ‘bash’ from command prompt, powershell, or windows search bar to run  


## WSL Dependencies

Do the following in your bash shell

1. Install ssh and make (need the root password you made when initializing your distro)  
	> `sudo apt install ssh make`
2. Make an ssh config file. Optional but recommended.  
	> `mkdir ~/.ssh && touch ~/.ssh/config`  

note: `~` is home dir, handy for building paths to things


## VS Code Dependencies and File Setup

Set up VS Code environment by installing extensions and testing the workflow

1. Install the following extensions: 


	| Required                      |   Optional                            |  
	|  ---                          | ---                                   |    
	| Live Share *by Microsoft*     | Remote-SSH *by Microsoft*           	|   
	| Remote-WSL *by Microsoft*     | TCL *by rashwell*                     |
	|                            |  Verilog HDL/SystemVerilog *by msr-h* |   
	|                            | Better Comments *by Aaron Bond*       |  

	Note: Remote-SSH is my preference for solo work, though incompatible with Live Share. It plays kinda sorta nicely-ish with [ControlMaster][^1]...  
2. Open Remote-WSL session (click the little green [><] guy in bottom left of VS Code window, then Remote-WSL: New Window)
3. Decide where you want your repo to live in your WSL instance (mine's at `~/code/`, so I run `cd ~/code/`), call it LOCAL_DIR. Then run
	> `cd LOCALDIR`  
	
	 e.g. I would run  
	> `cd ~/code`
4. clone group3w20 repo:
	* replace [USERNAME] in the following command with your **bitbucket username**, then run:
		> `git clone https://[USERNAME]@bitbucket.org/eecs470staff/group3w20.git`
	* Since I'm in group 3 and my LOCAL_DIR is `~/code/`, the result for me would be `~/code/group3w20`, which is the name of our top-level bitbucket directory, containing the familiar verilog/, testbench/, etc. 
	* Note that the git root is *inside* `group3w20/`, which will be relevant later in setup.
5. Add sync.mk and README_sync.md to LOCAL_DIR, on the same level as groupXw20 (**NOT** in it)

6. Personalize sync.mk  
	* Define the variable `REMOTE_BASEDIR` as the relative path (from home, ~) of the directory to which you want things synced in your CAEN account  
	e.g. I want to put things in `~/Private/470/testing` so I set `REMOTE_BASEDIR := Private/470/testing`
	* This is different for each *person*, not just each group, so don't push your copy to your repo unless you've modified this setup somehow.
7. Add the following rule to your top-level makefile (i.e. `groupXw20/Makefile`)
	```Makefile
	# This tells make to cd up a level and invoke the sync2caen target in sync.mk there
	sync2caen:		
		cd .. && $(MAKE) -f sync.mk sync2caen   
	.PHONY: sync2caen
	```

That's it for setup! 

[^1]: <https://en.wikibooks.org/wiki/OpenSSH/Cookbook/Multiplexing> "SSH Multiplexing"

# Hosting a session

Do this after initial setup to test and whenever you want to work with your group

Examples of the filepaths we care about (with some other junk for context) are:  
> `LOCAL_DIR/groupXw20`  
> should be same as  
> `YourComputer-WSL:~/some/path/you/fancy/groupXw20/verilog`  
> i.e.  
> LOCAL_DIR = ~/some/path/you/fancy

and 

> `~/REMOTE_BASEDIR/groupXw20/verilog`  
> should be same as  
> `CaenComputer:~/some/other/pleasant/path/groupXw20/verilog`  
> i.e.  
> REMOTE_BASEDIR = ~/some/path/you/fancy


1. Local setup - VS Code
	- [><] Remote-WSL: New window
	- Open folder LOCAL_DIR (from File > Open Folder) that you chose during setup
	- Open integrated terminal and, after replacing LOCAL_DIR and X, run
		```bash
		cd LOCAL_DIR/groupXw20
		make sync2caen
		``` 
	- Enter your umich password and hate your way through Duo prompt to sync LOCAL_DIR to REMOTE_BASEDIR/LOCAL_DIR
	- Open a new terminal for an ssh session (leaving terminal just used open you can run local sync command)
		* clck the '+' to the right of 'bash' dropdown in integrated terminal
	- Start ssh session so you have a terminal into your CAEN account for testing.
		* basic non ssh-config way to start connection is `ssh login-course.engin.umich.edu`
		* I haven't been able to get rsync to use existing ssh connections to avoid extra DUOing but it's a goal.
		* config file needed for multiplexing but since it doesn't work rn don't worry about it
	- cd to REMOTE_BASEDIR/group3w20
	- Run make to your heart's content
2. Live Share setup
	- Click Live Share icon in activity bar (left side)
	- Click 'start collaborative session'
	- If it's your first time using Live Share, you need to log in through some Microsoft web auth pages that will pop up
	- Your collaboration link should be copied to your clipboard automatically. Share it with your group so they can join
	- In the Live Share panel (left), a new 'Shared Terminals' dropdown should appear once the session is started
	- Right click on the name of terminal with ssh running and select 'Make read/write' to share it fully with group
	- Do the same for the local bash terminal so people can sync code when they've changed it.

I think that's it. You should have a working Live Share session with read/write access to project files and a terminal for building and testing!

# Bonus Round: SSH config

If you already have an ssh config, go you. If not, I've provided the basic version of what I use to login to CAEN servers.

See file 'config' and put it in `~/.ssh` on your local WSL instance (and your local .ssh if you have it installed on Windows and find it handy)

Also see references pertaining to rsync, ControlMaster, SSH multiplexing, and ssh-config at the end if you want to learn more.


# Known Issues

There's some real shit here.

## Usage Problems
- git remote actions (fetch, push, pull) can only be done by the session host since a password is required 
	- Unless you have an ssh key set up, in which case it might work. Haven't tested.
- Syncing to CAEN can currently only be done by session host, which should NOT be a problem.
	- If ControlMaster worked properly (or possibly if I were less of a bungling fool) then the password would only be needed once, which would effectively solve the issue.
- The need for an extra makefile seems dumb. Setting this up to accommodate multiple users would be more dumb.
- DUO is the root of all evil
	- get a yubikey for free from computer showcase (I hear they deliver now) 
	- then you just tap a dongle instead of pressing 1
	- make a shorter password if u spicy
- ??? Pls fill in!

## Things that Should Work
- ControlMaster works for ssh sessions started in the terminal, but not for rsync started via Makefile. Could be a shell environment issue? But the way I have it set up (with ssh-config), should be independent of shell env I think.
- ???

## Proposed Solutions (or paths to them)

- ControlMaster not working for rsync
	- git gud
	- Look further into Darden's course material (seems to be open access) for ControlMaster and ssh-config setup
	- read more rsync documentation
	- try using a jump server, maybe w/ proxy command: nc something something dark side
- session joinees can't run git push
	- consider making a group email account with bitbucket access, shared password/key?

# Troubleshooting

* no rule sync2caen
	* If you're in LOCAL_DIR/groupXw20  
		Check groupXw20 has rule provided in "VS Code Dependencies and File Setup" step 7
	* If you're in LOCAL_DIR
		You should probably be in LOCAL_DIR/groupXw20. Else if you really wanna be there, run `make -F sync.mk sync2caen`
* ssh borked, something like 'key not accepted' when trying to connect to CAEN
	* you might have ssh-agent running. You can check with some variation on `top` then `h` or maybe that `ps -aux grep "ssh"` from linux lab slides
- Fork I should probably upload this instead of thinking of more stupid problems you'll have (/I've had). Have fun!





# Links and References
Darden’s magic Makefile with rsync:  
https://gitlab.eecs.umich.edu/eecs281/makefile/commit/710a34af3bfba481a09dffb1e12cfa086b16a937

Also, from his class c4cs:  
https://c4cs.github.io/lectures/w18/week11.pdf

SSH config file man page  
https://linux.die.net/man/5/ssh_config

More readable SSH config reference  
https://www.cyberciti.biz/faq/create-ssh-config-file-on-linux-unix/

Rsync man page  
https://linux.die.net/man/1/rsync

Makefile reference for some things used (notdir)  
https://ftp.gnu.org/old-gnu/Manuals/make-3.79.1/html_node/make_79.html

SSH Multiplexing reference (not really working yet but ideal for not wasting duo time)  
https://en.wikibooks.org/wiki/OpenSSH/Cookbook/Multiplexing

Linux file permission view/modify  
https://phoenixnap.com/kb/linux-file-permissions

Install WSL  
https://docs.microsoft.com/en-us/windows/wsl/install-win10#install-your-linux-distribution-of-choice

Initialize new WSL distro  
https://docs.microsoft.com/en-us/windows/wsl/initialize-distro

WSL 2 (optional)  
https://docs.microsoft.com/en-us/windows/wsl/wsl2-install

Live Share page   
https://visualstudio.microsoft.com/services/live-share/

Remote-WSL page  
https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-wsl
https://code.visualstudio.com/docs/remote/wsl

VS Code  
https://code.visualstudio.com/

Ubuntu Windows Store App  
https://www.microsoft.com/store/apps/9N9TNGVNDL3Q  
more at  
https://docs.microsoft.com/en-us/windows/wsl/install-win10#install-your-linux-distribution-of-choice
