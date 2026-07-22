import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tpb_business_flutter/core/services/preferences.dart';
import 'package:tpb_business_flutter/core/services/repository.dart';
import 'package:tpb_business_flutter/features/fluxo_caixa/fluxo_caixa_model.dart';
import 'package:tpb_business_flutter/features/fluxo_caixa/lista/fluxo_caixa_lista_controller.dart';

class MockRepository extends Mock implements Repository {}

void main() {
  late MockRepository mockRepository;
  late FluxoCaixaListaController controller;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'email': 'tatianapacheco09@gmail.com',
      'token': 'mock_token',
      'user': 'Tatiana',
      'name': 'Tatiana',
      'moeda': 'R\$',
      'refreshToken': 'mock_refresh',
      'deviceId': 'mock_device_id',
    });
    await Preferences.instance.init();
    mockRepository = MockRepository();
    controller = FluxoCaixaListaController(mockRepository);
  });

  tearDown(() {
    controller.close();
  });

  final fluxoCaixaResponse = {
    'saldo': 300.0,
    'total_entradas': 500.0,
    'total_saidas': 200.0,
    'fluxo_caixa_list': [
      {
        'uid': 'fc-1',
        'descricao': 'Pagamento Serviço',
        'valor': 150.0,
        'tipo_movimentacao': 'entrada',
        'forma_pagamento': 'dinheiro',
        'pago': true,
        'created_at': '2026-07-20T10:00:00.000Z',
      },
      {
        'uid': 'fc-2',
        'descricao': 'Material',
        'valor': 50.0,
        'tipo_movimentacao': 'saida',
        'forma_pagamento': 'cartao',
        'pago': true,
        'created_at': '2026-07-19T15:00:00.000Z',
      },
    ],
  };

  group('FluxoCaixaListaController - getFluxoCaixa', () {
    blocTest<FluxoCaixaListaController, dynamic>(
      'deve emitir FluxoCaixaModel populado com grupos ao retornar 200 sem filtros',
      build: () {
        when(() => mockRepository.get(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: fluxoCaixaResponse,
            statusCode: 200,
          ),
        );
        return controller;
      },
      act: (c) => c.getFluxoCaixa(),
      verify: (c) {
        expect(c.state.isLoading, false);
        expect(c.state.hasError, null);
        expect(c.state.data!.saldo, 300.0);
        expect(c.state.data!.totalEntradas, 500.0);
        expect(c.state.data!.totalSaidas, 200.0);
        expect(c.state.data!.fluxoCaixaList!.length, 2);
        // Deve ter criado grupos por data
        expect(c.state.data!.grupos, isNotNull);
        expect(c.state.data!.grupos!.length, 2); // duas datas distintas
      },
    );

    blocTest<FluxoCaixaListaController, dynamic>(
      'deve montar URL com parâmetros de filtro quando fornecidos',
      build: () {
        when(() => mockRepository.get(any())).thenAnswer((invocation) async {
          final url = invocation.positionalArguments[0] as String;
          expect(url, contains('forma_pagamento=dinheiro'));
          expect(url, contains('tipo_movimentacao=entrada'));
          expect(url, contains('data_registro_inicio=2026-07-01'));
          expect(url, contains('data_registro_fim=2026-07-31'));
          return Response(
            requestOptions: RequestOptions(path: url),
            data: fluxoCaixaResponse,
            statusCode: 200,
          );
        });
        return controller;
      },
      act: (c) => c.getFluxoCaixa(
        formaPagamento: 'dinheiro',
        tipoMovimentacao: 'entrada',
        dataRegistroInicio: '2026-07-01',
        dataRegistroFim: '2026-07-31',
      ),
      verify: (c) {
        expect(c.state.data!.formaPagamento, 'dinheiro');
        expect(c.state.data!.tipoMovimentacao, 'entrada');
        expect(c.state.data!.dataInicio, '2026-07-01');
        expect(c.state.data!.dataFim, '2026-07-31');
      },
    );

    blocTest<FluxoCaixaListaController, dynamic>(
      'não deve adicionar forma_pagamento na URL quando valor é "todas"',
      build: () {
        when(() => mockRepository.get(any())).thenAnswer((invocation) async {
          final url = invocation.positionalArguments[0] as String;
          expect(url, isNot(contains('forma_pagamento')));
          return Response(
            requestOptions: RequestOptions(path: url),
            data: fluxoCaixaResponse,
            statusCode: 200,
          );
        });
        return controller;
      },
      act: (c) => c.getFluxoCaixa(formaPagamento: 'todas'),
      verify: (c) {
        expect(c.state.isLoading, false);
      },
    );

    blocTest<FluxoCaixaListaController, dynamic>(
      'deve emitir erro interno ao retornar 500',
      build: () {
        when(() => mockRepository.get(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 500,
          ),
        );
        return controller;
      },
      act: (c) => c.getFluxoCaixa(),
      expect: () => [
        isA<dynamic>().having((s) => s.isLoading, 'isLoading', true),
        isA<dynamic>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having(
              (s) => s.hasError,
              'hasError',
              'Erro interno ao obter fluxo de caixa',
            ),
      ],
    );

    blocTest<FluxoCaixaListaController, dynamic>(
      'deve emitir erro genérico para status fora do padrão',
      build: () {
        when(() => mockRepository.get(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 400,
          ),
        );
        return controller;
      },
      act: (c) => c.getFluxoCaixa(),
      expect: () => [
        isA<dynamic>().having((s) => s.isLoading, 'isLoading', true),
        isA<dynamic>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having(
              (s) => s.hasError,
              'hasError',
              'Erro ao obter fluxo de caixa',
            ),
      ],
    );

    blocTest<FluxoCaixaListaController, dynamic>(
      'deve emitir erro ao lançar DioException',
      build: () {
        when(() => mockRepository.get(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            message: 'Timeout',
          ),
        );
        return controller;
      },
      act: (c) => c.getFluxoCaixa(),
      verify: (c) {
        expect(c.state.isLoading, false);
        expect(c.state.hasError, isNotNull);
        expect(
          c.state.hasError.toString(),
          contains('Ocorreu um erro ao obter fluxo de caixa'),
        );
      },
    );
  });

  group('FluxoCaixaListaController - getGrupos', () {
    test(
      'deve agrupar itens por data e ordenar do mais recente ao mais antigo',
      () {
        final itens = [
          FluxoCaixaItemModel(
            uid: 'fc-1',
            descricao: 'A',
            createdAt: '2026-07-18T10:00:00.000Z',
          ),
          FluxoCaixaItemModel(
            uid: 'fc-2',
            descricao: 'B',
            createdAt: '2026-07-20T15:00:00.000Z',
          ),
          FluxoCaixaItemModel(
            uid: 'fc-3',
            descricao: 'C',
            createdAt: '2026-07-20T09:00:00.000Z',
          ),
        ];

        final grupos = controller.getGrupos(itens);

        expect(grupos.length, 2); // duas datas distintas: 20 e 18
        // O mais recente deve vir primeiro
        expect(grupos[0].data.day, 20);
        expect(grupos[1].data.day, 18);
        // O dia 20 deve ter 2 itens
        expect(grupos[0].fluxoCaixaList.length, 2);
      },
    );

    test('deve retornar lista vazia quando fluxoCaixaList for nula', () {
      final grupos = controller.getGrupos(null);
      expect(grupos, isEmpty);
    });

    test('deve retornar lista vazia quando fluxoCaixaList estiver vazia', () {
      final grupos = controller.getGrupos([]);
      expect(grupos, isEmpty);
    });
  });
}
