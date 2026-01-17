#!/usr/bin/env bash

echo "Testing input..."
echo "Please enter a number (1-7):"
read -p "Choice: " choice
echo ""
echo "You entered: '$choice'"
echo "Length: ${#choice}"

case $choice in
    1) echo "You picked 1" ;;
    2) echo "You picked 2" ;;
    *) echo "You picked something else: $choice" ;;
esac
