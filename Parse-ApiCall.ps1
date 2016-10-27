<#
    No cmdletbinding. We're accepting $args instead.

    We expect an array of size one, containing the URL query with a leading slash.

    Schema:
    /apikey?key1=value1&key2=value2

#>


Write-Host "Entered parser"

if ($args[0] -like "/foo") {
    return "bar"
}

$ArgsTokens = $args[0] -split "\?"
$ApiKey = $ArgsTokens[0] -replace "^/"

$QueryTokens = $ArgsTokens[1] -split "&"
$SqlQuery = @{}
$QueryTokens | %{
    $Subtokens = $_ -split '='
    $SqlQuery += @{$Subtokens[0]=$Subtokens[1]}
}

write-host "Parsed arguments"
#return "hiii"
return (gci DB:\)

#More typical, but you annoyingly need to select the UserID property on the $UserID object
#$UserID = Invoke-Item DB:\ -Sql "SELECT UserID FROM Logins WHERE ApiKey='d12831d5-2a0f-4467-a94d-56e7e8be92d7'"

$Login = Get-ChildItem DB:\Logins #-Filter "Apikey='d12831d5-2a0f-4467-a94d-56e7e8be92d7'"
return $login

#$Login = Get-ChildItem DB:\Logins -Filter "Apikey='$ApiKey'"

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

return $Forecast #.Forecast



#SQL "UPDATE UserProfiles SET LocationID='141c5875' WHERE UserID='WillCodeForPizza'"




















#default case to avoid returning null
return "invalid query syntax. Try /help for some shoddy documentation."