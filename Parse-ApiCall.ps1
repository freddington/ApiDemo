
    param(
        $Query,
        $Method,
        $Body
    )

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

    $ParseSplat = @{
        ApiKey = $ApiKey;
        SqlQuery = $SqlQuery;
        Method = $Method;
        Body = $Body
    }


    function Parse-Post {
        #I couldn't get this working in time for the demo

        param(
            $ApiKey,
            $SqlQuery,
            $Method,
            $Body
        )


        #$Login = Get-ChildItem DB:\Logins -Filter "Apikey='d12831d5-2a0f-4467-a94d-56e7e8be92d7'"
        $Login = Get-ChildItem DB:\Logins -Filter "Apikey='$ApiKey'"
        if (-not $Login) {return "Invalid API key"}
        $UserProfile = Get-ChildItem DB:\UserProfiles -Filter "UserID='$($Login.UserID)'"

        #TODO: SQL queries based on $Body
        return $Body


    }







    function Parse-Get {
        param(
            $ApiKey,
            $SqlQuery
        )

        #More typical, but you annoyingly need to select the UserID property on the $UserID object
        #$UserID = Invoke-Item DB:\ -Sql "SELECT UserID FROM Logins WHERE ApiKey='d12831d5-2a0f-4467-a94d-56e7e8be92d7'"


        #$Login = Get-ChildItem DB:\Logins -Filter "Apikey='d12831d5-2a0f-4467-a94d-56e7e8be92d7'"
        $Login = Get-ChildItem DB:\Logins -Filter "Apikey='$ApiKey'"
        if (-not $Login) {return "Invalid API key"}
        $UserProfile = Get-ChildItem DB:\UserProfiles -Filter "UserID='$($Login.UserID)'"


        #Use provided location or, if not provided, default location from user profile
        if ($SqlQuery.ContainsKey("Location")) {
            $LocationFilter = "LocationName='$($SqlQuery.Location)'"
        } else {
            $LocationFilter = "LocationID='$($UserProfile.Location)'"
        }
        $Location = Get-ChildItem DB:\Locations -Filter $LocationFilter
    



        $ForecastFilter = "LocationID='$($Location.LocationID)'"

        #Use provided forecast period or, if not provided, all
        if ($SqlQuery.ContainsKey("ForecastPeriod")) {
            $ForecastFilter += " AND ForecastPeriodID='$($SqlQuery.ForecastPeriod)'"
        }
        #return $ForecastFilter
        #Get the record we want
        $Forecast = Get-ChildItem DB:\Forecasts -Filter $ForecastFilter

        return $Forecast | select ForecastPeriodID, Prediction


    }



    if ($Method -like "GET") {return Parse-Get @ParseSplat}
    #select -ExcludeProperty SSItemMode, PSPath, PSParentPath, PSChildName, PSDrive, PSProvider, PSIsContainer, RowError, RowState, Table, ItemArray, HasErrors
    if ($Method -like "POST") {return Parse-Post @ParseSplat}
    