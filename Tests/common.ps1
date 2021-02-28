#
# Copyright 2019, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

if ("Desktop" -eq $PSVersionTable.PsEdition) {
    # -BeOfType is not same on PowerShell Core and Desktop (get int with Desktop and long with Core for number)
    $script:pester_longint = "int"
}
else {
    $script:pester_longint = "long"
}

$script:invokeParams = @{
    server               = $ipaddress;
    token                = $token;
    port                 = $port;
    SkipCertificateCheck = $true;
}

if ($null -eq $port) {
    $invokeParams.port = 443
}

. ../credential.ps1
#TODO: Add check if no ipaddress/token info...
Connect-ArubaCP @invokeParams -SkipCertificateCheck

$script:VersionBefore680 = $DefaultArubaCPConnection.Version -lt [version]"6.8.0"

Disconnect-ArubaCP -confirm:$false