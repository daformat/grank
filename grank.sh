#!/bin/bash

# grank - find your google rank index
#
# 2008 - Mike Golvach - eggi@comcast.net
# updated 2013 - Mathieu jouhet - @daformat
#
# Creative Commons Attribution-Noncommercial-Share Alike 3.0 United States License
#

# Setup variables
results_per_page=10
base=0
num=1
start=0
multiple_search=0
not_found=0
found=0
output=0
# Default behavior is to stop at the first result page where url is found
search_all_results=0 # Set this to 1 to continue searching until 1000 first results.

# Text color variables
txtred=$(tput setaf 1) #  red
txtgrn=$(tput setaf 2) #  green
txtylw=$(tput setaf 3) #  yellow
txtprp=$(tput setaf 4) #  purple
txtpnk=$(tput setaf 5) #  pink
txtcyn=$(tput setaf 6) #  cyan
txtwht=$(tput setaf 7) #  white

# Text modifiers
txtund=$(tput sgr 0 1)  # Underline
txtbld=$(tput bold)     # Bold
txtrst=$(tput sgr0)     # Reset

#feedback
info="${txtbld}${txtcyn}[i]${txtrst}"
warn="${txtbld}${txtred}[!]${txtrst}"
ques="${txtbld}${txtylw}[?]${txtrst}"
ok="${txtbld}${txtgrn}[ok]${txtrst}"


# Wrong invocation
if [ $# -lt 2 -a $# -ne 0 ]
then
        echo "${txtbld}${txtylw}Usage: $0 URL Search_Term(s)${txtrst}"
        echo "URLs ${txtund}with${txtrst} http(s)://, ftp://, etc"
        exit 1
fi

# Invocation without parameters
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

# Compute search query string
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

echo "${txtwht}Searching Google index${txtrst} for ${txtund}$url${txtrst} with search query: ${txtund}$search_terms${txtrst}...${txtrst}"

num_results=`wget -q --user-agent=Firefox -O - http://www.google.com/search?q=$search_string\&hl=en\&safe=off\&pwst=1\&start=$start\&sa=N|awk '{ if ( $0 ~ /.*bout .* results<\/div><div id="res">.*/ ) print $0 }'|awk -F"bout " '{print $2}'|awk -F" results" '{print $1}'`
echo "About $num_results results found in google index"
echo "wget -q --user-agent=Firefox -O - http://www.google.com/search?q=$search_string\&hl=en\&safe=off\&pwst=1\&start=$start\&sa=N"
echo

while :;
do
        if [ $not_found -eq 1 ]
        then
                break
        fi
        echo "Searching $results_per_page results, starting at #$start"
        output=`wget -q --user-agent=Firefox -O - http://www.google.com/search?q=$search_string\&num=$results_per_page\&hl=en\&safe=off\&pwst=1\&start=$start\&sa=N|awk '{ gsub(/<h3 class/,"\n <h3 class"); print }'|sed 's/.*\(<h3 class="r">\)<a href=\"\([^\"]*\)\">/\n\2\n/g'|awk -v num=$num -v base=$base '{ if ( $1 ~ /http/ ) print base,num++,$0 }'|awk '{ if ( $2 < 10 ) print "# " $1 "0" $2 " for page: " $3; else if ( $2 == 100 ) print "# " $1+1 "00 for page: " $3;else print "# " $1 $2 " for page: " $3 }'|sed "s/\(.*for page: \).*q=\(.*\)&amp;sa=.*/$ok \1\2/g"|grep -i $url`

        if [ $? -ne 0 ]
        then
                let start=$start+$results_per_page
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
                if [ $found -eq 0 ]
                then
                        let found=$start+$results_per_page
                fi
                echo "$output";

                # Now that we found something, should we continue until we reach 1000 results ?
                if [ $search_all_results -ne 1 ]
                then
                        break
                fi

                # If we do continue...
                let start=$start+$results_per_page
                if [ $start -eq 1000 ]
                then
                        break
                fi
                let base=$base+1
                first_page=0

        fi

        let sleep_time=${RANDOM}/600
        if [ $found -eq 0 ]
        then
                echo "${info} Not found in top $start results: sleeping $sleep_time seconds..."
        else
                echo "${info} Found in top $found results."
                echo "${txtwht}Script is setup to search through every results.${txtrst} Sleeping $sleep_time seconds..."
        fi
        echo 
        sleep $sleep_time
done

if [ $not_found -eq 1 ]
then
        echo "${warn} Not Found In First 1,000 Index Results - Google's Hard Limit"
else
        echo
        echo "${txtgrn}Found in top $found results.${txtrst}"
fi

echo
exit 0