import '../models/clinic_model.dart';
import '../models/hospital_model.dart';
import '../models/location_model.dart';
import '../models/pharmacy_model.dart';
import '../models/route_model.dart';

class NearbyHealthcareDummyData {
  static const currentLocation = LocationModel(
    latitude: 27.7172,
    longitude: 85.3240,
    address: 'Ratna Park, Kathmandu',
    label: 'Current location',
  );

  static const hospitals = [
    HospitalModel(
      id: 'h1',
      name: 'City General Hospital',
      type: 'Multi-specialty hospital',
      location: LocationModel(
        latitude: 27.7106,
        longitude: 85.3201,
        address: 'Tripureshwor, Kathmandu',
        label: 'City General Hospital',
      ),
      distanceKm: 1.4,
      travelTimeMinutes: 7,
      rating: 4.6,
      phoneNumber: '+977-01-5550101',
      isOpen: true,
      hasEmergency: true,
      services: ['Emergency', 'ICU', 'Radiology', 'Pharmacy', 'Lab'],
    ),
    HospitalModel(
      id: 'h2',
      name: 'Kathmandu Heart Center',
      type: 'Cardiac hospital',
      location: LocationModel(
        latitude: 27.7241,
        longitude: 85.3364,
        address: 'Naxal, Kathmandu',
        label: 'Kathmandu Heart Center',
      ),
      distanceKm: 2.2,
      travelTimeMinutes: 11,
      rating: 4.7,
      phoneNumber: '+977-01-5550202',
      isOpen: true,
      hasEmergency: true,
      services: ['Cardiology', 'ECG', 'Cath Lab', 'Emergency'],
    ),
    HospitalModel(
      id: 'h3',
      name: 'Community Care Hospital',
      type: 'General hospital',
      location: LocationModel(
        latitude: 27.7016,
        longitude: 85.3180,
        address: 'Teku, Kathmandu',
        label: 'Community Care Hospital',
      ),
      distanceKm: 2.8,
      travelTimeMinutes: 14,
      rating: 4.3,
      phoneNumber: '+977-01-5550303',
      isOpen: false,
      hasEmergency: false,
      services: ['OPD', 'Lab', 'Pediatrics', 'General Medicine'],
    ),
  ];

  static const clinics = [
    ClinicModel(
      id: 'c1',
      name: 'Family Health Clinic',
      specialty: 'Family Medicine',
      location: LocationModel(
        latitude: 27.7158,
        longitude: 85.3298,
        address: 'Kamaladi, Kathmandu',
        label: 'Family Health Clinic',
      ),
      distanceKm: 0.9,
      travelTimeMinutes: 5,
      rating: 4.4,
      phoneNumber: '+977-01-5551101',
      isOpen: true,
    ),
    ClinicModel(
      id: 'c2',
      name: 'Women and Child Clinic',
      specialty: 'Gynecology and Pediatrics',
      location: LocationModel(
        latitude: 27.7212,
        longitude: 85.3135,
        address: 'Thamel, Kathmandu',
        label: 'Women and Child Clinic',
      ),
      distanceKm: 1.7,
      travelTimeMinutes: 9,
      rating: 4.5,
      phoneNumber: '+977-01-5551202',
      isOpen: true,
    ),
  ];

  static const pharmacies = [
    PharmacyModel(
      id: 'p1',
      name: '24 Hour Care Pharmacy',
      location: LocationModel(
        latitude: 27.7161,
        longitude: 85.3228,
        address: 'Bagbazar, Kathmandu',
        label: '24 Hour Care Pharmacy',
      ),
      distanceKm: 0.5,
      travelTimeMinutes: 3,
      rating: 4.5,
      phoneNumber: '+977-01-5552101',
      isOpen: true,
      hasDelivery: true,
      availableServices: ['Prescription refill', 'OTC medicines', 'Delivery'],
    ),
    PharmacyModel(
      id: 'p2',
      name: 'MediPoint Pharmacy',
      location: LocationModel(
        latitude: 27.7128,
        longitude: 85.3311,
        address: 'Putalisadak, Kathmandu',
        label: 'MediPoint Pharmacy',
      ),
      distanceKm: 1.1,
      travelTimeMinutes: 6,
      rating: 4.2,
      phoneNumber: '+977-01-5552202',
      isOpen: true,
      hasDelivery: false,
      availableServices: ['OTC medicines', 'First aid', 'Health devices'],
    ),
  ];

  static HealthcareRouteModel routeTo({
    required LocationModel destination,
    required double distanceKm,
    required int minutes,
  }) {
    return HealthcareRouteModel(
      id: 'route-${destination.label.toLowerCase().replaceAll(' ', '-')}',
      origin: currentLocation,
      destination: destination,
      distanceKm: distanceKm,
      travelTimeMinutes: minutes,
      mode: 'Driving',
      steps: [
        'Start from ${currentLocation.address}.',
        'Head toward the nearest main road.',
        'Continue for ${distanceKm.toStringAsFixed(1)} km.',
        'Arrive at ${destination.label}.',
      ],
    );
  }
}
