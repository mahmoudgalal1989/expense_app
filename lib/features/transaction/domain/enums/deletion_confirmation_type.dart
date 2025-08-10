/// Enum representing the type of confirmation required for deletion operations
enum DeletionConfirmationType {
  /// Show preview of what will be deleted before confirmation
  preview,
  
  /// Delete immediately without preview (for single items or trusted operations)
  immediate,
  
  /// User has already confirmed the deletion (after seeing preview)
  confirmed,
}

/// Extension to provide utility methods for DeletionConfirmationType
extension DeletionConfirmationTypeExtension on DeletionConfirmationType {
  /// Returns true if this requires a preview step
  bool get requiresPreview => this == DeletionConfirmationType.preview;
  
  /// Returns true if this allows immediate deletion
  bool get allowsImmediate => this == DeletionConfirmationType.immediate;
  
  /// Returns true if this represents a confirmed deletion
  bool get isConfirmed => this == DeletionConfirmationType.confirmed;
  
  /// Returns a human-readable string representation
  String get displayName {
    switch (this) {
      case DeletionConfirmationType.preview:
        return 'Preview Required';
      case DeletionConfirmationType.immediate:
        return 'Immediate Deletion';
      case DeletionConfirmationType.confirmed:
        return 'Confirmed Deletion';
    }
  }
}
