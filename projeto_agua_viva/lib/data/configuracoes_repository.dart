import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/entities/configuracoes.dart';
import '../domain/entities/sensor_info.dart';

/// Lê e grava [Configuracoes] no [SharedPreferences], com fallback seguro em
/// memória caso o armazenamento nativo falhe ou demore para inicializar.
class ConfiguracoesRepository {
  static const _host = 'cfg_host';
  static const _porta = 'cfg_porta';
  static const _manterConexao = 'cfg_manter_conexao';
  static const _janela = 'cfg_janela_min';
  static const _pontos = 'cfg_pontos_relatorio';
  static const _aviso = 'cfg_aviso_ausencia';
  static const _ausencia = 'cfg_ausencia_min';
  static const _tema = 'cfg_tema';
  static const _escala = 'cfg_escala_auto';
  static const _modoAcessibilidade = 'cfg_modo_acessibilidade';
  static const _tutorialConcluido = 'cfg_tutorial_concluido';

  static String _chaveFaixaMin(TipoSensor s) => 'cfg_faixa_${s.id}_min';
  static String _chaveFaixaMax(TipoSensor s) => 'cfg_faixa_${s.id}_max';

  static const _chavesBase = [
    _host, _porta, _manterConexao, _janela, _pontos,
    _aviso, _ausencia, _tema, _escala, _modoAcessibilidade,
  ];

  final SharedPreferences? _prefs;
  final Map<String, Object> _memoria = {};

  ConfiguracoesRepository([this._prefs]);

  /// Inicializa o [SharedPreferences] com proteção contra exceções nativas/JNI
  /// e limite de tempo para nunca bloquear o `runApp()`.
  static Future<ConfiguracoesRepository> inicializarSeguro({
    Future<SharedPreferences> Function()? carregador,
    Duration timeout = const Duration(seconds: 3),
  }) async {
    try {
      final prefs = await (carregador ?? SharedPreferences.getInstance)()
          .timeout(timeout);
      return ConfiguracoesRepository(prefs);
    } catch (e, st) {
      debugPrint(
        'Aviso: falha ao inicializar SharedPreferences; usando fallback em memória: $e\n$st',
      );
      return ConfiguracoesRepository(null);
    }
  }

  bool? _lerBool(String chave) {
    try {
      final v = _prefs?.getBool(chave);
      if (v != null) return v;
    } catch (_) {}
    final mem = _memoria[chave];
    return mem is bool ? mem : null;
  }

  int? _lerInt(String chave) {
    try {
      final v = _prefs?.getInt(chave);
      if (v != null) return v;
    } catch (_) {}
    final mem = _memoria[chave];
    return mem is int ? mem : null;
  }

  double? _lerDouble(String chave) {
    try {
      final v = _prefs?.getDouble(chave);
      if (v != null) return v;
    } catch (_) {}
    final mem = _memoria[chave];
    return mem is double ? mem : null;
  }

  String? _lerString(String chave) {
    try {
      final v = _prefs?.getString(chave);
      if (v != null) return v;
    } catch (_) {}
    final mem = _memoria[chave];
    return mem is String ? mem : null;
  }

  Future<bool> _gravarBool(String chave, bool valor) async {
    _memoria[chave] = valor;
    try {
      final p = _prefs;
      if (p != null) return await p.setBool(chave, valor);
    } catch (_) {}
    return true;
  }

  Future<bool> _gravarInt(String chave, int valor) async {
    _memoria[chave] = valor;
    try {
      final p = _prefs;
      if (p != null) return await p.setInt(chave, valor);
    } catch (_) {}
    return true;
  }

  Future<bool> _gravarDouble(String chave, double valor) async {
    _memoria[chave] = valor;
    try {
      final p = _prefs;
      if (p != null) return await p.setDouble(chave, valor);
    } catch (_) {}
    return true;
  }

  Future<bool> _gravarString(String chave, String valor) async {
    _memoria[chave] = valor;
    try {
      final p = _prefs;
      if (p != null) return await p.setString(chave, valor);
    } catch (_) {}
    return true;
  }

  Future<bool> _removerChave(String chave) async {
    _memoria.remove(chave);
    try {
      final p = _prefs;
      if (p != null) return await p.remove(chave);
    } catch (_) {}
    return true;
  }

  /// Indica se o usuário já visualizou a tela de boas-vindas/tutorial inicial.
  bool get tutorialConcluido => _lerBool(_tutorialConcluido) ?? false;

  /// Salva que o usuário já concluiu o tutorial inicial.
  Future<void> marcarTutorialConcluido() =>
      _gravarBool(_tutorialConcluido, true);

  /// Carrega as preferências. Valores ausentes ou inválidos (ex.: de uma
  /// versão antiga) caem no padrão.
  Configuracoes carregar() {
    const d = Configuracoes();

    int opcao(String chave, List<int> opcoes, int padrao) {
      final v = _lerInt(chave);
      return v != null && opcoes.contains(v) ? v : padrao;
    }

    final host = _lerString(_host);
    final porta = _lerInt(_porta);
    final tema = _lerString(_tema);

    final faixas = <TipoSensor, FaixaIdealSensor>{};
    for (final s in TipoSensor.values) {
      final min = _lerDouble(_chaveFaixaMin(s));
      final max = _lerDouble(_chaveFaixaMax(s));
      if (min != null && max != null && s.validarFaixa(min, max) == null) {
        final f = FaixaIdealSensor(min: min, max: max);
        if (f != s.faixaPadrao) {
          faixas[s] = f;
        }
      }
    }

    return Configuracoes(
      host: host != null && Configuracoes.validarHost(host) == null
          ? host
          : d.host,
      porta: porta != null && Configuracoes.validarPorta('$porta') == null
          ? porta
          : d.porta,
      manterConexaoEmSegundoPlano:
          _lerBool(_manterConexao) ?? d.manterConexaoEmSegundoPlano,
      janelaAoVivoMin:
          opcao(_janela, Configuracoes.opcoesJanelaMin, d.janelaAoVivoMin),
      maxPontosRelatorio: opcao(
          _pontos, Configuracoes.opcoesPontosRelatorio, d.maxPontosRelatorio),
      avisoAusencia: _lerBool(_aviso) ?? d.avisoAusencia,
      limiteAusenciaMin: opcao(
          _ausencia, Configuracoes.opcoesAusenciaMin, d.limiteAusenciaMin),
      tema: TemaApp.values.asNameMap()[tema] ?? d.tema,
      escalaAutomatica: _lerBool(_escala) ?? d.escalaAutomatica,
      modoAcessibilidade:
          _lerBool(_modoAcessibilidade) ?? d.modoAcessibilidade,
      faixasIdeais: Map.unmodifiable(faixas),
    );
  }

  Future<void> salvar(Configuracoes c) async {
    final operacoes = <Future<bool>>[
      _gravarString(_host, c.host),
      _gravarInt(_porta, c.porta),
      _gravarBool(_manterConexao, c.manterConexaoEmSegundoPlano),
      _gravarInt(_janela, c.janelaAoVivoMin),
      _gravarInt(_pontos, c.maxPontosRelatorio),
      _gravarBool(_aviso, c.avisoAusencia),
      _gravarInt(_ausencia, c.limiteAusenciaMin),
      _gravarString(_tema, c.tema.name),
      _gravarBool(_escala, c.escalaAutomatica),
      _gravarBool(_modoAcessibilidade, c.modoAcessibilidade),
    ];

    for (final s in TipoSensor.values) {
      final f = c.faixasIdeais[s];
      if (f != null && f != s.faixaPadrao) {
        operacoes.add(_gravarDouble(_chaveFaixaMin(s), f.min));
        operacoes.add(_gravarDouble(_chaveFaixaMax(s), f.max));
      } else {
        operacoes.add(_removerChave(_chaveFaixaMin(s)));
        operacoes.add(_removerChave(_chaveFaixaMax(s)));
      }
    }

    await Future.wait(operacoes);
  }

  Future<void> limpar() async {
    final chavesFaixas = [
      for (final s in TipoSensor.values) ...[
        _chaveFaixaMin(s),
        _chaveFaixaMax(s),
      ],
    ];
    await Future.wait([
      ..._chavesBase.map(_removerChave),
      ...chavesFaixas.map(_removerChave),
    ]);
  }
}
