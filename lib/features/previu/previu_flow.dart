import 'dart:async';
import 'package:flutter/material.dart';
import '../weather/data/weather_repository.dart';
import '../weather/data/weather_service.dart';
import '../weather/data/device_location_service.dart';
import '../weather/domain/weather_city.dart';
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
  WeatherCity selectedCity = WeatherCity.curitiba;
  List<ForecastDay> forecast = [];
  String? forecastError;
  CurrentWeather? weather;
  String? error;
  ForecastDay day = ForecastDay.demo[1];
  int request = 0;
  Timer? refreshTimer;
  bool busy = false;
  @override
  void initState() {
    super.initState();
    if (!widget.repository.demo) {
      refreshTimer = Timer.periodic(const Duration(minutes: 5), (_) {
        if (!busy && weather != null && screen == PreviuScreen.today) { load(refresh: true, silent: true); }
      });
    }
  }
  void go(PreviuScreen next) {
    if (screen == PreviuScreen.loading) {
      request++;
      busy = false;
    }
    setState(() {
      previous = screen;
      screen = next;
    });
  }

  Future<void> load({bool refresh = false, bool silent = false}) async {
    busy = true;
    final id = ++request;
    setState(() {
      if (!silent) screen = PreviuScreen.loading;
      error = null;
    });
    try {
      if (widget.repository.demo) {
        await Future<void>.delayed(const Duration(milliseconds: 650));
      }
      final value = await widget.repository.current(
        refresh: refresh,
        city: selectedCity,
      );
      if (!mounted || id != request) return;
      if (mounted && id == request) {
        setState(() {
          weather = value;
          if (!silent) screen = PreviuScreen.today;
        });
      }
      if (!widget.repository.demo) {
        try {
          final data = await widget.repository.service.fetchForecast(
            selectedCity,
          );
          final days = ForecastDay.fromOpenWeather(data);
          if (mounted && id == request) {
            setState(() {
              forecast = days;
              forecastError = days.isEmpty
                  ? 'Previsão indisponível neste momento.'
                  : null;
            });
          }
        } catch (_) {
          if (mounted && id == request) {
            setState(() {
              forecastError =
                  'Não foi possível atualizar a previsão. Atualize o tempo para tentar novamente.';
            });
          }
        }
      }
    } catch (e) {
      if (mounted && id == request) {
        setState(() {
          error = e is WeatherException
              ? e.message
              : 'Confira sua conexão e a configuração do serviço de clima.';
          if (!silent || screen == PreviuScreen.today) {
            screen = PreviuScreen.offline;
          }
        });
      }
    } finally { if (mounted && id == request) busy = false; }
  }

  void select(WeatherCity value) {
    if (selectedCity.cacheKey != value.cacheKey) {
      weather = null;
      forecast = [];
      forecastError = null;
    }
    selectedCity = value;
    city = value.label;
    load(refresh: true);
  }

  Future<void> location() async {
    if (widget.repository.demo) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Demonstração: usando Curitiba.',
          ),
        ),
      );
      select(WeatherCity.curitiba);
    } else {
      final id = ++request;
      busy = true;
      setState(() => screen = PreviuScreen.loading);
      try {
        final position = await DeviceLocationService().current();
        if (!mounted || id != request) return;
        var value = WeatherCity(name: 'Minha localização', country: '',
            latitude: position.latitude, longitude: position.longitude);
        try {
          value = await widget.repository.service.cityAt(
              position.latitude, position.longitude);
        } catch (_) {
          // Weather can still be requested if the city name is unavailable.
        }
        if (!mounted || id != request) return;
        select(value);
      } catch (e) {
        if (!mounted || id != request) return;
        busy = false;
        go(PreviuScreen.search);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e is WeatherException ? e.message :
              'Não foi possível obter sua localização. Tente buscar uma cidade.'),
          duration: const Duration(seconds: 8),
        ));
      }
    }
  }

  void detail(ForecastDay value) {
    day = value;
    go(PreviuScreen.detail);
  }

  void back() => go(
    screen == PreviuScreen.detail
        ? PreviuScreen.week
        : previous == PreviuScreen.welcome || weather == null
        ? PreviuScreen.welcome
        : PreviuScreen.today,
  );
  @override
  void dispose() {
    refreshTimer?.cancel();
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
        weather: weather!,
        demo: widget.repository.demo,
        onWeek: () => go(PreviuScreen.week),
        onDay: detail,
        onRefresh: () => load(refresh: true),
        forecast: forecast,
        forecastError: forecastError,
        onChangeCity: () => go(PreviuScreen.search),
      ),
      PreviuScreen.week => WeekPage(
        city: city,
        demo: widget.repository.demo,
        onDay: detail,
        forecast: forecast,
        error: forecastError,
      ),
      PreviuScreen.detail => DayDetailPage(
        day: day,
        city: city,
        demo: widget.repository.demo,
        currentWeather: !widget.repository.demo && day.name == 'Hoje' ? weather : null,
        onChangeCity: () => go(PreviuScreen.search),
      ),
      PreviuScreen.search => SearchCityPage(
        key: const ValueKey('search'),
        service: widget.repository.demo ? null : widget.repository.service,
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
                    const Flexible(
                      child: Text(
                        'Previu',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
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
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: welcome
                  ? content
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                      child: content,
                    ),
            ),
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
                  destinations: [
                    const NavigationDestination(
                      icon: Icon(Icons.light_mode_outlined),
                      label: 'Hoje',
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.calendar_month_outlined),
                      label: widget.repository.demo ? '7 dias' : 'Próximos dias',
                    ),
                    const NavigationDestination(
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
