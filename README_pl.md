# Dokumentacja biblioteki Przelewy24 - iOS
![](https://raw.githubusercontent.com/przelewy24/p24-mobile-lib-ios/master/libVerImg.svg?sanitize=true)

Ogólne informacje o działaniu bibliotek mobilnych w systemie Przelewy24 znajdziesz pod adresem:

- [https://github.com/przelewy24/p24-mobile-lib-doc](https://github.com/przelewy24/p24-mobile-lib-doc)

Przykład implementacji biblioteki:

- [https://github.com/przelewy24/p24-mobile-lib-ios-example](https://github.com/przelewy24/p24-mobile-lib-ios-example)

## 1. Konfiguracja projektu

W ustawieniach projektu Xcode należy ustawić „iOS Deployment Target” (zakładka „Info” ustawień projektu) na wersję 8.0 lub nowszą. Wersja 8.0 to minimalna wersja systemu iOS wymagana do poprawnego działania biblioteki. Konfiguracja jest identyczna dla projektu
Objective-C i Swift.

### Dodawanie zależności

Należy dodać bibliotekę (`libP24.xcframework`) do projektu. W tym celu należy:

- wybrać w Xcode „File → Add Files To”
- wybrać plik biblioteki
- zaznaczyć opcję „Copy items if needed”
- zaznaczyć opcję „Create groups”
- w polu „Add to targets” wybrać wszystkie elementy, do których ma zostać dodana biblioteka

### Przygotowanie projektu

Należy dodać poniższe ustawienie do pliku konfiguracyjnego `Info.plist` aplikacji:

```xml
<key>NSAppTransportSecurity</key>
<dict>
 	<key>NSAllowsArbitraryLoadsInWebContent</key>
 	<true/>
</dict>
```

**UWAGA!!**

 > Biblioteka ma zaszyte pułapki antydebuggerowe, dlatego korzystając z metod biblioteki należy mieć wyłączone ustawienie „Debug Executable”.

### SSL Pinning

Biblioteka posiada mechanizm SSL Pinningu, który można aktywować globalnie - aby funkcja działała należy upewnić się, że przed wywołaniem jakiejkolwiek metody biblioteki jest ona odpowiedno skonfigurowana. Przykład:

```swift
P24SdkConfig.setCertificatePinningEnabled(true);
```
**UWAGA!!**

 > Aktywując SSL Pinning należy mieć na uwadze, że zaszyte w bibliotece certyfikaty mają swój czas ważności. Gdy będzie się zbliżał czas ich wygaśnięcia, Przelewy24 poinformują o tym oraz udostępnią odpowiednią aktualizację.
 
### Płatność podzielona (split payment)

Funkcja jest dostępna dla wywołań transfer (trnRequest, trnDirect, express). By ją aktywować należy ustawić odpowiednią flagę przed wywołaniem transakcji:

```java
SdkConfig.setSplitPaymentEnabled(true);
```

## 2. Wywołanie transakcji trnDirect

W tym celu należy ustawić parametry transakcji korzystając z klasy `P24TransactionParams`, podając Merchant ID i klucz do CRC:

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

Parametry opcjonalne:

```swift
transactionParams.method = XXX;
transactionParams.timeLimit = 30;
transactionParams.channel = P24_CHANNEL_CARDS;
transactionParams.urlStatus = "http://XXXXXX";
transactionParams.transferLabel = "Test label";
transactionParams.shipping = 0;

```

Następnie stworzyć obiekt z parametrami wywołania transakcji, odpowiedni dla danej metody:

```swift
let params = P24TrnDirectParams.init(transactionParams: transactionParams)!
```

Opcjonalne można ustawić wywołanie transakcji na serwer Sandbox:

```swift
params.sandbox = true;
```

Mając gotowe obiekty konfiguracyjne możemy przystąpić do wywołania `ViewController` dla transakcji. Uruchomienie wygląda następująco:

```swift
P24.startTrnDirect(params, in: parentViewController, delegate: p24TransferDelegate)
```

Aby obsłużyć rezultat transakcji należy przekazać delegat nasłuchujący wywołania odpowiedniej metody wyniku:

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

`TransferViewController` zwraca tylko informację o tym, że transakcja się zakończyła. Nie zawsze oznacza to czy transakcja jest zweryfikowana przez serwer partnera, dlatego za każdym razem po wywołaniu metody `p24TransferOnSuccess` aplikacja powinna odpytać własny backend o status transakcji.

## 3. Wywołanie transakcji trnRequest

Podczas rejestracji transakcji metodą "trnRegister" należy podać dodatkowe parametry:
- `p24_mobile_lib=1`
- `p24_sdk_version=X` – gdzie X jest wersją biblioteki mobilnej otrzymana w wywołaniu metody `[P24 sdkVersion]`

Dzięki tym parametrom system Przelewy24 będzie wiedział że powinien traktować transakcję jako mobilną. Token zarejestrowany bez tego parametru nie zadziała w bibliotece mobilnej (wystąpi błąd po powrocie z banku i okno biblioteki nie wykryje zakończenia płatności).


**UWAGA!**

 > Rejestrując transakcję, która będzie wykonana w bibliotece mobilnej należy pamiętać o dodatkowych parametrach:
- `p24_channel` – jeżeli nie będzie ustawiony, to domyślnie w bibliotece pojawią się formy płatności „przelew tradycyjny” i „użyj przedpłatę”, które są niepotrzebne przy płatności mobilnej. Aby wyłączyć te opcje należy ustawić w tym parametrze flagi nie uwzględniające tych form (np. wartość 3 – przelewy i karty, domyślnie ustawione w bibliotece przy wejściu bezpośrednio z parametrami)
- `p24_method` – jeżeli w bibliotece dla danej transakcji ma być ustawiona domyślnie dana metoda płatności, należy ustawić ją w tym parametrze przy rejestracji
- `p24_url_status` - adres, który zostanie wykorzystany do weryfikacji transakcji przez serwer partnera po zakończeniu procesu płatności w bibliotece mobilnej


Należy ustawić parametry transakcji podając token zarejestrowanej wcześniej transakcji, opcjonalnie można ustawić serwer sandbox:

```swift
let params = P24TrnRequestParams.init(token: "XXXXXXXXXX-XXXXXX-XXXXXX-XXXXXXXXXX")!
params.sandbox = true
```

Następnie mając gotową konfugurację należy uruchomić `ViewControler`, do którego przekazujemy parametry oraz delegata:

```swift
P24.startTrnRequest(params, in: parentViewController, delegate: p24TransferDelegate)

```

Rezultat transakcji należy obsłużyć identycznie jak dla wywołania "trnDirect".

## 4. Wywołanie transakcji Ekspres

Należy ustawić parametry transakcji podając url uzyskany podczas rejestracji transakcji w systemie Ekspres. Transakcja musi być zarejestrowana jako mobilna.

```swift
let params = P24ExpressParams.init(url: url);
```

Następnie wywołać `ViewControler`:

```swift
P24.startExpress(params, in: parentViewController, delegate: p24TransferDelegate);
```

Rezultat transakcji należy obsłużyć identycznie jak dla wywołania "trnDirect".

## 5. Wywołanie transakcji z Pasażem 2.0

Należy ustawić parametry transakcji identycznie jak dla wywołania "trnDirect", dodając odpowiednio przygotowany obiekt koszyka:

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

Wywołanie transakcji oraz odbieranie wyniku jest realizowane identycznie jak dla wywołania "trnDirect".

## 6. Apple Pay

Przed włączeniem tej funkcji należy posiadać odpowiednio skonfigurowany projekt oraz konto Apple Developer:

[https://developer.apple.com/documentation/passkit/apple_pay/](https://developer.apple.com/documentation/passkit/apple_pay/)

By wywołać transakcję Apple Pay należy podać odpowiednie parametry:

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

Alternatywnie, w obiekcie P24ApplePayParams zamiast kwoty i opisu może zostać przekazana lista obiektów typu `PaymentItem`:

```swift
let params = P24ApplePayParams.init(
    items: [exampleItem, exampleItem2],
    currency: "PLN",
    appleMerchantId: "merchant.Przelewy24.sandbox",
    registrar: self
)

P24.startApplePay(params, in: self, delegate: self)
```

Obiekt `PaymentItem` składa się z pola `itemDescription` oraz `amount`:

```swift
let exampleItem = PaymentItem()
exampleItem.amount = 10
exampleItem.itemDescription = "First item"
```

**UWAGA**

>*Parametr `appleMerchantId` to ID uzyskane z kosoli Apple Developer. Należy mieć nauwadze, że to nie to samo co `merchant_id` z sytemu Przelewy24.*

Protokół `P24ApplePayTransactionRegistrar` pozwala na implementację wymiany tokenu otrzymanego za pomocą Apple Pay na token transkacji P24. W momencie wywołania metody `exchange` należy skomunikować się z serwerami P24, przekazać token płatności Apple Pay jako parametr p24_method_ref_id, a następnie tak uzyskany token transakcji przekazać do biblioteki za pomocą delegata, wywołując metodę `onRegisterSuccess`.

```swift
func exchange(_ applePayToken: String!, delegate: P24ApplePayTransactionRegistrarDelegate!) {
    delegate.onRegisterSuccess("P24_TRANSACTION_TOKEN")
}
```

Obsługa rezultatu odbywa się dzięki implementacji protokołu `P24ApplePayDelegate`:

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

W przypadku kiedy chcemy, by tło procesu płatności było transparentne, podczas inicjacji obiektu `P24ApplePayParams` należy przekazać parametr `fullscreen` z wartością ustawioną na true
