// Copyright 2020 Joan Pablo Jimenez Milian. All rights reserved.
// Use of this source code is governed by the MIT license that can be
// found in the LICENSE file.

import 'package:reactive_forms/reactive_forms.dart';

/// Represents a [FormGroup] validator that compares two controls in the group.
class CompareValidator<T> extends Validator<Map<String, Object?>> {
  final String controlName;
  final String compareControlName;
  final CompareOption compareOption;

  /// Constructs an instance of the validator.
  ///
  /// The arguments [controlName], [compareControlName] and [compareOption]
  /// must not be null.
  CompareValidator(
    this.controlName,
    this.compareControlName,
    this.compareOption,
  );

  @override
  Map<String, Object>? validate(AbstractControl<Map<String, Object?>> form) {
    if (form is! FormGroup) {
      // Maybe throw an exception is better
      return {ValidationMessage.compare: true};
    }

    final mainControl = form.control(this.controlName);
    final compareControl = form.control(this.compareControlName);
    final error = {
      ValidationMessage.compare: {
        'control': mainControl.value,
        'compareControl': compareControl.value,
        'option': this.compareOption,
      }
    };

    if (mainControl.value is! Comparable<T> ||
        compareControl.value is! T) {
      return error;
    }

    if (_meetsComparison(
        mainControl.value as Comparable<T>, compareControl.value as T)) {
      mainControl.removeError(ValidationMessage.compare);
    } else {
      mainControl.setErrors(error);
      mainControl.markAsTouched();
    }

    return null;
  }

  bool _meetsComparison(Comparable<T> value, T compareValue) {
    switch (this.compareOption) {
      case CompareOption.lower:
        return value.compareTo(compareValue) < 0;
      case CompareOption.lower_or_equal:
        return value.compareTo(compareValue) <= 0;
      case CompareOption.greater:
        return value.compareTo(compareValue) > 0;
      case CompareOption.greater_or_equal:
        return value.compareTo(compareValue) >= 0;
      default: //CompareOption.equal:
        return value.compareTo(compareValue) == 0;
    }
  }
}
