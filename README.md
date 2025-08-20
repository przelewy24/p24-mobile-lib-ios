# Przelewy24 library documentation - iOS
![](https://raw.githubusercontent.com/przelewy24/p24-mobile-lib-ios/master/libVerImg.svg?sanitize=true)

For general information on the operation of Przelewy24 mobile libraries, visit:
- [https://github.com/przelewy24/p24-mobile-lib-doc](https://github.com/przelewy24/p24-mobile-lib-doc)

To see implementation example please check the example project:
- [https://github.com/przelewy24/p24-mobile-lib-ios-example](https://github.com/przelewy24/p24-mobile-lib-ios-example)

## 1. Project configuration

In project Xcode settings set „iOS Deployment Target” ( „Info” project settings bookmark) to version 8.0 or newer. Version 8.0 is the minimum requirement for the library to work properly with the iOS. The configuration is the same as in the case of Objective-C and Swift.

### Adding dependencies

#### Swift Package Manager Integration
The library can be easily integrated using Swift Package Manager. To add the Przelewy24 library to your project:

1. In Xcode, select **File > Add Package Dependencies**
2. Enter the repository URL: `https://github.com/przelewy24/p24-mobile-lib-ios`
3. Select the version rule that fits your needs (recommended: "Up to Next Major Version")
4. Add the package to your target named **P24**

Alternatively, you can add the dependency directly in your `Package.swift` file:
```swift
dependencies: [
    .package(url: "https://github.com/przelewy24/p24-mobile-lib-ios", from: "3.x.x")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: ["P24"]
    )
]
```

#### Manual integration
Library file `libP24.xcframework`) should be added to the project. In order to add them, perform the following:
- select „File → Add Files To” in Xcode
- select library file
- select option „Copy items if needed"
- select option „Create groups”
- in the field „Add to targets” select all the elements to which a library can be added

### Preparation of project

Add the setting below to the configurational file `Info.plist`  of the application:

```xml
<key>NSAppTransportSecurity</key>
<dict>
 	<key>NSAllowsArbitraryLoadsInWebContent</key>
 	<true/>
</dict>
```

**NOTE!**

 > The library contains anti-debug traps, so when using the library methods make sure the „Debug Executable” option is off.

### SSL Pinning

The library has a Pinning SSL mechanism that can be activated globally for webview calls.
If you want use this feature, please make sure configuration is setup before any library methods calls. Example:

```swift
P24SdkConfig.setCertificatePinningEnabled(true);
```

**NOTE!!**

 > When activating SSL Pinning, keep in mind that the certificates embedded in the library have their validity time. Before time of their expiry, Przelewy24 will be sending out appropriate information and updating

 ### Split payment

The function is available for transfer calls (trnRequest, trnDirect, express). To activate, use the appropriate flag before the transaction request:

```java
SdkConfig.setSplitPaymentEnabled(true);
```

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

The transaction parameters must be set using the token of a transaction registered earlier. Optionally, the sandbox server:

```swift
let params = P24TrnRequestParams.init(token: "XXXXXXXXXX-XXXXXX-XXXXXX-XXXXXXXXXX")!
params.sandbox = true
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

## 6. Apple Pay

Before enabling this function, you must have a properly configured project and an Apple Developer account:

[https://developer.apple.com/documentation/passkit/apple_pay/](https://developer.apple.com/documentation/passkit/apple_pay/)

To execute an Apple Pay transaction, you must provide the appropriate parameters:

```swift

let params = P24ApplePayParams.init(
    appleMerchantId: "merchant.Przelewy24.sandbox",
    amount: 1,
    currency: "PLN",
    description: "Test transaction",
    registrar: self
)

P24.startApplePay(params, in: self, delegate: self)
```

Alternatively, in P24ApplePayParams object instead of amount and description can be passed objects list of type `PaymentItem`:

```swift
let params = P24ApplePayParams.init(
    items: [exampleItem, exampleItem2],
    currency: "PLN",
    appleMerchantId: "merchant.Przelewy24.sandbox",
    registrar: self
)

P24.startApplePay(params, in: self, delegate: self)
```

Object `PaymentItem` consists of `itemDescription` and `amount` fields:

```swift
let exampleItem = PaymentItem()
exampleItem.amount = 10
exampleItem.itemDescription = "First item"
```

**WARNING**

>*The parameter `appleMerchantId` is the ID obtained from the Apple Developer console. You should pay attention that this is not the same as the `merchant_id` from Przelewy24.*

The `P24ApplePayTransactionRegistrar` protocol allows you to implement the exchange of a token received with Apple Pay into a P24 transaction token. When calling the `exchange` method, communicate with the P24 servers, pass the Apple Pay payment token as the parameter `p24_method_ref_id`, and then return the transaction token to the library by calling the `onRegisterSuccess` callback method.

```swift
func exchange(_ applePayToken: String!, delegate: P24ApplePayTransactionRegistrarDelegate!) {
    delegate.onRegisterSuccess("P24_TRANSACTION_TOKEN")
}
```

To handle transaction result you need to implement `P24ApplePayDelegate`:

```swift
func p24ApplePayOnSuccess() {
    // handle success
}

func p24ApplePayOnCanceled() {
    // handle transaction canceled
}

func p24ApplePay(onError errorCode: String!) {
    // handle transaction error
}
```

If we want the background of the payment process to be transparent, wee need init `P24ApplePayParams` object with `fullscreen` parameter value set to true
