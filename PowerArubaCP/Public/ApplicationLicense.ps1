#
# Copyright 2018-2020, Alexis La Goutte <alexis.lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Get-ArubaCPApplicationLicense {

    <#
        .SYNOPSIS
        Get Application License info on CPPM

        .DESCRIPTION
        Get Application License (Id, Name, Type, user Count...)

        .EXAMPLE
        Get-ArubaCPApplicationLicense

        Get ALL Application License  on the Clearpass

        .EXAMPLE
        Get-ArubaCPApplicationLicense -product_name Access

        Get info about Application License where product_name is Access

       .EXAMPLE
        Get-ArubaCPApplicationLicense -filter_attribute license_key -filter_type contains -filter_value 5S5C

        Get info about Application License where license_key contains 5S5C

    #>

    [CmdLetBinding(DefaultParameterSetName = "Default")]

    Param(
        [Parameter (Mandatory = $false)]
        [Parameter (ParameterSetName = "product_name")]
        [string]$product_name,
        [Parameter (Mandatory = $false)]
        [Parameter (ParameterSetName = "filter")]
        [string]$filter_attribute,
        [Parameter (Mandatory = $false)]
        [Parameter (ParameterSetName = "product_name")]
        [Parameter (ParameterSetName = "filter")]
        [ValidateSet('equal', 'contains')]
        [string]$filter_type,
        [Parameter (Mandatory = $false)]
        [Parameter (ParameterSetName = "filter")]
        [psobject]$filter_value,
        [Parameter (Mandatory = $false)]
        [int]$limit
    )

    Begin {
    }

    Process {

        $invokeParams = @{ }
        if ( $PsBoundParameters.ContainsKey('limit') ) {
            $invokeParams.add( 'limit', $limit )
        }

        switch ( $PSCmdlet.ParameterSetName ) {
            "product_name" {
                $filter_value = $product_name
                $filter_attribute = "product_name"
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

        $url = "api/application-license"

        $al = Invoke-ArubaCPRestMethod -method "GET" -uri $url @invokeParams

        $al._embedded.items
    }

    End {
    }
}

