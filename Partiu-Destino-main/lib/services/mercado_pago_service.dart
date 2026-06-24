import 'package:dio/dio.dart';

class MercadoPagoService {
  static const String _accessToken =
      'APP_USR-7972295214379226-060621-75aee6631e3cb15a8f56400ad5299a4d-3456267258';

  static const String _publicKey =
      'APP_USR-33dca5d5-2dcb-436b-916b-24209e25fbf3';

  static String get publicKey => _publicKey;

  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://api.mercadopago.com',
    headers: {
      'Authorization': 'Bearer $_accessToken',
      'Content-Type': 'application/json',
    },
  ));

  Future<Map<String, dynamic>> createPaymentPreference({
    required String title,
    required double unitPrice,
    required String payerEmail,
  }) async {
    try {
      final response = await _dio.post('/checkout/preferences', data: {
        'items': [
          {
            'title': title,
            'unit_price': unitPrice,
            'quantity': 1,
            'currency_id': 'BRL'
          }
        ],
        'payer': {'email': payerEmail},
        'back_urls': {'success': 'partiudestino://payment/success'},
        'auto_return': 'approved',
      });
      return {
        'success': true,
        'init_point': response.data['init_point'],
        'sandbox_init_point': response.data['sandbox_init_point']
      };
    } catch (e) {
      return {'success': false, 'message': 'Erro ao criar preferência.'};
    }
  }

  Future<Map<String, dynamic>> generatePix({
    required double transactionAmount,
    required String payerEmail,
    required String payerCpf,
    required String payerFirstName,
    required String payerLastName,
  }) async {
    try {
      final response = await _dio.post('/v1/payments',
          data: {
            'transaction_amount': transactionAmount,
            'description': 'Reserva Partiu Destino',
            'payment_method_id': 'pix',
            'payer': {
              'email': payerEmail,
              'first_name': payerFirstName,
              'last_name': payerLastName,
              'identification': {'type': 'CPF', 'number': payerCpf},
            },
          },
          options: Options(headers: {
            'X-Idempotency-Key': '${DateTime.now().millisecondsSinceEpoch}'
          }));
      final txInfo = response.data['point_of_interaction']?['transaction_data'];
      return {
        'success': true,
        'qr_code': txInfo?['qr_code'],
        'qr_code_base64': txInfo?['qr_code_base64']
      };
    } catch (e) {
      return {'success': false, 'message': 'Erro ao gerar PIX.'};
    }
  }

  Future<Map<String, dynamic>> generateBoleto({
    required double transactionAmount,
    required String payerEmail,
    required String payerCpf,
    required String payerFirstName,
    required String payerLastName,
  }) async {
    try {
      final response = await _dio.post('/v1/payments', data: {
        'transaction_amount': transactionAmount,
        'description': 'Reserva Partiu Destino',
        'payment_method_id': 'bolbradesco',
        'payer': {
          'email': payerEmail,
          'first_name': payerFirstName,
          'last_name': payerLastName,
          'identification': {'type': 'CPF', 'number': payerCpf},
        },
      });
      return {
        'success': true,
        'barcode': response.data['barcode']?['content'],
        'url': response.data['transaction_details']?['external_resource_url']
      };
    } catch (e) {
      return {'success': false, 'message': 'Erro ao gerar boleto.'};
    }
  }
}
