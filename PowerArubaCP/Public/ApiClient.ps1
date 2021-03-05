#
# Copyright 2018-2020, Alexis La Goutte <alexis.lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Add-ArubaCPApiClient {

    <#
        .SYNOPSIS
        Add an API Client on ClearPass

        .DESCRIPTION
        Add an API Client with client id, client secret, grand_types...

        .EXAMPLE
        Add-ArubaCPApiClient -client_id Client1 -grant_types client_credentials -profile_id 1

        Add API Client Client1 type client_credentials with profile id 1 (Super Administrator)

        .EXAMPLE
        Add-ArubaCPApiClient -client_id Client2 -client_secret mySecret -client_description "Add via PowerArubaCP" -grant_types client_credentials -profile_id 1

        Add API Client Client2 with Client Secret mySecret and client description "Add Via PowerArubaCP"

        .EXAMPLE
        Add-ArubaCPApiClient -client_id Client3 -grant_types client_credentials -profile_id 1 -enabled:$false

        Add API Client Client3 with enabled status to disabled
    #>

    Param(
        [Parameter (Mandatory = $false)]
        [int]$id,
        [Parameter (Mandatory = $true)]
        [string]$client_id,
        [Parameter (Mandatory = $false)]
        [string]$client_secret,
        [Parameter (Mandatory = $false)]
        [string]$client_description,
        [Parameter (Mandatory = $true)]
        [ValidateSet('client_credentials', 'password')]
        [string]$grant_types,
        [Parameter (Mandatory = $true)]
        [string]$profile_id,
        [Parameter (Mandatory = $false)]
        [switch]$enabled,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCPConnection
    )

    Begin {
    }

    Process {

        $uri = "api/api-client"

        $_ac = new-Object -TypeName PSObject

        if ( $PsBoundParameters.ContainsKey('id') ) {
            $_ac | add-member -name "id" -membertype NoteProperty -Value $id
        }

        $_ac | add-member -name "client_id" -membertype NoteProperty -Value $client_id

        if ( $PsBoundParameters.ContainsKey('client_description') ) {
            $_ac | add-member -name "client_description" -membertype NoteProperty -Value $client_description
        }

        if ( $PsBoundParameters.ContainsKey('client_secret') ) {
            $_ac | add-member -name "client_secret" -membertype NoteProperty -Value $client_secret
        }

        $_ac | add-member -name "grant_types" -membertype NoteProperty -Value $grant_types

        $_ac | add-member -name "profile_id" -membertype NoteProperty -Value $profile_id

        if ( $PsBoundParameters.ContainsKey('enabled') ) {
            if ( $enabled ) {
                $_ac | add-member -name "enabled" -membertype NoteProperty -Value $True
            }
            else {
                $_ac | add-member -name "enabled" -membertype NoteProperty -Value $false
            }
        }

        $ac = invoke-ArubaCPRestMethod -method "POST" -body $_ac -uri $uri -connection $connection
        $ac
    }

    End {
    }
}
function Get-ArubaCPApiClient {

    <#
        .SYNOPSIS
        Get API Client info on CPPM

        .DESCRIPTION
        Get API Client (Client Id, Client Secret, Grand Types...)

        .EXAMPLE
        Get-ArubaCPApiClient

        Get ALL API Client on the Clearpass

        .EXAMPLE
        Get-ArubaCPApiClient -client_id PowerArubaCP

        Get info about API Client ID PowerArubaCP Aruba on the ClearPass

        .EXAMPLE
        Get-ArubaCPApiClient -grant_types client_cretendials

        Get info about API Client Grant Types equal client_credentials on the ClearPass

        .EXAMPLE
        Get-ArubaCApiClient -id 23

        Get info about API id 23 on the ClearPass

        .EXAMPLE
        Get-ArubaCPApiClient -client_id PowerArubaCP -filter_type contains

        Get info about API Client where client_id contains PowerArubaCP

    #>

    [CmdLetBinding(DefaultParameterSetName = "Default")]

    Param(
        [Parameter (Mandatory = $false)]
        [Parameter (ParameterSetName = "id")]
        [int]$id,
        [Parameter (Mandatory = $false, Position = 1)]
        [Parameter (ParameterSetName = "client_id")]
        [string]$client_id,
        [Parameter (Mandatory = $false)]
        [Parameter (ParameterSetName = "grant_types")]
        [ValidateSet('client_credentials', 'password')]
        [string]$grant_types,
        [Parameter (Mandatory = $false)]
        [Parameter (ParameterSetName = "filter")]
        [string]$filter_attribute,
        [Parameter (Mandatory = $false)]
        [Parameter (ParameterSetName = "id")]
        [Parameter (ParameterSetName = "client_id")]
        [Parameter (ParameterSetName = "grant_types")]
        [Parameter (ParameterSetName = "filter")]
        [ValidateSet('equal', 'contains')]
        [string]$filter_type,
        [Parameter (Mandatory = $false)]
        [Parameter (ParameterSetName = "filter")]
        [psobject]$filter_value,
        [Parameter (Mandatory = $false)]
        [int]$limit,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCPConnection
    )

    Begin {
    }

    Process {

        $invokeParams = @{ }
        if ( $PsBoundParameters.ContainsKey('limit') ) {
            $invokeParams.add( 'limit', $limit )
        }

        switch ( $PSCmdlet.ParameterSetName ) {
            "id" {
                $filter_value = $id
                $filter_attribute = "id"
            }
            "client_id" {
                $filter_value = $client_id
                $filter_attribute = "client_id"
            }
            "grant_types" {
                $filter_value = $grant_types
                $filter_attribute = "grant_types"
            }
            default { }
        }

        if ( $PsBoundParameters.ContainsKey('filter_type') ) {
            switch ( $filter_type ) {
                "equal" {
                    $filter_value = @{ "`$eq" = $filter_value }
                }
                "contains" {
                    $filter_value = @{ "`$contains" = $filter_value }
                }
                default { }
            }
        }

        if ($filter_value -and $filter_attribute) {
            $filter = @{ $filter_attribute = $filter_value }
            $invokeParams.add( 'filter', $filter )
        }

        $uri = "api/api-client"

        $ac = Invoke-ArubaCPRestMethod -method "GET" -uri $uri @invokeParams -connection $connection

        $ac._embedded.items
    }

    End {
    }
}

function Remove-ArubaCPApiClient {

    <#
        .SYNOPSIS
        Remove an ApiClient on ClearPass

        .DESCRIPTION
        Remove an ApiClient on ClearPass

        .EXAMPLE
        $ac = Get-ArubaCPApiClient -client_id PowerArubaCP
        PS C:\>$ac | Remove-ArubaCPApiClient

        Remove API Client with client id PowerArubaCP

        .EXAMPLE
        Remove-ArubaCPEndpoint -id 3001 -confirm:$false

        Remove API Client with id 3001 and no confirmation
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'high')]
    Param(
        [Parameter (Mandatory = $true, ParameterSetName = "id")]
        [string]$id,
        [Parameter (Mandatory = $true, ValueFromPipeline = $true, Position = 1, ParameterSetName = "ac")]
        [ValidateScript( { Confirm-ArubaCPApiClient $_ })]
        [psobject]$ac,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCPConnection
    )

    Begin {
    }

    Process {

        #get ApiClient id from nad ps object
        if ($ac) {
            $id = $ac.client_id
        }

        $uri = "api/api-client/${id}"

        if ($PSCmdlet.ShouldProcess("$id", 'Remove API Client')) {
            Invoke-ArubaCPRestMethod -method "DELETE" -uri $uri -connection $connection
        }
    }

    End {
    }
}