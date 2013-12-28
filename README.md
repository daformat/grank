grank
=====

Find your google index rank using this bash script.

### Usage

```shell
	./grank.sh [-a] [ -h host ] [ -l locale ] [ url ] [ search_term ... ]
```

Where `url` is the url too look for in the google index and `search_term` is the search term to look for.  
You can add multiple search terms, they will get concatenated as a query string using the + delimitor.

**Options**

`-a` Use this flag if you want the script to continue searching through all 1000 first google results.  
`-h` specify the host to use (default is 'google.com', you can use other tld such as 'google.fr', google.it'...)  
`-l` is the locale to use (default is 'en', you can any other locale supported by google such as 'fr', 'it'...)

**Example**
```shell
	./grank.sh http://www.urbandictionary.com get a life
```

Will search for urbandictionary.com's position here :  
[http://www.google.com/search?q=get+a+life](http://www.google.com/search?q=get+a+life)

Alternatively, just launch the script **without** parameters, it will launch in interactive mode and ask you for the url and search terms, using the default host and locale.


### MacOSX users
If you get this error:
```
	sed: RE error: illegal byte sequence
```

Type those commands, or add them to your ~/.bash_profile if you don't want to do that everytime you restart your terminal:
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