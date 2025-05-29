import 'package:get/get.dart';

class BarcodeScannerController extends GetxController {
  // Observable for the scanned barcode result
  var scannedCode = RxString('');
  
  // Observable for loading/processing state if needed
  var isLoading = false.obs;
  
  // Method to update the scanned code
  void updateScannedCode(String code) {
    scannedCode.value = code;
  }
  
  // Clear the scanned code (if needed)
  void clearScannedCode() {
    scannedCode.value = '';
  }
}
