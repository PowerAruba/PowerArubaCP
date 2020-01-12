#
# Copyright 2019, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1

Describe  "Get Static Host List" {

    BeforeAll {
        #Add 2 entries
        Add-ArubaCPStaticHostList -name pester_SHL-list-IPAddress -host_format list -host_type IPAddress -host_entries_address 192.0.2.1 -host_entries_description "Add via PowerArubaCP"
        Add-ArubaCPStaticHostList -name pester_SHL-list-MACAddress -host_format list -host_type MACAddress -host_entries_address 00:01:02:03:04:05 -host_entries_description "Add via PowerArubaCP"
    }

    It "Get Static Host List Does not throw an error" {
        {
            Get-ArubaCPStaticHostList
        } | Should Not Throw
    }

    It "Get ALL Static Host List" {
        $shl = Get-ArubaCPStaticHostList
        $shl.count | Should not be $NULL
    }

    It "Get Static Host List (pester_SHL-list-IPAddress)" {
        $shl = Get-ArubaCPStaticHostList | Where-Object { $_.name -eq "pester_SHL-list-IPAddress" }
        $shl.id | Should not be BeNullOrEmpty
        $shl.name | Should be "pester_SHL-list-IPAddress"
    }

    It "Get Static Host List (pester_SHL-list-IPAddress) and confirm (via Confirm-ArubaCPStaticHostList)" {
        $shl = Get-ArubaCPStaticHostList | Where-Object { $_.name -eq "pester_SHL-list-IPAddress" }
        Confirm-ArubaCPStaticHostList $shl | Should be $true
    }

    It "Search Static Host List by name (pester_SHL-list-MACAddress)" {
        $shl = Get-ArubaCPStaticHostList -name pester_SHL-list-MACAddress
        @($shl).count | Should be 1
        $shl.id | Should not be BeNullOrEmpty
        $shl.name | Should be "pester_SHL-list-MACAddress"
    }

    It "Search Static Host List by name (contains *pester*)" {
        $shl = Get-ArubaCPStaticHostList -name pester -filter_type contains
        @($shl).count | Should be 2
    }

    AfterAll {
        #Remove 2 entries
        Get-ArubaCPStaticHostList -name pester_SHL-list-IPAddress | Remove-ArubaCPStaticHostList -noconfirm
        Get-ArubaCPStaticHostList -name pester_SHL-list-MACAddress | Remove-ArubaCPStaticHostList -noconfirm
    }
}

Describe  "Add Static Host List" {

    It "Add Static Host List with format list and type IPAddress" {
        Add-ArubaCPStaticHostList -name pester_SHL -host_format list -host_type IPAddress -host_entries_address 192.0.2.1 -host_entries_description "Add via PowerArubaCP"
        $shl = Get-ArubaCPStaticHostList -name pester_SHL
        $shl.id | Should not be BeNullOrEmpty
        $shl.name | Should be "pester_SHL"
        $shl.host_format | Should be "list"
        $shl.host_type | Should be "IPAddress"
        $shl.host_entries[0].host_address | Should be "192.0.2.1"
        $shl.host_entries[0].host_address_desc | Should be "Add via PowerArubaCP"
    }


    It "Add Static Host List with format list and type IPAddress (and add/remove second entries)" {
        Add-ArubaCPStaticHostList -name pester_SHL -host_format list -host_type IPAddress -host_entries_address 192.0.2.1 -host_entries_description "Add via PowerArubaCP"
        Get-ArubaCPStaticHostList -name pester_SHL | Add-ArubaCPStaticHostListMember -host_entries_address 192.0.2.2 -host_entries_description "Add via ArubaCPStaticHostListMember"
        $shl = Get-ArubaCPStaticHostList -name pester_SHL
        $shl.id | Should not be BeNullOrEmpty
        $shl.name | Should be "pester_SHL"
        $shl.host_format | Should be "list"
        $shl.host_type | Should be "IPAddress"
        ($shl.host_entries).count | Should be "2"
        $shl.host_entries[0].host_address | Should be "192.0.2.1"
        $shl.host_entries[0].host_address_desc | Should be "Add via PowerArubaCP"
        $shl.host_entries[1].host_address | Should be "192.0.2.2"
        $shl.host_entries[1].host_address_desc | Should be "Add via ArubaCPStaticHostListMember"
        #Remove a entries...
        $shl = Get-ArubaCPStaticHostList -name pester_SHL | Remove-ArubaCPStaticHostListMember -host_entries_address 192.0.2.1
        ($shl.host_entries).count | Should be "1"
    }

    It "Add Static Host List with format list and type MACAddress" {
        Add-ArubaCPStaticHostList -name pester_SHL -host_format list -host_type MACAddress -host_entries_address 00:01:02:03:04:05 -host_entries_description "Add via PowerArubaCP"
        $shl = Get-ArubaCPStaticHostList -name pester_SHL
        $shl.id | Should not be BeNullOrEmpty
        $shl.name | Should be "pester_SHL"
        $shl.host_format | Should be "list"
        $shl.host_type | Should be "MACAddress"
        $shl.host_entries[0].host_address | Should be "00:01:02:03:04:05"
        $shl.host_entries[0].host_address_desc | Should be "Add via PowerArubaCP"
    }

    It "Add Static Host List with format list and type MACAddress (and add/remove second entries)" {
        Add-ArubaCPStaticHostList -name pester_SHL -host_format list -host_type MACAddress -host_entries_address 00:01:02:03:04:05 -host_entries_description "Add via PowerArubaCP"
        Get-ArubaCPStaticHostList -name pester_SHL | Add-ArubaCPStaticHostListMember -host_entries_address 00:01:02:03:04:06 -host_entries_description "Add via ArubaCPStaticHostListMember"
        $shl = Get-ArubaCPStaticHostList -name pester_SHL
        $shl.id | Should not be BeNullOrEmpty
        $shl.name | Should be "pester_SHL"
        $shl.host_format | Should be "list"
        $shl.host_type | Should be "MACAddress"
        ($shl.host_entries).count | Should be "2"
        $shl.host_entries[0].host_address | Should be "00:01:02:03:04:05"
        $shl.host_entries[0].host_address_desc | Should be "Add via PowerArubaCP"
        $shl.host_entries[1].host_address | Should be "00:01:02:03:04:06"
        $shl.host_entries[1].host_address_desc | Should be "Add via ArubaCPStaticHostListMember"
        #Remove a entries...
        $shl = Get-ArubaCPStaticHostList -name pester_SHL | Remove-ArubaCPStaticHostListMember -host_entries_address 00:01:02:03:04:05
        ($shl.host_entries).count | Should be "1"
    }

    It "Add Static Host List with format list and type IPAddress (add multiple entries on same time)" {
        Add-ArubaCPStaticHostList -name pester_SHL -host_format list -host_type IPAddress -host_entries_address 192.0.2.1, 192.0.2.2 -host_entries_description "pester entry 1", "pester entry 2"
        $shl = Get-ArubaCPStaticHostList -name pester_SHL
        $shl.id | Should not be BeNullOrEmpty
        $shl.name | Should be "pester_SHL"
        $shl.host_format | Should be "list"
        $shl.host_type | Should be "IPAddress"
        $shl.host_entries[0].host_address | Should be "192.0.2.1"
        $shl.host_entries[0].host_address_desc | Should be "pester entry 1"
        $shl.host_entries[1].host_address | Should be "192.0.2.2"
        $shl.host_entries[1].host_address_desc | Should be "pester entry 2"
    }

    It "Add Static Host List with format list and type MACAddress (add multiple entries on same time without second description)" {
        Add-ArubaCPStaticHostList -name pester_SHL -host_format list -host_type MACAddress -host_entries_address 00:01:02:03:04:05, 00:01:02:03:04:06 -host_entries_description "pester entry 1"
        $shl = Get-ArubaCPStaticHostList -name pester_SHL
        $shl.id | Should not be BeNullOrEmpty
        $shl.name | Should be "pester_SHL"
        $shl.host_format | Should be "list"
        $shl.host_type | Should be "MACAddress"
        $shl.host_entries[0].host_address | Should be "00:01:02:03:04:05"
        $shl.host_entries[0].host_address_desc | Should be "pester entry 1"
        $shl.host_entries[1].host_address | Should be "00:01:02:03:04:06"
        $shl.host_entries[1].host_address_desc | Should be "Add via PowerArubaCP"
    }


    AfterEach {
        Get-ArubaCPStaticHostList -name pester_SHL | Remove-ArubaCPStaticHostList -noconfirm
    }
}


Describe  "Set Static Host List" {
    BeforeEach {
        Add-ArubaCPStaticHostList -name pester_SHL -host_format list -host_type MACAddress -host_entries_address 00:01:02:03:04:05 -host_entries_description "Add via PowerArubaCP"
    }

    It "Set Static Host List (Name and Description)" {
        Get-ArubaCPStaticHostList -name pester_SHL | Set-ArubaCPStaticHostList -name pester_SHL2 -description "Change via PowerArubaCP"
        $shl = Get-ArubaCPStaticHostList -name pester_SHL2
        $shl.name | Should be "pester_SHL2"
        $shl.description | Should be "Change via PowerArubaCP"
    }

    It "Set Static Host List (host_entries)" {
        $host_entries = @()
        $host_entries += @{ host_address = "00:01:02:03:04:06"; host_address_desc = "Change via PowerArubaCP" }
        Get-ArubaCPStaticHostList -name pester_SHL | Set-ArubaCPStaticHostList -host_entries $host_entries
        $shl = Get-ArubaCPStaticHostList -name pester_SHL
        ($shl.host_entries).count | Should be "1"
        $shl.host_entries[0].host_address | Should be "00:01:02:03:04:06"
        $shl.host_entries[0].host_address_desc | Should be "Change via PowerArubaCP"
        $host_entries = @()
        $host_entries += @{ host_address = "00:01:02:03:04:05"; host_address_desc = "Change via PowerArubaCP" }
        $host_entries += @{ host_address = "00:01:02:03:04:06"; host_address_desc = "Change via PowerArubaCP" }
        Get-ArubaCPStaticHostList -name pester_SHL | Set-ArubaCPStaticHostList -host_entries $host_entries
        $shl = Get-ArubaCPStaticHostList -name pester_SHL
        ($shl.host_entries).count | Should be "2"
        $shl.host_entries[0].host_address | Should be "00:01:02:03:04:05"
        $shl.host_entries[0].host_address_desc | Should be "Change via PowerArubaCP"
        $shl.host_entries[1].host_address | Should be "00:01:02:03:04:06"
        $shl.host_entries[1].host_address_desc | Should be "Change via PowerArubaCP"
    }

    AfterEach {
        Get-ArubaCPStaticHostList -name pester_SHL | Remove-ArubaCPStaticHostList -noconfirm
        Get-ArubaCPStaticHostList -name pester_SHL2 | Remove-ArubaCPStaticHostList -noconfirm
    }
}

Describe  "Remove Static Host List" {

    It "Remove Static Host List by id" {
        Add-ArubaCPStaticHostList -name pester_SHL -host_format list -host_type IPAddress -host_entries_address 192.0.2.1 -host_entries_description "Add via PowerArubaCP"
        $shl = Get-ArubaCPStaticHostList -name pester_SHL
        $shl.name | Should be "pester_SHL"
        @($shl).count | should be 1
        Remove-ArubaCPStaticHostList -id $shl.id -noconfirm
        $shl = Get-ArubaCPStaticHostList -name pester_SHL
        $shl | Should BeNullOrEmpty
        @($shl).count | should be 0
    }

    It "Remove Static Host List by name (and pipeline)" {
        Add-ArubaCPStaticHostList -name pester_SHL -host_format list -host_type IPAddress -host_entries_address 192.0.2.1 -host_entries_description "Add via PowerArubaCP"
        $shl = Get-ArubaCPStaticHostList -name pester_SHL
        $shl.name | Should be "pester_SHL"
        @($shl).count | should be 1
        Get-ArubaCPStaticHostList -name pester_SHL | Remove-ArubaCPStaticHostList -noconfirm
        $shl = Get-ArubaCPStaticHostList -name pester_SHL
        $shl | Should BeNullOrEmpty
        @($shl).count | should be 0
    }

    AfterEach {
        Get-ArubaCPStaticHostList -name pester_SHL | Remove-ArubaCPStaticHostList -noconfirm
    }
}

Disconnect-ArubaCP -noconfirm