#
# Copyright 2019, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1

Describe  "Get Application License" {

    It "Get Application License Does not throw an error" -Skip:$VersionBefore680 {
        {
            Get-ArubaCPApplicationLicense
        } | Should Not Throw
    }

    It "Get ALL Application License" -Skip:$VersionBefore680 {
        $al = Get-ArubaCPApplicationLicense
        $al.count | Should not be $NULL
    }

    It "Get Application License and confirm" -Skip:$VersionBefore680 {
        $al = Get-ArubaCPApplicationLicense
        Confirm-ArubaCPApplicationLicense $al[0] | Should be $true
    }

    It "Get Application License thow a error when use with CPPM <= 6.8.0" -Skip: ($VersionBefore680 -eq 0) {
        { Get-ArubaCPApplicationLicense } | Should throw "Need ClearPass >= 6.8.0 for use this cmdlet"
    }

}

Describe  "Add and Remove Application License" {

    It "Add Application License ($pester_license_type)" -Skip:($pester_license -eq $null --and $VersionBefore680) {
        Add-ArubaCPApplicationLicense -product_name $pester_license_type -license_key $pester_license
        $al = Get-ArubaCPApplicationLicense -product_name $pester_license_type #Only check if search work !
        $al.id | Should not be BeNullOrEmpty
        $al.product_name | Should be $pester_license_type
    }

    It "Remove Application License ($pester_license_type)" -Skip:($pester_license -eq $null -and $VersionBefore680) {
        Get-ArubaCPApplicationLicense -product_name $pester_license_type | Remove-ArubaCPApplicationLicense -noconfirm
        $al = Get-ArubaCPApplicationLicense -product_name $pester_license_type
        $al | Should be $null
    }

}


Disconnect-ArubaCP -noconfirm