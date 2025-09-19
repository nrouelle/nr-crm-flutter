import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isRequired;
  final String? helperText;
  final String? hintText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool obscureText;
  final int? maxLength;
  final int? maxLines;
  final Color? fillColor;
  final EdgeInsets? contentPadding;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.isRequired = false,
    this.helperText,
    this.hintText,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.obscureText = false,
    this.maxLength,
    this.maxLines = 1,
    this.fillColor,
    this.contentPadding,
  });

  // Factory pour les champs nom/prénom
  factory CustomTextFormField.name({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    String? helperText,
  }) {
    return CustomTextFormField(
      controller: controller,
      label: '$label *',
      icon: Icons.person_outline,
      isRequired: true,
      helperText: helperText ?? 'Uniquement lettres, espaces, tirets et apostrophes',
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r"[a-zA-ZÀ-ÿ\s\-'\.]")),
        LengthLimitingTextInputFormatter(50),
      ],
      validator: validator,
    );
  }

  // Factory pour les emails
  factory CustomTextFormField.email({
    required TextEditingController controller,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return CustomTextFormField(
      controller: controller,
      label: 'Email *',
      icon: Icons.email_outlined,
      isRequired: true,
      helperText: 'Format: nom@domaine.com',
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[a-z0-9@._\-]')),
        LengthLimitingTextInputFormatter(100),
      ],
      validator: validator,
      onChanged: onChanged,
    );
  }

  // Factory pour les téléphones
  factory CustomTextFormField.phone({
    required TextEditingController controller,
    required List<TextInputFormatter> phoneFormatters,
    String? Function(String?)? validator,
  }) {
    return CustomTextFormField(
      controller: controller,
      label: 'Téléphone *',
      icon: Icons.phone_outlined,
      isRequired: true,
      helperText: 'Format: 06 12 34 56 78 ou +33 6 12 34 56 78',
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      inputFormatters: [
        ...phoneFormatters,
        LengthLimitingTextInputFormatter(20),
      ],
      validator: validator,
    );
  }

  // Factory pour les URLs
  factory CustomTextFormField.url({
    required TextEditingController controller,
    required String label,
    String? helperText,
    String? hintText,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return CustomTextFormField(
      controller: controller,
      label: label,
      icon: Icons.link_outlined,
      helperText: helperText,
      hintText: hintText,
      keyboardType: TextInputType.url,
      textInputAction: TextInputAction.done,
      inputFormatters: [
        LengthLimitingTextInputFormatter(200),
      ],
      validator: validator,
      onChanged: onChanged,
    );
  }

  // Factory pour les mots de passe
  factory CustomTextFormField.password({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    bool obscureText = true,
  }) {
    return CustomTextFormField(
      controller: controller,
      label: '$label *',
      icon: Icons.lock_outline,
      isRequired: true,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.done,
      inputFormatters: [
        LengthLimitingTextInputFormatter(128),
      ],
      validator: validator,
      obscureText: obscureText,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF219ebc),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: fillColor ?? Colors.grey[50],
            helperText: helperText,
            hintText: hintText,
            contentPadding: contentPadding ?? const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            helperStyle: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
            errorStyle: const TextStyle(
              color: Colors.red,
              fontSize: 12,
            ),
          ),
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          inputFormatters: inputFormatters,
          validator: validator,
          onChanged: onChanged,
          obscureText: obscureText,
          maxLength: maxLength,
          maxLines: maxLines,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),

        // Indicateur visuel pour les champs obligatoires
        if (isRequired && helperText == null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12),
            child: Text(
              'Champ obligatoire',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}

// Extension pour les animations et états visuels
extension CustomTextFormFieldState on CustomTextFormField {
  // Méthode pour animer le focus
  static void animateFocus(TextEditingController from, TextEditingController to) {
    // Implementation future pour les animations de transition
  }

  // Méthode pour valider visuellement
  static bool isValid(GlobalKey<FormState> formKey, TextEditingController controller) {
    return formKey.currentState?.validate() ?? false;
  }
}