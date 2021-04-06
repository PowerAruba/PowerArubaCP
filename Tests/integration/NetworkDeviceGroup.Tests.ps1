#
# Copyright 2019, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1

BeforeAll {
    Connect-ArubaCP @invokeParams
}

Describe "Get Network Device Group" {

    BeforeAll {
        #Add 2 entries
        Add-ArubaCPNetworkDeviceGroup -name pester_NDG-subnet1 -subnet 192.0.2.0/24 -description "Add via PowerArubaCP"
        Add-ArubaCPNetworkDeviceGroup -name pester_NDG-subnet2 -subnet 198.51.100.0/24 -description "Add via PowerArubaCP"
    }

    It "Get Network Device Group Does not throw an error" {
        {
            Get-ArubaCPNetworkDeviceGroup
        } | Should -Not -Throw
    }

    It "Get ALL Network Device Group" {
        $ndg = Get-ArubaCPNetworkDeviceGroup
        $ndg.count | Should -Not -Be be $NULL
    }

    It "Get Network Device Group (pester_NDG-subnet1)" {
        $ndg = Get-ArubaCPNetworkDeviceGroup | Where-Object { $_.name -eq "pester_NDG-subnet1" }
        $ndg.id | Should -Not -BeNullOrEmpty
        $ndg.name | Should -Be "pester_NDG-subnet1"
    }

    It "Get Network Device Group (pester_NDG-subnet1) and confirm (via Confirm-ArubaCPNetworkDeviceGroup)" {
        $ndg = Get-ArubaCPNetworkDeviceGroup | Where-Object { $_.name -eq "pester_NDG-subnet1" }
        Confirm-ArubaCPNetworkDeviceGroup $ndg | Should -Be $true
    }

    It "Search Network Device Group by name (pester_NDG-subnet2)" {
        $ndg = Get-ArubaCPNetworkDeviceGroup -name pester_NDG-subnet2
        @($ndg).count | Should -Be 1
        $ndg.id | Should -Not -BeNullOrEmpty
        $ndg.name | Should -Be "pester_NDG-subnet2"
    }

    It "Search Network Device Group by name (contains *pester*)" {
        $ndg = Get-ArubaCPNetworkDeviceGroup -name pester -filter_type contains
        @($ndg).count | Should -Be 2
    }

    AfterAll {
        #Remove 2 entries
        Get-ArubaCPNetworkDeviceGroup -name pester_NDG-subnet1 | Remove-ArubaCPNetworkDeviceGroup -confirm:$false
        Get-ArubaCPNetworkDeviceGroup -name pester_NDG-subnet2 | Remove-ArubaCPNetworkDeviceGroup -confirm:$false
    }
}

Describe "Add Network Device Group" {

    BeforeAll {
        #Add 2 entries
        Add-ArubaCPNetworkDevice -name pester_SW1 -ip_address 192.0.2.1 -radius_secret MySecurePassword -vendor Aruba -description "Add by PowerArubaCP"
        Add-ArubaCPNetworkDevice -name pester_SW2 -ip_address 192.0.2.2 -radius_secret MySecurePassword -vendor Hewlett-Packard-Enterprise -description "Add by PowerArubaCP"
    }

    It "Add Network Device Group with format list (with one IP)" {
        Add-ArubaCPNetworkDeviceGroup -name pester_NDG -description "Add via PowerArubaCP" -list_ip 192.0.2.1
        $ndg = Get-ArubaCPNetworkDeviceGroup -name pester_NDG
        $ndg.id | Should -Not -BeNullOrEmpty
        $ndg.name | Should -Be "pester_NDG"
        $ndg.description | Should -Be "Add via PowerArubaCP"
        $ndg.group_format | Should -Be "list"
        $ndg.value | Should -Be "192.0.2.1"
    }

    It "Add Network Device Group with format list (with 2 IP)" {
        Add-ArubaCPNetworkDeviceGroup -name pester_NDG -description "Add via PowerArubaCP" -list_ip 192.0.2.1, 192.0.2.2
        $ndg = Get-ArubaCPNetworkDeviceGroup -name pester_NDG
        $ndg.id | Should -Not -BeNullOrEmpty
        $ndg.name | Should -Be "pester_NDG"
        $ndg.description | Should -Be "Add via PowerArubaCP"
        $ndg.group_format | Should -Be "list"
        $ndg.value | Should -Be "192.0.2.1, 192.0.2.2"
    }

    It "Add Network Device Group with format subnet" {
        Add-ArubaCPNetworkDeviceGroup -name pester_NDG -description "Add via PowerArubaCP" -subnet 192.0.2.0/24
        $ndg = Get-ArubaCPNetworkDeviceGroup -name pester_NDG
        $ndg.id | Should -Not -BeNullOrEmpty
        $ndg.name | Should -Be "pester_NDG"
        $ndg.description | Should -Be "Add via PowerArubaCP"
        $ndg.group_format | Should -Be "subnet"
        $ndg.value | Should -Be "192.0.2.0/24"
    }

    It "Add Network Device Group with format regex" {
        Add-ArubaCPNetworkDeviceGroup -name pester_NDG -description "Add via PowerArubaCP" -regex "^192(.[0-9]*){3}$"
        $ndg = Get-ArubaCPNetworkDeviceGroup -name pester_NDG
        $ndg.id | Should -Not -BeNullOrEmpty
        $ndg.name | Should -Be "pester_NDG"
        $ndg.description | Should -Be "Add via PowerArubaCP"
        $ndg.group_format | Should -Be "regex"
        $ndg.value | Should -Be "^192(.[0-9]*){3}$"
    }

    AfterEach {
        Get-ArubaCPNetworkDeviceGroup -name pester_NDG | Remove-ArubaCPNetworkDeviceGroup -confirm:$false
    }

    AfterAll {
        #Remove 2 entries
        Get-ArubaCPNetworkDevice -name pester_SW1 | Remove-ArubaCPNetworkDevice -confirm:$false
        Get-ArubaCPNetworkDevice -name pester_SW2 | Remove-ArubaCPNetworkDevice -confirm:$false
    }
}

Describe "Add Firewall Address Group Member" {

    BeforeAll {
        #Add 3 entries
        Add-ArubaCPNetworkDevice -name pester_SW1 -ip_address 192.0.2.1 -radius_secret MySecurePassword -vendor Aruba -description "Add by PowerArubaCP"
        Add-ArubaCPNetworkDevice -name pester_SW2 -ip_address 192.0.2.2 -radius_secret MySecurePassword -vendor Hewlett-Packard-Enterprise -description "Add by PowerArubaCP"
        Add-ArubaCPNetworkDevice -name pester_SW3 -ip_address 192.0.2.3 -radius_secret MySecurePassword -vendor Aruba -description "Add by PowerArubaCP"
    }

    BeforeEach {
        Add-ArubaCPNetworkDeviceGroup -name pester_NDG -description "Add via PowerArubaCP" -list_ip 192.0.2.1
    }

    It "Add 1 member to Network Device Group to list_ip (with 1 member before)" {
        Get-ArubaCPNetworkDeviceGroup -name pester_NDG | Add-ArubaCPNetworkDeviceGroupMember -list_ip 192.0.2.2
        $ndg = Get-ArubaCPNetworkDeviceGroup -name pester_NDG
        $ndg.id | Should -Not -BeNullOrEmpty
        $ndg.name | Should -Be "pester_NDG"
        $ndg.description | Should -Be "Add via PowerArubaCP"
        $ndg.group_format | Should -Be "list"
        $ndg.value | Should -Be "192.0.2.1, 192.0.2.2"
    }

    It "Add 2 members to Network Device Group to list_ip (with 1 member before)" {
        Get-ArubaCPNetworkDeviceGroup -name pester_NDG | Add-ArubaCPNetworkDeviceGroupMember -list_ip 192.0.2.2, 192.0.2.3
        $ndg = Get-ArubaCPNetworkDeviceGroup -name pester_NDG
        $ndg.id | Should -Not -BeNullOrEmpty
        $ndg.name | Should -Be "pester_NDG"
        $ndg.description | Should -Be "Add via PowerArubaCP"
        $ndg.group_format | Should -Be "list"
        $ndg.value | Should -Be "192.0.2.1, 192.0.2.2, 192.0.2.3"
    }

    AfterEach {
        Get-ArubaCPNetworkDeviceGroup -name pester_NDG | Remove-ArubaCPNetworkDeviceGroup -confirm:$false
        Get-ArubaCPNetworkDeviceGroup -name pester_NDG2 | Remove-ArubaCPNetworkDeviceGroup -confirm:$false
    }

    AfterAll {
        #Remove 2 entries
        Get-ArubaCPNetworkDevice -name pester_SW1 | Remove-ArubaCPNetworkDevice -confirm:$false
        Get-ArubaCPNetworkDevice -name pester_SW2 | Remove-ArubaCPNetworkDevice -confirm:$false
        Get-ArubaCPNetworkDevice -name pester_SW3 | Remove-ArubaCPNetworkDevice -confirm:$false
    }

}

Describe "Set Network Device Group" {

    BeforeAll {
        #Add 3 entries
        Add-ArubaCPNetworkDevice -name pester_SW1 -ip_address 192.0.2.1 -radius_secret MySecurePassword -vendor Aruba -description "Add by PowerArubaCP"
        Add-ArubaCPNetworkDevice -name pester_SW2 -ip_address 192.0.2.2 -radius_secret MySecurePassword -vendor Hewlett-Packard-Enterprise -description "Add by PowerArubaCP"
        Add-ArubaCPNetworkDevice -name pester_SW3 -ip_address 192.0.2.3 -radius_secret MySecurePassword -vendor Aruba -description "Add by PowerArubaCP"
    }

    BeforeEach {
        Add-ArubaCPNetworkDeviceGroup -name pester_NDG -description "Add via PowerArubaCP" -list_ip 192.0.2.1
    }

    It "Set Network Device Group (Name and Description)" {
        Get-ArubaCPNetworkDeviceGroup -name pester_NDG | Set-ArubaCPNetworkDeviceGroup -name pester_NDG2 -description "Change via PowerArubaCP"
        $ndg = Get-ArubaCPNetworkDeviceGroup -name pester_NDG2
        $ndg.name | Should -Be "pester_NDG2"
        $ndg.description | Should -Be "Change via PowerArubaCP"
    }

    It "Set Network Device Group (Change to list_ip with 1 IP)" {
        Get-ArubaCPNetworkDeviceGroup -name pester_NDG | Set-ArubaCPNetworkDeviceGroup -list_ip 192.0.2.2
        $ndg = Get-ArubaCPNetworkDeviceGroup -name pester_NDG
        $ndg.id | Should -Not -BeNullOrEmpty
        $ndg.name | Should -Be "pester_NDG"
        $ndg.description | Should -Be "Add via PowerArubaCP"
        $ndg.group_format | Should -Be "list"
        $ndg.value | Should -Be "192.0.2.2"
    }

    It "Set Network Device Group (Change to list_ip with 2 IP)" {
        Get-ArubaCPNetworkDeviceGroup -name pester_NDG | Set-ArubaCPNetworkDeviceGroup -list_ip 192.0.2.2, 192.0.2.3
        $ndg = Get-ArubaCPNetworkDeviceGroup -name pester_NDG
        $ndg.id | Should -Not -BeNullOrEmpty
        $ndg.name | Should -Be "pester_NDG"
        $ndg.description | Should -Be "Add via PowerArubaCP"
        $ndg.group_format | Should -Be "list"
        $ndg.value | Should -Be "192.0.2.2, 192.0.2.3"
    }

    It "Set Network Device Group (Change to subnet)" {
        Get-ArubaCPNetworkDeviceGroup -name pester_NDG | Set-ArubaCPNetworkDeviceGroup -subnet 192.0.2.0/24
        $ndg = Get-ArubaCPNetworkDeviceGroup -name pester_NDG
        $ndg.id | Should -Not -BeNullOrEmpty
        $ndg.name | Should -Be "pester_NDG"
        $ndg.description | Should -Be "Add via PowerArubaCP"
        $ndg.group_format | Should -Be "subnet"
        $ndg.value | Should -Be "192.0.2.0/24"
    }

    It "Set Network Device Group (Change to regex)" {
        Get-ArubaCPNetworkDeviceGroup -name pester_NDG | Set-ArubaCPNetworkDeviceGroup -regex "^192(.[0-9]*){3}$"
        $ndg = Get-ArubaCPNetworkDeviceGroup -name pester_NDG
        $ndg.id | Should -Not -BeNullOrEmpty
        $ndg.name | Should -Be "pester_NDG"
        $ndg.description | Should -Be "Add via PowerArubaCP"
        $ndg.group_format | Should -Be "regex"
        $ndg.value | Should -Be "^192(.[0-9]*){3}$"
    }

    AfterEach {
        Get-ArubaCPNetworkDeviceGroup -name pester_NDG | Remove-ArubaCPNetworkDeviceGroup -confirm:$false
        Get-ArubaCPNetworkDeviceGroup -name pester_NDG2 | Remove-ArubaCPNetworkDeviceGroup -confirm:$false
    }

    AfterAll {
        #Remove 2 entries
        Get-ArubaCPNetworkDevice -name pester_SW1 | Remove-ArubaCPNetworkDevice -confirm:$false
        Get-ArubaCPNetworkDevice -name pester_SW2 | Remove-ArubaCPNetworkDevice -confirm:$false
        Get-ArubaCPNetworkDevice -name pester_SW3 | Remove-ArubaCPNetworkDevice -confirm:$false
    }
}

Describe "Remove Network Device Group" {

    It "Remove Network Device Group by id" {
        Add-ArubaCPNetworkDeviceGroup -name pester_NDG -subnet 192.0.2.0/24
        $ndg = Get-ArubaCPNetworkDeviceGroup -name pester_NDG
        $ndg.name | Should -Be "pester_NDG"
        @($ndg).count | Should -Be 1
        Remove-ArubaCPNetworkDeviceGroup -id $ndg.id -confirm:$false
        $ndg = Get-ArubaCPNetworkDeviceGroup -name pester_NDG
        $ndg | Should -BeNullOrEmpty
        @($ndg).count | Should -Be 0
    }

    It "Remove Network Device Group by name (and pipeline)" {
        Add-ArubaCPNetworkDeviceGroup -name pester_NDG -subnet 192.0.2.0/24
        $ndg = Get-ArubaCPNetworkDeviceGroup -name pester_NDG
        $ndg.name | Should -Be "pester_NDG"
        @($ndg).count | Should -Be 1
        Get-ArubaCPNetworkDeviceGroup -name pester_NDG | Remove-ArubaCPNetworkDeviceGroup -confirm:$false
        $ndg = Get-ArubaCPNetworkDeviceGroup -name pester_NDG
        $ndg | Should -BeNullOrEmpty
        @($ndg).count | Should -Be 0
    }

    AfterEach {
        Get-ArubaCPNetworkDeviceGroup -name pester_NDG | Remove-ArubaCPNetworkDeviceGroup -confirm:$false
    }

}

Describe "Remove Network Device Group Member" {

    BeforeAll {
        #Add 3 entries
        Add-ArubaCPNetworkDevice -name pester_SW1 -ip_address 192.0.2.1 -radius_secret MySecurePassword -vendor Aruba -description "Add by PowerArubaCP"
        Add-ArubaCPNetworkDevice -name pester_SW2 -ip_address 192.0.2.2 -radius_secret MySecurePassword -vendor Hewlett-Packard-Enterprise -description "Add by PowerArubaCP"
        Add-ArubaCPNetworkDevice -name pester_SW3 -ip_address 192.0.2.3 -radius_secret MySecurePassword -vendor Aruba -description "Add by PowerArubaCP"
    }

    It "Remove an entry of Network Device Group with format list and type IPAddress" {
        $ndg = Add-ArubaCPNetworkDeviceGroup -name pester_NDG -list_ip 192.0.2.1, 192.0.2.2
        $ndg.value | Should -Be "192.0.2.1, 192.0.2.2"
        #Remove a entry...
        $ndg = Get-ArubaCPNetworkDeviceGroup -name pester_NDG | Remove-ArubaCPNetworkDeviceGroupMember -list_ip 192.0.2.1
        $ndg.value | Should -Be "192.0.2.2"
    }

    It "Remove an entry of Network Device Group with format list and type IPAddress" {
        $ndg = Add-ArubaCPNetworkDeviceGroup -name pester_NDG -list_ip 192.0.2.1, 192.0.2.2, 192.0.2.3
        $ndg.value | Should -Be "192.0.2.1, 192.0.2.2, 192.0.2.3"
        #Remove a entry...
        $ndg = Get-ArubaCPNetworkDeviceGroup -name pester_NDG | Remove-ArubaCPNetworkDeviceGroupMember -list_ip 192.0.2.1
        $ndg.value | Should -Be "192.0.2.2, 192.0.2.3"
    }

    It "Throw when remove all Entry" {
        Add-ArubaCPNetworkDeviceGroup -name pester_NDG -list_ip 192.0.2.1
        { Get-ArubaCPNetworkDeviceGroup -name pester_NDG | Remove-ArubaCPNetworkDeviceGroupMember -list_ip 192.0.2.1 } | Should -Throw "You can't remove all entries. Use Remove-ArubaCPNetworkDeviceGroup to remove Network Device Group"
    }

    AfterEach {
        Get-ArubaCPNetworkDeviceGroup -name pester_NDG | Remove-ArubaCPNetworkDeviceGroup -confirm:$false
    }

    AfterAll {
        #Remove 2 entries
        Get-ArubaCPNetworkDevice -name pester_SW1 | Remove-ArubaCPNetworkDevice -confirm:$false
        Get-ArubaCPNetworkDevice -name pester_SW2 | Remove-ArubaCPNetworkDevice -confirm:$false
        Get-ArubaCPNetworkDevice -name pester_SW3 | Remove-ArubaCPNetworkDevice -confirm:$false
    }
}

AfterAll {
    Disconnect-ArubaCP -confirm:$false
}