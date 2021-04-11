#
# Copyright 2021, Alexis La Goutte <alexis.lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Get-ArubaCPAuthSource {

    <#
        .SYNOPSIS
        Get Authentication Source on CPPM

        .DESCRIPTION
        Get Auth Source (Id, Name, Type, Host Name, ....)

        .EXAMPLE
        Get-ArubaCPAuthSource

        Get ALL Auth Source on the Clearpass

        .EXAMPLE
        Get-ArubaCPAuthSource PowerArubaCP

        Get info about Auth Source PowerArubaCP on the ClearPass

        .EXAMPLE
        Get-ArubaCPAuthSource -id 23

        Get info about Auth Source id 23 on the ClearPass

        .EXAMPLE
        Get-ArubaCPAuthSource PowerArubaCP -filter_type contains

        Get info about Auth Source where name contains PowerArubaCP

       .EXAMPLE
        Get-ArubaCPAuthSource -filter_attribute type -filter_type equal -filter_value ldap

        Get info about Auth Source where type equal ldap

    #>

    [CmdLetBinding(DefaultParameterSetName = "Default")]

    Param(
        [Parameter (Mandatory = $false)]
        [Parameter (ParameterSetName = "id")]
        [int]$id,
        [Parameter (Mandatory = $false, Position = 1)]
        [Parameter (ParameterSetName = "name")]
        [string]$Name,
        [Parameter (Mandatory = $false)]
        [Parameter (ParameterSetName = "filter")]
        [string]$filter_attribute,
        [Parameter (Mandatory = $false)]
        [Parameter (ParameterSetName = "id")]
        [Parameter (ParameterSetName = "name")]
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
            "name" {
                $filter_value = $name
                $filter_attribute = "name"
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

        $uri = "api/auth-source"

        $as = Invoke-ArubaCPRestMethod -method "GET" -uri $uri @invokeParams -connection $connection

        $as._embedded.items
    }

    End {
    }
}