import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:otobix_inspection_app/Controller/login_controller.dart';

import 'package:otobix_inspection_app/constants/app_colors.dart';
import 'package:otobix_inspection_app/widgets/button_widget.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});
  final formKey = GlobalKey<FormState>();
  final LoginController getxController = Get.put(LoginController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: formKey,
                // autovalidateMode: AutovalidateMode.always,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildAppLogo(),
                    SizedBox(height: 10),
                    _buildSignInText(),
                    SizedBox(height: 30),
                    _buildCustomTextField(
                      icon: Icons.person,
                      label: 'User Name / User ID',
                      controller: getxController.userNameController,
                      hintText: 'e.g. amitparekh007',
                      keyboardType: TextInputType.text,
                      isRequired: true,
                    ),
                    SizedBox(height: 15),
                    _buildCustomTextField(
                      icon: Icons.lock,
                      label: 'Password',
                      controller: getxController.passwordController,
                      hintText: 'e.g. amit123',
                      keyboardType: TextInputType.visiblePassword,
                      isRequired: true,
                      isPasswordField: true,
                    ),
                    SizedBox(height: 15),
                    _buildCustomTextField(
                      label: 'Contact Number',
                      controller: getxController.phoneNumberController,
                      hintText: 'e.g. 9876543210',
                      limitLengthToTen: true,
                      keyboardType: TextInputType.phone,
                      isRequired: true,
                      onSubmitted: (value) {
                        // Validate all fields first
                        // if (formKey.currentState!.validate()) {
                        getxController.loginUser();
                        // }
                      },
                    ),
                    // SizedBox(height: 10),
                    // _buildForgetPasswordButton(),
                    SizedBox(height: 15),
                    _buildContinueButton(context),
                    // SizedBox(height: 50),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     Text(
                    //       'Don\'t have an account?',
                    //       style: TextStyle(color: AppColors.grey),
                    //     ),
                    //     SizedBox(width: 5),
                    //     InkWell(
                    //       onTap: () {
                    //         // Get.delete<RegisterController>();
                    //         // Get.to(() => RegisterPage());
                    //       },
                    //       borderRadius: BorderRadius.circular(50),

                    //       // onTap: () => Get.to(() => SignUpPage()),
                    //       child: Padding(
                    //         padding: const EdgeInsets.symmetric(horizontal: 3),
                    //         child: Text(
                    //           'Register',
                    //           style: TextStyle(
                    //             color: AppColors.green,
                    //             fontWeight: FontWeight.bold,
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppLogo() =>
      Image.asset("assets/images/applogo.png", height: 150, width: 150);
  Widget _buildSignInText() => Column(
    children: [
      Text(
        'Login',
        style: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
          color: AppColors.black,
        ),
      ),
      Text(
        'Please enter your details',
        style: TextStyle(fontSize: 12, color: AppColors.grey),
      ),
    ],
  );
  Widget _buildCustomTextField({
    IconData? icon,
    required String label,
    required TextEditingController controller,
    required String hintText,
    required TextInputType keyboardType,
    required bool isRequired,
    bool isPasswordField = false,
    bool limitLengthToTen = false,
    Function(String)? onSubmitted,
  }) {
    // String? validator(String? value) {
    //   if (isRequired && (value == null || value.trim().isEmpty)) {
    //     return "$label is required";
    //   }
    //   if (limitLengthToTen && value!.length != 10) {
    //     return "Contact Number must be exactly 10 digits";
    //   }
    //   return null;
    // }

    String? validator(String? value) {
      final text = value?.trim() ?? "";
      if (isRequired && text.isEmpty) {
        return "$label is required";
      }
      if (label == "User Name / User ID" &&
          text.isNotEmpty &&
          text.length < 4) {
        return "User ID must be at least 4 characters";
      }
      if (isPasswordField && text.isNotEmpty) {
        final msg = getxController.validatePassword(text);
        if (msg != null) return msg;
      }
      if (label == "Contact Number" && text.isNotEmpty) {
        // if (!RegExp(r'^[0-9]{10}$').hasMatch(text)) {
        if (!RegExp(r'^[6-9]\d{9}$').hasMatch(text)) {
          return "Enter a valid 10-digit phone number";
        }
      }
      return null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        SizedBox(height: 5),
        !isPasswordField
            ? TextFormField(
                controller: controller,
                keyboardType: keyboardType,
                maxLength: limitLengthToTen ? 10 : null,
                validator: validator,
                onFieldSubmitted: onSubmitted,
                decoration: InputDecoration(
                  counterText: "",
                  hintText: hintText,
                  hintStyle: TextStyle(
                    color: AppColors.grey.withValues(alpha: .5),
                  ),
                  prefixIconConstraints: BoxConstraints(
                    minWidth: 0,
                    minHeight: 0,
                  ),
                  prefixIcon: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        icon != null
                            ? Icon(icon, color: AppColors.black, size: 20)
                            : Text(
                                '+91',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                        SizedBox(width: 8),
                        Container(width: 1, height: 20, color: Colors.grey),
                        SizedBox(width: 8),
                      ],
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.green, width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 10,
                  ),
                ),
              )
            : Obx(
                () => TextFormField(
                  controller: controller,
                  keyboardType: keyboardType,
                  maxLength: limitLengthToTen ? 10 : null,
                  obscureText: isPasswordField
                      ? getxController.obsecureText.value
                      : false,
                  validator: validator,
                  decoration: InputDecoration(
                    counterText: "",
                    hintText: hintText,
                    hintStyle: TextStyle(color: AppColors.grey.withOpacity(.5)),
                    prefixIconConstraints: BoxConstraints(
                      minWidth: 0,
                      minHeight: 0,
                    ),
                    prefixIcon: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          icon != null
                              ? Icon(icon, color: AppColors.black, size: 20)
                              : Text(
                                  '+91',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                          SizedBox(width: 8),
                          Container(width: 1, height: 20, color: Colors.grey),
                          SizedBox(width: 8),
                        ],
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppColors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppColors.green, width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 10,
                    ),
                    suffixIcon: isPasswordField
                        ? GestureDetector(
                            onTap: () => getxController.obsecureText.value =
                                !getxController.obsecureText.value,
                            child: Icon(
                              getxController.obsecureText.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          )
                        : SizedBox.shrink(),
                  ),
                ),
              ),
      ],
    );
  }

  Widget _buildContinueButton(BuildContext context) => ButtonWidget(
    text: 'Continue',
    isLoading: getxController.isLoading,
    onTap: () {
      getxController.loginUser();
    },
    height: 40,
    width: 150,
    backgroundColor: AppColors.green,
    textColor: AppColors.white,
    loaderSize: 15,
    loaderStrokeWidth: 1,
    loaderColor: AppColors.white,
  );
}
