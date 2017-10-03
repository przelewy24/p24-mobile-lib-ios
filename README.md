# Dokumentacja biblioteki Przelewy24 - iOS

Ogólne informacje o działaniu bibliotek mobilnych w systemie Przelewy24 znajdziesz pod adresem:

- [https://github.com/przelewy24/p24-mobile-lib-doc](https://github.com/przelewy24/p24-mobile-lib-doc)

## 1. Konfiguracja projektu

W ustawieniach projektu Xcode należy ustawić „iOS Deployment Target” (zakładka „Info”
ustawień projektu) na wersję 8.0 lub nowszą. Wersja 8.0 to minimalna wersja systemu iOS
wymagana do poprawnego działania biblioteki. Konfiguracja jest identyczna dla projektu
Objective-C i Swift.

### Dodawanie zależności

Należy dodać pliki biblioteki (`libP24.a`, `P24.h`) do projektu. W tym celu należy:

- wybrać w Xcode „File → Add Files To”
- wybrać katalog zawierający bibliotekę (katalog lib)
- zaznaczyć opcję „Copy items into destination folder (if needed)”
- zaznaczyć opcję „Create groups for any added folders”
- w polu „Add to targets” wybrać wszystkie elementy, do których ma zostać dodana
biblioteka

Należy upewnić się, czy ustawienia Targetów zostały poprawnie zaktualizowane. Plik `libP24.a`
powinien zostać automatycznie dopisany w polu „Link Binary With Libraries” w zakładce
„Build Phases”. W tym celu należy:

- wybrać projekt w “Project Navigator”
- wybrać Target, w którym ma być używana biblioteka
- wybrać zakładkę “Build Phases”
- wybrać sekcję “Link Binary With Libraries”
- jeżeli plik `libP24.a` nie znajduje się na liście, należy przeciągnąć go z okna “Project
Navigator”
- powtórzyć powyższe kroki dla wszystkich Targetów, w których ma być wykorzystywana
biblioteka

Należy dodać do Targetu wymagane biblioteki systemowe. Wymagane są następujące
biblioteki:

- Security.Framework
- UIKit.Framework
- Foundation.Framework
- libz

Biblioteki te należy dodać do sekcji „Link Binary With Libraries” w zakładce „Build Phases”. Należy wykonać to dla każdego Targetu, w którym będzie wykorzystywana biblioteka.

### Przygotowanie projektu

Należy dodać flagi „-ObjC” i „-lstdc++” w polu „Other Linker Flags” w ustawieniach Targetu. W tym celu należy:

- wybrać zakładkę „Build Settings” w ustawieniach Targetu
- ustawić wartość pola „Other Linker Flags” na „-ObjC -lstdc++”. Pole „Other
Linker Flags” znajduje się w sekcji „Linking”
- powyższe kroki należy powtórzyć dla każdego Targetu, w którym biblioteka będzie
wykorzystywana

Należy dodać poniższe ustawienie do pliku konfiguracyjnego `Info.plist` aplikacji:

```xml
<key>NSAppTransportSecurity</key>
<dict>
 	<key>NSAllowsArbitraryLoadsInWebContent</key>
 	<true/>
</dict>
```

Dla aplikacji w języku Swift dodać do projektu plik `{PROJECT-NAME}-Bridging-Header.h`. W
zakładce „Build Settings” projektu w polu „Objective-C Bridging Header” wpisać ścieżkę do
utworzonego pliku (np. `{PROJECT-NAME}/{PROJECT-NAME}-Bridging-Header.h`). Wpisać w
utworzonym pliku import do pliku `P24.h`:

```swift
#import "P24.h"
```
[quote]
# Uwaga
Biblioteka ma zaszyte pułapki antydebuggerowe, dlatego korzystając z metod biblioteki należy mieć wyłączony „Debug Executable”.
[/quote]

## 2. Wywołanie transakcji trnDirect

W tym celu należy ustawić parametry transakcji korzystając z klasy `P24TransactionParams`, podając Merchant Id i klucz do CRC:

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

Następnie stworzyć obiekt z parametrami wywołania transakcji, odpowiedni dla danej metody:

```swift
let params = P24TrnDirectParams.init(transactionParams: transactionParams)!
```

Opcjonalne można ustawić wywołanie transakcji na serwer Sandbox:

```swift
params.sandbox = true;
```

Również opcjonalne można dodać ustawienia zachowania biblioteki dla stron banków (style mobile na stronach banków – domyślnie włączone, czy biblioteka ma zapamiętywać logi i hasło do banków):

```swift
let settingsParams = new P24SettingsParams();
settingsParams.setEnableBanksRwd = true;
settingsParams.setSaveBankCredential = true;
params.settings = settingsParams;
```

Mając gotowe obiekty konfiguracyjne możemy przystąpić do wywołania `ViewController` dla transakcji. Uruchomienie wygląda następująco:

```swift
P24.startTrnDirect(params, in: parentViewController, delegate: p24TransferDelegate)
```

Aby obsłużyć rezultat transakcji należy przekazać delegat nasłuchujący wywołania odpowiedniej metody wyniku:

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

`TransferViewController` zwraca tylko informację o tym, że transakcja się zakończyła. Nie zawsze oznacza to czy transakcja jest zweryfikowana przez serwer partnera, dlatego za każdym razem po wywołaniu metody `p24TransferOnSuccess` aplikacja powinna odpytać własny backend o status transakcji.

## 3. Wywołanie transakcji trnRequest

Podczas rejestracji transakcji metodą "trnRegister" należy podać parametr `p24_mobile_lib=1`, dzięki czemu system Przelewy24 będzie wiedział że powinien traktować transakcję jako mobilną. Token zarejestrowany bez tego parametru nie zadziała w bibliotece mobilnej (wystąpi błąd po powrocie z banku i okno biblioteki nie wykryje zakończenia płatności).

**UWAGA!**

 > Rejestrując transakcję, która będzie wykonana w bibliotece mobilnej należy
pamiętać o dodatkowych parametrach:
- `p24_channel` – jeżeli nie będzie ustawiony, to domyślnie w bibliotece pojawią się
formy płatności „przelew tradycyjny” i „użyj przedpłatę”, które są niepotrzebne przy płatności mobilnej. Aby wyłączyć te opcje należy ustawić w tym parametrze flagi nie
uwzględniające tych form (np. wartość 3 – przelewy i karty, domyślnie ustawione w
bibliotece przy wejściu bezpośrednio z parametrami)
- `p24_method` – jeżeli w bibliotece dla danej transakcji ma być ustawiona domyślnie
dana metoda płatności, należy ustawić ją w tym parametrze przy rejestracji
- `p24_url_status` - adres, który zostanie wykorzystany do weryfikacji transakcji przez serwer partnera po zakończeniu procesu płatności w bibliotece mobilnej


Należy ustawić parametry transakcji podając token zarejestrowanej wcześniej transakcji, opcjonalnie można ustawić serwer sandbox oraz konfigurację banków:

```swift
let params = P24TrnRequestParams.init(token: token)!
params.sandbox = sandnoxSwitch.isOn
params.settings = settings
```

Następnie mając gotową konfugurację należy uruchomić `ViewControler`, do którego przekazujemy parametry oraz delegata:

```swift
P24.startTrnRequest(params, in: parentViewController, delegate: p24TransferDelegate)

```

Rezultat transakcji należy obsłużyć identycznie jak dla wywołania "trnDirect".

## 4. Wywołanie transakcji Ekspres

Należy ustawić parametry transakcji podając url uzyskany podczas rejestracji transakcji w systemie Ekspres. Transakcja musi być zarejestrowana jako mobilna.

```swift
let params = P24ExpressParams.init(url: url);
```

Następnie wywołać `ViewControler`:

```swift
P24.startExpress(params, in: parentViewController, delegate: p24TransferDelegate);
```

Rezultat transakcji należy obsłużyć identycznie jak dla wywołania "trnDirect".

## 5. Wywołanie transakcji z Pasażem 2.0

Należy ustawić parametry transakcji identycznie jak dla wywołania "trnDirect", dodając odpowiednio przygotowany obiekt koszyka:

```swift
let cart = P24PassageCart()

var item = P24PassageItem(name: "Product 1")!
item.desc = "description 1"
item.quantity = 1
item.price = 100
item.number = 1
item.targetAmount = 100
item.targetPosId = 51987

cart.addItem(item)
```

```swift
transactionParams.passageCart = cart;
```

Wywołanie transakcji oraz odbieranie wyniku jest realizowane identycznie jak dla wywołania "trnDirect".
