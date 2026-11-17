import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/esp32_websocket_service.dart';
import '../../domain/entities/configuracoes.dart';
import '../../domain/entities/sensor_info.dart';
import '../cubit/configuracoes_cubit.dart';
import '../theme/app_theme.dart';
import '../widgets/dialogo_bioglow.dart';
import '../widgets/faixa_sensor_dialog.dart';
import 'onboarding_screen.dart';

class ConfiguracoesScreen extends StatelessWidget {
  const ConfiguracoesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ConfiguracoesCubit>();
    final scheme = Theme.of(context).colorScheme;
    final cores = CoresBioglow.of(context);
    final resp = Responsivo.of(context);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: resp.alturaAppBar,
        title: const Row(
          children: [
            IconePng(IconesApp.settings, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text('Configurações', maxLines: 1),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Voltar ao Início',
            icon: const IconePng(IconesApp.home, size: 20),
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ],
      ),
      body: BlocBuilder<ConfiguracoesCubit, Configuracoes>(
        builder: (context, c) => ListView(
          padding: resp.paddingLista(topo: 12, base: 32),
          children: [
            // ---------------------------------------------------------
            // 1. Conexão com a boia
            // ---------------------------------------------------------
            const _Secao(
              titulo: 'Conexão com a boia',
              icone: Icons.wifi_tethering_rounded,
            ),
            _CardConfiguracao(
              children: [
                const _TileStatusConexao(),
                const _DivisorCard(),
                ListTile(
                  leading: _IconeConfiguracao(
                    icone: Icons.router_outlined,
                    cor: scheme.primary,
                  ),
                  title: const Text(
                    'Endereço da boia',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    c.url,
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest.withValues(
                        alpha: 0.45,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: scheme.primary,
                    ),
                  ),
                  onTap: () => _editarEndereco(context, c),
                ),
                const _DivisorCard(),
                SwitchListTile(
                  secondary: _IconeConfiguracao(
                    icone: Icons.battery_saver_outlined,
                    cor: scheme.secondary,
                  ),
                  title: const Text(
                    'Manter conexão em segundo plano',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    c.manterConexaoEmSegundoPlano
                        ? 'Recebe leituras com o app minimizado (gasta mais bateria)'
                        : 'Desconecta após 30 s fora do app para poupar bateria',
                  ),
                  value: c.manterConexaoEmSegundoPlano,
                  onChanged: cubit.definirManterConexao,
                ),
              ],
            ),

            // ---------------------------------------------------------
            // 2. Ao vivo
            // ---------------------------------------------------------
            const _Secao(
              titulo: 'Ao vivo',
              icone: Icons.show_chart_rounded,
            ),
            _CardConfiguracao(
              children: [
                _ListTileOpcoes<int>(
                  icone: Icons.timeline,
                  assetIconePng: IconesApp.sliders,
                  cor: scheme.primary,
                  titulo: 'Janela do gráfico',
                  descricao: 'Quanto tempo de leituras fica visível',
                  valor: c.janelaAoVivoMin,
                  opcoes: Configuracoes.opcoesJanelaMin,
                  rotulo: (v) => '$v min',
                  onChanged: cubit.definirJanelaAoVivo,
                ),
              ],
            ),

            // ---------------------------------------------------------
            // 3. Relatório do cartão SD
            // ---------------------------------------------------------
            const _Secao(
              titulo: 'Relatório do cartão SD',
              icone: Icons.sd_card_outlined,
            ),
            _CardConfiguracao(
              children: [
                _ListTileOpcoes<int>(
                  icone: Icons.scatter_plot_outlined,
                  assetIconePng: IconesApp.chart,
                  cor: scheme.primary,
                  titulo: 'Pontos no gráfico',
                  descricao: 'Mais pontos = mais detalhe, download mais lento',
                  valor: c.maxPontosRelatorio,
                  opcoes: Configuracoes.opcoesPontosRelatorio,
                  rotulo: (v) => '$v',
                  onChanged: cubit.definirMaxPontosRelatorio,
                ),
                const _DivisorCard(),
                SwitchListTile(
                  secondary: _IconeConfiguracao(
                    icone: Icons.notifications_active_outlined,
                    cor: cores.alerta,
                  ),
                  title: const Text(
                    'Avisar ao voltar ao app',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Mostra quantos dados a boia gravou enquanto você esteve fora',
                  ),
                  value: c.avisoAusencia,
                  onChanged: cubit.definirAvisoAusencia,
                ),
                const _DivisorCard(),
                _ListTileOpcoes<int>(
                  icone: Icons.timer_outlined,
                  cor: scheme.secondary,
                  titulo: 'Tempo fora para avisar',
                  valor: c.limiteAusenciaMin,
                  opcoes: Configuracoes.opcoesAusenciaMin,
                  rotulo: (v) => v >= 60 ? '${v ~/ 60} h' : '$v min',
                  onChanged:
                      c.avisoAusencia ? cubit.definirLimiteAusencia : null,
                ),
              ],
            ),

            // ---------------------------------------------------------
            // 4. Aparência
            // ---------------------------------------------------------
            const _Secao(
              titulo: 'Aparência',
              icone: Icons.palette_outlined,
            ),
            _CardConfiguracao(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _IconeConfiguracao(
                            icone: Icons.brightness_6_outlined,
                            cor: scheme.primary,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tema do aplicativo',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  'Escolha entre claro para sol intenso ou escuro',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _SeletorTemaCards(
                        temaAtual: c.tema,
                        onChanged: cubit.definirTema,
                      ),
                    ],
                  ),
                ),
                const _DivisorCard(),
                SwitchListTile(
                  secondary: _IconeConfiguracao(
                    icone: Icons.accessibility_new_rounded,
                    cor: scheme.tertiary,
                  ),
                  title: const Text(
                    'Modo Acessibilidade (Fontes Grandes)',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    c.modoAcessibilidade
                        ? 'Fontes ampliadas ativas para melhor visualização'
                        : 'Amplia todas as fontes do app para facilitar a leitura',
                  ),
                  value: c.modoAcessibilidade,
                  onChanged: cubit.definirModoAcessibilidade,
                ),
                const _DivisorCard(),
                SwitchListTile(
                  secondary: _IconeConfiguracao(
                    assetIconePng: IconesApp.sliders,
                    cor: scheme.primary,
                  ),
                  title: const Text(
                    'Escala automática nos gráficos',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    c.escalaAutomatica
                        ? 'Eixo vertical ajustado aos valores medidos'
                        : 'Eixo vertical fixo na escala total de cada sensor',
                  ),
                  value: c.escalaAutomatica,
                  onChanged: cubit.definirEscalaAutomatica,
                ),
              ],
            ),

            // ---------------------------------------------------------
            // 5. Faixas Ideais e Sensores da Boia
            // ---------------------------------------------------------
            const _Secao(
              titulo: 'Faixas Ideais e Sensores da Boia',
              icone: Icons.tune_rounded,
            ),
            _CardConfiguracao(
              children: [
                ListTile(
                  leading: _IconeConfiguracao(
                    icone: Icons.tune_rounded,
                    cor: scheme.primary,
                  ),
                  title: const Text(
                    'Definir todas as faixas ideais',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    c.possuiAlgumaFaixaPersonalizada
                        ? 'Alguns sensores usam valores personalizados pelo usuário'
                        : 'Configurar valor mínimo e máximo ideal dos 4 sensores',
                  ),
                  trailing: c.possuiAlgumaFaixaPersonalizada
                      ? TextButton(
                          onPressed: () async {
                            await cubit.restaurarTodasFaixasPadrao();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Faixas dos sensores restauradas para os valores comuns.',
                                ),
                              ),
                            );
                          },
                          child: const Text('Usar comuns'),
                        )
                      : Icon(
                          Icons.chevron_right_rounded,
                          color: scheme.onSurfaceVariant,
                        ),
                  onTap: () => mostrarDialogoTodasFaixasSensores(context),
                ),
                for (final s in TipoSensor.values) ...[
                  const _DivisorCard(),
                  ListTile(
                    leading: _IconeConfiguracao(
                      icone: iconeDoSensor(s),
                      cor: cores.corDoSensor(s),
                    ),
                    title: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Text(
                          s.nome,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        if (c.temFaixaPersonalizada(s))
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: cores
                                  .corDoSensor(s)
                                  .withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: cores
                                    .corDoSensor(s)
                                    .withValues(alpha: 0.35),
                              ),
                            ),
                            child: Text(
                              'Personalizada',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: cores.corDoSensor(s),
                              ),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Text(
                      '${c.descricaoFaixaDoSensor(s)} • Unidade: ${s.unidade}',
                    ),
                    trailing: Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: cores.corDoSensor(s),
                    ),
                    onTap: () => mostrarDialogoFaixaSensor(context, s),
                  ),
                ],
                const _DivisorCard(),
                ListTile(
                  leading: _IconeConfiguracao(
                    assetIconePng: IconesApp.help,
                    cor: scheme.primary,
                  ),
                  title: const Text(
                    'Tutorial do aplicativo',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Rever apresentação dos sensores, tabelas, gráficos e cartão SD',
                  ),
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: scheme.onSurfaceVariant,
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => OnboardingScreen(
                        modoRevisao: true,
                        onConcluir: () => Navigator.of(ctx).pop(),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ---------------------------------------------------------
            // 6. Sobre
            // ---------------------------------------------------------
            const _Secao(
              titulo: 'Sobre',
              icone: Icons.info_outline_rounded,
            ),
            _CardConfiguracao(
              children: [
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              scheme.primary.withValues(alpha: 0.22),
                              scheme.primary.withValues(alpha: 0.08),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: scheme.primary.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Image.asset(
                          kAssetBoiaBioglow,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Água Viva Estação Flutuante',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Versão 0.3.0 • Estação Multiparamétrica (ESP32)',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ---------------------------------------------------------
            // 7. Restaurar padrões
            // ---------------------------------------------------------
            const SizedBox(height: 20),
            Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: scheme.error.withValues(alpha: 0.35),
                ),
              ),
              child: ListTile(
                leading: _IconeConfiguracao(
                  icone: Icons.restore_rounded,
                  cor: scheme.error,
                ),
                title: Text(
                  'Restaurar padrões',
                  style: TextStyle(
                    color: scheme.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: const Text(
                  'Volta conexão, aparência e faixas ideais aos valores originais',
                ),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: scheme.error.withValues(alpha: 0.75),
                ),
                onTap: () => _confirmarRestaurar(context),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _editarEndereco(BuildContext context, Configuracoes c) async {
    final resultado = await showDialog<(String, int)>(
      context: context,
      builder: (_) => _DialogoEndereco(host: c.host, porta: c.porta),
    );
    if (resultado == null || !context.mounted) return;
    final (host, porta) = resultado;
    context.read<ConfiguracoesCubit>().definirEndereco(host, porta);
  }

  Future<void> _confirmarRestaurar(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final scheme = Theme.of(ctx).colorScheme;
        return DialogoBioglow(
          corDestaque: scheme.primary,
          icone: Icon(Icons.restore_rounded, color: scheme.primary, size: 22),
          titulo: 'Restaurar padrões?',
          subtitulo: 'Redefinir preferências do aplicativo',
          corpo: Text(
            'Todas as configurações de conexão, aparência e faixas ideais voltarão aos valores originais.',
            style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          acaoCancelar: OutlinedButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          acaoConfirmar: FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Restaurar'),
          ),
        );
      },
    );
    if (ok != true || !context.mounted) return;
    await context.read<ConfiguracoesCubit>().restaurarPadroes();
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Configurações restauradas.')));
  }
}

class _CardConfiguracao extends StatelessWidget {
  final List<Widget> children;

  const _CardConfiguracao({required this.children});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: scheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

class _DivisorCard extends StatelessWidget {
  const _DivisorCard();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 66,
      color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.35),
    );
  }
}

class _IconeConfiguracao extends StatelessWidget {
  final IconData? icone;
  final String? assetIconePng;
  final Color cor;

  const _IconeConfiguracao({
    this.icone,
    this.assetIconePng,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: cor.withValues(alpha: 0.28)),
      ),
      child: Center(
        child: assetIconePng != null
            ? IconePng(assetIconePng!, size: 19, color: cor)
            : Icon(icone, size: 20, color: cor),
      ),
    );
  }
}

class _SeletorTemaCards extends StatelessWidget {
  final TemaApp temaAtual;
  final ValueChanged<TemaApp> onChanged;

  const _SeletorTemaCards({required this.temaAtual, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const opcoes = [
      (TemaApp.sistema, Icons.brightness_auto_outlined, 'Sistema'),
      (TemaApp.claro, Icons.light_mode_outlined, 'Claro'),
      (TemaApp.escuro, Icons.dark_mode_outlined, 'Escuro'),
    ];

    return Row(
      children: [
        for (var i = 0; i < opcoes.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: Builder(
              builder: (context) {
                final (valor, icone, rotulo) = opcoes[i];
                final selecionado = valor == temaAtual;
                return InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => onChanged(valor),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: selecionado
                          ? scheme.secondaryContainer
                          : scheme.surfaceContainerHighest.withValues(
                              alpha: 0.25,
                            ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selecionado
                            ? scheme.primary
                            : scheme.outlineVariant.withValues(alpha: 0.55),
                        width: selecionado ? 1.5 : 1.0,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          icone,
                          size: 20,
                          color: selecionado
                              ? scheme.onSecondaryContainer
                              : scheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 6),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            rotulo,
                            maxLines: 1,
                            softWrap: false,
                            style: TextStyle(
                              fontWeight: selecionado
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: selecionado
                                  ? scheme.onSecondaryContainer
                                  : scheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _Secao extends StatelessWidget {
  final String titulo;
  final IconData icone;
  const _Secao({required this.titulo, required this.icone});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
      child: Semantics(
        header: true,
        child: Row(
          children: [
            Icon(icone, size: 17, color: scheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                titulo,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TileStatusConexao extends StatelessWidget {
  const _TileStatusConexao();

  @override
  Widget build(BuildContext context) {
    final service = context.read<Esp32WebSocketService>();
    final cores = CoresBioglow.of(context);

    return StreamBuilder<StatusConexao>(
      stream: service.status,
      initialData: service.statusAtual,
      builder: (context, snapshot) {
        final status = snapshot.data ?? StatusConexao.desconectado;
        final (icone, cor, texto) = switch (status) {
          StatusConexao.conectado => (
            Icons.check_circle_outline,
            cores.ok,
            'Conectado à boia',
          ),
          StatusConexao.conectando => (
            Icons.sync,
            cores.alerta,
            'Conectando à boia...',
          ),
          StatusConexao.desconectado => (
            Icons.error_outline,
            cores.erro,
            'Desconectado da boia',
          ),
        };

        return ListTile(
          leading: _IconeConfiguracao(icone: icone, cor: cor),
          title: Text(
            texto,
            style: TextStyle(color: cor, fontWeight: FontWeight.w700),
          ),
          subtitle: const Text('Toque para testar ou reconectar'),
          trailing: FilledButton.tonalIcon(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              visualDensity: VisualDensity.compact,
            ),
            onPressed: () => service.reconectar(),
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Testar'),
          ),
          onTap: () => service.reconectar(),
        );
      },
    );
  }
}

/// ListTile com um menu suspenso estilizado de opções à direita.
class _ListTileOpcoes<T> extends StatelessWidget {
  final IconData icone;
  final String? assetIconePng;
  final Color cor;
  final String titulo;
  final String? descricao;
  final T valor;
  final List<T> opcoes;
  final String Function(T) rotulo;
  final ValueChanged<T>? onChanged;

  const _ListTileOpcoes({
    required this.icone,
    this.assetIconePng,
    required this.cor,
    required this.titulo,
    this.descricao,
    required this.valor,
    required this.opcoes,
    required this.rotulo,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final habilitado = onChanged != null;
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      enabled: habilitado,
      leading: _IconeConfiguracao(
        icone: icone,
        assetIconePng: assetIconePng,
        cor: habilitado ? cor : scheme.outline,
      ),
      title: Text(
        titulo,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: descricao == null ? null : Text(descricao!),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(
            alpha: habilitado ? 0.55 : 0.25,
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: DropdownButton<T>(
          value: valor,
          isDense: true,
          borderRadius: BorderRadius.circular(12),
          underline: const SizedBox.shrink(),
          onChanged:
              habilitado ? (v) => v == null ? null : onChanged!(v) : null,
          items: [
            for (final o in opcoes)
              DropdownMenuItem(value: o, child: Text(rotulo(o))),
          ],
        ),
      ),
    );
  }
}

class _DialogoEndereco extends StatefulWidget {
  final String host;
  final int porta;
  const _DialogoEndereco({required this.host, required this.porta});

  @override
  State<_DialogoEndereco> createState() => _DialogoEnderecoState();
}

class _DialogoEnderecoState extends State<_DialogoEndereco> {
  final _form = GlobalKey<FormState>();
  late final _host = TextEditingController(text: widget.host);
  late final _porta = TextEditingController(text: '${widget.porta}');

  @override
  void dispose() {
    _host.dispose();
    _porta.dispose();
    super.dispose();
  }

  void _salvar() {
    if (!_form.currentState!.validate()) return;
    Navigator.of(
      context,
    ).pop((_host.text.trim(), int.parse(_porta.text.trim())));
  }

  void _padrao() {
    _host.text = Configuracoes.hostPadrao;
    _porta.text = '${Configuracoes.portaPadrao}';
    _form.currentState?.validate();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DialogoBioglow(
      corDestaque: scheme.primary,
      icone: Icon(Icons.router_outlined, color: scheme.primary, size: 22),
      titulo: 'Endereço da boia',
      subtitulo: 'Conexão WebSocket local (Wi-Fi)',
      corpo: Form(
        key: _form,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.32),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: scheme.outlineVariant.withValues(alpha: 0.45),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.wifi_tethering_rounded,
                    size: 16,
                    color: scheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Padrão da boia: ws://${Configuracoes.hostPadrao}:${Configuracoes.portaPadrao}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _host,
              autofocus: true,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.next,
              scrollPadding: const EdgeInsets.only(bottom: 84),
              decoration: DialogoBioglow.decoracaoCampo(
                context,
                label: 'IP ou nome',
                hint: Configuracoes.hostPadrao,
                prefixText: 'ws://',
              ),
              validator: Configuracoes.validarHost,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _porta,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              scrollPadding: const EdgeInsets.only(bottom: 84),
              decoration: DialogoBioglow.decoracaoCampo(
                context,
                label: 'Porta',
                hint: '${Configuracoes.portaPadrao}',
              ),
              validator: Configuracoes.validarPorta,
              onFieldSubmitted: (_) => _salvar(),
            ),
          ],
        ),
      ),
      acaoEsquerda: TextButton.icon(
        onPressed: _padrao,
        icon: const Icon(Icons.restart_alt_rounded, size: 17),
        label: const Text('Padrão'),
      ),
      acaoCancelar: OutlinedButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancelar'),
      ),
      acaoConfirmar: FilledButton.icon(
        onPressed: _salvar,
        icon: const Icon(Icons.check_rounded, size: 18),
        label: const Text('Salvar'),
      ),
    );
  }
}
