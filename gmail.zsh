URL="https://mail.google.com/mail/feed/atom"

gmail () {
  case "$1" in
    show)
      gmail_show $2
      ;;
    count)
      gmail_count
      ;;
    *)
      gmail_ls
      ;;
  esac
}

gmail_ls () {
  ls=$(curl -u $GMAIL_USERNAME:$GMAIL_PASSWORD --silent $URL | awk 'BEGIN{FS="\n";RS="(</entry>\n)?<entry>"}NR!=1{print "from:", $9, "title:", $2}' | sed -e 's,<[^>]*>,,g' | column -t -s $'\t' | nl)
  echo $ls
}

gmail_show () {
  number=$1
  show=$(curl -u $GMAIL_USERNAME:$GMAIL_PASSWORD --silent $URL | awk '/^<summary>/' | sed "s/<summary>//" | sed 's/<\/summary>//' | sed -n ${number}p)
  echo $show
}

gmail_count () {
  count=$(curl -u $GMAIL_USERNAME:$GMAIL_PASSWORD --silent $URL | awk '/^<fullcount>/' | sed "s/<fullcount>//" | sed 's/<\/fullcount>//')
  echo $count
}

_gmail () {
  local curcontext="$curcontext" state line
  typeset -A opt_args

  _arguments \
    '1: :->cmds' \
    '*: :->mail_list'

  case $state in
    cmds)
      _arguments '1:Cmds:(ls show count)'
      ;;
    *)
      case $words[2] in
        show)
          _mails=( $(gmail_ls | awk '{print $1}') )
          if [[ $_mails != "" ]]; then
            _values 'mails' $_mails && ret=0
          fi
          ;;
      esac
  esac
}

compdef _gmail gmail
