/// Placeholder use case for skipping a dose.
/// Currently does not persist anything, but kept for symmetry and future logging.
class SkipDose {
  const SkipDose();

  Future<void> call(String medId) async {
    // No-op for now. Could log or update analytics in the future.
    return;
  }
}

