#!/bin/bash

WORKSPACE=/tmp/reading02.$(id -u)
FAILURES=0

case $(uname) in
Darwin)
    SHA1SUM=shasum
    ;;
*)
    SHA1SUM=sha1sum
    ;;
esac

error() {
    echo "$@"
    [ -r $WORKSPACE/test ] && (echo; cat $WORKSPACE/test; echo)
    FAILURES=$((FAILURES + 1))
}

cleanup() {
    STATUS=${1:-$FAILURES}
    rm -fr $WORKSPACE

    if [ "$STATUS" -eq 0 ]; then
	echo "  Status Success"
    else
	echo "  Status Failure"
    fi

    echo
    exit $STATUS
}

grep_all() {
    for pattern in $1; do
	if ! grep -q -E "$pattern" $2; then
	    echo "FAILURE: Missing '$pattern' in '$2'" > $WORKSPACE/test
	    return 1;
	fi
    done
    return 0;
}

grep_any() {
    for pattern in $1; do
	if grep -q -E "$pattern" $2; then
	    echo "FAILURE: Contains '$pattern' in '$2'" > $WORKSPACE/test
	    return 1;
	fi
    done
    return 0;
}


mkdir $WORKSPACE

trap "cleanup" EXIT
trap "cleanup 1" INT TERM

echo "Testing reading02 program..."


printf " %-60s ... " "I/O System Calls"
if ! grep_all "open read close" program.c; then
    error "Failure"
else
    echo "Success"
fi


printf " %-60s ... " "I/O Functions"
if ! grep_any "fopen fread fclose popen" program.c; then
    error "Failure"
else
    echo "Success"
fi


printf " %-60s ... " "Memory Functions"
if ! grep_all "malloc free" program.c; then
    error "Failure"
else
    echo "Success"
fi


printf " %-60s ... " "SHA1 Functions"
if ! grep_all "SHA1" program.c || ! grep_any "SHA1_Init SHA1_Update SHA1_Final" program.c; then
    error "Failure"
else
    echo "Success"
fi

printf " %-60s ... " "program"
./program &> $WORKSPACE/test
if [ $? -ne 0 ]; then
    error "Failure"
else
    echo "Success"
fi

printf " %-60s ... " "program (valgrind)"
valgrind --leak-check=full ./program &> $WORKSPACE/test
if [ $? -ne 0 ] || [ $(awk '/ERROR SUMMARY:/ {print $4}' $WORKSPACE/test) -ne 0 ]; then
    error "Failure"
else
    echo "Success"
fi


ARGUMENTS="Makefile"
printf " %-60s ... " "program $ARGUMENTS"
diff -u <($SHA1SUM $ARGUMENTS) <(./program $ARGUMENTS) &> $WORKSPACE/test
if [ $? -ne 0 ]; then
    error "Failure"
else
    echo "Success"
fi

printf " %-60s ... " "program $ARGUMENTS (valgrind)"
valgrind --leak-check=full ./program $ARGUMENTS &> $WORKSPACE/test
if [ $? -ne 0 ] || [ $(awk '/ERROR SUMMARY:/ {print $4}' $WORKSPACE/test) -ne 0 ]; then
    error "Failure"
else
    echo "Success"
fi


ARGUMENTS="Makefile README.md"
printf " %-60s ... " "program $ARGUMENTS"
diff -u <($SHA1SUM $ARGUMENTS) <(./program $ARGUMENTS) &> $WORKSPACE/test
if [ $? -ne 0 ]; then
    error "Failure"
else
    echo "Success"
fi

printf " %-60s ... " "program $ARGUMENTS (valgrind)"
valgrind --leak-check=full ./program $ARGUMENTS &> $WORKSPACE/test
if [ $? -ne 0 ] || [ $(awk '/ERROR SUMMARY:/ {print $4}' $WORKSPACE/test) -ne 0 ]; then
    error "Failure"
else
    echo "Success"
fi


ARGUMENTS="Makefile README.md program.c"
printf " %-60s ... " "program $ARGUMENTS"
diff -u <($SHA1SUM $ARGUMENTS) <(./program $ARGUMENTS) &> $WORKSPACE/test
if [ $? -ne 0 ]; then
    error "Failure"
else
    echo "Success"
fi

printf " %-60s ... " "program $ARGUMENTS (valgrind)"
valgrind --leak-check=full ./program $ARGUMENTS &> $WORKSPACE/test
if [ $? -ne 0 ] || [ $(awk '/ERROR SUMMARY:/ {print $4}' $WORKSPACE/test) -ne 0 ]; then
    error "Failure"
else
    echo "Success"
fi


ARGUMENTS="Makefile README.md program.c asdf"
printf " %-60s ... " "program $ARGUMENTS"
diff -u <($SHA1SUM $ARGUMENTS 2> /dev/null) <(./program $ARGUMENTS) &> $WORKSPACE/test
if [ $? -ne 0 ]; then
    error "Failure"
else
    echo "Success"
fi

printf " %-60s ... " "program $ARGUMENTS (valgrind)"
valgrind --leak-check=full ./program $ARGUMENTS &> $WORKSPACE/test
if [ $? -ne 1 ] || [ $(awk '/ERROR SUMMARY:/ {print $4}' $WORKSPACE/test) -ne 0 ]; then
    echo "Exit Status: $?" >> $WORKSPACE/test
    error "Failure"
else
    echo "Success"
fi


ARGUMENTS="Makefile README.md /bin/ls /bin/bash"
printf " %-60s ... " "program $ARGUMENTS"
diff -u <($SHA1SUM $ARGUMENTS 2> /dev/null) <(./program $ARGUMENTS) &> $WORKSPACE/test
if [ $? -ne 0 ]; then
    error "Failure"
else
    echo "Success"
fi

printf " %-60s ... " "program $ARGUMENTS (valgrind)"
valgrind --leak-check=full ./program $ARGUMENTS &> $WORKSPACE/test
if [ $? -ne 0 ] || [ $(awk '/ERROR SUMMARY:/ {print $4}' $WORKSPACE/test) -ne 0 ]; then
    echo "Exit Status: $?" >> $WORKSPACE/test
    error "Failure"
else
    echo "Success"
fi


TESTS=$(($(grep -c Success $0) - 1))
SCORE=$(python3 <<EOF
print("{:0.2f} / 3.00".format(($TESTS - $FAILURES) * 3.0 / $TESTS))
EOF
)
echo "   Score $SCORE"
