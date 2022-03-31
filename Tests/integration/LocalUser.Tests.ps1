#
# Copyright 2022, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1

BeforeAll {
    Connect-ArubaCP @invokeParams
}

Describe "Get Local User" {

    BeforeAll {
        #Add 2 Local User...
        Add-ArubaCPLocalUser -user_id pester_PowerArubaCP_1 -password MyPassword -role_name "[Employee]"
        Add-ArubaCPLocalUser -user_id pester_PowerArubaCP_2 -password MyPassword -role_name "[Guest]" -username "pester_PowerArubaCP_username"
    }

    It "Get Local User Does not throw an error" {
        {
            Get-ArubaCPLocalUser
        } | Should -Not -Throw
    }

    It "Get ALL Local User" {
        $lu = Get-ArubaCPLocalUser
        $lu.count | Should -Not -Be $NULL
    }

    It "Get Local User (pester_PowerArubaCP_1)" {
        $lu = Get-ArubaCPLocalUser | Where-Object { $_.user_id -eq "pester_PowerArubaCP_1" }
        $lu.id | Should -Not -BeNullOrEmpty
        $lu.user_id | Should -Be "pester_PowerArubaCP_1"
        $lu.username | Should -Be "pester_PowerArubaCP_1"
        $lu.role_name | Should -Be "[Employee]"
    }

    It "Get Local User (pester_PowerArubaCP_2) and confirm (via Confirm-ArubaCPLocalUser)" {
        $lu = Get-ArubaCPLocalUser | Where-Object { $_.user_id -eq "pester_PowerArubaCP_2" }
        Confirm-ArubaCPLocalUser $lu | Should -Be $true
    }

    Context "Search " {

        It "Search Local User by user_id (pester_PowerArubaCP_2)" {
            $lu = Get-ArubaCPLocalUser -user_id pester_PowerArubaCP_2
            @($lu).count | Should -Be 1
            $lu.id | Should -Not -BeNullOrEmpty
            $lu.user_id | Should -Be "pester_PowerArubaCP_2"
        }

        It "Search Local User by username (pester_PowerArubaCP_username)" {
            $lu = Get-ArubaCPLocalUser -username pester_PowerArubaCP_username
            @($lu).count | Should -Be 1
            $lu.id | Should -Not -BeNullOrEmpty
            $lu.user_id | Should -Be "pester_PowerArubaCP_2"
            $lu.username | Should -Be "pester_PowerArubaCP_username"
        }

        It "Search Local User by user_id (contains *pester*)" {
            $lu = Get-ArubaCPLocalUser -user_id pester -filter_type contains
            @($lu).count | Should -Be 2
        }

        It "Search Local User by attribute (user_id contains PowerArubaCP_2)" {
            $lu = Get-ArubaCPLocalUser -filter_attribute user_id -filter_type contains -filter_value PowerArubaCP_2
            @($lu).count | Should -Be 1
        }

    }

    AfterAll {
        #Remove 2 entries
        Get-ArubaCPLocalUser -user_id pester_PowerArubaCP_1 | Remove-ArubaCPLocalUser -confirm:$false
        Get-ArubaCPLocalUser -user_id pester_PowerArubaCP_2 | Remove-ArubaCPLocalUser -confirm:$false
    }

}

Describe "Add Local User" {

    It "Add Local User with mandatory Parameter (password, role_name)" {
        Add-ArubaCPLocalUser -user_id pester_PowerArubaCP_1 -password MyPassword -role_name "[Employee]"
        $lu = Get-ArubaCPLocalUser -user_id pester_PowerArubaCP_1
        $lu.id | Should -Not -BeNullOrEmpty
        $lu.user_id | Should -Be "pester_PowerArubaCP_1"
        $lu.username | Should -Be "pester_PowerArubaCP_1"
        $lu.role_name | Should -Be "[Employee]"
        $lu.enabled | Should -Be $True
        $lu.change_pwd_next_login | Should -Be $false
        $lu.attributes | Should -Be ""
    }

    It "Add Local User with an username" {
        Add-ArubaCPLocalUser -user_id pester_PowerArubaCP_1 -password MyPassword -role_name "[Employee]" -username pester_PowerArubaCP_username
        $lu = Get-ArubaCPLocalUser -user_id pester_PowerArubaCP_1
        $lu.id | Should -Not -BeNullOrEmpty
        $lu.user_id | Should -Be "pester_PowerArubaCP_1"
        $lu.username | Should -Be "pester_PowerArubaCP_username"
        $lu.role_name | Should -Be "[Employee]"
        $lu.enabled | Should -Be $True
        $lu.change_pwd_next_login | Should -Be $false
        $lu.attributes | Should -Be ""
    }

    It "Add Local User with enabled (disable)" {
        Add-ArubaCPLocalUser -user_id pester_PowerArubaCP_1 -password MyPassword -role_name "[Employee]" -enabled:$false
        $lu = Get-ArubaCPLocalUser -user_id pester_PowerArubaCP_1
        $lu.id | Should -Not -BeNullOrEmpty
        $lu.user_id | Should -Be "pester_PowerArubaCP_1"
        $lu.username | Should -Be "pester_PowerArubaCP_1"
        $lu.role_name | Should -Be "[Employee]"
        $lu.enabled | Should -Be $false
        $lu.change_pwd_next_login | Should -Be $false
        $lu.attributes | Should -Be ""
    }

    It "Add Local User with change_pwd_next_login (enable)" {
        Add-ArubaCPLocalUser -user_id pester_PowerArubaCP_1 -password MyPassword -role_name "[Employee]" -change_pwd_next_login
        $lu = Get-ArubaCPLocalUser -user_id pester_PowerArubaCP_1
        $lu.id | Should -Not -BeNullOrEmpty
        $lu.user_id | Should -Be "pester_PowerArubaCP_1"
        $lu.username | Should -Be "pester_PowerArubaCP_1"
        $lu.role_name | Should -Be "[Employee]"
        $lu.enabled | Should -Be $True
        $lu.change_pwd_next_login | Should -Be $True
        $lu.attributes | Should -Be ""
    }

    It "Add Local User with an attribute (Sponsor)" {
        Add-ArubaCPLocalUser -user_id pester_PowerArubaCP_1 -password MyPassword -role_name "[Employee]" -attributes @{ "Sponsor" = "PowerArubaCP" }
        $lu = Get-ArubaCPLocalUser -user_id pester_PowerArubaCP_1
        $lu.id | Should -Not -BeNullOrEmpty
        $lu.user_id | Should -Be "pester_PowerArubaCP_1"
        $lu.username | Should -Be "pester_PowerArubaCP_1"
        $lu.role_name | Should -Be "[Employee]"
        $lu.enabled | Should -Be $True
        $lu.change_pwd_next_login | Should -Be $false
        ($lu.attributes | Get-Member -MemberType NoteProperty).count | Should -Be "1"
        $lu.attributes.sponsor | Should -Be "PowerArubaCP"
    }

    It "Add Local User with two attributes (Sponsor and Title)" {
        Add-ArubaCPLocalUser -user_id pester_PowerArubaCP_1 -password MyPassword -role_name "[Employee]" -attributes @{ "Sponsor" = "PowerArubaCP"; "Title" = "Pester" }
        $lu = Get-ArubaCPLocalUser -user_id pester_PowerArubaCP_1
        $lu.id | Should -Not -BeNullOrEmpty
        $lu.user_id | Should -Be "pester_PowerArubaCP_1"
        $lu.username | Should -Be "pester_PowerArubaCP_1"
        $lu.role_name | Should -Be "[Employee]"
        $lu.enabled | Should -Be $True
        $lu.change_pwd_next_login | Should -Be $false
        ($lu.attributes | Get-Member -MemberType NoteProperty).count | Should -Be "2"
        $lu.attributes.sponsor | Should -Be "PowerArubaCP"
        $lu.attributes.title | Should -Be "Pester"
    }

    AfterEach {
        Get-ArubaCPLocalUser -user_id pester_PowerArubaCP_1 | Remove-ArubaCPLocalUser -confirm:$false
    }

}

Describe "Configure Local User" {
    BeforeEach {
        #Add 1 entry
        Add-ArubaCPLocalUser -user_id pester_PowerArubaCP_1 -password MyPassword -role_name "[Employee]"
    }

    It "Change user_id Local User (pester_PowerArubaCP_1 => pester_PowerArubaCP_2)" {
        Get-ArubaCPLocalUser -user_id pester_PowerArubaCP_1 | Set-ArubaCPLocalUser -user_id pester_PowerArubaCP_2
        $lu = Get-ArubaCPLocalUser -user_id pester_PowerArubaCP_2
        $lu.id | Should -Not -BeNullOrEmpty
        $lu.user_id | Should -Be "pester_PowerArubaCP_2"
        $lu.username | Should -Be "pester_PowerArubaCP_1"
        $lu.role_name | Should -Be "[Employee]"
        $lu.enabled | Should -Be $True
        $lu.change_pwd_next_login | Should -Be $false
        $lu.attributes | Should -Be ""
    }

    It "Change username Local User (pester_PowerArubaCP_1 => pester_PowerArubaCP_username)" {
        Get-ArubaCPLocalUser -user_id pester_PowerArubaCP_1 | Set-ArubaCPLocalUser -username pester_PowerArubaCP_username
        $lu = Get-ArubaCPLocalUser -user_id pester_PowerArubaCP_1
        $lu.id | Should -Not -BeNullOrEmpty
        $lu.user_id | Should -Be "pester_PowerArubaCP_1"
        $lu.username | Should -Be "pester_PowerArubaCP_username"
        $lu.role_name | Should -Be "[Employee]"
        $lu.enabled | Should -Be $True
        $lu.change_pwd_next_login | Should -Be $false
        $lu.attributes | Should -Be ""
    }

    It "Change Password Local User" {
        #no way to check if the password is changed...
        Get-ArubaCPLocalUser -user_id pester_PowerArubaCP_1 | Set-ArubaCPLocalUser -password MyNewPassword
        $lu = Get-ArubaCPLocalUser -user_id pester_PowerArubaCP_1
        $lu.id | Should -Not -BeNullOrEmpty
        $lu.user_id | Should -Be "pester_PowerArubaCP_1"
        $lu.username | Should -Be "pester_PowerArubaCP_1"
        $lu.role_name | Should -Be "[Employee]"
        $lu.enabled | Should -Be $True
        $lu.change_pwd_next_login | Should -Be $false
        $lu.attributes | Should -Be ""
    }

    It "Change role(_name) Local User ([Guest])" {
        Get-ArubaCPLocalUser -user_id pester_PowerArubaCP_1 | Set-ArubaCPLocalUser -role_name "[Guest]"
        $lu = Get-ArubaCPLocalUser -user_id pester_PowerArubaCP_1
        $lu.id | Should -Not -BeNullOrEmpty
        $lu.user_id | Should -Be "pester_PowerArubaCP_1"
        $lu.username | Should -Be "pester_PowerArubaCP_1"
        $lu.role_name | Should -Be "[Guest]"
        $lu.enabled | Should -Be $True
        $lu.change_pwd_next_login | Should -Be $false
        $lu.attributes | Should -Be ""
    }

    It "Change Enabled Local User (disable)" {
        Get-ArubaCPLocalUser -user_id pester_PowerArubaCP_1 | Set-ArubaCPLocalUser -enabled:$false
        $lu = Get-ArubaCPLocalUser -user_id pester_PowerArubaCP_1
        $lu.id | Should -Not -BeNullOrEmpty
        $lu.user_id | Should -Be "pester_PowerArubaCP_1"
        $lu.username | Should -Be "pester_PowerArubaCP_1"
        $lu.role_name | Should -Be "[Employee]"
        $lu.enabled | Should -Be $false
        $lu.change_pwd_next_login | Should -Be $false
        $lu.attributes | Should -Be ""
    }

    It "Change change_pwd_next_login Local User (enable)" {
        Get-ArubaCPLocalUser -user_id pester_PowerArubaCP_1 | Set-ArubaCPLocalUser -change_pwd_next_login
        $lu = Get-ArubaCPLocalUser -user_id pester_PowerArubaCP_1
        $lu.id | Should -Not -BeNullOrEmpty
        $lu.user_id | Should -Be "pester_PowerArubaCP_1"
        $lu.username | Should -Be "pester_PowerArubaCP_1"
        $lu.role_name | Should -Be "[Employee]"
        $lu.enabled | Should -Be $true
        $lu.change_pwd_next_login | Should -Be $true
        $lu.attributes | Should -Be ""
    }

    It "Change Attribute Local User (Set 1 Attribute)" {
        Get-ArubaCPLocalUser -user_id pester_PowerArubaCP_1 | Set-ArubaCPLocalUser -attributes @{ "Sponsor" = "PowerArubaCP" }
        $lu = Get-ArubaCPLocalUser -user_id pester_PowerArubaCP_1
        $lu.id | Should -Not -BeNullOrEmpty
        $lu.user_id | Should -Be "pester_PowerArubaCP_1"
        $lu.username | Should -Be "pester_PowerArubaCP_1"
        $lu.role_name | Should -Be "[Employee]"
        $lu.enabled | Should -Be $true
        $lu.change_pwd_next_login | Should -Be $false
        ($lu.attributes | Get-Member -MemberType NoteProperty).count | Should -Be "1"
        $lu.attributes.sponsor | Should -Be "PowerArubaCP"
    }

    It "Change Attribute Local User (Set 2 Attributes)" {
        Get-ArubaCPLocalUser -user_id pester_PowerArubaCP_1 | Set-ArubaCPLocalUser -attributes @{ "Sponsor" = "PowerArubaCP" ; "Title" = "Pester" }
        $lu = Get-ArubaCPLocalUser -user_id pester_PowerArubaCP_1
        $lu.id | Should -Not -BeNullOrEmpty
        $lu.user_id | Should -Be "pester_PowerArubaCP_1"
        $lu.username | Should -Be "pester_PowerArubaCP_1"
        $lu.role_name | Should -Be "[Employee]"
        $lu.enabled | Should -Be $true
        $lu.change_pwd_next_login | Should -Be $false
        ($lu.attributes | Get-Member -MemberType NoteProperty).count | Should -Be "2"
        $lu.attributes.sponsor | Should -Be "PowerArubaCP"
        $lu.attributes.title | Should -Be "Pester"
    }

    It "Change Attribute Local User (Set 1 Attribute with 1 Attribute before)" {
        Get-ArubaCPLocalUser -user_id pester_PowerArubaCP_1 | Set-ArubaCPLocalUser -attributes @{ "Sponsor" = "PowerArubaCP" }
        Get-ArubaCPLocalUser -user_id pester_PowerArubaCP_1 | Set-ArubaCPLocalUser -attributes @{ "Title" = "Pester" }
        $lu = Get-ArubaCPLocalUser -user_id pester_PowerArubaCP_1
        $lu.id | Should -Not -BeNullOrEmpty
        $lu.user_id | Should -Be "pester_PowerArubaCP_1"
        $lu.username | Should -Be "pester_PowerArubaCP_1"
        $lu.role_name | Should -Be "[Employee]"
        $lu.enabled | Should -Be $true
        $lu.change_pwd_next_login | Should -Be $false
        #Should Be Replace ? and not add ??
        ($lu.attributes | Get-Member -MemberType NoteProperty).count | Should -Be "2"
        $lu.attributes.sponsor | Should -Be "PowerArubaCP"
        $lu.attributes.title | Should -Be "Pester"
    }

    AfterEach {
        Get-ArubaCPLocalUser -user_id pester_PowerArubaCP_1 | Remove-ArubaCPLocalUser -confirm:$false
        Get-ArubaCPLocalUser -user_id pester_PowerArubaCP_2 | Remove-ArubaCPLocalUser -confirm:$false
    }

}

Describe "Remove Local User" {

    It "Remove Local User by id" {
        Add-ArubaCPLocalUser -user_id pester_PowerArubaCP_1 -password MyPassword -role_name "[Employee]"
        $lu = Get-ArubaCPLocalUser -user_id pester_PowerArubaCP_1
        $lu.user_id | Should -Be "pester_PowerArubaCP_1"
        @($lu).count | Should -Be 1
        Remove-ArubaCPLocalUser -id $lu.id -confirm:$false
        $lu = Get-ArubaCPLocalUser -user_id pester_PowerArubaCP_1
        $lu | Should -BeNullOrEmpty
        @($lu).count | Should -Be 0
    }

    It "Remove Local User by name (and pipeline)" {
        Add-ArubaCPLocalUser -user_id pester_PowerArubaCP_1 -password MyPassword -role_name "[Employee]"
        $lu = Get-ArubaCPLocalUser -user_id pester_PowerArubaCP_1
        $lu.user_id | Should -Be "pester_PowerArubaCP_1"
        @($lu).count | Should -Be 1
        Get-ArubaCPLocalUser -user_id pester_PowerArubaCP_1 | Remove-ArubaCPLocalUser -confirm:$false
        $lu = Get-ArubaCPLocalUser -user_id pester_PowerArubaCP_1
        $lu | Should -BeNullOrEmpty
        @($lu).count | Should -Be 0
    }

    AfterEach {
        Get-ArubaCPLocalUser -user_id pester_PowerArubaCP_1 | Remove-ArubaCPLocalUser -confirm:$false
    }

}

AfterAll {
    Disconnect-ArubaCP -confirm:$false
}