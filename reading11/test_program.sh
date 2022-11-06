#!/bin/bash

output() {
    cat <<EOF | base64 -d
L2Rldi9tZDEyNwpleHQ0CnJhaWQxCjMyRwozNTM5MDEyCjE0MzIyNAo=
EOF
}

echo "Testing reading11 program ... "

DIFF=$(diff <(./program 2> /dev/null) <(output) | grep -E "^[><]" | wc -l)
COUNT=$(output | wc -l)
SCORE=$(python3 <<EOF
print("{:0.2f} / 3.00".format(($COUNT - $DIFF) * 3.0 / $COUNT.0))
EOF
)

echo "   Score $SCORE"

if [ "$DIFF" -eq 0 ]; then
    echo "  Status Success"
else
    echo "  Status Failure"
fi

echo
exit $DIFF
