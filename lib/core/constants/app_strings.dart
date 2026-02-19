/// App string constants for SwiftPOS
class AppStrings {
  AppStrings._();

  // App Name
  static const String appName = 'SwiftPOS';

  // Common
  static const String ok = 'OK';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String save = 'Save';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String add = 'Add';
  static const String update = 'Update';
  static const String remove = 'Remove';
  static const String search = 'Search';
  static const String filter = 'Filter';
  static const String sort = 'Sort';
  static const String refresh = 'Refresh';
  static const String clear = 'Clear';
  static const String close = 'Close';
  static const String back = 'Back';
  static const String next = 'Next';
  static const String previous = 'Previous';
  static const String done = 'Done';
  static const String apply = 'Apply';
  static const String submit = 'Submit';
  static const String reset = 'Reset';
  static const String view = 'View';
  static const String select = 'Select';
  static const String all = 'All';
  static const String none = 'None';
  static const String yes = 'Yes';
  static const String no = 'No';
  static const String or = 'or';
  static const String and = 'and';

  // Navigation
  static const String home = 'Home';
  static const String dashboard = 'Dashboard';
  static const String settings = 'Settings';
  static const String profile = 'Profile';
  static const String notifications = 'Notifications';
  static const String help = 'Help';
  static const String about = 'About';

  // Status
  static const String loading = 'Loading...';
  static const String success = 'Success';
  static const String error = 'Error';
  static const String warning = 'Warning';
  static const String info = 'Info';
  static const String failed = 'Failed';
  static const String completed = 'Completed';
  static const String pending = 'Pending';
  static const String processing = 'Processing';
  static const String active = 'Active';
  static const String inactive = 'Inactive';

  // Messages
  static const String noData = 'No data available';
  static const String noResults = 'No results found';
  static const String somethingWentWrong = 'Something went wrong';
  static const String pleaseTryAgain = 'Please try again';
  static const String networkError = 'Network error';
  static const String checkConnection = 'Please check your internet connection';
  static const String sessionExpired = 'Session expired';
  static const String loginAgain = 'Please login again';
  static const String unauthorized = 'Unauthorized access';
  static const String forbidden = 'Access forbidden';
  static const String notFound = 'Not found';
  static const String serverError = 'Server error';

  // Validation
  static const String required = 'This field is required';
  static const String invalidEmail = 'Invalid email address';
  static const String invalidPhone = 'Invalid phone number';
  static const String invalidPassword = 'Invalid password';
  static const String passwordTooShort = 'Password is too short';
  static const String passwordMismatch = 'Passwords do not match';
  static const String invalidUrl = 'Invalid URL';
  static const String invalidNumber = 'Invalid number';
  static const String invalidDate = 'Invalid date';
  static const String invalidTime = 'Invalid time';
  static const String minCharacters = 'Minimum {count} characters required';
  static const String maxCharacters = 'Maximum {count} characters allowed';
  static const String minValue = 'Minimum value is {value}';
  static const String maxValue = 'Maximum value is {value}';

  // Auth
  static const String login = 'Login';
  static const String logout = 'Logout';
  static const String signup = 'Sign Up';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String forgotPassword = 'Forgot Password?';
  static const String rememberMe = 'Remember me';
  static const String dontHaveAccount = "Don't have an account?";
  static const String alreadyHaveAccount = 'Already have an account?';
  static const String createAccount = 'Create Account';
  static const String signIn = 'Sign In';
  static const String signUp = 'Sign Up';
  static const String welcomeBack = 'Welcome Back';
  static const String getStarted = 'Get Started';

  // Form
  static const String firstName = 'First Name';
  static const String lastName = 'Last Name';
  static const String fullName = 'Full Name';
  static const String username = 'Username';
  static const String phone = 'Phone';
  static const String address = 'Address';
  static const String city = 'City';
  static const String state = 'State';
  static const String country = 'Country';
  static const String zipCode = 'Zip Code';
  static const String dateOfBirth = 'Date of Birth';
  static const String gender = 'Gender';
  static const String description = 'Description';
  static const String notes = 'Notes';
  static const String tags = 'Tags';
  static const String category = 'Category';
  static const String type = 'Type';
  static const String status = 'Status';
  static const String priority = 'Priority';
  static const String date = 'Date';
  static const String time = 'Time';
  static const String amount = 'Amount';
  static const String price = 'Price';
  static const String quantity = 'Quantity';
  static const String discount = 'Discount';
  static const String tax = 'Tax';
  static const String total = 'Total';

  // Actions
  static const String deleteConfirm =
      'Are you sure you want to delete this item?';
  static const String deleteSuccess = 'Item deleted successfully';
  static const String saveSuccess = 'Saved successfully';
  static const String updateSuccess = 'Updated successfully';
  static const String addSuccess = 'Added successfully';
  static const String removeSuccess = 'Removed successfully';
  static const String copy = 'Copy';
  static const String copied = 'Copied!';
  static const String share = 'Share';
  static const String download = 'Download';
  static const String upload = 'Upload';
  static const String export = 'Export';
  static const String import = 'Import';
  static const String print = 'Print';

  // Time
  static const String today = 'Today';
  static const String yesterday = 'Yesterday';
  static const String tomorrow = 'Tomorrow';
  static const String thisWeek = 'This Week';
  static const String thisMonth = 'This Month';
  static const String thisYear = 'This Year';
  static const String lastWeek = 'Last Week';
  static const String lastMonth = 'Last Month';
  static const String lastYear = 'Last Year';
  static const String nextWeek = 'Next Week';
  static const String nextMonth = 'Next Month';
  static const String nextYear = 'Next Year';

  // Empty States
  static const String emptyList = 'No items in the list';
  static const String emptyCart = 'Your cart is empty';
  static const String emptyOrders = 'No orders yet';
  static const String emptyNotifications = 'No notifications';
  static const String emptyMessages = 'No messages';
  static const String emptySearch = 'Try searching for something else';
  static const String emptyFavorites = 'No favorites yet';
  static const String emptyHistory = 'No history available';

  // Features (POS specific)
  static const String products = 'Products';
  static const String orders = 'Orders';
  static const String customers = 'Customers';
  static const String categories = 'Categories';
  static const String inventory = 'Inventory';
  static const String reports = 'Reports';
  static const String sales = 'Sales';
  static const String discounts = 'Discounts';
  static const String coupons = 'Coupons';
  static const String checkout = 'Checkout';
  static const String payment = 'Payment';
  static const String receipt = 'Receipt';
  static const String invoice = 'Invoice';
  static const String refund = 'Refund';
  static const String exchange = 'Exchange';
  static const String cart = 'Cart';
  static const String wishlist = 'Wishlist';
  static const String favorites = 'Favorites';
  static const String history = 'History';
  static const String transactions = 'Transactions';
}
