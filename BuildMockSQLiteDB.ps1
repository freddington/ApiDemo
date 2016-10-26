& '.\sqlite3.exe' Weather.db

PRAGMA foreign_keys=ON;



CREATE TABLE Logins (
    UserID text PRIMARY KEY,
    ApiKey text NOT NULL UNIQUE
);
INSERT INTO "Logins" VALUES('Freddie','d12831d5-2a0f-4467-a94d-56e7e8be92d7');
INSERT INTO "Logins" VALUES('WillCodeForPizza','58d5f3d5-f9b9-4b48-8325-a94ef4f7c8f9');
686102


CREATE TABLE Locations (
    LocationID text PRIMARY KEY,
    LocationName text NOT NULL UNIQUE
);
INSERT INTO "Locations" VALUES("141c5875", "London");
INSERT INTO "Locations" VALUES("2d8ec3c3", "Orkney");
INSERT INTO "Locations" VALUES("a91c4ce9", "Zanzibar");
INSERT INTO "Locations" VALUES("6fbcf9ba", "Dogger_Bank");



CREATE TABLE ForecastPeriods (
    ForecastPeriodID text PRIMARY KEY,
    ForecastPeriodName text NOT NULL UNIQUE
);
INSERT INTO "ForecastPeriods" VALUES("f1day", "1-day forecast");
INSERT INTO "ForecastPeriods" VALUES("f5day", "5-day forecast");
INSERT INTO "ForecastPeriods" VALUES("f2100", "The year 2100");



CREATE TABLE Forecasts (
    LocationID text,
    ForecastPeriodID text,
    Prediction text,
    PRIMARY KEY (LocationID, ForecastPeriodID),
    FOREIGN KEY (LocationID) REFERENCES Locations (LocationID) ON DELETE CASCADE ON UPDATE NO ACTION,
    FOREIGN KEY (ForecastPeriodID) REFERENCES ForecastPeriods (ForecastPeriodID) ON DELETE CASCADE ON UPDATE NO ACTION
);
INSERT INTO "Forecasts" VALUES("141c5875", "f1day", "Awful");
INSERT INTO "Forecasts" VALUES("141c5875", "f5day", "Sleet, shading into blizzards");
INSERT INTO "Forecasts" VALUES("141c5875", "f2100", "Nuclear winter. Acid rain. Blistering hellhole");
INSERT INTO "Forecasts" VALUES("2d8ec3c3", "f1day", "Balmy");
INSERT INTO "Forecasts" VALUES("2d8ec3c3", "f5day", "Rains of frogs, becoming fish later");
INSERT INTO "Forecasts" VALUES("2d8ec3c3", "f2100", "Nuclear winter. Acid rain. Blistering hellhole");
INSERT INTO "Forecasts" VALUES("a91c4ce9", "f1day", "Mosquitoes and humidity");
INSERT INTO "Forecasts" VALUES("a91c4ce9", "f5day", "Mosquitoes and humidity, so many mosquitoes");
INSERT INTO "Forecasts" VALUES("a91c4ce9", "f2100", "Nuclear winter. Acid rain. Blistering hellhole");
INSERT INTO "Forecasts" VALUES("6fbcf9ba", "f1day", "Gentle hurricanes");
INSERT INTO "Forecasts" VALUES("6fbcf9ba", "f5day", "Squalls. Love that word. Squalls squalls squalls");
INSERT INTO "Forecasts" VALUES("6fbcf9ba", "f2100", "Nuclear winter. Acid rain. Blistering hellhole");

.save Weather.db