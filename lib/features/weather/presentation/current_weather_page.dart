import 'package:flutter/material.dart';

import '../data/weather_repository.dart';
import '../data/weather_service.dart';
import '../domain/current_weather.dart';
import 'widgets/weather_icon.dart';

const _ink = Color(0xFF27292C);
const _muted = Color(0xFF757A82);
const _surface = Color(0xFFF4F4F5);
const _line = Color(0xFFE3E5E8);

class CurrentWeatherPage extends StatefulWidget {
  const CurrentWeatherPage({super.key, required this.repository});
  final WeatherRepository repository;

  @override
  State<CurrentWeatherPage> createState() => _CurrentWeatherPageState();
}

class _CurrentWeatherPageState extends State<CurrentWeatherPage> {
  CurrentWeather? _weather;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool refresh = false}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final weather = await widget.repository.current(refresh: refresh);
      if (mounted) setState(() => _weather = weather);
    } on WeatherException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    widget.repository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= 600;
        return Center(
          child: Padding(
            padding: EdgeInsets.all(desktop ? 24 : 0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 430, maxHeight: 844),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(desktop ? 28 : 0),
                border: desktop ? Border.all(color: _line) : null,
              ),
              clipBehavior: Clip.antiAlias,
              child: Material(
                color: Colors.white,
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      const _Header(),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            if (!_loading) await _load(refresh: true);
                          },
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (widget.repository.demo)
                                  const Padding(
                                    padding: EdgeInsets.only(bottom: 16),
                                    child: Text(
                                      'PRÉVIA · DADOS ILUSTRATIVOS',
                                      style: TextStyle(
                                        fontSize: 9,
                                        letterSpacing: .9,
                                        color: _muted,
                                      ),
                                    ),
                                  ),
                                if (_error != null)
                                  _ErrorContent(
                                    message: _error!,
                                    weather: _weather,
                                    onRetry: () => _load(refresh: true),
                                  )
                                else if (_weather != null)
                                  _WeatherContent(
                                    weather: _weather!,
                                    demo: widget.repository.demo,
                                    loading: _loading,
                                    onRefresh: () => _load(refresh: true),
                                  )
                                else
                                  const _LoadingContent(),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const _BottomNavigation(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 14, 12, 4),
    child: Row(
      children: [
        const WeatherIcon(size: 23),
        const SizedBox(width: 10),
        const Text(
          'Previu',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -.5,
          ),
        ),
        const Spacer(),
        const Tooltip(
          message: 'Busca de cidades disponível em breve',
          child: IconButton(
            onPressed: null,
            disabledColor: _muted,
            icon: Icon(Icons.search_rounded, size: 23),
          ),
        ),
      ],
    ),
  );
}

class _WeatherContent extends StatelessWidget {
  const _WeatherContent({
    required this.weather,
    required this.demo,
    required this.loading,
    required this.onRefresh,
  });
  final CurrentWeather weather;
  final bool demo;
  final bool loading;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final local = weather.updatedAtUtc.add(
      Duration(seconds: weather.utcOffsetSeconds),
    );
    final description = weather.description;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Row(
          children: [
            Icon(Icons.location_on_outlined, size: 20),
            SizedBox(width: 4),
            Flexible(
              child: Text(
                'Curitiba, PR',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(_date(local), style: const TextStyle(fontSize: 12, color: _muted)),
        const SizedBox(height: 20),
        _Panel(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 19, 12, 9),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Eyebrow('Agora'),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${weather.temperature.round()}°',
                        style: const TextStyle(
                          fontSize: 60,
                          height: 1.1,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -2.5,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 28),
                      child: WeatherIcon(
                        conditionId: weather.conditionId,
                        isNight: weather.isNight,
                        size: 33,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  description.isEmpty
                      ? 'Não informado'
                      : '${description[0].toUpperCase()}${description.substring(1)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Sensação ${weather.feelsLike.round()}°',
                  style: const TextStyle(fontSize: 12, color: _muted),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Atualizado às ${weather.localTime(weather.updatedAtUtc)}',
                        style: const TextStyle(fontSize: 10, color: _muted),
                      ),
                    ),
                    Tooltip(
                      message: 'Atualizar tempo',
                      child: IconButton(
                        onPressed: loading ? null : onRefresh,
                        icon: loading
                            ? const SizedBox.square(
                                dimension: 15,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                ),
                              )
                            : const Icon(
                                Icons.refresh_rounded,
                                size: 18,
                                color: _muted,
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _Metric(
                icon: Icons.water_drop_outlined,
                label: 'Umidade',
                value: _value(weather.humidity, '%'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Metric(
                icon: Icons.air_rounded,
                label: 'Vento',
                value: _value(
                  weather.windSpeed == null ? null : weather.windSpeed! * 3.6,
                  ' km/h',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _ForecastPreview(demo: demo, localDate: local),
        const SizedBox(height: 16),
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: const EdgeInsets.only(top: 4, bottom: 12),
            iconColor: _muted,
            collapsedIconColor: _muted,
            title: const Text(
              'Mais detalhes de hoje',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            children: [
              _DetailRow('Pressão', _value(weather.pressure, ' hPa')),
              _DetailRow(
                'Visibilidade',
                _value(
                  weather.visibility == null
                      ? null
                      : weather.visibility! / 1000,
                  ' km',
                  decimals:
                      weather.visibility != null &&
                          weather.visibility! % 1000 != 0
                      ? 1
                      : 0,
                ),
              ),
              _DetailRow(
                'Nascer do sol',
                weather.localTime(weather.sunriseUtc),
              ),
              _DetailRow('Pôr do sol', weather.localTime(weather.sunsetUtc)),
            ],
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Fonte: OpenWeather',
          style: TextStyle(fontSize: 10, color: _muted),
        ),
      ],
    );
  }
}

class _ForecastPreview extends StatelessWidget {
  const _ForecastPreview({required this.demo, required this.localDate});
  final bool demo;
  final DateTime localDate;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Row(
        children: [
          Expanded(
            child: Text(
              'Próximos 7 dias',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          Text('Em breve', style: TextStyle(fontSize: 11, color: _muted)),
        ],
      ),
      const SizedBox(height: 12),
      if (demo) ...[
        _ForecastRow(
          label: 'Hoje',
          date: _shortDate(localDate),
          code: 802,
          chance: '40%',
          temperatures: '18° / 27°',
          highlighted: true,
        ),
        _ForecastRow(
          label: 'Amanhã',
          date: _shortDate(localDate.add(const Duration(days: 1))),
          code: 500,
          chance: '70%',
          temperatures: '17° / 26°',
        ),
      ] else
        _Panel(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 23,
                  color: _muted,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'A previsão dos próximos dias estará disponível em breve.',
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.6,
                      color: _muted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
    ],
  );
}

class _ForecastRow extends StatelessWidget {
  const _ForecastRow({
    required this.label,
    required this.date,
    required this.code,
    required this.chance,
    required this.temperatures,
    this.highlighted = false,
  });
  final String label;
  final String date;
  final int code;
  final String chance;
  final String temperatures;
  final bool highlighted;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    decoration: BoxDecoration(
      color: highlighted ? _surface : Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(date, style: const TextStyle(fontSize: 10, color: _muted)),
            ],
          ),
        ),
        WeatherIcon(conditionId: code, size: 23),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: Text(
            chance,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: _muted),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            temperatures,
            textAlign: TextAlign.end,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => _Panel(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 19, color: _muted),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: _muted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            value,
            style: TextStyle(
              fontSize: value == 'Não informado' ? 13 : 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}

class _ErrorContent extends StatelessWidget {
  const _ErrorContent({
    required this.message,
    required this.weather,
    required this.onRetry,
  });
  final String message;
  final CurrentWeather? weather;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const SizedBox(height: 46),
      const Icon(Icons.wifi_off_rounded, size: 25, color: _ink),
      const SizedBox(height: 44),
      const Text(
        'Não conseguimos\natualizar o tempo.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
      ),
      const SizedBox(height: 16),
      Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 13, color: _muted, height: 1.6),
      ),
      const SizedBox(height: 24),
      Center(
        child: FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded, size: 19),
          label: const Text('Tentar novamente'),
        ),
      ),
      if (weather != null) ...[
        const SizedBox(height: 32),
        _Panel(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Eyebrow('Últimos dados disponíveis'),
                const SizedBox(height: 10),
                const Text(
                  'Curitiba, PR',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Text(
                  '${weather!.temperature.round()}°',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Atualizado às ${weather!.localTime(weather!.updatedAtUtc)}',
                  style: const TextStyle(fontSize: 11, color: _muted),
                ),
              ],
            ),
          ),
        ),
      ],
      const SizedBox(height: 26),
      const Text(
        'Tente novamente quando houver conexão.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 11, color: _muted),
      ),
    ],
  );
}

class _LoadingContent extends StatelessWidget {
  const _LoadingContent();

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    label: 'Carregando previsão',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Skeleton(width: 156, height: 14),
        const SizedBox(height: 10),
        const _Skeleton(width: 220, height: 10),
        const SizedBox(height: 20),
        const _Panel(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Skeleton(width: 70, height: 10),
                SizedBox(height: 20),
                _Skeleton(width: 110, height: 65),
                SizedBox(height: 26),
                _Skeleton(width: 210, height: 13),
                SizedBox(height: 10),
                _Skeleton(width: 140, height: 10),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Row(
          children: [
            Expanded(
              child: _Panel(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Skeleton(width: 85, height: 10),
                      SizedBox(height: 12),
                      _Skeleton(width: 55, height: 18),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _Panel(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Skeleton(width: 85, height: 10),
                      SizedBox(height: 12),
                      _Skeleton(width: 55, height: 18),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Text(
            'Carregando previsão…',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: _muted),
          ),
        ),
        const _Panel(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: _Skeleton(width: 210, height: 16),
          ),
        ),
        const SizedBox(height: 10),
        const _Panel(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: _Skeleton(width: 190, height: 16),
          ),
        ),
      ],
    ),
  );
}

class _Skeleton extends StatelessWidget {
  const _Skeleton({required this.width, required this.height});
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE6E7E9),
        borderRadius: BorderRadius.circular(5),
      ),
    ),
  );
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: _surface,
      borderRadius: BorderRadius.circular(16),
    ),
    child: child,
  );
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: _muted,
      letterSpacing: .35,
    ),
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 9),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: _muted),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    ),
  );
}

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation();

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(color: _line)),
    ),
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        child: Row(
          children: [
            _item(Icons.light_mode_outlined, 'Hoje', selected: true),
            _item(Icons.calendar_month_outlined, '7 dias'),
            _item(Icons.location_on_outlined, 'Cidades'),
          ],
        ),
      ),
    ),
  );

  Widget _item(
    IconData icon,
    String label, {
    bool selected = false,
  }) => Expanded(
    child: Semantics(
      selected: selected,
      enabled: selected,
      label: selected ? label : '$label. Em breve.',
      child: Tooltip(
        message: selected ? 'Tempo de hoje' : '$label disponível em breve',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFE9EAEC) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 22, color: selected ? _ink : _muted),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: selected ? _ink : _muted,
                fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

String _value(num? value, String unit, {int decimals = 0}) => value == null
    ? 'Não informado'
    : '${value.toStringAsFixed(decimals).replaceAll('.', ',')}$unit';

const _weekdays = [
  'segunda-feira',
  'terça-feira',
  'quarta-feira',
  'quinta-feira',
  'sexta-feira',
  'sábado',
  'domingo',
];
const _months = [
  'janeiro',
  'fevereiro',
  'março',
  'abril',
  'maio',
  'junho',
  'julho',
  'agosto',
  'setembro',
  'outubro',
  'novembro',
  'dezembro',
];
const _shortMonths = [
  'jan.',
  'fev.',
  'mar.',
  'abr.',
  'mai.',
  'jun.',
  'jul.',
  'ago.',
  'set.',
  'out.',
  'nov.',
  'dez.',
];
String _date(DateTime date) =>
    '${_weekdays[date.weekday - 1]}, ${date.day} de ${_months[date.month - 1]}';
String _shortDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')} ${_shortMonths[date.month - 1]}';
