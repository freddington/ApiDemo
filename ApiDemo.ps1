sl $PSScriptRoot
    

$Help = @'
    Documentation:
    Accepts URLs in the format
        <hostname or IP>/deadbeefdeadbeef/forecast=f1day

'@

 
$BuildString = @'

CREATE TABLE Logins (
    UserID text PRIMARY KEY,
    ApiKey text NOT NULL UNIQUE
);
INSERT INTO 'Logins' VALUES('Freddie','d12831d5-2a0f-4467-a94d-56e7e8be92d7');
INSERT INTO 'Logins' VALUES('WillCodeForPizza','58d5f3d5-f9b9-4b48-8325-a94ef4f7c8f9');


CREATE TABLE Locations (
    LocationID text PRIMARY KEY,
    LocationName text NOT NULL UNIQUE
);
INSERT INTO 'Locations' VALUES('141c5875', 'London');
INSERT INTO 'Locations' VALUES('2d8ec3c3', 'Orkney');
INSERT INTO 'Locations' VALUES('a91c4ce9', 'Zanzibar');
INSERT INTO 'Locations' VALUES('6fbcf9ba', 'Dogger_Bank');



CREATE TABLE UserProfiles (
    UserID text PRIMARY KEY,
    LocationID text NOT NULL,
    FOREIGN KEY (LocationID) REFERENCES Locations (LocationID) ON DELETE CASCADE ON UPDATE NO ACTION
);
INSERT INTO 'UserProfiles' VALUES('Freddie', '141c5875');
INSERT INTO 'UserProfiles' VALUES('WillCodeForPizza', '2d8ec3c3');



CREATE TABLE ForecastPeriods (
    ForecastPeriodID text PRIMARY KEY,
    ForecastPeriodName text NOT NULL UNIQUE
);
INSERT INTO 'ForecastPeriods' VALUES('1day', '1-day forecast');
INSERT INTO 'ForecastPeriods' VALUES('5day', '5-day forecast');
INSERT INTO 'ForecastPeriods' VALUES('2100', 'The year 2100');



CREATE TABLE Forecasts (
    LocationID text,
    ForecastPeriodID text,
    Prediction text,
    PRIMARY KEY (LocationID, ForecastPeriodID),
    FOREIGN KEY (LocationID) REFERENCES Locations (LocationID) ON DELETE CASCADE ON UPDATE NO ACTION,
    FOREIGN KEY (ForecastPeriodID) REFERENCES ForecastPeriods (ForecastPeriodID) ON DELETE CASCADE ON UPDATE NO ACTION
);
INSERT INTO 'Forecasts' VALUES('141c5875', '1day', 'Awful');
INSERT INTO 'Forecasts' VALUES('141c5875', '5day', 'Sleet, shading into blizzards');
INSERT INTO 'Forecasts' VALUES('141c5875', '2100', 'Nuclear winter. Acid rain. Blistering hellhole');
INSERT INTO 'Forecasts' VALUES('2d8ec3c3', '1day', 'Balmy');
INSERT INTO 'Forecasts' VALUES('2d8ec3c3', '5day', 'Rains of frogs, becoming fish later');
INSERT INTO 'Forecasts' VALUES('2d8ec3c3', '2100', 'Nuclear winter. Acid rain. Blistering hellhole');
INSERT INTO 'Forecasts' VALUES('a91c4ce9', '1day', 'Mosquitoes and humidity');
INSERT INTO 'Forecasts' VALUES('a91c4ce9', '5day', 'Mosquitoes and humidity, so many mosquitoes');
INSERT INTO 'Forecasts' VALUES('a91c4ce9', '2100', 'Nuclear winter. Acid rain. Blistering hellhole');
INSERT INTO 'Forecasts' VALUES('6fbcf9ba', '1day', 'Gentle hurricanes');
INSERT INTO 'Forecasts' VALUES('6fbcf9ba', '5day', 'Squalls. Love that word. Squalls squalls squalls');
INSERT INTO 'Forecasts' VALUES('6fbcf9ba', '2100', 'Nuclear winter. Acid rain. Blistering hellhole');

'@



#Expects to find SQLite PowerShell Provider in same-level directory
#Download from https://psqlite.codeplex.com
#run Unblock-File on downloaded zip before extracting
Import-Module ..\SQLite

Remove-PSDrive DB -ErrorAction SilentlyContinue
mount-sqlite -name DB #-dataSource $PSScriptRoot\weather.sqlite

function SQL {Invoke-Item DB:\ -SQL ($args -join " ")}

SQL $BuildString





function Parse-ApiCall {
    param ($Query)

    if ($Query -like "/foo") {
        return "bar"
    }


    $QueryTokens = $Query -split "\?"
    $ApiKey = $QueryTokens[0] -replace "^/"

    $QueryTokens2 = $QueryTokens[1] -split "&"
    $SqlQuery = @{}
    $QueryTokens2 | %{
        $Subtokens = $_ -split '='
        $SqlQuery += @{$Subtokens[0]=$Subtokens[1]}
    }


    #More typical, but you annoyingly need to select the UserID property on the $UserID object
    #$UserID = Invoke-Item DB:\ -Sql "SELECT UserID FROM Logins WHERE ApiKey='d12831d5-2a0f-4467-a94d-56e7e8be92d7'"


    #$Login = Get-ChildItem DB:\Logins -Filter "Apikey='d12831d5-2a0f-4467-a94d-56e7e8be92d7'"
    $Login = Get-ChildItem DB:\Logins -Filter "Apikey='$ApiKey'"

    if (-not $Login) {return "Invalid API key"}



    #Use provided location or, if not provided, default location from user profile
    if ($SqlQuery.ContainsKey("Location")) {
        $Location = Get-ChildItem DB:\Logins -Filter "LocationName='$($SqlQuery.Location)'"
    } else {
        $UserProfile = Get-ChildItem DB:\UserProfiles -Filter "UserID='$($Login.UserID)'"
        $Location = Get-ChildItem DB:\Locations -Filter "LocationID='$($UserProfile.LocationID)'"
    }


    #Use provided forecast period or, if not provided, default
    if ($SqlQuery.ContainsKey("ForecastPeriod")) {
        $ForecastPeriod = Get-ChildItem DB:\ForecastPeriods -Filter "ForecastPeriodID='$($SqlQuery.ForecastPeriod)'"
    } else {
        $ForecastPeriod = Get-ChildItem DB:\ForecastPeriods -Filter "ForecastPeriodID='1day'"
    }



    #Get the record we want
    $Forecast = Get-ChildItem DB:\Forecasts -Filter "LocationID='$($Location.LocationID)' AND ForecastPeriodID='$($ForecastPeriod.ForecastPeriodID)'"

    return $Forecast | select ForecastPeriodID, Prediction


}





    
#intialise web server
$Binding = [uri]"http://127.0.0.1:8080"
$Listener = New-Object System.Net.HttpListener
$Listener.Prefixes.Add($Binding.AbsoluteUri)


try {
    $Listener.Start()
} catch [System.Net.HttpListenerException] {
    #Already running on this binding, so quit
    if ($_.Exception -like "*conflicts with an existing registration on the machine.*") {
        Write-Host "Binding $Binding is already in use"
        return
    }
}

Write-Host "Listening at $($Binding.AbsoluteUri)..."







while ($Listener.IsListening) {

    $Context = $Listener.GetContext()
    $RequestUrl = $Context.Request.Url
    $Response = $Context.Response
    $RequestQuery = $RequestUrl.PathAndQuery


    Write-Host ''
    Write-Host "> $RequestUrl"


    #Prepare content based on query
    switch ($RequestQuery) {
        '/end' {
            #$Response.Close()
            $Listener.Stop()
            return
        }

        '/DB' {
            $Content = Get-PSDrive DB

        }

        '/help' {
            $Content = $Help
        }


        default {
            $Content = ConvertTo-Json (Parse-ApiCall $RequestQuery) -Depth 10 #-Compress

        }
    }


    #serve the content
    if ($Content) {
        $Buffer = [System.Text.Encoding]::UTF8.GetBytes($Content)
        
    } else {
        #if $Content is null, the encoding to UTF8 will throw, and $Buffer will still hold data from last request
        $Buffer = [byte[]]@()
    }

    $Response.AddHeader("ContentType", "text/plain")
    $Response.AddHeader("Accept-Ranges", "bytes")
    $Response.ContentLength64 = $Buffer.Length
    $Response.OutputStream.Write($Buffer, 0, $Buffer.Length)


    #close
    $Response.Close()

    $ResponseStatus = $Response.StatusCode
    Write-Host "< $ResponseStatus"


}





$Response.Close()
$Listener.Dispose()