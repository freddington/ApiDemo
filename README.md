# Latest code from the demo will be uploaded over the weekend (29/10 Oct 16)

# ApiDemo

A demo of a SQL-based weather API in PowerShell. This accepts API queries and returns JSON-formatted weather forecasts.

This is not heavily developed, it's just an indication of what is possible. It uses SQLite as a backend and HttpListener as a frontend and it parses API queries (I started working on parsing POST with JSON body but ran out of time). To be clear, this is for fun - just because you CAN do something doesn't mean you SHOULD.

The real-world applicability of this might actually be to get metrics or perform management actions on a box, or if you look at my "Pacman" repo you'll see I serve a PAC file to the local machine over this web server. For that purpose it's fine.

This works in synchronous mode. I do not fancy attempting this as a proper asynchronous server - there are easier ways to do that (PoshServer / IIS / any kind of lightweight server). There is a small performance impact of running a continuous loop which you could get around if you used event-driven programming in C#. There may be a way to do that in PowerShell with Register-ObjectEvent, but I recommend getting familiar with the conpt in C# if you are new to events and delegates.

This is still in "hack" mode and therefore not packaged and refactored into pretty code. It's all .ps1s rather than .psm1s because I could test out ideas faster.


# SQLite backend

SQLite turned out to be single-user-only, so that made developing harder. Fortunately you can run it in "transient" mode, i.e. entirely in process memory, so that's what I've done. It is super easy using the SQLite PowerShell Provider (link below). DB code:
    BuildMockSQLiteDB.ps1
I've been dot-sourcing it but this appears not to be strictly necessary. It mounts a DB:\ provider which contains the tables as child items. So you can run:
    gci DB:\Logins
and get back the rows in the Logins table. Nifty!
    gci DB:\Logins -Filter "UserID LIKE 'Freddie'"
adds a WHERE clause.

What is annoying is that you get back a PSObject with extra properties such as PSParent, etc. It's like working with the registry, you get the property called "UserID" and then you have to access the "UserID" property on that object. Annoying.

The returned object hangs on some operations, it seems to crash ConvertTo-Json. If you run it through select, that acts like an object cast and gets rid of the problem.


# Web frontend (ha!)

We create a System.Net.HttpListener, add an IP/port combo and start it. I found I had to explicitly set a port, this won't use 80 by default. The interesting properties of this object are Request and Response. Request contains properties relating to what the client sends, Response is what you update and send back.

No need to run as admin.

Because this is synchronous and runs a while loop, I've written ApiDemo.ps1 as a ps1.

Helper script: dot-source StartAndStop.ps1
   . .\StartAndStop.ps1

To start the server:
    api

To stop the server:
   stop
   
To test:
   test "/apikey?optionalkey=valuepairs&morekey=valuepairs"
    
The web server part is in ApiDemo.ps1, which calls an internal function to parse the request and return the data to the web server to send over HTTP. For ease of dev, I separated this into a separate Parse-ApiCall.ps1, so that I can update that script and test it without taking the extra seconds to stop and start the web server.


# Parsing (i.e. implementing the "API" part of the API)

First, decide on your API schema and your DB schema. (By which I mean table names, columns, etc.) You will need this close at hand.

If implementing a POST and accepting a request body, that will be either JSON or XML, so it's easy to convert that to a PSObject and perform logic based on the properties (for example, by crafting SQL queries). If, like me, you started with GET and used only URL queries, you need to split the string based on delimiters. I have not yet found an elegant way to do this :-(

With hindsight, rather than passing the PathAndQuery property to the Parse-ApiCall form the web request, I could have passed the Path and the Query separately. Then I wouldn't have to split out the API key myself.

Once you've got the request query re-inflated into an object, you need to run a sequence of SQL queries to build the response. I was not concerned with performance, so I ran a sequence of simple SQL statements to get to the final object to return. If you were doing this for real, you would probably build a single query with JOIN.


# Security

I didn't fit this into my talk, but there are some caveats. Somehting like this may be vulnerable to SQL injection. If you run a web server that serves from the file system, you need to prevent users from getting out of your "safe" directory by putting '..' in their query. Also, in your while loop, if a variable assignment fails, you have the risk of returning a previous response, so at the head of the loop I assign $null to a few relevant variables.


# Dependencies

SQLite PowerShell Provider
https://psqlite.codeplex.com/


SQLite
https://sqlite.org/download.html
*This is not strictly required, but useful for hacking and very easy to use.*
