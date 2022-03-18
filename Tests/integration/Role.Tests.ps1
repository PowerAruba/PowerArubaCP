#
# Copyright 2022, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1

BeforeAll {
    Connect-ArubaCP @invokeParams
}

Describe "Get Role" {

    BeforeAll {
        #Add 2 Role...
        Add-ArubaCPRole -name pester_PowerArubaCP_1
        Add-ArubaCPRole -name pester_PowerArubaCP_2 -description "Add by PowerArubaCP"
    }

    It "Get Role Does not throw an error" {
        {
            Get-ArubaCPRole -limit 100
        } | Should -Not -Throw
    }

    It "Get ALL Role" {
        $r = Get-ArubaCPRole -limit 100
        $r.count | Should -Not -Be $NULL
    }

    It "Get Role (pester_PowerArubaCP_1)" {
        $r = Get-ArubaCPRole -limit 100 | Where-Object { $_.name -eq "pester_PowerArubaCP_1" }
        $r.id | Should -Not -BeNullOrEmpty
        $r.name | Should -Be "pester_PowerArubaCP_1"
    }

    It "Get Role (pester_PowerArubaCP_2) and confirm (via Confirm-ArubaCPRole)" {
        $r = Get-ArubaCPRole -limit 100 | Where-Object { $_.name -eq "pester_PowerArubaCP_2" }
        Confirm-ArubaCPRole $r | Should -Be $true
    }

    It "Search Role by name (pester_PowerArubaCP_2)" {
        $r = Get-ArubaCPRole -name pester_PowerArubaCP_2
        @($r).count | Should -Be 1
        $r.id | Should -Not -BeNullOrEmpty
        $r.name | Should -Be "pester_PowerArubaCP_2"
    }

    It "Search Role by name (contains *pester*)" {
        $r = Get-ArubaCPRole -name pester -filter_type contains
        @($r).count | Should -Be 2
    }

    It "Search Role by attribute (name contains PowerArubaCP)" {
        $r = Get-ArubaCPRole -filter_attribute description -filter_type contains -filter_value PowerArubaCP
        @($r).count | Should -Be 1
    }

    AfterAll {
        #Remove 2 entries
        Get-ArubaCPRole -name pester_PowerArubaCP_1 | Remove-ArubaCPRole -confirm:$false
        Get-ArubaCPRole -name pester_PowerArubaCP_2 | Remove-ArubaCPRole -confirm:$false
    }
}

Describe "Add Role" {

    It "Add Role with mandatory Parameter (name)" {
        Add-ArubaCPRole -name pester_PowerArubaCP_1
        $r = Get-ArubaCPRole -name pester_PowerArubaCP_1
        $r.id | Should -Not -BeNullOrEmpty
        $r.name | Should -Be "pester_PowerArubaCP_1"
        #$r.description | Should -Be ""
    }

    It "Add Role with description" {
        Add-ArubaCPRole -name pester_PowerArubaCP_1 -description "Add via PowerArubaCP"
        $r = Get-ArubaCPRole -name pester_PowerArubaCP_1
        $r.id | Should -Not -BeNullOrEmpty
        $r.name | Should -Be "pester_PowerArubaCP_1"
        $r.description | Should -Be "Add via PowerArubaCP"
    }

    AfterEach {
        Get-ArubaCPRole -name pester_PowerArubaCP_1 | Remove-ArubaCPRole -confirm:$false
    }
}

Describe "Configure Role" {
    BeforeEach {
        #Add 1 entry
        Add-ArubaCPRole -name pester_PowerArubaCP_1
    }

    It "Change name Role (pester_PowerArubaCP_1 => pester_PowerArubaCP_2)" {
        Get-ArubaCPRole -name pester_PowerArubaCP_1 | Set-ArubaCPRole -name pester_PowerArubaCP_2
        $r = Get-ArubaCPRole -name pester_PowerArubaCP_2
        $r.id | Should -Not -BeNullOrEmpty
        $r.name | Should -Be "pester_PowerArubaCP_2"
    }

    It "Change description Role" {
        Get-ArubaCPRole -name pester_PowerArubaCP_1 | Set-ArubaCPRole -description "Modified via PowerArubaCP"
        $r = Get-ArubaCPRole -name pester_PowerArubaCP_1
        $r.id | Should -Not -BeNullOrEmpty
        $r.name | Should -Be "pester_PowerArubaCP_1"
        $r.description | Should -Be "Modified via PowerArubaCP"
    }

    AfterEach {
        Get-ArubaCPRole -name pester_PowerArubaCP_1 | Remove-ArubaCPRole -confirm:$false
        Get-ArubaCPRole -name pester_PowerArubaCP_2 | Remove-ArubaCPRole -confirm:$false
    }
}

Describe "Remove Role" {

    It "Remove Role by id" {
        Add-ArubaCPRole -name pester_PowerArubaCP_1
        $r = Get-ArubaCPRole -name pester_PowerArubaCP_1
        $r.name | Should -Be "pester_PowerArubaCP_1"
        @($r).count | Should -Be 1
        Remove-ArubaCPRole -id $r.id -confirm:$false
        $r = Get-ArubaCPRole -name pester_PowerArubaCP_1
        $r | Should -BeNullOrEmpty
        @($r).count | Should -Be 0
    }

    It "Remove Role by name (and pipeline)" {
        Add-ArubaCPRole -name pester_PowerArubaCP_1
        $r = Get-ArubaCPRole -name pester_PowerArubaCP_1
        $r.name | Should -Be "pester_PowerArubaCP_1"
        @($r).count | Should -Be 1
        Get-ArubaCPRole -name pester_PowerArubaCP_1 | Remove-ArubaCPRole -confirm:$false
        $r = Get-ArubaCPRole -name pester_PowerArubaCP_1
        $r | Should -BeNullOrEmpty
        @($r).count | Should -Be 0
    }

    AfterEach {
        Get-ArubaCPRole -name pester_PowerArubaCP_1 | Remove-ArubaCPRole -confirm:$false
    }
}

AfterAll {
    Disconnect-ArubaCP -confirm:$false
}