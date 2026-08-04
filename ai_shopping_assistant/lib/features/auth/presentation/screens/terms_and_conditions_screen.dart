import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/app_color.dart';
import '../../../../core/utils/app_sizes.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightMedium,
      appBar: AppBar(
        backgroundColor: AppColors.lightMedium,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.secondBlack),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Terms & Conditions",
          style: GoogleFonts.poppins(
            fontSize: AppSizes.sp16,
            fontWeight: FontWeight.w600,
            color: AppColors.secondBlack,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: AppSizes.w24, vertical: AppSizes.h16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLastUpdated(),
            SizedBox(height: AppSizes.h16),
            _buildIntro(),
            SizedBox(height: AppSizes.h20),
            _buildSection(
              title: "1. Acceptance of Terms",
              content:
              "By accessing or using HabiSpace, you agree to be bound by these Terms and Conditions. If you do not agree to all of these terms, you may not use our services.",
            ),
            _buildSection(
              title: "2. Use of Service",
              content:
              "You agree to use HabiSpace only for lawful purposes and in a manner that does not infringe the rights of others. You must not:\n\n"
                  "• Post false, misleading, or fraudulent listings\n"
                  "• Impersonate any person or entity\n"
                  "• Collect user information without consent\n"
                  "• Use the service for any illegal activity\n"
                  "• Interfere with the proper working of the app",
            ),
            _buildSection(
              title: "3. Account Responsibilities",
              content:
              "You are responsible for maintaining the confidentiality of your account credentials. You agree to:\n\n"
                  "• Provide accurate and complete registration information\n"
                  "• Notify us immediately of any unauthorized account use\n"
                  "• Take responsibility for all activities under your account",
            ),
            _buildSection(
              title: "4. Property Listings",
              content:
              "All property listings on HabiSpace are provided for informational purposes only. We do not guarantee the accuracy, completeness, or availability of any listing. Users are encouraged to verify all information before making any decisions.",
            ),
            _buildSection(
              title: "5. Intellectual Property",
              content:
              "All content on HabiSpace, including logos, text, graphics, and software, is the property of HabiSpace or its content suppliers and is protected by applicable intellectual property laws.",
            ),
            _buildSection(
              title: "6. Limitation of Liability",
              content:
              "HabiSpace shall not be liable for any indirect, incidental, special, or consequential damages arising from your use of our services, including but not limited to loss of profits, data, or goodwill.",
            ),
            _buildSection(
              title: "7. Third-Party Links",
              content:
              "Our app may contain links to third-party websites or services. We are not responsible for the content or practices of those third parties and encourage you to review their terms and privacy policies.",
            ),
            _buildSection(
              title: "8. Termination",
              content:
              "We reserve the right to suspend or terminate your account at any time, without notice, for conduct that we determine violates these Terms or is harmful to other users, us, or third parties.",
            ),
            _buildSection(
              title: "9. Governing Law",
              content:
              "These Terms shall be governed by and construed in accordance with the laws of the Arab Republic of Egypt, without regard to its conflict of law provisions.",
            ),
            _buildSection(
              title: "10. Contact Us",
              content:
              "For any questions regarding these Terms and Conditions:\n\n"
                  "📧 legal@habispace.com\n"
                  "📍 Cairo, Egypt",
            ),
            SizedBox(height: AppSizes.h32),
          ],
        ),
      ),
    );
  }

  Widget _buildLastUpdated() {
    return Container(
      padding: EdgeInsets.all(AppSizes.h12),
      decoration: BoxDecoration(
        color: AppColors.blue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSizes.r8),
        border: Border.all(color: AppColors.blue.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.blue, size: AppSizes.r16),
          SizedBox(width: AppSizes.w8),
          Text(
            "Last updated: May 1, 2025",
            style: GoogleFonts.poppins(
              fontSize: AppSizes.sp12,
              color: AppColors.blue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntro() {
    return Text(
      "Please read these Terms and Conditions carefully before using the HabiSpace application. These terms govern your use of our platform and services.",
      style: GoogleFonts.poppins(
        fontSize: AppSizes.sp12,
        color: AppColors.secondBlack.withValues(alpha: 0.75),
        height: 1.7,
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.h20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: AppSizes.sp14,
              fontWeight: FontWeight.w600,
              color: AppColors.secondBlack,
            ),
          ),
          SizedBox(height: AppSizes.h8),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: AppSizes.sp12,
              fontWeight: FontWeight.w400,
              color: AppColors.secondBlack.withValues(alpha: 0.75),
              height: 1.7,
            ),
          ),
          SizedBox(height: AppSizes.h12),
          Divider(color: AppColors.borderColor, thickness: 1),
        ],
      ),
    );
  }
}