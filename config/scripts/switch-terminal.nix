{}:
''
  if ! swaymsg "[app_id=xfce4-terminal title="^sticky"] focus";
    then swaymsg "exec xfce4-terminal --initial-title=sticky;";
  fi
''
