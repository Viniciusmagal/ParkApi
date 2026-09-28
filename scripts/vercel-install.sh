set -e
if [ ! -x "$HOME/flutter/bin/flutter" ]; then
  git clone https://github.com/flutter/flutter.git --branch stable --depth 1 "$HOME/flutter"
fi
"$HOME/flutter/bin/flutter" config --no-analytics
"$HOME/flutter/bin/flutter" --version
