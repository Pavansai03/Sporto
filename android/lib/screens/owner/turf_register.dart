import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sporto/common/sporto_title.dart';
import 'dart:math' as math;
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sporto/controllers/owner/owner_auth_controller.dart';

class SportTiming {
  TextEditingController sportController = TextEditingController();
  TextEditingController timingController = TextEditingController();
  TextEditingController priceController = TextEditingController();
}

class TurfRegister extends StatefulWidget {
  const TurfRegister({super.key});

  @override
  State<TurfRegister> createState() => _TurfRegisterState();
}

class _TurfRegisterState extends State<TurfRegister> {
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormState>();
  final OwnerAuthController controller = Get.put(OwnerAuthController());

  // Data State
  String ownerName = "", email = "", mobile = "", password = "";
  String turfName = "", address = "";
  double? lat, lng;

  // Image State for Multi-Upload
  List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  // Visibility States for Animation
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  List<SportTiming> dynamicSports = [SportTiming()];

  @override
  void dispose() {
    for (var element in dynamicSports) {
      element.sportController.dispose();
      element.timingController.dispose();
      element.priceController.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  // --- Image Handling Logic ---
  Future<void> _pickMultiImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(imageQuality: 70);
      if (images.isNotEmpty) {
        setState(() => _selectedImages.addAll(images));
      }
    } catch (e) {
      Get.rawSnackbar(message: "Error picking images: $e");
    }
  }

  Future<void> _takeCameraPhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);
      if (photo != null) {
        setState(() => _selectedImages.add(photo));
      }
    } catch (e) {
      Get.rawSnackbar(message: "Error taking photo: $e");
    }
  }

  void _showImageSourceSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.white),
              title: const Text('Take a Photo', style: TextStyle(color: Colors.white)),
              onTap: () { Get.back(); _takeCameraPhoto(); },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.white),
              title: const Text('Choose multiple from Gallery', style: TextStyle(color: Colors.white)),
              onTap: () { Get.back(); _pickMultiImages(); },
            ),
          ],
        ),
      ),
    );
  }

  // --- UI Sections ---

  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Turf Photos', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        _selectedImages.isEmpty
            ? GestureDetector(
          onTap: _showImageSourceSheet,
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_a_photo_outlined, color: Colors.grey, size: 40),
                Text("Add Turf Images", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        )
            : SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _selectedImages.length + 1,
            itemBuilder: (context, index) {
              if (index == _selectedImages.length) {
                return GestureDetector(
                  onTap: _showImageSourceSheet,
                  child: Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                );
              }
              return Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(File(_selectedImages[index].path), width: 100, height: 120, fit: BoxFit.cover),
                    ),
                  ),
                  Positioned(
                    right: 15,
                    top: 5,
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedImages.removeAt(index)),
                      child: Container(
                        decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                        child: const Icon(Icons.close, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStepOne() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Owner Information', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 15),
        _buildTextField('Full Name', Icons.person_outline, (v) => ownerName = v, (v) => v!.isEmpty ? 'Name required' : null),
        const SizedBox(height: 12),
        _buildTextField('Email Address', Icons.email_outlined, (v) => email = v, (v) => !GetUtils.isEmail(v!) ? 'Invalid email' : null),
        const SizedBox(height: 12),
        _buildTextField('Mobile Number', Icons.phone_android_outlined, (v) => mobile = v, (v) => v!.length < 10 ? 'Invalid mobile' : null),
        const SizedBox(height: 12),
        _buildAnimatedPasswordField('Password', _isPasswordVisible, () => setState(() => _isPasswordVisible = !_isPasswordVisible), (v) => v!.length < 6 ? 'Too short' : null, (v) => password = v),
        const SizedBox(height: 12),
        _buildAnimatedPasswordField('Confirm Password', _isConfirmPasswordVisible, () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible), (v) => v != password ? 'Mismatch' : null, (v) {}),
        const SizedBox(height: 30),
        _buildActionButton("Next: Turf Details", () {
          if (_formKey.currentState!.validate()) _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
        }),
      ],
    );
  }

  Widget _buildStepTwo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Turf Details', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 15),
        _buildImageUploadSection(), // Multi-image section
        const SizedBox(height: 20),
        _buildTextField('Turf Name', Icons.stadium_outlined, (v) => turfName = v, (v) => v!.isEmpty ? 'Turf name required' : null),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration('Turf Address', Icons.location_on_outlined),
                onChanged: (val) => address = val,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.1), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), side: const BorderSide(color: Colors.grey)),
                onPressed: () async {
                  if (address.isEmpty) return;
                  try {
                    List<Location> locations = await locationFromAddress(address);
                    if (locations.isNotEmpty) {
                      setState(() {
                        lat = locations.first.latitude;
                        lng = locations.first.longitude;
                      });
                    }
                  } catch (e) {
                    Get.rawSnackbar(message: "Address not found", backgroundColor: Colors.redAccent);
                  }
                },
                child: const Icon(Icons.search_sharp),
              ),
            ),
          ],
        ),
        if (lat != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Color.fromRGBO(61, 205, 22, 1.0), size: 16),
                const SizedBox(width: 4),
                Text('Coordinates: $lat, $lng', style: const TextStyle(color: Color.fromRGBO(61, 205, 22, 1.0), fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),
        const SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Sports, Timings & Price', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            IconButton(onPressed: () => setState(() => dynamicSports.add(SportTiming())), icon: const Icon(Icons.add_circle, color: Color.fromRGBO(61, 205, 22, 1.0), size: 30)),
          ],
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: dynamicSports.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(flex: 3, child: TextFormField(controller: dynamicSports[index].sportController, style: const TextStyle(color: Colors.white, fontSize: 13), decoration: _buildSimpleDecoration('Sport'))),
                  const SizedBox(width: 5),
                  Expanded(flex: 4, child: TextFormField(controller: dynamicSports[index].timingController, style: const TextStyle(color: Colors.white, fontSize: 13), decoration: _buildSimpleDecoration('Timings'))),
                  const SizedBox(width: 5),
                  Expanded(flex: 3, child: TextFormField(controller: dynamicSports[index].priceController, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white, fontSize: 13), decoration: _buildSimpleDecoration('Price/hr'))),
                  if (index > 0) IconButton(onPressed: () => setState(() => dynamicSports.removeAt(index)), icon: const Icon(Icons.remove_circle, color: Colors.redAccent, size: 24)),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 30),
        _buildActionButton("Register Turf", () {
          if (_formKey.currentState!.validate() && lat != null) {
            controller.registerOwnerTurf(
              name: ownerName, email: email, mobile: mobile, password: password,
              turfName: turfName, address: address, lat: lat, lng: lng,
              dynamicSportsData: dynamicSports,
              imageFiles: _selectedImages.map((e) => File(e.path)).toList(), // Passing multi-images
            );
          }
        }),
        Center(child: TextButton(onPressed: () => _pageController.previousPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut), child: const Text("Back", style: TextStyle(color: Colors.grey)))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.black),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, stops: [0.0, 0.4, 0.8], colors: [Color.fromRGBO(61, 205, 22, 1.0), Colors.black, Colors.black]),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SportoTitle(),
                          IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close, color: Colors.white)),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Container(height: 1.0, width: double.infinity, color: Colors.white.withOpacity(0.3)),
                    ],
                  ),
                ),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        SingleChildScrollView(padding: const EdgeInsets.symmetric(horizontal: 16), child: _buildStepOne()),
                        SingleChildScrollView(padding: const EdgeInsets.symmetric(horizontal: 16), child: _buildStepTwo()),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Helpers ---
  InputDecoration _buildInputDecoration(String label, IconData icon) => InputDecoration(prefixIcon: Icon(icon, color: Colors.grey), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.grey)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white)), errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.redAccent)), label: Text(label), labelStyle: const TextStyle(color: Colors.grey));
  InputDecoration _buildSimpleDecoration(String hint) => InputDecoration(hintText: hint, hintStyle: const TextStyle(color: Colors.grey, fontSize: 12), contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.grey, width: 0.5)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.white, width: 1.0)));
  Widget _buildTextField(String l, IconData i, Function(String) o, String? Function(String?) v) => TextFormField(autovalidateMode: AutovalidateMode.onUserInteraction, style: const TextStyle(color: Colors.white), decoration: _buildInputDecoration(l, i), onChanged: o, validator: v);
  Widget _buildAnimatedPasswordField(String l, bool s, VoidCallback t, String? Function(String?) v, Function(String) n) => TextFormField(autovalidateMode: AutovalidateMode.onUserInteraction, style: const TextStyle(color: Colors.white), obscureText: !s, decoration: _buildInputDecoration(l, Icons.lock_outline).copyWith(suffixIcon: IconButton(onPressed: t, icon: TweenAnimationBuilder<double>(duration: const Duration(milliseconds: 400), tween: Tween<double>(begin: 0.0, end: s ? 0.0 : 1.0), builder: (context, value, child) { return Stack(alignment: Alignment.center, children: [const Icon(Icons.visibility, color: Colors.grey), Opacity(opacity: value, child: Transform.rotate(angle: -math.pi / 4, child: Container(width: 2.2, height: 22 * value, color: Colors.grey)))]); }))), validator: v, onChanged: n);
  Widget _buildActionButton(String l, VoidCallback p) => Obx(() => ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color.fromRGBO(61, 205, 22, 1.0), minimumSize: const Size.fromHeight(55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), onPressed: p, child: Text(controller.isOwnerSignupLoading.value ? 'Wait...' : l, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))));
}