# EXAMEN · MÒDUL 489

## Programació de Dispositius Mòbils i Multimèdia

**Unitats Formatives:** RA2 i RA3  
**Curs:** 2n DAM · Videojocs  
**Data:** _______23/03/2026_____________  
**Durada:** 2 hores  

**Alumne/a:** _________Nicolas Alejandro Rios Garcia_______________________________________  
**Grup:** _______________DAM 2n___________________________________  

---

## Posada en marxa de l'entorn

Consulta el fitxer **`README.md`** del projecte per a les instruccions completes d'instal·lació i arrencada (Node.js, servidor mock i Flutter).

---

> **Instruccions generals**
>
> - Respon cada pregunta en l'espai indicat (substitueix el text `[Escriu la teva resposta aquí]`).
> - Per a la part de codi, escriu directament en bloc `dart`. No és necessari que el codi compili, però ha de reflectir coneixement real de Flutter/Dart.
> - Tens el codi dels projectes **Cars** i **Phone** com a referència en el teu ordinador. **No pots accedir a internet** durant l'examen.
> - Desa el fitxer i lliura'l amb el nom: `EXAMEN_M489_[el_teu_nom].md`
> - Fes commit i push del .md modificat i de tots els arxius que hagis modificat

---

## BLOC 1 · ARQUITECTURA I CICLE DE VIDA *(RA 2)*

### Pregunta 1.1 – Comunicació entre Widgets *(12 punts)*

Al projecte **Cars**, el widget `CarsPage` gestiona el número de pàgina actual (`_currentPage`) i el passa a `CarsList1`. El widget `ButtonPanel` conté els botons "Anterior" i "Següent".

**a)** A `cars_page.dart`, el widget utilitza el mètode `setState` per gestionar la paginació. Explica:

- Quina és la funció de `setState` i per què cridar-lo fa que la UI es torni a dibuixar.
- Per quin motiu `_loadPage()` fa servir dos crides a `setState` separades (una a l'inici i una al final) en lloc d'una sola.

**Resposta:**

```
setState notifica a Flutter que l'estat intern del "State" ha canviat. Quan el cridem flutter marca el widget com a "dirty" i torna a executar build, de manera que la UI es refresca amb els nous valors.

A `_loadPage()` es fan dues crides separades perquè representen dos moments diferents:
1) Inici de la petició: "_isloading = true" i "_error = null".
2) Final de la petició: actualitzar dades (_cars) o error (_error) i posar "_isloading = false".

Si fas una sola crida, l'usuari no veuria l'estat de càrrega mentre espera la resposta de xarxa.
```

---

### Pregunta 1.2 – Cicle de vida d'un widget amb recursos *(13 punts)*

Al projecte **Camera**, el widget `CameraScreen` utilitza un `CameraController` per gestionar la càmera del dispositiu. Aquest controlador ocupa recursos del sistema (càmera, memòria) i cal alliberar-los correctament.

**a)** Quin mètode del cicle de vida de `State` s'usa a `CameraScreen` per alliberar el `CameraController` quan el widget és destruït? Escriu com es fa i explica per quina raó és imprescindible cridar-lo.

**Resposta:**

```
S'utilitza dispose()

void dispose() {
  _controller.dispose();
  super.dispose();
}
```

---

**b)** El `CameraController` s'inicialitza de forma asíncrona a `initState()` i el resultat es guarda a `_initializeControllerFuture`. Respon les preguntes següents:

- Per quin motiu no es pot fer `await` directament a `initState()`?
- Quina millora aporta a l'usuari usar `FutureBuilder` en lloc de bloquejar el fil?
- Com treballen junts `_initializeControllerFuture` i `FutureBuilder`?

**Resposta:**

```
No es pot fer "await" en initState() perquè ha de ser síncrona, i flutter necessita que retorni.
FutureBuilder no bloqueixa el fil principal
```

---

## BLOC 2 · COMUNICACIÓ, PERSISTÈNCIA I PROVES *(RA 2 — 35 punts)*

### Pregunta 2.1 – Consum d'API i robustesa *(18 punts)*

Analitza el mètode `getCarsPage(int page, int limit)` de `car_http_service.dart`.

Què passaria si el servidor de l'API trigués 60 segons a respondre? L'aplicació quedaria bloquejada per a l'usuari? Per què? Escriu com implementaries un *timeout* de 10 segons a la petició HTTP.

**Resposta:**

```dart
// Escriu la modificació al getCarsPage aquí:
Future<List<CarsModel>> getCarsPage(int page, int limit) async {
  final offset = (page - 1) * limit;
  final uri = _buildUri('/v1/cars', {'limit': '$limit', 'offset': '$offset'});

  try {
    final response = await http
        .get(uri, headers: _headers)
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return CarsModel.listFromJsonString(response.body);
    }

      throw Exception('Error ${response.statusCode}: ${response.body}');
    } on TimeoutException {
      throw Exception('el servidor ha trigat mes de 10 segons en respondre.');
    } catch (e) {
      throw Exception('Error a getCarsPage: $e');
    }
}
```

---

### Pregunta 2.2 – Models de dades  *(17 punts)*

Analitza el constructor `factory CarsModel.fromMapToCarObject(Map<String, dynamic> json)` de `car_model.dart`.

**a)** Imagina que l'API retorna per error el camp `year` com a `String` en lloc d'`int` (per exemple, `"2021"` en lloc de `2021`). El codi actual fallaria. Escriu com resoldries el problema.

**Resposta:**

```
Resoldria el problema amb una funció que utilitzaria cada vegada que llegim la API, amb una condició, que si no es valor integer salti un error indicant amb un missatge que el valor introduit en el parametre no es un Integer 
```

---

**b)** Al fitxer `class_model_test.dart`, el test utilitza un `const jsonString` amb un JSON escrit a mà en lloc de fer una petició real a l'API de RapidAPI. Explica per quin motiu és millor simular el JSON en un test unitari.

**Resposta:**

```
És millor simular JSON en un test unitari per l'aillament, el test no depèn de la xarxa, per la reproductibilitat sempre s'executa amb les mateixes dades i perque és més ràpid executar tests locals amb dades mock és molt més ràpid que fer-les a HTTP.
```

---

## BLOC 3 · IMPLEMENTACIÓ PRÀCTICA *(RA 3 — 30 punts)*

### Exercici – Widget de detall amb dades remotes

Imagina que volem crear una pantalla de detall per a cada cotxe del projecte Cars. Implementa el mètode `build` d'un widget `StatelessWidget` anomenat `CarDetailPage` que compleixi els requisits següents:

1. Rep un paràmetre `final CarsModel car` al constructor.
2. Mostra el **make** i el **model** del cotxe com a títol destacat (`Text` amb estil gran i negreta).
3. Mostra una **icona diferent** depenent del `type` del cotxe:
   - Si el `type` és `'SUV'`, mostra `Icons.directions_car`.
   - Per qualsevol altre tipus, mostra `Icons.car_rental`.
4. Afegeix un botó `ElevatedButton` que, quan es premi, mostri un `SnackBar` amb el text: `"Cotxe seleccionat: [make] [model]"`.

```dart
// Escriu el teu codi aquí:

class CarDetailPage extends StatelessWidget {
  final CarsModel car;

  const CarDetailPage({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    final iconData = car.type == 'SUV'
        ? Icons.directions_car
        : Icons.car_rental;

    return Scaffold(
      appBar: AppBar(title: const Text('Detall del cotxe')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${car.make} ${car.model}',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Icon(iconData, size: 48),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Cotxe seleccionat: ${car.make} ${car.model}',
                    ),
                  ),
                );
              },
              child: const Text('Seleccionar cotxe'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

**Ampliació (nivell Expert):** Afegeix un `FutureBuilder` que cridi al mètode `CarHttpService().getCarsPage(1, 5)` i mentre espera les dades mostri un `CircularProgressIndicator`. Quan les dades estiguin llestes, mostra un `ListView.builder` amb el `make` de cada cotxe. Si hi hagués un error, mostra un `Text` en color vermell amb el missatge de l'error.

```dart
//Escriu la teva ampliació aquí:
```

---

## BLOC 4 · EXTENSIÓ DEL SERVEI HTTP *(RA 2 — 10 punts)*

### Exercici 4.1 – Mètode parametritzat a `CarHttpService` *(10 punts)*

El servidor mock local té disponible un  endpoint de cerca:

```
GET http://localhost:8080/v1/cars/search?make=Toyota&model=Corolla
```

- El paràmetre `make` filtra per marca (coincidència parcial, insensible a majúscules).
- El paràmetre `model` filtra per model (coincidència parcial, insensible a majúscules).
- Tots dos paràmetres són opcionals: si no s'envien, retorna tots els cotxes.

Exemples vàlids:

- `/v1/cars/search?make=Toyota` → tots els Toyota
- `/v1/cars/search?model=X5` → tots els cotxes amb "X5" al model
- `/v1/cars/search?make=BMW&model=X` → BMW amb "X" al model

**Implementa** el mètode `getCarsByFilter` a la classe `CarHttpService` existent, seguint el mateix patrons que `getCarsPage`:

```dart
// Afegeix aquest mètode a car_http_service.dart:
```

Requisits:

1. Utilitza el mètode privat `_buildUri(String path, Map<String, String> queryParams)` ja existent.
2. Només afegeix els paràmetres `make` i/o `model` al mapa si el valor no és `null` ni buit (`isEmpty`).
3. Gestiona errors i timeout amb el mateix mecanisme que `getCarsPage`.

**Resposta:**

```dart
// Escriu aquí la teva implementació completa del mètode:
Future<List<CarsModel>> getCarsByFilter({String? make, String? model}) async {
}

```

---

## Resum de l'examen

| Bloc | RA | Punts màxims |
|------|----|:------------:|
| Bloc 1 – Arquitectura i Cicle de vida | RA 2 | 25 |
| Bloc 2 – Comunicació, Persistència i Proves | RA 2  | 35 |
| Bloc 3 – `CarDetailPage` (base) | RA 3 | 20 |
| Bloc 3 – Ampliació `FutureBuilder`  | RA 3 | 10 |
| Bloc 4 – Extensió del servei HTTP | RA 2 | 10 |
| **TOTAL** | | **100** |

---
