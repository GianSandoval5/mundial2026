import 'package:flutter_test/flutter_test.dart';
import 'package:mundialito_app/features/mundial/domain/mundial_models.dart';

void main() {
  test('TeamRef builds a compact fallback code', () {
    const team = TeamRef(id: 1, name: 'Costa Rica');

    expect(team.shortName, 'CR');
  });
}
