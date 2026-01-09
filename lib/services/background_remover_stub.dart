class BackgroundRemoverImplementation {
  Future<String?> removeBackground(String imagePath) async {
    // Web fallback: Just return the original path.
    // Ideally we would show a warning "Not supported on Web".
    print(
      'ML Kit Background Removal not supported on Web. returning original.',
    );
    await Future.delayed(const Duration(seconds: 1)); // Simulate work
    return imagePath;
  }
}

BackgroundRemoverImplementation getBackgroundRemoverImplementation() =>
    BackgroundRemoverImplementation();
