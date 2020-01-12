#
# Copyright 2020, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1

Describe  "Get Server Configuration" {

    It "Get ServerConfiguration Does not throw an error" {
        {
            Get-ArubaCPServerConfiguration
        } | Should Not Throw
    }

    It "Get Server Configuration (name, uuid, server / management ip... )" {
        $sc = Get-ArubaCPServerConfiguration
        $sc.name | Should not be $NULL
        $sc.local_server | Should not be $NULL
        $sc.server_uuid | Should not be $NULL
        $sc.server_dns_name | Should not be $NULL
        $sc.management_ip | Should not be $NULL
        $sc.is_master | Should not be $NULL
        $sc.is_insight_enabled | Should not be $NULL
        $sc.is_insight_master | Should not be $NULL
        $sc.replication_status | Should not be $NULL
        $sc.is_profiler_enabled | Should not be $NULL
    }
}


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

Describe  "Get CPPM Version" {

    It "Get CPPMVersion Does not throw an error" {
        {
            Get-ArubaCPCPPMVersion
        } | Should Not Throw
    }

    It "Get CPPM Version (Major, Minor, service, hardware...)" {
        $cv = Get-ArubaCPCPPMVersion
        $cv.app_major_version | Should be "6"
        $cv.app_minor_version | Should -BeIn (7..9)
        $cv.app_service_release | Should -BeIn (0..15)
        $cv.app_build_number | Should not be $NULL
        $cv.hardware_version | Should not be $NULL
        $cv.fips_enabled | Should not be $NULL
        $cv.eval_license | Should not be $NULL
        $cv.cloud_mode | Should not be $NULL
    }
}


Disconnect-ArubaCP -noconfirm