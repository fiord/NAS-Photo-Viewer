import 'package:nas_photo_viewer/model/certification.dart';
import 'package:nas_photo_viewer/service/certification/certification_repository.dart';

class SettingsPageBloc {
  final CertificationRepository _certificationRepository;

  SettingsPageBloc(this._certificationRepository);

  Future<bool> saveSettings(Certification cert) async {
    return await _certificationRepository.setCertification(cert);
  }

  Future<Certification> loadSettings() async {
    return await _certificationRepository.getCertification();
  }
}
