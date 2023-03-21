''
  enable-proxy() {
    PROXY_HOST="localhost"
    PROXY_PORT="7890"

    export HTTP_PROXY="http://$PROXY_HOST:$PROXY_PORT/"
    export http_proxy="$HTTP_PROXY"

    export HTTPS_PROXY="http://$PROXY_HOST:$PROXY_PORT/"
    export https_proxy="$HTTPS_PROXY"

    export NO_PROXY="localhost, 127.0.0.0/8, ::1"
    export no_proxy="$NO_PROXY"

    echo "HTTP Proxy Enabled!"
  }

  disable-proxy() {
    unset HTTP_PROXY http_proxy
    unset HTTPS_PROXY https_proxy
    unset NO_PROXY no_proxy

    echo "HTTP Proxy Disabled!"
  }

  deploy() {
    nixos-rebuild --target-host deploy@"$1" --flake $MYOS_FLAKE#"$1" --use-remote-sudo switch
  }

  deploy-remote() {
    nixos-rebuild --build-host deploy@"$1" --target-host deploy@"$1" --flake $MYOS_FLAKE#"$1" --use-remote-sudo switch
  }
''
