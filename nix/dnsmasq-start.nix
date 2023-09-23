{ writeShellScriptBin
}:
writeShellScriptBin "dnsmasq-start" ''
  sudo dnsmasq \
    --server='/*/8.8.8.8' \
    --address='/*.code.test/127.0.0.1' \
    --address '/*.code.supply/81.187.237.24'
''
