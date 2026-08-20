# Kotest specs are discovered by scanning the compiled classes. Selecting by
# package finds the engine but none of its tests, so the classpath is scanned.

CLASSES=.:`ls /kotlin/*.jar | tr '\n' ':'`
LAUNCHER=`ls /kotlin/junit-platform-console-standalone-*.jar`

# Every .kt file is compiled, including ones in sub-directories and ones
# nothing else refers to yet, so a file you are midway through writing shows
# its errors instead of being silently skipped.
kotlinc `find . -name '*.kt'` -cp $CLASSES
compiled=$?
if [ $compiled -ne 0 ]; then
  exit $compiled
fi

# By default you get a _large_ stack-trace when tests fail. Only the frames
# naming the dojo package are kept, so the failing line in your own file
# survives and the test engine's frames do not.
java -XX:TieredStopAtLevel=1 \
  -jar $LAUNCHER \
  execute \
  --class-path $CLASSES \
  --scan-classpath . \
  --details=summary \
  --disable-ansi-colors \
  2>&1 | awk '/^[ \t]+[A-Za-z_][A-Za-z0-9_.$]*\(/ { if ($0 ~ /^[ \t]+dojo\./) print; next } { print }'

# awk exits zero even when the run it filters failed, so the status of the
# tests themselves has to come from PIPESTATUS.
exit ${PIPESTATUS[0]}
