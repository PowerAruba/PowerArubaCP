#
# Copyright 2019, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1

Describe  "Connect to a ClearPass (using Token)" {
    BeforeAll {
        #Disconnect "default connection"
        Disconnect-ArubaCP -noconfirm
    }
    It "Connect to ClearPass (using Token) and check global variable" {
        Connect-ArubaCP $ipaddress -Token $token -SkipCertificateCheck
        $DefaultArubaCPConnection | Should Not BeNullOrEmpty
        $DefaultArubaCPConnection.server | Should be $ipaddress
        $DefaultArubaCPConnection.token | Should be $token
    }
    It "Disconnect to ClearPass (using HTTP) and check global variable" {
        Disconnect-ArubaCP -noconfirm
        $DefaultArubaCPConnection | Should be $null
    }
    #TODO: Connect using wrong login/password

    #This test only work with PowerShell 6 / Core (-SkipCertificateCheck don't change global variable but only Invoke-WebRequest/RestMethod)
    #This test will be fail, if there is valid certificate...
    It "Throw when try to use Invoke-ArubaCPRestMethod with don't use -SkipCertifiateCheck" -Skip:("Desktop" -eq $PSEdition) {
        Connect-ArubaCP $ipaddress -Token $token
        { Invoke-ArubaCPRestMethod -uri "rest/v4/vlans" } | Should throw "Unable to connect (certificate)"
        Disconnect-ArubaCP -noconfirm
    }
    It "Throw when try to use Invoke-ArubaCPRestMethod and not connected" {
        { Invoke-ArubaCPRestMethod -uri "rest/v4/vlans" } | Should throw "Not Connected. Connect to the ClearPass with Connect-ArubaCP"
    }
}
