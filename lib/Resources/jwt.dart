import 'dart:convert';

final Codec<Object?, String> _jwtCodec = json.fuse(utf8).fuse(base64);

/// A RegExp that can match, and extract parts from a JWT Token.
///
/// A JWT token consists of 3 base-64 encoded parts of data separated by periods:
///
///   header.payload.signature
///
/// More info: https://regexr.com/789qc
final RegExp _jwtTokenRegexp = RegExp(
    r'^(?<header>[^\.\s]+)\.(?<payload>[^\.\s]+)\.(?<signature>[^\.\s]+)$');

/// Decodes the `claims` of a JWT token and returns them as a Map.
///
/// JWT `claims` are stored as a JSON object in the `payload` part of the token.
///
String idToken = '';

/// (This method does not validate the signature of the token.)
///
/// See https://www.rfc-editor.org/rfc/rfc7519#section-3
Map<String, Object?>? decodePayload(String? token) {
  if (token != null) {
    idToken = token;
    print("el token es....:${token}");
    final RegExpMatch? match = _jwtTokenRegexp.firstMatch(token);
    if (match != null) {
      print("estoy aqui solito con este TOKEN: ${idToken}");
      

      return _decodeJwtPayload(match.namedGroup('payload'));
    }
  }
  print("Estoy en jwt retornando idToken:${idToken}");

  return null;
}

/// Decodes a JWT payload using the [_jwtCodec].
Map<String, Object?>? _decodeJwtPayload(String? payload) {
  try {
    // Payload must be normalized before passing it to the codec
    return _jwtCodec.decode(base64.normalize(payload!))
        as Map<String, Object?>?;
  } catch (_) {
    // Do nothing, we always return null for any failure.
  }
  return null;
}
