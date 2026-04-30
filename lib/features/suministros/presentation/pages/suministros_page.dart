import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ciemsi_app/features/suministros/presentation/bloc/suministro_bloc.dart';
import 'package:ciemsi_app/features/suministros/presentation/bloc/suministro_event.dart';
import 'package:ciemsi_app/features/suministros/presentation/bloc/suministro_state.dart';
import 'package:ciemsi_app/features/suministros/domain/entities/suministro.dart';
import 'crear_suministro_page.dart';

class SuministrosPage extends StatefulWidget {
  const SuministrosPage({super.key});

  @override
  State<SuministrosPage> createState() => _SuministrosPageState();
}

class _SuministrosPageState extends State<SuministrosPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<SuministroBloc>().add(ListarSuministrosEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Color _colorTipo(TipoSuministro tipo) {
    switch (tipo) {
      case TipoSuministro.MEDICAMENTO:
        return const Color(0xFF00B5C8);
      case TipoSuministro.INSUMO:
        return const Color(0xFF8DC63F);
      case TipoSuministro.MATERIAL:
        return Colors.purple;
    }
  }

  IconData _iconoTipo(TipoSuministro tipo) {
    switch (tipo) {
      case TipoSuministro.MEDICAMENTO:
        return Icons.medication_outlined;
      case TipoSuministro.INSUMO:
        return Icons.science_outlined;
      case TipoSuministro.MATERIAL:
        return Icons.medical_services_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text(
          'Suministros',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF00B5C8),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<SuministroBloc>().add(ListarSuministrosEvent()),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF8DC63F),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Todos'),
            Tab(text: 'Medicamentos'),
            Tab(text: 'Insumos/Mat.'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF8DC63F),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<SuministroBloc>(),
                child: const CrearSuministroPage(),
              ),
            ),
          );
          context.read<SuministroBloc>().add(ListarSuministrosEvent());
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nuevo', style: TextStyle(color: Colors.white)),
      ),
      body: BlocBuilder<SuministroBloc, SuministroState>(
        builder: (context, state) {
          if (state is SuministroLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00B5C8)),
            );
          }
          if (state is SuministroError) {
            return Center(child: Text(state.mensaje));
          }
          if (state is SuministroCreado || state is SuministroInitial) {
            context.read<SuministroBloc>().add(ListarSuministrosEvent());
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00B5C8)),
            );
          }
          if (state is SuministrosListados) {
            final todos = state.suministros
                .where(
                  (s) => s.nombreSuministro.toLowerCase().contains(
                    _busqueda.toLowerCase(),
                  ),
                )
                .toList();
            final medicamentos = todos
                .where((s) => s.tipo == TipoSuministro.MEDICAMENTO)
                .toList();
            final insumosYMateriales = todos
                .where((s) => s.tipo != TipoSuministro.MEDICAMENTO)
                .toList();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar suministro...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF00B5C8),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (v) => setState(() => _busqueda = v),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildLista(todos),
                      _buildLista(medicamentos),
                      _buildLista(insumosYMateriales),
                    ],
                  ),
                ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildLista(List<Suministro> suministros) {
    if (suministros.isEmpty) {
      return const Center(
        child: Text('No hay suministros', style: TextStyle(color: Colors.grey)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      itemCount: suministros.length,
      itemBuilder: (context, index) {
        final s = suministros[index];
        final color = _colorTipo(s.tipo);
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              child: Icon(_iconoTipo(s.tipo), color: color),
            ),
            title: Text(
              s.nombreSuministro,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${s.unidadMedida.name} • ${s.marca ?? 'Sin marca'} • Umbral: ${s.umbral}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                s.tipo.name,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
