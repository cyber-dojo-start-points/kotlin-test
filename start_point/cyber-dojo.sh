# Kotest specs are discovered by scanning the compiled classes. Selecting by
# package finds the engine but none of its tests, so the classpath is scanned.

CLASSES=.:`ls /kotlin/*.jar | tr '\n' ':'`
LAUNCHER=`ls /kotlin/junit-platform-console-standalone-*.jar`

# The compiler is started directly rather than through the kotlinc script. That
# script runs the compiler behind a Preloader, which loads it through a
# classloader of its own, and an AOT cache recorded for that arrangement is
# slower than no cache at all. Started this way the compiler's classes come off
# the classpath, where the cache can reach them.
COMPILER_JAR=/usr/share/kotlin/kotlinc/lib/kotlin-compiler.jar
COMPILER_MAIN=org.jetbrains.kotlin.cli.jvm.K2JVMCompiler

# Both JVMs below read something the image recorded at build time instead of
# doing the same work on every run. Nothing is lost when either is missing or
# unusable: the JVM says so and does the work itself, and the run is slower.
#
# The collector is named rather than left to the JVM to choose. Replaying the
# AOT cache under the one it picks by default kills the compiler outright with
# SIGILL, five runs in six, and a compiler that dies before printing anything
# leaves no summary line, so every kata scores amber whatever its tests did.
# A JVM that lives for half a second has nothing to gain from a concurrent
# collector in any case.
COMPILER_OPTS=()
COMPILER_OPTS+=(-XX:AOTCache=/kotlin/kotlinc.aot)          # the compiler's own classes, linked
COMPILER_OPTS+=(-XX:+UseSerialGC)                          # see below; the default one crashes replaying the cache
COMPILER_OPTS+=(-XX:TieredStopAtLevel=1)                   # still ahead even over a half-second compile
COMPILER_OPTS+=(-Xlog:cds*=off)                            # a JVM that cannot use it says so on stdout
COMPILER_OPTS+=(-Xlog:aot*=off)                            # as above, for the aot cache
COMPILER_OPTS+=(--enable-native-access=ALL-UNNAMED)        # the kotlinc script passes this on jdk 24+
COMPILER_OPTS+=(--sun-misc-unsafe-memory-access=allow)     # as above

# The test JVM keeps its class-data archive. An AOT cache was measured here too
# and came out level with it, so there is nothing to gain by changing it.
TEST_OPTS=()
TEST_OPTS+=(-XX:TieredStopAtLevel=1)
TEST_OPTS+=(-XX:SharedArchiveFile=/kotlin/junit.jsa)
TEST_OPTS+=(-Xlog:cds*=off)

# Every .kt file is compiled, including ones in sub-directories and ones
# nothing else refers to yet, so a file you are midway through writing shows
# its errors instead of being silently skipped.
java "${COMPILER_OPTS[@]}" -cp "${COMPILER_JAR}" "${COMPILER_MAIN}" \
  `find . -name '*.kt'` -cp $CLASSES -d .
compiled=$?
if [ $compiled -ne 0 ]; then
  exit $compiled
fi

# By default you get a _large_ stack-trace when tests fail. Only the frames
# naming the dojo package are kept, so the failing line in your own file
# survives and the test engine's frames do not.
java "${TEST_OPTS[@]}" \
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
