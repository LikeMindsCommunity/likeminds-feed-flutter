/// An extension on the List class to provide additional utility methods.
///
/// This extension adds a method to create a copy of the list.
extension LMFeedListExtension<T> on List<T> {
  /// Creates a copy of the list.
  ///
  /// Returns a new list containing all the elements of the original list.
  List<T> copy() {
    return List<T>.from(this);
  }
}
