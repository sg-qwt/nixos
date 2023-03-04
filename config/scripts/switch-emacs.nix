{}:
''
  if [[ -n $(pidof -x emacs) ]];
    then swaymsg "[app_id=emacs] focus";
    else swaymsg "exec emacs;";
  fi
''
