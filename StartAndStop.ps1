function Api {
    start powershell "-NoExit", ".\ApiDemo.ps1"
}

function Stop {
    Invoke-WebRequest "http://127.0.0.1:8080/end" -UseBasicParsing 
}

function foo {
    Invoke-WebRequest "http://127.0.0.1:8080/foo" -UseBasicParsing | select -ExpandProperty RawContent | %{$_ -split "\n(\s)*\n" | select -Last 1}
}

function apihelp {
    Invoke-WebRequest "http://127.0.0.1:8080/help" -UseBasicParsing | select -ExpandProperty RawContent | %{$_ -split "\n(\s)*\n" | select -Last 1}
}

function test {
    param([string]$Query)
    
    $Response = Invoke-WebRequest "http://127.0.0.1:8080$Query" -UseBasicParsing | select -ExpandProperty RawContent
    $Response -split "\n(\s)*\n" | select -Last 1

    <#
    $Response = Invoke-WebRequest "http://127.0.0.1:8080$Query" -UseBasicParsing | select -ExpandProperty RawContent
    [regex]::Replace(
        $Response,
        "^.*\n(\s)*\n",
        '',
        [System.Text.RegularExpressions.RegexOptions]::Multiline
    )
    #>
}

