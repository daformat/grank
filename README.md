grank
=====

Find your google index rank using this bash script

### Usage

```shell
	./grank.sh url search_term [search_term...]
```


Where `url` is the url too look for in the google index and `search_term` is the search term to look for.  
You can add multiple search terms, they will get concatenated as a query string using the + delimitor.


**Example**
```shell
	./grank.sh http://www.urbandictionary.com get a life
```

Will search for urbandictionary.com's position here :  
[http://www.google.com/search?q=get+a+life](http://www.google.com/search?q=get+a+life)


### MacOSX users
If you get this error:
```
	sed: RE error: illegal byte sequence
```

Add the following lines to your ~/.bash_profile.
```shell
	export LC_CTYPE=C
	export LANG=C
```

### Warning

Google doesn't like bots scraping its index, if you make too many queries you will be blocked.  
The server will return a 503 error (service unavailable).

### Credits 

Initial (2008) script by Mike Golvach - [Original script here](http://linuxshellaccount.blogspot.fr/2008/08/finding-your-google-index-rank-with.html) 

Heavily tweaked by Mathieu Jouhet (@daformat)

### License

[Creative Commons Attribution-Noncommercial-Share Alike 3.0 United States License](http://creativecommons.org/licenses/by-nc-sa/3.0/us/)