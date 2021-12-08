#
# Copyright 2021, Cedric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1

Describe  "Get Cluster Certificates (Get-ArubaCPClusterCertificates)" {

    It "Get Cluster Certificates Does not throw an error" {
        {
            Get-ArubaCPClusterCertificates
        } | Should Not Throw
    }

    It "Get Cluster Certificates" {
        $cc = Get-ArubaCPClusterCertificates
        @($cc).count | Should not be $NULL
    }

    It "Get Cluster Certificates and confirm" {
        $cc = Get-ArubaCPClusterCertificates
        Confirm-ArubaCPServerCertificate $cc | Should be $true
    }

    It "Get Cluster Certificates with service_id Does not throw an error" {
        {
            Get-ArubaCPClusterCertificates -service_id 1
        } | Should Not Throw
    }

    It "Get Cluster Certificates with service_name Does not throw an error" {
        {
            Get-ArubaCPClusterCertificates -service_name "HTTPS(ECC)"
        } | Should Not Throw
    }

    It "Get Cluster Certificates with service_type Does not throw an error" {
        {
            Get-ArubaCPClusterCertificates -certificate_type "HTTPS(RSA) Server Certificate"
        } | Should Not Throw
    }

    It "Get Cluster Certificates with service_id" {
        $cc = Get-ArubaCPClusterCertificates -service_id 1
        @($cc).count | Should not be $NULL
    }

    It "Get Cluster Certificates with service_name" {
        $cc = Get-ArubaCPClusterCertificates -service_name "HTTPS(ECC)"
        @($cc).count | Should not be $NULL
    }

    It "Get Cluster Certificates with service_type" {
        $cc = Get-ArubaCPClusterCertificates -certificate_type "HTTPS(RSA) Server Certificate"
        @($cc).count | Should not be $NULL
    }

}

Describe  "Get Server Certificate (Get-ArubaCPServerCertificate)" {

    It "Get Server Certificate Does not throw an error" {
        {
            Get-ArubaCPServerCertificate -service_name "RADIUS"
        } | Should Not Throw
    }

    It "Get Server Certificate" {
        $cc = Get-ArubaCPServerCertificate -service_name "RadSec"
        @($cc).count | Should not be $NULL
    }

    It "Get Server Certificate and confirm" {
        $cc = Get-ArubaCPServerCertificate -service_name "HTTPS(RSA)"
        Confirm-ArubaCPServerCertificate $cc | Should be $true
    }

}

Disconnect-ArubaCP -noconfirm