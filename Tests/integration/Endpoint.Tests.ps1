#
# Copyright 2019, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1

BeforeAll {
    Connect-ArubaCP @invokeParams
}

Describe  "Get Endpoint" {

    BeforeAll {
        #Add 2 entries
        Add-ArubaCPEndpoint -mac_address 00-01-02-03-04-05 -description "Add by PowerArubaCP for Pester" -status Known
        Add-ArubaCPEndpoint -mac_address 00-01-02-03-04-06 -description "Add by PowerArubaCP for Pester" -status Unknown
    }

    It "Get Endpoint Does not throw an error" {
        {
            Get-ArubaCPEndpoint
        } | Should -Not -Throw
    }

    It "Get ALL Endpoint" {
        $ep = Get-ArubaCPEndpoint
        $ep.count | Should -Not -Be $NULL
    }

    It "Get Endpoint (00-01-02-03-04-05)" {
        $ep = Get-ArubaCPEndpoint | Where-Object { $_.mac_address -eq "000102030405" }
        $ep.id | Should -Not -BeNullOrEmpty
        $ep.mac_address | Should -Be "000102030405"
        $ep.description | Should -Be "Add by PowerArubaCP for Pester"
        $ep.status | Should -Be "Known"
    }

    It "Get Endpoint (00-01-02-03-04-06) and confirm (via Confirm-ArubaCPEndpoint)" {
        $ep = Get-ArubaCPEndpoint | Where-Object { $_.mac_address -eq "000102030406" }
        Confirm-ArubaCPEndpoint $ep | Should -Be $true
    }

    It "Search Endpoint by name (000102030405)" {
        $ep = Get-ArubaCPEndpoint -mac_address 00-01-02-03-04-05
        @($ep).count | Should -Be 1
        $ep.id | Should -Not -BeNullOrEmpty
        $ep.mac_address | Should -Be "000102030405"
        $ep.description | Should -Be "Add by PowerArubaCP for Pester"
    }

    It "Search Endpoint by description (contains *00-01-02-03-04*)" {
        $ep = Get-ArubaCPEndpoint -mac_address 00-01-02-03-04 -filter_type contains
        @($ep).count | Should -Be 2
    }

    It "Search Endpoint by attribute (description contains *pester*)" {
        $ep = Get-ArubaCPEndpoint -filter_attribute description -filter_type contains -filter_value pester
        @($ep).count | Should -Be 2
    }

    AfterAll {
        #Remove 2 entries
        Get-ArubaCPEndpoint -mac_address 00-01-02-03-04-05 | Remove-ArubaCPEndpoint -noconfirm
        Get-ArubaCPEndpoint -mac_address 00-01-02-03-04-06 | Remove-ArubaCPEndpoint -noconfirm
    }
}

Describe  "Add Endpoint" {

    It "Add Endpoint with Known Status" {
        Add-ArubaCPEndpoint -mac_address 00-01-02-03-04-05 -status Known
        $ep = Get-ArubaCPEndpoint -mac_address 00-01-02-03-04-05
        $ep.id | Should -Not -BeNullOrEmpty
        $ep.mac_address | Should -Be "000102030405"
        $ep.status | Should -Be "Known"
        $ep.attributes | Should -Be ""
    }

    It "Add Endpoint with Unknown Status and description" {
        Add-ArubaCPEndpoint -mac_address 00-01-02-03-04-05 -Status Unknown -description "Add By PowerArubaCP"
        $ep = Get-ArubaCPEndpoint -mac_address 00-01-02-03-04-05
        $ep.id | Should -Not -BeNullOrEmpty
        $ep.mac_address | Should -Be "000102030405"
        $ep.status | Should -Be "Unknown"
        $ep.description | Should -Be "Add By PowerArubaCP"
        $ep.attributes | Should -Be ""
    }

    It "Add Endpoint with Disable Status and an attribute" {
        $attributes = @{"Disabled by" = "PowerArubaCP" }
        Add-ArubaCPEndpoint -mac_address 00-01-02-03-04-05 -Status Disabled -attributes $attributes
        $ep = Get-ArubaCPEndpoint -mac_address 00-01-02-03-04-05
        $ep.id | Should -Not -BeNullOrEmpty
        $ep.mac_address | Should -Be "000102030405"
        $ep.status | Should -Be "Disabled"
        $ep.attributes.'Disabled by' | Should -Be "PowerArubaCP"
    }

    AfterEach {
        Get-ArubaCPEndpoint -mac_address 00-01-02-03-04-05 | Remove-ArubaCPEndpoint -noconfirm
    }
}

Describe  "Configure Endpoint" {
    BeforeEach {
        #Add 1 entry
        Add-ArubaCPEndpoint -mac_address 00-01-02-03-04-05 -status Known
    }

    It "Change Status Endpoint (Known => Unknown) and description" {
        Get-ArubaCPEndpoint -mac_address 00-01-02-03-04-05 | Set-ArubaCPEndpoint -status "Unknown" -description "Modified by PowerArubaCP"
        $ep = Get-ArubaCPEndpoint -mac_address 00-01-02-03-04-05
        $ep.id | Should -Not -BeNullOrEmpty
        $ep.mac_address | Should -Be "000102030405"
        $ep.status | Should -Be "Unknown"
        $ep.description | Should -Be "Modified by PowerArubaCP"
        $ep.attributes | Should -Be ""
    }

    It "Change status Endpoint (Known => Disabled) and attributes" {
        $attributes = @{"Disabled by" = "PowerArubaCP" }
        Get-ArubaCPEndpoint -mac_address 00-01-02-03-04-05 | Set-ArubaCPEndpoint -status "Disabled" -attributes $attributes
        $ep = Get-ArubaCPEndpoint -mac_address 00-01-02-03-04-05
        $ep.id | Should -Not -BeNullOrEmpty
        $ep.mac_address | Should -Be "000102030405"
        $ep.status | Should -Be "Disabled"
        $ep.attributes.'disabled by' | Should -Be "PowerArubaCP"
    }

    It "Change MAC Address Endpoint" {
        Get-ArubaCPEndpoint -mac_address 00-01-02-03-04-05 | Set-ArubaCPEndpoint -mac_address 00-01-02-03-04-06
        $ep = Get-ArubaCPEndpoint -mac_address 00-01-02-03-04-06
        $ep.id | Should -Not -BeNullOrEmpty
        $ep.mac_address | Should -Be "000102030406"
        $ep.status | Should -Be "Known"
        $ep.attributes | Should -Be ""
    }

    AfterEach {
        Get-ArubaCPEndpoint -mac_address 00-01-02-03-04-05 | Remove-ArubaCPEndpoint -noconfirm
        Get-ArubaCPEndpoint -mac_address 00-01-02-03-04-06 | Remove-ArubaCPEndpoint -noconfirm
    }
}
Describe  "Remove Endpoint" {

    It "Remove Endpoint by id" {
        Add-ArubaCPEndpoint -mac_address 00-01-02-03-04-05 -status Unknown
        $ep = Get-ArubaCPEndpoint -mac_address 00-01-02-03-04-05
        $ep.mac_address | Should -Be "000102030405"
        @($ep).count | Should -Be 1
        Remove-ArubaCPEndpoint -id $ep.id -noconfirm
        $ep = Get-ArubaCPEndpoint -mac_address 00-01-02-03-04-05
        $ep | Should -BeNullOrEmpty
        @($ep).count | Should -Be 0
    }

    It "Remove Endpoint by name (and pipeline)" {
        Add-ArubaCPEndpoint -mac_address 00-01-02-03-04-05 -status Unknown
        $ep = Get-ArubaCPEndpoint -mac_address 00-01-02-03-04-05
        $ep.mac_address | Should -Be "000102030405"
        @($ep).count | Should -Be 1
        Get-ArubaCPEndpoint -mac_address 00-01-02-03-04-05 | Remove-ArubaCPEndpoint -noconfirm
        $ep = Get-ArubaCPEndpoint -mac_address 00-01-02-03-04-05
        $ep | Should -BeNullOrEmpty
        @($ep).count | Should -Be 0
    }

    AfterEach {
        Get-ArubaCPEndpoint -mac_address 00-01-02-03-04-05 | Remove-ArubaCPEndpoint -noconfirm
    }
}

AfterAll {
    Disconnect-ArubaCP -noconfirm
}