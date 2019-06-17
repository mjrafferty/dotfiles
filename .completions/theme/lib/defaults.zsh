# vim:ft=bash
typeset -g     RIFF_NODE_VERSION_PROJECT_ONLY=false
typeset -g     RIFF_ALWAYS_SHOW_CONTEXT=false
typeset -g     RIFF_ALWAYS_SHOW_USER=false
typeset -g     RIFF_ANACONDA_LEFT_DELIMITER="("
typeset -g     RIFF_ANACONDA_RIGHT_DELIMITER=")"
typeset -g     RIFF_BACKGROUND_JOBS_VERBOSE_ALWAYS=false
typeset -g     RIFF_BACKGROUND_JOBS_VERBOSE=true
typeset -g -i  RIFF_BATTERY_HIDE_ABOVE_THRESHOLD=999
typeset -g -a  RIFF_BATTERY_LEVEL_BACKGROUND
typeset -g -i  RIFF_BATTERY_LOW_THRESHOLD=10
typeset -g     RIFF_BATTERY_VERBOSE=true
typeset -g     RIFF_CHRUBY_SHOW_ENGINE=true
typeset -g     RIFF_CHRUBY_SHOW_VERSION=true
typeset -g     RIFF_COLOR_SCHEME="dark"
typeset -g -i  RIFF_COMMAND_EXECUTION_TIME_PRECISION=2
typeset -g -i  RIFF_COMMAND_EXECUTION_TIME_THRESHOLD=3
typeset -g     RIFF_DIR_MAX_LENGTH=0
typeset -g     RIFF_DIR_OMIT_FIRST_CHARACTER=false
typeset -g -a  RIFF_DIR_PACKAGE_FILES
RIFF_DIR_PACKAGE_FILES=(package.json composer.json)
typeset -g     RIFF_DIR_PATH_ABSOLUTE=false
typeset -g     RIFF_DIR_PATH_HIGHLIGHT_BOLD=false
typeset -g     RIFF_DIR_PATH_SEPARATOR="/"
typeset -g     RIFF_DIR_PATH_SEPARATOR_FOREGROUND=""
typeset -g     RIFF_DIR_SHOW_WRITABLE=false
typeset -g     RIFF_DISABLE_GITSTATUS=false
typeset -g     RIFF_DISABLE_RPROMPT=false
typeset -g -i  RIFF_DISK_USAGE_CRITICAL_LEVEL=95
typeset -g     RIFF_DISK_USAGE_ONLY_WARNING=false
typeset -g -i  RIFF_DISK_USAGE_WARNING_LEVEL=90
typeset -g     RIFF_EXPERIMENTAL_TIME_REALTIME=false
typeset -g     RIFF_HIDE_BRANCH_ICON=false
typeset -g     RIFF_HOME_FOLDER_ABBREVIATION="~"
typeset -g     RIFF_HOST_TEMPLATE="%m"
typeset -g     RIFF_IGNORE_TERM_COLORS=false
typeset -g     RIFF_IGNORE_TERM_LANG=false
typeset -g     RIFF_IP_INTERFACE="^[^                                                                ]+"
typeset -g     RIFF_JAVA_VERSION_FULL=true
typeset -g -a  RIFF_KUBECONTEXT_CLASSES
typeset -g     RIFF_KUBECONTEXT_SHOW_DEFAULT_NAMESPACE=true
typeset -g -a  RIFF_LEFT_PROMPT_ELEMENTS
RIFF_LEFT_PROMPT_ELEMENTS=(context dir vcs)
typeset -g -i  RIFF_LOAD_WHICH=5
typeset -g -i  RIFF_MAX_CACHE_SIZE=10000
typeset -g     RIFF_MODE=""
typeset -g     RIFF_PROMPT_ADD_NEWLINE=false
typeset -g     RIFF_PROMPT_ON_NEWLINE=false
typeset -g     RIFF_PUBLIC_IP_HOST="http://ident.me"
typeset -g -a  RIFF_PUBLIC_IP_METHODS
RIFF_PUBLIC_IP_METHODS=(dig curl wget)
typeset -g     RIFF_PUBLIC_IP_NONE=""
typeset -g -i  RIFF_PUBLIC_IP_TIMEOUT=300
typeset -g     RIFF_PUBLIC_IP_VPN_INTERFACE=""
typeset -g     RIFF_PYENV_PROMPT_ALWAYS_SHOW=false
typeset -g     RIFF_RBENV_PROMPT_ALWAYS_SHOW=false
typeset -g -a  RIFF_RIGHT_PROMPT_ELEMENTS
RIFF_RIGHT_PROMPT_ELEMENTS=(status root_indicator background_jobs history time)
typeset -g     RIFF_RPROMPT_ON_NEWLINE=false
typeset -g     RIFF_SHORTEN_FOLDER_MARKER="(.shorten_folder_marker|.bzr|CVS|.git|.hg|.svn|.terraform|.citc)"
typeset -g     RIFF_SHORTEN_STRATEGY=""
typeset -g     RIFF_SHOW_CHANGESET=false
typeset -g     RIFF_SHOW_RULER=false
typeset -g     RIFF_STATUS_CROSS=false
typeset -g     RIFF_STATUS_HIDE_SIGNAME=false
typeset -g     RIFF_STATUS_OK_IN_NON_VERBOSE=false
typeset -g     RIFF_STATUS_OK=true
typeset -g     RIFF_STATUS_SHOW_PIPESTATUS=true
typeset -g     RIFF_STATUS_VERBOSE=true
typeset -g     RIFF_TIME_FORMAT="%D{%H:%M:%S}"
typeset -g     RIFF_USER_TEMPLATE="%n"
typeset -g     RIFF_VCS_ACTIONFORMAT_FOREGROUND=red
typeset -g -a  RIFF_VCS_BACKENDS
RIFF_VCS_BACKENDS=(git)
typeset -g -i  RIFF_VCS_COMMITS_AHEAD_MAX_NUM=-1
typeset -g -i  RIFF_VCS_COMMITS_BEHIND_MAX_NUM=-1
typeset -g -a  RIFF_VCS_GIT_HOOKS
RIFF_VCS_GIT_HOOKS=(vcs-detect-changes git-untracked git-aheadbehind git-stash git-remotebranch git-tagname)
typeset -g -a  RIFF_VCS_HG_HOOKS
RIFF_VCS_HG_HOOKS=(vcs-detect-changes)
typeset -g     RIFF_VCS_HIDE_TAGS=false
typeset -g -i  RIFF_VCS_INTERNAL_HASH_LENGTH=8
typeset -g     RIFF_VCS_LOADING_TEXT=loading
typeset -g -i  RIFF_VCS_MAX_INDEX_SIZE_DIRTY=-1
typeset -g -F  RIFF_VCS_MAX_SYNC_LATENCY_SECONDS=0.05
typeset -g     RIFF_VCS_SHOW_SUBMODULE_DIRTY=false
typeset -g -i  RIFF_VCS_STAGED_MAX_NUM=1
typeset -g -a  RIFF_VCS_SVN_HOOKS
RIFF_VCS_SVN_HOOKS=(vcs-detect-changes  svn-detect-changes)
typeset -g -i  RIFF_VCS_UNSTAGED_MAX_NUM=1
typeset -g -i  RIFF_VCS_UNTRACKED_MAX_NUM=1
typeset -g     RIFF_VI_COMMAND_MODE_STRING="NORMAL"
typeset -g     RIFF_VI_INSERT_MODE_STRING="INSERT"
typeset -g     RIFF_VPN_IP_INTERFACE="tun"
typeset -g     RIFF_WHITESPACE_BETWEEN_LEFT_SEGMENTS=" "
typeset -g     RIFF_WHITESPACE_BETWEEN_RIGHT_SEGMENTS=" "

#typeset -g     RIFF_BATTERY_STAGES
#typeset -g     RIFF_CHANGESET_HASH_LENGTH
#typeset -g     RIFF_DIR_PATH_HIGHLIGHT_FOREGROUND
#typeset -g     RIFF_GITSTATUS_DIR
#typeset -g     RIFF_KUBECONTEXT_BACKGROUND
#typeset -g     RIFF_KUBECONTEXT_CLASSES
#typeset -g     RIFF_KUBECONTEXT_FOREGROUND
#typeset -g     RIFF_KUBECONTEXT_OTHER_BACKGROUND
#typeset -g     RIFF_KUBECONTEXT_PROD_BACKGROUND
#typeset -g     RIFF_KUBECONTEXT_TESTING_BACKGROUND
#typeset -g     RIFF_PROMPT_ADD_NEWLINE_COUNT
#typeset -g     RIFF_RULER_CHAR
#typeset -g     RIFF_SHORTEN_DELIMITER
#typeset -g     RIFF_SHORTEN_DELIMITER_LENGTH
#typeset -g     RIFF_SHORTEN_DIR_LENGTH
#typeset -g     RIFF_VCS_MAX_NUM_STAGED
#typeset -g     RIFF_VCS_MAX_NUM_UNSTAGED
#typeset -g     RIFF_VCS_MAX_NUM_UNTRACKED
#typeset -g     RIFF_VCS_SHORTEN_DELIMITER
#typeset -g     RIFF_VCS_SHORTEN_LENGTH=""
#typeset -g     RIFF_VCS_SHORTEN_MIN_LENGTH=""
## RIFF_VCS_SHORTEN_STRATEGY truncate_middle or truncate_from_right
#typeset -g     RIFF_VCS_SHORTEN_STRATEGY=""
#typeset -g     RIFF_VI_VISUAL_MODE_STRING=""
