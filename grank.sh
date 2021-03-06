#!/bin/bash

# grank - find your google rank index
# -----------------------------------
# 2008 - Mike Golvach - eggi@comcast.net
# updated 2013 - Mathieu jouhet - @daformat
#
# version: 0.5
# lastmod: 2013/12/28
#
# License
# -------
# Creative Commons
# Attribution-Noncommercial-Share Alike 3.0 United States License
#

# Settings
# ---------

# how many results per page ? (Maximum is 100)
results_per_page=100

# Default behavior is to stop at the page where the url was found
# Set this to 1 to continue searching until 1000 first results.
# Remember google doesn't like you to scrape it's content
# Do this at your own risk
search_all_results=0

# set the host to use for scrapping
search_host="google.com"

# set the locale used for searching
lang="en"

### Don't touch this ###
# Those are needed for the script to work correctly
base=0
num=1
start=0
multiple_search=0
not_found=0
found=0
output=0
debug=0

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

# Feedback helpers
info="${txtbld}${txtcyn}[i]${txtrst}"
warn="${txtbld}${txtred}[!]${txtrst}"
ques="${txtbld}${txtylw}[?]${txtrst}"
ok="${txtbld}${txtgrn}[ok]${txtrst}"

# Script Options
while getopts "avh:l:" option
do
  case "$option" in
    a)
    # the script will continue searching even if a result was found
    search_all_results=1
    shift $((OPTIND-1)); OPTIND=1
    ;;
    v)
    # verbosity
    debug=$((debug+1))
    shift $((OPTIND-1)); OPTIND=1
    ;;
    h)
    # set-up host
    search_host=$OPTARG
    shift $((OPTIND-1)); OPTIND=1
    ;;
    l)
    # set-up locale
    lang=$OPTARG
    shift $((OPTIND-1)); OPTIND=1
    ;;
    ?)
    # no options was given
    ;;
  esac
done

# Wrong invocation, give some instructions
if [ $# -lt 2 -a $# -ne 0 -o $1 == "help" ]
then
  echo
  echo "${txtwht}GRANK${txtrst}"
  echo
  echo "  ${txtbld}${txtylw}Usage:${txtrst} $0 [-a] [ -h ${txtund}host${txtrst}] [ -l ${txtund}locale${txtrst}] [${txtund}URL${txtrst}] [${txtund}search_term1${txtrst} ${txtund}...${txtrst}]"
  echo "  ${txtbld}${txtylw}Or${txtrst} launch without parameters to get into interactive mode"
  echo
  echo "  URL should be given ${txtund}with${txtrst} http:// or https://"
  echo "  So you don't get too much false positive"
  echo
  exit 1
  # Invocation without parameters, interactive mode
elif [ $# -eq 0 ]
then
  echo
  echo "${txtbld}${txtcyn}Please type the URL to look for:${txtrst}"
  read x
  echo
  echo "${txtbld}${txtcyn}Please type the search terms:${txtrst}"
  read y

  $0 $x "$y"
  exit 0
else
  # Invocation with parameters
  url=$1
  shift
  search_terms=$@

  # Debug
  if [ $debug -gt 0 ]
  then
    echo "$info Debug: $debug"
    echo "$info Continue after first match: $search_all_results"
    echo "$info Search Host: $search_host"
    echo "$info Locale: $lang"
    echo "$info Looking results linking to: $url"
    echo "$info For query: "$search_terms
  fi
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

echo
echo "${txtwht}Searching ${txtund}${txtcyn}$search_host${txtrst} index for ${txtund}${txtcyn}$url${txtrst}..."

# We issue a first request to get the total number of results in Google index
# We could definitely use this first search request for the first page, but I'm lazy :)
search_page_url="http://www.$search_host/search?q=$search_string\&hl=$lang\&safe=off\&pwst=1\&start=$start\&sa=N"

# Perform the search request
wgetoutput=`wget -S --user-agent=Firefox -O - $search_page_url 2>&1`
if [ $? -ne 0 ]
then
  error503=`echo $wgetoutput | grep -oE "503:? Service Unavailable" | wc -l`
  if [ $error503 -ne 0 ]
  then
    echo "${warn} Got an error 503. Google is cooling you down..."
  else
    echo "${warn} Error while getting remote data."
    echo $wgetoutput
  fi
  exit 1
fi

# Convert to UTF-8
wgetoutput=`echo $wgetoutput | iconv -f ISO-8859-1`

# Lookup the approximate number of results in Google index
num_results=`echo $wgetoutput | grep -oE 'resultStats">([^<])*' | sed "s/\(&#160;\|\.\)/,/g" | sed 's/.*\s\([0-9,]\+\)\s.*/\1/'`
echo "${txtwht}About ${txtcyn}$num_results${txtrst} results found for query: ${txtund}${txtcyn}$search_terms${txtrst}"

# Debug
if [ $debug -gt 0 ]
then
  echo "$info wget --user-agent=Firefox -O - http://www.$search_host/search?q=$search_string&num=$results_per_page&hl=$lang&safe=off&pwst=1&start=$start&sa=N"
fi


echo


# Inifinite loop, will be broke anyways
while :;
do
  # If we already searched everything and did not found, break
  if [ $not_found -eq 1 ]
  then
    break
  fi


  # Prepare $url of the next next result page
  search_page_url="http://www.$search_host/search?q=$search_string&num=$results_per_page&hl=$lang&safe=off&pwst=1&start=$start&sa=N"
  echo "Searching $results_per_page results, starting at #$start"
  echo "${txtcyn}$search_page_url${txtrst}"

  # Perform the search request
  wgetoutput=`wget --user-agent=Firefox -O - $search_page_url 2>&1`
  if [ $? -ne 0 ]
  then
    error503=`echo $wgetoutput | grep -oE "503:? Service Unavailable" | wc -l`
    if [ $error503 -ne 0 ]
    then
      echo "${warn} Got an error 503. Google is cooling you down..."
    else
      echo "${warn} Error while getting remote data"
      echo $wgetoutput
    fi
    exit 1
  fi

  wgetoutput=`echo $wgetoutput | iconv -f ISO-8859-1`

  # Check we actually have results in the current page
  current_page_num_results=`echo $wgetoutput | grep -o '<h3 class="r">' | wc -l`
  if [ $current_page_num_results -eq 0 ]
  then
    echo "${warn} No results in the current page, stopping."
    exit
  fi

  echo "$current_page_num_results results in the current page."
  output=`echo $wgetoutput|awk '{ gsub(/<h3 class/,"\n <h3 class"); print }'|sed 's/.*\(<h3 class="r">\)<a href=\"\([^\"]*\)\">/\n\2\n/g'|awk -v num=$num -v base=$base '{ if ( $1 ~ /http/ ) print base,num++,$0 }'|awk '{ if ( $2 < 10 ) print "# " $1 "0" $2 " for page: " $3; else if ( $2 == 100 ) print "# " $1+1 "00 for page: " $3;else print "# " $1 $2 " for page: " $3 }'|sed "s/\(.*for page: \).*q=\(.*\)&amp;sa=.*/$ok \1\2/g"|grep -i $url`

  # If we got an error, it means that we did not find $url in the
  # current search results. Let's search in the next page
  if [ $? -ne 0 ]
  then
    let start=$start+$results_per_page
    # break once we reach a thousand results
    if [ $start -eq 1000 ]
    then
      break
    fi
    let base=$base+1

  # If we didn't get any error
  else
    # If no result was found previously
    if [ $found -eq 0 ]
    then
      # Store the first page where $url was found
      let found=$start+$results_per_page
    fi
    echo "$output";

    # Now that we found something, should we continue
    # until we reach 1000 results ?
    if [ $search_all_results -ne 1 ]
    then
      break
    fi

    # If we do, continue...
    let start=$start+$results_per_page

    # Google hard limit
    if [ $start -eq 1000 ]
    then
      break
    fi

    let base=$base+1

  fi

  # Random sleep time to behave more like a human
  let sleep_time=${RANDOM}/1200

  # Output what's happening
  if [ $found -eq 0 ]
  then
    echo "${info} Not found in top $start results: sleeping $sleep_time seconds..."
  else
    echo "${info} Found in top $found results."
    echo
    echo "${txtwht}Script is setup to search through every results.${txtrst} Sleeping $sleep_time seconds..."
  fi
  echo

  # Let's sleep a little so that we dont get blocked to quickly
  sleep $sleep_time
done

# Let's summarize what we did
if [ $not_found -eq 1 ]
then
  echo "${warn} Not Found In First 1,000 Index Results - Google's Hard Limit"
else
  echo
  echo "${txtgrn}Found in top $found results.${txtrst}"
fi

echo
exit 0
