import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_options.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  /// Ensures Firebase is initialized before returning [FirebaseFirestore.instance].
  Future<FirebaseFirestore> get _db async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    return FirebaseFirestore.instance;
  }

  // Stream Market Prices from Firebase Firestore
  Stream<QuerySnapshot<Map<String, dynamic>>> getMarketPricesStream() async* {
    try {
      final db = await _db;
      yield* db.collection('market_prices').snapshots();
    } catch (e) {
      debugPrint('Error streaming market prices: $e');
    }
  }

  // Stream Government Schemes from Firebase Firestore
  Stream<QuerySnapshot<Map<String, dynamic>>> getGovtSchemesStream() async* {
    try {
      final db = await _db;
      yield* db.collection('govt_schemes').snapshots();
    } catch (e) {
      debugPrint('Error streaming govt schemes: $e');
    }
  }

  // Stream Equipment List from Firebase Firestore
  Stream<QuerySnapshot<Map<String, dynamic>>> getEquipmentStream() async* {
    try {
      final db = await _db;
      yield* db.collection('equipment').snapshots();
    } catch (e) {
      debugPrint('Error streaming equipment: $e');
    }
  }

  // Stream Saved Expense & Profit Calculations from Firebase Firestore
  Stream<QuerySnapshot<Map<String, dynamic>>> getExpensesStream() async* {
    try {
      final db = await _db;
      yield* db
          .collection('expenses')
          .orderBy('createdAt', descending: true)
          .snapshots();
    } catch (e) {
      debugPrint('Error streaming expenses: $e');
    }
  }

  // Save Expense & Profit Calculation to Firebase Firestore
  Future<void> saveExpenseCalculation({
    required double seeds,
    required double fertilizer,
    required double labor,
    required double irrigation,
    required double other,
    required double totalExpense,
    required double revenue,
    required double netProfit,
  }) async {
    final db = await _db;
    await db.collection('expenses').add({
      'seeds': seeds,
      'fertilizer': fertilizer,
      'labor': labor,
      'irrigation': irrigation,
      'other': other,
      'totalExpense': totalExpense,
      'revenue': revenue,
      'netProfit': netProfit,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Stream AI Assistant Messages from Firebase Firestore
  Stream<QuerySnapshot<Map<String, dynamic>>> getAiChatsStream() async* {
    try {
      final db = await _db;
      yield* db
          .collection('ai_chats')
          .orderBy('timestamp', descending: false)
          .snapshots();
    } catch (e) {
      debugPrint('Error streaming AI chats: $e');
    }
  }

  // Save AI Assistant Chat Message to Firebase Firestore
  Future<void> saveAiChatMessage({
    required String question,
    required String answer,
  }) async {
    final db = await _db;
    await db.collection('ai_chats').add({
      'question': question,
      'answer': answer,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Submit Scheme Application to Firebase Firestore
  Future<void> submitSchemeApplication({
    required String schemeName,
    required String fullName,
    required String mobileNumber,
    required String aadhaarNumber,
    required String village,
    required String district,
    required String landArea,
  }) async {
    final db = await _db;
    await db.collection('scheme_applications').add({
      'schemeName': schemeName,
      'fullName': fullName,
      'mobileNumber': mobileNumber,
      'aadhaarNumber': aadhaarNumber,
      'village': village,
      'district': district,
      'landArea': landArea,
      'status': 'Pending',
      'appliedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Seeds default market prices, government schemes, and equipment into
  /// Firebase Firestore if the collections are empty.
  Future<void> seedInitialDataIfEmpty() async {
    try {
      final db = await _db;

      // Seed Market Prices
      final mRef = db.collection('market_prices');
      final marketSnap = await mRef.limit(1).get();
      if (marketSnap.docs.isEmpty) {
        final initialMarketPrices = [
          {
            'nameGu': 'કપાસ',
            'nameEn': 'Cotton',
            'market': 'Bhavnagar Yard',
            'min': 1450,
            'max': 1620,
            'avg': 1540,
            'changePercent': 1.8,
            'updatedAt': '8:00 AM',
          },
          {
            'nameGu': 'મગફળી',
            'nameEn': 'Groundnut',
            'market': 'Rajkot Yard',
            'min': 1180,
            'max': 1340,
            'avg': 1260,
            'changePercent': -0.9,
            'updatedAt': '8:00 AM',
          },
          {
            'nameGu': 'ઘઉં',
            'nameEn': 'Wheat',
            'market': 'Bhavnagar Yard',
            'min': 480,
            'max': 540,
            'avg': 512,
            'changePercent': 0.4,
            'updatedAt': '8:00 AM',
          },
          {
            'nameGu': 'બાજરી',
            'nameEn': 'Bajra',
            'market': 'Amreli Yard',
            'min': 410,
            'max': 460,
            'avg': 435,
            'changePercent': 2.1,
            'updatedAt': '8:00 AM',
          },
          {
            'nameGu': 'ડુંગળી',
            'nameEn': 'Onion',
            'market': 'Rajkot Yard',
            'min': 260,
            'max': 340,
            'avg': 300,
            'changePercent': -3.2,
            'updatedAt': '8:00 AM',
          },
        ];
        for (var item in initialMarketPrices) {
          await mRef.add(item);
        }
      }

      // Seed Govt Schemes
      final sRef = db.collection('govt_schemes');
      final schemeSnap = await sRef.limit(1).get();
      if (schemeSnap.docs.isEmpty) {
        final initialSchemes = [
          {
            'iconCode': 0xe1f5,
            'nameGu': 'પ્રધાનમંત્રી કિસાન સન્માન નિધિ',
            'nameEn': 'PM-KISAN',
            'benefitGu': 'વાર્ષિક ₹6,000 ત્રણ હપ્તામાં ખાતામાં જમા',
            'benefitEn': '₹6,000/year credited in 3 installments',
            'eligGu': 'તમામ ખેડૂત પરિવારો (નાની/સીમાંત જમીનધારકો સહિત)',
            'eligEn': 'All landholding farmer families',
          },
          {
            'iconCode': 0xe581,
            'nameGu': 'પ્રધાનમંત્રી ફસલ વીમા યોજના',
            'nameEn': 'Fasal Bima Yojana',
            'benefitGu': 'કુદરતી આપત્તિથી પાક નુકસાનનું વીમા કવચ',
            'benefitEn': 'Crop insurance against natural calamities',
            'eligGu': 'લોન ધારક અને બિન-લોન ધારક ખેડૂતો',
            'eligEn': 'Loanee and non-loanee farmers',
          },
          {
            'iconCode': 0xe571,
            'nameGu': 'સોઈલ હેલ્થ કાર્ડ યોજના',
            'nameEn': 'Soil Health Card Scheme',
            'benefitGu': 'મફત જમીન પરીક્ષણ અને ખાતર સલાહ',
            'benefitEn': 'Free soil testing and fertilizer advice',
            'eligGu': 'તમામ ખેડૂતો',
            'eligEn': 'All farmers',
          },
          {
            'iconCode': 0xe19f,
            'nameGu': 'કિસાન ક્રેડિટ કાર્ડ',
            'nameEn': 'Kisan Credit Card',
            'benefitGu': 'ઓછા વ્યાજે ટૂંકા ગાળાની ખેતી લોન',
            'benefitEn': 'Low-interest short-term farm credit',
            'eligGu': 'જમીન ધરાવતા ખેડૂતો, ભાડૂત ખેડૂતો',
            'eligEn': 'Landowning and tenant farmers',
          },
          {
            'iconCode': 0xe700,
            'nameGu': 'ડ્રિપ ઇરિગેશન સબસિડી',
            'nameEn': 'Drip Irrigation Subsidy',
            'benefitGu': 'ડ્રિપ સિસ્ટમ પર 50-80% સબસિડી',
            'benefitEn': '50-80% subsidy on drip irrigation systems',
            'eligGu': 'નાના અને સીમાંત ખેડૂતો',
            'eligEn': 'Small and marginal farmers',
          },
        ];
        for (var scheme in initialSchemes) {
          await sRef.add(scheme);
        }
      }

      // Seed Equipment
      final eRef = db.collection('equipment');
      final equipSnap = await eRef.limit(1).get();
      if (equipSnap.docs.isEmpty) {
        final initialEquipment = [
          {
            'nameGu': 'ટ્રેક્ટર',
            'nameEn': 'Tractor',
            'brand': 'Mahindra',
            'model': '575 DI',
            'price': 725000,
            'emi': 12500,
          },
          {
            'nameGu': 'રોટાવેટર',
            'nameEn': 'Rotavator',
            'brand': 'Shaktiman',
            'model': 'SRT-6',
            'price': 68000,
            'emi': 2200,
          },
          {
            'nameGu': 'સ્પ્રેયર',
            'nameEn': 'Sprayer',
            'brand': 'Kisankraft',
            'model': 'KK-16E',
            'price': 4500,
            'emi': 0,
          },
          {
            'nameGu': 'ડ્રિપ ઇરિગેશન',
            'nameEn': 'Drip Irrigation',
            'brand': 'Jain Irrigation',
            'model': 'J-Turbo',
            'price': 32000,
            'emi': 1500,
          },
          {
            'nameGu': 'હાર્વેસ્ટર',
            'nameEn': 'Harvester',
            'brand': 'John Deere',
            'model': 'W70',
            'price': 1850000,
            'emi': 28000,
          },
          {
            'nameGu': 'વોટર પંપ',
            'nameEn': 'Water Pump',
            'brand': 'Kirloskar',
            'model': 'KDS-134',
            'price': 15500,
            'emi': 800,
          },
        ];
        for (var equip in initialEquipment) {
          await eRef.add(equip);
        }
      }
    } catch (e) {
      debugPrint('Firestore seed error/warning: $e');
    }
  }
}
