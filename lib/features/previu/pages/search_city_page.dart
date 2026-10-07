import 'dart:async';
import 'package:flutter/material.dart';
import '../../weather/data/weather_service.dart';
import '../../weather/domain/weather_city.dart';
import '../ui.dart';
import 'city_not_found_page.dart';

const demoCities = [
  'Curitiba, PR',
  'São Paulo, SP',
  'Rio de Janeiro, RJ',
  'Florianópolis, SC',
  'Joinville, SC',
  'Blumenau, SC',
  'Brasília, DF',
  'Porto Alegre, RS',
];
String normalizeCity(String text) {
  var result = text.toLowerCase().trim();
  const accents = 'áàãâéêíóôõúüç', plain = 'aaaaeeiooouuc';
  for (var i = 0; i < accents.length; i++) {
    result = result.replaceAll(accents[i], plain[i]);
  }
  return result;
}

class SearchCityPage extends StatefulWidget {
  const SearchCityPage({
    super.key,
    required this.onSelect,
    required this.onLocation,
    this.initialQuery = '',
    this.service,
  });
  final ValueChanged<WeatherCity> onSelect;
  final VoidCallback onLocation;
  final String initialQuery;
  final WeatherService? service;
  @override
  State<SearchCityPage> createState() => _SearchCityPageState();
}

class _SearchCityPageState extends State<SearchCityPage> {
  late final TextEditingController controller;
  Timer? debounce;
  List<WeatherCity> results = [];
  bool loading = false, searched = false;
  String? error;
  int revision = 0;
  bool get demo => widget.service == null;
  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialQuery);
    if (demo) {
      filterDemo();
    }
  }

  void filterDemo() {
    final query = normalizeCity(controller.text);
    results = demoCities
        .where((c) => normalizeCity(c).contains(query))
        .map(
          (c) => WeatherCity(
            name: c.split(', ').first,
            state: c.split(', ').last,
            latitude: -25.43,
            longitude: -49.27,
          ),
        )
        .toList();
    searched = query.isNotEmpty;
  }

  void changed(String text) {
    debounce?.cancel();
    revision++;
    if (demo) {
      setState(filterDemo);
      return;
    }
    setState(() {
      results = [];
      error = null;
      searched = false;
      loading = text.trim().length >= 2;
    });
    if (text.trim().length >= 2) {
      debounce = Timer(const Duration(milliseconds: 450), search);
    }
  }

  Future<void> search() async {
    debounce?.cancel();
    final query = controller.text.trim();
    if (query.length < 2 || demo) return;
    final id = ++revision;
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final found = await widget.service!.searchCities(query);
      if (mounted && id == revision) {
        setState(() {
          results = found;
          searched = true;
          loading = false;
        });
      }
    } on WeatherException catch (e) {
      if (mounted && id == revision) {
        setState(() {
          error = e.message;
          loading = false;
        });
      }
    } catch (_) {
      if (mounted && id == revision) {
        setState(() {
          error = 'Não foi possível buscar cidades. Tente novamente.';
          loading = false;
        });
      }
    }
  }

  void clear() {
    controller.clear();
    changed('');
  }

  @override
  void dispose() {
    revision++;
    debounce?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final missing = searched && !loading && error == null && results.isEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Qual cidade?',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: controller,
          onChanged: changed,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) {
            if (demo && results.length == 1) {
              widget.onSelect(results.first);
            } else {
              search();
            }
          },
          decoration: InputDecoration(
            hintText: 'Cidade ou cidade, UF',
            filled: true,
            fillColor: panel,
            prefixIcon: const Icon(Icons.search, size: 22),
            suffixIcon: IconButton(
              tooltip: 'Limpar busca',
              onPressed: clear,
              icon: const Icon(Icons.close, size: 20),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: line),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: line),
            ),
          ),
        ),
        const SizedBox(height: 14),
        if (!demo) ...[
          const Caption('Digite o nome completo, por exemplo: Concordia ou Joinville, SC.'),
          Align(alignment: Alignment.centerLeft, child: TextButton.icon(
            onPressed: search, icon: const Icon(Icons.search),
            label: const Text('Buscar cidade'))),
        ],
        if (missing)
          CityNotFoundPage(onClear: clear, onLocation: widget.onLocation)
        else ...[
          Align(
            alignment: Alignment.centerLeft,
            child: LocationButton(onPressed: widget.onLocation, outlined: true),
          ),
          const SizedBox(height: 28),
          if (loading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else if (error != null) ...[
            Caption(error!),
            TextButton(
              onPressed: search,
              child: const Text('Tentar novamente'),
            ),
          ] else if (results.isEmpty)
            const Caption(
              'Digite pelo menos duas letras para buscar uma cidade.',
            )
          else ...[
            const Caption('RESULTADOS'),
            const SizedBox(height: 12),
            ...results.map(
              (city) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: line),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.location_on_outlined),
                    title: Text(
                      city.label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Caption(city.country),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () => widget.onSelect(city),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Caption('Escolha a cidade para consultar o tempo.'),
          ],
          if (demo) const Caption('Busca de demonstração'),
        ],
      ],
    );
  }
}
