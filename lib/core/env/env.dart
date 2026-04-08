import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'TDX_CLIENT_ID', obfuscate: true)
  static final String tdxClientId = _Env.tdxClientId;

  @EnviedField(varName: 'TDX_CLIENT_SECRET', obfuscate: true)
  static final String tdxClientSecret = _Env.tdxClientSecret;
}
