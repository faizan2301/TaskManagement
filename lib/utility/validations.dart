String? validateMobile(String value) {
  if (value.isEmpty) {
    return 'Please enter a mobile number';
  } else if (value.length != 10) {
    return 'Mobile number should be 10 digits';
  }
  return null;
}

String? validateUrl(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter a URL';
  }

  const urlPattern =
      r'^(http[s]?:\/\/)?([^\s(["<,>]*\.[^\s[",><]*)+(\:[0-9]{1,5})?(\/[^\s]*)?$';
  final result = RegExp(urlPattern, caseSensitive: false).hasMatch(value);

  if (!result) {
    return 'Please enter a valid URL';
  }
  return null;
}

String? validateEmail(String value) {
  String pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regExp = RegExp(pattern);
  if (value.isEmpty) {
    return "Email is Required";
  } else if (!regExp.hasMatch(value)) {
    return "Invalid Email";
  } else {
    return null;
  }
}

String? validateAdditionalDetails(String value, String hintText) {
  if (value.isEmpty) {
    return "Please enter $hintText";
  }
  return null;
}

String? validateName(String value) {
  if (value.isEmpty) {
    return "Name is required";
  }
  if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
    return "Name can only contain letters and spaces";
  }
  if (value.trim().length < 2) {
    return "Name must be at least 2 characters long";
  }
  return null;
}

String? validatePassword(String value) {
  if (value.isEmpty) {
    return "Password is required";
  }
  if (value.length < 6) {
    return "Password must be at least 6 characters long";
  }
  if (!RegExp(r'[A-Z]').hasMatch(value)) {
    return "Password must contain at least one uppercase letter";
  }
  if (!RegExp(r'[a-z]').hasMatch(value)) {
    return "Password must contain at least one lowercase letter";
  }
  if (!RegExp(r'[0-9]').hasMatch(value)) {
    return "Password must contain at least one number";
  }
  if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
    return "Password must contain at least one special character";
  }
  return null;
}

String? validateConfirmPassword(String password, String confirmPassword) {
  if (confirmPassword.isEmpty) {
    return "Confirm Password is required";
  } else if (password != confirmPassword) {
    return "Passwords do not match";
  }
  return null;
}
