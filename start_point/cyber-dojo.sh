# [X] See hard-wired-test-name.txt

CLASSES=.:`ls /usr/share/kotlin/kotlinc/lib/*.jar | tr '\n' ':'`
CLASSES=`ls /kotlin/*.jar | tr '\n' ':'`${CLASSES}
kotlinc *.kt -include-runtime -cp $CLASSES
EXECUTE_TEST="java -cp $CLASSES io.kotlintest.runner.console.LauncherKt --writer basic --spec hiker.HikerTest"
if [ $? -eq 0 ]; then
   $EXECUTE_TEST | sed 's/\x1b\[[0-9;]*m//g'
fi
