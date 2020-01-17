#
# Copyright 2019, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
Function Confirm-ArubaCPApplicationLicense {

    Param (
        [Parameter (Mandatory = $true)]
        [object]$argument
    )

    #Check if it looks like an Application License element

    if ( -not ( $argument | get-member -name id -Membertype Properties)) {
        throw "Element specified does not contain a id property."
    }
    if ( -not ( $argument | get-member -name product_id -Membertype Properties)) {
        throw "Element specified does not contain an product_id property."
    }
    if ( -not ( $argument | get-member -name product_name -Membertype Properties)) {
        throw "Element specified does not contain a product_name property."
    }
    if ( -not ( $argument | get-member -name license_key -Membertype Properties)) {
        throw "Element specified does not contain a license_key property."
    }
    if ( -not ( $argument | get-member -name license_type -Membertype Properties)) {
        throw "Element specified does not contain a license_type property."
    }
    if ( -not ( $argument | get-member -name user_count -Membertype Properties)) {
        throw "Element specified does not contain a user_count property."
    }
    if ( -not ( $argument | get-member -name license_added_on -Membertype Properties)) {
        throw "Element specified does not contain a license_added_on property."
    }
    if ( -not ( $argument | get-member -name activation_status -Membertype Properties)) {
        throw "Element specified does not contain a activation_status property."
    }
    $true

}

Function Confirm-ArubaCPEndpoint {

    Param (
        [Parameter (Mandatory = $true)]
        [object]$argument
    )

    #Check if it looks like an EndPoint element

    if ( -not ( $argument | get-member -name id -Membertype Properties)) {
        throw "Element specified does not contain a id property."
    }
    if ( -not ( $argument | get-member -name mac_address -Membertype Properties)) {
        throw "Element specified does not contain an product_id property."
    }
    if ( -not ( $argument | get-member -name status -Membertype Properties)) {
        throw "Element specified does not contain a status property."
    }
    if ( -not ( $argument | get-member -name attributes -Membertype Properties)) {
        throw "Element specified does not contain a attributes property."
    }
    $true

}

Function Confirm-ArubaCPNetworkDevice {

    Param (
        [Parameter (Mandatory = $true)]
        [object]$argument
    )

    #Check if it looks like an Network Device (NAS) element

    if ( -not ( $argument | get-member -name id -Membertype Properties)) {
        throw "Element specified does not contain a id property."
    }
    if ( -not ( $argument | get-member -name name -Membertype Properties)) {
        throw "Element specified does not contain an name property."
    }
    if ( -not ( $argument | get-member -name ip_address -Membertype Properties)) {
        throw "Element specified does not contain a ip_address property."
    }
    if ( -not ( $argument | get-member -name radius_secret -Membertype Properties)) {
        throw "Element specified does not contain a radius_secret property."
    }
    if ( -not ( $argument | get-member -name tacacs_secret -Membertype Properties)) {
        throw "Element specified does not contain a tacacs_secret property."
    }
    if ( -not ( $argument | get-member -name vendor_name -Membertype Properties)) {
        throw "Element specified does not contain a vendor_name property."
    }
    if ( -not ( $argument | get-member -name coa_capable -Membertype Properties)) {
        throw "Element specified does not contain a coa_capable property."
    }
    if ( -not ( $argument | get-member -name coa_port -Membertype Properties)) {
        throw "Element specified does not contain a coa_port property."
    }
    $true

}

Function Confirm-ArubaCPService {

    Param (
        [Parameter (Mandatory = $true)]
        [object]$argument
    )

    #Check if it looks like an Service element

    if ( -not ( $argument | get-member -name id -Membertype Properties)) {
        throw "Element specified does not contain a id property."
    }
    if ( -not ( $argument | get-member -name name -Membertype Properties)) {
        throw "Element specified does not contain an name property."
    }
    if ( -not ( $argument | get-member -name type -Membertype Properties)) {
        throw "Element specified does not contain a type property."
    }
    if ( -not ( $argument | get-member -name template -Membertype Properties)) {
        throw "Element specified does not contain a template property."
    }
    if ( -not ( $argument | get-member -name enabled -Membertype Properties)) {
        throw "Element specified does not contain a enabled property."
    }
    if ( -not ( $argument | get-member -name orderNo -Membertype Properties)) {
        throw "Element specified does not contain a orderNo property."
    }
    $true

}

Function Confirm-ArubaCPStaticHostList {

    Param (
        [Parameter (Mandatory = $true)]
        [object]$argument
    )

    #Check if it looks like an Static Host List element

    if ( -not ( $argument | get-member -name id -Membertype Properties)) {
        throw "Element specified does not contain a id property."
    }
    if ( -not ( $argument | get-member -name name -Membertype Properties)) {
        throw "Element specified does not contain an name property."
    }
    if ( -not ( $argument | get-member -name host_format -Membertype Properties)) {
        throw "Element specified does not contain a host_format property."
    }
    if ( -not ( $argument | get-member -name host_type -Membertype Properties)) {
        throw "Element specified does not contain a host_type property."
    }
    $true

}