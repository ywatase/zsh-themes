KOMACHI_BRACKET_COLOR="%{$fg[white]%}"
KOMACHI_AWSENV_COLOR="%{$fg[yellow]%}"
KOMACHI_MKRENV_COLOR="%{$fg[cyan]%}"
KOMACHI_RVM_COLOR="%{$fg[magenta]%}"
KOMACHI_PYENV_COLOR="%{$fg[magenta]%}"
KOMACHI_PLENV_COLOR="%{$fg[magenta]%}"
KOMACHI_PERL_LOCALLIB_COLOR="%{$fg[magenta]%}"
KOMACHI_DIR_COLOR="%{$fg[cyan]%}"
KOMACHI_GIT_BRANCH_COLOR="%{$fg[green]%}"
KOMACHI_GIT_CLEAN_COLOR="%{$fg[green]%}"
KOMACHI_GIT_DIRTY_COLOR="%{$fg[red]%}"

# These Git variables are used by the oh-my-zsh git_prompt_info helper:
ZSH_THEME_GIT_PROMPT_PREFIX="$KOMACHI_BRACKET_COLOR:$KOMACHI_GIT_BRANCH_COLOR"
ZSH_THEME_GIT_PROMPT_SUFFIX=""
ZSH_THEME_GIT_PROMPT_CLEAN=" $KOMACHI_GIT_CLEAN_COLOR✓"
ZSH_THEME_GIT_PROMPT_DIRTY=" $KOMACHI_GIT_DIRTY_COLOR✗"

# Our elements:
_get_aws_profile () {
	echo $AWS_PROFILE
}

_get_mackerel_profile () {
	echo $MACKEREL_PROFILE
}

_get_pythonversion () {
	local pythonversion
	if which pyenv &> /dev/null; then
		pythonversion=$(pyenv version | sed -e 's/ (set.*$//' -e 's/^python-//')
	fi
	echo $pythonversion
}

_get_rubyversion () {
	local rubyversion
	if [ -e ~/.rvm/bin/rvm-prompt ]; then
		rubyversion=${$(~/.rvm/bin/rvm-prompt i v g)#ruby-}
	else
		if which rbenv &> /dev/null; then
			rubyversion=$(rbenv version | sed -e 's/ (set.*$//' -e 's/^ruby-//')
		fi
	fi
	echo $rubyversion
}

_get_perlversion () {
	local perlversion
	local perlpath
	perlpath=$(which perl)
	if [[ "$perlpath" =~ "plenv" ]] ; then
		perlversion=$(plenv version | sed -e 's/ (set.*$//')
	elif [[ "$perlpath" =~ "perlbrew" ]] ; then
		perlversion=$(perlbrew use | sed -e 's/^Currently using //' -e 's/^perl-//')
	else
		perlversion=$(perl -e 'use version; print version->parse($])->normal' 2>/dev/null || perl -e 'print $]')
  fi
	echo $perlversion
}
_get_perllocallib () {
	local perllocallib
	if [[ -n "$PERL_LOCAL_LIB_ROOT" ]] ; then
		perllocallib=$(perl -MFile::Spec::Functions=abs2rel -le '($a = shift) =~s/\A:+//msx;print abs2rel($a)' $PERL_LOCAL_LIB_ROOT)
		echo "%{$reset_color%}|llib:${KOMACHI_PERL_LOCALLIB_COLOR}$perllocallib"
	fi
}

_is_enough_term_width () {
	if [[ $COLUMNS > 200 ]] ; then
		true
	else
		false
	fi
}

_get_prompt () {
	local KOMACHI_DIR_ KOMACHI_HOST_ KOMACHI_PROMPT

	KOMACHI_DIR_="$KOMACHI_DIR_COLOR%~${$(git_prompt_info)}%{$reset_color%} "
	KOMACHI_HOST_='%n@%m:'
	KOMACHI_PROMPT_="
%(?,%{$fg[green]%}(^_^%)%{$reset_color%},%{$fg[red]%}(T^T%)%{$reset_color%}) \$%{$reset_color%} "

	if _is_enough_term_width ; then
		_get_mkrenv
		_get_awsenv
		_get_plenv
		_get_rbenv
		_get_pyenv
		echo "$KOMACHI_HOST_$KOMACHI_MKRENV_$KOMACHI_AWSENV_$KOMACHI_PLENV_$KOMACHI_RVM_$KOMACHI_PYENV_:$KOMACHI_DIR_$KOMACHI_PROMPT_"
	else
		echo "$KOMACHI_HOST_$KOMACHI_DIR_$KOMACHI_PROMPT_"
	fi
}

_get_rprompt () {
	if ! _is_enough_term_width ; then
		_get_mkrenv
		_get_awsenv
		_get_plenv
		_get_rbenv
		_get_pyenv
		echo "$KOMACHI_MKRENV_$KOMACHI_AWSENV_$KOMACHI_PLENV_$KOMACHI_RVM_$KOMACHI_PYENV_"
	fi
}

_get_mkrenv () {
  if [[ "$MACKEREL_PROFILE" != "" ]] ; then
		KOMACHI_MKRENV_="$KOMACHI_BRACKET_COLOR"[mkr:"$KOMACHI_MKRENV_COLOR${$(_get_mackerel_profile)}$KOMACHI_BRACKET_COLOR"]"%{$reset_color%}"
	else
		KOMACHI_MKRENV_=
	fi
}

_get_awsenv () {
  if [[ "$AWS_PROFILE" != "" ]] ; then
		KOMACHI_AWSENV_="$KOMACHI_BRACKET_COLOR"[aws:"$KOMACHI_AWSENV_COLOR${$(_get_aws_profile)}$KOMACHI_BRACKET_COLOR"]"%{$reset_color%}"
	else
		KOMACHI_AWSENV_=
	fi
}

_get_plenv () {
  if [[ "$(_get_perlversion)" != "" ]] ; then
	  KOMACHI_PLENV_="$KOMACHI_BRACKET_COLOR"[pl:"$KOMACHI_PLENV_COLOR${$(_get_perlversion)}${$(_get_perllocallib)}$KOMACHI_BRACKET_COLOR"]"%{$reset_color%}"
	else
		KOMACHI_PLENV_=
  fi
}

_get_rbenv () {
	if [[ "$(_get_rubyversion)" != "" ]] ; then
		KOMACHI_RVM_="$KOMACHI_BRACKET_COLOR"[rb:"$KOMACHI_RVM_COLOR${$(_get_rubyversion)}$KOMACHI_BRACKET_COLOR"]"%{$reset_color%}"
	else
		KOMACHI_RVM_=
	fi
}

_get_pyenv () {
	if [[ "$(_get_pythonversion)" != "" ]] ; then
		KOMACHI_PYENV_="$KOMACHI_BRACKET_COLOR"[py:"$KOMACHI_PYENV_COLOR${$(_get_pythonversion)}$KOMACHI_BRACKET_COLOR"]"%{$reset_color%}"
	else
		KOMACHI_PYENV_=
	fi
}

# Put it all together!
PROMPT="\${\$(_get_prompt)}"
RPROMPT="\${\$(_get_rprompt)}"

# vim:ft=zsh si ts=2 sw=2 sts=2:
