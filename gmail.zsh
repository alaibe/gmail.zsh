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
  echo "Inbox for $GMAIL_USERNAME, you have $(_gmail_count) unread emails"

  ls=$(_gmail_fetch | tr -d '\n' | awk -F '<entry>' '{for (i=2; i<=NF; i++) {print $i}}' | sed -n "s/<title>\(.*\)<\/title.*name>\(.*\)<\/name>.*/\2 - \1/p")
  echo $ls
}

gmail_show () {
  number=$1
  show=$(_gmail_fetch | awk '/^<summary>/' | sed "s/<summary>//" | sed 's/<\/summary>//' | sed -n ${number}p)
  echo $show
}

_gmail_count () {
  _gmail_fetch | awk '/^<fullcount>/' | sed "s/<fullcount>//" | sed 's/<\/fullcount>//'
}

_gmail_fetch () {
  curl -u $GMAIL_USERNAME:$GMAIL_PASSWORD --silent $URL
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
