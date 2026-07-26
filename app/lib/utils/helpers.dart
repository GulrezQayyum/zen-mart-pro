class FirestoreHelper {
  // Convert Firestore Timestamp to readable format
  static String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
 
  // Get time difference (e.g., "2 hours ago")
  static String getTimeAgo(DateTime date) {
    Duration diff = DateTime.now().difference(date);
    
    if (diff.inDays > 0) {
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} minute${diff.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
 
  // Format currency
  static String formatCurrency(double amount) {
    return 'Rs. ${amount.toStringAsFixed(2)}';
  }
 
  // Format rating
  static String formatRating(double rating) {
    return rating.toStringAsFixed(1);
  }
}