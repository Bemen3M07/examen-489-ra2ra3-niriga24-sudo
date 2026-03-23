import 'package:flutter/material.dart';
import '../models/car_model.dart';
import '../services/car_http_service.dart';

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
            const SizedBox(height: 24),
            const Text(
              'Llista remota (ampliacio):',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: FutureBuilder<List<CarsModel>>(
                future: CarHttpService().getCarsPage(1, 5),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    );
                  }

                  final cars = snapshot.data ?? const <CarsModel>[];
                  return ListView.builder(
                    itemCount: cars.length,
                    itemBuilder: (context, index) {
                      return ListTile(title: Text(cars[index].make));
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
