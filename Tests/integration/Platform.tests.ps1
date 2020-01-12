#
# Copyright 2020, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1

Describe  "Get Server Version" {

    It "Get ServerVersion Does not throw an error" {
        {
            Get-ArubaCPServerVersion
        } | Should Not Throw
    }

    It "Get Server Version (CPPM, Guest, Installed Patches)" {
        $sv = Get-ArubaCPServerVersion
        $sv.cppm_version | Should not be $NULL
        $sv.guest_version | Should not be $NULL
        $sv.installed_patches | Should not be $NULL
    }
}

Disconnect-ArubaCP -noconfirm