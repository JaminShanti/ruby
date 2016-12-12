#!/usr/bin/env bash



keyword="rehearsal"
grepweekdays="-i -e monday -e tuesday -e wednesday -e thursday -e friday -esaturday -e sunday"

musicsite="http://www.carolinaclarinet.org/links2.htm"
sitelist=( $( lynx --dump --listonly "$musicsite"| grep http | cut -f2- -d'.' | tr -d ' ' | sort | uniq ) )
for site in ${sitelist[@]}
do
     (subsitelist=( $( lynx --dump --listonly "$site" 2>/dev/null | grep http | cut -f2- -d'.' | tr -d ' ' | sort | uniq ) )
     siteresponse=$( lynx --dump ${site} 2>/dev/null | grep -i -e "$keyword" | eval grep "${grepweekdays}")
     if [ -n "$siteresponse" ]
       then
          echo "$site : $siteresponse" | sed -e 's/<[^>]*>//g'
     fi
     for subsite in ${subsitelist[@]}
     do
            if [[ "$subsite" == *"$site"* ]]
            then
                subsiteresponse=$( lynx --dump ${subsite} 2>/dev/null | grep -i -e "$keyword" | eval grep "${grepweekdays}")
                if [ -n "$subsiteresponse" ]
                    then

                    echo "$site : $subsiteresponse" | sed -e 's/<[^>]*>//g'
                fi
            fi
     done) &

done
wait