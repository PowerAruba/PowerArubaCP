#
# Copyright 2018-2021, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1

BeforeAll {
    Connect-ArubaCP @invokeParams
}

Describe "Get Auth Source" {

    It "Get Auth Source Does not throw an error" {
        {
            Get-ArubaCPAuthSource
        } | Should -Not -Throw
    }

    It "Get Auth Source" {
        $as = Get-ArubaCPAuthSource
        $as.count | Should -Not -Be $NULL
    }

    It "Get Auth Source id (id 1)" {
        $as = Get-ArubaCPAuthSource | Where-Object { $_.id -eq "1" }
        $as.id | Should -Be "1"
        $as.name | Should -Be "[Local User Repository]"
        $as.type | Should -Be "Local"
        $as.use_for_authorization | Should -Be "True"
    }

    #There is no yet Confirm-ArubaCPAuthSource...
    #It "Get Auth Source (id 1) and confirm (via Confirm-ArubaCPAuthSource)" {
    #    $as = Get-ArubaCPAuthSource | Where-Object { $_.id -eq "1" }
    #    Confirm-ArubaCPAuthSource $as | Should -Be $true
    #}

    It "Search Auth Source by id (1)" {
        $as = Get-ArubaCPAuthSource -id 1
        @($as).count | Should -Be 1
        $as.id | Should -Not -BeNullOrEmpty
        $as.name | Should -Be "[Local User Repository]"
    }

    It "Search Auth Source by id ([Local User Repository])" {
        $as = Get-ArubaCPAuthSource -name '[Local User Repository]'
        @($as).count | Should -Be 1
        $as.id | Should -Not -BeNullOrEmpty
        $as.name | Should -Be "[Local User Repository]"
    }

    It "Search Auth Source by name (contains *Local*)" {
        $as = Get-ArubaCPAuthSource -name Local -filter_type contains
        @($as).count | Should -Be 1
        $as.id | Should -Not -BeNullOrEmpty
        $as.name | Should -Be "[Local User Repository]"
    }

    It "Search Auth Source by attribute (type equal http)" {
        $as = Get-ArubaCPAuthSource -filter_attribute type -filter_type equal -filter_value http
        @($as).count | Should -Be 1
        $as.type | Should -Be "http"
    }

    #Don't work ?! Bug
    #It "Search Auth Source by attribute (type equal local)" {
    #    $as = Get-ArubaCPAuthSource -filter_attribute type -filter_type equal -filter_value http
    #    @($as).count | Should -Not -BeNullOrEmpty
    #    $as.type | Should -Be "local"
    #}

}

AfterAll {
    Disconnect-ArubaCP -confirm:$false
}