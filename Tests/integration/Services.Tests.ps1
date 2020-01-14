#
# Copyright 2018-2020, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1

Describe  "Get Service" {

    It "Get Service Does not throw an error" {
        {
            Get-ArubaCPService
        } | Should Not Throw
    }

    It "Get Service " {
        $s = Get-ArubaCPService
        $s.count | Should not be $NULL
    }

    It "Get Service id (id 1)" {
        $s = Get-ArubaCPService | Where-Object { $_.id -eq "1" }
        $s.id | Should be "1"
        $s.name | Should be "[Policy Manager Admin Network Login Service]"
        $s.type | Should be "TACACS"
        $s.template | Should be "TACACS_ENFORCEMENT"
        $s.enabled | Should be "True"
        $s.orderNo | Should be "1"
    }

    It "Get Network Device (id 1) and confirm (via Confirm-ArubaCPService)" {
        $s = Get-ArubaCPService | Where-Object { $_.id -eq "1" }
        Confirm-ArubaCPService $s | Should be $true
    }

    It "Search Service by id (1)" {
        $s = Get-ArubaCPService -id 1
        @($s).count | Should be 1
        $s.id | Should not be BeNullOrEmpty
        $s.name | Should be "[Policy Manager Admin Network Login Service]"
    }

    It "Search Service by id ([Policy Manager Admin Network Login Service])" {
        $s = Get-ArubaCPService -name '[Policy Manager Admin Network Login Service]'
        @($s).count | Should be 1
        $s.id | Should not be BeNullOrEmpty
        $s.name | Should be "[Policy Manager Admin Network Login Service]"
    }

    It "Search Network Device by name (contains *Policy*)" {
        $s = Get-ArubaCPService -name Policy -filter_type contains
        @($s).count | Should be 1
        $s.id | Should not be BeNullOrEmpty
        $s.name | Should be "[Policy Manager Admin Network Login Service]"
    }

    #Disable because freeze...
    # It "Search Service by attribute (type equal RADIUS)" {
    #     $s = Get-ArubaCPService -filter_attribute ip_address -filter_type equal -filter_value 192.0.2.1
    #     @($s).count | Should be 1
    #     $s.type | Should be "RADIYS"
    # }

}

Disconnect-ArubaCP -noconfirm