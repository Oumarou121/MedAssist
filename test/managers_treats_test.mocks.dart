// Mocks generated by Mockito 5.4.6 from annotations
// in med_assist/test/managers_treats_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;

import 'package:med_assist/Models/treat.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;

import 'ITreatmentService.dart' as _i3;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: must_be_immutable
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeTreat_0 extends _i1.SmartFake implements _i2.Treat {
  _FakeTreat_0(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

/// A class which mocks [ITreatmentService].
///
/// See the documentation for Mockito's code generation for more information.
class MockITreatmentService extends _i1.Mock implements _i3.ITreatmentService {
  MockITreatmentService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Stream<List<_i2.Treat>> get treatments =>
      (super.noSuchMethod(
            Invocation.getter(#treatments),
            returnValue: _i4.Stream<List<_i2.Treat>>.empty(),
          )
          as _i4.Stream<List<_i2.Treat>>);

  @override
  _i4.Future<void> addTreatment(_i2.Treat? treatment) =>
      (super.noSuchMethod(
            Invocation.method(#addTreatment, [treatment]),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  _i4.Future<void> saveTreatment(_i2.Treat? treatment) =>
      (super.noSuchMethod(
            Invocation.method(#saveTreatment, [treatment]),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  _i4.Future<void> updateTreatment(_i2.Treat? treatment) =>
      (super.noSuchMethod(
            Invocation.method(#updateTreatment, [treatment]),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  _i4.Future<void> deleteTreatment(String? code) =>
      (super.noSuchMethod(
            Invocation.method(#deleteTreatment, [code]),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  _i4.Future<_i2.Treat> getTreatmentByCode(String? code) =>
      (super.noSuchMethod(
            Invocation.method(#getTreatmentByCode, [code]),
            returnValue: _i4.Future<_i2.Treat>.value(
              _FakeTreat_0(
                this,
                Invocation.method(#getTreatmentByCode, [code]),
              ),
            ),
          )
          as _i4.Future<_i2.Treat>);

  @override
  _i4.Future<List<_i2.Treat>> getPublicTreatments() =>
      (super.noSuchMethod(
            Invocation.method(#getPublicTreatments, []),
            returnValue: _i4.Future<List<_i2.Treat>>.value(<_i2.Treat>[]),
          )
          as _i4.Future<List<_i2.Treat>>);

  @override
  _i4.Future<void> addFollowerToTreatment(String? code, String? followerUid) =>
      (super.noSuchMethod(
            Invocation.method(#addFollowerToTreatment, [code, followerUid]),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  _i4.Future<void> removeFollowerFromTreatment(
    String? code,
    String? followerUid,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#removeFollowerFromTreatment, [
              code,
              followerUid,
            ]),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);
}
