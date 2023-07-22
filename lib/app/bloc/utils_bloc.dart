class Utils {
  String formatUserNameForCollection(String userName) {
    String formattedName = userName.toLowerCase();

    formattedName = formattedName.replaceAll(' ', '_');

    return formattedName;
  }
}
