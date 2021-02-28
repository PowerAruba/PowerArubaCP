#
# Copyright 2019, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1

BeforeAll {
    Connect-ArubaCP @invokeParams
}

Describe  "Get API Client" {

    BeforeAll {
        #Add 2 entries
        Add-ArubaCPApiClient -client_id pester_PowerArubaCP1 -client_secret "mySecret" -client_description "Add by PowerArubaCP" -grant_types "client_credentials" -profile_id 1
        Add-ArubaCPApiClient -client_id pester_PowerArubaCP2 -client_secret "mySecret" -client_description "Add by PowerArubaCP" -grant_types "client_credentials" -profile_id 1
    }

    It "Get NetworkDevice Does not throw an error" {
        {
            Get-ArubaCPApiClient
        } | Should -Not -Throw
    }

    It "Get ALL Api Client" {
        $ac = Get-ArubaCPApiClient
        $ac.count | Should -Not -Be $NULL
    }

    It "Get Api Client (pester_PowerArubaCP1)" {
        $ac = Get-ArubaCPApiClient | Where-Object { $_.client_id -eq "pester_PowerArubaCP1" }
        $ac.id | Should -Not -BeNullOrEmpty
        $ac.client_id | Should -Be "pester_PowerArubaCP1"
        $ac.client_secret | Should -Not -BeNullOrEmpty
        $ac.client_description | Should -Be "Add by PowerArubaCP"
        $ac.grant_types | Should -Be "client_credentials"
        $ac.profile_id | Should -Be "1"
    }

    It "Get Api Client (pester_PowerArubaCP2) and confirm (via Confirm-ArubaCPApiClient)" {
        $ac = Get-ArubaCPApiClient | Where-Object { $_.client_id -eq "pester_PowerArubaCP2" }
        Confirm-ArubaCPApiClient $ac | Should -Be $true
    }

    It "Search Api Client by client_id (pester_PowerArubaCP1)" {
        $ac = Get-ArubaCPApiClient -client_id pester_PowerArubaCP1
        @($ac).count | Should -Be 1
        $ac.id | Should -Not -BeNullOrEmpty
        $ac.client_id | Should -Be "pester_PowerArubaCP1"
        $ac.client_description | Should -Be "Add by PowerArubaCP"
    }

    It "Search Api Client by client_id (contains *pester*)" {
        $ac = Get-ArubaCPApiClient -client_id pester -filter_type contains
        @($ac).count | Should -Be 2
    }

    AfterAll {
        #Remove 2 entries
        Get-ArubaCPApiClient -client_id pester_PowerArubaCP1 | Remove-ArubaCPApiClient -noconfirm
        Get-ArubaCPApiClient -client_id pester_PowerArubaCP2 | Remove-ArubaCPApiClient -noconfirm
    }
}

Describe  "Add Api Client" {

    It "Add Api Client with grant types client_credentials and description" {
        Add-ArubaCPApiClient -client_id pester_PowerArubaCP1 -client_description "Add by PowerArubaCP" -grant_types "client_credentials" -profile_id 1
        $ac = Get-ArubaCPApiClient -client_id pester_PowerArubaCP1
        $ac.id | Should -Not -BeNullOrEmpty
        $ac.client_id | Should -Not -BeNullOrEmpty
        $ac.client_secret | Should -Not -BeNullOrEmpty
        $ac.client_description | Should -Be "Add by PowerArubaCP"
        $ac.grant_types | Should -Be "client_credentials"
        $ac.profile_id | Should -Be "1"
    }

    It "Add Api Client with grant type password (refresh_token) and status disabled" {
        Add-ArubaCPApiClient -client_id pester_PowerArubaCP1 -grant_types password -profile_id 1 -enabled:$false
        $ac = Get-ArubaCPApiClient -client_id pester_PowerArubaCP1
        $ac.id | Should -Not -BeNullOrEmpty
        $ac.client_id | Should -Be "pester_PowerArubaCP1"
        $ac.grant_types | Should -Be "password refresh_token"
        $ac.profile_id | Should -Be "1"
        $ac.enabled | Should -Be "false"
    }

    AfterEach {
        Get-ArubaCPApiClient -client_id pester_PowerArubaCP1 | Remove-ArubaCPApiClient -noconfirm
    }
}


Describe  "Remove Api Client" {

    It "Remove Api Client by id" {
        Add-ArubaCPApiClient -client_id pester_PowerArubaCP1 -grant_types "client_credentials" -profile_id 1
        $ac = Get-ArubaCPApiClient -client_id pester_PowerArubaCP1
        $ac.client_id | Should -Be "pester_PowerArubaCP1"
        @($ac).count | Should -Be 1
        Remove-ArubaCPApiClient -id $ac.client_id -noconfirm
        $ac = Get-ArubaCPApiClient -client_id pester_PowerArubaCP1
        $ac | Should -BeNullOrEmpty
        @($ac).count | Should -Be 0
    }

    It "Remove Api Client by client_id (and pipeline)" {
        Add-ArubaCPApiClient -client_id pester_PowerArubaCP1 -grant_types "client_credentials" -profile_id 1
        $ac = Get-ArubaCPApiClient -client_id pester_PowerArubaCP1
        $ac.client_id | Should -Be "pester_PowerArubaCP1"
        @($ac).count | Should -Be 1
        Get-ArubaCPApiClient -client_id pester_PowerArubaCP1 | Remove-ArubaCPApiClient -noconfirm
        $ac = Get-ArubaCPApiClient -client_id pester_PowerArubaCP1
        $ac | Should -BeNullOrEmpty
        @($ac).count | Should -Be 0
    }

    AfterEach {
        Get-ArubaCPApiClient -client_id pester_PowerArubaCP1 | Remove-ArubaCPApiClient -noconfirm
    }
}

AfterAll {
    Disconnect-ArubaCP -noconfirm
}