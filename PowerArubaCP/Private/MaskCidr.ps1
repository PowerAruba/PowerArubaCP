
#
# Copyright 2018-2021, Alexis La Goutte <alexis.lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Convert-ArubaCPCIDR2Mask {

    <#
        .SYNOPSIS
        Convert a CIDR to Mask

        .DESCRIPTION
        Convert a CIDR to Mask

        .EXAMPLE
        Convert-ArubaCPCIDR2Mask 24

        Convert a CIDR (24) to Mask (255.255.255.0)

    #>
    Param(
        [Parameter (Mandatory = $true, ValueFromPipeline)]
        [int]$cidr
    )

    switch ($cidr) {
        "0" {
            $subnet = '0.0.0.0'
        }
        "1" {
            $subnet = '128.0.0.0'
        }
        "2" {
            $subnet = '192.0.0.0'
        }
        "3" {
            $subnet = '224.0.0.0'
        }
        "4" {
            $subnet = '240.0.0.0'
        }
        "5" {
            $subnet = '248.0.0.0'
        }
        "6" {
            $subnet = '252.0.0.0'
        }
        "7" {
            $subnet = '254.0.0.0'
        }
        "8" {
            $subnet = '255.0.0.0'
        }
        "9" {
            $subnet = '255.128.0.0'
        }
        "10" {
            $subnet = '255.192.0.0'
        }
        "11" {
            $subnet = '255.224.0.0'
        }
        "12" {
            $subnet = '255.240.0.0'
        }
        "13" {
            $subnet = '255.248.0.0'
        }
        "14" {
            $subnet = '255.252.0.0'
        }
        "15" {
            $subnet = '255.254.0.0'
        }
        "16" {
            $subnet = '255.255.0.0'
        }
        "17" {
            $subnet = '255.255.128.0'
        }
        "18" {
            $subnet = '255.255.192.0'
        }
        "19" {
            $subnet = '255.255.224.0'
        }
        "20" {
            $subnet = '255.255.240.0'
        }
        "21" {
            $subnet = '255.255.248.0'
        }
        "22" {
            $subnet = '255.255.252.0'
        }
        "23" {
            $subnet = '255.255.254.0'
        }
        "24" {
            $subnet = '255.255.255.0'
        }
        "25" {
            $subnet = '255.255.255.128'
        }
        "26" {
            $subnet = '255.255.255.192'
        }
        "27" {
            $subnet = '255.255.255.224'
        }
        "28" {
            $subnet = '255.255.255.240'
        }
        "29" {
            $subnet = '255.255.255.248'
        }
        "30" {
            $subnet = '255.255.255.252'
        }
        "31" {
            $subnet = '255.255.255.254'
        }
        "32" {
            $subnet = '255.255.255.255'
        }
    }

    $subnet

}
