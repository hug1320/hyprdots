if status is-interactive
    # Commands to run in interactive sessions can go here
end

set GTK_IM_MODULE fcitx
set QT_IM_MODULE fcitx
set XMODIFIERS @im=fcitx

export VOLTA_HOME="$HOME/.volta"
export PATH="/usr/bin/vendor_perl/:$VOLTA_HOME/bin:$PATH:$HOME/.local/bin/"
eval $(opam env)

# Edit this .bashrc file
alias ebrc='xdg-open ~/.bashrc'

# Edit fish config
alias efc='nvim ~/.config/fish/config.fish'

# alias to show the date
alias da='date "+%Y-%m-%d %A %T %Z"'

# Change directory abbr
# alias home='cd ~'
abbr .. 'cd ..'
abbr ... 'cd ../..'
abbr .... 'cd ../../..'
abbr ..... 'cd ../../../..'

# cd into the old directory
abbr pd prevd
abbr nd nextd

# Alias's for multiple directory listing commands
abbr la 'lsd -A' # show hidden files
abbr lx 'lsd -lXh' # sort by extension
abbr lk 'lsd -lSrh' # sort by size
abbr lc '/bin/ls -lcrh' # sort by change time
abbr lu '/bin/ls -lurh' # sort by access time
abbr lr 'lsd -lRh' # recursive ls
abbr lt 'lsd -ltrh' # sort by date
abbr lm 'lsd -alh |more' # pipe through 'more'
abbr lw '/bin/ls -xAh' # wide listing format
abbr ll 'lsd -alFh' # long listing format
abbr labc 'lsd -la' #alphabetical sort
abbr lf "lsd -l | grep -Ev '^d'" # files only
abbr ldir "lsd -l | grep -E '^d'" # directories only

# Search command line history
alias h="history | grep "

# Search running processes
alias p="ps aux | grep "
alias topcpu="/bin/ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10"

# Search files in the current folder
# alias f="fd . | grep "

# Count all files (recursively) in the current folder
function countfiles
    for t in files links directories
        set first_char (string sub -s 1 -l 1 $t)
        echo (fd . -t $first_char 2>/dev/null | wc -l) $t
    end
end

# Show current network connections to the server
alias ipview="sudo netstat -anpl | grep :80 | awk {'print \$5'} | cut -d\":\" -f1 | sort | uniq -c | sort -n | sed -e 's/^ *//' -e 's/ *\$//'"

# Show open ports
alias openports='netstat -nape --inet'

# Alias's to show disk space and space used in a folder
alias diskspace="du -S | sort -n -r |more"
alias folders='du -h --max-depth=1'
alias folderssort='fd . -d 1 -t d -0 | xargs -0 du -sk | sort -rn'
# alias tree='tree -CAhF --dirsfirst'
# alias treed='tree -CAFd'
alias mountedinfo='df -hT'
abbr df duf
abbr du dust

# Extracts any archive(s) (if unp isn't installed)
function extract
	for archive in $argv
		if test -f $archive
			switch $archive
				case '*.tar.bz2'
					tar xvjf $archive    
				case '*.tar.gz'    
					tar xvzf $archive    
				case '*.bz2'       
					bunzip2 $archive     
				case '*.rar'       
					unrar x $archive       
				case '*.gz'        
					gunzip $archive      
				case '*.tar'       
					tar xvf $archive     
				case '*.tbz2'      
					tar xvjf $archive    
				case '*.tgz'       
					tar xvzf $archive    
				case '*.zip'       
					unzip $archive       
				case '*.Z'         
					uncompress $archive  
				case '*.7z'        
					7z x $archive        
				case '*'           
					echo "don't know how to extract '$archive'..."
			end
		else
			echo "'$archive' is not a valid file!"
		end
	end
end	

# Searches for text in all files in the current folder
function ftext
	# -i case-insensitive
	# -I ignore binary files
	# -H causes filename to be printed
	# -r recursive search
	# -n causes line number to be printed
	# optional: -F treat search term as a literal, not a regular expression
	# optional: -l only print filenames and not the matching lines ex. grep -irl "$1" *
	grep -iIHrn --color=always $argv[1] . | less
end

# Copy file with a progress bar
function cpp
    set src $argv[1]
    set dest $argv[2]
    set total_size (stat -c '%s' $src)
    
    if strace -q -ewrite cp -- $src $dest 2>&1 | awk '{
        count += $NF
        if (count % 10 == 0) {
            percent = count / total_size * 100
            printf "%3d%% [", percent
            for (i=0; i<=percent; i++)
                printf "="
            printf ">"
            for (i=percent; i<100; i++)
                printf " "
            printf "]\r"
        }
    }
    END { print "" }' total_size=$total_size count=0
    echo "Copy completed successfully."
    end
end

# Copy and go to the directory
function cpg
    if test -d $argv[2]
        cp $argv[1] $argv[2] && cd $argv[2]
    else
        cp $argv[1] $argv[2]
    end
end

# Move and go to the directory
function mvg
	if test -d $argv[2]
		mv $argv[1] $argv[2] && cd $argv[2]
	else
		mv $argv[1] $argv[2]
	end
end

# Create and go to the directory
function mkdirg
	mkdir -p $argv[1]
	cd $argv[1]
end

# Goes up a specified number of directories  (i.e. up 4)
function up 
	set d ""
	set limit $argv[1]
	for i in (seq $limit)
			set d $d/..
	end
	set d $(echo $d | sed 's/^\///')
	if test -z $d
		set d ..
	end
	cd $d
end

abbr kernel uname -sr

abbr vim nvim

# Automatically install the needed support files for this .bashrc file
function install_config_support
	sudo pacman -S tree unp lsd bat xdg-utils fd git dust duf ripgrep
end

function netinfo
	echo "--------------- Network Information ---------------"
	/sbin/ifconfig wlp1s0 | awk /'inet / {print $2}'
	echo ""
	/sbin/ifconfig wlp1s0 | awk /'inet / {print $4}'
	echo ""
	/sbin/ifconfig wlp1s0 | awk /'inet / {print $6}'
	echo ""
	/sbin/ifconfig wlp1s0 | awk /'ether/ {print $2}'
	echo "---------------------------------------------------"
end

# IP address lookup
function whatsmyip
	# Dumps a list of all IP addresses for every device
	# /sbin/ifconfig |grep -B1 "inet addr" |awk '{ if ( $1 == "inet" ) { print $2 } else if ( $2 == "Link" ) { printf "%s:" ,$1 } }' |awk -F: '{ print $1 ": " $3 }';

	# Internal IP Lookup
	echo -n "Internal IP: " ; ifconfig wlp1s0 | grep inet | awk '{print $2}' | awk 'NR==1{print $1}'

	# External IP Lookup
	echo -n "External IP: " ; wget -qO- http://4.ident.me | xargs echo
end
abbr whatismyip "whatsmyip"

# Trim leading and trailing spaces (for scripts)
function trim
	set var $argv
	set var (string trim -l "$var")  # Supprime les espaces en début de chaîne
	set var (string trim -r "$var")  # Supprime les espaces en fin de chaîne
	echo -n "$var"
end

alias cpu="grep 'cpu ' /proc/stat | awk '{usage=(\$2+\$4)*100/(\$2+\$4+\$5)} END {print usage}' | awk '{printf(\"%.1f\n\", \$1)}'"

# Fonction cd Sx
function cds 
	cd ~/Documents/n7/S$argv[1]/
end

# LSD
command -v lsd > /dev/null && \
  alias ls='lsd --group-dirs first' && \
  abbr tree lsd --tree
	
# CAT & LESS
command -v bat > /dev/null && \
	alias bat='bat --theme=ansi' && \
	alias cat='bat -pp' && \
	alias less='bat'

# TOP
command -v btop > /dev/null && \
  abbr top 'btop'

# Check needrestart pour arch
# alias needrestart="~/Documents/Bordel/needrestart"

#help alias ls
function hls 
  echo "la - show hidden files
  lx - sort by extension
  lk - sort by size
  lc - sort by change time
  lu - sort by access time
  lr - recursive ls
  lt - sort by date
  lm - pipe through 'more'
  lw - wide listing format
  ll - long listing format
  labc - alphabetical sort
  lf - files only
  ldir - directories only"
end

# Marcel: Le docker français
alias marcel='python ~/marcel.py'

# abbr time !
abbr :q exit
abbr rm rm -I
abbr py python3
abbr ksh kitten ssh
abbr cm chezmoi

# git abbr
abbr ga git add
abbr gr git restore
abbr gs git status
abbr gc git commit -m
abbr gps git push
abbr gpl git pull
abbr lg lazygit

