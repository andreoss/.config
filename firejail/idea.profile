include idea.sh.local
include globals.local

noblacklist ${HOME}/.config/JetBrains
noblacklist ${HOME}/.idea
noblacklist ${HOME}/.ideavimrc
noblacklist ${HOME}/.android
noblacklist ${HOME}/.local/share/JetBrains
noblacklist ${HOME}/.tooling
noblacklist ${HOME}/.m2
noblacklist ${HOME}/.java
noblacklist ${HOME}/.ivy2
noblacklist ${HOME}/.jdk
noblacklist ${HOME}/.sbt
noblacklist ${HOME}/.gradle
noblacklist ${HOME}/src
noblacklist ${HOME}/work

include disable-programs.inc

caps.drop all
netfilter
nodvd
nogroups
nonewprivs
noroot
notv
nou2f
novideo
protocol unix,inet,inet6
seccomp

private-cache
private-dev
private-tmp

noexec /tmp
