import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../providers/summary_provider.dart';
import '../widgets/api_key_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isSplitView = false;

  @override
  void initState() {
    super.initState();
    // 检查API密钥是否已设置，如果未设置则显示对话框
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<SummaryProvider>(context, listen: false);
      if (!provider.isApiKeySet) {
        _showApiKeyDialog();
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _showApiKeyDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const ApiKeyDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.auto_stories, size: 28),
            const SizedBox(width: 12),
            const Text('半阅', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: '设置API密钥',
            onPressed: _showApiKeyDialog,
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: IconButton(
                key: ValueKey<bool>(_isSplitView),
                icon: Icon(
                  _isSplitView ? Icons.fullscreen : Icons.splitscreen,
                  size: 24,
                ),
                tooltip: _isSplitView ? '全屏视图' : '分屏视图',
                onPressed: () {
                  setState(() {
                    _isSplitView = !_isSplitView;
                  });
                  // 添加触觉反馈
                  HapticFeedback.lightImpact();
                },
              ),
            ),
          ),
        ],
      ),
      body: Consumer<SummaryProvider>(
        builder: (context, provider, child) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child:
                _isSplitView
                    ? _buildSplitView(provider)
                    : _buildFullView(provider),
          );
        },
      ),
    );
  }

  Widget _buildFullView(SummaryProvider provider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.surface,
            colorScheme.surfaceContainerHighest.withAlpha(76),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Input Card
              Card(
                elevation: 2,
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.edit_note, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            '输入文本',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInputSection(provider),
                      const SizedBox(height: 16),
                      _buildReasoningEffortSelector(provider),
                      const SizedBox(height: 16),
                      _buildGenerateButton(provider),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Output Card
              Expanded(
                child: Card(
                  elevation: 2,
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.summarize, color: colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              '摘要结果',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            if (provider.status == SummaryStatus.success)
                              IconButton(
                                icon: Icon(
                                  Icons.copy,
                                  size: 20,
                                  color: colorScheme.primary,
                                ),
                                tooltip: '复制摘要',
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(text: provider.summaryText),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('摘要已复制到剪贴板')),
                                  );
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Expanded(child: _buildOutputSection(provider)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSplitView(SummaryProvider provider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.surface,
            colorScheme.surfaceContainerHighest.withAlpha(
              76,
            ), // Using withAlpha instead of withOpacity
          ],
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // 左侧：原文
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 2,
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.edit_note, color: colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              '原文',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildInputSection(provider),
                        const SizedBox(height: 16),
                        _buildReasoningEffortSelector(provider),
                        const SizedBox(height: 16),
                        _buildGenerateButton(provider),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 分隔线 - 使用动画效果
            SizedBox(
              width: 8,
              child: Center(
                child: Container(
                  width: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        colorScheme.primary.withAlpha(50),
                        colorScheme.primary,
                        colorScheme.primary.withAlpha(50),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ),

            // 右侧：摘要
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 2,
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.summarize, color: colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              '摘要',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            if (provider.status == SummaryStatus.success)
                              IconButton(
                                icon: Icon(
                                  Icons.copy,
                                  size: 20,
                                  color: colorScheme.primary,
                                ),
                                tooltip: '复制摘要',
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(text: provider.summaryText),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('摘要已复制到剪贴板')),
                                  );
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Expanded(child: _buildOutputSection(provider)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection(SummaryProvider provider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextField(
      controller: _textController,
      maxLines: 5,
      style: theme.textTheme.bodyMedium,
      decoration: InputDecoration(
        hintText: '输入文本...',
        hintStyle: TextStyle(color: Colors.grey.shade500),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        filled: true,
        fillColor:
            theme.brightness == Brightness.light
                ? Colors.grey.shade50
                : Colors.grey.shade900,
        contentPadding: const EdgeInsets.all(16),
        suffixIcon: AnimatedOpacity(
          opacity: _textController.text.isNotEmpty ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: IconButton(
            icon: const Icon(Icons.clear),
            tooltip: '清除文本',
            onPressed: () {
              _textController.clear();
              provider.reset();
              // 添加触觉反馈
              HapticFeedback.lightImpact();
            },
          ),
        ),
      ),
      onChanged: (value) {
        setState(() {}); // 更新UI以显示/隐藏清除按钮
        provider.setOriginalText(value);
      },
    );
  }

  Widget _buildReasoningEffortSelector(SummaryProvider provider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.tune, size: 18, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              '推理深度：',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: SegmentedButton<ReasoningEffort>(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color>((
                Set<MaterialState> states,
              ) {
                if (states.contains(MaterialState.selected)) {
                  return colorScheme.primary;
                }
                return Colors.transparent;
              }),
              foregroundColor: MaterialStateProperty.resolveWith<Color>((
                Set<MaterialState> states,
              ) {
                if (states.contains(MaterialState.selected)) {
                  return colorScheme.onPrimary;
                }
                return colorScheme.onSurface;
              }),
              side: MaterialStateProperty.all(BorderSide.none),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            segments: [
              ButtonSegment(
                value: ReasoningEffort.low,
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.speed,
                      size: 16,
                      color:
                          provider.reasoningEffort == ReasoningEffort.low
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface.withOpacity(0.7),
                    ),
                    const SizedBox(width: 4),
                    const Text('低'),
                  ],
                ),
              ),
              ButtonSegment(
                value: ReasoningEffort.medium,
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.speed,
                      size: 16,
                      color:
                          provider.reasoningEffort == ReasoningEffort.medium
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface.withOpacity(0.7),
                    ),
                    const SizedBox(width: 4),
                    const Text('中'),
                  ],
                ),
              ),
              ButtonSegment(
                value: ReasoningEffort.high,
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.speed,
                      size: 16,
                      color:
                          provider.reasoningEffort == ReasoningEffort.high
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface.withOpacity(0.7),
                    ),
                    const SizedBox(width: 4),
                    const Text('高'),
                  ],
                ),
              ),
            ],
            selected: {provider.reasoningEffort},
            onSelectionChanged: (Set<ReasoningEffort> selection) {
              provider.setReasoningEffort(selection.first);
              // 添加触觉反馈
              HapticFeedback.selectionClick();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGenerateButton(SummaryProvider provider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLoading = provider.status == SummaryStatus.loading;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed:
            isLoading
                ? null
                : () {
                  provider.generateSummary();
                  // 添加触觉反馈
                  HapticFeedback.mediumImpact();
                },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: colorScheme.primary.withAlpha(120),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            );
          },
          child:
              isLoading
                  ? SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.onPrimary,
                      ),
                    ),
                  )
                  : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '生成摘要',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }

  Widget _buildOutputSection(SummaryProvider provider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (provider.status == SummaryStatus.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error, size: 48),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withAlpha(50),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.error.withAlpha(100),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    '发生错误',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.errorMessage,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('重试'),
              onPressed: () {
                provider.reset();
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                side: BorderSide(color: colorScheme.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (provider.status == SummaryStatus.initial) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.text_snippet_outlined,
              size: 64,
              color: colorScheme.primary.withAlpha(100),
            ),
            const SizedBox(height: 24),
            Text(
              '等待生成摘要',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface.withAlpha(180),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '输入文本并点击"生成摘要"按钮',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withAlpha(150),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            theme.brightness == Brightness.light
                ? Colors.grey.shade50
                : Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              theme.brightness == Brightness.light
                  ? Colors.grey.shade200
                  : Colors.grey.shade800,
        ),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Text(
          provider.summaryText,
          style: theme.textTheme.bodyLarge?.copyWith(
            height: 1.5,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
