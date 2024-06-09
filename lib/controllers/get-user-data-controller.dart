//ignore_for_file: file_names, unused_field, prefer_final_fields, unnecessary_null_comparison, prefer_typing_uninitialized_variables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class GetUserDataController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<QueryDocumentSnapshot<Object?>>> getUserData(String uId) async {
    final QuerySnapshot<Object?> userData = await _firestore
        .collection('controllers')
        .where('uId', isEqualTo: uId)
        .get();
    return userData.docs;
  }
}