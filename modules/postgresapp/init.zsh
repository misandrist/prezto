#
# Enables binaries and compiling with Postgress.app
#
# Authors:
#   Evan Cofsky <evan@theunixman.com>
#

if [[ -d /Applications/Postgres.app/Contents/Versions/9.4/bin ]]; then
   path=(/Applications/Postgres.app/Contents/Versions/9.4/bin $path)
fi
