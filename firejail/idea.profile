caps.drop all

include allow-common-devel.inc
include allow-ssh.inc
include disable-common.inc
include disable-programs.inc
include globals.local
include idea.sh.local

netfilter

noblacklist ${HOME}/.android
noblacklist ${HOME}/.config/JetBrains
noblacklist ${HOME}/.gradle
noblacklist ${HOME}/.idea
noblacklist ${HOME}/.IdeaIC*
noblacklist ${HOME}/.ideavimrc
noblacklist ${HOME}/.ivy2
noblacklist ${HOME}/.jack-server
noblacklist ${HOME}/.jack-settings
noblacklist ${HOME}/.java
noblacklist ${HOME}/.jdk
noblacklist ${HOME}/.local/share/JetBrains
noblacklist ${HOME}/.m2
noblacklist ${HOME}/.sbt
noblacklist ${HOME}/.tooling
noblacklist ${HOME}/src
noblacklist ${HOME}/work

nodvd
noexec /tmp
nogroups
noinput
nonewprivs
noroot
notv
nou2f
novideo
private-cache
private-dev
private-tmp
protocol unix,inet,inet6
restrict-namespaces

seccomp
