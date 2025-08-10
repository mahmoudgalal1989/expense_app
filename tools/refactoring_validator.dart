/// Refactoring Validation Tool
/// 
/// This tool validates that global BLoC refactoring follows architectural
/// guardrails and prevents common anti-patterns.

import 'dart:io';
import 'dart:convert';

class RefactoringValidator {
  static const String _configPath = 'refactoring_config.json';
  
  /// Validates the current refactoring state against architectural guidelines
  static Future<ValidationResult> validateRefactoring() async {
    final result = ValidationResult();
    
    // Load configuration
    final config = await _loadConfig();
    
    // Run validation checks
    await _validateScopeControl(result, config);
    await _validatePerformanceProtection(result, config);
    await _validateTestability(result, config);
    await _validateDependencyBoundaries(result, config);
    await _validateInitializationStrategy(result, config);
    await _validateGodBlocPrevention(result, config);
    
    return result;
  }
  
  /// Validates that only appropriate state is included in global BLoC
  static Future<void> _validateScopeControl(
    ValidationResult result, 
    Map<String, dynamic> config,
  ) async {
    print('🔍 Validating Scope Control...');
    
    // Check for prohibited state types in global BLoC
    final prohibitedPatterns = [
      'Transaction', 'Search', 'Filter', 'Form', 'Navigation',
      'Loading', 'Error', 'Temporary', 'Cache'
    ];
    
    final globalBlocFiles = await _findGlobalBlocFiles();
    
    for (final file in globalBlocFiles) {
      final content = await File(file).readAsString();
      
      for (final pattern in prohibitedPatterns) {
        if (content.contains('${pattern}State') || 
            content.contains('${pattern}Event')) {
          result.addError(
            'Scope Control Violation',
            'Found prohibited pattern "$pattern" in global BLoC: $file',
            'Move $pattern-related state to feature-specific BLoC',
          );
        }
      }
    }
    
    // Check for required cross-cutting state
    final requiredPatterns = ['Currency', 'Category', 'Theme', 'Locale'];
    final foundPatterns = <String>[];
    
    for (final file in globalBlocFiles) {
      final content = await File(file).readAsString();
      
      for (final pattern in requiredPatterns) {
        if (content.contains(pattern)) {
          foundPatterns.add(pattern);
        }
      }
    }
    
    final missingPatterns = requiredPatterns
        .where((pattern) => !foundPatterns.contains(pattern))
        .toList();
    
    if (missingPatterns.isNotEmpty) {
      result.addWarning(
        'Missing Cross-cutting State',
        'Global BLoC missing: ${missingPatterns.join(', ')}',
        'Consider adding these cross-cutting concerns to global BLoC',
      );
    }
    
    result.addSuccess('Scope Control', 'Validated state boundaries');
  }
  
  /// Validates performance protection measures
  static Future<void> _validatePerformanceProtection(
    ValidationResult result,
    Map<String, dynamic> config,
  ) async {
    print('⚡ Validating Performance Protection...');
    
    final widgetFiles = await _findWidgetFiles();
    
    for (final file in widgetFiles) {
      final content = await File(file).readAsString();
      
      // Check for BlocBuilder without selector (potential performance issue)
      if (content.contains('BlocBuilder<AppSettingsBloc') &&
          !content.contains('BlocSelector')) {
        result.addWarning(
          'Performance Risk',
          'BlocBuilder without selector in: $file',
          'Consider using BlocSelector for granular updates',
        );
      }
      
      // Check for MaterialApp inside BlocBuilder (major performance issue)
      if (content.contains('BlocBuilder') && content.contains('MaterialApp')) {
        result.addError(
          'Performance Critical',
          'MaterialApp inside BlocBuilder in: $file',
          'Move MaterialApp outside BlocBuilder to prevent full tree rebuilds',
        );
      }
      
      // Check for proper state splitting
      if (content.contains('copyWith') && 
          !content.contains('copyWithCurrency') &&
          !content.contains('copyWithCategory')) {
        result.addWarning(
          'State Granularity',
          'Generic copyWith detected in: $file',
          'Consider specific copyWith methods for granular updates',
        );
      }
    }
    
    result.addSuccess('Performance Protection', 'Validated rebuild optimization');
  }
  
  /// Validates testability through modularity
  static Future<void> _validateTestability(
    ValidationResult result,
    Map<String, dynamic> config,
  ) async {
    print('🧪 Validating Testability...');
    
    // Check for handler pattern implementation
    final handlerFiles = await _findHandlerFiles();
    
    if (handlerFiles.isEmpty) {
      result.addError(
        'Testability Issue',
        'No handler files found',
        'Implement handler pattern for modular, testable logic',
      );
      return;
    }
    
    // Check that handlers are testable
    for (final file in handlerFiles) {
      final content = await File(file).readAsString();
      
      // Check for proper handler interface
      if (!content.contains('SettingsHandler') &&
          !content.contains('abstract class')) {
        result.addWarning(
          'Handler Pattern',
          'Handler may not follow interface pattern: $file',
          'Ensure handlers implement SettingsHandler interface',
        );
      }
      
      // Check for dependency injection
      if (!content.contains('Repository') || !content.contains('final')) {
        result.addWarning(
          'Dependency Injection',
          'Handler may not use dependency injection: $file',
          'Inject repositories through constructor for testability',
        );
      }
    }
    
    // Check for corresponding test files
    final testFiles = await _findTestFiles();
    final handlerTestFiles = testFiles
        .where((file) => file.contains('handler') && file.contains('test'))
        .toList();
    
    if (handlerTestFiles.length < handlerFiles.length) {
      result.addWarning(
        'Test Coverage',
        'Missing tests for ${handlerFiles.length - handlerTestFiles.length} handlers',
        'Add unit tests for all handlers',
      );
    }
    
    result.addSuccess('Testability', 'Validated modular architecture');
  }
  
  /// Validates dependency boundaries
  static Future<void> _validateDependencyBoundaries(
    ValidationResult result,
    Map<String, dynamic> config,
  ) async {
    print('🔗 Validating Dependency Boundaries...');
    
    final globalBlocFiles = await _findGlobalBlocFiles();
    
    for (final file in globalBlocFiles) {
      final content = await File(file).readAsString();
      
      // Check for direct repository dependencies (should use service layer)
      final repositoryCount = RegExp(r'Repository\s+\w+;').allMatches(content).length;
      
      if (repositoryCount > 1) {
        result.addError(
          'Dependency Boundary Violation',
          'Global BLoC has $repositoryCount direct repository dependencies in: $file',
          'Introduce SettingsService to aggregate repository calls',
        );
      }
      
      // Check for service layer usage
      if (!content.contains('Service') && repositoryCount > 0) {
        result.addWarning(
          'Missing Service Layer',
          'Consider using service layer in: $file',
          'Aggregate repository calls through SettingsService',
        );
      }
    }
    
    result.addSuccess('Dependency Boundaries', 'Validated service layer usage');
  }
  
  /// Validates initialization strategy
  static Future<void> _validateInitializationStrategy(
    ValidationResult result,
    Map<String, dynamic> config,
  ) async {
    print('🚀 Validating Initialization Strategy...');
    
    final mainFiles = await _findMainFiles();
    
    for (final file in mainFiles) {
      final content = await File(file).readAsString();
      
      // Check for blocking initialization
      if (content.contains('await') && content.contains('InitializeAppSettings')) {
        result.addError(
          'Blocking Initialization',
          'Synchronous initialization detected in: $file',
          'Use lazy loading to prevent blocking app startup',
        );
      }
      
      // Check for partial rendering support
      if (!content.contains('hasData') && !content.contains('isLoaded')) {
        result.addWarning(
          'Partial Rendering',
          'No partial rendering support detected in: $file',
          'Support rendering with partial settings loaded',
        );
      }
    }
    
    result.addSuccess('Initialization Strategy', 'Validated non-blocking startup');
  }
  
  /// Validates against "God BLoC" anti-pattern
  static Future<void> _validateGodBlocPrevention(
    ValidationResult result,
    Map<String, dynamic> config,
  ) async {
    print('🛡️ Validating God BLoC Prevention...');
    
    final globalBlocFiles = await _findGlobalBlocFiles();
    
    for (final file in globalBlocFiles) {
      final content = await File(file).readAsString();
      
      // Count event types
      final eventCount = RegExp(r'class \w+Event').allMatches(content).length;
      final maxEvents = config['maxEventsInGlobalBloc'] ?? 15;
      
      if (eventCount > maxEvents) {
        result.addError(
          'God BLoC Warning',
          'Global BLoC has $eventCount events (max: $maxEvents) in: $file',
          'Consider splitting into multiple BLoCs or removing non-global state',
        );
      }
      
      // Count state properties
      final stateProperties = RegExp(r'final \w+ \w+;').allMatches(content).length;
      final maxProperties = config['maxPropertiesInGlobalState'] ?? 10;
      
      if (stateProperties > maxProperties) {
        result.addWarning(
          'State Complexity',
          'Global state has $stateProperties properties (max: $maxProperties) in: $file',
          'Consider grouping related properties into sub-objects',
        );
      }
    }
    
    result.addSuccess('God BLoC Prevention', 'Validated BLoC size limits');
  }
  
  // Helper methods for file discovery
  static Future<List<String>> _findGlobalBlocFiles() async {
    return await _findFiles(['**/app_settings_bloc.dart', '**/global_*_bloc.dart']);
  }
  
  static Future<List<String>> _findHandlerFiles() async {
    return await _findFiles(['**/handlers/*.dart', '**/*_handler.dart']);
  }
  
  static Future<List<String>> _findWidgetFiles() async {
    return await _findFiles(['**/screens/*.dart', '**/widgets/*.dart', '**/pages/*.dart']);
  }
  
  static Future<List<String>> _findTestFiles() async {
    return await _findFiles(['**/test/**/*.dart']);
  }
  
  static Future<List<String>> _findMainFiles() async {
    return await _findFiles(['**/main.dart', '**/app.dart']);
  }
  
  static Future<List<String>> _findFiles(List<String> patterns) async {
    final files = <String>[];
    final directory = Directory.current;
    
    await for (final entity in directory.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        for (final pattern in patterns) {
          final regex = RegExp(pattern.replaceAll('**/', '.*').replaceAll('*', '.*'));
          if (regex.hasMatch(entity.path)) {
            files.add(entity.path);
            break;
          }
        }
      }
    }
    
    return files;
  }
  
  static Future<Map<String, dynamic>> _loadConfig() async {
    try {
      final file = File(_configPath);
      if (await file.exists()) {
        final content = await file.readAsString();
        return json.decode(content);
      }
    } catch (e) {
      print('Warning: Could not load config file. Using defaults.');
    }
    
    // Default configuration
    return {
      'maxEventsInGlobalBloc': 15,
      'maxPropertiesInGlobalState': 10,
      'requireServiceLayer': true,
      'enforceHandlerPattern': true,
    };
  }
}

class ValidationResult {
  final List<ValidationIssue> _errors = [];
  final List<ValidationIssue> _warnings = [];
  final List<ValidationIssue> _successes = [];
  
  void addError(String category, String message, String recommendation) {
    _errors.add(ValidationIssue(category, message, recommendation, IssueType.error));
  }
  
  void addWarning(String category, String message, String recommendation) {
    _warnings.add(ValidationIssue(category, message, recommendation, IssueType.warning));
  }
  
  void addSuccess(String category, String message) {
    _successes.add(ValidationIssue(category, message, '', IssueType.success));
  }
  
  bool get hasErrors => _errors.isNotEmpty;
  bool get hasWarnings => _warnings.isNotEmpty;
  bool get isValid => !hasErrors;
  
  void printReport() {
    print('\n' + '=' * 60);
    print('🔍 GLOBAL BLOC REFACTORING VALIDATION REPORT');
    print('=' * 60);
    
    if (_successes.isNotEmpty) {
      print('\n✅ SUCCESSES (${_successes.length}):');
      for (final success in _successes) {
        print('  ✓ ${success.category}: ${success.message}');
      }
    }
    
    if (_warnings.isNotEmpty) {
      print('\n⚠️  WARNINGS (${_warnings.length}):');
      for (final warning in _warnings) {
        print('  ⚠️  ${warning.category}: ${warning.message}');
        print('     💡 ${warning.recommendation}');
      }
    }
    
    if (_errors.isNotEmpty) {
      print('\n❌ ERRORS (${_errors.length}):');
      for (final error in _errors) {
        print('  ❌ ${error.category}: ${error.message}');
        print('     🔧 ${error.recommendation}');
      }
    }
    
    print('\n' + '=' * 60);
    if (isValid) {
      print('🎉 VALIDATION PASSED: Refactoring follows architectural guidelines!');
    } else {
      print('🚨 VALIDATION FAILED: ${_errors.length} errors must be fixed before proceeding.');
    }
    print('=' * 60 + '\n');
  }
  
  /// Generate JSON report for CI/CD integration
  Map<String, dynamic> toJson() {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'isValid': isValid,
      'summary': {
        'errors': _errors.length,
        'warnings': _warnings.length,
        'successes': _successes.length,
      },
      'errors': _errors.map((e) => e.toJson()).toList(),
      'warnings': _warnings.map((w) => w.toJson()).toList(),
      'successes': _successes.map((s) => s.toJson()).toList(),
    };
  }
}

class ValidationIssue {
  final String category;
  final String message;
  final String recommendation;
  final IssueType type;
  
  ValidationIssue(this.category, this.message, this.recommendation, this.type);
  
  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'message': message,
      'recommendation': recommendation,
      'type': type.toString(),
    };
  }
}

enum IssueType { error, warning, success }

/// CLI entry point for validation tool
void main(List<String> args) async {
  print('🚀 Starting Global BLoC Refactoring Validation...\n');
  
  final result = await RefactoringValidator.validateRefactoring();
  result.printReport();
  
  // Generate JSON report if requested
  if (args.contains('--json')) {
    final jsonReport = json.encode(result.toJson());
    await File('refactoring_validation_report.json').writeAsString(jsonReport);
    print('📄 JSON report saved to: refactoring_validation_report.json');
  }
  
  // Exit with appropriate code for CI/CD
  exit(result.isValid ? 0 : 1);
}
