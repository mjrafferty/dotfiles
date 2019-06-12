# vim:ft=bash
set_default     P9K_NODE_VERSION_PROJECT_ONLY                    false
set_default     POWERLEVEL9K_ALWAYS_SHOW_CONTEXT                 false
set_default     POWERLEVEL9K_ALWAYS_SHOW_USER                    false
set_default     POWERLEVEL9K_ANACONDA_LEFT_DELIMITER             "("
set_default     POWERLEVEL9K_ANACONDA_RIGHT_DELIMITER            ")"
set_default     POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE_ALWAYS      false
set_default     POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE             true
set_default -i  POWERLEVEL9K_BATTERY_HIDE_ABOVE_THRESHOLD        999
set_default -a  POWERLEVEL9K_BATTERY_LEVEL_BACKGROUND
set_default -i  POWERLEVEL9K_BATTERY_LOW_THRESHOLD               10
set_default     POWERLEVEL9K_BATTERY_VERBOSE                     true
set_default     POWERLEVEL9K_CHRUBY_SHOW_ENGINE                  true
set_default     POWERLEVEL9K_CHRUBY_SHOW_VERSION                 true
set_default     POWERLEVEL9K_COLOR_SCHEME                        "dark"
set_default -i  POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION    2
set_default -i  POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD    3
set_default     POWERLEVEL9K_CONTEXT_TEMPLATE                    "%n@%m"
set_default     POWERLEVEL9K_DATE_FORMAT                         "%D{%d.%m.%y}"
set_default     POWERLEVEL9K_DIR_MAX_LENGTH                      0
set_default     POWERLEVEL9K_DIR_OMIT_FIRST_CHARACTER            false
set_default -a  POWERLEVEL9K_DIR_PACKAGE_FILES                   package.json composer.json
set_default     POWERLEVEL9K_DIR_PATH_ABSOLUTE                   false
set_default     POWERLEVEL9K_DIR_PATH_HIGHLIGHT_BOLD             false
set_default     POWERLEVEL9K_DIR_PATH_SEPARATOR                  "/"
set_default     POWERLEVEL9K_DIR_PATH_SEPARATOR_FOREGROUND       ""
set_default     POWERLEVEL9K_DIR_SHOW_WRITABLE                   false
set_default     POWERLEVEL9K_DISABLE_GITSTATUS                   false
set_default     POWERLEVEL9K_DISABLE_RPROMPT                     false
set_default -i  POWERLEVEL9K_DISK_USAGE_CRITICAL_LEVEL           95
set_default     POWERLEVEL9K_DISK_USAGE_ONLY_WARNING             false
set_default -i  POWERLEVEL9K_DISK_USAGE_WARNING_LEVEL            90
set_default     POWERLEVEL9K_EXPERIMENTAL_TIME_REALTIME          false
set_default     POWERLEVEL9K_HIDE_BRANCH_ICON                    false
set_default     POWERLEVEL9K_HOME_FOLDER_ABBREVIATION            "~"
set_default     POWERLEVEL9K_HOST_TEMPLATE                       "%m"
set_default     POWERLEVEL9K_IGNORE_TERM_COLORS                  false
set_default     POWERLEVEL9K_IGNORE_TERM_LANG                    false
set_default     POWERLEVEL9K_IP_INTERFACE                        "^[^                                                                ]+"
set_default     POWERLEVEL9K_JAVA_VERSION_FULL                   true
set_default -a  POWERLEVEL9K_KUBECONTEXT_CLASSES
set_default     POWERLEVEL9K_KUBECONTEXT_SHOW_DEFAULT_NAMESPACE  true
set_default -a  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS                context dir vcs
set_default -i  POWERLEVEL9K_LOAD_WHICH                          5
set_default -i  POWERLEVEL9K_MAX_CACHE_SIZE                      10000
set_default     POWERLEVEL9K_MODE                                ""
set_default     POWERLEVEL9K_PROMPT_ADD_NEWLINE                  false
set_default     POWERLEVEL9K_PROMPT_ON_NEWLINE                   false
set_default     POWERLEVEL9K_PUBLIC_IP_HOST                      "http://ident.me"
set_default -a  POWERLEVEL9K_PUBLIC_IP_METHODS                   dig curl wget
set_default     POWERLEVEL9K_PUBLIC_IP_NONE                      ""
set_default -i  POWERLEVEL9K_PUBLIC_IP_TIMEOUT                   300
set_default     POWERLEVEL9K_PUBLIC_IP_VPN_INTERFACE             ""
set_default     POWERLEVEL9K_PYENV_PROMPT_ALWAYS_SHOW            false
set_default     POWERLEVEL9K_RBENV_PROMPT_ALWAYS_SHOW            false
set_default -a  POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS               status root_indicator background_jobs history time
set_default     POWERLEVEL9K_RPROMPT_ON_NEWLINE                  false
set_default     POWERLEVEL9K_SHORTEN_FOLDER_MARKER               "(.shorten_folder_marker|.bzr|CVS|.git|.hg|.svn|.terraform|.citc)"
set_default     POWERLEVEL9K_SHORTEN_STRATEGY                    ""
set_default     POWERLEVEL9K_SHOW_CHANGESET                      false
set_default     POWERLEVEL9K_SHOW_RULER                          false
set_default     POWERLEVEL9K_STATUS_CROSS                        false
set_default     POWERLEVEL9K_STATUS_HIDE_SIGNAME                 false
set_default     POWERLEVEL9K_STATUS_OK_IN_NON_VERBOSE            false
set_default     POWERLEVEL9K_STATUS_OK                           true
set_default     POWERLEVEL9K_STATUS_SHOW_PIPESTATUS              true
set_default     POWERLEVEL9K_STATUS_VERBOSE                      true
set_default     POWERLEVEL9K_TIME_FORMAT                         "%D{%H:%M:%S}"
set_default     POWERLEVEL9K_USER_TEMPLATE                       "%n"
set_default     POWERLEVEL9K_VCS_ACTIONFORMAT_FOREGROUND         red
set_default -a  POWERLEVEL9K_VCS_BACKENDS                        git
set_default -i  POWERLEVEL9K_VCS_COMMITS_AHEAD_MAX_NUM           -1
set_default -i  POWERLEVEL9K_VCS_COMMITS_BEHIND_MAX_NUM          -1
set_default -a  POWERLEVEL9K_VCS_GIT_HOOKS                       vcs-detect-changes git-untracked git-aheadbehind git-stash git-remotebranch git-tagname
set_default -a  POWERLEVEL9K_VCS_HG_HOOKS                        vcs-detect-changes
set_default     POWERLEVEL9K_VCS_HIDE_TAGS                       false
set_default -i  POWERLEVEL9K_VCS_INTERNAL_HASH_LENGTH            8
set_default     POWERLEVEL9K_VCS_LOADING_TEXT                    loading
set_default -i  POWERLEVEL9K_VCS_MAX_INDEX_SIZE_DIRTY            -1
set_default -F  POWERLEVEL9K_VCS_MAX_SYNC_LATENCY_SECONDS        0.05
set_default     POWERLEVEL9K_VCS_SHOW_SUBMODULE_DIRTY            false
set_default -i  POWERLEVEL9K_VCS_STAGED_MAX_NUM                  1
set_default -a  POWERLEVEL9K_VCS_SVN_HOOKS                       vcs-detect-changes  svn-detect-changes
set_default -i  POWERLEVEL9K_VCS_UNSTAGED_MAX_NUM                1
set_default -i  POWERLEVEL9K_VCS_UNTRACKED_MAX_NUM               1
set_default     POWERLEVEL9K_VI_COMMAND_MODE_STRING              "NORMAL"
set_default     POWERLEVEL9K_VI_INSERT_MODE_STRING               "INSERT"
set_default     POWERLEVEL9K_VPN_IP_INTERFACE                    "tun"
set_default     POWERLEVEL9K_WHITESPACE_BETWEEN_LEFT_SEGMENTS    " "
set_default     POWERLEVEL9K_WHITESPACE_BETWEEN_RIGHT_SEGMENTS   " "

#set_default     POWERLEVEL9K_BATTERY_STAGES
#set_default     POWERLEVEL9K_CHANGESET_HASH_LENGTH
#set_default     POWERLEVEL9K_DIR_PATH_HIGHLIGHT_FOREGROUND
#set_default     POWERLEVEL9K_GITSTATUS_DIR
#set_default     POWERLEVEL9K_KUBECONTEXT_BACKGROUND
#set_default     POWERLEVEL9K_KUBECONTEXT_CLASSES
#set_default     POWERLEVEL9K_KUBECONTEXT_FOREGROUND
#set_default     POWERLEVEL9K_KUBECONTEXT_OTHER_BACKGROUND
#set_default     POWERLEVEL9K_KUBECONTEXT_PROD_BACKGROUND
#set_default     POWERLEVEL9K_KUBECONTEXT_TESTING_BACKGROUND
#set_default     POWERLEVEL9K_PROMPT_ADD_NEWLINE_COUNT
#set_default     POWERLEVEL9K_RULER_CHAR
#set_default     POWERLEVEL9K_SHORTEN_DELIMITER
#set_default     POWERLEVEL9K_SHORTEN_DELIMITER_LENGTH
#set_default     POWERLEVEL9K_SHORTEN_DIR_LENGTH
#set_default     POWERLEVEL9K_VCS_MAX_NUM_STAGED
#set_default     POWERLEVEL9K_VCS_MAX_NUM_UNSTAGED
#set_default     POWERLEVEL9K_VCS_MAX_NUM_UNTRACKED
#set_default     POWERLEVEL9K_VCS_SHORTEN_DELIMITER
#set_default     POWERLEVEL9K_VCS_SHORTEN_LENGTH                 ""
#set_default     POWERLEVEL9K_VCS_SHORTEN_MIN_LENGTH             ""
## POWERLEVEL9K_VCS_SHORTEN_STRATEGY truncate_middle or truncate_from_right
#set_default     POWERLEVEL9K_VCS_SHORTEN_STRATEGY               ""
#set_default     POWERLEVEL9K_VI_VISUAL_MODE_STRING              ""
