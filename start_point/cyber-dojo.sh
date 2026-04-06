# We are using the "--package dojo" flag so Kotest will
# discover and run all test classes in that package.
# All test classes must be in the dojo package.

CLASSES=.:`ls /usr/share/kotlin/kotlinc/lib/*.jar | tr '\n' ':'`
CLASSES=`ls /kotlin/*.jar | tr '\n' ':'`${CLASSES}
kotlinc *.kt -include-runtime -cp $CLASSES
if [ $? -eq 0 ]; then
  # By default you get a _large_ stack-trace when tests fail. 
  # The grep filters stack-trace lines eg "  some.Class.method(File.kt:42)"
  java -XX:TieredStopAtLevel=1 \
    -Dkotest.framework.disableTestNestedJarScanning=true \
    -Dkotest.framework.classpath.scanning.autoscan.disable=true \
    -cp $CLASSES \
    io.kotest.engine.launcher.MainKt \
    --package dojo \
    --termcolor false \
    2>&1 | grep -vE '^[[:space:]]+[[:alnum:]_][[:alnum:]_.$]*\('
fi
