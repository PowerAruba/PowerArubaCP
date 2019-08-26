#
# Copyright 2019, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

if ("Desktop" -eq $PSVersionTable.PsEdition) { # -BeOfType is not same on PowerShell Core and Desktop (get int with Desktop and long with Core for number)
    $script:pester_longint = "int"
}
else {
    $script:pester_longint = "long"
}

. ../credential.ps1
#TODO: Add check if no ipaddress/token info...

Connect-ArubaCP -Server $ipaddress -Token $token -SkipCertificateCheck

