import 'package:flutter/material.dart';
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
  const accents = 'áàãâéêíóôõúüç';
  const plain = 'aaaaeeiooouuc';
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
    this.forceNotFound = false,
  });
  final ValueChanged<String> onSelect;
  final VoidCallback onLocation;
  final String initialQuery;
  final bool forceNotFound;
  @override
  State<SearchCityPage> createState() => _SearchCityPageState();
}

class _SearchCityPageState extends State<SearchCityPage> {
  late final TextEditingController controller;
  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = normalizeCity(controller.text);
    final results = demoCities
        .where((city) => normalizeCity(city).contains(query))
        .toList();
    final missing = query.isNotEmpty && results.isEmpty;
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
          onChanged: (_) => setState(() {}),
          textInputAction: TextInputAction.search,
          onSubmitted: (_) {
            if (results.length == 1) {
              widget.onSelect(results.first);
            }
          },
          decoration: InputDecoration(
            hintText: 'Buscar cidade',
            filled: true,
            fillColor: panel,
            prefixIcon: const Icon(Icons.search, size: 22),
            suffixIcon: IconButton(
              tooltip: 'Limpar busca',
              onPressed: () => setState(controller.clear),
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
        if (missing)
          CityNotFoundPage(
            onClear: () => setState(controller.clear),
            onLocation: widget.onLocation,
          )
        else ...[
          Align(
            alignment: Alignment.centerLeft,
            child: LocationButton(onPressed: widget.onLocation, outlined: true),
          ),
          const SizedBox(height: 28),
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
                    city,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Caption('Brasil'),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () => widget.onSelect(city),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Caption('Escolha a cidade para consultar o tempo.'),
          const SizedBox(height: 12),
          const Caption(
            'Busca de demonstração · cidades disponíveis nesta prévia',
          ),
        ],
      ],
    );
  }
}
