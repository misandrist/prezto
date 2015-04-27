pgversions=/Applications/Postgres.app/Contents/Versions

if [ -d $pgversions ]; then
    version=$(ls $pgversions | sort | tail -1)
    path=($pgversions/$version/bin(/N) $path)
fi

unset version pgversions
