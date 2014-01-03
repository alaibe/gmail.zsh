URL="https://mail.google.com/mail/feed/atom"

gmail () {
  if [ -z "$1" ]
  then
    gmail_ls
  else
    open $1
  fi
}

gmail_ls () {
  echo "Inbox for $GMAIL_USERNAME, you have $(_gmail_count) unread emails"

  res=$((_gmail_header; _gmail_fetch | _gmail_catch_entry) | column -t -s '|')
  echo $res
}

_gmail_count () {
  _gmail_fetch | awk '/^<fullcount>/' | sed "s/<fullcount>//" | sed 's/<\/fullcount>//'
}

_gmail_fetch () {
  curl -u $GMAIL_USERNAME:$GMAIL_PASSWORD --silent $URL
}

_gmail_header () {
  printf "SUBJECT|AUTHOR|RECEIVED|SUMMARY\n"
}

_gmail_catch_entry () {
  tr -d '\n' | awk -F '<entry>' '{for (i=2; i<=NF; i++) {print $i}}' | _gmail_format_entry
}

_gmail_format_entry () {
  awk -F'[<|>]' '/title/{printf "%s|%s (%s)|%s|%s\n",$3, $27, $31, $17, $7 }'
}

_gmail () {
  local curcontext="$curcontext" state line
  typeset -A opt_args

  _arguments \
    '*: :->gmail_ls'

  case $state in
    gmail_ls)
      _mails=( $(gmail_ls) )
        if [[ $_mails != "" ]]; then
          _values 'mails' $_mails && ret=0
        fi
        ;;
  esac
}

compdef _gmail gmail
