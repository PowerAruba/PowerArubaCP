#
# Copyright 2018-2020, Alexis La Goutte <alexis.lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Format-ArubaCPMacAddress {

    <#
        .SYNOPSIS
        Format Mac Address

        .DESCRIPTION
        Format Mac Address

        .EXAMPLE
        Format-ArubaCPMacAddress 00:01:02:03:04:05

        Format Mac Address (Remove Dash, Colon, dots Whitespace....)

    #>
    Param(
        [Parameter (Mandatory = $true)]
        [string]$mac
    )

    #From https://github.com/lazywinadmin/PowerShell/blob/master/TOOL-Clean-MacAddress/Clean-MacAddress.ps1
    $mac_clean = $mac
    $mac_clean = $mac_clean -replace "-", "" #Replace Dash
    $mac_clean = $mac_clean -replace ":", "" #Replace Colon
    $mac_clean = $mac_clean -replace "/s", "" #Remove whitespace
    $mac_clean = $mac_clean -replace " ", "" #Remove whitespace
    $mac_clean = $mac_clean -replace "\.", "" #Remove dots
    $mac_clean = $mac_clean.trim() #Remove space at the beginning
    $mac_clean = $mac_clean.trimend() #Remove space at the end

    $mac_clean
}