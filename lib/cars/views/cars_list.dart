import 'package:flutter/material.dart';
import '../models/car_model.dart';
import 'car_detail_page.dart';

/// Widget de presentació de la llista de cotxes.
///
/// Rep les dades ja carregades des del widget pare (CarsPage).
/// RA2.2: StatelessWidget – no gestiona estat propi ni cicle de vida.
/// RA2.6: Ús del model CarsModel per mostrar dades.
class CarsList extends StatelessWidget {
  final List<CarsModel> cars;
  final bool isLoading;
  final String? error;

  const CarsList({
    super.key,
    required this.cars,
    required this.isLoading,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    // Estat 1: S'estan carregant les dades (setState des de CarsPage)
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Estat 2: S'ha produït un error en la petició HTTP
    if (error != null) {
      return Center(
        child: Text('Error: $error', style: const TextStyle(color: Colors.red)),
      );
    }

    // Estat 3: Llista buida (darrera pàgina)
    if (cars.isEmpty) {
      return const Center(child: Text('No hi ha més cotxes.'));
    }

    // Estat 4: Dades rebudes correctament
    return ListView.builder(
      itemCount: cars.length,
      itemBuilder: (context, index) {
        final car = cars[index];
        return ListTile(
          leading: const Icon(Icons.directions_car),
          title: Text('${car.make} ${car.model}'),
          subtitle: Text('${car.year} · ${car.type}'),
          trailing: Text(
            car.color,
            style: const TextStyle(color: Colors.blueGrey),
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CarDetailPage(car: car),
              ),
            );
          },
        );
      },
    );
  }
}
