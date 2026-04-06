# [X] See please-help.txt

CLASSES=.:`ls /usr/share/kotlin/kotlinc/lib/*.jar | tr '\n' ':'`
CLASSES=`ls /kotlin/*.jar | tr '\n' ':'`${CLASSES}
kotlinc *.kt -include-runtime -cp $CLASSES
if [ $? -eq 0 ]; then
  # grep filters stack-trace lines eg "  some.Class.method(File.kt:42)"
  java -XX:TieredStopAtLevel=1 \
    -Dkotest.framework.disableTestNestedJarScanning=true \
    -Dkotest.framework.classpath.scanning.autoscan.disable=true \
    -cp $CLASSES \
    io.kotest.engine.launcher.MainKt \
    --spec hiker.HikerTest \
    --termcolor false \
    2>&1 | grep -vE '^[[:space:]]+[[:alnum:]_][[:alnum:]_.$]*\('
    # [X]
fi
