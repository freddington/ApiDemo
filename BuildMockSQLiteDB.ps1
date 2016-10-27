<#

    This demo requires a sqlite DB of mock data. Current file builds the DB

#>


<#
    The manual way: 
    
        --invoke the SQLite CLI (download from https://sqlite.org/download.html, you need the SQLite tools package):
            & $PSScriptRoot\..\sqlite-tools-win32-x86-3150000\sqlite3.exe' Weather.db

        --You should now be in the sqlite> prompt.


        --by default you can't use foreign keys, so enable them (not required in the SQLite PowerShell Provider):
            PRAGMA foreign_keys=ON;


        --Create tables and populate with some mock data:

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


        --So far this is all transient. Save to disk (use / as path separator):
            .save weather.sqlite

#>



<#

    Using the SQLite Powershell Provider.

    I did not use this to create the weather.sqlite example file, because I can't figure out how to save to disk with this module.

#>


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
Import-Module $PSScriptRoot\..\SQLite

Remove-PSDrive DB -ErrorAction SilentlyContinue

mount-sqlite -name DB #-dataSource $PSScriptRoot\weather.sqlite

function SQL {Invoke-Item DB:\ -SQL ($args -join " ")}

SQL $BuildString

#Remove-PSDrive DB