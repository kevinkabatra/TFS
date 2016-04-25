# Author: Miodrag Milic <miodrag.milic@gmail.com>
# Last Change: 25-Apr-2016.

<#
.SYNOPSIS
    Get the build definition history
#>
function Get-TFSBuildDefinitionHistory{
    [CmdletBinding()]
    param(
        # Build definition history id [int] or name [string]
        $Id,
        # Return raw data instead of the table
        [switch]$Raw
    )
    check_credential


    if ( ![String]::IsNullOrEmpty($Id) -and ($Id.GetType() -eq [string]) ) { $Id = Get-TFSBuildDefinitions -Name $Id | % id }
    if ( [String]::IsNullOrEmpty($Id) ) { throw "Build definition with that name or id doesn't exist: '$Id' " }
    Write-Verbose "Build definition history id: $Id"

    $uri = "$proj_uri/_apis/build/definitions/$($Id)/revisions?api-version=" + $global:tfs.api_version
    Write-Verbose "URI: $uri"

    $params = @{ Uri = $uri; Method = 'Get' }
    $r = invoke_rest $params
    if ($Raw) { return $r.value }

    $props = 'revision', 'comment', 'changeType',
             @{ N='date';       E={ (get-date $_.changedDate).tostring($time_format)} },
             @{ N='changed by'; E={ $_.changedBy.displayName } }

    $r.value | select -Property $props | sort revision -Desc | ft -au
}
