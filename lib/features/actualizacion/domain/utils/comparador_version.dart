/// Compara dos versiones tipo "1.2.10" (sin sufijo de build) y devuelve
/// true si [remota] es más nueva que [local]. Lógica pura, sin dependencias
/// de Flutter ni de infraestructura, para que sea testeable de forma aislada.
bool esVersionMasNueva({required String remota, required String local}) {
  final partesRemota = _partes(remota);
  final partesLocal = _partes(local);
  final longitud = partesRemota.length > partesLocal.length
      ? partesRemota.length
      : partesLocal.length;

  for (var i = 0; i < longitud; i++) {
    final r = i < partesRemota.length ? partesRemota[i] : 0;
    final l = i < partesLocal.length ? partesLocal[i] : 0;
    if (r != l) return r > l;
  }
  return false;
}

List<int> _partes(String version) {
  final limpia = version.trim().toLowerCase().replaceFirst(
    RegExp(r'^v'),
    '',
  );
  return limpia
      .split('.')
      .map((p) => int.tryParse(p.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0)
      .toList();
}
