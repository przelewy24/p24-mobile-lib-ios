# Przelewy24 library documentation - iOS

For general information on the operation of Przelewy24 mobile libraries, visit:
- [https://github.com/przelewy24/p24-mobile-lib-doc](https://github.com/przelewy24/p24-mobile-lib-doc)

To see implementation example please check the example project:
- [https://github.com/przelewy24/p24-mobile-lib-ios-example](https://github.com/przelewy24/p24-mobile-lib-ios-example)

## 1. Project configuration

In project Xcode settings set „iOS Deployment Target” ( „Info” project settings bookmark) to version 8.0 or newer. Version 8.0 is the minimum requirement for the library to work properly with the iOS. The configuration is the same as in the case of Objective-C and Swift.

### Adding dependencies

Library files (`libP24.a`, `P24.h`) should be added to the project. In order to add them, perform the following:

- select „File → Add Files To” in Xcode
- select the folder containing the library
- select option „Copy items into destination folder (if needed)”
- select option „Create groups for any added folders”
- in the field „Add to targets” select all the elements to which a library can be added

Make sure that the Target settings have been updated properly. File `libP24.a` should be added automatically in the field „Link Binary With Libraries”, bookmark „Build Phases”. In order to check that, perform the following:

- select project in “Project Navigator”
- select the Target in which the library is to be used
- select bookmark “Build Phases”
- select section “Link Binary With Libraries”
- if file`libP24.a` is not on the list, drag it from the “Project Navigator” window
- repeat the steps above for all the Targets in which a library is to be used

The following libraries are required and must be added to the Target:

- Security.Framework
- UIKit.Framework
- Foundation.Framework
- libz

The above libraries must be added in section „Link Binary With Libraries”, bookmark „Build Phases”. The operation must be performed for each Target in which a library is to be used.

### Preparation of project

Add flags „-ObjC” i „-lstdc++” in field „Other Linker Flags” in Target settings. In order to add them, perform the following:

- select bookmark „Build Settings” in Target settings
- set field value „Other Linker Flags” to „-ObjC -lstdc++”. Field „Other Linker Flags” is in the „Linking” section
- The steps above must be performed for each Target in which a library is to be used.

Add the setting below to the configurational file `Info.plist`  of the application:

```xml
<key>NSAppTransportSecurity</key>
<dict>
 	<key>NSAllowsArbitraryLoadsInWebContent</key>
 	<true/>
</dict>
```

For applications in Swift, add file `{PROJECT-NAME}-Bridging-Header.h` to the project. In the project bookmark „Build Settings”, field „Objective-C Bridging Header”, enter the access path to the created file  (e.g.  `{PROJECT-NAME}/{PROJECT-NAME}-Bridging-Header.h`). In the created file enter import to file `P24.h`:

```swift
#import "P24.h"
```

**NOTE!**

 > The library contains anti-debug traps, so when using the library methods make sure the „Debug Executable” option is off.

## 2. trnDirect transaction call

In order to call the transaction, the following parameters must be set using the `P24TransactionParams`, class and providing the Merchant ID and the CRC key:


```swift
let transactionParams = P24TransactionParams();
transactionParams.merchantId = XXXXXXX;
transactionParams.crc = XXXXXXX;
transactionParams.sessionId = XXXXXXX;
transactionParams.address = "Test street";
transactionParams.amount = 1;
transactionParams.city = "Poznan";
transactionParams.zip = "61-600";
transactionParams.client = "John smith";
transactionParams.country = "PL";
transactionParams.language = "pl";
transactionParams.currency = "PLN";
transactionParams.email = "test@test.pl";
transactionParams.phone = "1223134134";
transactionParams.desc = "test payment description";

```

Optional parameters:

```swift
transactionParams.method = XXX;
transactionParams.timeLimit = 30;
transactionParams.channel = P24_CHANNEL_CARDS;
transactionParams.urlStatus = "http://XXXXXX";
transactionParams.transferLabel = "Test label";
transactionParams.shipping = 0;

```

Next, an object with the transaction call parameters should be created that will be applicable to the specific method:

```swift
let params = P24TrnDirectParams.init(transactionParams: transactionParams)!
```

Optionally, the transaction call may be set at the Sandbox server:

```swift
params.sandbox = true;
```

Yet another option is to add library settings for bank websites (mobile styles at the banks’ websites – turned on by default, should the library remember logins and passwords, should the library automatically paste sms passwords to the transaction confirmation form at the bank page):

```swift
let settingsParams = new P24SettingsParams();
settingsParams.setEnableBanksRwd = true;
settingsParams.setSaveBankCredential = true;
params.settings = settingsParams;
```

With the configurational objects complete, one may proceed to call `ViewController`  for the transaction. The initiation looks as follows:

```swift
P24.startTrnDirect(params, in: parentViewController, delegate: p24TransferDelegate)
```

In order to serve the transaction result, a delegate must be provided:

```swift
func p24TransferOnSuccess() {
    //sucess
}

func p24TransferOnCanceled() {
    //canceled
}

func p24Transfer(onError errorCode: String!) {
    //error
}
```

`TransferViewController` returns only information regarding the completion of the transaction. It need not mean that the transaction has been verified by the partner’s server. That is why, each time the `p24TransferOnSuccess` method is called, the application should call its own backend to check the transaction status.

## 3. trnRequest transaction call

During the registration with the "trnRegister" method, additional parameters should be provided:
- `p24_mobile_lib=1`
- `p24_sdk_version=X` – where X is a moibile lib version provided by `[P24 sdkVersion]` method

This parameters  allows Przelewy24 to classify the transaction as a mobile transaction. A Token registered without this parameter will not work in the mobile application (an error will appear upon return to the bank and the library file will not detect payment completion).

**NOTE!**

 > When registering a transaction which is to be carried out in a mobile library, remember about the additional parameters:
- `p24_channel` – unless set, the library will feature the payment options „traditional transfer” and „use prepayment”, which are unnecessary in case of mobile payments. In order to deactivate them, use flags that disregard these forms (e.g. value 3 – payments and cards, default entry setting, directly with parameters)
- `p24_method` – if a given transaction in the library is to have a specific, preset method of payment, this method must be selected during the registration
- `p24_url_status` - the address to be used for transaction verification by the partner’s server once the payment process in the mobile library is finished

The transaction parameters must be set using the token of a transaction registered earlier. Optionally, the sandbox server and bank configuration may be set:

```swift
let params = P24TrnRequestParams.init(token: "XXXXXXXXXX-XXXXXX-XXXXXX-XXXXXXXXXX")!
params.sandbox = true
params.settings = settings
```

Next, with the configuration ready, run `ViewControler` to which the parameters and the delegate are to be transferred:

```swift
P24.startTrnRequest(params, in: parentViewController, delegate: p24TransferDelegate)

```

The transaction result should be served in the same way as in the case of "trnDirect".

## 4. Express transaction call

The transaction parameters must be set using the url obtained during the registration of the transaction with Express. The transaction must be registered as mobile.

```swift
let params = P24ExpressParams.init(url: url);
```

Next, call `ViewControler`:

```swift
P24.startExpress(params, in: parentViewController, delegate: p24TransferDelegate);
```

The transaction result should be served in the same way as in the case of "trnDirect".

## 5. Passage 2.0 transaction call

The transaction parameters must be set in the same way as for “trnDirect”. A properly prepared cart object should be added:

```swift
let cart = P24PassageCart()

var item = P24PassageItem(name: "Product 1")!
item.desc = "description 1"
item.quantity = 1
item.price = 100
item.number = 1
item.targetAmount = 100
item.targetPosId = XXXXX

cart.addItem(item)
```

```swift
transactionParams.passageCart = cart;
```

The transaction call and result receipt are carried out in the same way as in the case of „trnDirect”.
