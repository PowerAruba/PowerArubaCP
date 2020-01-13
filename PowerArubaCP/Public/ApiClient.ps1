#
# Copyright 2018-2020, Alexis La Goutte <alexis.lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#


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