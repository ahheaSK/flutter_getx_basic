import 'package:either_dart/either.dart';

import '../../constant/api_constant.dart';
import '../../core/util/api_client.dart';
import '../../core/util/api_exception.dart';
import '../model/slider_model.dart';

/// The home-screen carousel.
///
/// `GET /api/sliders` is public on the backend, so this works before login —
/// the Bearer header is attached anyway and simply ignored.
class SliderService {
  SliderService(this._api);

  final ApiClient _api;

  /// Active banners in display order. Not paginated: a carousel is small.
  Future<Either<ApiException, List<SliderModel>>> getCarousel() async {
    try {
      final Map<String, dynamic> json = await _api.get(ApiConstant.sliders);
      final List<dynamic> rows =
          (json['data'] as List<dynamic>?) ?? <dynamic>[];
      return Right<ApiException, List<SliderModel>>(
        rows
            .whereType<Map<String, dynamic>>()
            .map(SliderModel.fromJson)
            .toList(growable: false),
      );
    } on ApiException catch (e) {
      return Left<ApiException, List<SliderModel>>(e);
    }
  }
}
