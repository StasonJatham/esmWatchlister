param(
    $file = "MyDefaultPathToExportFile\RuleExport_XXXXXXXXXXXX.xml"
)

Add-Type -AssemblyName System.Web
[xml]$xmlElm = Get-Content -Path $file

foreach ($rule in $xmlElm.nitro_policy.rules.rule.text.InnerText) {
    [xml]$ruleXML = $rule
    $filterData = $ruleXML.ruleset.rule.matchFilter.singleFilterComponent.filterData.value

    if ($filterData -match "$watch=") {
        Write-Output "--> $($ruleXML.ruleset.name) ($($ruleXML.ruleset.id))"
        $pattern = "$watch=(.*?)(,| |])"
        $string  = [string]$filterData

        $watchlist = Select-String $pattern -InputObject $string -AllMatches | Foreach {$_.matches.Value}
        $watchlist_clean = $watchlist.Replace(" ", "").Replace("=","").Replace(",","").Replace("]","")

        foreach ($wl in $watchlist_clean) {
            Write-Output "+ $([System.Web.HTTPUtility]::UrlDecode($wl))"
        }

        Write-Output "-----------------"
    }
    # --> uncomment to show all rules
    #else {
    #    Write-Output "--> $($ruleXML.ruleset.name) ($($ruleXML.ruleset.id))"
    #}
}
