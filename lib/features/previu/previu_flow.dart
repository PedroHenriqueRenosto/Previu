import 'package:flutter/material.dart';
import '../weather/data/weather_repository.dart';
import '../weather/domain/current_weather.dart';
import 'ui.dart';
import 'pages/welcome_page.dart';
import 'pages/today_page.dart';
import 'pages/week_page.dart';
import 'pages/search_city_page.dart';
import 'pages/day_detail_page.dart';
import 'pages/loading_page.dart';
import 'pages/offline_page.dart';

enum PreviuScreen {
  welcome,
  today,
  week,
  search,
  detail,
  loading,
  offline,
  notFound,
}

class PreviuFlow extends StatefulWidget {
  const PreviuFlow({super.key, required this.repository});
  final WeatherRepository repository;
  @override
  State<PreviuFlow> createState() => _PreviuFlowState();
}

class _PreviuFlowState extends State<PreviuFlow> {
  PreviuScreen screen = PreviuScreen.welcome;
  PreviuScreen previous = PreviuScreen.welcome;
  String city = 'Curitiba, PR';
  CurrentWeather? weather;
  String? error;
  ForecastDay day = ForecastDay.demo[1];
  int request = 0;
  void go(PreviuScreen next) {
    request++;
    setState(() {
      previous = screen;
      screen = next;
    });
  }

  Future<void> load({bool refresh = false}) async {
    final id = ++request;
    setState(() {
      screen = PreviuScreen.loading;
      error = null;
    });
    try {
      if (widget.repository.demo) {
        await Future<void>.delayed(const Duration(milliseconds: 650));
      }
      final value = await widget.repository.current(refresh: refresh);
      if (mounted && id == request) {
        setState(() {
          weather = value;
          screen = PreviuScreen.today;
        });
      }
    } catch (e) {
      if (mounted && id == request) {
        setState(() {
          error = 'Confira sua conexão e a configuração do serviço de clima.';
          screen = PreviuScreen.offline;
        });
      }
    }
  }

  void select(String value) {
    if (!widget.repository.demo && value != 'Curitiba, PR') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'A consulta real está configurada para Curitiba. As outras cidades estão disponíveis na demonstração.',
          ),
        ),
      );
      return;
    }
    city = value;
    load();
  }

  void location() {
    if (widget.repository.demo) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Demonstração: usando Curitiba. O GPS ainda não está conectado.',
          ),
        ),
      );
      select('Curitiba, PR');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'A localização do dispositivo ainda não está integrada. Busque Curitiba para consultar o tempo real.',
          ),
        ),
      );
      go(PreviuScreen.search);
    }
  }

  void detail(ForecastDay value) {
    day = value;
    go(PreviuScreen.detail);
  }

  void back() => go(
    screen == PreviuScreen.detail
        ? PreviuScreen.week
        : previous == PreviuScreen.welcome
        ? PreviuScreen.welcome
        : PreviuScreen.today,
  );
  @override
  void dispose() {
    request++;
    widget.repository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final search =
        screen == PreviuScreen.search || screen == PreviuScreen.notFound;
    final welcome = screen == PreviuScreen.welcome;
    final selected = search
        ? 2
        : screen == PreviuScreen.week || screen == PreviuScreen.detail
        ? 1
        : 0;
    final content = switch (screen) {
      PreviuScreen.welcome => WelcomePage(
        onSearch: () => go(PreviuScreen.search),
        onLocation: location,
      ),
      PreviuScreen.today => TodayPage(
        city: city,
        weather: weather ?? CurrentWeather.preview(),
        demo: widget.repository.demo,
        onWeek: () => go(PreviuScreen.week),
        onDay: detail,
        onRefresh: () => load(refresh: true),
      ),
      PreviuScreen.week => WeekPage(
        city: city,
        demo: widget.repository.demo,
        onDay: detail,
      ),
      PreviuScreen.detail => DayDetailPage(day: day, city: city),
      PreviuScreen.search => SearchCityPage(
        key: const ValueKey('search'),
        onSelect: select,
        onLocation: location,
      ),
      PreviuScreen.notFound => SearchCityPage(
        key: const ValueKey('missing'),
        initialQuery: 'Abcxyz',
        onSelect: select,
        onLocation: location,
      ),
      PreviuScreen.loading => const LoadingPage(),
      PreviuScreen.offline => OfflinePage(
        onRetry: () => load(refresh: true),
        city: city,
        weather: weather,
        message: error,
      ),
    };
    return PopScope(
      canPop: welcome,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          back();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: welcome
            ? null
            : AppBar(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                automaticallyImplyLeading: false,
                title: Row(
                  children: [
                    if (search || screen == PreviuScreen.detail)
                      IconButton(
                        tooltip: 'Voltar',
                        onPressed: back,
                        icon: const Icon(Icons.chevron_left),
                      )
                    else
                      const WeatherIcon(size: 24),
                    const SizedBox(width: 10),
                    const Text(
                      'Previu',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                actions: [
                  if (!search)
                    IconButton(
                      tooltip: 'Buscar cidade',
                      onPressed: () => go(PreviuScreen.search),
                      icon: const Icon(Icons.search),
                    ),
                  if (widget.repository.demo)
                    PopupMenuButton<PreviuScreen>(
                      tooltip: 'Explorar as 8 telas',
                      icon: const Icon(Icons.more_horiz),
                      onSelected: (value) {
                        if (value == PreviuScreen.today) {
                          load();
                        } else {
                          if (value == PreviuScreen.offline) {
                            weather ??= CurrentWeather.preview();
                          }
                          go(value);
                        }
                      },
                      itemBuilder: (_) => PreviuScreen.values
                          .map(
                            (s) => PopupMenuItem(
                              value: s,
                              child: Text(
                                [
                                  '01 Boas-vindas',
                                  '02 Hoje',
                                  '03 Previsão de 7 dias',
                                  '04 Buscar cidade',
                                  '05 Detalhes do dia',
                                  '06 Carregando',
                                  '07 Sem conexão',
                                  '08 Cidade não encontrada',
                                ][s.index],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                ],
              ),
        body: SafeArea(
          child: welcome
              ? content
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                  child: content,
                ),
        ),
        bottomNavigationBar: welcome
            ? null
            : DecoratedBox(
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: line)),
                ),
                child: NavigationBar(
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.white,
                  indicatorColor: const Color(0xFFE9EAEC),
                  selectedIndex: selected,
                  onDestinationSelected: (index) {
                    if (index == 0) {
                      load();
                    } else {
                      go(index == 1 ? PreviuScreen.week : PreviuScreen.search);
                    }
                  },
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.light_mode_outlined),
                      label: 'Hoje',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.calendar_month_outlined),
                      label: '7 dias',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.location_on_outlined),
                      label: 'Cidades',
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
