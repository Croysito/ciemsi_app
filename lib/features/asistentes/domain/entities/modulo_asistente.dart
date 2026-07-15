class ModuloAsistente {
  final String clave;
  final String etiqueta;

  const ModuloAsistente(this.clave, this.etiqueta);

  static const List<ModuloAsistente> todos = [
    ModuloAsistente('servicios', 'Servicios'),
    ModuloAsistente('suministros', 'Suministros'),
    ModuloAsistente('tratamientos', 'Tratamientos'),
    ModuloAsistente('productos', 'Productos'),
    ModuloAsistente('compras', 'Compras'),
    ModuloAsistente('qr_pago', 'QR de pago'),
    ModuloAsistente('cuentas', 'Cuentas'),
  ];
}
