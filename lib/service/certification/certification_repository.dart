import 'package:nas_photo_viewer/data/secure_storage/secure_storage.dart';
import 'package:nas_photo_viewer/model/certification.dart';

const String _nasnameKey = 'nas_name';
const String _usernameKey = 'nas_username';
const String _passwordKey = 'nas_password';

class CertificationRepository {
  final SecureStorage _secureStorage;

  CertificationRepository(this._secureStorage);

  Future<Certification> getCertification() async {
    String nasName = (await _secureStorage.getData(key: _nasnameKey)) ?? '';
    String userName = (await _secureStorage.getData(key: _usernameKey)) ?? '';
    String password = (await _secureStorage.getData(key: _passwordKey)) ?? '';
    return Certification(
        nasName: nasName, userName: userName, password: password);
  }

  Future<bool> setCertification(Certification cert) async {
    await _secureStorage.setData(key: _nasnameKey, value: cert.nasName);
    await _secureStorage.setData(key: _usernameKey, value: cert.userName);
    await _secureStorage.setData(key: _passwordKey, value: cert.password);
    return true;
  }
}
