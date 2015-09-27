#!/bin/sh
CMDNAME=`basename $0`
if [ $# -lt 1 ]; then
    echo "Usage: $CMDNAME file ..." 1>&2
    exit 1
fi

echo "#!/bin/sh"
echo "# This is a shell archive; to unpack:"
echo "# 1. Remove everything before the \"#!/bin/sh\"."
echo "# 2. Save the rest of the archive."
echo "# 3. Execute the archive by entering \"sh archive\"."
echo "#"
echo "#This archive contains the following files:"
echo "#"

for FILE; do
    echo "#     $FILE"
done

for FILE; do
    echo ""
    echo "if [ -f $FILE ]; then"
    echo "    echo The file $FILE already exists."
    echo "else"
    echo "    echo Extracting $FILE"
    echo "    sed 's/^X//' > $FILE << \EOF"
    sed 's/^/X/' < $FILE
    echo "EOF"
    echo "fi"
done
echo "exit 0"
exit 0
