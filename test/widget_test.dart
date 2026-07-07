import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tpb_business_flutter/core/components/camposelect_component.dart';

void main() {
  testWidgets('CampoSelectComponent updates the selected value when an item is chosen', (WidgetTester tester) async {
    String? selectedValue;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CampoSelectComponent<String>(
            label: 'Moeda',
            value: 'R\$',
            items: [
              CampoSelectItem<String>(label: 'Real: R\$', value: 'R\$'),
              CampoSelectItem<String>(label: 'Dólar: \$', value: '\$'),
            ],
            onChange: (value) {
              selectedValue = value;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dólar: \$').last);
    await tester.pumpAndSettle();

    final dropdown = tester.widget<DropdownButton<String>>(find.byType(DropdownButton<String>));

    expect(dropdown.value, '\$');
    expect(selectedValue, '\$');
  });
}
