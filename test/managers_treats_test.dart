import 'package:flutter_test/flutter_test.dart';
import 'package:med_assist/Models/treat.dart'
    show FrequencyType, Medicine, Treat;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'ITreatmentService.dart';
import 'managers_treats_test.mocks.dart';
//flutter test --reporter=expanded

@GenerateMocks([ITreatmentService])
void main() {
  group('ManagersTreats Tests', () {
    late MockITreatmentService mockService;
    late ManagersTreats managersTreats;
    final testUid = 'test_uid';
    final testName = 'Test User';

    final sampleTreatments = [
      Treat(
        code: 'T001',
        title: 'Active Treatment 1',
        authorName: 'Dr Smith',
        authorUid: 'doc_001',
        isPublic: true,
        followers: [],
        medicines: [
          Medicine(
            name: 'Medicine A',
            dose: '100mg',
            frequencyType: FrequencyType.daily,
            frequency: 2,
            duration: 7,
            intervale: 12,
            createAt: DateTime.now().subtract(Duration(days: 1)),
          ),
        ],
        createdAt: DateTime.now().subtract(Duration(days: 1)),
        isMissing: false,
      ),
      Treat(
        code: 'T002',
        title: 'Active Treatment 2',
        authorName: 'Dr Jones',
        authorUid: 'doc_002',
        isPublic: false,
        followers: [],
        medicines: [
          Medicine(
            name: 'Medicine B',
            dose: '200mg',
            frequencyType: FrequencyType.daily,
            frequency: 1,
            duration: 14,
            intervale: 24,
            createAt: DateTime.now(),
          ),
        ],
        createdAt: DateTime.now(),
        isMissing: false,
      ),
      Treat(
        code: 'T003',
        title: 'Finished Treatment',
        authorName: 'Dr Brown',
        authorUid: 'doc_003',
        isPublic: true,
        followers: [],
        medicines: [
          Medicine(
            name: 'Medicine C',
            dose: '300mg',
            frequencyType: FrequencyType.daily,
            frequency: 3,
            duration: 5,
            intervale: 8,
            createAt: DateTime.now().subtract(Duration(days: 10)),
          ),
        ],
        createdAt: DateTime.now().subtract(Duration(days: 10)),
        isMissing: false,
      ),
      Treat(
        code: 'T004',
        title: 'Failed Treatment',
        authorName: 'Dr White',
        authorUid: 'doc_004',
        isPublic: false,
        followers: [],
        medicines: [
          Medicine(
            name: 'Medicine D',
            dose: '400mg',
            frequencyType: FrequencyType.daily,
            frequency: 1,
            duration: 3,
            intervale: 24,
            createAt: DateTime.now().subtract(Duration(days: 2)),
          ),
        ],
        createdAt: DateTime.now().subtract(Duration(days: 2)),
        isMissing: true,
      ),
    ];

    setUp(() {
      mockService = MockITreatmentService();
      managersTreats = ManagersTreats(
        uid: testUid,
        name: testName,
        treats: List.from(sampleTreatments),
        service: mockService,
      );
    });

    test('activeTreatments should return only active treatments', () {
      final active = managersTreats.activeTreatments();

      expect(active.length, 2);
      expect(active.any((t) => t.code == 'T003'), false);
      expect(active.any((t) => t.code == 'T004'), false);

      expect(active[0].createdAt.isAfter(active[1].createdAt), true);
    });

    test('failedTreatments should return only failed treatments', () {
      final failed = managersTreats.failedTreatments();

      expect(failed.length, 1);
      expect(failed[0].code, 'T004');
    });

    test('finishedTreatments should return only finished treatments', () {
      final finished = managersTreats.finishedTreatments();

      expect(finished.length, 1);
      expect(finished[0].code, 'T003');
    });

    test('addTreatment should add treatment and call service', () async {
      final newTreat = Treat(
        code: 'T005',
        title: 'New Treatment',
        authorName: 'Dr New',
        authorUid: 'doc_new',
        isPublic: true,
        followers: [],
        medicines: [],
        createdAt: DateTime.now(),
      );


      when(mockService.addTreatment(any)).thenAnswer((_) async => {});

      await managersTreats.addTreatment(newTreat);

      verify(mockService.addTreatment(newTreat)).called(1);
    });

    test('removeTreatment should remove treatment and call service', () async {
      final toRemove = managersTreats.treats.first;

      when(
        mockService.deleteTreatment(toRemove.code),
      ).thenAnswer((_) async => {});

      await managersTreats.removeTreatment(toRemove);

      expect(managersTreats.treats.length, 3);
      expect(managersTreats.treats.any((t) => t.code == toRemove.code), false);

      verify(mockService.deleteTreatment(toRemove.code)).called(1);
    });

    test('alreadyExists should detect existing and non-existing codes', () {
      expect(managersTreats.alreadyExists('T001'), true);
      expect(managersTreats.alreadyExists('T999'), false);
    });
  });
}
