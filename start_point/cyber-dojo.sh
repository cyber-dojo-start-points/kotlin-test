# [X] See hard-wired-test-name.txt

CLASSES=.:`ls /usr/share/kotlin/kotlinc/lib/*.jar | tr '\n' ':'`
CLASSES=`ls /kotlin/*.jar | tr '\n' ':'`${CLASSES}
kotlinc *.kt -include-runtime -cp $CLASSES
if [ $? -eq 0 ]; then
  java -cp $CLASSES \
    io.kotest.engine.launcher.MainKt \
    --spec hiker.HikerTest \
    --termcolor true
    # [X]
fi
