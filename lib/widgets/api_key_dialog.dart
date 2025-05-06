import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/summary_provider.dart';

class ApiKeyDialog extends StatefulWidget {
  const ApiKeyDialog({Key? key}) : super(key: key);

  @override
  State<ApiKeyDialog> createState() => _ApiKeyDialogState();
}

class _ApiKeyDialogState extends State<ApiKeyDialog> {
  final TextEditingController _apiKeyController = TextEditingController();
  bool _isSubmitting = false;
  String _errorMessage = '';
  bool _isValidInput = false;
  
  @override
  void initState() {
    super.initState();
    _apiKeyController.addListener(_validateInput);
  }
  
  void _validateInput() {
    final apiKey = _apiKeyController.text.trim();
    setState(() {
      _isValidInput = apiKey.length >= 8; // 简单验证API密钥长度
      if (_errorMessage.isNotEmpty && _isValidInput) {
        _errorMessage = '';
      }
    });
  }

  @override
  void dispose() {
    _apiKeyController.removeListener(_validateInput);
    _apiKeyController.dispose();
    super.dispose();
  }

  void _saveApiKey() async {
    final apiKey = _apiKeyController.text.trim();
    if (apiKey.isEmpty) {
      setState(() {
        _errorMessage = 'API密钥不能为空';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = '';
    });

    try {
      await Provider.of<SummaryProvider>(context, listen: false).setApiKey(apiKey);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 标题和图标
            Row(
              children: [
                Icon(Icons.key, color: colorScheme.primary, size: 28),
                const SizedBox(width: 12),
                Text(
                  '设置Gemini API密钥',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // 说明文字
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: colorScheme.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '请输入您的Gemini API密钥以使用摘要生成功能',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () {
                            // 打开获取API密钥的帮助页面
                            // 这里可以使用url_launcher包打开网页
                            // 暂时只显示提示
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('请访问Google AI Studio获取Gemini API密钥'))
                            );
                          },
                          child: Text(
                            '如何获取API密钥？',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // 输入框
            TextField(
              controller: _apiKeyController,
              decoration: InputDecoration(
                labelText: 'API密钥',
                hintText: '输入您的Gemini API密钥',
                prefixIcon: Icon(Icons.vpn_key, color: colorScheme.primary),
                suffixIcon: _apiKeyController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          _isValidInput ? Icons.check_circle : Icons.error_outline,
                          color: _isValidInput ? Colors.green : Colors.orange,
                        ),
                        onPressed: () {
                          if (!_isValidInput) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('API密钥长度应至少为8个字符'))
                            );
                          }
                        },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _apiKeyController.text.isNotEmpty
                        ? (_isValidInput ? Colors.green.withOpacity(0.5) : Colors.orange.withOpacity(0.5))
                        : Colors.grey.withOpacity(0.3),
                  ),
                ),
                filled: true,
                fillColor: colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              ),
              obscureText: true,
              style: theme.textTheme.bodyLarge,
              autofocus: true,
            ),
            // 错误信息
            AnimatedCrossFade(
              firstChild: const SizedBox(height: 0),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              crossFadeState: _errorMessage.isNotEmpty
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),
            const SizedBox(height: 24),
            // 按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isSubmitting ? null : () {
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: Text('取消', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.8))),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isSubmitting || !_isValidInput ? null : _saveApiKey,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('保存'),
                            const SizedBox(width: 6),
                            Icon(Icons.check, size: 18),
                          ],
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}