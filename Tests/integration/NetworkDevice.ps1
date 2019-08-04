#
# Copyright 2019, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1

Describe  "Get Network Device" {

    BeforeAll {
        #Add 2 entries
        Add-ArubaCPNetworkDevice -name pester_SW1 -ip_address 192.0.2.1 -radius_secret MySecurePassword -vendor Aruba -description "Add by PowerArubaCP"
        Add-ArubaCPNetworkDevice -name pester_SW2 -ip_address 192.0.2.2 -radius_secret MySecurePassword -vendor Hewlett-Packard-Enterprise -description "Add by PowerArubaCP"
    }

    It "Get NetworkDevice Does not throw an error" {
        {
            Get-ArubaCPNetworkDevice
        } | Should Not Throw
    }

    It "Get ALL Network Device" {
        $nad = Get-ArubaCPNetworkDevice
        $nad.count | Should not be $NULL
    }

    It "Get Network Device (pester_SW1)" {
        $nad = Get-ArubaCPNetworkDevice | Where-Object { $_.name -eq "pester_SW1" }
        $nad.id | Should not be BeNullOrEmpty
        $nad.name | Should be "pester_SW1"
        $nad.description | Should be "Add by PowerArubaCP"
        $nad.ip_address | Should be "192.0.2.1"
        $nad.vendor_name | Should be "Aruba"
        $nad.coa_capable | Should be "False"
        $nad.coa_port | Should be "3799"
    }

    It "Search Network Device by name (pester_SW2)" {
        $nad = Get-ArubaCPNetworkDevice -name pester_SW2
        $nad.count | Should be 1
        $nad.id | Should not be BeNullOrEmpty
        $nad.name | Should be "pester_SW2"
        $nad.description | Should be "Add by PowerArubaCP"
    }
    AfterAll {
        #Remove 2 entries
        Get-ArubaCPNetworkDevice -name pester_SW1 | Remove-ArubaCPNetworkDevice -noconfirm
        Get-ArubaCPNetworkDevice -name pester_SW2 | Remove-ArubaCPNetworkDevice -noconfirm
    }
}