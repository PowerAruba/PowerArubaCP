#
# Copyright 2018-2021, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1

BeforeAll {
    Connect-ArubaCP @invokeParams
}

Describe "Get Auth Method" {

    It "Get Auth Method Does not throw an error" {
        {
            Get-ArubaCPAuthMethod
        } | Should -Not -Throw
    }

    It "Get Auth Method" {
        $am = Get-ArubaCPAuthMethod
        $am.count | Should -Not -Be $NULL
    }

    It "Get Auth Method id (id 1)" {
        $am = Get-ArubaCPAuthMethod | Where-Object { $_.id -eq "1" }
        $am.id | Should -Be "1"
        $am.name | Should -Be "[PAP]"
        $am.description | Should -Be "Default settings for PAP"
        $am.method_type | Should -Be "PAP"
        $am.details.encryption_scheme | Should -Be "auto"
    }

    #There is no yet Confirm-ArubaCPAuthMethod...
    #It "Get Auth Method (id 1) and confirm (via Confirm-ArubaCPAuthMethod)" {
    #    $am = Get-ArubaCPAuthMethod | Where-Object { $_.id -eq "1" }
    #    Confirm-ArubaCPAuthMethod $am | Should -Be $true
    #}

    It "Search Auth Method by id (1)" {
        $am = Get-ArubaCPAuthMethod -id 1
        @($am).count | Should -Be 1
        $am.id | Should -Not -BeNullOrEmpty
        $am.name | Should -Be "[PAP]"
    }

    It "Search Auth Method by id ([PAP])" {
        $am = Get-ArubaCPAuthMethod -name '[PAP]'
        @($am).count | Should -Be 1
        $am.id | Should -Not -BeNullOrEmpty
        $am.name | Should -Be "[PAP]"
    }

    It "Search Auth Method by name (contains *PAP*)" {
        $am = Get-ArubaCPAuthMethod -name PAP -filter_type contains
        @($am).count | Should -Be 1
        $am.id | Should -Not -BeNullOrEmpty
        $am.name | Should -Be "[PAP]"
    }

    It "Search Auth Method by attribute (method_type equal PAP)" {
        $am = Get-ArubaCPAuthMethod -filter_attribute method_type -filter_type equal -filter_value PAP
        @($am).count | Should -Be 2
        $am.method_type | Should -BeIn "PAP"
    }

}

AfterAll {
    Disconnect-ArubaCP -confirm:$false
}