#!/usr/bin/env bash



keyword="rehearsal"
grepweekdays="-i -e monday -e tuesday -e wednesday -e thursday -e friday -esaturday -e sunday"

churchSite="http://www.churches-of-christ.net/usa/nc_churches.html"
churchAddress=$(wget -q -O -  ${churchSite}  | grep  -E '^.*[0-9]{5}-[0-9]{4}' | sed -E 's/([0-9]{5}-[0-9]{4}).*/\1/' | sed 's/&nbsp;//')