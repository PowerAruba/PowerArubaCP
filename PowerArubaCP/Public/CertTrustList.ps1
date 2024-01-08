#
# Copyright 2021, Alexis La Goutte <alexis.lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Get-ArubaCPCertTrustList {

    <#
        .SYNOPSIS
        Get Certificate Trusted List on CPPM

        .DESCRIPTION
        Get Certificate Trusted List (Id, file, enabled, Usage ...)

        .EXAMPLE
        Get-ArubaCPCertTrustList

        Get ALL Certificate Trusted Lists on the Clearpass

        .EXAMPLE
        Get-ArubaCPCertTrustList -id 23

        Get info about Cert Trust List id 23 on the ClearPass

        .EXAMPLE
        Get-ArubaCPCertTrustList Aruba -filter_type contains

        Get info about Cert Trust List where cert usage contains Aruba

       .EXAMPLE
        Get-ArubaCPCertTrustList -filter_attribute enabled -filter_type equal -filter_value True

        Get info about Cert Trust List where enabled equal True

    #>

    [CmdLetBinding(DefaultParameterSetName = "Default")]

    Param(
        [Parameter (Mandatory = $false)]
        [Parameter (ParameterSetName = "id")]
        [int]$id,
        [Parameter (Mandatory = $false)]
        [Parameter (ParameterSetName = "cert_usage")]
        [string]$cert_usage,
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
            "cert_usage" {
                $filter_value = $name
                $filter_attribute = "cert_usage"
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

        $uri = "api/cert-trust-list"

        $ctl = Invoke-ArubaCPRestMethod -method "GET" -uri $uri @invokeParams -connection $connection
        $ctl._embedded.items
    }

    End {
    }
}