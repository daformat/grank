#!/bin/bash

# grank - find your google rank index
#
# 2008 - Mike Golvach - eggi@comcast.net
# updated 2013 - Mathieu jouhet - @daformat
#
# Creative Commons Attribution-Noncommercial-Share Alike 3.0 United States License
#

if [ $# -lt 2 -a $# -ne 0 ]
then
        echo "Usage: $0 URL Search_Term(s)"
        echo "URL with or with http(s)://, ftp://, etc"
        exit 1
fi

if [ $# -eq 0 ]
then
        while read x y
        do
                url=$x
                search_terms=$y
                $0 $x "$y"
        done
        exit 0
else
        url=$1
 shift
        search_terms=$@
fi

base=0
num=1
start=0
multiple_search=0
not_found=0

for x in $search_terms
do
        if [ $multiple_search -eq 0 ]
        then
                search_string=$x
                multiple_search=1
        else
                search_string="${search_string}+$x"
        fi
done

echo "Searching For Google Index For $url With Search Terms: $search_terms..."
echo

num_results=`wget -q --user-agent=Firefox -O - http://www.google.com/search?q=$search_string\&hl=en\&safe=off\&pwst=1\&start=$start\&sa=N|awk '{ if ( $0 ~ /.*bout .* results.*/ ) print $0 }'|awk -F"bout " '{print $2}'|awk -F" results" '{print $1}'`
echo "About $num_results results found in google index"

while :;
do
        if [ $not_found -eq 1 ]
        then
                break
        fi
        echo "Searching in 10 results, starting at result #$start"
        wget -q --user-agent=Firefox -O - http://www.google.com/search?q=$search_string\&num=10\&hl=en\&safe=off\&pwst=1\&start=$start\&sa=N|sed 's/.*<h3 class="r"><a href=\"\([^\"]*\)\">/\n\1\n/g'|awk -v num=$num -v base=$base '{ if ( $1 ~ /http/ ) print base,num++,$0 }'|awk '{ if ( $2 < 10 ) print "Google Index Number " $1 "0" $2 " For Page: " $3; else if ( $2 == 100 ) print "Google Index Number " $1+1 "00 For Page: " $3;else print "Google Index Number " $1 $2 " For Page: " $3 }'|sed 's/\(.*For Page: \).*q=\(.*\)&amp;sa=.*/\1\2/g'|grep -i $url

        if [ $? -ne 0 ]
        then
                let start=$start+10
                if [ $start -eq 1000 ]
                then
                        not_found=1
                        if [ $not_found -eq 1 ]
                        then
                                break
                        fi
                fi
                let base=$base+1
                first_page=0
        else
                break
        fi

        let sleep_time=${RANDOM}/600
        echo "Not In Top $start Results: Sleeping $sleep_time seconds..."
        sleep $sleep_time
done

if [ $not_found -eq 1 ]
then
        echo "Not Found In First 1,000 Index Results - Google's Hard Limit"
        echo
fi

echo "Out Of Approximately $num_results Results"
echo
exit 0