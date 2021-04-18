
# PowerArubaCP

This is a Powershell module for configure an Aruba ClearPass (CPPM).

<p align="center">
<img src="https://raw.githubusercontent.com/PowerAruba/PowerArubaCP/master/Medias/PowerArubaCP.png" width="250" height="250" />
</p>

With this module (version 0.4.0) you can manage:

- [API Client](#api-client) (Add / Get / Remove)
- [Application License](#application-license) (Add / Get / Remove)
- CPPM (Get Version)
- Endpoint (Add / Get / Set / Remove)
- [Network Device](#NAS-Management) (Add / Get / Set / Remove a NAS)
- Server (Get Configuration, Version)
- Service (Get / Enable / Disable)
- Static Host List ( Add / Get / Set / Remove a Static Host List and Add/Remove Member)
- Invoke API using Invoke-ArubaCPRestMethod

There is some extra feature
- [Invoke API](#Invoke-API)
- [Multi Connection](#MultiConnection)
- [Filtering](#Filtering)

More functionality will be added later.

Tested with Aruba ClearPass (using release 6.7.x and 6.8.x)  
Application Licence, Service and Static Host List are not supported on Clearpass < 6.8.0

# Usage

All resource management functions are available with the Powershell verbs GET, ADD, SET, REMOVE.  
For example, you can manage NAS (NetworkDevice) with the following commands:
- `Get-ArubaCPNetworkDevice`
- `Add-ArubaCPNetworkDevice`
- `Set-ArubaCPNetworkDevice`
- `Remove-ArubaCPNetworkDevice`

# Requirements

- Powershell 5 or 6.x/7.x (Core) (If possible get the latest version)
- A ClearPass (with release >= 6.7.x) and API Client enable

# Instructions
### Install the module
```powershell
# Automated installation (Powershell 5 and later):
    Install-Module PowerArubaCP

# Import the module
    Import-Module PowerArubaCP

# Get commands in the module
    Get-Command -Module PowerArubaCP

# Get help
    Get-Help Add-ArubaCPNetworkDevice -Full
```

# Examples

### Connecting to the ClearPass using API

The first thing to do is to get API Client
there is two methods to connect, using [client_id/client_secret](#Use-API-client_idclient_secret) or [token](#Use-API-Token) 

#### Use API client_id/client_secret


Go on WebGUI of your ClearPass, on Guest Modules
![](./Medias/CPPM_Guest_API.PNG)  
Go on `Administration` => `API Services` => `API Clients`

![](./Medias/CPPM_Create_API_Client.PNG)  
Create a `New API Client`
- Client ID : a client name (for example PowerArubaCP)
- Operator Profile : Super Administrator
- Grant type : Client credentials
- Access Token Lifetime : You can increment ! (24 hours !)

Click on `Create API Client`

```powershell
# Connect to the Aruba Clearpass using client_id/client_secret
    Connect-ArubaCP 192.0.2.1 -client_id PowerArubaCP -client_secret QRFttyxOmWX3NopMIYzKysj30wvIMxAwB6kUy7uJc67B

    Name                           Value
    ----                           -----
    token                          7aa3de0be5ea230ea92b6de0bafa14d7a76e2305
    invokeParams                   {DisableKeepAlive, SkipCertificateCheck}
    server                         192.0.2.1
    port                           443
    version                        6.8.4

```

#### Use API Token

Like for client_id/client_secret, generate a API Client but you don't need to store the Client Secret

On `API Clients List`, select the your client
![](./Medias/CPPM_Generate_Access_Token.PNG)  

Click on `Generate Access Token`

![](./Medias/CPPM_Get_Token.PNG)  
And kept the token (for example : 70680f1d19f86110800d5d5cb4414fbde7be12ae)


After connect to an Aruba ClearPass with the command `Connect-ArubaCP` :

```powershell
# Connect to the Aruba Clearpass using Token
    Connect-ArubaCP 192.0.2.1 -token 70680f1d19f86110800d5d5cb4414fbde7be12ae

    Name                           Value
    ----                           -----
    token                          70680f1d19f86110800d5d5cb4414fbde7be12ae
    invokeParams                   {DisableKeepAlive, SkipCertificateCheck}
    server                         192.0.2.1
    port                           443
    version                        6.8.4
```

### Invoke API
for example to get ClearPass version

```powershell
# get ClearPass version using API
    Invoke-ArubaCPRestMethod -method "get" -uri "api/cppm-version"

    app_major_version   : 6
    app_minor_version   : 7
    app_service_release : 2
    app_build_number    : 105008
    hardware_version    : CLABV
    fips_enabled        : False
    eval_license        : False
    cloud_mode          : False
```

if you get a warning about `Unable to connect` Look [Issue](#Issue)

to get API uri, go to ClearPass Swagger (https://CPPM-IP/api-docs)
![](./Medias/CPPM_API_Docs.PNG)  

And choice a service (for example Platform)
![](./Medias/CPPM_API_Docs_platform.PNG)  

### NAS Management

You can create a new NAS `Add-ArubaCPNetworkDevice`, retrieve its information `Get-ArubaCPNetworkDevice`, modify its properties `Set-ArubaCPNetworkDevice`, or delete it `Remove-ArubaCPNetworkDevice`.

```powershell
# Create a NAS
    Add-ArubaCPNetworkDevice -name SW1 -ip_address 192.0.2.1 -radius_secret MySecurePassword -vendor Aruba -description "Add by PowerArubaCP"

    id            : 3004
    name          : SW1
    description   : Add by PowerArubaCP
    ip_address    : 192.0.2.1
    radius_secret :
    tacacs_secret :
    vendor_name   : Aruba
    coa_capable   : False
    coa_port      : 3799
    attributes    :
    _links        : @{self=}


# Get information about NAS
    Get-ArubaCPNetworkDevice -name SW1 | Format-Table

    id   name description         ip_address radius_secret tacacs_secret vendor_name coa_capable coa_port attributes
    --   ---- -----------         ---------- ------------- ------------- ----------- ----------- -------- ----------
    3004 SW1  Add by PowerArubaCP 192.0.2.1                              Aruba       False       3799

# (Re)Configure NAS
    Get-ArubaCPNetworkDevice -name SW1 | Set-ArubaCPNetworkDevice  -ip_address 192.0.2.2 -vendor_name Hewlett-Packard-Enterprise

    id            : 3004
    name          : SW1
    description   :
    ip_address    : 192.0.2.2
    radius_secret :
    tacacs_secret :
    vendor_name   : Hewlett-Packard-Enterprise
    coa_capable   : True
    coa_port      : 3799
    attributes    :
    _links        : @{self=}

# Remove a NAS
    $nad = Get-ArubaCPNetworkDevice -name SW1
    $nad | Remove-ArubaCPNetworkDevice

    Confirm
    Are you sure you want to perform this action?
    Performing the operation "Remove Network device" on target "3344 (SW1)".
    [Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"):
```

### API Client

You can create a new API Client `Add-ArubaCPApiClient`, retrieve its information `Get-ArubaCPApiClient` or delete it `Remove-ArubaCPApiClient`.

```powershell
# Create an API Client
    Add-ArubaCPApiClient -client_id MyAPIClient -grant_types client_credentials -profile_id 1

    client_id                    : MyAPIClient
    client_secret                : $2y$10$OXRszKzBSH7hP5QwgZ3cCuNZwbGaddb767l0Kx52Ww.RPEhBfbj6u
    client_description           :
    grant_types                  : client_credentials
    redirect_uri                 :
    operating_scope              :
    profile_id                   : 1
    auto_confirm                 : False
    enabled                      : True
    scope                        :
    user_id                      :
    access_lifetime              : 8 hours
    refresh_lifetime             : 14 days
    operating_scope_label        : ClearPass REST API
    profile_name                 : Super Administrator
    client_public                : False
    client_refresh               : False
    access_token_lifetime        : 8
    access_token_lifetime_units  : hours
    refresh_token_lifetime       : 14
    refresh_token_lifetime_units : days
    id                           : MyAPIClient
    _links                       : @{self=}


# Get information about API Client
    Get-ArubaCPApiClient -client_id MyAPIClient | Format-Table

    client_id   client_secret      client_description grant_types        redirect_uri operating_scope profile_id auto_confirm enabled scope
    ---------   -------------      ------------------ -----------        ------------ --------------- ---------- ------------ ------- -----
    MyAPIClient $2y$10$OXRszKzB...                    client_credentials                              1                 False    True

# Remove an API Client
    $ac = Get-ArubaCPApiClient -client_id MyAPIClient
    $ac | Remove-ArubaCPApiClient

    Confirm
    Are you sure you want to perform this action?
    Performing the operation "Remove API Client" on target "MyAPIClient".
    [Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"):
```

### Application License

You can create add Application License `Add-ArubaCPApplicationLicense`, retrieve its information `Get-ArubaCPApplicationLicense` or delete it `Remove-ArubaCPApplicationLicense`.

```powershell
# Add Application License (Onboard)
    Add-ArubaCPApplicationLicense -product_name Onboard -license_key "-----BEGIN CLEARPASS ONBOARD LICENSE KEY----- .... "

    id                : 3002
    product_id        : 8
    product_name      : Onboard
    license_key       : -----BEGIN CLEARPASS ONBOARD LICENSE KEY-----
                        .......
                        -----END CLEARPASS ONBOARD LICENSE KEY-----
    license_type      : Evaluation
    user_count        : 100
    duration          : 90
    duration_units    : days
    license_added_on  : 18/04/2021 13:45:27
    activation_status : False
    _links            : @{self=}


# Get information about Application License
    Get-ArubaCPApplicationLicense -product_name Onboard | Format-Table

    id product_id product_name license_key
    -- ---------- ------------ -----------
    3002          8 Onboard      -----BEGIN CLEARPASS ONBOARD LICENSE KEY-----...

# Remove Application License Onboard
    $al = Get-ArubaCPApplicationLicense -product_name Onboard
    $al | Remove-ArubaCPApplicationLicense

    Confirm
    Are you sure you want to perform this action?
    Performing the operation "Remove Application License" on target "3002 (Onboard)".
    [Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"):
```

### MultiConnection

From release 0.4.0, it is possible to connect on same times to multi ClearPass
You need to use -connection parameter to cmdlet

For example to get Vlan Ports of 2 switchs

```powershell
# Connect to first ClearPass
    $cppm1 = Connect-ArubaCP 192.0.2.1 -SkipCertificateCheck -DefaultConnection:$false

#DefaultConnection set to false is not mandatory but only don't set the connection info on global variable

# Connect to second ClearPass
    $cppm2 = Connect-ArubaCP 192.0.2.1 -SkipCertificateCheck -DefaultConnection:$false

# Get Static Host List for first ClearPass
   Get-ArubaCPStaticHostList -connection $cppm1 | Format-Table

  id name                description host_format host_type  value                 _links
  -- ----                ----------- ----------- ---------  -----                 ------
3001 SHL-list-IPAddress              list        IPAddress                        @{self=}
....
# Get Static Host List for first ClearPass
   Get-ArubaCPStaticHostList -connection $cppm2 | Format-Table

  id name                description host_format host_type  value                 _links
  -- ----                ----------- ----------- ---------  -----                 ------
3001 SHL-list-MACAddress             list        MACAddress                       @{self=}
...

#Each cmdlet can use -connection parameter
```

### Filtering
For `Invoke-ArubaCPRestMethod`, it is possible to use -filter parameter
You need to use ClearPass API syntax :

|Description |	JSON Filter Syntax |
| ---------- | ------------------- |
| No filter, matches everything | {} |
| Field is equal to "value" | {"fieldName":"value"} or {"fieldName":{"$eq":"value"}} |
| Field is one of a list of values | {"fieldName":["value1", "value2"]}  or {"fieldName":{"$in":["value1", "value2"]}} |
| Field is not one of a list of values | {"fieldName":{"$nin":["value1", "value2"]}} |
| Field contains a substring "value" | {"fieldName":{"$contains":"value"}} |
| Field is not equal to "value" | {"fieldName":{"$ne":"value"}} |
| Field is greater than "value" | {"fieldName":{"$gt":"value"}} |
| Field is greater than or equal to "value" | {"fieldName":{"$gte":"value"}} |
| Field is less than "value" | {"fieldName":{"$lt":"value"}} |
| Field is less than or equal to "value" | {"fieldName":{"$lte":"value"}} |
| Field matches a regular expression (case-sensitive) | {"fieldName":{"$regex":"regex"}} |
| Field matches a regular expression (case-insensitive) | {"fieldName":{"$regex":"regex", "$options":"i"}} |
| Field exists (does not contain a null value) | {"fieldName":{"$exists":true}} |
| Field is NULL | {"fieldName":{"$exists":false}} |
| Combining filter expressions with AND | {"$and":[ filter1, filter2, ... ]} |
| Combining filter expressions with OR | {"$or":[ filter1, filter2, ... ]} |
| Inverting a filter expression | {"$not":{ filter }} |
| Field is greater than or equal to 2 and less than 5 | {"fieldName":{"$gte":2, "$lt":5}} {"$and":[ {"fieldName":{"$gte":2}}, {"fieldName":{"$lt":5}} ]}

For `Get-XXX` cmdlet like `Get-ArubaCPNetwork`, it is possible to using some helper filter (`-filter_attribute`, `-filter_type`, `-filter_value`)

```powershell
# Get NetworkDevice named NAD-PowerArubaCP
    Get-ArubaCPNetworkDevice -name NAD-PowerArubaCP
...

# Get NetworkDevice contains NAD-PowerArubaCP
    Get-ArubaCPNetworkDevice -name NAD-PowerArubaCP -filter_type contains
...

# Get NetworkDevice where ip_address equal 192.168.1.1
    Get-ArubaCPNetworkDevice -filter_attribute ip_address -filter_type equal -filter_value 192.168.1.1
...

```
Actually, support only `equal` and `contains` filter type

### Disconnecting

```powershell
# Disconnect from the Aruba ClearPass
    Disconnect-ArubaCP
```

# Issue

## Unable to connect (certificate)
if you use `Connect-ArubaCP` and get `Unable to Connect (certificate)`

The issue coming from use Self-Signed or Expired Certificate for switch management

Try to connect using `Connect-ArubaCP -SkipCertificateCheck`

# List of available command
```powershell
Add-ArubaCPApiClient
Add-ArubaCPApplicationLicense
Add-ArubaCPDeviceFingerprint
Add-ArubaCPEndpoint
Add-ArubaCPNetworkDevice
Add-ArubaCPNetworkDeviceGroup
Add-ArubaCPNetworkDeviceGroupMember
Add-ArubaCPStaticHostList
Add-ArubaCPStaticHostListMember
Confirm-ArubaCPApiClient
Confirm-ArubaCPApplicationLicense
Confirm-ArubaCPEndpoint
Confirm-ArubaCPNetworkDevice
Confirm-ArubaCPNetworkDeviceGroup
Confirm-ArubaCPService
Confirm-ArubaCPStaticHostList
Connect-ArubaCP
Convert-ArubaCPCIDR2Mask
Deploy-ArubaCPVm
Disable-ArubaCPService
Disconnect-ArubaCP
Enable-ArubaCPService
Format-ArubaCPMacAddress
Get-ArubaCPApiClient
Get-ArubaCPApplicationLicense
Get-ArubaCPAuthMethod
Get-ArubaCPAuthSource
Get-ArubaCPCPPMVersion
Get-ArubaCPDeviceFingerprint
Get-ArubaCPEndpoint
Get-ArubaCPNetworkDevice
Get-ArubaCPNetworkDeviceGroup
Get-ArubaCPServerConfiguration
Get-ArubaCPServerVersion
Get-ArubaCPService
Get-ArubaCPStaticHostList
Invoke-ArubaCPRestMethod
Remove-ArubaCPApiClient
Remove-ArubaCPApplicationLicense
Remove-ArubaCPEndpoint
Remove-ArubaCPNetworkDevice
Remove-ArubaCPNetworkDeviceGroup
Remove-ArubaCPNetworkDeviceGroupMember
Remove-ArubaCPStaticHostList
Remove-ArubaCPStaticHostListMember
Set-ArubaCPCipherSSL
Set-ArubaCPEndpoint
Set-ArubaCPNetworkDevice
Set-ArubaCPNetworkDeviceGroup
Set-ArubaCPStaticHostList
Set-ArubaCPuntrustedSSL
Set-ArubaCPVmAddLicencePlatform
Set-ArubaCPVmApiClient
Set-ArubaCPVmFirstBoot
Set-ArubaCPVmSetup
Set-ArubaCPVmUpdate
Show-ArubaCPException
```

# Author

**Alexis La Goutte**
- <https://github.com/alagoutte>
- <https://twitter.com/alagoutte>

# Special Thanks

- Warren F. for his [blog post](http://ramblingcookiemonster.github.io/Building-A-PowerShell-Module/) 'Building a Powershell module'
- Erwan Quelin for help about Powershell

# License

Copyright 2018 Alexis La Goutte and the community.
