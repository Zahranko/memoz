import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Dummy Model for the Driver
class Driver {
  final String id;
  final String name;
  final String carModel;
  final String carColor;
  final double rating;
  final String priceEstimate;
  final String imageUrl;
  final String arrivalTime;

  Driver({
    required this.id,
    required this.name,
    required this.carModel,
    required this.carColor,
    required this.rating,
    required this.priceEstimate,
    required this.imageUrl,
    required this.arrivalTime,
  });
}

class PickDriverPage extends StatelessWidget {
  final String location;

  PickDriverPage({Key? key, required this.location}) : super(key: key);

  // Dummy Data List
  final List<Driver> dummyDrivers = [
    Driver(
      id: '1',
      name: 'Ahmed Saed',
      carModel: 'Toyota Camry',
      carColor: 'White',
      rating: 4.8,
      priceEstimate: '3.50 JOD',
      arrivalTime: '5 mins',
      imageUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
    ),
    Driver(
      id: '2',
      name: 'Sarah Khaled',
      carModel: 'Hyundai Elantra',
      carColor: 'Silver',
      rating: 4.9,
      priceEstimate: '4.00 JOD',
      arrivalTime: '8 mins',
      imageUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
    ),
    Driver(
      id: '3',
      name: 'Mahmoud Ali',
      carModel: 'Kia Optima',
      carColor: 'Black',
      rating: 4.5,
      priceEstimate: '3.00 JOD',
      arrivalTime: '2 mins',
      imageUrl: 'https://randomuser.me/api/portraits/men/85.jpg',
    ),
    Driver(
      id: '4',
      name: 'John Doe',
      carModel: 'Tesla Model 3',
      carColor: 'Red',
      rating: 5.0,
      priceEstimate: '6.50 JOD',
      arrivalTime: '12 mins',
      imageUrl: 'https://randomuser.me/api/portraits/men/11.jpg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select a Driver",
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
            Text(
              "Near $location",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: dummyDrivers.length,
        itemBuilder: (context, index) {
          final driver = dummyDrivers[index];
          return _buildDriverCard(context, driver);
        },
      ),
    );
  }

  Widget _buildDriverCard(BuildContext context, Driver driver) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(driver.imageUrl),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driver.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${driver.carColor} ${driver.carModel}",
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      driver.rating.toString(),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "• ${driver.arrivalTime} away",
                      style: const TextStyle(color: Colors.green, fontSize: 12),
                    ),
                  ],
                )
              ],
            ),
          ),
          // Price & Button
          Column(
            children: [
              Text(
                driver.priceEstimate,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.brown,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  Get.snackbar(
                    "Request Sent",
                    "Waiting for ${driver.name} to accept...",
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text("Select", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}