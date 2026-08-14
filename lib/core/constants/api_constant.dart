class ApiConstant {
  static const String baseUrl = 'https://grocery.newcinderella.online/api';

  static const String login = '/auth/login';
  static const String loginWithGoogle = '/auth/google';
  static const String logout = '/auth/logout';
  static const String getProfile = '/profile';
  static const String updateProfileInfo = '/profile/info';
  static const String updateProfileImage = '/profile/image';
  // Backend documentation does not state this multipart field name.
  // Keep it isolated so it can be corrected once the contract is supplied.
  static const String profileImageMultipartField = 'profile_image';
  static const String signup = '/auth/register';
  static const String category = '/categories';
  static const String resetPassword = '/auth/reset-password';

  static String detailsOfSubcategories(int id) => '/categories/$id/meals';
  static const String todaysdeals = '/meals/today';
  static const String todayDeals = '/meals/today';
  static const String getProducts = '/products';
  static const String getProductDetails = '/products/:id';
  static const String getmeals = '/meals/:id';
  static const String addToCart = '/cart/items';
  static String updateCartItem(int itemId) => '/cart/items/$itemId';
  static String removeCartItem(int itemId) => '/cart/items/$itemId';
  static const String getCart = '/cart';
  static const String clearCart = '/cart/clear';
  static const String checkout = '/checkout';
  static const String ordersHistory = '/orders';
  static const String getOrderDetails = '/orders/:id';
  static const String getFavorites = '/favorites';
  static const String toggleFavorite = '/favorites/:id/toggle';
  static const String getSmartLists = '/smart-lists';
  static const String smartLists = '/smart-lists';
  static const String smartList = '/smart-lists/:id';
  static const String getOrders = '/orders';
  static const String trackOrder = '/orders/track';
  static String orderDetails(int id) => '/orders/$id';
  static const String sendOtp = '/auth/forgot-password';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyOtp = '/auth/verify-otp';
  static const String recommendations = '/meals/recommendations';
  static const String subcategories = '/subcategories';

  static String meals(int subcategoryId) {
    return "/subcategories/$subcategoryId/meals";
  }

  static const int connectTimeout = 30;
  static const int receiveTimeout = 30;
  static const Map<String, String> headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };
}
