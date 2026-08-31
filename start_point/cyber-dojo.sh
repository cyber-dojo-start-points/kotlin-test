# Kotest specs are discovered by scanning the compiled classes. Selecting by
# package finds the engine but none of its tests, so the classpath is scanned.

CLASSES=.:`ls /kotlin/*.jar | tr '\n' ':'`
LAUNCHER=`ls /kotlin/junit-platform-console-standalone-*.jar`

# Both JVMs below replay a class-data archive the image dumped at build time,
# which is most of what they would otherwise spend their time doing: a fresh
# container loads every class from the jars again. cds logging is off because a
# JVM that cannot use an archive says so on stdout, and that belongs in a build
# log rather than in front of whoever is doing the kata. Nothing is lost when an
# archive cannot be used; the run is only slower.
readonly CDS_COMPILER='-XX:SharedArchiveFile=/kotlin/kotlinc.jsa -Xlog:cds*=off'
readonly CDS_TESTS='-XX:SharedArchiveFile=/kotlin/junit.jsa -Xlog:cds*=off'

# Every .kt file is compiled, including ones in sub-directories and ones
# nothing else refers to yet, so a file you are midway through writing shows
# its errors instead of being silently skipped.
#
# The compiler runs in a JVM of its own. A kata holds few enough files that the
# JVM never runs long enough to profit from its optimising compiler, so it is
# told to stop at the quick one, the same way the test JVM below is.
JAVA_OPTS="-XX:TieredStopAtLevel=1 ${CDS_COMPILER}" kotlinc `find . -name '*.kt'` -cp $CLASSES
compiled=$?
if [ $compiled -ne 0 ]; then
  exit $compiled
fi

# By default you get a _large_ stack-trace when tests fail. Only the frames
# naming the dojo package are kept, so the failing line in your own file
# survives and the test engine's frames do not.
java -XX:TieredStopAtLevel=1 \
  ${CDS_TESTS} \
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
